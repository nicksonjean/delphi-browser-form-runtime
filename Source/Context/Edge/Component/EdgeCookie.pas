unit EdgeCookie;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.Dwmapi,
  Winapi.ShellAPI,
  Winapi.ActiveX,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Edge,
  Vcl.OleCtrls,
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.Win.ComObj,
  WebView2;

type
  IEdgeCookie = interface
    ['{8A75BDF8-3608-4B5A-8DA0-6C7A8D3D4E5F}']
    function Get_Name: PWideChar; stdcall;
    function Get_Value: PWideChar; stdcall;
    function Get_Domain: PWideChar; stdcall;
    function Get_Path: PWideChar; stdcall;
    procedure Set_Value(const value: PWideChar); stdcall;
    property Name: PWideChar read Get_Name;
    property Value: PWideChar read Get_Value write Set_Value;
    property Domain: PWideChar read Get_Domain;
    property Path: PWideChar read Get_Path;
  end;

  TEdgeCookie = class(TInterfacedObject, IEdgeCookie)
  private
    FName: string;
    FValue: string;
    FDomain: string;
    FPath: string;
    FNamePtr: PWideChar;
    FValuePtr: PWideChar;
    FDomainPtr: PWideChar;
    FPathPtr: PWideChar;
    procedure UpdatePointers;
    procedure FreePointers;
  public
    constructor Create(const AName, AValue, ADomain, APath: string);
    destructor Destroy; override;
    function Get_Name: PWideChar; stdcall;
    function Get_Value: PWideChar; stdcall;
    function Get_Domain: PWideChar; stdcall;
    function Get_Path: PWideChar; stdcall;
    procedure Set_Value(const value: PWideChar); stdcall;
  end;

implementation

constructor TEdgeCookie.Create(const AName, AValue, ADomain, APath: string);
begin
  inherited Create;
  FName := AName;
  FValue := AValue;
  FDomain := ADomain;
  FPath := APath;
  UpdatePointers;
end;

destructor TEdgeCookie.Destroy;
begin
  FreePointers;
  inherited;
end;

procedure TEdgeCookie.UpdatePointers;
begin
  FreePointers;

  if FName <> '' then
  begin
    FNamePtr := CoTaskMemAlloc((Length(FName) + 1) * SizeOf(WideChar));
    if Assigned(FNamePtr) then
      Move(PWideChar(FName)^, FNamePtr^, (Length(FName) + 1) * SizeOf(WideChar));
  end;

  if FValue <> '' then
  begin
    FValuePtr := CoTaskMemAlloc((Length(FValue) + 1) * SizeOf(WideChar));
    if Assigned(FValuePtr) then
      Move(PWideChar(FValue)^, FValuePtr^, (Length(FValue) + 1) * SizeOf(WideChar));
  end;

  if FDomain <> '' then
  begin
    FDomainPtr := CoTaskMemAlloc((Length(FDomain) + 1) * SizeOf(WideChar));
    if Assigned(FDomainPtr) then
      Move(PWideChar(FDomain)^, FDomainPtr^, (Length(FDomain) + 1) * SizeOf(WideChar));
  end;

  if FPath <> '' then
  begin
    FPathPtr := CoTaskMemAlloc((Length(FPath) + 1) * SizeOf(WideChar));
    if Assigned(FPathPtr) then
      Move(PWideChar(FPath)^, FPathPtr^, (Length(FPath) + 1) * SizeOf(WideChar));
  end;
end;


procedure TEdgeCookie.FreePointers;
begin
  if Assigned(FNamePtr) then
  begin
    CoTaskMemFree(FNamePtr);
    FNamePtr := nil;
  end;

  if Assigned(FValuePtr) then
  begin
    CoTaskMemFree(FValuePtr);
    FValuePtr := nil;
  end;

  if Assigned(FDomainPtr) then
  begin
    CoTaskMemFree(FDomainPtr);
    FDomainPtr := nil;
  end;

  if Assigned(FPathPtr) then
  begin
    CoTaskMemFree(FPathPtr);
    FPathPtr := nil;
  end;
end;

function TEdgeCookie.Get_Name: PWideChar;
begin
  Result := FNamePtr;
end;

function TEdgeCookie.Get_Value: PWideChar;
begin
  Result := FValuePtr;
end;

function TEdgeCookie.Get_Domain: PWideChar;
begin
  Result := FDomainPtr;
end;

function TEdgeCookie.Get_Path: PWideChar;
begin
  Result := FPathPtr;
end;

procedure TEdgeCookie.Set_Value(const value: PWideChar);
begin
  if Assigned(value) then
  begin
    FValue := string(value);
    UpdatePointers;
  end;
end;

end.
