unit spectrum;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,CRT,Z80Globals,hardware,Global,acs_misc;

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
  MAXFREQ = 16500;

type
  TTapeBlockInfo = record
    Filepos: longint;
    Size: word;
    Flag: byte;
  end;


  TTapeInfo = array[1..MAX_TAPE_BLOCKS] of TTapeBlockInfo;

  TAYEnvelope = record
    //freq: integer;
    enabled: boolean;
    counter: integer;
    period: integer;
    typ: byte;
    signal: boolean;
    starting: boolean;
    value: byte;
    incv: integer;
  end;

  TAYChannel = record
    counter: integer;
    rng: longint;
    noise_period: integer;
    noise_enabled: boolean;
    noise_level: boolean;
    sound_level: byte;
    signal: boolean;
    enabled,paused: boolean;
    env: TAYEnvelope;
    freq: integer;          // dy
    d: integer;             // d
    d1,d2: integer;
    data: array[0..7014] of byte;
    volume: byte;
    envelope_volume: boolean;
    buffer: array[0..bufsize] of byte;
  end;

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
  volume_speaker: byte = 8;
  speaker_out: boolean = false;
  speaker_data: array[0..7014] of byte;
  AYCHA, AYCHB, AYCHC: TAYChannel;
  speaker_buffer: array[0..bufsize] of byte;
  sound_bytes: longint = 0;
  prev_sound_bytes: longint = 0;
  //nb: byte = 0;
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
  last_out_fffd : byte = 0;
  last_out_bffd : byte = 0;
  last_in_fffd  : byte = 0;
  last_in_fe    : byte = 0;
  last_out_fe   : byte = 0;

  keyboard: array[0..7] of byte = ($bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf);

procedure spectrum_out(port: word; v: byte);
function spectrum_in(port: word): byte;
procedure init_spectrum;
procedure clear_keyboard;
procedure Init_AY_Channel(var AYCH: TAYChannel);
procedure CONFIG_AY_Channel(var AYCH: TAYChannel;
                                tone_freq: integer; volume: byte; tone_enabled: boolean;
                                noise_freq: integer; noise_enabled: boolean;
                                env_freq:integer; env_type: byte; env_enabled: boolean);
procedure RUN_AY_Channel(var AYCH: TAYChannel);

implementation

procedure Init_AY_Channel(var AYCH: TAYChannel);
begin
  AYCH.enabled := false;
  AYCH.volume := 8;
  AYCH.paused := false;
  AYCH.freq := MAXFREQ;
  AYCH.rng := 1;
  AYCH.noise_period := 0;
  AYCH.noise_enabled := false;
  AYCH.counter := 0;
  AYCH.noise_level := false;
  AYCH.env.period:=0;
  AYCH.env.enabled:= false;
  AYCH.env.starting := true;
end;

procedure CONFIG_AY_Channel(var AYCH: TAYChannel;
                                tone_freq: integer; volume: byte; tone_enabled: boolean;
                                noise_freq: integer; noise_enabled: boolean;
                                env_freq:integer; env_type: byte; env_enabled: boolean);
var
  prev_env_period, prev_noise_period: integer;
begin
  if (AYCH.freq <> tone_freq) and tone_enabled then
  begin
    AYCH.d := tone_freq*2*2-MAXFREQ;
    AYCH.d2 := (tone_freq*2-MAXFREQ)*2;
    AYCH.d1 := tone_freq*2*2;
  end;


  AYCH.enabled := tone_enabled;
  AYCH.noise_enabled := noise_enabled;
  prev_noise_period := AYCH.noise_period;
  if noise_freq > 0 then
     AYCH.noise_period := MAXFREQ div noise_freq
  else
     AYCH.noise_period := 0;
  if (AYCH.noise_period <> prev_noise_period) and noise_enabled then
  begin
    AYCH.counter := 0;
  end;

  AYCH.freq:= tone_freq;
  AYCH.volume:= volume and %1111;
  AYCH.envelope_volume:= (AYCH.volume and %10000) <> 0;
  AYCH.sound_level := 0;

  prev_env_period := AYCH.env.period;
  AYCH.env.enabled:=env_enabled;
  if env_freq > 0 then
     AYCH.env.period := (MAXFREQ div env_freq)*4
  else
     AYCH.env.period := 0;

  AYCH.env.signal := false;
  AYCH.env.starting := true;
  AYCH.env.counter := 0;
  if (AYCH.env.period <> prev_env_period) and env_enabled then
  begin
  end;

  AYCH.env.typ:=env_type;
  AYCH.env.counter:=0;
  if AYCH.env.period > 0 then
     AYCH.env.incv := (AYCH.env.period div 16)
  else
     AYCH.env.incv := 0;
end;

procedure RUN_AY_Channel(var AYCH: TAYChannel);
var
  vv: byte;
begin
  with AYCH do
  begin
    sound_level := 0; //128;
    if enabled and not paused then
    begin
       if d < 0 then
           d += d1
       else begin
          d += d2;
          signal := not signal;
       end;
       if signal then
          sound_level := {128+}1//AYCH.volume*8
       else
          sound_level := 0;//128;
    end;

    vv := AYCH.volume;

    // ENVELOPE
    // 0      \__________     single decay then off
    //
    // 4      /|_________     single attack then off
    //
    // 8      \|\|\|\|\|\     repeated decay
    //
    // 9      \__________     single decay then off
    //
    //10      \/\/\/\/\/\     repeated decay-attack
    //          _________
    //11      \|              single decay then hold
    //
    //12      /|/|/|/|/|/     repeated attack
    //         __________
    //13      /               single attack then hold
    //
    //14      /\/\/\/\/\/     repeated attack-decay
    //
    //15      /|_________     single attack then off
    if env.enabled and not paused then
    begin
      inc(env.counter);
      if not env.signal then
      begin
        case env.typ of
           0,9:
             if env.starting then
               env.value := 15-(16*env.counter div AYCH.env.period)
             else
               env.value := 0; //128;
           11:
             if env.starting then
               env.value := 15-(16*env.counter div AYCH.env.period)
             else
               env.value := {128+}64;
           4,15:
              if env.starting then
                 env.value := (16*env.counter div AYCH.env.period)
              else
                 env.value := 0;//128;
           13:
              if env.starting then
                 env.value := (16*env.counter div AYCH.env.period)
              else
                 env.value := {128+}64;
           8,10: env.value := 15-(16*env.counter div AYCH.env.period);
           12,14: env.value := (16*env.counter div AYCH.env.period);
        end;
      end else begin
        case env.typ of
           0,4,9,14,15:
             env.value := 0;//128;
           8,10,11,13:
             env.value := {128+}15;
        end;
      end;
      if env.counter >= env.period then
      begin
        env.starting := false;
        env.counter := 0;
        env.signal:= not env.signal;
      end;
      vv := env.value;
    end;

    // NOISE
    inc(counter);
    if (counter >= noise_period) and noise_enabled and not paused then
    begin
      if (((rng + 1) and $02) <> 0) then
         noise_level := not noise_level;
      if ((rng and $01) <> 0) then
         rng := rng xor %100100000000000000;  // $24000
      rng := rng >> 1;
      if noise_level then
         sound_level := {128+}1; //vv*8;
      counter := 0;
    end;
    sound_level := sound_level * vv*4;
  end;
end;

procedure config_AY;
var
  d1,d2,d3,de,f1,f2,f3,nf,ef: word;
begin
  d1 := AY1.R[0]+AY1.R[1]*256;
  d2 := AY1.R[2]+AY1.R[3]*256;
  d3 := AY1.R[4]+AY1.R[5]*256;
  de := AY1.R[11]+AY1.R[12]*256;
  if d1 > 0 then
     f1 := 3500000 div 32 div d1
  else
     f1 := 0;
  if d2 > 0 then
     f2 := 3500000 div 32 div d2
  else
     f2 := 0;
  if d3 > 0 then
     f3 := 3500000 div 32 div d3
  else
     f3 := 0;
  if de > 0 then
     ef := 3500000 div 32 div de
  else
     ef := 0;
  if AY1.R[6] > 0 then
     nf := 3500000 div 32 div AY1.R[6]
  else
     nf := 0;
  CONFIG_AY_Channel(AYCHA,
                          f1,AY1.R[ 8],AY1.R[7] and %001 = 0,
                          nf,AY1.R[7] and %00001000 = 0,
                          ef,AY1.R[13], AY1.R[8] and %00010000 <> 0);
  CONFIG_AY_Channel(AYCHB,
                          f2,AY1.R[ 9],AY1.R[7] and %010 = 0,
                          nf,AY1.R[7] and %00010000 = 0,
                          ef,AY1.R[13], AY1.R[9] and %00010000 <> 0);
  CONFIG_AY_Channel(AYCHC,
                          f3,AY1.R[10],AY1.R[7] and %100 = 0,
                          nf,AY1.R[7] and %00100000 = 0,
                          ef,AY1.R[13], AY1.R[10] and %00010000 <> 0);
end;

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
    last_out_fe := v;
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

    // port $fffd AY Select a register 0-14
    if port and %1100000000000010 = %1100000000000000 then
    begin
      last_out_fffd := v;
      AY1.selReg:=v;
    end;
    // port $bffd Write to the selected register
    if port and %1100000000000010 = %1000000000000000 then
    begin
      last_out_bffd := v;
      case AY1.selreg of
       1,3,5,13:
         AY1.R[AY1.selreg]:=v and %1111;
       8,9,10,6:
         AY1.R[AY1.selreg]:=v and %11111;
       else
            AY1.R[AY1.selreg]:=v;
      end;
       config_AY;
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
     last_in_FE := v;
  end else begin                   // other write ports
    v := $ff;
  end;
  // port $fffd AY Read the value of the selected register
  if port and %1100000000000010 = %1100000000000000 then
  begin
     v := AY1.R[AY1.selreg];
     last_in_fffd := v;
  end;
  spectrum_in := v;
end;

end.

