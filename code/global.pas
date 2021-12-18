unit Global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

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

  REG_F  = $00;
  REG_A  = $01;
  REG_C  = $02;
  REG_B  = $03;
  REG_E  = $04;
  REG_D  = $05;
  REG_L  = $06;
  REG_H  = $07;
  REG_F1 = $08;
  REG_A1 = $09;
  REG_C1 = $0A;
  REG_B1 = $0B;
  REG_E1 = $0C;
  REG_D1 = $0D;
  REG_L1 = $0E;
  REG_H1 = $0F;

  REG_AF  = $10;
  REG_BC  = $11;
  REG_DE  = $12;
  REG_HL  = $13;
  REG_AF1 = $14;
  REG_BC1 = $15;
  REG_DE1 = $16;
  REG_HL1 = $17;

  REG_PC  = $20;
  REG_SP  = $21;
  REG_R   = $22;
  REG_I   = $23;

  REG_MEM  = $F0;
  REG_IN   = $F1;
  REG_OUT  = $F2;
  REG_MEMW = $F3;
  REG_MEMR = $F4;

  OP_EQ  = 0;
  OP_GT  = 1;
  OP_LT  = 2;
  OP_NEQ = 3;
  OP_GET = 4;
  OP_LET = 5;
  OP_RD  = 6;
  OP_WR  = 7;



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
    Issue2: boolean;
    volume_AY: byte;
    volume_speaker: byte;
    volume_ear: byte;
    volume_mic: byte;
    AspectRatio: Boolean;
    ScrColor: integer;
    Dummy: Array[0..99] of byte;
  end;

  Tcond = record
    active: boolean;
    reg: byte;
    addr: word;
    op: byte;
    value: word;
  end;

  Tbreakpoint = record
    active: boolean;
    cond: array[0..2] of Tcond;
  end;

var
  options: Toptions;
  coldbootrequired: boolean = false;
  fdc_present: boolean = true;
  breakpoints: array[0..255] of Tbreakpoint;
  max_breakpoint: byte;
  grid_breakpoint_active: boolean = false;
  last_mem_write_addr: word = 0;
  last_mem_write_value: byte = 0;
  last_mem_read_addr: word = 0;
  last_mem_read_value: byte = 0;
  ports_in: array[0..$FFFF] of byte;
  ports_out: array[0..$FFFF] of byte;
  BorderEffect: boolean = false;

function is_plus3type_machine: boolean;
function is_fdc_machine: boolean;
function is_48k_machine: boolean;
function is_plus2type_machine: boolean;
function AYMachine: boolean;
procedure UnirArchivo( sTrozo, sArchivoOriginal: TFileName );
function Log10( x: real):real;
function calcVolumen(level: longint; minlevel, maxlevel: longint): word;
function calcVolumen(level: longint; maxlevel: longint): word;
function calcVolumen(level: longint): word;

implementation

function Log10( x: real):real;
begin
  Log10 := ln (x) / ln (10);
end;

function calcVolumen(level: longint; minlevel, maxlevel: longint): word;
begin
  if level = 0 then
    calcVolumen := 0
  else begin
    level := minlevel+(maxlevel-minlevel)*level div maxlevel;
    calcVolumen := round(10*log10(maxlevel/((maxlevel+1)-level)));
  end;
end;

function calcVolumen(level: longint; maxlevel: longint): word;
begin
  calcVolumen := calcVolumen(level,0,maxlevel);;
end;

function calcVolumen(level: longint): word;
begin
  CalcVolumen := calcVolumen(level,0,100);
end;

procedure UnirArchivo( sTrozo, sArchivoOriginal: TFileName );
var
  i: integer;
  FS, Stream: TFileStream;
begin
  i := 1;
  FS := TFileStream.Create( sArchivoOriginal, fmCreate or fmShareExclusive );

  try
    while FileExists( sTrozo ) do
    begin
      Stream := TFileStream.Create( sTrozo, fmOpenRead or fmShareDenyWrite );

      try
        FS.CopyFrom( Stream, 0 );
      finally
        Stream.Free;
      end;

      Inc(i);
      sTrozo := ChangeFileExt( sTrozo, '.' + FormatFloat( '000', i ) );
    end;
  finally
    FS.Free;
  end;
end;

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

