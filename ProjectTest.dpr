program ProjectTest;

uses
  Vcl.Forms,
  FormTest in 'FormTest.pas' {FormBrowserTest},
  WebBrowserFormClass in 'WebBrowserFormClass.pas',
  WVBrowserFormClass in 'WVBrowserFormClass.pas',
  BrowserFormInterface in 'BrowserFormInterface.pas',
  BrowserFormTypes in 'BrowserFormTypes.pas',
  BrowserStrategyClass in 'BrowserStrategyClass.pas',
  BrowserStrategyInterface in 'BrowserStrategyInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormBrowserTest, FormBrowserTest);
  Application.Run;
end.
