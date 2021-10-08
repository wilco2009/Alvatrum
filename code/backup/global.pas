unit Global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type
  Tmachine = (Spectrum48, Spectrum128, Spectrum_plus3, Spectrum_pus2, Spectrum_plus2a);
  TjoystickProtocol = (joyp_none,joyp_kempston, joyp_sinclair,joyp_user);
  TjoystickType = (joyt_none,joyt_cursor, joyt_j1,joyt_j2);
  TUser_buttons = array[0..4,0..1] of byte;

  TOptions = record
    machine: Tmachine;
    joystick_Protocol: TjoystickProtocol;
    JL_Type,JR_Type: TJoystickType;
    user_keys: TUser_buttons;
  end;

var
  options: Toptions;

implementation

end.

