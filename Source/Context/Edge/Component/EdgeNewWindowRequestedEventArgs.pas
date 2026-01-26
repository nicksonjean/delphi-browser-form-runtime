unit EdgeNewWindowRequestedEventArgs;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  Vcl.Edge,
  WebView2,
  EdgeDeferral;

const
  IID_ICoreWebView2WindowFeatures: TGUID = '{5EF2FD94-9DDB-4B57-8D5A-FA5E8B4A3B42}';

type
  TEdgeNewWindowRequestedEventArgs = class
  private
    FArgs: ICoreWebView2NewWindowRequestedEventArgs;
    FUri: string;
    FHandled: Boolean;
    FNewWindow: ICoreWebView2;
    FDeferral: TEdgeDeferral;
    FDeferralCompleted: Boolean;
  public
    constructor Create(AArgs: TNewWindowRequestedEventArgs); overload;
    constructor Create(AArgs: ICoreWebView2NewWindowRequestedEventArgs); overload;
    destructor Destroy; override;

    function GetUri: string;
    function GetHandled: Boolean;
    function GetCoreArgs: ICoreWebView2NewWindowRequestedEventArgs;
    function GetDeferral: TEdgeDeferral;
    procedure SetHandled(AHandled: Boolean);
    procedure SetNewWindow(ANewWindow: ICoreWebView2);

    function TryGetWindowFeatures: Boolean;
    procedure CompleteDeferral;

    property Uri: string read GetUri;
    property Handled: Boolean read GetHandled write SetHandled;
    property CoreArgs: ICoreWebView2NewWindowRequestedEventArgs read GetCoreArgs;
    property Deferral: TEdgeDeferral read GetDeferral;
  end;

implementation

constructor TEdgeNewWindowRequestedEventArgs.Create(AArgs: ICoreWebView2NewWindowRequestedEventArgs);
var
  Uri: PWideChar;
begin
  inherited Create;
  FArgs := AArgs;
  FHandled := False;
  FUri := '';
  FDeferral := nil;
  FDeferralCompleted := False;

  if Assigned(FArgs) and Succeeded(FArgs.Get_uri(Uri)) then
  begin
    try
      if Assigned(Uri) then
        FUri := string(Uri);
    finally
      if Assigned(Uri) then
        CoTaskMemFree(Uri);
    end;
  end;
end;

constructor TEdgeNewWindowRequestedEventArgs.Create(AArgs: TNewWindowRequestedEventArgs);
begin
  Create(AArgs as ICoreWebView2NewWindowRequestedEventArgs);
end;

destructor TEdgeNewWindowRequestedEventArgs.Destroy;
begin
  if Assigned(FDeferral) and not FDeferralCompleted then
  begin
    try
      FDeferral.Complete;
      FDeferralCompleted := True;
    except

    end;
  end;

  try
    FNewWindow := nil;
    FArgs := nil;
  except

  end;

  FUri := EmptyStr;

  inherited;
end;

function TEdgeNewWindowRequestedEventArgs.GetDeferral: TEdgeDeferral;
var
  CoreDeferral: ICoreWebView2Deferral;
begin
  if not Assigned(FDeferral) and not FDeferralCompleted then
  begin
    if Assigned(FArgs) and Succeeded(FArgs.GetDeferral(CoreDeferral)) then
    begin
      FDeferral := TEdgeDeferral.Create(
        procedure
        begin
          try
            if Assigned(CoreDeferral) and not FDeferralCompleted then
            begin
              CoreDeferral.Complete;
              FDeferralCompleted := True;
            end;
          except

          end;
        end
      );
    end
    else
    begin
      FDeferral := TEdgeDeferral.Create(
        procedure
        begin
          FDeferralCompleted := True;
        end
      );
    end;
  end;
  Result := FDeferral;
end;

procedure TEdgeNewWindowRequestedEventArgs.CompleteDeferral;
begin
  if Assigned(FDeferral) and not FDeferralCompleted then
  begin
    try
      FDeferral.Complete;
      FDeferralCompleted := True;
    except

    end;
  end;
end;

function TEdgeNewWindowRequestedEventArgs.GetUri: string;
begin
  Result := FUri;
end;

function TEdgeNewWindowRequestedEventArgs.GetCoreArgs: ICoreWebView2NewWindowRequestedEventArgs;
begin
  Result := FArgs;
end;

function TEdgeNewWindowRequestedEventArgs.GetHandled: Boolean;
begin
  Result := FHandled;
end;

procedure TEdgeNewWindowRequestedEventArgs.SetHandled(AHandled: Boolean);
begin
  FHandled := AHandled;
  if Assigned(FArgs) then
  begin
    try
      if AHandled then
        FArgs.Set_Handled(1)
      else
        FArgs.Set_Handled(0);
    except

    end;
  end;
end;

procedure TEdgeNewWindowRequestedEventArgs.SetNewWindow(ANewWindow: ICoreWebView2);
begin
  try
    FNewWindow := ANewWindow;
    if Assigned(FArgs) and Assigned(ANewWindow) then
      FArgs.Set_NewWindow(ANewWindow);
  except

  end;
end;

function TEdgeNewWindowRequestedEventArgs.TryGetWindowFeatures: Boolean;
var
  WindowFeatures: IUnknown;
begin
  Result := False;
  if not Assigned(FArgs) then
    Exit;

  try
    Result := Succeeded(FArgs.QueryInterface(IID_ICoreWebView2WindowFeatures, WindowFeatures));
    WindowFeatures := nil;
  except
    Result := False;
  end;
end;

end.