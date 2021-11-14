unit spectrum;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,CRT,Z80Globals,hardware,Global,cassette;

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
  total_screen_lines = alto_borde*2+192;
  t_states_scanline = screen_testados_total div total_screen_lines;

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
    buffer: array[0..spec_buffer_size] of byte;
  end;

var
  bcolor: array[0..total_screen_lines-1] of byte;
  screen_line: word;
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
  speaker_buffer: array[0..spec_buffer_size] of byte;
  sound_bytes: longint = 0;
  prev_sound_bytes: longint = 0;
  //nb: byte = 0;
  scanlines : integer = 0;
  soundpos_read: longint = 0;
  soundpos_write: longint = 0;
  sound_active : boolean= false;
  sonido_acumulado : longint= 0;
  printer_strobe: boolean = false;
  screen_page: byte = 5;
  pagging_mode: byte = 0;
  special_mode: byte = 0;

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
  function decsound: byte;
  begin
    if AYCH.env.period = 0 then
       decsound := 0
    else
        decsound := 15-(16*AYCH.env.counter div AYCH.env.period);
  end;

  function incsound: byte;
  begin
    if AYCH.env.period = 0 then
       incsound := 0
    else
        incsound := (16*AYCH.env.counter div AYCH.env.period)
  end;

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
               env.value := decsound
             else
               env.value := 0; //128;
           11:
             if env.starting then
               env.value := decsound
             else
               env.value := {128+}64;
           4,15:
              if env.starting then
                 env.value := incsound
              else
                 env.value := 0;//128;
           13:
              if env.starting then
                 env.value := incsound
              else
                 env.value := {128+}64;
           8,10: env.value := decsound;
           12,14: env.value := incsound;
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
begin
  border_color := 7;
  clear_keyboard;
  screen_page := Mem_banks[1];
  last_out_7ffd := 0;
  last_out_1ffd := 0;
  last_out_fffd := 0;
  last_out_bffd := 0;
  last_in_fffd  := 0;
  last_in_fe    := 0;
  last_out_fe   := 0;
  printer_strobe:= false;
  membanks_mode0[0] := 0;
  membanks_mode0[1] := 1;
  membanks_mode0[2] := 2;
  membanks_mode0[3] := 3;
  AY1.R[$E] := $bf;
  pagging_mode := 0;
  disable_pagging := false;
end;

procedure spectrum_out(port: word; v: byte);
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
    if is_plus2type_machine
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
       membanks_mode0[0] := Mem_banks[0];
       membanks_mode0[1] := Mem_banks[1];
       membanks_mode0[2] := Mem_banks[2];
       membanks_mode0[3] := Mem_banks[3];
    end;
    // port 7ffd spectrum +2a/+3
    if is_plus3type_machine
    and ((port and %1100000000000010) = %0100000000000000)  then
    begin
       last_out_7ffd := v;
       if (v and %1000) = 0 then
          screen_page := SCREENPAGE
       else
          screen_page := SHADOWPAGE;
       rom_bank := (rom_bank and %10) or ((v and %10000)>>4);
       disable_pagging := (v and %100000) <> 0;

       //if (pagging_mode = 0) then
       //begin
         ///////// asignar los bancos de RAM para modo 0 independiente del modo
         //Mem_banks[3] := v and %111;
         membanks_mode0[3] := v and %111;
         membanks_mode0[1] := 5;
         if (pagging_mode = 0) then
         begin
           Mem_banks[3] := membanks_mode0[3];
           select_rom;
         end;
    end;
    // port 1ffd spectrum +2a/+3
    if is_plus3type_machine
    and ((port and %1111000000000010) = %0001000000000000) then
    begin
      last_out_1ffd := v;
      pagging_mode := v and %1;
      disk_motor_on := (v and %1000) <> 0;
      disk_motor[fdc.US1*2+fdc.US0] := disk_motor_on;
      printer_strobe := (v and %10000) <> 0;
      if pagging_mode = 0 then
      begin
        Mem_banks[0] := membanks_mode0[0];
        Mem_banks[1] := membanks_mode0[1];
        Mem_banks[2] := membanks_mode0[2];
        Mem_banks[3] := membanks_mode0[3];
        rom_bank := (rom_bank and %01) or ((v and %100)>>1);
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

      ///  asignar la ram dependiendo del modo en el que estemos.
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
       14: AY1.R[AY1.selreg]:=v and $bf;
       else
            AY1.R[AY1.selreg]:=v;
      end;
       config_AY;
     end;
  end;
  if is_fdc_machine then
  begin
    // port $3ffd Bytes written to this port are sent to the FDC
    if port and %1111000000000010 = %0011000000000000 then
    begin
      Handle_fdc(v,FROM_OUT);
    end;
  end;
end;

function spectrum_in(port: word): byte;
var
  hport, lport, v: byte;
begin
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
        if v and 1 = 0 then
           a := a;
     end;
     if (hport and %00100000) = 0 then
        v := v and Keyboard[5]; // P O I U Y
     if (hport and %01000000) = 0 then
        v := v and Keyboard[6]; // ENTER L K J H
     if (hport and %10000000) = 0 then
        v := v and Keyboard[7]; // SPACE SYM M N B
     v := v or ear_value;
     last_in_FE := v;
  end else begin                   // other write ports
    if (lport = $ff) and not is_plus3type_machine or
       (((port and %1111000000000011) = %0000000000000001)
               and is_plus3type_machine) then
    begin
      // screen 224 t-states
      // border 128 t-states
      // upper+lower border 12500 t-states
      if (t_states_cur_frame > 12500) {and (t_states_cur_frame < 70000-12500)} then
      begin

        case t_states_cur_frame mod 8 of
             3,5,7: v := random(256); // screen attributes
             2,4,6: v := random(256); // screen data
             else v := $ff;         // border
        end;
      end;
    end else v := $ff;
  end;
  // port $fffd AY Read the value of the selected register
  if port and %1100000000000010 = %1100000000000000 then
  begin
     v := AY1.R[AY1.selreg];
     last_in_fffd := v;
  end;
  // port $2ffd Reading from this port will return the main status register of the uPD765A
  // DB0 FDD 0 Busy
  // DB1 FDD 1 Busy
  // DB2 FDD 2 Busy
  // DB3 FDD 3 Busy
  // DB4 FDC Busy
  // DB5 Execution Mode
  // DB6 Data Input/Output
  // DB7 Request for master
  if is_fdc_machine and is_plus3type_machine then
  begin
    // port $2ffd
    if port and %1111000000000010 = %0010000000000000 then
    begin
      v := fdc.main_reg;
      //if (v and %00010000) <> 0 then operation_pending := false;
    end;
    // port $3ffd reading from this port will read bytes from the FDC
    if port and %1111000000000010 = %0011000000000000 then
    begin
      Handle_fdc(v,FROM_IN);
    end;
  end;
  spectrum_in := v;
end;

begin
  init_spectrum;
end.

