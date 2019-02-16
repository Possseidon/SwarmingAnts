object mdlgGenerateGrid: TmdlgGenerateGrid
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Netz-Generator'
  ClientHeight = 125
  ClientWidth = 133
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  DesignSize = (
    133
    125)
  PixelsPerInch = 96
  TextHeight = 13
  object lbWidth: TLabel
    Left = 8
    Top = 11
    Width = 32
    Height = 13
    Caption = 'Breite:'
  end
  object lbHeight: TLabel
    Left = 8
    Top = 39
    Width = 29
    Height = 13
    Caption = 'H'#246'he:'
  end
  object lbDistance: TLabel
    Left = 8
    Top = 67
    Width = 44
    Height = 13
    Caption = 'Abstand:'
  end
  object seWidth: TSpinEdit
    Left = 68
    Top = 8
    Width = 57
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 5
    MaxValue = 100
    MinValue = 2
    TabOrder = 0
    Value = 20
  end
  object seHeight: TSpinEdit
    Left = 68
    Top = 36
    Width = 57
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 5
    MaxValue = 100
    MinValue = 2
    TabOrder = 1
    Value = 20
  end
  object seDistance: TSpinEdit
    Left = 68
    Top = 64
    Width = 57
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 5
    MaxValue = 500
    MinValue = 10
    TabOrder = 2
    Value = 15
  end
  object btnGenerate: TButton
    Left = 8
    Top = 92
    Width = 117
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Generieren'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnGenerateClick
  end
end
