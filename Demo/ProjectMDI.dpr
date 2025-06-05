program ProjectMDI;

uses
  Vcl.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitFilho in 'UnitFilho.pas' {FormFilho},
  BrowserTypes in '..\Source\Generic\BrowserTypes.pas',
  BrowserGenericInterface in '..\Source\Generic\BrowserGenericInterface.pas',
  BrowserFormInterface in '..\Source\Context\BrowserFormInterface.pas',
  WVBrowserFormClass in '..\Source\Context\WVBrowserFormClass.pas',
  AdvancedPopupExample in '..\Source\Example\AdvancedPopupExample.pas';


{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
