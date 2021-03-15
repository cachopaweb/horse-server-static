# Horse-Server-Static
Middleware to server static files in Horse

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/CachopaWeb/horse-server-static
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

## usage

### It can be any folder next to the executable
### Image directory
### Ex.: public/imagem.jpg
``` sh
THorse.Use(ServerStatic('public'));

http://localhost:9000/imagem.jpg
```
### Or files from a static website
### Ex.: public/index.html

``` sh
http://localhost:9000/index.html
http://localhost:9000/css/style.css
http://localhost:9000/js/app.js
http://localhost:9000/images/bg.png
```
