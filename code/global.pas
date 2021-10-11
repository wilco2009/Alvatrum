unit Global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  user_up = 0;
  user_down = 1;
  user_left = 2;
  user_right = 3;
  user_fire = 4;

  kempston_right = 0;
  kempston_left  = 1;
  kempston_down  = 2;
  kempston_up    = 3;
  kempston_fire  = 4;

  ROMPAGE0 = 32;
  ROMPAGE1 = 33;
  ROMPAGE2 = 34;
  ROMPAGE3 = 35;

  SCREENPAGE = 5;
  SHADOWPAGE = 7;


Type
  Tmachine = (Spectrum48, Spectrum128, Spectrum_plus2, Spectrum_plus2a, Spectrum_plus3);
  TjoystickProtocol = (joyp_none,joyp_kempston, joyp_sinclair,joyp_user);
  TjoystickType = (joyt_none,joyt_cursor, joyt_j1,joyt_j2);
  TUser_buttons = array[0..4,0..1] of byte;

  TOptions = record
    machine: Tmachine;
    joystick_Protocol: TjoystickProtocol;
    JL_Type,JR_Type: TJoystickType;
    user_keys: TUser_buttons;
    ROMFilename: array[0..10,0..3] of string[100];
  end;

var
  options: Toptions;
  coldbootrequired: boolean = false;

implementation

end.

