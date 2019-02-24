unit DisplayView;

interface

uses
  Winapi.Windows,

  System.Types,
  System.Classes,

  Vcl.ExtCtrls,
  Vcl.Direct2D,
  Vcl.Controls,

  GdiPlus,
  GdiPlusHelpers,

  Pengine.Collections,
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.Utility,

  GraphDefine,
  System.SysUtils;

type

  TEditorTool = (
    etMove,
    etPoint,
    etConnection,
    etStart,
    etFinish
    );

  TDisplay = class
  private
    FPaintBox: TPaintBox;
    FCamera: IGPMatrix;
    FCamDrag: TOpt<TVector2>;
    FGraph: TGraph;
    FPointSize: Single;
    FLineWidth: Single;
    FEditable: Boolean;
    FTool: TEditorTool;
    FPointAtCursor: TOpt<TGraph.TPoint>;
    FConnectionAtCursor: TOpt<TGraph.TConnection>;
    FSmoothing: Boolean;

    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseLeave(Sender: TObject);

    procedure UpdateMouseHover(APos: TVector2);

    procedure SetLineWidth(const Value: Single);
    procedure SetPointSize(const Value: Single);

    function ConvertPoint(APos: TVector2; ACursorToGraph: Boolean): TVector2;
    function CursorToGraph(APos: TVector2): TVector2;
    function GraphToCursor(APos: TVector2): TVector2;
    procedure SetSmoothing(const Value: Boolean);

  public
    constructor Create(APaintBox: TPaintBox);
    destructor Destroy; override;

    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);

    property PaintBox: TPaintBox read FPaintBox;

    property Graph: TGraph read FGraph;

    property Editable: Boolean read FEditable write FEditable;
    property Tool: TEditorTool read FTool write FTool;

    property Smoothing: Boolean read FSmoothing write SetSmoothing;

    procedure ResetCamera;
    procedure MoveCamera(AOffset: TVector2);
    procedure ZoomCamera(AFactor: Single; APos: TVector2);

    property PointSize: Single read FPointSize write SetPointSize;
    property LineWidth: Single read FLineWidth write SetLineWidth;

  end;

implementation

{ TDisplay }

function TDisplay.ConvertPoint(APos: TVector2; ACursorToGraph: Boolean): TVector2;
var
  CamHelper: IGPMatrix;
  Point: TGPPointF;
begin
  CamHelper := TGPMatrix.Create;
  CamHelper.Translate(PaintBox.ClientWidth / 2, PaintBox.ClientHeight / 2);
  CamHelper.Multiply(FCamera);
  if ACursorToGraph then
    CamHelper.Invert;
  Point := TGPPointF.Create(APos.X, APos.Y);
  CamHelper.TransformPoint(Point);
  Result := Vec2(Point.X, Point.Y);
end;

constructor TDisplay.Create(APaintBox: TPaintBox);
begin
  FPaintBox := APaintBox;
  PaintBox.OnPaint := PaintBoxPaint;
  PaintBox.OnMouseDown := PaintBoxMouseDown;
  PaintBox.OnMouseMove := PaintBoxMouseMove;
  PaintBox.OnMouseUp := PaintBoxMouseUp;
  PaintBox.OnMouseLeave := PaintBoxMouseLeave;
  PaintBox.ControlStyle := PaintBox.ControlStyle + [csOpaque];
  FCamera := TGPMatrix.Create;
  FGraph := TGraph.Create;

  Graph.OnChanged.Add(PaintBox.Invalidate);

  FSmoothing := True;

  FPointSize := 12;
  FLineWidth := 5;
end;

function TDisplay.CursorToGraph(APos: TVector2): TVector2;
begin
  Result := ConvertPoint(APos, True);
end;

destructor TDisplay.Destroy;
begin
  FGraph.Free;
  inherited;
end;

function TDisplay.GraphToCursor(APos: TVector2): TVector2;
begin
  Result := ConvertPoint(APos, False);
end;

procedure TDisplay.MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);
begin
  // if ssCtrl in Shift then
  ZoomCamera(1 + WheelDelta / WHEEL_DELTA * 0.1, Vec2(MousePos.X, MousePos.Y));
end;

procedure TDisplay.MoveCamera(AOffset: TVector2);
begin
  FCamera.Translate(-AOffset.X, -AOffset.Y, MatrixOrderAppend);
  PaintBox.Invalidate;
end;

procedure TDisplay.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FCamDrag := Vec2(X, Y);
end;

procedure TDisplay.PaintBoxMouseLeave(Sender: TObject);
begin
  FPointAtCursor.Clear;
  FConnectionAtCursor.Clear;
  PaintBox.Invalidate;
end;

procedure TDisplay.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FCamDrag.HasValue then
  begin
    if FPointAtCursor.HasValue then
      FPointAtCursor.Value.Pos := FPointAtCursor.Value.Pos + CursorToGraph(Vec2(X, Y)) - CursorToGraph(FCamDrag)
    else
      MoveCamera(FCamDrag - Vec2(X, Y));
    FCamDrag := Vec2(X, Y);
  end
  else
    UpdateMouseHover(Vec2(X, Y));
end;

procedure TDisplay.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FCamDrag.Clear;
end;

procedure TDisplay.PaintBoxPaint(Sender: TObject);
var
  G: IGPGraphics;
  BoundsRect: TGPRect;
  Connection: TGraph.TConnection;
  Point: TGraph.TPoint;
  Brush: IGPSolidBrush;
  R: TGPRectF;
  Pen: IGPPen;
  HoverBrush: IGPSolidBrush;
  PointHoverPen: IGPPen;
  HoverBrushSecondary: IGPSolidBrush;
begin
  // Set everything up
  BoundsRect.Initialize(PaintBox.ClientRect);
  Dec(BoundsRect.Width);
  Dec(BoundsRect.Height);
  G := PaintBox.ToGPGraphics;
  if Smoothing then
    G.SmoothingMode := SmoothingModeHighQuality
  else
    G.SmoothingMode := SmoothingModeHighSpeed;

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
  G.TranslateTransform(PaintBox.ClientWidth / 2, PaintBox.ClientHeight / 2);
  G.MultiplyTransform(FCamera);

  // Render Connections
  Pen := TGPPen.Create($FF7F7FCF, LineWidth);
  PointHoverPen := TGPPen.Create($FF9F9FEF, LineWidth);
  for Connection in Graph.Connections do
  begin
    with Connection do
    begin
      if FPointAtCursor.HasValue and Connection.AnyIs(FPointAtCursor) then
        G.DrawLine(PointHoverPen, PointA.Pos.X, PointA.Pos.Y, PointB.Pos.X, PointB.Pos.Y)
      else
        G.DrawLine(Pen, PointA.Pos.X, PointA.Pos.Y, PointB.Pos.X, PointB.Pos.Y);
    end;
  end;

  // Render Points
  Brush := TGPSolidBrush.Create($FF3F3F7F);
  HoverBrush := TGPSolidBrush.Create($FFAF2FAF);
  HoverBrushSecondary := TGPSolidBrush.Create($FF4F4FBF);
  for Point in Graph.Points do
  begin
    with Point do
    begin
      R := TGPRectF.Create(Pos.X - PointSize / 2, Pos.Y - PointSize / 2, PointSize, PointSize);
      if Point = FPointAtCursor then
        G.FillEllipse(HoverBrush, R)
      else if FPointAtCursor.HasValue and Point.IsConnected(FPointAtCursor) then
        G.FillEllipse(HoverBrushSecondary, R)
      else
        G.FillEllipse(Brush, R);
    end;
  end;
end;

procedure TDisplay.ResetCamera;
begin
  FCamera.Reset;
  PaintBox.Invalidate;
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

procedure TDisplay.SetSmoothing(const Value: Boolean);
begin
  if Smoothing = Value then
    Exit;
  FSmoothing := Value;
  PaintBox.Invalidate;
end;

procedure TDisplay.UpdateMouseHover(APos: TVector2);
var
  OldPointAtCursor: TOpt<TGraph.TPoint>;
  OldConnectionAtCursor: TOpt<TGraph.TConnection>;
  Point: TGraph.TPoint;
  NewDistance, ClosestDistance: Single;
begin
  APos := CursorToGraph(APos);

  // First find hovered point
  OldPointAtCursor := FPointAtCursor;
  FPointAtCursor.Clear;
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
  FConnectionAtCursor.Clear;
  if not FPointAtCursor.HasValue then
  begin
    // TODO: Connection selection
  end;

  if (FPointAtCursor <> OldPointAtCursor) or (FConnectionAtCursor <> OldConnectionAtCursor) then
    PaintBox.Invalidate;
end;

procedure TDisplay.ZoomCamera(AFactor: Single; APos: TVector2);
var
  E: TGPMatrixElements;
  Scale: Single;
  ScalePos: TVector2;
begin
  E := FCamera.Elements;
  Scale := Vec2(E.M11, E.M12).Length * AFactor;
  if (Scale > 20) and (AFactor > 1) or
    (Scale < 0.2) and (AFactor < 1) then
    Exit;

  ScalePos.X := APos.X - PaintBox.ClientWidth / 2;
  ScalePos.Y := APos.Y - PaintBox.ClientHeight / 2;

  FCamera.Translate(-ScalePos.X, -ScalePos.Y, MatrixOrderAppend);
  FCamera.Scale(AFactor, AFactor, MatrixOrderAppend);
  FCamera.Translate(ScalePos.X, ScalePos.Y, MatrixOrderAppend);

  PaintBox.Invalidate;
end;

end.
