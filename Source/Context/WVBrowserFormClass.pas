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
  DEBUG_MODE = False;

type
  TCustomFormWVBrowser = class;

  TCallbackInfo = record
    Timer: TTimer;
    Callback: TProc;
  end;

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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
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
    FParentBrowser: TWVBrowser;
    FCheckTimer: TTimer;
    FCallbackList: TList<TCallbackInfo>;
    FOnWindowOpened: TNotifyEvent;
    FOnWindowClosed: TNotifyEvent;
    FParentFormToRestore: TForm;
    FParentFormEnabledState: Boolean;
    FOriginalOnWindowClosed: TNotifyEvent;
    FIsModalMode: Boolean;

    // Internal Methods
    procedure InitComponents;
    procedure CreateComponents(AParentBrowser: TWVBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
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
    procedure TryCreateBrowser;
    procedure ResizeBrowser;
    procedure InitializePopupBrowser;
    procedure WaitForBrowserInitialization(const ACallback: TProc);
    procedure CheckInitializationTimer(Sender: TObject);
    procedure RestoreParentFormState(Sender: TObject);
    function DecodeDataURL(const DataURL: string): string;
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
    function GetWindowOpenedProp: TNotifyEvent;
    function GetWindowClosedProp: TNotifyEvent;
    function ReadMessageReceiverProp: TMessageReceiverCallback;
    function ReadMessageSenderProp: String;

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
    procedure SetWindowOpenedProp(const Value: TNotifyEvent);
    procedure SetWindowClosedProp(const Value: TNotifyEvent);
    procedure SetMessageReceiverProp(const Value: TMessageReceiverCallback);
    procedure SetMessageSenderProp(const Value: String);
  public
    // Constructor and Destructor
    constructor Create(const AURL: String = ''); overload;
    constructor CreateAsPopup(AParentBrowser: TWVBrowser; const AURL: String = ''); overload;
    function CreateInheritedPopup(const AURL: string): TCustomFormWVBrowser; overload;
    class function CreateAsPopup(const AURL: string): TCustomFormWVBrowser; overload;
    destructor Destroy; override;

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
    function IBrowserForm.SetWindowOpened = ISetWindowOpened;
    function IBrowserForm.SetWindowClosed = ISetWindowClosed;
    function IBrowserForm.SetHTMLContent = ISetHTMLContent;
    function IBrowserForm.SetMessageReceiver = ISetMessageReceiver;
    function IBrowserForm.SetMessageSender = ISetMessageSender;

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
    function ISetWindowOpened(const AEvent: TNotifyEvent): IBrowserForm;
    function ISetWindowClosed(const AEvent: TNotifyEvent): IBrowserForm;
    function ISetHTMLContent(const AHTMLContent: String): IBrowserForm;
    function ISetMessageReceiver(const AMessage: TMessageReceiverCallback): IBrowserForm;
    function ISetMessageSender(const AMessage: String): IBrowserForm;

    // Final Method
    procedure Show(const AType: TOpenType = TOpenType.Normal);
    procedure ShowModal(const AType: TOpenType = TOpenType.Modal);
    procedure ShowAsModal(AParentForm: TForm = nil);
    procedure ShowAsMDI(TFormulario: TComponentClass; var Formulario; AutoShow: Boolean = True);
    procedure ShowAsMDIAdvanced(TFormulario: TComponentClass; var Formulario; AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True);

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
    property OnMessageReceiver: TMessageReceiverCallback read ReadMessageReceiverProp write SetMessageReceiverProp;
    property OnMessageSender: String read ReadMessageSenderProp write SetMessageSenderProp;
    property OnWindowOpened: TNotifyEvent read GetWindowOpenedProp write SetWindowOpenedProp;
    property OnWindowClosed: TNotifyEvent read GetWindowClosedProp write SetWindowClosedProp;
    property IsPopup: Boolean read FIsPopup;
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
  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
    (BrowserInstance as TCustomFormWVBrowser).FBrowser.NotifyParentWindowPositionChanged;

  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TCustomFormWVBrowser).FOnWindowClosed) then
    (BrowserInstance as TCustomFormWVBrowser).FOnWindowClosed(BrowserInstance as TCustomFormWVBrowser);
end;

procedure TCustomWVForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
    (BrowserInstance as TCustomFormWVBrowser).FBrowser.ExecuteScript('window.dispatchEvent(new Event("beforeunload"))');
end;

procedure TCustomWVForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FDeferral) then
    FreeAndNil(FDeferral);

  if Assigned(FArgs) then
    FreeAndNil(FArgs);
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
    CenterToScreenWithMonitor;
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
    ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormWVBrowser.SetHeight(const AHeight: Integer): TCustomFormWVBrowser;
begin
  FHeight := AHeight;
  if Assigned(FForm) then
  begin
    FForm.ClientHeight := AHeight;
    ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormWVBrowser.SetCaption(const ACaption: String; APosition: TPositionCaption): TCustomFormWVBrowser;
begin
  FCaption := ACaption;
  FCaptionPosition := APosition;
  if FBrowserInitialized then
    OnDocTitleChanged(FBrowser);
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

// Context

procedure TCustomFormWVBrowser.CreateComponents(AParentBrowser: TWVBrowser = nil; AIsPopup: Boolean = false; const AURL: String = '');
begin
  FParentFormToRestore := nil;
  FParentFormEnabledState := True;
  FOriginalOnWindowClosed := nil;
  FIsModalMode := False;

  FWidth := 800;
  FHeight := 600;
  FURL := AURL;
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

constructor TCustomFormWVBrowser.Create(const AURL: String = '');
begin
  inherited Create;

  Self.CreateComponents(nil, false, AURL);
end;

class function TCustomFormWVBrowser.CreateAsPopup(const AURL: string): TCustomFormWVBrowser;
begin
  Result := TCustomFormWVBrowser.Create(AURL);
  Result.Caption := 'Exemplo';
  Result.Width := 2048;
  Result.Height := 1024;
  Result.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  Result.Resizable := true;
  Result.Movable := true;
  Result.CookieName := 'CookieName';
  Result.CookieValue := 'CookieValue';
  Result.CookieDomain := 'CookieDomain';
end;

constructor TCustomFormWVBrowser.CreateAsPopup(AParentBrowser: TWVBrowser; const AURL: String = '');
begin
  inherited Create;

  Self.CreateComponents(AParentBrowser, true, AURL);
end;

function TCustomFormWVBrowser.CreateInheritedPopup(const AURL: string): TCustomFormWVBrowser;
begin
  Result := TCustomFormWVBrowser.Create(AURL);

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
  if Assigned(FBrowser) then
    FBrowser.Free;
  if Assigned(FWindowParent) then
    FWindowParent.Free;
  if Assigned(FTimer) then
    FTimer.Free;
  if Assigned(FForm) then
    FForm.Free;
  if Assigned(FCheckTimer) then
    FCheckTimer.Free;
   if Assigned(FCallbackList) then
   begin
     while FCallbackList.Count > 0 do
     begin
       FCallbackList[0].Timer.Free;
       FCallbackList.Delete(0);
     end;
     FCallbackList.Free;
   end;
   inherited;
end;

procedure TCustomFormWVBrowser.InitComponents;
begin
  // WebBrowser
  FBrowser := TWVBrowser.Create(FForm);
  FBrowser.DefaultURL := EmptyStr;
  FBrowser.OnAfterCreated := OnAfterCreated;
  FBrowser.OnDocumentTitleChanged := OnDocTitleChanged;
  FBrowser.OnInitializationError := OnInitError;
  FBrowser.OnNewWindowRequested := OnNewWindowRequested;
  FBrowser.OnWindowCloseRequested := OnWindowCloseRequested;
  FBrowser.OnNavigationCompleted := OnNavigationCompleted;
  FBrowser.OnWebMessageReceived := OnWebMessageReceived;

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

    if FURL <> '' then
    begin
      FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
      if Assigned(FCookie) then
        FBrowser.AddOrUpdateCookie(FCookie);
      FBrowser.Navigate(FURL);
    end;

    FBrowserInitialized := True;
    ResizeBrowser;
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

  if FURL <> '' then
  begin
    if Assigned(FBrowser) then
    begin
       if (FCookieName <> '') and (FCookieValue <> '') and (FCookieDomain <> '') then
      begin
        FCookie := FBrowser.CreateCookie(FCookieName, FCookieValue, FCookieDomain, FCookiePath);
        if Assigned(FCookie) then
          FBrowser.AddOrUpdateCookie(FCookie);
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
  ShowMessage('WebView2 Initialization Error: ' + aErrorMessage);
end;

procedure TCustomFormWVBrowser.OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2NavigationCompletedEventArgs);
begin
  ResizeBrowser;
end;

procedure TCustomFormWVBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  TryCreateBrowser;
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
begin
  try
    if Succeeded(aArgs.GetDeferral(Deferral)) then
    begin
      try
        UriString := '';
        if Succeeded(aArgs.Get_uri(Uri)) then
          UriString := string(Uri);

        if DEBUG_MODE then
          TempBrowser := Self.CreateInheritedPopup('about:blank')
        else
          TempBrowser := TCustomFormWVBrowser.CreateAsPopup('about:blank');

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

          if DEBUG_MODE then
          begin
            TempBrowser.FOriginalOnWindowClosed := Self.OnPopupClosed;
            TempBrowser.ShowAsModal(Self.FForm);
          end
          else
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
                    if UriString = 'about:blank' then
                    begin
                      // Para about:blank, aguarda o JavaScript injetar o conteúdo
                      // Não fazemos nada aqui, o conteúdo será injetado pelo JS
                    end
                    else if Pos('data:text/html', UriString) = 1 then
                    begin
                      DecodedContent := DecodeDataURL(UriString);
                      if DecodedContent <> '' then
                        TempBrowser.SetHTMLContent(DecodedContent);
                    end
                    else
                    begin
                      TempBrowser.FBrowser.Navigate(UriString);
                    end;
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
          ShowMessage('Erro ao criar popup: ' + E.Message);
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
    ShowMessage('Popup foi concluiu a abertura! Instância: ' + TCustomFormWVBrowser(Sender).ClassName);
end;

procedure TCustomFormWVBrowser.OnPopupClosed(Sender: TObject);
begin
  if DEBUG_MODE then
    ShowMessage('Popup foi fechado! Instância: ' + TCustomFormWVBrowser(Sender).ClassName);
end;

function TCustomFormWVBrowser.DecodeDataURL(const DataURL: string): string;
var
  CommaPos: Integer;
  DataPart: string;
begin
  Result := '';
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
    ShowMessage(GlobalWebView2Loader.ErrorMessage)
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

procedure TCustomFormWVBrowser.Show(const AType: TOpenType = TOpenType.Normal);
begin
  if Assigned(FForm) then
  begin
    if AType = TOpenType.Normal then
      FForm.Show
    else
      FForm.ShowModal;
  end;
end;

procedure TCustomFormWVBrowser.ShowModal(const AType: TOpenType = TOpenType.Modal);
begin
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

procedure TCustomFormWVBrowser.ShowAsMDI(TFormulario: TComponentClass; var Formulario; AutoShow: Boolean = True);
var
  Form: TForm;
  ExistingForm: TForm;
  i: Integer;
begin
  ExistingForm := nil;
  if Assigned(Application.MainForm) then
  begin
    for i := 0 to Application.MainForm.MDIChildCount - 1 do
    begin
      if Application.MainForm.MDIChildren[i].ClassType = TFormulario then
      begin
        ExistingForm := Application.MainForm.MDIChildren[i];
        Break;
      end;
    end;
  end;

  if Assigned(ExistingForm) then
  begin
    TForm(Formulario) := ExistingForm;
    if AutoShow then
    begin
      ExistingForm.Show;
      ExistingForm.BringToFront;
      if ExistingForm.CanFocus then
        ExistingForm.SetFocus;
    end;
  end
  else
  begin
    try
      if not Assigned(Application.MainForm) then
        raise Exception.Create('Application.MainForm não está definido');

      if Application.MainForm.FormStyle <> fsMDIForm then
        raise Exception.Create('MainForm deve ter FormStyle = fsMDIForm para usar MDI');

      Form := TFormulario.Create(Application.MainForm) as TForm;

      Form.FormStyle := fsMDIChild;
      Form.WindowState := wsMaximized;

      TForm(Formulario) := Form;

      if AutoShow then
      begin
        Form.Show;
        if Form.CanFocus then
          Form.SetFocus;
      end;

    except
      on E: Exception do
      begin
        TForm(Formulario) := nil;
        raise Exception.Create('Erro ao criar formulário MDI: ' + E.Message);
      end;
    end;
  end;
end;

procedure TCustomFormWVBrowser.ShowAsMDIAdvanced(TFormulario: TComponentClass; var Formulario; AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True);
var
  Form: TForm;
  ExistingForm: TForm;
  i: Integer;
  MDIParent: TForm;
begin
  MDIParent := Application.MainForm;
  if not Assigned(MDIParent) then
    raise Exception.Create('Application.MainForm não está definido');

  if MDIParent.FormStyle <> fsMDIForm then
    raise Exception.Create('MainForm deve ter FormStyle = fsMDIForm para usar MDI');

  ExistingForm := nil;
  if SingleInstance then
  begin
    for i := 0 to MDIParent.MDIChildCount - 1 do
    begin
      if MDIParent.MDIChildren[i].ClassType = TFormulario then
      begin
        ExistingForm := MDIParent.MDIChildren[i];
        Break;
      end;
    end;
  end;

  if Assigned(ExistingForm) then
  begin
    TForm(Formulario) := ExistingForm;
    if AutoShow then
    begin
      if ExistingForm.WindowState = wsMinimized then
        ExistingForm.WindowState := wsNormal;

      ExistingForm.Show;

      if BringToFrontIfExists then
        ExistingForm.BringToFront;

      if MaximizeOnShow and (ExistingForm.WindowState <> wsMaximized) then
        ExistingForm.WindowState := wsMaximized;

      if ExistingForm.CanFocus then
        ExistingForm.SetFocus;
    end;
  end
  else
  begin
    try
      Form := TFormulario.Create(MDIParent) as TForm;
      Form.FormStyle := fsMDIChild;

      if MaximizeOnShow then
        Form.WindowState := wsMaximized;

      TForm(Formulario) := Form;

      if AutoShow then
      begin
        Form.Show;
        if Form.CanFocus then
          Form.SetFocus;
      end;

    except
      on E: Exception do
      begin
        TForm(Formulario) := nil;
        raise Exception.Create('Erro ao criar formulário MDI: ' + E.Message);
      end;
    end;
  end;
end;

end.
