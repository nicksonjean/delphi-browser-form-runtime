unit BrowserGenericInterface;

interface

uses
  Vcl.Forms, System.Classes, BrowserTypes;

type
  IBrowserGeneric = interface
  ['{6C60A2A9-3AC3-4B29-AB6A-2A184F8B7414}']
    // Getters
    function GetWidthProp: Integer;
    function GetHeightProp: Integer;
    function GetCaptionProp: String;
    function GetCaptionPositionProp: TPositionCaption;
    function GetActionButtonsProp: TBorderIcons;
    function GetResizableProp: Boolean;
    function GetMovableProp: Boolean;
    function GetTitleBarProp: Boolean;
    function GetInstanceProp: TComponent;
    function ReadMessageReceiverProp: TMessageReceiverCallback;
    function ReadMessageSenderProp: String;

    // Setters
    procedure SetWidthProp(const Value: Integer);
    procedure SetHeightProp(const Value: Integer);
    procedure SetCaptionProp(const Value: string);
    procedure SetCaptionPositionProp(const Value: TPositionCaption);
    procedure SetActionButtonsProp(const Value: TBorderIcons);
    procedure SetResizableProp(const Value: Boolean);
    procedure SetMovableProp(const Value: Boolean);
    procedure SetTitleBarProp(const Value: Boolean);
    procedure SetMessageReceiverProp(const Value: TMessageReceiverCallback);
    procedure SetMessageSenderProp(const Value: String);

    // Properties
    property Width: Integer read GetWidthProp write SetWidthProp;
    property Height: Integer read GetHeightProp write SetHeightProp;
    property Caption: string read GetCaptionProp write SetCaptionProp;
    property CaptionPosition: TPositionCaption read GetCaptionPositionProp write SetCaptionPositionProp;
    property ActionButtons: TBorderIcons read GetActionButtonsProp write SetActionButtonsProp;
    property Resizable: Boolean read GetResizableProp write SetResizableProp;
    property Movable: Boolean read GetMovableProp write SetMovableProp;
    property TitleBar: Boolean read GetTitleBarProp write SetTitleBarProp;
    property Instance: TComponent read GetInstanceProp;
    property OnMessageReceiver: TMessageReceiverCallback read ReadMessageReceiverProp write SetMessageReceiverProp;
    property OnMessageSender: String read ReadMessageSenderProp write SetMessageSenderProp;
  end;

implementation

end.

