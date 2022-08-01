object fchange_value: Tfchange_value
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'New value'
  ClientHeight = 179
  ClientWidth = 824
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 105
    Width = 824
    Height = 74
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object B_canc: TBitBtn
      Left = 96
      Top = 17
      Width = 105
      Height = 33
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
      OnClick = B_cancClick
    end
    object b_ok: TBitBtn
      Left = 207
      Top = 17
      Width = 105
      Height = 33
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
      OnClick = b_okClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 96
    Height = 105
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object Label1: TLabel
      Left = 21
      Top = 19
      Width = 70
      Height = 13
      Caption = 'New value for '
    end
    object Label2: TLabel
      Left = 21
      Top = 60
      Width = 50
      Height = 13
      Caption = 'New Value'
    end
  end
  object Panel5: TPanel
    Left = 96
    Top = 0
    Width = 720
    Height = 105
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object Panel4: TPanel
      Left = 0
      Top = 16
      Width = 720
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      object E_name_variab: TEdit
        Left = 0
        Top = 0
        Width = 720
        Height = 21
        Align = alTop
        TabOrder = 0
        Text = 'E_name_variab'
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 57
      Width = 720
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 1
      object E_valueVariab: TEdit
        Left = 0
        Top = 0
        Width = 720
        Height = 21
        Align = alTop
        TabOrder = 0
        Text = 'E_valueVariab'
      end
    end
    object Panel6: TPanel
      Left = 0
      Top = 0
      Width = 720
      Height = 16
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 2
    end
  end
  object Panel7: TPanel
    Left = 816
    Top = 0
    Width = 8
    Height = 105
    Align = alRight
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 3
  end
end
