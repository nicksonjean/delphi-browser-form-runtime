program ProjectMDI;

uses
  Vcl.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitFilho in 'UnitFilho.pas' {FormFilho},
  BrowserTypes in '..\Source\Generic\BrowserTypes.pas',
  WVBrowserGenericInterface in '..\Source\Generic\WVBrowserGenericInterface.pas',
  WVBrowserFormInterface in '..\Source\Context\WVBrowserFormInterface.pas',
  WVBrowserFormClass in '..\Source\Context\WVBrowserFormClass.pas',
  WVAdvancedPopupExample in '..\Source\Example\WVAdvancedPopupExample.pas',
  EdgeBrowserFormClass in '..\Source\Context\EdgeBrowserFormClass.pas',
  EdgeBrowserFormInterface in '..\Source\Context\EdgeBrowserFormInterface.pas',
  EdgeBrowserGenericInterface in '..\Source\Generic\EdgeBrowserGenericInterface.pas',
  UtilsLib in '..\Source\Generic\UtilsLib.pas',
  EdgeCookie in '..\Source\Context\Edge\EdgeCookie.pas',
  EdgeDeferral in '..\Source\Context\Edge\EdgeDeferral.pas',
  EdgeNewWindowRequestedEventArgs in '..\Source\Context\Edge\EdgeNewWindowRequestedEventArgs.pas',
  EdgeBrowserHelper in '..\Source\Context\Edge\EdgeBrowserHelper.pas',
  EdgeWindowFeatures in '..\Source\Context\Edge\EdgeWindowFeatures.pas',
  TimerHelper in '..\Source\Generic\TimerHelper.pas',
  EdgeAdvancedPopupExample in '..\Source\Example\EdgeAdvancedPopupExample.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Run;
end.
