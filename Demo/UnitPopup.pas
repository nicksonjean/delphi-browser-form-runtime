unit UnitPopup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.JSON, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes, uWVTypeLibrary,
  uWVBrowserBase, uWVCoreWebView2Args, uWVCoreWebView2Deferral, uWVLoader,
  uWVLibFunctions, uWVConstants, uWVCoreWebView2, uWVInterfaces,
  uWVCoreWebView2WindowFeatures,

  BrowserTypes,
  BrowserFormInterface,
  WVBrowserFormClass,
  AdvancedPopupExample;

type
  TFormPopup = class(TForm)
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  protected
    { Protected declarations }
    FPopupManager: TAdvancedPopupManager;
  private
    { Private declarations }
    FMainBrowser: TCustomFormWVBrowser;
    FPopupBrowser: TCustomFormWVBrowser;
    procedure LogMessage(const AMessage: string);
    procedure OnMainBrowserMessage(Sender: TObject; const Message: string);
    procedure OnPopupBrowserMessage(Sender: TObject; const Message: string);
    procedure OnBrowserWindowClosed(Sender: TObject);
    procedure OnMessageReceived(ASender: TObject; const AMessage: string);
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
  OnClose := FormClose;
  OnDestroy := FormDestroy;
  FPopupManager := nil;
end;

destructor TFormPopup.Destroy;
begin
  if Assigned(FPopupManager) then
  begin
    FPopupManager.CleanupAndDestroy;
    FPopupManager.Free;
    FPopupManager := nil;
  end;

  inherited;
end;

procedure TFormPopup.FormCreate(Sender: TObject);
begin
  MemoMessageSender.Lines.Text := ' { ' + sLineBreak
  + '   "operation": "putMessage", ' + sLineBreak
  + '   "data":{' + sLineBreak
  + '      "text": "Enviou para o WebView"' + sLineBreak
  + '    }' + sLineBreak
  + ' } ';

  memoLog.Lines.Add('=== Exemplo de Uso do WVBrowserFormClass ===');
  memoLog.Lines.Add('1. Primeiro clique em "Criar Browser Principal"');
  memoLog.Lines.Add('2. Depois clique em "Criar Popup"');
  memoLog.Lines.Add('');
end;

procedure TFormPopup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FPopupManager) then
    FPopupManager.CleanupAndDestroy;
end;

procedure TFormPopup.FormDestroy(Sender: TObject);
begin
  if Assigned(FPopupManager) then
  begin
    FPopupManager.CleanupAndDestroy;
    FPopupManager.Free;
    FPopupManager := nil;
  end;

  inherited;
end;

procedure TFormPopup.LogMessage(const AMessage: string);
begin
  memoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMessage);
end;

procedure TFormPopup.OnBrowserWindowClosed(Sender: TObject);
begin
  LogMessage('Janela do browser foi fechada: ' + Sender.ClassName);
end;

procedure TFormPopup.OnMessageReceived(ASender: TObject; const AMessage: string);
begin
  MemoMessageReceiver.Lines.Add('Mensagem recebida do browser: ' + AMessage);
end;

procedure TFormPopup.BtnWVBrowserClassChainableTestClick(Sender: TObject);
var
  FBrowserForm: TCustomFormWVBrowser;
  BrowserTag: String;
begin
  BrowserTag := 'UniqueID1';
  FBrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
    .SetCaption('Exemplo de Teste')
    .SetUniqueIdentifier(BrowserTag)
    .SetWidth(2048)
    .SetHeight(1800)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true)
    .SetCookie('CookieName', 'CookieValue', 'CookieDomain')
    .SetMessageReceiver(procedure(Sender: TObject; const MessageText: string)
    begin
      MemoMessageReceiver.Lines.Add(MessageText);
      ProcessarJSON(MessageText);
    end);
  FBrowserForm.Show;
end;

procedure TFormPopup.BtnWVBrowserClassPropertiesTestClick(Sender: TObject);
var
  FBrowserForm: TCustomFormWVBrowser;
  BrowserTag: String;
begin
  BrowserTag := 'UniqueID2';
  FBrowserForm := TCustomFormWVBrowser.Create;
  FBrowserForm.URL := 'file:///' + ExtractFilePath(ParamStr(0)) + 'index.html';
  FBrowserForm.UniqueIdentifier := BrowserTag;
  FBrowserForm.Caption := 'Exemplo de Teste';
  FBrowserForm.Width := 2048;
  FBrowserForm.Height := 1800;
  FBrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  FBrowserForm.Resizable := true;
  FBrowserForm.Movable := true;
  FBrowserForm.CookieName := 'CookieName';
  FBrowserForm.CookieValue := 'CookieValue';
  FBrowserForm.CookieDomain := 'CookieDomain';
  FBrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
  begin
    MemoMessageReceiver.Lines.Add(MessageText);
    ProcessarJSON(MessageText);
  end;
  FBrowserForm.Show;
end;

procedure TFormPopup.BtnWVBrowserInterfaceChainableTestClick(Sender: TObject);
var
  FBrowserForm: IBrowserForm;
  BrowserTag: String;
begin
  BrowserTag := 'UniqueID3';
  FBrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
    .SetCaption('Exemplo de Teste')
    .SetUniqueIdentifier(BrowserTag)
    .SetWidth(2048)
    .SetHeight(1800)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true)
    .SetCookie('CookieName', 'CookieValue', 'CookieDomain')
    .SetMessageReceiver(procedure(Sender: TObject; const MessageText: string)
    begin
      MemoMessageReceiver.Lines.Add(MessageText);
      ProcessarJSON(MessageText);
    end);
  FBrowserForm.Show;
end;

procedure TFormPopup.BtnWVBrowserInterfacePropertiesTestClick(Sender: TObject);
var
  FBrowserForm: IBrowserForm;
  BrowserTag: String;
begin
  BrowserTag := 'UniqueID4';
  FBrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
  FBrowserForm.Caption := 'Exemplo de Teste';
  FBrowserForm.UniqueIdentifier := BrowserTag;
  FBrowserForm.Width := 2048;
  FBrowserForm.Height := 1800;
  FBrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  FBrowserForm.Resizable := true;
  FBrowserForm.Movable := true;
  FBrowserForm.CookieName := 'CookieName';
  FBrowserForm.CookieValue := 'CookieValue';
  FBrowserForm.CookieDomain := 'CookieDomain';
  FBrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
  begin
    MemoMessageReceiver.Lines.Add(MessageText);
    ProcessarJSON(MessageText);
  end;
  FBrowserForm.Show;
end;

procedure TFormPopup.BtnCreateAdvPopupClick(Sender: TObject);
begin
  if Assigned(FPopupManager) then
  begin
    FPopupManager.CleanupAndDestroy;
    FPopupManager.Free;
    FPopupManager := nil;
  end;

  FPopupManager := TAdvancedPopupManager.Create(Self);
  FPopupManager.CreateMainBrowser;
end;

procedure TFormPopup.BtnCreateMainBrowserClick(Sender: TObject);
begin
  try
    LogMessage('Criando browser principal...');

    // Criar o browser principal
    FMainBrowser := TCustomFormWVBrowser.Create('https://www.google.com')
      .SetWidth(1000)
      .SetHeight(700)
      .SetCaption('Browser Principal', TPositionCaption.Before)
      .SetResizable(True)
      .SetMovable(True)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetCookie('session_id', '123456789', '.google.com', '/')
      .SetMessageReceiver(OnMainBrowserMessage);

    // Mostrar o browser principal
    FMainBrowser.Show;

    LogMessage('Browser principal criado e exibido!');
    btnCreatePopup.Enabled := True;

  except
    on E: Exception do
    begin
      LogMessage('ERRO ao criar browser principal: ' + E.Message);
    end;
  end;
end;

procedure TFormPopup.BtnCreatePopupClick(Sender: TObject);
begin
  try
    if not Assigned(FMainBrowser) then
    begin
      LogMessage('Primeiro crie o browser principal!');
      Exit;
    end;

    LogMessage('Criando popup...');

    FPopupBrowser := TCustomFormWVBrowser.CreateAsPopup(
      FMainBrowser.Instance as TWVBrowser, // Browser pai
      'https://www.github.com'             // URL do popup
    )
      .SetWidth(800)
      .SetHeight(800)
      .SetCaption('Popup - GitHub', TPositionCaption.Before)
      .SetResizable(True)
      .SetMovable(True)
      .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
      .SetCookie('popup_session', 'popup_123', '.github.com', '/')
      .SetMessageReceiver(OnPopupBrowserMessage);

    // Mostrar o popup
    FPopupBrowser.ShowModal;

    LogMessage('Popup criado e exibido!');

  except
    on E: Exception do
    begin
      LogMessage('Erro: ' + E.Message);
    end;
  end;
end;

procedure TFormPopup.BtnCreatePopupHtmlClick(Sender: TObject);
var
  Browser: IBrowserForm;
  HTMLContent: string;
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
    '    <p><strong>Data/Hora:</strong> ' + DateTimeToStr(Now) + '</p>' +
    '    <button onclick="enviarMensagem()">📤 Enviar Mensagem</button>' +
    '  </div>' +
    '</body>' +
    '</html>';

  Browser := TCustomFormWVBrowser.Create
    .SetHTMLContent(HTMLContent)
    .SetWidth(800)
    .SetHeight(800)
    .SetCaption('HTML Personalizado')
    .SetResizable(False)
    .SetMovable(True)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetWindowClosed(OnBrowserWindowClosed)
    .SetMessageReceiver(OnMessageReceived);
  Browser.ShowAsModal;
  LogMessage('Browser com HTML customizado criado');
end;

procedure TFormPopup.OnMainBrowserMessage(Sender: TObject; const Message: string);
begin
  LogMessage('Mensagem do Browser Principal: ' + Message);

  // Exemplo de como responder à mensagem
  if Assigned(FMainBrowser) then
  begin
    FMainBrowser.SetMessageSender('{"response": "Mensagem recebida no Delphi!", "timestamp": "' + DateTimeToStr(Now) + '"}');
  end;
end;

procedure TFormPopup.OnPopupBrowserMessage(Sender: TObject; const Message: string);
begin
  LogMessage('Mensagem do Popup: ' + Message);

  // Exemplo de como responder à mensagem do popup
  if Assigned(FPopupBrowser) then
  begin
    FPopupBrowser.SetMessageSender('{"response": "Popup respondeu!", "timestamp": "' + DateTimeToStr(Now) + '"}');
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
    JSONObject.Free;
  end;
end;

procedure TFormPopup.BtnMessageSenderByChainableClick(Sender: TObject);
begin
  if TCustomFormWVBrowser.FindInstance('UniqueID1') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID1').OnMessageSender := MemoMessageSender.Text
  else if TCustomFormWVBrowser.FindInstance('UniqueID2') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID2').OnMessageSender := MemoMessageSender.Text
  else if TCustomFormWVBrowser.FindInstance('UniqueID3') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID3').OnMessageSender := MemoMessageSender.Text
  else if TCustomFormWVBrowser.FindInstance('UniqueID4') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID4').OnMessageSender := MemoMessageSender.Text;
end;

procedure TFormPopup.BtnMessageSenderByPropertyClick(Sender: TObject);
begin
  if TCustomFormWVBrowser.FindInstance('UniqueID1') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID1').OnMessageSender := MemoMessageSender.Text
  else if TCustomFormWVBrowser.FindInstance('UniqueID2') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID2').OnMessageSender := MemoMessageSender.Text
  else if TCustomFormWVBrowser.FindInstance('UniqueID3') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID3').OnMessageSender := MemoMessageSender.Text
  else if TCustomFormWVBrowser.FindInstance('UniqueID4') is TCustomFormWVBrowser then
    TCustomFormWVBrowser.FindInstance('UniqueID4').OnMessageSender := MemoMessageSender.Text;
end;

end.
