unit DisplayView;

interface

uses
  Winapi.Windows,

  System.Types,
  System.Classes,
  System.Math,

  Vcl.ExtCtrls,
  Vcl.Direct2D,
  Vcl.Controls,

  GdiPlus,
  GdiPlusHelpers,

  Pengine.Collections,
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.Utility,
  Pengine.EventHandling,
  Pengine.Color,

  GraphDefine,
  AntDefine;

type

  TEditorTool = (
    etSelection,
    etPoint,
    etConnection,
    etStart,
    etFinish
    );

  TCamera = class
  public type

    TEventInfo = TSenderEventInfo<TCamera>;

    TEvent = TEvent<TEventInfo>;

  private
    FOnChange: TEvent;
    FPos: TVector2;
    FScale: Single;

    procedure SetPos(const Value: TVector2);
    procedure SetScale(const Value: Single);
    function GetOnChange: TEvent.TAccess;

  public
    constructor Create;

    procedure Assign(AFrom: TCamera);
    function Copy: TCamera;

    property OnChange: TEvent.TAccess read GetOnChange;

    procedure Reset;

    property Pos: TVector2 read FPos write SetPos;
    property Scale: Single read FScale write SetScale;

    procedure Move(AOffset: TVector2);
    procedure Zoom(AFactor: Single; APos: TVector2);

    function CalculateMatrix(ASize: TIntVector2): IGPMatrix;

  end;

  TDisplay = class abstract
  private
    FPaintBox: TPaintBox;
    FCamera: TCamera;
    FCamDrag: TOpt<TVector2>;
    FPointSize: Single;
    FLineWidth: Single;

    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseLeave(Sender: TObject);

    function ConvertPoint(APos: TVector2; ACursorToGraph: Boolean): TVector2;
    function CursorToGraph(APos: TVector2): TVector2;
    // function GraphToCursor(APos: TVector2): TVector2;

    function GetCameraMatrix: IGPMatrix;
    function GetPaintBoxSize: TIntVector2;

    procedure SetLineWidth(const Value: Single);
    procedure SetPointSize(const Value: Single);

    procedure UpdateMouseDrag(APos: TVector2);
    procedure UpdateMouseHover(APos: TVector2);
    procedure SetCamera(const Value: TCamera);

  protected
    function GetGraph: TGraph; virtual; abstract;

    procedure Paint(G: IGPGraphics); virtual;
    procedure Drag(AAmount: TVector2); virtual;
    procedure Hover(APos: TVector2); virtual;
    procedure MouseDown(APos: TVector2; AButton: TMouseButton); virtual;
    procedure MouseUp(APos: TVector2; AButton: TMouseButton); virtual;
    procedure MouseLeave; virtual;

  public
    constructor Create(APaintBox: TPaintBox);
    destructor Destroy; override;

    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);

    property PaintBox: TPaintBox read FPaintBox;
    property PaintBoxSize: TIntVector2 read GetPaintBoxSize;

    property Graph: TGraph read GetGraph;

    property Camera: TCamera read FCamera write SetCamera;
    property CameraMatrix: IGPMatrix read GetCameraMatrix;

    property PointSize: Single read FPointSize write SetPointSize;
    property LineWidth: Single read FLineWidth write SetLineWidth;

  end;

  TEditorDisplay = class(TDisplay)
  public type

    TEventInfo = TSenderEventInfo<TEditorDisplay>;

    TEvent = TEvent<TEventInfo>;

  private
    FGraph: TGraphEditable;
    FTool: TEditorTool;
    FPointAtCursor: TGraphEditable.TPoint;
    FConnectionAtCursor: TGraphEditable.TConnection;
    FConnectionStart: TGraphEditable.TPoint;
    FConnectionDrag: TVector2;
    FOnToolChange: TEvent;

    procedure SetTool(const Value: TEditorTool);

    function GetOnToolChange: TEvent.TAccess;

    procedure SetGraph(const Value: TGraphEditable);

  protected
    function GetGraph: TGraph; override;

    procedure Paint(G: IGPGraphics); override;
    procedure Drag(AAmount: TVector2); override;
    procedure Hover(APos: TVector2); override;
    procedure MouseDown(APos: TVector2; AButton: TMouseButton); override;
    procedure MouseUp(APos: TVector2; AButton: TMouseButton); override;
    procedure MouseLeave; override;

  public
    constructor Create(APaintBox: TPaintBox);
    destructor Destroy; override;

    property Graph: TGraphEditable read FGraph write SetGraph;

    property Tool: TEditorTool read FTool write SetTool;

    property OnToolChange: TEvent.TAccess read GetOnToolChange;

  end;

  TSimulationDisplay = class(TDisplay)
  private
    FPheromoneData: TPheromoneData;
    FVisibleAnt: TAnt;

    procedure SetPheromoneData(const Value: TPheromoneData);
    procedure HideAntPath;
    procedure SetVisibleAnt(const Value: TAnt);
    procedure ShowAntPath(AAnt: TAnt);

  protected
    function GetGraph: TGraph; override;

    procedure Paint(G: IGPGraphics); override;

  public
    property PheromoneData: TPheromoneData read FPheromoneData write SetPheromoneData;

    property VisibleAnt: TAnt read FVisibleAnt write SetVisibleAnt;

  end;

implementation

{ TDisplay }

function TDisplay.ConvertPoint(APos: TVector2; ACursorToGraph: Boolean): TVector2;
var
  Cam: IGPMatrix;
  Point: TGPPointF;
begin
  Cam := CameraMatrix;
  if ACursorToGraph then
    Cam.Invert;
  Point := TGPPointF.Create(APos.X, APos.Y);
  Cam.TransformPoint(Point);
  Result := Vec2(Point.X, Point.Y);
end;

constructor TDisplay.Create(APaintBox: TPaintBox);
begin
  FPaintBox := APaintBox;
  PaintBox.ControlStyle := PaintBox.ControlStyle + [csOpaque];

  PaintBox.OnPaint := PaintBoxPaint;
  PaintBox.OnMouseDown := PaintBoxMouseDown;
  PaintBox.OnMouseMove := PaintBoxMouseMove;
  PaintBox.OnMouseUp := PaintBoxMouseUp;
  PaintBox.OnMouseLeave := PaintBoxMouseLeave;

  FCamera := TCamera.Create;
  FCamera.OnChange.Add(PaintBox.Invalidate);

  FPointSize := 12;
  FLineWidth := 5;
end;

function TDisplay.CursorToGraph(APos: TVector2): TVector2;
begin
  Result := ConvertPoint(APos, True);
end;

destructor TDisplay.Destroy;
begin
  PaintBox.OnPaint := nil;
  PaintBox.OnMouseDown := nil;
  PaintBox.OnMouseMove := nil;
  PaintBox.OnMouseUp := nil;
  PaintBox.OnMouseLeave := nil;
  FCamera.Free;
  inherited;
end;

procedure TDisplay.Drag(AAmount: TVector2);
begin
  Camera.Move(-AAmount);
end;

function TDisplay.GetCameraMatrix: IGPMatrix;
begin
  Result := Camera.CalculateMatrix(PaintBoxSize);
end;

function TDisplay.GetPaintBoxSize: TIntVector2;
begin
  Result := IVec2(PaintBox.Width, PaintBox.Height);
end;

{
  function TDisplay.GraphToCursor(APos: TVector2): TVector2;
  begin
  Result := ConvertPoint(APos, False);
  end;
}

procedure TDisplay.Hover(APos: TVector2);
begin
  // nothing
end;

procedure TDisplay.MouseDown(APos: TVector2; AButton: TMouseButton);
begin
  // nothing
end;

procedure TDisplay.MouseLeave;
begin
  // nothing
end;

procedure TDisplay.MouseUp(APos: TVector2; AButton: TMouseButton);
begin
  // nothing
end;

procedure TDisplay.SetCamera(const Value: TCamera);
begin
  Camera.Assign(Value);
end;

procedure TDisplay.SetLineWidth(const Value: Single);
begin
  if LineWidth = Value then
    Exit;
  FLineWidth := Value;
  PaintBox.Invalidate;
end;

procedure TDisplay.SetPointSize(const Value: Single);
begin
  if PointSize = Value then
    Exit;
  FPointSize := Value;
  PaintBox.Invalidate;
end;

procedure TDisplay.UpdateMouseDrag(APos: TVector2);
begin
  Drag(APos - FCamDrag);
  FCamDrag := APos;
end;

procedure TDisplay.UpdateMouseHover(APos: TVector2);
begin
  APos := CursorToGraph(APos);
  Hover(APos);
end;

procedure TDisplay.MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);
begin
  // if ssCtrl in Shift then
  Camera.Zoom(1 + WheelDelta / WHEEL_DELTA * 0.1, Vec2(MousePos.X, MousePos.Y) - TVector2(PaintBoxSize) / 2);
end;

{ TEditorDisplay }

constructor TEditorDisplay.Create(APaintBox: TPaintBox);
begin
  inherited;
  FGraph := TGraphEditable.Create;
  FGraph.OnChange.Add(PaintBox.Invalidate);
end;

destructor TEditorDisplay.Destroy;
begin
  FGraph.Free;
  inherited;
end;

procedure TEditorDisplay.Drag(AAmount: TVector2);
begin
  if Tool = etConnection then
    FConnectionDrag := FConnectionDrag + AAmount
  else if FPointAtCursor <> nil then
    FPointAtCursor.Pos := FPointAtCursor.Pos + AAmount / FCamera.Scale
  else
    inherited;
end;

function TEditorDisplay.GetGraph: TGraph;
begin
  Result := Graph;
end;

function TEditorDisplay.GetOnToolChange: TEvent.TAccess;
begin
  Result := FOnToolChange.Access;
end;

procedure TEditorDisplay.Hover(APos: TVector2);
var
  OldPointAtCursor: TOpt<TGraph.TPoint>;
  OldConnectionAtCursor: TOpt<TGraph.TConnection>;
  Point: TGraphEditable.TPoint;
  NewDistance, ClosestDistance: Single;
begin
  // First find hovered point
  OldPointAtCursor := FPointAtCursor;
  FPointAtCursor := nil;
  ClosestDistance := PointSize / 2;

  // Point selection
  for Point in Graph.Points do
  begin
    NewDistance := Point.Pos.DistanceTo(APos);
    if NewDistance < ClosestDistance then
    begin
      ClosestDistance := NewDistance;
      FPointAtCursor := Point;
    end;
  end;

  // If no point is found, find connection
  OldConnectionAtCursor := FConnectionAtCursor;
  FConnectionAtCursor := nil;
  if FPointAtCursor = nil then
  begin
    // TODO: Connection selection
  end;

  if (FPointAtCursor <> OldPointAtCursor) or (FConnectionAtCursor <> OldConnectionAtCursor) then
    PaintBox.Invalidate;
end;

procedure TEditorDisplay.MouseDown(APos: TVector2; AButton: TMouseButton);
begin
  case Tool of
    etPoint:
      if AButton = mbLeft then
      begin
        FGraph.AddPoint(APos);
        FCamDrag.Clear;
        PaintBox.Invalidate;
      end;
    etConnection:
      if AButton = mbLeft then
      begin
        FConnectionStart := FPointAtCursor;
        FConnectionDrag := APos;
        PaintBox.Invalidate;
      end;
    etStart:
      if AButton = mbLeft then
      begin
        if FPointAtCursor <> nil then
        begin
          FPointAtCursor.IsStart := True;
          Tool := etSelection;
          FCamDrag.Clear;
          PaintBox.Invalidate;
        end;
      end;
    etFinish:
      if AButton = mbLeft then
      begin
        if FPointAtCursor <> nil then
        begin
          FPointAtCursor.IsFinish := True;
          Tool := etSelection;
          FCamDrag.Clear;
          PaintBox.Invalidate;
        end;
      end;
  end;
end;

procedure TEditorDisplay.MouseLeave;
begin
  FPointAtCursor := nil;
  FConnectionAtCursor := nil;
  PaintBox.Invalidate;
end;

procedure TEditorDisplay.MouseUp(APos: TVector2; AButton: TMouseButton);
begin
  if (FConnectionStart <> nil) and (FPointAtCursor <> nil) then
    FConnectionStart.Connect(FPointAtCursor);
  FConnectionStart := nil;
  PaintBox.Invalidate;
end;

procedure TEditorDisplay.Paint(G: IGPGraphics);
var
  Connection: TGraphEditable.TConnection;
  Point: TGraphEditable.TPoint;
  Brush: IGPSolidBrush;
  R: TGPRectF;
  Pen: IGPPen;
  HoverBrush: IGPSolidBrush;
  PointHoverPen: IGPPen;
  HoverBrushSecondary: IGPSolidBrush;
  StartBrush: IGPSolidBrush;
  FinishBrush: IGPSolidBrush;
begin
  // Render Connections
  Pen := TGPPen.Create($FF7F7FCF, LineWidth);
  PointHoverPen := TGPPen.Create($FF9F9FEF, LineWidth);
  for Connection in Graph.Connections do
  begin
    with Connection do
    begin
      if (FPointAtCursor <> nil) and Connection.AnyIs(FPointAtCursor) then
        G.DrawLine(PointHoverPen, PointA.Pos.X, PointA.Pos.Y, PointB.Pos.X, PointB.Pos.Y)
      else
        G.DrawLine(Pen, PointA.Pos.X, PointA.Pos.Y, PointB.Pos.X, PointB.Pos.Y);
    end;
  end;

  // Render Points
  Brush := TGPSolidBrush.Create($FF3F3F7F);
  HoverBrush := TGPSolidBrush.Create($FFAF2FAF);
  HoverBrushSecondary := TGPSolidBrush.Create($FF4F4FBF);
  StartBrush := TGPSolidBrush.Create($FF3FCF3F);
  FinishBrush := TGPSolidBrush.Create($FFCF3F3F);
  for Point in Graph.Points do
  begin
    with Point do
    begin
      R := TGPRectF.Create(Pos.X - PointSize / 2, Pos.Y - PointSize / 2, PointSize, PointSize);

      if Point = FPointAtCursor then
        G.FillEllipse(HoverBrush, R)
      else if (FPointAtCursor <> nil) and Point.IsConnected(FPointAtCursor) then
        G.FillEllipse(HoverBrushSecondary, R)
      else
        G.FillEllipse(Brush, R);

      if IsStart then
      begin
        R.Inflate(-PointSize * 0.15);
        G.FillEllipse(StartBrush, R);
      end;

      if IsFinish then
      begin
        R.Inflate(-PointSize * 0.15);
        G.FillEllipse(FinishBrush, R);
      end;

    end;
  end;

  if FConnectionStart <> nil then
  begin
    G.DrawLine(TGPPen.Create(TGPColor.Blue, LineWidth / 2),
      FConnectionStart.Pos.X, FConnectionStart.Pos.Y,
      FConnectionDrag.X, FConnectionDrag.Y);
  end;

end;

procedure TDisplay.Paint(G: IGPGraphics);
begin
  // nothing
end;

procedure TDisplay.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FCamDrag := Vec2(X, Y);
  MouseDown(CursorToGraph(FCamDrag), Button);
end;

procedure TDisplay.PaintBoxMouseLeave(Sender: TObject);
begin
  MouseLeave;
end;

procedure TDisplay.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FCamDrag.HasValue then
    UpdateMouseDrag(Vec2(X, Y))
  else
    UpdateMouseHover(Vec2(X, Y));
end;

procedure TDisplay.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(CursorToGraph(Vec2(X, Y)), Button);
  FCamDrag.Clear;
end;

procedure TDisplay.PaintBoxPaint(Sender: TObject);
var
  G: IGPGraphics;
  BoundsRect: TGPRect;
begin
  // Set everything up
  BoundsRect.Initialize(PaintBox.ClientRect);
  Dec(BoundsRect.Width);
  Dec(BoundsRect.Height);
  G := PaintBox.ToGPGraphics;
  G.SmoothingMode := SmoothingModeHighQuality;

  // Draw gray border
  G.Clear(TGPColor.White);
  G.DrawRectangle(TGPPen.Create(TGPColor.LightGray, 1), BoundsRect);

  // Set ClipRegion
  Inc(BoundsRect.X);
  Inc(BoundsRect.Y);
  Dec(BoundsRect.Width);
  Dec(BoundsRect.Height);
  G.Clip := TGPRegion.Create(BoundsRect);

  // Move to Camera
  G.Transform := CameraMatrix;

  Paint(G);
end;

procedure TEditorDisplay.SetGraph(const Value: TGraphEditable);
begin
  Graph.Assign(Value);
end;

procedure TEditorDisplay.SetTool(const Value: TEditorTool);
begin
  if Tool = Value then
    Exit;
  FTool := Value;
  PaintBox.Invalidate;
  FOnToolChange.Execute(TEventInfo.Create(Self));
end;

{ TCamera }

procedure TCamera.Assign(AFrom: TCamera);
begin
  Pos := AFrom.Pos;
  Scale := AFrom.Scale;
end;

function TCamera.CalculateMatrix(ASize: TIntVector2): IGPMatrix;
begin
  Result := TGPMatrix.Create;
  Result.Translate(ASize.X / 2, ASize.Y / 2);
  Result.Translate(-Pos.X, -Pos.Y);
  Result.Scale(Scale, Scale);
end;

function TCamera.Copy: TCamera;
begin
  Result := TCamera.Create;
  Result.Assign(Self);
end;

constructor TCamera.Create;
begin
  Reset;
end;

function TCamera.GetOnChange: TEvent.TAccess;
begin
  Result := FOnChange.Access;
end;

procedure TCamera.Move(AOffset: TVector2);
begin
  Pos := Pos + AOffset;
end;

procedure TCamera.Reset;
begin
  Pos := 0;
  Scale := 0.8;
end;

procedure TCamera.SetPos(const Value: TVector2);
begin
  if Pos = Value then
    Exit;
  FPos := Value;
  FOnChange.Execute(TEventInfo.Create(Self));
end;

procedure TCamera.SetScale(const Value: Single);
begin
  if Scale = Value then
    Exit;
  FScale := Value;
  FOnChange.Execute(TEventInfo.Create(Self));
end;

procedure TCamera.Zoom(AFactor: Single; APos: TVector2);
var
  OldPos: TVector2;
begin
  OldPos := (Pos + APos) / Scale;
  Scale := EnsureRange(Scale * AFactor, 0.2, 20);
  Pos := OldPos * Scale - APos;
end;

{ TSimulationDisplay }

function TSimulationDisplay.GetGraph: TGraph;
begin
  if FPheromoneData = nil then
    Exit(nil);
  Result := PheromoneData.Graph;
end;

procedure TSimulationDisplay.HideAntPath;
begin
  FVisibleAnt := nil;
  PaintBox.Invalidate;
end;

procedure TSimulationDisplay.Paint(G: IGPGraphics);
var
  Pen: IGPPen;
  Connection: TGraph.TConnection;
  MaxPheromones: Single;
  ColorRGB: TColorRGB;
  Color: TGPColor;
  Brush: IGPSolidBrush;
  StartFinishBrush: IGPSolidBrush;
  Rect: TGPRectF;
  Point: TGraph.TPoint;
begin
  MaxPheromones := 0;
  for Connection in PheromoneData.Graph.Connections do
    MaxPheromones := Max(MaxPheromones, PheromoneData[Connection]);

  // Prevent division by zero
  if MaxPheromones = 0 then
    MaxPheromones := 1;

  for Connection in PheromoneData.Graph.Connections do
  begin
    ColorRGB := TColorRGB.HSV(2 - PheromoneData[Connection] / MaxPheromones * 3, 1.0, 0.8);
    Color.InitializeFromColorRef(ColorRGB.ToWinColor);

    with Connection do
      G.DrawLine(TGPPen.Create(Color, LineWidth), PointA.Pos.X, PointA.Pos.Y, PointB.Pos.X, PointB.Pos.Y);
  end;

  ColorRGB := TColorRGB.HSV(2, 1.0, 0.6);
  Color.InitializeFromColorRef(ColorRGB.ToWinColor);
  Brush := TGPSolidBrush.Create(Color);
  StartFinishBrush := TGPSolidBrush.Create(TGPColor.Brown);
  for Point in PheromoneData.Graph.Points do
  begin
    with Point do
    begin
      Rect.Initialize(Pos.X, Pos.Y, 0, 0);
      Rect.Inflate(PointSize / 2);
      if IsStart or IsFinish then
        G.FillEllipse(StartFinishBrush, Rect)
      else
        G.FillEllipse(Brush, Rect);
    end;
  end;

  if FVisibleAnt <> nil then
  begin
    if FVisibleAnt.Success then
      Pen := TGPPen.Create(TGPColor.Blue, LineWidth * 1.5)
    else
      Pen := TGPPen.Create(TGPColor.Red, LineWidth * 1.5);
    for Connection in FVisibleAnt.Path do
      with Connection do
        G.DrawLine(Pen, PointA.Pos.X, PointA.Pos.Y, PointB.Pos.X,
          PointB.Pos.Y);
  end;

  {
  if (FAnt <> nil) and not FAnt.Path.Empty then
  begin
    SetLength(AntPath, FAnt.Path.Count + 1);
    for I := 0 to FAnt.Path.MaxIndex do
      AntPath[I] := TGPPointF(FAnt.Path[I].PointA.Pos);
    AntPath[FAnt.Path.MaxIndex + 1] := TGPPointF(FAnt.Path.Last.PointB.Pos);

    Pen := TGPPen.Create(TGPColor.Blue, LineWidth * 1.5);
    G.DrawCurve(Pen, AntPath, 0.9);
  end;
   }
end;

procedure TSimulationDisplay.SetPheromoneData(const Value: TPheromoneData);
begin
  if PheromoneData = Value then
    Exit;
  FPheromoneData := Value;
  PaintBox.Invalidate;
end;

procedure TSimulationDisplay.SetVisibleAnt(const Value: TAnt);
begin
  FVisibleAnt := Value;
  PaintBox.Invalidate;
end;

procedure TSimulationDisplay.ShowAntPath(AAnt: TAnt);
begin
  FVisibleAnt := AAnt;
  PaintBox.Invalidate;
end;

end.
