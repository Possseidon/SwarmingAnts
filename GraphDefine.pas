unit GraphDefine;

interface

uses
  Pengine.EventHandling,
  Pengine.Vector,
  Pengine.Collections, Pengine.IntMaths;

type

  TGraph = class
  public type

    TEventInfo = TSenderEventInfo<TGraph>;

    TEvent = TEvent<TEventInfo>;

    TConnection = class;

    TConnections = TRefArray<TConnection>;

    TPoint = class
    private
      FGraph: TGraph;
      FPos: TVector2;
      FConnections: TConnections;

      procedure SetPos(const Value: TVector2);
      function GetConnections: TConnections.TReader;

    public
      constructor Create(AGraph: TGraph; APos: TVector2);
      destructor Destroy; override;

      property Graph: TGraph read FGraph;

      property Pos: TVector2 read FPos write SetPos;

      property Connections: TConnections.TReader read GetConnections;

      function IsConnected(AOther: TPoint): Boolean;
      function FindConnection(AOther: TPoint): TConnection;

      function Connect(AOther: TPoint): TConnection;

    end;

    TConnection = class
    private
      FGraph: TGraph;
      FPointA: TPoint;
      FPointB: TPoint;
      FCostFactor: Single;

      function GetCost: Single;
      procedure SetCostFactor(const Value: Single);

    public
      constructor Create(AGraph: TGraph; APointA, APointB: TPoint);
      destructor Destroy; override;

      property Graph: TGraph read FGraph;

      function AnyIs(APoint: TPoint): Boolean;

      property PointA: TPoint read FPointA;
      property PointB: TPoint read FPointB;
      property CostFactor: Single read FCostFactor write SetCostFactor;
      property Cost: Single read GetCost;

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

  private
    FPoints: TPoints;
    FConnections: TConnections;
    FOnChanged: TEvent;

    procedure Changed;

    function GetConnections: TConnections.TReader;
    function GetPoints: TPoints.TReader;

  public
    constructor Create;
    destructor Destroy; override;

    property Points: TPoints.TReader read GetPoints;
    property Connections: TConnections.TReader read GetConnections;

    function AddPoint(APos: TVector2): TPoint;
    function Connect(A, B: TPoint): TConnection;

    procedure Clear;

    function OnChanged: TEvent.TAccess;

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

function TGraph.TPoint.IsConnected(AOther: TPoint): Boolean;
begin
  Result := FindConnection(AOther) <> nil;
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

procedure TGraph.Changed;
begin
  FOnChanged.Execute(TEventInfo.Create(Self));
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

  Changed;
end;

function TGraph.Connect(A, B: TPoint): TConnection;
begin
  Result := A.Connect(B);
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

function TGraph.OnChanged: TEvent.TAccess;
begin
  Result := FOnChanged.Access;
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
