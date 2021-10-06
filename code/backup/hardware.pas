unit hardware;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure setKempston(n: byte);
procedure ResetKempston(n: byte);

var
    Kempston: byte;

implementation

procedure setKempston(n: byte);
begin
     Kempston := Kemston or (1 << n);
end;

procedure ResetKempston(n: byte);
begin
     Kempston := Kemston and not (1 << n);
end;

begin
  Kempston := 0;
end.

