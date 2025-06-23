unit EdgeBrowserFormClass;

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
  Winapi.ActiveX,

  WebView2,
  Vcl.Edge,

  EdgeDeferral,
  EdgeCookie,
  EdgeWindowFeatures,
  EdgeBrowserHelper,
  EdgeNewWindowRequestedEventArgs,

  TimerHelper,
  UtilsLib,
  BrowserTypes,
  EdgeBrowserFormInterface;

const
  DEBUG_MODE = false;
  CACHE_PATH = 'EdgeCustomCache';
  DEFAULT_URL = 'about:blank';
  DEFAULT_WIDTH = 800;
  DEFAULT_HEIGHT = 600;
  DEFAULT_LEGACY_FORM = false;
  DEFAULT_MAX_INSTANCES = 0;

type
  TCustomFormEdgeBrowser = class;

  TCustomEdgeForm = class(TForm)
  strict private
    FInitialized: Boolean;
    FArgs: TEdgeNewWindowRequestedEventArgs;
    FDeferral: TEdgeDeferral;
    procedure WMSize(var aMessage: TMessage); message WM_SIZE;
    procedure WMWindowPosChanging(var aMessage: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;
  public
    BrowserInstance: IEdgeBrowserForm;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure CenterToScreenWithMonitor;
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
  end;

  TCustomFormEdgeBrowser = class(TInterfacedObject, IEdgeBrowserForm)
  private
    FForm: TCustomEdgeForm;
    FBrowser: TEdgeBrowser;
    FMemoryLeakTimer: TTimer;
    FPendingCleanupArgs: TEdgeNewWindowRequestedEventArgs;
    FCookie: IEdgeCookie;
    FCookieName: String;
    FCookieValue: String;
    FCookieDomain: String;
    FCookiePath: String;
    FTimer: TTimer;
    FWidth: Integer;
    FHeight: Integer;
    FURL: string;
    FBrowserInitialized: Boolean;
    FCaption: string;
    FCaptionPosition: TPositionCaption;
    FMovable: Boolean;
    FAlpha: Boolean;
    FMessageSender: string;
    FMessageReceiver: TMessageReceiverCallback;
    FIsPopup: Boolean;
    FCheckTimer: TTimer;
    FCallbackList: TList<TCallbackInfo>;
    FOnWindowOpened: TNotifyEvent;
    FOnWindowClosed: TNotifyEvent;
    FParentFormToRestore: TForm;
    FParentFormEnabledState: Boolean;
    FOriginalOnWindowClosed: TNotifyEvent;
    FIsModalMode: Boolean;
    FIsClosing: Boolean;
    FIsInitializing: Boolean;
    FComponentsCreated: Boolean;
    FParentBrowser: TEdgeBrowser;
    FParentForm: TForm;
    FUniqueIdentifier: String;
    FMaxInstances: Integer;
    FLegacyForm: Boolean;
    FEdgeDLLHandle: THandle;
    FEdgeDLLPath: string;

    // Registry Control
    class var FFinalizationStarted: Boolean;

    // Registry for MDI Instances
    class var FMDIInstanceRegistry: TDictionary<string, TList<TCustomFormEdgeBrowser>>;
    class function GetMDIInstanceRegistry: TDictionary<string, TList<TCustomFormEdgeBrowser>>;
    class procedure RegisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormEdgeBrowser);
    class procedure UnregisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormEdgeBrowser);
    class function GetMDIInstanceCount(const AIdentifier: string): Integer;
    class function GetOldestMDIInstance(const AIdentifier: string): TCustomFormEdgeBrowser;
    class function CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
    class procedure CleanupMDIRegistry;

    // Registry for Popup Instances
    class var FPopupInstanceRegistry: TDictionary<string, TCustomFormEdgeBrowser>;
    class function GetPopupInstanceRegistry: TDictionary<string, TCustomFormEdgeBrowser>;
    class procedure RegisterPopupInstance(const AIdentifier: string; AInstance: TCustomFormEdgeBrowser);
    class procedure UnregisterPopupInstance(const AIdentifier: string);
    class procedure CleanupPopupRegistry;

    // Internal Generic Methods
    procedure ResizeBrowser;
    procedure TryCreateBrowser;
    procedure InitializePopupBrowser;
    procedure WaitForBrowserInitialization(const ACallback: TProc);
    procedure CheckInitializationTimer(Sender: TObject);
    procedure RestoreParentFormState(Sender: TObject);
    procedure EnsureComponentsCreated;
    procedure InitComponents;

    // Normal and Modal Methods
    procedure CreateComponents(AParentBrowser: TEdgeBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
    procedure CleanupWebViewResources;

    // MDI Methods
    procedure CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
    procedure ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);

    // Event Methods
    procedure OnTimer(Sender: TObject);
    procedure OnAfterCreated(Sender: TObject);
    procedure OnDocumentTitleChanged(Sender: TCustomEdgeBrowser; const ADocumentTitle: string);
    procedure OnInitializationError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure OnNavigationCompleted(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: TOleEnum);
    procedure OnWebMessageReceived(Sender: TCustomEdgeBrowser; aArgs: TWebMessageReceivedEventArgs);
    procedure OnNewWindowRequested(Sender: TCustomEdgeBrowser; aArgs: TNewWindowRequestedEventArgs);
    procedure OnWindowCloseRequested(Sender: TObject);
    procedure OnPopupOpened(Sender: TObject);
    procedure OnPopupClosed(Sender: TObject);

    // DLL
    procedure LoadEdgeSpecificDLL;
    procedure UnloadEdgeDLL;
    function GetEdgeDLLPath: string;
  protected
    // Getters
    function GetWidthProp: Integer;
    function GetHeightProp: Integer;
    function GetCaptionProp: String;
    function GetCaptionPositionProp: TPositionCaption;
    function GetActionButtonsProp: TBorderIcons;
    function GetResizableProp: Boolean;
    function GetMovableProp: Boolean;
    function GetTitleBarProp: Boolean;
    function GetInstanceProp: TComponent;
    function GetCookieNameProp: String;
    function GetCookieValueProp: String;
    function GetCookieDomainProp: String;
    function GetCookiePathProp: String;
    function GetAlphaProp: Boolean;
    function GetURLProp: String;
    function GetParentFormProp: TForm;
    function GetParentBrowserProp: TEdgeBrowser;
    function GetUniqueIdentifierProp: String;
    function GetMaxInstancesProp: Integer;
    function GetLegacyFormProp: Boolean;
    function GetWindowOpenedProp: TNotifyEvent;
    function GetWindowClosedProp: TNotifyEvent;
    function ReadMessageReceiverProp: TMessageReceiverCallback;
    function ReadMessageSenderProp: String;
    function GetPopupProp: Boolean;

    // Setters
    procedure SetWidthProp(const Value: Integer);
    procedure SetHeightProp(const Value: Integer);
    procedure SetCaptionProp(const Value: String);
    procedure SetCaptionPositionProp(const Value: TPositionCaption);
    procedure SetActionButtonsProp(const Value: TBorderIcons);
    procedure SetResizableProp(const Value: Boolean);
    procedure SetMovableProp(const Value: Boolean);
    procedure SetTitleBarProp(const Value: Boolean);
    procedure SetCookieNameProp(const Value: String);
    procedure SetCookieValueProp(const Value: String);
    procedure SetCookieDomainProp(const Value: String);
    procedure SetCookiePathProp(const Value: String = '/');
    procedure SetAlphaProp(const Value: Boolean);
    procedure SetURLProp(const Value: String);
    procedure SetParentFormProp(const Value: TForm);
    procedure SetParentBrowserProp(const Value: TEdgeBrowser);
    procedure SetUniqueIdentifierProp(const Value: String);
    procedure SetMaxInstancesProp(const Value: Integer);
    procedure SetLegacyFormProp(const Value: Boolean);
    procedure SetWindowOpenedProp(const Value: TNotifyEvent);
    procedure SetWindowClosedProp(const Value: TNotifyEvent);
    procedure SetMessageReceiverProp(const Value: TMessageReceiverCallback);
    procedure SetMessageSenderProp(const Value: String);
  public
    // Constructors and Destructor
    constructor Create; overload;
    constructor Create(const AURL: String); overload;
    constructor Create(const AURL: String; AParentObject: TObject; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM); overload;
    constructor CreateAsBrowser(const AURL: String = '');
    constructor CreateAsPopup(AParentBrowser: TEdgeBrowser; const AURL: String = '');
    constructor CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
    destructor Destroy; override;

    // Alias Static Constructors
    class function NewBrowser(const AURL: string): TCustomFormEdgeBrowser;
    class function NewPopup(const AURL: string; AParentBrowser: TEdgeBrowser = nil): TCustomFormEdgeBrowser;
    class function NewMDI(const AURL: String; AParentForm: TForm = nil): TCustomFormEdgeBrowser;

    // Static Method for Popup Forms
    class function FindInstance(const AIdentifier: string): TCustomFormEdgeBrowser;

    // Static Method for MDI Forms
    class function FindMDIInstance(const AIdentifier: string): TCustomFormEdgeBrowser;
    class function CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;

    // Fluent Chainable Methods
    function SetWidth(const AWidth: Integer): TCustomFormEdgeBrowser;
    function SetHeight(const AHeight: Integer): TCustomFormEdgeBrowser;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): TCustomFormEdgeBrowser;
    function SetActionButtons(const AButton: TBorderIcons): TCustomFormEdgeBrowser;
    function SetResizable(const AResize: Boolean): TCustomFormEdgeBrowser;
    function SetMovable(const AMove: Boolean): TCustomFormEdgeBrowser;
    function SetTitleBar(const ATitleBar: Boolean): TCustomFormEdgeBrowser;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TCustomFormEdgeBrowser;
    function SetAlpha(const AAlpha: Boolean): TCustomFormEdgeBrowser;
    function SetURL(const AURL: String): TCustomFormEdgeBrowser;
    function SetParentForm(const AParentForm: TForm): TCustomFormEdgeBrowser;
    function SetParentBrowser(const AParentBrowser: TEdgeBrowser): TCustomFormEdgeBrowser;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): TCustomFormEdgeBrowser;
    function SetMaxInstances(const AMaxInstances: Integer): TCustomFormEdgeBrowser;
    function SetLegacyForm(const ALegacyForm: Boolean): TCustomFormEdgeBrowser;
    function SetWindowOpened(const AEvent: TNotifyEvent): TCustomFormEdgeBrowser;
    function SetWindowClosed(const AEvent: TNotifyEvent): TCustomFormEdgeBrowser;
    function SetHTMLContent(const AHTMLContent: String): TCustomFormEdgeBrowser;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): TCustomFormEdgeBrowser;
    function SetMessageSender(const AMessage: String): TCustomFormEdgeBrowser;

    // Interface Methods
    function IEdgeBrowserForm.SetWidth = ISetWidth;
    function IEdgeBrowserForm.SetHeight = ISetHeight;
    function IEdgeBrowserForm.SetCaption = ISetCaption;
    function IEdgeBrowserForm.SetActionButtons = ISetActionButtons;
    function IEdgeBrowserForm.SetResizable = ISetResizable;
    function IEdgeBrowserForm.SetMovable = ISetMovable;
    function IEdgeBrowserForm.SetTitleBar = ISetTitleBar;
    function IEdgeBrowserForm.SetCookie = ISetCookie;
    function IEdgeBrowserForm.SetAlpha = ISetAlpha;
    function IEdgeBrowserForm.SetURL = ISetURL;
    function IEdgeBrowserForm.SetParentForm = ISetParentForm;
    function IEdgeBrowserForm.SetParentBrowser = ISetParentBrowser;
    function IEdgeBrowserForm.SetUniqueIdentifier = ISetUniqueIdentifier;
    function IEdgeBrowserForm.SetMaxInstances = ISetMaxInstances;
    function IEdgeBrowserForm.SetLegacyForm = ISetLegacyForm;
    function IEdgeBrowserForm.SetWindowOpened = ISetWindowOpened;
    function IEdgeBrowserForm.SetWindowClosed = ISetWindowClosed;
    function IEdgeBrowserForm.SetHTMLContent = ISetHTMLContent;
    function IEdgeBrowserForm.SetMessageReceiver = ISetMessageReceiver;
    function IEdgeBrowserForm.SetMessageSender = ISetMessageSender;
    procedure IEdgeBrowserForm.Show = IShow;
    procedure IEdgeBrowserForm.ShowModal = IShowModal;
    procedure IEdgeBrowserForm.ShowAsModal = IShowAsModal;
    procedure IEdgeBrowserForm.ShowAsMDICustom = IShowAsMDICustom;
    procedure IEdgeBrowserForm.ShowAsMDISimple = IShowAsMDISimple;
    procedure IEdgeBrowserForm.ShowAsMDIAdvanced = IShowAsMDIAdvanced;

    // Interface Methods
    function ISetWidth(const AWidth: Integer): IEdgeBrowserForm;
    function ISetHeight(const AHeight: Integer): IEdgeBrowserForm;
    function ISetCaption(const ACaption: String; APosition: TPositionCaption): IEdgeBrowserForm;
    function ISetActionButtons(const AButtons: TBorderIcons): IEdgeBrowserForm;
    function ISetResizable(const AResize: Boolean): IEdgeBrowserForm;
    function ISetMovable(const AMove: Boolean): IEdgeBrowserForm;
    function ISetTitleBar(const ATitleBar: Boolean): IEdgeBrowserForm;
    function ISetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IEdgeBrowserForm;
    function ISetAlpha(const AAlpha: Boolean): IEdgeBrowserForm;
    function ISetURL(const AURL: String): IEdgeBrowserForm;
    function ISetParentForm(const AParentForm: TForm): IEdgeBrowserForm;
    function ISetParentBrowser(const AParentBrowser: TEdgeBrowser): IEdgeBrowserForm;
    function ISetUniqueIdentifier(const AUniqueIdentifier: String): IEdgeBrowserForm;
    function ISetMaxInstances(const AMaxInstances: Integer): IEdgeBrowserForm;
    function ISetLegacyForm(const ALegacyForm: Boolean): IEdgeBrowserForm;
    function ISetWindowOpened(const AEvent: TNotifyEvent): IEdgeBrowserForm;
    function ISetWindowClosed(const AEvent: TNotifyEvent): IEdgeBrowserForm;
    function ISetHTMLContent(const AHTMLContent: String): IEdgeBrowserForm;
    function ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IEdgeBrowserForm;
    function ISetMessageSender(const AMessage: String): IEdgeBrowserForm;
    procedure IShow(const AType: TOpenType = TOpenType.Default);
    procedure IShowModal(const AType: TOpenType = TOpenType.Modal);
    procedure IShowAsModal(AParentForm: TForm = nil);
    procedure IShowAsMDICustom(AutoShow: Boolean = True);
    procedure IShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True); overload;
    procedure IShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);

    // Final Methods
    procedure Show(const AType: TOpenType = TOpenType.Default);
    procedure ShowModal(const AType: TOpenType = TOpenType.Modal);
    procedure ShowAsModal(AParentForm: TForm = nil);
    procedure ShowAsMDICustom(AutoShow: Boolean = True);
    procedure ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
    procedure ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);

    // Overload Final Methods
    procedure ShowAsMDI; overload;
    procedure ShowAsMDI(const AOptions: TMDIOptions); overload;

    // Properties
    property Width: Integer read GetWidthProp write SetWidthProp;
    property Height: Integer read GetHeightProp write SetHeightProp;
    property Caption: string read GetCaptionProp write SetCaptionProp;
    property CaptionPosition: TPositionCaption read GetCaptionPositionProp write SetCaptionPositionProp;
    property ActionButtons: TBorderIcons read GetActionButtonsProp write SetActionButtonsProp;
    property Resizable: Boolean read GetResizableProp write SetResizableProp;
    property Movable: Boolean read GetMovableProp write SetMovableProp;
    property TitleBar: Boolean read GetTitleBarProp write SetTitleBarProp;
    property CookieName: String read GetCookieNameProp write SetCookieNameProp;
    property CookieValue: String read GetCookieValueProp write SetCookieValueProp;
    property CookieDomain: String read GetCookieDomainProp write SetCookieDomainProp;
    property CookiePath: String read GetCookiePathProp write SetCookiePathProp;
    property Instance: TComponent read GetInstanceProp;
    property Alpha: Boolean read GetAlphaProp write SetAlphaProp;
    property URL: String read GetURLProp write SetURLProp;
    property ParentForm: TForm read GetParentFormProp write SetParentFormProp;
    property ParentBrowser: TEdgeBrowser read GetParentBrowserProp write SetParentBrowserProp;
    property UniqueIdentifier: String read GetUniqueIdentifierProp write SetUniqueIdentifierProp;
    property MaxInstances: Integer read GetMaxInstancesProp write SetMaxInstancesProp;
    property OnMessageReceiver: TMessageReceiverCallback read ReadMessageReceiverProp write SetMessageReceiverProp;
    property OnMessageSender: String read ReadMessageSenderProp write SetMessageSenderProp;
    property OnWindowOpened: TNotifyEvent read GetWindowOpenedProp write SetWindowOpenedProp;
    property OnWindowClosed: TNotifyEvent read GetWindowClosedProp write SetWindowClosedProp;
    property IsPopup: Boolean read GetPopupProp;
    property LegacyForm: Boolean read GetLegacyFormProp write SetLegacyFormProp;
  end;

implementation

{ TCustomEdgeForm }

procedure TCustomFormEdgeBrowser.LoadEdgeSpecificDLL;
var
  DLLPath: string;
  ErrorMsg: string;
begin
  FEdgeDLLHandle := 0;

  try
    DLLPath := GetEdgeDLLPath;
    FEdgeDLLPath := DLLPath;

    if not FileExists(DLLPath) then
      raise Exception.CreateFmt('DLL não encontrada: %s', [DLLPath]);

    FEdgeDLLHandle := LoadLibrary(PChar(DLLPath));
    if FEdgeDLLHandle = 0 then
    begin
      ErrorMsg := SysErrorMessage(GetLastError);
      raise Exception.CreateFmt('Erro ao carregar DLL %s: %s', [DLLPath, ErrorMsg]);
    end;

    if DEBUG_MODE then
      ShowMessage(Format('EdgeBrowser DLL carregada: %s (Handle: %d)', [DLLPath, FEdgeDLLHandle]));

  except
    on E: Exception do
    begin
      if FEdgeDLLHandle <> 0 then
      begin
        FreeLibrary(FEdgeDLLHandle);
        FEdgeDLLHandle := 0;
      end;
      raise Exception.CreateFmt('Falha ao carregar DLL específica para EdgeBrowser: %s', [E.Message]);
    end;
  end;
end;

procedure TCustomFormEdgeBrowser.UnloadEdgeDLL;
begin
  if FEdgeDLLHandle <> 0 then
  begin
    try
      if DEBUG_MODE then
        ShowMessage(Format('Descarregando EdgeBrowser DLL (Handle: %d)', [FEdgeDLLHandle]));

      FreeLibrary(FEdgeDLLHandle);
    except

    end;
    FEdgeDLLHandle := 0;
  end;
  FEdgeDLLPath := '';
end;

function TCustomFormEdgeBrowser.GetEdgeDLLPath: string;
var
  AppPath: string;
begin
  AppPath := ExtractFilePath(Application.ExeName);

  Result := AppPath + 'WebView2\Edge\WebView2Loader.dll';

  if not FileExists(Result) then
    Result := AppPath + 'WebView2Loader_Edge.dll';

  if not FileExists(Result) then
    Result := AppPath + 'WebView2Loader.dll';
end;

procedure TCustomEdgeForm.CenterToScreenWithMonitor;
var
  Monitor: TMonitor;
begin
  Monitor := Screen.MonitorFromWindow(Handle);
  SetBounds(
    Monitor.Left + (Monitor.Width - Width) div 2,
    Monitor.Top + (Monitor.Height - Height) div 2,
    Width,
    Height
  );
end;

constructor TCustomEdgeForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
end;

constructor TCustomEdgeForm.CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
begin
  inherited CreateNew(AOwner);

  if Assigned(aArgs) then
  begin
    FArgs := TEdgeNewWindowRequestedEventArgs.Create(aArgs);
    FDeferral := FArgs.Deferral;
  end;
end;

procedure TCustomEdgeForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TCustomFormEdgeBrowser).FIsClosing := True;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FTimer) then
    begin
      (BrowserInstance as TCustomFormEdgeBrowser).FTimer.Enabled := False;
      (BrowserInstance as TCustomFormEdgeBrowser).FTimer.OnTimer := nil;
    end;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FCheckTimer) then
    begin
      (BrowserInstance as TCustomFormEdgeBrowser).FCheckTimer.Enabled := False;
      (BrowserInstance as TCustomFormEdgeBrowser).FCheckTimer.OnTimer := nil;
    end;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FCallbackList) then
    begin
      while (BrowserInstance as TCustomFormEdgeBrowser).FCallbackList.Count > 0 do
      begin
        if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FCallbackList[0].Timer) then
        begin
          (BrowserInstance as TCustomFormEdgeBrowser).FCallbackList[0].Timer.Enabled := False;
          (BrowserInstance as TCustomFormEdgeBrowser).FCallbackList[0].Timer.OnTimer := nil;
        end;
        (BrowserInstance as TCustomFormEdgeBrowser).FCallbackList.Delete(0);
      end;
    end;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FBrowser) then
    begin
      if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FCookie) then
        (BrowserInstance as TCustomFormEdgeBrowser).FCookie := nil;

      if (BrowserInstance as TCustomFormEdgeBrowser).FBrowserInitialized then
      begin
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnAfterCreated := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnDocumentTitleChanged := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnInitializationError := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnNewWindowRequested := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnWindowCloseRequested := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnNavigationCompleted := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.OnWebMessageReceived := nil;
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowserInitialized := False;
      end;
    end;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FOnWindowClosed) then
      (BrowserInstance as TCustomFormEdgeBrowser).FOnWindowClosed(BrowserInstance as TCustomFormEdgeBrowser);
  end;
  Action := caFree;
end;

procedure TCustomEdgeForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TCustomFormEdgeBrowser).FIsClosing := True;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FTimer) then
      (BrowserInstance as TCustomFormEdgeBrowser).FTimer.Enabled := False;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FCheckTimer) then
      (BrowserInstance as TCustomFormEdgeBrowser).FCheckTimer.Enabled := False;

    if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FBrowser) then
    begin
      if (BrowserInstance as TCustomFormEdgeBrowser).FBrowserInitialized then
        (BrowserInstance as TCustomFormEdgeBrowser).FBrowser.ExecuteScript('window.dispatchEvent(new Event("beforeunload"))');

      if Assigned((BrowserInstance as TCustomFormEdgeBrowser).FCookie) then
        (BrowserInstance as TCustomFormEdgeBrowser).FCookie := nil;
    end;
  end;
end;

procedure TCustomEdgeForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FArgs) then
  begin
    try
      if Assigned(FDeferral) and not FDeferral.IsCompleted then
        FDeferral.Complete;
      FreeAndNil(FArgs);
    except
      FArgs := nil;
    end;
  end;

  if Assigned(FDeferral) then
  begin
    try
      FreeAndNil(FDeferral);
    except
      FDeferral := nil;
    end;
  end;

  BrowserInstance := nil;
end;

procedure TCustomEdgeForm.FormResize(Sender: TObject);
begin
  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormEdgeBrowser).ResizeBrowser;
end;

procedure TCustomEdgeForm.FormShow(Sender: TObject);
begin
  if not FInitialized then
  begin
    CenterToScreenWithMonitor;
    FInitialized := True;
  end;
  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormEdgeBrowser).TryCreateBrowser;
end;

procedure TCustomEdgeForm.WMMove(var aMessage: TWMMove);
begin
  inherited;
end;

procedure TCustomEdgeForm.WMMoving(var aMessage: TMessage);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TCustomFormEdgeBrowser).FMovable then
  begin
    CenterToScreenWithMonitor;
    aMessage.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomEdgeForm.WMSize(var aMessage: TMessage);
begin
  inherited;
  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormEdgeBrowser).ResizeBrowser;
end;

procedure TCustomEdgeForm.WMWindowPosChanging(var aMessage: TWMWindowPosChanging);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TCustomFormEdgeBrowser).FMovable then
  begin
    Self.CenterToScreenWithMonitor;
    aMessage.WindowPos^.flags := aMessage.WindowPos^.flags or SWP_NOMOVE;
  end;
  inherited;
end;

{ TCustomFormEdgeBrowser }

// Interface Methods

function TCustomFormEdgeBrowser.ISetWidth(const AWidth: Integer): IEdgeBrowserForm;
begin
  SetWidth(AWidth);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetHeight(const AHeight: Integer): IEdgeBrowserForm;
begin
  SetHeight(AHeight);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetCaption(const ACaption: string; APosition: TPositionCaption): IEdgeBrowserForm;
begin
  SetCaption(ACaption, APosition);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetActionButtons(const AButtons: TBorderIcons): IEdgeBrowserForm;
begin
  SetActionButtons(AButtons);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetResizable(const AResize: Boolean): IEdgeBrowserForm;
begin
  SetResizable(AResize);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetMovable(const AMove: Boolean): IEdgeBrowserForm;
begin
  SetMovable(AMove);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetTitleBar(const ATitleBar: Boolean): IEdgeBrowserForm;
begin
  SetTitleBar(ATitleBar);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetAlpha(const AAlpha: Boolean): IEdgeBrowserForm;
begin
  SetAlpha(AAlpha);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetURL(const AURL: String): IEdgeBrowserForm;
begin
  SetURL(AURL);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetParentForm(const AParentForm: TForm): IEdgeBrowserForm;
begin
  SetParentForm(AParentForm);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetParentBrowser(const AParentBrowser: TEdgeBrowser): IEdgeBrowserForm;
begin
  SetParentBrowser(AParentBrowser);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetUniqueIdentifier(const AUniqueIdentifier: String): IEdgeBrowserForm;
begin
  SetUniqueIdentifier(AUniqueIdentifier);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetMaxInstances(const AMaxInstances: Integer): IEdgeBrowserForm;
begin
  SetMaxInstances(AMaxInstances);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetLegacyForm(const ALegacyForm: Boolean): IEdgeBrowserForm;
begin
  SetLegacyForm(ALegacyForm);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetWindowOpened(const AEvent: TNotifyEvent): IEdgeBrowserForm;
begin
  SetWindowOpened(AEvent);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetWindowClosed(const AEvent: TNotifyEvent): IEdgeBrowserForm;
begin
  SetWindowClosed(AEvent);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetHTMLContent(const AHTMLContent: String): IEdgeBrowserForm;
begin
  SetHTMLContent(AHTMLContent);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetCookie(const ACookieName: string; const ACookieValue: string; const ACookieDomain: string; const ACookiePath: string = '/'): IEdgeBrowserForm;
begin
  SetCookie(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IEdgeBrowserForm;
begin
  SetMessageReceiver(AMessage);
  Result := Self;
end;

function TCustomFormEdgeBrowser.ISetMessageSender(const AMessage: String): IEdgeBrowserForm;
begin
  SetMessageSender(AMessage);
  Result := Self;
end;

procedure TCustomFormEdgeBrowser.IShowAsMDICustom(AutoShow: Boolean = True);
begin
  ShowAsMDICustom(AutoShow);
end;

procedure TCustomFormEdgeBrowser.IShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
begin
  ShowAsMDISimple(AutoShow, SingleInstance, MaximizeOnShow);
end;

procedure TCustomFormEdgeBrowser.IShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
begin
  ShowAsMDIAdvanced(AutoShow, SingleInstance, MaximizeOnShow, BringToFrontIfExists, UniqueIdentifier, MaxInstances);
end;

procedure TCustomFormEdgeBrowser.IShow(const AType: TOpenType);
begin
  Show(AType);
end;

procedure TCustomFormEdgeBrowser.IShowAsModal(AParentForm: TForm);
begin
  ShowAsModal(AParentForm);
end;

procedure TCustomFormEdgeBrowser.IShowModal(const AType: TOpenType);
begin
  ShowModal(AType);
end;

// Getters

function TCustomFormEdgeBrowser.GetWidthProp: Integer;
begin
  Result := FWidth;
end;

function TCustomFormEdgeBrowser.GetHeightProp: Integer;
begin
  Result := FHeight;
end;

function TCustomFormEdgeBrowser.GetCaptionProp: string;
begin
  Result := FCaption;
end;

function TCustomFormEdgeBrowser.GetCaptionPositionProp: TPositionCaption;
begin
  Result := FCaptionPosition;
end;

function TCustomFormEdgeBrowser.GetActionButtonsProp: TBorderIcons;
begin
  Result := FForm.BorderIcons;
end;

function TCustomFormEdgeBrowser.GetResizableProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsSizeable;
end;

function TCustomFormEdgeBrowser.GetMovableProp: Boolean;
begin
  Result := FMovable;
end;

function TCustomFormEdgeBrowser.GetPopupProp: Boolean;
begin
  Result:= FIsPopup;
end;

function TCustomFormEdgeBrowser.GetTitleBarProp: Boolean;
begin
  Result := FForm.BorderStyle <> TFormBorderStyle.bsNone;
end;

function TCustomFormEdgeBrowser.GetInstanceProp: TComponent;
begin
  Result := FBrowser;
end;

function TCustomFormEdgeBrowser.GetCookieNameProp: String;
begin
  Result := FCookieName;
end;

function TCustomFormEdgeBrowser.GetCookieValueProp: String;
begin
  Result := FCookieValue;
end;

function TCustomFormEdgeBrowser.GetCookieDomainProp: String;
begin
  Result := FCookieDomain;
end;

function TCustomFormEdgeBrowser.GetCookiePathProp: String;
begin
  Result := FCookiePath;
end;

function TCustomFormEdgeBrowser.GetAlphaProp: Boolean;
begin
  Result := FAlpha;
end;

function TCustomFormEdgeBrowser.GetURLProp: String;
begin
  Result := FURL;
end;

function TCustomFormEdgeBrowser.GetParentFormProp: TForm;
begin
  Result := FParentForm;
end;

function TCustomFormEdgeBrowser.GetParentBrowserProp: TEdgeBrowser;
begin
  Result := FParentBrowser;
end;

function TCustomFormEdgeBrowser.GetUniqueIdentifierProp: String;
begin
  Result := FUniqueIdentifier;
end;

function TCustomFormEdgeBrowser.GetMaxInstancesProp: Integer;
begin
  Result := FMaxInstances;
end;

function TCustomFormEdgeBrowser.GetLegacyFormProp: Boolean;
begin
  Result := FLegacyForm;
end;

function TCustomFormEdgeBrowser.GetWindowOpenedProp: TNotifyEvent;
begin
  Result := FOnWindowOpened;
end;

function TCustomFormEdgeBrowser.GetWindowClosedProp: TNotifyEvent;
begin
  Result := FOnWindowClosed;
end;

function TCustomFormEdgeBrowser.ReadMessageReceiverProp: TMessageReceiverCallback;
begin
  Result := FMessageReceiver;
end;

function TCustomFormEdgeBrowser.ReadMessageSenderProp: string;
begin
  Result := FMessageSender;
end;

// Setters

procedure TCustomFormEdgeBrowser.SetWidthProp(const Value: Integer);
begin
  SetWidth(Value);
end;

procedure TCustomFormEdgeBrowser.SetHeightProp(const Value: Integer);
begin
  SetHeight(Value);
end;

procedure TCustomFormEdgeBrowser.SetCaptionProp(const Value: string);
begin
  SetCaption(Value, FCaptionPosition);
end;

procedure TCustomFormEdgeBrowser.SetCaptionPositionProp(const Value: TPositionCaption);
begin
  FCaptionPosition := Value;
  SetCaption(FCaption, Value);
end;

procedure TCustomFormEdgeBrowser.SetActionButtonsProp(const Value: TBorderIcons);
begin
  SetActionButtons(Value);
end;

procedure TCustomFormEdgeBrowser.SetResizableProp(const Value: Boolean);
begin
  SetResizable(Value);
end;

procedure TCustomFormEdgeBrowser.SetMovableProp(const Value: Boolean);
begin
  SetMovable(Value);
end;

procedure TCustomFormEdgeBrowser.SetTitleBarProp(const Value: Boolean);
begin
  SetTitleBar(Value);
end;

procedure TCustomFormEdgeBrowser.SetCookieNameProp(const Value: String);
begin
  SetCookie(Value, FCookieValue, FCookieDomain, FCookiePath);
end;

procedure TCustomFormEdgeBrowser.SetCookieValueProp(const Value: String);
begin
  FCookieValue := Value;
  SetCookie(FCookieName, Value, FCookieDomain, FCookiePath);
end;

procedure TCustomFormEdgeBrowser.SetCookieDomainProp(const Value: String);
begin
  FCookieDomain := Value;
  SetCookie(FCookieName, FCookieValue, Value, FCookiePath);
end;

procedure TCustomFormEdgeBrowser.SetCookiePathProp(const Value: String);
begin
  FCookiePath := Value;
  SetCookie(FCookieName, FCookieValue, FCookieDomain, Value);
end;

procedure TCustomFormEdgeBrowser.SetAlphaProp(const Value: Boolean);
begin
  SetAlpha(Value);
end;

procedure TCustomFormEdgeBrowser.SetURLProp(const Value: String);
begin
  SetURL(Value);
end;

procedure TCustomFormEdgeBrowser.SetParentFormProp(const Value: TForm);
begin
  SetParentForm(Value);
end;

procedure TCustomFormEdgeBrowser.SetParentBrowserProp(const Value: TEdgeBrowser);
begin
  SetParentBrowser(Value);
end;

procedure TCustomFormEdgeBrowser.SetUniqueIdentifierProp(const Value: String);
begin
  SetUniqueIdentifier(Value);
end;

procedure TCustomFormEdgeBrowser.SetMaxInstancesProp(const Value: Integer);
begin
  SetMaxInstances(Value);
end;

procedure TCustomFormEdgeBrowser.SetLegacyFormProp(const Value: Boolean);
begin
  SetLegacyForm(Value);
end;

procedure TCustomFormEdgeBrowser.SetWindowOpenedProp(const Value: TNotifyEvent);
begin
  SetWindowOpened(Value);
end;

procedure TCustomFormEdgeBrowser.SetWindowClosedProp(const Value: TNotifyEvent);
begin
  SetWindowClosed(Value);
end;

procedure TCustomFormEdgeBrowser.SetMessageReceiverProp(const Value: TMessageReceiverCallback);
begin
  SetMessageReceiver(Value);
end;

procedure TCustomFormEdgeBrowser.SetMessageSenderProp(const Value: string);
begin
  SetMessageSender(Value);
end;

// Chainable Methods

function TCustomFormEdgeBrowser.SetWidth(const AWidth: Integer): TCustomFormEdgeBrowser;
begin
  FWidth := AWidth;
  if Assigned(FForm) then
  begin
    FForm.ClientWidth := AWidth;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetHeight(const AHeight: Integer): TCustomFormEdgeBrowser;
begin
  FHeight := AHeight;
  if Assigned(FForm) then
  begin
    FForm.ClientHeight := AHeight;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetCaption(const ACaption: String; APosition: TPositionCaption): TCustomFormEdgeBrowser;
begin
  FCaption := ACaption;
  FCaptionPosition := APosition;
  if FBrowserInitialized then
    Self.OnDocumentTitleChanged(FBrowser, FCaption);
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetActionButtons(const AButton: TBorderIcons): TCustomFormEdgeBrowser;
begin
  FForm.BorderIcons := FForm.BorderIcons - AButton;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetResizable(const AResize: Boolean): TCustomFormEdgeBrowser;
begin
  if AResize then
  begin
    FForm.BorderStyle := TFormBorderStyle.bsSizeable;
    FForm.Constraints.MinWidth := 100;
    FForm.Constraints.MinHeight := 100;
  end
  else
  begin
    FForm.BorderStyle := TFormBorderStyle.bsSingle;
    FForm.Constraints.MinWidth := FForm.Width;
    FForm.Constraints.MinHeight := FForm.Height;
    FForm.Constraints.MaxWidth := FForm.Width;
    FForm.Constraints.MaxHeight := FForm.Height;
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetMovable(const AMove: Boolean): TCustomFormEdgeBrowser;
begin
  FMovable := AMove;
  if Assigned(FForm) and not AMove then
    FForm.CenterToScreenWithMonitor;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetTitleBar(const ATitleBar: Boolean): TCustomFormEdgeBrowser;
begin
  if not ATitleBar then
  begin
    FForm.BorderStyle := TFormBorderStyle.bsNone;
    FForm.Constraints.MinWidth := FForm.Width;
    FForm.Constraints.MinHeight := FForm.Height;
    FForm.Constraints.MaxWidth := FForm.Width;
    FForm.Constraints.MaxHeight := FForm.Height;
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TCustomFormEdgeBrowser;
begin
  FCookieName := ACookieName;
  FCookieValue := ACookieValue;
  FCookieDomain := ACookieDomain;
  FCookiePath := ACookiePath;

  if Assigned(FCookie) then
    FCookie := nil;

  if FBrowserInitialized and Assigned(FBrowser) then
  begin
    FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
    if Assigned(FCookie) then
      FBrowser.AddOrUpdateCookie(FCookie);
  end;

  Result := Self;
end;

function TCustomFormEdgeBrowser.SetAlpha(const AAlpha: Boolean): TCustomFormEdgeBrowser;
begin
  FAlpha := AAlpha;
  if Assigned(FForm) and not AAlpha then
  begin
    FForm.AlphaBlend := false;
    FForm.AlphaBlendValue := 100;
  end
  else
  begin
    FForm.AlphaBlend := true;
    FForm.AlphaBlendValue := 0;
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetURL(const AURL: String): TCustomFormEdgeBrowser;
begin
  FURL := AURL;
  if not FComponentsCreated and (AURL <> EmptyStr) then
  begin
    if Assigned(FParentForm) and (FParentForm.FormStyle = fsMDIForm) then
    begin
      Self.CreateMDIComponents(FParentForm, AURL, FLegacyForm);
      FComponentsCreated := True;
    end
    else if Assigned(FParentBrowser) then
    begin
      Self.CreateComponents(FParentBrowser, true, AURL);
      FComponentsCreated := True;
      FIsPopup := True;
    end
    else
    begin
      Self.CreateComponents(nil, false, AURL);
      FComponentsCreated := True;
    end;
  end
  else if FComponentsCreated and FBrowserInitialized and Assigned(FBrowser) then
    FBrowser.Navigate(AURL)
  else if FComponentsCreated and not FBrowserInitialized then
  begin
    WaitForBrowserInitialization(
      procedure
      begin
        if Assigned(FBrowser) then
          FBrowser.Navigate(AURL);
      end
    );
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetParentForm(const AParentForm: TForm): TCustomFormEdgeBrowser;
begin
  FParentForm := AParentForm;

  if not FComponentsCreated and Assigned(AParentForm) then
  begin
    if AParentForm.FormStyle = fsMDIForm then
    begin
      Self.CreateMDIComponents(AParentForm, FURL, FLegacyForm);
      FComponentsCreated := True;
    end;
  end
  else if FComponentsCreated and Assigned(AParentForm) and (AParentForm.FormStyle = fsMDIForm) then
    ConvertToMDI(AParentForm, False);

  Result := Self;
end;

function TCustomFormEdgeBrowser.SetParentBrowser(const AParentBrowser: TEdgeBrowser): TCustomFormEdgeBrowser;
begin
  FParentBrowser := AParentBrowser;

  if not FComponentsCreated and Assigned(AParentBrowser) then
  begin
    Self.CreateComponents(AParentBrowser, true, FURL);
    FComponentsCreated := True;
    FIsPopup := True;
  end;

  Result := Self;
end;

function TCustomFormEdgeBrowser.SetUniqueIdentifier(const AUniqueIdentifier: String): TCustomFormEdgeBrowser;
begin
  if FUniqueIdentifier <> EmptyStr then
    UnregisterPopupInstance(FUniqueIdentifier);

  FUniqueIdentifier := AUniqueIdentifier;

  if AUniqueIdentifier <> EmptyStr then
    RegisterPopupInstance(AUniqueIdentifier, Self);

  Result := Self;
end;

function TCustomFormEdgeBrowser.SetMaxInstances(const AMaxInstances: Integer): TCustomFormEdgeBrowser;
begin
  FMaxInstances := AMaxInstances;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetLegacyForm(const ALegacyForm: Boolean): TCustomFormEdgeBrowser;
begin
  FLegacyForm := ALegacyForm;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetWindowOpened(const AEvent: TNotifyEvent): TCustomFormEdgeBrowser;
begin
  FOnWindowOpened := AEvent;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetWindowClosed(const AEvent: TNotifyEvent): TCustomFormEdgeBrowser;
begin
  FOnWindowClosed := AEvent;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetHTMLContent(const AHTMLContent: String): TCustomFormEdgeBrowser;
begin
  if not FComponentsCreated then
  begin
    if Assigned(FParentForm) and (FParentForm.FormStyle = fsMDIForm) then
    begin
      Self.CreateMDIComponents(FParentForm, DEFAULT_URL, FLegacyForm);
      FComponentsCreated := True;
    end
    else if Assigned(FParentBrowser) then
    begin
      Self.CreateComponents(FParentBrowser, true, DEFAULT_URL);
      FComponentsCreated := True;
      FIsPopup := True;
    end
    else
    begin
      Self.CreateComponents(nil, false, DEFAULT_URL);
      FComponentsCreated := True;
    end;
  end;

  if FBrowserInitialized and Assigned(FBrowser) then
  begin
    FBrowser.NavigateToString(AHTMLContent);
  end
  else
  begin
    WaitForBrowserInitialization(
      procedure
      begin
        if Assigned(FBrowser) then
          FBrowser.NavigateToString(AHTMLContent);
      end
    );
  end;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetMessageReceiver(const AMessage: TMessageReceiverCallback): TCustomFormEdgeBrowser;
begin
  FMessageReceiver := AMessage;
  Result := Self;
end;

function TCustomFormEdgeBrowser.SetMessageSender(const AMessage: String): TCustomFormEdgeBrowser;
var
  CoreWebView: ICoreWebView2;
  WideMessage: PWideChar;
begin
  FMessageSender := AMessage;
  if Assigned(FBrowser) and
     FBrowser.WebViewCreated and
     Assigned(FBrowser.ControllerInterface) then
  begin
    if Succeeded(FBrowser.ControllerInterface.Get_CoreWebView2(CoreWebView)) then
    begin
      WideMessage := PWideChar(UnicodeString(AMessage));
      CoreWebView.PostWebMessageAsString(WideMessage);
    end;
  end;
  Result := Self;
end;

// Registry MDI

class function TCustomFormEdgeBrowser.GetMDIInstanceRegistry: TDictionary<string, TList<TCustomFormEdgeBrowser>>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FMDIInstanceRegistry) then
    FMDIInstanceRegistry := TDictionary<string, TList<TCustomFormEdgeBrowser>>.Create;
  Result := FMDIInstanceRegistry;
end;

class procedure TCustomFormEdgeBrowser.RegisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormEdgeBrowser);
var
  InstanceList: TList<TCustomFormEdgeBrowser>;
  Registry: TDictionary<string, TList<TCustomFormEdgeBrowser>>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetMDIInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if not Registry.TryGetValue(AIdentifier, InstanceList) then
  begin
    InstanceList := TList<TCustomFormEdgeBrowser>.Create;
    Registry.Add(AIdentifier, InstanceList);
  end;

  if InstanceList.IndexOf(AInstance) = -1 then
    InstanceList.Add(AInstance);
end;

class procedure TCustomFormEdgeBrowser.UnregisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormEdgeBrowser);
var
  InstanceList: TList<TCustomFormEdgeBrowser>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) or not Assigned(FMDIInstanceRegistry) then
    Exit;

  if FMDIInstanceRegistry.TryGetValue(AIdentifier, InstanceList) then
  begin
    if Assigned(InstanceList) then
    begin
      if Assigned(AInstance) then
        AInstance.CleanupWebViewResources;

      InstanceList.Remove(AInstance);

      if InstanceList.Count = 0 then
      begin
        FMDIInstanceRegistry.Remove(AIdentifier);
        InstanceList.Free;
      end;
    end;
  end;
end;

class function TCustomFormEdgeBrowser.GetMDIInstanceCount(const AIdentifier: string): Integer;
var
  InstanceList: TList<TCustomFormEdgeBrowser>;
  Registry: TDictionary<string, TList<TCustomFormEdgeBrowser>>;
  i: Integer;
begin
  Result := 0;
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetMDIInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if Registry.TryGetValue(AIdentifier, InstanceList) then
  begin
    if Assigned(InstanceList) then
    begin
      for i := InstanceList.Count - 1 downto 0 do
      begin
        if not Assigned(InstanceList[i]) or
           not Assigned(InstanceList[i].FForm) or
           InstanceList[i].FIsClosing then
        begin
          InstanceList.Delete(i);
        end
        else
          Inc(Result);
      end;

      if InstanceList.Count = 0 then
      begin
        Registry.Remove(AIdentifier);
        InstanceList.Free;
      end;
    end;
  end;
end;

class function TCustomFormEdgeBrowser.GetOldestMDIInstance(const AIdentifier: string): TCustomFormEdgeBrowser;
var
  InstanceList: TList<TCustomFormEdgeBrowser>;
  Registry: TDictionary<string, TList<TCustomFormEdgeBrowser>>;
  i: Integer;
begin
  Result := nil;
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetMDIInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if Registry.TryGetValue(AIdentifier, InstanceList) then
  begin
    if Assigned(InstanceList) then
    begin
      for i := 0 to InstanceList.Count - 1 do
      begin
        if Assigned(InstanceList[i]) and Assigned(InstanceList[i].FForm) and not InstanceList[i].FIsClosing then
        begin
          Result := InstanceList[i];
          Break;
        end;
      end;
    end;
  end;
end;

class function TCustomFormEdgeBrowser.FindMDIInstance(const AIdentifier: string): TCustomFormEdgeBrowser;
begin
  Result := GetOldestMDIInstance(AIdentifier);
end;

class function TCustomFormEdgeBrowser.CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
var
  CurrentCount: Integer;
begin
  Result := True;

  if AIdentifier = EmptyStr then
    Exit;

  if ASingleInstance then
  begin
    Result := not Assigned(FindMDIInstance(AIdentifier));
  end

  else if AMaxInstances > 1 then
  begin
    CurrentCount := GetMDIInstanceCount(AIdentifier);
    Result := CurrentCount < AMaxInstances;
  end;
end;

class function TCustomFormEdgeBrowser.CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;
begin
  Result := CanCreateMDIInstance(AUniqueIdentifier, AMaxInstances, ASingleInstance);
end;

class procedure TCustomFormEdgeBrowser.CleanupMDIRegistry;
var
  Pair: TPair<string, TList<TCustomFormEdgeBrowser>>;
  InstanceList: TList<TCustomFormEdgeBrowser>;
  i: Integer;
  Instance: TCustomFormEdgeBrowser;
begin
  FFinalizationStarted := True;

  if Assigned(FMDIInstanceRegistry) then
  begin
    for Pair in FMDIInstanceRegistry do
    begin
      InstanceList := Pair.Value;
      if Assigned(InstanceList) then
      begin
        for i := InstanceList.Count - 1 downto 0 do
        begin
          Instance := InstanceList[i];
          if Assigned(Instance) then
          begin
            if Assigned(Instance.FCookie) then
              Instance.FCookie := nil;
            Instance.FIsClosing := True;
          end;
        end;
        InstanceList.Clear;
        InstanceList.Free;
      end;
    end;

    FMDIInstanceRegistry.Clear;
    FreeAndNil(FMDIInstanceRegistry);
  end;
end;

// Registry Popup

class function TCustomFormEdgeBrowser.GetPopupInstanceRegistry: TDictionary<string, TCustomFormEdgeBrowser>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FPopupInstanceRegistry) then
    FPopupInstanceRegistry := TDictionary<string, TCustomFormEdgeBrowser>.Create;
  Result := FPopupInstanceRegistry;
end;

class procedure TCustomFormEdgeBrowser.RegisterPopupInstance(const AIdentifier: string; AInstance: TCustomFormEdgeBrowser);
var
  Registry: TDictionary<string, TCustomFormEdgeBrowser>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetPopupInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if Registry.ContainsKey(AIdentifier) then
    Registry.Remove(AIdentifier);

  Registry.Add(AIdentifier, AInstance);
end;

class procedure TCustomFormEdgeBrowser.UnregisterPopupInstance(const AIdentifier: string);
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) or not Assigned(FPopupInstanceRegistry) then
    Exit;

  if FPopupInstanceRegistry.ContainsKey(AIdentifier) then
    FPopupInstanceRegistry.Remove(AIdentifier);
end;

class function TCustomFormEdgeBrowser.FindInstance(const AIdentifier: string): TCustomFormEdgeBrowser;
var
  Registry: TDictionary<string, TCustomFormEdgeBrowser>;
begin
  Result := nil;
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetPopupInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if Registry.ContainsKey(AIdentifier) then
  begin
    Result := Registry[AIdentifier];
    if Assigned(Result) and (Result.FIsClosing or not Assigned(Result.FForm)) then
    begin
      Registry.Remove(AIdentifier);
      Result := nil;
    end;
  end;
end;

class procedure TCustomFormEdgeBrowser.CleanupPopupRegistry;
begin
  if Assigned(FPopupInstanceRegistry) then
  begin
    FPopupInstanceRegistry.Clear;
    FreeAndNil(FPopupInstanceRegistry);
  end;
end;

// Context

procedure TCustomFormEdgeBrowser.CreateComponents(AParentBrowser: TEdgeBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
begin
  FParentFormToRestore := nil;
  FParentFormEnabledState := True;
  FOriginalOnWindowClosed := nil;
  FIsModalMode := False;

  if FURL = EmptyStr then
    FURL := AURL;

  if FWidth = 0 then
    FWidth := DEFAULT_WIDTH;

  if FHeight = 0 then
    FHeight := DEFAULT_HEIGHT;

  FCaption := EmptyStr;
  FCaptionPosition := TPositionCaption.Between;
  FMovable := True;
  FBrowserInitialized := False;
  FIsPopup := AIsPopup;

  if AParentBrowser <> nil then
    FParentBrowser := AParentBrowser;

  FBrowser.UserDataFolder := TUtils.EnsureCacheDirectory(CACHE_PATH);

  FForm := TCustomEdgeForm.CreateWithArgs(nil, nil);
  FForm.BrowserInstance := Self;
  FForm.Caption := FCaption;
  FForm.Position := poScreenCenter;
  FForm.Width := FWidth;
  FForm.Height := FHeight;
  FForm.BorderIcons := FForm.BorderIcons - [];
  FForm.BorderStyle := TFormBorderStyle.bsSizeable;
  FForm.OnShow := FForm.FormShow;
  FForm.OnClose := FForm.FormClose;
  FForm.OnCloseQuery := FForm.FormCloseQuery;
  FForm.OnDestroy := FForm.FormDestroy;
  FForm.OnResize := FForm.FormResize;

  FForm.ClientWidth := FWidth;
  FForm.ClientHeight := FHeight;

  if AIsPopup then
  begin
    FForm.Constraints.MinWidth := FWidth;
    FForm.Constraints.MinHeight := FHeight;
  end;

  InitComponents;
end;

procedure TCustomFormEdgeBrowser.CleanupWebViewResources;
begin
  if Assigned(FCookie) then
    FCookie := nil;

  if Assigned(FBrowser) and FBrowserInitialized then
  begin
    FBrowser.OnAfterCreated := nil;
    FBrowser.OnDocumentTitleChanged := nil;
    FBrowser.OnInitializationError := nil;
    FBrowser.OnNewWindowRequested := nil;
    FBrowser.OnWindowCloseRequested := nil;
    FBrowser.OnNavigationCompleted := nil;
    FBrowser.OnWebMessageReceived := nil;

    FBrowserInitialized := False;
  end;
end;

procedure TCustomFormEdgeBrowser.CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
var
  OldForm: TCustomEdgeForm;
begin
  OldForm := FForm;

  if FURL = EmptyStr then
    FURL := AURL;

  if FWidth = 0 then
    FWidth := DEFAULT_WIDTH;

  if FHeight = 0 then
    FHeight := DEFAULT_HEIGHT;

  FIsClosing := False;
  FParentForm := AParentForm;
  FIsInitializing := False;

  FBrowser.UserDataFolder := TUtils.EnsureCacheDirectory(CACHE_PATH);

  try

    if ALegacyForm then
    begin
      Application.CreateForm(TCustomEdgeForm, FForm);

      if Assigned(AParentForm) then
      begin
        FForm.Parent := AParentForm;
        FForm.ParentWindow := AParentForm.Handle;
      end;
    end
    else
    begin
      FForm := TCustomEdgeForm.CreateWithArgs(AParentForm, nil);
      FForm.FormStyle := fsMDIChild;
    end;

    FForm.BrowserInstance := Self;
    FForm.Caption := FCaption;
    FForm.Position := poScreenCenter;
    FForm.Width := FWidth;
    FForm.Height := FHeight;
    FForm.BorderIcons := FForm.BorderIcons - [];
    FForm.BorderStyle := TFormBorderStyle.bsSizeable;
    FForm.OnShow := FForm.FormShow;
    FForm.OnClose := FForm.FormClose;
    FForm.OnCloseQuery := FForm.FormCloseQuery;
    FForm.OnDestroy := FForm.FormDestroy;
    FForm.OnResize := FForm.FormResize;

    FForm.ClientWidth := FWidth;
    FForm.ClientHeight := FHeight;

    if not Assigned(FBrowser) then
      Self.InitComponents;

    if Assigned(OldForm) and (OldForm <> FForm) then
    begin
      OldForm.BrowserInstance := nil;
      OldForm.Release;
    end;

  except
    if Assigned(OldForm) then
      FForm := OldForm;
  end;
end;

// Constructors and Destructor

constructor TCustomFormEdgeBrowser.Create;
begin
  inherited Create;

  LoadEdgeSpecificDLL;

  FIsClosing := False;
  FIsInitializing := False;
  FParentForm := nil;
  FParentBrowser := nil;
  FComponentsCreated := False;
  
  FWidth := DEFAULT_WIDTH;
  FHeight := DEFAULT_HEIGHT;
  FURL := DEFAULT_URL;
  FMaxInstances := DEFAULT_MAX_INSTANCES;

  FCaption := EmptyStr;
  FCaptionPosition := TPositionCaption.Between;
  FMovable := True;
  FBrowserInitialized := False;
  FIsPopup := False;
end;

constructor TCustomFormEdgeBrowser.Create(const AURL: String);
begin
  inherited Create;

  LoadEdgeSpecificDLL;

  FIsClosing := False;
  FIsInitializing := False;
  FParentForm := nil;
  FParentBrowser := nil;
  FComponentsCreated := False;

  FWidth := DEFAULT_WIDTH;
  FHeight := DEFAULT_HEIGHT;
  if AURL <> EmptyStr then
    FURL := AURL
  else
    FURL := DEFAULT_URL;
  FMaxInstances := DEFAULT_MAX_INSTANCES;

  FCaption := EmptyStr;
  FCaptionPosition := TPositionCaption.Between;
  FMovable := True;
  FBrowserInitialized := False;
  FIsPopup := False;

  if AURL <> EmptyStr then
  begin
    Self.CreateComponents(nil, false, AURL);
    FComponentsCreated := True;
  end;
end;

constructor TCustomFormEdgeBrowser.Create(const AURL: String; AParentObject: TObject; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
begin
  inherited Create;

  LoadEdgeSpecificDLL;

  FIsClosing := False;
  FIsInitializing := False;
  FParentForm := nil;
  FParentBrowser := nil;
  FComponentsCreated := False;
  
  if AParentObject is TForm then
  begin
    FParentForm := TForm(AParentObject);
    if TForm(AParentObject).FormStyle = fsMDIForm then
    begin
      Self.CreateMDIComponents(TForm(AParentObject), AURL, ALegacyForm);
      FComponentsCreated := True;
    end
    else
    begin
      Self.CreateComponents(nil, false, AURL);
      FComponentsCreated := True;
    end;
  end
  else if AParentObject is TEdgeBrowser then
  begin
    FParentBrowser := TEdgeBrowser(AParentObject);
    Self.CreateComponents(TEdgeBrowser(AParentObject), true, AURL);
    FComponentsCreated := True;
  end
  else
  begin
    Self.CreateComponents(nil, false, AURL);
    FComponentsCreated := True;
  end;
end;

constructor TCustomFormEdgeBrowser.CreateAsBrowser(const AURL: String = '');
begin
  Self.Create(AURL);
end;

constructor TCustomFormEdgeBrowser.CreateAsPopup(AParentBrowser: TEdgeBrowser; const AURL: String = '');
begin
  if not Assigned(AParentBrowser) then
    raise Exception.Create('ParentBrowser cannot be nil for Popup');

  Self.Create(AURL, AParentBrowser);
end;

constructor TCustomFormEdgeBrowser.CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
begin
  if not Assigned(AParentForm) then
    raise Exception.Create('ParentForm cannot be nil for MDI');
  if AParentForm.FormStyle <> fsMDIForm then
    raise Exception.Create('ParentForm must have FormStyle=fsMDIForm to use MDI');

  Self.Create(AURL, AParentForm, ALegacyForm);
end;

// Static Constructors

class function TCustomFormEdgeBrowser.NewBrowser(const AURL: string): TCustomFormEdgeBrowser;
begin
  Result := TCustomFormEdgeBrowser.Create(AURL);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TCustomFormEdgeBrowser.NewPopup(const AURL: string; AParentBrowser: TEdgeBrowser = nil): TCustomFormEdgeBrowser;
begin
  Result := TCustomFormEdgeBrowser.Create(AURL, AParentBrowser);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TCustomFormEdgeBrowser.NewMDI(const AURL: String; AParentForm: TForm = nil): TCustomFormEdgeBrowser;
begin
  Result := TCustomFormEdgeBrowser.Create(AURL, AParentForm);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

destructor TCustomFormEdgeBrowser.Destroy;
begin
  FIsClosing := True;

  if (FUniqueIdentifier <> EmptyStr) and not TCustomFormEdgeBrowser.FFinalizationStarted then
  begin
    UnregisterPopupInstance(FUniqueIdentifier);
    UnregisterMDIInstance(FUniqueIdentifier, Self);
  end;

  if Assigned(FMemoryLeakTimer) then
  begin
    FMemoryLeakTimer.Enabled := False;
    FreeAndNil(FMemoryLeakTimer);
  end;

  if Assigned(FPendingCleanupArgs) then
  begin
    FPendingCleanupArgs.Free;
    FPendingCleanupArgs := nil;
  end;

  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    FTimer.OnTimer := nil;
    FreeAndNil(FTimer);
  end;

  if Assigned(FCheckTimer) then
  begin
    FCheckTimer.Enabled := False;
    FCheckTimer.OnTimer := nil;
    FreeAndNil(FCheckTimer);
  end;

  if Assigned(FCallbackList) then
  begin
    while FCallbackList.Count > 0 do
    begin
      if Assigned(FCallbackList[0].Timer) then
      begin
        FCallbackList[0].Timer.Enabled := False;
        FCallbackList[0].Timer.OnTimer := nil;
        FCallbackList[0].Timer.Free;
      end;
      FCallbackList.Delete(0);
    end;
    FreeAndNil(FCallbackList);
  end;

  if Assigned(FCookie) then
    FCookie := nil;

  if Assigned(FBrowser) then
  begin
    if FBrowserInitialized then
    begin
      FBrowser.OnAfterCreated := nil;
      FBrowser.OnDocumentTitleChanged := nil;
      FBrowser.OnInitializationError := nil;
      FBrowser.OnNewWindowRequested := nil;
      FBrowser.OnWindowCloseRequested := nil;
      FBrowser.OnNavigationCompleted := nil;
      FBrowser.OnWebMessageReceived := nil;
    end;

    FBrowserInitialized := False;
    FreeAndNil(FBrowser);
  end;

  FForm := nil;

  UnloadEdgeDLL;

  inherited;
end;

procedure TCustomFormEdgeBrowser.EnsureComponentsCreated;
begin
  if not FComponentsCreated then
  begin
    if Assigned(FParentForm) and (FParentForm.FormStyle = fsMDIForm) then
      Self.CreateMDIComponents(FParentForm, FURL, FLegacyForm)
    else if Assigned(FParentBrowser) then
    begin
      Self.CreateComponents(FParentBrowser, true, FURL);
      FIsPopup := True;
    end
    else
      Self.CreateComponents(nil, false, FURL);
    FComponentsCreated := True;
  end;
end;

procedure TCustomFormEdgeBrowser.InitComponents;
begin
  if FEdgeDLLHandle = 0 then
    raise Exception.Create('DLL específica do EdgeBrowser não foi carregada corretamente');

  // EdgeBrowser
  FBrowser := TEdgeBrowser.Create(FForm);
  FBrowser.Parent := FForm;
  FBrowser.Align := TAlign.alClient;
  FBrowser.Width := FForm.Width;
  FBrowser.Height := FForm.Height;

  // EdgeBrowser Events
  FBrowser.OnDocumentTitleChanged := Self.OnDocumentTitleChanged;
  FBrowser.OnNavigationCompleted := Self.OnNavigationCompleted;
  FBrowser.OnNewWindowRequested := Self.OnNewWindowRequested;
  FBrowser.OnWindowCloseRequested := Self.OnWindowCloseRequested;
  FBrowser.OnWebMessageReceived := Self.OnWebMessageReceived;
  FBrowser.OnInitializationError := Self.OnInitializationError;
  FBrowser.OnAfterCreated := Self.OnAfterCreated;

  // Cache Path
  if FBrowser.UserDataFolder = EmptyStr then
    FBrowser.UserDataFolder := TUtils.EnsureCacheDirectory(CACHE_PATH);

  // Timer
  FTimer := TTimer.Create(FForm);
  FTimer.Enabled := False;
  FTimer.Interval := 100;
  FTimer.OnTimer := OnTimer;
end;

procedure TCustomFormEdgeBrowser.InitializePopupBrowser;
begin
  if FIsPopup and Assigned(FParentBrowser) then
  begin

    if FURL <> EmptyStr then
    begin
      FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
      if Assigned(FCookie) then
        FBrowser.AddOrUpdateCookie(FCookie);
      FBrowser.Navigate(FURL);
    end;

    FBrowserInitialized := True;
    Self.ResizeBrowser;
  end;
end;

procedure TCustomFormEdgeBrowser.CheckInitializationTimer(Sender: TObject);
var
  Timer: TTimer;
  i: Integer;
  CallbackInfo: TCallbackInfo;
begin
  Timer := TTimer(Sender);

  if FBrowserInitialized then
  begin
    Timer.Enabled := False;

    if Assigned(FCallbackList) then
    begin
      for i := FCallbackList.Count - 1 downto 0 do
      begin
        CallbackInfo := FCallbackList[i];
        if CallbackInfo.Timer = Timer then
        begin
          if Assigned(CallbackInfo.Callback) then
            CallbackInfo.Callback();
          FCallbackList.Delete(i);
          Break;
        end;
      end;
    end;

    Timer.Free;
  end;
end;

procedure TCustomFormEdgeBrowser.RestoreParentFormState(Sender: TObject);
begin
  if Assigned(FParentFormToRestore) and FIsModalMode then
  begin
    FParentFormToRestore.Enabled := FParentFormEnabledState;
    FParentFormToRestore := nil;
    FIsModalMode := False;
  end;

  if Assigned(FOriginalOnWindowClosed) then
    FOriginalOnWindowClosed(Sender);
end;

procedure TCustomFormEdgeBrowser.WaitForBrowserInitialization(const ACallback: TProc);
var
  CheckTimer: TTimer;
  CallbackInfo: TCallbackInfo;
begin
  if FBrowserInitialized then
  begin
    if Assigned(ACallback) then
      ACallback();
  end
  else
  begin
    if not Assigned(FCallbackList) then
      FCallbackList := TList<TCallbackInfo>.Create;

    CheckTimer := TTimer.Create(nil);
    CheckTimer.Interval := 50;
    CheckTimer.OnTimer := CheckInitializationTimer;

    CallbackInfo.Timer := CheckTimer;
    CallbackInfo.Callback := ACallback;
    FCallbackList.Add(CallbackInfo);

    CheckTimer.Enabled := True;
  end;
end;

procedure TCustomFormEdgeBrowser.OnAfterCreated(Sender: TObject);
begin
  FBrowserInitialized := True;
  ResizeBrowser;

  if FURL <> EmptyStr then
  begin
    if Assigned(FBrowser) then
    begin
      if (FCookieName <> EmptyStr) and (FCookieValue <> EmptyStr) and (FCookieDomain <> EmptyStr) then
      begin
        if FBrowser.WebViewCreated then
        begin
          FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
          if Assigned(FCookie) then
            FBrowser.AddOrUpdateCookie(FCookie);
        end;
      end;
      FBrowser.Navigate(FURL);
    end;
  end;
end;

procedure TCustomFormEdgeBrowser.OnDocumentTitleChanged(Sender: TCustomEdgeBrowser; const ADocumentTitle: string);
var
  Title: string;
begin
  Title := ADocumentTitle;
  case FCaptionPosition of
    TPositionCaption.Before:
      FForm.Caption := FCaption + ' - ' + Title;
    TPositionCaption.After:
      FForm.Caption := Title + ' - ' + FCaption;
    TPositionCaption.Replaced:
      FForm.Caption := FCaption;
    TPositionCaption.Between:
      FForm.Caption := FCaption + ' ' + '[' + Title + ']';
    TPositionCaption.None:
      FForm.Caption := Title;
  end;
end;

procedure TCustomFormEdgeBrowser.OnInitializationError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  raise Exception.Create('EdgeBrowser Initialization Error: ' + aErrorMessage);
end;

procedure TCustomFormEdgeBrowser.OnNavigationCompleted(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: TOleEnum);
begin
  if not FBrowserInitialized and IsSuccess then
  begin
    FBrowserInitialized := True;
    FBrowser.DoOnAfterCreated;
  end;
  ResizeBrowser;
end;

procedure TCustomFormEdgeBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  Self.TryCreateBrowser;
end;

procedure TCustomFormEdgeBrowser.OnWebMessageReceived(Sender: TCustomEdgeBrowser; aArgs: TWebMessageReceivedEventArgs);
var
  MessageString: String;
  MessageObject: TJsonValue;
  Args: ICoreWebView2WebMessageReceivedEventArgs;
  JSON: PWideChar;
begin
  Args := aArgs as ICoreWebView2WebMessageReceivedEventArgs;
  if Succeeded(Args.TryGetWebMessageAsString(JSON)) then
  begin
    try
      MessageString := string(JSON);
      if not MessageString.Trim.IsEmpty then
      begin
        MessageObject := TJsonObject.ParseJSONValue(MessageString);
        if Assigned(MessageObject) then
        begin
          try
            if Assigned(FMessageReceiver) then
              FMessageReceiver(Self, MessageString);
          finally
            MessageObject.Free;
          end;
        end
        else
        begin
          if Assigned(FMessageReceiver) then
            FMessageReceiver(Self, MessageString);
        end;
      end;
    finally
      if Assigned(json) then
        CoTaskMemFree(json);
    end;
  end;
end;

procedure TCustomFormEdgeBrowser.OnNewWindowRequested(Sender: TCustomEdgeBrowser; aArgs: TNewWindowRequestedEventArgs);
var
  TempBrowser: TCustomFormEdgeBrowser;
  Deferral: TEdgeDeferral;
  Uri: PWideChar;
  WindowFeatures: TEdgeWindowFeatures;
  FEdgeArgs: TEdgeNewWindowRequestedEventArgs;
  CoreArgs: ICoreWebView2NewWindowRequestedEventArgs;
  CoreWebView: ICoreWebView2;
  UriString: string;
  HasPosition, HasSize: Integer;
  WinLeft, WinTop, WinWidth, WinHeight: Cardinal;
  DummyAction: Integer;
begin
  DummyAction := 0;
  Deferral := nil;
  Uri := nil;
  FEdgeArgs := nil;
  CoreArgs := nil;
  WindowFeatures := nil;

  try
    FEdgeArgs := TEdgeNewWindowRequestedEventArgs.Create(aArgs);
    CoreArgs := FEdgeArgs.CoreArgs;

    if not Assigned(CoreArgs) then
      Exit;

    Deferral := FEdgeArgs.GetDeferral;

    UriString := FEdgeArgs.GetUri;
    if (UriString = '') and Succeeded(CoreArgs.Get_uri(Uri)) then
    begin
      try
        UriString := string(Uri);
      finally
        if Assigned(Uri) then
          CoTaskMemFree(Uri);
      end;
    end;

    WindowFeatures := TEdgeWindowFeaturesHelper.TryGetWindowFeatures(CoreArgs);
    TempBrowser := TCustomFormEdgeBrowser.NewPopup(DEFAULT_URL);

    if Assigned(TempBrowser) then
    begin
      TempBrowser.FOnWindowClosed := Self.OnPopupClosed;
      TempBrowser.FOnWindowOpened := Self.OnPopupOpened;

      if Assigned(TempBrowser.FForm) then
      begin
        if Assigned(WindowFeatures) and WindowFeatures.Valid then
        begin
          if Succeeded(WindowFeatures.Get_HasPosition(HasPosition)) and (HasPosition <> 0) then
          begin
            if Succeeded(WindowFeatures.Get_Left(WinLeft)) and Succeeded(WindowFeatures.Get_Top(WinTop)) then
            begin
              if Assigned(TempBrowser.FForm) then
              begin
                TempBrowser.FForm.Position := TPosition.poDesigned;
                TempBrowser.FForm.Left := Integer(WinLeft);
                TempBrowser.FForm.Top := Integer(WinTop);
              end;
            end;
          end;

          if Succeeded(WindowFeatures.Get_HasSize(HasSize)) and (HasSize <> 0) then
          begin
            if Succeeded(WindowFeatures.Get_Width(WinWidth)) and Succeeded(WindowFeatures.Get_Height(WinHeight)) then
            begin
              if Assigned(TempBrowser.FForm) then
              begin
                TempBrowser.FForm.Width := Integer(WinWidth);
                TempBrowser.FForm.Height := Integer(WinHeight) + 22;
              end;
            end;
          end;
        end;
      end;

      TempBrowser.Show;

      if not Assigned(FMemoryLeakTimer) then
      begin
        FMemoryLeakTimer := TTimer.Create(nil);
        FMemoryLeakTimer.Interval := 500;
        FMemoryLeakTimer.OnInlineTimer := procedure(Sender: TObject)
          begin
            try
              if Assigned(FPendingCleanupArgs) then
              begin
                FPendingCleanupArgs.Free;
                FPendingCleanupArgs := nil;
              end;
            finally
              FMemoryLeakTimer.Enabled := False;
              FreeAndNil(FMemoryLeakTimer);
            end;
          end;
      end;

      FPendingCleanupArgs := FEdgeArgs;
      FMemoryLeakTimer.Enabled := True;

      TempBrowser.WaitForBrowserInitialization(
        procedure
        var
          DecodedContent: string;
          LocalUriString: string;
        begin
          LocalUriString := UriString;
          try
            if Assigned(TempBrowser.FBrowser) and Assigned(TempBrowser.FBrowser.ControllerInterface) then
            begin
              if Succeeded(TempBrowser.FBrowser.ControllerInterface.Get_CoreWebView2(CoreWebView)) then
              begin
                CoreArgs.Set_NewWindow(CoreWebView);
                FEdgeArgs.SetHandled(true);
                if LocalUriString = DEFAULT_URL then
                  DummyAction := 1
                else if Pos('data:text/html', LocalUriString) = 1 then
                begin
                  DecodedContent := TUtils.DecodeDataURL(LocalUriString);
                  if DecodedContent <> '' then
                    TempBrowser.SetHTMLContent(DecodedContent);
                end
                else
                  TempBrowser.FBrowser.Navigate(LocalUriString);
              end;
            end;
          except
            on E: Exception do
            begin
              if Assigned(FEdgeArgs) then
                FEdgeArgs.SetHandled(False);
            end;
          end;

          if Assigned(FMemoryLeakTimer) then
          begin
            FMemoryLeakTimer.Enabled := False;
            FreeAndNil(FMemoryLeakTimer);
          end;

          if Assigned(FPendingCleanupArgs) then
          begin
            FPendingCleanupArgs.Free;
            FPendingCleanupArgs := nil;
          end;

          if Assigned(Deferral) then
          begin
            Deferral.Complete;
            Deferral.Free;
          end;

          if Assigned(WindowFeatures) then
            WindowFeatures.Free;
        end
      );

      if Assigned(Uri) then
        Uri := nil;

    end
    else
    begin
      if Assigned(FEdgeArgs) then
      begin
        FEdgeArgs.SetHandled(False);
        FEdgeArgs.Free;
      end;

      if Assigned(Deferral) then
      begin
        Deferral.Complete;
        Deferral.Free;
      end;

      if Assigned(WindowFeatures) then
        WindowFeatures.Free;
    end;

  except
    on E: Exception do
    begin
      if Assigned(TempBrowser) then
        TempBrowser.Free;

      if Assigned(FEdgeArgs) then
      begin
        FEdgeArgs.SetHandled(False);
        FEdgeArgs.Free;
      end;

      if Assigned(Deferral) then
        Deferral.Complete;

      if Assigned(WindowFeatures) then
        WindowFeatures.Free;

      if Assigned(FMemoryLeakTimer) then
      begin
        FMemoryLeakTimer.Enabled := False;
        FreeAndNil(FMemoryLeakTimer);
      end;

      FPendingCleanupArgs := nil;
    end;
  end;
end;

procedure TCustomFormEdgeBrowser.OnWindowCloseRequested(Sender: TObject);
begin
  PostMessage(FForm.Handle, WM_CLOSE, 0, 0);
end;

procedure TCustomFormEdgeBrowser.OnPopupOpened(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup has completed opening! Instance: ' + TCustomFormEdgeBrowser(Sender).ClassName);
end;

procedure TCustomFormEdgeBrowser.OnPopupClosed(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup has been closed! Instance: ' + TCustomFormEdgeBrowser(Sender).ClassName);
end;

procedure TCustomFormEdgeBrowser.TryCreateBrowser;
begin
  if not FBrowserInitialized then
  begin
    try
      if FIsPopup then
      begin
        InitializePopupBrowser;
      end
      else
      begin
        if FURL <> EmptyStr then
        begin
          FBrowser.Navigate(FURL);
        end
        else
        begin
          FBrowser.Navigate('about:blank');
        end;
      end;
    except
      on E: Exception do
      begin
        if Assigned(FBrowser) then
          FBrowser.DoOnInitializationError(E_FAIL, E.Message);
      end;
    end;
  end;
  ResizeBrowser;
end;

procedure TCustomFormEdgeBrowser.ResizeBrowser;
begin
  if Assigned(FBrowser) then
  begin
    FBrowser.SetBounds(0, 0, FForm.ClientWidth, FForm.ClientHeight);
    FBrowser.Invalidate;
    FBrowser.Update;
  end;
end;

procedure TCustomFormEdgeBrowser.Show(const AType: TOpenType = TOpenType.Default);
begin
  Self.EnsureComponentsCreated;

  if Assigned(FForm) then
  begin
    if AType = TOpenType.Default then
      FForm.Show
    else
      FForm.ShowModal;
  end;
end;

procedure TCustomFormEdgeBrowser.ShowModal(const AType: TOpenType = TOpenType.Modal);
begin
  Self.EnsureComponentsCreated;

  if Assigned(FForm) then
  begin
    if AType = TOpenType.Modal then
      FForm.ShowModal
    else
      FForm.Show;
  end;
end;

procedure TCustomFormEdgeBrowser.ShowAsModal(AParentForm: TForm = nil);
var
  ParentForm: TForm;
begin
  Self.EnsureComponentsCreated;

  if Assigned(AParentForm) then
    ParentForm := AParentForm
  else if Assigned(Application.MainForm) then
    ParentForm := Application.MainForm
  else if Screen.ActiveForm <> nil then
    ParentForm := Screen.ActiveForm
  else
    ParentForm := nil;

  if Assigned(ParentForm) and Assigned(FForm) then
  begin
    FParentFormToRestore := ParentForm;
    FParentFormEnabledState := ParentForm.Enabled;
    FIsModalMode := True;

    FOriginalOnWindowClosed := FOnWindowClosed;
    FOnWindowClosed := RestoreParentFormState;
    ParentForm.Enabled := False;
    FForm.Show;

    if FForm.CanFocus then
      FForm.SetFocus;
  end
  else
    Show;
end;

procedure TCustomFormEdgeBrowser.ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);
begin
  FIsClosing := False;
  FParentForm := AParentForm;

  if not Assigned(FForm) then
    CreateMDIComponents(AParentForm, FURL, FLegacyForm)
  else
  begin
    try
      if Assigned(FTimer) then
        FTimer.Enabled := False;

      FForm.FormStyle := fsMDIChild;

      if FForm.Parent <> AParentForm then
        FForm.Parent := AParentForm;

      if FCaption <> EmptyStr then
        FForm.Caption := FCaption;

      if not FBrowserInitialized then
      begin
        try
          FBrowserInitialized := True;
          if FURL <> EmptyStr then
            FBrowser.Navigate(FURL);
        except
          if Assigned(FTimer) then
            FTimer.Enabled := True;
        end;
      end;

    except
      try
        CreateMDIComponents(AParentForm, FURL);
      except
        Exit;
      end;
    end;
  end;

  if AutoShow and Assigned(FForm) then
  begin
    FForm.Show;
    if FForm.CanFocus then
      FForm.SetFocus;
  end;
end;

procedure TCustomFormEdgeBrowser.ShowAsMDI;
var
  Options: TMDIOptions;
begin
  Options.AutoShow := True;
  Options.SingleInstance := True;
  Options.MaximizeOnShow := True;
  Options.BringToFrontIfExists := True;
  Options.UniqueIdentifier := FUniqueIdentifier;

  Self.ShowAsMDI(Options);
end;

procedure TCustomFormEdgeBrowser.ShowAsMDI(const AOptions: TMDIOptions);
var
  ExistingInstance: TCustomFormEdgeBrowser;
begin
  if AOptions.SingleInstance and (AOptions.UniqueIdentifier <> EmptyStr) then
  begin
    ExistingInstance := FindMDIInstance(AOptions.UniqueIdentifier);

    if Assigned(ExistingInstance) then
    begin
      ExistingInstance.ShowAsMDIAdvanced(
        AOptions.AutoShow,
        AOptions.SingleInstance,
        AOptions.MaximizeOnShow,
        AOptions.BringToFrontIfExists,
        AOptions.UniqueIdentifier,
        AOptions.MaxInstances
      );

      if Self <> ExistingInstance then
        Self.Free;

      Exit;
    end;
  end;

  Self.ShowAsMDIAdvanced(
    AOptions.AutoShow,
    AOptions.SingleInstance,
    AOptions.MaximizeOnShow,
    AOptions.BringToFrontIfExists,
    AOptions.UniqueIdentifier,
    AOptions.MaxInstances
  );
end;

procedure TCustomFormEdgeBrowser.ShowAsMDICustom(AutoShow: Boolean = True);
begin
  Self.EnsureComponentsCreated;

  if not Assigned(FParentForm) then
    Exit;

  if FParentForm.FormStyle <> fsMDIForm then
    Exit;

  if Assigned(FForm) and (FForm.FormStyle = fsMDIChild) and (FForm.Parent = FParentForm) then
  begin
    if AutoShow then
    begin
      FForm.Show;
      if FForm.CanFocus then
        FForm.SetFocus;
    end;
  end
  else
    Self.ConvertToMDI(FParentForm, AutoShow);
end;

procedure TCustomFormEdgeBrowser.ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
begin
  if not Assigned(FParentForm) then
    Exit;

  if FParentForm.FormStyle <> fsMDIForm then
    Exit;

  Self.ShowAsMDICustom(AutoShow);

  if AutoShow and Assigned(FForm) and MaximizeOnShow then
    FForm.WindowState := wsMaximized;
end;

procedure TCustomFormEdgeBrowser.ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
var
  ExistingBrowser: TCustomFormEdgeBrowser;
  FormIdentifier: String;
begin
  if not Assigned(FParentForm) then
    Exit;

  if FParentForm.FormStyle <> fsMDIForm then
    Exit;

  FormIdentifier := UniqueIdentifier;
  if FormIdentifier = EmptyStr then
    FormIdentifier := FUniqueIdentifier;
  if FormIdentifier = EmptyStr then
    FormIdentifier := FURL;

  if SingleInstance and (FormIdentifier <> EmptyStr) then
  begin
    ExistingBrowser := FindMDIInstance(FormIdentifier);
    if Assigned(ExistingBrowser) then
    begin
      if AutoShow then
      begin
        if ExistingBrowser.FForm.WindowState = wsMinimized then
          ExistingBrowser.FForm.WindowState := wsNormal;

        ExistingBrowser.FForm.Show;

        if BringToFrontIfExists then
          ExistingBrowser.FForm.BringToFront;

        if MaximizeOnShow and (ExistingBrowser.FForm.WindowState <> wsMaximized) then
          ExistingBrowser.FForm.WindowState := wsMaximized;

        if ExistingBrowser.FForm.CanFocus then
          ExistingBrowser.FForm.SetFocus;
      end;

      Exit;
    end;
  end
  else if not SingleInstance and (MaxInstances > 1) and (FormIdentifier <> EmptyStr) then
  begin
    if not CanCreateMDIInstance(FormIdentifier, MaxInstances, SingleInstance) then
      Exit;
  end;

  if FormIdentifier <> EmptyStr then
  begin
    FUniqueIdentifier := FormIdentifier;
    FMaxInstances := MaxInstances;
    RegisterMDIInstance(FormIdentifier, Self);
  end;

  Self.ConvertToMDI(FParentForm, AutoShow);
  if AutoShow and Assigned(FForm) and MaximizeOnShow then
    FForm.WindowState := TWindowstate.wsMaximized;
end;

initialization
  TCustomFormEdgeBrowser.FFinalizationStarted := False;

finalization
  TCustomFormEdgeBrowser.CleanupMDIRegistry;
  TCustomFormEdgeBrowser.CleanupPopupRegistry;

end.

