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
  System.Math,

  Vcl.ComCtrls,
  Vcl.Dialogs,
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
  Pengine.JSON,
  Pengine.Collections,
  Pengine.IntMaths,

  DisplayView,
  GraphDefine,
  MiniDialogGenerateGrid,
  AntDefine,
  Vcl.Grids;

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
    actGenerate: TAction;
    actStart: TAction;
    lbBatchSize: TLabel;
    seBatchSize: TSpinEdit;
    lbPheromoneDissipation: TLabel;
    edtPheromoneDissipation: TEdit;
    lbPheromoneDissipationUnit: TLabel;
    gbPopulation: TGroupBox;
    seBatch: TSpinEdit;
    lbBatch: TLabel;
    gbStatistics: TGroupBox;
    lbTodoChart: TLabel;
    splStatistics: TSplitter;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    tmrUpdate: TTimer;
    actReset: TAction;
    gbControl: TGroupBox;
    btnReset: TButton;
    btnStart: TButton;
    btnGenerate: TButton;
    Label1: TLabel;
    edtInfluenceFactor: TEdit;
    Label2: TLabel;
    lvAnts: TListView;
    btnHidePath: TButton;
    actHidePath: TAction;
    sgStatistics: TStringGrid;
    procedure actClearExecute(Sender: TObject);
    procedure actConnectionToolExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actEditorActiveExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actFinishToolExecute(Sender: TObject);
    procedure actGenerateGridExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSelectionToolExecute(Sender: TObject);
    procedure actPointToolExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actResetViewExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actGenerateExecute(Sender: TObject);
    procedure actGenerateUpdate(Sender: TObject);
    procedure actHidePathExecute(Sender: TObject);
    procedure actHidePathUpdate(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actStartToolExecute(Sender: TObject);
    procedure actStartUpdate(Sender: TObject);
    procedure edtInfluenceFactorExit(Sender: TObject);
    procedure edtPheromoneDissipationExit(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
      var Handled: Boolean);
    procedure lvAntsColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvAntsCompare(Sender: TObject; Item1, Item2: TListItem; Data:
      Integer; var Compare: Integer);
    procedure lvAntsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure seBatchChange(Sender: TObject);
    procedure seBatchExit(Sender: TObject);
    procedure seBatchSizeExit(Sender: TObject);
    procedure tmrUpdateTimer(Sender: TObject);
  private
    FDisplay: TDisplay;
    FSimulation: TSimulation;
    FSortColumn: Integer;

    procedure DisplayToolChange;
    function GetEditorDisplay: TEditorDisplay;
    function GetSimulationDisplay: TSimulationDisplay;
    function GetEditable: Boolean;
    procedure SetEditable(const Value: Boolean);
    function GetPheromoneData: TPheromoneData;

    procedure SyncSimulationData;
    procedure GenerateAntList;

  public
    property EditorDisplay: TEditorDisplay read GetEditorDisplay;
    property SimulationDisplay: TSimulationDisplay read GetSimulationDisplay;
    property PheromoneData: TPheromoneData read GetPheromoneData;

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
  FSimulation.Free;
  FDisplay.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Editable := False;
  DisplayToolChange;
  SyncSimulationData;

  sgStatistics.Cells[0, 0] := 'Best';
  sgStatistics.Cells[1, 0] := 'Worst';
  sgStatistics.Cells[2, 0] := 'Average';
  sgStatistics.Cells[3, 0] := 'Median';
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

procedure TfrmMain.actOpenExecute(Sender: TObject);
var
  JGraph: TJObject;
  Graph: TGraphEditable;
begin
  if not dlgOpen.Execute then
    Exit;

  Graph := nil;
  JGraph := nil;

  try
    Graph := TGraphEditable.Create;
    JGraph := TJObject.CreateFromFile(dlgOpen.FileName);

    TJSerializer.Unserialize(Graph, JGraph);

    if Editable then
    begin
      EditorDisplay.Graph := Graph;
    end
    else
    begin
      FSimulation.Free;
      FSimulation := TSimulation.Create(Graph);
      SimulationDisplay.PheromoneData := FSimulation.PheromoneData;
      SyncSimulationData;
    end;

    pbDisplay.Invalidate;

  finally
    JGraph.Free;
    Graph.Free;

  end;

  TPath.GetInvalidFileNameChars
end;

procedure TfrmMain.actSelectionToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etSelection;
end;

procedure TfrmMain.actPointToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etPoint;
end;

procedure TfrmMain.actResetExecute(Sender: TObject);
begin
  SimulationDisplay.VisibleAnt := nil;
  seBatch.MaxValue := 1;
  seBatch.Value := 1;
  seBatch.Enabled := False;
  FSimulation.Clear;
  SyncSimulationData;
  GenerateAntList;
  pbDisplay.Invalidate;
end;

procedure TfrmMain.actResetViewExecute(Sender: TObject);
begin
  FDisplay.Camera.Reset;
end;

procedure TfrmMain.actSaveAsExecute(Sender: TObject);
var
  Serialized: TJObject;
begin
  if not dlgSave.Execute then
    Exit;

  Serialized := TJSerializer.Serialize(EditorDisplay.Graph);
  try
    ForceDirectories(ExtractFilePath(dlgSave.FileName));
    Serialized.SaveToFile(dlgSave.FileName);

  finally
    Serialized.Free;

  end;
end;

procedure TfrmMain.actGenerateExecute(Sender: TObject);
begin
  FSimulation.GenerateBatch;
  seBatch.MaxValue := FSimulation.Batches.Count;
  seBatch.Value := FSimulation.Batches.Count;
  seBatch.Enabled := FSimulation.Batches.Count > 1;
  GenerateAntList;
  pbDisplay.Invalidate;
end;

procedure TfrmMain.actGenerateUpdate(Sender: TObject);
begin
  actGenerate.Enabled := PheromoneData.Graph.Valid;
end;

procedure TfrmMain.actHidePathExecute(Sender: TObject);
begin
  SimulationDisplay.VisibleAnt := nil;
end;

procedure TfrmMain.actHidePathUpdate(Sender: TObject);
begin
  actHidePath.Enabled := not Editable and (SimulationDisplay.VisibleAnt <> nil);
end;

procedure TfrmMain.actStartExecute(Sender: TObject);
begin
  tmrUpdate.Enabled := not tmrUpdate.Enabled;
end;

procedure TfrmMain.actStartToolExecute(Sender: TObject);
begin
  EditorDisplay.Tool := etStart;
end;

procedure TfrmMain.actStartUpdate(Sender: TObject);
begin
  actStart.Enabled := PheromoneData.Graph.Valid;
  if tmrUpdate.Enabled then
    actStart.Caption := 'Stop'
  else
    actStart.Caption := 'Start';
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

procedure TfrmMain.edtInfluenceFactorExit(Sender: TObject);
var
  Value: Single;
begin
  if FSimulation = nil then
    Exit;
  if Single.TryParse(edtInfluenceFactor.Text, Value, TFormatSettings.Invariant) then
    FSimulation.InfluencedFactor := EnsureRange(Value / 100, 0, 1);
  edtInfluenceFactor.Text := PrettyFloat(Single(FSimulation.InfluencedFactor * 100));
end;

procedure TfrmMain.edtPheromoneDissipationExit(Sender: TObject);
var
  Value: Single;
begin
  if FSimulation = nil then
    Exit;
  if Single.TryParse(edtPheromoneDissipation.Text, Value, TFormatSettings.Invariant) then
    FSimulation.PheromoneDissipation := EnsureRange(Value / 100, 0, 1);
  edtPheromoneDissipation.Text := PrettyFloat(Single(FSimulation.PheromoneDissipation * 100));
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

procedure TfrmMain.GenerateAntList;
var
  Batch: TSimulation.TBatch;
  I: Integer;
  Item: TListItem;
  S: TSimulation.TStatisticType;
  Stats: TSimulation.TStatistic;
begin
  SimulationDisplay.PheromoneData := FSimulation.PheromoneData;

  if FSimulation.Batches.Empty then
  begin
    for S := Low(TSimulation.TStatisticType) to High(TSimulation.TStatisticType) do
      sgStatistics.Cells[Ord(S), 1] := '-';
  end
  else
  begin
    Stats := FSimulation.Batches.Last.GetPathLengthStatistic;
    for S := Low(TSimulation.TStatisticType) to High(TSimulation.TStatisticType) do
      sgStatistics.Cells[Ord(S), 1] := Round(Stats[S]).ToString;
  end;

  lvAnts.Items.BeginUpdate;
  try
    lvAnts.Items.Clear;

    if FSimulation.Batches.Empty then
      Exit;

    Batch := FSimulation.Batches[seBatch.Value - 1];
    for I := 0 to Batch.Ants.MaxIndex do
    begin
      Item := lvAnts.Items.Add;
      Item.Caption := (I + 1).ToString;
      Item.Data := Batch.Ants[I];
      if Batch.Ants[I].Success then
        Item.SubItems.Add(Round(Batch.Ants[I].PathLength).ToString)
      else
        Item.SubItems.Add('failed');
    end;

  finally
    lvAnts.Items.EndUpdate;

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

function TfrmMain.GetPheromoneData: TPheromoneData;
begin
  Result := FSimulation.PheromoneData;
end;

procedure TfrmMain.SyncSimulationData;
begin
  seBatchSizeExit(nil);
  edtInfluenceFactorExit(nil);
  edtPheromoneDissipationExit(nil);
end;

function TfrmMain.GetSimulationDisplay: TSimulationDisplay;
begin
  Result := FDisplay as TSimulationDisplay;
end;

procedure TfrmMain.lvAntsColumnClick(Sender: TObject; Column: TListColumn);
begin
  if FSortColumn = Column.Index + 1 then
    FSortColumn := -FSortColumn
  else
    FSortColumn := Column.Index + 1;
  lvAnts.AlphaSort;
end;

procedure TfrmMain.lvAntsCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  Ant1, Ant2: TAnt;
begin
  Ant1 := Item1.Data;
  Ant2 := Item2.Data;
  case Abs(FSortColumn) of
    1:
      Compare := CompareValue(Item1.Caption.ToInteger, Item2.Caption.ToInteger);
    2:
      if not Ant1.Success or not Ant2.Success then
        Compare := IfThen(Ant1.Success, -1, 1)
      else
        Compare := CompareValue(Ant1.PathLength, Ant2.PathLength);
  end;
  Compare := Compare * Sign(FSortColumn);
end;

procedure TfrmMain.lvAntsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Ant: TAnt;
begin
  Ant := Item.Data;
  if Selected then
    SimulationDisplay.VisibleAnt := Ant
  else
    SimulationDisplay.VisibleAnt := nil;
end;

procedure TfrmMain.seBatchChange(Sender: TObject);
var
  Batch: Integer;
begin
  if not Integer.TryParse(seBatch.Text, Batch) then
    Exit;
  if FSimulation.Batches.RangeCheck(Batch - 1) then
    GenerateAntList;
end;

procedure TfrmMain.seBatchExit(Sender: TObject);
var
  Batch: Integer;
begin
  if not Integer.TryParse(seBatch.Text, Batch) then
    seBatch.Value := 1;
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
  Graph: TGraphEditable;
begin
  if FDisplay <> nil then
  begin
    if Editable = Value then
      Exit;
    Camera := FDisplay.Camera.Copy;
    Graph := FDisplay.Graph.Copy;
  end
  else
  begin
    Camera := nil;
    // default graph
    Graph := TGraphEditable.Create;
  end;

  if Value then
  begin
    FreeAndNil(FSimulation);
    FDisplay.Free;
    FDisplay := TEditorDisplay.Create(pbDisplay);
    EditorDisplay.OnToolChange.Add(DisplayToolChange);
    EditorDisplay.Graph := Graph;
  end
  else
  begin
    FDisplay.Free;
    FDisplay := TSimulationDisplay.Create(pbDisplay);
    FSimulation := TSimulation.Create(Graph);
    SimulationDisplay.PheromoneData := FSimulation.PheromoneData;
    SyncSimulationData;
  end;

  Graph.Free;

  if Camera <> nil then
  begin
    FDisplay.Camera := Camera;
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
    end,
    'Editor');
end;

procedure TfrmMain.tmrUpdateTimer(Sender: TObject);
begin
  if Editable then
  begin
    tmrUpdate.Enabled := False;
    Exit;
  end;

  FSimulation.GenerateBatch;
  pbDisplay.Invalidate;
end;

end.
