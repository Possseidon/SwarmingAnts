object mdlgGenerateRandomPoints: TmdlgGenerateRandomPoints
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Zufallspunkt-Generator'
  ClientHeight = 69
  ClientWidth = 148
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  DesignSize = (
    148
    69)
  PixelsPerInch = 96
  TextHeight = 13
  object lbCount: TLabel
    Left = 8
    Top = 11
    Width = 36
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Anzahl:'
  end
  object seCount: TSpinEdit
    Left = 81
    Top = 8
    Width = 57
    Height = 22
    Anchors = [akRight, akBottom]
    Increment = 5
    MaxValue = 500
    MinValue = 1
    TabOrder = 0
    Value = 50
  end
  object btnGenerate: TButton
    Left = 8
    Top = 36
    Width = 132
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Generieren'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
