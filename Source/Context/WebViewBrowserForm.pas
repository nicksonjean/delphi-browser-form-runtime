unit WebViewBrowserForm;

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


  uWVBrowser,
  uWVWindowParent,
  uWVTypes,
  uWVTypeLibrary,
  uWVCoreWebView2Args,
  uWVCoreWebView2Deferral,
  uWVLoader,


  UtilsLib,
  BrowserTypes,
  IBrowserFormBase,
  IWebViewBrowserForm;

const
  DEBUG_MODE = false;
  CACHE_PATH = 'WVCustomCache';
  DEFAULT_URL = 'about:blank';
  DEFAULT_WIDTH = 800;
  DEFAULT_HEIGHT = 600;
  DEFAULT_LEGACY_FORM = false;
  DEFAULT_MAX_INSTANCES = 0;

type
  TWebViewBrowser = class;

  TWebViewForm = class(TForm)
  strict private
    FInitialized: Boolean;
    FArgs: TCoreWebView2NewWindowRequestedEventArgs;
    FDeferral: TCoreWebView2Deferral;
    procedure WMSize(var aMessage: TMessage); message WM_SIZE;
    procedure WMWindowPosChanging(var aMessage: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;
  public
    BrowserInstance: IWVBrowserForm;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure CenterToScreenWithMonitor;
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
  end;

  TWebViewBrowser = class(TInterfacedObject, IWVBrowserForm, IBrowserForm)
  private
    FForm: TWebViewForm;
    FBrowser: TWVBrowser;
    FWindowParent: TWVWindowParent;
    FCookie: ICoreWebView2Cookie;
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
    FParentBrowser: TWVBrowser;
    FParentForm: TForm;
    FUniqueIdentifier: String;
    FMaxInstances: Integer;
    FLegacyForm: Boolean;

    // Registry Control
    class var FFinalizationStarted: Boolean;

    // Registry for MDI Instances
    class var FMDIInstanceRegistry: TDictionary<string, TList<TWebViewBrowser>>;
    class function GetMDIInstanceRegistry: TDictionary<string, TList<TWebViewBrowser>>;
    class procedure RegisterMDIInstance(const AIdentifier: string; AInstance: TWebViewBrowser);
    class procedure UnregisterMDIInstance(const AIdentifier: string; AInstance: TWebViewBrowser);
    class function GetMDIInstanceCount(const AIdentifier: string): Integer;
    class function GetOldestMDIInstance(const AIdentifier: string): TWebViewBrowser;
    class function CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
    class procedure CleanupMDIRegistry;

    // Registry for Popup Instances
    class var FPopupInstanceRegistry: TDictionary<string, TWebViewBrowser>;
    class function GetPopupInstanceRegistry: TDictionary<string, TWebViewBrowser>;
    class procedure RegisterPopupInstance(const AIdentifier: string; AInstance: TWebViewBrowser);
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
    procedure CreateComponents(AParentBrowser: TWVBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
    procedure CleanupWebViewResources;

    // MDI Methods
    procedure CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
    procedure ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);

    // Event Methods
    procedure OnTimer(Sender: TObject);
    procedure OnAfterCreated(Sender: TObject);
    procedure OnDocumentTitleChanged(Sender: TObject);
    procedure OnInitializationError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NavigationCompletedEventArgs);
    procedure OnWebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
    procedure OnNewWindowRequested(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
    procedure OnWindowCloseRequested(Sender: TObject);
    procedure OnPopupOpened(Sender: TObject);
    procedure OnPopupClosed(Sender: TObject);
    procedure OnContextMenuRequested(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2ContextMenuRequestedEventArgs);

    // Loader
    procedure ConfigureWebView2Loader;
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
    function GetParentWebViewProp: TWVBrowser;
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
    procedure SetParentWebViewProp(const Value: TWVBrowser);
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
    constructor CreateAsPopup(AParentBrowser: TWVBrowser; const AURL: String = '');
    constructor CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
    destructor Destroy; override;

    // Alias Static Constructors
    class function NewBrowser(const AURL: string): TWebViewBrowser;
    class function NewPopup(const AURL: string; AParentBrowser: TWVBrowser = nil): TWebViewBrowser;
    class function NewMDI(const AURL: String; AParentForm: TForm = nil): TWebViewBrowser;

    // Static Method for Popup Forms
    class function FindInstance(const AIdentifier: string): TWebViewBrowser;

    // Static Method for MDI Forms
    class function FindMDIInstance(const AIdentifier: string): TWebViewBrowser;
    class function CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;

    // Fluent Concrete Chainable Methods
    function SetWidth(const AWidth: Integer): TWebViewBrowser;
    function SetHeight(const AHeight: Integer): TWebViewBrowser;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): TWebViewBrowser;
    function SetActionButtons(const AButtons: TBorderIcons): TWebViewBrowser;
    function SetResizable(const AResize: Boolean): TWebViewBrowser;
    function SetMovable(const AMove: Boolean): TWebViewBrowser;
    function SetTitleBar(const ATitleBar: Boolean): TWebViewBrowser;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TWebViewBrowser;
    function SetAlpha(const AAlpha: Boolean): TWebViewBrowser;
    function SetURL(const AURL: String): TWebViewBrowser;
    function SetParentForm(const AParentForm: TForm): TWebViewBrowser;
    function SetParentBrowser(const AParentBrowser: TWVBrowser): TWebViewBrowser;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): TWebViewBrowser;
    function SetMaxInstances(const AMaxInstances: Integer): TWebViewBrowser;
    function SetLegacyForm(const ALegacyForm: Boolean): TWebViewBrowser;
    function SetWindowOpened(const AEvent: TNotifyEvent): TWebViewBrowser;
    function SetWindowClosed(const AEvent: TNotifyEvent): TWebViewBrowser;
    function SetHTMLContent(const AHTMLContent: String): TWebViewBrowser;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): TWebViewBrowser;
    function SetMessageSender(const AMessage: String): TWebViewBrowser;

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

    // WebView Interface Methods
    function IWVSetWidth(const AWidth: Integer): IWVBrowserForm;
    function IWVSetHeight(const AHeight: Integer): IWVBrowserForm;
    function IWVSetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): IWVBrowserForm;
    function IWVSetActionButtons(const AButtons: TBorderIcons): IWVBrowserForm;
    function IWVSetResizable(const AResize: Boolean): IWVBrowserForm;
    function IWVSetMovable(const AMove: Boolean): IWVBrowserForm;
    function IWVSetTitleBar(const ATitleBar: Boolean): IWVBrowserForm;
    function IWVSetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IWVBrowserForm;
    function IWVSetAlpha(const AAlpha: Boolean): IWVBrowserForm;
    function IWVSetURL(const AURL: String): IWVBrowserForm;
    function IWVSetParentForm(const AParentForm: TForm): IWVBrowserForm;
    function IWVSetParentBrowser(const AParentBrowser: TWVBrowser): IWVBrowserForm;
    function IWVSetUniqueIdentifier(const AUniqueIdentifier: String): IWVBrowserForm;
    function IWVSetMaxInstances(const AMaxInstances: Integer): IWVBrowserForm;
    function IWVSetLegacyForm(const ALegacyForm: Boolean): IWVBrowserForm;
    function IWVSetWindowOpened(const AEvent: TNotifyEvent): IWVBrowserForm;
    function IWVSetWindowClosed(const AEvent: TNotifyEvent): IWVBrowserForm;
    function IWVSetHTMLContent(const AHTMLContent: String): IWVBrowserForm;
    function IWVSetMessageReceiver(const AMessage: TMessageReceiverCallback): IWVBrowserForm;
    function IWVSetMessageSender(const AMessage: String): IWVBrowserForm;

    // Method Resolution Interfaces
    function IWVBrowserForm.SetWidth = IWVSetWidth;
    function IWVBrowserForm.SetHeight = IWVSetHeight;
    function IWVBrowserForm.SetCaption = IWVSetCaption;
    function IWVBrowserForm.SetActionButtons = IWVSetActionButtons;
    function IWVBrowserForm.SetResizable = IWVSetResizable;
    function IWVBrowserForm.SetMovable = IWVSetMovable;
    function IWVBrowserForm.SetTitleBar = IWVSetTitleBar;
    function IWVBrowserForm.SetCookie = IWVSetCookie;
    function IWVBrowserForm.SetAlpha = IWVSetAlpha;
    function IWVBrowserForm.SetURL = IWVSetURL;
    function IWVBrowserForm.SetParentForm = IWVSetParentForm;
    function IWVBrowserForm.SetParentBrowser = IWVSetParentBrowser;
    function IWVBrowserForm.SetUniqueIdentifier = IWVSetUniqueIdentifier;
    function IWVBrowserForm.SetMaxInstances = IWVSetMaxInstances;
    function IWVBrowserForm.SetLegacyForm = IWVSetLegacyForm;
    function IWVBrowserForm.SetWindowOpened = IWVSetWindowOpened;
    function IWVBrowserForm.SetWindowClosed = IWVSetWindowClosed;
    function IWVBrowserForm.SetHTMLContent = IWVSetHTMLContent;
    function IWVBrowserForm.SetMessageReceiver = IWVSetMessageReceiver;
    function IWVBrowserForm.SetMessageSender = IWVSetMessageSender;

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
    property ParentWebView: TWVBrowser read GetParentWebViewProp write SetParentWebViewProp;
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

{ TWebViewForm }

procedure TWebViewForm.CenterToScreenWithMonitor;
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

constructor TWebViewForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
end;

constructor TWebViewForm.CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
begin
  inherited CreateNew(AOwner);

  if Assigned(aArgs) then
  begin
    FArgs := TCoreWebView2NewWindowRequestedEventArgs.Create(aArgs);
    FDeferral := TCoreWebView2Deferral.Create(FArgs.Deferral);
  end;
end;

procedure TWebViewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TWebViewBrowser).FIsClosing := True;

    if Assigned((BrowserInstance as TWebViewBrowser).FTimer) then
    begin
      (BrowserInstance as TWebViewBrowser).FTimer.Enabled := False;
      (BrowserInstance as TWebViewBrowser).FTimer.OnTimer := nil;
    end;

    if Assigned((BrowserInstance as TWebViewBrowser).FCheckTimer) then
    begin
      (BrowserInstance as TWebViewBrowser).FCheckTimer.Enabled := False;
      (BrowserInstance as TWebViewBrowser).FCheckTimer.OnTimer := nil;
    end;

    if Assigned((BrowserInstance as TWebViewBrowser).FCallbackList) then
    begin
      while (BrowserInstance as TWebViewBrowser).FCallbackList.Count > 0 do
      begin
        if Assigned((BrowserInstance as TWebViewBrowser).FCallbackList[0].Timer) then
        begin
          (BrowserInstance as TWebViewBrowser).FCallbackList[0].Timer.Enabled := False;
          (BrowserInstance as TWebViewBrowser).FCallbackList[0].Timer.OnTimer := nil;
        end;
        (BrowserInstance as TWebViewBrowser).FCallbackList.Delete(0);
      end;
    end;

    if Assigned((BrowserInstance as TWebViewBrowser).FBrowser) then
    begin
      if Assigned((BrowserInstance as TWebViewBrowser).FCookie) then
        (BrowserInstance as TWebViewBrowser).FCookie := nil;

      if (BrowserInstance as TWebViewBrowser).FBrowserInitialized then
      begin
        (BrowserInstance as TWebViewBrowser).FBrowser.OnAfterCreated := nil;
        (BrowserInstance as TWebViewBrowser).FBrowser.OnDocumentTitleChanged := nil;
        (BrowserInstance as TWebViewBrowser).FBrowser.OnInitializationError := nil;
        (BrowserInstance as TWebViewBrowser).FBrowser.OnNewWindowRequested := nil;
        (BrowserInstance as TWebViewBrowser).FBrowser.OnWindowCloseRequested := nil;
        (BrowserInstance as TWebViewBrowser).FBrowser.OnNavigationCompleted := nil;
        (BrowserInstance as TWebViewBrowser).FBrowser.OnWebMessageReceived := nil;
        (BrowserInstance as TWebViewBrowser).FBrowserInitialized := False;
      end;

      (BrowserInstance as TWebViewBrowser).FBrowser.NotifyParentWindowPositionChanged;
    end;

    if Assigned((BrowserInstance as TWebViewBrowser).FOnWindowClosed) then
      (BrowserInstance as TWebViewBrowser).FOnWindowClosed(BrowserInstance as TWebViewBrowser);
  end;
  Action := caFree;
end;

procedure TWebViewForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TWebViewBrowser).FIsClosing := True;

    if Assigned((BrowserInstance as TWebViewBrowser).FTimer) then
      (BrowserInstance as TWebViewBrowser).FTimer.Enabled := False;

    if Assigned((BrowserInstance as TWebViewBrowser).FCheckTimer) then
      (BrowserInstance as TWebViewBrowser).FCheckTimer.Enabled := False;

    if Assigned((BrowserInstance as TWebViewBrowser).FBrowser) then
    begin
      if (BrowserInstance as TWebViewBrowser).FBrowserInitialized then
        (BrowserInstance as TWebViewBrowser).FBrowser.ExecuteScript('window.dispatchEvent(new Event("beforeunload"))');

      if Assigned((BrowserInstance as TWebViewBrowser).FCookie) then
        (BrowserInstance as TWebViewBrowser).FCookie := nil;
    end;
  end;
end;

procedure TWebViewForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FArgs) then
    FreeAndNil(FArgs);
  if Assigned(FDeferral) then
    FreeAndNil(FDeferral);
  BrowserInstance := nil;
end;

procedure TWebViewForm.FormResize(Sender: TObject);
begin
  if Assigned(BrowserInstance) then
    (BrowserInstance as TWebViewBrowser).ResizeBrowser;
end;

procedure TWebViewForm.FormShow(Sender: TObject);
begin
  if not FInitialized then
  begin
    CenterToScreenWithMonitor;
    FInitialized := True;
  end;
  if Assigned(BrowserInstance) then
    (BrowserInstance as TWebViewBrowser).TryCreateBrowser;
end;

procedure TWebViewForm.WMMove(var aMessage: TWMMove);
begin
  inherited;

  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TWebViewBrowser).FBrowser) then
    (BrowserInstance as TWebViewBrowser).FBrowser.NotifyParentWindowPositionChanged;
end;

procedure TWebViewForm.WMMoving(var aMessage: TMessage);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TWebViewBrowser).FMovable then
  begin
    CenterToScreenWithMonitor;
    aMessage.Result := 1;
    Exit;
  end;
  inherited;
  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TWebViewBrowser).FBrowser) then
    (BrowserInstance as TWebViewBrowser).FBrowser.NotifyParentWindowPositionChanged;
end;

procedure TWebViewForm.WMSize(var aMessage: TMessage);
begin
  inherited;
  if Assigned(BrowserInstance) then
    (BrowserInstance as TWebViewBrowser).ResizeBrowser;
end;

procedure TWebViewForm.WMWindowPosChanging(var aMessage: TWMWindowPosChanging);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TWebViewBrowser).FMovable then
  begin
    Self.CenterToScreenWithMonitor;
    aMessage.WindowPos^.flags := aMessage.WindowPos^.flags or SWP_NOMOVE;
  end;
  inherited;
end;

{ TWebViewBrowser }

// Getters

function TWebViewBrowser.GetWidthProp: Integer;
begin
  Result := FWidth;
end;

function TWebViewBrowser.GetHeightProp: Integer;
begin
  Result := FHeight;
end;

function TWebViewBrowser.GetCaptionProp: string;
begin
  Result := FCaption;
end;

function TWebViewBrowser.GetCaptionPositionProp: TPositionCaption;
begin
  Result := FCaptionPosition;
end;

function TWebViewBrowser.GetActionButtonsProp: TBorderIcons;
begin
  Result := FForm.BorderIcons;
end;

function TWebViewBrowser.GetResizableProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsSizeable;
end;

function TWebViewBrowser.GetMovableProp: Boolean;
begin
  Result := FMovable;
end;

function TWebViewBrowser.GetPopupProp: Boolean;
begin
  Result:= FIsPopup;
end;

function TWebViewBrowser.GetTitleBarProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsNone;
end;

function TWebViewBrowser.GetInstanceProp: TComponent;
begin
  Result := FBrowser;
end;

function TWebViewBrowser.GetCookieNameProp: String;
begin
  Result := FCookieName;
end;

function TWebViewBrowser.GetCookieValueProp: String;
begin
  Result := FCookieValue;
end;

function TWebViewBrowser.GetCookieDomainProp: String;
begin
  Result := FCookieDomain;
end;

function TWebViewBrowser.GetCookiePathProp: String;
begin
  Result := FCookiePath;
end;

function TWebViewBrowser.GetAlphaProp: Boolean;
begin
  Result := FAlpha;
end;

function TWebViewBrowser.GetURLProp: String;
begin
  Result := FURL;
end;

function TWebViewBrowser.GetParentFormProp: TForm;
begin
  Result := FParentForm;
end;

function TWebViewBrowser.GetParentWebViewProp: TWVBrowser;
begin
  Result := FParentBrowser;
end;

function TWebViewBrowser.GetParentBrowserProp: TComponent;
begin
  Result := FParentBrowser as TComponent;
end;

function TWebViewBrowser.GetUniqueIdentifierProp: String;
begin
  Result := FUniqueIdentifier;
end;

function TWebViewBrowser.GetMaxInstancesProp: Integer;
begin
  Result := FMaxInstances;
end;

function TWebViewBrowser.GetLegacyFormProp: Boolean;
begin
  Result := FLegacyForm;
end;

function TWebViewBrowser.GetWindowOpenedProp: TNotifyEvent;
begin
  Result := FOnWindowOpened;
end;

function TWebViewBrowser.GetWindowClosedProp: TNotifyEvent;
begin
  Result := FOnWindowClosed;
end;

function TWebViewBrowser.ReadMessageReceiverProp: TMessageReceiverCallback;
begin
  Result := FMessageReceiver;
end;

function TWebViewBrowser.ReadMessageSenderProp: string;
begin
  Result := FMessageSender;
end;

// Setters

procedure TWebViewBrowser.SetWidthProp(const Value: Integer);
begin
  SetWidth(Value);
end;

procedure TWebViewBrowser.SetHeightProp(const Value: Integer);
begin
  SetHeight(Value);
end;

procedure TWebViewBrowser.SetCaptionProp(const Value: string);
begin
  SetCaption(Value, FCaptionPosition);
end;

procedure TWebViewBrowser.SetCaptionPositionProp(const Value: TPositionCaption);
begin
  FCaptionPosition := Value;
  SetCaption(FCaption, Value);
end;

procedure TWebViewBrowser.SetActionButtonsProp(const Value: TBorderIcons);
begin
  SetActionButtons(Value);
end;

procedure TWebViewBrowser.SetResizableProp(const Value: Boolean);
begin
  SetResizable(Value);
end;

procedure TWebViewBrowser.SetMovableProp(const Value: Boolean);
begin
  SetMovable(Value);
end;

procedure TWebViewBrowser.SetTitleBarProp(const Value: Boolean);
begin
  SetTitleBar(Value);
end;

procedure TWebViewBrowser.SetCookieNameProp(const Value: String);
begin
  SetCookie(Value, FCookieValue, FCookieDomain, FCookiePath);
end;

procedure TWebViewBrowser.SetCookieValueProp(const Value: String);
begin
  FCookieValue := Value;
  SetCookie(FCookieName, Value, FCookieDomain, FCookiePath);
end;

procedure TWebViewBrowser.SetCookieDomainProp(const Value: String);
begin
  FCookieDomain := Value;
  SetCookie(FCookieName, FCookieValue, Value, FCookiePath);
end;

procedure TWebViewBrowser.SetCookiePathProp(const Value: String);
begin
  FCookiePath := Value;
  SetCookie(FCookieName, FCookieValue, FCookieDomain, Value);
end;

procedure TWebViewBrowser.SetAlphaProp(const Value: Boolean);
begin
  SetAlpha(Value);
end;

procedure TWebViewBrowser.SetURLProp(const Value: String);
begin
  SetURL(Value);
end;

procedure TWebViewBrowser.SetParentFormProp(const Value: TForm);
begin
  SetParentForm(Value);
end;

procedure TWebViewBrowser.SetParentWebViewProp(const Value: TWVBrowser);
begin
  SetParentBrowser(Value);
end;

procedure TWebViewBrowser.SetParentBrowserProp(const Value: TComponent);
begin
  if Value is TWVBrowser then
    SetParentWebViewProp(TWVBrowser(Value))
  else if Assigned(Value) then
    raise Exception.Create('ParentBrowser must be TWVBrowser for WebView2')
  else
    SetParentBrowserProp(nil);
end;

procedure TWebViewBrowser.SetUniqueIdentifierProp(const Value: String);
begin
  SetUniqueIdentifier(Value);
end;

procedure TWebViewBrowser.SetMaxInstancesProp(const Value: Integer);
begin
  SetMaxInstances(Value);
end;

procedure TWebViewBrowser.SetLegacyFormProp(const Value: Boolean);
begin
  SetLegacyForm(Value);
end;

procedure TWebViewBrowser.SetWindowOpenedProp(const Value: TNotifyEvent);
begin
  SetWindowOpened(Value);
end;

procedure TWebViewBrowser.SetWindowClosedProp(const Value: TNotifyEvent);
begin
  SetWindowClosed(Value);
end;

procedure TWebViewBrowser.SetMessageReceiverProp(const Value: TMessageReceiverCallback);
begin
  SetMessageReceiver(Value);
end;

procedure TWebViewBrowser.SetMessageSenderProp(const Value: string);
begin
  SetMessageSender(Value);
end;

// Chainable Methods - TWebViewBrowser

function TWebViewBrowser.SetWidth(const AWidth: Integer): TWebViewBrowser;
begin
  FWidth := AWidth;
  if Assigned(FForm) then
  begin
    FForm.ClientWidth := AWidth;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TWebViewBrowser.SetHeight(const AHeight: Integer): TWebViewBrowser;
begin
  FHeight := AHeight;
  if Assigned(FForm) then
  begin
    FForm.ClientHeight := AHeight;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TWebViewBrowser.SetCaption(const ACaption: String; APosition: TPositionCaption): TWebViewBrowser;
begin
  FCaption := ACaption;
  FCaptionPosition := APosition;
  if FBrowserInitialized then
    Self.OnDocumentTitleChanged(FBrowser);
  Result := Self;
end;

function TWebViewBrowser.SetActionButtons(const AButtons: TBorderIcons): TWebViewBrowser;
begin
  FForm.BorderIcons := FForm.BorderIcons - AButtons;
  Result := Self;
end;

function TWebViewBrowser.SetResizable(const AResize: Boolean): TWebViewBrowser;
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

function TWebViewBrowser.SetMovable(const AMove: Boolean): TWebViewBrowser;
begin
  FMovable := AMove;
  if Assigned(FForm) and not AMove then
    FForm.CenterToScreenWithMonitor;
  Result := Self;
end;

function TWebViewBrowser.SetTitleBar(const ATitleBar: Boolean): TWebViewBrowser;
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

function TWebViewBrowser.SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TWebViewBrowser;
begin
  FCookieName := ACookieName;
  FCookieValue := ACookieValue;
  FCookieDomain := ACookieDomain;
  FCookiePath := ACookiePath;

  if Assigned(FCookie) then
    FCookie := nil;

  if FBrowserInitialized and Assigned(FBrowser) and Assigned(FBrowser.CoreWebView2) then
  begin
    FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
    if Assigned(FCookie) then
      FBrowser.AddOrUpdateCookie(FCookie);
  end;

  Result := Self;
end;

function TWebViewBrowser.SetAlpha(const AAlpha: Boolean): TWebViewBrowser;
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

function TWebViewBrowser.SetURL(const AURL: String): TWebViewBrowser;
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

function TWebViewBrowser.SetParentForm(const AParentForm: TForm): TWebViewBrowser;
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

function TWebViewBrowser.SetParentBrowser(const AParentBrowser: TWVBrowser): TWebViewBrowser;
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

function TWebViewBrowser.SetUniqueIdentifier(const AUniqueIdentifier: String): TWebViewBrowser;
begin
  if FUniqueIdentifier <> EmptyStr then
    UnregisterPopupInstance(FUniqueIdentifier);

  FUniqueIdentifier := AUniqueIdentifier;

  if AUniqueIdentifier <> EmptyStr then
    RegisterPopupInstance(AUniqueIdentifier, Self);

  Result := Self;
end;

function TWebViewBrowser.SetMaxInstances(const AMaxInstances: Integer): TWebViewBrowser;
begin
  FMaxInstances := AMaxInstances;
  Result := Self;
end;

function TWebViewBrowser.SetLegacyForm(const ALegacyForm: Boolean): TWebViewBrowser;
begin
  FLegacyForm := ALegacyForm;
  Result := Self;
end;

function TWebViewBrowser.SetWindowOpened(const AEvent: TNotifyEvent): TWebViewBrowser;
begin
  FOnWindowOpened := AEvent;
  Result := Self;
end;

function TWebViewBrowser.SetWindowClosed(const AEvent: TNotifyEvent): TWebViewBrowser;
begin
  FOnWindowClosed := AEvent;
  Result := Self;
end;

function TWebViewBrowser.SetHTMLContent(const AHTMLContent: String): TWebViewBrowser;
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

function TWebViewBrowser.SetMessageReceiver(const AMessage: TMessageReceiverCallback): TWebViewBrowser;
begin
  FMessageReceiver := AMessage;
  Result := Self;
end;

function TWebViewBrowser.SetMessageSender(const AMessage: String): TWebViewBrowser;
begin
  FMessageSender := AMessage;
  if Assigned(FBrowser) then
    FBrowser.PostWebMessageAsString(FMessageSender);
  Result := Self;
end;

// Interface Methods - IWVBrowserForm

function TWebViewBrowser.IWVSetWidth(const AWidth: Integer): IWVBrowserForm;
begin
  Self.SetWidth(AWidth);
  Result := Self;
end;

function TWebViewBrowser.IWVSetHeight(const AHeight: Integer): IWVBrowserForm;
begin
  Self.SetHeight(AHeight);
  Result := Self;
end;

function TWebViewBrowser.IWVSetCaption(const ACaption: String; APosition: TPositionCaption): IWVBrowserForm;
begin
  Self.SetCaption(ACaption, APosition);
  Result := Self;
end;

function TWebViewBrowser.IWVSetActionButtons(const AButtons: TBorderIcons): IWVBrowserForm;
begin
  Self.SetActionButtons(AButtons);
  Result := Self;
end;

function TWebViewBrowser.IWVSetResizable(const AResize: Boolean): IWVBrowserForm;
begin
  Self.SetResizable(AResize);
  Result := Self;
end;

function TWebViewBrowser.IWVSetMovable(const AMove: Boolean): IWVBrowserForm;
begin
  Self.SetMovable(AMove);
  Result := Self;
end;

function TWebViewBrowser.IWVSetTitleBar(const ATitleBar: Boolean): IWVBrowserForm;
begin
  Self.SetTitleBar(ATitleBar);
  Result := Self;
end;

function TWebViewBrowser.IWVSetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String): IWVBrowserForm;
begin
  Self.SetCookie(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
  Result := Self;
end;

function TWebViewBrowser.IWVSetAlpha(const AAlpha: Boolean): IWVBrowserForm;
begin
  Self.SetAlpha(AAlpha);
  Result := Self;
end;

function TWebViewBrowser.IWVSetURL(const AURL: String): IWVBrowserForm;
begin
  Self.SetURL(AURL);
  Result := Self;
end;

function TWebViewBrowser.IWVSetParentForm(const AParentForm: TForm): IWVBrowserForm;
begin
  Self.SetParentForm(AParentForm);
  Result := Self;
end;

function TWebViewBrowser.IWVSetParentBrowser(const AParentBrowser: TWVBrowser): IWVBrowserForm;
begin
  Self.SetParentBrowser(AParentBrowser);
  Result := Self;
end;

function TWebViewBrowser.IWVSetUniqueIdentifier(const AUniqueIdentifier: String): IWVBrowserForm;
begin
  Self.SetUniqueIdentifier(AUniqueIdentifier);
  Result := Self;
end;

function TWebViewBrowser.IWVSetMaxInstances(const AMaxInstances: Integer): IWVBrowserForm;
begin
  Self.SetMaxInstances(AMaxInstances);
  Result := Self;
end;

function TWebViewBrowser.IWVSetLegacyForm(const ALegacyForm: Boolean): IWVBrowserForm;
begin
  Self.SetLegacyForm(ALegacyForm);
  Result := Self;
end;

function TWebViewBrowser.IWVSetWindowOpened(const AEvent: TNotifyEvent): IWVBrowserForm;
begin
  Self.SetWindowOpened(AEvent);
  Result := Self;
end;

function TWebViewBrowser.IWVSetWindowClosed(const AEvent: TNotifyEvent): IWVBrowserForm;
begin
  Self.SetWindowClosed(AEvent);
  Result := Self;
end;

function TWebViewBrowser.IWVSetHTMLContent(const AHTMLContent: String): IWVBrowserForm;
begin
  Self.SetHTMLContent(AHTMLContent);
  Result := Self;
end;

function TWebViewBrowser.IWVSetMessageReceiver(const AMessage: TMessageReceiverCallback): IWVBrowserForm;
begin
  Self.SetMessageReceiver(AMessage);
  Result := Self;
end;

function TWebViewBrowser.IWVSetMessageSender(const AMessage: String): IWVBrowserForm;
begin
  Self.SetMessageSender(AMessage);
  Result := Self;
end;

// Interface Methods - IBrowserForm

function TWebViewBrowser.ISetWidth(const AWidth: Integer): IBrowserForm;
begin
  Self.SetWidth(AWidth);
  Result := Self;
end;

function TWebViewBrowser.ISetHeight(const AHeight: Integer): IBrowserForm;
begin
  Self.SetHeight(AHeight);
  Result := Self;
end;

function TWebViewBrowser.ISetCaption(const ACaption: String; APosition: TPositionCaption): IBrowserForm;
begin
  Self.SetCaption(ACaption, APosition);
  Result := Self;
end;

function TWebViewBrowser.ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
begin
  Self.SetActionButtons(AButtons);
  Result := Self;
end;

function TWebViewBrowser.ISetResizable(const AResize: Boolean): IBrowserForm;
begin
  Self.SetResizable(AResize);
  Result := Self;
end;

function TWebViewBrowser.ISetMovable(const AMove: Boolean): IBrowserForm;
begin
  Self.SetMovable(AMove);
  Result := Self;
end;

function TWebViewBrowser.ISetTitleBar(const ATitleBar: Boolean): IBrowserForm;
begin
  Self.SetTitleBar(ATitleBar);
  Result := Self;
end;

function TWebViewBrowser.ISetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String): IBrowserForm;
begin
  Self.SetCookie(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
  Result := Self;
end;

function TWebViewBrowser.ISetAlpha(const AAlpha: Boolean): IBrowserForm;
begin
  Self.SetAlpha(AAlpha);
  Result := Self;
end;

function TWebViewBrowser.ISetURL(const AURL: String): IBrowserForm;
begin
  Self.SetURL(AURL);
  Result := Self;
end;

function TWebViewBrowser.ISetParentForm(const AParentForm: TForm): IBrowserForm;
begin
  Self.SetParentForm(AParentForm);
  Result := Self;
end;

function TWebViewBrowser.ISetParentBrowser(const AParentBrowser: TComponent): IBrowserForm;
begin
  if AParentBrowser is TWVBrowser then
    Self.SetParentBrowser(TWVBrowser(AParentBrowser))
  else if Assigned(AParentBrowser) then
    raise Exception.Create('ParentBrowser must be TWVBrowser for WebView2')
  else
    Self.SetParentBrowser(nil);
  Result := Self;
end;

function TWebViewBrowser.ISetUniqueIdentifier(const AUniqueIdentifier: String): IBrowserForm;
begin
  Self.SetUniqueIdentifier(AUniqueIdentifier);
  Result := Self;
end;

function TWebViewBrowser.ISetMaxInstances(const AMaxInstances: Integer): IBrowserForm;
begin
  Self.SetMaxInstances(AMaxInstances);
  Result := Self;
end;

function TWebViewBrowser.ISetLegacyForm(const ALegacyForm: Boolean): IBrowserForm;
begin
  Self.SetLegacyForm(ALegacyForm);
  Result := Self;
end;

function TWebViewBrowser.ISetWindowOpened(const AEvent: TNotifyEvent): IBrowserForm;
begin
  Self.SetWindowOpened(AEvent);
  Result := Self;
end;

function TWebViewBrowser.ISetWindowClosed(const AEvent: TNotifyEvent): IBrowserForm;
begin
  Self.SetWindowClosed(AEvent);
  Result := Self;
end;

function TWebViewBrowser.ISetHTMLContent(const AHTMLContent: String): IBrowserForm;
begin
  Self.SetHTMLContent(AHTMLContent);
  Result := Self;
end;

function TWebViewBrowser.ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IBrowserForm;
begin
  Self.SetMessageReceiver(AMessage);
  Result := Self;
end;

function TWebViewBrowser.ISetMessageSender(const AMessage: String): IBrowserForm;
begin
  Self.SetMessageSender(AMessage);
  Result := Self;
end;

// Registry MDI

class function TWebViewBrowser.GetMDIInstanceRegistry: TDictionary<string, TList<TWebViewBrowser>>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FMDIInstanceRegistry) then
    FMDIInstanceRegistry := TDictionary<string, TList<TWebViewBrowser>>.Create;
  Result := FMDIInstanceRegistry;
end;

class procedure TWebViewBrowser.RegisterMDIInstance(const AIdentifier: string; AInstance: TWebViewBrowser);
var
  InstanceList: TList<TWebViewBrowser>;
  Registry: TDictionary<string, TList<TWebViewBrowser>>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetMDIInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if not Registry.TryGetValue(AIdentifier, InstanceList) then
  begin
    InstanceList := TList<TWebViewBrowser>.Create;
    Registry.Add(AIdentifier, InstanceList);
  end;

  if InstanceList.IndexOf(AInstance) = -1 then
    InstanceList.Add(AInstance);
end;

class procedure TWebViewBrowser.UnregisterMDIInstance(const AIdentifier: string; AInstance: TWebViewBrowser);
var
  InstanceList: TList<TWebViewBrowser>;
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

class function TWebViewBrowser.GetMDIInstanceCount(const AIdentifier: string): Integer;
var
  InstanceList: TList<TWebViewBrowser>;
  Registry: TDictionary<string, TList<TWebViewBrowser>>;
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

class function TWebViewBrowser.GetOldestMDIInstance(const AIdentifier: string): TWebViewBrowser;
var
  InstanceList: TList<TWebViewBrowser>;
  Registry: TDictionary<string, TList<TWebViewBrowser>>;
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

class function TWebViewBrowser.FindMDIInstance(const AIdentifier: string): TWebViewBrowser;
begin
  Result := GetOldestMDIInstance(AIdentifier);
end;

class function TWebViewBrowser.CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
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

class function TWebViewBrowser.CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;
begin
  Result := CanCreateMDIInstance(AUniqueIdentifier, AMaxInstances, ASingleInstance);
end;

class procedure TWebViewBrowser.CleanupMDIRegistry;
var
  Pair: TPair<string, TList<TWebViewBrowser>>;
  InstanceList: TList<TWebViewBrowser>;
  i: Integer;
  Instance: TWebViewBrowser;
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

class function TWebViewBrowser.GetPopupInstanceRegistry: TDictionary<string, TWebViewBrowser>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FPopupInstanceRegistry) then
    FPopupInstanceRegistry := TDictionary<string, TWebViewBrowser>.Create;
  Result := FPopupInstanceRegistry;
end;

class procedure TWebViewBrowser.RegisterPopupInstance(const AIdentifier: string; AInstance: TWebViewBrowser);
var
  Registry: TDictionary<string, TWebViewBrowser>;
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

class procedure TWebViewBrowser.UnregisterPopupInstance(const AIdentifier: string);
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) or not Assigned(FPopupInstanceRegistry) then
    Exit;

  if FPopupInstanceRegistry.ContainsKey(AIdentifier) then
    FPopupInstanceRegistry.Remove(AIdentifier);
end;

class function TWebViewBrowser.FindInstance(const AIdentifier: string): TWebViewBrowser;
var
  Registry: TDictionary<string, TWebViewBrowser>;
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

class procedure TWebViewBrowser.CleanupPopupRegistry;
begin
  if Assigned(FPopupInstanceRegistry) then
  begin
    FPopupInstanceRegistry.Clear;
    FreeAndNil(FPopupInstanceRegistry);
  end;
end;

// Context

procedure TWebViewBrowser.ConfigureWebView2Loader;
begin
  if not Assigned(GlobalWebView2Loader) then
  begin
    GlobalWebView2Loader := TWVLoader.Create(nil);
    GlobalWebView2Loader.UserDataFolder := TUtils.EnsureCacheDirectory(CACHE_PATH);
    GlobalWebView2Loader.LoaderDllPath := ExtractFilePath(Application.ExeName) + 'WebView2\WV\WebView2Loader.dll';
    GlobalWebView2Loader.StartWebView2;
  end;
end;

procedure TWebViewBrowser.CreateComponents(AParentBrowser: TWVBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
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

  Self.ConfigureWebView2Loader;

  FForm := TWebViewForm.CreateWithArgs(nil, nil);
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

procedure TWebViewBrowser.CleanupWebViewResources;
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

procedure TWebViewBrowser.CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
var
  OldForm: TWebViewForm;
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

  Self.ConfigureWebView2Loader;

  try

    if ALegacyForm then
    begin
      Application.CreateForm(TWebViewForm, FForm);

      if Assigned(AParentForm) then
      begin
        FForm.Parent := AParentForm;
        FForm.ParentWindow := AParentForm.Handle;
      end;
    end
    else
    begin
      FForm := TWebViewForm.CreateWithArgs(AParentForm, nil);
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

constructor TWebViewBrowser.Create;
begin
  inherited Create;

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

constructor TWebViewBrowser.Create(const AURL: String);
begin
  inherited Create;

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

constructor TWebViewBrowser.Create(const AURL: String; AParentObject: TObject; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
begin
  inherited Create;

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
  else if AParentObject is TWVBrowser then
  begin
    FParentBrowser := TWVBrowser(AParentObject);
    Self.CreateComponents(TWVBrowser(AParentObject), true, AURL);
    FComponentsCreated := True;
  end
  else
  begin
    Self.CreateComponents(nil, false, AURL);
    FComponentsCreated := True;
  end;
end;

constructor TWebViewBrowser.CreateAsBrowser(const AURL: String = '');
begin
  Self.Create(AURL);
end;

constructor TWebViewBrowser.CreateAsPopup(AParentBrowser: TWVBrowser; const AURL: String = '');
begin
  if not Assigned(AParentBrowser) then
    raise Exception.Create('ParentBrowser cannot be nil for Popup');

  Self.Create(AURL, AParentBrowser);
end;

constructor TWebViewBrowser.CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
begin
  if not Assigned(AParentForm) then
    raise Exception.Create('ParentForm cannot be nil for MDI');
  if AParentForm.FormStyle <> fsMDIForm then
    raise Exception.Create('ParentForm must have FormStyle=fsMDIForm to use MDI');

  Self.Create(AURL, AParentForm, ALegacyForm);
end;

// Static Constructors

class function TWebViewBrowser.NewBrowser(const AURL: string): TWebViewBrowser;
begin
  Result := TWebViewBrowser.Create(AURL);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TWebViewBrowser.NewPopup(const AURL: string; AParentBrowser: TWVBrowser = nil): TWebViewBrowser;
begin
  Result := TWebViewBrowser.Create(AURL, AParentBrowser);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TWebViewBrowser.NewMDI(const AURL: String; AParentForm: TForm): TWebViewBrowser;
begin
  Result := TWebViewBrowser.Create(AURL, AParentForm);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

destructor TWebViewBrowser.Destroy;
begin
  FIsClosing := True;

  if (FUniqueIdentifier <> EmptyStr) and not TWebViewBrowser.FFinalizationStarted then
  begin
    UnregisterPopupInstance(FUniqueIdentifier);
    UnregisterMDIInstance(FUniqueIdentifier, Self);
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

  if Assigned(FWindowParent) then
  begin
    FWindowParent.Browser := nil;
    FreeAndNil(FWindowParent);
  end;

  FForm := nil;

  inherited;
end;

procedure TWebViewBrowser.EnsureComponentsCreated;
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

procedure TWebViewBrowser.InitComponents;
begin
  // WVBrowser
  FBrowser := TWVBrowser.Create(FForm);
  FBrowser.DefaultURL := EmptyStr;

  FBrowser.OnAfterCreated := Self.OnAfterCreated;
  FBrowser.OnDocumentTitleChanged := Self.OnDocumentTitleChanged;
  FBrowser.OnInitializationError := Self.OnInitializationError;
  FBrowser.OnNewWindowRequested := Self.OnNewWindowRequested;
  FBrowser.OnWindowCloseRequested := Self.OnWindowCloseRequested;
  FBrowser.OnNavigationCompleted := Self.OnNavigationCompleted;
  FBrowser.OnWebMessageReceived := Self.OnWebMessageReceived;
  FBrowser.OnContextMenuRequested := Self.OnContextMenuRequested;

  // WVWindowParent Container
  FWindowParent := TWVWindowParent.Create(FForm);
  FWindowParent.Parent := FForm;
  FWindowParent.Align := TAlign.alClient;
  FWindowParent.Left := 0;
  FWindowParent.Top := 0;
  FWindowParent.Width := FForm.Width;
  FWindowParent.Height := FForm.Height;
  FWindowParent.Browser := FBrowser;

  // Timer
  FTimer := TTimer.Create(FForm);
  FTimer.Enabled := False;
  FTimer.Interval := 100;
  FTimer.OnTimer := OnTimer;
end;

procedure TWebViewBrowser.InitializePopupBrowser;
begin
  if FIsPopup and Assigned(FParentBrowser) then
  begin
    FBrowser.CreateBrowser(FWindowParent.Handle);

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

procedure TWebViewBrowser.CheckInitializationTimer(Sender: TObject);
var
  Timer: TTimer;
  i: Integer;
  CallbackInfo: TCallbackInfo;
begin
  Timer := TTimer(Sender);

  if FBrowserInitialized and Assigned(FBrowser.CoreWebView2) then
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

procedure TWebViewBrowser.RestoreParentFormState(Sender: TObject);
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

procedure TWebViewBrowser.WaitForBrowserInitialization(const ACallback: TProc);
var
  CheckTimer: TTimer;
  CallbackInfo: TCallbackInfo;
begin
  if FBrowserInitialized and Assigned(FBrowser.CoreWebView2) then
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

procedure TWebViewBrowser.OnAfterCreated(Sender: TObject);
begin
  FBrowserInitialized := True;

  if Assigned(FBrowser.CoreWebView2) then
  begin
//    FBrowser.CoreWebView2.Settings.Set_AreDevToolsEnabled(0);
//    FBrowser.CoreWebView2.Settings.Set_AreDefaultContextMenusEnabled(0);
  end;

  ResizeBrowser;

  if FURL <> EmptyStr then
  begin
    if Assigned(FBrowser) then
    begin
      if (FCookieName <> EmptyStr) and (FCookieValue <> EmptyStr) and (FCookieDomain <> EmptyStr) then
      begin
        if Assigned(FBrowser.CoreWebView2) then
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

procedure TWebViewBrowser.OnDocumentTitleChanged(Sender: TObject);
var
  Title: string;
begin
  Title := FBrowser.DocumentTitle;
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

procedure TWebViewBrowser.OnInitializationError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  raise Exception.Create('WebView2 Initialization Error: ' + aErrorMessage);
end;

procedure TWebViewBrowser.OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NavigationCompletedEventArgs);
begin
  Self.ResizeBrowser;
end;

procedure TWebViewBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  Self.TryCreateBrowser;
end;

procedure TWebViewBrowser.OnWebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
var
  Args: TCoreWebView2WebMessageReceivedEventArgs;
  MessageString: String;
  MessageObject: TJsonValue;
begin
  Args := TCoreWebView2WebMessageReceivedEventArgs.Create(aArgs);
  try
    MessageString := Args.WebMessageAsString;
    MessageObject := TJsonObject.ParseJSONValue(MessageString);

    if Assigned(MessageObject) then
    begin
      try
        if Assigned(FMessageReceiver) then
          FMessageReceiver(Self, MessageString);
      finally
        MessageObject.Free;
      end;
    end;
  finally
    Args.Free;
  end;
end;

procedure TWebViewBrowser.OnNewWindowRequested(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
var
  TempBrowser: TWebViewBrowser;
  Deferral: ICoreWebView2Deferral;
  Uri: PWideChar;
  WindowFeatures: ICoreWebView2WindowFeatures;
  HasPosition, HasSize: Integer;
  WinLeft, WinTop, WinWidth, WinHeight: Cardinal;
  UriString: string;
  DummyAction: Integer;
begin
  DummyAction := 0;
  Deferral := nil;
  Uri := nil;
  try
    if Succeeded(aArgs.GetDeferral(Deferral)) then
    begin
      try
        UriString := EmptyStr;
        if Succeeded(aArgs.Get_uri(Uri)) then
          UriString := string(Uri);

        TempBrowser := TWebViewBrowser.NewPopup(DEFAULT_URL);

        if Assigned(TempBrowser) then
        begin
          TempBrowser.FOnWindowClosed := Self.OnPopupClosed;
          TempBrowser.FOnWindowOpened := Self.OnPopupOpened;

          if Assigned(TempBrowser.FForm) then
          begin
            if Succeeded(aArgs.Get_WindowFeatures(WindowFeatures)) then
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

          TempBrowser.WaitForBrowserInitialization(
            procedure
            var
              DecodedContent: string;
            begin
              try
                if Assigned(TempBrowser.FBrowser) and Assigned(TempBrowser.FBrowser.CoreWebView2) then
                begin
                  if Assigned(TempBrowser.FBrowser.CoreWebView2.BaseIntf) then
                  begin
                    aArgs.Set_NewWindow(TempBrowser.FBrowser.CoreWebView2.BaseIntf);
                    aArgs.Set_Handled(1);
                    if UriString = DEFAULT_URL then
                      DummyAction := 1
                    else if Pos('data:text/html', UriString) = 1 then
                    begin
                      DecodedContent := TUtils.DecodeDataURL(UriString);
                      if DecodedContent <> EmptyStr then
                        TempBrowser.SetHTMLContent(DecodedContent);
                    end
                    else
                      TempBrowser.FBrowser.Navigate(UriString);
                  end;
                end;
              finally
                if Assigned(Deferral) then
                  Deferral.Complete;
              end;
            end
          );
        end
        else
        begin
          if Assigned(Deferral) then
            Deferral.Complete;
        end;

      except
        on E: Exception do
        begin
          if Assigned(Deferral) then
            Deferral.Complete;
          raise Exception.Create('Error creating popup: ' + E.Message);
        end;
      end;
    end;

  except
    on E: Exception do
    begin
      if Assigned(Deferral) then
        Deferral.Complete;
    end;
  end;
end;

procedure TWebViewBrowser.OnWindowCloseRequested(Sender: TObject);
begin
  PostMessage(FForm.Handle, WM_CLOSE, 0, 0);
end;

procedure TWebViewBrowser.OnPopupOpened(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup has completed opening! Instance: ' + TWebViewBrowser(Sender).ClassName);
end;

procedure TWebViewBrowser.OnPopupClosed(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup has been closed! Instance: ' + TWebViewBrowser(Sender).ClassName);
end;

procedure TWebViewBrowser.OnContextMenuRequested(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2ContextMenuRequestedEventArgs);
var
  MenuItems: ICoreWebView2ContextMenuItemCollection;
  MenuItem: ICoreWebView2ContextMenuItem;
  MenuItemsCount: Cardinal;
  ItemName: PWideChar;
  ItemNameStr: string;
  i: Integer;
  ItemKind: COREWEBVIEW2_CONTEXT_MENU_ITEM_KIND;
begin
  try
    if Succeeded(aArgs.Get_MenuItems(MenuItems)) then
    begin
      if Succeeded(MenuItems.Get_Count(MenuItemsCount)) then
      begin
        for i := Integer(MenuItemsCount) - 1 downto 0 do
        begin
          if Succeeded(MenuItems.GetValueAtIndex(i, MenuItem)) then
          begin
            if Succeeded(MenuItem.Get_Name(ItemName)) then
            begin
              ItemNameStr := string(ItemName);
              if (ItemNameStr = 'inspectElement') or
                 (ItemNameStr = 'devtools') or
                 (ItemNameStr = 'inspect') or
                 (Pos('inspect', LowerCase(ItemNameStr)) > 0) or
                 (Pos('devtools', LowerCase(ItemNameStr)) > 0) then
              begin
                MenuItems.RemoveValueAtIndex(i);
                if DEBUG_MODE then
                  ShowMessage('Removido item: ' + ItemNameStr);

                if (i > 0) and Succeeded(MenuItems.GetValueAtIndex(i - 1, MenuItem)) then
                begin
                  if Succeeded(MenuItem.Get_Kind(ItemKind)) then
                  begin
                    if ItemKind = COREWEBVIEW2_CONTEXT_MENU_ITEM_KIND_SEPARATOR then
                    begin
                      MenuItems.RemoveValueAtIndex(i - 1);
                      if DEBUG_MODE then
                        ShowMessage('Removido separador anterior ao item: ' + ItemNameStr);
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      if DEBUG_MODE then
        ShowMessage('Erro ao processar menu de contexto: ' + E.Message);
    end;
  end;
end;

procedure TWebViewBrowser.TryCreateBrowser;
begin
  if not FWindowParent.HandleAllocated then
    FWindowParent.HandleNeeded;

  if GlobalWebView2Loader.InitializationError then
    raise Exception.Create(GlobalWebView2Loader.ErrorMessage)
  else if GlobalWebView2Loader.Initialized then
  begin
    ResizeBrowser;
    if FWindowParent.HandleAllocated then
    begin
      if not FBrowserInitialized then
      begin
        if FIsPopup then
          InitializePopupBrowser
        else
          FBrowser.CreateBrowser(FWindowParent.Handle);
      end;
    end;
  end
  else
    FTimer.Enabled := True;
end;

procedure TWebViewBrowser.ResizeBrowser;
begin
  if Assigned(FWindowParent) then
  begin
    FWindowParent.HandleNeeded;
    FWindowParent.SetBounds(0, 0, FForm.ClientWidth, FForm.ClientHeight);
    FWindowParent.Invalidate;
    FWindowParent.Update;
    if FBrowserInitialized and Assigned(FBrowser) then
    begin
      FWindowParent.UpdateSize;
      FBrowser.NotifyParentWindowPositionChanged;
    end;
  end;
end;

procedure TWebViewBrowser.Show(const AType: TOpenType = TOpenType.Default);
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

procedure TWebViewBrowser.ShowModal(const AType: TOpenType = TOpenType.Modal);
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

procedure TWebViewBrowser.ShowAsModal(AParentForm: TForm = nil);
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

procedure TWebViewBrowser.ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);
begin
  FIsClosing := False;
  FParentForm := AParentForm;

  if not Assigned(FForm) then
    Self.CreateMDIComponents(AParentForm, FURL, FLegacyForm)
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

      if not FBrowserInitialized and Assigned(FWindowParent) then
      begin
        if not FWindowParent.HandleAllocated then
          FWindowParent.HandleNeeded;

        if GlobalWebView2Loader.Initialized and FWindowParent.HandleAllocated then
        begin
          try
            if not FBrowserInitialized then
              FBrowser.CreateBrowser(FWindowParent.Handle);
          except
            if Assigned(FTimer) then
              FTimer.Enabled := True;
          end;
        end
        else
        begin
          if Assigned(FTimer) then
            FTimer.Enabled := True;
        end;
      end;

    except
      try
        Self.CreateMDIComponents(AParentForm, FURL);
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

procedure TWebViewBrowser.ShowAsMDI;
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

procedure TWebViewBrowser.ShowAsMDI(const AOptions: TMDIOptions);
var
  ExistingInstance: TWebViewBrowser;
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

procedure TWebViewBrowser.ShowAsMDICustom(AutoShow: Boolean = True);
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

procedure TWebViewBrowser.ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
begin
  if not Assigned(FParentForm) then
    Exit;

  if FParentForm.FormStyle <> fsMDIForm then
    Exit;

  Self.ShowAsMDICustom(AutoShow);

  if AutoShow and Assigned(FForm) and MaximizeOnShow then
    FForm.WindowState := wsMaximized;
end;

procedure TWebViewBrowser.ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
var
  ExistingBrowser: TWebViewBrowser;
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
  TWebViewBrowser.FFinalizationStarted := False;

finalization
  TWebViewBrowser.CleanupMDIRegistry;
  TWebViewBrowser.CleanupPopupRegistry;

end.

