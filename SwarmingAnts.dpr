program SwarmingAnts;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmMain},
  DisplayView in 'DisplayView.pas',
  GraphDefine in 'GraphDefine.pas',
  MiniDialogGenerateGrid in 'MiniDialogs\MiniDialogGenerateGrid.pas' {mdlgGenerateGrid},
  MiniDialogGenerateRandomPoints in 'MiniDialogs\MiniDialogGenerateRandomPoints.pas' {mdlgGenerateRandomPoints};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TmdlgGenerateGrid, mdlgGenerateGrid);
  Application.CreateForm(TmdlgGenerateRandomPoints, mdlgGenerateRandomPoints);
  Application.Run;
end.

