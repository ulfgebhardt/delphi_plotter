(*
// Information / License ///////////////////////////////////////////////////////

 Originally written in March 2005 by tyberis (aka delfiphan)
 Original version can be downloaded here:
  http://www.tyberis.com/download/tyParser.pas

 * This unit can be copied/used/modified without permission by the author.
   Credits appreciated but not required (give credit to "tyberis")
 * Code comes with no warranties whatsoever.
 * Do not alter/remove/separate this information/license from the unit!

 Version 1.2.2

////////////////////////////////////////////////////////////////////////////////
*)

{
- Description ------------------------------------------------------------------

What it does / How it works:
tyParser is a parser for mathematical expressions. It can be used to evaluate
string expressions like "x + 1/2".
The parser takes a mathematical expression as a string and creates a bytecode.
This bytecode can be evaluated very efficiently. To further highten the speed
of the evaluation, the bytecode can be compiled to machine code.

Performance:
The tyParser compiler will create an (almost autonomous) function which can be
run like a regular delphi function. This guarantees top performance!

Safety/Usage:
For easy and safe usage, see examples 1-3. The interface wrapper will take care
of all problems that might arise when using the parser/compiler directly but
will introduce some overhead.
If you need top performance you can use the parser or compiler directly. Please
note that the functions generated directly by the compiler are potentially
unsafe when used incorrectly.
1. Make sure that you always pass the correct number of arguments with the
   correct type.
2. Make sure that you free all functions that you create (using FreeFunc).
See examples 4-7 to find out how to use the parser/compiler directly.

- Examples A - using the interface wrapper (safe but with additional overhead) -
uses ..., tyParser;

Var
 sinc: IExpr1V;
 sinexp: IExpr2V;
 Sum_abc: IExprR;
 Args: array[0..2] of Extended;
 Result: Extended;
begin
 // EXAMPLE 1
 sinc := compileStr1V('sin(x)/x');
 Result := sinc.Eval(1.0);

 // EXAMPLE 2
 sinexp := compileStr2V('sin(x)*exp(y)');
 Result := sinexp.Eval(2.0, 3.0);

 // EXAMPLE 3
 Sum_abc := compileStrR('a+b+c',['a','b','c']);
 Args[0] := 1.0;  // a = 1.0
 Args[1] := 2.0;  // b = 2.0
 Args[2] := 3.0;  // c = 3.0
 Result := Sum_abc.Eval(Args)

 // All functions are freed automatically when out of scope
end;

- Examples B - direct usage, top performance but potentially unsafe ------------
uses ..., tyParser;

Var
 SinC   : ExprFunc1V; // Function(const x : Extended): Extended;
 SinExp : ExprFunc2V; // Function(const x,y : Extended): Extended;
 Sum_abc: ExprFuncR;  // Function(var Args): Extended;
 Expr   : Expression;
 Result : Extended;
 Args: array[0..2] of Extended;
begin
// Examples with compiling
// -----------------------

 // EXAMPLE 4 -- 1 Variable Example (pass by value)
 // -----------------------------------------------
  SinC := CompileExpr(ParseExpr('sin(x)/x',['x']),tyPass1V);    // parse and compile expression
  Result := SinC(1.0);                                          // evaluate the Expression
  FreeFunc(@SinC);                                              // Free Function
  ShowMessage('Result = '+floattostr(Result));

 // EXAMPLE 5 -- 2 Variables Example (pass by value)
 // ------------------------------------------------
  SinExp := CompileExpr(ParseExpr('sin(x)*exp(y)',['x','y']),tyPass2V);     // parse and compile expression
  Result := SinExp(2.0,3.0);                                                // evaluate the Expression
  FreeFunc(@SinExp);                                                        // Free Function
  ShowMessage('Result = '+floattostr(Result));

 // EXAMPLE 6 -- 3 Variables Example (pass by reference)
 // ----------------------------------------------------
  Sum_abc := CompileExpr(ParseExpr('a+b+c',['a','b','c'])); // parse and compile expression
  Args[0] := 1.0;  // a = 1.0
  Args[1] := 2.0;  // b = 2.0
  Args[2] := 3.0;  // c = 3.0
  Result := Sum_abc(Args);                                  // evaluate the Expression
  FreeFunc(@Sum_abc);                                       // Free Function
  ShowMessage('Result = '+floattostr(Result));

// EXAMPLE 7 -- Evaluate without compiling (evaluate from bytecode)
// ----------------------------------------------------------------
  Expr := ParseExpr('sin(x*2*pi/maxX)*cos(y*2*pi/maxY)/2+0.5',['x','y','maxX','maxY']);
  if Expr.Error then
  begin
   ShowMessage('Syntax error!');
   exit;
  end;
  Result := EvalExpr(Expr,[2,3,200,100]); // x=2, y=3, maxX=200, maxY=100
end;

- List of internal functions ---------------------------------------------------
 abs,sin,cos,tan,cot,arcsin,arccos,arctan,arccot,ln,log,lb,exp,sqrt,sqr,round,
 trunc,frac,heaviside,sign

- Constants --------------------------------------------------------------------
 pi,e

- Operators --------------------------------------------------------------------
 +,-,/,*,^

Note: x^y^z = x^(y^z)
}

{$define ErrCode}         // Generate detailed syntax error messages? (ErrCode, ErrPos)
                          // Disable for faster compilation (10%-20% faster)
{$define MultDefaultOp}   // Multiplication as default operator? (Allow expressions like "2x")

{$booleval off}
{$warnings off}
{$ifdef VER170}
 {$inline auto}
{$endif}

unit parser;

interface

uses
  Math, SysUtils;

Type
 {$ifdef ErrCode}
 parseErrEnum =
   (parseErr_NoErr,parseErr_OpenBracket,parseErr_UnknownVariableOrConstant,
    parseErr_InvalidNumber,parseErr_NumberVarFuncOrBracketExpected,
    parseErr_OperatorExpected,parseErr_UnknownFunction);

 parseErrInfo = record
  ErrPos: Integer;
  ErrCode: parseErrEnum;
 end;
 {$endif}

 Expression = record
  Bytecode: array[0..255] of Byte;
  Consts: array of Extended;
  {$ifdef ErrCode}
  ErrInfo: parseErrInfo;
  {$endif}
  Error: Boolean;
 end;

 tyPassType = (tyPassRef,tyPass1V,tyPass2V);

 ExprFuncR = function(var Args): Extended;
 ExprFunc1V = function(const x: Extended): Extended;
 ExprFunc2V = function(const x,y: Extended): Extended;

// -----------------------------------------------------------------------------
// - Interface wrapper ---------------------------------------------------------
// -----------------------------------------------------------------------------
type
IExpr = interface
 function compiled: Boolean;
 {$ifdef ErrCode}
 function getErrInfo: parseErrInfo;
 function getErrStr: String;
 {$endif}
end;

IExpr1V = interface(IExpr)
 function Eval(const x: Extended): Extended;
end;

IExpr2V = interface(IExpr)
 function Eval(const x,y: Extended): Extended;
end;

IExprR = interface(IExpr)
 function Eval(var Args: array of Extended): Extended;
end;

function compileStr1V(const Formula: String): IExpr1V; overload;
function compileStr2V(const Formula: String): IExpr2V; overload;
function compileStr1V(const Formula: String; const Vars: array of Const): IExpr1V; overload;
function compileStr2V(const Formula: String; const Vars: array of Const): IExpr2V; overload;
function compileStrR(const Formula: String; const Vars: array of Const): IExprR;

// -----------------------------------------------------------------------------
// - Parser and compiler -------------------------------------------------------
// -----------------------------------------------------------------------------

function ParseExpr(const S: String): Expression; overload;
function ParseExpr(const S: String; const Variables: array of const): Expression; overload;
function EvalExpr(const ByteCode: Expression): Extended; overload;
function EvalExpr(const ByteCode: Expression; const Variables: array of const): Extended; overload;

function CompileExpr(const Bytecode: Expression; PT: tyPassType = tyPassRef): Pointer;
procedure FreeFunc(E: Pointer);

{$ifdef ErrCode}
function FormatError(const ErrInfo: parseErrInfo): String;
{$endif}

implementation

uses windows;

// -----------------------------------------------------------------------------
// - Interface wrapper ---------------------------------------------------------
// -----------------------------------------------------------------------------
const
 evalExStr = 'Cannot evaluate expression due to a syntax error.';

type
TExprFunction = class(TInterfacedObject)
{$ifdef ErrCode}
private
 FErrInfo: parseErrInfo;
public
 function getErrInfo: parseErrInfo;
 function getErrStr: String;
{$endif}
end;

TExprFunction1V = class (TExprFunction,IExpr1V)
public
 constructor Create(const S: String); overload;
 constructor Create(const S: String; const Vars: array of Const); overload;
 destructor Destroy; override;
 function Eval(const x: Extended): Extended;
private
 FFunc: ExprFunc1V;
 function compiled: Boolean;
end;

TExprFunction2V = class (TExprFunction,IExpr2V)
public
 constructor Create(const S: String); overload;
 constructor Create(const S: String; const Vars: array of Const); overload;
 destructor Destroy; override;
 function Eval(const x,y: Extended): Extended;
private
 FFunc: ExprFunc2V;
 function compiled: Boolean;
end;

TExprFunctionR = class (TExprFunction,IExprR)
public
 constructor Create(const S: String; const Vars: array of Const);
 destructor Destroy; override;
 function Eval(var Args: array of Extended): Extended;
private
 FFunc: ExprFuncR;
 FArgCount: Integer;
 function compiled: Boolean;
end;

{$ifdef ErrCode}
function TExprFunction.getErrInfo: parseErrInfo;
begin
 Result := FErrInfo;
end;

function TExprFunction.getErrStr: String;
begin
 Result := FormatError(FErrInfo);
end;
{$endif}

constructor TExprFunction1V.Create(const S: String);
Var
 Expr: Expression;
begin
 Expr := ParseExpr(S,['x']);
 if not Expr.Error then
  FFunc := CompileExpr(Expr,tyPass1V)
 {$ifdef ErrCode}
 else
  FErrInfo := Expr.ErrInfo;
 {$endif}
end;

function TExprFunction1V.compiled: Boolean;
begin
 Result := @FFunc <> nil;
end;

constructor TExprFunction1V.Create(const S: String; const Vars: array of Const);
Var
 Expr: Expression;
begin
 if length(Vars) <> 1 then
  raise EInvalidArgument.Create('Wrong variable count: One variable expected.');
 Expr := ParseExpr(S,Vars);
 if not Expr.Error then
  FFunc := CompileExpr(Expr,tyPass1V)
 {$ifdef ErrCode}
 else
  FErrInfo := Expr.ErrInfo;
 {$endif}
end;

destructor TExprFunction1V.Destroy;
begin
 if @FFunc <> nil then
  FreeFunc(@FFunc);
 inherited;
end;

function TExprFunction1V.Eval(const x: Extended): Extended;
begin
 if @FFunc = nil then
  raise Exception.Create(evalExStr);
 Result := FFunc(x);
end;

constructor TExprFunction2V.Create(const S: String);
Var
 Expr: Expression;
begin
 Expr := ParseExpr(S,['x','y']);
 if not Expr.Error then
  FFunc := CompileExpr(Expr,tyPass2V)
 {$ifdef ErrCode}
 else
  FErrInfo := Expr.ErrInfo;
 {$endif}
end;

function TExprFunction2V.compiled: Boolean;
begin
 Result := @FFunc <> nil;
end;

constructor TExprFunction2V.Create(const S: String; const Vars: array of Const);
Var
 Expr: Expression;
begin
 if length(Vars) <> 2 then
  raise EInvalidArgument.Create('Wrong variables count: Two variables expected.');
 Expr := ParseExpr(S,Vars);
 if not Expr.Error then
  FFunc := CompileExpr(Expr,tyPass2V)
 {$ifdef ErrCode}
 else
  FErrInfo := Expr.ErrInfo;
 {$endif}
end;

destructor TExprFunction2V.Destroy;
begin
 if @FFunc <> nil then
  FreeFunc(@FFunc);
 inherited;
end;

function TExprFunction2V.Eval(const x,y: Extended): Extended;
begin
 if @FFunc = nil then
  raise Exception.Create(evalExStr);
 Result := FFunc(x,y);
end;

function TExprFunctionR.compiled: Boolean;
begin
 Result := @FFunc <> nil;
end;

constructor TExprFunctionR.Create(const S: String; const Vars: array of Const);
Var
 Expr: Expression;
begin
 FArgCount := length(Vars);
 Expr := ParseExpr(S,Vars);
 if not Expr.Error then
  FFunc := CompileExpr(Expr)
 {$ifdef ErrCode}
 else
  FErrInfo := Expr.ErrInfo;
 {$endif}
end;

destructor TExprFunctionR.Destroy;
begin
 if @FFunc <> nil then
  FreeFunc(@FFunc);
 inherited;
end;

function TExprFunctionR.Eval(var Args: array of Extended): Extended;
begin
 if @FFunc = nil then
  raise Exception.Create(evalExStr);
 if length(Args) <> FArgCount then
  raise EInvalidArgument.Create(Format('Wrong argument count: %d argument(s) expected.',[FArgCount]));
 Result := FFunc(args[0]);
end;

function compileStr1V(const Formula: String): IExpr1V;
begin
 Result := TExprFunction1V.Create(Formula);
end;

function compileStr2V(const Formula: String): IExpr2V;
begin
 Result := TExprFunction2V.Create(Formula);
end;

function compileStr1V(const Formula: String; const Vars: array of Const): IExpr1V;
begin
 Result := TExprFunction1V.Create(Formula, Vars);
end;

function compileStr2V(const Formula: String; const Vars: array of Const): IExpr2V;
begin
 Result := TExprFunction2V.Create(Formula, Vars);
end;

function compileStrR(const Formula: String; const Vars: array of Const): IExprR;
begin
 Result := TExprFunctionR.Create(Formula, Vars);
end;

// -----------------------------------------------------------------------------
// - Parser and compiler -------------------------------------------------------
// -----------------------------------------------------------------------------

Type
 EFuncs = (_sin,_cos,_tan,_cot,_arcsin,_arccos,_arctan,_arccot,_ln,_lb,_log,
           _exp,_sqrt,_sqr,_sign,_abs,_frac,_round,_trunc,_heaviside,_invalid);
 EConst = (_pi,_e,_one,_zero);
 EOpCodes = (OpEnd,OpVar,OpConst,OpIConst,OpAdd,OpSub,OpMul,OpDiv,OpHoch,OpNeg,
             OpFunc);

function getLastErrorMsg: String;
var
  buf: array[0..MAX_PATH] of Char;
begin
 ZeroMemory(@buf,sizeof(buf));
 FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0, buf, sizeof(buf), nil);
 Result := Buf;
end;

Function ParseExpr(const S: String): Expression;
begin
 Result := parseExpr(S, []);
end;

{$ifdef ErrCode}
Function FormatError(const ErrInfo: parseErrInfo): String;
const
 ErrPrefix = 'Error on char %d: ';
begin
 with ErrInfo do
  Case ErrCode of
   parseErr_OperatorExpected:
    Result := Format(ErrPrefix+'Operator expected',[ErrPos]);
   parseErr_UnknownVariableOrConstant:
    Result := Format(ErrPrefix+'Unknown variable or constant',[ErrPos]);
   parseErr_UnknownFunction:
    Result := Format(ErrPrefix+'Unknown function',[ErrPos]);
   parseErr_InvalidNumber:
    Result := Format(ErrPrefix+'Invalid number',[ErrPos]);
   parseErr_NumberVarFuncOrBracketExpected:
    Result := Format(ErrPrefix+'Number, variable, constant, function or parenthesis expected',[ErrPos]);
   parseErr_OpenBracket:
    Result := Format(ErrPrefix+'")" or operator expected',[ErrPos])
   else
    Result := 'ParseExpr: Unknown syntax error';
  end;
end;
{$endif}

Function ParseExpr(const S: String; const Variables: array of const): Expression;
type
OutputType = record
 Length: Integer;
 Wert: Extended;
end;
Var
 CodePos: Integer;
 globalResult: Expression;
 ConstCount: Integer;
{$ifdef ErrCode}
 ErrorStrPos: PChar;
{$endif}
Type
 cTyp = (cPlusMinus,cMultDiv,cPower,cOpenPar,cClosePar,cUndefined,cDot,cExp);

function parseWholeNum(SubExpr: PChar; var Output: OutputType): Boolean; forward;
function parseVarFunc(SubExpr: PChar; var ExprLen: Integer): Boolean; forward;
function parseFactor(SubExpr: PChar; var ExprLen: Integer): Boolean; forward;
function parseParExpr(SubExpr: PChar; var ExprLen: Integer): Boolean; forward;
function parseMultiplication(SubExpr: PChar; var ExprLen: Integer): Boolean; forward;
function parseAddition(SubExpr: PChar; var ExprLen: Integer): Boolean; forward;
function parseRealnum(SubExpr: PChar; var ExprLen : Integer): Boolean; forward;

function SkipWhiteSpace(var SubExpr: PChar): Integer;
begin
 Result := 0;
 while (SubExpr^<>#0) and (SubExpr^=' ') do
 begin
  inc(SubExpr);
  inc(Result);
 end;
end;

const
 parseInvalidTypeStr = 'ParseExpr: Invalid variable type';

function getVarNo(const aVarName: Char): Integer;
var
  I: Integer;
  VarName: Char;
begin
  for I := 0 to High(Variables) do
  begin
   with Variables[I] do
    case VType of
     vtString,
     vtPChar,
     vtAnsiString:;
     vtChar: VarName := VChar
     else
      raise EInvalidArgument.Create(parseInvalidTypeStr);
    end;
   if VarName = aVarName then
   begin
    Result := I;
    exit;
   end;
  end;
 Result := -1;
end;

function getLongVarNo(const aVarName: String): Integer;
var
  I: Integer;
  VarName: String;
begin
  for I := 0 to High(Variables) do
  begin
   with Variables[I] do
    case VType of
     vtChar:;
     vtString:     VarName := VString^;
     vtPChar:      VarName := VPChar;
     vtAnsiString: VarName := string(VAnsiString)
     else
      raise EInvalidArgument.Create(parseInvalidTypeStr);
    end;
   if VarName = aVarName then
   begin
    Result := I;
    exit;
   end;
  end;
 Result := -1;
end;

function parseChrType(SubExpr: PChar; Typ: cTyp; var Operation: Char; var ExprLen: Integer): Boolean;
Var
 sTyp: cTyp;
begin
 ExprLen := SkipWhiteSpace(SubExpr)+1;
 sTyp := cUndefined;
 if SubExpr^ <> #0 then
 case SubExpr^ of
  '^': sTyp := cPower;
  '.',',': sTyp := cDot;
  '+','-': sTyp := cPlusMinus;
  '*','/': sTyp := cMultDiv;
  '(': sTyp := cOpenPar;
  ')': sTyp := cClosePar;
  'e','E': sTyp := cExp;
 end;
 if sTyp = Typ then
 begin
  Operation := SubExpr^;
  Result := True;
  {$ifdef ErrCode}
  globalResult.ErrInfo.ErrCode := parseErr_NoErr;
  {$endif}
  exit;
 end;
 Result := False;
end;
function parseAlphaNum(SubExpr: PChar; var Output: Char): Boolean;
begin
 if SubExpr^ = #0 then
 begin
  result := False;
  exit;
 end;
 Case SubExpr^ of
  '0'..'9','A'..'Z','a'..'z':
  begin
   Output := SubExpr^;
   Result := True;
   {$ifdef ErrCode}
   globalResult.ErrInfo.ErrCode := parseErr_NoErr;
   {$endif}
   exit;
  end;
 end;
 Result := False;
end;

function parseWholeNum(SubExpr: PChar; var Output: OutputType): Boolean;
Var
 Count: Integer;
 C: Char;
begin
 Output.Wert := 0;
 Count := 0;
 if SubExpr^ <> #0 then
 begin
  C := SubExpr^;
  while (C>='0')and(C<='9') do
  begin
   inc(Count);
   Output.Wert := Output.Wert*10 + (ord(SubExpr^)-ord('0'));
   inc(SubExpr);
   if SubExpr^ = #0 then break;
   C := SubExpr^;
  end;
  Output.Length := Count;
 end;
 Result := Count > 0;
end;

function getFunNo(const S: String): EFuncs;
begin
 Result := _invalid;
 Case S[1] of
  'a': if S = 'abs' then
        Result := _abs else
       if S = 'arcsin' then
        Result := _arcsin else
       if S = 'arccos' then
        Result := _arccos else
       if S = 'arctan' then
        Result := _arctan else
       if S = 'arccot' then
        Result := _arccot;
  'c': if S = 'cos' then
        Result := _cos else
       if S = 'cot' then
        Result := _cot;
  'e': if S = 'exp' then
        Result := _exp;
  'f': if S = 'frac' then
        Result := _frac;
  'h': if S = 'heaviside' then
        Result := _heaviside;
  'r': if S = 'round' then
        Result := _round;
  's': if S = 'sin' then
        Result := _sin else
       if S = 'sqrt' then
        Result := _sqrt else
       if S = 'sqr' then
        Result := _sqr else
       if S = 'sign' then
        Result := _sign;
  'l': if S = 'ln' then
        Result := _ln else
       if S = 'log' then
        Result := _log else
       if S = 'lb' then
        Result := _lb;
  't': if S = 'tan' then
        Result := _tan else
       if S = 'trunc' then
        Result := _trunc;
 end;
end;

function parseVarFunc(SubExpr: PChar; var ExprLen: Integer): Boolean;
Var
 C: Char;
 St: String;
 Klammer: Integer;
 Temp: Integer;
{$ifdef ErrCode}
 oldSubExpr: PChar;
{$endif}
begin
 St := '';
 while parseAlphaNum(SubExpr, C) do
 begin
  St := St + C;
  inc(SubExpr);
 end;
 if St <> '' then
 begin
  {$ifdef ErrCode}
  oldSubExpr := SubExpr;
  {$endif}
  ExprLen := length(St)+SkipWhiteSpace(SubExpr);
  if SubExpr^ = '(' then
  begin
   Temp := Byte(getFunNo(St));
   if EFuncs(Temp) <> _invalid then
   begin
    if parseParExpr(SubExpr, Klammer) then
    begin
     inc(ExprLen, Klammer);
     globalResult.Bytecode[CodePos] := Byte(OpFunc); inc(CodePos);
     globalResult.Bytecode[CodePos] := Temp; inc(CodePos);
     Result := True;
     {$ifdef ErrCode}
     globalResult.ErrInfo.ErrCode := parseErr_NoErr;
     {$endif}
     exit;
    end;
   end else
   begin
    {$ifdef ErrCode}
    Result := False;
    if globalResult.ErrInfo.ErrCode = parseErr_NoErr then
    begin
     globalResult.ErrInfo.ErrCode := parseErr_UnknownFunction;
     ErrorStrPos := oldSubExpr;
    end;
    exit;
    {$endif}
   end;
  end else
  begin
   if length(St) = 1 then
   begin
    Temp := getVarNo(St[1]);
    if Temp >= 0 then
    begin
     globalResult.Bytecode[CodePos] := Byte(OpVar); inc(CodePos);
     globalResult.Bytecode[CodePos] := Temp; inc(CodePos);
     Result := True;
     {$ifdef ErrCode}
     globalResult.ErrInfo.ErrCode := parseErr_NoErr;
     {$endif}
     exit;
    end else
     if St[1] = 'e' then
     begin
      globalResult.Bytecode[CodePos] := Byte(OpIConst); inc(CodePos);
      globalResult.Bytecode[CodePos] := Byte(_e); inc(CodePos);
      Result := True;
      {$ifdef ErrCode}
      globalResult.ErrInfo.ErrCode := parseErr_NoErr;
      {$endif}
      exit;
     end;
   end else
   begin
    Temp := getLongVarNo(St);
    if Temp >= 0 then
    begin
     globalResult.Bytecode[CodePos] := Byte(OpVar); inc(CodePos);
     globalResult.Bytecode[CodePos] := Temp; inc(CodePos);
     Result := True;
     {$ifdef ErrCode}
     globalResult.ErrInfo.ErrCode := parseErr_NoErr;
     {$endif}
     exit;
    end else
     if St = 'pi' then
     begin
      globalResult.Bytecode[CodePos] := Byte(OpIConst); inc(CodePos);
      globalResult.Bytecode[CodePos] := Byte(_pi); inc(CodePos);
      Result := True;
      {$ifdef ErrCode}
      globalResult.ErrInfo.ErrCode := parseErr_NoErr;
      {$endif}
      exit;
     end;
   end;
  end;
 end;
 Result := False;
 {$ifdef ErrCode}
 if globalResult.ErrInfo.ErrCode = parseErr_NoErr then
 begin
  globalResult.ErrInfo.ErrCode := parseErr_UnknownVariableOrConstant;
  ErrorStrPos := oldSubExpr;
 end;
 {$endif}
end;

function parseRealNum(SubExpr: PChar; var ExprLen: Integer): Boolean;
Var
 GanzZahl, NachKomma, Exp: OutputType;
 Value: Extended;
 ignore, Vorzeichen: Char;
 Index, Chr: Integer;
 AlreadyExists, Success: Boolean;
begin
 Result := False;
 try
  if parseWholeNum(SubExpr, GanzZahl) then
  begin
   inc(SubExpr, GanzZahl.Length);
   if parseChrType(SubExpr, cDot,ignore, Chr) then
   begin
    if Chr <> 1 then
     exit;
    inc(SubExpr, Chr);
    if parseWholeNum(SubExpr, NachKomma) then
    begin
     inc(SubExpr, NachKomma.Length);
     ExprLen := GanzZahl.Length + Chr + NachKomma.Length;
     Value := GanzZahl.Wert + NachKomma.Wert / Power(10, NachKomma.Length);
    end else
     exit;
   end else
   begin
    Value := GanzZahl.Wert;
    ExprLen := GanzZahl.Length;
   end;
   if parseChrType(SubExpr, cExp,ignore, Chr) then
   begin
    if Chr <> 1 then
     exit;
    inc(SubExpr, Chr);
    inc(ExprLen, Chr);
    if parseChrType(SubExpr, cPlusMinus,Vorzeichen, Chr) then
    begin
     if Chr <> 1 then
      exit;
     inc(SubExpr, Chr);
     inc(ExprLen, Chr);
    end else
     Vorzeichen := '+'; // Standardvorzeichen
    if parseWholeNum(SubExpr, Exp) then
    begin
     inc(ExprLen, Exp.Length);
     if Vorzeichen = '-' then
      Exp.Wert := -Exp.Wert;
     Value := Value*Power(10,Exp.Wert);
     Result := True;
     {$ifdef ErrCode}
     globalResult.ErrInfo.ErrCode := parseErr_NoErr;
     {$endif}
     exit;
    end;
   end else
   begin
    Result := True;
    {$ifdef ErrCode}
    globalResult.ErrInfo.ErrCode := parseErr_NoErr;
    {$endif}
    exit;
   end;
  end;
 finally
  if result then
  begin
   Success := False;
   if Frac(Value)=0 then
   begin
    Case Trunc(Value) of
     0: begin
         globalResult.Bytecode[CodePos] := Byte(OpIConst); inc(CodePos);
         globalResult.Bytecode[CodePos] := Byte(_zero); inc(CodePos);
         Success := True;
        end;
     1: begin
         globalResult.Bytecode[CodePos] := Byte(OpIConst); inc(CodePos);
         globalResult.Bytecode[CodePos] := Byte(_one); inc(CodePos);
         Success := True;
        end;
    end;
   end;
   if not Success then
   begin
    AlreadyExists := False;
    For Index := 0 to ConstCount-1 do // look for duplicate constant
     if Value = globalResult.Consts[Index] then
     begin
      AlreadyExists := True;
      break;
     end;
    if not AlreadyExists then
    begin
     Index := ConstCount;
     inc(ConstCount);
     SetLength(globalResult.Consts, Index+1);
     globalResult.Consts[Index] := Value;
    end;
    globalResult.Bytecode[CodePos] := Byte(OpConst); inc(CodePos);
    globalResult.Bytecode[CodePos] := Index; inc(CodePos);
   end;
  end else
  begin // if result = false
   {$ifdef ErrCode}
   if globalResult.ErrInfo.ErrCode = parseErr_NoErr then
   begin
    globalResult.ErrInfo.ErrCode := parseErr_InvalidNumber;
    ErrorStrPos := SubExpr;
   end;
   {$endif}
  end;
 end;
end;

function parseParExpr(SubExpr: Pchar; var ExprLen: Integer): Boolean;
var
 ignore: Char;
 Ausdruck, Chr1, Chr2: Integer;
begin
 if parseChrType(SubExpr, cOpenPar, ignore, Chr1) then
 begin
  inc(SubExpr, Chr1);
  if parseAddition(SubExpr, Ausdruck) then
  begin
   inc(SubExpr, Ausdruck);
   if parseChrType(SubExpr, cClosePar, ignore, Chr2) then
   begin
    ExprLen := Chr1 + Ausdruck + Chr2;
    Result := True;
    {$ifdef ErrCode}
    globalResult.ErrInfo.ErrCode := parseErr_NoErr;
    {$endif}
    exit;
   end else
   begin
    {$ifdef ErrCode}
    if globalResult.ErrInfo.ErrCode = parseErr_NoErr then
    begin
     globalResult.ErrInfo.ErrCode := parseErr_OpenBracket;
     ErrorStrPos := SubExpr;
    end;
    {$endif}
   end;
  end;
 end;
 Result := False;
end;
function parseSem(SubExpr: PChar; var ExprLen: Integer): Boolean;
Var Spaces: Integer;
begin
 Spaces := SkipWhiteSpace(SubExpr);
 if SubExpr^ = #0 then
 begin
  Result := False;
  {$ifdef ErrCode}
  if globalResult.ErrInfo.ErrCode = parseErr_NoErr then
  begin
   globalResult.ErrInfo.ErrCode := parseErr_NumberVarFuncOrBracketExpected;
   ErrorStrPos := SubExpr;
  end;
  {$endif}
  exit;
 end;
 case SubExpr^ of
 '0'..'9'          : Result := parseRealnum(SubExpr, ExprLen);
 'a'..'z','A'..'Z' : Result := parseVarFunc(SubExpr, ExprLen);
 '(':                Result := parseParExpr(SubExpr, ExprLen) else
  begin
   Result := False;
   {$ifdef ErrCode}
   if globalResult.ErrInfo.ErrCode = parseErr_NoErr then
   begin
    globalResult.ErrInfo.ErrCode := parseErr_NumberVarFuncOrBracketExpected;
    ErrorStrPos := SubExpr;
   end;
   {$endif}
  end;
 end;
 inc(ExprLen, Spaces);
end;

function parseFactor(SubExpr: PChar; var ExprLen: Integer): Boolean;
Var
 Exponent, Chr: Integer;
 Operation: Char;
begin
 if parseChrType(SubExpr, cPlusMinus, Operation, Chr) then // Vorzeichen?
  if parseFactor(SubExpr+Chr, Exponent) then
  begin
   ExprLen := Chr + Exponent;
   Case Operation of
    '-': begin
          globalResult.Bytecode[CodePos] := Byte(OpNeg); inc(CodePos);
         end;
    '+': begin
         end;
   end;
   Result := True;
   {$ifdef ErrCode}
   globalResult.ErrInfo.ErrCode := parseErr_NoErr;
   {$endif}
   exit;
  end;
 if parseSem(SubExpr, Exponent) then
 begin
  inc(SubExpr, Exponent);
  if parseChrType(SubExpr, cPower, Operation, Chr) then
  begin
   inc(SubExpr, Chr);
   if parseFactor(SubExpr, ExprLen) then
   begin
    ExprLen := Exponent + Chr + ExprLen;
    Result := True;
    {$ifdef ErrCode}
    globalResult.ErrInfo.ErrCode := parseErr_NoErr;
    {$endif}
    globalResult.Bytecode[CodePos] := Byte(OpHoch); inc(CodePos);
    exit;
   end;
  end else
  begin
   ExprLen := Exponent;
   Result := True;
   {$ifdef ErrCode}
   globalResult.ErrInfo.ErrCode := parseErr_NoErr;
   {$endif}
   exit;
  end;
 end;
 Result := False;
end;

function parseMultiplication(SubExpr: PChar; var ExprLen: Integer): Boolean;
var
 Faktor, Chr: Integer;
 Operation: Char;
 Pending: Boolean;
 Count: Integer;
begin
 ExprLen := 0;
 Count := 0;
 Pending := False;
 while parseFactor(SubExpr, Faktor) do
 begin
  Pending := False;
  inc(ExprLen, Faktor);
  inc(SubExpr, Faktor);
  if Count > 0 then
   Case Operation of
    '*': begin
          globalResult.Bytecode[CodePos] := Byte(OpMul); inc(CodePos);
         end;
    '/': begin
          globalResult.Bytecode[CodePos] := Byte(OpDiv); inc(CodePos);
         end;
   end;
  inc(Count);
  {$ifdef MultDefaultOp}
  Inc(ExprLen, SkipWhiteSpace(SubExpr));
  Case SubExpr^ of
   #0: break;
   '+','-': break;
  end;
  {$endif}
  if parseChrType(SubExpr, cMultDiv, Operation, Chr) then
  begin
   Pending := True;
   inc(SubExpr, Chr);
   inc(ExprLen, Chr);
  end else
  {$ifdef MultDefaultOp}
  Operation := '*';
  {$else}
  break;
  {$endif}
 end;
 Result := (Count>=1) and not Pending;
end;

function parseAddition(SubExpr: PChar; var ExprLen: Integer): Boolean;
var
 Term: Integer;
 Operation: Char;
 Pending: Boolean;
 Count, Chr: Integer;
begin
 ExprLen := 0;
 Count := 0;
 Pending := False;
 while parseMultiplication(SubExpr, Term) do
 begin
  Pending := False;
  inc(ExprLen, Term);
  inc(SubExpr, Term);
  if Count > 0 then
   Case Operation of
    '+': begin
          globalResult.Bytecode[CodePos] := Byte(OpAdd); inc(CodePos);
         end;
    '-': begin
          globalResult.Bytecode[CodePos] := Byte(OpSub); inc(CodePos);
         end;
   end;
  inc(Count);
  if parseChrType(SubExpr, cPlusMinus, Operation, Chr) then
  begin
   Pending := True;
   inc(SubExpr, Chr);
   inc(ExprLen, Chr);
  end else break;
 end;
 Result := (Count>=1) and not Pending;
 inc(ExprLen, SkipWhiteSpace(SubExpr));
end;
Var
 ExprLen: Integer;
begin
 CodePos := 0;
 ConstCount := 0;
 globalResult.Consts := nil;
 ZeroMemory(@globalResult, SizeOf(globalResult));
 {$ifdef ErrCode}
 globalResult.ErrInfo.ErrCode := parseErr_NoErr;
 globalResult.ErrInfo.ErrPos := -1;
 ErrorStrPos := nil;
 {$endif}
 globalResult.Error := not (parseAddition(PChar(S), ExprLen) and
                           (ExprLen = length(S)));
 {$ifdef ErrCode}
 with globalResult do
 if Error then
  if (ErrInfo.ErrCode = parseErr_NoErr) and (ExprLen <> length(S)) then
  begin
   ErrInfo.ErrCode := parseErr_OperatorExpected;
   ErrInfo.ErrPos := ExprLen;
  end else
   if ErrorStrPos <> nil then
    ErrInfo.ErrPos := ErrorStrPos-PChar(S)
   else
    ErrInfo.ErrPos := 0;
 {$endif}
 globalResult.Bytecode[CodePos] := Byte(OpEnd); inc(CodePos);
 Result := globalResult;
end;

function EvalExpr(const Bytecode: Expression): Extended;
begin
 Result := evalExpr(Bytecode, []);
end;

function EvalExpr(const Bytecode: Expression; const Variables: array of const): Extended;
Type
 PExtended = ^Extended;
Var
 Stack: array[0..31] of Extended; // No check for overflow
 _SP: PExtended;  // Stack Pointer
 _IP: Integer;    // Instruction Pointer
 Temp: Extended; 
 Befehl: EOpCodes;
begin
 if Bytecode.Error then
 begin
  Result := NaN;
  exit;
 end;
 _IP := 0;
 _SP := @Stack[0];
 Befehl := EOpCodes(ByteCode.Bytecode[0]);
 while Befehl <> OpEnd do
 begin
  inc(_IP);
  Case Befehl of
   OpVar:
    begin
     if Bytecode.Bytecode[_IP] > High(Variables) then
      raise EInvalidArgument.Create('EvalExpr: Not enough arguments.');
     with Variables[Bytecode.Bytecode[_IP]] do
     case VType of
      vtExtended:   _SP^ := VExtended^;
      vtInteger:    _SP^ := VInteger;
      vtInt64:      _SP^ := VInt64^ else
       raise EInvalidArgument.Create('EvalExpr: Invalid argument format.');
     end;
     inc(_SP);
     inc(_IP);
    end;
   OpConst:
    begin
     _SP^ := ByteCode.Consts[ByteCode.Bytecode[_IP]];
     inc(_SP);
     inc(_IP);
    end;
   OpIConst:
    begin
     Case EConst(ByteCode.Bytecode[_IP]) of
      _pi  : _SP^ := pi;
      _e   : _SP^ := exp(1);
      _one : _SP^ := 1;
      _zero: _SP^ := 0;
     end;
     inc(_SP);
     inc(_IP);
    end;
   OpAdd:
    begin
     dec(_SP);
     Temp := _SP^;
     dec(_SP);
     _SP^ := _SP^ + Temp;
     inc(_SP);
    end;
   OpSub:
    begin
     dec(_SP);
     Temp := _SP^;
     dec(_SP);
     _SP^ := _SP^ - Temp;
     inc(_SP);
    end;
   OpMul:
    begin
     dec(_SP);
     Temp := _SP^;
     dec(_SP);
     _SP^ := _SP^  * Temp;
     inc(_SP);
    end;
   OpDiv:
    begin
     dec(_SP);
     Temp := _SP^;
     dec(_SP);
     _SP^ := _SP^ / temp;
     inc(_SP);
    end;
   OpHoch:
    begin
     dec(_SP);
     Temp := _SP^;
     dec(_SP);
     _SP^ := Power(_SP^,Temp);
     inc(_SP);
    end;
   OpNeg:
    begin
     dec(_SP);
     _SP^ := -_SP^;
     inc(_SP);
    end;
   OpFunc:
   begin
     dec(_SP);
     Case EFuncs(ByteCode.Bytecode[_IP]) of
      _abs      : _SP^ := abs(_SP^);
      _frac     : _SP^ := frac(_SP^);
      _sin      : _SP^ := sin(_SP^);
      _cos      : _SP^ := cos(_SP^);
      _tan      : _SP^ := tan(_SP^);
      _sign     : _SP^ := sign(_SP^);
      _cot      : _SP^ := cot(_SP^);
      _arcsin   : _SP^ := arcsin(_SP^);
      _arccos   : _SP^ := arccos(_SP^);
      _arctan   : _SP^ := arctan(_SP^);
      _arccot   : _SP^ := arccot(_SP^);
      _ln       : _SP^ := ln(_SP^);
      _log      : _SP^ := ln(_SP^)/ln(10);
      _lb       : _SP^ := ln(_SP^)/ln(2);
      _exp      : _SP^ := exp(_SP^);
      _sqrt     : _SP^ := sqrt(_SP^);
      _sqr      : _sP^ := sqr(_SP^);
      _round    : _SP^ := round(_SP^);
      _trunc    : _SP^ := trunc(_SP^);
      _heaviside: if _SP^ >= 0 then _SP^ := 1 else _SP^ := 0;
     end;
     inc(_SP);
     inc(_IP);
   end;
  end;
  Befehl := EOpCodes(ByteCode.Bytecode[_IP]);
 end;
 dec(_SP);
 Result := _SP^;
end;

Procedure XPower;
Var
 Base, Exponent: Extended;
 Result: Extended absolute Base;
Begin
 asm
  push eax
  fstp tbyte ptr [Exponent]
  fstp tbyte ptr [Base]
 end;
 if (Frac(Exponent) = 0.0) and (Abs(Exponent) <= MaxInt) then
 begin
   Result := IntPower(Base, Integer(Trunc(Exponent)));
   asm
    fld tbyte ptr [Result];
   end;
 end else
  asm // exp(Exponent*ln(Base))
   fldln2
   fld tbyte ptr [Base]
   fyl2x
   fld tbyte ptr [Exponent]
   fmulp st(1), st
   fldl2e
   fmulp st(1), st
   fld st(0)
   frndint
   fsub st(1), st
   fxch st(1)
   f2xm1
   fld1
   faddp st(1), st
   fscale
   fstp st(1)
  end;
 asm
  pop eax
 end;
end;

Const
 Epilogue: array[0..1] of Byte = ($9b,$c3);
 EpilogueBy1Value: array[0..2] of Byte = ($c2,$0c,$00);
 EpilogueBy2Values: array[0..2] of Byte = ($c2,$18,$00);
 { pass by reference }
 fld8: array[0..1] of Byte = ($db,$68);
 fld16: array[0..1] of Byte = ($db,$a8);
 fldIndex0: array[0..1] of Byte = ($db,$28);
 { pass by value }
 fldIndex0By1Value: array[0..3] of Byte = ($db,$6c,$24,$04);

 fldIndex0By2Values: array[0..3] of Byte = ($db,$6c,$24,$10);
 fldIndex1By2Values: array[0..3] of Byte = ($db,$6c,$24,$04);

 fldAddr: array[0..1] of Byte = ($db,$2d);
 fmulp: array[0..1] of Byte = ($de,$c9);
 fdivp: array[0..1] of Byte = ($de,$f9);
 faddp: array[0..1] of Byte = ($de,$c1);
 fsubp: array[0..1] of Byte = ($de,$e9);
 fldpi: array[0..1] of Byte = ($d9,$eb);
 fsin: array[0..1] of Byte = ($d9,$fe);
 fcos: array[0..1] of Byte = ($d9,$ff);
 fabs: array[0..1] of byte = ($d9,$e1);
 fatan: array[0..3] of Byte = ($d9,$e8,$d9,$f3);
 ftan: array[0..3] of Byte = ($d9,$f2,$dd,$d8);
 fcot: array[0..3] of Byte = ($d9,$f2,$de,$f1);
 facot: array[0..5] of Byte = ($d9,$e8,$d9,$c9,$d9,$f3);
 fsqrt: array[0..1] of Byte = ($d9,$fa);
 fsqr: array[0..3] of Byte = ($d9,$c0,$de,$c9);
 flog: array[0..9] of Byte = ($d9,$e8,$d9,$c9,$d9,$f1,$d9,$e9,$de,$f9);
 fln: array[0..9] of Byte = ($d9,$e8,$d9,$c9,$d9,$f1,$d9,$ea,$de,$f9);
 flb: array[0..5] of Byte = ($d9,$e8,$d9,$c9,$d9,$f1);
 fxchg: array[0..1] of Byte = ($d9,$c9);
 fchs: array[0..1] of Byte = ($d9,$e0);
 fld1: array[0..1] of Byte = ($d9,$e8);
 fld0: array[0..1] of Byte = ($d9,$ee);
 fexp : array[0..21] of Byte =
   ($9,$ea,$de,$c9,$d9,$c0,$d9,$fc,$dc,$e9,$d9,$c9,$d9,$f0,$d9,$e8,$de,$c1,$d9,
    $fd,$dd,$d9);
 fheaviside: array[0..19] of Byte =
   ($d9,$ee,$d8,$d9,$9b,$df,$e0,$9e,$76,$06,$dd,$d8,$d9,$ee,$eb,$04,$dd,$d8,$d9,
    $e8);
 fround: array[0..12] of Byte =
   ($83,$ec,$08,$df,$3C,$24,$9b,$df,$2c,$24,$83,$c4,$08);
 farcsin: array[0..11] of Byte =
   ($d9,$c0,$d8,$c8,$d9,$e8,$de,$e1,$d9,$fa,$d9,$f3);
 farccos: array[0..13] of Byte =
   ($d9,$c0,$d8,$c8,$d9,$e8,$de,$e1,$d9,$fa,$d9,$c9,$d9,$f3);
 ftrunc: array[0..35] of Byte =
   ($83,$ec,$0c,$d9,$3c,$24,$d9,$7C,$24,$02,$66,$81,$4c,$24,$02,$00,$0f,$d9,$6c,
    $24,$02,$df,$7c,$24,$04,$9b,$d9,$2c,$24,$59,$df,$2c,$24,$83,$c4,$08);
 ffrac: array[0..34] of Byte =
   ($d9,$c0,$83,$ec,$04,$d9,$3c,$24,$d9,$7c,$24,02,$9b,$66,$81,$4c,$24,$02,$00,
    $0f,$d9,$6c,$24,$02,$d9,$fc,$9b,$d9,$2c,$24,$83,$c4,$04,$de,$e9);
 fsign: array[0..23] of Byte =
   ($d9,$ee,$d8,$d9,$9b,$df,$e0,$9e,$76,$08,$dd,$d8,$d9,$e8,$d9,$e0,$eb,$06,$73,
    $04,$dd,$d8,$d9,$e8);
 call: Byte = ($e8);

function CompileExpr(const Bytecode: Expression; PT: tyPassType = tyPassRef): Pointer;
Type
 PExtended = ^Extended;
 TIConsts = record
  e: Integer;
 end;
 TConstantEntry = record
  Addr: ^Pointer;
  Index: Integer;
 end;
Var
 _IP: Integer; // Instruction Pointer
 Befehl: EOpCodes;
 P: PByte;
 I, J, ConstsCount: Integer;
 index: Integer;
 IConsts: TIConsts;
 AddIConsts: array of Extended;
 ConstsTable: array of TConstantEntry;

Procedure LoadArgNo(ConstNo: Integer);
begin
 Case PT of
  tyPassRef:
   begin
    ConstNo := ConstNo * SizeOf(Extended);
    if ConstNo < 128 then
    begin
     if ConstNo = 0 then
     begin
      Move(fldIndex0, P^, SizeOf(fldIndex0));  inc(P, SizeOf(fldIndex0));
     end else
     begin
      Move(Fld8, P^, SizeOf(Fld8));            inc(P, SizeOf(Fld8));
      P^ := ConstNo; inc(P);
     end;
    end else
    begin
     Move(Fld16, P^, SizeOf(Fld16));          inc(P, SizeOf(Fld16));
     Move(ConstNo, P^, SizeOf(DWord));        inc(P, SizeOf(DWord));
    end;
   end;
  tyPass1V:
  begin
   if ConstNo > 0 then
    EInvalidArgument.Create('CompileExpr: Only one variable can be passed by value');
   Move(fldIndex0by1Value, P^, SizeOf(fldIndex0by1Value));
   inc(P, SizeOf(fldIndex0by1Value));
  end;
  tyPass2V:
   Case ConstNo of
    0: begin
        Move(fldIndex0by2Values, P^, SizeOf(fldIndex0by2Values));
        inc(P, SizeOf(fldIndex0by2Values));
       end;
    1: begin
        Move(fldIndex1by2Values, P^, SizeOf(fldIndex1by2Values));
        inc(P, SizeOf(fldIndex1by2Values));
       end
   else
    EInvalidArgument.Create('CompileExpr: Only two variables can be passed by value');
   end;
 end;
end;

Procedure AddToConstsTable(P: Pointer; Index: Integer);
Var I: Integer;
begin
 I := length(ConstsTable);
 SetLength(ConstsTable, I+1);
 ConstsTable[I].Addr := P;
 ConstsTable[I].Index := Index;
end;

procedure AddIConst(Var IConst: Integer; const Value: Extended);
begin // Add inline constant (e,...) to additional constants table
 if IConst >= 0 then
 begin
  Move(fldAddr, P^, SizeOf(fldAddr)); inc(P, SizeOf(fldAddr));
  AddToConstsTable(P, IConst); inc(P, SizeOf(DWord));
 end else
 begin
  Index := length(AddIConsts);
  SetLength(AddIConsts, Index+1);
  AddIConsts[Index] := Value;
  IConst := Index+ConstsCount;
  Move(fldAddr, P^, SizeOf(fldAddr)); inc(P, SizeOf(fldAddr));
  AddToConstsTable(P, IConst); inc(P, SizeOf(DWord));
 end;
end;

procedure AddPowerCmd;
Var
 Callee: DWord;
begin
 P^ := call; inc(P);
 Callee := DWord(@XPower)-DWord(P)-4; // relative Position
 Move(Callee, P^, SizeOf(Callee)); inc(P, SizeOf(Callee));
end;

begin
 {$ifdef ErrCode}
 with Bytecode do
  if Error then
   raise Exception.Create('ParseExpr: '+FormatError(ErrInfo));
 {$else}
 if Bytecode.Error then
  raise Exception.Create('ParseExpr: Syntax error');
 {$endif}

 Result := VirtualAlloc(nil, 4096, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
 if Result = nil then
  raise Exception.Create('CompileExpr: '+getLastErrorMsg);

 try
  FillChar(IConsts, SizeOF(IConsts), -1); // list with indexes of inline constants that cannot be
                                          // directly converted
  ConstsCount := length(Bytecode.Consts); // how many (not inline) constants in expression

  P := Result;

//  Move(Prologue, P^, SizeOf(Prologue));
//  inc(P, SizeOf(Prologue));

  _IP := 0;
  Befehl := EOpCodes(ByteCode.Bytecode[0]);
  while Befehl <> OpEnd do
  begin
   inc(_IP);
   Case Befehl of
    OpVar:
     begin
      LoadArgNo(Bytecode.Bytecode[_IP]);
      inc(_IP);
     end;
    OpConst:
     begin
      Move(fldAddr, P^, SizeOf(fldAddr)); inc(P, SizeOf(fldAddr));
      AddToConstsTable(P, Integer(Bytecode.Bytecode[_IP])); inc(P, SizeOf(DWord));
      inc(_IP);
     end;
    OpIConst:
     begin
      Case EConst(ByteCode.Bytecode[_IP]) of
       _pi  : begin Move(fldpi, P^, SizeOf(fldpi)); inc(P, SizeOf(fldpi)); end;
       _one : begin Move(fld1, P^, SizeOf(fld1)); inc(P, SizeOf(fld1)); end;
       _zero: begin Move(fld0, P^, SizeOf(fld0)); inc(P, SizeOf(fld0)); end;
       _e   : AddIConst(IConsts.e, exp(1));
       else
        raise Exception.Create('CompileExpr: Constant not supported');
      end;
      inc(_IP);
     end;
    OpMul: begin
            Move(fmulp, P^, SizeOf(fmulp)); inc(P, SizeOf(fmulp));
           end;
    OpDiv: begin
            Move(fdivp, P^, SizeOf(fdivp)); inc(P, SizeOf(fdivp));
           end;
    OpAdd: begin
            Move(faddp, P^, SizeOf(faddp)); inc(P, SizeOf(faddp));
           end;
    OpSub: begin
            Move(fsubp, P^, SizeOf(fsubp)); inc(P, SizeOf(fsubp));
           end;
    OpHoch: begin
             AddPowerCmd;
            end;
    OpNeg: begin
            Move(fchs, P^, SizeOf(fchs)); inc(P, SizeOf(fchs));
           end;
    OpFunc:
    begin
      Case EFuncs(ByteCode.Bytecode[_IP]) of
       _abs     : begin
                   Move(fabs, P^, SizeOf(fabs)); inc(P, SizeOf(fabs));
                  end;
       _arctan  : begin
                   Move(fatan, P^, SizeOf(fatan)); inc(P, SizeOf(fatan));
                  end;
       _arccot  : begin
                   Move(facot, P^, SizeOf(facot)); inc(P, SizeOf(facot));
                  end;
       _arcsin  : begin
                   Move(farcsin, P^, SizeOf(farcsin)); inc(P, SizeOf(farcsin));
                  end;
       _arccos  : begin
                   Move(farccos, P^, SizeOf(farccos)); inc(P, SizeOf(farccos));
                  end;
       _sqr     : begin
                   Move(fsqr, P^, SizeOf(fsqr)); inc(P, SizeOf(fsqr));
                  end;
       _sqrt    : begin
                   Move(fsqrt, P^, SizeOf(fsqrt)); inc(P, SizeOf(fsqrt));
                  end;
       _sign    : begin
                   Move(fsign, P^, SizeOf(fsign)); inc(P, SizeOf(fsign));
                  end;
       _ln      : begin
                   Move(fln, P^, SizeOf(fln)); inc(P, SizeOf(fln));
                  end;
       _log     : begin
                   Move(flog, P^, SizeOf(flog)); inc(P, SizeOf(flog));
                  end;
       _lb      : begin
                   Move(flb, P^, SizeOf(flb)); inc(P, SizeOf(flb));
                  end;
       _cot     : begin
                   Move(fcot, P^, SizeOf(fcot)); inc(P, SizeOf(fcot));
                  end;
       _tan     : begin
                   Move(ftan, P^, SizeOf(ftan)); inc(P, SizeOf(ftan));
                  end;
       _sin     : begin
                   Move(fsin, P^, SizeOf(fsin)); inc(P, SizeOf(fsin));
                  end;
       _cos     : begin
                   Move(fcos, P^, SizeOf(fcos)); inc(P, SizeOf(fcos));
                  end;
       _round   : begin
                   Move(fround, P^, SizeOf(fround)); inc(P, SizeOf(fround));
                  end;
       _trunc   : begin
                   Move(ftrunc, P^, SizeOf(ftrunc)); inc(P, SizeOf(ftrunc));
                  end;
       _frac    : begin
                   Move(ffrac, P^, SizeOf(ffrac)); inc(P, SizeOf(ffrac));
                  end;
      _heaviside: begin
                   Move(fheaviside, P^, SizeOf(fheaviside)); inc(P, SizeOf(fheaviside));
                  end;
       _exp     : begin
                   Move(fexp, P^, SizeOf(fexp)); inc(P, SizeOf(fexp));
                  end else
                  raise Exception.Create('CompileExpr: Function not supported');
      end;
      inc(_IP);
    end;
   end;
   Befehl := EOpCodes(ByteCode.Bytecode[_IP]);
  end;
  Case PT of
   tyPassRef:
    begin
     Move(Epilogue, P^, SizeOf(Epilogue));
     inc(P, SizeOf(Epilogue));
    end;
   tyPass1V:
    begin
     Move(EpilogueBy1Value, P^, SizeOf(EpilogueBy1Value));
     inc(P, SizeOf(EpilogueBy1Value));
    end;
   tyPass2V:
    begin
     Move(EpilogueBy2Values, P^, SizeOf(EpilogueBy2Values));
     inc(P, SizeOf(EpilogueBy2Values));
    end;
  end;
  For I := 0 to length(ConstsTable)-1 do
  begin
   J := ConstsTable[I].Index;
   if J < ConstsCount then
    Move(Bytecode.Consts[J], P^, SizeOf(Extended))
   else
    Move(AddIConsts[J-ConstsCount], P^, SizeOf(Extended));
   ConstsTable[I].Addr^ := P;
   inc(P, SizeOf(Extended));
  end;
 except
  FreeFunc(Result);
  raise;
 end;
end;

procedure FreeFunc(E: Pointer);
begin
 if not VirtualFree(E, 0, MEM_RELEASE) then
  raise Exception.Create('FreeFunc: '+getLastErrorMsg);
end;

end.

