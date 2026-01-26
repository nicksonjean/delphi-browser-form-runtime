unit TestUnitBrowserForm;

interface

uses
  DUnitX.TestFramework,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.StrUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.WinXCtrls,

  Vcl.Edge,
  uWVBrowser,
  IBrowserFormBase,

  UtilsLib,
  BrowserTypes,
  IEdgeWebBrowserForm,
  IWebViewBrowserForm,

  EdgeWebBrowserForm,
  EdgeWebAdvancedPopupExample,
  WebViewBrowserForm,
  WebViewAdvancedPopupExample
  ;

const
  DEFAULT_URL = 'about:blank';
  DEFAULT_WIDTH = 800;
  DEFAULT_HEIGHT = 600;

type
  [TestFixture]
  TTestWebViewBrowser = class
  private
    FBrowserForm: TWebViewBrowser;
    FTestForm: TForm;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // Testes Básicos de Construção
    [Test]
    [Category('Constructor')]
    procedure TestCreate_Default_ShouldSetDefaultValues;

    [Test]
    [Category('Constructor')]
    procedure TestCreate_WithURL_ShouldSetURL;

    // Testes de Propriedades Básicas
    [Test]
    [Category('Properties')]
    procedure TestSetWidth_ShouldUpdateProperty;

    [Test]
    [Category('Properties')]
    procedure TestSetHeight_ShouldUpdateProperty;

    [Test]
    [Category('Properties')]
    procedure TestSetCaption_ShouldUpdateCaption;

    [Test]
    [Category('Properties')]
    procedure TestSetURL_ShouldUpdateURL;

    // Testes de Interface Fluente
    [Test]
    [Category('FluentInterface')]
    procedure TestChainableMethods_ShouldReturnSelf;

    [Test]
    [Category('FluentInterface')]
    procedure TestComplexChaining_ShouldWorkCorrectly;

    // Testes de Configuração
    [Test]
    [Category('Configuration')]
    procedure TestSetResizable_ShouldWork;

    [Test]
    [Category('Configuration')]
    procedure TestSetMovable_ShouldWork;

    // Testes de Cookies
    [Test]
    [Category('Cookies')]
    procedure TestSetCookie_ShouldSetProperties;

    // Testes de MDI
    [Test]
    [Category('MDI')]
    procedure TestSetMaxInstances_ShouldUpdateProperty;

    [Test]
    [Category('MDI')]
    procedure TestCheckMDILimits_ShouldReturnTrue;

    // Testes de Estados
    [Test]
    [Category('State')]
    procedure TestIsPopup_InitialState_ShouldBeFalse;

    // Testes de Factory Methods
    [Test]
    [Category('Factory')]
    procedure TestNewBrowser_ShouldCreateWithDefaults;

    // Testes de Interface
    [Test]
    [Category('Interface')]
    procedure TestInterfaceCompatibility_ShouldWork;

    // Testes de HTML Content
    [Test]
    [Category('Content')]
    procedure TestSetHTMLContent_ShouldReturnSelf;

    // Testes de Show Methods (simplificados)
    [Test]
    [Category('ShowMethods')]
    procedure TestShow_ShouldNotRaiseUnexpectedExceptions;
  end;

implementation

{ TTestUnitBrowserForm }

procedure TTestWebViewBrowser.Setup;
begin
  FBrowserForm := TWebViewBrowser.Create;
  FTestForm := TForm.Create(nil);
  FTestForm.FormStyle := fsMDIForm;
end;

procedure TTestWebViewBrowser.TearDown;
begin
  if Assigned(FBrowserForm) then
  begin
    FBrowserForm.Free;
    FBrowserForm := nil;
  end;

  if Assigned(FTestForm) then
  begin
    FTestForm.Free;
    FTestForm := nil;
  end;
end;

// Testes de Construção

procedure TTestWebViewBrowser.TestCreate_Default_ShouldSetDefaultValues;
begin
  Assert.IsNotNull(FBrowserForm, 'Browser form should be created');
  Assert.AreEqual(DEFAULT_WIDTH, FBrowserForm.Width, 'Default width should be 800');
  Assert.AreEqual(DEFAULT_HEIGHT, FBrowserForm.Height, 'Default height should be 600');
  Assert.AreEqual(DEFAULT_URL, FBrowserForm.URL, 'Default URL should be about:blank');
  Assert.IsFalse(FBrowserForm.IsPopup, 'Should not be popup by default');
end;

procedure TTestWebViewBrowser.TestCreate_WithURL_ShouldSetURL;
const
  TEST_URL = 'https://www.example.com';
var
  BrowserWithURL: TWebViewBrowser;
begin
  BrowserWithURL := nil;
  try
    BrowserWithURL := TWebViewBrowser.Create(TEST_URL);
    Assert.AreEqual(TEST_URL, BrowserWithURL.URL, 'URL should be set from constructor');
  finally
    if Assigned(BrowserWithURL) then
      BrowserWithURL.Free;
  end;
end;

// Testes de Propriedades

procedure TTestWebViewBrowser.TestSetWidth_ShouldUpdateProperty;
const
  TEST_WIDTH = 1024;
begin
  FBrowserForm.SetWidth(TEST_WIDTH);
  Assert.AreEqual(TEST_WIDTH, FBrowserForm.Width, 'Width should be updated');
end;

procedure TTestWebViewBrowser.TestSetHeight_ShouldUpdateProperty;
const
  TEST_HEIGHT = 768;
begin
  FBrowserForm.SetHeight(TEST_HEIGHT);
  Assert.AreEqual(TEST_HEIGHT, FBrowserForm.Height, 'Height should be updated');
end;

procedure TTestWebViewBrowser.TestSetCaption_ShouldUpdateCaption;
const
  TEST_CAPTION = 'Test Browser Window';
begin
  FBrowserForm.SetCaption(TEST_CAPTION);
  Assert.AreEqual(TEST_CAPTION, FBrowserForm.Caption, 'Caption should be updated');
end;

procedure TTestWebViewBrowser.TestSetURL_ShouldUpdateURL;
const
  TEST_URL = 'https://www.google.com';
begin
  FBrowserForm.SetURL(TEST_URL);
  Assert.AreEqual(TEST_URL, FBrowserForm.URL, 'URL should be updated');
end;

// Testes de Interface Fluente

procedure TTestWebViewBrowser.TestChainableMethods_ShouldReturnSelf;
var
  Result: TWebViewBrowser;
begin
  Result := FBrowserForm.SetWidth(1024);
  Assert.AreSame(FBrowserForm, Result, 'SetWidth should return self');

  Result := FBrowserForm.SetHeight(768);
  Assert.AreSame(FBrowserForm, Result, 'SetHeight should return self');

  Result := FBrowserForm.SetCaption('Test');
  Assert.AreSame(FBrowserForm, Result, 'SetCaption should return self');
end;

procedure TTestWebViewBrowser.TestComplexChaining_ShouldWorkCorrectly;
var
  Result: TWebViewBrowser;
const
  TEST_WIDTH = 1920;
  TEST_HEIGHT = 1080;
  TEST_CAPTION = 'Chained Browser';
begin
  Result := FBrowserForm
    .SetWidth(TEST_WIDTH)
    .SetHeight(TEST_HEIGHT)
    .SetCaption(TEST_CAPTION)
    .SetResizable(True)
    .SetMovable(False);

  Assert.AreSame(FBrowserForm, Result, 'Complex chaining should return self');
  Assert.AreEqual(TEST_WIDTH, FBrowserForm.Width, 'Width should be set correctly');
  Assert.AreEqual(TEST_HEIGHT, FBrowserForm.Height, 'Height should be set correctly');
  Assert.AreEqual(TEST_CAPTION, FBrowserForm.Caption, 'Caption should be set correctly');
end;

// Testes de Configuração

procedure TTestWebViewBrowser.TestSetResizable_ShouldWork;
begin
  FBrowserForm.SetResizable(True);
  Assert.IsTrue(FBrowserForm.Resizable, 'Should be resizable when set to true');

  FBrowserForm.SetResizable(False);
  Assert.IsFalse(FBrowserForm.Resizable, 'Should not be resizable when set to false');
end;

procedure TTestWebViewBrowser.TestSetMovable_ShouldWork;
begin
  FBrowserForm.SetMovable(False);
  Assert.IsFalse(FBrowserForm.Movable, 'Should not be movable when set to false');

  FBrowserForm.SetMovable(True);
  Assert.IsTrue(FBrowserForm.Movable, 'Should be movable when set to true');
end;

// Testes de Cookies

procedure TTestWebViewBrowser.TestSetCookie_ShouldSetProperties;
const
  COOKIE_NAME = 'TestCookie';
  COOKIE_VALUE = 'TestValue';
  COOKIE_DOMAIN = 'example.com';
  COOKIE_PATH = '/test';
begin
  FBrowserForm.SetCookie(COOKIE_NAME, COOKIE_VALUE, COOKIE_DOMAIN, COOKIE_PATH);

  Assert.AreEqual(COOKIE_NAME, FBrowserForm.CookieName, 'Cookie name should be set');
  Assert.AreEqual(COOKIE_VALUE, FBrowserForm.CookieValue, 'Cookie value should be set');
  Assert.AreEqual(COOKIE_DOMAIN, FBrowserForm.CookieDomain, 'Cookie domain should be set');
  Assert.AreEqual(COOKIE_PATH, FBrowserForm.CookiePath, 'Cookie path should be set');
end;

// Testes MDI

procedure TTestWebViewBrowser.TestSetMaxInstances_ShouldUpdateProperty;
const
  MAX_INSTANCES = 5;
begin
  FBrowserForm.SetMaxInstances(MAX_INSTANCES);
  Assert.AreEqual(MAX_INSTANCES, FBrowserForm.MaxInstances, 'Max instances should be updated');
end;

procedure TTestWebViewBrowser.TestCheckMDILimits_ShouldReturnTrue;
const
  TEST_IDENTIFIER = 'TestBrowser';
begin
  Assert.IsTrue(
    TWebViewBrowser.CheckMDILimits(TEST_IDENTIFIER, 1, True),
    'CheckMDILimits should return true for new identifier'
  );
end;

// Testes de Estados

procedure TTestWebViewBrowser.TestIsPopup_InitialState_ShouldBeFalse;
begin
  Assert.IsFalse(FBrowserForm.IsPopup, 'IsPopup should be false initially');
end;

// Testes de Factory Methods

procedure TTestWebViewBrowser.TestNewBrowser_ShouldCreateWithDefaults;
var
  Browser: TWebViewBrowser;
begin
  Browser := nil;
  try
    Browser := TWebViewBrowser.NewBrowser('https://example.com');
    Assert.IsNotNull(Browser, 'NewBrowser should create instance');
    Assert.AreEqual('https://example.com', Browser.URL, 'URL should be set');
    Assert.IsFalse(Browser.IsPopup, 'Should not be popup');
  finally
    if Assigned(Browser) then
      Browser.Free;
  end;
end;

// Testes de Interface

procedure TTestWebViewBrowser.TestInterfaceCompatibility_ShouldWork;
var
  BrowserInterface: IBrowserForm;
begin
  BrowserInterface := FBrowserForm;
  Assert.IsNotNull(BrowserInterface, 'Should support IBrowserForm interface');

  // Test interface properties
  BrowserInterface.Width := 1024;
  BrowserInterface.Height := 768;
  Assert.AreEqual(1024, FBrowserForm.Width, 'Interface property should work');
  Assert.AreEqual(768, FBrowserForm.Height, 'Interface property should work');
end;

// Testes de HTML Content

procedure TTestWebViewBrowser.TestSetHTMLContent_ShouldReturnSelf;
const
  HTML_CONTENT = '<html><body><h1>Test</h1></body></html>';
var
  Result: TWebViewBrowser;
begin
  Result := FBrowserForm.SetHTMLContent(HTML_CONTENT);
  Assert.AreSame(FBrowserForm, Result, 'SetHTMLContent should return self');
end;

// Testes de Show Methods

procedure TTestWebViewBrowser.TestShow_ShouldNotRaiseUnexpectedExceptions;
begin
  try
    FBrowserForm.Show(TOpenType.Default);
    Assert.Pass('Show executed without unexpected exceptions');
  except
    on E: Exception do
    begin
      // Allow WebView2 related exceptions in test environment
      if Pos('WebView2', E.Message) > 0 then
        Assert.Pass('Show failed with expected WebView2 exception')
      else
        Assert.Fail('Show raised unexpected exception: ' + E.Message);
    end;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestWebViewBrowser);

end.
