unit UnitPopup;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.StrUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.WinXCtrls,

  Vcl.Edge,
  uWVBrowser,

  UtilsLib,
  BrowserTypes,
  EdgeBrowserFormInterface,
  EdgeBrowserFormClass,
  EdgeAdvancedPopupExample,
  WVBrowserFormInterface,
  WVBrowserFormClass,
  WVAdvancedPopupExample
  ;

type
  TBrowserComponentType = (bctEdgeBrowser, bctWVBrowser);

  TBrowserRegistry = record
    EdgePointer: Pointer;
    WVInterfacePointer: Pointer;
    WVInstancePointer: Pointer;
    BrowserType: string;
    Caption: string;
  end;

  TFormPopup = class(TForm)
    GroupBoxComponentSelector: TGroupBox;
    SwitchComponentType: TToggleSwitch;
    GroupBoxWVBrowser: TGroupBox;
    GroupBoxWVBrowserWithClass: TGroupBox;
    BtnWVBrowserClassChainableTest: TButton;
    BtnWVBrowserClassPropertiesTest: TButton;
    GroupBoxWVBrowserWithInterface: TGroupBox;
    BtnWVBrowserInterfaceChainableTest: TButton;
    BtnWVBrowserInterfacePropertiesTest: TButton;
    GroupBoxMessageReceiver: TGroupBox;
    MemoMessageReceiver: TMemo;
    GroupBoxMessageSender: TGroupBox;
    MemoMessageSender: TMemo;
    BtnMessageSenderByProperty: TButton;
    BtnMessageSenderByChainable: TButton;
    GroupBoxWindowAndSubWindow: TGroupBox;
    Memolog: TMemo;
    BtnCreatePopupHtml: TButton;
    BtnCreateMainBrowser: TButton;
    BtnCreatePopup: TButton;
    BtnCreateAdvPopup: TButton;
    procedure BtnWVBrowserInterfaceChainableTestClick(Sender: TObject);
    procedure BtnWVBrowserClassPropertiesTestClick(Sender: TObject);
    procedure BtnWVBrowserClassChainableTestClick(Sender: TObject);
    procedure BtnWVBrowserInterfacePropertiesTestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnMessageSenderByPropertyClick(Sender: TObject);
    procedure BtnMessageSenderByChainableClick(Sender: TObject);
    procedure BtnCreateMainBrowserClick(Sender: TObject);
    procedure BtnCreatePopupClick(Sender: TObject);
    procedure BtnCreatePopupHtmlClick(Sender: TObject);
    procedure BtnCreateAdvPopupClick(Sender: TObject);
    procedure SwitchComponentTypeClick(Sender: TObject);
  private
    { Private declarations }
    FCurrentComponentType: TBrowserComponentType;
    FMainEdgeBrowserRef: Pointer;
    FMainWVBrowserRef: Pointer;
    FPopupEdgeBrowserRef: Pointer;
    FPopupWVBrowserRef: Pointer;
    FPopupManager: TEdgeAdvancedPopupManager;
    FWVPopupManager: TWVAdvancedPopupManager;

    FMainBrowserRegistry: TBrowserRegistry;
    FPopupBrowserRegistry: TBrowserRegistry;

    procedure LogMessage(const AMessage: string);
    procedure OnMainBrowserMessage(Sender: TObject; const Message: string);
    procedure OnPopupBrowserMessage(Sender: TObject; const Message: string);
    procedure OnBrowserWindowClosed(Sender: TObject);
    procedure OnMessageReceived(ASender: TObject; const AMessage: string);
    procedure UpdateComponentSelection;
    function GetUniqueID: string;
    function IsUsingEdgeBrowser: Boolean;
    function IsUsingWVBrowser: Boolean;
    function GetMainEdgeBrowser: TCustomFormEdgeBrowser;
    function GetMainWVBrowser: IWVBrowserForm;
    function GetPopupEdgeBrowser: TCustomFormEdgeBrowser;
    function GetPopupWVBrowser: IWVBrowserForm;
    procedure RegisterMainBrowser(EdgePtr: Pointer; WVInterfacePtr: Pointer; WVInstancePtr: Pointer; const Caption: string);
    procedure RegisterPopupBrowser(EdgePtr: Pointer; WVInterfacePtr: Pointer; WVInstancePtr: Pointer; const Caption: string);
    procedure ClearBrowserRegistries;
    procedure ClearMainBrowserRegistry;
    procedure ClearPopupBrowserRegistry;
  public
    { Public declarations }
    procedure ProcessarJSON(JSONString: String);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FormPopup: TFormPopup;

implementation

{$R *.dfm}

constructor TFormPopup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCurrentComponentType := bctEdgeBrowser;

  FMainEdgeBrowserRef := nil;
  FMainWVBrowserRef := nil;
  FPopupEdgeBrowserRef := nil;
  FPopupWVBrowserRef := nil;
  FPopupManager := nil;
  FWVPopupManager := nil;

  ClearBrowserRegistries;
end;

destructor TFormPopup.Destroy;
begin
  FMainEdgeBrowserRef := nil;
  FMainWVBrowserRef := nil;
  FPopupEdgeBrowserRef := nil;
  FPopupWVBrowserRef := nil;

  if Assigned(FPopupManager) then
    FPopupManager.Free;
  if Assigned(FWVPopupManager) then
    FWVPopupManager.Free;

  inherited;
end;

function TFormPopup.GetMainEdgeBrowser: TCustomFormEdgeBrowser;
begin
  Result := TCustomFormEdgeBrowser(FMainEdgeBrowserRef);
end;

function TFormPopup.GetMainWVBrowser: IWVBrowserForm;
begin
  Result := IWVBrowserForm(FMainWVBrowserRef);
end;

function TFormPopup.GetPopupEdgeBrowser: TCustomFormEdgeBrowser;
begin
  Result := TCustomFormEdgeBrowser(FPopupEdgeBrowserRef);
end;

function TFormPopup.GetPopupWVBrowser: IWVBrowserForm;
begin
  Result := IWVBrowserForm(FPopupWVBrowserRef);
end;

procedure TFormPopup.RegisterMainBrowser(EdgePtr: Pointer; WVInterfacePtr: Pointer; WVInstancePtr: Pointer; const Caption: string);
begin
  FMainBrowserRegistry.EdgePointer := EdgePtr;
  FMainBrowserRegistry.WVInterfacePointer := WVInterfacePtr;
  FMainBrowserRegistry.WVInstancePointer := WVInstancePtr;
  FMainBrowserRegistry.BrowserType := 'MAIN';
  FMainBrowserRegistry.Caption := Caption;

  LogMessage('Main Browser registrado - Edge: ' + IntToHex(NativeInt(EdgePtr), 8) +
             ', WVInterface: ' + IntToHex(NativeInt(WVInterfacePtr), 8) +
             ', WVInstance: ' + IntToHex(NativeInt(WVInstancePtr), 8));
end;

procedure TFormPopup.RegisterPopupBrowser(EdgePtr: Pointer; WVInterfacePtr: Pointer; WVInstancePtr: Pointer; const Caption: string);
begin
  FPopupBrowserRegistry.EdgePointer := EdgePtr;
  FPopupBrowserRegistry.WVInterfacePointer := WVInterfacePtr;
  FPopupBrowserRegistry.WVInstancePointer := WVInstancePtr;
  FPopupBrowserRegistry.BrowserType := 'POPUP';
  FPopupBrowserRegistry.Caption := Caption;

  LogMessage('Popup Browser registrado - Edge: ' + IntToHex(NativeInt(EdgePtr), 8) +
             ', WVInterface: ' + IntToHex(NativeInt(WVInterfacePtr), 8) +
             ', WVInstance: ' + IntToHex(NativeInt(WVInstancePtr), 8));
end;

procedure TFormPopup.ClearBrowserRegistries;
begin
  FMainBrowserRegistry.EdgePointer := nil;
  FMainBrowserRegistry.WVInterfacePointer := nil;
  FMainBrowserRegistry.WVInstancePointer := nil;
  FMainBrowserRegistry.BrowserType := '';
  FMainBrowserRegistry.Caption := '';

  FPopupBrowserRegistry.EdgePointer := nil;
  FPopupBrowserRegistry.WVInterfacePointer := nil;
  FPopupBrowserRegistry.WVInstancePointer := nil;
  FPopupBrowserRegistry.BrowserType := '';
  FPopupBrowserRegistry.Caption := '';
end;

procedure TFormPopup.ClearMainBrowserRegistry;
begin
  FMainBrowserRegistry.EdgePointer := nil;
  FMainBrowserRegistry.WVInterfacePointer := nil;
  FMainBrowserRegistry.WVInstancePointer := nil;
  FMainBrowserRegistry.BrowserType := '';
  FMainBrowserRegistry.Caption := '';
end;

procedure TFormPopup.ClearPopupBrowserRegistry;
begin
  FPopupBrowserRegistry.EdgePointer := nil;
  FPopupBrowserRegistry.WVInterfacePointer := nil;
  FPopupBrowserRegistry.WVInstancePointer := nil;
  FPopupBrowserRegistry.BrowserType := '';
  FPopupBrowserRegistry.Caption := '';
end;

procedure TFormPopup.FormCreate(Sender: TObject);
begin
  SwitchComponentType.StateCaptions.CaptionOff := 'EdgeBrowser';

  MemoMessageSender.Lines.Text := ' { ' + sLineBreak
  + '   "operation": "putMessage", ' + sLineBreak
  + '   "data":{' + sLineBreak
  + '      "text": "Enviou para o WebView"' + sLineBreak
  + '    }' + sLineBreak
  + ' } ';

  memoLog.Lines.Add('=== Exemplo de Uso do Browser Components ===');
  memoLog.Lines.Add('1. Selecione o tipo de componente (EdgeBrowser/WVBrowser)');
  memoLog.Lines.Add('2. Clique em "Criar Browser Principal"');
  memoLog.Lines.Add('3. Depois clique em "Criar Popup"');
  memoLog.Lines.Add('');

  UpdateComponentSelection;
end;

procedure TFormPopup.SwitchComponentTypeClick(Sender: TObject);
begin
  FMainEdgeBrowserRef := nil;
  FMainWVBrowserRef := nil;
  FPopupEdgeBrowserRef := nil;
  FPopupWVBrowserRef := nil;
  btnCreatePopup.Enabled := False;

  ClearBrowserRegistries;

  if SwitchComponentType.State = tssOn then
    FCurrentComponentType := bctWVBrowser
  else
    FCurrentComponentType := bctEdgeBrowser;

  UpdateComponentSelection;

  LogMessage('Componente alterado para: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
end;

procedure TFormPopup.UpdateComponentSelection;
begin
  if IsUsingEdgeBrowser then
  begin
    SwitchComponentType.State := tssOff;
    SwitchComponentType.StateCaptions.CaptionOff := 'EdgeBrowser';
    GroupBoxWVBrowser.Caption := 'EdgeBrowser Components';
    GroupBoxWVBrowserWithClass.Caption := 'EdgeBrowser - Classe Non Modal';
    GroupBoxWVBrowserWithInterface.Caption := 'EdgeBrowser - Interface Non Modal';
  end
  else
  begin
    SwitchComponentType.State := tssOn;
    SwitchComponentType.StateCaptions.CaptionOn := 'WVBrowser';
    GroupBoxWVBrowser.Caption := 'WVBrowser Components';
    GroupBoxWVBrowserWithClass.Caption := 'WVBrowser - Classe Non Modal';
    GroupBoxWVBrowserWithInterface.Caption := 'WVBrowser - Interface Non Modal';
  end;
end;

function TFormPopup.GetUniqueID: string;
begin
  if IsUsingWVBrowser then
    Result := 'WVID' + IntToStr(Random(4) + 1)
  else
    Result := 'EdgeID' + IntToStr(Random(4) + 1);
end;

function TFormPopup.IsUsingEdgeBrowser: Boolean;
begin
  Result := FCurrentComponentType = bctEdgeBrowser;
end;

function TFormPopup.IsUsingWVBrowser: Boolean;
begin
  Result := FCurrentComponentType = bctWVBrowser;
end;

procedure TFormPopup.LogMessage(const AMessage: string);
begin
  memoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMessage);
end;

procedure TFormPopup.OnBrowserWindowClosed(Sender: TObject);
var
  SenderAddress: NativeInt;
  IsMainFound, IsPopupFound: Boolean;
begin
  LogMessage('=== OnBrowserWindowClosed INICIADO ===');
  SenderAddress := NativeInt(Sender);
  LogMessage('Sender: ' + Sender.ClassName + ' - Endereço: ' + IntToHex(SenderAddress, 8));

  IsMainFound := False;
  IsPopupFound := False;

  if IsUsingEdgeBrowser then
  begin
    if Pointer(Sender) = FMainEdgeBrowserRef then
    begin
      FMainEdgeBrowserRef := nil;
      btnCreatePopup.Enabled := False;
      ClearBrowserRegistries;
      LogMessage('✓ Main EdgeBrowser fechado - botão Create Popup desabilitado');
      LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
      Exit;
    end;

    if Pointer(Sender) = FPopupEdgeBrowserRef then
    begin
      FPopupEdgeBrowserRef := nil;
      ClearPopupBrowserRegistry;
      LogMessage('✓ Popup EdgeBrowser fechado');
      LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
      Exit;
    end;
  end
  else
  begin
    LogMessage('--- Verificando WVBrowser via Registry ---');

    LogMessage('Verificando Main - Registry WVInterface: ' + IntToHex(NativeInt(FMainBrowserRegistry.WVInterfacePointer), 8));
    LogMessage('Verificando Main - Registry WVInstance: ' + IntToHex(NativeInt(FMainBrowserRegistry.WVInstancePointer), 8));

    if (FMainBrowserRegistry.WVInterfacePointer = Pointer(Sender)) or (FMainBrowserRegistry.WVInstancePointer = Pointer(Sender)) then
    begin
      LogMessage('✓ Main WVBrowser identificado pelo registry');
      FMainWVBrowserRef := nil;
      ClearMainBrowserRegistry;
      btnCreatePopup.Enabled := False;
      LogMessage('✓ Main WVBrowser fechado - botão Create Popup desabilitado');
      LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
      Exit;
    end;

    LogMessage('Verificando Popup - Registry WVInterface: ' + IntToHex(NativeInt(FPopupBrowserRegistry.WVInterfacePointer), 8));
    LogMessage('Verificando Popup - Registry WVInstance: ' + IntToHex(NativeInt(FPopupBrowserRegistry.WVInstancePointer), 8));

    if (FPopupBrowserRegistry.WVInterfacePointer = Pointer(Sender)) or (FPopupBrowserRegistry.WVInstancePointer = Pointer(Sender)) then
    begin
      LogMessage('✓ Popup WVBrowser identificado pelo registry');
      FPopupWVBrowserRef := nil;
      ClearPopupBrowserRegistry;
      LogMessage('✓ Popup WVBrowser fechado');
      LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
      Exit;
    end;

    LogMessage('--- Método registry direto falhou, tentando busca ampliada ---');

    if Assigned(FMainWVBrowserRef) then
    begin
      try
        if Assigned(IWVBrowserForm(FMainWVBrowserRef).Instance) then
          LogMessage('Main WV Interface ainda válida - Instance: ' + IntToHex(NativeInt(IWVBrowserForm(FMainWVBrowserRef).Instance), 8));
      except
        on E: Exception do
        begin
          LogMessage('Main WV Interface inválida (provavelmente fechada): ' + E.Message);
          FMainWVBrowserRef := nil;
          ClearMainBrowserRegistry;
          btnCreatePopup.Enabled := False;
          LogMessage('✓ Main WVBrowser fechado (detectado por interface inválida) - botão Create Popup desabilitado');
          LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
          Exit;
        end;
      end;
    end;

    if Assigned(FPopupWVBrowserRef) and not IsMainFound then
    begin
      try
        if Assigned(IWVBrowserForm(FPopupWVBrowserRef).Instance) then
          LogMessage('Popup WV Interface ainda válida - Instance: ' + IntToHex(NativeInt(IWVBrowserForm(FPopupWVBrowserRef).Instance), 8));
      except
        on E: Exception do
        begin
          LogMessage('Popup WV Interface inválida (provavelmente fechada): ' + E.Message);
          FPopupWVBrowserRef := nil;
          ClearPopupBrowserRegistry;
          LogMessage('✓ Popup WVBrowser fechado (detectado por interface inválida)');
          LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
          Exit;
        end;
      end;
    end;

    if not IsMainFound and not IsPopupFound then
    begin
      LogMessage('--- Último recurso: verificação por ordem de criação ---');

      if Assigned(FPopupWVBrowserRef) then
      begin
        LogMessage('Assumindo que é o Popup (ainda existe referência do popup)');
        FPopupWVBrowserRef := nil;
        ClearPopupBrowserRegistry;
        LogMessage('✓ Popup WVBrowser fechado (por eliminação)');
      end
      else if Assigned(FMainWVBrowserRef) then
      begin
        LogMessage('Assumindo que é o Main (popup já foi fechado)');
        FMainWVBrowserRef := nil;
        ClearMainBrowserRegistry;
        btnCreatePopup.Enabled := False;
        LogMessage('✓ Main WVBrowser fechado (por eliminação) - botão Create Popup desabilitado');
      end
      else
        LogMessage('⚠️ Todas as referências já foram limpas - evento duplicado ou janela externa');
    end;
  end;

  LogMessage('=== OnBrowserWindowClosed FINALIZADO ===');
end;

procedure TFormPopup.OnMessageReceived(ASender: TObject; const AMessage: string);
begin
  MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(AMessage));
end;

procedure TFormPopup.BtnWVBrowserClassChainableTestClick(Sender: TObject);
var
  BrowserTag: String;
begin
  BrowserTag := GetUniqueID;

  if IsUsingEdgeBrowser then
  begin
    (TCustomFormEdgeBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
      .SetCaption('EdgeBrowser - Chainable Test')
      .SetUniqueIdentifier(BrowserTag)
      .SetWidth(2048)
      .SetHeight(1800)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetResizable(true)
      .SetMovable(true)
      .SetCookie('CookieName', 'CookieValue', 'CookieDomain')
      .SetMessageReceiver(procedure(Sender: TObject; const MessageText: string)
      begin
        MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
        ProcessarJSON(MessageText);
      end) as TCustomFormEdgeBrowser).Show;
  end
  else
  begin
    (TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
      .SetCaption('WVBrowser - Chainable Test')
      .SetUniqueIdentifier(BrowserTag)
      .SetWidth(2048)
      .SetHeight(1800)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetResizable(true)
      .SetMovable(true)
      .SetCookie('CookieName', 'CookieValue', 'CookieDomain')
      .SetMessageReceiver(procedure(Sender: TObject; const MessageText: string)
      begin
        MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
        ProcessarJSON(MessageText);
      end) as IWVBrowserForm).Show;
  end;

  LogMessage('Browser criado via Chainable - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
end;

procedure TFormPopup.BtnWVBrowserClassPropertiesTestClick(Sender: TObject);
var
  BrowserTag: String;
  EdgeBrowser: TCustomFormEdgeBrowser;
  WVBrowser: TCustomFormWVBrowser;
begin
  BrowserTag := GetUniqueID;

  if IsUsingEdgeBrowser then
  begin
    EdgeBrowser := TCustomFormEdgeBrowser.Create;
    EdgeBrowser.URL := 'file:///' + ExtractFilePath(ParamStr(0)) + 'index.html';
    EdgeBrowser.UniqueIdentifier := BrowserTag;
    EdgeBrowser.Caption := 'EdgeBrowser - Properties Test';
    EdgeBrowser.Width := 2048;
    EdgeBrowser.Height := 1800;
    EdgeBrowser.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
    EdgeBrowser.Resizable := true;
    EdgeBrowser.Movable := true;
    EdgeBrowser.CookieName := 'CookieName';
    EdgeBrowser.CookieValue := 'CookieValue';
    EdgeBrowser.CookieDomain := 'CookieDomain';
    EdgeBrowser.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
      ProcessarJSON(MessageText);
    end;
    EdgeBrowser.Show;
  end
  else
  begin
    WVBrowser := TCustomFormWVBrowser.Create;
    WVBrowser.URL := 'file:///' + ExtractFilePath(ParamStr(0)) + 'index.html';
    WVBrowser.Caption := 'WVBrowser - Properties Test';
    WVBrowser.UniqueIdentifier := BrowserTag;
    WVBrowser.Width := 2048;
    WVBrowser.Height := 1800;
    WVBrowser.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
    WVBrowser.Resizable := true;
    WVBrowser.Movable := true;
    WVBrowser.CookieName := 'CookieName';
    WVBrowser.CookieValue := 'CookieValue';
    WVBrowser.CookieDomain := 'CookieDomain';
    WVBrowser.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
      ProcessarJSON(MessageText);
    end;
    WVBrowser.Show;
  end;

  LogMessage('Browser criado via Properties - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
end;

procedure TFormPopup.BtnWVBrowserInterfaceChainableTestClick(Sender: TObject);
var
  BrowserTag: String;
  EdgeBrowser: IEdgeBrowserForm;
  WVBrowser: IWVBrowserForm;
begin
  BrowserTag := GetUniqueID;

  if IsUsingEdgeBrowser then
  begin
      EdgeBrowser := TCustomFormEdgeBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
      .SetCaption('EdgeBrowser - Interface Chainable')
      .SetUniqueIdentifier(BrowserTag)
      .SetWidth(2048)
      .SetHeight(1800)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetResizable(true)
      .SetMovable(true)
      .SetCookie('CookieName', 'CookieValue', 'CookieDomain')
      .SetMessageReceiver(procedure(Sender: TObject; const MessageText: string)
      begin
        MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
        ProcessarJSON(MessageText);
      end);
    EdgeBrowser.Show;
  end
  else
  begin
      WVBrowser := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
      .SetCaption('WVBrowser - Interface Chainable')
      .SetUniqueIdentifier(BrowserTag)
      .SetWidth(2048)
      .SetHeight(1800)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetResizable(true)
      .SetMovable(true)
      .SetCookie('CookieName', 'CookieValue', 'CookieDomain')
      .SetMessageReceiver(procedure(Sender: TObject; const MessageText: string)
      begin
        MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
        ProcessarJSON(MessageText);
      end);
    WVBrowser.Show;
  end;

  LogMessage('Browser criado via Interface Chainable - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
end;

procedure TFormPopup.BtnWVBrowserInterfacePropertiesTestClick(Sender: TObject);
var
  BrowserTag: String;
  EdgeBrowser: IEdgeBrowserForm;
  WVBrowser: IWVBrowserForm;
begin
  BrowserTag := GetUniqueID;

  if IsUsingEdgeBrowser then
  begin
    EdgeBrowser := TCustomFormEdgeBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
    EdgeBrowser.Caption := 'EdgeBrowser - Interface Properties';
    EdgeBrowser.UniqueIdentifier := BrowserTag;
    EdgeBrowser.Width := 2048;
    EdgeBrowser.Height := 1800;
    EdgeBrowser.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
    EdgeBrowser.Resizable := true;
    EdgeBrowser.Movable := true;
    EdgeBrowser.CookieName := 'CookieName';
    EdgeBrowser.CookieValue := 'CookieValue';
    EdgeBrowser.CookieDomain := 'CookieDomain';
    EdgeBrowser.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
      ProcessarJSON(MessageText);
    end;
    EdgeBrowser.Show;
  end
  else
  begin
    WVBrowser := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
    WVBrowser.Caption := 'WVBrowser - Interface Properties';
    WVBrowser.UniqueIdentifier := BrowserTag;
    WVBrowser.Width := 2048;
    WVBrowser.Height := 1800;
    WVBrowser.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
    WVBrowser.Resizable := true;
    WVBrowser.Movable := true;
    WVBrowser.CookieName := 'CookieName';
    WVBrowser.CookieValue := 'CookieValue';
    WVBrowser.CookieDomain := 'CookieDomain';
    WVBrowser.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      MemoMessageReceiver.Lines.Add(TUtils.FormatJSONString(MessageText));
      ProcessarJSON(MessageText);
    end;
    WVBrowser.Show;
  end;

  LogMessage('Browser criado via Interface Properties - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
end;

procedure TFormPopup.BtnCreateAdvPopupClick(Sender: TObject);
begin
  if IsUsingEdgeBrowser then
  begin
    FPopupManager := TEdgeAdvancedPopupManager.Create(Self);
    FPopupManager.CreateMainBrowser;
    LogMessage('EdgeBrowser Advanced Popup Manager criado');
  end
  else
  begin
    FWVPopupManager := TWVAdvancedPopupManager.Create(Self);
    FWVPopupManager.CreateMainBrowser;
    LogMessage('WVBrowser Advanced Popup Manager criado');
  end;
end;

procedure TFormPopup.BtnCreateMainBrowserClick(Sender: TObject);
var
  EdgeBrowser: TCustomFormEdgeBrowser;
  WVBrowser: IWVBrowserForm;
begin
  try
    FMainEdgeBrowserRef := nil;
    FMainWVBrowserRef := nil;
    ClearBrowserRegistries;

    LogMessage('Criando browser principal...');

    if IsUsingEdgeBrowser then
    begin
      EdgeBrowser := TCustomFormEdgeBrowser.Create('https://www.google.com')
        .SetWidth(1000)
        .SetHeight(700)
        .SetCaption('EdgeBrowser Principal', TPositionCaption.Before)
        .SetResizable(True)
        .SetMovable(True)
        .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
        .SetCookie('session_id', '123456789', '.google.com', '/')
        .SetMessageReceiver(OnMainBrowserMessage)
        .SetWindowClosed(OnBrowserWindowClosed);

      FMainEdgeBrowserRef := Pointer(EdgeBrowser);
      RegisterMainBrowser(Pointer(EdgeBrowser), nil, nil, 'EdgeBrowser Principal');
      LogMessage('EdgeBrowser criado - Ref: ' + IntToHex(NativeInt(FMainEdgeBrowserRef), 8));
      EdgeBrowser.Show;
    end
    else
    begin
      WVBrowser := TCustomFormWVBrowser.Create('https://www.google.com')
        .SetWidth(1000)
        .SetHeight(700)
        .SetCaption('WVBrowser Principal', TPositionCaption.Before)
        .SetResizable(True)
        .SetMovable(True)
        .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
        .SetCookie('session_id', '123456789', '.google.com', '/')
        .SetMessageReceiver(OnMainBrowserMessage)
        .SetWindowClosed(OnBrowserWindowClosed);

      FMainWVBrowserRef := Pointer(WVBrowser);
      RegisterMainBrowser(nil, Pointer(WVBrowser), Pointer(WVBrowser.Instance), 'WVBrowser Principal');
      LogMessage('WVBrowser criado - Interface Ref: ' + IntToHex(NativeInt(FMainWVBrowserRef), 8));
      LogMessage('WVBrowser criado - Instance Ref: ' + IntToHex(NativeInt(WVBrowser.Instance), 8));
      WVBrowser.Show;
    end;

    LogMessage('Browser principal criado - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
    btnCreatePopup.Enabled := True;

  except
    on E: Exception do
    begin
      LogMessage('ERRO ao criar browser principal: ' + E.Message);
    end;
  end;
end;

procedure TFormPopup.BtnCreatePopupClick(Sender: TObject);
var
  EdgePopup: TCustomFormEdgeBrowser;
  WVPopup: IWVBrowserForm;
  MainEdge: TCustomFormEdgeBrowser;
  MainWV: IWVBrowserForm;
begin
  try
    if IsUsingEdgeBrowser then
    begin
      MainEdge := GetMainEdgeBrowser;
      if not Assigned(MainEdge) then
      begin
        LogMessage('Primeiro crie o browser principal EdgeBrowser!');
        Exit;
      end;
    end
    else
    begin
      MainWV := GetMainWVBrowser;
      if not Assigned(MainWV) then
      begin
        LogMessage('Primeiro crie o browser principal WVBrowser!');
        Exit;
      end;
    end;

    FPopupEdgeBrowserRef := nil;
    FPopupWVBrowserRef := nil;

    LogMessage('Criando popup...');

    if IsUsingEdgeBrowser then
    begin
      MainEdge := GetMainEdgeBrowser;
      EdgePopup := TCustomFormEdgeBrowser.CreateAsPopup(
        MainEdge.Instance as TEdgeBrowser,
        'https://www.github.com'
      )
        .SetWidth(800)
        .SetHeight(800)
        .SetCaption('EdgeBrowser Popup - GitHub', TPositionCaption.Before)
        .SetResizable(True)
        .SetMovable(True)
        .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
        .SetCookie('popup_session', 'popup_123', '.github.com', '/')
        .SetMessageReceiver(OnPopupBrowserMessage)
        .SetWindowClosed(OnBrowserWindowClosed);

      FPopupEdgeBrowserRef := Pointer(EdgePopup);
      RegisterPopupBrowser(Pointer(EdgePopup), nil, nil, 'EdgeBrowser Popup - GitHub');
      LogMessage('EdgeBrowser Popup criado - Ref: ' + IntToHex(NativeInt(FPopupEdgeBrowserRef), 8));
      EdgePopup.ShowModal;
    end
    else
    begin
      WVPopup := TCustomFormWVBrowser.CreateAsPopup(
        MainWV.Instance as TWVBrowser,
        'https://www.github.com'
      )
        .SetWidth(800)
        .SetHeight(800)
        .SetCaption('WVBrowser Popup - GitHub', TPositionCaption.Before)
        .SetResizable(True)
        .SetMovable(True)
        .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
        .SetCookie('popup_session', 'popup_123', '.github.com', '/')
        .SetMessageReceiver(OnPopupBrowserMessage)
        .SetWindowClosed(OnBrowserWindowClosed);

      FPopupWVBrowserRef := Pointer(WVPopup);
      RegisterPopupBrowser(nil, Pointer(WVPopup), Pointer(WVPopup.Instance), 'WVBrowser Popup - GitHub');
      LogMessage('WVBrowser Popup criado - Interface Ref: ' + IntToHex(NativeInt(FPopupWVBrowserRef), 8));
      LogMessage('WVBrowser Popup criado - Instance Ref: ' + IntToHex(NativeInt(WVPopup.Instance), 8));
      WVPopup.ShowAsModal;
    end;

    LogMessage('Popup criado - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
  except
    on E: Exception do
    begin
      LogMessage('Erro ao criar popup: ' + E.Message);
    end;
  end;
end;

procedure TFormPopup.BtnCreatePopupHtmlClick(Sender: TObject);
var
  HTMLContent: string;
  EdgeBrowser: IEdgeBrowserForm;
  WVBrowser: IWVBrowserForm;
begin
  LogMessage('Criando browser com HTML customizado...');

  HTMLContent :=
    '<!DOCTYPE html>' +
    '<html>' +
    '<head>' +
    '  <title>Conteúdo Personalizado</title>' +
    '  <style>' +
    '    body { font-family: Arial; background: linear-gradient(45deg, #667eea, #764ba2); ' +
    '           color: white; text-align: center; padding: 50px; }' +
    '    .container { background: rgba(255,255,255,0.1); padding: 30px; ' +
    '                border-radius: 15px; backdrop-filter: blur(10px); }' +
    '    button { padding: 15px 30px; background: #fff; color: #333; ' +
    '            border: none; border-radius: 8px; cursor: pointer; font-size: 16px; }' +
    '  </style>' +
    '  <script>' +
    '    function enviarMensagem() {' +
    '      if (window.chrome && window.chrome.webview) {' +
    '        window.chrome.webview.postMessage(''{   "operation": "open-modal",   "payload": {    "name": "pre-cadastro-limite", "context": { "clienteId": "1234567890" }}}'');' +
    '      } else {' +
    '        alert("WebView2 messaging not available");' +
    '      }' +
    '    }' +
    '  </script>' +
    '</head>' +
    '<body>' +
    '  <div class="container">' +
    '    <h1>🎨 Conteúdo HTML Personalizado</h1>' +
    '    <p>Este conteúdo foi injetado diretamente via SetHTMLContent!</p>' +
    '    <p><strong>Tipo de Browser:</strong> ' +
        IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser') + '</p>' +
    '    <p><strong>Data/Hora:</strong> ' + DateTimeToStr(Now) + '</p>' +
    '    <button onclick="enviarMensagem()">📤 Enviar Mensagem</button>' +
    '  </div>' +
    '</body>' +
    '</html>';

  if IsUsingEdgeBrowser then
  begin
    EdgeBrowser := TCustomFormEdgeBrowser.Create
      .SetHTMLContent(HTMLContent)
      .SetWidth(800)
      .SetHeight(800)
      .SetCaption('EdgeBrowser - HTML Personalizado')
      .SetResizable(False)
      .SetMovable(True)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetWindowClosed(OnBrowserWindowClosed)
      .SetMessageReceiver(OnMessageReceived);
    EdgeBrowser.ShowAsModal;
  end
  else
  begin
    WVBrowser := TCustomFormWVBrowser.Create
      .SetHTMLContent(HTMLContent)
      .SetWidth(800)
      .SetHeight(800)
      .SetCaption('WVBrowser - HTML Personalizado')
      .SetResizable(False)
      .SetMovable(True)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetWindowClosed(OnBrowserWindowClosed)
      .SetMessageReceiver(OnMessageReceived);
    WVBrowser.ShowAsModal;
  end;

  LogMessage('Browser com HTML customizado criado - Tipo: ' + IfThen(IsUsingEdgeBrowser, 'EdgeBrowser', 'WVBrowser'));
end;

procedure TFormPopup.OnMainBrowserMessage(Sender: TObject; const Message: string);
var
  MainEdge: TCustomFormEdgeBrowser;
  MainWV: IWVBrowserForm;
begin
  LogMessage('Mensagem do Browser Principal: ' + Message);

  if IsUsingEdgeBrowser then
  begin
    MainEdge := GetMainEdgeBrowser;
    if Assigned(MainEdge) then
      MainEdge.SetMessageSender('{"response": "Mensagem recebida no Delphi!", "timestamp": "' + DateTimeToStr(Now) + '"}');
  end
  else
  begin
    MainWV := GetMainWVBrowser;
    if Assigned(MainWV) then
      MainWV.SetMessageSender('{"response": "Mensagem recebida no Delphi!", "timestamp": "' + DateTimeToStr(Now) + '"}');
  end;
end;

procedure TFormPopup.OnPopupBrowserMessage(Sender: TObject; const Message: string);
var
  PopupEdge: TCustomFormEdgeBrowser;
  PopupWV: IWVBrowserForm;
begin
  LogMessage('Mensagem do Popup: ' + Message);

  if IsUsingEdgeBrowser then
  begin
    PopupEdge := GetPopupEdgeBrowser;
    if Assigned(PopupEdge) then
      PopupEdge.SetMessageSender('{"response": "Popup respondeu!", "timestamp": "' + DateTimeToStr(Now) + '"}');
  end
  else
  begin
    PopupWV := GetPopupWVBrowser;
    if Assigned(PopupWV) then
      PopupWV.SetMessageSender('{"response": "Popup respondeu!", "timestamp": "' + DateTimeToStr(Now) + '"}');
  end;
end;

procedure TFormPopup.ProcessarJSON(JSONString: String);
var
  JSONObject: TJSONObject;
  Operation: string;
  PayloadName: string;
  ClienteId: string;
begin
  JSONObject := nil;
  try
    JSONObject := TJSONObject.ParseJSONValue(JSONString) as TJSONObject;

    if JSONObject <> nil then
    begin
      Operation := JSONObject.GetValue<string>('operation');
      PayloadName := JSONObject.GetValue<string>('payload.name');
      ClienteId := JSONObject.GetValue<string>('payload.context.clienteId');

      LogMessage('Operation: ' + Operation);
      LogMessage('PayloadName: ' + PayloadName);
      LogMessage('ClienteId: ' + ClienteId);
    end;

  finally
    if Assigned(JSONObject) then
      JSONObject.Free;
  end;
end;

procedure TFormPopup.BtnMessageSenderByChainableClick(Sender: TObject);
var
  MessageSent: Boolean;
  EdgeInstance: TCustomFormEdgeBrowser;
  WVInstance: IWVBrowserForm;
begin
  MessageSent := False;

  if IsUsingEdgeBrowser then
  begin
    EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID1');
    if not Assigned(EdgeInstance) then
      EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID2');
    if not Assigned(EdgeInstance) then
      EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID3');
    if not Assigned(EdgeInstance) then
      EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID4');

    if Assigned(EdgeInstance) then
    begin
      EdgeInstance.OnMessageSender := MemoMessageSender.Text;
      MessageSent := True;
      LogMessage('Mensagem enviada via Chainable para EdgeBrowser ID: ' + EdgeInstance.UniqueIdentifier);
    end;
  end
  else
  begin
    WVInstance := TCustomFormWVBrowser.FindInstance('WVID1');
    if not Assigned(WVInstance) then
      WVInstance := TCustomFormWVBrowser.FindInstance('WVID2');
    if not Assigned(WVInstance) then
      WVInstance := TCustomFormWVBrowser.FindInstance('WVID3');
    if not Assigned(WVInstance) then
      WVInstance := TCustomFormWVBrowser.FindInstance('WVID4');

    if Assigned(WVInstance) then
    begin
      WVInstance.OnMessageSender := MemoMessageSender.Text;
      MessageSent := True;
      LogMessage('Mensagem enviada via Chainable para WVBrowser ID: ' + WVInstance.UniqueIdentifier);
    end;
  end;

  if not MessageSent then
    LogMessage('Nenhuma instância encontrada para envio de mensagem. Crie um browser primeiro usando os botões de teste.');
end;

procedure TFormPopup.BtnMessageSenderByPropertyClick(Sender: TObject);
var
  MessageSent: Boolean;
  EdgeInstance: TCustomFormEdgeBrowser;
  WVInstance: IWVBrowserForm;
begin
  MessageSent := False;

  if IsUsingEdgeBrowser then
  begin
    EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID1');
    if not Assigned(EdgeInstance) then
      EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID2');
    if not Assigned(EdgeInstance) then
      EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID3');
    if not Assigned(EdgeInstance) then
      EdgeInstance := TCustomFormEdgeBrowser.FindInstance('EdgeID4');

    if Assigned(EdgeInstance) then
    begin
      EdgeInstance.OnMessageSender := MemoMessageSender.Text;
      MessageSent := True;
      LogMessage('Mensagem enviada via Property para EdgeBrowser ID: ' + EdgeInstance.UniqueIdentifier);
    end;
  end
  else
  begin
    WVInstance := TCustomFormWVBrowser.FindInstance('WVID1');
    if not Assigned(WVInstance) then
      WVInstance := TCustomFormWVBrowser.FindInstance('WVID2');
    if not Assigned(WVInstance) then
      WVInstance := TCustomFormWVBrowser.FindInstance('WVID3');
    if not Assigned(WVInstance) then
      WVInstance := TCustomFormWVBrowser.FindInstance('WVID4');

    if Assigned(WVInstance) then
    begin
      WVInstance.OnMessageSender := MemoMessageSender.Text;
      MessageSent := True;
      LogMessage('Mensagem enviada via Property para WVBrowser ID: ' + WVInstance.UniqueIdentifier);
    end;
  end;

  if not MessageSent then
    LogMessage('Nenhuma instância encontrada para envio de mensagem. Crie um browser primeiro usando os botões de teste.');
end;

end.
