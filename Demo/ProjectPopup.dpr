program ProjectTest;

uses
  Vcl.Forms,
  UnitPopup in 'UnitPopup.pas' {FormPopup},
  WebViewBrowserForm in '..\Source\Context\WebViewBrowserForm.pas',
  WebViewAdvancedPopupExample in '..\Source\Example\WebViewAdvancedPopupExample.pas',
  EdgeWebBrowserForm in '..\Source\Context\EdgeWebBrowserForm.pas',
  EdgeWebAdvancedPopupExample in '..\Source\Example\EdgeWebAdvancedPopupExample.pas',
  UtilsLib in '..\Source\Generic\UtilsLib.pas',
  TimerHelper in '..\Source\Generic\TimerHelper.pas',
  BrowserTypes in '..\Source\Context\BrowserTypes.pas',
  IEdgeWebBrowserForm in '..\Source\Context\Edge\Interfaces\IEdgeWebBrowserForm.pas',
  IWebViewBrowserForm in '..\Source\Context\WebView\Interfaces\IWebViewBrowserForm.pas',
  EdgeBrowserHelper in '..\Source\Context\Edge\Component\EdgeBrowserHelper.pas',
  EdgeCookie in '..\Source\Context\Edge\Component\EdgeCookie.pas',
  EdgeDeferral in '..\Source\Context\Edge\Component\EdgeDeferral.pas',
  EdgeNewWindowRequestedEventArgs in '..\Source\Context\Edge\Component\EdgeNewWindowRequestedEventArgs.pas',
  EdgeWindowFeatures in '..\Source\Context\Edge\Component\EdgeWindowFeatures.pas',
  IBrowserFormBase in '..\Source\Context\IBrowserFormBase.pas',
  BrowserFactory in '..\Source\Strategy\BrowserFactory.pas';

{$R ProjectPopup.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPopup, FormPopup);
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Run;
end.
