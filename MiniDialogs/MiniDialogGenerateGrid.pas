unit MiniDialogGenerateGrid;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Samples.Spin,

  GraphDefine,
  Pengine.IntMaths,
  Pengine.Vector;

type

  TmdlgGenerateGrid = class(TForm)
    seWidth: TSpinEdit;
    lbWidth: TLabel;
    seHeight: TSpinEdit;
    lbHeight: TLabel;
    seDistance: TSpinEdit;
    lbDistance: TLabel;
    btnGenerate: TButton;
    procedure btnGenerateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FGraph: TGraph;

  protected
    procedure UpdateActions; override;

  public
    procedure Execute(AGraph: TGraph);

  end;

var
  mdlgGenerateGrid: TmdlgGenerateGrid;

implementation

{$R *.dfm}

{ TmdlgGenerateGrid }

procedure TmdlgGenerateGrid.btnGenerateClick(Sender: TObject);
begin
  // make sure the active spin edit loses focus, to limit the value
  SetFocusedControl(btnGenerate);
  ModalResult := mrOk;
  Close;
end;

procedure TmdlgGenerateGrid.Execute(AGraph: TGraph);
begin
  FGraph := AGraph;
  ModalResult := mrCancel;
  Position := poMainFormCenter;
  Show;
end;

procedure TmdlgGenerateGrid.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then
  begin
    with TGraph.TGridGenerator.Create(FGraph) do
    begin
      try
        Size := IVec2(seWidth.Value, seHeight.Value);
        Bounds := Bounds2(0).Outset(seDistance.Value * TVector2(Size));
        Generate;

      finally
        Free;

      end;
    end;
  end;
end;

procedure TmdlgGenerateGrid.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TmdlgGenerateGrid.FormKeyDown(Sender: TObject; var Key: Word; Shift:
  TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TmdlgGenerateGrid.UpdateActions;
begin
  inherited;
  btnGenerate.Enabled := (seWidth.Text <> '') and (seHeight.Text <> '') and (seDistance.Text <> '');
end;

end.
