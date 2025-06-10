object FormPopup: TFormPopup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FormPopup'
  ClientHeight = 729
  ClientWidth = 356
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxWVBrowser: TGroupBox
    Left = 0
    Top = 0
    Width = 356
    Height = 140
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alTop
    Caption = 'WVBrowser'
    TabOrder = 0
    object GroupBoxWVBrowserWithClass: TGroupBox
      Left = 2
      Top = 15
      Width = 173
      Height = 123
      Align = alLeft
      Caption = 'Classe Modal'
      TabOrder = 0
      object BtnWVBrowserClassChainableTest: TButton
        Left = 22
        Top = 39
        Width = 123
        Height = 25
        Caption = 'Chainable'
        TabOrder = 0
        OnClick = BtnWVBrowserClassChainableTestClick
      end
      object BtnWVBrowserClassPropertiesTest: TButton
        Left = 22
        Top = 70
        Width = 123
        Height = 25
        Caption = 'Properties'
        TabOrder = 1
        OnClick = BtnWVBrowserClassPropertiesTestClick
      end
    end
    object GroupBoxWVBrowserWithInterface: TGroupBox
      Left = 181
      Top = 15
      Width = 173
      Height = 123
      Align = alRight
      Caption = 'Interface Non Modal'
      TabOrder = 1
      object BtnWVBrowserInterfaceChainableTest: TButton
        Left = 27
        Top = 40
        Width = 123
        Height = 25
        Caption = 'Chainable'
        TabOrder = 0
        OnClick = BtnWVBrowserInterfaceChainableTestClick
      end
      object BtnWVBrowserInterfacePropertiesTest: TButton
        Left = 27
        Top = 71
        Width = 123
        Height = 25
        Caption = 'Properties'
        TabOrder = 1
        OnClick = BtnWVBrowserInterfacePropertiesTestClick
      end
    end
  end
  object GroupBoxMessageReceiver: TGroupBox
    Left = 0
    Top = 350
    Width = 356
    Height = 140
    Align = alTop
    Caption = 'Message Receiver'
    TabOrder = 1
    object MemoMessageReceiver: TMemo
      Left = 2
      Top = 15
      Width = 352
      Height = 123
      Align = alClient
      TabOrder = 0
    end
  end
  object GroupBoxMessageSender: TGroupBox
    Left = 0
    Top = 140
    Width = 356
    Height = 210
    Align = alTop
    Caption = 'Message Sender'
    TabOrder = 2
    object MemoMessageSender: TMemo
      Left = 2
      Top = 15
      Width = 352
      Height = 123
      Align = alTop
      TabOrder = 0
    end
    object BtnMessageSenderByProperty: TButton
      Left = 202
      Top = 162
      Width = 123
      Height = 25
      Caption = 'Send By Property'
      TabOrder = 1
      OnClick = BtnMessageSenderByPropertyClick
    end
    object BtnMessageSenderByChainable: TButton
      Left = 24
      Top = 160
      Width = 123
      Height = 25
      Caption = 'Send By Chainable'
      TabOrder = 2
      OnClick = BtnMessageSenderByChainableClick
    end
  end
  object GroupBoxWindowAndSubWindow: TGroupBox
    Left = 0
    Top = 490
    Width = 356
    Height = 240
    Align = alTop
    Caption = 'Window And SubWindow'
    TabOrder = 3
    object Memolog: TMemo
      Left = 2
      Top = 15
      Width = 352
      Height = 123
      Align = alTop
      TabOrder = 0
    end
    object BtnCreatePopupHtml: TButton
      Left = 208
      Top = 197
      Width = 123
      Height = 25
      Caption = 'Create Popup HTML'
      TabOrder = 1
      OnClick = BtnCreatePopupHtmlClick
    end
    object BtnCreateMainBrowser: TButton
      Left = 24
      Top = 158
      Width = 123
      Height = 25
      Caption = 'Create Main Browser'
      TabOrder = 2
      OnClick = BtnCreateMainBrowserClick
    end
    object BtnCreatePopup: TButton
      Left = 208
      Top = 158
      Width = 123
      Height = 25
      Caption = 'Create Popup'
      TabOrder = 3
      OnClick = BtnCreatePopupClick
    end
    object BtnCreateAdvPopup: TButton
      Left = 24
      Top = 189
      Width = 123
      Height = 25
      Caption = 'Create Adv Popup'
      TabOrder = 4
      OnClick = BtnCreateAdvPopupClick
    end
  end
end
