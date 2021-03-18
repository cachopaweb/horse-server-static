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

uses System.Net.Mime;

var Path: string;

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
  aType: string;
  aKind: TMimeTypes.TKind;
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
      TMimeTypes.Default.GetFileInfo(PathFull, aType, aKind);
      Res.RawWebResponse.ContentType := aType;
      Res.RawWebResponse.ContentStream := FileStream;
      Res.RawWebResponse.SendResponse;
    finally

    end;
  end;

  Next;

end;

end.
