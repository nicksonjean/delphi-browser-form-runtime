program ProjectTest;

uses
  Vcl.Forms,
  FormTest in 'FormTest.pas' {FormBrowserTest},
  BrowserTypes in '..\Source\Generic\BrowserTypes.pas',
  BrowserGenericInterface in '..\Source\Generic\BrowserGenericInterface.pas',
  BrowserFormInterface in '..\Source\Context\BrowserFormInterface.pas',
  WVBrowserFormClass in '..\Source\Context\WVBrowserFormClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormBrowserTest, FormBrowserTest);
  Application.Run;
end.
