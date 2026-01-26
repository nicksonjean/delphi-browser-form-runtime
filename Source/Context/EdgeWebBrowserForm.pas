unit EdgeWebBrowserForm;

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
  IBrowserFormBase,
  IEdgeWebBrowserForm;

const
  DEBUG_MODE = false;
  CACHE_PATH = 'EdgeCustomCache';
  DEFAULT_URL = 'about:blank';
  DEFAULT_WIDTH = 800;
  DEFAULT_HEIGHT = 600;
  DEFAULT_LEGACY_FORM = false;
  DEFAULT_MAX_INSTANCES = 0;

type
  TEdgeWebBrowser = class;

  TEdgeWebForm = class(TForm)
  strict private
    FInitialized: Boolean;
    FArgs: TEdgeNewWindowRequestedEventArgs;
    FDeferral: TEdgeDeferral;
    procedure WMSize(var aMessage: TMessage); message WM_SIZE;
    procedure WMWindowPosChanging(var aMessage: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;
  public
    BrowserInstance: IEWBrowserForm;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure CenterToScreenWithMonitor;
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
  end;

  TEdgeWebBrowser = class(TInterfacedObject, IEWBrowserForm, IBrowserForm)
  private
    FForm: TEdgeWebForm;
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
    class var FMDIInstanceRegistry: TDictionary<string, TList<TEdgeWebBrowser>>;
    class function GetMDIInstanceRegistry: TDictionary<string, TList<TEdgeWebBrowser>>;
    class procedure RegisterMDIInstance(const AIdentifier: string; AInstance: TEdgeWebBrowser);
    class procedure UnregisterMDIInstance(const AIdentifier: string; AInstance: TEdgeWebBrowser);
    class function GetMDIInstanceCount(const AIdentifier: string): Integer;
    class function GetOldestMDIInstance(const AIdentifier: string): TEdgeWebBrowser;
    class function CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
    class procedure CleanupMDIRegistry;

    // Registry for Popup Instances
    class var FPopupInstanceRegistry: TDictionary<string, TEdgeWebBrowser>;
    class function GetPopupInstanceRegistry: TDictionary<string, TEdgeWebBrowser>;
    class procedure RegisterPopupInstance(const AIdentifier: string; AInstance: TEdgeWebBrowser);
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
    function GetParentEdgeWebProp: TEdgeBrowser;
    function GetParentBrowserProp: TComponent;
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
    procedure SetParentEdgeWebProp(const Value: TEdgeBrowser);
    procedure SetParentBrowserProp(const Value: TComponent);
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
    class function NewBrowser(const AURL: string): TEdgeWebBrowser;
    class function NewPopup(const AURL: string; AParentBrowser: TEdgeBrowser = nil): TEdgeWebBrowser;
    class function NewMDI(const AURL: String; AParentForm: TForm = nil): TEdgeWebBrowser;

    // Static Method for Popup Forms
    class function FindInstance(const AIdentifier: string): TEdgeWebBrowser;

    // Static Method for MDI Forms
    class function FindMDIInstance(const AIdentifier: string): TEdgeWebBrowser;
    class function CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;

    // Fluent Concrete Chainable Methods
    function SetWidth(const AWidth: Integer): TEdgeWebBrowser;
    function SetHeight(const AHeight: Integer): TEdgeWebBrowser;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): TEdgeWebBrowser;
    function SetActionButtons(const AButton: TBorderIcons): TEdgeWebBrowser;
    function SetResizable(const AResize: Boolean): TEdgeWebBrowser;
    function SetMovable(const AMove: Boolean): TEdgeWebBrowser;
    function SetTitleBar(const ATitleBar: Boolean): TEdgeWebBrowser;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TEdgeWebBrowser;
    function SetAlpha(const AAlpha: Boolean): TEdgeWebBrowser;
    function SetURL(const AURL: String): TEdgeWebBrowser;
    function SetParentForm(const AParentForm: TForm): TEdgeWebBrowser;
    function SetParentBrowser(const AParentBrowser: TEdgeBrowser): TEdgeWebBrowser;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): TEdgeWebBrowser;
    function SetMaxInstances(const AMaxInstances: Integer): TEdgeWebBrowser;
    function SetLegacyForm(const ALegacyForm: Boolean): TEdgeWebBrowser;
    function SetWindowOpened(const AEvent: TNotifyEvent): TEdgeWebBrowser;
    function SetWindowClosed(const AEvent: TNotifyEvent): TEdgeWebBrowser;
    function SetHTMLContent(const AHTMLContent: String): TEdgeWebBrowser;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): TEdgeWebBrowser;
    function SetMessageSender(const AMessage: String): TEdgeWebBrowser;

    // Generic Interface Methods
    function ISetWidth(const AWidth: Integer): IBrowserForm;
    function ISetHeight(const AHeight: Integer): IBrowserForm;
    function ISetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): IBrowserForm;
    function ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
    function ISetResizable(const AResize: Boolean): IBrowserForm;
    function ISetMovable(const AMove: Boolean): IBrowserForm;
    function ISetTitleBar(const ATitleBar: Boolean): IBrowserForm;
    function ISetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IBrowserForm;
    function ISetAlpha(const AAlpha: Boolean): IBrowserForm;
    function ISetURL(const AURL: String): IBrowserForm;
    function ISetParentForm(const AParentForm: TForm): IBrowserForm;
    function ISetParentBrowser(const AParentBrowser: TComponent): IBrowserForm;
    function ISetUniqueIdentifier(const AUniqueIdentifier: String): IBrowserForm;
    function ISetMaxInstances(const AMaxInstances: Integer): IBrowserForm;
    function ISetLegacyForm(const ALegacyForm: Boolean): IBrowserForm;
    function ISetWindowOpened(const AEvent: TNotifyEvent): IBrowserForm;
    function ISetWindowClosed(const AEvent: TNotifyEvent): IBrowserForm;
    function ISetHTMLContent(const AHTMLContent: String): IBrowserForm;
    function ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IBrowserForm;
    function ISetMessageSender(const AMessage: String): IBrowserForm;

    // EdgeWeb Interface Methods
    function IEWSetWidth(const AWidth: Integer): IEWBrowserForm;
    function IEWSetHeight(const AHeight: Integer): IEWBrowserForm;
    function IEWSetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): IEWBrowserForm;
    function IEWSetActionButtons(const AButtons: TBorderIcons): IEWBrowserForm;
    function IEWSetResizable(const AResize: Boolean): IEWBrowserForm;
    function IEWSetMovable(const AMove: Boolean): IEWBrowserForm;
    function IEWSetTitleBar(const ATitleBar: Boolean): IEWBrowserForm;
    function IEWSetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IEWBrowserForm;
    function IEWSetAlpha(const AAlpha: Boolean): IEWBrowserForm;
    function IEWSetURL(const AURL: String): IEWBrowserForm;
    function IEWSetParentForm(const AParentForm: TForm): IEWBrowserForm;
    function IEWSetParentBrowser(const AParentBrowser: TEdgeBrowser): IEWBrowserForm;
    function IEWSetUniqueIdentifier(const AUniqueIdentifier: String): IEWBrowserForm;
    function IEWSetMaxInstances(const AMaxInstances: Integer): IEWBrowserForm;
    function IEWSetLegacyForm(const ALegacyForm: Boolean): IEWBrowserForm;
    function IEWSetWindowOpened(const AEvent: TNotifyEvent): IEWBrowserForm;
    function IEWSetWindowClosed(const AEvent: TNotifyEvent): IEWBrowserForm;
    function IEWSetHTMLContent(const AHTMLContent: String): IEWBrowserForm;
    function IEWSetMessageReceiver(const AMessage: TMessageReceiverCallback): IEWBrowserForm;
    function IEWSetMessageSender(const AMessage: String): IEWBrowserForm;

    // Method Resolution Interfaces
    function IEWBrowserForm.SetWidth = IEWSetWidth;
    function IEWBrowserForm.SetHeight = IEWSetHeight;
    function IEWBrowserForm.SetCaption = IEWSetCaption;
    function IEWBrowserForm.SetActionButtons = IEWSetActionButtons;
    function IEWBrowserForm.SetResizable = IEWSetResizable;
    function IEWBrowserForm.SetMovable = IEWSetMovable;
    function IEWBrowserForm.SetTitleBar = IEWSetTitleBar;
    function IEWBrowserForm.SetCookie = IEWSetCookie;
    function IEWBrowserForm.SetAlpha = IEWSetAlpha;
    function IEWBrowserForm.SetURL = IEWSetURL;
    function IEWBrowserForm.SetParentForm = IEWSetParentForm;
    function IEWBrowserForm.SetParentBrowser = IEWSetParentBrowser;
    function IEWBrowserForm.SetUniqueIdentifier = IEWSetUniqueIdentifier;
    function IEWBrowserForm.SetMaxInstances = IEWSetMaxInstances;
    function IEWBrowserForm.SetLegacyForm = IEWSetLegacyForm;
    function IEWBrowserForm.SetWindowOpened = IEWSetWindowOpened;
    function IEWBrowserForm.SetWindowClosed = IEWSetWindowClosed;
    function IEWBrowserForm.SetHTMLContent = IEWSetHTMLContent;
    function IEWBrowserForm.SetMessageReceiver = IEWSetMessageReceiver;
    function IEWBrowserForm.SetMessageSender = IEWSetMessageSender;

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
    property ParentEdgeWeb: TEdgeBrowser read GetParentEdgeWebProp write SetParentEdgeWebProp;
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

{ TEdgeWebForm }

procedure TEdgeWebBrowser.LoadEdgeSpecificDLL;
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

procedure TEdgeWebBrowser.UnloadEdgeDLL;
begin
  if FEdgeDLLHandle <> 0 then
  begin
    try
      FreeLibrary(FEdgeDLLHandle);
    except
      on E: Exception do
      begin
        raise Exception.CreateFmt('Falha ao carregar DLL específica para EdgeBrowser: %s', [E.Message]);
      end;
    end;
    FEdgeDLLHandle := 0;
  end;
  FEdgeDLLPath := '';
end;

function TEdgeWebBrowser.GetEdgeDLLPath: string;
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

procedure TEdgeWebForm.CenterToScreenWithMonitor;
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

constructor TEdgeWebForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
end;

constructor TEdgeWebForm.CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
begin
  inherited CreateNew(AOwner);

  if Assigned(aArgs) then
  begin
    FArgs := TEdgeNewWindowRequestedEventArgs.Create(aArgs);
    FDeferral := FArgs.Deferral;
  end;
end;

procedure TEdgeWebForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TEdgeWebBrowser).FIsClosing := True;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FTimer) then
    begin
      (BrowserInstance as TEdgeWebBrowser).FTimer.Enabled := False;
      (BrowserInstance as TEdgeWebBrowser).FTimer.OnTimer := nil;
    end;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FCheckTimer) then
    begin
      (BrowserInstance as TEdgeWebBrowser).FCheckTimer.Enabled := False;
      (BrowserInstance as TEdgeWebBrowser).FCheckTimer.OnTimer := nil;
    end;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FCallbackList) then
    begin
      while (BrowserInstance as TEdgeWebBrowser).FCallbackList.Count > 0 do
      begin
        if Assigned((BrowserInstance as TEdgeWebBrowser).FCallbackList[0].Timer) then
        begin
          (BrowserInstance as TEdgeWebBrowser).FCallbackList[0].Timer.Enabled := False;
          (BrowserInstance as TEdgeWebBrowser).FCallbackList[0].Timer.OnTimer := nil;
        end;
        (BrowserInstance as TEdgeWebBrowser).FCallbackList.Delete(0);
      end;
    end;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FBrowser) then
    begin
      if Assigned((BrowserInstance as TEdgeWebBrowser).FCookie) then
        (BrowserInstance as TEdgeWebBrowser).FCookie := nil;

      if (BrowserInstance as TEdgeWebBrowser).FBrowserInitialized then
      begin
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnAfterCreated := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnDocumentTitleChanged := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnInitializationError := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnNewWindowRequested := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnWindowCloseRequested := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnNavigationCompleted := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnWebMessageReceived := nil;
//        (BrowserInstance as TEdgeWebBrowser).FBrowser.OnContextMenuRequested := nil;
        (BrowserInstance as TEdgeWebBrowser).FBrowserInitialized := False;
      end;
    end;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FOnWindowClosed) then
      (BrowserInstance as TEdgeWebBrowser).FOnWindowClosed(BrowserInstance as TEdgeWebBrowser);
  end;
  Action := caFree;
end;

procedure TEdgeWebForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TEdgeWebBrowser).FIsClosing := True;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FTimer) then
      (BrowserInstance as TEdgeWebBrowser).FTimer.Enabled := False;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FCheckTimer) then
      (BrowserInstance as TEdgeWebBrowser).FCheckTimer.Enabled := False;

    if Assigned((BrowserInstance as TEdgeWebBrowser).FBrowser) then
    begin
      if (BrowserInstance as TEdgeWebBrowser).FBrowserInitialized then
        (BrowserInstance as TEdgeWebBrowser).FBrowser.ExecuteScript('window.dispatchEvent(new Event("beforeunload"))');

      if Assigned((BrowserInstance as TEdgeWebBrowser).FCookie) then
        (BrowserInstance as TEdgeWebBrowser).FCookie := nil;
    end;
  end;
end;

procedure TEdgeWebForm.FormDestroy(Sender: TObject);
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

procedure TEdgeWebForm.FormResize(Sender: TObject);
begin
  if Assigned(BrowserInstance) then
    (BrowserInstance as TEdgeWebBrowser).ResizeBrowser;
end;

procedure TEdgeWebForm.FormShow(Sender: TObject);
begin
  if not FInitialized then
  begin
    CenterToScreenWithMonitor;
    FInitialized := True;
  end;
  if Assigned(BrowserInstance) then
    (BrowserInstance as TEdgeWebBrowser).TryCreateBrowser;
end;

procedure TEdgeWebForm.WMMove(var aMessage: TWMMove);
begin
  inherited;
end;

procedure TEdgeWebForm.WMMoving(var aMessage: TMessage);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TEdgeWebBrowser).FMovable then
  begin
    CenterToScreenWithMonitor;
    aMessage.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TEdgeWebForm.WMSize(var aMessage: TMessage);
begin
  inherited;
  if Assigned(BrowserInstance) then
    (BrowserInstance as TEdgeWebBrowser).ResizeBrowser;
end;

procedure TEdgeWebForm.WMWindowPosChanging(var aMessage: TWMWindowPosChanging);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TEdgeWebBrowser).FMovable then
  begin
    Self.CenterToScreenWithMonitor;
    aMessage.WindowPos^.flags := aMessage.WindowPos^.flags or SWP_NOMOVE;
  end;
  inherited;
end;

{ TEdgeWebBrowser }

// Getters

function TEdgeWebBrowser.GetWidthProp: Integer;
begin
  Result := FWidth;
end;

function TEdgeWebBrowser.GetHeightProp: Integer;
begin
  Result := FHeight;
end;

function TEdgeWebBrowser.GetCaptionProp: string;
begin
  Result := FCaption;
end;

function TEdgeWebBrowser.GetCaptionPositionProp: TPositionCaption;
begin
  Result := FCaptionPosition;
end;

function TEdgeWebBrowser.GetActionButtonsProp: TBorderIcons;
begin
  Result := FForm.BorderIcons;
end;

function TEdgeWebBrowser.GetResizableProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsSizeable;
end;

function TEdgeWebBrowser.GetMovableProp: Boolean;
begin
  Result := FMovable;
end;

function TEdgeWebBrowser.GetPopupProp: Boolean;
begin
  Result:= FIsPopup;
end;

function TEdgeWebBrowser.GetTitleBarProp: Boolean;
begin
  Result := FForm.BorderStyle <> TFormBorderStyle.bsNone;
end;

function TEdgeWebBrowser.GetInstanceProp: TComponent;
begin
  Result := FBrowser;
end;

function TEdgeWebBrowser.GetCookieNameProp: String;
begin
  Result := FCookieName;
end;

function TEdgeWebBrowser.GetCookieValueProp: String;
begin
  Result := FCookieValue;
end;

function TEdgeWebBrowser.GetCookieDomainProp: String;
begin
  Result := FCookieDomain;
end;

function TEdgeWebBrowser.GetCookiePathProp: String;
begin
  Result := FCookiePath;
end;

function TEdgeWebBrowser.GetAlphaProp: Boolean;
begin
  Result := FAlpha;
end;

function TEdgeWebBrowser.GetURLProp: String;
begin
  Result := FURL;
end;

function TEdgeWebBrowser.GetParentFormProp: TForm;
begin
  Result := FParentForm;
end;

function TEdgeWebBrowser.GetParentEdgeWebProp: TEdgeBrowser;
begin
  Result := FParentBrowser;
end;

function TEdgeWebBrowser.GetParentBrowserProp: TComponent;
begin
  Result := FParentBrowser as TComponent;
end;

function TEdgeWebBrowser.GetUniqueIdentifierProp: String;
begin
  Result := FUniqueIdentifier;
end;

function TEdgeWebBrowser.GetMaxInstancesProp: Integer;
begin
  Result := FMaxInstances;
end;

function TEdgeWebBrowser.GetLegacyFormProp: Boolean;
begin
  Result := FLegacyForm;
end;

function TEdgeWebBrowser.GetWindowOpenedProp: TNotifyEvent;
begin
  Result := FOnWindowOpened;
end;

function TEdgeWebBrowser.GetWindowClosedProp: TNotifyEvent;
begin
  Result := FOnWindowClosed;
end;

function TEdgeWebBrowser.ReadMessageReceiverProp: TMessageReceiverCallback;
begin
  Result := FMessageReceiver;
end;

function TEdgeWebBrowser.ReadMessageSenderProp: string;
begin
  Result := FMessageSender;
end;

// Setters

procedure TEdgeWebBrowser.SetWidthProp(const Value: Integer);
begin
  SetWidth(Value);
end;

procedure TEdgeWebBrowser.SetHeightProp(const Value: Integer);
begin
  SetHeight(Value);
end;

procedure TEdgeWebBrowser.SetCaptionProp(const Value: string);
begin
  SetCaption(Value, FCaptionPosition);
end;

procedure TEdgeWebBrowser.SetCaptionPositionProp(const Value: TPositionCaption);
begin
  FCaptionPosition := Value;
  SetCaption(FCaption, Value);
end;

procedure TEdgeWebBrowser.SetActionButtonsProp(const Value: TBorderIcons);
begin
  SetActionButtons(Value);
end;

procedure TEdgeWebBrowser.SetResizableProp(const Value: Boolean);
begin
  SetResizable(Value);
end;

procedure TEdgeWebBrowser.SetMovableProp(const Value: Boolean);
begin
  SetMovable(Value);
end;

procedure TEdgeWebBrowser.SetTitleBarProp(const Value: Boolean);
begin
  SetTitleBar(Value);
end;

procedure TEdgeWebBrowser.SetCookieNameProp(const Value: String);
begin
  SetCookie(Value, FCookieValue, FCookieDomain, FCookiePath);
end;

procedure TEdgeWebBrowser.SetCookieValueProp(const Value: String);
begin
  FCookieValue := Value;
  SetCookie(FCookieName, Value, FCookieDomain, FCookiePath);
end;

procedure TEdgeWebBrowser.SetCookieDomainProp(const Value: String);
begin
  FCookieDomain := Value;
  SetCookie(FCookieName, FCookieValue, Value, FCookiePath);
end;

procedure TEdgeWebBrowser.SetCookiePathProp(const Value: String);
begin
  FCookiePath := Value;
  SetCookie(FCookieName, FCookieValue, FCookieDomain, Value);
end;

procedure TEdgeWebBrowser.SetAlphaProp(const Value: Boolean);
begin
  SetAlpha(Value);
end;

procedure TEdgeWebBrowser.SetURLProp(const Value: String);
begin
  SetURL(Value);
end;

procedure TEdgeWebBrowser.SetParentFormProp(const Value: TForm);
begin
  SetParentForm(Value);
end;

procedure TEdgeWebBrowser.SetParentEdgeWebProp(const Value: TEdgeBrowser);
begin
  SetParentBrowser(Value);
end;

procedure TEdgeWebBrowser.SetParentBrowserProp(const Value: TComponent);
begin
  if Value is TEdgeBrowser then
    SetParentEdgeWebProp(TEdgeBrowser(Value))
  else if Assigned(Value) then
    raise Exception.Create('ParentBrowser must be TEdgeBrowser for WebView2')
  else
    SetParentBrowserProp(nil);
end;

procedure TEdgeWebBrowser.SetUniqueIdentifierProp(const Value: String);
begin
  SetUniqueIdentifier(Value);
end;

procedure TEdgeWebBrowser.SetMaxInstancesProp(const Value: Integer);
begin
  SetMaxInstances(Value);
end;

procedure TEdgeWebBrowser.SetLegacyFormProp(const Value: Boolean);
begin
  SetLegacyForm(Value);
end;

procedure TEdgeWebBrowser.SetWindowOpenedProp(const Value: TNotifyEvent);
begin
  SetWindowOpened(Value);
end;

procedure TEdgeWebBrowser.SetWindowClosedProp(const Value: TNotifyEvent);
begin
  SetWindowClosed(Value);
end;

procedure TEdgeWebBrowser.SetMessageReceiverProp(const Value: TMessageReceiverCallback);
begin
  SetMessageReceiver(Value);
end;

procedure TEdgeWebBrowser.SetMessageSenderProp(const Value: string);
begin
  SetMessageSender(Value);
end;

// Chainable Methods - TEdgeWebBrowser

function TEdgeWebBrowser.SetWidth(const AWidth: Integer): TEdgeWebBrowser;
begin
  FWidth := AWidth;
  if Assigned(FForm) then
  begin
    FForm.ClientWidth := AWidth;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TEdgeWebBrowser.SetHeight(const AHeight: Integer): TEdgeWebBrowser;
begin
  FHeight := AHeight;
  if Assigned(FForm) then
  begin
    FForm.ClientHeight := AHeight;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TEdgeWebBrowser.SetCaption(const ACaption: String; APosition: TPositionCaption): TEdgeWebBrowser;
begin
  FCaption := ACaption;
  FCaptionPosition := APosition;
  if FBrowserInitialized then
    Self.OnDocumentTitleChanged(FBrowser, FCaption);
  Result := Self;
end;

function TEdgeWebBrowser.SetActionButtons(const AButton: TBorderIcons): TEdgeWebBrowser;
begin
  FForm.BorderIcons := FForm.BorderIcons - AButton;
  Result := Self;
end;

function TEdgeWebBrowser.SetResizable(const AResize: Boolean): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetMovable(const AMove: Boolean): TEdgeWebBrowser;
begin
  FMovable := AMove;
  if Assigned(FForm) and not AMove then
    FForm.CenterToScreenWithMonitor;
  Result := Self;
end;

function TEdgeWebBrowser.SetTitleBar(const ATitleBar: Boolean): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetAlpha(const AAlpha: Boolean): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetURL(const AURL: String): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetParentForm(const AParentForm: TForm): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetParentBrowser(const AParentBrowser: TEdgeBrowser): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetUniqueIdentifier(const AUniqueIdentifier: String): TEdgeWebBrowser;
begin
  if FUniqueIdentifier <> EmptyStr then
    UnregisterPopupInstance(FUniqueIdentifier);

  FUniqueIdentifier := AUniqueIdentifier;

  if AUniqueIdentifier <> EmptyStr then
    RegisterPopupInstance(AUniqueIdentifier, Self);

  Result := Self;
end;

function TEdgeWebBrowser.SetMaxInstances(const AMaxInstances: Integer): TEdgeWebBrowser;
begin
  FMaxInstances := AMaxInstances;
  Result := Self;
end;

function TEdgeWebBrowser.SetLegacyForm(const ALegacyForm: Boolean): TEdgeWebBrowser;
begin
  FLegacyForm := ALegacyForm;
  Result := Self;
end;

function TEdgeWebBrowser.SetWindowOpened(const AEvent: TNotifyEvent): TEdgeWebBrowser;
begin
  FOnWindowOpened := AEvent;
  Result := Self;
end;

function TEdgeWebBrowser.SetWindowClosed(const AEvent: TNotifyEvent): TEdgeWebBrowser;
begin
  FOnWindowClosed := AEvent;
  Result := Self;
end;

function TEdgeWebBrowser.SetHTMLContent(const AHTMLContent: String): TEdgeWebBrowser;
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

function TEdgeWebBrowser.SetMessageReceiver(const AMessage: TMessageReceiverCallback): TEdgeWebBrowser;
begin
  FMessageReceiver := AMessage;
  Result := Self;
end;

function TEdgeWebBrowser.SetMessageSender(const AMessage: String): TEdgeWebBrowser;
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

// Interface Methods - IEWBrowserForm

function TEdgeWebBrowser.IEWSetWidth(const AWidth: Integer): IEWBrowserForm;
begin
  Self.SetWidth(AWidth);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetHeight(const AHeight: Integer): IEWBrowserForm;
begin
  Self.SetHeight(AHeight);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetCaption(const ACaption: String; APosition: TPositionCaption): IEWBrowserForm;
begin
  Self.SetCaption(ACaption, APosition);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetActionButtons(const AButtons: TBorderIcons): IEWBrowserForm;
begin
  Self.SetActionButtons(AButtons);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetResizable(const AResize: Boolean): IEWBrowserForm;
begin
  Self.SetResizable(AResize);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetMovable(const AMove: Boolean): IEWBrowserForm;
begin
  Self.SetMovable(AMove);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetTitleBar(const ATitleBar: Boolean): IEWBrowserForm;
begin
  Self.SetTitleBar(ATitleBar);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String): IEWBrowserForm;
begin
  Self.SetCookie(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetAlpha(const AAlpha: Boolean): IEWBrowserForm;
begin
  Self.SetAlpha(AAlpha);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetURL(const AURL: String): IEWBrowserForm;
begin
  Self.SetURL(AURL);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetParentForm(const AParentForm: TForm): IEWBrowserForm;
begin
  Self.SetParentForm(AParentForm);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetParentBrowser(const AParentBrowser: TEdgeBrowser): IEWBrowserForm;
begin
  Self.SetParentBrowser(AParentBrowser);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetUniqueIdentifier(const AUniqueIdentifier: String): IEWBrowserForm;
begin
  Self.SetUniqueIdentifier(AUniqueIdentifier);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetMaxInstances(const AMaxInstances: Integer): IEWBrowserForm;
begin
  Self.SetMaxInstances(AMaxInstances);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetLegacyForm(const ALegacyForm: Boolean): IEWBrowserForm;
begin
  Self.SetLegacyForm(ALegacyForm);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetWindowOpened(const AEvent: TNotifyEvent): IEWBrowserForm;
begin
  Self.SetWindowOpened(AEvent);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetWindowClosed(const AEvent: TNotifyEvent): IEWBrowserForm;
begin
  Self.SetWindowClosed(AEvent);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetHTMLContent(const AHTMLContent: String): IEWBrowserForm;
begin
  Self.SetHTMLContent(AHTMLContent);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetMessageReceiver(const AMessage: TMessageReceiverCallback): IEWBrowserForm;
begin
  Self.SetMessageReceiver(AMessage);
  Result := Self;
end;

function TEdgeWebBrowser.IEWSetMessageSender(const AMessage: String): IEWBrowserForm;
begin
  Self.SetMessageSender(AMessage);
  Result := Self;
end;

// Interface Methods - IBrowserForm

function TEdgeWebBrowser.ISetWidth(const AWidth: Integer): IBrowserForm;
begin
  Self.SetWidth(AWidth);
  Result := Self;
end;

function TEdgeWebBrowser.ISetHeight(const AHeight: Integer): IBrowserForm;
begin
  Self.SetHeight(AHeight);
  Result := Self;
end;

function TEdgeWebBrowser.ISetCaption(const ACaption: String; APosition: TPositionCaption): IBrowserForm;
begin
  Self.SetCaption(ACaption, APosition);
  Result := Self;
end;

function TEdgeWebBrowser.ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
begin
  Self.SetActionButtons(AButtons);
  Result := Self;
end;

function TEdgeWebBrowser.ISetResizable(const AResize: Boolean): IBrowserForm;
begin
  Self.SetResizable(AResize);
  Result := Self;
end;

function TEdgeWebBrowser.ISetMovable(const AMove: Boolean): IBrowserForm;
begin
  Self.SetMovable(AMove);
  Result := Self;
end;

function TEdgeWebBrowser.ISetTitleBar(const ATitleBar: Boolean): IBrowserForm;
begin
  Self.SetTitleBar(ATitleBar);
  Result := Self;
end;

function TEdgeWebBrowser.ISetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String): IBrowserForm;
begin
  Self.SetCookie(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
  Result := Self;
end;

function TEdgeWebBrowser.ISetAlpha(const AAlpha: Boolean): IBrowserForm;
begin
  Self.SetAlpha(AAlpha);
  Result := Self;
end;

function TEdgeWebBrowser.ISetURL(const AURL: String): IBrowserForm;
begin
  Self.SetURL(AURL);
  Result := Self;
end;

function TEdgeWebBrowser.ISetParentForm(const AParentForm: TForm): IBrowserForm;
begin
  Self.SetParentForm(AParentForm);
  Result := Self;
end;

function TEdgeWebBrowser.ISetParentBrowser(const AParentBrowser: TComponent): IBrowserForm;
begin
  if AParentBrowser is TEdgeBrowser then
    Self.SetParentBrowser(TEdgeBrowser(AParentBrowser))
  else if Assigned(AParentBrowser) then
    raise Exception.Create('ParentBrowser must be TWVBrowser for WebView2')
  else
    Self.SetParentBrowser(nil);
  Result := Self;
end;

function TEdgeWebBrowser.ISetUniqueIdentifier(const AUniqueIdentifier: String): IBrowserForm;
begin
  Self.SetUniqueIdentifier(AUniqueIdentifier);
  Result := Self;
end;

function TEdgeWebBrowser.ISetMaxInstances(const AMaxInstances: Integer): IBrowserForm;
begin
  Self.SetMaxInstances(AMaxInstances);
  Result := Self;
end;

function TEdgeWebBrowser.ISetLegacyForm(const ALegacyForm: Boolean): IBrowserForm;
begin
  Self.SetLegacyForm(ALegacyForm);
  Result := Self;
end;

function TEdgeWebBrowser.ISetWindowOpened(const AEvent: TNotifyEvent): IBrowserForm;
begin
  Self.SetWindowOpened(AEvent);
  Result := Self;
end;

function TEdgeWebBrowser.ISetWindowClosed(const AEvent: TNotifyEvent): IBrowserForm;
begin
  Self.SetWindowClosed(AEvent);
  Result := Self;
end;

function TEdgeWebBrowser.ISetHTMLContent(const AHTMLContent: String): IBrowserForm;
begin
  Self.SetHTMLContent(AHTMLContent);
  Result := Self;
end;

function TEdgeWebBrowser.ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IBrowserForm;
begin
  Self.SetMessageReceiver(AMessage);
  Result := Self;
end;

function TEdgeWebBrowser.ISetMessageSender(const AMessage: String): IBrowserForm;
begin
  Self.SetMessageSender(AMessage);
  Result := Self;
end;

// Registry MDI

class function TEdgeWebBrowser.GetMDIInstanceRegistry: TDictionary<string, TList<TEdgeWebBrowser>>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FMDIInstanceRegistry) then
    FMDIInstanceRegistry := TDictionary<string, TList<TEdgeWebBrowser>>.Create;
  Result := FMDIInstanceRegistry;
end;

class procedure TEdgeWebBrowser.RegisterMDIInstance(const AIdentifier: string; AInstance: TEdgeWebBrowser);
var
  InstanceList: TList<TEdgeWebBrowser>;
  Registry: TDictionary<string, TList<TEdgeWebBrowser>>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetMDIInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if not Registry.TryGetValue(AIdentifier, InstanceList) then
  begin
    InstanceList := TList<TEdgeWebBrowser>.Create;
    Registry.Add(AIdentifier, InstanceList);
  end;

  if InstanceList.IndexOf(AInstance) = -1 then
    InstanceList.Add(AInstance);
end;

class procedure TEdgeWebBrowser.UnregisterMDIInstance(const AIdentifier: string; AInstance: TEdgeWebBrowser);
var
  InstanceList: TList<TEdgeWebBrowser>;
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

class function TEdgeWebBrowser.GetMDIInstanceCount(const AIdentifier: string): Integer;
var
  InstanceList: TList<TEdgeWebBrowser>;
  Registry: TDictionary<string, TList<TEdgeWebBrowser>>;
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

class function TEdgeWebBrowser.GetOldestMDIInstance(const AIdentifier: string): TEdgeWebBrowser;
var
  InstanceList: TList<TEdgeWebBrowser>;
  Registry: TDictionary<string, TList<TEdgeWebBrowser>>;
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

class function TEdgeWebBrowser.FindMDIInstance(const AIdentifier: string): TEdgeWebBrowser;
begin
  Result := GetOldestMDIInstance(AIdentifier);
end;

class function TEdgeWebBrowser.CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
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

class function TEdgeWebBrowser.CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;
begin
  Result := CanCreateMDIInstance(AUniqueIdentifier, AMaxInstances, ASingleInstance);
end;

class procedure TEdgeWebBrowser.CleanupMDIRegistry;
var
  Pair: TPair<string, TList<TEdgeWebBrowser>>;
  InstanceList: TList<TEdgeWebBrowser>;
  i: Integer;
  Instance: TEdgeWebBrowser;
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

class function TEdgeWebBrowser.GetPopupInstanceRegistry: TDictionary<string, TEdgeWebBrowser>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FPopupInstanceRegistry) then
    FPopupInstanceRegistry := TDictionary<string, TEdgeWebBrowser>.Create;
  Result := FPopupInstanceRegistry;
end;

class procedure TEdgeWebBrowser.RegisterPopupInstance(const AIdentifier: string; AInstance: TEdgeWebBrowser);
var
  Registry: TDictionary<string, TEdgeWebBrowser>;
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

class procedure TEdgeWebBrowser.UnregisterPopupInstance(const AIdentifier: string);
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) or not Assigned(FPopupInstanceRegistry) then
    Exit;

  if FPopupInstanceRegistry.ContainsKey(AIdentifier) then
    FPopupInstanceRegistry.Remove(AIdentifier);
end;

class function TEdgeWebBrowser.FindInstance(const AIdentifier: string): TEdgeWebBrowser;
var
  Registry: TDictionary<string, TEdgeWebBrowser>;
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

class procedure TEdgeWebBrowser.CleanupPopupRegistry;
begin
  if Assigned(FPopupInstanceRegistry) then
  begin
    FPopupInstanceRegistry.Clear;
    FreeAndNil(FPopupInstanceRegistry);
  end;
end;

// Context

procedure TEdgeWebBrowser.CreateComponents(AParentBrowser: TEdgeBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
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

  FForm := TEdgeWebForm.CreateWithArgs(nil, nil);
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

procedure TEdgeWebBrowser.CleanupWebViewResources;
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
//    FBrowser.OnContextMenuRequested := nil;

    FBrowserInitialized := False;
  end;
end;

procedure TEdgeWebBrowser.CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
var
  OldForm: TEdgeWebForm;
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
      Application.CreateForm(TEdgeWebForm, FForm);

      if Assigned(AParentForm) then
      begin
        FForm.Parent := AParentForm;
        FForm.ParentWindow := AParentForm.Handle;
      end;
    end
    else
    begin
      FForm := TEdgeWebForm.CreateWithArgs(AParentForm, nil);
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

constructor TEdgeWebBrowser.Create;
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

constructor TEdgeWebBrowser.Create(const AURL: String);
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

constructor TEdgeWebBrowser.Create(const AURL: String; AParentObject: TObject; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
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

constructor TEdgeWebBrowser.CreateAsBrowser(const AURL: String = '');
begin
  Self.Create(AURL);
end;

constructor TEdgeWebBrowser.CreateAsPopup(AParentBrowser: TEdgeBrowser; const AURL: String = '');
begin
  if not Assigned(AParentBrowser) then
    raise Exception.Create('ParentBrowser cannot be nil for Popup');

  Self.Create(AURL, AParentBrowser);
end;

constructor TEdgeWebBrowser.CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
begin
  if not Assigned(AParentForm) then
    raise Exception.Create('ParentForm cannot be nil for MDI');
  if AParentForm.FormStyle <> fsMDIForm then
    raise Exception.Create('ParentForm must have FormStyle=fsMDIForm to use MDI');

  Self.Create(AURL, AParentForm, ALegacyForm);
end;

// Static Constructors

class function TEdgeWebBrowser.NewBrowser(const AURL: string): TEdgeWebBrowser;
begin
  Result := TEdgeWebBrowser.Create(AURL);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TEdgeWebBrowser.NewPopup(const AURL: string; AParentBrowser: TEdgeBrowser = nil): TEdgeWebBrowser;
begin
  Result := TEdgeWebBrowser.Create(AURL, AParentBrowser);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TEdgeWebBrowser.NewMDI(const AURL: String; AParentForm: TForm = nil): TEdgeWebBrowser;
begin
  Result := TEdgeWebBrowser.Create(AURL, AParentForm);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

destructor TEdgeWebBrowser.Destroy;
begin
  FIsClosing := True;

  if (FUniqueIdentifier <> EmptyStr) and not TEdgeWebBrowser.FFinalizationStarted then
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

procedure TEdgeWebBrowser.EnsureComponentsCreated;
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

procedure TEdgeWebBrowser.InitComponents;
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
  FBrowser.OnAfterCreated := Self.OnAfterCreated;
  FBrowser.OnDocumentTitleChanged := Self.OnDocumentTitleChanged;
  FBrowser.OnNavigationCompleted := Self.OnNavigationCompleted;
  FBrowser.OnNewWindowRequested := Self.OnNewWindowRequested;
  FBrowser.OnWindowCloseRequested := Self.OnWindowCloseRequested;
  FBrowser.OnWebMessageReceived := Self.OnWebMessageReceived;
  FBrowser.OnInitializationError := Self.OnInitializationError;
//  FBrowser.OnContextMenuRequested := Self.OnContextMenuRequested;

  // Cache Path
  if FBrowser.UserDataFolder = EmptyStr then
    FBrowser.UserDataFolder := TUtils.EnsureCacheDirectory(CACHE_PATH);

  // Timer
  FTimer := TTimer.Create(FForm);
  FTimer.Enabled := False;
  FTimer.Interval := 100;
  FTimer.OnTimer := OnTimer;
end;

procedure TEdgeWebBrowser.InitializePopupBrowser;
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

procedure TEdgeWebBrowser.CheckInitializationTimer(Sender: TObject);
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

procedure TEdgeWebBrowser.RestoreParentFormState(Sender: TObject);
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

procedure TEdgeWebBrowser.WaitForBrowserInitialization(const ACallback: TProc);
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

procedure TEdgeWebBrowser.OnAfterCreated(Sender: TObject);
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

procedure TEdgeWebBrowser.OnDocumentTitleChanged(Sender: TCustomEdgeBrowser; const ADocumentTitle: string);
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

procedure TEdgeWebBrowser.OnInitializationError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  raise Exception.Create('EdgeBrowser Initialization Error: ' + aErrorMessage);
end;

procedure TEdgeWebBrowser.OnNavigationCompleted(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: TOleEnum);
begin
  if not FBrowserInitialized and IsSuccess then
  begin
    FBrowserInitialized := True;
    FBrowser.DoOnAfterCreated;
  end;
  ResizeBrowser;
end;

procedure TEdgeWebBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  Self.TryCreateBrowser;
end;

procedure TEdgeWebBrowser.OnWebMessageReceived(Sender: TCustomEdgeBrowser; aArgs: TWebMessageReceivedEventArgs);
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

procedure TEdgeWebBrowser.OnNewWindowRequested(Sender: TCustomEdgeBrowser; aArgs: TNewWindowRequestedEventArgs);
var
  TempBrowser: TEdgeWebBrowser;
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
    TempBrowser := TEdgeWebBrowser.NewPopup(DEFAULT_URL);

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

procedure TEdgeWebBrowser.OnWindowCloseRequested(Sender: TObject);
begin
  PostMessage(FForm.Handle, WM_CLOSE, 0, 0);
end;

procedure TEdgeWebBrowser.OnPopupOpened(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup has completed opening! Instance: ' + TEdgeWebBrowser(Sender).ClassName);
end;

procedure TEdgeWebBrowser.OnPopupClosed(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup has been closed! Instance: ' + TEdgeWebBrowser(Sender).ClassName);
end;

procedure TEdgeWebBrowser.TryCreateBrowser;
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

procedure TEdgeWebBrowser.ResizeBrowser;
begin
  if Assigned(FBrowser) then
  begin
    FBrowser.SetBounds(0, 0, FForm.ClientWidth, FForm.ClientHeight);
    FBrowser.Invalidate;
    FBrowser.Update;
  end;
end;

procedure TEdgeWebBrowser.Show(const AType: TOpenType = TOpenType.Default);
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

procedure TEdgeWebBrowser.ShowModal(const AType: TOpenType = TOpenType.Modal);
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

procedure TEdgeWebBrowser.ShowAsModal(AParentForm: TForm = nil);
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

procedure TEdgeWebBrowser.ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);
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

procedure TEdgeWebBrowser.ShowAsMDI;
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

procedure TEdgeWebBrowser.ShowAsMDI(const AOptions: TMDIOptions);
var
  ExistingInstance: TEdgeWebBrowser;
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

procedure TEdgeWebBrowser.ShowAsMDICustom(AutoShow: Boolean = True);
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

procedure TEdgeWebBrowser.ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
begin
  if not Assigned(FParentForm) then
    Exit;

  if FParentForm.FormStyle <> fsMDIForm then
    Exit;

  Self.ShowAsMDICustom(AutoShow);

  if AutoShow and Assigned(FForm) and MaximizeOnShow then
    FForm.WindowState := wsMaximized;
end;

procedure TEdgeWebBrowser.ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
var
  ExistingBrowser: TEdgeWebBrowser;
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
  TEdgeWebBrowser.FFinalizationStarted := False;

finalization
  TEdgeWebBrowser.CleanupMDIRegistry;
  TEdgeWebBrowser.CleanupPopupRegistry;

end.

