unit hardware;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure setKempston(n: byte);
procedure ResetKempston(n: byte);
procedure setSinclairLeft(n: byte);
procedure ResetSinclairLeft(n: byte);
procedure setSinclairRight(n: byte);
procedure ResetSinclairRight(n: byte);

var
    Kempston: byte = 0;
    SinclairRight: byte = 0;
    SinclairLeft: byte = 0;

implementation

procedure setSinclairLeft(n: byte);
begin
     SinclairLeft := SinclairLeft and not (1 << n);
end;

procedure ResetSinclairLeft(n: byte);
begin
     SinclairLeft := SinclairLeft or (1 << n);
end;

procedure setSinclairRight(n: byte);
begin
     SinclairRight := SinclairRight and not (1 << n);
end;

procedure ResetSinclairRight(n: byte);
begin
     SinclairRight := SinclairRight or (1 << n);
end;

procedure setKempston(n: byte);
begin
     Kempston := Kempston or (1 << n);
end;

procedure ResetKempston(n: byte);
begin
     Kempston := Kempston and not (1 << n);
end;

begin
  Kempston := 0;
end.

