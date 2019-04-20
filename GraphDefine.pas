unit GraphDefine;

interface

uses
  System.SysUtils,

  Pengine.EventHandling,
  Pengine.Vector,
  Pengine.Collections,
  Pengine.IntMaths,
  Pengine.Interfaces,
  Pengine.JSON,
  Pengine.Utility;

type

  TGraphEditable = class;

  TGraph = class(TInterfaceBase, IJSerializable)
  public type

    TConnection = class;

    TConnections = TRefArray<TConnection>;

    TPoint = class
    private
      FGraph: TGraph;
      FPos: TVector2;
      FConnections: TConnections;
      FIndex: Integer;

    protected
      function GetPos: TVector2;
      procedure SetPos(const Value: TVector2);

      function GetIsStart: Boolean;
      procedure SetIsStart(const Value: Boolean);
      function GetIsFinish: Boolean;
      procedure SetIsFinish(const Value: Boolean);

      function GetConnections: TConnections.TReader;

    public
      constructor Create(AGraph: TGraph; APos: TVector2);
      destructor Destroy; override;

      procedure Remove;

      property Index: Integer read FIndex;

      property Graph: TGraph read FGraph;

      property Pos: TVector2 read FPos;

      property Connections: TConnections.TReader read GetConnections;

      function IsConnected(AOther: TPoint): Boolean;
      function FindConnection(AOther: TPoint): TConnection;

      property IsStart: Boolean read GetIsStart;
      property IsFinish: Boolean read GetIsFinish;

    end;

    TConnection = class
    private
      FGraph: TGraph;
      FPointA: TPoint;
      FPointB: TPoint;
      FCostFactor: Single;
      FIndex: Integer;

      function GetCost: Single;

    protected
      function GetCostFactor: Single;
      procedure SetCostFactor(const Value: Single);

    public
      constructor Create(AGraph: TGraph; APointA, APointB: TPoint);
      destructor Destroy; override;

      procedure Remove;

      property Graph: TGraph read FGraph;
      property Index: Integer read FIndex;

      function AnyIs(APoint: TPoint): Boolean;
      function Other(APoint: TPoint): TPoint;

      property PointA: TPoint read FPointA;
      property PointB: TPoint read FPointB;
      property CostFactor: Single read GetCostFactor;
      property Cost: Single read GetCost;

    end;

    TPoints = TRefArray<TPoint>;

  private
    FPoints: TPoints;
    FConnections: TConnections;
    FStartPoint: TPoint;
    FFinishPoint: TPoint;

    function GetConnections: TConnections.TReader;
    function GetPoints: TPoints.TReader;

  protected
    procedure DoDefineJStorage(ASerializer: TJSerializer);

    procedure Assign(AFrom: TGraph);

    function AddPointX(APos: TVector2): TPoint; virtual;
    function ConnectX(A, B: TPoint): TConnection; virtual;

    procedure Remove(APoint: TPoint); overload;
    procedure Remove(AConnection: TConnection); overload;

    procedure Clear;

    procedure SetFinishPoint(const Value: TPoint);
    procedure SetStartPoint(const Value: TPoint);

    procedure Changed; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    /// <returns>An exact copy of the whole graph.</returns>
    function Copy: TGraphEditable;
    function CopyReadonly: TGraph;

    /// <summary>A readonly list of all points.</summary>
    property Points: TPoints.TReader read GetPoints;
    /// <summary>A readonly list of all connections between points.</summary>
    property Connections: TConnections.TReader read GetConnections;

    /// <summary>A single start point for this graph.</summary>
    property StartPoint: TPoint read FStartPoint;
    /// <summary>A single finish point for this graph.</summary>
    property FinishPoint: TPoint read FFinishPoint;

    function HasStart: Boolean;
    function HasFinish: Boolean;
    function Valid: Boolean;

    // IJSerializable
    function GetJVersion: Integer;
    procedure DefineJStorage(ASerializer: TJSerializer); virtual;

  end;

  TGraphEditable = class(TGraph)
  public type

    TEventInfo = TSenderEventInfo<TGraphEditable>;

    TEvent = TEvent<TEventInfo>;

    TConnection = class;

    TPoint = class(TGraph.TPoint)
    private
      function GetGraph: TGraphEditable;

    public
      constructor Create(AGraph: TGraphEditable; APos: TVector2);

      property Graph: TGraphEditable read GetGraph;

      property Pos: TVector2 read GetPos write SetPos;

      function Connect(AOther: TPoint): TConnection;

      property IsStart: Boolean read GetIsStart write SetIsStart;
      property IsFinish: Boolean read GetIsFinish write SetIsFinish;

    end;

    TPoints = TRefArray<TPoint>;

    TConnection = class(TGraph.TConnection)
    private
      function GetGraph: TGraphEditable;

    public
      constructor Create(AGraph: TGraphEditable; APointA, APointB: TPoint);

      property Graph: TGraphEditable read GetGraph;

      property CostFactor: Single read GetCostFactor write SetCostFactor;

    end;

    TConnections = TRefArray<TConnection>;

    TGenerator = class abstract
    private
      FGraph: TGraphEditable;

    public
      constructor Create(AGraph: TGraphEditable);

      property Graph: TGraphEditable read FGraph;

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
    FOnChange: TGraphEditable.TEvent;

    function GetStartPoint: TPoint;
    procedure SetStartPoint(const Value: TPoint);
    function GetFinishPoint: TPoint;
    procedure SetFinishPoint(const Value: TPoint);

    function GetPoints: TPoints.TReader;
    function GetConnections: TConnections.TReader;

  protected
    procedure Changed; override;

    function AddPointX(APos: TVector2): TGraph.TPoint; override;
    function ConnectX(A, B: TGraph.TPoint): TGraph.TConnection; override;

  public
    /// <summary>Copies everything from the given graph to this graph.</summary>
    procedure Assign(AFrom: TGraph);

    /// <summary>A readonly list of all points.</summary>
    property Points: TPoints.TReader read GetPoints;
    /// <summary>A readonly list of all connections between points.</summary>
    property Connections: TConnections.TReader read GetConnections;

    /// <summary>A single start point for this graph.</summary>
    property StartPoint: TPoint read GetStartPoint write SetStartPoint;
    /// <summary>A single finish point for this graph.</summary>
    property FinishPoint: TPoint read GetFinishPoint write SetFinishPoint;

    /// <summary>Adds a point at the specified position and returns said point.</summary>
    function AddPoint(APos: TVector2): TPoint;
    /// <summary>Creates a connection between two given points and returns said connection.</summary>
    function Connect(A, B: TPoint): TConnection;

    /// <summary>Called whenever the graph changes in any way.</summary>
    function OnChange: TGraphEditable.TEvent.TAccess;

    /// <summary>Removes all points and connections from the graph.</summary>
    procedure Clear;

    // IJSerializable
    procedure DefineJStorage(ASerializer: TJSerializer); override;

  end;

implementation

{ TGraph.TPoint }

procedure TGraph.TPoint.SetPos(const Value: TVector2);
begin
  if Pos = Value then
    Exit;
  FPos := Value;
  Graph.Changed;
end;

function TGraph.TPoint.GetIsStart: Boolean;
begin
  Result := Self = Graph.StartPoint;
end;

function TGraph.TPoint.GetPos: TVector2;
begin
  Result := FPos;
end;

procedure TGraph.TPoint.SetIsStart(const Value: Boolean);
begin
  if Value then
    Graph.SetStartPoint(Self)
  else if Graph.StartPoint = Self then
    Graph.SetStartPoint(nil);
end;

function TGraph.TPoint.GetIsFinish: Boolean;
begin
  Result := Self = Graph.FinishPoint;
end;

procedure TGraph.TPoint.SetIsFinish(const Value: Boolean);
begin
  if Value then
    Graph.SetFinishPoint(Self)
  else if Graph.FinishPoint = Self then
    Graph.SetFinishPoint(nil);
end;

function TGraph.TPoint.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

constructor TGraph.TPoint.Create(AGraph: TGraph; APos: TVector2);
begin
  FGraph := AGraph;
  FIndex := FGraph.Points.Count;
  FPos := APos;
  FConnections := TConnections.Create;
end;

destructor TGraph.TPoint.Destroy;
begin
  while not Connections.Empty do
    Connections.Last.Remove;
  FConnections.Free;
  inherited;
end;

function TGraph.TPoint.IsConnected(AOther: TPoint): Boolean;
begin
  Result := FindConnection(AOther) <> nil;
end;

procedure TGraph.TPoint.Remove;
begin
  Graph.Remove(Self);
end;

function TGraph.TPoint.FindConnection(AOther: TPoint): TConnection;
begin
  for Result in Connections do
    if Result.AnyIs(AOther) then
      Exit;
  Result := nil;
end;

{ TGraphEditable.TPoint }

function TGraphEditable.TPoint.GetGraph: TGraphEditable;
begin
  Result := TGraphEditable(FGraph);
end;

constructor TGraphEditable.TPoint.Create(AGraph: TGraphEditable; APos: TVector2);
begin
  inherited Create(AGraph, APos);
end;

function TGraphEditable.TPoint.Connect(AOther: TPoint): TConnection;
begin
  Result := Graph.Connect(Self, AOther);
end;

{ TGraph.TConnection }

function TGraph.TConnection.GetCost: Single;
begin
  Result := PointA.Pos.DistanceTo(PointB.Pos) * CostFactor;
end;

function TGraph.TConnection.GetCostFactor: Single;
begin
  Result := FCostFactor;
end;

procedure TGraph.TConnection.SetCostFactor(const Value: Single);
begin
  FCostFactor := Value;
end;

constructor TGraph.TConnection.Create(AGraph: TGraph; APointA, APointB: TPoint);
begin
  FGraph := AGraph;
  FIndex := Graph.Connections.Count;
  FPointA := APointA;
  FPointB := APointB;
  FCostFactor := 1;
  PointA.FConnections.Add(Self);
  PointB.FConnections.Add(Self);
end;

destructor TGraph.TConnection.Destroy;
begin
  PointA.FConnections.Remove(Self);
  PointB.FConnections.Remove(Self);
  inherited;
end;

function TGraph.TConnection.AnyIs(APoint: TPoint): Boolean;
begin
  Result := (APoint = PointA) or (APoint = PointB);
end;

function TGraph.TConnection.Other(APoint: TPoint): TPoint;
begin
  if APoint = PointA then
    Exit(PointB);
  Result := PointA;
end;

procedure TGraph.TConnection.Remove;
begin
  Graph.Remove(Self);
end;

{ TGraphEditable.TConnection }

function TGraphEditable.TConnection.GetGraph: TGraphEditable;
begin
  Result := TGraphEditable(FGraph);
end;

constructor TGraphEditable.TConnection.Create(AGraph: TGraphEditable; APointA, APointB: TPoint);
begin
  inherited Create(AGraph, APointA, APointB);
end;

{ TGraph }

function TGraph.AddPointX(APos: TVector2): TPoint;
begin
  Result := TPoint.Create(Self, APos);
  FPoints.Add(Result);
end;

procedure TGraph.Assign(AFrom: TGraph);
var
  Point, NewPoint: TPoint;
  Connection, NewConnection: TConnection;
begin
  Clear;

  for Point in AFrom.Points do
  begin
    NewPoint := AddPointX(Point.Pos);
    NewPoint.SetIsStart(Point.IsStart);
    NewPoint.SetIsFinish(Point.IsFinish);
  end;

  for Connection in AFrom.Connections do
  begin
    NewConnection := ConnectX(Points[Connection.PointA.Index], Points[Connection.PointB.Index]);
    NewConnection.SetCostFactor(Connection.CostFactor);
  end;
end;

{ TGraphEditable }

function TGraphEditable.AddPoint(APos: TVector2): TPoint;
begin
  Result := TPoint(AddPointX(APos));
end;

function TGraphEditable.AddPointX(APos: TVector2): TGraph.TPoint;
begin
  Result := TPoint.Create(Self, APos);
  FPoints.Add(Result);
end;

procedure TGraphEditable.Assign(AFrom: TGraph);
begin
  inherited;
end;

procedure TGraphEditable.Changed;
begin
  FOnChange.Execute(TEventInfo.Create(Self));
end;

procedure TGraph.Changed;
begin
  // nothing by default
end;

procedure TGraph.Clear;
begin
  FConnections.Clear;
  FPoints.Clear;

  FStartPoint := nil;
  FFinishPoint := nil;

  Changed;
end;

function TGraphEditable.Connect(A, B: TPoint): TConnection;
begin
  Result := TConnection(ConnectX(A, B));
end;

function TGraphEditable.ConnectX(A, B: TGraph.TPoint): TGraph.TConnection;
begin
  Result := TConnection.Create(Self, TPoint(A), TPoint(B));
  FConnections.Add(Result);
end;

function TGraph.Copy: TGraphEditable;
begin
  Result := TGraphEditable.Create;
  Result.Assign(Self);
end;

procedure TGraphEditable.DefineJStorage(ASerializer: TJSerializer);
begin
  DoDefineJStorage(ASerializer);
end;

function TGraphEditable.GetConnections: TConnections.TReader;
begin
  Result := TConnections.TReader(inherited GetConnections);
end;

function TGraphEditable.GetFinishPoint: TPoint;
begin
  Result := TPoint(inherited FinishPoint);
end;

function TGraphEditable.GetPoints: TPoints.TReader;
begin
  Result := TPoints.TReader(inherited GetPoints);
end;

function TGraphEditable.GetStartPoint: TPoint;
begin
  Result := TPoint(inherited StartPoint);
end;

function TGraphEditable.OnChange: TEvent.TAccess;
begin
  Result := FOnChange.Access;
end;

procedure TGraphEditable.Clear;
begin
  inherited Clear;
end;

function TGraph.ConnectX(A, B: TPoint): TConnection;
begin
  Result := TConnection.Create(Self, A, B);
  FConnections.Add(Result);
end;

function TGraph.CopyReadonly: TGraph;
begin
  Result := TGraph.Create;
  Result.Assign(Self);
end;

constructor TGraph.Create;
begin
  FPoints := TPoints.Create(True);
  FConnections := TConnections.Create(True);
end;

procedure TGraph.DoDefineJStorage(ASerializer: TJSerializer);
var
  Point: TPoint;
  Connection: TConnection;
  JArray, JPoint: TJArray;
  JPointIndex: TJValue;
  JConnection: TJValue;
  JPoints: TJArray;
begin
  case ASerializer.Mode of
    smSerialize:
      begin
        if StartPoint <> nil then
          ASerializer.Value['start'] := StartPoint.Index;
        if FinishPoint <> nil then
          ASerializer.Value['finish'] := FinishPoint.Index;

        JArray := ASerializer.Value['points'];
        for Point in Points do
        begin
          JPoint := JArray.AddArray;
          JPoint[0] := Point.Pos.X;
          JPoint[1] := Point.Pos.Y;
        end;

        JArray := ASerializer.Value['connections'];
        for Connection in Connections do
        begin
          if Connection.CostFactor <> 1 then
          begin
            JConnection := JArray.AddObject;
            JConnection['cost'] := Connection.CostFactor;
            JPoints := JConnection.AddArray('points');
          end
          else
            JPoints := JArray.AddArray;
          JPoints[0] := Connection.PointA.Index;
          JPoints[1] := Connection.PointB.Index;
        end;
      end;
    smUnserialize:
      begin
        Clear;

        for JPoint in ASerializer.Value['points'].AsArray do
          AddPointX(Vec2(JPoint[0], JPoint[1]));

        for JConnection in ASerializer.Value['connections'].AsArray do
        begin
          if JConnection.IsObject then
            JPoints := JConnection['points']
          else
            JPoints := JConnection;
          Connection := ConnectX(Points[JPoints[0]], Points[JPoints[1]]);
          if JConnection.IsObject then
            Connection.SetCostFactor(JConnection['cost']);
        end;

        if ASerializer.Value.Get('start', JPointIndex) then
          FStartPoint := Points[JPointIndex];
        if ASerializer.Value.Get('finish', JPointIndex) then
          FFinishPoint := Points[JPointIndex];
      end;
  end;
end;

procedure TGraph.DefineJStorage(ASerializer: TJSerializer);
begin
  if ASerializer.IsLoading then
    raise Exception.Create('Cannot load readonly graph.');
  DoDefineJStorage(ASerializer);
end;

destructor TGraph.Destroy;
begin
  FConnections.Free;
  FPoints.Free;
  inherited;
end;

function TGraph.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TGraph.GetJVersion: Integer;
begin
  Result := 0;
end;

function TGraph.GetPoints: TPoints.TReader;
begin
  Result := FPoints.Reader;
end;

function TGraph.HasFinish: Boolean;
begin
  Result := FinishPoint <> nil;
end;

function TGraph.HasStart: Boolean;
begin
  Result := StartPoint <> nil;
end;

function TGraph.Valid: Boolean;
begin
  Result := HasStart and HasFinish;
end;

procedure TGraph.Remove(AConnection: TConnection);
var
  I: Integer;
begin
  for I := AConnection.Index to Connections.MaxIndex do
    Dec(FConnections[I].FIndex);
  FConnections.RemoveAt(AConnection.Index);
end;

procedure TGraph.Remove(APoint: TPoint);
var
  I: Integer;
begin
  for I := APoint.Index + 1 to Points.MaxIndex do
    Dec(FPoints[I].FIndex);
  FPoints.RemoveAt(APoint.Index);
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

procedure TGraphEditable.SetFinishPoint(const Value: TPoint);
begin
  inherited SetFinishPoint(Value);
end;

procedure TGraphEditable.SetStartPoint(const Value: TPoint);
begin
  inherited SetStartPoint(Value);
end;

{ TGraphEditable.TGridGenerator }

procedure TGraphEditable.TGridGenerator.Generate;
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

{ TGraphEditable.TGenerator }

constructor TGraphEditable.TGenerator.Create(AGraph: TGraphEditable);
begin
  FGraph := AGraph;
end;

{ TGraphEditable.TRandomPointGenerator }

procedure TGraphEditable.TRandomPointGenerator.Generate;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Graph.AddPoint(Bounds.InvPoint[TVector2.Random]);
end;

end.
