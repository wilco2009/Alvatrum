unit Global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type
  Tmachine = (Spectrum48, Spectrum128, Spectrum_plus3, Spectrum_pus2, Spectrum_plus2a);
  Tjoystick = (joy_kempston, joy_sinclair);

  TOptions = record
    machine: Tmachine;
    joystick: Tjoystick;
  end;

var
  options: Toptions;

implementation

end.

