unit AntDefine;

interface

uses
  System.SysUtils,

  Pengine.Collections,
  Pengine.Vector,
  Pengine.EventHandling,

  GraphDefine;

type

  TAnt = class;

  TPheromoneMap = class
  public type

    TAnts = TRefArray<TAnt>;

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

      property Pos: TVector2 read FPos;

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
      procedure DissipatePheromones(APercentage: Single);

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
    FAntSpeed: Single;
    FPheromoneDissipation: Single;
    FPheromoneTrail: Single;
    FValid: Boolean;

    function GetConnections: TConnections.TReader;
    function GetPoints: TPoints.TReader;
    function GetAnts: TAnts.TReader;

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

    /// <summary>All ants on the map.</summary>
    property Ants: TAnts.TReader read GetAnts;

    /// <summary>Spawns in a single ant at the start.</summary>
    function SpawnAnt: TAnt;
    /// <summary>Spawns in multiple ants at the start.</summary>
    procedure SpawnAnts(ACount: Integer);

    /// <summary>Removed all ants from the map.</summary>
    procedure ClearAnts;

    /// <summary>How much the ant moves to every call of the Step method.</summary>
    property AntSpeed: Single read FAntSpeed write FAntSpeed;
    /// <summary>Percentage of how much pheromone dissipate on every connection every timestep.</summary>
    property PheromoneDissipation: Single read FPheromoneDissipation write FPheromoneDissipation;
    /// <summary>How many pheromones newly created ants leave behind after passing a connection.</summary>
    property PheromoneTrail: Single read FPheromoneTrail write FPheromoneTrail;

    /// <summary>Runs a single timestep, meaning pheromone dissipation and ant movement including pheromone trails.</summary>
    procedure Step;

  end;

  TAnt = class
  private
    FPheromoneMap: TPheromoneMap;
    FPosition: TPheromoneMap.TPosition;
    FLastConnection: TPheromoneMap.TConnection;
    FSpeed: Single;
    FInfluencedFactor: Single;
    FPheromoneTrail: Single;

    /// <summary>Evaluates the best next direction for the ant.</summary>
    procedure EnsurePositionFinish;

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

    /// <summary>Moves the ant by the given amount.</summary>
    /// <remarks>The amount is actually multiplied with the speed of the ant first.</remarks>
    procedure Step(AAmount: Single);

  end;

  TSimulation = class
  public type

    TBatch = class
    public type

      TAnts = TRefArray<TAnt>;

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

    procedure Step;

  end;

implementation

{ TAnt }

constructor TAnt.Create(APheromoneMap: TPheromoneMap);
begin
  FPheromoneMap := APheromoneMap;
  FPosition := TPheromoneMap.TPosition.Create;
  Position.Start := PheromoneMap.StartPoint;
  Speed := 1.0;
  InfluencedFactor := 0.5;
  PheromoneTrail := 0.1;
end;

destructor TAnt.Destroy;
begin
  FPosition.Free;
  if PheromoneMap <> nil then
    PheromoneMap.FAnts.Remove(Self);
  inherited;
end;

procedure TAnt.EnsurePositionFinish;

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
begin
  if Position.Connection <> nil then
    Exit;

  TotalPheromones := 0;
  Connections := TPheromoneMap.TConnections.Create;
  for Connection in Position.Start.Connections do
  begin
    if Connection <> FLastConnection then
    begin
      Connections.Add(Connection);
      TotalPheromones := TotalPheromones + InfluencePheromones(Connection.Pheromones);
    end;
  end;
  Connections.Sort(
    function(A, B: TPheromoneMap.TConnection): Boolean
    begin
      Result := A.Pheromones > B.Pheromones;
    end
    );

  TotalPheromones := Random * TotalPheromones;
  ConnectionIndex := 0;
  while ConnectionIndex < Connections.MaxIndex do
  begin
    TotalPheromones := TotalPheromones - InfluencePheromones(Connections[ConnectionIndex].Pheromones);
    if TotalPheromones <= 0 then
      Break;
    Inc(ConnectionIndex);
  end;
  Position.StartMovement(Connections[ConnectionIndex]);

  Connections.Free;
end;

procedure TAnt.Step(AAmount: Single);
var
  CurrentProgress: Single;
begin
  AAmount := AAmount * Speed;
  while AAmount > 0 do
  begin
    EnsurePositionFinish;

    CurrentProgress := AAmount / Position.Connection.Cost;
    if Position.Progress + CurrentProgress >= 1 then
    begin
      AAmount := AAmount - CurrentProgress;
      Position.Start := Position.Finish;
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
  Ant: TAnt;
begin
  for Ant in FAnts do
    Ant.FPheromoneMap := nil;
  FAnts.OwnsObjects := True;
  FAnts.Clear;
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
  FAntSpeed := 1;
  FPheromoneDissipation := 0.5;

  FValid := (StartPoint <> nil) and (FinishPoint <> nil);
end;

destructor TPheromoneMap.Destroy;
begin
  ClearAnts;
  FAnts.Free;
  FPoints.Free;
  FConnections.Free;
  inherited;
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

function TPheromoneMap.SpawnAnt: TAnt;
begin
  Result := TAnt.Create(Self);
  Result.PheromoneTrail := PheromoneTrail;
  FAnts.Add(Result);
end;

procedure TPheromoneMap.SpawnAnts(ACount: Integer);
var
  I: Integer;
begin
  for I := 0 to ACount - 1 do
    SpawnAnt;
end;

procedure TPheromoneMap.Step;
var
  Connection: TConnection;
  Ant: TAnt;
begin
  for Connection in Connections do
    Connection.DissipatePheromones(PheromoneDissipation);
  for Ant in Ants do
    Ant.Step(AntSpeed);
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

procedure TPheromoneMap.TConnection.DissipatePheromones(APercentage: Single);
begin
  Pheromones := Pheromones * (1 - APercentage)
end;

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

procedure TSimulation.Step;
begin
  if not PheromoneMap.Valid then
    raise Exception.Create('Graph is not valid');
  FBatchTimeout := FBatchTimeout - PheromoneMap.AntSpeed;
  while FBatchTimeout <= 0 do
  begin
    GenerateBatch;
    FBatchTimeout := FBatchTimeout + FBatchInterval;
  end;
  PheromoneMap.Step;
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
