unit AntDefine;

interface

uses
  System.SysUtils,
  System.Math,

  Pengine.Collections,
  Pengine.Vector,
  Pengine.EventHandling,
  Pengine.CollectionInterfaces,
  Pengine.Bitfield,

  GraphDefine;

type

  TAnt = class;

  TPheromoneData = class
  private
    FGraph: TGraph;
    FPheromones: array of Single;

    function GetPheromones(AConnection: TGraph.TConnection): Single;
    procedure SetPheromones(AConnection: TGraph.TConnection; const Value: Single);

  public
    constructor Create(AGraph: TGraph);

    function Copy: TPheromoneData;
    procedure Assign(AFrom: TPheromoneData);

    property Graph: TGraph read FGraph;

    property Pheromones[AConnection: TGraph.TConnection]: Single read GetPheromones write SetPheromones; default;
    procedure Clear;

    procedure LeaveTrail(APath: IIterable<TGraph.TConnection>; AAmount: Single);
    procedure Dissipate(APercentage: Single);

  end;

  TAnt = class
  public type

    TPath = TRefArray<TGraph.TConnection>;

    TPoints = TRefArray<TGraph.TPoint>;

  private
    FPheromoneData: TPheromoneData;
    FPassedPoints: TBitfield;
    FInfluencedFactor: Single;
    FSuccess: Boolean;
    FPath: TPath;
    FPoints: TPoints;
    FPathLength: Single;

    function GetPheromoneAmount: Single;

    /// <summary>Tries to choose a connection.</returns>
    function ChooseConnection(APoint: TGraph.TPoint; out AConnection: TGraph.TConnection): Boolean;
    function GetGraph: TGraph;
    function GetPath: TPath.TReader;
    function GetPoints: TPoints.TReader;

  public
    constructor Create(APheromoneData: TPheromoneData);
    destructor Destroy; override;

    property Graph: TGraph read GetGraph;
    property PheromoneData: TPheromoneData read FPheromoneData;

    /// <summary>How much the ant is influenced by pheromones on the graph.</summary>
    property InfluencedFactor: Single read FInfluencedFactor write FInfluencedFactor;

    /// <summary>The full path of points, that this ant took.</summary>
    property Path: TPath.TReader read GetPath;
    property Points: TPoints.TReader read GetPoints;
    /// <returns>Whether the ant passed over the given point.</returns>
    function PassedPoint(APoint: TGraph.TPoint): Boolean;
    /// <summary>The total length of the path.</summary>
    property PathLength: Single read FPathLength;
    /// <summary>An arbitrary value ranging from 0 to 1, depending on how short the path is or zero on failure.</summary>
    property PheromoneAmount: Single read GetPheromoneAmount;

    /// <summary>Simulates the ant to traverse the graph.</summary>
    procedure FindPath;
    /// <summary>Leaves a trail on the graph, depending on how good the ant did and wether the finish was reached at all.</summary>
    procedure LeaveTrail;

    /// <summary>Whether the ant managed to find a finish.</summary>
    property Success: Boolean read FSuccess;

  end;

  TSimulation = class
  public type

    TStatisticType = (
      stBest,
      stWorst,
      stAverage,
      stMedian
      );

    TStatistic = array [TStatisticType] of Single;

    TBatch = class
    public type

      TAnts = TObjectArray<TAnt>;

    private
      FSimulation: TSimulation;
      FPheromoneData: TPheromoneData;
      FAnts: TAnts;

      function GetAnts: TAnts.TReader;

    public
      constructor Create(ASimulation: TSimulation; ACount: Integer);
      destructor Destroy; override;

      property Simulation: TSimulation read FSimulation;
      property PheromoneData: TPheromoneData read FPheromoneData;

      property Ants: TAnts.TReader read GetAnts;

      function GetPathLengthStatistic: TStatistic;

    end;

    TBatches = TObjectArray<TBatch>;

  private
    FGraph: TGraph;
    FInitialPheromoneData: TPheromoneData;
    FInfluencedFactor: Single;
    FPheromoneDissipation: Single;
    FBatchSize: Integer;
    FBatches: TBatches;

    function GetBatches: TBatches.TReader;
    function GetPheromoneData: TPheromoneData;

  public
    constructor Create(AGraph: TGraph);
    destructor Destroy; override;

    property Graph: TGraph read FGraph;
    /// <summary>The Pheromone Data of the lastly created Batch.</summary>
    property PheromoneData: TPheromoneData read GetPheromoneData;

    property BatchSize: Integer read FBatchSize write FBatchSize;
    property Batches: TBatches.TReader read GetBatches;

    function GenerateBatch: TBatch;

    property InfluencedFactor: Single read FInfluencedFactor write FInfluencedFactor;
    property PheromoneDissipation: Single read FPheromoneDissipation write FPheromoneDissipation;

    /// <summary>Removes all Batches.</summary>
    procedure Clear;

  end;

implementation

{ TAnt }

constructor TAnt.Create(APheromoneData: TPheromoneData);
begin
  FPheromoneData := APheromoneData;
  FPassedPoints := TBitfield.Create(Graph.Connections.Count);
  FPath := TPath.Create;
  FPoints := TPoints.Create;
end;

destructor TAnt.Destroy;
begin
  FPoints.Free;
  FPath.Free;
  FPassedPoints.Free;
  inherited;
end;

function TAnt.ChooseConnection(APoint: TGraph.TPoint; out AConnection: TGraph.TConnection): Boolean;

  function InfluencePheromones(APheromones: Single): Single;
  begin
    // 1.0 -> p
    // 0.5 -> p * 0.5 + 0.5
    // 0.0 -> 1
    Result := 1 + FInfluencedFactor * (APheromones - 1);
  end;

var
  Connections: TGraph.TConnections;
  Connection: TGraph.TConnection;
  TotalPheromones: Single;
  ConnectionIndex: Integer;
begin
  // Create a list of all valid next connections
  TotalPheromones := 0;
  Connections := TGraph.TConnections.Create;
  for Connection in APoint.Connections do
  begin
    if not PassedPoint(Connection.Other(APoint)) then
    begin
      Connections.Add(Connection);
      TotalPheromones := TotalPheromones + InfluencePheromones(PheromoneData[Connection]);
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
        function(A, B: TGraph.TConnection): Boolean
        begin
          Result := PheromoneData[A] > PheromoneData[B];
        end
        );

      // Randomize the value and find the now weighted random connection
      TotalPheromones := Random * TotalPheromones;
      while ConnectionIndex < Connections.MaxIndex do
      begin
        TotalPheromones := TotalPheromones - InfluencePheromones(PheromoneData[Connections[ConnectionIndex]]);
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
  Current: TGraph.TPoint;
  Connection: TGraph.TConnection;
begin
  Current := Graph.StartPoint;
  FPoints.Add(Current);
  FPassedPoints[Current.Index] := True;
  while Current <> Graph.FinishPoint do
  begin
    if ChooseConnection(Current, Connection) then
    begin
      FPath.Add(Connection);
      Current := Connection.Other(Current);
      FPoints.Add(Current);
      FPassedPoints[Current.Index] := True;
    end
    else
    begin
      if Path.Empty then
        Break;
      Current := FPath.Last.Other(Current);
      FPoints.RemoveLast;
      FPath.RemoveLast;
    end;
  end;
  FPathLength := 0;
  for Connection in Path do
    FPathLength := FPathLength + Connection.Cost;
  FSuccess := Current = Graph.FinishPoint;
end;

function TAnt.GetGraph: TGraph;
begin
  Result := PheromoneData.Graph;
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

function TAnt.GetPoints: TPoints.TReader;
begin
  Result := FPoints.Reader;
end;

procedure TAnt.LeaveTrail;
begin
  PheromoneData.LeaveTrail(FPath, PheromoneAmount);
end;

function TAnt.PassedPoint(APoint: TGraph.TPoint): Boolean;
begin
  Result := FPassedPoints[APoint.Index];
end;

{ TSimulation }

constructor TSimulation.Create(AGraph: TGraph);
begin
  FGraph := AGraph.Copy;
  FInitialPheromoneData := TPheromoneData.Create(Graph);
  FBatches := TBatches.Create;
  FBatchSize := 20;
  FInfluencedFactor := 0.9;
  FPheromoneDissipation := 0.5;
end;

destructor TSimulation.Destroy;
begin
  FGraph.Free;
  FInitialPheromoneData.Free;
  FBatches.Free;
  inherited;
end;

function TSimulation.GenerateBatch: TBatch;
begin
  Result := TBatch.Create(Self, BatchSize);
  FBatches.Add(Result);
end;

function TSimulation.GetBatches: TBatches.TReader;
begin
  Result := FBatches.Reader;
end;

function TSimulation.GetPheromoneData: TPheromoneData;
begin
  if Batches.Empty then
    Exit(FInitialPheromoneData);
  Result := Batches.Last.PheromoneData;
end;

procedure TSimulation.Clear;
begin
  FInitialPheromoneData.Clear;
  FBatches.Clear;
end;

{ TSimulation.TBatch }

constructor TSimulation.TBatch.Create(ASimulation: TSimulation; ACount: Integer);
var
  I: Integer;
  Ant: TAnt;
begin
  FSimulation := ASimulation;
  FPheromoneData := Simulation.PheromoneData.Copy;
  PheromoneData.Dissipate(Simulation.PheromoneDissipation);

  FAnts := TAnts.Create;
  for I := 0 to ACount - 1 do
  begin
    Ant := TAnt.Create(PheromoneData);
    Ant.InfluencedFactor := Simulation.InfluencedFactor;
    FAnts.Add(Ant);
    Ant.FindPath;
  end;

  for Ant in Ants do
    Ant.LeaveTrail;

  FAnts.Sort(
    function(A, B: TAnt): Boolean
    begin
      Result := A.PathLength < B.PathLength;
    end
  );
end;

destructor TSimulation.TBatch.Destroy;
begin
  FPheromoneData.Free;
  FAnts.Free;
  inherited;
end;

function TSimulation.TBatch.GetAnts: TAnts.TReader;
begin
  Result := FAnts.Reader;
end;

function TSimulation.TBatch.GetPathLengthStatistic: TStatistic;
var
  Ant: TAnt;
begin
  if Ants.Empty then
    raise Exception.Create('Data required to generate statistic.');

  Result[stBest] := Ants.First.PathLength;
  Result[stWorst] := Ants.Last.PathLength;
  Result[stAverage] := 0;
  for Ant in Ants do
    Result[stAverage] := Result[stAverage] + Ant.PathLength;
  Result[stAverage] := Result[stAverage] / Ants.Count;

  Result[stMedian] := Ants[Ants.MaxIndex div 2].PathLength;
  if not Odd(FAnts.Count) then
    Result[stMedian] := (Result[stMedian] + Ants[Ants.MaxIndex div 2 + 1].PathLength) / 2;
end;

{ TPheromoneData }

procedure TPheromoneData.Assign(AFrom: TPheromoneData);
begin
  FGraph := AFrom.Graph;
  SetLength(FPheromones, AFrom.Graph.Connections.Count);
  Move(AFrom.FPheromones[0], FPheromones[0], Length(FPheromones) * SizeOf(FPheromones[0]));
end;

procedure TPheromoneData.Clear;
begin
  FillChar(FPheromones[0], Length(FPheromones) * SizeOf(FPheromones[0]), 0);
end;

function TPheromoneData.Copy: TPheromoneData;
begin
  Result := TPheromoneData.Create(Graph);
  Result.Assign(Self);
end;

constructor TPheromoneData.Create(AGraph: TGraph);
begin
  FGraph := AGraph;
  SetLength(FPheromones, Graph.Connections.Count);
end;

procedure TPheromoneData.Dissipate(APercentage: Single);
var
  I: Integer;
begin
  for I := 0 to Length(FPheromones) - 1 do
    FPheromones[I] := FPheromones[I] * (1 - APercentage);
end;

function TPheromoneData.GetPheromones(AConnection: TGraph.TConnection): Single;
begin
  Result := FPheromones[AConnection.Index];
end;

procedure TPheromoneData.LeaveTrail(APath: IIterable<TGraph.TConnection>; AAmount: Single);
var
  Connection: TGraph.TConnection;
begin
  for Connection in APath do
    Pheromones[Connection] := Pheromones[Connection] + AAmount;
end;

procedure TPheromoneData.SetPheromones(AConnection: TGraph.TConnection; const Value: Single);
begin
  FPheromones[AConnection.Index] := Value;
end;

end.
