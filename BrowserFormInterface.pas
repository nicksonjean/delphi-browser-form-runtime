unit BrowserFormInterface;

interface

uses
  Vcl.Forms, BrowserFormTypes;

type
  IBrowserForm = interface
  ['{F3F73E9C-B0C0-41D3-9B8A-FAC7F5E1E4B9}']
  // Fluent methods
  function SetWidth(const AWidth: Integer): IBrowserForm;
  function SetHeight(const AHeight: Integer): IBrowserForm;
  function SetCaption(const ACaption: String; APosition: TPositionCaption = TPositionCaption.Before): IBrowserForm;
  function SetActionButtons(const AButtons: TBorderIcons): IBrowserForm;
  function SetResizable(const AResize: Boolean): IBrowserForm;
  function SetMovable(const AMove: Boolean): IBrowserForm;
  procedure Show(const AType: TOpenType = TOpenType.Normal);
  procedure ShowModal(const AType: TOpenType = TOpenType.Modal);

  // Getters
  function GetWidthProp: Integer;
  function GetHeightProp: Integer;
  function GetCaptionProp: String;
  function GetCaptionPositionProp: TPositionCaption;
  function GetActionButtonsProp: TBorderIcons;
  function GetResizableProp: Boolean;
  function GetMovableProp: Boolean;

  // Setters
  procedure SetWidthProp(const Value: Integer);
  procedure SetHeightProp(const Value: Integer);
  procedure SetCaptionProp(const Value: string);
  procedure SetCaptionPositionProp(const Value: TPositionCaption);
  procedure SetActionButtonsProp(const Value: TBorderIcons);
  procedure SetResizableProp(const Value: Boolean);
  procedure SetMovableProp(const Value: Boolean);

  // Properties
  property Width: Integer read GetWidthProp write SetWidthProp;
  property Height: Integer read GetHeightProp write SetHeightProp;
  property Caption: string read GetCaptionProp write SetCaptionProp;
  property CaptionPosition: TPositionCaption read GetCaptionPositionProp write SetCaptionPositionProp;
  property ActionButtons: TBorderIcons read GetActionButtonsProp write SetActionButtonsProp;
  property Resizable: Boolean read GetResizableProp write SetResizableProp;
  property Movable: Boolean read GetMovableProp write SetMovableProp;
end;

implementation

end.
