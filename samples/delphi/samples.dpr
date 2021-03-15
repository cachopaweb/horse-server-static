program samples;

{$APPTYPE CONSOLE}

{$R *.res}

uses System.SysUtils,
     Horse,
     Horse.ServerStatic;

begin
  THorse.Use(ServerStatic('public'));

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000,
  procedure (App: THorse)
  begin
    Writeln('Server is running on port '+App.Port.ToString);
  end);

end.
