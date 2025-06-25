program ProjectMDI;

uses
  Vcl.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitFilho in 'UnitFilho.pas' {FormFilho},
  BrowserTypes in '..\Source\Generic\BrowserTypes.pas',
  WVBrowserGenericInterface in '..\Source\Generic\WVBrowserGenericInterface.pas',
  IWebViewBrowserForm in '..\Source\Context\IWebViewBrowserForm.pas',
  WebViewBrowserForm in '..\Source\Context\WebViewBrowserForm.pas',
  WebViewAdvancedPopupExample in '..\Source\Example\WebViewAdvancedPopupExample.pas',
  EdgeWebBrowserForm in '..\Source\Context\EdgeWebBrowserForm.pas',
  IEdgeWebBrowserForm in '..\Source\Context\IEdgeWebBrowserForm.pas',
  EdgeBrowserGenericInterface in '..\Source\Generic\EdgeBrowserGenericInterface.pas',
  UtilsLib in '..\Source\Generic\UtilsLib.pas',
  EdgeCookie in '..\Source\Context\Edge\EdgeCookie.pas',
  EdgeDeferral in '..\Source\Context\Edge\EdgeDeferral.pas',
  EdgeNewWindowRequestedEventArgs in '..\Source\Context\Edge\EdgeNewWindowRequestedEventArgs.pas',
  EdgeBrowserHelper in '..\Source\Context\Edge\EdgeBrowserHelper.pas',
  EdgeWindowFeatures in '..\Source\Context\Edge\EdgeWindowFeatures.pas',
  TimerHelper in '..\Source\Generic\TimerHelper.pas',
  EdgeWebAdvancedPopupExample in '..\Source\Example\EdgeWebAdvancedPopupExample.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Run;
end.
