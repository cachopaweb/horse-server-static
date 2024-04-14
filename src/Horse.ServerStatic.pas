unit Horse.ServerStatic;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  Classes,
  SysUtils,
  {$ELSE}
  System.Classes,
  System.SysUtils,
  {$ENDIF}
  Horse,
  Horse.Commons;

function ServerStatic(PathRoot: String; RegisteredRoute: String = ''): THorseCallback;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});

implementation

uses
  {$IF DEFINED(FPC)}
  fpmimetypes, Types, StrUtils;
  {$ELSE}
  System.Net.Mime, System.IOUtils, System.Types, System.StrUtils;
  {$ENDIF}

var Path, RegRoute: string;

function ServerStatic(PathRoot, RegisteredRoute: String): THorseCallback;
begin
  Path := PathRoot;
  RegRoute := RegisteredRoute;
  if not AnsiStartsStr('/', RegRoute) then
    RegRoute := '/'+RegRoute;
  Result :=  {$IF DEFINED(FPC)}@Middleware{$ELSE}Middleware{$ENDIF};
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LFileStream: TFileStream;
  LFullPath: string;
  {$IFDEF FPC}
  LRetFind: Integer;
  LSearchRec: TSearchRec;
  LFiles: String;
  {$ELSE}
  LType: string;
  LKind: TMimeTypes.TKind;
  {$ENDIF}
  LPath: String;
  LIndexFiles : TStringDynArray;
  LExtension: string;	
begin
	LExtension := ExtractFileExt(Req.RawWebRequest.PathInfo);
  if not LExtension.isEmpty or Req.RawWebRequest.PathInfo.EndsWith('/') then
	begin
    {$IF DEFINED(FPC)}
    LPath := ConcatPaths([GetCurrentDir]);
    LFullPath := ConcatPaths([LPath,Req.RawWebRequest.PathInfo.Replace(RegRoute, EmptyStr).Replace('/',PathDelim)]);
    LFullPath := LFullPath.Replace(PathDelim+PathDelim,PathDelim);
    {$ELSE}
    LPath := TPath.Combine(TPath.GetLibraryPath,Path);
    LFullPath := LPath + TPath.DirectorySeparatorChar + Req.RawWebRequest.PathInfo.Replace(RegRoute, EmptyStr).Replace('/',TPath.DirectorySeparatorChar);
    LFullPath := LFullPath.Replace(TPath.DirectorySeparatorChar+TPath.DirectorySeparatorChar,TPath.DirectorySeparatorChar);
    {$ENDIF}

    if not DirectoryExists(ExtractFileDir(LFullPath)) then
      raise Exception.Create('Directory not found');

    if not FileExists(LFullPath) then
    begin
      {$IF DEFINED(FPC)}
      LFiles := EmptyStr;
      LRetFind := FindFirst(ConcatPaths([LFullPath,'index.*']), faAnyFile, LSearchRec);
      if (LRetFind = 0) then
      begin
        LFiles := ConcatPaths([LFullPath,LSearchRec.Name]);
        LIndexFiles := TStringDynArray.create(LFiles);
      end;
      {$ELSE}
      LIndexFiles := TDirectory.GetFiles(LFullPath,'index.*');
      {$ENDIF}
      if Length(LIndexFiles) > 0 then
        LFullPath := LIndexFiles[0]
      else
        raise Exception.Create('File not found');
    end;

    if not FileExists(LFullPath) then
      raise Exception.Create('File not found');

    LFileStream := TFileStream.Create(LFullPath, fmOpenRead or fmShareDenyNone);
    try
      LFileStream.Position := 0;

      Res.Status(THTTPStatus.OK);
      {$IF DEFINED(FPC)}
      MimeTypes.LoadKnownTypes;
      Res.ContentType(MimeTypes.GetMimeType(ExtractFileExt(LFullPath)));
      {$ELSE}
      TMimeTypes.Default.GetFileInfo(LFullPath, LType, LKind);
      Res.RawWebResponse.ContentType := LType;
      {$ENDIF}
      Res.RawWebResponse.ContentStream := LFileStream;
      Res.RawWebResponse.SendResponse;
      raise EHorseCallbackInterrupted.Create;
    finally
      LFileStream.Free;
    end;
  end;

  Next;
end;

end.