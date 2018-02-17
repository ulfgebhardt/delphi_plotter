program Plotter;

uses
  Forms,
  fgraph in 'fgraph.pas' {fGraph},
  graph in 'graph.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfGraph, formGraph);
  Application.Run;
end.
