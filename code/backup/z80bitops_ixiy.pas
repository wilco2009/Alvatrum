unit Z80bitops_ixiy;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,z80Globals,z80bitops;

function rlc_ixiy(v: word): byte;
function rrc_ixiy(v: word): byte;
function rl_ixiy(v: word): byte;
function rr_ixiy(v: word): byte;
function sla_ixiy(v: word): byte;
function sra_ixiy(v: word): byte;
function sll_ixiy(v: word): byte;
function srl_ixiy(v: word): byte;
procedure bit_ixiy(n: byte; addr: word);
function res_ixiy(n: byte; v: word): byte;
function bset_ixiy(n: byte; v: word): byte;

implementation

function rlc_ixiy(v: word): byte;
var
   r: byte;
begin
  r := rlc(rdmem(v));
  store(v,r);
  rlc_ixiy := r;
end;

function rrc_ixiy(v: word): byte;
var
   r: byte;
begin
  r := rrc(rdmem(v));
  store(v,r);
  rrc_ixiy := r;
end;

function rl_ixiy(v: word): byte;
var
   r: byte;
begin
  r := rl(rdmem(v));
  store(v,r);
  rl_ixiy := r;
end;

function rr_ixiy(v: word): byte;
var
   r: byte;
begin
  r := rr(rdmem(v));
  store(v,r);
  rr_ixiy := r;
end;

function sla_ixiy(v: word): byte;
var
   r: byte;
begin
  r := sla(rdmem(v));
  store(v,r);
  sla_ixiy := r;
end;

function sra_ixiy(v: word): byte;
var
   r: byte;
begin
  r := sra(rdmem(v));
  store(v,r);
  sra_ixiy := r;
end;

function sll_ixiy(v: word): byte;
var
   r: byte;
begin
  r := sll(rdmem(v));
  store(v,r);
  sll_ixiy := r;
end;
function srl_ixiy(v: word): byte;
var
   r: byte;
begin
  r := srl(rdmem(v));
  store(v,r);
  srl_ixiy := r;
end;
procedure bit_ixiy(n: byte; addr: word);
var
  valor_and,v: byte;
  a:char;
begin
  v := rdmem(addr);
  valor_and:=1;
  if (n <> 0) then valor_and := valor_and << n;
  h_flag := FLAG_H;
  z_flag := iffb((v and valor_and)=0,FLAG_Z,0);;
  pv_flag := iffb((v and valor_and)=0,FLAG_PV,0);;
  s_flag := iffb((n=7) and ((v and 128)<>0),FLAG_S,0);;
  n_flag := 0;
  set_undocumented_flags_bits((addr>>8) and $ff);
  compose_flags;

end;
function res_ixiy(n: byte; v: word): byte;
var
   r: byte;
begin
  r := res(n,rdmem(v));
  store(v,r);
  res_ixiy := r;
end;
function bset_ixiy(n: byte; v: word): byte;
var
   r: byte;
begin
  r := bset(n,rdmem(v));
  store(v,r);
  bset_ixiy := r;
end;

end.

