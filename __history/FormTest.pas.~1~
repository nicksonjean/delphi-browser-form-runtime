unit FormTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  BrowserFormTypes,
  BrowserFormInterface,
  WebBrowserFormClass,
  WVBrowserFormClass,
  BrowserStrategyInterface,
  BrowserStrategyClass
  ;

type
  TFormBrowserTest = class(TForm)
    GroupBoxWebBrowser: TGroupBox;
    GroupBoxWVBrowser: TGroupBox;
    GroupBoxWebBrowserWithClass: TGroupBox;
    BtnWebBrowserClassChainableTest: TButton;
    BtnWebBrowserClassPropertiesTest: TButton;
    GroupBoxWebBrowserWithInterface: TGroupBox;
    BtnWebBrowserInterfaceChainableTest: TButton;
    BtnWebBrowserInterfacePropertiesTest: TButton;
    GroupBoxWVBrowserWithClass: TGroupBox;
    BtnWVBrowserClassChainableTest: TButton;
    BtnWVBrowserClassPropertiesTest: TButton;
    GroupBoxWVBrowserWithInterface: TGroupBox;
    BtnWVBrowserInterfaceChainableTest: TButton;
    BtnWVBrowserInterfacePropertiesTest: TButton;
    GroupBoxStrategy: TGroupBox;
    GroupBoxStrategyWithClass: TGroupBox;
    GroupBoxStrategyWithInterface: TGroupBox;
    BtnBrowserClassChainableTest: TButton;
    BtnBrowserClassPropertiesTest: TButton;
    BtnBrowserInterfaceChainableTest: TButton;
    BtnBrowserInterfacePropertiesTest: TButton;
    procedure BtnWebBrowserClassChainableTestClick(Sender: TObject);
    procedure BtnWVBrowserInterfaceChainableTestClick(Sender: TObject);
    procedure BtnWVBrowserClassPropertiesTestClick(Sender: TObject);
    procedure BtnWebBrowserClassPropertiesTestClick(Sender: TObject);
    procedure BtnWebBrowserInterfaceChainableTestClick(Sender: TObject);
    procedure BtnWebBrowserInterfacePropertiesTestClick(Sender: TObject);
    procedure BtnWVBrowserClassChainableTestClick(Sender: TObject);
    procedure BtnWVBrowserInterfacePropertiesTestClick(Sender: TObject);
    procedure BtnBrowserClassChainableTestClick(Sender: TObject);
    procedure BtnBrowserClassPropertiesTestClick(Sender: TObject);
    procedure BtnBrowserInterfaceChainableTestClick(Sender: TObject);
    procedure BtnBrowserInterfacePropertiesTestClick(Sender: TObject);
  protected
    { Protected declarations }
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormBrowserTest: TFormBrowserTest;

implementation

{$R *.dfm}

procedure TFormBrowserTest.BtnBrowserClassChainableTestClick(Sender: TObject);
var
  BrowserForm: TBrowser;
begin
  BrowserForm := TBrowser.Create(WebBrowser, 'https://google.com.br/')
    .SetCaption('Exemplo')
    .SetWidth(2048)
    .SetHeight(1024)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true);
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnBrowserClassPropertiesTestClick(Sender: TObject);
var
  BrowserForm: TBrowser;
begin
  BrowserForm := TBrowser.Create(WebView2, 'file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
  BrowserForm.Caption := 'Exemplo';
  BrowserForm.Width := 2048;
  BrowserForm.Height := 1024;
  BrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnBrowserInterfaceChainableTestClick(Sender: TObject);
var
  BrowserForm: IBrowser;
begin
  BrowserForm := TBrowser.Create(WebBrowser, 'https://google.com.br/')
    .SetCaption('Exemplo')
    .SetWidth(2048)
    .SetHeight(1024)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true);
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnBrowserInterfacePropertiesTestClick(Sender: TObject);
var
  BrowserForm: IBrowser;
begin
  BrowserForm := TBrowser.Create(WebView2, 'file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
  BrowserForm.Caption := 'Exemplo';
  BrowserForm.Width := 2048;
  BrowserForm.Height := 1024;
  BrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWebBrowserClassChainableTestClick(Sender: TObject);
var
  BrowserForm: TCustomFormWebBrowser;
begin
  BrowserForm := TCustomFormWebBrowser.Create('https://google.com.br/')
    .SetCaption('Exemplo')
    .SetWidth(2048)
    .SetHeight(1024)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true);
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWebBrowserClassPropertiesTestClick(Sender: TObject);
var
  BrowserForm: TCustomFormWebBrowser;
begin
  BrowserForm := TCustomFormWebBrowser.Create('https://google.com.br/');
  BrowserForm.Caption := 'Exemplo';
  BrowserForm.Width := 2048;
  BrowserForm.Height := 1024;
  BrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWebBrowserInterfaceChainableTestClick(Sender: TObject);
var
  BrowserForm: IBrowserForm;
begin
  BrowserForm := TCustomFormWebBrowser.Create('https://google.com.br/')
    .SetCaption('Exemplo')
    .SetWidth(2048)
    .SetHeight(1024)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true);
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWebBrowserInterfacePropertiesTestClick(Sender: TObject);
var
  BrowserForm: IBrowserForm;
begin
  BrowserForm := TCustomFormWebBrowser.Create('https://google.com.br/');
  BrowserForm.Caption := 'Exemplo';
  BrowserForm.Width := 2048;
  BrowserForm.Height := 1024;
  BrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWVBrowserClassChainableTestClick(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
begin
  BrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
    .SetCaption('Exemplo')
    .SetWidth(2048)
    .SetHeight(1024)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true);
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWVBrowserClassPropertiesTestClick(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
begin
  BrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
  BrowserForm.Caption := 'Exemplo';
  BrowserForm.Width := 2048;
  BrowserForm.Height := 1024;
  BrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWVBrowserInterfaceChainableTestClick(Sender: TObject);
var
  BrowserForm: IBrowserForm;
begin
  BrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html')
    .SetCaption('Exemplo')
    .SetWidth(2048)
    .SetHeight(1024)
    .SetActionButtons([TBorderIcon.biMinimize, TBorderIcon.biMaximize])
    .SetResizable(true)
    .SetMovable(true);
  BrowserForm.ShowModal;
end;

procedure TFormBrowserTest.BtnWVBrowserInterfacePropertiesTestClick(Sender: TObject);
var
  BrowserForm: IBrowserForm;
begin
  BrowserForm := TCustomFormWVBrowser.Create('file:///' + ExtractFilePath(ParamStr(0)) + 'index.html');
  BrowserForm.Caption := 'Exemplo';
  BrowserForm.Width := 2048;
  BrowserForm.Height := 1024;
  BrowserForm.ActionButtons := [TBorderIcon.biMinimize, TBorderIcon.biMaximize];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.ShowModal;
end;

end.
