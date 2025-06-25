unit IEdgeWebBrowserForm;

interface

uses
  Vcl.Forms, System.Classes, Vcl.Edge, BrowserTypes, IBrowserFormBase;

type
  IEWBrowserForm = interface(IBrowserForm)
  ['{AEEB03BD-08A4-49D7-9993-5969B1A25AD1}']
    // EdgeWeb Specialized Methods
    function GetParentEdgeWebProp: TEdgeBrowser;
    procedure SetParentEdgeWebProp(const Value: TEdgeBrowser);
    property ParentEdgeWeb: TEdgeBrowser read GetParentEdgeWebProp write SetParentEdgeWebProp;

    // Fluent Methods
    function SetWidth(const AWidth: Integer): IEWBrowserForm;
    function SetHeight(const AHeight: Integer): IEWBrowserForm;
    function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Between): IEWBrowserForm;
    function SetActionButtons(const AButtons: TBorderIcons): IEWBrowserForm;
    function SetResizable(const AResize: Boolean): IEWBrowserForm;
    function SetMovable(const AMove: Boolean): IEWBrowserForm;
    function SetTitleBar(const ATitleBar: Boolean): IEWBrowserForm;
    function SetMessageReceiver(const AMessage: TMessageReceiverCallback): IEWBrowserForm;
    function SetMessageSender(const AMessage: String): IEWBrowserForm;
    function SetCookie(const ACookieName, ACookieValue, ACookieDomain: String; const ACookiePath: String = '/'): IEWBrowserForm;
    function SetAlpha(const AAlpha: Boolean): IEWBrowserForm;
    function SetURL(const AURL: String): IEWBrowserForm;
    function SetParentForm(const AParentForm: TForm): IEWBrowserForm;
    function SetParentBrowser(const AParentBrowser: TEdgeBrowser): IEWBrowserForm;
    function SetUniqueIdentifier(const AUniqueIdentifier: String): IEWBrowserForm;
    function SetMaxInstances(const AMaxInstances: Integer): IEWBrowserForm;
    function SetLegacyForm(const ALegacyForm: Boolean): IEWBrowserForm;
    function SetWindowOpened(const AEvent: TNotifyEvent): IEWBrowserForm;
    function SetWindowClosed(const AEvent: TNotifyEvent): IEWBrowserForm;
    function SetHTMLContent(const AHTMLContent: String): IEWBrowserForm;
  end;

implementation

end.
