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
  System.Types,

  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.Menus,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,

  Pengine.Vector,
  Pengine.Utility,

  DisplayView,
  GraphDefine,
  MiniDialogGenerateGrid,
  AntDefine;

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
    gbSimulation: TGroupBox;
    miView: TMenuItem;
    actEditorActive: TAction;
    miEditMode: TMenuItem;
    pbDisplay: TPaintBox;
    tbDisplay: TToolBar;
    tbClear: TToolButton;
    tbSplit: TToolButton;
    actClear: TAction;
    ilIcons: TImageList;
    tbPointTool: TToolButton;
    tbConnectionTool: TToolButton;
    tbGenerateGrid: TToolButton;
    actGenerateGrid: TAction;
    actResetView: TAction;
    miResetView: TMenuItem;
    miEdit: TMenuItem;
    miClear: TMenuItem;
    miGenerateGrid: TMenuItem;
    actPointTool: TAction;
    actConnectionTool: TAction;
    N5: TMenuItem;
    PunktWerkzeug1: TMenuItem;
    VerbindungsWerkzeug1: TMenuItem;
    actSelectionTool: TAction;
    tbSelectionTool: TToolButton;
    KameraTool1: TMenuItem;
    tbStartTool: TToolButton;
    tbFinishTool: TToolButton;
    actStartTool: TAction;
    actFinishTool: TAction;
    StartWerkzeug1: TMenuItem;
    actFinishTool1: TMenuItem;
    N6: TMenuItem;
    btnSingleStep: TButton;
    btnStart: TButton;
    actSingleStep: TAction;
    actStart: TAction;
    lbBatchInterval: TLabel;
    edtBatchInterval: TEdit;
    lbBatchIntervalUnit: TLabel;
    lbBatchSize: TLabel;
    seBatchSize: TSpinEdit;
    lbPheromoneDissipation: TLabel;
    edtPheromoneDissipation: TEdit;
    lbPheromoneTrail: TLabel;
    edtPheromoneTrail: TEdit;
    lbPheromoneDissipationUnit: TLabel;
    lbStepSize: TLabel;
    gbPopulation: TGroupBox;
    seBatch: TSpinEdit;
    lbBatch: TLabel;
    lbPopulation: TListBox;
    lbTodoBatchStatistics: TLabel;
    lbTodoAntData: TLabel;
    edtStepSize: TEdit;
    gbStatistics: TGroupBox;
    lbTodoChart: TLabel;
    splStatistics: TSplitter;
    lbStepSizeUnit: TLabel;
    procedure actClearExecute(Sender: TObject);
    procedure actConnectionToolExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actEditorActiveExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actFinishToolExecute(Sender: TObject);
    procedure actGenerateGridExecute(Sender: TObject);
    procedure actSelectionToolExecute(Sender: TObject);
    procedure actPointToolExecute(Sender: TObject);
    procedure actResetViewExecute(Sender: TObject);
    procedure actSingleStepExecute(Sender: TObject);
    procedure actSingleStepUpdate(Sender: TObject);
    procedure actStartToolExecute(Sender: TObject);
    procedure edtBatchIntervalExit(Sender: TObject);
    procedure edtPheromoneTrailExit(Sender: TObject);
    procedure edtPheromoneDissipationExit(Sender: TObject);
    procedure edtStepSizeExit(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
      var Handled: Boolean);
    procedure seBatchSizeExit(Sender: TObject);
  private
    FBackupGraph: TGraph;
    FDisplay: TDisplay;
    FSimulation: TSimulation;

    procedure DisplayToolChange;
    function GetEditorDisplay: TEditorDisplay;
    function GetSimulationDisplay: TSimulationDisplay;
    function GetEditable: Boolean;
    procedure SetEditable(const Value: Boolean);
    function GetPheromoneMap: TPheromoneMap;
    procedure SyncSimulationData;

  public
    property EditorDisplay: TEditorDisplay read GetEditorDisplay;
    property SimulationDisplay: TSimulationDisplay read GetSimulationDisplay;
    property PheromoneMap: TPheromoneMap read GetPheromoneMap;

    property Editable: Boolean read GetEditable write SetEditable;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


procedure TfrmMain.actClearExecute(Sender: TObject);
begin
  EditorDisplay.Graph.Clear;
end;

procedure TfrmMain.actConnectionToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etConnection;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FBackupGraph.Free;
  FSimulation.Free;
  FDisplay.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Editable := False;
  DisplayToolChange;
  SyncSimulationData;
end;

procedure TfrmMain.actEditorActiveExecute(Sender: TObject);
begin
  Editable := not Editable;
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actFinishToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etFinish;
end;

procedure TfrmMain.actGenerateGridExecute(Sender: TObject);
begin
  mdlgGenerateGrid.Execute(EditorDisplay.Graph);
end;

procedure TfrmMain.actSelectionToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etSelection;
end;

procedure TfrmMain.actPointToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etPoint;
end;

procedure TfrmMain.actResetViewExecute(Sender: TObject);
begin
  FDisplay.Camera.Reset;
end;

procedure TfrmMain.actSingleStepExecute(Sender: TObject);
begin
  FSimulation.Step;
  pbDisplay.Invalidate;
end;

procedure TfrmMain.actSingleStepUpdate(Sender: TObject);
begin
  actSingleStep.Enabled := PheromoneMap.Valid;
end;

procedure TfrmMain.actStartToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etStart;
end;

procedure TfrmMain.DisplayToolChange;
begin
  if not Editable then
    Exit;
  actSelectionTool.Checked := EditorDisplay.Tool = etSelection;
  actPointTool.Checked := EditorDisplay.Tool = etPoint;
  actConnectionTool.Checked := EditorDisplay.Tool = etConnection;
  actStartTool.Checked := EditorDisplay.Tool = etStart;
  actFinishTool.Checked := EditorDisplay.Tool = etFinish;
end;

procedure TfrmMain.edtBatchIntervalExit(Sender: TObject);
var
  Value: Single;
begin
  if FSimulation = nil then
    Exit;
  if Single.TryParse(edtBatchInterval.Text, Value, TFormatSettings.Invariant) then
    FSimulation.BatchInterval := Value
  else
    edtBatchInterval.Text := PrettyFloat(FSimulation.BatchInterval);
end;

procedure TfrmMain.edtPheromoneTrailExit(Sender: TObject);
var
  Value: Single;
begin
  if FSimulation = nil then
    Exit;
  if Single.TryParse(edtPheromoneTrail.Text, Value, TFormatSettings.Invariant) then
    PheromoneMap.PheromoneTrail := Value
  else
    edtPheromoneTrail.Text := PrettyFloat(PheromoneMap.PheromoneTrail);
end;

procedure TfrmMain.edtPheromoneDissipationExit(Sender: TObject);
var
  Value: Single;
begin
  if FSimulation = nil then
    Exit;
  if Single.TryParse(edtPheromoneDissipation.Text, Value, TFormatSettings.Invariant) then
    PheromoneMap.PheromoneDissipation := Value
  else
    edtPheromoneDissipation.Text := PrettyFloat(PheromoneMap.PheromoneDissipation);
end;

procedure TfrmMain.edtStepSizeExit(Sender: TObject);
var
  Value: Single;
begin
  if FSimulation = nil then
    Exit;
  if Single.TryParse(edtStepSize.Text, Value, TFormatSettings.Invariant) then
    PheromoneMap.AntSpeed := Value
  else
    edtStepSize.Text := PrettyFloat(PheromoneMap.AntSpeed);
end;

procedure TfrmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  MousePos := MousePos - pbDisplay.ClientToScreen(Point(0, 0));
  if Rect(0, 0, pbDisplay.Width, pbDisplay.Height).Contains(MousePos) then
  begin
    FDisplay.MouseWheel(Shift, WheelDelta, MousePos);
    Handled := True;
  end;
end;

function TfrmMain.GetEditable: Boolean;
begin
  Result := FDisplay is TEditorDisplay;
end;

function TfrmMain.GetEditorDisplay: TEditorDisplay;
begin
  Result := FDisplay as TEditorDisplay;
end;

function TfrmMain.GetPheromoneMap: TPheromoneMap;
begin
  Result := SimulationDisplay.PheromoneMap;
end;

procedure TfrmMain.SyncSimulationData;
begin
  edtBatchIntervalExit(nil);
  seBatchSizeExit(nil);
  edtPheromoneDissipationExit(nil);
  edtPheromoneTrailExit(nil);
  edtStepSizeExit(nil);
end;

function TfrmMain.GetSimulationDisplay: TSimulationDisplay;
begin
  Result := FDisplay as TSimulationDisplay;
end;

procedure TfrmMain.seBatchSizeExit(Sender: TObject);
var
  Value: Integer;
begin
  if FSimulation = nil then
    Exit;
  if Integer.TryParse(seBatchSize.Text, Value) then
    FSimulation.BatchSize := Value
  else
    seBatchSize.Text := FSimulation.BatchSize.ToString;
end;

procedure TfrmMain.SetEditable(const Value: Boolean);
var
  Camera: TCamera;
begin
  if (FDisplay <> nil) then
  begin
    if Editable = Value then
      Exit;
    Camera := FDisplay.Camera.Copy;
  end
  else
    Camera := nil;

  if Value then
  begin
    FreeAndNil(FSimulation);
    FDisplay.Free;
    FDisplay := TEditorDisplay.Create(pbDisplay);
    EditorDisplay.OnToolChange.Add(DisplayToolChange);
    EditorDisplay.Graph.Assign(FBackupGraph);
  end
  else
  begin
    FBackupGraph.Free;
    if Editable then
      FBackupGraph := EditorDisplay.Graph.Copy
    else
      FBackupGraph := TGraph.Create; // TODO: Default loading
    FDisplay.Free;
    FDisplay := TSimulationDisplay.Create(pbDisplay, FBackupGraph);
    FSimulation := TSimulation.Create(SimulationDisplay.PheromoneMap);
    SyncSimulationData;
  end;

  if Camera <> nil then
  begin
    FDisplay.Camera.Assign(Camera);
    Camera.Free;
  end;

  if Value then
    actEditorActive.Caption := 'Editor deaktivieren'
  else
    actEditorActive.Caption := 'Editor aktivieren';

  tbDisplay.Visible := Editable;
  sbSidebar.Visible := not Editable;

  alMain.EnumByCategory(
    procedure(const Action: TContainedAction; var Done: Boolean)
    begin
      Action.Enabled := Editable or (Action = actEditorActive);
    end, 'Editor');
end;

end.
