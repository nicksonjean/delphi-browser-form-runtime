unit WebBrowserFormClass;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  Vcl.OleCtrls, SHDocVw, MSHTML,

  BrowserFormTypes,
  BrowserFormInterface;

type
  TCustomFormWebBrowser = class;

  TCustomWebForm = class(TForm)
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

  TCustomFormWebBrowser = class(TInterfacedObject, IBrowserForm)
  private
    FForm: TCustomWebForm;
    FBrowser: TWebBrowser;
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
    procedure OnNavigateComplete2(Sender: TObject; const pDisp: IDispatch; const URL: OleVariant);
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
    function SetWidth(const AWidth: Integer): TCustomFormWebBrowser;
    function SetHeight(const AHeight: Integer): TCustomFormWebBrowser;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Before): TCustomFormWebBrowser;
    function SetActionButtons(const AButton: TBorderIcons): TCustomFormWebBrowser;
    function SetResizable(const AResize: Boolean): TCustomFormWebBrowser;
    function SetMovable(const AMove: Boolean): TCustomFormWebBrowser;

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

{ TCustomWebForm }

procedure TCustomWebForm.CenterToScreenWithMonitor;
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

procedure TCustomWebForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Implement Custom Safe Close
end;

procedure TCustomWebForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
end;

procedure TCustomWebForm.FormDestroy(Sender: TObject);
begin
  // Implement Custom Safe Destroy
end;

procedure TCustomWebForm.FormResize(Sender: TObject);
begin
  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormWebBrowser).ResizeBrowser;
end;

procedure TCustomWebForm.FormShow(Sender: TObject);
begin
  if not FInitialized then
  begin
    CenterToScreenWithMonitor;
    FInitialized := True;
  end;

  if Assigned(BrowserInstance) then
    (BrowserInstance as TCustomFormWebBrowser).TryCreateBrowser;
end;

procedure TCustomWebForm.WMMove(var aMessage: TWMMove);
begin
  inherited;
end;

procedure TCustomWebForm.WMMoving(var aMessage: TMessage);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TCustomFormWebBrowser).FMovable then
  begin
    CenterToScreenWithMonitor;
    aMessage.Result := 1;
    Exit;
  end;

  inherited;
end;

procedure TCustomWebForm.WMSize(var aMessage: TMessage);
begin
  inherited;
end;

procedure TCustomWebForm.WMWindowPosChanging(var aMessage: TWMWindowPosChanging);
begin
  if Assigned(BrowserInstance) and not (BrowserInstance as TCustomFormWebBrowser).FMovable then
  begin
    CenterToScreenWithMonitor;
    aMessage.WindowPos^.flags := aMessage.WindowPos^.flags or SWP_NOMOVE;
  end;

  inherited;
end;

{ TCustomFormWebBrowser }

// Interface Methods

function TCustomFormWebBrowser.ISetWidth(const AWidth: Integer): IBrowserForm;
begin
  SetWidth(AWidth);
  Result := Self;
end;

function TCustomFormWebBrowser.ISetHeight(const AHeight: Integer): IBrowserForm;
begin
  SetHeight(AHeight);
  Result := Self;
end;

function TCustomFormWebBrowser.ISetCaption(const ACaption: string; APosition: TPositionCaption): IBrowserForm;
begin
  SetCaption(ACaption, APosition);
  Result := Self;
end;

function TCustomFormWebBrowser.ISetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
begin
  SetActionButtons(AButtons);
  Result := Self;
end;

function TCustomFormWebBrowser.ISetResizable(const AResize: Boolean): IBrowserForm;
begin
  SetResizable(AResize);
  Result := Self;
end;

function TCustomFormWebBrowser.ISetMovable(const AMove: Boolean): IBrowserForm;
begin
  SetMovable(AMove);
  Result := Self;
end;

// Getters

function TCustomFormWebBrowser.GetWidthProp: Integer;
begin
  Result := FWidth;
end;

function TCustomFormWebBrowser.GetHeightProp: Integer;
begin
  Result := FHeight;
end;

function TCustomFormWebBrowser.GetCaptionProp: string;
begin
  Result := FCaption;
end;

function TCustomFormWebBrowser.GetCaptionPositionProp: TPositionCaption;
begin
  Result := FCaptionPosition;
end;

function TCustomFormWebBrowser.GetActionButtonsProp: TBorderIcons;
begin
  Result := FForm.BorderIcons;
end;

function TCustomFormWebBrowser.GetResizableProp: Boolean;
begin
  Result := FForm.BorderStyle = TFormBorderStyle.bsSizeable;
end;

function TCustomFormWebBrowser.GetMovableProp: Boolean;
begin
  Result := FMovable;
end;

// Setters

procedure TCustomFormWebBrowser.SetWidthProp(const Value: Integer);
begin
  SetWidth(Value);
end;

procedure TCustomFormWebBrowser.SetHeightProp(const Value: Integer);
begin
  SetHeight(Value);
end;

procedure TCustomFormWebBrowser.SetCaptionProp(const Value: string);
begin
  SetCaption(Value, FCaptionPosition);
end;

procedure TCustomFormWebBrowser.SetCaptionPositionProp(const Value: TPositionCaption);
begin
  FCaptionPosition := Value;
  SetCaption(FCaption, Value);
end;

procedure TCustomFormWebBrowser.SetActionButtonsProp(const Value: TBorderIcons);
begin
  SetActionButtons(Value);
end;

procedure TCustomFormWebBrowser.SetResizableProp(const Value: Boolean);
begin
  SetResizable(Value);
end;

procedure TCustomFormWebBrowser.SetMovableProp(const Value: Boolean);
begin
  SetMovable(Value);
end;

// Chainable Methods

function TCustomFormWebBrowser.SetWidth(const AWidth: Integer): TCustomFormWebBrowser;
begin
  FWidth := AWidth;
  if Assigned(FForm) then
  begin
    FForm.ClientWidth := AWidth;
    ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormWebBrowser.SetHeight(const AHeight: Integer): TCustomFormWebBrowser;
begin
  FHeight := AHeight;
  if Assigned(FForm) then
  begin
    FForm.ClientHeight := AHeight;
    ResizeBrowser;
  end;
  Result := Self;
end;

function TCustomFormWebBrowser.SetCaption(const ACaption: String; APosition: TPositionCaption): TCustomFormWebBrowser;
begin
  FCaption := ACaption;
  FCaptionPosition := APosition;
  if FBrowserInitialized then
    OnDocTitleChanged(FBrowser);
  Result := Self;
end;

function TCustomFormWebBrowser.SetActionButtons(const AButton: TBorderIcons): TCustomFormWebBrowser;
begin
  FForm.BorderIcons := FForm.BorderIcons - AButton;
  Result := Self;
end;

function TCustomFormWebBrowser.SetResizable(const AResize: Boolean): TCustomFormWebBrowser;
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

function TCustomFormWebBrowser.SetMovable(const AMove: Boolean): TCustomFormWebBrowser;
begin
  FMovable := AMove;
  if Assigned(FForm) and not AMove then
    FForm.CenterToScreenWithMonitor;
  Result := Self;
end;

constructor TCustomFormWebBrowser.Create(const AInitialURL: string);
begin
  inherited Create;
  FWidth := 800;
  FHeight := 600;
  FPendingURL := AInitialURL;
  FCaption := EmptyStr;
  FCaptionPosition := TPositionCaption.Before;
  FMovable := True;
  FBrowserInitialized := False;

  FForm := TCustomWebForm.CreateNew(nil);
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

destructor TCustomFormWebBrowser.Destroy;
begin
  if Assigned(FBrowser) then
    FBrowser.Free;
  if Assigned(FTimer) then
    FTimer.Free;
  if Assigned(FForm) then
    FForm.Free;
  inherited;
end;

procedure TCustomFormWebBrowser.InitComponents;
begin
  // WebBrowser
  FBrowser := TWebBrowser.Create(FForm);
  FBrowser.SetParentComponent(FForm);
  FBrowser.Align := alClient;
  FBrowser.OnNavigateComplete2 := OnNavigateComplete2;

  // Timer
  FTimer := TTimer.Create(FForm);
  FTimer.Enabled := False;
  FTimer.Interval := 100;
  FTimer.OnTimer := OnTimer;
end;

procedure TCustomFormWebBrowser.OnAfterCreated(Sender: TObject);
begin
  FBrowserInitialized := True;
  ResizeBrowser;

  FForm.SetFocus;
end;

procedure TCustomFormWebBrowser.OnDocTitleChanged(Sender: TObject);
var
  Doc: IHTMLDocument2;
begin
  if Assigned(FBrowser.Document) then
  begin
    Doc := FBrowser.Document as IHTMLDocument2;

    case FCaptionPosition of
      TPositionCaption.Before:
        FForm.Caption := FCaption + ' - ' + Doc.title;
      TPositionCaption.After:
        FForm.Caption := Doc.title + ' - ' + FCaption;
      TPositionCaption.Replaced:
        FForm.Caption := FCaption;
      TPositionCaption.None:
        FForm.Caption := Doc.title;
    end;
  end;
end;

procedure TCustomFormWebBrowser.OnNavigateComplete2(Sender: TObject; const pDisp: IDispatch; const URL: OleVariant);
begin
  OnAfterCreated(Sender);
  OnDocTitleChanged(Sender);
  ResizeBrowser;
end;

procedure TCustomFormWebBrowser.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  TryCreateBrowser;
end;

procedure TCustomFormWebBrowser.TryCreateBrowser;
begin
  if Assigned(FBrowser) and (FPendingURL <> '') then
    FBrowser.Navigate(FPendingURL);
end;

procedure TCustomFormWebBrowser.ResizeBrowser;
begin
  //
end;

procedure TCustomFormWebBrowser.Show(const AType: TOpenType = TOpenType.Normal);
begin
  if Assigned(FForm) then
  begin
    if AType = TOpenType.Normal then
      FForm.Show
    else
      FForm.ShowModal;
  end;
end;

procedure TCustomFormWebBrowser.ShowModal(const AType: TOpenType = TOpenType.Modal);
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

