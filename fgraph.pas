unit fgraph;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, graph;

type
  TfGraph = class(TForm)
    ptop: TPanel;
    pleft: TPanel;
    pbottom: TPanel;
    pright: TPanel;
    pmiddle: TPanel;
    iGraph: TImage;
    lheader: TLabel;
    lexit: TLabel;
    lmax: TLabel;
    lmin: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    procedure lexitMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lexitMouseLeave(Sender: TObject);
    procedure lexitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lmaxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lmaxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lmaxMouseLeave(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lminMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lminMouseLeave(Sender: TObject);
    procedure lminClick(Sender: TObject);
    procedure iGraphClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    graph:TGraph;
  end;

var
  formGraph: TfGraph;

implementation

{$R *.dfm}

procedure TfGraph.lexitMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  lexit.Font.Color:=clred;

end;

procedure TfGraph.lexitMouseLeave(Sender: TObject);
begin

  lexit.Font.Color:=clblack;

end;

procedure TfGraph.lexitMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  Application.Terminate;

end;

procedure TfGraph.lmaxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if formGraph.WindowState=wsmaximized then formGraph.WindowState:=wsnormal else formGraph.WindowState:=wsmaximized;

  graph.drawAchsis;

end;

procedure TfGraph.lmaxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  lmax.Font.Color:=clred;

end;

procedure TfGraph.lmaxMouseLeave(Sender: TObject);
begin

  lmax.Font.Color:=clblack;

end;

procedure TfGraph.FormPaint(Sender: TObject);
var rgn: HRGN;
begin

  if windowstate=wsmaximized then
    begin
    rgn := CreateRoundRectRgn(0,// x-coordinate of the region's upper-left corner
        0,            // y-coordinate of the region's upper-left corner
        ClientWidth,  // x-coordinate of the region's lower-right corner
        ClientHeight, // y-coordinate of the region's lower-right corner
        0,           // height of ellipse for rounded corners
        0);          // width of ellipse for rounded corners
      SetWindowRgn(Handle, rgn, True);
    end else
      begin
      rgn := CreateRoundRectRgn(0,// x-coordinate of the region's upper-left corner
        0,            // y-coordinate of the region's upper-left corner
        ClientWidth,  // x-coordinate of the region's lower-right corner
        ClientHeight, // y-coordinate of the region's lower-right corner
        25,           // height of ellipse for rounded corners
        25);          // width of ellipse for rounded corners
      SetWindowRgn(Handle, rgn, True);
      end;
      
  rgn := CreateRoundRectRgn(0,// x-coordinate of the region's upper-left corner
    0,            // y-coordinate of the region's upper-left corner
    pmiddle.Width,  // x-coordinate of the region's lower-right corner
    pmiddle.Height, // y-coordinate of the region's lower-right corner
    25,           // height of ellipse for rounded corners
    25);          // width of ellipse for rounded corners
  SetWindowRgn(pmiddle.Handle, rgn, True);

end;

procedure TfGraph.FormResize(Sender: TObject);
var rgn: HRGN;
begin

  if windowstate=wsmaximized then
    begin
    rgn := CreateRoundRectRgn(0,// x-coordinate of the region's upper-left corner
        0,            // y-coordinate of the region's upper-left corner
        ClientWidth,  // x-coordinate of the region's lower-right corner
        ClientHeight, // y-coordinate of the region's lower-right corner
        0,           // height of ellipse for rounded corners
        0);          // width of ellipse for rounded corners
      SetWindowRgn(Handle, rgn, True);
    end else
      begin
      rgn := CreateRoundRectRgn(0,// x-coordinate of the region's upper-left corner
        0,            // y-coordinate of the region's upper-left corner
        ClientWidth,  // x-coordinate of the region's lower-right corner
        ClientHeight, // y-coordinate of the region's lower-right corner
        25,           // height of ellipse for rounded corners
        25);          // width of ellipse for rounded corners
      SetWindowRgn(Handle, rgn, True);
      end;

end;

procedure TfGraph.FormCreate(Sender: TObject);
var rgn: HRGN;
begin

  rgn := CreateRoundRectRgn(0,// x-coordinate of the region's upper-left corner
    0,            // y-coordinate of the region's upper-left corner
    ClientWidth,  // x-coordinate of the region's lower-right corner
    ClientHeight, // y-coordinate of the region's lower-right corner
    25,           // height of ellipse for rounded corners
    25);          // width of ellipse for rounded corners
  SetWindowRgn(Handle, rgn, True);

  graph:=TGraph.create;

  graph.init(50,50,iGraph);

end;

procedure TfGraph.lminMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  lmin.Font.Color:=clred;

end;

procedure TfGraph.lminMouseLeave(Sender: TObject);
begin

  lmin.Font.Color:=clblack;

end;

procedure TfGraph.lminClick(Sender: TObject);
begin

  Application.Minimize;

end;

procedure TfGraph.iGraphClick(Sender: TObject);
var point:TPoint;
begin

  getcursorpos(point);

  graph.drawAchsis(point.x-formGraph.left-pleft.width,screen.Height-point.y-(screen.Height-formgraph.Height-formgraph.Top)-(formgraph.pbottom.Height));

end;

procedure TfGraph.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  graph.ZeichenAbstandX:=graph.ZeichenAbstandX-1;
  graph.ZeichenAbstandY:=graph.ZeichenAbstandY-1;
  graph.drawAchsis;

end;

procedure TfGraph.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  graph.ZeichenAbstandX:=graph.ZeichenAbstandX+1;
  graph.ZeichenAbstandY:=graph.ZeichenAbstandY+1;
  graph.drawAchsis;

end;

procedure TfGraph.Button1Click(Sender: TObject);
begin

  graph.drawFunction(edit1.Text);

end;

end.

