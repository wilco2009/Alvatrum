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
  Tmachine = (Spectrum48, tk90x, tk95, inves, Spectrum128, Spectrum_plus2, Spectrum_plus2a, Spectrum_plus3);
  TjoystickProtocol = (joyp_none,joyp_kempston, joyp_sinclair,joyp_user);
  TjoystickType = (joyt_none,joyt_cursor, joyt_j1,joyt_j2);
  TUser_buttons = array[0..4,0..1] of byte;

  TOptions = record
    machine: Tmachine;
    joystick_Protocol: TjoystickProtocol;
    JL_Type,JR_Type: TJoystickType;
    user_keys: TUser_buttons;
    ROMFilename: array[0..10,0..3] of string[100];
    cursorfire: word;
  end;

var
  options: Toptions;
  coldbootrequired: boolean = false;
  fdc_present: boolean = true;

function is_plus3type_machine: boolean;
function is_fdc_machine: boolean;
function is_48k_machine: boolean;
function is_plus2type_machine: boolean;
function AYMachine: boolean;

implementation

function AYMachine: boolean;
begin
     AYMachine := options.machine <= spectrum128;
end;

function is_plus3type_machine: boolean;
begin
  is_plus3type_machine := ((options.machine = Spectrum_plus2a) or (options.machine = Spectrum_plus3));
end;

function is_fdc_machine: boolean;
begin
  is_fdc_machine := (options.machine = spectrum_plus3);
end;

function is_48k_machine: boolean;
begin
  is_48k_machine := options.machine in [spectrum48,tk90x,tk95,inves];
end;

function is_plus2type_machine: boolean;
begin
  is_plus2type_machine := (options.machine = spectrum128) or (options.machine = spectrum_plus2);
end;

end.

