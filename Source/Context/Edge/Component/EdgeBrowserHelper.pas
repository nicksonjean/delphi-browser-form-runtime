unit EdgeBrowserHelper;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  WebView2,
  Vcl.Edge,
  Winapi.ActiveX,
  EdgeCookie;

type
  {$IFDEF DELPHI12_UP}
    wvstring = type string;
  {$ELSE}
    {$IFDEF FPC}
      wvstring = type UnicodeString;
    {$ELSE}
      wvstring = type WideString;
    {$ENDIF}
  {$ENDIF}

  // Tipos de evento - usar nomes únicos para evitar conflitos
  TEdgeInitializationErrorEvent = procedure(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring) of object;
  TEdgeAfterCreatedEvent = procedure(Sender: TObject) of object;

  TEdgeBrowserHelper = class helper for TEdgeBrowser
  private
    function GetOnInitializationError: TEdgeInitializationErrorEvent;
    procedure SetOnInitializationError(const Value: TEdgeInitializationErrorEvent);
    function GetOnAfterCreated: TEdgeAfterCreatedEvent;
    procedure SetOnAfterCreated(const Value: TEdgeAfterCreatedEvent);
  public
    // Propriedades de eventos
    property OnInitializationError: TEdgeInitializationErrorEvent read GetOnInitializationError write SetOnInitializationError;
    property OnAfterCreated: TEdgeAfterCreatedEvent read GetOnAfterCreated write SetOnAfterCreated;

    // Métodos de cookies
    function CreateCookie(const ACookieName, ACookieValue, ACookieDomain, ACookiePath: string): IEdgeCookie;
    procedure AddOrUpdateCookie(const ACookie: IEdgeCookie);
    procedure SetCookieViaScript(const ACookieName, ACookieValue, ACookieDomain, ACookiePath: string);
    procedure GetCookieViaScript(const ACookieName: string; ACallback: TProc<string>);

    // Métodos de acesso ao WebView2
    function GetCoreWebView2: ICoreWebView2;

    // Métodos de eventos
    procedure DoOnInitializationError(aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure DoOnAfterCreated;

    // Métodos utilitários
    procedure PostWebMessageAsString(const AMessage: string);
    procedure NavigateToString(const AHTMLContent: string);
  end;

implementation

// Variáveis globais para armazenar eventos (workaround para helper)
var
  GlobalInitErrorEvents: TDictionary<TEdgeBrowser, TEdgeInitializationErrorEvent>;
  GlobalAfterCreatedEvents: TDictionary<TEdgeBrowser, TEdgeAfterCreatedEvent>;

{ TEdgeBrowserHelper }

// Getters e Setters para eventos

function TEdgeBrowserHelper.GetOnInitializationError: TEdgeInitializationErrorEvent;
begin
  Result := nil;
  if Assigned(GlobalInitErrorEvents) and GlobalInitErrorEvents.ContainsKey(Self) then
    Result := GlobalInitErrorEvents[Self];
end;

procedure TEdgeBrowserHelper.SetOnInitializationError(const Value: TEdgeInitializationErrorEvent);
var
  Method: TMethod absolute Value;
begin
  if not Assigned(GlobalInitErrorEvents) then
    GlobalInitErrorEvents := TDictionary<TEdgeBrowser, TEdgeInitializationErrorEvent>.Create;

  if Method.Code <> nil then
    GlobalInitErrorEvents.AddOrSetValue(Self, Value)
  else if GlobalInitErrorEvents.ContainsKey(Self) then
    GlobalInitErrorEvents.Remove(Self);
end;

function TEdgeBrowserHelper.GetOnAfterCreated: TEdgeAfterCreatedEvent;
begin
  Result := nil;
  if Assigned(GlobalAfterCreatedEvents) and GlobalAfterCreatedEvents.ContainsKey(Self) then
    Result := GlobalAfterCreatedEvents[Self];
end;

procedure TEdgeBrowserHelper.SetOnAfterCreated(const Value: TEdgeAfterCreatedEvent);
var
  Method: TMethod absolute Value;
begin
  if not Assigned(GlobalAfterCreatedEvents) then
    GlobalAfterCreatedEvents := TDictionary<TEdgeBrowser, TEdgeAfterCreatedEvent>.Create;

  if Method.Code <> nil then
    GlobalAfterCreatedEvents.AddOrSetValue(Self, Value)
  else if GlobalAfterCreatedEvents.ContainsKey(Self) then
    GlobalAfterCreatedEvents.Remove(Self);
end;

// Métodos de eventos

procedure TEdgeBrowserHelper.DoOnInitializationError(aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  if Assigned(GlobalInitErrorEvents) and GlobalInitErrorEvents.ContainsKey(Self) then
    GlobalInitErrorEvents[Self](Self, aErrorCode, aErrorMessage);
end;

procedure TEdgeBrowserHelper.DoOnAfterCreated;
begin
  if Assigned(GlobalAfterCreatedEvents) and GlobalAfterCreatedEvents.ContainsKey(Self) then
    GlobalAfterCreatedEvents[Self](Self);
end;

// Métodos do WebView2

function TEdgeBrowserHelper.GetCoreWebView2: ICoreWebView2;
var
  CoreWebView: ICoreWebView2;
begin
  Result := nil;
  if Assigned(Self) and Self.WebViewCreated and Assigned(Self.ControllerInterface) then
  begin
    if Succeeded(Self.ControllerInterface.Get_CoreWebView2(CoreWebView)) then
      Result := CoreWebView;
  end;
end;

// Métodos de cookies

function TEdgeBrowserHelper.CreateCookie(const ACookieName, ACookieValue, ACookieDomain, ACookiePath: string): IEdgeCookie;
begin
  Result := TEdgeCookie.Create(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
end;

procedure TEdgeBrowserHelper.AddOrUpdateCookie(const ACookie: IEdgeCookie);
var
  CookieScript: string;
  CookieName, CookieValue, CookieDomain, CookiePath: string;
begin
  if not Assigned(ACookie) then
    Exit;

  if not (Assigned(Self) and Self.WebViewCreated) then
    Exit;

  // Extrair valores do cookie de forma segura
  CookieName := '';
  CookieValue := '';
  CookieDomain := '';
  CookiePath := '';

  if Assigned(ACookie.Name) then
    CookieName := string(ACookie.Name);

  if Assigned(ACookie.Value) then
    CookieValue := string(ACookie.Value);

  if Assigned(ACookie.Domain) then
    CookieDomain := string(ACookie.Domain);

  if Assigned(ACookie.Path) then
    CookiePath := string(ACookie.Path);

  // Validar dados mínimos
  if (CookieName = '') or (CookieValue = '') then
    Exit;

  // Construir script JavaScript para definir cookie
  CookieScript := Format('document.cookie = "%s=%s', [CookieName, CookieValue]);

  // Adicionar domínio se especificado
  if CookieDomain <> '' then
    CookieScript := CookieScript + '; domain=' + CookieDomain;

  // Adicionar path se especificado
  if CookiePath <> '' then
    CookieScript := CookieScript + '; path=' + CookiePath
  else
    CookieScript := CookieScript + '; path=/';

  // Finalizar comando
  CookieScript := CookieScript + '";';

  try
    // Executar script para definir cookie
    Self.ExecuteScript(CookieScript);
  except
    on E: Exception do
    begin
      // Chamar evento de erro se disponível
      DoOnInitializationError(E_FAIL, 'Erro ao definir cookie: ' + E.Message);
    end;
  end;
end;

procedure TEdgeBrowserHelper.SetCookieViaScript(const ACookieName, ACookieValue, ACookieDomain, ACookiePath: string);
var
  CookieScript: string;
begin
  if not (Assigned(Self) and Self.WebViewCreated) then
    Exit;

  if (ACookieName = '') or (ACookieValue = '') then
    Exit;

  // Construir script JavaScript
  CookieScript := Format('document.cookie = "%s=%s', [ACookieName, ACookieValue]);

  if ACookieDomain <> '' then
    CookieScript := CookieScript + '; domain=' + ACookieDomain;

  if ACookiePath <> '' then
    CookieScript := CookieScript + '; path=' + ACookiePath
  else
    CookieScript := CookieScript + '; path=/';

  CookieScript := CookieScript + '";';

  try
    Self.ExecuteScript(CookieScript);
  except
    on E: Exception do
    begin
      DoOnInitializationError(E_FAIL, 'Erro ao definir cookie via script: ' + E.Message);
    end;
  end;
end;

procedure TEdgeBrowserHelper.GetCookieViaScript(const ACookieName: string; ACallback: TProc<string>);
var
  Script: string;
  Method: TMethod absolute ACallback;
begin
  if not (Assigned(Self) and Self.WebViewCreated) then
  begin
    if Method.Code <> nil then
      ACallback('');
    Exit;
  end;

  if ACookieName = '' then
  begin
    if Method.Code <> nil then
      ACallback('');
    Exit;
  end;

  // Script para buscar cookie específico
  Script := Format(
    'function getCookie(name) {' +
    '  var nameEQ = name + "=";' +
    '  var ca = document.cookie.split(";");' +
    '  for(var i = 0; i < ca.length; i++) {' +
    '    var c = ca[i];' +
    '    while (c.charAt(0) == " ") c = c.substring(1, c.length);' +
    '    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);' +
    '  }' +
    '  return "";' +
    '}' +
    'window.chrome.webview.postMessage(getCookie("%s"));',
    [ACookieName]
  );

  try
    Self.ExecuteScript(Script);
    // O resultado será recebido via OnWebMessageReceived
  except
    on E: Exception do
    begin
      if Method.Code <> nil then
        ACallback('');
      DoOnInitializationError(E_FAIL, 'Erro ao ler cookie via script: ' + E.Message);
    end;
  end;
end;

// Métodos utilitários

procedure TEdgeBrowserHelper.PostWebMessageAsString(const AMessage: string);
var
  CoreWebView: ICoreWebView2;
  WideMessage: PWideChar;
begin
  CoreWebView := GetCoreWebView2;
  if not Assigned(CoreWebView) then
    Exit;

  try
    WideMessage := PWideChar(UnicodeString(AMessage));
    if Failed(CoreWebView.PostWebMessageAsString(WideMessage)) then
      DoOnInitializationError(E_FAIL, 'Falha ao enviar mensagem web');
  except
    on E: Exception do
      DoOnInitializationError(E_FAIL, 'Erro ao enviar mensagem: ' + E.Message);
  end;
end;

procedure TEdgeBrowserHelper.NavigateToString(const AHTMLContent: string);
var
  DataURL: string;
begin
  if not (Assigned(Self) and Self.WebViewCreated) then
    Exit;

  try
    // Codificar HTML como Data URL
    DataURL := 'data:text/html;charset=utf-8,' +
               StringReplace(
                 StringReplace(
                   StringReplace(AHTMLContent, '#', '%23', [rfReplaceAll]),
                   '?', '%3F', [rfReplaceAll]),
                 '&', '%26', [rfReplaceAll]);

    Self.Navigate(DataURL);
  except
    on E: Exception do
      DoOnInitializationError(E_FAIL, 'Erro ao navegar para string HTML: ' + E.Message);
  end;
end;

// Inicialização e finalização

initialization

finalization
  if Assigned(GlobalInitErrorEvents) then
  begin
    GlobalInitErrorEvents.Clear;
    FreeAndNil(GlobalInitErrorEvents);
  end;

  if Assigned(GlobalAfterCreatedEvents) then
  begin
    GlobalAfterCreatedEvents.Clear;
    FreeAndNil(GlobalAfterCreatedEvents);
  end;

end.
