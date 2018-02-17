object fGraph: TfGraph
  Left = 216
  Top = 178
  BorderStyle = bsNone
  Caption = 'fGraph'
  ClientHeight = 514
  ClientWidth = 699
  Color = clSkyBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ptop: TPanel
    Left = 0
    Top = 0
    Width = 699
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    Color = clSkyBlue
    TabOrder = 0
    DesignSize = (
      699
      33)
    object lheader: TLabel
      Left = 0
      Top = 0
      Width = 699
      Height = 33
      Align = alClient
      Alignment = taCenter
      Caption = 'Plotter Graph'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGreen
      Font.Height = -24
      Font.Name = 'Comic Sans MS'
      Font.Style = []
      ParentFont = False
    end
    object lexit: TLabel
      Left = 674
      Top = 8
      Width = 25
      Height = 41
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'X'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Comic Sans MS'
      Font.Style = []
      ParentFont = False
      OnMouseDown = lexitMouseDown
      OnMouseMove = lexitMouseMove
      OnMouseLeave = lexitMouseLeave
    end
    object lmax: TLabel
      Left = 658
      Top = 0
      Width = 15
      Height = 41
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '^'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Comic Sans MS'
      Font.Style = []
      ParentFont = False
      OnMouseDown = lmaxMouseDown
      OnMouseMove = lmaxMouseMove
      OnMouseLeave = lmaxMouseLeave
    end
  end
  object pleft: TPanel
    Left = 0
    Top = 33
    Width = 41
    Height = 440
    Align = alLeft
    BevelOuter = bvNone
    Color = clSkyBlue
    TabOrder = 1
  end
  object pbottom: TPanel
    Left = 0
    Top = 473
    Width = 699
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Color = clSkyBlue
    TabOrder = 2
    object Edit1: TEdit
      Left = 32
      Top = 8
      Width = 217
      Height = 21
      TabOrder = 0
      Text = 'x^2 + x^3'
    end
    object Button1: TButton
      Left = 256
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Evaluate'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object pright: TPanel
    Left = 657
    Top = 33
    Width = 42
    Height = 440
    Align = alRight
    BevelOuter = bvNone
    Color = clSkyBlue
    TabOrder = 3
    DesignSize = (
      42
      440)
    object lmin: TLabel
      Left = 8
      Top = -12
      Width = 26
      Height = 25
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Comic Sans MS'
      Font.Style = []
      ParentFont = False
      OnClick = lminClick
      OnMouseMove = lminMouseMove
      OnMouseLeave = lminMouseLeave
    end
  end
  object pmiddle: TPanel
    Left = 41
    Top = 33
    Width = 616
    Height = 440
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 4
    object iGraph: TImage
      Left = 0
      Top = 0
      Width = 616
      Height = 440
      Align = alClient
      OnClick = iGraphClick
    end
  end
end
