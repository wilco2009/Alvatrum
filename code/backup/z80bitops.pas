unit z80bitops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,z80Globals;

function rlc_comun(v: byte): byte;
function rlc(v: byte): byte;
function rrc_comun(v: byte): byte;
function rrc(v: byte): byte;
function rl_comun(v: byte): byte;
function rl(v: byte): byte;
function rr_comun(v: byte): byte;
function rr(v: byte): byte;
function sla(v: byte): byte;
function sra(v: byte): byte;
function sll(v: byte): byte;
function srl(v: byte): byte;
procedure bit(n,v: byte);
function res(n,v: byte): byte;
function bset(n,v: byte): byte;
function getbit(opcode: byte): byte;

implementation

function rlc_comun(v: byte): byte;
begin
  c_flag := iffb((v and 128)<>0, FLAG_C, 0);
  v := v << 1;
  v := v or c_flag;
  set_undocumented_flags_bits(v);

  n_flag := 0;
  h_flag := 0;
  rlc_comun := v;
end;

function rlc(v: byte): byte;
begin
  v := rlc_comun(v);
  set_flags_zero_sign(v);
  pv_flag := parity(v);

  compose_flags;
  rlc := v;
end;

function rrc_comun(v: byte): byte;
begin
  c_flag := iffb((v and 1)<>0, FLAG_C, 0);
  v := v >> 1;
  v := v or (c_flag * 128);
  set_undocumented_flags_bits(v);

  n_flag := 0;
  h_flag := 0;
  rrc_comun := v;
end;


function rrc(v: byte): byte;
begin
  v := rrc_comun(v);

  set_flags_zero_sign(v);
  pv_flag := parity(v);

  compose_flags;
  rrc := v;
end;

function rl_comun(v: byte): byte;
var
  cmem: byte;
begin
  cmem := c_flag;
  c_flag := iffb((v and 128)<>0, FLAG_C, 0);
  v := v << 1;
  v := v or cmem;
  set_undocumented_flags_bits(v);

  n_flag := 0;
  h_flag := 0;
  rl_comun := v;
end;

function rl(v: byte): byte;
var
  cmem: byte;
begin
  //cmem := c_flag;
  //c_flag := iffb((v and 128)<>0, FLAG_C, 0);
  //v := v << 1;
  //v := v or cmem;
  //set_undocumented_flags_bits(v);
  //
  //n_flag := 0;
  //h_flag := 0;
  v := rl_comun(v);
  set_flags_zero_sign(v);
  pv_flag := parity(v);

  compose_flags;
  rl := v;
end;

function rr_comun(v: byte): byte;
var
  cmem: byte;
begin
  cmem := c_flag;
  c_flag := iffb((v and 1)<>0, FLAG_C, 0);
  v := v >> 1;
  v := v or (cmem << 7);
  set_undocumented_flags_bits(v);

  n_flag := 0;
  h_flag := 0;
  rr_comun := v;
end;

function rr(v: byte): byte;
var
  cmem: byte;
begin
  //cmem := c_flag;
  //c_flag := iffb((v and 1)<>0, FLAG_C, 0);
  //v := v >> 1;
  //v := v or (cmem << 7);
  //set_undocumented_flags_bits(v);
  //
  //n_flag := 0;
  //h_flag := 0;
  v := rr_comun(v);
  set_flags_zero_sign(v);
  pv_flag := parity(v);

  compose_flags;
  rr := v;
end;


function sla(v: byte): byte;
begin
  c_flag := iffb((v and 128)<>0, FLAG_C, 0);
  v := v << 1;
  n_flag := 0;
  h_flag := 0;
  //pv_flag := 0;
  //n3_flag := 0;
  //n5_flag := 0;
  set_sz53p_flags(v);
  //s_flag  := iffb(v and $80 <>0, FLAG_S, 0);
  //z_flag  := iffb(        v = 0, FLAG_Z, 0);
  compose_flags;
  sla := v;
end;

function sra(v: byte): byte;
var
  value7: byte;
begin
  value7 := v and 128;
  c_flag := iffb((v and 1)<>0, FLAG_C, 0);
  v := v >> 1;
  v := v or value7;
  n_flag := 0;
  h_flag := 0;
  //s_flag  := iffb(v and $80 <>0, FLAG_S, 0);
  //z_flag  := iffb(        v = 0, FLAG_Z, 0);
  //pv_flag := 0;
  //n3_flag := 0;
  //n5_flag := 0;
  set_sz53p_flags(v);
  compose_flags;
  sra := v;
end;
function sll(v: byte): byte;
begin
  c_flag := iffb((v and 128)<>0, FLAG_C, 0);
  v := (v << 1) or 1;
  //s_flag  := iffb(v and $80 <>0, FLAG_S, 0);
  //z_flag  := iffb(        v = 0, FLAG_Z, 0);
  n_flag := 0;
  h_flag := 0;
  //pv_flag := 0;
  //n3_flag := 0;
  //n5_flag := 0;
  set_sz53p_flags(v);
  compose_flags;
  sll := v;
end;
function srl(v: byte): byte;
begin
  c_flag := iffb((v and 1)<>0, FLAG_C, 0);
  v := (v >> 1);
  //s_flag  := iffb(v and $80 <>0, FLAG_S, 0);
  //z_flag  := iffb(        v = 0, FLAG_Z, 0);
  n_flag := 0;
  h_flag := 0;
  //pv_flag := 0;
  //n3_flag := 0;
  //n5_flag := 0;
  set_sz53p_flags(v);
  compose_flags;
  srl := v;
end;
procedure bit(n,v: byte);
var
  valor_or: byte;
begin
     valor_or:=1;
     if (n <> 0) then valor_or := valor_or << n;
     n5_flag := iffb((n=5) and ((v and 32)<>0),FLAG_5,0);
     n3_flag := iffb((n=3) and ((v and  8)<>0),FLAG_3,0);
     h_flag := FLAG_H;
     z_flag := iffb((v and valor_or)=0,FLAG_Z,0);;
     pv_flag := iffb((v and valor_or)=0,FLAG_PV,0);;
     s_flag := iffb((n=7) and ((v and 128)<>0),FLAG_S,0);;
     n_flag := 0;
     compose_flags;
end;
function res(n,v: byte): byte;
var
  valor_and: byte;
begin
     valor_and := 1;
     if (n <> 0) then valor_and := valor_and << n;
     valor_and := valor_and xor $ff;
     v := v and valor_and;
     res := v;
end;
function bset(n,v: byte): byte;
var
  valor_or: byte;
begin
     valor_or := 1;
     if (n <> 0) then valor_or := valor_or << n;
     v := v or valor_or;
     bset := v;
end;
function getbit(opcode: byte): byte;
begin
  getbit:=(opcode >> 3) and 7;
end;

end.

