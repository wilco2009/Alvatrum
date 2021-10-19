unit Z80ops;

{$mode objfpc}{$H+}
{$MACRO ON}

interface

uses
  Classes, SysUtils, Z80Globals, z80bitops, spectrum;

// STACK

function pop2: word;
procedure push2(v: word);

procedure popr(var r: word);
procedure popaf;
procedure pop_IXIY(var r: word);
procedure pushr(var r: word);
procedure push_IXIY(var r: word);

// OTHERS
procedure int_mode(n: byte);
procedure halt;
procedure daa;
procedure disable_int;
procedure enable_int;

// FLAGS
procedure set_flags_halfcarry_resta(antes,result: byte);
procedure set_flags_carry_resta(antes,result: byte);
procedure set_flags_overflow_resta(antes,result: byte);
function ZERO: boolean;
function NO_ZERO: boolean;
function CARRY: boolean;
function NO_CARRY: boolean;
function NEGATIVE: boolean;
function POSITIVE: boolean;
function PARITY_EVEN: boolean;
function PARITY_ODD: boolean;

// LOGIC
procedure anda(v: byte);
procedure andareg(reg: byte);
procedure anda_mem8r(addr: word);
procedure anda_n;
procedure xora(v: byte);
procedure xorareg(reg: byte);
procedure xora_mem8r(addr: word);
procedure xoran;
procedure ora(v: byte);
procedure orareg(reg: byte);
procedure ora_mem8r(addr: word);
procedure oran;
procedure cpa(v: byte);
procedure cpareg(reg: byte);
procedure cpa_mem8r(addr: word);
procedure cpan;

procedure anda_ixiy_mem8(reg: word);
procedure ora_ixiy_reg8(r: byte);
procedure xora_ixiy_reg8(r: byte);
procedure cpa_ixiy_reg8(r: byte);
procedure ora_ixiy_mem8(reg: word);
procedure xora_ixiy_mem8(reg: word);
procedure cpa_ixiy_mem8(reg: word);

// FLOW CONTROL
procedure ret;
procedure retn;
procedure reti;
procedure call(addr: word);
procedure calln;
procedure rst(n: byte);
procedure retc(cond: boolean);
procedure jrc(cond: boolean);
procedure callc(cond: boolean);
procedure jpc(cond: boolean);
procedure jmp;
procedure djnz;
procedure jr;
procedure jphl;
procedure jp_ixiy(reg: word);

// INPUT / OUTPUT
procedure z80out(port: word; v: byte);
function z80in(port: word): byte;
procedure in_c_f;
procedure in_c(var v: byte);
procedure in_n;
procedure out_c(v: byte);
procedure out_n;
procedure ini;
procedure inir;
procedure outi;
procedure otir;
procedure ind;
procedure indr;
procedure outd;
procedure otdr;

// EX
procedure EX_reg_reg(var reg1: word; var reg2: word);
procedure EX_af_af1;
procedure EX_mem_reg(addr: word; var reg: word);
procedure EX_mem_hl;
procedure EX_mem_ixiy(var reg: word);
procedure EXX;

//LD
procedure ld_reg8_reg8(var r1: byte; r2: byte);
procedure ld_reg8_n(var reg: byte);
procedure ld_reg8_mem8(var reg: byte);
procedure ld_reg8_mem8r(var r1: byte; r2: word);
procedure ld_mem8r_reg(reg16: word; reg8:byte);
procedure ld_mem8r_n(reg16: word);
procedure ld_mem8_reg8(var reg: byte);

procedure ld_reg16_n(var reg: word);
procedure ld_hl_mem16;
procedure ld_mem16_hl;
procedure ld_SP_reg16(var reg: word);

// LD EXTENDED OPCODES
procedure e_ld_reg8_reg8(var r1: byte; r2: byte);
procedure e_ld_i_a;
procedure e_ld_r_a;
procedure e_ld_a_reg8(r2: byte);
procedure e_ld_mem16_reg16(reg: word);
procedure e_ld_reg16_mem16(var reg: word);

// LD IX/IY
procedure ld_ixiy_reg8(regixiy: word; reg8: byte);
procedure ld_ixiy_nn(var reg: word);
procedure ld_SP_ixiy(var reg: word);
procedure ld_mem_ixiy_nn(reg: word);

procedure ld_ixiy_mem16(var reg: word);
procedure ld_mem16_ixiy(reg: word);

procedure set_high_ixiy(var reg: word; v: byte);
procedure set_low_ixiy(var reg: word; v: byte);
procedure set_low_ixiy_mem(var reg: word; regxiyi: word);
procedure set_high_ixiy_mem(var reg: word; regxiyi: word);

// BIT HANDLE
procedure neg_a;
procedure rrca;
procedure rlca;
procedure rla;
procedure rra;
procedure scf;
procedure ccf;
procedure rld;
procedure rrd;
procedure ldi;
procedure ldir;
procedure cpl;
procedure cpi;
procedure cpir;
procedure ldd;
procedure lddr;
procedure cpd;
procedure cpdr;

// 8 BIT ARITHMETIC
procedure suba(v: byte);
procedure suban;
procedure sbca(v: byte);
procedure sbcan;
procedure subareg(reg: byte);
procedure sbcareg(reg: byte);
procedure suba_mem8r(addr: word);
procedure sbca_mem8r(addr: word);
procedure adda(v: byte);
procedure addan;
procedure adcan;
procedure adca(v: byte);
procedure addareg(v: byte);
procedure adcareg(v: byte);
procedure adca_mem8r(r: word);
procedure adda_mem8r(r: word);
procedure adda_ixiy_reg8(r: byte);
procedure adca_ixiy_reg8(r: byte);
procedure suba_ixiy_reg8(r: byte);
procedure sbca_ixiy_reg8(r: byte);
procedure anda_ixiy_reg8(r: byte);

procedure adda_ixiy_mem8(reg: word);
procedure adca_ixiy_mem8(reg: word);
procedure suba_ixiy_mem8(reg: word);
procedure sbca_ixiy_mem8(reg: word);

// 16 BIT ARITHMETIC
procedure add_ixiy_reg16(var reg1: word; reg2: word);
procedure add_reg16_reg16(var reg1: word; reg2: word);
function sbc_16bit(reg: word; value: word): word;
function adc_16bit(reg: word; value: word): word;

// INC/DEC
procedure inc_8bit(var reg: byte);
procedure dec_8bit(var reg: byte);
procedure inc16(var reg: word);
procedure dec16(var reg: word);

procedure inc_ixiy(var reg: word);
procedure dec_ixiy(var reg: word);

procedure inc_high_ixiy(var reg: word);
procedure dec_high_ixiy(var reg: word);
procedure inc_low_ixiy(var reg: word);
procedure dec_low_ixiy(var reg: word);

procedure inc_mem(addr: word);
procedure dec_mem(addr: word);

implementation

// ****************** STACK *************************************

function pop2: word;
begin
  pop2 := rdmem2(sp);
  inc(sp,2);
end;

procedure push2(v: word);
begin
  dec(sp,2);
  store2(sp,v);
end;

procedure popr(var r: word);
begin
  r := pop2;
  inc(t_states,10);
end;

procedure popaf;
begin
  af := pop2;
  explode_flags;
  inc(t_states,10);
end;

procedure pop_IXIY(var r: word);
begin
  r := pop2;
  inc(t_states,14);
end;

procedure pushr(var r: word);
begin
  push2(r);
  inc(t_states,11);
end;

procedure push_IXIY(var r: word);
begin
  push2(r);
  inc(t_states,15);
end;

// ******************* OTHERS *******************************************

procedure halt;
begin
   dec(pc);
   halted := true;
   inc(t_states,4);
end;

procedure int_mode(n: byte);
begin
     im:=n;
     inc(t_states, 8);
end;

procedure disable_int;
begin
  iff1:=false; iff2:=false;
  inc(t_states,4);
end;

procedure enable_int;
begin
     iff1:=true; iff2:=true;
     intpend := false;
     inc(t_states,4);
end;

procedure daa;
var
    low_a,high_a: byte;
    diff: byte =0;
    f_C: byte =0;
    flag_H_final: byte =0;

begin
  diff := 0;
  flag_H_final := 0;
  f_C := 0;
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

    //if n_flag =0 then
    //begin
    //  if (c_flag =0) and ((high_a>=$0) and (high_a<=$9)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$00; f_C :=      0; end;
    //  if (c_flag =0) and ((high_a>=$0) and (high_a<=$8)) and (flag_H =0) and ((low_a>=$a) and (low_a<=$f)) then begin diff:=$06; f_C :=      0; end;
    //  if (c_flag =0) and ((high_a>=$0) and (high_a<=$9)) and (flag_H<>0) and ((low_a>=$0) and (low_a<=$3)) then begin diff:=$06; f_C :=      0; end;
    //  if (c_flag =0) and ((high_a>=$0) and (high_a<=$2)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$60; f_C := FLAG_C; end;
    //  if (c_flag =0) and ((high_a>=$9) and (high_a<=$f)) and (flag_H =0) and ((low_a>=$a) and (low_a<=$f)) then begin diff:=$66; f_C := FLAG_C; end;
    //  if (c_flag =0) and ((high_a>=$a) and (high_a<=$f)) and (flag_H<>0) and ((low_a>=$0) and (low_a<=$3)) then begin diff:=$66; f_C := FLAG_C; end;
    //  if (c_flag<>0) and ((high_a>=$0) and (high_a<=$2)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$60; f_C := FLAG_C; end;
    //  if (c_flag<>0) and ((high_a>=$0) and (high_a<=$2)) and (flag_H =0) and ((low_a>=$a) and (low_a<=$f)) then begin diff:=$66; f_C := FLAG_C; end;
    //  if (c_flag<>0) and ((high_a>=$0) and (high_a<=$3)) and (flag_H<>0) and ((low_a>=$0) and (low_a<=$3)) then begin diff:=$66; f_C := FLAG_C; end;
    //end else
    //begin
    //  if (c_flag =0) and ((high_a>=$0) and (high_a<=$9)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$00; f_C :=      0; end;
    //  if (c_flag =0) and ((high_a>=$0) and (high_a<=$8)) and (flag_H<>0) and ((low_a>=$6) and (low_a<=$f)) then begin diff:=$fa; f_C :=      0; end;
    //  if (c_flag<>0) and ((high_a>=$7) and (high_a<=$f)) and (flag_H =0) and ((low_a>=$0) and (low_a<=$9)) then begin diff:=$a0; f_C := FLAG_C; end;
    //  if (c_flag<>0) and ((high_a>=$6) and (high_a<=$f)) and (flag_H<>0) and ((low_a>=$6) and (low_a<=$f)) then begin diff:=$9a; f_C := FLAG_C; end;
    //end;
    //
    //a +=diff;

    if (c_flag=0)  and (high_a>=$0) and (high_a<=$9) and (h_flag=0)  and (low_a>=$0) and (low_a<=$9) then diff:=$00;
    if (c_flag=0)  and (high_a>=$0) and (high_a<=$9) and (h_flag<>0) and (low_a>=$0) and (low_a<=$9) then diff:=$06;
    if (c_flag=0)  and (high_a>=$0) and (high_a<=$8) and                 (low_a>=$a) and (low_a<=$f) then diff:=$06;
    if (c_flag=0)  and (high_a>=$a) and (high_a<=$f) and (h_flag=0)  and (low_a>=$0) and (low_a<=$9) then diff:=$60;
    if (c_flag<>0) and                                   (h_flag=0)  and (low_a>=$0) and (low_a<=$9) then diff:=$60;
    if (c_flag<>0) and                                   (h_flag<>0) and (low_a>=$0) and (low_a<=$9) then diff:=$66;
    if (c_flag<>0) and                                                   (low_a>=$a) and (low_a<=$f) then diff:=$66;
    if (c_flag=0)  and (high_a>=$9) and (high_a<=$f) and                 (low_a>=$a) and (low_a<=$f) then diff:=$66;
    if (c_flag=0)  and (high_a>=$a) and (high_a<=$f) and (h_flag<>0) and (low_a>=$0) and (low_a<=$9) then diff:=$66;

    if (n_flag=0) then a +=diff
    else a -=diff;

    //Calculo de flags

    if (c_flag=0) and (high_a>=$9) and (high_a<=$f) and (low_a>=$a) and (low_a<=$f) then f_C:=FLAG_C;

    if (c_flag=0) and (high_a>=$a) and (high_a<=$f) and (low_a>=$0) and (low_a<=$9) then f_C:=FLAG_C;

    if (c_flag<>0)                                                                  then f_C:=FLAG_C;

    c_flag    := f_C;

//    f=(f and (255-FLAG_C)) | flag_C_final;


    //Calculo flag H

    if (n_flag=0) and                (low_a>=$a) and (low_a<=$f) then flag_H_final:=FLAG_H;


    if (n_flag<>0) and (h_flag<>0) and (low_a>=$0) and (low_a<=$5) then flag_H_final:=FLAG_H;

    h_flag := flag_H_final;

    set_sz53p_flags(a);
    compose_flags;
    // f=(f and (255-FLAG_H-FLAG_S-FLAG_Z-FLAG_3-FLAG_5-FLAG_PV)) | flag_H_final | sz53p_table[reg_a];


end;

// ******************* FLAGS *********************************************

//La mayoria de veces se llama aqui desde set_flags_carry_, dado que casi todas las operaciones que tocan el carry tocan el halfcarry
//hay algunas operaciones, como inc8, que tocan el halfcarry pero no el carry
procedure set_flags_halfcarry_resta(antes,result: byte);
begin
  antes:=antes and $F;
  result:=result and $F;

  if (result>antes) then h_flag:=FLAG_H
  else h_flag := 0;
end;

procedure set_flags_carry_resta(antes,result: byte);
begin
  if (result>antes) then c_flag :=FLAG_C
  else c_flag := 0;

  set_flags_halfcarry_resta(antes,result);
end;

procedure set_flags_overflow_resta(antes,result: byte);

//Siempre llamar a esta funcion despues de haber actualizado el Flag de Carry, pues lo utiliza

//Well as stated in chapter 3 if the result of an operation in two's complement produces a result that's signed incorrectly then there's an overflow
//o So overflow flag = carry-out flag XOR carry from bit 6 into bit 7.
var
   overflow67: byte;


begin
  //127+127=254 ->overflow    01111111 01111111 = 11111110    NC   67=y    xor=1
  //-100-100=-200 -> overflow 10011100 10011100 = 100111000    C    67=n   xor=1

  //-2+127=125 -> no overflow 11111110 01111111 = 11111101     C    67=y   xor=0
  //127-2=125 -> no overlow   01111111 11111110 = 11111101     C    67=y   xor=0

  //10-100=-90 -> no overflow 00001010 10011100 = 10100110    NC    67=n   xor=0

  if ( (result and 127) > (antes and 127) ) then overflow67:=FLAG_C
  else overflow67:=0;

  if ( c_flag xor overflow67) <> 0 then pv_flag :=FLAG_PV
  else pv_flag := 0;
end;

function ZERO: boolean;
begin
     ZERO        := z_flag  <> 0;
end;

function NO_ZERO: boolean;
begin
     NO_ZERO     := z_flag   = 0;
end;

function CARRY: boolean;
begin
     CARRY        := c_flag  <> 0;
end;

function NO_CARRY: boolean;
begin
     NO_CARRY     := c_flag   = 0;
end;

function NEGATIVE: boolean;
begin
     NEGATIVE    := s_flag  <> 0;
end;

function POSITIVE: boolean;
begin
     POSITIVE    := s_flag   = 0;
end;

function PARITY_EVEN: boolean;
begin
     PARITY_EVEN := pv_flag <> 0;
end;

function PARITY_ODD: boolean;
begin
     PARITY_ODD  := pv_flag  = 0;
end;

// ******************* LOGIC *********************************************

procedure anda_ixiy_reg8(r: byte);
begin
    anda(r);
    inc(t_states,8);
end;

procedure anda_ixiy_mem8(reg: word);
begin
    anda(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure ora_ixiy_reg8(r: byte);
begin
    ora(r);
    inc(t_states,8);
end;

procedure ora_ixiy_mem8(reg: word);
begin
    ora(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure xora_ixiy_reg8(r: byte);
begin
    xora(r);
    inc(t_states,8);
end;

procedure xora_ixiy_mem8(reg: word);
begin
    xora(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure cpa_ixiy_reg8(r: byte);
begin
    cpa(r);
    inc(t_states,8);
end;

procedure cpa_ixiy_mem8(reg: word);
begin
    cpa(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure anda(v: byte);
begin
  a := a and v;
  set_sz53p_flags(a);
  h_flag := FLAG_H;
  n_flag := 0;
  c_flag := 0;
  compose_flags;
end;

procedure andareg(reg: byte);
begin
  anda(reg);
  inc(t_states,4);
end;

procedure anda_mem8r(addr: word);
begin
  anda(rdmem(addr));
  inc(t_states,7);
end;

procedure anda_n;
begin
  anda(fetch_pc);
  inc(t_states,7);
end;

procedure xora(v: byte);
begin
  a := a xor v;
  set_sz53_flags(a);
  h_flag := 0;
  n_flag := 0;
  c_flag := 0;
  pv_flag := parity(a);
  compose_flags;
end;

procedure xorareg(reg: byte);
begin
  xora(reg);
  inc(t_states,4);
end;

procedure xora_mem8r(addr: word);
begin
  xora(rdmem(addr));
  inc(t_states,7);
end;

procedure xoran;
begin
  xora(fetch_pc);
  inc(t_states,7);
end;



procedure ora(v: byte);
begin
  a := a or v;
  set_sz53_flags(a);
  h_flag := 0;
  n_flag := 0;
  c_flag := 0;
  pv_flag := parity(a);
  compose_flags;
end;

procedure orareg(reg: byte);
begin
  ora(reg);
  inc(t_states,4);
end;

procedure ora_mem8r(addr: word);
begin
  ora(rdmem(addr));
  inc(t_states,7);
end;

procedure oran;
begin
  ora(fetch_pc);
  inc(t_states,7);
end;

procedure cpa(v: byte);
var
   antes, result: byte;
begin
  set_undocumented_flags_bits(v);
  antes := a;
  result := byte(integer(a)-v);
  set_flags_zero_sign(result);
  set_flags_carry_resta(antes,result);
  set_flags_overflow_resta(antes,result);
  n_flag := FLAG_N;
  compose_flags;
end;

procedure cpareg(reg: byte);
begin
  cpa(reg);
  inc(t_states,4);
end;

procedure cpa_mem8r(addr: word);
begin
  cpa(rdmem(addr));
  inc(t_states,7);
end;

procedure cpan;
begin
  cpa(fetch_pc);
  inc(t_states,7);
end;

// ******************* FLOW CONTROL *********************************************
procedure ret;
begin
  pc := pop2;
  inc(t_states,10);
end;

procedure retn;
begin
   iff1:=iff2;
   inc(t_states,4);    // 4 additional
   ret;
end;

procedure reti;
begin
   iff1:=iff2;
   inc(t_states,4);    // 4 additional
   ret;
end;

procedure retc(cond: boolean);
begin
  if cond then begin
    pc := pop2;
    inc(t_states,11);
  end else begin
    inc(t_states,5);
  end;
end;

procedure call(addr: word);
begin
  push2(pc);
  pc := addr;
end;

procedure calln;
begin
  call(fetch2_pc);
  inc(t_states,17);
end;

procedure rst(n: byte);
begin
  push2(pc);
  pc := n;
  inc(t_states,11);
end;

procedure jrc(cond: boolean);
begin
  if cond then begin
     pc += signed_fetch_pc;
     inc(t_states,12);
  end else begin
      inc(t_states,7);
  end;
  inc(pc);
end;

procedure callc(cond: boolean);
begin
  if cond then begin
     call(fetch2_pc);
     inc(t_states,17);
  end else begin
      pc+=2;
      inc(t_states,10);
  end;
end;

procedure jpc(cond: boolean);
var
   v: word;
begin
  if cond then
     v := fetch2_pc
  else
     v := pc+2;
  pc := v;
  inc(t_states,10);
end;

procedure jmp;
begin
  jpc(true);
end;

procedure jphl;
begin
   pc := hl;
   inc(t_states,4);
end;

procedure jp_IXIY(reg: word);
begin
   pc := reg;
   inc(t_states,8);
end;

procedure jr;
begin
     pc+=signed_fetch_pc+1;
     inc(t_states, 12);
end;

procedure djnz;
begin
     dec(b);
     if (b <> 0) then begin
       pc+= signed_fetch_pc;
       inc(t_states, 13);
     end else begin
       inc(t_states, 8);
     end;
     inc(pc);
end;

// ******************* INPUT/OUTPUT *********************************************
function z80in(port: word): byte;
begin
  z80in := spectrum_in(port);
end;

procedure z80out(port: word; v: byte);
begin
     spectrum_out(port, v);
end;

procedure out_n;
begin
     z80out((a<<8) or fetch_pc, a);
     inc(t_states,11);
end;

procedure in_c(var v: byte);
begin
  v := z80in(bc);
  set_flags_in(v);
  compose_flags;
  inc(t_states,12);
end;

procedure in_c_f;
begin
  f := z80in(bc);
  inc(t_states,12);
  explode_flags;
end;

procedure in_n;
begin
     a := z80in((word(a)<<8) or fetch_pc);
     inc(t_states,11);
end;

procedure out_c(v: byte);
begin
     z80out(bc, v);
     inc(t_states,12);
end;

procedure ini;
var
   v, aux: byte;
begin
  in_c(v);
  store(hl,v);
  dec(b);
  inc(hl);

  aux := v + c + 1;
  n_flag  := iffb((v and $80) <>0, FLAG_N, 0);
  c_flag  := iffb(aux<v, FLAG_C, 0);
  h_flag  := iffb(aux<v, FLAG_H, 0);
  set_sz53_flags(b);
  pv_flag := parity((aux and $07) xor b);
  compose_flags;
  inc(t_states, 16);
end;

procedure inir;
begin
  ini;
  if bc <> 0 then begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;

procedure outi;
var
   v, aux: byte;
begin
  v := rdmem(hl);
  dec(b);
  out_c(v);
  inc(hl);

  aux := v + l;
  n_flag  := iffb((v and $80) <>0, FLAG_N, 0);
  c_flag  := iffb(aux<v, FLAG_C, 0);
  h_flag  := iffb(aux<v, FLAG_H, 0);
  set_sz53_flags(b);
  pv_flag := parity((aux and $07) xor b);
  compose_flags;
  inc(t_states, 16);
end;

procedure otir;
begin
  outi;
  if bc <> 0 then begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;

procedure ind;
var
   v, aux: byte;
begin
  in_c(v);
  store(hl,v);
  dec(b);
  dec(hl);

  aux := v + c - 1;
  n_flag  := iffb((v and $80) <>0, FLAG_N, 0);
  c_flag  := iffb(aux<v, FLAG_C, 0);
  h_flag  := iffb(aux<v, FLAG_H, 0);
  set_sz53_flags(b);
  pv_flag := parity((aux and $07) xor b);
  compose_flags;
  inc(t_states, 16);
end;

procedure indr;
begin
  ind;
  if bc <> 0 then begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;

procedure outd;
var
   v, aux: byte;
begin
  v := rdmem(hl);
  dec(b);
  out_c(v);
  dec(hl);

  aux := v + l;
  n_flag  := iffb((v and $80) <>0, FLAG_N, 0);
  c_flag  := iffb(aux<v, FLAG_C, 0);
  h_flag  := iffb(aux<v, FLAG_H, 0);
  set_sz53_flags(b);
  pv_flag := parity((aux and $07) xor b);
  compose_flags;
  inc(t_states, 16);
end;

procedure otdr;
begin
  outd;
  if bc <> 0 then begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;

// ******************* EX *********************************************
procedure exx;
begin
   swap(b,b1);
   swap(c,c1);
   swap(d,d1);
   swap(e,e1);
   swap(h,h1);
   swap(l,l1);
   inc(t_states, 4);
end;

procedure EX_reg_reg(var reg1: word; var reg2: word);
var
   tmp: word;
begin
  tmp := reg1;
  reg1 := reg2;
  reg2 := tmp;
  inc(t_states, 4);
end;

procedure EX_af_af1;
begin
  EX_reg_reg(af,af1);
  explode_flags;
end;

procedure EX_mem_reg(addr: word; var reg: word);
var
   t: word;
begin
  t:=rdmem2(addr);
//  store2b(addr,reg>>8,reg and $ff);
  store2(addr,reg);
  reg :=t;
end;

procedure EX_mem_hl;
begin
     EX_mem_reg(sp,hl);
     inc(t_states, 19);
end;

procedure EX_mem_ixiy(var reg: word);
begin
     EX_mem_reg(sp,reg);
     inc(t_states, 23);
end;

// ******************* LD *********************************************
procedure ld_reg8_reg8(var r1: byte; r2: byte);
begin
     r1 := r2;
     inc(t_states,4);
end;

procedure ld_reg8_mem8r(var r1: byte; r2: word);
begin
    r1 := rdmem(r2);
    inc(t_states, 7);
end;

procedure ld_reg8_n(var reg: byte);
begin
     reg :=fetch_pc;
     inc(t_states,7);
end;

procedure ld_mem8r_reg(reg16: word; reg8:byte);
begin
     store(reg16,reg8);
     inc(t_states, 7);
end;

procedure ld_mem8r_n(reg16: word);
begin
     store(reg16,fetch_pc);
     inc(t_states,10);
end;

procedure ld_reg8_mem8(var reg: byte);
begin
     reg := rdmem(fetch2_pc);
     inc(t_states,13);
end;

procedure ld_mem8_reg8(var reg: byte);
var
   addr: word;
begin
     addr:=fetch2_pc;
     store(addr, reg);
     inc(t_states,13);
end;

procedure ld_hl_mem16;
begin
     hl := rdmem2(fetch2_pc);
     inc(t_states,16);
end;

procedure ld_mem16_hl;
var
   addr: word;
begin
   addr:=fetch2_pc;
   store2(addr, hl);
   inc(t_states,16);
end;

procedure ld_reg16_n(var reg: word);
begin
  reg := fetch2_pc;
  inc(t_states, 10);
end;

procedure ld_SP_reg16(var reg: word);
begin
  sp := reg;
  inc(t_states, 6);
end;

// ******************* LD EXTENDED CODE ***************************************
procedure e_ld_reg8_reg8(var r1: byte; r2: byte);
begin
     r1 := r2;
     inc(t_states,9);
end;

procedure e_ld_i_a;
begin
  e_ld_reg8_reg8(i,a);
end;

procedure e_ld_r_a;
begin
  e_ld_reg8_reg8(r,a);
  r_bit7 := r >> 7;
end;


procedure e_ld_a_reg8(r2: byte);
begin
     e_ld_reg8_reg8(a,r2);
     set_a_flags;
end;

procedure e_ld_reg16_mem16(var reg: word);
begin
     reg := rdmem2(fetch2_pc);
     inc(t_states,20);
end;

procedure e_ld_mem16_reg16(reg: word);
var
   addr: word;
begin
   addr:=fetch2_pc;
   store2(addr, reg);
   inc(t_states,20);
end;

// ******************* LD IX/IY ***************************************
procedure ld_ixiy_mem16(var reg: word);
begin
     reg := rdmem2(fetch2_pc);
     inc(t_states,16);
end;

procedure ld_mem16_ixiy(reg: word);
begin
     store2(fetch2_pc, reg);
     inc(t_states,20);
end;

procedure ld_ixiy_nn(var reg: word);
begin
     reg := fetch2_pc;
     inc(t_states,14);
end;

procedure ld_ixiy_reg8(regixiy: word; reg8: byte);
begin
     store(regixiy+signed_fetch_pc,reg8);
     inc(t_states,19);
end;

procedure ld_SP_ixiy(var reg: word);
begin
  sp := reg;
  inc(t_states, 10);
end;

procedure ld_mem_ixiy_nn(reg: word);
var
   tmp1: int8;
   tmp2: byte;
begin
     tmp1 := signed_fetch_pc;
     tmp2 := fetch_pc;
     store(reg+tmp1,tmp2);
     inc(t_states,19);
end;
procedure set_high_ixiy(var reg: word; v: byte);
begin
  reg := (reg and $00FF) or (word(v) << 8);
  inc(t_states,8);
end;

procedure set_high_ixiy_mem(var reg: word; regxiyi: word);
begin
  reg := (reg and $00FF) or (rdmem(regxiyi+signed_fetch_pc) << 8);
  inc(t_states,19);
end;

procedure set_low_ixiy(var reg: word; v: byte);
begin
  reg := (reg and $FF00) or v;
  inc(t_states,8);
end;

procedure set_low_ixiy_mem(var reg: word; regxiyi: word);
begin
  reg := (reg and $FF00) or rdmem(regxiyi+signed_fetch_pc);
  inc(t_states,8);
end;


// ******************* BIT HANDLE *********************************************
procedure ccf;
begin
     if CARRY then begin
        h_flag := FLAG_H;
        c_flag := 0;
     end else begin
        h_flag := 0;
        c_flag := FLAG_C;
     end;
     n_flag := 0;
     compose_flags;
     inc(t_states,4);
end;

procedure scf;
begin
     h_flag := 0;
     n_flag := 0;
     c_flag := FLAG_C;
     set_undocumented_flags_bits(a);
     compose_flags;
     inc(t_states,4);
end;

procedure cpl;
begin
  a := a xor $ff;
  h_flag := FLAG_H;
  n_flag := FLAG_N;
  set_undocumented_flags_bits(a);
  compose_flags;
  inc(t_states,4);
end;

procedure rra;
begin
  a := rr_comun(a);
  compose_flags;
  inc(t_states, 4);
end;

procedure rla;
begin
  a := rl_comun(a);
  compose_flags;
  inc(t_states, 4);
end;

procedure rrca;
begin
   a := rrc_comun(a);
   compose_flags;
   inc(t_states,4);
end;

procedure rlca;
begin
    //a:=(a<<1)or(a>>7);
    //f:=(f and $c4)or(a and $29);
  A := rlc_comun(a);
  compose_flags;
  inc(t_states,4);
end;

procedure neg_a;
var
   tempneg: byte;
begin
  tempneg:= a;
  a:=0;
  suba(tempneg);
  inc(t_states, 8);
end;

procedure rrd;
var
   high_hl,low_hl,low_hl_copia,bytehl,high_a,low_a: byte;
begin
  bytehl := rdmem(hl);
  low_hl:= bytehl and $0F;
  low_hl_copia := low_hl;
  high_hl:=(bytehl >> 4) and $0F;

  low_a :=a and $0F;
  high_a := a and $f0;
  low_hl := high_hl;
  high_hl := low_a;
  low_a := low_hl_copia;
  a := high_a or low_a;
  bytehl := (high_hl<<4) or low_hl;
  store(hl,bytehl);
  f := c_flag;
  explode_flags;
  set_sz53p_flags(a);
  h_flag := 0;
  n_flag := 0;
//  set_flags_rrd_rld;
  compose_flags;
  inc(t_states, 18);
end;

//procedure rrd;
//var
//   tmp: byte;
//begin
//  tmp := rdmem(hl);
//  store(hl,(tmp << $04) or (tmp  >> $04));
//  a := (a and  $f0) or (tmp and $0f);
//  set_flags_rrd_rld;
//  compose_flags;
//  inc(t_states, 18);
//end;

procedure rld;
var
   high_hl,low_hl,bytehl,high_a,low_a,low_a_copia: byte;
begin
  bytehl := rdmem(hl);
  low_hl:=bytehl and $0F;
  high_hl:=(bytehl >> 4) and $0F;

  low_a :=a and $0F;
  low_a_copia := low_a;
  high_a := a and $f0;
  low_a := high_hl;
  high_hl := low_hl;
  low_hl := low_a_copia;
  a := high_a or low_a;
  bytehl := (high_hl<<4) or low_hl;
  store(hl,bytehl);
  f := c_flag;
  explode_flags;
  set_sz53p_flags(a);
  h_flag := 0;
  n_flag := 0;
//  set_flags_rrd_rld;
  compose_flags;
  inc(t_states, 18);
end;

procedure ldi;
var
   v: byte;
begin
  v := rdmem(hl);
  store(de,v);
  inc(hl);
  inc(de);
  dec(bc);
  h_flag  := 0;
  pv_flag := iffb(bc<>0,FLAG_PV,0);
  n_flag  := 0;
  n3_flag := iffb((v and 8) <> 0,FLAG_3,0);
  n5_flag := iffb((v and 2) <> 0,FLAG_5,0);
  compose_flags;
  inc(t_states, 16);
end;

procedure ldir;
begin
     ldi;
     if bc <> 0 then begin
       pc-=2;
       inc(t_states, 5);       // 5 additional
     end else begin
     end;
end;

procedure cpi_cpd_common;
var
   v, antes: byte;
begin
  antes := a;
  v := a-rdmem(hl);
  set_undocumented_flags_bits(v);

  set_flags_zero_sign(v);
  set_flags_halfcarry_resta(antes,v);
  n_flag := FLAG_N;
  dec(bc);

  pv_flag := iffb(bc=0,0,FLAG_PV);
  if h_flag <>0 then dec(v);

  n3_flag := iffb((v and 8) <> 0, FLAG_3, 0);
  n5_flag := iffb((v and 2) <> 0, FLAG_5, 0);
  compose_flags;
end;

procedure cpi;
begin
     cpi_cpd_common;
     inc(hl);
     inc(t_states, 16);
end;

procedure cpir;
begin
  cpi;
  if (pv_flag=0) or (z_flag<>0) then
  begin
    // end of CPIR
  end else begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;

procedure ldd;
var
   v: byte;
begin
  v := rdmem(hl);
  store(de,v);
  dec(hl);
  dec(de);
  dec(bc);
  h_flag  := 0;
  pv_flag := iffb(bc<>0,FLAG_PV,0);
  n_flag  := 0;
  n3_flag := iffb((v and 8) <> 0,FLAG_3,0);
  n5_flag := iffb((v and 2) <> 0,FLAG_5,0);
  compose_flags;
  inc(t_states, 16);
end;

procedure lddr;
begin
  ldd;
  if bc <> 0 then begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;

procedure cpd;
begin
  cpi_cpd_common;
  dec(hl);
  inc(t_states, 16);
end;

procedure cpdr;
begin
  cpd;
  if (pv_flag=0) or (z_flag<>0) then
  begin
    // end of CPDR
  end else begin
    pc-=2;
    inc(t_states, 5);       // 5 additional
  end;
end;


// ******************* 8 BIT ARITHMETIC *******************************************
procedure suba(v: byte);
var
   antes: byte;
begin
    antes := a;
    a -=  v;
    set_sz53_flags(a);
    set_flags_carry_resta(antes,a);
    set_flags_overflow_resta(antes,a);
    n_flag := FLAG_N;
    compose_flags;
end;

procedure sbca(v: byte);
var
   result,lookup: byte;
   result16: integer;
begin
  result16:=a;
  result16:=a-v-c_flag;
  lookup :=((a and $88)>>3) or ((v and $88)>>2) or ((result16 and $88)>>1);
  result := result16 and $ff;
  a := result;

  c_flag := iffb((result16 and $100) <> 0, FLAG_C, 0);
  h_flag := halfcarry_sub_table[lookup and $07];
  pv_flag := overflow_sub_table[lookup >> 4];
  n_flag := FLAG_N;
  set_sz53_flags(a);
  compose_flags;
end;

procedure suban;
begin
  suba(fetch_pc);
  inc(t_states,7);
end;

procedure subareg(reg: byte);
begin
  suba(reg);
  inc(t_states,4);
end;

procedure sbcareg(reg: byte);
begin
  sbca(reg);
  inc(t_states,4);
end;

procedure sbcan;
begin
  sbca(fetch_pc);
  inc(t_states,7);
end;

procedure suba_mem8r(addr: word);
begin
  suba(rdmem(addr));
  inc(t_states,7);
end;

procedure sbca_mem8r(addr: word);
begin
  sbca(rdmem(addr));
  inc(t_states,7);
end;

procedure add_ixiy_reg16(var reg1: word; reg2: word);
begin
  reg1 := add_16bit(reg1, reg2);
  inc(t_states, 15);
end;

procedure add_reg16_reg16(var reg1: word; reg2: word);
begin
  reg1 := word(add_16bit(reg1, reg2));
  inc(t_states, 11);
end;

procedure adda(v: byte);
var
   antes: byte;
begin
     antes := a;
     a +=  v;
     set_sz53_flags(a);
     set_flags_carry_suma(antes,a);
     set_flags_overflow_suma(antes,a);
     n_flag := 0;
     compose_flags;
end;

procedure addareg(v: byte);
begin
    adda(v);
    inc(t_states,4);
end;

procedure addan;
begin
    adda(fetch_pc);
    inc(t_states,7);
end;

procedure adca(v: byte);
var
   lookup, result: byte;
   result16: word;
begin
     result16 := a + v + c_flag;
     lookup := ((a and $88)>>3) or ((v and $88)>>2) or ((result16 and $88)>>1);
     result := result16 and $ff;
     a := result;
     c_flag := iffb((result16 and $100) <> 0, FLAG_C, 0);
     h_flag := halfcarry_add_table[lookup and $07];
     pv_flag := overflow_add_table[lookup >> 4];
     set_sz53_flags(a);
     n_flag := 0;
     compose_flags;
end;

procedure adcan;
begin
    adca(fetch_pc);
    inc(t_states,7);
end;

procedure adcareg(v: byte);
begin
    adca(v);
    inc(t_states,4);
end;

procedure adca_mem8r(r: word);
begin
    adca(rdmem(r));
    inc(t_states,7);
end;
procedure adda_mem8r(r: word);
begin
    adda(rdmem(r));
    inc(t_states,7);
end;

procedure adda_ixiy_reg8(r: byte);
begin
    adda(r);
    inc(t_states,8);
end;

procedure adda_ixiy_mem8(reg: word);
begin
    adda(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure adca_ixiy_reg8(r: byte);
begin
    adca(r);
    inc(t_states,8);
end;

procedure adca_ixiy_mem8(reg: word);
begin
    adca(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure suba_ixiy_reg8(r: byte);
begin
    suba(r);
    inc(t_states,8);
end;

procedure suba_ixiy_mem8(reg: word);
begin
    suba(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

procedure sbca_ixiy_reg8(r: byte);
begin
    sbca(r);
    inc(t_states,8);
end;

procedure sbca_ixiy_mem8(reg: word);
begin
    sbca(rdmem(reg+signed_fetch_pc));
    inc(t_states,19);
end;

// ******************* 16 BIT ARITHMETIC *******************************************
function sbc_16bit(reg: word; value: word): word;
var
  result16, lookup: word;
  h: byte;
  result_32bit: dword;
begin
  result_32bit := dword(reg-value-c_flag);

  lookup := (word((reg and $8800 )>>11))
         or ((value and $8800 )>>10)
         or (word(result_32bit and $8800)>>9);


  result16 := result_32bit and 65535;
  h := result16 >> 8;
  set_undocumented_flags_bits(h);


  if (result_32bit and $10000) <> 0 then c_flag := FLAG_C
  else c_flag := 0;


  //z_flag := iffb(result16=0, FLAG_Z, 0);
  //s_flag := iffb((result16 and 32768) <> 0, FLAG_S, 0);
  set_flags_zero_sign_16(result16);
  h_flag := halfcarry_sub_table[lookup and $07];
  pv_flag := overflow_sub_table[lookup >> 4];
  n_flag := FLAG_N;

  compose_flags;

  inc(t_states,15);

  sbc_16bit := result16;
end;

function adc_16bit(reg: word; value: word): word;
var
   result16, lookup: word;
   h: byte;
   result_32bit: dword;
begin
  result_32bit := reg+value+c_flag;

  lookup := ((reg and $8800 )>>11)
         or ((value and $8800 )>>10)
         or ((result_32bit and $8800)>>9);


  result16 := result_32bit and 65535;
  h := result16 >> 8;
  set_undocumented_flags_bits(h);


  if (result_32bit and $10000) <> 0 then c_flag := FLAG_C
  else c_flag := 0;

  //z_flag := iffb(result16=0, FLAG_Z, 0);
  //s_flag := iffb((result16 and 32768) <> 0, FLAG_S, 0);
  set_flags_zero_sign_16(result16);
  h_flag := halfcarry_add_table[lookup and $07];
  pv_flag := overflow_add_table[lookup >> 4];
  n_flag := 0;

  inc(t_states, 15);

  compose_flags;

  adc_16bit := result16;
end;

// ******************* INC/DEC *******************************************
procedure inc_8bit(var reg: byte);
begin
  inc(reg);
  n_flag := 0;
  pv_flag := iffb(reg=128, FLAG_PV, 0);
  h_flag := iffb((reg and $0f)<>0, 0, FLAG_H);
  set_sz53_flags(reg);
  compose_flags;
  inc(t_states,4);
end;

procedure dec_8bit(var reg: byte);
begin
  if reg and $0f <> 0 then h_flag := 0 else h_flag := FLAG_H;
  h_flag := iffb((reg and $0f) <> 0, 0, FLAG_H);
  dec(reg);
  n_flag := FLAG_N;
  pv_flag := iffb(reg=127, FLAG_PV, 0);
  set_sz53_flags(reg);
  compose_flags;
  inc(t_states,4);
end;


procedure dec_mem(addr: word);
var
   t: byte;
begin
   t := rdmem(addr);
   dec_8bit(t);
   store(addr, t);
   inc(t_states,19); // 19 aditional
end;

procedure inc_mem(addr: word);
var
   t: byte;
begin
     t := rdmem(addr);
     inc_8bit(t);
     store(addr, t);
     inc(t_states,19); // 19 aditional
end;

procedure inc16(var reg: word);
begin
  inc(reg);
  inc(t_states, 6);
end;

procedure dec16(var reg: word);
begin
  dec(reg);
  inc(t_states, 6);
end;

procedure inc_ixiy(var reg: word);
begin
  inc(reg);
  inc(t_states, 8);
end;

procedure dec_ixiy(var reg: word);
begin
  dec(reg);
  inc(t_states, 8);
end;

procedure dec_high_ixiy(var reg: word);
var
   r: byte;
begin
  r := reg >> 8;
  dec_8bit(r);
  reg := (reg and $00FF) or (r << 8);
  inc(t_states,4);       // 4 additional
end;

procedure inc_high_ixiy(var reg: word);
var
   r: byte;
begin
  r := reg >> 8;
  inc_8bit(r);
  reg := (reg and $00FF) or (r << 8);
  inc(t_states,4);       // 4 additional
end;

procedure dec_low_ixiy(var reg: word);
var
   r: byte;
begin
  r := reg and $ff;
  dec_8bit(r);
  reg := (reg and $FF00) or r;
  inc(t_states,4);       // 4 additional
end;

procedure inc_low_ixiy(var reg: word);
var
   r: byte;
begin
  r := reg and $ff;
  inc_8bit(r);
  reg := (reg and $FF00) or r;
  inc(t_states,4);       // 4 additional
end;


end.

