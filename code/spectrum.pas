unit spectrum;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,CRT,Z80Globals,hardware,Global;

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
  scanline_testados = 208; //208;// zesarux=224//208; //screen_testados_total div 334;//312;
  screen_tstates_half_scanline = scanline_testados;

  MAX_TAPE_BLOCKS = 99;

type
  TTapeBlockInfo = record
    Filepos: longint;
    Size: word;
    Flag: byte;
  end;


  TTapeInfo = array[1..MAX_TAPE_BLOCKS] of TTapeBlockInfo;

var
  Tape_info: TTapeInfo;
//  Tape_info_bak: TTapeInfo;
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
  disk_motor: boolean = false;
  printer_strobe: boolean = false;
  screen_page: byte = 5;

  last_out_7ffd : byte = 0;
  last_out_1ffd : byte = 0;

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
     screen_page := Mem_banks[1];
end;

procedure spectrum_out(port: word; v: byte);
var
  pagging_mode, special_mode: byte;
begin
  if (port and 1) = 0 then begin // ULA port 0xfe
     border_color := v and $7;
     if (v and %00010000) <> 0 then
     begin
        speaker_out := true;
     end else begin
       speaker_out := false;
     end;
  end;
  if not disable_pagging then
  begin
    // port 7ffd spectrum 128 and +2 gray
    if ((options.machine = Spectrum128) or (options.machine = Spectrum_plus2))
    and ((port and %1000000000000010) = 0) then
    begin
      last_out_7ffd := v;
       //if (v and %1000) = 0 then
       //   Mem_banks[1] := SCREENPAGE
       //else
       //  Mem_banks[1] := SHADOWPAGE;
      if (v and %1000) = 0 then
         screen_page := SCREENPAGE
      else
         screen_page := SHADOWPAGE;
      Mem_banks[1] := 5;
       if (v and %10000) = 0 then
          Mem_banks[0] := ROMPAGE0
       else
         Mem_banks[0] := ROMPAGE1;
       disable_pagging := (v and %100000) = 1;

       Mem_banks[3] := v and %111;
    end;
    // port 7ffd spectrum +2a/+3
    if ((options.machine = Spectrum_plus2a) or (options.machine = Spectrum_plus3))
    and ((port and %1100000000000010) = %0100000000000000) then
    begin
       last_out_7ffd := v;
       if (v and %1000) = 0 then
          screen_page := SCREENPAGE
       else
          screen_page := SHADOWPAGE;
       Mem_banks[1] := 5;
       rom_bank := (rom_bank and %10) or ((v and %10000)>>4);
       disable_pagging := (v and %100000) = 1;

       Mem_banks[3] := v and %111;
       select_rom;
    end;
    // port 1ffd spectrum +2a/+3
    if ((options.machine = Spectrum_plus2a) or (options.machine = Spectrum_plus3))
    and ((port and %1111000000000010) = %0001000000000000) then
    begin
       last_out_1ffd := v;
       pagging_mode := v and %1;
       if pagging_mode = 0 then
       begin
         rom_bank := (rom_bank and %01) or ((v and %100)>>1);
         disk_motor := (v and %1000) <> 0;
         printer_strobe := (v and %10000) <> 0;
         select_rom;
      end else begin
         special_mode := (v and %110) >> 1;
         case special_mode of
           %00: begin
             Mem_banks[0] := 0;
             Mem_banks[1] := 1;
             Mem_banks[2] := 2;
             Mem_banks[3] := 3;
           end;
           %01: begin
             Mem_banks[0] := 4;
             Mem_banks[1] := 5;
             Mem_banks[2] := 6;
             Mem_banks[3] := 7;
           end;
           %10: begin
             Mem_banks[0] := 4;
             Mem_banks[1] := 5;
             Mem_banks[2] := 6;
             Mem_banks[3] := 3;
           end;
           %11: begin
             Mem_banks[0] := 4;
             Mem_banks[1] := 7;
             Mem_banks[2] := 6;
             Mem_banks[3] := 3;
           end;
         end;
       end;
    end;
  end;
end;

function spectrum_in(port: word): byte;
var
  hport, lport, v: byte;
begin
  if rdmem(sp)=$79 then
     a := a;
  v := $ff;
  hport := port >> 8;
  lport := port and $ff;
  if lport and %11100000 = $00 then       // Kempston joystick
      v := Kempston
  else if (port and 1) = 0 then begin // ULA port 0xfe
     if (hport and %00000001) = 0 then
        v := v and Keyboard[0]; // SHIFT Z X C V
     if (hport and %00000010) = 0 then
        v := v and Keyboard[1]; // A S D F G
     if (hport and %00000100) = 0 then
        v := v and Keyboard[2]; // Q W E R T
     if (hport and %00001000) = 0 then
     begin
        v := v and Keyboard[3]; // 1 2 3 4 5
        v := v and SinclairLeft;
     end;
     if (hport and %00010000) = 0 then
     begin
        v := v and Keyboard[4]; // 0 9 8 7 6
        v := v and SinclairRight;
     end;
     if (hport and %00100000) = 0 then
        v := v and Keyboard[5]; // P O I U Y
     if (hport and %01000000) = 0 then
        v := v and Keyboard[6]; // ENTER L K J H
     if (hport and %10000000) = 0 then
        v := v and Keyboard[7]; // SPACE SYM M N B
  end else begin                   // other write ports
    v := $ff;
  end;
  spectrum_in := v;
end;

end.

