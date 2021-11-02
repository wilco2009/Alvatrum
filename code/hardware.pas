unit hardware;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, LCLType,global;

type
  tAYChip = record
    R: array[0..15] of byte;
    selReg: byte;
  end;
  tfdc_state = (sfdc_command,sfdc_read_params,sfdc_exec,sfdc_results);
  tfdc_command = (
     cfdc_null,
     cfdc_readtrack,
     cfdc_specify,
     cfdc_sensedrive,
     cfdc_writedata,
     cfdc_readdata,
     cfdc_recalibrate,
     cfdc_senseinterrupt,
     cfdc_writedeldata,
     cfdc_sectorid,
     cfdc_readdeldata,
     cfdc_format,
     cfdc_seek,
     cfdc_scanequal,
     cfdc_scanloworequal,
     cfdc_scanhighorequal,
     cfdc_invalid);
  TbufferDsk = Array[0..$FFFFF] of byte; // 1MB
  Tdiskinfo = record
    version: byte;
    Tracks: byte;
    sides: byte;
    track_size:array[0..255] of word;
  end;
  ttrack_block = record
    id: array[0..$0b] of char;
    unused1: array[0..3] of byte;
    track: byte;
    side: byte;
    unused2: array[0..1] of byte;
    sector_size: byte;
    sectors: byte;
    gap_length: byte;
    filler_byte: byte;
  end;

  tsector_block = record
    track: byte;
    side: byte;
    sector_ID: byte;
    sector_size: byte;
    ST1: byte;
    ST2: byte;
    data_len: word;
  end;

  tdrive_pos = record
    side, track, sector: byte;
  end;

procedure setKempston(n: byte);
procedure ResetKempston(n: byte);
procedure setSinclairLeft(n: byte);
procedure ResetSinclairLeft(n: byte);
procedure setSinclairRight(n: byte);
procedure ResetSinclairRight(n: byte);
procedure AssignUserButton(dir: byte; key: word);
function getdircaption(x: byte): string;
function AYMachine: boolean;
procedure Handle_fdc(var v: byte; source: byte);
procedure getdiskinfo(drive: byte);
procedure reset_fdc;
procedure getTrackblock(drive: byte; head: byte; track: byte; var track_block: ttrack_block);
procedure getSectorBlock(drive: byte; head: byte; track: byte; sector: byte; var sector_block: tsector_block);
procedure getSectorData(drive: byte; head: byte; track: byte; sector: byte; var buffer);
procedure putSectorData(drive: byte; head: byte; track: byte; sector: byte; var buffer);
function getdskversionstring(drive: byte): string;
function getdskcreator(drive: byte): string;

const
  FROM_IN    = 0;
  FROM_OUT   = 1;
  FROM_TIMER = 2;

  to_processor = true;
  to_fdc = false;


var
    drive_pos: array[0..3] of tdrive_pos;
    disk_motor: array[0..3] of boolean = (false,false,false,false);
    disk_motor_on: boolean;
    sector_data: array[0..4095] of byte;
    sector_sizes: array[0..5] of integer = (128,256,512,1024,2048,4096);
    bsize_dsk: array[0..1] of longint;
    buffer_dsk: array[0..1] of TbufferDsk;
    disk_info: array[0..1] of Tdiskinfo;
    track_block: ttrack_block;
    sector_block: tsector_block;
    fdc_state: tfdc_state = sfdc_command;
    fdc_command: tfdc_command = cfdc_null;
    operation_pending: boolean = false;
    param_num: byte = 0;
    led_motor_on: array[0..3] of boolean = (false,false,false,false);
    drive_two_sides: array[0..3] of byte = (0,0,0,0);
    drive_protected: array[0..3] of byte = (0,0,0,0);
    drive_not_ready: array[0..3] of byte = (1,1,1,1);
    executed: boolean;
    data_count: word;

    fdc: record
      C,H,R,N,EOT,GPL: byte;
      DTL,ST0,ST1,ST2,D,STP: byte;
      param0,SC,SRT_HUT,HLT_ND,SRT,HUT,HLT,
      ST3,NCN,PCN,SK,MT,MF: byte;
      main_reg: byte;

      IC,SE,EC,NR,HD,US1,US0: byte;
      EN,DE,rOR,ND,NW,MA: byte;
      CM,DD,WC,SH,SN,BC,MD,FT,WP,RY,T0,TS: byte;
    end;

    Kempston: byte = 0;
    SinclairRight: byte = $FF;
    SinclairLeft: byte = $FF;
    user_buttons: tUser_buttons;

    AY1: tAYChip;

implementation

procedure test_ready;
begin
  with fdc do
  begin
    //if ((US1*2+US0)=0) then
    //begin
    //  if driveA_ready then NR := 0
    //  else NR := 1;
    //end else begin
    //  if driveB_ready then NR := 0
    //  else NR := 1;
    //end;
    NR := drive_not_ready[US1*2+US0];
  end;
end;

procedure fdc_composeST0;
begin
  with fdc do
  begin
     test_ready;
     ST0 := (IC << 6) or (SE << 5) or (EC << 4) or
      (NR << 3) or (HD << 2) or (US1 << 1) or (US0);
  end;
end;

procedure fdc_explodeST0;
begin
  with fdc do
  begin
    IC := ST0 >> 6;
    SE := (ST0 >> 5) and 1;
    EC := (ST0 >> 4) and 1;
    NR := (ST0 >> 3) and 1;
    HD := (ST0 >> 2) and 1;
    US1 := (ST0 >> 1) and 1;
    US0 := ST0 and 1;
  end;
end;

procedure fdc_composeST1;
begin
   with fdc do
     ST1 := (EN << 7) or (DE << 5) or (fdc.rOR << 4) or
          (ND << 2) or (NW << 1) or (MA);
end;

procedure fdc_explodeST1;
begin
  with fdc do
  begin
    EN := ST1 >> 7;
    DE := (ST1 >> 5) and 1;
    rOR := (ST1 >> 4) and 1;
    ND := (ST1 >> 2) and 1;
    NW := (ST1 >> 1) and 1;
    MA := ST1 and 1;
  end;
end;

procedure fdc_composeST2;
begin
   with fdc do
     ST2 := (CM << 6) or (DD << 5) or (WC << 4) or
          (SH << 3) or (SN << 2) or (BC << 1) or (MD);
end;

procedure fdc_explodeST2;
begin
  with fdc do
  begin
    CM := (ST2 >> 6) and 1;
    DD := (ST2 >> 5) and 1;
    WC := (ST2 >> 4) and 1;
    SH := (ST2 >> 3) and 1;
    SN := (ST2 >> 2) and 1;
    BC := (ST2 >> 1) and 1;
    MD := ST2 and 1;
  end;
end;

procedure fdc_composeST3;
var
    drive: byte;
begin
   with fdc do
   begin
     drive := (US1 << 1) or (US0);
     RY := (not NR) and 1;
     WP := drive_protected[drive];
     T0 := byte(C=0) and 1;
     TS := drive_two_sides[drive];
     ST3 := (FT << 7) or (WP << 6) or (RY << 5) or (T0 << 4) or
            (TS << 3) or (H << 2) or drive;
   end;
end;

procedure fdc_explodeST3;
begin
  with fdc do
  begin
    CM := (ST3 >> 7) and 1;
    WP := (ST3 >> 6) and 1;
    RY := (ST3 >> 5) and 1;
    T0 := (ST3 >> 4) and 1;
    TS := (ST3 >> 3) and 1;
    HD := (ST3 >> 2) and 1;
    US1 := (ST3 >> 1) and 1;
    US0 := ST3 and 1;
  end;
end;

procedure fdc_compose_status;
begin
   fdc_composeST0;
   fdc_composeST1;
   fdc_composeST2;
   fdc_composeST3;
end;

procedure fdc_explode_status;
begin
   fdc_explodeST0;
   fdc_explodeST1;
   fdc_explodeST2;
   fdc_explodeST3;
end;

procedure reset_fdc;
var
    jj: byte;
begin
  fdc_state:= sfdc_command;
  fdc_command:= cfdc_null;
  operation_pending:= false;
  param_num:= 0;
  disk_motor[0] := false;
  disk_motor[1] := false;
  disk_motor[2] := false;
  disk_motor[3] := false;
  with fdc do
  begin
    C := 0;
    H := 0;
    R := 0;
    N := 0;
    EOT := 0;
    GPL := 0;
    DTL := 0;
    ST0 := 0;
    ST1 := 0;
    ST2 := 0;
    D := 0;
    STP := 0;
    param0 := fdc.MT or fdc.MF or fdc.SK;
    SC := 0;
    SRT_HUT := (fdc.SRT << 4) or fdc.HUT; // SRT+HUT
    HLT_ND := (fdc.HLT << 1) or fdc.ND;   // HLT+ND
    SRT := $08;
    HUT := $07;
    HLT := $07;
    ST3 := 0;
    NCN := 0;
    PCN := 5;
    SK := 0;
    MT := 0;
    MF := 0;
    main_reg := %10000000;
    IC := 0;
    SE := 0;
    EC := 0;
    NR := 0;
    HD := 0;
    US1 := 0;
    US0 := 0;
    EN := 0;
    DE := 0;
    rOR := 0;
    ND := 0;
    NW := 0;
    MA := 0;
    CM := 0;
    DD := 0;
    WC := 0;
    SH := 0;
    SN := 0;
    BC := 0;
    MD := 0;
    FT := 0;
    WP := 0;
    RY := 0;
    T0 := 0;
    TS := 0;
    fdc_compose_status;
  end;
  for jj := 0 to 3 do
      with drive_pos[jj] do
      begin
        sector := 1;
        side := 0;
        track := 0;
      end;
end;

function calcSectorDataSize(size_code: byte): word;
begin
     case size_code of
       0: calcSectorDataSize := 128;
       1: calcSectorDataSize := 256;
       2: calcSectorDataSize := 512;
       3: calcSectorDataSize := 1024;
       4: calcSectorDataSize := 2048;
       5: calcSectorDataSize := 4096;
       6: calcSectorDataSize := 8912;
     end;
end;

procedure getdiskinfo(drive: byte);
var
    jj: byte;
begin
  if buffer_dsk[drive][0] = ord('M') then // old format
  begin
    disk_info[drive].version := 0;
    disk_info[drive].Tracks := buffer_dsk[drive][$30];
    disk_info[drive].sides := buffer_dsk[drive][$31];
    for jj := 0 to disk_info[drive].Tracks*disk_info[drive].sides do
    begin
       disk_info[drive].track_size[jj] := buffer_dsk[drive][$32+$33*$FF];
    end;
  end else if buffer_dsk[drive][0] = ord('E') then // Extended format
  begin
    disk_info[drive].version := 1;
    disk_info[drive].Tracks := buffer_dsk[drive][$30];
    disk_info[drive].sides := buffer_dsk[drive][$31];
    for jj := 0 to (disk_info[drive].Tracks*disk_info[drive].sides)-1 do
    begin
       disk_info[drive].track_size[jj] := buffer_dsk[drive][$34+jj]*256;
    end;
  end;
end;

function getTrackoffset(drive: byte; head: byte; track: byte): longint;
var
    pos: longint;
    jj: integer;
begin
  pos := $100;
  if track > 0 then
    for jj := 0 to (track*disk_info[drive].sides)+head-1 do
      pos+= disk_info[drive].track_size[jj];
  getTrackoffset := pos;
end;

procedure getTrackblock(drive: byte; head: byte; track: byte; var track_block: ttrack_block);
var
    pos: longint;
begin
  pos := getTrackoffset(drive,head,track);
  move(buffer_dsk[drive][pos], track_block,sizeof(track_block));
end;

function getSectorOffset(drive: byte; head: byte; track: byte; sector: byte): longint;
var
    pos: longint;
    jj: word;
    track_block: TTrack_block;
begin
  getTrackBlock(drive,head,track,track_block);
  pos := $100;
  if track > 0 then
    for jj := 0 to (track*disk_info[drive].sides)+head-1 do
      pos+= disk_info[drive].track_size[jj];
  pos+=$18+(sector-1)*8;
  getSectorOffset := pos;
end;
function getDataOffset(drive: byte; head: byte; track: byte; sector: byte): longint;
var
    track_block: TTrack_block;
    datasize: word;
begin
  getTrackBlock(drive,head,track,track_block);
  datasize := calcSectorDataSize(track_block.sector_size);
  getDataOffset := getTrackOffset(drive,head,track)+$100+(sector-1)*datasize;
end;

procedure getSectorBlock(drive: byte; head: byte; track: byte; sector: byte; var sector_block: tsector_block);
var
    pos: longint;
begin
  pos := getSectorOffset(drive,head,track,sector);
  move(buffer_dsk[drive][pos], sector_block,sizeof(sector_block));
end;


procedure getSectorData(drive: byte; head: byte; track: byte; sector: byte; var buffer);
var
    pos: longint;
    track_block: TTrack_block;
    ds: word;
    fisical_sector: byte;
begin
  getTrackBlock(drive,head,track,track_block);
  fisical_sector := 0;
  repeat
    inc(fisical_sector);
    getSectorBlock(drive,head,track,fisical_sector,sector_block);
  until (fisical_sector > track_block.sectors) or (sector_block.sector_ID = sector);
  pos := getDataOffset(drive,head,track,fisical_sector);
  ds := calcSectorDataSize(track_block.sector_size);
  move(buffer_dsk[drive][pos], buffer,ds);
end;

procedure putSectorData(drive: byte; head: byte; track: byte; sector: byte; var buffer);
var
    pos: longint;
    track_block: TTrack_block;
    ds: word;
begin
  getTrackBlock(drive,head,track,track_block);
  pos := getDataOffset(drive,head,track,sector);
  ds := calcSectorDataSize(track_block.sector_size);
  move(buffer,buffer_dsk[drive][pos],ds);
end;

function getdskcreator(drive: byte): string;
var
    S: string[34];
    jj: byte;
begin
  S := '';
  jj := 34;
  while {(buffer_dsk[drive][jj] <> 13) and} (jj < 34+14) do
  begin
    if buffer_dsk[drive][jj] >= 32 then
      s := s + chr(buffer_dsk[drive][jj])
    else
      s := s + ' ';
    inc(jj);
  end;
  getdskcreator := S;
end;


function getdskversionstring(drive: byte): string;
var
    S: string[34];
    jj: byte;
begin
  S := '';
  jj := 0;
  while {(buffer_dsk[drive][jj] <> 13) and} (jj < 34) do
  begin
    if buffer_dsk[drive][jj] >= 32 then
      s := s + chr(buffer_dsk[drive][jj])
    else
      s := s + ' ';
    inc(jj);
  end;
  getdskversionstring := S;
end;

procedure getSectorInfo;
begin
  with fdc do
  begin
    getSectorBlock(US0+US1*2,HD,C,R,sector_block);

    ST1 := sector_block.ST1;
    ST2 := sector_block.ST2;
    fdc_explode_status;
    IC := 0;
    N := sector_block.sector_size;
  end;
  fdc_compose_status;
end;

procedure check_ready(drive: byte);
begin
  with fdc do
  begin
    //if drive = 0 then
    //begin
    //  if not driveA_ready then
    //     main_reg := main_reg or %00000001
    //  else
    //    main_reg := main_reg and %11111110;
    //end else begin
    //  if not driveB_ready then
    //     main_reg := main_reg or %00000010
    //  else
    //    main_reg := main_reg and %00000001;
    //end;
  end;
end;

procedure Handle_fdc(var v: byte; source: byte);

  procedure from_processor_to_fdc;
  begin
     fdc.main_reg := fdc.main_reg and %10111111;
  end;

  procedure from_fdc_to_processor;
  begin
     fdc.main_reg := fdc.main_reg or %01000000;
  end;

  procedure set_exec_phase(direction: boolean);
  begin
    fdc.main_reg:= fdc.main_reg or %00100000; // set execution mode
    if direction=to_processor then
       from_fdc_to_processor
    else
      from_processor_to_fdc;
     fdc_state := sfdc_exec;
     param_num := 0;
  end;
  procedure set_params_phase;
  begin
    fdc.main_reg:= fdc.main_reg and %11011111; // reset execution mode
    fdc_state := sfdc_read_params;
    from_processor_to_fdc;
    param_num := 0;
  end;

  procedure set_results_phase;
  begin
    fdc.main_reg:= fdc.main_reg and %11011111; // reset execution mode
    from_fdc_to_processor;
    fdc_state := sfdc_results;
    param_num := 0;
  end;

  procedure set_command_phase;
  begin
    fdc.main_reg:= fdc.main_reg and %11011111; // reset execution mode
    from_processor_to_fdc;
    fdc_state := sfdc_command;
    fdc_command := cfdc_null;
    param_num := 0;
  end;

  procedure extract_param0(mask: byte);
  begin
     if (mask and %100) <> 0 then
        fdc.HD := (fdc.param0 >> 2) and 1;
     if (mask and %010) <> 0 then
        fdc.US1 := (fdc.param0 >> 1) and 1;
     if (mask and %001) <> 0 then
        fdc.US0 := fdc.param0 and 1;
     fdc.H := fdc.HD;
  end;

  procedure execute_inmediate;
  begin
     case fdc_command of
       cfdc_recalibrate:
        begin
          set_command_phase;
       end;
      cfdc_seek,
       cfdc_specify: begin
         set_command_phase;
       end;
     end;
  end;


  procedure fdc_read_command_params(params: array of pbyte; nextphase: tfdc_state; direction: boolean);
  var
      min,max: byte;
  begin
    min := Low(params);
    max := High(params);
    params[param_num]^ := v;
    inc(param_num);
    if param_num > max then
    begin
      case nextphase of
        sfdc_command  : set_command_phase;
        sfdc_exec     : set_exec_phase(direction);
        sfdc_results  : set_results_phase;
      end;
    end;
  end;
  procedure fdc_read_command_params(params: array of pbyte; nextphase: tfdc_state);
  begin
       fdc_read_command_params(params,nextphase,true);
  end;

  procedure fdc_write_command_results(params: array of pbyte);
  var
      min,max: byte;
  begin
     min := Low(params);
     max := High(params);
     v := params[param_num]^;
     inc(param_num);
     if param_num > max then
     begin
       set_command_phase;
    end;
  end;

begin
  case fdc_state of
    sfdc_command:
    if source = FROM_OUT then
    with fdc do
    begin
      executed := false;
      set_params_phase;  // next phase by default
      case v and %11111 of
        $02: fdc_command := cfdc_readtrack;          // read track command
        $03: fdc_command := cfdc_specify;            // specify command
        $04: fdc_command := cfdc_sensedrive;         // sense drive status command
        $05: fdc_command := cfdc_writedata;          // write data command
        $06: fdc_command := cfdc_readdata;           // read data command
        $07: fdc_command := cfdc_recalibrate;        // recalibrate command
        $08:                                         // sense interrupt status command
        begin
          fdc_command := cfdc_senseinterrupt;
          if operation_pending then
          begin
            PCN := NCN;
            SE := 1;
            IC := %00;
          end else begin
            SE := 0;
            IC := %10;
          end;
          fdc_composeST0;
          set_results_phase;
          operation_pending := false;
        end;
        $09: fdc_command := cfdc_writedeldata;       // write deleted data command
        $0a: fdc_command := cfdc_sectorid;           // read sector ID command
        $0c: fdc_command := cfdc_readdeldata;        // read deleted data command
        $0d: fdc_command := cfdc_format;             // format a track command
        $0f: fdc_command := cfdc_seek;               // seek command
        $11: fdc_command := cfdc_scanequal;          // scan equal command
        $19: fdc_command := cfdc_scanloworequal;     // scan low or equal command
        $1d: fdc_command := cfdc_scanhighorequal;    // scan high or equal command
        else fdc_command := cfdc_invalid;
      end;
      if fdc_command in [cfdc_readdata,cfdc_readdeldata,
         cfdc_writedata,cfdc_writedeldata,cfdc_scanequal,cfdc_scanloworequal,
         cfdc_scanhighorequal] then
            fdc.MT := (v >> 7) and 1;
      if fdc_command in [cfdc_readdata,cfdc_readtrack,cfdc_readdeldata,
         cfdc_writedata,cfdc_writedeldata,cfdc_scanequal,cfdc_scanloworequal,
         cfdc_scanhighorequal,cfdc_sectorid,cfdc_format] then
            fdc.MF := (v >> 6) and 1;
      if fdc_command in [cfdc_readdata,cfdc_readtrack,cfdc_readdeldata,
         cfdc_scanequal,cfdc_scanloworequal,cfdc_scanhighorequal] then
            fdc.SK := (v >> 5) and 1;
    end;
    sfdc_read_params:
    if source=FROM_OUT then
    with fdc do
    begin
      case fdc_command of
        cfdc_readdata: begin
          fdc_read_command_params([@param0,@C,@H,@R,@N,@EOT,@GPL,@DTL],sfdc_exec,to_processor);
        end;
        cfdc_readtrack,
        cfdc_readdeldata,
        cfdc_writedeldata: begin   // sin probar
          fdc := fdc;
        end;
        cfdc_writedata:
        begin
          fdc_read_command_params([@param0,@C,@H,@R,@N,@EOT,@GPL,@DTL],sfdc_exec,to_fdc);
        end;
        cfdc_sectorid:
        begin
          fdc_read_command_params([@param0],sfdc_results);
          if param_num = 0 then
            extract_param0(%111);
        end;
        cfdc_sensedrive:
        begin
            fdc_read_command_params([@param0],sfdc_results);
            fdc_composeST3;
            set_results_phase;
            extract_param0(%111);
        end;
        cfdc_format: // sin probar
        begin
            fdc_read_command_params([@param0,@N,@SC,@GPL,@D],sfdc_results);
            extract_param0(%111);
        end;
        cfdc_scanequal,
        cfdc_scanloworequal,
        cfdc_scanhighorequal:
        begin
            fdc_read_command_params([@param0,@C,@H,@R,@N,@EOT,@GPL,@STP],sfdc_results);
            extract_param0(%111);
        end;
        cfdc_recalibrate:
        begin
            fdc_read_command_params([@param0],sfdc_command);
            extract_param0(%011);
            SE := 0;
            C := 0;
            H := 0;
            IC := %00;
            with drive_pos[(US1 << 1) or US0] do
            begin
              side := H;
              track := C;
              sector := R;
            end;
            check_ready((US1 << 1) or US0);
            fdc_composeST0;
            operation_pending := true;
        end;
        cfdc_seek:
        begin
            fdc_read_command_params([@param0,@C],sfdc_command);
            extract_param0(%011);
            SE := 0;
            IC := %00;
            check_ready((US1 << 1) or US0);
            fdc_composeST0;
            operation_pending := true;
            if fdc_state = sfdc_command then
              with drive_pos[(US1 << 1) or US0] do
              begin
                side := H;
                track := C;
              end;
        end;
        cfdc_specify:
        begin
            fdc_read_command_params([@SRT_HUT,@HLT_ND],sfdc_command);
            SRT := SRT_HUT >> 4;
            HUT := SRT_HUT and $0F;
        end;
      end;
    end;
    sfdc_exec:
    with fdc do
    begin
      case fdc_command of
        cfdc_readtrack:   // falta probar
        begin
           if not executed then
          begin
            executed := true;
            getSectorBlock(us0+us1*2,H,C,R,sector_block);
            getSectorData(us0+us1*2,H,C,R,sector_data);
            data_count := 0;
          end;
          v := sector_data[data_count];
          inc(data_count);
          if data_count >= calcSectorDataSize(N) then
          begin
            if R < EOT then
            begin
              inc(R);
              getSectorBlock(us0+us1*2,H,C,R,sector_block);
              getSectorData(us0+us1*2,H,C,R,sector_data);
              data_count := 0;
            end else begin
              getSectorInfo;
              set_results_phase;
              executed := false;
              with drive_pos[(US1 << 1) or US0] do
              begin
                side := H;
                track := C;
                sector := R;
              end;
            end;
          end;
        end;

        cfdc_readdata:
        begin
           if not executed then
          begin
            executed := true;
            getSectorBlock(us0+us1*2,H,C,R,sector_block);
            getSectorData(us0+us1*2,H,C,R,sector_data);
            data_count := 0;
          end;
          v := sector_data[data_count];
          inc(data_count);
          if data_count >= calcSectorDataSize(N) then
          begin
            getSectorInfo;
            if MT = 0 then
            begin
              if R < track_block.sectors then
                inc(R)
              else begin
                R := 1;
                inc(C);
                H := (not H) and 1;
              end;
            end;
            set_results_phase;
            executed := false;
            with drive_pos[(US1 << 1) or US0] do
            begin
              side := H;
              track := C;
              sector := R;
            end;
          end;
        end;

        cfdc_writedata:
        begin
           if not executed then
          begin
            executed := true;
            getSectorBlock(us0+us1*2,H,C,R,sector_block);
            getSectorData(us0+us1*2,H,C,R,sector_data);
            data_count := 0;
          end;
          sector_data[data_count] := v;
          inc(data_count);
          if data_count >= calcSectorDataSize(N) then
          begin
            getSectorInfo;
            putSectorData(us0+us1*2,H,C,R,sector_data);
            if MT = 0 then
            begin
              if R < track_block.sectors then
                inc(R)
              else begin
                R := 1;
                inc(C);
                //H := (not H) and 1;
              end;
            end;
            set_results_phase;
            executed := false;
            with drive_pos[(US1 << 1) or US0] do
            begin
              side := H;
              track := C;
              sector := R;
            end;
          end;
        end;
        cfdc_invalid: begin
          ST0 := $80;
          set_results_phase;
        end;
      end;
    end;
    sfdc_results:
    if source = FROM_IN then
    with fdc do
    begin
      case fdc_command of
        cfdc_readdata,
        cfdc_readtrack,
        cfdc_readdeldata,
        cfdc_writedata,
        cfdc_writedeldata,
        cfdc_format,
        cfdc_scanequal,
        cfdc_scanloworequal,
        cfdc_scanhighorequal:
        begin
          fdc_write_command_results([@ST0,@ST1,@ST2,@C,@H,@R,@N]);
        end;
        cfdc_sectorid:
        begin
            if param_num = 0 then
            with drive_pos[(US1 << 1) or US0] do
            begin
              H := side;
              C := track;
              R := sector;
              getsectorinfo;
              R := sector_block.sector_ID;
            end;
            fdc_write_command_results([@ST0,@ST1,@ST2,@C,@H,@R,@N]);
        end;
        cfdc_sensedrive:
            fdc_write_command_results([@ST3]);
        cfdc_senseinterrupt:
            fdc_write_command_results([@ST0,@PCN]);
        cfdc_invalid:
            fdc_write_command_results([@ST0]);
      end;
    end;
  end;
  fdc_compose_status;
end;

function AYMachine: boolean;
begin
     AYMachine := options.machine <= spectrum128;
end;

function getdircaption(x: byte): string;
var
    row,col: byte;
begin
  row := user_buttons[x,0];
  col := user_buttons[x,1];
  case row of
    0: begin
       case col of
         0: getdircaption := '↑';
         1: getdircaption := 'Z';
         2: getdircaption := 'X';
         3: getdircaption := 'C';
         4: getdircaption := 'V';
       end;
    end;
    1: begin
       case col of
         0: getdircaption := 'A';
         1: getdircaption := 'S';
         2: getdircaption := 'D';
         3: getdircaption := 'F';
         4: getdircaption := 'G';
       end;
    end;
    2: begin
       case col of
         0: getdircaption := 'Q';
         1: getdircaption := 'W';
         2: getdircaption := 'E';
         3: getdircaption := 'R';
         4: getdircaption := 'T';
       end;
    end;
    3: begin
       case col of
         0: getdircaption := '1';
         1: getdircaption := '2';
         2: getdircaption := '3';
         3: getdircaption := '4';
         4: getdircaption := '5';
       end;
    end;
    4: begin
       case col of
         0: getdircaption := '0';
         1: getdircaption := '9';
         2: getdircaption := '8';
         3: getdircaption := '7';
         4: getdircaption := '6';
       end;
    end;
    5: begin
       case col of
         0: getdircaption := 'P';
         1: getdircaption := 'O';
         2: getdircaption := 'I';
         3: getdircaption := 'U';
         4: getdircaption := 'Y';
       end;
    end;
    6: begin
       case col of
         0: getdircaption := '┘';
         1: getdircaption := 'L';
         2: getdircaption := 'K';
         3: getdircaption := 'J';
         4: getdircaption := 'H';
       end;
    end;
    7: begin
       case col of
         0: getdircaption := '_';
         1: getdircaption := '⌂';
         2: getdircaption := 'M';
         3: getdircaption := 'N';
         4: getdircaption := 'B';
       end;
    end;
  end;
end;

procedure AssignUserButton(dir: byte; key: word);
begin
     case key of
       VK_SHIFT,VK_Z,VK_X,VK_C,VK_V: user_buttons[dir,0] := 0;
       VK_A,VK_S,VK_D,VK_F,VK_G: user_buttons[dir,0] := 1;
       VK_Q,VK_W,VK_E,VK_R,VK_T: user_buttons[dir,0] := 2;
       VK_1,VK_2,VK_3,VK_4,VK_5: user_buttons[dir,0] := 3;
       VK_0,VK_9,VK_8,VK_7,VK_6: user_buttons[dir,0] := 4;
       VK_P,VK_O,VK_I,VK_U,VK_Y: user_buttons[dir,0] := 5;
       VK_RETURN,VK_L,VK_K,VK_J,VK_H: user_buttons[dir,0] := 6;
       VK_SPACE,VK_MENU,VK_M,VK_N,VK_B: user_buttons[dir,0] := 7;
     end;

     case key of
       VK_SHIFT,VK_A,VK_Q,VK_1,VK_0,VK_P,VK_RETURN,VK_SPACE: user_buttons[dir,1] := 0;
       VK_Z,VK_S,VK_W,VK_2,VK_9,VK_O,VK_L,VK_MENU: user_buttons[dir,1] := 1;
       VK_X,VK_D,VK_E,VK_3,VK_8,VK_I,VK_K,VK_M: user_buttons[dir,1] := 2;
       VK_C,VK_F,VK_R,VK_4,VK_7,VK_U,VK_J,VK_N: user_buttons[dir,1] := 3;
       VK_V,VK_G,VK_T,VK_5,VK_6,VK_Y,VK_H,VK_B: user_buttons[dir,1] := 4;
     end;

end;

procedure setSinclairLeft(n: byte);
begin
     SinclairLeft := SinclairLeft and not (1 << n);
end;

procedure ResetSinclairLeft(n: byte);
begin
     SinclairLeft := SinclairLeft or (1 << n);
end;

procedure setSinclairRight(n: byte);
begin
     SinclairRight := SinclairRight and not (1 << n);
end;

procedure ResetSinclairRight(n: byte);
begin
     SinclairRight := SinclairRight or (1 << n);
end;

procedure setKempston(n: byte);
begin
     Kempston := Kempston or (1 << n);
end;

procedure ResetKempston(n: byte);
begin
     Kempston := Kempston and not (1 << n);
end;

begin
  Kempston := 0;
  fillchar(user_buttons, sizeof(user_buttons),0);
  fillchar(AY1, sizeof(AY1), 0);

  //fdc.C := 0;       // cylinder
  //fdc.H := 0;       // head
  //fdc.R := 0;       // Record
  //fdc.N := 0;       // Number of data bytes in a sector
  //fdc.EOT := 0;     // End of track
  //fdc.GPL := 0;     // Gap length
  //fdc.DTL := 0;     // Data length
  //fdc.D := 0;       // Data
  //fdc.STP:= 0;      // During a Scan operation, if STP = 1, the data in contiguous sectors is compared byte by byte
  //                  // with data sent from the processor (or DMA); and if STP = 2, then alternate sectors are read
  //                  // and compared.
  //fdc.SC := 0;      // sector
  //fdc.SRT := $08;     // Step rate time
  //fdc.HUT := $07;   // Head unload time
  //fdc.HLT := $07;   // Head load time
  //fdc.ND := 0;      // Non DMA Mode
  //fdc.NCN := 0;     // new cylinder number
  //fdc.PCN := 5;     // present cylinder number
  //fdc.SK := 0;      // Skip
  //fdc.MT := 0;      // Multitrack
  //fdc.MF := 0;      // FM or MFM mode
  //
  //fdc.SRT_HUT := (fdc.SRT << 4) or fdc.HUT; // SRT+HUT
  //fdc.HLT_ND := (fdc.HLT << 1) or fdc.ND;   // HLT+ND
  //fdc.param0 := fdc.MT or fdc.MF or fdc.SK;
  //fdc_composeST0;
  //fdc_composeST1;
  //fdc_composeST2;
  //fdc_composeST3;
  //
  //fdc.main_reg := %10000000;
  reset_fdc;
end.

