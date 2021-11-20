unit cassette;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Z80Globals,Global;

const
  PILOT_TONE_PULSE_WIDTH = 2168;
  BIT0_PULSE_WIDTH = 855;
  BIT1_PULSE_WIDTH = 1710;
  SYNC1_PULSE_WIDTH = 637;
  SYNC2_PULSE_WIDTH = 735;
  PILOT2_PULSES = 3223;
  PILOT1_PULSES = 8063;
  MAX_TAPE_BLOCKS = 99;


  ftTAP = 0;
  ftTZX = 1;

  bfNONE   = 0;
  bfPILOT  = 1;
  bfSYNC   = 2;
  bfDATA   = 3;
  bfPAUSE  = 4;
  bfPULSES = 5;

  tone_none        = 0;
  tone_pilot       = 1;
  tone_sync        = 2;
  tone_1           = 3;
  tone_0           = 4;
  tone_pause       = 5;
  tone_pulse_sequence = 6;

procedure handle_load_sound(var block: word);
procedure start_pulse(width_on, width_off: integer);
procedure handle_load_tones;
procedure playtap(filename: string; addr: longint; block: word);
procedure stoptap;

type
  HW_type = record
    machine_type: byte;
    hardware_id: byte;
    hardware_info: byte;
  end;
  TTapeBlockInfo = record
    Filepos: longint;
    Size: word;
    Flag: byte;
  end;

  Tselect_option = record
    offset: word;
    text: string[30];
  end;

  TTapeInfo = array[1..MAX_TAPE_BLOCKS] of TTapeBlockInfo;

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
  data: array [0..128*1024] of byte;
  byte_counter: longint = 0;
  bit_counter: byte = 0;
  data_size: longint = 0;
  ear_value: byte = 0;
  stop_signal: boolean = false;
  block_ID: byte = 0;
  pause_len: word = 1000;
  pilot_pulse_len: word;
  SYNC1_len: word;
  SYNC2_len: word;
  BIT0_len: word;
  BIT1_len: word;
  PILOT_pulses: word;
  bits_in_last_byte: byte = 8;
  data_size3: array[0..2] of byte;
  pulse_number: byte;
  pulses_len: array[0..255] of word;
  LoopBegin : longint= 0;
  LoopBegin_blocknum: word = 0;
  loop_counter: word = 0;
  call_counter: word = 0;
  num_machines: byte;
  machine: HW_type;
  Tape_info: TTapeInfo;
  call_blocks: array[0..65535] of int16;
  call_block: int16;
  num_calls: word = 0;
  return_addr : longint= 0;
  return_blocknum: word = 0;
  Infolen: QWord = 0;
  block_len: Qword = 0;
  Blocklen: word;
  num_options: byte;
  option: word = $ffff;
  select_option: Tselect_option;
  select_options: array[0..255] of Tselect_option;
  show_selection_menu: boolean = true;
  show_time: byte;

implementation

procedure reset_play;
begin
  tone_active:= tone_none;
  tone_counter:= 0;
  load_pulses:= 0;
  playing_pulse:= false;
  playing_load_tone:= false;
  //pulse_sign:= false;
  pulse_sign:= true;
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
  Text: String;
  size: word;
  //nlines: byte;
  nn: byte;
  jmp_addr: int16;
begin
  AssignFile (F, tap_filename);
  try
    Reset(F,1);
    Seek(F,tap_block_addr);
    if filetype = ftTAP then
    begin
      BlockRead(F, size, sizeof(size),bytes_readed);
      data_size := size;
      BlockRead(F, data, size,bytes_readed);
      pilot_pulse_len := PILOT_TONE_PULSE_WIDTH;
      SYNC1_len := SYNC1_PULSE_WIDTH;
      SYNC2_len := SYNC2_PULSE_WIDTH;
      BIT0_len:= BIT0_PULSE_WIDTH;
      BIT1_len:= BIT1_PULSE_WIDTH;
      bits_in_last_byte:= 8;
      flagbyte := data[0];
      if flagbyte < 128 then
        PILOT_pulses := PILOT1_PULSES
      else
        PILOT_pulses := PILOT2_PULSES;
      inc(tap_block_addr,data_size+2);
      close(F);
      if bytes_readed < data_size then
        stoptap;
    end else begin
      block_fase := 0;
      BlockRead(F, block_ID, sizeof(block_ID),bytes_readed);
      if bytes_readed < 1 then
        stoptap;
      inc(tap_block_addr,bytes_readed);
      case block_ID of
        $10: // standard speed data block
        begin
          bits_in_last_byte := 8;
          BlockRead(F, pause_len, sizeof(pause_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, size, sizeof(size),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          data_size := size;
          BlockRead(F, data, data_size,bytes_readed);
          inc(tap_block_addr,bytes_readed);
          pilot_pulse_len := PILOT_TONE_PULSE_WIDTH;
          SYNC1_len := SYNC1_PULSE_WIDTH;
          SYNC2_len := SYNC2_PULSE_WIDTH;
          BIT0_len:= BIT0_PULSE_WIDTH;
          BIT1_len:= BIT1_PULSE_WIDTH;
          PILOT_pulses := PILOT1_PULSES;
          bits_in_last_byte:= 8;
          flagbyte := data[0];
          if bytes_readed < data_size then
            stoptap;
        end;
        $11: // Turbo Speed Data Block
        begin
          BlockRead(F, pilot_pulse_len, sizeof(pilot_pulse_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, SYNC1_len, sizeof(SYNC1_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, SYNC2_len, sizeof(SYNC2_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, BIT0_len, sizeof(BIT0_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, BIT1_len, sizeof(BIT1_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, PILOT_pulses, sizeof(PILOT_pulses),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, bits_in_last_byte, sizeof(bits_in_last_byte),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, pause_len, sizeof(pause_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data_size3, sizeof(data_size3),bytes_readed);
          data_size := data_size3[2]*65536+data_size3[1]*256+data_size3[0];
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data, data_size,bytes_readed);
          inc(tap_block_addr,bytes_readed);
          flagbyte := data[0];
          if bytes_readed < data_size then
            stoptap;
        end;
        $12: // Pure Tone
        begin
          BlockRead(F, pilot_pulse_len, sizeof(pilot_pulse_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, PILOT_pulses, sizeof(PILOT_pulses),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          if bytes_readed < sizeof(PILOT_pulses) then
            stoptap;
        end;
        $13: // Pulse sequence
        begin
          BlockRead(F, pulse_number, sizeof(pulse_number),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          for nn := 0 to pulse_number-1 do
          begin
            BlockRead(F, pulses_len[nn], sizeof(pulses_len[nn]),bytes_readed);
            inc(tap_block_addr,bytes_readed);
          end;
          if bytes_readed < sizeof(PILOT_pulses) then
            stoptap;
        end;
        $14: // Pure Data Block
        begin
          BlockRead(F, BIT0_len, sizeof(BIT0_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, BIT1_len, sizeof(BIT1_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, bits_in_last_byte, sizeof(bits_in_last_byte),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, pause_len, sizeof(pause_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data_size3, sizeof(data_size3),bytes_readed);
          data_size := data_size3[2]*65536+data_size3[1]*256+data_size3[0];
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data, data_size,bytes_readed);
          inc(tap_block_addr,bytes_readed);
          flagbyte := data[0];
          byte_counter := 0;
          if bytes_readed < data_size then
            stoptap;
        end;
        $20: // Pause (silence) or 'Stop the Tape' command
        begin
          BlockRead(F, pause_len, sizeof(pause_len),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          block_fase := bfNONE;
          if bytes_readed < sizeof(pause_len) then
            stoptap;
        end;
        $21, // Group start
        $30: // Text description
        begin
          BlockRead(F, data[0], sizeof(byte),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data[1], data[0],bytes_readed);
          inc(tap_block_addr,bytes_readed);
          if bytes_readed < data[0] then
            stoptap;
        end;
        $22: // Group end
        begin
        end;
        $23: // Jump to block
        begin
          BlockRead(F, jmp_addr, sizeof(jmp_addr),bytes_readed);
          inc(tap_block_num,jmp_addr-1);
          tap_block_addr := Tape_info[tap_block_num+1].FilePos;
        end;
        $24: // Loop start
        begin
          BlockRead(F, loop_counter, sizeof(loop_counter),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          LoopBegin := tap_block_addr;
          LoopBegin_blocknum := tap_block_num;
        end;
        $25: // Loop end
        begin
          dec(loop_counter);
          if loop_counter > 0 then
          begin
            tap_block_addr := LoopBegin;
            tap_block_num := LoopBegin_blocknum;
          end;
        end;
        $26: // Call sequence
        begin
          BlockRead(F, num_calls, sizeof(num_calls),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          for nn := 0 to num_calls-1 do
          begin
            BlockRead(F, call_block, sizeof(call_block),bytes_readed);
            call_blocks[nn] := call_block;
            inc(tap_block_addr,bytes_readed);
          end;
          return_addr := tap_block_addr;
          return_blocknum := tap_block_num;
          tap_block_num := tap_block_num+call_blocks[0]-1;
          tap_block_addr := Tape_info[tap_block_num+1].FilePos;
          call_counter := 0;
        end;
        $27: // Return from sequence
        begin
          inc(call_counter);
          if call_counter = num_calls then
          begin
            tap_block_addr := return_addr;
            tap_block_num := return_blocknum;
          end else begin
            tap_block_num := tap_block_num+call_blocks[call_counter];
            tap_block_addr := Tape_info[tap_block_num].FilePos;
          end;
        end;
        $28: // Select block
        begin
          BlockRead(F, Blocklen, sizeof(Blocklen),tap_block_addr);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, num_options, sizeof(num_options),tap_block_addr);
          inc(tap_block_addr,bytes_readed);
          for nn := 0 to num_options-1 do
          begin
            BlockRead(F, select_option.offset,2,tap_block_addr);
            inc(tap_block_addr,bytes_readed);
            BlockRead(F, select_option.text[0],1,tap_block_addr);
            inc(tap_block_addr,bytes_readed);
            BlockRead(F, select_option.text[1],byte(select_option.text[0]),tap_block_addr);
            inc(tap_block_addr,bytes_readed);
          end;
          show_selection_menu := true;
        end;
        $2A: // Stop the tape if in 48K mode
        begin
          BlockRead(F, block_len, 4,bytes_readed);
          inc(tap_block_addr,bytes_readed);
          if is_48k_machine then
          begin
            stoptap;
            inc(tap_block_num);
          end;
        end;
        $31: // Message block
        begin
          blockread(f,show_time,1,bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data[0], sizeof(byte),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data[1], data[0],bytes_readed);
          inc(tap_block_addr,bytes_readed);
          if bytes_readed < data[0] then
            stoptap;
        end;
         $32: // Archive info
        begin
          BlockRead(F, size, sizeof(size),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          BlockRead(F, data, size,bytes_readed);
          inc(tap_block_addr,bytes_readed);
          //for nn := 0 to nlines-1 do
          //begin
          //  BlockRead(F, data[0], sizeof(byte),bytes_readed); // Text identification byte
          //  inc($26tap_block_addr,bytes_readed);
          //  BlockRead(F, data[0], sizeof(byte),bytes_readed); // Text lenght
          //  inc(tap_block_addr,bytes_readed);
          //  BlockRead(F, data[1], data[0],bytes_readed);      // Text itself
          //  inc(tap_block_addr,bytes_readed);
          //end;
          if bytes_readed < size then
            stoptap;
        end;
        $33: // Hardware type
        begin
          BlockRead(F, num_machines, sizeof(num_machines),bytes_readed);
          inc(tap_block_addr,bytes_readed);
          for nn := 0 to num_machines-1 do
          begin
            BlockRead(F, machine, sizeof(machine),bytes_readed);
            inc(tap_block_addr,bytes_readed);
          end;
          if bytes_readed < size then
            stoptap;
        end;
        $35: // Custom info
        begin
         BlockRead(F,data, 10,bytes_readed);
         inc(tap_block_addr,bytes_readed);
         BlockRead(F,Infolen, 4,bytes_readed);
         inc(tap_block_addr,bytes_readed);
         BlockRead(F,data,Infolen,bytes_readed);
         if bytes_readed < size then
           stoptap;
        end;
        $5A: // "Glue" block
        begin
          BlockRead(F, data, 9,bytes_readed);
          inc(tap_block_addr,bytes_readed);
         end
        else begin  // unknown blocks are treated as extension blocks
         BlockRead(F, block_len, 4,bytes_readed);
         inc(tap_block_addr,bytes_readed);
         BlockRead(F, data, block_len,bytes_readed);
         inc(tap_block_addr,bytes_readed);
        end;
      end;
      close(F);
    end;
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
    if playing_pulse and pulse_sign then
       playing_pulse := false;
    tstates_pulse_ini := tstates_pulse_ini + width;
  end;
  handle_load_tones;
end;

procedure next_pulse(pulse_on_width, pulse_off_width: integer; num_pulses: integer);
begin
  if load_pulses < num_pulses then begin
     start_pulse(pulse_on_width,pulse_off_width);
     inc(load_pulses,2);
  end else begin
    playing_pulse := false;
    tone_active := tone_none;
  end;
end;

procedure next_pulse(pulse_width: integer; num_pulses: integer);
begin
  next_pulse(pulse_width, pulse_width, num_pulses);
end;

procedure start_sync_tone;
begin
  block_fase := bfSYNC;
  tone_active := tone_sync;
  byte_counter := 0;
  bit_counter := 7;    // MSb first
end;

procedure start_pilot_tone;
begin
  block_fase := bfPILOT;
  tone_active := tone_pilot;
  //PILOT_pulses := pulses;
  //pilot_pulse_len := pulse_len;
end;

procedure next_block;
begin
  block_fase := bfNONE;
  tone_active := tone_none;
  inc(tap_block_num);
  read_next_block;
end;

procedure handle_DATA_block;
var
  bit,min_bit: byte;
begin
  if byte_counter < data_size then
  begin
    bit := (data[byte_counter] >> bit_counter) and 1;
    if bit = 0 then
       tone_active := tone_0
    else
      tone_active := tone_1;
    if (byte_counter = data_size-1) then
      min_bit := 8-bits_in_last_byte
    else
      min_bit := 0;
    if (bit_counter = min_bit) then
    begin
      inc(byte_counter);
      bit_counter := 7;
    end else dec(bit_counter);
  end else begin
    block_fase := bfPAUSE;
    tone_active := tone_pause;
    pause_ini := t_states;
  end;
end;

procedure next_tone_tap;
begin
  case (block_fase) of
    bfNONE: start_pilot_tone;
    bfPILOT: start_sync_tone;
    bfSYNC:
    begin
      block_fase := bfDATA;
      tone_active := tone_none;
    end;
    bfDATA:  handle_DATA_block;
    bfPAUSE: next_block;
  end;
  load_pulses := 0;
end;

procedure next_tone_pilot;
begin
  if block_fase=bfNONE then
    start_pilot_tone
  else
    next_block;
  load_pulses := 0;
end;

procedure next_tone_pause;
begin
  if block_fase=bfNONE then
  begin
    block_fase := bfPAUSE;
    tone_active := tone_pause;
    pause_ini := t_states;
  end else
    next_block;
  load_pulses := 0;
end;

procedure next_tone_none;
begin
  block_fase := bfNONE;
  inc(tap_block_num);
  read_next_block;
end;

procedure next_tone_pulse_sequence;
begin
  case block_fase of
    bfNONE:
    begin
      load_pulses := 0;
      tone_active := tone_pulse_sequence;
      block_fase := bfPULSES;
    end;
    bfPULSES:
      if (load_pulses >= pulse_number) then
      begin
        block_fase := bfNONE;
        inc(tap_block_num);
        read_next_block;
      end;
  end;
end;

procedure next_tone_pure_datablock;
begin
  case block_fase of
    bfNONE:
    begin
      block_fase := bfDATA;
      tone_active := tone_none;
    end;
    bfDATA:  handle_DATA_block;
    bfPAUSE: next_block;
  end;
  load_pulses := 0;
end;

procedure next_tone_end_block;
begin
  inc(tap_block_num);
  read_next_block;
end;

procedure next_tone_select;
begin
  if option <> $ffff then
  begin
    tap_block_num += select_options[option].offset;
    tap_block_addr := tape_info[tap_block_num].Filepos;
    read_next_block;
    option := $ffff;
  end;
end;

procedure next_tone;
begin
  if filetype = ftTAP then
  begin
    next_tone_tap;
  end else begin
    case block_ID of
      $10: next_tone_tap;
      $11: next_tone_tap;
      $12: next_tone_pilot;
      $13: next_tone_pulse_sequence;
      $14: next_tone_pure_datablock;
      $20: next_tone_pause;
      $22: next_tone_end_block;
      $21,
      $23,
      $24,
      $25,
      $26,
      $27,
      $2A,
      $30,
      $31,
      $32,
      $33,
      $35,
      $5A: next_tone_none;
      $28: next_tone_select;
      else next_tone_none;
    end;

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
      tone_pause: wait_pause(pause_len);
      tone_sync: next_pulse(SYNC2_len,SYNC1_len,2);
      //tone_pilot_2: next_pulse(PILOT_TONE_PULSE_WIDTH,PILOT2_PULSES);
      tone_pilot: next_pulse(PILOT_pulse_len,pilot_pulses);
      tone_0: next_pulse(BIT0_len,2);
      tone_1: next_pulse(BIT1_len,2);
      tone_pulse_sequence: next_pulse(pulses_len[load_pulses+1],pulses_len[load_pulses],pulse_number);
    end;
  end;
end;

procedure playtap(filename: string; addr: longint; block: word);
var
  ext: String;
begin
  tap_filename := filename;
  ext := Upcase(extractFileExt(filename));
  playing_tap := true;
  tap_block_addr := addr;
  tap_block_num := block;
  if ext = '.TAP' then
  begin
     filetype := ftTAP;
     pause_len := 1000;
  end else begin
    filetype := ftTZX;
    //tap_block_addr := $0a;
  end;
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

