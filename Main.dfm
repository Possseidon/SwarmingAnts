object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Swarm-Intelligence Demo'
  ClientHeight = 558
  ClientWidth = 700
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
    Top = 539
    Width = 700
    Height = 19
    AutoHint = True
    Panels = <
      item
        Width = 420
      end>
  end
  object pnlMain: TPanel
    Left = 233
    Top = 0
    Width = 467
    Height = 539
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object pbDisplay: TPaintBox
      AlignWithMargins = True
      Left = 0
      Top = 35
      Width = 464
      Height = 343
      Margins.Left = 0
      Align = alClient
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 8
      ExplicitTop = 3
      ExplicitWidth = 532
      ExplicitHeight = 341
    end
    object splStatistics: TSplitter
      Left = 0
      Top = 381
      Width = 467
      Height = 5
      Cursor = crVSplit
      Align = alBottom
      Beveled = True
      ResizeStyle = rsUpdate
      ExplicitTop = 383
      ExplicitWidth = 476
    end
    object tbDisplay: TToolBar
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 464
      Height = 26
      Margins.Right = 0
      AutoSize = True
      Caption = 'tbDisplay'
      DrawingStyle = dsGradient
      EdgeBorders = [ebLeft, ebTop, ebBottom]
      Images = ilIcons
      TabOrder = 0
      object tbGenerateGrid: TToolButton
        Left = 0
        Top = 0
        Action = actGenerateGrid
      end
      object tbClear: TToolButton
        Left = 23
        Top = 0
        Action = actClear
      end
      object tbSplit: TToolButton
        Left = 46
        Top = 0
        Width = 8
        Caption = 'tbSplit'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object tbSelectionTool: TToolButton
        Left = 54
        Top = 0
        Action = actSelectionTool
        Grouped = True
        Style = tbsCheck
      end
      object tbPointTool: TToolButton
        Left = 77
        Top = 0
        Action = actPointTool
        Grouped = True
        Style = tbsCheck
      end
      object tbConnectionTool: TToolButton
        Left = 100
        Top = 0
        Action = actConnectionTool
        Grouped = True
        Style = tbsCheck
      end
      object tbStartTool: TToolButton
        Left = 123
        Top = 0
        Action = actStartTool
        Grouped = True
        Style = tbsCheck
      end
      object tbFinishTool: TToolButton
        Left = 146
        Top = 0
        Action = actFinishTool
        Grouped = True
        Style = tbsCheck
      end
    end
    object gbStatistics: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 389
      Width = 461
      Height = 147
      Align = alBottom
      Caption = 'Statistik'
      TabOrder = 1
      object lbTodoChart: TLabel
        Left = 184
        Top = 62
        Width = 63
        Height = 13
        Caption = 'TODO: Chart'
      end
    end
  end
  object sbSidebar: TScrollBox
    Left = 0
    Top = 0
    Width = 233
    Height = 539
    VertScrollBar.Tracking = True
    Align = alLeft
    BevelInner = bvNone
    BorderStyle = bsNone
    TabOrder = 2
    object gbSimulation: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 227
      Height = 110
      Align = alTop
      Caption = 'Einstellungen'
      TabOrder = 0
      object lbBatchSize: TLabel
        Left = 12
        Top = 23
        Width = 63
        Height = 13
        Caption = 'Batch Gr'#246#223'e:'
      end
      object lbPheromoneDissipation: TLabel
        Left = 12
        Top = 78
        Width = 73
        Height = 13
        Caption = 'Verfl'#252'chtigung:'
      end
      object lbPheromoneDissipationUnit: TLabel
        Left = 202
        Top = 78
        Width = 11
        Height = 13
        Caption = '%'
      end
      object Label1: TLabel
        Left = 12
        Top = 51
        Width = 70
        Height = 13
        Caption = 'Beeinflussung:'
      end
      object Label2: TLabel
        Left = 202
        Top = 51
        Width = 11
        Height = 13
        Caption = '%'
      end
      object seBatchSize: TSpinEdit
        Left = 112
        Top = 20
        Width = 103
        Height = 22
        MaxValue = 500
        MinValue = 1
        TabOrder = 0
        Value = 20
        OnExit = seBatchSizeExit
      end
      object edtPheromoneDissipation: TEdit
        Left = 112
        Top = 75
        Width = 84
        Height = 21
        TabOrder = 2
        OnExit = edtPheromoneDissipationExit
      end
      object edtInfluenceFactor: TEdit
        Left = 112
        Top = 48
        Width = 84
        Height = 21
        TabOrder = 1
        OnExit = edtInfluenceFactorExit
      end
    end
    object gbPopulation: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 213
      Width = 227
      Height = 323
      Align = alClient
      Caption = 'Population'
      TabOrder = 1
      object lbBatch: TLabel
        Left = 16
        Top = 27
        Width = 31
        Height = 13
        Caption = 'Batch:'
      end
      object lbTodoBatchStatistics: TLabel
        Left = 56
        Top = 64
        Width = 109
        Height = 13
        Caption = 'TODO: Batch Statistics'
      end
      object seBatch: TSpinEdit
        Left = 112
        Top = 24
        Width = 103
        Height = 22
        Enabled = False
        MaxValue = 1
        MinValue = 1
        TabOrder = 0
        Value = 1
        OnChange = seBatchChange
      end
      object lvAnts: TListView
        Left = 12
        Top = 96
        Width = 203
        Height = 209
        Columns = <
          item
            Caption = 'ID'
            Width = 30
          end
          item
            Caption = 'Pfadl'#228'nge'
            Width = 80
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        OnColumnClick = lvAntsColumnClick
        OnCompare = lvAntsCompare
        OnSelectItem = lvAntsSelectItem
      end
    end
    object gbControl: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 119
      Width = 227
      Height = 88
      Align = alTop
      Caption = 'Steuerung'
      TabOrder = 2
      DesignSize = (
        227
        88)
      object btnReset: TButton
        Left = 12
        Top = 23
        Width = 84
        Height = 25
        Action = actReset
        Anchors = [akLeft, akBottom]
        TabOrder = 0
      end
      object btnStart: TButton
        Left = 112
        Top = 23
        Width = 84
        Height = 25
        Action = actStart
        Anchors = [akLeft, akBottom]
        TabOrder = 1
      end
      object btnGenerate: TButton
        Left = 16
        Top = 54
        Width = 199
        Height = 25
        Action = actGenerate
        Anchors = [akLeft, akBottom]
        Caption = 'Generiere Batch'
        TabOrder = 2
      end
    end
  end
  object mmMain: TMainMenu
    Images = ilIcons
    Left = 312
    Top = 56
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
    object miView: TMenuItem
      Caption = 'Ansicht'
      object miResetView: TMenuItem
        Action = actResetView
      end
    end
    object miEdit: TMenuItem
      Caption = 'Editor'
      object miEditMode: TMenuItem
        Action = actEditorActive
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object miGenerateGrid: TMenuItem
        Action = actGenerateGrid
      end
      object miClear: TMenuItem
        Action = actClear
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object KameraTool1: TMenuItem
        Action = actSelectionTool
      end
      object PunktWerkzeug1: TMenuItem
        Action = actPointTool
      end
      object VerbindungsWerkzeug1: TMenuItem
        Action = actConnectionTool
      end
      object StartWerkzeug1: TMenuItem
        Action = actStartTool
      end
      object actFinishTool1: TMenuItem
        Action = actFinishTool
      end
    end
  end
  object alMain: TActionList
    Images = ilIcons
    Left = 256
    Top = 56
    object actClear: TAction
      Category = 'Editor'
      Caption = 'Alles l'#246'schen'
      Hint = 'L'#246'scht alle Wegpunkte und deren Verbindungen.'
      ImageIndex = 6
      OnExecute = actClearExecute
    end
    object actGenerateGrid: TAction
      Category = 'Editor'
      Caption = 'Netz generieren...'
      Hint = 
        'Generiert ein Punkte-Netz in Form eines Gatters beliebiger Gr'#246#223'e' +
        '.'
      ImageIndex = 5
      OnExecute = actGenerateGridExecute
    end
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
      OnExecute = actOpenExecute
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
      OnExecute = actSaveAsExecute
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'Beenden'
      Hint = 'Beendet die Anwendung.'
      OnExecute = actExitExecute
    end
    object actEditorActive: TAction
      Category = 'Editor'
      Caption = '...'
      Hint = 'Wechselt zwischen Simulations- und Editormodus.'
      OnExecute = actEditorActiveExecute
    end
    object actSelectionTool: TAction
      Category = 'Editor'
      Caption = 'Auswahl Werkzeug'
      GroupIndex = 1
      Hint = 'Erlaubt das Bewegen und Ausw'#228'hlen von Punkten und Verbindungen.'
      ImageIndex = 0
      OnExecute = actSelectionToolExecute
    end
    object actResetView: TAction
      Category = 'View'
      Caption = 'Ansicht zur'#252'cksetzen'
      OnExecute = actResetViewExecute
    end
    object actPointTool: TAction
      Category = 'Editor'
      Caption = 'Punkt Werkzeug'
      GroupIndex = 1
      Hint = 'Erlaubt das platzieren von Wegpunkten.'
      ImageIndex = 1
      OnExecute = actPointToolExecute
    end
    object actConnectionTool: TAction
      Category = 'Editor'
      Caption = 'Verbindungs Werkzeug'
      GroupIndex = 1
      Hint = 'Erlaubt das ziehen von Verbindungen.'
      ImageIndex = 2
      OnExecute = actConnectionToolExecute
    end
    object actStartTool: TAction
      Category = 'Editor'
      Caption = 'Start setzen'
      GroupIndex = 1
      Hint = 'Erlaubt das Setzen eines Startpunktes.'
      ImageIndex = 3
      OnExecute = actStartToolExecute
    end
    object actFinishTool: TAction
      Category = 'Editor'
      Caption = 'Ziel setzen'
      GroupIndex = 1
      Hint = 'Erlaubt das Setzen eines Zielpunktes.'
      ImageIndex = 4
      OnExecute = actFinishToolExecute
    end
    object actGenerate: TAction
      Category = 'Simulation'
      Caption = 'Generiere'
      OnExecute = actGenerateExecute
      OnUpdate = actGenerateUpdate
    end
    object actStart: TAction
      Category = 'Simulation'
      Caption = 'Start'
      OnExecute = actStartExecute
      OnUpdate = actStartUpdate
    end
    object actReset: TAction
      Category = 'Simulation'
      Caption = 'Zur'#252'cksetzen'
      OnExecute = actResetExecute
    end
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Left = 366
    Top = 56
    Bitmap = {
      494C010107000800040010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000100000
      0014000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000070000
      0533000000130000000200000000000000000000000000000000000000000000
      0000000000040000022100000015000000020000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000B0B0B6C3F3F3FFF1414
      148F000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000D060654854343FF8543
      43FF0D060654000000000D060654854343FF854343FF0D060654000000000D06
      0654854343FF854343FF0D06065400000000000000000000000000051E650015
      83DD00072F910000032900000003000000000000000000000000000000000000
      000400126AAC000A3A9700021159000000120000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000A585858D73F3F3FFF2626
      26C7000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006B3535EB7E3E3EFF7E3E
      3EFF854343FFCF7E7EFF6B3535EB7E3E3EFF7E3E3EFF854343FFCF7E7EFF6B35
      35EB7E3E3EFF7E3E3EFF854343FF000000000000000000020E3C0026DDF5001E
      B7FF00168EF400093CA400010637000000060000000000000000000000040014
      72AB002AF2FF0021C3F800072878000000100000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000024B4B4BC54B4B4BFC3D3D
      3DFB000000080000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006B3535EB7E3E3EFF7E3E
      3EFF854343FFCF7E7EFF6B3535EB7E3E3EFF7E3E3EFF854343FFCF7E7EFF6B35
      35EB7E3E3EFF7E3E3EFF854343FF000000000000000014246DA70E38FDFF0028
      E6FF001EB8FF00178CED000A43AD0003135E0000000A00000004001472AB002D
      FFFF002CFDFF002AF3FF000D4C8F000000020000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000393939AB434343DE3F3F
      3FFF04040440000000000000000000000000000000000501337D0C0486CC1006
      A9E40D059DDE0B0266AC0000042300000000000000000B05054C6B3535EB6B35
      35EB0B05054C000000000B05054C6B3535EB6B3535EB0B05054C000000000B05
      054C6B3535EB6B3535EB0B05054C0000000000000000161A2D6C5B70D6EA2248
      FDFF0028EAFF001FBCFF00178EF1000E59C700010A43001472AB002DFFFF002D
      FFFF002DFFFF000E508F00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000001D1D1D7B454545CD3F3F
      3FFF0E0E0E78000000000000000000000113090487D20202BCFF0403D2FF0403
      D6FF1106D8FF0003AFFF0B0265AB000000000000000000000000CF7E7EFFCF7E
      7EFF000000000000000000000000CF7E7EFFCF7E7EFF00000000000000000000
      0000CF7E7EFFCF7E7EFF0000000000000000000000000000000006070E3C4F63
      C6E13659FDFF002AF1FF0024D3FF001686D7001478B7002DFFFF002DFFFF002D
      FFFF000E508F0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000003030329555555D64040
      40FF292442D604002568020160B90005A7FB0603C3FF0303F3FB000FFFFF000F
      FFFF000CEBF50E05D3FF0A0494DB00000000000000000D060654854343FF8543
      43FF0D060654000000000D060654854343FF854343FF0D060654000000000D06
      0654854343FF854343FF0D060654000000000000000000000000000000000101
      031C4F64C6E1395CFFFF002DFCFF002AF3FF002CFDFF002DFFFF002DFFFF000E
      508F000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000004D4D4DC84747
      47FF3D3B4AFE1006CFFF0E05D1FF0D06F4FF0107E4F2000FFFFF000FFFFF000F
      FFFF000FFFFF0804E4FF0A04B7F600000000000000006B3535EB7E3E3EFF7E3E
      3EFF854343FFCF7E7EFF6B3535EB7E3E3EFF7E3E3EFF854343FFCF7E7EFF6B35
      35EB7E3E3EFF7E3E3EFF854343FF000000000000000000000000000000000000
      00000000000B495CBDDC0330FFFF002DFFFF002DFFFF002CFCFF000F5CA20000
      0222000000040000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002F2F2F9C4A4A
      4CEC4C508BFF2C2FD4EE000BE5F2000FFFFF000FFFFF000FFFFF000FFFFF000F
      FFFF000FFFFF0804EAFC0603BEFF00000110000000006B3535EB7E3E3EFF7E3E
      3EFF854343FFCF7E7EFF6B3535EB7E3E3EFF7E3E3EFF854343FFCF7E7EFF6B35
      35EB7E3E3EFF7E3E3EFF854343FF000000000000000000000000000000000000
      000000000004001472AB002DFFFF002DFFFF002DFFFF0029EFFF001686D8000A
      3EA7000109410000000400000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000E0E0E574B4B
      4BD63E45BCFF8389FFFF0A1AFFFF000FFFFF000FFFFF000FFFFF000FFFFF000F
      FFFF000FFFFF0403D5EB0302B8FF0200134C000000000B05054C6B3535EB6B35
      35EB0B05054C000000000B05054C6B3535EB6B3535EB0B05054C000000000B05
      054C6B3535EB6B3535EB0B05054C000000000000000000000000000000000000
      0004001472AB002DFFFF002DFFFF012EFFFF2C51FFFF002BF8FF0021C4FF0017
      90F6000B49B400010A4300000006000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000101011E5656
      56D83C3E67FF7B80FBFE3440FFFF000FFFFF000FFFFF000FFFFF000FFFFF000F
      FFFF0A13E5F22C1CDEEE1C16CFFF0803519E0000000000000000CF7E7EFFCF7E
      7EFF000000000000000000000000CF7E7EFFCF7E7EFF00000000000000000000
      0000CF7E7EFFCF7E7EFF00000000000000000000000000000000000000040014
      72AB002DFFFF002DFFFF002DFFFF011054935267CBE4173FFEFF0029F0FF001F
      BCFF00178CED000B46B10001083E000000040000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000004444
      44BE4C4C4CFF676DE4FB7880FFFF0817FFFF000FFFFF000FFFFF0F14EBF55B5C
      FFFF7A7CFFFF7778FFFF5B59F4FF0902539B000000000D060654854343FF8543
      43FF0D060654000000000D060654854343FF854343FF0D060654000000000D06
      0654854343FF854343FF0D060654000000000000000000000004001472AB002D
      FFFF002DFFFF002DFFFF000E508F00000000090B1449647AE1F00B36FEFF002A
      F1FF0020C2FF00178CED0005217A000000140000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000001F1F
      1F7F585858F7353CB3FF777EFFFF3944FFFF0312FFFF464AF7FB8186FFFF7273
      F3F92E2E69A41C1A488808022D6C00000000000000006B3535EB7E3E3EFF7E3E
      3EFF854343FFCF7E7EFF6B3535EB7E3E3EFF7E3E3EFF854343FFCF7E7EFF6B35
      35EB7E3E3EFF7E3E3EFF854343FF000000000F121F5A2F43A4CD002DFFFF002D
      FFFF002DFFFF000E508F00000000000000000000000111142460495CBDDC123B
      FEFF002BF6FF0026DFFF001268AA000000020000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000909
      09475E5D5FEA35375BFF595BF2FF7D81FDFE676AFDFE7A7DFFFF382FABD10000
      011100000000000000000000000000000000000000006B3535EB7E3E3EFF7E3E
      3EFF854343FFCF7E7EFF6B3535EB7E3E3EFF7E3E3EFF854343FFCF7E7EFF6B35
      35EB7E3E3EFF7E3E3EFF854343FF0000000001010219657AD8EB3556F1F8002D
      FFFF000E508F00000000000000000000000000000000000000000F12205B586D
      D3E80834FFFF0029E7F300020E3C000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0008717172F5403F44FB37299FF37E82FFFF7F84FDFE19135C99000000000000
      000000000000000000000000000000000000000000000B05054C6B3535EB6B35
      35EB0B05054C000000000B05054C6B3535EB6B3535EB0B05054C000000000B05
      054C6B3535EB6B3535EB0B05054C0000000000000000000102171A214888000C
      4787000000000000000000000000000000000000000000000000000000000203
      0628010D498900020E3C00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000001000000008000000000101031C0000000200000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000001000015120407579E213EFF12040757010000150000
      0000000000000000000000000000000000000000000000000000000000000000
      0000040202302E17179B592C2CD77E3E3EFF7E3E3EFF592C2CD72E17179B0402
      0230000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000100000
      0014000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000100001512040757DD2F58FF9E213EFF9E213EFF120407570100
      00150000000000000000000000000000000000000000000000000000000C3118
      189F7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF3118189F0000000C000000000000000000000000120B0B4C5D3838AB0000
      000C000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000B0B0B6C3F3F3FFF1414
      148F000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000B020446DD2F58FFDD2F58FFDD2F58FF9E213EFF9E213EFF0B02
      044600000000000000000000000000000000000000000000000C492424C37E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF492424C30000000C000000000603032CBB7272F3CF7E7EFF8350
      50CB010101180000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000A585858D73F3F3FFF2626
      26C7000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000DD2F58FFDD2F58FFDD2F58FFDD2F58FFDD2F58FF0B0204460100
      001500000000000000000000000000000000000000003118189F7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF3118189F0000000036212183CF7E7EFFCF7E7EFFCF7E
      7EFFAA6767E70704043000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000024B4B4BC54B4B4BFC3D3D
      3DFB000000080000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000010000150B02
      0446010000150000000000000000DD2F58FF9E213EFF0B020446000000000000
      0000010000150B0204460100001500000000040202307E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF040202300000000022151568C87A7AFBCF7E
      7EFFCF7E7EFFBB7272F3140C0C50000000000000000000000000000000000000
      00000000000000000000000000000000000000000000393939AB434343DE3F3F
      3FFF04040440000000000000000000000000000000000133017D058604CC07A9
      06E4069D05DE026604AC00040023000000000000000001000015120407579E21
      3EFF0B0204460000000000000000DD2F58FF9E213EFF0B020446000000000000
      00000B0204469E213EFF12040757010000152E17179B7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF2E17179B0000000000000000100A0A48BB72
      72F3CF7E7EFFCF7E7EFFC87A7AFB2D1C1C780000000000000000000000000000
      000000000000000000000000000000000000000000001D1D1D7B454545CD3F3F
      3FFF0E0E0E78000000000000000000010013078704D20EBC02FF10D203FF10D6
      03FF09D806FF0FAF00FF026504AB000000000100001512040757DD2F58FF9E21
      3EFF120407570B0204460B020446DD2F58FF9E213EFF120407570B0204460B02
      0446DD2F58FF9E213EFF9E213EFF12040757592C2CD77E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF592C2CD70000000000000000000000000503
      03289E6060DFCF7E7EFFCF7E7EFFCF7E7EFF4C2E2E9B00000004000000000000
      0000000000000000000000000000000000000000000003030329555555D64040
      40FF244227D600250168076001B910A700FB0DC303FF13F303FB20FF00FF20FF
      00FF1CEB00F50AD305FF079404DB000000000B020446DD2F58FFDD2F58FF9E21
      3EFF9E213EFF9E213EFF9E213EFFDD2F58FF9E213EFF9E213EFF9E213EFF9E21
      3EFFDD2F58FFDD2F58FF9E213EFF9E213EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF0000000000000000000000000000
      000001010118794949C3CF7E7EFFCF7E7EFFCF7E7EFF744646BF000000100000
      00000000000000000000000000000000000000000000000000004D4D4DC84747
      47FF3B4A3CFE09CF06FF0AD105FF0FF406FF16E401F220FF00FF20FF00FF20FF
      00FF20FF00FF0FE404FF0BB704F600000000DD2F58FFDD2F58FFDD2F58FFDD2F
      58FFDD2F58FFDD2F58FFDD2F58FFDD2F58FFDD2F58FFDD2F58FFDD2F58FFDD2F
      58FFDD2F58FFDD2F58FFDD2F58FF120407577E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF0000000000000000000000000000
      00000000000000000008543333A3CF7E7EFFCF7E7EFFCF7E7EFF935959D70503
      03280000000000000000000000000000000000000000000000002F2F2F9C4A4C
      4AEC548B4CFF3AD42CEE1AE500F220FF00FF20FF00FF20FF00FF20FF00FF20FF
      00FF20FF00FF10EA04FC0CBE03FF0001001000000000DD2F58FFDD2F58FF9E21
      3EFF0B0204460000000000000000DD2F58FF9E213EFF0B020446000000000000
      0000DD2F58FFDD2F58FF1204075701000015592C2CD77E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF592C2CD70000000000000000000000000000
      000000000000000000000000000034202080CF7E7EFFCF7E7EFFCF7E7EFFB06B
      6BEB0D08084000000000000000000000000000000000000000000E0E0E574B4B
      4BD64DBC3EFF91FF83FF2AFF0AFF20FF00FF20FF00FF20FF00FF20FF00FF20FF
      00FF20FF00FF10D503EB0DB802FF0013004C0000000000000000DD2F58FF0B02
      0446010000150000000000000000DD2F58FF9E213EFF0B020446000000000000
      0000DD2F58FF0B02044601000015000000002C1515977E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF2C1515970000000000000000000000000000
      000000000000000000000000000000000000180F0F58C27676F7CF7E7EFFCF7E
      7EFFC87A7AFB1D121260000000000000000000000000000000000101011E5656
      56D841673CFF89FB7BFE4DFF34FF20FF00FF20FF00FF20FF00FF20FF00FF20FF
      00FF22E50AF21CDE1FEE1CCF16FF0351039E0000000000000000000000000000
      000000000000010000150B020446DD2F58FF9E213EFF120407570B0204460100
      001500000000000000000000000000000000040202307E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF040202300000000000000000000000000000
      0000000000000000000000000000000000000000000009060638AA6767E7CF7E
      7EFFCF7E7EFFCF7E7EFF3A232387000000000000000000000000000000004444
      44BE4C4C4CFF76E467FB89FF78FF27FF08FF20FF00FF20FF00FF23EB0FF567FF
      5BFF86FF7AFF82FF77FF61F459FF0253039B0000000000000000000000000000
      0000000000000B0204469E213EFFDD2F58FF9E213EFF9E213EFF9E213EFF0B02
      044600000000000000000000000000000000000000002C1515977E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF7E3E3EFF2C151597000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000030202208D56
      56D3CF7E7EFFCF7E7EFFCF7E7EFF482C2C970000000000000000000000001F1F
      1F7F585858F744B335FF88FF77FF51FF39FF23FF03FF56F746FB8EFF81FF7DF3
      72F931692EA41B481A88022D056C000000000000000000000000000000000000
      000000000000DD2F58FFDD2F58FFDD2F58FFDD2F58FFDD2F58FF120407570100
      0015000000000000000000000000000000000000000000000008492424C37E3E
      3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF7E3E3EFF492424C300000008000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000C6B4141B7CF7E7EFFBB7272F3070404300000000000000000000000000909
      09475D5F5EEA3A5B35FF65F259FF8AFD7DFE74FD67FE87FF7AFF2FAB30D10001
      0011000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DD2F58FFDD2F58FFDD2F58FF12040757010000150000
      0000000000000000000000000000000000000000000000000000000000082C15
      15977E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E3EFF7E3E
      3EFF2C1515970000000800000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000044027278F140C0C50000000000000000000000000000000000000
      0008717271F53F4440FB299F2FF38BFF7EFF8CFD7FFE135C1499000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DD2F58FF0B02044601000015000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000040202302C151597592C2CD77E3E3EFF7E3E3EFF592C2CD72C1515970402
      0230000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000001000000008000000000103011C0000000200000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object dlgSave: TSaveDialog
    DefaultExt = '.json'
    FileName = 'Graph'
    Filter = 'Wegpunktenetz|*.json'
    Left = 257
    Top = 112
  end
  object dlgOpen: TOpenDialog
    Filter = 'Wegpunktenetz|*.json'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 313
    Top = 112
  end
  object tmrUpdate: TTimer
    Enabled = False
    Interval = 20
    OnTimer = tmrUpdateTimer
    Left = 257
    Top = 176
  end
end
