unit graph;

interface

uses windows, ExtCtrls, sysutils, parser, graphics, dialogs;

type TGraph = class
       public
       Ursprung:TPoint;
       Bild:TImage;
       ZeichenAbstandX:integer;
       ZeichenAbstandY:integer;
       ZeichenSchrittX:integer;
       ZeichenSchrittY:integer;

       procedure drawAchsis; overload;
       procedure drawAchsis(Ursprungx,Ursprungy:integer); overload;
       procedure init(Ursprungx,Ursprungy:integer;pBild:TImage);
       procedure leereBild;
       procedure drawPoint(x,y:integer);
       procedure drawFunction(formalstr:string);
end;

implementation

procedure TGraph.drawFunction(formalstr:string);
var Expression:IExpr1V;
    i:extended;
begin

  expression:=compileStr1V(formalstr);
  if Expression.getErrInfo.ErrPos > 0 then messagedlg(Expression.getErrStr,mtwarning, [MBok],0) else
    begin
    i:=-(Bild.Width div ZeichenAbstandX);
    repeat
      try
        drawPoint(round(i*ZeichenAbstandX),round(expression.eval(i)*ZeichenAbstandX));
      except
        end;
      i:=i+0.001;
    until i >=(Bild.Width div ZeichenAbstandX);
    end;

end;

procedure TGraph.drawPoint(x,y:integer);
begin

  Bild.Canvas.Pixels[Ursprung.X+x,Ursprung.Y-y]:=clred;

end;

procedure TGraph.init(Ursprungx,Ursprungy:integer;pBild:TImage);
begin

  Bild:=pBild;

  Ursprung.x:=Ursprungx;
  Ursprung.y:=bild.Height-ursprungy;

  ZeichenAbstandX:=50;
  ZeichenAbstandY:=50;
  ZeichenSchrittX:=1;
  ZeichenSchrittY:=1;

  drawAchsis;

end;

procedure TGraph.drawAchsis;
var i:integer;
begin

  if ZeichenAbstandX<5 then ZeichenAbstandX:=5;
  if ZeichenAbstandY<5 then ZeichenAbstandY:=5;

  leereBild;

  //Linie X:
  Bild.Canvas.MoveTo(0,ursprung.Y);
  Bild.Canvas.LineTo(bild.Width,ursprung.y);

  //Line Y:
  Bild.Canvas.MoveTo(ursprung.x,0);
  Bild.Canvas.LineTo(ursprung.x,bild.height);

  // Abschnitte X positiv
  for i:=1 to (Bild.Width div ZeichenAbstandX) do
    begin
    Bild.Canvas.MoveTo(Ursprung.x+(ZeichenAbstandX*i),Ursprung.y+3);
    Bild.Canvas.LineTo(Ursprung.x+(ZeichenAbstandX*i),Ursprung.y-3);
    Bild.Canvas.TextOut(Ursprung.x+(ZeichenAbstandX*i)-3,Ursprung.y+6,inttostr(ZeichenSchrittY*i));
    end;

  // Abschnitte X negativ
  for i:=1 to (Bild.Width div ZeichenAbstandX) do
    begin
    Bild.Canvas.MoveTo(Ursprung.x-(ZeichenAbstandX*i),Ursprung.y+3);
    Bild.Canvas.LineTo(Ursprung.x-(ZeichenAbstandX*i),Ursprung.y-3);
    Bild.Canvas.TextOut(Ursprung.x-(ZeichenAbstandX*i)-3,Ursprung.y+6,inttostr(ZeichenSchrittY*i));
    end;

  // Abschnitte Y negativ
  for i:=1 to (Bild.height div ZeichenAbstandY) do
    begin
    Bild.Canvas.MoveTo(Ursprung.x+3,Ursprung.Y+(ZeichenAbstandY*i));
    Bild.Canvas.LineTo(Ursprung.x-4,Ursprung.Y+(ZeichenAbstandY*i));
    Bild.Canvas.TextOut(Ursprung.x-(length(inttostr(ZeichenSchrittY*i))*6)-5,Ursprung.y+(ZeichenAbstandy*i)-4,inttostr(ZeichenSchrittY*i));
    end;

  // Abschnitte Y positiv
  for i:=1 to (Bild.height div ZeichenAbstandY) do
    begin
    Bild.Canvas.MoveTo(Ursprung.x+3,Ursprung.Y-(ZeichenAbstandY*i));
    Bild.Canvas.LineTo(Ursprung.x-4,Ursprung.Y-(ZeichenAbstandY*i));
    Bild.Canvas.TextOut(Ursprung.x-(length(inttostr(ZeichenSchrittY*i))*6)-5,Ursprung.y-(ZeichenAbstandy*i)-4,inttostr(ZeichenSchrittY*i));
    end;

end;

procedure Tgraph.leereBild;
begin

  Bild.picture:=nil;

end;

procedure TGraph.drawAchsis(Ursprungx,Ursprungy:integer);
begin

  Ursprung.x:=Ursprungx;
  Ursprung.y:=bild.Height-ursprungy;

  drawAchsis;

end;

end.
