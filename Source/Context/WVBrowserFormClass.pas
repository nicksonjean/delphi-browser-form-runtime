unit WVBrowserFormClass;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.Dwmapi, Winapi.ShellAPI,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs, Vcl.ComCtrls, Vcl.AppEvnts,
  System.JSON, System.Generics.Collections, System.SysUtils, System.Classes, System.Win.ComObj,

  uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes, uWVTypeLibrary,
  uWVBrowserBase, uWVCoreWebView2Args, uWVCoreWebView2Deferral, uWVLoader,
  uWVLibFunctions, uWVConstants, uWVCoreWebView2, uWVInterfaces,
  uWVCoreWebView2WindowFeatures,

  BrowserTypes,
  BrowserFormInterface;

const
  DEBUG_MODE = false;
  DEFAULT_URL = 'about:blank';
  DEFAULT_WIDTH = 800;
  DEFAULT_HEIGHT = 600;
  DEFAULT_LEGACY_FORM = false;
  DEFAULT_MAX_INSTANCES = 0;

type
  TCustomFormWVBrowser = class;

  TCustomWVForm = class(TForm)
  strict private
    FInitialized: Boolean;
    FArgs: TCoreWebView2NewWindowRequestedEventArgs;
    FDeferral: TCoreWebView2Deferral;
    procedure WMSize(var aMessage: TMessage); message WM_SIZE;
    procedure WMWindowPosChanging(var aMessage: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;
  public
    BrowserInstance: IBrowserForm;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure CenterToScreenWithMonitor;
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
  end;

  TCustomFormWVBrowser = class(TInterfacedObject, IBrowserForm)
  private
    FForm: TCustomWVForm;
    FBrowser: TWVBrowser;
    FWindowParent: TWVWindowParent;
    FCookie: ICoreWebView2Cookie;
    FProfile: ICoreWebView2Profile;
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

    class var FFinalizationStarted: Boolean;
    class var FMDIInstanceRegistry: TDictionary<string, TList<TCustomFormWVBrowser>>;
    class function GetMDIInstanceRegistry: TDictionary<string, TList<TCustomFormWVBrowser>>;
    class procedure RegisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormWVBrowser);
    class procedure UnregisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormWVBrowser);
    class function GetMDIInstanceCount(const AIdentifier: string): Integer;
    class function GetOldestMDIInstance(const AIdentifier: string): TCustomFormWVBrowser;
    class function CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
    class procedure CleanupMDIRegistry;

    // Internal Generic Methods
    function DecodeDataURL(const DataURL: string): string;
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
    procedure CleanupProfile;

    // MDI Methods
    procedure CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
    procedure ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);

    // Event Methods
    procedure OnTimer(Sender: TObject);
    procedure OnAfterCreated(Sender: TObject);
    procedure OnDocTitleChanged(Sender: TObject);
    procedure OnInitError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NavigationCompletedEventArgs);
    procedure OnWebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
    procedure OnNewWindowRequested(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
    procedure OnWindowCloseRequested(Sender: TObject);
    procedure OnPopupOpened(Sender: TObject);
    procedure OnPopupClosed(Sender: TObject);
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
    function GetParentBrowserProp: TWVBrowser;
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
    procedure SetParentBrowserProp(const Value: TWVBrowser);
    procedure SetUniqueIdentifierProp(const Value: String);
    procedure SetMaxInstancesProp(const Value: Integer);
    procedure SetLegacyFormProp(const Value: Boolean);
    procedure SetWindowOpenedProp(const Value: TNotifyEvent);
    procedure SetWindowClosedProp(const Value: TNotifyEvent);
    procedure SetMessageReceiverProp(const Value: TMessageReceiverCallback);
    procedure SetMessageSenderProp(const Value: String);
  public
    // Constructor and Destructor
    constructor Create; overload;
    constructor Create(const AURL: String); overload;
    constructor Create(const AURL: String; AParentObject: TObject; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM); overload;
    constructor CreateAsBrowser(const AURL: String = '');
    constructor CreateAsPopup(AParentBrowser: TWVBrowser; const AURL: String = '');
    constructor CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
    destructor Destroy; override;

    // Alias Static Constructors
    class function NewBrowser(const AURL: string): TCustomFormWVBrowser;
    class function NewPopup(const AURL: string; AParentBrowser: TWVBrowser = nil): TCustomFormWVBrowser;
    class function NewMDI(const AURL: String; AParentForm: TForm = nil): TCustomFormWVBrowser;

    // Alias Method for Popup Childs
    function Recreate(const AURL: string): TCustomFormWVBrowser;

    // Static Method for MDI Forms
    class function FindMDIInstance(const AIdentifier: string): TCustomFormWVBrowser;
    class function CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;

    // Fluent Chainable Methods
    function SetWidth(const AWidth: Integer): TCustomFormWVBrowser;
    function SetHeight(const AHeight: Integer): TCustomFormWVBrowser;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): TCustomFormWVBrowser;
    function SetActionButtons(const AButton: TBorderIcons): TCustomFormWVBrowser;
    function SetResizable(const AResize: Boolean): TCustomFormWVBrowser;
    function SetMovable(const AMove: Boolean): TCustomFormWVBrowser;
    function SetTitleBar(const ATitleBar: Boolean): TCustomFormWVBrowser;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TCustomFormWVBrowser;
    function SetAlpha(const AAlpha: Boolean): TCustomFormWVBrowser;
    function SetURL(const AURL: String): TCustomFormWVBrowser;
    function SetParentForm(const AParentForm: TForm): TCustomFormWVBrowser;
    function SetParentBrowser(const AParentBrowser: TWVBrowser): TCustomFormWVBrowser;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): TCustomFormWVBrowser;
    function SetMaxInstances(const AMaxInstances: Integer): TCustomFormWVBrowser;
    function SetLegacyForm(const ALegacyForm: Boolean): TCustomFormWVBrowser;
    function SetWindowOpened(const AEvent: TNotifyEvent): TCustomFormWVBrowser;
    function SetWindowClosed(const AEvent: TNotifyEvent): TCustomFormWVBrowser;
    function SetHTMLContent(const AHTMLContent: String): TCustomFormWVBrowser;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): TCustomFormWVBrowser;
    function SetMessageSender(const AMessage: String): TCustomFormWVBrowser;

    // Interface Methods
    function IBrowserForm.SetWidth = ISetWidth;
    function IBrowserForm.SetHeight = ISetHeight;
    function IBrowserForm.SetCaption = ISetCaption;
    function IBrowserForm.SetActionButtons = ISetActionButtons;
    function IBrowserForm.SetResizable = ISetResizable;
    function IBrowserForm.SetMovable = ISetMovable;
    function IBrowserForm.SetTitleBar = ISetTitleBar;
    function IBrowserForm.SetCookie = ISetCookie;
    function IBrowserForm.SetAlpha = ISetAlpha;
    function IBrowserForm.SetURL = ISetURL;
    function IBrowserForm.SetParentForm = ISetParentForm;
    function IBrowserForm.SetParentBrowser = ISetParentBrowser;
    function IBrowserForm.SetUniqueIdentifier = ISetUniqueIdentifier;
    function IBrowserForm.SetMaxInstances = ISetMaxInstances;
    function IBrowserForm.SetLegacyForm = ISetLegacyForm;
    function IBrowserForm.SetWindowOpened = ISetWindowOpened;
    function IBrowserForm.SetWindowClosed = ISetWindowClosed;
    function IBrowserForm.SetHTMLContent = ISetHTMLContent;
    function IBrowserForm.SetMessageReceiver = ISetMessageReceiver;
    function IBrowserForm.SetMessageSender = ISetMessageSender;
    procedure IBrowserForm.Show = IShow;
    procedure IBrowserForm.ShowModal = IShowModal;
    procedure IBrowserForm.ShowAsModal = IShowAsModal;
    procedure IBrowserForm.ShowAsMDICustom = IShowAsMDICustom;
    procedure IBrowserForm.ShowAsMDISimple = IShowAsMDISimple;
    procedure IBrowserForm.ShowAsMDIAdvanced = IShowAsMDIAdvanced;

    function ISetWidth(const AWidth: Integer): IBrowserForm;
    function ISetHeight(const AHeight: Integer): IBrowserForm;
    function ISetCaption(const ACaption: String; APosition: TPositionCaption): IBrowserForm;
    function ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
    function ISetResizable(const AResize: Boolean): IBrowserForm;
    function ISetMovable(const AMove: Boolean): IBrowserForm;
    function ISetTitleBar(const ATitleBar: Boolean): IBrowserForm;
    function ISetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IBrowserForm;
    function ISetAlpha(const AAlpha: Boolean): IBrowserForm;
    function ISetURL(const AURL: String): IBrowserForm;
    function ISetParentForm(const AParentForm: TForm): IBrowserForm;
    function ISetParentBrowser(const AParentBrowser: TWVBrowser): IBrowserForm;
    function ISetUniqueIdentifier(const AUniqueIdentifier: String): IBrowserForm;
    function ISetMaxInstances(const AMaxInstances: Integer): IBrowserForm;
    function ISetLegacyForm(const ALegacyForm: Boolean): IBrowserForm;
    function ISetWindowOpened(const AEvent: TNotifyEvent): IBrowserForm;
    function ISetWindowClosed(const AEvent: TNotifyEvent): IBrowserForm;
    function ISetHTMLContent(const AHTMLContent: String): IBrowserForm;
    function ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IBrowserForm;
    function ISetMessageSender(const AMessage: String): IBrowserForm;
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
    property ParentBrowser: TWVBrowser read GetParentBrowserProp write SetParentBrowserProp;
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

{ TCustomWVForm }

procedure TCustomWVForm.CenterToScreenWithMonitor;
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

constructor TCustomWVForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
end;

constructor TCustomWVForm.CreateWithArgs(AOwner: TComponent; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
begin
  inherited CreateNew(AOwner);

  if Assigned(aArgs) then
  begin
    FArgs := TCoreWebView2NewWindowRequestedEventArgs.Create(aArgs);
    FDeferral := TCoreWebView2Deferral.Create(FArgs.Deferral);
  end;
end;

procedure TCustomWVForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(BrowserInstance) then
  begin
    try
      // Marca como fechando antes de qualquer operação
      (BrowserInstance as TCustomFormWVBrowser).FIsClosing := True;
      
      // Para timers
      if Assigned((BrowserInstance as TCustomFormWVBrowser).FTimer) then
      begin
        (BrowserInstance as TCustomFormWVBrowser).FTimer.Enabled := False;
        (BrowserInstance as TCustomFormWVBrowser).FTimer.OnTimer := nil;
      end;

      if Assigned((BrowserInstance as TCustomFormWVBrowser).FCheckTimer) then
      begin
        (BrowserInstance as TCustomFormWVBrowser).FCheckTimer.Enabled := False;
        (BrowserInstance as TCustomFormWVBrowser).FCheckTimer.OnTimer := nil;
      end;

      // Limpa callbacks
      if Assigned((BrowserInstance as TCustomFormWVBrowser).FCallbackList) then
      begin
        while (BrowserInstance as TCustomFormWVBrowser).FCallbackList.Count > 0 do
        begin
          if Assigned((BrowserInstance as TCustomFormWVBrowser).FCallbackList[0].Timer) then
          begin
            (BrowserInstance as TCustomFormWVBrowser).FCallbackList[0].Timer.Enabled := False;
            (BrowserInstance as TCustomFormWVBrowser).FCallbackList[0].Timer.OnTimer := nil;
          end;
          (BrowserInstance as TCustomFormWVBrowser).FCallbackList.Delete(0);
        end;
      end;

      // Limpeza específica do Profile
      if Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
      begin
        try
          // 1º - Limpa Profile explicitamente
          (BrowserInstance as TCustomFormWVBrowser).CleanupProfile;

          // 2º - Limpa cookie
          if Assigned((BrowserInstance as TCustomFormWVBrowser).FCookie) then
            (BrowserInstance as TCustomFormWVBrowser).FCookie := nil;

          // 3º - Remove event handlers
          if (BrowserInstance as TCustomFormWVBrowser).FBrowserInitialized then
          begin
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnAfterCreated := nil;
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnDocumentTitleChanged := nil;
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnInitializationError := nil;
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnNewWindowRequested := nil;
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnWindowCloseRequested := nil;
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnNavigationCompleted := nil;
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.OnWebMessageReceived := nil;

            (BrowserInstance as TCustomFormWVBrowser).FBrowserInitialized := False;
            
            // 4º - Garante que o Profile seja liberado após limpar os handlers
            (BrowserInstance as TCustomFormWVBrowser).CleanupProfile;
          end;

          // 5º - Notifica mudança de posição
          try
            (BrowserInstance as TCustomFormWVBrowser).FBrowser.NotifyParentWindowPositionChanged;
          except
            // Ignora exceções durante notificação
          end;
        except
          // Ignora exceções durante limpeza
        end;
      end;

      // Chama evento de fechamento
      if Assigned((BrowserInstance as TCustomFormWVBrowser).FOnWindowClosed) then
        (BrowserInstance as TCustomFormWVBrowser).FOnWindowClosed(BrowserInstance as TCustomFormWVBrowser);
    except
      // Ignora exceções durante fechamento
    end;
  end;

  Action := caFree;
end;

procedure TCustomWVForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;

  if Assigned(BrowserInstance) then
  begin
    (BrowserInstance as TCustomFormWVBrowser).FIsClosing := True;

    // Para timers
    if Assigned((BrowserInstance as TCustomFormWVBrowser).FTimer) then
      (BrowserInstance as TCustomFormWVBrowser).FTimer.Enabled := False;

    if Assigned((BrowserInstance as TCustomFormWVBrowser).FCheckTimer) then
      (BrowserInstance as TCustomFormWVBrowser).FCheckTimer.Enabled := False;

    // Limpeza antecipada do Profile no CloseQuery
    if Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
    begin
      try
        // Executa beforeunload
        if (BrowserInstance as TCustomFormWVBrowser).FBrowserInitialized then
          (BrowserInstance as TCustomFormWVBrowser).FBrowser.ExecuteScript('window.dispatchEvent(new Event("beforeunload"))');

        // Limpa Profile antecipadamente no CloseQuery
        (BrowserInstance as TCustomFormWVBrowser).CleanupProfile;

        // Limpeza do cookie
        if Assigned((BrowserInstance as TCustomFormWVBrowser).FCookie) then
        begin
          (BrowserInstance as TCustomFormWVBrowser).FCookie := nil;
        end;
      except
        // Ignora excees durante CloseQuery
      end;
    end;
  end;
end;

procedure TCustomWVForm.FormDestroy(Sender: TObject);
begin
  try
    // Limpa referências antes de destruir
    if Assigned(FArgs) then
      FreeAndNil(FArgs);

    if Assigned(FDeferral) then
      FreeAndNil(FDeferral);

    // Limpa referência do BrowserInstance por último
    BrowserInstance := nil;
  except
    // Ignora exceções durante destruição
  end;
end;

procedure TCustomWVForm.FormResize(Sender: TObject);
begin
  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormWVBrowser).ResizeBrowser;
end;

procedure TCustomWVForm.FormShow(Sender: TObject);
begin
  if not FInitialized then
  begin
    CenterToScreenWithMonitor;
    FInitialized := True;
  end;

  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormWVBrowser).TryCreateBrowser;
end;

procedure TCustomWVForm.WMMove(var aMessage: TWMMove);
begin
  inherited;

  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
    (BrowserInstance as TCustomFormWVBrowser).FBrowser.NotifyParentWindowPositionChanged;
end;

procedure TCustomWVForm.WMMoving(var aMessage: TMessage);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TCustomFormWVBrowser).FMovable then
  begin
    CenterToScreenWithMonitor;
    aMessage.Result := 1;
    Exit;
  end;

  inherited;

  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
    (BrowserInstance as TCustomFormWVBrowser).FBrowser.NotifyParentWindowPositionChanged;
end;

procedure TCustomWVForm.WMSize(var aMessage: TMessage);
begin
  inherited;

  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormWVBrowser).ResizeBrowser;
end;

procedure TCustomWVForm.WMWindowPosChanging(var aMessage: TWMWindowPosChanging);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TCustomFormWVBrowser).FMovable then
  begin
    Self.CenterToScreenWithMonitor;
    aMessage.WindowPos^.flags := aMessage.WindowPos^.flags or SWP_NOMOVE;
  end;

  inherited;
end;

{ TCustomFormWVBrowser }

// Interface Methods

function TCustomFormWVBrowser.ISetWidth(const AWidth: Integer): IBrowserForm;
begin
  SetWidth(AWidth);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetHeight(const AHeight: Integer): IBrowserForm;
begin
  SetHeight(AHeight);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetCaption(const ACaption: string; APosition: TPositionCaption): IBrowserForm;
begin
  SetCaption(ACaption, APosition);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
begin
  SetActionButtons(AButtons);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetResizable(const AResize: Boolean): IBrowserForm;
begin
  SetResizable(AResize);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetMovable(const AMove: Boolean): IBrowserForm;
begin
  SetMovable(AMove);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetTitleBar(const ATitleBar: Boolean): IBrowserForm;
begin
  SetTitleBar(ATitleBar);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetAlpha(const AAlpha: Boolean): IBrowserForm;
begin
  SetAlpha(AAlpha);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetURL(const AURL: String): IBrowserForm;
begin
  SetURL(AURL);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetParentForm(const AParentForm: TForm): IBrowserForm;
begin
  SetParentForm(AParentForm);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetParentBrowser(const AParentBrowser: TWVBrowser): IBrowserForm;
begin
  SetParentBrowser(AParentBrowser);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetUniqueIdentifier(const AUniqueIdentifier: String): IBrowserForm;
begin
  SetUniqueIdentifier(AUniqueIdentifier);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetMaxInstances(const AMaxInstances: Integer): IBrowserForm;
begin
  SetMaxInstances(AMaxInstances);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetLegacyForm(const ALegacyForm: Boolean): IBrowserForm;
begin
  SetLegacyForm(ALegacyForm);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetWindowOpened(const AEvent: TNotifyEvent): IBrowserForm;
begin
  SetWindowOpened(AEvent);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetWindowClosed(const AEvent: TNotifyEvent): IBrowserForm;
begin
  SetWindowClosed(AEvent);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetHTMLContent(const AHTMLContent: String): IBrowserForm;
begin
  SetHTMLContent(AHTMLContent);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetCookie(const ACookieName: string; const ACookieValue: string; const ACookieDomain: string; const ACookiePath: string = '/'): IBrowserForm;
begin
  SetCookie(ACookieName, ACookieValue, ACookieDomain, ACookiePath);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IBrowserForm;
begin
  SetMessageReceiver(AMessage);
  Result := Self;
end;

function TCustomFormWVBrowser.ISetMessageSender(const AMessage: String): IBrowserForm;
begin
  SetMessageSender(AMessage);
  Result := Self;
end;

procedure TCustomFormWVBrowser.IShowAsMDICustom(AutoShow: Boolean = True);
begin
  ShowAsMDICustom(AutoShow);
end;

procedure TCustomFormWVBrowser.IShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
begin
  ShowAsMDISimple(AutoShow, SingleInstance, MaximizeOnShow);
end;

procedure TCustomFormWVBrowser.IShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
begin
  ShowAsMDIAdvanced(AutoShow, SingleInstance, MaximizeOnShow, BringToFrontIfExists, UniqueIdentifier, MaxInstances);
end;

procedure TCustomFormWVBrowser.IShow(const AType: TOpenType);
begin
  Show(AType);
end;

procedure TCustomFormWVBrowser.IShowAsModal(AParentForm: TForm);
begin
  ShowAsModal(AParentForm);
end;

procedure TCustomFormWVBrowser.IShowModal(const AType: TOpenType);
begin
  ShowModal(AType);
end;

// Getters

function TCustomFormWVBrowser.GetWidthProp: Integer;
begin
  Result := FWidth;
end;

function TCustomFormWVBrowser.GetHeightProp: Integer;
begin
  Result := FHeight;
end;

function TCustomFormWVBrowser.GetCaptionProp: string;
begin
  Result := FCaption;
end;

function TCustomFormWVBrowser.GetCaptionPositionProp: TPositionCaption;
begin
  Result := FCaptionPosition;
end;

function TCustomFormWVBrowser.GetActionButtonsProp: TBorderIcons;
begin
  Result := FForm.BorderIcons;
end;

function TCustomFormWVBrowser.GetResizableProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsSizeable;
end;

function TCustomFormWVBrowser.GetMovableProp: Boolean;
begin
  Result := FMovable;
end;

function TCustomFormWVBrowser.GetPopupProp: Boolean;
begin
  Result:= FIsPopup;
end;

function TCustomFormWVBrowser.GetTitleBarProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsNone;
end;

function TCustomFormWVBrowser.GetInstanceProp: TComponent;
begin
  Result := FBrowser;
end;

function TCustomFormWVBrowser.GetCookieNameProp: String;
begin
  Result := FCookieName;
end;

function TCustomFormWVBrowser.GetCookieValueProp: String;
begin
  Result := FCookieValue;
end;

function TCustomFormWVBrowser.GetCookieDomainProp: String;
begin
  Result := FCookieDomain;
end;

function TCustomFormWVBrowser.GetCookiePathProp: String;
begin
  Result := FCookiePath;
end;

function TCustomFormWVBrowser.GetAlphaProp: Boolean;
begin
  Result := FAlpha;
end;

function TCustomFormWVBrowser.GetURLProp: String;
begin
  Result := FURL;
end;

function TCustomFormWVBrowser.GetParentFormProp: TForm;
begin
  Result := FParentForm;
end;

function TCustomFormWVBrowser.GetParentBrowserProp: TWVBrowser;
begin
  Result := FParentBrowser;
end;

function TCustomFormWVBrowser.GetUniqueIdentifierProp: String;
begin
  Result := FUniqueIdentifier;
end;

function TCustomFormWVBrowser.GetMaxInstancesProp: Integer;
begin
  Result := FMaxInstances;
end;

function TCustomFormWVBrowser.GetLegacyFormProp: Boolean;
begin
  Result := FLegacyForm;
end;

function TCustomFormWVBrowser.GetWindowOpenedProp: TNotifyEvent;
begin
  Result := FOnWindowOpened;
end;

function TCustomFormWVBrowser.GetWindowClosedProp: TNotifyEvent;
begin
  Result := FOnWindowClosed;
end;

function TCustomFormWVBrowser.ReadMessageReceiverProp: TMessageReceiverCallback;
begin
  Result := FMessageReceiver;
end;

function TCustomFormWVBrowser.ReadMessageSenderProp: string;
begin
  Result := FMessageSender;
end;

// Setters

procedure TCustomFormWVBrowser.SetWidthProp(const Value: Integer);
begin
  SetWidth(Value);
end;

procedure TCustomFormWVBrowser.SetHeightProp(const Value: Integer);
begin
  SetHeight(Value);
end;

procedure TCustomFormWVBrowser.SetCaptionProp(const Value: string);
begin
  SetCaption(Value, FCaptionPosition);
end;

procedure TCustomFormWVBrowser.SetCaptionPositionProp(const Value: TPositionCaption);
begin
  FCaptionPosition := Value;
  SetCaption(FCaption, Value);
end;

procedure TCustomFormWVBrowser.SetActionButtonsProp(const Value: TBorderIcons);
begin
  SetActionButtons(Value);
end;

procedure TCustomFormWVBrowser.SetResizableProp(const Value: Boolean);
begin
  SetResizable(Value);
end;

procedure TCustomFormWVBrowser.SetMovableProp(const Value: Boolean);
begin
  SetMovable(Value);
end;

procedure TCustomFormWVBrowser.SetTitleBarProp(const Value: Boolean);
begin
  SetTitleBar(Value);
end;

procedure TCustomFormWVBrowser.SetCookieNameProp(const Value: String);
begin
  SetCookie(Value, FCookieValue, FCookieDomain, FCookiePath);
end;

procedure TCustomFormWVBrowser.SetCookieValueProp(const Value: String);
begin
  FCookieValue := Value;
  SetCookie(FCookieName, Value, FCookieDomain, FCookiePath);
end;

procedure TCustomFormWVBrowser.SetCookieDomainProp(const Value: String);
begin
  FCookieDomain := Value;
  SetCookie(FCookieName, FCookieValue, Value, FCookiePath);
end;

procedure TCustomFormWVBrowser.SetCookiePathProp(const Value: String);
begin
  FCookiePath := Value;
  SetCookie(FCookieName, FCookieValue, FCookieDomain, Value);
end;

procedure TCustomFormWVBrowser.SetAlphaProp(const Value: Boolean);
begin
  SetAlpha(Value);
end;

procedure TCustomFormWVBrowser.SetURLProp(const Value: String);
begin
  SetURL(Value);
end;

procedure TCustomFormWVBrowser.SetParentFormProp(const Value: TForm);
begin
  SetParentForm(Value);
end;

procedure TCustomFormWVBrowser.SetParentBrowserProp(const Value: TWVBrowser);
begin
  SetParentBrowser(Value);
end;

procedure TCustomFormWVBrowser.SetUniqueIdentifierProp(const Value: String);
begin
  SetUniqueIdentifier(Value);
end;

procedure TCustomFormWVBrowser.SetMaxInstancesProp(const Value: Integer);
begin
  SetMaxInstances(Value);
end;

procedure TCustomFormWVBrowser.SetLegacyFormProp(const Value: Boolean);
begin
  SetLegacyForm(Value);
end;

procedure TCustomFormWVBrowser.SetWindowOpenedProp(const Value: TNotifyEvent);
begin
  SetWindowOpened(Value);
end;

procedure TCustomFormWVBrowser.SetWindowClosedProp(const Value: TNotifyEvent);
begin
  SetWindowClosed(Value);
end;

procedure TCustomFormWVBrowser.SetMessageReceiverProp(const Value: TMessageReceiverCallback);
begin
  SetMessageReceiver(Value);
end;

procedure TCustomFormWVBrowser.SetMessageSenderProp(const Value: string);
begin
  SetMessageSender(Value);
end;

// Chainable Methods

function TCustomFormWVBrowser.SetWidth(const AWidth: Integer): TCustomFormWVBrowser;
begin
  FWidth := AWidth;
  if Assigned(FForm) then
  begin
    FForm.ClientWidth := AWidth;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormWVBrowser.SetHeight(const AHeight: Integer): TCustomFormWVBrowser;
begin
  FHeight := AHeight;
  if Assigned(FForm) then
  begin
    FForm.ClientHeight := AHeight;
    Self.ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormWVBrowser.SetCaption(const ACaption: String; APosition: TPositionCaption): TCustomFormWVBrowser;
begin
  FCaption := ACaption;
  FCaptionPosition := APosition;
  if FBrowserInitialized then
    Self.OnDocTitleChanged(FBrowser);
  Result := Self;
end;

function TCustomFormWVBrowser.SetActionButtons(const AButton: TBorderIcons): TCustomFormWVBrowser;
begin
  FForm.BorderIcons := FForm.BorderIcons - AButton;
  Result := Self;
end;

function TCustomFormWVBrowser.SetResizable(const AResize: Boolean): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetMovable(const AMove: Boolean): TCustomFormWVBrowser;
begin
  FMovable := AMove;
  if Assigned(FForm) and not AMove then
    FForm.CenterToScreenWithMonitor;
  Result := Self;
end;

function TCustomFormWVBrowser.SetTitleBar(const ATitleBar: Boolean): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): TCustomFormWVBrowser;
begin
  FCookieName := ACookieName;
  FCookieValue := ACookieValue;
  FCookieDomain := ACookieDomain;
  FCookiePath := ACookiePath;

  // Libera cookie anterior se existir
  if Assigned(FCookie) then
  begin
    FCookie := nil;
  end;

  // Libera Profile anterior se existir
  CleanupProfile;

  if FBrowserInitialized and Assigned(FBrowser) and Assigned(FBrowser.CoreWebView2) then
  begin
    try
      // Armazena o Profile em campo próprio para controle de liberação
      FProfile := FBrowser.CoreWebView2.Profile;
      if Assigned(FProfile) then
      begin
        FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
        if Assigned(FCookie) then
          FBrowser.AddOrUpdateCookie(FCookie);
      end;
    except
      // Em caso de exceção, garante que Profile seja liberado
      CleanupProfile;
    end;
  end;

  Result := Self;
end;

function TCustomFormWVBrowser.SetAlpha(const AAlpha: Boolean): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetURL(const AURL: String): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetParentForm(const AParentForm: TForm): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetParentBrowser(const AParentBrowser: TWVBrowser): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetUniqueIdentifier(const AUniqueIdentifier: String): TCustomFormWVBrowser;
begin
  FUniqueIdentifier := AUniqueIdentifier;
  Result := Self;
end;

function TCustomFormWVBrowser.SetMaxInstances(const AMaxInstances: Integer): TCustomFormWVBrowser;
begin
  FMaxInstances := AMaxInstances;
  Result := Self;
end;

function TCustomFormWVBrowser.SetLegacyForm(const ALegacyForm: Boolean): TCustomFormWVBrowser;
begin
  FLegacyForm := ALegacyForm;
  Result := Self;
end;

function TCustomFormWVBrowser.SetWindowOpened(const AEvent: TNotifyEvent): TCustomFormWVBrowser;
begin
  FOnWindowOpened := AEvent;
  Result := Self;
end;

function TCustomFormWVBrowser.SetWindowClosed(const AEvent: TNotifyEvent): TCustomFormWVBrowser;
begin
  FOnWindowClosed := AEvent;
  Result := Self;
end;

function TCustomFormWVBrowser.SetHTMLContent(const AHTMLContent: String): TCustomFormWVBrowser;
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

function TCustomFormWVBrowser.SetMessageReceiver(const AMessage: TMessageReceiverCallback): TCustomFormWVBrowser;
begin
  FMessageReceiver := AMessage;
  Result := Self;
end;

function TCustomFormWVBrowser.SetMessageSender(const AMessage: String): TCustomFormWVBrowser;
begin
  FMessageSender := AMessage;
  if Assigned(FBrowser) then
    FBrowser.PostWebMessageAsString(FMessageSender);
  Result := Self;
end;

// Registry

class function TCustomFormWVBrowser.GetMDIInstanceRegistry: TDictionary<string, TList<TCustomFormWVBrowser>>;
begin
  if FFinalizationStarted then
  begin
    Result := nil;
    Exit;
  end;

  if not Assigned(FMDIInstanceRegistry) then
    FMDIInstanceRegistry := TDictionary<string, TList<TCustomFormWVBrowser>>.Create;
  Result := FMDIInstanceRegistry;
end;

class procedure TCustomFormWVBrowser.RegisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormWVBrowser);
var
  InstanceList: TList<TCustomFormWVBrowser>;
  Registry: TDictionary<string, TList<TCustomFormWVBrowser>>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) then
    Exit;

  Registry := GetMDIInstanceRegistry;
  if not Assigned(Registry) then
    Exit;

  if not Registry.TryGetValue(AIdentifier, InstanceList) then
  begin
    InstanceList := TList<TCustomFormWVBrowser>.Create;
    Registry.Add(AIdentifier, InstanceList);
  end;

  if InstanceList.IndexOf(AInstance) = -1 then
    InstanceList.Add(AInstance);
end;

class procedure TCustomFormWVBrowser.UnregisterMDIInstance(const AIdentifier: string; AInstance: TCustomFormWVBrowser);
var
  InstanceList: TList<TCustomFormWVBrowser>;
begin
  if FFinalizationStarted or (AIdentifier = EmptyStr) or not Assigned(FMDIInstanceRegistry) then
    Exit;

  if FMDIInstanceRegistry.TryGetValue(AIdentifier, InstanceList) then
  begin
    if Assigned(InstanceList) then
    begin
      // CORREO: Usa mtodo centralizado de limpeza
      if Assigned(AInstance) then
      begin
        try
          AInstance.CleanupWebViewResources;
        except
          // Ignora excees durante limpeza
        end;
      end;

      // Remove da lista
      InstanceList.Remove(AInstance);

      // Se a lista ficou vazia, remove e libera
      if InstanceList.Count = 0 then
      begin
        FMDIInstanceRegistry.Remove(AIdentifier);
        InstanceList.Free;
      end;
    end;
  end;
end;

class function TCustomFormWVBrowser.GetMDIInstanceCount(const AIdentifier: string): Integer;
var
  InstanceList: TList<TCustomFormWVBrowser>;
  Registry: TDictionary<string, TList<TCustomFormWVBrowser>>;
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

class function TCustomFormWVBrowser.GetOldestMDIInstance(const AIdentifier: string): TCustomFormWVBrowser;
var
  InstanceList: TList<TCustomFormWVBrowser>;
  Registry: TDictionary<string, TList<TCustomFormWVBrowser>>;
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

class function TCustomFormWVBrowser.FindMDIInstance(const AIdentifier: string): TCustomFormWVBrowser;
begin
  Result := GetOldestMDIInstance(AIdentifier);
end;

class function TCustomFormWVBrowser.CanCreateMDIInstance(const AIdentifier: string; AMaxInstances: Integer; ASingleInstance: Boolean): Boolean;
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

class function TCustomFormWVBrowser.CheckMDILimits(const AUniqueIdentifier: string; AMaxInstances: Integer = 1; ASingleInstance: Boolean = True): Boolean;
begin
  Result := CanCreateMDIInstance(AUniqueIdentifier, AMaxInstances, ASingleInstance);
end;

class procedure TCustomFormWVBrowser.CleanupMDIRegistry;
var
  Pair: TPair<string, TList<TCustomFormWVBrowser>>;
  InstanceList: TList<TCustomFormWVBrowser>;
  i: Integer;
  Instance: TCustomFormWVBrowser;
begin
  FFinalizationStarted := True;

  if Assigned(FMDIInstanceRegistry) then
  begin
    // CORREO: Foca especificamente na limpeza do Profile
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
            try
              // CORREO: Limpeza especfica do Profile
              Instance.CleanupProfile;

              // Libera cookie
              if Assigned(Instance.FCookie) then
                Instance.FCookie := nil;

              Instance.FIsClosing := True;
            except
              // Ignora excees durante limpeza forada
            end;
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

// Context

procedure TCustomFormWVBrowser.CreateComponents(AParentBrowser: TWVBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
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

  if not Assigned(GlobalWebView2Loader) then
  begin
    GlobalWebView2Loader := TWVLoader.Create(nil);
    GlobalWebView2Loader.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'CustomCache';
    GlobalWebView2Loader.StartWebView2;
  end;

  FForm := TCustomWVForm.CreateWithArgs(nil, nil);
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

  if AIsPopup = true then
  begin
    FForm.Constraints.MinWidth := FWidth;
    FForm.Constraints.MinHeight := FHeight;
  end;

  InitComponents;
end;

procedure TCustomFormWVBrowser.CleanupWebViewResources;
begin
  // Limpa Profile ANTES do cookie
  CleanupProfile;

  if Assigned(FCookie) then
  begin
    FCookie := nil;
  end;

  if Assigned(FBrowser) and FBrowserInitialized then
  begin
    try
      // Remove event handlers e marca como não inicializado
      FBrowser.OnAfterCreated := nil;
      FBrowser.OnDocumentTitleChanged := nil;
      FBrowser.OnInitializationError := nil;
      FBrowser.OnNewWindowRequested := nil;
      FBrowser.OnWindowCloseRequested := nil;
      FBrowser.OnNavigationCompleted := nil;
      FBrowser.OnWebMessageReceived := nil;

      FBrowserInitialized := False;
      
      // Garante que o Profile seja liberado após limpar os handlers
      CleanupProfile;
    except
      // Ignora exceções durante limpeza
    end;
  end;
end;

procedure TCustomFormWVBrowser.CleanupProfile;
begin
  // Libera Profile explicitamente
  if Assigned(FProfile) then
  begin
    try
      // Notifica mudança de posição antes de liberar
      if Assigned(FBrowser) and FBrowserInitialized then
        FBrowser.NotifyParentWindowPositionChanged;
        
      // Força a liberação do Profile
      FProfile := nil;
      
      // Garante que o Profile seja liberado
      if Assigned(FBrowser) and FBrowserInitialized and Assigned(FBrowser.CoreWebView2) then
      begin
        try
          FBrowser.CoreWebView2.Profile := nil;
        except
          // Ignora exceções durante liberação do Profile
        end;
      end;
    except
      // Ignora exceções durante liberação do Profile
    end;
  end;
end;

procedure TCustomFormWVBrowser.CreateMDIComponents(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
var
  OldForm: TCustomWVForm;
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

  if not Assigned(GlobalWebView2Loader) then
  begin
    GlobalWebView2Loader := TWVLoader.Create(nil);
    GlobalWebView2Loader.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'CustomCache';
    GlobalWebView2Loader.StartWebView2;
  end;

  try

    if ALegacyForm then
    begin
      Application.CreateForm(TCustomWVForm, FForm);

      if Assigned(AParentForm) then
      begin
        FForm.Parent := AParentForm;
        FForm.ParentWindow := AParentForm.Handle;
      end;
    end
    else
    begin
      FForm := TCustomWVForm.CreateWithArgs(AParentForm, nil);
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

constructor TCustomFormWVBrowser.Create;
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

constructor TCustomFormWVBrowser.Create(const AURL: String);
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

constructor TCustomFormWVBrowser.Create(const AURL: String; AParentObject: TObject; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
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

constructor TCustomFormWVBrowser.CreateAsBrowser(const AURL: String = '');
begin
  Self.Create(AURL);
end;

constructor TCustomFormWVBrowser.CreateAsPopup(AParentBrowser: TWVBrowser; const AURL: String = '');
begin
  if not Assigned(AParentBrowser) then
    raise Exception.Create('ParentBrowser n o pode ser nil para Popup');

  Self.Create(AURL, AParentBrowser);
end;

constructor TCustomFormWVBrowser.CreateAsMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = DEFAULT_LEGACY_FORM);
begin
  if not Assigned(AParentForm) then
    raise Exception.Create('ParentForm n o pode ser nil para MDI');
  if AParentForm.FormStyle <> fsMDIForm then
    raise Exception.Create('ParentForm deve ter FormStyle = fsMDIForm para usar MDI');

  Self.Create(AURL, AParentForm, ALegacyForm);
end;

class function TCustomFormWVBrowser.NewBrowser(const AURL: string): TCustomFormWVBrowser;
begin
  Result := TCustomFormWVBrowser.Create(AURL);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TCustomFormWVBrowser.NewPopup(const AURL: string; AParentBrowser: TWVBrowser = nil): TCustomFormWVBrowser;
begin
  Result := TCustomFormWVBrowser.Create(AURL, AParentBrowser);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

class function TCustomFormWVBrowser.NewMDI(const AURL: String; AParentForm: TForm): TCustomFormWVBrowser;
begin
  Result := TCustomFormWVBrowser.Create(AURL, AParentForm);
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.FForm.FormStyle := TFormStyle.fsStayOnTop;
end;

function TCustomFormWVBrowser.Recreate(const AURL: string): TCustomFormWVBrowser;
begin
  Result := TCustomFormWVBrowser.Create(AURL, nil, false);

  Result.Caption := Self.Caption;
  Result.Width := Self.Width;
  Result.Height := Self.Height;
  Result.FForm.BorderIcons := Self.ActionButtons;

  Result.CaptionPosition := Self.FCaptionPosition;
  Result.Resizable := Self.Resizable;
  Result.Movable := Self.Movable;
  Result.Alpha := false;

  if Self.FCookieName <> EmptyStr then
  begin
    Result.CookieName := Self.CookieName;
    Result.CookieValue := Self.CookieValue;
    Result.CookieDomain := Self.CookieDomain;
    Result.CookiePath := Self.CookiePath;
  end;

  Result.OnWindowOpened := Self.OnWindowOpened;
  Result.OnWindowClosed := Self.OnWindowClosed;
  Result.OnMessageSender := Self.OnMessageSender;
  Result.OnMessageReceiver := Self.OnMessageReceiver;
end;

destructor TCustomFormWVBrowser.Destroy;
begin
  try
    FIsClosing := True;

    if (FUniqueIdentifier <> EmptyStr) and not TCustomFormWVBrowser.FFinalizationStarted then
      UnregisterMDIInstance(FUniqueIdentifier, Self);

    // Para todos os timers
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

    // Limpa callbacks
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

    // Ordem específica de liberação para resolver memory leak do Profile

    // 1º - Libera Profile explicitamente ANTES de tudo
    CleanupProfile;

    // 2º - Libera Cookie
    if Assigned(FCookie) then
    begin
      FCookie := nil;
    end;

    // 3º - Remove event handlers e limpa browser
    if Assigned(FBrowser) then
    begin
      try
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
        
        // Garante que o Profile seja liberado após limpar os handlers
        CleanupProfile;
        
        FBrowserInitialized := False;
        
        // Libera o browser
        FreeAndNil(FBrowser);
      except
        // Ignora exceções durante limpeza
      end;
    end;

    // 4º - Libera WindowParent
    if Assigned(FWindowParent) then
    begin
      try
        FWindowParent.Browser := nil;
        FreeAndNil(FWindowParent);
      except
        // Ignora exceções durante liberação do WindowParent
      end;
    end;

    // 5º - Libera referência do form
    FForm := nil;

    // 6º - Garante que o Profile seja liberado uma última vez
    CleanupProfile;

    inherited;
  except
    // Ignora exceções durante destruição
  end;
end;

procedure TCustomFormWVBrowser.EnsureComponentsCreated;
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

procedure TCustomFormWVBrowser.InitComponents;
begin
  // WebBrowser
  FBrowser := TWVBrowser.Create(FForm);
  FBrowser.DefaultURL := EmptyStr;
  FBrowser.OnAfterCreated := Self.OnAfterCreated;
  FBrowser.OnDocumentTitleChanged := Self.OnDocTitleChanged;
  FBrowser.OnInitializationError := Self.OnInitError;
  FBrowser.OnNewWindowRequested := Self.OnNewWindowRequested;
  FBrowser.OnWindowCloseRequested := Self.OnWindowCloseRequested;
  FBrowser.OnNavigationCompleted := Self.OnNavigationCompleted;
  FBrowser.OnWebMessageReceived := Self.OnWebMessageReceived;

  // WebView2 Container
  FWindowParent := TWVWindowParent.Create(FForm);
  FWindowParent.Parent := FForm;
  FWindowParent.Align := alClient;
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

procedure TCustomFormWVBrowser.InitializePopupBrowser;
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

procedure TCustomFormWVBrowser.CheckInitializationTimer(Sender: TObject);
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

procedure TCustomFormWVBrowser.RestoreParentFormState(Sender: TObject);
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

procedure TCustomFormWVBrowser.WaitForBrowserInitialization(const ACallback: TProc);
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

procedure TCustomFormWVBrowser.OnAfterCreated(Sender: TObject);
begin
  FBrowserInitialized := True;
  ResizeBrowser;

  if FURL <> EmptyStr then
  begin
    if Assigned(FBrowser) then
    begin
      if (FCookieName <> EmptyStr) and (FCookieValue <> EmptyStr) and (FCookieDomain <> EmptyStr) then
      begin
        try
          // Libera Profile anterior se existir
          CleanupProfile;

          // Armazena o Profile em campo próprio
          if Assigned(FBrowser.CoreWebView2) then
          begin
            FProfile := FBrowser.CoreWebView2.Profile;
            if Assigned(FProfile) then
            begin
              FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
              if Assigned(FCookie) then
                FBrowser.AddOrUpdateCookie(FCookie);
            end;
          end;
        except
          // Em caso de exceção, garante que Profile seja liberado
          CleanupProfile;
        end;
      end;
      FBrowser.Navigate(FURL);
    end;
  end;
end;

procedure TCustomFormWVBrowser.OnDocTitleChanged(Sender: TObject);
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

procedure TCustomFormWVBrowser.OnInitError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  raise Exception.Create('WebView2 Initialization Error: ' + aErrorMessage);
end;

procedure TCustomFormWVBrowser.OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NavigationCompletedEventArgs);
begin
  Self.ResizeBrowser;
end;

procedure TCustomFormWVBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  Self.TryCreateBrowser;
end;

procedure TCustomFormWVBrowser.OnWebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
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

procedure TCustomFormWVBrowser.OnNewWindowRequested(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
var
  TempBrowser: TCustomFormWVBrowser;
  Deferral: ICoreWebView2Deferral;
  Uri: PWideChar;
  WindowFeatures: ICoreWebView2WindowFeatures;
  HasPosition, HasSize: Integer;
  WinLeft, WinTop, WinWidth, WinHeight: Cardinal;
  UriString: string;
  DummyAction: Integer;
begin
  DummyAction := 0;
  try
    if Succeeded(aArgs.GetDeferral(Deferral)) then
    begin
      try
        UriString := EmptyStr;
        if Succeeded(aArgs.Get_uri(Uri)) then
          UriString := string(Uri);

        TempBrowser := TCustomFormWVBrowser.NewPopup(DEFAULT_URL);

        if Assigned(TempBrowser) then
        begin
          TempBrowser.FOnWindowClosed := Self.OnPopupClosed;
          TempBrowser.FOnWindowOpened := Self.OnPopupOpened;

          if Succeeded(aArgs.Get_WindowFeatures(WindowFeatures)) then
          begin
            if Succeeded(WindowFeatures.Get_HasPosition(HasPosition)) and (HasPosition <> 0) then
            begin
              if Succeeded(WindowFeatures.Get_Left(WinLeft)) and
                 Succeeded(WindowFeatures.Get_Top(WinTop)) then
              begin
                if Assigned(TempBrowser.FForm) then
                begin
                  TempBrowser.FForm.Position := poDesigned;
                  TempBrowser.FForm.Left := Integer(WinLeft);
                  TempBrowser.FForm.Top := Integer(WinTop);
                end;
              end;
            end;

            if Succeeded(WindowFeatures.Get_HasSize(HasSize)) and (HasSize <> 0) then
            begin
              if Succeeded(WindowFeatures.Get_Width(WinWidth)) and
                 Succeeded(WindowFeatures.Get_Height(WinHeight)) then
              begin
                if Assigned(TempBrowser.FForm) then
                begin
                  TempBrowser.FForm.Width := Integer(WinWidth);
                  TempBrowser.FForm.Height := Integer(WinHeight) + 22;
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
                      DecodedContent := DecodeDataURL(UriString);
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
          raise Exception.Create('Erro ao criar popup: ' + E.Message);
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

procedure TCustomFormWVBrowser.OnWindowCloseRequested(Sender: TObject);
begin
  PostMessage(FForm.Handle, WM_CLOSE, 0, 0);
end;

procedure TCustomFormWVBrowser.OnPopupOpened(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup foi concluiu a abertura! Inst ncia: ' + TCustomFormWVBrowser(Sender).ClassName);
end;

procedure TCustomFormWVBrowser.OnPopupClosed(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup foi fechado! Inst ncia: ' + TCustomFormWVBrowser(Sender).ClassName);
end;

function TCustomFormWVBrowser.DecodeDataURL(const DataURL: string): string;
var
  CommaPos: Integer;
  DataPart: string;
begin
  Result := EmptyStr;
  CommaPos := Pos(',', DataURL);
  if CommaPos > 0 then
  begin
    DataPart := Copy(DataURL, CommaPos + 1, Length(DataURL));
    DataPart := StringReplace(DataPart, '%20', ' ', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%0A', #10, [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%0D', #13, [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%22', '"', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%3C', '<', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%3E', '>', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%3D', '=', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%2F', '/', [rfReplaceAll]);

    Result := DataPart;
  end;
end;

procedure TCustomFormWVBrowser.TryCreateBrowser;
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

procedure TCustomFormWVBrowser.ResizeBrowser;
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

procedure TCustomFormWVBrowser.Show(const AType: TOpenType = TOpenType.Default);
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

procedure TCustomFormWVBrowser.ShowModal(const AType: TOpenType = TOpenType.Modal);
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

procedure TCustomFormWVBrowser.ShowAsModal(AParentForm: TForm = nil);
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

procedure TCustomFormWVBrowser.ConvertToMDI(AParentForm: TForm; AutoShow: Boolean);
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

procedure TCustomFormWVBrowser.ShowAsMDI;
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

procedure TCustomFormWVBrowser.ShowAsMDI(const AOptions: TMDIOptions);
var
  ExistingInstance: TCustomFormWVBrowser;
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

procedure TCustomFormWVBrowser.ShowAsMDICustom(AutoShow: Boolean = True);
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

procedure TCustomFormWVBrowser.ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
begin
  if not Assigned(FParentForm) then
    Exit;

  if FParentForm.FormStyle <> fsMDIForm then
    Exit;

  Self.ShowAsMDICustom(AutoShow);

  if AutoShow and Assigned(FForm) and MaximizeOnShow then
    FForm.WindowState := wsMaximized;
end;

procedure TCustomFormWVBrowser.ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
var
  ExistingBrowser: TCustomFormWVBrowser;
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
    FForm.WindowState := wsMaximized;
end;

initialization
  TCustomFormWVBrowser.FFinalizationStarted := False;

finalization
  TCustomFormWVBrowser.CleanupMDIRegistry;

end.

