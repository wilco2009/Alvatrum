unit spectrum;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,CRT,Z80Globals;

const
  ancho_borde = 30;
  alto_borde = 30;
  bufsize = 89*2;//195;//780;
  spec_buffer_size = bufsize*16;
  //screen_invisible_borde_superior=8;
  //screen_borde_superior=56;
  //screen_total_borde_inferior=56;
  //screen_total_borde_izquierdo=48;
  //screen_total_borde_derecho=48;
  //screen_invisible_borde_derecho=96;
  //screen_indice_inicio_pant=screen_invisible_borde_superior+screen_borde_superior;
  //screen_indice_fin_pant=screen_indice_inicio_pant+192;
  //screen_scanlines=screen_indice_fin_pant+screen_total_borde_inferior;
  //screen_testados_linea=224;
  //screen_testados_total=screen_testados_linea*screen_scanlines;
  screen_testados_total=70000;
  scanline_testados = 218;//208; //screen_testados_total div 334;//312;
  screen_tstates_half_scanline = scanline_testados;

  MAX_TAPE_BLOCKS = 99;

type
  TTapeBlockInfo = record
    Filepos: longint;
    Size: word;
    Flag: byte;
  end;

var
  Tape_info: array[1..MAX_TAPE_BLOCKS] of TTapeBlockInfo;
  border_color : byte = 7;
  frame: byte = 0;
  //enter_pulsado: boolean = false;
  real_time, sp_time: qword;
  em_delay: longint;
  repaint_screen: boolean = false;
  screen_tstates_reached : boolean = false;
  init_time, current_time: QWord;
  frames: longint = 0;
  time: real;
  t_states_cur_half_scanline : Qword = 0;
  t_states_ini_half_scanline : Qword = 0;
  t_states_cur_instruction: Qword = 0;
  t_states_prev_instruction: Qword = 0;
  t_states_sound_bit: Qword = screen_tstates_half_scanline;
  SoundFrames: Qword = 0;
  speaker_out: boolean = false;
    data: array[0..7014] of byte;
    sound_bytes: longint = 0;
    prev_sound_bytes: longint = 0;
    nb: byte = 0;
    buffer: array[0..1,0..bufsize] of byte;
    scanlines : integer = 0;
    soundpos_read: longint = 0;
    soundpos_write: longint = 0;
    sound_active : boolean= false;
    sonido_acumulado : longint= 0;



  keyboard: array[0..7] of byte = ($bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf);

procedure spectrum_out(port: word; v: byte);
function spectrum_in(port: word): byte;
procedure init_spectrum;
procedure clear_keyboard;

implementation

procedure clear_keyboard;
var
   j: byte;
begin
  for j := 0 to 7 do
      keyboard[j] := $bf;
end;

procedure init_spectrum;
var
  x: byte;
begin
     border_color := 7;
     clear_keyboard;
end;

procedure spectrum_out(port: word; v: byte);
begin
  if (port and 1) = 0 then begin // ULA port 0xfe
     border_color := v and $7;
     if (v and %00010000) <> 0 then
     begin
        speaker_out := true;
     end else begin
       speaker_out := false;
     end;
     //else
     //  NoSound;
  end else begin                 // other write ports
  end;
end;

function spectrum_in(port: word): byte;
var
  hport, lport, v: byte;
begin
  if mem[sp]=$79 then
     a := a;
  v := $ff;
  hport := port >> 8;
  lport := port and $ff;
  if (port and 1) = 0 then begin // ULA port 0xfe
     if (hport and %00000001) = 0 then
        v := v and Keyboard[0]; // SHIFT Z X C V
     if (hport and %00000010) = 0 then
        v := v and Keyboard[1]; // A S D F G
     if (hport and %00000100) = 0 then
        v := v and Keyboard[2]; // Q W E R T
     if (hport and %00001000) = 0 then
        v := v and Keyboard[3]; // 1 2 3 4 5
     if (hport and %00010000) = 0 then
        v := v and Keyboard[4]; // 0 9 8 7 6
     if (hport and %00100000) = 0 then
        v := v and Keyboard[5]; // P O I U Y
     if (hport and %01000000) = 0 then
        v := v and Keyboard[6]; // ENTER L K J H
     if (hport and %10000000) = 0 then
        v := v and Keyboard[7]; // SPACE SYM M N B
     if (Keyboard[7] and 1 = 0) then
       a := a;
  end else begin                 // other write ports
  end;
  spectrum_in := v;
end;

end.

