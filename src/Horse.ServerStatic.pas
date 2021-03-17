unit Horse.ServerStatic;

interface

uses
  System.Classes,
  System.SysUtils,
  Horse,
  Horse.Commons;

function ServerStatic(PathRoot: String): THorseCallback;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

var Path: string;

function StrInArray(Str: String; const Lista: Array of string): Boolean;
var
  i: integer;
begin
  for i := Low(Lista) to High(Lista) do
  begin
    if Lista[i] = Str then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function ChangeContentType(Extension: String): String;
begin
  if StrInArray(Extension, ['.jpg', '.png', '.jpeg']) then
    Result := 'image/png';
  if StrInArray(Extension, ['.html', '.htm']) then
    Result := 'text/html; charset=utf-8';
  if StrInArray(Extension, ['.js']) then
    Result := 'application/javascript';
  if StrInArray(Extension, ['.css']) then
    Result := 'text/css';
  if StrInArray(Extension, ['.json']) then
    Result := 'application/json';
  if Result = '' then
    Result := 'text/html; charset=utf-8';
end;

function ServerStatic(PathRoot: String): THorseCallback;
begin
  Path := PathRoot;
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  FileStream: TFileStream;
  PathFull: string;
  Extension: string;
begin
  Extension := ExtractFileExt(Req.RawWebRequest.PathInfo);
  if not Extension.isEmpty then
  begin
    PathFull := Path+'/'+Req.RawWebRequest.PathInfo;
    if not DirectoryExists(Path) then
      raise Exception.Create('Directory not found');
    if not FileExists(PathFull) then
      raise Exception.Create('File not found');
    try
      FileStream := TFileStream.Create(PathFull, fmOpenRead or fmShareDenyNone);
      FileStream.Position := 0;
      //send response
      Res.Status(THTTPStatus.OK);
      Res.RawWebResponse.SetCustomHeader('Content-Type', ChangeContentType(Extension));
      Res.RawWebResponse.ContentStream := FileStream;
      Res.RawWebResponse.SendResponse;
    finally

    end;
  end;

  Next;

end;

end.
