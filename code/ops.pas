unit Ops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure daa;
function parity(a: byte): byte; inline;
function iffb(cond: boolean; yes: byte; no: byte): byte; inline;
procedure compose_flags; inline;
procedure wrmem(x: word; y: byte); inline;
// store 8 bit value y at 16 bit location x
procedure store(x: word; y: byte); inline;
// store 8 bit value y at 16 bit location x
procedure store2b(x: word; hi: byte; lo: byte); inline;
procedure store2(x: word; y: word); inline;
function rdmem(addr: word): byte; inline;
function fetch_pc: byte; inline;
function signed_fetch_pc: int8; inline;
function rdmem2(addr: word): word; inline;
function fetch2_pc: word; inline;
procedure swap(var x: byte; var y: byte); inline;
procedure inc_8bit(var reg: byte);
procedure dec_8bit(var reg: byte);
//Activa los flags 5,3 segun valor
procedure set_undocumented_flags_bits(value: byte); inline;
function add_16bit(reg, op: cardinal): cardinal; inline; // 16-bit add
procedure adda(v: byte); inline;

var
   n3_flag, n5_flag, c_flag, h_flag, n_flag, z_flag, s_flag, pv_flag: byte;

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
   Mem: Array[0..65535] of byte;
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
   r, i: Byte;
   pc: word;
   ix, iy, sp: word;

   // some flags
   intpend: boolean = false;
//   new_ixoriy: byte=0;
//   ixoriy: Byte=0;
   halfcarry_add_table: Array[0..7] of byte =(0, FLAG_H, FLAG_H, FLAG_H, 0, 0, 0, FLAG_H );

implementation

procedure daa;
var
    low_a,high_a: byte;
    diff: byte =0;
    f_C: byte =0;
    flag_H_final: byte =0;

begin
{   N   C   Value of     H  Value of     Hex no   C flag after
            high nibble     low nibble   added    execution
    0   0      0-9       0     0-9       00       0 +
    0   0      0-8       0     A-F       06       0 +
    0   0      0-9       1     0-3       06       0 +
    0   0      A-F       0     0-9       60       1 +
    0   0      9-F       0     A-F       66       1 +
    0   0      A-F       1     0-3       66       1 +
    0   1      0-2       0     0-9       60       1 +
    0   1      0-2       0     A-F       66       1 +
    0   1      0-3       1     0-3       66       1 +
    1   0      0-9       0     0-9       00       0 +
    1   0      0-8       1     6-F       FA       0 +
    1   1      7-F       0     0-9       A0       1
    1   1      6-F       1     6-F       9A       1}
    //Calculo de valor a sumar

    low_a:=a and $F;
    high_a:=(a>>4) and $F;

    if n_flag =0 then
    begin
      if (c_flag =0) and ((high_a>=$0) and (high_a<=$9)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$00; f_C :=      0; end;
      if (c_flag =0) and ((high_a>=$0) and (high_a<=$8)) and (flag_H =0) and ((low_a>=$a) and (low_a<=$f)) then begin diff:=$06; f_C :=      0; end;
      if (c_flag =0) and ((high_a>=$0) and (high_a<=$9)) and (flag_H<>0) and ((low_a>=$0) and (low_a<=$3)) then begin diff:=$06; f_C :=      0; end;
      if (c_flag =0) and ((high_a>=$0) and (high_a<=$2)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$60; f_C := FLAG_C; end;
      if (c_flag =0) and ((high_a>=$9) and (high_a<=$f)) and (flag_H =0) and ((low_a>=$a) and (low_a<=$f)) then begin diff:=$66; f_C := FLAG_C; end;
      if (c_flag =0) and ((high_a>=$a) and (high_a<=$f)) and (flag_H<>0) and ((low_a>=$0) and (low_a<=$3)) then begin diff:=$66; f_C := FLAG_C; end;
      if (c_flag<>0) and ((high_a>=$0) and (high_a<=$2)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$60; f_C := FLAG_C; end;
      if (c_flag<>0) and ((high_a>=$0) and (high_a<=$2)) and (flag_H =0) and ((low_a>=$a) and (low_a<=$f)) then begin diff:=$66; f_C := FLAG_C; end;
      if (c_flag<>0) and ((high_a>=$0) and (high_a<=$3)) and (flag_H<>0) and ((low_a>=$0) and (low_a<=$3)) then begin diff:=$66; f_C := FLAG_C; end;
    end else
    begin
      if (c_flag =0) and ((high_a>=$0) and (high_a<=$9)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$00; f_C :=      0; end;
      if (c_flag =0) and ((high_a>=$0) and (high_a<=$8)) and (flag_H<>0) and ((low_a>=$6) and (low_a<=$f)) then begin diff:=$fa; f_C :=      0; end;
      if (c_flag<>0) and ((high_a>=$7) and (high_a<=$f)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$a0; f_C := FLAG_C; end;
      if (c_flag<>0) and ((high_a>=$6) and (high_a<=$f)) and (flag_H<>0) and ((low_a>=$6) and (low_a<=$f)) then begin diff:=$9a; f_C := FLAG_C; end;
    end;

    a +=diff;

    //Calculo de flags

    s_flag    := iffb((a and $80) <> 0, FLAG_S, 0);
    z_flag    := iffb(a=0,FLAG_Z,0);
    pv_flag   := parity(a);
    c_flag    := f_C;

//    f=(f and (255-FLAG_C)) | flag_C_final;


    //Calculo flag H

    if (f and FLAG_N =0) and                (low_a>=$a) and (low_a<=$f) then flag_H_final:=FLAG_H;


    if (f and FLAG_N<>0) and (f and FLAG_H <> 0) and (low_a>=$0) and (low_a<=$5) then flag_H_final:=FLAG_H;

    h_flag := flag_H_final;

    compose_flags;
    // f=(f and (255-FLAG_H-FLAG_S-FLAG_Z-FLAG_3-FLAG_5-FLAG_PV)) | flag_H_final | sz53p_table[reg_a];


end;

function parity(a: byte): byte; inline;
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


function iffb(cond: boolean; yes: byte; no: byte): byte; inline;
begin
    if(cond) then iffb := yes else iffb := no;
end;

procedure compose_flags; inline;
begin
    f := c_flag or n_flag or pv_flag or n3_flag or h_flag or n5_flag or z_flag or s_flag;
end;

procedure wrmem(x: word; y: byte); inline;
begin
     Mem[x] := y;
end;


// store 8 bit value y at 16 bit location x
procedure store(x: word; y: byte); inline;
begin
 wrmem(x,y);
end;

// store 8 bit value y at 16 bit location x
procedure store2b(x: word; hi: byte; lo: byte); inline;
begin
    wrmem(x,lo);
    wrmem(x+1,hi);
end;

procedure store2(x: word; y: word); inline;
begin
    store2b(x,y>>8,y and 255);
end;

function rdmem(addr: word): byte; inline;
begin
    rdmem := Mem[addr];
end;

//function fetch(addr: word): byte; inline;
//begin
//    fetch := rdmem(addr);
//end;

function fetch_pc: byte; inline;
begin
    fetch_pc := rdmem(pc);
    inc(pc);
end;

function signed_fetch_pc: int8; inline;
var
   t: byte;
   s: int8 absolute t;
begin
     t := fetch_pc;
     signed_fetch_pc := s;
end;

function rdmem2(addr: word): word; inline;
begin
     rdmem2 := ((rdmem((addr)+1)<<8)or rdmem(addr));
end;

function fetch2_pc: word; inline;
begin
     fetch2_pc := ((rdmem((pc)+1)<<8)or rdmem(pc));
     pc+=2;
end;

procedure swap(var x: byte; var y: byte); inline;
var
   dummy: byte;
begin
     dummy := x;
     x := y;
     y := dummy;
end;

procedure inc_8bit(var reg: byte);
begin
  inc(reg);
  n_flag := 0;
  pv_flag := iffb(reg=128, FLAG_PV, 0);
  h_flag := iffb((reg and $0f)<>0, 0, FLAG_H);
  z_flag := iffb(reg=0, FLAG_Z, 0);
  s_flag := iffb(reg>127, FLAG_S, 0);
  compose_flags;
end;

procedure dec_8bit(var reg: byte);
begin
  if reg and $0f <> 0 then h_flag := 0 else h_flag := FLAG_H;
  h_flag := iffb((reg and $0f) <> 0, 0, FLAG_H);
  dec(reg);
  n_flag := FLAG_N;
  pv_flag := iffb(reg=127, FLAG_PV, 0);
  z_flag := iffb(reg=0, FLAG_Z, 0);
  s_flag := iffb(reg>127, FLAG_S, 0);
  compose_flags;
end;

//Activa los flags 5,3 segun valor
procedure set_undocumented_flags_bits(value: byte); inline;
begin
    n3_flag := value and FLAG_3;
    n5_flag := value and FLAG_5;
//     f := (f and (255-FLAG_3-FLAG_5)) or ( value and ( FLAG_3 or FLAG_5 ) );
end;


function add_16bit(reg, op: cardinal): cardinal; inline; // 16-bit add
var
   res: longint;
begin
    res := reg+op;

{    lookup := ( (  (reg) and $0800 ) >> 11 ) or
             ( (  (op) and $0800 ) >> 10 ) or
             ( (   res and $0800 ) >>  9 );

}    if res > $ffff then
       c_flag := FLAG_C
    else
       c_flag := $00;

    if (hl<=$7fff) and (res > $7fff) then
       h_flag := FLAG_H
    else
       h_flag := $00;

    hl := res and $ffff;

//    f :=(f and $c4); // borramos los flags H, N y C

//    f := f or h_ or carry;

    set_undocumented_flags_bits(h);
    compose_flags;
    add_16bit := res;
end;

procedure adda(v: byte); inline;
begin

end;

end.

