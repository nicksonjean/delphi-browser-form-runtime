unit BrowserTypes;

interface

uses
  System.SysUtils, Vcl.ExtCtrls;

type
  TBrowserConstructorType = (Dummy);
  TBrowserType = (WebBrowser, WebView);
  TOpenType = (Default, Modal);
  TFormType = (Normal, Popup, MDI);
  TPositionCaption = (Before, After, Replaced, Between, None);
  TMessageReceiverCallback = reference to procedure(Sender: TObject; const MessageText: string);

  TCallbackInfo = record
    Timer: TTimer;
    Callback: TProc;
  end;

  TMDIOptions = record
    AutoShow: Boolean;
    SingleInstance: Boolean;
    MaximizeOnShow: Boolean;
    BringToFrontIfExists: Boolean;
    UniqueIdentifier: String;
    MaxInstances: Integer;
    class function Default: TMDIOptions; static;
    class function Simple: TMDIOptions; static;
    class function SingleInstanceMode(const AUniqueID: String = ''): TMDIOptions; static;
    class function MultiInstanceMode(const AMaxInstances: Integer; const AUniqueID: String = ''): TMDIOptions; static;
  end;

implementation

{ TMDIOptions }

class function TMDIOptions.Default: TMDIOptions;
begin
  Result.AutoShow := True;
  Result.SingleInstance := False;
  Result.MaximizeOnShow := True;
  Result.BringToFrontIfExists := True;
  Result.UniqueIdentifier := '';
  Result.MaxInstances := 999;
end;

class function TMDIOptions.Simple: TMDIOptions;
begin
  Result := Default;
  Result.SingleInstance := False;
  Result.MaxInstances := 999;
end;

class function TMDIOptions.SingleInstanceMode(const AUniqueID: String): TMDIOptions;
begin
  Result := Default;
  Result.SingleInstance := True;
  Result.UniqueIdentifier := AUniqueID;
  Result.MaxInstances := 1;
end;

class function TMDIOptions.MultiInstanceMode(const AMaxInstances: Integer; const AUniqueID: String): TMDIOptions;
begin
  Result := Default;
  Result.SingleInstance := False;
  Result.MaxInstances := AMaxInstances;
  Result.UniqueIdentifier := AUniqueID;
end;

end.
