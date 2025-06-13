program ProjectTest;

uses
  Vcl.Forms,
  UnitPopup in 'UnitPopup.pas' {FormPopup},
  BrowserTypes in '..\Source\Generic\BrowserTypes.pas',
  BrowserGenericInterface in '..\Source\Generic\BrowserGenericInterface.pas',
  BrowserFormInterface in '..\Source\Context\BrowserFormInterface.pas',
  WVBrowserFormClass in '..\Source\Context\WVBrowserFormClass.pas',
  AdvancedPopupExample in '..\Source\Example\AdvancedPopupExample.pas';

{$R ProjectPopup.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPopup, FormPopup);
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Run;
end.
