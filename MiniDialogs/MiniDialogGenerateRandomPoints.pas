unit MiniDialogGenerateRandomPoints;

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
  Pengine.Vector;

type
  TmdlgGenerateRandomPoints = class(TForm)
    lbCount: TLabel;
    seCount: TSpinEdit;
    btnGenerate: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FGraph: TGraph;

  protected
    procedure UpdateActions; override;

  public
    procedure Execute(AGraph: TGraph);

  end;

var
  mdlgGenerateRandomPoints: TmdlgGenerateRandomPoints;

implementation

{$R *.dfm}

{ TForm1 }

procedure TmdlgGenerateRandomPoints.Execute(AGraph: TGraph);
begin
  FGraph := AGraph;
  ModalResult := mrCancel;
  Position := poMainFormCenter;
  Show;
end;

procedure TmdlgGenerateRandomPoints.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then
  begin
    with TGraph.TRandomPointGenerator.Create(FGraph) do
    begin
      try
        Count := seCount.Value;
        Bounds := Bounds2(-300, 300);
        Generate;

      finally
        Free;

      end;
    end;
  end;
end;

procedure TmdlgGenerateRandomPoints.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TmdlgGenerateRandomPoints.UpdateActions;
begin
  inherited;

end;

end.
