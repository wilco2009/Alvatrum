unit z80Globals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, graphics,global;

var
   n3_flag, n5_flag, c_flag, h_flag, n_flag, z_flag, s_flag, pv_flag: byte;
   monitor: TBitmap;

const
     FLAG_C =$01;
     FLAG_N =$02;
     FLAG_PV=$04;
     FLAG_3 =$08;
     FLAG_H =$10;
     FLAG_5 =$20;
     FLAG_Z =$40;
     FLAG_S =$80;

var
   cpu_backup: record
     registers: Array[0..15] of byte;
     iff1, iff2: boolean;
     im: byte;
     r, i: Byte;
     ix, iy, sp: word;
     pc: word;
     halted: boolean;
     intpend: boolean;
     NMI: boolean;
   end;
   // Mem: Array[0..65535] of byte;
   MemP: Array[0..35,0..$3FFF] of byte; // absolute Mem;
   Mem_banks: array[0..3] of byte = (0,1,2,3);
   disable_pagging: boolean = false;
   registers: Array[0..15] of byte;
   iff1, iff2: boolean;
   im: byte;
   af: word absolute registers[0];
   bc: word absolute registers[2];
   de: word absolute registers[4];
   hl: word absolute registers[6];
   af1: word absolute registers[8];
   bc1: word absolute registers[10];
   de1: word absolute registers[12];
   hl1: word absolute registers[14];

   f: byte absolute registers[0];
   a: byte absolute registers[1];
   c: byte absolute registers[2];
   b: byte absolute registers[3];
   e: byte absolute registers[4];
   d: byte absolute registers[5];
   l: byte absolute registers[6];
   h: byte absolute registers[7];

   f1: byte absolute registers[8];
   a1: byte absolute registers[9];
   c1: byte absolute registers[10];
   b1: byte absolute registers[11];
   e1: byte absolute registers[12];
   d1: byte absolute registers[13];
   l1: byte absolute registers[14];
   h1: byte absolute registers[15];
   r, i, r_bit7: Byte;
   pc, pc_before: word;
   ix, iy, sp: word;
   halted: boolean;
   t_states, t_states_ini_frame, t_states_cur_frame: int64;
   real_time, sp_time: qword;
   rom_bank: byte = 0;


   intpend: boolean = false;
   NMI: boolean = false;
   halfcarry_add_table: Array[0..7] of byte = (0,  FLAG_H, FLAG_H,  FLAG_H,       0, 0,       0, FLAG_H);
   halfcarry_sub_table: Array[0..7] of byte = (0,       0, FLAG_H,       0,  FLAG_H, 0,  FLAG_H, FLAG_H);
   overflow_add_table : Array[0..7] of byte = (0,       0,      0, FLAG_PV, FLAG_PV, 0,       0,      0);
   overflow_sub_table : Array[0..7] of byte = (0, FLAG_PV,      0,       0,       0, 0, FLAG_PV,      0);

   procedure save_cpu_status;
   procedure restore_cpu_status;
   function parity(a: byte): byte; //inline;
   function iffb(cond: boolean; yes: byte; no: byte): byte; //inline;
   function iffc(cond: boolean; yes: char; no: char): char; //inline;
   procedure compose_flags; //inline;
   procedure explode_flags; //inline;
   procedure wrmem(x: word; y: byte); //inline;
   // store 8 bit value y at 16 bit location x
   procedure store(x: word; y: byte);
   // store 8 bit value y at 16 bit location x
   procedure store2b(x: word; hi: byte; lo: byte); //inline;
   procedure store2(x: word; y: word); //inline;
   function rdmem(addr: word): byte; //inline;
   function rdmem_signed(addr: word): shortint; //inline;
   function fetch_pc: byte; //inline;
   function signed_fetch_pc: int8;  //inline;
   function rdmem2(addr: word): word; //inline;
   function fetch2_pc: word;
   procedure swap(var x: byte; var y: byte);
   function add_16bit(reg, op: cardinal): cardinal;  // 16-bit add
   //Activa los flags 5,3 segun valor
   procedure set_undocumented_flags_bits(value: byte);
   procedure set_undocumented_flags_bits_memptr(memptr: word);
   procedure set_flags_carry_16_suma(antes,result: word);
   procedure set_flags_halfcarry_suma(antes, result: Byte);
   procedure set_flags_carry_suma(antes,result: byte);
   procedure set_flags_overflow_suma(antes,result: byte);
   procedure set_sz53_flags(reg: byte);
   procedure set_sz53p_flags(reg: byte);
   procedure set_flags_zero_sign_16(value: word);
   procedure set_flags_zero_sign(value: byte);
   procedure set_flags_in(val: byte);
   procedure set_flags_rrd_rld;
   procedure set_a_flags;
   function hi(reg: word): byte;
   function lo(reg: word): byte;
   procedure invalid_instruction;
   procedure inc_register_r;
   function desp8_to_16(desp: byte): integer;
   function mem_page(x: word): word;
   function mem_offset(x: word): word;
   procedure reset_memory_banks;
   procedure select_rom;
   function PageToStr(page: byte): string;


implementation

function PageToStr(page: byte): string;
begin
  if page < 32 then
    PageToStr := 'RAM'+ IntToStr(page)
  else
    PageToStr := 'ROM'+ IntToStr(page-32);
end;

procedure select_rom;
begin
  case rom_bank of
    0: Mem_banks[0] := ROMPAGE0;
    1: Mem_banks[0] := ROMPAGE1;
    2: Mem_banks[0] := ROMPAGE2;
    3: Mem_banks[0] := ROMPAGE3;
  end;
end;

procedure reset_memory_banks;
begin
  rom_bank := 0;
  case options.machine of
    Spectrum48: begin
      Mem_banks[0] := ROMPAGE0;
      Mem_banks[1] := 1;
      Mem_banks[2] := 2;
      Mem_banks[3] := 3;
    end;
    Spectrum128,Spectrum_plus2,Spectrum_plus2a,Spectrum_plus3: begin
      Mem_banks[0] := ROMPAGE0;
      Mem_banks[1] := SCREENPAGE;
      Mem_banks[2] := 2;
      Mem_banks[3] := 0;
    end;
  end;
end;


procedure save_cpu_status;
begin
    cpu_backup.registers := registers;
    cpu_backup.iff1 := iff1;
    cpu_backup.iff2 := iff2;
    cpu_backup.im := im;
    cpu_backup.r := r;
    cpu_backup.i := i;
    cpu_backup.ix := ix;
    cpu_backup.iy := iy;
    cpu_backup.sp := sp;
    cpu_backup.pc := pc;
    cpu_backup.halted := halted;
    cpu_backup.intpend := intpend;
    cpu_backup.NMI := NMI;
end;

procedure restore_cpu_status;
begin
    registers := cpu_backup.registers;
    iff1 := cpu_backup.iff1;
    iff2 := cpu_backup.iff2;
    im := cpu_backup.im;
    r := cpu_backup.r;
    i := cpu_backup.i;
    ix := cpu_backup.ix;
    iy := cpu_backup.iy;
    sp := cpu_backup.sp;
    pc := cpu_backup.pc;
    halted := cpu_backup.halted;
    intpend := cpu_backup.intpend;
    NMI := cpu_backup.NMI;
end;

procedure inc_register_r;
begin
     inc(r);
     r := (r and $7f) or r_bit7;
end;

function parity(a: byte): byte;
var
   partable: array [0..255] of byte=(
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      0, 4, 4, 0, 4, 0, 0, 4, 4, 0, 0, 4, 0, 4, 4, 0,
      4, 0, 0, 4, 0, 4, 4, 0, 0, 4, 4, 0, 4, 0, 0, 4
   );

begin
    parity := partable[a];
end;


function iffb(cond: boolean; yes: byte; no: byte): byte;
begin
    if(cond) then iffb := yes else iffb := no;
end;

function iffc(cond: boolean; yes: char; no: char): char; inline;
begin
    if(cond) then iffc := yes else iffc := no;
end;


procedure compose_flags;
begin
    f := c_flag or n_flag or pv_flag or n3_flag or h_flag or n5_flag or z_flag or s_flag;
end;

procedure explode_flags;
begin
  c_flag  := f and FLAG_C;
  n_flag  := f and FLAG_N;
  pv_flag := f and FLAG_PV;
  n3_flag := f and FLAG_3;
  h_flag  := f and FLAG_H;
  n5_flag := f and FLAG_5;
  z_flag  := f and FLAG_Z;
  s_flag  := f and FLAG_S;
end;

//Mem_banks: array[0..3] of byte = (0,1,2,3);

function mem_page(x: word): word;
begin
     mem_page := Mem_Banks[x div $4000];
end;

function mem_offset(x: word): word;
begin
     mem_offset := x mod $4000;
end;

procedure wrmem(x: word; y: byte);
begin
     if x >= 16384 then
     begin
        MemP[mem_page(x), mem_offset(x)] := y;
        //Mem[x] := y;
     end;
end;


// store 8 bit value y at 16 bit location x
procedure store(x: word; y: byte);
begin
 wrmem(x,y);
    //if (x = $5c91) and (y>0) then
    //   a := a;
end;

// store 8 bit value y at 16 bit location x
procedure store2b(x: word; hi: byte; lo: byte);
begin
    wrmem(x,lo);
    wrmem(x+1,hi);
end;

procedure store2(x: word; y: word);
begin
    store2b(x,y>>8,y and 255);
end;

function rdmem(addr: word): byte;
begin
    rdmem := MemP[mem_page(addr), mem_offset(addr)];// Mem[addr];
end;

function rdmem_signed(addr: word): shortint;
var
   tmp: byte;
begin
     tmp := MemP[mem_page(addr), mem_offset(addr)];// Mem[addr];
     rdmem_signed := shortint(tmp);
end;

//function fetch(addr: word): byte;
//begin
//    fetch := rdmem(addr);
//end;

function fetch_pc: byte;
var
   t: word;
begin
    t := rdmem(pc);
    inc(pc);
    fetch_pc := t;
end;

function signed_fetch_pc: int8;
var
   t: byte;
   s: int8 absolute t;
begin
     t := fetch_pc;
     signed_fetch_pc := s;
end;

function rdmem2(addr: word): word;
begin
     rdmem2 := ((rdmem(addr+1)<<8)or rdmem(addr));
end;

function fetch2_pc: word;
var
   v1,v2: byte;
   res: word;
begin
    v1 := rdmem(pc+1);
    v2 := rdmem(pc);
    res := (v1<<8) or v2;
    pc+=2;
    fetch2_pc := res;
end;

procedure swap(var x: byte; var y: byte);
var
   dummy: byte;
begin
     dummy := x;
     x := y;
     y := dummy;
end;

procedure set_z_flag(reg: byte);
begin
     z_flag := iffb(reg=0, FLAG_Z, 0);
end;

procedure set_s_flag(reg: byte);
begin
     s_flag := iffb(reg>127, FLAG_S, 0);
end;

procedure set_3_flag(reg: byte);
begin
     n3_flag := reg and FLAG_3;
end;

procedure set_5_flag(reg: byte);
begin
     n5_flag := reg and FLAG_5;
end;

function desp8_to_16(desp: byte): integer;
var
   desp16: integer;

begin
  if (desp>127) then
  begin
    desp:=256-desp;
    desp16:=-desp;
  end else begin
    desp16:=desp;
  end;

  desp8_to_16 := desp16;
end;

procedure set_a_flags;
begin
  f := c_flag;
  explode_flags;
  set_sz53_flags(a);
  if iff2 then
     pv_flag := FLAG_PV;
  compose_flags;
end;

procedure set_sz53_flags(reg: byte);
begin
  set_z_flag(reg);
  set_s_flag(reg);
  set_3_flag(reg);
  set_5_flag(reg);
end;
procedure set_sz53p_flags(reg: byte);
begin
  set_z_flag(reg);
  set_s_flag(reg);
  set_3_flag(reg);
  set_5_flag(reg);
  pv_flag := parity(reg);
end;

procedure set_high(var reg: word; v: byte);
begin
  reg := (reg and $00FF) or (v << 8);
  inc(t_states,11);
end;

procedure set_low(var reg: word; v: byte);
begin
  reg := (reg and $FF00) or v;
  inc(t_states,11);
end;

function add_16bit(reg, op: cardinal): cardinal;  // 16-bit add
var
   antes, res: longint;
   lookup, t: byte;
begin
    antes := reg;
    res := reg+op;

    lookup := ( (  (reg) and $0800 ) >> 11 ) or
             ( (  (op) and $0800 ) >> 10 ) or
             ( (   res and $0800 ) >>  9 );

    t := (res >> 8) and $ff;
//    if res > $ffff then
//       c_flag := FLAG_C
//    else
//       c_flag := $00;
//
//    if (hl<=$7fff) and (res > $7fff) then
//       h_flag := FLAG_H
//    else
//       h_flag := $00;
//
//    hl := res and $ffff;
//
////    f :=(f and $c4); // borramos los flags H, N y C
//
////    f := f or h_ or carry;

    set_undocumented_flags_bits(t);
    set_flags_carry_16_suma(antes,res);

    h_flag := halfcarry_add_table[lookup];
    n_flag := 0;

    compose_flags;
    inc(t_states, 15);
    add_16bit := res;
end;


procedure set_undocumented_flags_bits(value: byte);
begin
    n3_flag := value and FLAG_3;
    n5_flag := value and FLAG_5;
end;

procedure set_undocumented_flags_bits_memptr(memptr: word);
begin
     n3_flag := (memptr >> 8) and FLAG_3;
     n5_flag := (memptr >> 8) and FLAG_5;
end;

procedure set_flags_carry_16_suma(antes,result: word);
begin
  if (result<antes) then c_flag := FLAG_C
  else c_flag := 0;
end;


procedure set_flags_zero_sign_16(value: word);
begin
     z_flag := iffb(value = 0, FLAG_Z,0);
     s_flag := iffb((value and 32768) <> 0, FLAG_S,0);
end;

procedure set_flags_zero_sign(value: byte);
begin
     z_flag := iffb(value = 0, FLAG_Z,0);
     s_flag := value and FLAG_S;// iffb((value and FLAG_S) <> 0, FLAG_S,0);
end;

procedure set_flags_in(val: byte);
begin
  set_sz53p_flags(val);
  h_flag  := 0;
  n_flag  := 0;
end;

procedure set_flags_halfcarry_suma(antes, result: Byte);
begin
  antes:=antes and $F;
  result:=result and $F;

  if result<antes then h_flag :=FLAG_H
  else h_flag := 0;
end;

procedure set_flags_carry_suma(antes, result: byte);
begin
  if result<antes then
     c_flag := FLAG_C
  else c_flag := 0;

  set_flags_halfcarry_suma(antes,result);
end;

procedure set_flags_overflow_suma(antes,result: byte);
//Well as stated in chapter 3 if the result of an operation in two's complement produces a result that's signed incorrectly then there's an overflow
//o So overflow flag = carry-out flag XOR carry from bit 6 into bit 7.
var
   overflow67: byte;
begin
	//127+127=254 ->overflow    01111111 01111111 = 11111110    NC   67=y    xor=1
	//-100-100=-200 -> overflow 10011100 10011100 = 00111000     C    67=n   xor=1

	//-2+127=125 -> no overflow 11111110 01111111 = 11111101     C    67=y   xor=0
	//127-2=125 -> no overlow   01111111 11111110 = 11111101     C    67=y   xor=0

	//10-100=-90 -> no overflow 00001010 10011100 = 10100110    NC    67=n   xor=0

        if (result and 127) < (antes and 127) then overflow67:=FLAG_C
        else overflow67:=0;

	if (c_flag xor overflow67)<>0 then pv_flag := FLAG_PV
	else pv_flag := 0;
end;

procedure set_flags_rrd_rld;
begin
  set_sz53p_flags(a);

  h_flag  := 0;
  pv_flag := parity(a);
  n_flag  := 0;
end;


function hi(reg: word): byte;
begin
     hi := reg >> 8;
end;

function lo(reg: word): byte;
begin
     lo := reg and $ff;
end;

procedure invalid_instruction;
begin

end;

end.

