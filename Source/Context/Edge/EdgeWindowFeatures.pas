unit EdgeWindowFeatures;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  WebView2;

type
  ICoreWebView2WindowFeatures = interface(IUnknown)
    ['{ddb5578f-65e1-4ae8-b155-8417cd73b844}']
    function Get_HasPosition(out value: Integer): HRESULT; stdcall;
    function Get_HasSize(out value: Integer): HRESULT; stdcall;
    function Get_Left(out value: Cardinal): HRESULT; stdcall;
    function Get_Top(out value: Cardinal): HRESULT; stdcall;
    function Get_Width(out value: Cardinal): HRESULT; stdcall;
    function Get_Height(out value: Cardinal): HRESULT; stdcall;
    function Get_ShouldDisplayMenuBar(out value: Integer): HRESULT; stdcall;
    function Get_ShouldDisplayStatus(out value: Integer): HRESULT; stdcall;
    function Get_ShouldDisplayToolbar(out value: Integer): HRESULT; stdcall;
    function Get_ShouldDisplayScrollBars(out value: Integer): HRESULT; stdcall;
  end;

  ICoreWebView2NewWindowRequestedEventArgs2 = interface(ICoreWebView2NewWindowRequestedEventArgs)
    ['{bbc7baed-74c6-4c92-b33e-7f69aba91de1}']
    function Get_WindowFeatures(out windowFeatures: ICoreWebView2WindowFeatures): HRESULT; stdcall;
  end;

  TEdgeWindowFeatures = class
  private
    FWindowFeatures: ICoreWebView2WindowFeatures;
    FHasPosition: Boolean;
    FHasSize: Boolean;
    FLeft: Cardinal;
    FTop: Cardinal;
    FWidth: Cardinal;
    FHeight: Cardinal;
    FShouldDisplayMenuBar: Boolean;
    FShouldDisplayStatus: Boolean;
    FShouldDisplayToolbar: Boolean;
    FShouldDisplayScrollBars: Boolean;
    FIsValid: Boolean;

    procedure LoadFeatures;
  public
    constructor Create(AWindowFeatures: ICoreWebView2WindowFeatures);
    constructor CreateDefault;
    destructor Destroy; override;

    function IsValid: Boolean;
    function HasPosition: Boolean;
    function HasSize: Boolean;
    function GetLeft: Cardinal;
    function GetTop: Cardinal;
    function GetWidth: Cardinal;
    function GetHeight: Cardinal;
    function ShouldDisplayMenuBar: Boolean;
    function ShouldDisplayStatus: Boolean;
    function ShouldDisplayToolbar: Boolean;
    function ShouldDisplayScrollBars: Boolean;

    // Novos métodos para verificar se há posição/tamanho e obter valores
    function Get_HasPosition(out HasPosition: Integer): HRESULT;
    function Get_HasSize(out HasSize: Integer): HRESULT;
    function Get_Left(out Left: Cardinal): HRESULT;
    function Get_Top(out Top: Cardinal): HRESULT;
    function Get_Width(out Width: Cardinal): HRESULT;
    function Get_Height(out Height: Cardinal): HRESULT;

    property Valid: Boolean read IsValid;
    property Position: Boolean read HasPosition;
    property Size: Boolean read HasSize;
    property Left: Cardinal read GetLeft;
    property Top: Cardinal read GetTop;
    property Width: Cardinal read GetWidth;
    property Height: Cardinal read GetHeight;
    property MenuBar: Boolean read ShouldDisplayMenuBar;
    property StatusBar: Boolean read ShouldDisplayStatus;
    property Toolbar: Boolean read ShouldDisplayToolbar;
    property ScrollBars: Boolean read ShouldDisplayScrollBars;
  end;

  TEdgeWindowFeaturesHelper = class
  public
    class function TryGetWindowFeatures(const AArgs: ICoreWebView2NewWindowRequestedEventArgs): TEdgeWindowFeatures;
    class function SupportsWindowFeatures(const AArgs: ICoreWebView2NewWindowRequestedEventArgs): Boolean;
  end;

implementation

{ TEdgeWindowFeatures }

constructor TEdgeWindowFeatures.Create(AWindowFeatures: ICoreWebView2WindowFeatures);
begin
  inherited Create;
  FWindowFeatures := AWindowFeatures;
  FIsValid := Assigned(FWindowFeatures);

  FHasPosition := False;
  FHasSize := False;
  FLeft := 0;
  FTop := 0;
  FWidth := 800;
  FHeight := 600;
  FShouldDisplayMenuBar := True;
  FShouldDisplayStatus := True;
  FShouldDisplayToolbar := True;
  FShouldDisplayScrollBars := True;

  if FIsValid then
    LoadFeatures;
end;

constructor TEdgeWindowFeatures.CreateDefault;
begin
  inherited Create;
  FWindowFeatures := nil;
  FIsValid := True;


  FHasPosition := False;
  FHasSize := True;
  FLeft := 0;
  FTop := 0;
  FWidth := 800;
  FHeight := 600;
  FShouldDisplayMenuBar := True;
  FShouldDisplayStatus := True;
  FShouldDisplayToolbar := True;
  FShouldDisplayScrollBars := True;
end;

destructor TEdgeWindowFeatures.Destroy;
begin
  FWindowFeatures := nil;
  inherited;
end;

procedure TEdgeWindowFeatures.LoadFeatures;
var
  Value: Integer;
  CardinalValue: Cardinal;
begin
  if not Assigned(FWindowFeatures) then
    Exit;

  try
    if Succeeded(FWindowFeatures.Get_HasPosition(Value)) then
    begin
      FHasPosition := (Value <> 0);

      if FHasPosition then
      begin
        if Succeeded(FWindowFeatures.Get_Left(CardinalValue)) then
          FLeft := CardinalValue;

        if Succeeded(FWindowFeatures.Get_Top(CardinalValue)) then
          FTop := CardinalValue;
      end;
    end;

    if Succeeded(FWindowFeatures.Get_HasSize(Value)) then
    begin
      FHasSize := (Value <> 0);

      if FHasSize then
      begin
        if Succeeded(FWindowFeatures.Get_Width(CardinalValue)) then
          FWidth := CardinalValue;

        if Succeeded(FWindowFeatures.Get_Height(CardinalValue)) then
          FHeight := CardinalValue;
      end;
    end;

    if Succeeded(FWindowFeatures.Get_ShouldDisplayMenuBar(Value)) then
      FShouldDisplayMenuBar := (Value <> 0);

    if Succeeded(FWindowFeatures.Get_ShouldDisplayStatus(Value)) then
      FShouldDisplayStatus := (Value <> 0);

    if Succeeded(FWindowFeatures.Get_ShouldDisplayToolbar(Value)) then
      FShouldDisplayToolbar := (Value <> 0);

    if Succeeded(FWindowFeatures.Get_ShouldDisplayScrollBars(Value)) then
      FShouldDisplayScrollBars := (Value <> 0);

  except
    on E: Exception do
    begin
      FIsValid := False;
    end;
  end;
end;

function TEdgeWindowFeatures.IsValid: Boolean;
begin
  Result := FIsValid;
end;

function TEdgeWindowFeatures.HasPosition: Boolean;
begin
  Result := FHasPosition;
end;

function TEdgeWindowFeatures.HasSize: Boolean;
begin
  Result := FHasSize;
end;

function TEdgeWindowFeatures.GetLeft: Cardinal;
begin
  Result := FLeft;
end;

function TEdgeWindowFeatures.GetTop: Cardinal;
begin
  Result := FTop;
end;

function TEdgeWindowFeatures.GetWidth: Cardinal;
begin
  Result := FWidth;
end;

function TEdgeWindowFeatures.GetHeight: Cardinal;
begin
  Result := FHeight;
end;

function TEdgeWindowFeatures.ShouldDisplayMenuBar: Boolean;
begin
  Result := FShouldDisplayMenuBar;
end;

function TEdgeWindowFeatures.ShouldDisplayStatus: Boolean;
begin
  Result := FShouldDisplayStatus;
end;

function TEdgeWindowFeatures.ShouldDisplayToolbar: Boolean;
begin
  Result := FShouldDisplayToolbar;
end;

function TEdgeWindowFeatures.ShouldDisplayScrollBars: Boolean;
begin
  Result := FShouldDisplayScrollBars;
end;

function TEdgeWindowFeatures.Get_HasPosition(out HasPosition: Integer): HRESULT;
begin
  try
    if Assigned(FWindowFeatures) then
    begin
      Result := FWindowFeatures.Get_HasPosition(HasPosition);
    end
    else
    begin
      HasPosition := Integer(FHasPosition);
      Result := S_OK;
    end;
  except
    HasPosition := 0;
    Result := E_FAIL;
  end;
end;

function TEdgeWindowFeatures.Get_HasSize(out HasSize: Integer): HRESULT;
begin
  try
    if Assigned(FWindowFeatures) then
    begin
      Result := FWindowFeatures.Get_HasSize(HasSize);
    end
    else
    begin
      HasSize := Integer(FHasSize);
      Result := S_OK;
    end;
  except
    HasSize := 0;
    Result := E_FAIL;
  end;
end;

function TEdgeWindowFeatures.Get_Left(out Left: Cardinal): HRESULT;
begin
  try
    if Assigned(FWindowFeatures) then
    begin
      Result := FWindowFeatures.Get_Left(Left);
    end
    else
    begin
      Left := FLeft;
      Result := S_OK;
    end;
  except
    Left := 0;
    Result := E_FAIL;
  end;
end;

function TEdgeWindowFeatures.Get_Top(out Top: Cardinal): HRESULT;
begin
  try
    if Assigned(FWindowFeatures) then
    begin
      Result := FWindowFeatures.Get_Top(Top);
    end
    else
    begin
      Top := FTop;
      Result := S_OK;
    end;
  except
    Top := 0;
    Result := E_FAIL;
  end;
end;

function TEdgeWindowFeatures.Get_Width(out Width: Cardinal): HRESULT;
begin
  try
    if Assigned(FWindowFeatures) then
    begin
      Result := FWindowFeatures.Get_Width(Width);
    end
    else
    begin
      Width := FWidth;
      Result := S_OK;
    end;
  except
    Width := 800;
    Result := E_FAIL;
  end;
end;

function TEdgeWindowFeatures.Get_Height(out Height: Cardinal): HRESULT;
begin
  try
    if Assigned(FWindowFeatures) then
    begin
      Result := FWindowFeatures.Get_Height(Height);
    end
    else
    begin
      Height := FHeight;
      Result := S_OK;
    end;
  except
    Height := 600;
    Result := E_FAIL;
  end;
end;

{ TEdgeWindowFeaturesHelper }

class function TEdgeWindowFeaturesHelper.TryGetWindowFeatures(const AArgs: ICoreWebView2NewWindowRequestedEventArgs): TEdgeWindowFeatures;
var
  Args2: ICoreWebView2NewWindowRequestedEventArgs2;
  WindowFeatures: ICoreWebView2WindowFeatures;
  HResults: HRESULT;
begin
  if not Assigned(AArgs) then
  begin
    Result := TEdgeWindowFeatures.CreateDefault;
    Exit;
  end;

  try
    HResults := AArgs.QueryInterface(ICoreWebView2NewWindowRequestedEventArgs2, Args2);

    if Succeeded(HResults) and Assigned(Args2) then
    begin
      HResults := Args2.Get_WindowFeatures(WindowFeatures);

      if Succeeded(HResults) and Assigned(WindowFeatures) then
      begin
        Result := TEdgeWindowFeatures.Create(WindowFeatures);
      end
      else
      begin
        Result := TEdgeWindowFeatures.CreateDefault;
      end;
    end
    else
    begin
      Result := TEdgeWindowFeatures.CreateDefault;
    end;

  except
    on E: Exception do
    begin
      try
        Result := TEdgeWindowFeatures.CreateDefault;
      except
        Result := nil;
      end;
    end;
  end;
end;

class function TEdgeWindowFeaturesHelper.SupportsWindowFeatures(const AArgs: ICoreWebView2NewWindowRequestedEventArgs): Boolean;
var
  Args2: ICoreWebView2NewWindowRequestedEventArgs2;
begin
  Result := False;

  if not Assigned(AArgs) then
    Exit;

  try
    Result := Succeeded(AArgs.QueryInterface(ICoreWebView2NewWindowRequestedEventArgs2, Args2));
  except
    Result := False;
  end;
end;

end.
