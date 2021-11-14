unit cassette;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Z80Globals;

const
  PILOT_TONE_PULSE_WIDTH = 2168;
  BIT0_PULSE_WIDTH = 855;
  BIT1_PULSE_WIDTH = 1710;
  SYNC1_PULSE_WIDTH = 637;
  SYNC2_PULSE_WIDTH = 735;

  ftTAP = 0;
  ftTZX = 1;

  bfNONE   = 0;
  bfPILOT  = 1;
  bfSYNC   = 2;
  bfDATA   = 3;
  bfPAUSE  = 4;

  tone_none        = 0;
  tone_pilot_1     = 1;
  tone_pilot_2     = 2;
  tone_sync        = 3;
  tone_1           = 4;
  tone_0           = 5;
  tone_pause_1000  = 6;

procedure handle_load_sound(var block: word);
procedure start_pulse(width_on, width_off: integer);
procedure handle_load_tones;
procedure playtap(filename: string; addr: longint; block: word);
procedure stoptap;

var
  tone_active: byte = tone_none;
  tone_counter: integer = 0;
  load_pulses: integer = 0;
  playing_pulse: boolean = false;
  playing_load_tone: boolean = false;
  pulse_sign: boolean = false;
  load_sound: byte;
  tstates_pulse_ini: QWord = 0;
  pulse_width_on: integer = 2168;
  pulse_width_off: integer = 2168;
  pause_ini: Qword = 0;
  playing_tap: boolean = false;
  filetype: byte;
  tap_filename: string;
  tap_block_addr: longint = 0;
  tap_block_num: word = 0;
  block_fase: byte = 0;
  flagbyte: byte = 0;
  data: array [0..65535] of byte;
  byte_counter: word = 0;
  bit_counter: byte = 0;
  data_size: word = 0;
  ear_value: byte = 0;
  stop_signal: boolean = false;

implementation

procedure reset_play;
begin
  tone_active:= tone_none;
  tone_counter:= 0;
  load_pulses:= 0;
  playing_pulse:= false;
  playing_load_tone:= false;
  pulse_sign:= false;
  load_sound:=0;
  tstates_pulse_ini:= 0;
  tap_filename := '';
  tap_block_addr := 0;
  tap_block_num := 1;
  block_fase := 0;
  data_size := 0;
  ear_value := 0;
  stop_signal := false;
end;

procedure read_next_block;
var
  F: File;
  bytes_readed: word;
begin
  AssignFile (F, tap_filename);
  try
    Reset(F,1);
    Seek(F,tap_block_addr);
    BlockRead(F, data_size, sizeof(data_size),bytes_readed);
    BlockRead(F, data, data_size,bytes_readed);
    flagbyte := data[0];
    inc(tap_block_addr,data_size+2);
    close(F);
    if bytes_readed < data_size then
      stoptap
    else
      inc(tap_block_num);
  except
    stoptap;
  end;
end;

procedure start_pulse(width_on, width_off: integer);
begin
  playing_pulse := true;
  pulse_width_on := width_on;
  pulse_width_off := width_off;
end;

procedure handle_load_sound(var block: word);
var
  width: integer;
begin
  block := tap_block_num;
  if tstates_pulse_ini = 0 then tstates_pulse_ini := t_states;
  if pulse_sign then
    width := pulse_width_on
  else
    width := pulse_width_off;
  if (t_states - tstates_pulse_ini) > width then
  begin
    if pulse_sign then
    begin
      load_sound := 8;
      ear_value := %00000000;
    end else
    begin
      load_sound := 0;
      ear_value := %01000000;
    end;
    if playing_pulse then
       pulse_sign := not pulse_sign;
    if playing_pulse and not pulse_sign then
       playing_pulse := false;
    tstates_pulse_ini := tstates_pulse_ini + width;
  end;
  handle_load_tones;
end;

procedure next_pulse(pulse_on_width, pulse_off_width: integer; num_pulses: integer);
begin
  if load_pulses < num_pulses then begin
     start_pulse(pulse_on_width,pulse_off_width);
  end else begin
    playing_pulse := false;
    tone_active := tone_none;
  end;
  inc(load_pulses,2);
end;

procedure next_pulse(pulse_width: integer; num_pulses: integer);
begin
  next_pulse(pulse_width, pulse_width, num_pulses);
end;

procedure next_tone;
var
  bit: byte;
begin
  if filetype = ftTAP then
  begin
    case (block_fase) of
      bfNONE:
      begin
        block_fase := bfPILOT;
        if flagbyte < 128 then
          tone_active := tone_pilot_1
        else
          tone_active := tone_pilot_2;
      end;
      bfPILOT:
      begin
        block_fase := bfSYNC;
        tone_active := tone_sync;
        byte_counter := 0;
        bit_counter := 7;    // MSb first
      end;
      bfSYNC:
      begin
        block_fase := bfDATA;
        tone_active := tone_none;
      end;
      bfDATA:
      begin
        if byte_counter < data_size then
        begin
          bit := (data[byte_counter] >> bit_counter) and 1;
          if bit = 0 then
             tone_active := tone_0
          else
            tone_active := tone_1;
          if bit_counter = 0 then
          begin
            inc(byte_counter);
            bit_counter := 7;
          end else dec(bit_counter);
        end else begin
          block_fase := bfPAUSE;
          tone_active := tone_pause_1000;
          pause_ini := t_states;
        end;
      end;
      bfPAUSE:
      begin
        block_fase := bfNONE;
        read_next_block;
      end;
    end;
    load_pulses := 0;
  end else begin
    if tone_counter = 0 then
    begin
      tone_active := tone_pilot_1;
    end else if tone_counter = 100 then begin
      tone_active := tone_pause_1000;
      pause_ini := t_states;
    end else if tone_counter = 101 then
    begin
      tone_active := tone_pilot_2;
    end else begin
      tone_active := random(2)+tone_1;
    end;
    load_pulses := 0;
    inc(tone_counter);
  end;
end;

function tstates_to_ms(ts: qword): integer;
begin
  tstates_to_ms := ts div 3500;
end;

procedure wait_pause(maxtime: integer);
begin
  if tstates_to_ms(t_states-pause_ini) >= maxtime then
    tone_active := tone_none;
end;

procedure handle_load_tones;
begin
  if not playing_pulse and playing_tap then
  begin
    case tone_active of
      tone_none: next_tone;
      tone_pause_1000: wait_pause(1000);
      tone_sync: next_pulse(SYNC2_PULSE_WIDTH,SYNC1_PULSE_WIDTH,2);
      tone_pilot_2: next_pulse(PILOT_TONE_PULSE_WIDTH,3223);
      tone_pilot_1: next_pulse(PILOT_TONE_PULSE_WIDTH,8063);
      tone_0: next_pulse(BIT0_PULSE_WIDTH,2);
      tone_1: next_pulse(BIT1_PULSE_WIDTH,2);
    end;
  end;
end;

procedure playtap(filename: string; addr: longint; block: word);
begin
  tap_filename := filename;
  playing_tap := true;
  tap_block_addr := addr;
  tap_block_num := block;
  read_next_block;
end;

procedure stoptap;
begin
  playing_tap := false;
  reset_play;
  stop_signal := true;
end;

begin
  reset_play;
end.

