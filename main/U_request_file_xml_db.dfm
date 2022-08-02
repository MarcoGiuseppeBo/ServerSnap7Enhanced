object F_ask_name_file_db_xml: TF_ask_name_file_db_xml
  Left = 0
  Top = 0
  Caption = 'Insert file from plc export / xml file definition'
  ClientHeight = 139
  ClientWidth = 723
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label8: TLabel
    Left = 8
    Top = 35
    Width = 80
    Height = 13
    Caption = 'DB/XML input file'
  end
  object Edit_DB: TEdit
    Left = 112
    Top = 30
    Width = 513
    Height = 21
    TabOrder = 0
  end
  object B_Search_DB: TButton
    Left = 640
    Top = 28
    Width = 75
    Height = 25
    Caption = 'Search'
    TabOrder = 1
    OnClick = B_Search_DBClick
  end
  object B_cancel: TBitBtn
    Left = 528
    Top = 88
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
    OnClick = B_cancelClick
  end
  object B_ok: TBitBtn
    Left = 640
    Top = 88
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 3
    OnClick = B_okClick
  end
  object FileOpenDialog_DB: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Siemens DB file'
        FileMask = '*.db'
      end
      item
        DisplayName = 'File xml definition'
        FileMask = '*.xml'
      end>
    Options = []
    Left = 415
    Top = 24
  end
end
