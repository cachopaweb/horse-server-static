program samples;

{$MODE DELPHI}{$H+}

uses Horse,
     Horse.ServerStatic;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  Res.Send('Pong');
end;

begin
  THorse.Use(ServerStatic('modules/horse/tests/'));

  THorse.Get('/ping', GetPing);
  THorse.Listen(9000);
end.


