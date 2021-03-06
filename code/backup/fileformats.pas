unit FileFormats;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Z80Globals,z80ops,spectrum, Dialogs,global;

function loadSnapshotfile(FileName: String):boolean;
function SaveSnapshotfile(FileName: String):boolean;

implementation


Type
  //Offset   Size   Description
  //------------------------------------------------------------------------
  //0        1      byte   I
  //1        8      word   HL',DE',BC',AF'
  //9        10     word   HL,DE,BC,IY,IX
  //19       1      byte   Interrupt (bit 2 contains IFF2, 1=EI/0=DI)
  //20       1      byte   R
  //21       4      words  AF,SP
  //25       1      byte   IntMode (0=IM0/1=IM1/2=IM2)
  //26       1      byte   BorderColor (0..7, not used by Spectrum 1.7)
  //27       49152  bytes  RAM dump 16384..65535
  //------------------------------------------------------------------------
  //Total: 49179 bytes
  //As the program counter is pushed onto the stack so that a RETN instruction can restart the program

  //Offset   Size   Description
  //------------------------------------------------------------------------
  //0        27     bytes  SNA header (see above)
  //27       16Kb   bytes  RAM bank 5 \
  //16411    16Kb   bytes  RAM bank 2  } - as standard 48Kb SNA file
  //32795    16Kb   bytes  RAM bank n / (currently paged bank)
  //49179    2      word   PC
  //49181    1      byte   port 0x7ffd setting
  //49182    1      byte   TR-DOS rom paged (1) or not (0)
  //49183    16Kb   bytes  remaining RAM banks in ascending order
  //...
  //------------------------------------------------------------------------
  //Total: 131103 or 147487 bytes

  {$ALIGN 1}
  TSnaFormat = record
    I: Byte;
    HL1:word;
    DE1,BC1,AF1: Word;
    HL,DE,BC,IY,IX: Word;
    Interrupt: Byte;
    R: Byte;
    AF,SP: Word;
    IntMode: byte;
    BorderColor: Byte;
    RAM: Array[16384..65535] of byte;
  end;
  TSnaFormatv2 = record
    I: Byte;
    HL1:word;
    DE1,BC1,AF1: Word;
    HL,DE,BC,IY,IX: Word;
    Interrupt: Byte;
    R: Byte;
    AF,SP: Word;
    IntMode: byte;
    BorderColor: Byte;
    RAM5: Array[0..$3FFF] of byte;
    RAM2: Array[0..$3FFF] of byte;
    RAMH: Array[0..$3FFF] of byte;
    pc: word;
    lastout_7ffd: byte;
    TRDOSROMP: byte;
    RAMP: Array[0..5,0..$3FFF] of byte;
  end;

  // Offset  Length  Description
    //---------------------------
    //0       1       A register
    //1       1       F register
    //2       2       BC register pair (LSB, i.e. C, first)
    //4       2       HL register pair
    //6       2       Program counter
    //8       2       Stack pointer
    //10      1       Interrupt register
    //11      1       Refresh register (Bit 7 is not significant!)
    //12      1       Bit 0  : Bit 7 of the R-register
    //                Bit 1-3: Border colour
    //                Bit 4  : 1=Basic SamRom switched in
    //                Bit 5  : 1=Block of data is compressed
    //                Bit 6-7: No meaning
    //13      2       DE register pair
    //15      2       BC' register pair
    //17      2       DE' register pair
    //19      2       HL' register pair
    //21      1       A' register
    //22      1       F' register
    //23      2       IY register (Again LSB first)
    //25      2       IX register
    //27      1       Interrupt flipflop, 0=DI, otherwise EI
    //28      1       IFF2 (not particularly important...)
    //29      1       Bit 0-1: Interrupt mode (0, 1 or 2)
    //                Bit 2  : 1=Issue 2 emulation
    //                Bit 3  : 1=Double interrupt frequency
    //                Bit 4-5: 1=High video synchronisation
    //                         3=Low video synchronisation
    //                         0,2=Normal
    //                Bit 6-7: 0=Cursor/Protek/AGF joystick
    //                         1=Kempston joystick
    //                         2=Sinclair 2 Left joystick (or user
    //                           defined, for version 3 .z80 files)
    //                         3=Sinclair 2 Right joystick
//After the first 30 bytes, an additional header follows:
//
//        Offset  Length  Description
//        ---------------------------
//      * 30      2       Length of additional header block (see below)
//      * 32      2       Program counter
//      * 34      1       Hardware mode (see below)
//      * 35      1       If in SamRam mode, bitwise state of 74ls259.
//                        For example, bit 6=1 after an OUT 31,13 (=2*6+1)
//                        If in 128 mode, contains last OUT to 0x7ffd
//    		    If in Timex mode, contains last OUT to 0xf4
//      * 36      1       Contains 0xff if Interface I rom paged
//    		    If in Timex mode, contains last OUT to 0xff
//      * 37      1       Bit 0: 1 if R register emulation on
//                        Bit 1: 1 if LDIR emulation on
//    		    Bit 2: AY sound in use, even on 48K machines
//    		    Bit 6: (if bit 2 set) Fuller Audio Box emulation
//    		    Bit 7: Modify hardware (see below)
//      * 38      1       Last OUT to port 0xfffd (soundchip register number)
//      * 39      16      Contents of the sound chip registers
//        55      2       Low T state counter
//        57      1       Hi T state counter
//        58      1       Flag byte used by Spectator (QL spec. emulator)
//                        Ignored by Z80 when loading, zero when saving
//        59      1       0xff if MGT Rom paged
//        60      1       0xff if Multiface Rom paged. Should always be 0.
//        61      1       0xff if 0-8191 is ROM, 0 if RAM
//        62      1       0xff if 8192-16383 is ROM, 0 if RAM
//        63      10      5 x keyboard mappings for user defined joystick
//        73      10      5 x ASCII word: keys corresponding to mappings above
//        83      1       MGT type: 0=Disciple+Epson,1=Disciple+HP,16=Plus D
//        84      1       Disciple inhibit button status: 0=out, 0ff=in
//        85      1       Disciple inhibit flag: 0=rom pageable, 0ff=not
//     ** 86      1       Last OUT to port 0x1ffd
  //TZ80Formatv1 = record
  //  A: Byte;
  //  F: Byte;
  //  bc: word;
  //  hl: word;
  //  pc: word;
  //  sp: word;
  //  IM: byte;
  //  R: byte;
  //  info1: Byte;
  //  de: word;
  //  bc1: word;
  //  de1: word;
  //  hl1: word;
  //  A1: byte;
  //  f1: byte;
  //  iy: word;
  //  ix: word;
  //  interrupt: byte; //Interrupt flipflop, 0=DI, otherwise EI
  //  iff2: byte;
  //  info2: Byte;
  //  RAM: Array[16384..65535] of byte;
  //end;

  TZ80Formatv2 = record
    A: Byte;
    F: Byte;
    bc: word;
    hl: word;
    old_pc_byte: word;
    sp: word;
    I: byte;
    R: byte;
    info1: Byte;
    de: word;
    bc1: word;
    de1: word;
    hl1: word;
    A1: byte;
    f1: byte;
    iy: word;
    ix: word;
    interrupt: byte; //Interrupt flipflop, 0=DI, otherwise EI
    iff2: byte;
    info2: Byte;
    Additional_len: word;
    pc: word;
    hardware_mode: byte;
    lastout_7ffd: byte;
    If1_rompaged: byte;
    info3: byte;
    lastout_fffd: byte;
    sound_registers: Array[0..15] of byte;
    TState_low: word;
    TState_High: word;
    SpectatorFlag: Byte;
    MGTROMPaged: byte;
    MultifaceROMPaged: byte;
    AllRAM: byte;
    KeyboardMappings: array[0..9] of byte;
    ASCIIWord: array[0..9] of byte;
    MGTType: byte;
    DiscipleButtonStatus: Byte;
    DiscipleFlag: Byte;
    lastout_1ffd: byte;
  end;

  tz80_block_header = record
    len: word;
    page: byte;
  end;

  ttzx_header = record
    TZX_signature: Array[0..6] of char;
    end_marker: byte;
    major_rev: byte;
    minor_rev: byte;
  end;
  ttzx_block_ID10 = record        // standard speed data block
    pause: word;
    len: array[0..2] of byte;
    data: array[0..$ffff] of byte;
  end;
  ttzx_block_ID11 = record        // turbo speed data block
    pilot_pulse_len: word;
    sync_first_len: word;
    sync_second_len: word;
    ZERObit_len: word;
    ONEbit_len: word;
    pilot_tone_len: word;
    used_bits_in_last_byte: byte;
    pause: word;
    len: array[0..2] of byte;
    data: array[0..$ffff] of byte;
  end;
  ttzx_block_ID12 = record          // pure tone block
    pulse_len: word;
    number: array[0..255] of word;
  end;

  ttzx_block_ID13 = record          // pulse sequence
    number: byte;
    pulses_len: array[0..255] of word;
  end;
  ttzx_block_ID14 = record          // pure data block
    ZERObit_len: word;
    ONEbit_len: word;
    used_bits_in_last_byte: byte;
    pause: word;
    len: array[0..2] of byte;
    data: array[0..$ffff] of byte;
  end;
  ttzx_block_ID15 = record          // direct recording
    t_states_per_sample: word;
    pause: word;
    used_bits_in_last_byte: byte;
    len: array[0..2] of byte;
    data: array[0..$ffff] of byte;
  end;
  ttzx_block_ID18 = record          // csw recording
    block_len: dword;
    pause: word;
    sampling_rate: array[0..2] of byte;
    compression_type: byte;
    number_of_pulses: dword;
    csw_data: array[0..$ffff] of byte;
  end;
  ttzx_block_ID19 = record          // generalized data
    block_len: dword;
    pause: word;
    symbols_in_pilot: dword;
    max_pulses_in_pilot: byte;
    pilot_sync_symbols_in_table: byte;
    symbols_in_data_stream: dword;
    max_pulses_in_data_symbol: byte;
    data_symbols_in_table: byte;
    //pilot_and_symbols_table:
  end;

var
  z80: Tz80Formatv2;
  snav2: TSnaFormatv2;
  sna: TSnaFormat absolute snav2;
  buffer: Array[0..65535] of byte;

  //z80v1: Tz80Formatv1 absolute z80;
  {$ALIGN ON}

function load_sna_file(filename: string): boolean;
var
  F: File;
  x,ii,pageh: byte;
  modo48k: boolean;
  rr: longint;
begin
   try
     Assignfile(F, filename);
     Reset(F,1);
     modo48k := filesize(f) = 49179;
     if modo48k then
        Blockread(F,sna,sizeof(sna),rr)
     else
       Blockread(F,snav2,sizeof(snav2),rr);
     CloseFile(F);
     i   := sna.i;
     hl1 := sna.hl1;
     de1 := sna.de1;
     bc1 := sna.bc1;
     af1 := sna.af1;
     hl  := sna.hl;
     de  := sna.de;
     bc  := sna.bc;
     iy  := sna.iy;
     ix  := sna.ix;
     iff2 := (sna.Interrupt and %100) <> 0;
     iff1 := iff2;
     r   := sna.r;
     af  := sna.af;
     sp  := sna.sp;
     im  := sna.intmode;
     border_color := sna.BorderColor;
     explode_flags;
     if modo48k then  // 48K mode
     begin
       // move(sna.RAM[16384],mem[16384],49152);
       case options.machine of
            spectrum48      : rom_bank := 0;
            spectrum128,
            Spectrum_plus2  : rom_bank := 1;
            Spectrum_plus2a,
            Spectrum_plus3  : rom_bank := 3;
       end;
       select_rom;
       for x := 1 to 3 do
           move(sna.RAM[x*$4000],memP[Mem_banks[x],0],$4000);
       retn;
     end else begin  // 128K mode
        case options.machine of
             spectrum128,
             Spectrum_plus2  : rom_bank := 1;
             Spectrum_plus2a,
             Spectrum_plus3  : rom_bank := 3;
        end;
        select_rom;
        spectrum_out($7ffd, snav2.lastout_7ffd);
        pageh := snav2.lastout_7ffd and %111;
        move(snav2.RAM5[0], memp[5,0],$4000);
        move(snav2.RAM2[0], memp[2,0],$4000);
        move(snav2.RAMH[0], memp[pageh,0],$4000);
        x := 0;
        ii := 0;
        repeat
          if (x <> 2) and (x <>5) and (x <> pageh) then
          begin
            move(snav2.RAMP[ii,0], memp[x,0], $4000);
            inc(ii);
          end;
          inc(x);
        until x > 7;
        pc := snav2.pc;
     end;
     load_sna_file := true;

   except
     ShowMessage('Error loading sna file');
   end;
end;

function load_z80_file(filename: string): boolean;
var
  FF: File;
  res: longint;
  header_size: word = 30;
  estado: byte = 0;
  v,rep: byte;
  no_more_blocks: boolean;
  bhead: tz80_block_header;
  ver: byte;
  modo48k,modo128k: boolean;

  procedure unpack_block(page: integer; endmarker: boolean; len: word);
  var
    j,k: word;
    m: byte;

    procedure poke(addr: word; value: byte);
    begin
       if page < 0 then
          wrmem(addr+$4000,value)
       else
         memp[page,addr]:=value;
    end;

  begin
       if page = $ff then exit;
       k := 0;
       for j := 0 to len-1 do
       begin
            if j = $ED0 then
               a := a;
           case estado of
                0: if Buffer[j] = $ED then estado := 1
                   else if (buffer[j]=0) and endmarker then estado := 4
                   else begin
                     // wrmem(k,Buffer[j]);
                     //memp[page,k]:=Buffer[j];
                     poke(k,Buffer[j]);
                     inc(k);
                   end;
                // $ED
                1: if Buffer[j] = $ED then estado := 2
                   else begin
                     //wrmem(k,$ED);
                     //memp[page,k]:=$ED;
                     poke(k,$ED);
                     inc(k);
                     //wrmem(k,Buffer[j]);
                     //memp[page,k]:=Buffer[j];
                     poke(k,Buffer[j]);
                     inc(k);
                     estado := 0;
                   end;
                // $ED$ED
                2: begin
                   rep := Buffer[j];
                   estado := 3;
                end;
                // $ED$ED rep
                3: begin
                   v := Buffer[j];
                   for m := 1 to rep do
                   begin
                       // wrmem(k,v);
                       // memp[page,k]:=v;
                       poke(k,v);
                       inc(k);
                   end;
                   estado := 0;
                end;
                // $00
                4: if buffer[j] = $ED then
                   estado := 5
                else begin
                  //wrmem(k,0);
                  //memp[page,k]:=0;
                  poke(k,0);
                  inc(k);
                  //wrmem(k,Buffer[j]);
                  //memp[page,k]:=Buffer[j];
                  poke(k,Buffer[j]);
                  inc(k);
                  estado := 0;
                end;
                // $00$ED
                5: if buffer[j] = $ED then
                   estado := 6
                else begin
                  // wrmem(k,0);
                  //memp[page,k]:=0;
                  poke(k,0);
                  inc(k);
                  //wrmem(k,$ED);
                  //memp[page,k]:=$ED;
                  poke(k,$ED);
                  inc(k);
                  //wrmem(k,Buffer[j]);
                  //memp[page,k]:=Buffer[j];
                  poke(k,Buffer[j]);
                  inc(k);
                  estado := 0;
                end;
                // $00$ED$ED
                6: begin
                  if buffer[j] = $00 then // $00$ED$ED$00 End of block
                    break
                  else begin
                    // wrmem(k,0);
                    //memp[page,k]:=0;
                    poke(k,0);
                    inc(k);
                    rep := Buffer[j];
                    estado := 3;
                    //// wrmem(k,$ED);
                    //// memp[page,k]:= $ED;
                    //poke(k,$ED);
                    //inc(k);
                    //// mem[k] := $ED;
                    ////memp[page,k]:=$ED;
                    //poke(k,$ED);
                    //inc(k);
                    //// wrmem(k,Buffer[j]);
                    //// memp[page,k]:=Buffer[j];
                    //poke(k,Buffer[j]);
                    //inc(k);
                    //estado := 0;
                  end;
                end;
           end;
       end;
  end;
begin
   try
     Assignfile(FF, filename);
     Reset(FF,1);
     fillchar(z80, sizeof(z80), 0);
     Blockread(FF,z80,Header_Size,res);
     A := z80.A;
     F := Z80.F;
     bc := Z80.bc;
     hl := z80.hl;
     if z80.old_pc_byte <> 0 then
     begin
        pc := z80.old_pc_byte // v1
     end else begin
        Blockread(FF,z80.Additional_len,sizeof(word),res);
        Blockread(FF,z80.pc,z80.Additional_len,res);
        pc := z80.pc;                                 // v2 o v3
     end;
     sp := z80.sp;
     i := z80.I;
     R := z80.R;
     if z80.info1 = 255 then z80.info1 := 1;
     R_bit7 := (z80.info1 and 1) << 7;
     R := R_bit7 or (R and %011111111);
     border_color := (z80.info1 >> 1) and %111;
     de := z80.de;
     bc1 := z80.bc1;
     de1 := z80.de1;
     hl1 := z80.hl1;
     A1 := z80.a1;
     f1 := z80.f1;
     iy := z80.iy;
     ix := z80.ix;
     iff1 := z80.iff2 <> 0;
     iff2 := iff1;
     im := z80.info2 and %11;
     explode_flags;


     if (z80.old_pc_byte <> 0) then
        ver := 1
     else if (z80.Additional_len = 23) then ver := 2
     else ver := 3;

     modo48k := (ver = 1) or
             (z80.hardware_mode = 0) or  (z80.hardware_mode = 1) or
             ((ver=3) and (z80.hardware_mode = 3));
     modo128k := (ver <> 1) and (((ver=2) and (z80.hardware_mode = 3)) or
                 (z80.hardware_mode = 4) or  (z80.hardware_mode = 5) or
                 (z80.hardware_mode = 6));

     if modo128k then
        spectrum_out($7ffd,z80.lastout_7ffd);

     if options.machine >= spectrum_plus2a then
     begin
       if modo128k and (z80.Additional_len = 55) then
          spectrum_out($1ffd,z80.lastout_1ffd)
       else
           spectrum_out($1ffd,%100);
     end;
     if ver=1 then             // v1
     begin
        Blockread(FF,buffer,$c000,res);
        if (z80.info1 and %00100000) <> 0 then // v1 compressed file
        begin
          unpack_block(-1,true,res);
        end else begin                           // v1 uncompressed file
          // move(buffer, mem[16384], res-Header_Size);
          move(buffer, memP[1,0], res-Header_Size);
        end;
     end else begin                              // v2 or V3
        no_more_blocks := false;
        repeat
         Blockread(FF,bhead,sizeof(bhead),res);
         if res = sizeof(bhead) then
         begin
            Blockread(FF,buffer,bhead.len,res);
            if modo48k then // 48K
            begin
              case bhead.page of
                0: unpack_block(32,false,bhead.len);      // 48KB BASIC
                1: unpack_block($ff,false,bhead.len);      // Interface I, Disciple or Plus D rom, according to setting
                2: unpack_block($ff,false,bhead.len);      //
                3: unpack_block($ff,false,bhead.len);      //
                4: unpack_block(2,false,bhead.len);      // 8000-bfff
                5: unpack_block(3,false,bhead.len);      // c000-ffff
                6: unpack_block(3,false,bhead.len);      //
                7: unpack_block($ff,false,bhead.len);      //
                8: unpack_block(1,false,bhead.len);      // 4000-7fff
                9: unpack_block($ff,false,bhead.len);      //
               10: unpack_block($ff,false,bhead.len);      //
               11: unpack_block($ff,false,bhead.len);      // Multiface rom
              end;
            end else if modo128k then // 128K
            begin
               case bhead.page of
                    0: unpack_block(35,false,bhead.len);      // 48KB BASIC
                    1: unpack_block($ff,false,bhead.len);      // Interface I, Disciple or Plus D rom, according to setting
                    2: unpack_block(32,false,bhead.len);      //
                    3: unpack_block(0,false,bhead.len);      //
                    4: unpack_block(1,false,bhead.len);      // 8000-bfff
                    5: unpack_block(2,false,bhead.len);      // c000-ffff
                    6: unpack_block(3,false,bhead.len);      //
                    7: unpack_block(4,false,bhead.len);      //
                    8: unpack_block(5,false,bhead.len);      // 4000-7fff
                    9: unpack_block(6,false,bhead.len);      //
                   10: unpack_block(7,false,bhead.len);      //
                   11: unpack_block($ff,false,bhead.len);      // Multiface rom
               end;
            end;
        end else no_more_blocks := true;
        until no_more_blocks;
     end;
     CloseFile(FF);
     load_z80_file := true;
   except
     load_z80_file := false;
     ShowMessage('Error reading z80 file');
   end;
end;

function loadSnapshotfile(FileName: String):boolean;
var
  ext: string;
  res: boolean;
begin
     ext := UpperCase(ExtractFileExt(filename));
     if ext = '.SNA' then res := load_sna_file(filename)
     else if ext = '.Z80' then res := load_z80_file(filename)
     else ShowMessage('Format not yet supported');
     loadSnapshotfile := res;
end;


function save_sna_file(FileName: String):boolean;
var
   F: File;
   x,ii,Banks_not_used,pageh: byte;
begin
    if options.machine = spectrum48 then
       push2(pc)
    else begin
        snav2.pc := pc;
        snav2.lastout_7ffd :=  last_out_7ffd;
        snav2.TRDOSROMP := 0;
    end;
    sna.i   := i;
    sna.hl1 := hl1;
    sna.de1 := de1;
    sna.bc1 := bc1;
    sna.af1 := af1;
    sna.hl  := hl;
    sna.de  := de;
    sna.bc  := bc;
    sna.iy  := iy;
    sna.ix  := ix;
    if iff1 then
       sna.Interrupt := sna.Interrupt or %00000100
    else
      sna.Interrupt := sna.Interrupt and %11111011;
    sna.r   := r;
    sna.af  := af;
    sna.sp  := sp;
    sna.intmode  := im;
    sna.BorderColor := border_color;

    if options.machine = spectrum48 then
    begin
      for x := 1 to 3 do
          move(memP[Mem_banks[x],0],sna.RAM[x*$4000],$4000);
      Try
        Assignfile(F, filename);
        Rewrite(F,1);
        Blockwrite(F,sna,sizeof(sna));
        CloseFile(F);
        save_sna_file := true;
        retn;
      except
        save_sna_file := false;
        ShowMessage('Error saving sna file.');
      end;

    end else begin // Spectrum128
       pageh := snav2.lastout_7ffd and %111;
       move(memp[5,0],snav2.RAM5[0],$4000);
       move(memp[2,0],snav2.RAM2[0],$4000);
       move(memp[pageh,0],snav2.RAMH[0],$4000);
       x := 0;
       ii := 0;
       repeat
         if (x <> 2) and (x <>5) and (x <> pageh) then
         begin
           move(memp[x,0],snav2.RAMP[ii,0],$4000);
           inc(ii);
         end;
         inc(x);
       until x > 7;
       Banks_not_used := 6-ii;
       Try
         Assignfile(F, filename);
         Rewrite(F,1);
         Blockwrite(F,snav2,sizeof(snav2)-Banks_not_used*$4000);
         CloseFile(F);
         save_sna_file := true;
       except
         save_sna_file := false;
         ShowMessage('Error saving sna file.');
       end;

    end;
end;

function save_z80_file(FileName: String):boolean;
begin
    ShowMessage('Format not yet supported');
     save_z80_file := true;
end;

function saveSnapshotfile(FileName: String):boolean;
var
  ext: string;
  res: boolean;
begin
     ext := UpperCase(ExtractFileExt(filename));
     if ext = '.SNA' then res := save_sna_file(filename)
     else if ext = '.Z80' then res := save_z80_file(filename)
     else ShowMessage('Format not yet supported');
     saveSnapshotfile := res;
end;
end.

