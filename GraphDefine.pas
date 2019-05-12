unit GraphDefine;

interface

uses
  System.SysUtils,

  Pengine.Bitfield,
  Pengine.EventHandling,
  Pengine.Vector,
  Pengine.Collections,
  Pengine.IntMaths,
  Pengine.Interfaces,
  Pengine.JSON,
  Pengine.Utility,
  System.Math;

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
      FHasFood: Boolean;

    protected
      function GetPos: TVector2;
      procedure SetPos(const Value: TVector2);

      function GetIsStart: Boolean;
      procedure SetIsStart(const Value: Boolean);
      function GetHasFood: Boolean;
      procedure SetHasFood(const Value: Boolean);

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
      property HasFood: Boolean read FHasFood;

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

    /// <summary>Wether there is a start point.</summary>
    function HasStart: Boolean;

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
      property HasFood: Boolean read GetHasFood write SetHasFood;

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
      constructor Create(AGraph: TGraphEditable); virtual;

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

    TTriangulator = class(TGenerator)
    private
      // Outline is CCW
      FOutline: TPoints;

      procedure AddToOutline(APoint: TPoint);

      procedure GenerateOutline;
      procedure GenerateOutline2;
      procedure Triangulate;

    public
      constructor Create(AGraph: TGraphEditable); override;
      destructor Destroy; override;

      procedure Generate; override;

    end;

    TDelaunayTriangulator = class(TGenerator)
    public
      procedure Generate; override;
      
    end;

  private
    FOnChange: TGraphEditable.TEvent;

    function GetStartPoint: TPoint;
    procedure SetStartPoint(const Value: TPoint);

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

procedure TGraph.TPoint.SetHasFood(const Value: Boolean);
begin
  FHasFood := Value;
end;

function TGraph.TPoint.GetConnections: TConnections.TReader;
begin
  Result := FConnections.Reader;
end;

function TGraph.TPoint.GetHasFood: Boolean;
begin
  Result := FHasFood;
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
    NewPoint.SetHasFood(Point.HasFood);
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
  Changed;
end;

procedure TGraphEditable.Assign(AFrom: TGraph);
begin
  inherited;
  Changed;
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
  Changed;
end;

function TGraphEditable.Connect(A, B: TPoint): TConnection;
begin
  Result := TConnection(ConnectX(A, B));
end;

function TGraphEditable.ConnectX(A, B: TGraph.TPoint): TGraph.TConnection;
begin
  if A.IsConnected(B) then
    Exit(A.FindConnection(B));
  Result := TConnection.Create(Self, TPoint(A), TPoint(B));
  FConnections.Add(Result);
  Changed;
end;

function TGraph.Copy: TGraphEditable;
begin
  Result := TGraphEditable.Create;
  Result.Assign(Self);
end;

procedure TGraphEditable.DefineJStorage(ASerializer: TJSerializer);
begin
  DoDefineJStorage(ASerializer);
  if ASerializer.IsLoading then
    Changed;
end;

function TGraphEditable.GetConnections: TConnections.TReader;
begin
  Result := TConnections.TReader(inherited GetConnections);
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
  Changed;
end;

function TGraph.ConnectX(A, B: TPoint): TConnection;
begin
  if A.IsConnected(B) then
    Exit(A.FindConnection(B));
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
  JFood: TJArray;
begin
  case ASerializer.Mode of
    smSerialize:
      begin
        if StartPoint <> nil then
          ASerializer.Value['start'] := StartPoint.Index;
        JFood := ASerializer.Value.AddArray('food');

        JArray := ASerializer.Value['points'];
        for Point in Points do
        begin
          JPoint := JArray.AddArray;
          JPoint[0] := Point.Pos.X;
          JPoint[1] := Point.Pos.Y;
          if Point.HasFood then
            JFood.Add(Point.Index);
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
        for JPointIndex in ASerializer.Value['food'].AsArray do
          FPoints[JPointIndex].SetHasFood(True);
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

function TGraph.HasStart: Boolean;
begin
  Result := StartPoint <> nil;
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

procedure TGraph.SetStartPoint(const Value: TPoint);
begin
  if StartPoint = Value then
    Exit;
  FStartPoint := Value;
  Changed;
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
    Graph.AddPoint(Bounds[TVector2.Random]);
end;

{ TGraphEditable.TTriangulator }

procedure TGraphEditable.TTriangulator.AddToOutline(APoint: TPoint);
var
  I, MinI: Integer;
  A, B: TPoint;
  Line: TLine2;
  S, MinS, NewS: Single;
  After: Boolean;
begin
  MinS := Infinity;
  MinI := -1;
  After := False;
  for I := 0 to FOutline.MaxIndex do
  begin
    A := FOutline[I];
    B := FOutline[(I + 1) mod FOutline.Count];
    Line := A.Pos.LineTo(B.Pos);

    if Line.Side(APoint.Pos) <> lsRight then
      Continue;

    S := Line.OrthoProj(APoint.Pos);
    if S in Bounds1(0, 1) then
    begin
      // Insert point
      FOutline.Insert(APoint, I);
      Exit;
    end;

    NewS := Min(Abs(S), Abs(S - 1));
    if NewS < MinS then
    begin
      MinI := I;
      MinS := NewS;
      After := Abs(S - 1) > Abs(S);
    end;
  end;

  if MinI = -1 then
    Exit;

  if After then
    FOutline[(MinI + 1) mod FOutline.Count] := APoint
  else
    FOutline[MinI] := APoint;

end;

constructor TGraphEditable.TTriangulator.Create(AGraph: TGraphEditable);
begin
  inherited;
  FOutline := TPoints.Create;
end;

destructor TGraphEditable.TTriangulator.Destroy;
begin
  FOutline.Free;
  inherited;
end;

procedure TGraphEditable.TTriangulator.Generate;
begin
  if Graph.Points.Count = 2 then
    Graph.Points[0].Connect(Graph.Points[1])
  else if Graph.Points.Count >= 3 then
  begin
    GenerateOutline2;
    Triangulate;
  end;
end;

procedure TGraphEditable.TTriangulator.GenerateOutline;
var
  I: Integer;
  Side: TLineSide;
begin
  // Choose two arbirary points
  FOutline.Add(Graph.Points[0]);
  Side := Graph.Points[0].Pos.LineTo(Graph.Points[1].Pos).Side(Graph.Points[2].Pos);
  if Side = lsLeft then
  begin
    FOutline.Add(Graph.Points[1]);
    FOutline.Add(Graph.Points[2]);
  end
  else
  begin
    FOutline.Add(Graph.Points[1]);
    FOutline.Add(Graph.Points[2]);
  end;

  // Integegrate all other points
  for I := 3 to Graph.Points.MaxIndex do
    AddToOutline(Graph.Points[I]);

  for I := 0 to FOutline.MaxIndex do
    FOutline[I].Connect(FOutline[(I + 1) mod FOutline.Count]);
end;

procedure TGraphEditable.TTriangulator.GenerateOutline2;
var
  A, B, C: TPoint;
  Line: TLine2;
  Side: TLineSide;
begin
  for A in Graph.Points do
  begin
    for B in Graph.Points do
    begin
      if A = B then
        Continue;
    
      Line := A.Pos.LineTo(B.Pos);
      Side := lsOn;
      for C in Graph.Points do
      begin
        if (C = A) or (C = B) then
          Continue;
      
        if Side = lsOn then
          Side := Line.Side(C.Pos)
        else if Side <> Line.Side(C.Pos) then
        begin
          Side := lsOn;
          Break;
        end;
      end;

      if Side <> lsOn then
        A.Connect(B);

    end;
  end;
end;

procedure TGraphEditable.TTriangulator.Triangulate;
begin

end;

{ TGraphEditable.TDelaunayTriangulator }

procedure TGraphEditable.TDelaunayTriangulator.Generate;
var
  A, B, C, D: TPoint;
  DelaunayMet: Boolean;
begin
  for A in Graph.Points do
  begin
    for B in Graph.Points do
    begin
      if A = B then
        Continue;
      for C in Graph.Points do
      begin
        if (C = A) or (C = B) then
          Continue;
        DelaunayMet := True;
        for D in Graph.Points do
        begin
          if (D = A) or (D = B) or (D = C) then
            Continue;
          if D.Pos.InCircumcircle(A.Pos, B.Pos, C.Pos) then
          begin
            DelaunayMet := False;
            Break;
          end;
        end;

        if DelaunayMet then
        begin
          A.Connect(B);
          B.Connect(C);
          C.Connect(A);        
        end;
      end;
    end;
  end;
end;

end.
