unit WVBrowserFormClass;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  uWVBrowser, uWVWindowParent, uWVTypes, uWVLoader, uWVLibFunctions,
  uWVConstants, uWVCoreWebView2, uWVInterfaces, uWVTypeLibrary,

  BrowserFormTypes,
  BrowserFormInterface;

type
  TCustomFormWVBrowser = class;

  TCustomWVForm = class(TForm)
  strict private
    FInitialized: Boolean;
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
  end;

  TCustomFormWVBrowser = class(TInterfacedObject, IBrowserForm)
  private
    FForm: TCustomWVForm;
    FBrowser: TWVBrowser;
    FWindowParent: TWVWindowParent;
    FTimer: TTimer;
    FWidth: Integer;
    FHeight: Integer;
    FPendingURL: string;
    FBrowserInitialized: Boolean;
    FCaption: string;
    FCaptionPosition: TPositionCaption;
    FMovable: Boolean;

    // Internal Methods
    procedure InitComponents;
    procedure OnTimer(Sender: TObject);
    procedure OnAfterCreated(Sender: TObject);
    procedure OnDocTitleChanged(Sender: TObject);
    procedure OnInitError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const Args: ICoreWebView2NavigationCompletedEventArgs);
    procedure TryCreateBrowser;
    procedure ResizeBrowser;
  protected
    // Getters
    function GetWidthProp: Integer;
    function GetHeightProp: Integer;
    function GetCaptionProp: String;
    function GetCaptionPositionProp: TPositionCaption;
    function GetActionButtonsProp: TBorderIcons;
    function GetResizableProp: Boolean;
    function GetMovableProp: Boolean;

    // Setters
    procedure SetWidthProp(const Value: Integer);
    procedure SetHeightProp(const Value: Integer);
    procedure SetCaptionProp(const Value: string);
    procedure SetCaptionPositionProp(const Value: TPositionCaption);
    procedure SetActionButtonsProp(const Value: TBorderIcons);
    procedure SetResizableProp(const Value: Boolean);
    procedure SetMovableProp(const Value: Boolean);
  public
    // Constructor and Destructor
    constructor Create(const AInitialURL: string);
    destructor Destroy; override;

    // Fluent Chainable Methods
    function SetWidth(const AWidth: Integer): TCustomFormWVBrowser;
    function SetHeight(const AHeight: Integer): TCustomFormWVBrowser;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Before): TCustomFormWVBrowser;
    function SetActionButtons(const AButton: TBorderIcons): TCustomFormWVBrowser;
    function SetResizable(const AResize: Boolean): TCustomFormWVBrowser;
    function SetMovable(const AMove: Boolean): TCustomFormWVBrowser;

    // Interface Methods
    function IBrowserForm.SetWidth = ISetWidth;
    function IBrowserForm.SetHeight = ISetHeight;
    function IBrowserForm.SetCaption = ISetCaption;
    function IBrowserForm.SetActionButtons = ISetActionButtons;
    function IBrowserForm.SetResizable = ISetResizable;
    function IBrowserForm.SetMovable = ISetMovable;

    function ISetWidth(const AWidth: Integer): IBrowserForm;
    function ISetHeight(const AHeight: Integer): IBrowserForm;
    function ISetCaption(const ACaption: string; APosition: TPositionCaption): IBrowserForm;
    function ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
    function ISetResizable(const AResize: Boolean): IBrowserForm;
    function ISetMovable(const AMove: Boolean): IBrowserForm;

    // Final Method
    procedure Show(const AType: TOpenType = TOpenType.Normal);
    procedure ShowModal(const AType: TOpenType = TOpenType.Modal);

    // Properties
    property Width: Integer read GetWidthProp write SetWidthProp;
    property Height: Integer read GetHeightProp write SetHeightProp;
    property Caption: string read GetCaptionProp write SetCaptionProp;
    property CaptionPosition: TPositionCaption read GetCaptionPositionProp write SetCaptionPositionProp;
    property ActionButtons: TBorderIcons read GetActionButtonsProp write SetActionButtonsProp;
    property Resizable: Boolean read GetResizableProp write SetResizableProp;
    property Movable: Boolean read GetMovableProp write SetMovableProp;
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

procedure TCustomWVForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(BrowserInstance) and Assigned((BrowserInstance as TCustomFormWVBrowser).FBrowser) then
    (BrowserInstance as TCustomFormWVBrowser).FBrowser.NotifyParentWindowPositionChanged;
end;

procedure TCustomWVForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
end;

procedure TCustomWVForm.FormDestroy(Sender: TObject);
begin
  // Implement Custom Safe Destroy
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

constructor TCustomFormWVBrowser.Create(const AInitialURL: string);
begin
  inherited Create;
  FWidth := 800;
  FHeight := 600;
  FPendingURL := AInitialURL;
  FCaption := EmptyStr;
  FCaptionPosition := TPositionCaption.Before;
  FMovable := True;
  FBrowserInitialized := False;

  if not Assigned(GlobalWebView2Loader) then
  begin
    GlobalWebView2Loader := TWVLoader.Create(nil);
    GlobalWebView2Loader.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'CustomCache';
    GlobalWebView2Loader.StartWebView2;
  end;

  FForm := TCustomWVForm.CreateNew(nil);
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
  FForm.Constraints.MinWidth := FWidth;
  FForm.Constraints.MinHeight := FHeight;

  InitComponents;
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
  FBrowser.OnNavigationCompleted := OnNavigationCompleted;

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

procedure TCustomFormWVBrowser.OnAfterCreated(Sender: TObject);
begin
  FBrowserInitialized := True;
  ResizeBrowser;

  if FPendingURL <> '' then
    FBrowser.Navigate(FPendingURL);
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
    TPositionCaption.None:
      FForm.Caption := Title;
  end;
end;


procedure TCustomFormWVBrowser.OnInitError(Sender: TObject; aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  ShowMessage('WebView2 Initialization Error: ' + aErrorMessage);
end;

procedure TCustomFormWVBrowser.OnNavigationCompleted(Sender: TObject; const aWebView: ICoreWebView2; const Args: ICoreWebView2NavigationCompletedEventArgs);
begin
  ResizeBrowser;
end;

procedure TCustomFormWVBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  TryCreateBrowser;
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
        FBrowser.CreateBrowser(FWindowParent.Handle);
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

end.
