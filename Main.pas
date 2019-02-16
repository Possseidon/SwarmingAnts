unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.IOUtils,
  System.ImageList,

  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.Menus,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ImgList,

  Pengine.Vector,

  DisplayView,
  GraphDefine,
  MiniDialogGenerateGrid;

type

  TfrmMain = class(TForm)
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miNew: TMenuItem;
    miOpen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miExit: TMenuItem;
    N1: TMenuItem;
    alMain: TActionList;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExit: TAction;
    N2: TMenuItem;
    sbMain: TStatusBar;
    pnlMain: TPanel;
    sbSidebar: TScrollBox;
    gbSettings: TGroupBox;
    gbProgress: TGroupBox;
    pbProgressBar: TProgressBar;
    pnlProgress: TPanel;
    lbProgressInfo: TLabel;
    lbProgressPercentage: TLabel;
    miView: TMenuItem;
    miShowProgress: TMenuItem;
    actShowProgress: TAction;
    miShowSidebar: TMenuItem;
    actShowSidebar: TAction;
    N3: TMenuItem;
    actEditMode: TAction;
    miEditMode: TMenuItem;
    pbDisplay: TPaintBox;
    tbDisplay: TToolBar;
    tbClear: TToolButton;
    ToolButton2: TToolButton;
    actClear: TAction;
    ilIcons: TImageList;
    ToolButton4: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    actGenerateGrid: TAction;
    N4: TMenuItem;
    actResetView: TAction;
    miResetView: TMenuItem;
    actSmoothing: TAction;
    miSmoothing: TMenuItem;
    miEdit: TMenuItem;
    miClear: TMenuItem;
    miGenerateGrid: TMenuItem;
    procedure actClearExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actEditModeExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actGenerateGridExecute(Sender: TObject);
    procedure actSmoothingExecute(Sender: TObject);
    procedure actResetViewExecute(Sender: TObject);
    procedure actShowProgressExecute(Sender: TObject);
    procedure actShowSidebarExecute(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
      var Handled: Boolean);
  private
    FDisplay: TDisplay;

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


procedure TfrmMain.actClearExecute(Sender: TObject);
begin
  FDisplay.Graph.Clear;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FDisplay.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FDisplay := TDisplay.Create(pbDisplay);
  actEditMode.Checked := tbDisplay.Visible;
  actShowProgress.Checked := gbProgress.Visible;
  actShowSidebar.Checked := sbSidebar.Visible;
  actSmoothing.Checked := FDisplay.Smoothing;
end;

procedure TfrmMain.actEditModeExecute(Sender: TObject);
var
  Editable: Boolean;
begin
  Editable := not tbDisplay.Visible;
  tbDisplay.Visible := Editable;
  actEditMode.Checked := Editable;
  FDisplay.Editable := Editable;
  alMain.EnumByCategory(
    procedure(const Action: TContainedAction; var Done: Boolean)
    begin
      Action.Enabled := Editable;
    end, 'Edit');
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actGenerateGridExecute(Sender: TObject);
begin
  mdlgGenerateGrid.Execute(FDisplay.Graph);
end;

procedure TfrmMain.actSmoothingExecute(Sender: TObject);
begin
  FDisplay.Smoothing := not FDisplay.Smoothing;
  actSmoothing.Checked := FDisplay.Smoothing;
end;

procedure TfrmMain.actResetViewExecute(Sender: TObject);
begin
  FDisplay.ResetCamera;
end;

procedure TfrmMain.actShowProgressExecute(Sender: TObject);
begin
  gbProgress.Visible := not gbProgress.Visible;
  actShowProgress.Checked := gbProgress.Visible;
end;

procedure TfrmMain.actShowSidebarExecute(Sender: TObject);
begin
  sbSidebar.Visible := not sbSidebar.Visible;
  actShowSidebar.Checked := sbSidebar.Visible;
end;

procedure TfrmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
var Handled: Boolean);
var
  DisplayPos: TPoint;
begin
  DisplayPos := pbDisplay.ScreenToClient(MousePos);
  if pbDisplay.BoundsRect.Contains(DisplayPos) then
  begin
    FDisplay.MouseWheel(Shift, WheelDelta, DisplayPos);
    Handled := True;
  end;
end;

end.
