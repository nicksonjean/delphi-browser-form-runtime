object FormFilho: TFormFilho
  Left = 0
  Top = 0
  Caption = 'Janela Filha'
  ClientHeight = 299
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 426
    Height = 57
    Align = alTop
    TabOrder = 0
    ExplicitTop = -6
    object Label1: TLabel
      Left = 16
      Top = 13
      Width = 153
      Height = 13
      Caption = 'Esta '#233' uma janela filha MDI'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Button1: TButton
      Left = 16
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Adicionar Linha'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 119
      Top = 32
      Width = 75
      Height = 17
      Caption = 'Limpar'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 57
    Width = 426
    Height = 242
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 1
    ExplicitTop = 55
  end
end
