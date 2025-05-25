unit BrowserTypes;

interface

type
  TPositionCaption = (Before, After, Replaced, Between, None);
  TOpenType = (Normal, Modal);
  TBrowserType = (WebBrowser, WebView);
  TMessageReceiverCallback = reference to procedure(Sender: TObject; const MessageText: string);

implementation

end.
