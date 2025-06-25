unit BrowserFactory;

interface

uses
  Vcl.Forms,
  System.Classes,
  System.SysUtils,

  uWVBrowser,
  Vcl.Edge,

  BrowserTypes,
  IBrowserFormBase,
  IWebViewBrowserForm,
  IEdgeWebBrowserForm;

type
  IBrowserFormFactory = interface
  ['{C1D2E3F4-A5B6-7890-CDEF-123456789ABC}']
    function CreateBrowser(const AURL: String = ''): IBrowserForm;
    function CreatePopup(AParentBrowser: TComponent; const AURL: String = ''): IBrowserForm;
    function CreateMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = false): IBrowserForm;
    function GetBrowserType: TBrowserType;
    function GetBrowserTypeName: String;
  end;

  TWVBrowserFormFactory = class(TInterfacedObject, IBrowserFormFactory)
  public
    function CreateBrowser(const AURL: String = ''): IBrowserForm;
    function CreatePopup(AParentBrowser: TComponent; const AURL: String = ''): IBrowserForm;
    function CreateMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = false): IBrowserForm;
    function GetBrowserType: TBrowserType;
    function GetBrowserTypeName: String;
  end;

  TEdgeBrowserFormFactory = class(TInterfacedObject, IBrowserFormFactory)
  public
    function CreateBrowser(const AURL: String = ''): IBrowserForm;
    function CreatePopup(AParentBrowser: TComponent; const AURL: String = ''): IBrowserForm;
    function CreateMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = false): IBrowserForm;
    function GetBrowserType: TBrowserType;
    function GetBrowserTypeName: String;
  end;

  TBrowserStrategy = class
  private
    class var FCurrentFactory: IBrowserFormFactory;
    class var FDefaultBrowserType: TBrowserType;
  public
    class procedure SetBrowserType(ABrowserType: TBrowserType);
    class function GetCurrentFactory: IBrowserFormFactory;
    class function CreateBrowser(const AURL: String = ''): IBrowserForm;
    class function CreatePopup(AParentBrowser: TComponent; const AURL: String = ''): IBrowserForm;
    class function CreateMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = false): IBrowserForm;
    class function GetCurrentBrowserType: TBrowserType;
    class function GetCurrentBrowserTypeName: String;
    class constructor Create;
    class destructor Destroy;
  end;

implementation

uses
  WebViewBrowserForm,
  EdgeWebBrowserForm;

{ TWVBrowserFormFactory }

function TWVBrowserFormFactory.CreateBrowser(const AURL: String): IBrowserForm;
begin
  Result := TWebViewBrowser.Create(AURL) as IBrowserForm;
end;

function TWVBrowserFormFactory.CreatePopup(AParentBrowser: TComponent; const AURL: String): IBrowserForm;
begin
  if not (AParentBrowser is TWVBrowser) then
    raise Exception.Create('Parent browser must be TWVBrowser for WebView2 popup');
  Result := TWebViewBrowser.CreateAsPopup(TWVBrowser(AParentBrowser), AURL) as IBrowserForm;
end;

function TWVBrowserFormFactory.CreateMDI(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean): IBrowserForm;
begin
  Result := TWebViewBrowser.CreateAsMDI(AParentForm, AURL, ALegacyForm) as IBrowserForm;
end;

function TWVBrowserFormFactory.GetBrowserType: TBrowserType;
begin
  Result := WebView2;
end;

function TWVBrowserFormFactory.GetBrowserTypeName: String;
begin
  Result := 'WebView2';
end;

{ TEdgeBrowserFormFactory }

function TEdgeBrowserFormFactory.CreateBrowser(const AURL: String): IBrowserForm;
begin
  Result := TEdgeWebBrowser.Create(AURL) as IBrowserForm;
end;

function TEdgeBrowserFormFactory.CreatePopup(AParentBrowser: TComponent; const AURL: String): IBrowserForm;
begin
  if not (AParentBrowser is TEdgeBrowser) then
    raise Exception.Create('Parent browser must be TEdgeBrowser for Edge popup');
  Result := TEdgeWebBrowser.CreateAsPopup(TEdgeBrowser(AParentBrowser), AURL) as IBrowserForm;
end;

function TEdgeBrowserFormFactory.CreateMDI(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean): IBrowserForm;
begin
  Result := TEdgeWebBrowser.CreateAsMDI(AParentForm, AURL, ALegacyForm) as IBrowserForm;
end;

function TEdgeBrowserFormFactory.GetBrowserType: TBrowserType;
begin
  Result := EdgeBrowser;
end;

function TEdgeBrowserFormFactory.GetBrowserTypeName: String;
begin
  Result := 'Edge';
end;

{ TBrowserStrategy }

class constructor TBrowserStrategy.Create;
begin
  FDefaultBrowserType := WebView2;
  SetBrowserType(FDefaultBrowserType);
end;

class destructor TBrowserStrategy.Destroy;
begin
  FCurrentFactory := nil;
end;

class procedure TBrowserStrategy.SetBrowserType(ABrowserType: TBrowserType);
begin
  FDefaultBrowserType := ABrowserType;
  case ABrowserType of
    WebView2: FCurrentFactory := TWVBrowserFormFactory.Create;
    EdgeBrowser: FCurrentFactory := TEdgeBrowserFormFactory.Create;
  end;
end;

class function TBrowserStrategy.GetCurrentFactory: IBrowserFormFactory;
begin
  if not Assigned(FCurrentFactory) then
    SetBrowserType(FDefaultBrowserType);
  Result := FCurrentFactory;
end;

class function TBrowserStrategy.CreateBrowser(const AURL: String): IBrowserForm;
begin
  Result := GetCurrentFactory.CreateBrowser(AURL);
end;

class function TBrowserStrategy.CreatePopup(AParentBrowser: TComponent; const AURL: String): IBrowserForm;
begin
  Result := GetCurrentFactory.CreatePopup(AParentBrowser, AURL);
end;

class function TBrowserStrategy.CreateMDI(AParentForm: TForm; const AURL: String; ALegacyForm: Boolean): IBrowserForm;
begin
  Result := GetCurrentFactory.CreateMDI(AParentForm, AURL, ALegacyForm);
end;

class function TBrowserStrategy.GetCurrentBrowserType: TBrowserType;
begin
  Result := GetCurrentFactory.GetBrowserType;
end;

class function TBrowserStrategy.GetCurrentBrowserTypeName: String;
begin
  Result := GetCurrentFactory.GetBrowserTypeName;
end;

end.
