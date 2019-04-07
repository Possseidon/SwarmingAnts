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

      function EitherIs(APoint: TPoint): Boolean;
      
      /// <summary>Assumes that the point is valid and returns the other point.</summay>
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
    FPheromoneDissipation: Single;
    FInfluencedFactor: Single;
    FValid: Boolean;

    function GetConnections: TConnections.TReader;
    function GetPoints: TPoints.TReader;

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

    /// <summary>Removes all pheoromone trails from the map.</summary>
    procedure ClearTrails;

    /// <summary>Percentage of how much pheromone dissipate on every connection every timestep.</summary>
    property PheromoneDissipation: Single read FPheromoneDissipation write FPheromoneDissipation;
    /// <summary>How much the ants get influenced by the pheromone trail.</summary>
    property InfluencedFactor: Single read FInfluencedFactor write FInfluencedFactor;

    /// <summary>Globally dissipates a percentage of the pheromones on each connection.</summary>
    procedure DissipatePheromones;
    
  end;

  TAnt = class
  public type

    TPath = TRefArray<TPheromoneMap.TConnection>;

  private
    FPheromoneMap: TPheromoneMap;
    FInfluencedFactor: Single;
    FSuccess: Boolean;
    FPath: TPath;
    FPathLength: Single;

    function GetPath: TPath.TReader;
    function GetPheromoneAmount: Single;

    /// <summary>Tries to choose a connection.</returns>
    function ChooseConnection(APoint: TPheromoneMap.TPoint; out AConnection: TPheromoneMap.TConnection): Boolean;

  public
    constructor Create(APheromoneMap: TPheromoneMap);
    destructor Destroy; override;

    property PheromoneMap: TPheromoneMap read FPheromoneMap;

    /// <summary>How much the ant is influenced by pheromones on the graph.</summary>
    property InfluencedFactor: Single read FInfluencedFactor write FInfluencedFactor;

    /// <summary>The full path of points, that this ant took.</summary>
    property Path: TPath.TReader read GetPath;
    /// <returns>Whether the ant passed over the given point.</returns>
    function PassedPoint(APoint: TPheromoneMap.TPoint): Boolean;
    /// <summary>The total length of the path.</summary>
    property PathLength: Single read FPathLength;
    /// <summary>An arbitrary value ranging from 0 to 1, depending on how short the path is or zero on failure.</summary>
    property PheromoneAmount: Single read GetPheromoneAmount;

    /// <summary>Simulates the ant to traverse the map.</summary>
    procedure FindPath;
    /// <summary>Leaves a trail on the map, depending on how good the ant did and wether the finish was reached at all.</summary>
    procedure LeaveTrail;

    /// <summary>Whether the ant managed to find a finish.</summary>
    property Success: Boolean read FSuccess;

  end;

  TSimulation = class
  public type

    TBatch = class
    public type

      TAnts = TObjectArray<TAnt>;

    private
      FPheromoneMap: TPheromoneMap;
      FAnts: TAnts;
      
      function GetAnts: TAnts.TReader;

    public
      constructor Create(APheromoneMap: TPheromoneMap; ACount: Integer);
      destructor Destroy; override;

      property PheromoneMap: TPheromoneMap read FPheromoneMap write FPheromoneMap;

      property Ants: TAnts.TReader read GetAnts;

    end;

    TBatches = TObjectArray<TBatch>;

  private
    FPheromoneMap: TPheromoneMap;
    FBatchSize: Integer;
    FBatches: TBatches;

    function GetBatches: TBatches.TReader;

  public
    constructor Create(APheromoneMap: TPheromoneMap);
    destructor Destroy; override;

    property PheromoneMap: TPheromoneMap read FPheromoneMap;

    property BatchSize: Integer read FBatchSize write FBatchSize;
    property Batches: TBatches.TReader read GetBatches;

    function GenerateBatch: TBatch;

    /// <summary>Removes all ants and resets the rest of the simulation.</summary>
    procedure Clear;

  end;

implementation

{ TAnt }

constructor TAnt.Create(APheromoneMap: TPheromoneMap);
begin
  FPheromoneMap := APheromoneMap;
  FPath := TPath.Create;
  InfluencedFactor := PheromoneMap.InfluencedFactor;
end;

destructor TAnt.Destroy;
begin
  FPath.Free;
  inherited;
end;

function TAnt.ChooseConnection(APoint: TPheromoneMap.TPoint; out AConnection: TPheromoneMap.TConnection): Boolean;

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
  // Create a list of all valid next connections
  TotalPheromones := 0;
  Connections := TPheromoneMap.TConnections.Create;
  for Connection in APoint.Connections do
  begin
    if not PassedPoint(Connection.Other(APoint)) then
    begin
      Connections.Add(Connection);
      TotalPheromones := TotalPheromones + InfluencePheromones(Connection.Pheromones);
    end;
  end;

  Result := not Connections.Empty;

  if Result then
  begin
    ConnectionIndex := 0;
    if Connections.Count > 1 then
    begin
      // Quick workaround for influence fator of 1 and pheromones all 0 resulting in a total of 0
      Connections.Shuffle;

      // Sort by best pheromone amount
      Connections.Sort(
        function(A, B: TPheromoneMap.TConnection): Boolean
        begin
          Result := A.Pheromones > B.Pheromones;
        end
        );

      // Randomize the value and find the now weighted random connection
      TotalPheromones := Random * TotalPheromones;
      while ConnectionIndex < Connections.MaxIndex do
      begin
        TotalPheromones := TotalPheromones - InfluencePheromones(Connections[ConnectionIndex].Pheromones);
        if TotalPheromones <= 0 then
          Break;
        Inc(ConnectionIndex);
      end;
    end;

    AConnection := Connections[ConnectionIndex];

  end;

  Connections.Free;
end;

procedure TAnt.FindPath;
var
  Current: TPheromoneMap.TPoint;
  Connection: TPheromoneMap.TConnection;
begin
  Current := PheromoneMap.StartPoint;
  while (Current <> PheromoneMap.FinishPoint) and ChooseConnection(Current, Connection) do
  begin
    FPath.Add(Connection);
    Current := Connection.Other(Current);
    FPathLength := FPathLength + Connection.Cost;
  end;
  FSuccess := Current = PheromoneMap.FinishPoint;
end;

function TAnt.GetPath: TPath.TReader;
begin
  Result := FPath.Reader;
end;

function TAnt.GetPheromoneAmount: Single;
begin
  if Success then
    Result := Power(1.01, -PathLength)
  else
    Result := 0;
end;

procedure TAnt.LeaveTrail;
var
  Connection: TPheromoneMap.TConnection;
  P: Single;
begin
  P := PheromoneAmount;
  for Connection in Path do
    Connection.LeaveTrail(P);
end;

function TAnt.PassedPoint(APoint: TPheromoneMap.TPoint): Boolean;
var
  Connection: TPheromoneMap.TConnection;
begin
  for Connection in Path do
    if Connection.EitherIs(APoint) then
      Exit(True);
  Result := False;    
end;

{ TPheromoneMap }

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

  FPheromoneDissipation := 0.5;
  FInfluencedFactor := 0.8;

  FValid := (StartPoint <> nil) and (FinishPoint <> nil);
end;

destructor TPheromoneMap.Destroy;
begin
  FPoints.Free;
  FConnections.Free;
  inherited;
end;

procedure TPheromoneMap.DissipatePheromones;
var
  Connection: TConnection;
begin
  for Connection in Connections do
    Connection.DissipatePheromones(PheromoneDissipation);
end;

function TPheromoneMap.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TPheromoneMap.GetPoints: TPoints.TReader;
begin
  Result := FPoints.Reader;
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

function TPheromoneMap.TConnection.EitherIs(APoint: TPoint): Boolean;
begin
  Result := (APoint = PointA) or (APoint = PointB);
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
  PheromoneMap.ClearTrails;
  FBatches.Clear;
end;

{ TSimulation.TBatch }

constructor TSimulation.TBatch.Create(APheromoneMap: TPheromoneMap; ACount: Integer);
var
  I: Integer;
  Ant: TAnt;
begin
  FPheromoneMap := APheromoneMap;
  FAnts := TAnts.Create;

  PheromoneMap.DissipatePheromones;

  for I := 0 to ACount - 1 do
  begin
    Ant := TAnt.Create(PheromoneMap);
    FAnts.Add(Ant);
    Ant.FindPath;
  end;

  for Ant in Ants do
    Ant.LeaveTrail;
end;

destructor TSimulation.TBatch.Destroy;
begin
  FAnts.Free;
  inherited;
end;

function TSimulation.TBatch.GetAnts: TAnts.TReader;
begin
  Result := FAnts.Reader;
end;

end.
