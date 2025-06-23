unit BrowserTypes;

interface
uses
  System.SysUtils, Vcl.ExtCtrls;

type
  TBrowserType = (EdgeBrowser, WVBrowser);
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
  end;

  TMDIOptionsHelper = record helper for TMDIOptions
  private
    class function InitWith(
      AAutoShow: Boolean;
      ASingleInstance: Boolean;
      AMaximizeOnShow: Boolean;
      ABringToFrontIfExists: Boolean;
      const AUniqueIdentifier: String;
      AMaxInstances: Integer
    ): TMDIOptions; static;
  public
    class function Default: TMDIOptions; static;
    class function Simple: TMDIOptions; static;
    class function SingleInstanceMode(const AUniqueID: String = ''): TMDIOptions; static;
    class function MultiInstanceMode(const AMaxInstances: Integer; const AUniqueID: String = ''): TMDIOptions; static;
  end;

implementation

{ TMDIOptionsHelper }

class function TMDIOptionsHelper.InitWith(
  AAutoShow: Boolean;
  ASingleInstance: Boolean;
  AMaximizeOnShow: Boolean;
  ABringToFrontIfExists: Boolean;
  const AUniqueIdentifier: String;
  AMaxInstances: Integer
): TMDIOptions;
begin
  Result.AutoShow := AAutoShow;
  Result.SingleInstance := ASingleInstance;
  Result.MaximizeOnShow := AMaximizeOnShow;
  Result.BringToFrontIfExists := ABringToFrontIfExists;
  Result.UniqueIdentifier := AUniqueIdentifier;
  Result.MaxInstances := AMaxInstances;
end;

class function TMDIOptionsHelper.Default: TMDIOptions;
begin
  Result := InitWith(True, True, True, True, EmptyStr, 1);
end;

class function TMDIOptionsHelper.Simple: TMDIOptions;
begin
  Result := InitWith(True, False, True, True, EmptyStr, 0);
end;

class function TMDIOptionsHelper.SingleInstanceMode(const AUniqueID: String): TMDIOptions;
begin
  Result := InitWith(True, True, True, True, AUniqueID, 1);
end;

class function TMDIOptionsHelper.MultiInstanceMode(const AMaxInstances: Integer; const AUniqueID: String): TMDIOptions;
begin
  Result := InitWith(True, False, True, True, AUniqueID, AMaxInstances);
end;

end.
