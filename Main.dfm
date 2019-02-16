object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Swarm-Intelligence Demo'
  ClientHeight = 552
  ClientWidth = 885
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TStatusBar
    Left = 0
    Top = 533
    Width = 885
    Height = 19
    AutoHint = True
    Panels = <
      item
        Width = 420
      end>
  end
  object pnlMain: TPanel
    Left = 222
    Top = 0
    Width = 663
    Height = 533
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object pbDisplay: TPaintBox
      AlignWithMargins = True
      Left = 28
      Top = 3
      Width = 632
      Height = 458
      Margins.Left = 0
      Align = alClient
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 8
      ExplicitWidth = 532
      ExplicitHeight = 341
    end
    object gbProgress: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 467
      Width = 657
      Height = 63
      Align = alBottom
      Caption = 'Fortschritt'
      TabOrder = 0
      Visible = False
      object pbProgressBar: TProgressBar
        AlignWithMargins = True
        Left = 5
        Top = 41
        Width = 647
        Height = 17
        Align = alBottom
        TabOrder = 0
      end
      object pnlProgress: TPanel
        Left = 2
        Top = 15
        Width = 653
        Height = 23
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lbProgressInfo: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 20
          Height = 17
          Align = alLeft
          Caption = '[...]'
          ExplicitHeight = 13
        end
        object lbProgressPercentage: TLabel
          AlignWithMargins = True
          Left = 633
          Top = 3
          Width = 17
          Height = 17
          Align = alRight
          Caption = '0%'
          ExplicitHeight = 13
        end
      end
    end
    object tbDisplay: TToolBar
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 25
      Height = 458
      Margins.Right = 0
      Align = alLeft
      AutoSize = True
      Caption = 'tbDisplay'
      DrawingStyle = dsGradient
      EdgeBorders = [ebLeft, ebTop, ebBottom]
      GradientDirection = gdHorizontal
      TabOrder = 1
      object ToolButton3: TToolButton
        Left = 0
        Top = 0
        Action = actGenerateGrid
        Wrap = True
      end
      object tbClear: TToolButton
        Left = 0
        Top = 22
        Action = actClear
      end
      object ToolButton2: TToolButton
        Left = 0
        Top = 22
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 1
        Wrap = True
        Style = tbsSeparator
      end
      object ToolButton4: TToolButton
        Left = 0
        Top = 52
        Caption = 'ToolButton4'
        ImageIndex = 1
        Wrap = True
      end
      object ToolButton1: TToolButton
        Left = 0
        Top = 74
        Caption = 'ToolButton1'
        ImageIndex = 2
      end
    end
  end
  object sbSidebar: TScrollBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 216
    Height = 527
    VertScrollBar.Tracking = True
    Align = alLeft
    BevelInner = bvNone
    BorderStyle = bsNone
    TabOrder = 2
    object gbSettings: TGroupBox
      Left = 0
      Top = 0
      Width = 216
      Height = 185
      Align = alTop
      Caption = 'Einstellungen'
      TabOrder = 0
    end
  end
  object mmMain: TMainMenu
    Left = 280
    Top = 72
    object miFile: TMenuItem
      Caption = 'Datei'
      object miNew: TMenuItem
        Action = actNew
      end
      object miOpen: TMenuItem
        Action = actOpen
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miSave: TMenuItem
        Action = actSave
      end
      object miSaveAs: TMenuItem
        Action = actSaveAs
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miExit: TMenuItem
        Action = actExit
      end
    end
    object miEdit: TMenuItem
      Caption = 'Bearbeiten'
      object miClear: TMenuItem
        Action = actClear
      end
      object miGenerateGrid: TMenuItem
        Action = actGenerateGrid
      end
    end
    object miView: TMenuItem
      Caption = 'Ansicht'
      object miShowSidebar: TMenuItem
        Action = actShowSidebar
      end
      object miShowProgress: TMenuItem
        Action = actShowProgress
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object miEditMode: TMenuItem
        Action = actEditMode
        AutoCheck = True
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object miResetView: TMenuItem
        Action = actResetView
      end
      object miSmoothing: TMenuItem
        Action = actSmoothing
      end
    end
  end
  object alMain: TActionList
    Images = ilIcons
    Left = 280
    Top = 16
    object actNew: TAction
      Category = 'File'
      Caption = 'Neu'
      Hint = 'Erstellt ein neues leeres Projekt.'
      ShortCut = 16462
    end
    object actOpen: TAction
      Category = 'File'
      Caption = #214'ffnen...'
      Hint = #214'ffnet ein Projekt.'
      ShortCut = 16463
    end
    object actSave: TAction
      Category = 'File'
      Caption = 'Speichern'
      Hint = 'Speichert das momentan ge'#246'ffnete Projekt.'
      ShortCut = 16467
    end
    object actSaveAs: TAction
      Category = 'File'
      Caption = 'Speichern unter...'
      Hint = 
        'Speichert das momentan ge'#246'ffnete Projekt unter einem bestimmten ' +
        'Namen.'
      ShortCut = 24659
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'Beenden'
      Hint = 'Beendet die Anwendung.'
      OnExecute = actExitExecute
    end
    object actShowProgress: TAction
      Category = 'View'
      Caption = 'Fortschrittsanzeige'
      Hint = 'Zeigt die Fortschrittsanzeige an.'
      OnExecute = actShowProgressExecute
    end
    object actShowSidebar: TAction
      Category = 'View'
      Caption = 'Sidebar'
      Hint = 'Zeigt die Sidebar an.'
      OnExecute = actShowSidebarExecute
    end
    object actEditMode: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Bearbeitungsmodus'
      Hint = 'Wechselt zwischen Simulations- und Bearbeitungsmodus.'
      OnExecute = actEditModeExecute
    end
    object actClear: TAction
      Category = 'Edit'
      Caption = 'Alles l'#246'schen'
      Hint = 'L'#246'scht alle Wegpunkte.'
      OnExecute = actClearExecute
    end
    object actGenerateGrid: TAction
      Category = 'Edit'
      Caption = 'Netz generieren...'
      Hint = 'Generiert ein Punkte-Netz beliebiger Gr'#246#223'e.'
      OnExecute = actGenerateGridExecute
    end
    object actResetView: TAction
      Category = 'View'
      Caption = 'Ansicht zur'#252'cksetzen'
      OnExecute = actResetViewExecute
    end
    object actSmoothing: TAction
      Category = 'View'
      Caption = 'Kantengl'#228'ttung'
      OnExecute = actSmoothingExecute
    end
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    Left = 278
    Top = 128
  end
end
