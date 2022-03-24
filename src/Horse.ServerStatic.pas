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

uses System.Net.Mime, System.IOUtils, System.Types;

var Path: string;

function ServerStatic(PathRoot: String): THorseCallback;
begin
  Path := PathRoot;
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LFileStream: TFileStream;
  LFullPath: string;
  LExtension: string;
  LType: string;
  LKind: TMimeTypes.TKind;
  LPath : string;
  LIndexFiles : TStringDynArray;
begin
  LExtension := ExtractFileExt(Req.RawWebRequest.PathInfo);
  if not LExtension.isEmpty or Req.RawWebRequest.PathInfo.EndsWith('/') then
  begin

    LPath := TPath.Combine(TPath.GetLibraryPath,Path);
    LFullPath := LPath + TPath.DirectorySeparatorChar + Req.RawWebRequest.PathInfo.Replace('/',TPath.DirectorySeparatorChar);
    LFullPath := LFullPath.Replace(TPath.DirectorySeparatorChar+TPath.DirectorySeparatorChar,TPath.DirectorySeparatorChar);

    if not DirectoryExists(LPath) then
      raise Exception.Create('Directory not found');
    if not FileExists(LFullPath) then
    begin
      LIndexFiles := TDirectory.GetFiles(LFullPath,'index.*');
      if Length(LIndexFiles) > 0 then
        LFullPath := LIndexFiles[0]
      else
        raise Exception.Create('File not found');
    end;

    LFileStream := TFileStream.Create(LFullPath, fmOpenRead or fmShareDenyNone);
    LFileStream.Position := 0;

    Res.Status(THTTPStatus.OK);
    TMimeTypes.Default.GetFileInfo(LFullPath, LType, LKind);
    Res.RawWebResponse.ContentType := LType;
    Res.RawWebResponse.ContentStream := LFileStream;
    Res.RawWebResponse.SendResponse;

  end;

  Next;

end;

end.
