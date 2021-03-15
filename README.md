# Horse-Server-Static
Middleware to server static files in Horse

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/CachopaWeb/Horse-Server-Static
```

Sample Horse Server
```delphi
uses Horse, Horse.ServerStatic;

begin
  THorse.Use(ServerStatic('public'));

  THorse.Post('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000,
  procedure (App: THorse)
  begin
    Writeln('Server is running on port '+App.Port.ToString);
  end);
end;
```