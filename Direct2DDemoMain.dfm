object Direct2DDemoMainForm: TDirect2DDemoMainForm
  Left = 2111
  Top = 115
  Caption = 'Direct2D Demo'
  ClientHeight = 459
  ClientWidth = 515
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DisplaySplitter: TSplitter
    Left = 0
    Top = 341
    Width = 515
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = 60
    ExplicitTop = 241
    ExplicitWidth = 401
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 515
    Height = 341
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    object AcceleratedPaintPanel1: TAcceleratedPaintPanel
      Left = 1
      Top = 1
      Width = 408
      Height = 339
      Align = alClient
      ParentBackground = False
      TabOrder = 0
      OnClick = AcceleratedPaintPanel1Click
      OnPaint = AcceleratedPaintBox1Paint
    end
    object RightPanel: TPanel
      Left = 409
      Top = 1
      Width = 105
      Height = 339
      Align = alRight
      TabOrder = 1
      object LoadImageButton: TButton
        Left = 16
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Load image'
        TabOrder = 0
        OnClick = LoadImageButtonClick
      end
      object ZoomOutButton: TButton
        Left = 16
        Top = 92
        Width = 75
        Height = 25
        Caption = 'Zoom Out'
        TabOrder = 1
        OnClick = ZoomOutButtonClick
      end
      object ZoomInButton: TButton
        Left = 16
        Top = 123
        Width = 75
        Height = 25
        Caption = 'Zoom In'
        TabOrder = 2
        OnClick = ZoomInButtonClick
      end
      object PanLeftButton: TButton
        Left = 16
        Top = 154
        Width = 75
        Height = 25
        Caption = 'Pan Left'
        TabOrder = 3
        OnClick = PanLeftButtonClick
      end
      object PanRightButton: TButton
        Left = 16
        Top = 185
        Width = 75
        Height = 25
        Caption = 'Pan Right'
        TabOrder = 4
        OnClick = PanRightButtonClick
      end
      object PanUpButton: TButton
        Left = 16
        Top = 215
        Width = 75
        Height = 25
        Caption = 'Pan Up'
        TabOrder = 5
        OnClick = PanUpButtonClick
      end
      object PanDownButton: TButton
        Left = 16
        Top = 245
        Width = 75
        Height = 25
        Caption = 'Pan Down'
        TabOrder = 6
        OnClick = PanDownButtonClick
      end
      object RotateCWButton: TButton
        Left = 16
        Top = 64
        Width = 75
        Height = 25
        Caption = 'Rotate CW'
        TabOrder = 7
        OnClick = RotateCWButtonClick
      end
      object FlipHorizButton: TButton
        Left = 16
        Top = 276
        Width = 75
        Height = 25
        Caption = 'Flip H'
        TabOrder = 8
        OnClick = FlipHorizButtonClick
      end
      object FlipVertButton: TButton
        Left = 16
        Top = 307
        Width = 75
        Height = 25
        Caption = 'Flip V'
        TabOrder = 9
        OnClick = FlipVertButtonClick
      end
    end
  end
  object DisplayMemo: TMemo
    Left = 0
    Top = 345
    Width = 515
    Height = 114
    Align = alBottom
    TabOrder = 1
  end
end
