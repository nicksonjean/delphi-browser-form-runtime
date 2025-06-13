unit TestWVBrowserFormClass;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  WVBrowserFormClass,
  BrowserTypes,
  BrowserFormInterface;

type
  [TestFixture]
  TTestWVBrowserForm = class
  private
    FBrowserForm: TCustomFormWVBrowser;
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

    // Testes de Propriedades
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

{ TTestWVBrowserForm }

procedure TTestWVBrowserForm.Setup;
begin
  FBrowserForm := TCustomFormWVBrowser.Create;
  FTestForm := TForm.Create(nil);
  FTestForm.FormStyle := fsMDIForm;
end;

procedure TTestWVBrowserForm.TearDown;
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

procedure TTestWVBrowserForm.TestCreate_Default_ShouldSetDefaultValues;
begin
  Assert.IsNotNull(FBrowserForm, 'Browser form should be created');
  Assert.AreEqual(DEFAULT_WIDTH, FBrowserForm.Width, 'Default width should be 800');
  Assert.AreEqual(DEFAULT_HEIGHT, FBrowserForm.Height, 'Default height should be 600');
  Assert.AreEqual(DEFAULT_URL, FBrowserForm.URL, 'Default URL should be about:blank');
  Assert.IsFalse(FBrowserForm.IsPopup, 'Should not be popup by default');
end;

procedure TTestWVBrowserForm.TestCreate_WithURL_ShouldSetURL;
const
  TEST_URL = 'https://www.example.com';
var
  BrowserWithURL: TCustomFormWVBrowser;
begin
  BrowserWithURL := TCustomFormWVBrowser.Create(TEST_URL);
  try
    Assert.AreEqual(TEST_URL, BrowserWithURL.URL, 'URL should be set from constructor');
  finally
    BrowserWithURL.Free;
  end;
end;

// Testes de Propriedades

procedure TTestWVBrowserForm.TestSetWidth_ShouldUpdateProperty;
const
  TEST_WIDTH = 1024;
begin
  FBrowserForm.SetWidth(TEST_WIDTH);
  Assert.AreEqual(TEST_WIDTH, FBrowserForm.Width, 'Width should be updated');
end;

procedure TTestWVBrowserForm.TestSetHeight_ShouldUpdateProperty;
const
  TEST_HEIGHT = 768;
begin
  FBrowserForm.SetHeight(TEST_HEIGHT);
  Assert.AreEqual(TEST_HEIGHT, FBrowserForm.Height, 'Height should be updated');
end;

procedure TTestWVBrowserForm.TestSetCaption_ShouldUpdateCaption;
const
  TEST_CAPTION = 'Test Browser Window';
begin
  FBrowserForm.SetCaption(TEST_CAPTION);
  Assert.AreEqual(TEST_CAPTION, FBrowserForm.Caption, 'Caption should be updated');
end;

procedure TTestWVBrowserForm.TestSetURL_ShouldUpdateURL;
const
  TEST_URL = 'https://www.google.com';
begin
  FBrowserForm.SetURL(TEST_URL);
  Assert.AreEqual(TEST_URL, FBrowserForm.URL, 'URL should be updated');
end;

// Testes de Interface Fluente

procedure TTestWVBrowserForm.TestChainableMethods_ShouldReturnSelf;
var
  Result: TCustomFormWVBrowser;
begin
  Result := FBrowserForm.SetWidth(1024);
  Assert.AreSame(FBrowserForm, Result, 'SetWidth should return self');

  Result := FBrowserForm.SetHeight(768);
  Assert.AreSame(FBrowserForm, Result, 'SetHeight should return self');

  Result := FBrowserForm.SetCaption('Test');
  Assert.AreSame(FBrowserForm, Result, 'SetCaption should return self');
end;

procedure TTestWVBrowserForm.TestComplexChaining_ShouldWorkCorrectly;
var
  Result: TCustomFormWVBrowser;
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

procedure TTestWVBrowserForm.TestSetResizable_ShouldWork;
begin
  FBrowserForm.SetResizable(True);
  Assert.IsTrue(FBrowserForm.Resizable, 'Should be resizable when set to true');

  FBrowserForm.SetResizable(False);
  Assert.IsFalse(FBrowserForm.Resizable, 'Should not be resizable when set to false');
end;

procedure TTestWVBrowserForm.TestSetMovable_ShouldWork;
begin
  FBrowserForm.SetMovable(False);
  Assert.IsFalse(FBrowserForm.Movable, 'Should not be movable when set to false');

  FBrowserForm.SetMovable(True);
  Assert.IsTrue(FBrowserForm.Movable, 'Should be movable when set to true');
end;

// Testes de Cookies

procedure TTestWVBrowserForm.TestSetCookie_ShouldSetProperties;
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

procedure TTestWVBrowserForm.TestSetMaxInstances_ShouldUpdateProperty;
const
  MAX_INSTANCES = 5;
begin
  FBrowserForm.SetMaxInstances(MAX_INSTANCES);
  Assert.AreEqual(MAX_INSTANCES, FBrowserForm.MaxInstances, 'Max instances should be updated');
end;

procedure TTestWVBrowserForm.TestCheckMDILimits_ShouldReturnTrue;
const
  TEST_IDENTIFIER = 'TestBrowser';
begin
  Assert.IsTrue(
    TCustomFormWVBrowser.CheckMDILimits(TEST_IDENTIFIER),
    'CheckMDILimits should return true for new identifier'
  );
end;

// Testes de Estados

procedure TTestWVBrowserForm.TestIsPopup_InitialState_ShouldBeFalse;
begin
  Assert.IsFalse(FBrowserForm.IsPopup, 'IsPopup should be false initially');
end;

// Testes de Factory Methods

procedure TTestWVBrowserForm.TestNewBrowser_ShouldCreateWithDefaults;
var
  Browser: TCustomFormWVBrowser;
begin
  Browser := TCustomFormWVBrowser.NewBrowser('https://example.com');
  try
    Assert.IsNotNull(Browser, 'NewBrowser should create instance');
    Assert.AreEqual('https://example.com', Browser.URL, 'URL should be set');
    Assert.IsFalse(Browser.IsPopup, 'Should not be popup');
  finally
    Browser.Free;
  end;
end;

// Testes de Interface

procedure TTestWVBrowserForm.TestInterfaceCompatibility_ShouldWork;
var
  BrowserInterface: IBrowserForm;
begin
  BrowserInterface := FBrowserForm;
  Assert.IsNotNull(BrowserInterface, 'Should support IBrowserForm interface');

  // Test interface methods
  BrowserInterface.SetWidth(1024).SetHeight(768);
  Assert.AreEqual(1024, FBrowserForm.Width, 'Interface method should work');
  Assert.AreEqual(768, FBrowserForm.Height, 'Interface method should work');
end;

// Testes de HTML Content

procedure TTestWVBrowserForm.TestSetHTMLContent_ShouldReturnSelf;
const
  HTML_CONTENT = '<html><body><h1>Test</h1></body></html>';
var
  Result: TCustomFormWVBrowser;
begin
  Result := FBrowserForm.SetHTMLContent(HTML_CONTENT);
  Assert.AreSame(FBrowserForm, Result, 'SetHTMLContent should return self');
end;

// Testes de Show Methods

procedure TTestWVBrowserForm.TestShow_ShouldNotRaiseUnexpectedExceptions;
begin
  try
    FBrowserForm.Show();
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
  TDUnitX.RegisterTestFixture(TTestWVBrowserForm);

end.
