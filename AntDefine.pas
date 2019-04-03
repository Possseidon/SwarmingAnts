unit AntDefine;

interface

uses
  System.SysUtils,

  Pengine.Collections,
  Pengine.Vector,
  Pengine.EventHandling,

  GraphDefine,
  System.Math;

type

  TMovingAnt = class;

  TPheromoneMap = class
  public type

    TAnts = TRefArray<TMovingAnt>;

    TConnection = class;

    TConnections = TRefArray<TConnection>;

    TPoint = class
    private
      FPheromoneMap: TPheromoneMap;
      FPos: TVector2;
      FConnections: TConnections;
      function GetConnections: TConnections.TReader;

    public
      constructor Create(APheromoneMap: TPheromoneMap; APos: TVector2);
      destructor Destroy; override;

      property PheromoneMap: TPheromoneMap read FPheromoneMap;

      property Connections: TConnections.TReader read GetConnections;

      function ConnectionTo(APoint: TPoint): TConnection;

      property Pos: TVector2 read FPos;
      function IsStart: Boolean;
      function IsFinish: Boolean;

    end;

    TConnection = class
    private
      FPheromoneMap: TPheromoneMap;
      FPointA: TPoint;
      FPointB: TPoint;
      FCost: Single;
      FPheromones: Single;

      procedure SetPheromones(const Value: Single);

    public
      constructor Create(APheromoneMap: TPheromoneMap; APointA, APointB: TPoint; ACostFactor: Single);

      property PointA: TPoint read FPointA;
      property PointB: TPoint read FPointB;
      property Cost: Single read FCost;
      property Pheromones: Single read FPheromones write SetPheromones;

      function Other(APoint: TPoint): TPoint;

      /// <summary>Dissipates a given percentage of pheromones on this connection.</summary>
      // procedure DissipatePheromones(APercentage: Single);

      /// <summary>Adds a given amount of pheromones on this connection.</summary>
      procedure LeaveTrail(AAmount: Single);

    end;

    TPoints = TRefArray<TPoint>;

    TPosition = class
    private
      FStart: TPoint;
      FConnection: TConnection;
      FProgress: Single;

      procedure SetStart(const Value: TPoint);
      function GetFinish: TPoint;
      procedure SetProgress(const Value: Single);
      function GetVisualPos: TVector2;

    public
      property Start: TPoint read FStart write SetStart;
      property Connection: TConnection read FConnection;
      property Finish: TPoint read GetFinish;
      property Progress: Single read FProgress write SetProgress;

      procedure StartMovement(AStart: TPoint; AConnection: TConnection); overload;
      procedure StartMovement(AConnection: TConnection); overload;

      property VisualPos: TVector2 read GetVisualPos;

    end;

  private
    FPoints: TPoints;
    FConnections: TConnections;
    FStartPoint: TPoint;
    FFinishPoint: TPoint;
    FAnts: TAnts;
    FActiveAnts: TAnts;
    FAntSpeed: Single;
    FPheromoneDissipation: Single;
    FPheromoneTrail: Single;
    FInfluencedFactor: Single;
    FValid: Boolean;

    function GetConnections: TConnections.TReader;
    function GetPoints: TPoints.TReader;
    function GetAnts: TAnts.TReader;
    function GetActiveAnts: TAnts.TReader;

  public
    constructor Create(AGraph: TGraph);
    destructor Destroy; override;

    property Valid: Boolean read FValid;

    /// <summary>All points in the graph.</summary>
    property Points: TPoints.TReader read GetPoints;
    /// <summary>All connections between points in the graph.</summary>
    property Connections: TConnections.TReader read GetConnections;

    property StartPoint: TPoint read FStartPoint;
    property FinishPoint: TPoint read FFinishPoint;

    /// <summary>All ants that are or were once on the map.</summary>
    property Ants: TAnts.TReader read GetAnts;
    /// <summary>All currently moving ants on the map.</summary>
    property ActiveAnts: TAnts.TReader read GetActiveAnts;

    /// <summary>Spawns in a single active ant at the start.</summary>
    function SpawnAnt: TMovingAnt;
    /// <summary>Spawns in group of active ants at the start.</summary>
    procedure SpawnAnts(ACount: Integer);

    /// <summary>Removes all ants from the map.</summary>
    procedure ClearAnts;
    /// <summary>Removes all pheoromone trails from the map.</summary>
    procedure ClearTrails;

    /// <summary>How much the ant moves to every call of the Step method.</summary>
    property AntSpeed: Single read FAntSpeed write FAntSpeed;
    /// <summary>Percentage of how much pheromone dissipate on every connection every timestep.</summary>
    property PheromoneDissipation: Single read FPheromoneDissipation write FPheromoneDissipation;
    /// <summary>How many pheromones newly created ants leave behind after passing a connection.</summary>
    property PheromoneTrail: Single read FPheromoneTrail write FPheromoneTrail;
    property InfluencedFactor: Single read FInfluencedFactor write FInfluencedFactor;

    /// <summary>Runs a single timestep, meaning pheromone dissipation and ant movement including pheromone trails.</summary>
    procedure Step(ADeltaTime: Single);

  end;

  TMovingAnt = class
  public type

    TState = (stActive, stFinished, stStuck, stKilled);

    TInactiveState = stFinished .. stKilled;

    TPath = TRefArray<TPheromoneMap.TPoint>;

  private
    FPheromoneMap: TPheromoneMap;
    FPosition: TPheromoneMap.TPosition;
    FSpeed: Single;
    FInfluencedFactor: Single;
    FPheromoneTrail: Single;
    FState: TState;
    FPath: TPath;

    /// <summary>Evaluates the best next direction for the ant.</summary>
    procedure EnsurePositionFinish;

    /// <summary>Deactives the ant for a given reason.</summary>
    procedure Deactivate(ANewState: TInactiveState);
    function GetPath: TPath.TReader;

  public
    constructor Create(APheromoneMap: TPheromoneMap);
    destructor Destroy; override;

    property PheromoneMap: TPheromoneMap read FPheromoneMap;

    /// <summary>The ants current position on the graph, including exact position on a connection.</summary>
    property Position: TPheromoneMap.TPosition read FPosition;
    /// <summary>A factor, multiplied onto the amount given in the Step method.</summary>
    property Speed: Single read FSpeed write FSpeed;
    /// <summary>How much the ant is influenced by pheromones on the graph.</summary>
    property InfluencedFactor: Single read FInfluencedFactor write FInfluencedFactor;
    /// <summary>How many pheromones the ant leaves behind after passing a connection.</summary>
    property PheromoneTrail: Single read FPheromoneTrail write FPheromoneTrail;

    /// <summary>The full path of points, that this ant took.</summary>
    property Path: TPath.TReader read GetPath;

    /// <summary>Moves the ant by the given amount.</summary>
    /// <remarks>The amount is actually multiplied with the speed of the ant first.</remarks>
    procedure Step(AAmount: Single);

    /// <summary>Whether this ant is still being processed by the PheromoneMap.</summary>
    function Active: Boolean;
    /// <summary>The state of the ant, being active, finished, stuck or killed.</summary>
    property State: TState read FState;
    /// <summary>Sets the state of the ant to being killed.</summary>
    procedure Kill;

  end;

  TSimulation = class
  public type

    TBatch = class
    public type

      TAnts = TRefArray<TMovingAnt>;

    private
      FPheromoneMap: TPheromoneMap;
      FAnts: TAnts;

    public
      constructor Create(APheromoneMap: TPheromoneMap; ACount: Integer);
      destructor Destroy; override;

      property PheromoneMap: TPheromoneMap read FPheromoneMap write FPheromoneMap;

    end;

    TBatches = TObjectArray<TBatch>;

  private
    FPheromoneMap: TPheromoneMap;
    FBatchSize: Integer;
    FBatchInterval: Single;
    FBatchTimeout: Single;
    FBatches: TBatches;

    function GetBatches: TBatches.TReader;

  public
    constructor Create(APheromoneMap: TPheromoneMap);
    destructor Destroy; override;

    property PheromoneMap: TPheromoneMap read FPheromoneMap;

    property BatchSize: Integer read FBatchSize write FBatchSize;
    property BatchInterval: Single read FBatchInterval write FBatchInterval;
    property Batches: TBatches.TReader read GetBatches;

    function GenerateBatch: TBatch;

    /// <summary>Steps the PheromoneMap and spawns in new ants as necessary.</summary>
    procedure Step(ADeltaTime: Single);

    /// <summary>Removes all ants and resets the rest of the simulation.</summary>
    procedure Clear;

  end;

implementation

{ TAnt }

function TMovingAnt.Active: Boolean;
begin
  Result := State = stActive;
end;

constructor TMovingAnt.Create(APheromoneMap: TPheromoneMap);
begin
  FPheromoneMap := APheromoneMap;
  FPosition := TPheromoneMap.TPosition.Create;
  Position.Start := PheromoneMap.StartPoint;
  FPath := TPath.Create;
  FPath.Add(Position.Start);
  Speed := 1.0;
  InfluencedFactor := PheromoneMap.InfluencedFactor;
  PheromoneTrail := PheromoneMap.PheromoneTrail;
end;

procedure TMovingAnt.Deactivate(ANewState: TInactiveState);
begin
  FState := ANewState;
end;

destructor TMovingAnt.Destroy;
begin
  FPath.Free;
  FPosition.Free;
  if PheromoneMap <> nil then
  begin
    PheromoneMap.FAnts.Remove(Self);
    if Active then
      PheromoneMap.FActiveAnts.Remove(Self);
  end;
  inherited;
end;

procedure TMovingAnt.EnsurePositionFinish;

  function InfluencePheromones(APheromones: Single): Single;
  begin
    // 1.0 -> p
    // 0.5 -> p * 0.5 + 0.5
    // 0.0 -> 1
    Result := 1 + FInfluencedFactor * (APheromones - 1);
  end;

var
  Connections: TPheromoneMap.TConnections;
  Connection: TPheromoneMap.TConnection;
  TotalPheromones: Single;
  ConnectionIndex: Integer;
  Point: TPheromoneMap.TPoint;
  I: Integer;
begin
  if Position.Connection <> nil then
    Exit;

  TotalPheromones := 0;
  Connections := TPheromoneMap.TConnections.Create;
  for Connection in Position.Start.Connections do
  begin
    if not Path.Contains(Connection.Other(Position.Start)) then
    begin
      Connections.Add(Connection);
      TotalPheromones := TotalPheromones + InfluencePheromones(Connection.Pheromones);
    end;
  end;

  if not Connections.Empty then
  begin
    ConnectionIndex := 0;
    if Connections.Count > 1 then
    begin
      Connections.Shuffle;

      Connections.Sort(
        function(A, B: TPheromoneMap.TConnection): Boolean
        begin
          Result := A.Pheromones > B.Pheromones;
        end
        );

      TotalPheromones := Random * TotalPheromones;
      while ConnectionIndex < Connections.MaxIndex do
      begin
        TotalPheromones := TotalPheromones - InfluencePheromones(Connections[ConnectionIndex].Pheromones);
        if TotalPheromones <= 0 then
          Break;
        Inc(ConnectionIndex);
      end;
    end;

    FPath.Add(Connections[ConnectionIndex].Other(Position.Start));
    Position.StartMovement(Connections[ConnectionIndex]);
    // Connections[ConnectionIndex].LeaveTrail(PheromoneTrail);

  end
  else
  begin
    Deactivate(stStuck);
    {
      for I := 0 to Path.MaxIndex - 1 do
      begin
      Connection := Path[I].ConnectionTo(Path[I + 1]);
      Connection.Pheromones := Connection.Pheromones * 0.5;
      end;
    }

    {
      ConnectionIndex := Random(Position.Start.Connections.Count);
      FPath.Add(Position.Start.Connections[ConnectionIndex].Other(Position.Start));
      Position.StartMovement(Position.Start.Connections[ConnectionIndex]);
      Position.Start.Connections[ConnectionIndex].LeaveTrail(PheromoneTrail);
    }
  end;

  Connections.Free;
end;

function TMovingAnt.GetPath: TPath.TReader;
begin
  Result := FPath.Reader;
end;

procedure TMovingAnt.Kill;
begin
  Deactivate(stKilled);
end;

procedure TMovingAnt.Step(AAmount: Single);
var
  CurrentProgress: Single;
  I: Integer;
begin
  Assert(Active, 'Cannot step inactive ant.');
  AAmount := AAmount * Speed;
  while AAmount > 0 do
  begin
    EnsurePositionFinish;

    if not Active then
      Break;

    CurrentProgress := AAmount / Position.Connection.Cost;
    if Position.Progress + CurrentProgress >= 1 then
    begin
      AAmount := AAmount - Position.Connection.Cost * (1 - Position.Progress);
      Position.Start := Position.Finish;
      if Position.Start.IsFinish then
      begin
        Deactivate(stFinished);
        for I := 0 to Path.MaxIndex - 1 do
          Path[I].ConnectionTo(Path[I + 1]).LeaveTrail(PheromoneTrail);
        Break;
      end;
    end
    else
    begin
      AAmount := 0;
      Position.Progress := Position.Progress + CurrentProgress;
    end;
  end;
end;

{ TPheromoneMap }

procedure TPheromoneMap.ClearAnts;
var
  Ant: TMovingAnt;
begin
  for Ant in FAnts do
    Ant.FPheromoneMap := nil;
  FAnts.OwnsObjects := True;
  FAnts.Clear;
  FActiveAnts.Clear;
end;

procedure TPheromoneMap.ClearTrails;
var
  Connection: TConnection;
begin
  for Connection in Connections do
    Connection.Pheromones := 0;
end;

constructor TPheromoneMap.Create(AGraph: TGraph);
var
  Point: TGraph.TPoint;
  Connection: TGraph.TConnection;
  NewConnection: TConnection;
begin
  FPoints := TPoints.Create(True);
  FConnections := TConnections.Create(True);

  for Point in AGraph.Points do
    FPoints.Add(TPoint.Create(Self, Point.Pos));

  for Connection in AGraph.Connections do
  begin
    NewConnection := TConnection.Create(Self, Points[Connection.PointA.Index], Points[Connection.PointB.Index],
      Connection.CostFactor);
    FConnections.Add(NewConnection);
    NewConnection.PointA.FConnections.Add(NewConnection);
    NewConnection.PointB.FConnections.Add(NewConnection);
  end;
  if AGraph.StartPoint <> nil then
    FStartPoint := Points[AGraph.StartPoint.Index];
  if AGraph.FinishPoint <> nil then
    FFinishPoint := Points[AGraph.FinishPoint.Index];

  FAnts := TAnts.Create;
  FActiveAnts := TAnts.Create;

  FAntSpeed := 1;
  FPheromoneDissipation := 0.5;
  FPheromoneTrail := 1.0;
  FInfluencedFactor := 0.9;

  FValid := (StartPoint <> nil) and (FinishPoint <> nil);
end;

destructor TPheromoneMap.Destroy;
begin
  ClearAnts;
  FAnts.Free;
  FActiveAnts.Free;
  FPoints.Free;
  FConnections.Free;
  inherited;
end;

function TPheromoneMap.GetActiveAnts: TAnts.TReader;
begin
  Result := FActiveAnts.Reader;
end;

function TPheromoneMap.GetAnts: TAnts.TReader;
begin
  Result := FAnts.Reader;
end;

function TPheromoneMap.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TPheromoneMap.GetPoints: TPoints.TReader;
begin
  Result := FPoints.Reader;
end;

function TPheromoneMap.SpawnAnt: TMovingAnt;
begin
  Result := TMovingAnt.Create(Self);
  FAnts.Add(Result);
  FActiveAnts.Add(Result);
end;

procedure TPheromoneMap.SpawnAnts(ACount: Integer);
var
  I: Integer;
begin
  for I := 0 to ACount - 1 do
    SpawnAnt;
end;

procedure TPheromoneMap.Step(ADeltaTime: Single);
var
  Connection: TConnection;
  I: Integer;
begin
  for Connection in Connections do
    Connection.Pheromones := Connection.Pheromones * Power(1 - PheromoneDissipation, ADeltaTime);
  for I := ActiveAnts.MaxIndex downto 0 do
  begin
    ActiveAnts[I].Step(AntSpeed * ADeltaTime);
    if not ActiveAnts[I].Active then
      FActiveAnts.RemoveAt(I);
  end;
end;

{ TPheromoneMap.TPosition }

function TPheromoneMap.TPosition.GetFinish: TPoint;
begin
  if Connection = nil then
    Exit(nil);
  Result := Connection.Other(Start);
end;

function TPheromoneMap.TPosition.GetVisualPos: TVector2;
begin
  Result := Start.Pos * (1 - Progress);
  if Progress <> 0 then
    Result := Result + Finish.Pos * Progress;
end;

procedure TPheromoneMap.TPosition.SetProgress(const Value: Single);
begin
  if Progress = Value then
    Exit;
  FProgress := Value;
end;

procedure TPheromoneMap.TPosition.SetStart(const Value: TPoint);
begin
  FStart := Value;
  FConnection := nil;
  FProgress := 0;
end;

procedure TPheromoneMap.TPosition.StartMovement(AConnection: TConnection);
begin
  FConnection := AConnection;
  FProgress := 0;
end;

procedure TPheromoneMap.TPosition.StartMovement(AStart: TPoint; AConnection: TConnection);
begin
  FStart := AStart;
  StartMovement(AConnection);
end;

{ TPheromoneMap.TConnection }

constructor TPheromoneMap.TConnection.Create(APheromoneMap: TPheromoneMap; APointA, APointB: TPoint;
ACostFactor: Single);
begin
  FPheromoneMap := APheromoneMap;
  FPointA := APointA;
  FPointB := APointB;
  FCost := ACostFactor * APointA.Pos.DistanceTo(APointB.Pos);
end;

// procedure TPheromoneMap.TConnection.DissipatePheromones(APercentage: Single);
// begin
// Pheromones := Pheromones * (1 - APercentage)
// end;

procedure TPheromoneMap.TConnection.LeaveTrail(AAmount: Single);
begin
  Pheromones := Pheromones + AAmount;
end;

function TPheromoneMap.TConnection.Other(APoint: TPoint): TPoint;
begin
  if APoint = PointA then
    Exit(PointB);
  Result := PointA;
end;

procedure TPheromoneMap.TConnection.SetPheromones(const Value: Single);
begin
  FPheromones := Value;
end;

{ TPheromoneMap.TPoint }

function TPheromoneMap.TPoint.ConnectionTo(APoint: TPoint): TConnection;
begin
  for Result in Connections do
    if Result.Other(Self) = APoint then
      Exit;
  Result := nil;
end;

constructor TPheromoneMap.TPoint.Create(APheromoneMap: TPheromoneMap; APos: TVector2);
begin
  FPheromoneMap := APheromoneMap;
  FPos := APos;
  FConnections := TConnections.Create;
end;

destructor TPheromoneMap.TPoint.Destroy;
begin
  FConnections.Free;
  inherited;
end;

function TPheromoneMap.TPoint.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TPheromoneMap.TPoint.IsFinish: Boolean;
begin
  Result := PheromoneMap.FinishPoint = Self;
end;

function TPheromoneMap.TPoint.IsStart: Boolean;
begin
  Result := PheromoneMap.StartPoint = Self;
end;

{ TSimulation }

constructor TSimulation.Create(APheromoneMap: TPheromoneMap);
begin
  FPheromoneMap := APheromoneMap;
  FBatches := TBatches.Create;
  FBatchSize := 20;
  FBatchInterval := 1;
end;

destructor TSimulation.Destroy;
begin
  FBatches.Free;
  inherited;
end;

function TSimulation.GenerateBatch: TBatch;
begin
  Result := TBatch.Create(PheromoneMap, BatchSize);
  FBatches.Add(Result);
end;

function TSimulation.GetBatches: TBatches.TReader;
begin
  Result := FBatches.Reader;
end;

procedure TSimulation.Clear;
begin
  PheromoneMap.ClearAnts;
  PheromoneMap.ClearTrails;
  FBatches.Clear;
  FBatchTimeout := 0;
end;

procedure TSimulation.Step(ADeltaTime: Single);
begin
  if not PheromoneMap.Valid then
    raise Exception.Create('Graph is not valid');

  FBatchTimeout := FBatchTimeout - ADeltaTime;
  while FBatchTimeout <= 0 do
  begin
    GenerateBatch;
    FBatchTimeout := FBatchTimeout + BatchInterval;
    if ADeltaTime > BatchInterval then
    begin
      PheromoneMap.Step(FBatchInterval);
      ADeltaTime := ADeltaTime - BatchInterval;
    end;
  end;
  PheromoneMap.Step(ADeltaTime);
end;

{ TSimulation.TBatch }

constructor TSimulation.TBatch.Create(APheromoneMap: TPheromoneMap; ACount: Integer);
var
  I: Integer;
begin
  FPheromoneMap := APheromoneMap;
  FAnts := TAnts.Create;
  for I := 0 to ACount - 1 do
    FAnts.Add(PheromoneMap.SpawnAnt);
end;

destructor TSimulation.TBatch.Destroy;
begin
  FAnts.Free;
  inherited;
end;

end.
