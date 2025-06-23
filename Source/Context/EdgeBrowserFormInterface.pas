unit EdgeBrowserFormInterface;

interface

uses
  Vcl.Forms, System.Classes, Vcl.Edge, BrowserTypes, EdgeBrowserGenericInterface;

type
  IEdgeBrowserForm = interface(IEdgeBrowserGeneric)
  ['{AEEB03BD-08A4-49D7-9993-5969B1A25AD1}']
    // Fluent methods
    function SetWidth(const AWidth: Integer): IEdgeBrowserForm;
    function SetHeight(const AHeight: Integer): IEdgeBrowserForm;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): IEdgeBrowserForm;
    function SetActionButtons(const AButtons: TBorderIcons): IEdgeBrowserForm;
    function SetResizable(const AResize: Boolean): IEdgeBrowserForm;
    function SetMovable(const AMove: Boolean): IEdgeBrowserForm;
    function SetTitleBar(const ATitleBar: Boolean): IEdgeBrowserForm;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): IEdgeBrowserForm;
    function SetMessageSender(const AMessage: String): IEdgeBrowserForm;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IEdgeBrowserForm;
    function SetAlpha(const AAlpha: Boolean): IEdgeBrowserForm;
    function SetURL(const AURL: String): IEdgeBrowserForm;
    function SetParentForm(const AParentForm: TForm): IEdgeBrowserForm;
    function SetParentBrowser(const AParentBrowser: TEdgeBrowser): IEdgeBrowserForm;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): IEdgeBrowserForm;
    function SetMaxInstances(const AMaxInstances: Integer): IEdgeBrowserForm;
    function SetLegacyForm(const ALegacyForm: Boolean): IEdgeBrowserForm;
    function SetWindowOpened(const AEvent: TNotifyEvent): IEdgeBrowserForm;
    function SetWindowClosed(const AEvent: TNotifyEvent): IEdgeBrowserForm;
    function SetHTMLContent(const AHTMLContent: String): IEdgeBrowserForm;
    procedure Show(const AType: TOpenType = TOpenType.Default);
    procedure ShowModal(const AType: TOpenType = TOpenType.Modal);
    procedure ShowAsModal(AParentForm: TForm = nil);
    procedure ShowAsMDICustom(AutoShow: Boolean = True);
    procedure ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
    procedure ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
  end;

implementation

end.
