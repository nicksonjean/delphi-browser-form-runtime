unit UnitPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.JSON, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,

  uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes, uWVTypeLibrary,
  uWVBrowserBase, uWVCoreWebView2Args, uWVCoreWebView2Deferral, uWVLoader,
  uWVLibFunctions, uWVConstants, uWVCoreWebView2, uWVInterfaces,
  uWVCoreWebView2WindowFeatures,

  BrowserTypes,
  BrowserFormInterface,
  WVBrowserFormClass,
  AdvancedPopupExample,

  UnitFilho;

type
  TFormPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    NovoDocumento1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    Janela1: TMenuItem;
    CascataVertical1: TMenuItem;
    LadoaLado1: TMenuItem;
    OrganizarIcones1: TMenuItem;
    N2: TMenuItem;
    FecharTodas1: TMenuItem;
    NovoFormulrioDinmico1: TMenuItem;
    N3: TMenuItem;
    NovoFormulrioDinmico2: TMenuItem;
    NovoFormulrioDinmico4: TMenuItem;
    NovoFormulrioDinmico3: TMenuItem;
    FormDinmicoMSN1: TMenuItem;
    FormDinmicoMax3Instncias1: TMenuItem;
    N5: TMenuItem;
    FormDinmicoBing1: TMenuItem;
    FormDinmicoGoogle1: TMenuItem;
    procedure NovoDocumento1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure CascataVertical1Click(Sender: TObject);
    procedure LadoaLado1Click(Sender: TObject);
    procedure OrganizarIcones1Click(Sender: TObject);
    procedure FecharTodas1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NovoFormulrioDinmico1Click(Sender: TObject);
    procedure NovoFormulrioDinmico2Click(Sender: TObject);
    procedure NovoFormulrioDinmico3Click(Sender: TObject);
    procedure NovoFormulrioDinmico4Click(Sender: TObject);
    procedure FormDinmicoMSN1Click(Sender: TObject);
    procedure FormDinmicoBing1Click(Sender: TObject);
    procedure FormDinmicoGoogle1Click(Sender: TObject);
    procedure FormDinmicoMax3Instncias1Click(Sender: TObject);
  private
    FContadorJanelas: Integer;
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIForm;
  FContadorJanelas := 0;
end;

procedure TFormPrincipal.NovoDocumento1Click(Sender: TObject);
var
  NovoForm: TFormFilho;
begin
  Inc(FContadorJanelas);
  NovoForm := TFormFilho.Create(Self);
  NovoForm.Caption := 'Documento ' + IntToStr(FContadorJanelas);
  NovoForm.Show;
end;

procedure TFormPrincipal.FormDinmicoBing1Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID8';
  BrowserForm := TCustomFormWVBrowser.CreateAsMDI(FormPrincipal, 'http://bing.com.br/', true);
  BrowserForm.Caption := 'Exemplo de Teste';
  BrowserForm.Width := 800;
  BrowserForm.Height := 600;
  BrowserForm.ActionButtons := [];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.CookieName := 'CookieName';
  BrowserForm.CookieValue := 'CookieValue';
  BrowserForm.CookieDomain := 'CookieDomain';
  BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
  begin
    Showmessage(MessageText);
  end;
  BrowserForm.ShowAsMDI(TMDIOptions.MultiInstanceMode(0, UniqueID));
end;

procedure TFormPrincipal.FormDinmicoGoogle1Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID7';
  BrowserForm := TCustomFormWVBrowser.Create;
  BrowserForm.LegacyForm := true;
  BrowserForm.ParentForm := FormPrincipal;
  BrowserForm.URL := 'http://google.com.br/';
  BrowserForm.Caption := 'Exemplo de Teste';
  BrowserForm.Width := 800;
  BrowserForm.Height := 600;
  BrowserForm.ActionButtons := [];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.CookieName := 'CookieName';
  BrowserForm.CookieValue := 'CookieValue';
  BrowserForm.CookieDomain := 'CookieDomain';
  BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
  begin
    Showmessage(MessageText);
  end;
  BrowserForm.ShowAsMDI(TMDIOptions.MultiInstanceMode(0, UniqueID));
end;

procedure TFormPrincipal.FormDinmicoMSN1Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID6';
  BrowserForm := TCustomFormWVBrowser.Create('https://www.msn.com/', FormPrincipal, true);
  BrowserForm.Caption := 'Exemplo de Teste';
  BrowserForm.Width := 800;
  BrowserForm.Height := 600;
  BrowserForm.ActionButtons := [];
  BrowserForm.Resizable := true;
  BrowserForm.Movable := true;
  BrowserForm.CookieName := 'CookieName';
  BrowserForm.CookieValue := 'CookieValue';
  BrowserForm.CookieDomain := 'CookieDomain';
  BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
  begin
    Showmessage(MessageText);
  end;
  BrowserForm.ShowAsMDI(TMDIOptions.MultiInstanceMode(0, UniqueID));
end;

procedure TFormPrincipal.FormDinmicoMax3Instncias1Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID5';
  if TCustomFormWVBrowser.CheckMDILimits(UniqueID, 3, False) then
  begin
    BrowserForm := TCustomFormWVBrowser.Create;
    BrowserForm.ParentForm := FormPrincipal;
    BrowserForm.UniqueIdentifier := UniqueID;
    BrowserForm.MaxInstances := 3;
    BrowserForm.URL := 'http://bing.com.br/';
    BrowserForm.Caption := 'Exemplo de Teste';
    BrowserForm.Width := 800;
    BrowserForm.Height := 600;
    BrowserForm.ActionButtons := [];
    BrowserForm.Resizable := true;
    BrowserForm.Movable := true;
    BrowserForm.CookieName := 'CookieName';
    BrowserForm.CookieValue := 'CookieValue';
    BrowserForm.CookieDomain := 'CookieDomain';
    BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      Showmessage(MessageText);
    end;
    BrowserForm.ShowAsMDI(TMDIOptions.MultiInstanceMode(3, UniqueID));
  end;
end;

procedure TFormPrincipal.NovoFormulrioDinmico1Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID1';
  BrowserForm := TCustomFormWVBrowser.FindMDIInstance(UniqueID);
  if Assigned(BrowserForm) then
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID))
  else
  begin
    BrowserForm := TCustomFormWVBrowser.Create;
    BrowserForm.ParentForm := FormPrincipal;
    BrowserForm.UniqueIdentifier := UniqueID;
    BrowserForm.URL := 'http://bing.com.br/';
    BrowserForm.Caption := 'Exemplo de Teste';
    BrowserForm.Width := 800;
    BrowserForm.Height := 600;
    BrowserForm.ActionButtons := [];
    BrowserForm.Resizable := true;
    BrowserForm.Movable := true;
    BrowserForm.CookieName := 'CookieName';
    BrowserForm.CookieValue := 'CookieValue';
    BrowserForm.CookieDomain := 'CookieDomain';
    BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      Showmessage(MessageText);
    end;
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID));
  end;
end;

procedure TFormPrincipal.NovoFormulrioDinmico2Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID2';
  BrowserForm := TCustomFormWVBrowser.FindMDIInstance(UniqueID);
  if Assigned(BrowserForm) then
  if Assigned(BrowserForm) then
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID))
  else
  begin
    BrowserForm := TCustomFormWVBrowser.Create;
    BrowserForm.ParentForm := FormPrincipal;
    BrowserForm.UniqueIdentifier := UniqueID;
    BrowserForm.URL := 'http://google.com.br/';
    BrowserForm.Caption := 'Exemplo de Teste';
    BrowserForm.Width := 800;
    BrowserForm.Height := 600;
    BrowserForm.ActionButtons := [];
    BrowserForm.Resizable := true;
    BrowserForm.Movable := true;
    BrowserForm.CookieName := 'CookieName';
    BrowserForm.CookieValue := 'CookieValue';
    BrowserForm.CookieDomain := 'CookieDomain';
    BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      Showmessage(MessageText);
    end;
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID));
  end;
end;

procedure TFormPrincipal.NovoFormulrioDinmico3Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID3';
  BrowserForm := TCustomFormWVBrowser.FindMDIInstance(UniqueID);
  if Assigned(BrowserForm) then
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID))
  else
  begin
    BrowserForm := TCustomFormWVBrowser.CreateAsMDI(FormPrincipal, 'https://www.msn.com/');
    BrowserForm.UniqueIdentifier := UniqueID;
    BrowserForm.Caption := 'Exemplo de Teste';
    BrowserForm.Width := 800;
    BrowserForm.Height := 600;
    BrowserForm.ActionButtons := [];
    BrowserForm.Resizable := true;
    BrowserForm.Movable := true;
    BrowserForm.CookieName := 'CookieName';
    BrowserForm.CookieValue := 'CookieValue';
    BrowserForm.CookieDomain := 'CookieDomain';
    BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      Showmessage(MessageText);
    end;
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID));
  end;
end;

procedure TFormPrincipal.NovoFormulrioDinmico4Click(Sender: TObject);
var
  BrowserForm: TCustomFormWVBrowser;
  UniqueID: String;
begin
  UniqueID := 'CustomID4';
  BrowserForm := TCustomFormWVBrowser.FindMDIInstance(UniqueID);
  if Assigned(BrowserForm) then
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID))
  else
  begin
    BrowserForm := TCustomFormWVBrowser.Create('https://duckduckgo.com/', FormPrincipal);
    BrowserForm.UniqueIdentifier := UniqueID;
    BrowserForm.Caption := 'Exemplo de Teste';
    BrowserForm.Width := 800;
    BrowserForm.Height := 600;
    BrowserForm.ActionButtons := [];
    BrowserForm.Resizable := true;
    BrowserForm.Movable := true;
    BrowserForm.CookieName := 'CookieName';
    BrowserForm.CookieValue := 'CookieValue';
    BrowserForm.CookieDomain := 'CookieDomain';
    BrowserForm.OnMessageReceiver := procedure(Sender: TObject; const MessageText: string)
    begin
      Showmessage(MessageText);
    end;
    BrowserForm.ShowAsMDI(TMDIOptions.SingleInstanceMode(UniqueID));
  end;
end;

procedure TFormPrincipal.Sair1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.CascataVertical1Click(Sender: TObject);
begin
  Cascade;
end;

procedure TFormPrincipal.LadoaLado1Click(Sender: TObject);
begin
  TileMode := tbHorizontal;
  Tile;
end;

procedure TFormPrincipal.OrganizarIcones1Click(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TFormPrincipal.FecharTodas1Click(Sender: TObject);
var
  i: Integer;
begin
  for i := MDIChildCount - 1 downto 0 do
    MDIChildren[i].Close;
end;

end.
