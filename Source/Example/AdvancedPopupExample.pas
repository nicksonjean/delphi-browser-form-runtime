unit AdvancedPopupExample;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.Dwmapi, Winapi.ShellAPI,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs, Vcl.ComCtrls, Vcl.AppEvnts,
  System.JSON, System.Generics.Collections, System.SysUtils, System.Classes, System.StrUtils,
  uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes, uWVTypeLibrary,
  uWVBrowserBase, uWVCoreWebView2Args, uWVCoreWebView2Deferral, uWVLoader,
  uWVLibFunctions, uWVConstants, uWVCoreWebView2, uWVInterfaces,
  WVBrowserFormClass, BrowserTypes, BrowserFormInterface;

type
  TAdvancedPopupManager = class
  private
    FMainBrowser: TCustomFormWVBrowser;
    FPopups: TList<TCustomFormWVBrowser>;
    procedure OnMessageReceived(Sender: TObject; const Message: string);
//    procedure CreateCustomHTMLPopup;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateMainBrowser;
    procedure CreateLoginPopup;
    procedure CreateNotificationPopup;
    procedure CreateDataEntryPopup;
  end;

implementation

constructor TAdvancedPopupManager.Create;
begin
  inherited;
  FPopups := TList<TCustomFormWVBrowser>.Create;
end;

destructor TAdvancedPopupManager.Destroy;
var
  i: Integer;
begin
  // Limpar todos os popups
  for i := 0 to FPopups.Count - 1 do
    FPopups[i].Free;
  FPopups.Free;

  if Assigned(FMainBrowser) then
    FMainBrowser.Free;

  inherited;
end;

procedure TAdvancedPopupManager.CreateMainBrowser;
const
  MAIN_HTML =
    '<!DOCTYPE html>' +
    '<html>' +
    '<head>' +
    '  <title>Sistema Principal</title>' +
    '  <style>' +
    '    body { font-family: Arial, sans-serif; padding: 20px; }' +
    '    button { padding: 10px 20px; margin: 5px; cursor: pointer; }' +
    '    .main-button { background: #007bff; color: white; border: none; border-radius: 5px; }' +
    '  </style>' +
    '</head>' +
    '<body>' +
    '  <h1>Sistema Principal</h1>' +
    '  <button class="main-button" onclick="openLoginPopup()">Abrir Login</button>' +
    '  <button class="main-button" onclick="openNotificationPopup()">Abrir Notificação</button>' +
    '  <button class="main-button" onclick="openDataEntryPopup()">Abrir Entrada de Dados</button>' +
    '  <script>' +
    '    function openLoginPopup() {' +
    '      window.chrome.webview.postMessage({action: "openLogin"});' +
    '    }' +
    '    function openNotificationPopup() {' +
    '      window.chrome.webview.postMessage({action: "openNotification"});' +
    '    }' +
    '    function openDataEntryPopup() {' +
    '      window.chrome.webview.postMessage({action: "openDataEntry"});' +
    '    }' +
    '  </script>' +
    '</body>' +
    '</html>';
begin
  FMainBrowser := TCustomFormWVBrowser.Create('data:text/html,' + MAIN_HTML, nil)
    .SetWidth(800)
    .SetHeight(600)
    .SetCaption('Sistema Principal')
    .SetResizable(True)
    .SetMovable(True)
    .SetMessageReceiver(OnMessageReceived);

  FMainBrowser.Show();
end;

procedure TAdvancedPopupManager.OnMessageReceived(Sender: TObject; const Message: string);
var
  JsonMsg: TJSONObject;
  Action: string;
begin
  try
    JsonMsg := TJSONObject.ParseJSONValue(Message) as TJSONObject;
    if Assigned(JsonMsg) then
    try
      Action := JsonMsg.GetValue<string>('action');
      case IndexStr(Action, ['openLogin', 'openNotification', 'openDataEntry']) of
        0: CreateLoginPopup;
        1: CreateNotificationPopup;
        2: CreateDataEntryPopup;
      end;
    finally
      JsonMsg.Free;
    end;
  except
    // Ignorar erros de parsing JSON
  end;
end;

procedure TAdvancedPopupManager.CreateLoginPopup;
const
  LOGIN_HTML =
    '<!DOCTYPE html>' +
    '<html>' +
    '<head>' +
    '  <title>Login</title>' +
    '  <style>' +
    '    body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }' +
    '    .login-form { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }' +
    '    input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; }' +
    '    button { width: 100%; padding: 12px; background: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer; }' +
    '    button:hover { background: #218838; }' +
    '  </style>' +
    '</head>' +
    '<body>' +
    '  <div class="login-form">' +
    '    <h2>Login do Sistema</h2>' +
    '    <input type="text" id="username" placeholder="Usuário" />' +
    '    <input type="password" id="password" placeholder="Senha" />' +
    '    <button onclick="doLogin()">Entrar</button>' +
    '  </div>' +
    '  <script>' +
    '    function doLogin() {' +
    '      const username = document.getElementById("username").value;' +
    '      const password = document.getElementById("password").value;' +
    '      window.chrome.webview.postMessage({' +
    '        action: "login",' +
    '        username: username,' +
    '        password: password' +
    '      });' +
    '      window.close();' +
    '    }' +
    '  </script>' +
    '</body>' +
    '</html>';
var
  LoginBrowser: TCustomFormWVBrowser;
begin
  LoginBrowser := TCustomFormWVBrowser.CreateAsPopup(
    FMainBrowser.Instance as TWVBrowser,
    'data:text/html,' + LOGIN_HTML
  )
    .SetWidth(400)
    .SetHeight(300)
    .SetCaption('Login')
    .SetResizable(False)
    .SetMovable(True)
    .SetActionButtons([biSystemMenu]);

  FPopups.Add(LoginBrowser);
  LoginBrowser.Show();
end;

procedure TAdvancedPopupManager.CreateNotificationPopup;
var
  NotificationHTML: string;
  NotificationBrowser: TCustomFormWVBrowser;
begin
  NotificationHTML :=
    '<!DOCTYPE html>' +
    '<html>' +
    '<head>' +
    '  <title>Notificação</title>' +
    '  <style>' +
    '    body { font-family: Arial, sans-serif; padding: 20px; background: #fff3cd; }' +
    '    .notification { padding: 20px; border: 1px solid #ffeaa7; border-radius: 10px; }' +
    '    .close-btn { float: right; background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; }' +
    '  </style>' +
    '</head>' +
    '<body>' +
    '  <div class="notification">' +
    '    <button class="close-btn" onclick="window.close()">×</button>' +
    '    <h3>⚠️ Notificação Importante</h3>' +
    '    <p>Esta é uma notificação de exemplo criada como popup!</p>' +
    '    <p>Timestamp: ' + DateTimeToStr(Now) + '</p>' +
    '  </div>' +
    '</body>' +
    '</html>';

  NotificationBrowser := TCustomFormWVBrowser.CreateAsPopup(
    FMainBrowser.Instance as TWVBrowser,
    'data:text/html,' + NotificationHTML
  )
    .SetWidth(350)
    .SetHeight(200)
    .SetCaption('Notificação')
    .SetResizable(False)
    .SetMovable(True)
    .SetTitleBar(False)
    .SetAlpha(True);

  FPopups.Add(NotificationBrowser);
  NotificationBrowser.Show();
end;

procedure TAdvancedPopupManager.CreateDataEntryPopup;
const
  DATA_ENTRY_HTML =
    '<!DOCTYPE html>' +
    '<html>' +
    '<head>' +
    '  <title>Entrada de Dados</title>' +
    '  <style>' +
    '    body { font-family: Arial, sans-serif; padding: 20px; }' +
    '    .form-group { margin: 15px 0; }' +
    '    label { display: block; margin-bottom: 5px; font-weight: bold; }' +
    '    input, textarea, select { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; }' +
    '    textarea { height: 80px; resize: vertical; }' +
    '    .btn-group { margin-top: 20px; }' +
    '    button { padding: 10px 20px; margin-right: 10px; border: none; border-radius: 4px; cursor: pointer; }' +
    '    .btn-save { background: #007bff; color: white; }' +
    '    .btn-cancel { background: #6c757d; color: white; }' +
    '  </style>' +
    '</head>' +
    '<body>' +
    '  <h2>Cadastro de Cliente</h2>' +
    '  <form onsubmit="saveData(event)">' +
    '    <div class="form-group">' +
    '      <label>Nome:</label>' +
    '      <input type="text" id="name" required />' +
    '    </div>' +
    '    <div class="form-group">' +
    '      <label>Email:</label>' +
    '      <input type="email" id="email" required />' +
    '    </div>' +
    '    <div class="form-group">' +
    '      <label>Tipo:</label>' +
    '      <select id="type">' +
    '        <option value="individual">Pessoa Física</option>' +
    '        <option value="company">Pessoa Jurídica</option>' +
    '      </select>' +
    '    </div>' +
    '    <div class="form-group">' +
    '      <label>Observações:</label>' +
    '      <textarea id="notes"></textarea>' +
    '    </div>' +
    '    <div class="btn-group">' +
    '      <button type="submit" class="btn-save">Salvar</button>' +
    '      <button type="button" class="btn-cancel" onclick="window.close()">Cancelar</button>' +
    '    </div>' +
    '  </form>' +
    '  <script>' +
    '    function saveData(event) {' +
    '      event.preventDefault();' +
    '      const data = {' +
    '        action: "saveClient",' +
    '        name: document.getElementById("name").value,' +
    '        email: document.getElementById("email").value,' +
    '        type: document.getElementById("type").value,' +
    '        notes: document.getElementById("notes").value,' +
    '        timestamp: new Date().toISOString()' +
    '      };' +
    '      window.chrome.webview.postMessage(data);' +
    '      window.close();' +
    '    }' +
    '  </script>' +
    '</body>' +
    '</html>';
var
  DataEntryBrowser: TCustomFormWVBrowser;
begin
  DataEntryBrowser := TCustomFormWVBrowser.CreateAsPopup(
    FMainBrowser.Instance as TWVBrowser,
    'data:text/html,' + DATA_ENTRY_HTML
  )
    .SetWidth(500)
    .SetHeight(450)
    .SetCaption('Entrada de Dados')
    .SetResizable(True)
    .SetMovable(True)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize]);

  FPopups.Add(DataEntryBrowser);
  DataEntryBrowser.Show();
end;

end.
