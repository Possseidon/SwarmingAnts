unit GraphDefine;

interface

uses
  Pengine.EventHandling,
  Pengine.Vector,
  Pengine.Collections,
  Pengine.IntMaths;

type

  TGraph = class
  public type

    TConnection = class;

    TConnections = TRefArray<TConnection>;

    TPoint = class
    private
      FGraph: TGraph;
      FPos: TVector2;
      FConnections: TConnections;

      procedure SetPos(const Value: TVector2);
      function GetConnections: TConnections.TReader;

      function GetIsFinish: Boolean;
      function GetIsStart: Boolean;
      procedure SetIsFinish(const Value: Boolean);
      procedure SetIsStart(const Value: Boolean);
      function GetIndex: Integer;

    public
      constructor Create(AGraph: TGraph; APos: TVector2);
      destructor Destroy; override;

      property Index: Integer read GetIndex;

      property Graph: TGraph read FGraph;

      property Pos: TVector2 read FPos write SetPos;

      property Connections: TConnections.TReader read GetConnections;

      function IsConnected(AOther: TPoint): Boolean;
      function FindConnection(AOther: TPoint): TConnection;

      function Connect(AOther: TPoint): TConnection;

      property IsStart: Boolean read GetIsStart write SetIsStart;
      property IsFinish: Boolean read GetIsFinish write SetIsFinish;

    end;

    TConnection = class
    public type

      TEventInfo = TSenderEventInfo<TConnection>;

      TEvent = TEvent<TEventInfo>;

    private
      FGraph: TGraph;
      FPointA: TPoint;
      FPointB: TPoint;
      FCostFactor: Single;
      FOnChange: TEvent;

      function GetCost: Single;
      procedure SetCostFactor(const Value: Single);
      function GetIndex: Integer;
      function GetOnChange: TEvent.TAccess;

    public
      constructor Create(AGraph: TGraph; APointA, APointB: TPoint);
      destructor Destroy; override;

      property Graph: TGraph read FGraph;
      property Index: Integer read GetIndex;

      function AnyIs(APoint: TPoint): Boolean;
      function Other(APoint: TPoint): TPoint;

      property PointA: TPoint read FPointA;
      property PointB: TPoint read FPointB;
      property CostFactor: Single read FCostFactor write SetCostFactor;
      property Cost: Single read GetCost;

      property OnChange: TEvent.TAccess read GetOnChange;

    end;

    TPoints = TRefArray<TPoint>;

    TGenerator = class abstract
    private
      FGraph: TGraph;

    public
      constructor Create(AGraph: TGraph);

      property Graph: TGraph read FGraph;

      procedure Generate; virtual; abstract;

    end;

    /// <summary>Generates a grid of variable size and position.</summary>
    TGridGenerator = class(TGenerator)
    private
      FBounds: TBounds2;
      FSize: TIntVector2;

    public
      property Bounds: TBounds2 read FBounds write FBounds;
      property Size: TIntVector2 read FSize write FSize;

      procedure Generate; override;

    end;

    TRandomPointGenerator = class(TGenerator)
    private
      FBounds: TBounds2;
      FCount: Integer;

    public
      property Bounds: TBounds2 read FBounds write FBounds;
      property Count: Integer read FCount write FCount;

      procedure Generate; override;

    end;

    TDelaunayTriangulator = class(TGenerator)

    end;

    TEventInfo = TSenderEventInfo<TGraph>;

    TEvent = TEvent<TEventInfo>;

  private
    FPoints: TPoints;
    FConnections: TConnections;
    FStartPoint: TPoint;
    FFinishPoint: TPoint;
    FOnChange: TEvent;

    procedure Changed;

    function GetConnections: TConnections.TReader;
    function GetPoints: TPoints.TReader;
    procedure SetFinishPoint(const Value: TPoint);
    procedure SetStartPoint(const Value: TPoint);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(AFrom: TGraph);

    /// <returns>An exact copy of the whole graph.</returns>
    /// <remarks>Runtime of O(n^2), as this uses the <c>Index</c> property which uses linear lookup.</remarks>
    function Copy: TGraph;

    /// <summary>A readonly list of all points.</summary>
    property Points: TPoints.TReader read GetPoints;
    /// <summary>A readonly list of all connections between points.</summary>
    property Connections: TConnections.TReader read GetConnections;

    /// <summary>A single start point for this graph.</summary>
    property StartPoint: TPoint read FStartPoint write SetStartPoint;
    /// <summary>A single finish point for this graph.</summary>
    property FinishPoint: TPoint read FFinishPoint write SetFinishPoint;

    /// <summary>Adds a point at the specified position and returns said point.</summary>
    function AddPoint(APos: TVector2): TPoint;
    /// <summary>Creates a connection between two given points and returns said connection.</summary>
    function Connect(A, B: TPoint): TConnection;

    /// <summary>Removes all points and connections from the graph.</summary>
    procedure Clear;

    /// <summary>Called whenever the graph changes in any way.</summary>
    function OnChange: TEvent.TAccess;

  end;

implementation

{ TGraph.TPoint }

function TGraph.TPoint.Connect(AOther: TPoint): TConnection;
begin
  Result := TConnection.Create(Graph, Self, AOther);
end;

constructor TGraph.TPoint.Create(AGraph: TGraph; APos: TVector2);
begin
  FGraph := AGraph;
  FPos := APos;
  FConnections := TConnections.Create;
  Graph.FPoints.Add(Self);
end;

destructor TGraph.TPoint.Destroy;
begin
  if Graph <> nil then
  begin
    IsStart := False;
    IsFinish := False;
    while not FConnections.Empty do
      FConnections.Last.Free;
    Graph.FPoints.Remove(Self);
    Graph.Changed;
  end;
  FConnections.Free;
  inherited;
end;

function TGraph.TPoint.FindConnection(AOther: TPoint): TConnection;
begin
  for Result in Connections do
    if Result.AnyIs(AOther) then
      Exit;
  Result := nil;
end;

function TGraph.TPoint.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TGraph.TPoint.GetIndex: Integer;
begin
  Result := Graph.Points.Find(Self);
end;

function TGraph.TPoint.GetIsFinish: Boolean;
begin
  Result := Self = Graph.FinishPoint;
end;

function TGraph.TPoint.GetIsStart: Boolean;
begin
  Result := Self = Graph.StartPoint;
end;

function TGraph.TPoint.IsConnected(AOther: TPoint): Boolean;
begin
  Result := FindConnection(AOther) <> nil;
end;

procedure TGraph.TPoint.SetIsFinish(const Value: Boolean);
begin
  if Value then
    Graph.FinishPoint := Self
  else
    Graph.FinishPoint := nil;
end;

procedure TGraph.TPoint.SetIsStart(const Value: Boolean);
begin
  if Value then
    Graph.StartPoint := Self
  else
    Graph.StartPoint := nil;
end;

procedure TGraph.TPoint.SetPos(const Value: TVector2);
begin
  if Pos = Value then
    Exit;
  FPos := Value;
  Graph.Changed;
end;

{ TGraph }

function TGraph.AddPoint(APos: TVector2): TPoint;
begin
  Result := TPoint.Create(Self, APos);
end;

procedure TGraph.Assign(AFrom: TGraph);
var
  Point, NewPoint: TPoint;
  Connection, NewConnection: TConnection;
begin
  Clear;

  for Point in AFrom.Points do
  begin
    NewPoint := AddPoint(Point.Pos);
    NewPoint.IsStart := Point.IsStart;
    NewPoint.IsFinish := Point.IsFinish;
  end;

  for Connection in AFrom.Connections do
  begin
    NewConnection := Points[Connection.PointA.Index].Connect(Points[Connection.PointB.Index]);
    NewConnection.CostFactor := Connection.CostFactor;
  end;

  if AFrom.StartPoint <> nil then
    FStartPoint := Points[AFrom.StartPoint.Index];
  if AFrom.FinishPoint <> nil then
    FFinishPoint := Points[AFrom.FinishPoint.Index];
end;

procedure TGraph.Changed;
begin
  FOnChange.Execute(TEventInfo.Create(Self));
end;

procedure TGraph.Clear;
var
  Connection: TConnection;
  Point: TPoint;
begin
  for Connection in Connections do
    Connection.FGraph := nil;
  FConnections.OwnsObjects := True;
  FConnections.Clear;

  for Point in Points do
    Point.FGraph := nil;
  FPoints.OwnsObjects := True;
  FPoints.Clear;

  FStartPoint := nil;
  FFinishPoint := nil;

  Changed;
end;

function TGraph.Connect(A, B: TPoint): TConnection;
begin
  Result := A.Connect(B);
end;

function TGraph.Copy: TGraph;
begin
  Result := TGraph.Create;
  Result.Assign(Self);
end;

constructor TGraph.Create;
begin
  FPoints := TPoints.Create;
  FConnections := TConnections.Create;
end;

destructor TGraph.Destroy;
begin
  Clear;
  FConnections.Free;
  FPoints.Free;
  inherited;
end;

function TGraph.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TGraph.GetPoints: TPoints.TReader;
begin
  Result := FPoints.Reader;
end;

function TGraph.OnChange: TEvent.TAccess;
begin
  Result := FOnChange.Access;
end;

procedure TGraph.SetFinishPoint(const Value: TPoint);
begin
  if FinishPoint = Value then
    Exit;
  FFinishPoint := Value;
  Changed;
end;

procedure TGraph.SetStartPoint(const Value: TPoint);
begin
  if StartPoint = Value then
    Exit;
  FStartPoint := Value;
  Changed;
end;

{ TGraph.TConnection }

function TGraph.TConnection.AnyIs(APoint: TPoint): Boolean;
begin
  Result := (APoint = PointA) or (APoint = PointB);
end;

constructor TGraph.TConnection.Create(AGraph: TGraph; APointA, APointB: TPoint);
begin
  FGraph := AGraph;
  FPointA := APointA;
  FPointB := APointB;
  FCostFactor := 1;
  Graph.FConnections.Add(Self);
  PointA.FConnections.Add(Self);
  PointB.FConnections.Add(Self);
  Graph.Changed;
end;

destructor TGraph.TConnection.Destroy;
begin
  if Graph <> nil then
  begin
    PointA.FConnections.Remove(Self);
    PointB.FConnections.Remove(Self);
    Graph.FConnections.Remove(Self);
    Graph.Changed;
  end;
  inherited;
end;

function TGraph.TConnection.GetCost: Single;
begin
  Result := PointA.Pos.DistanceTo(PointB.Pos) * CostFactor;
end;

function TGraph.TConnection.GetIndex: Integer;
begin
  Result := Graph.Connections.Find(Self);
end;

function TGraph.TConnection.GetOnChange: TConnection.TEvent.TAccess;
begin
  Result := FOnChange.Access;
end;

function TGraph.TConnection.Other(APoint: TPoint): TPoint;
begin
  if APoint = PointA then
    Exit(PointB);
  Result := PointA;
end;

procedure TGraph.TConnection.SetCostFactor(const Value: Single);
begin
  FCostFactor := Value;
end;

{ TGraph.TGridGenerator }

procedure TGraph.TGridGenerator.Generate;
var
  P: TIntVector2;
  I: Integer;
begin
  Graph.Clear;

  for P in Size do
    Graph.AddPoint(Bounds2(0, Size - 1).Convert(P, Bounds));
  // Graph.AddPoint(Bounds2(-1, 1).Convert(TVector2.RandomBox, Bounds));

  for I := 0 to Graph.Points.MaxIndex - 1 do
    if I mod Size.X <> (Size.X - 1) then
      Graph.Points[I].Connect(Graph.Points[I + 1]);
  for I := 0 to Graph.Points.MaxIndex - Size.X do
    Graph.Points[I].Connect(Graph.Points[I + Size.X]);
end;

{ TGraph.TGenerator }

constructor TGraph.TGenerator.Create(AGraph: TGraph);
begin
  FGraph := AGraph;
end;

{ TGraph.TRandomPointGenerator }

procedure TGraph.TRandomPointGenerator.Generate;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Graph.AddPoint(Bounds.InvPoint[TVector2.Random]);
end;

end.
