unit WVBrowserFormInterface;

interface

uses
  Vcl.Forms, System.Classes, uWVBrowser, BrowserTypes, WVBrowserGenericInterface;

type
  IWVBrowserForm = interface(IWVBrowserGeneric)
  ['{F3F73E9C-B0C0-41D3-9B8A-FAC7F5E1E4B9}']
    // Fluent methods
    function SetWidth(const AWidth: Integer): IWVBrowserForm;
    function SetHeight(const AHeight: Integer): IWVBrowserForm;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): IWVBrowserForm;
    function SetActionButtons(const AButtons: TBorderIcons): IWVBrowserForm;
    function SetResizable(const AResize: Boolean): IWVBrowserForm;
    function SetMovable(const AMove: Boolean): IWVBrowserForm;
    function SetTitleBar(const ATitleBar: Boolean): IWVBrowserForm;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): IWVBrowserForm;
    function SetMessageSender(const AMessage: String): IWVBrowserForm;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IWVBrowserForm;
    function SetAlpha(const AAlpha: Boolean): IWVBrowserForm;
    function SetURL(const AURL: String): IWVBrowserForm;
    function SetParentForm(const AParentForm: TForm): IWVBrowserForm;
    function SetParentBrowser(const AParentBrowser: TWVBrowser): IWVBrowserForm;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): IWVBrowserForm;
    function SetMaxInstances(const AMaxInstances: Integer): IWVBrowserForm;
    function SetLegacyForm(const ALegacyForm: Boolean): IWVBrowserForm;
    function SetWindowOpened(const AEvent: TNotifyEvent): IWVBrowserForm;
    function SetWindowClosed(const AEvent: TNotifyEvent): IWVBrowserForm;
    function SetHTMLContent(const AHTMLContent: String): IWVBrowserForm;
    procedure Show(const AType: TOpenType = TOpenType.Default);
    procedure ShowModal(const AType: TOpenType = TOpenType.Modal);
    procedure ShowAsModal(AParentForm: TForm = nil);
    procedure ShowAsMDICustom(AutoShow: Boolean = True);
    procedure ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
    procedure ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
  end;

implementation

end.
