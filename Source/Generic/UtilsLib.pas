unit UtilsLib;

interface

uses
  System.SysUtils, Vcl.ExtCtrls, System.JSON;

type
  TUtils = class
  public
    class function DecodeDataURL(const DataURL: string): string;
    class function EnsureCacheDirectory(const ACachePath: string): string;
    class function FormatJSONString(const JSONString: string): string;
  end;

implementation

{ TUtils }

class function TUtils.FormatJSONString(const JSONString: string): string;
var
  JSONObject: TJSONObject;
begin
  Result := JSONString;

  try
    JSONObject := TJSONObject.ParseJSONValue(JSONString) as TJSONObject;
    if Assigned(JSONObject) then
    begin
      try
        Result := JSONObject.Format(2);
      finally
        JSONObject.Free;
      end;
    end;
  except
    Result := JSONString;
  end;
end;

class function TUtils.DecodeDataURL(const DataURL: string): string;
var
  CommaPos: Integer;
  DataPart: string;
begin
  Result := EmptyStr;
  CommaPos := Pos(',', DataURL);
  if CommaPos > 0 then
  begin
    DataPart := Copy(DataURL, CommaPos + 1, Length(DataURL));
    DataPart := StringReplace(DataPart, '%20', ' ', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%0A', #10, [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%0D', #13, [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%22', '"', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%3C', '<', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%3E', '>', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%3D', '=', [rfReplaceAll]);
    DataPart := StringReplace(DataPart, '%2F', '/', [rfReplaceAll]);
    Result := DataPart;
  end;
end;

class function TUtils.EnsureCacheDirectory(const ACachePath: string): string;
var
  FullPath: string;
begin
  FullPath := ExtractFilePath(ParamStr(0)) + ACachePath;
  
    if not DirectoryExists(FullPath) then
  begin
    if not ForceDirectories(FullPath) then
      raise Exception.Create('Não foi possível criar o diretório de cache: ' + FullPath);
  end;
  
  Result := FullPath;
end;

end.
