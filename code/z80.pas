unit Z80;

{$mode objfpc}{$H+}
{$inline on}



interface

uses
  Classes, SysUtils, Z80ops, Z80Globals, Z80bitops, Z80bitops_ixiy;

procedure do_Z80;
procedure init_z80(coldboot: boolean);
procedure ddfd_cb_instructions(var reg: word);

implementation


// Extended instructions
procedure ed_instructions;
begin
    inc_register_r;
    case (fetch_pc) of
         $40: in_c(b);                        // IN B,(C)
         $41: out_c(b);                       // OUT (C),B
         $42: hl := sbc_16bit(hl,bc);         // SBC HL,BC
         $43: e_ld_mem16_reg16(bc);           // LD (NN),BC
         $44: neg_a;                          // NEG
         $45: retn;                           // RETN
         $46: int_mode(0);                    // IM 0;
         $47: e_ld_i_a;            // LD I,A
         $48: in_c(c);                        // IN C,(C)
         $49: out_c(c);                       // OUT C,(C)
         $4a: hl := adc_16bit(hl,bc);         // ADC HL,BC
         $4b: e_ld_reg16_mem16(bc);           // LD BC,(NN)
         $4c: neg_a;                          // NEG
         $4d: reti;                           // RETI
         $4e: int_mode(0);                    // IM 0;
         $4f: e_ld_r_a;            // LD R,A
         $50: in_c(d);                        // IN D,(C)
         $51: out_c(d);                       // OUT (C),D
         $52: hl := sbc_16bit(hl,de);         // SBC HL,DE
         $53: e_ld_mem16_reg16(de);           // LD (NN),DE
         $54: neg_a;                          // NEG
         $55: retn;                           // RETN
         $56: int_mode(1);                    // IM 1;
         $57: e_ld_a_reg8(i);                 // LD A,I
         $58: in_c(e);                        // IN E,(C)
         $59: out_c(e);                       // OUT (C),E
         $5a: hl := adc_16bit(hl,de);         // ADC HL,DE
         $5b: e_ld_reg16_mem16(de);           // LD DE,(NN)
         $5c: neg_a;                          // NEG
         $5d: retn;                           // RETN
         $5e: int_mode(2);                    // IM 2;
         $5f: e_ld_a_reg8(r);                 // LD A,R
         $60: in_c(h);                        // IN H,(C)
         $61: out_c(h);                       // OUT (C),H
         $62: hl := sbc_16bit(hl,hl);         // SBC HL,HL
         $63: e_ld_mem16_reg16(hl);           // LD (NN),HL
         $64: neg_a;                          // NEG
         $65: retn;                           // RETN
         $66: int_mode(0);                    // IM 2;
         $67: rrd;                            // rrd
         $68: in_c(l);                        // IN L,(C)
         $69: out_c(l);                       // OUT (C),L
         $6a: hl := adc_16bit(hl,hl);         // ADC HL,HL
         $6b: e_ld_reg16_mem16(hl);           // LD HL,(NN)
         $6c: neg_a;                          // NEG
         $6d: retn;                           // RETN
         $6e: int_mode(1);                    // IM 1;
         $6f: rld;                            // rld
         $70: in_c_f;                         // IN F,(C)
         $71: out_c(0);                       // OUT (C),0
         $72: hl := sbc_16bit(hl, sp);        // SBC HL,SP
         $73: e_ld_mem16_reg16(sp);           // LD (NN),SP
         $74: neg_a;                          // NEG
         $75: retn;                           // RETN
         $76: int_mode(1);                    // IM 1;
         $77: invalid_instruction;
         $78: in_c(a);                        // IN A,(C)
         $79: out_c(a);                       // OUT A,(C)
         $7a: hl := adc_16bit(hl,sp);         // ADC HL,SP
         $7b: e_ld_reg16_mem16(sp);           // LD SP,(NN)
         $7c: neg_a;                          // NEG
         $7d: retn;                           // RETN
         $7e: int_mode(2);                    // IM 2;
         $7f: invalid_instruction;
         $a0: ldi;                            // LDI
         $a1: cpi;                            // CPI
         $a2: ini;                            // INI
         $a3: outi;                           // OUTI
         $a4,$a7: invalid_instruction;
         $a8: ldd;                            // LDD
         $a9: cpd;                            // CPD
         $aa: ind;                            // IND
         $ab: outd;                           // OUTD
         $ac..$af: invalid_instruction;
         $b0: ldir;                           // LDIR
         $b1: cpir;                           // CPIR
         $b2: inir;                           // INIR
         $b3: otir;                           // OUTIR
         $b4,$b7: invalid_instruction;
         $b8: lddr;                           // LDDR
         $b9: cpdr;                           // CPDR
         $ba: indr;                           // INDR
         $bb: otdr;                           // OUTDR
         $bc..$bf: invalid_instruction;
         $c0..$ff: invalid_instruction;
    end;
end;

// Bit instructions
procedure cb_instructions;
var
   opcode, t: byte;
begin
    inc_register_r;
    opcode := fetch_pc;
    t := opcode and $f;
    if (t = $6) or (t=$e) then
       inc(t_states,15)
    else
        inc(t_states,8);
    case (opcode) of
         $00: b := rlc(b);
         $01: c := rlc(c);
         $02: d := rlc(d);
         $03: e := rlc(e);
         $04: h := rlc(h);
         $05: l := rlc(l);
         $06: store(hl,rlc(rdmem(hl)));
         $07: a := rlc(a);
         $08: b := rrc(b);
         $09: c := rrc(c);
         $0a: d := rrc(d);
         $0b: e := rrc(e);
         $0c: h := rrc(h);
         $0d: l := rrc(l);
         $0e: store(hl,rrc(rdmem(hl)));
         $0f: a := rrc(a);
         $10: b := rl(b);
         $11: c := rl(c);
         $12: d := rl(d);
         $13: e := rl(e);
         $14: h := rl(h);
         $15: l := rl(l);
         $16: store(hl,rl(rdmem(hl)));
         $17: a := rl(a);
         $18: b := rr(b);
         $19: c := rr(c);
         $1a: d := rr(d);
         $1b: e := rr(e);
         $1c: h := rr(h);
         $1d: l := rr(l);
         $1e: store(hl,rr(rdmem(hl)));
         $1f: a := rr(a);
         $20: b := sla(b);
         $21: c := sla(c);
         $22: d := sla(d);
         $23: e := sla(e);
         $24: h := sla(h);
         $25: l := sla(l);
         $26: store(hl,sla(rdmem(hl)));
         $27: a := sla(a);
         $28: b := sra(b);
         $29: c := sra(c);
         $2a: d := sra(d);
         $2b: e := sra(e);
         $2c: h := sra(h);
         $2d: l := sra(l);
         $2e: store(hl,sra(rdmem(hl)));
         $2f: a := sra(a);
         $30: b := sll(b);
         $31: c := sll(c);
         $32: d := sll(d);
         $33: e := sll(e);
         $34: h := sll(h);
         $35: l := sll(l);
         $36: store(hl,sll(rdmem(hl)));
         $37: a := sll(a);
         $38: b := srl(b);
         $39: c := srl(c);
         $3a: d := srl(d);
         $3b: e := srl(e);
         $3c: h := srl(h);
         $3d: l := srl(l);
         $3e: store(hl,srl(rdmem(hl)));
         $3f: a := srl(a);
         $40,$48,$50,$58,$60,$68,$70,$78:
         begin
              bit(getbit(opcode),b);
         end;
         $41,$49,$51,$59,$61,$69,$71,$79:
         begin
              bit(getbit(opcode),c);
         end;
         $42,$4a,$52,$5a,$62,$6a,$72,$7a:
         begin
              bit(getbit(opcode),d);
         end;
         $43,$4b,$53,$5b,$63,$6b,$73,$7b:
         begin
              bit(getbit(opcode),e);
         end;
         $44,$4c,$54,$5c,$64,$6c,$74,$7c:
         begin
              bit(getbit(opcode),h);
         end;
         $45,$4d,$55,$5d,$65,$6d,$75,$7d:
         begin
              bit(getbit(opcode),l);
         end;
         $46,$4e,$56,$5e,$66,$6e,$76,$7e:
         begin
              bit(getbit(opcode),rdmem(hl));
              //set_undocumented_flags_bits_memptr();
              compose_flags;
         end;
         $47,$4f,$57,$5f,$67,$6f,$77,$7f:
         begin
              bit(getbit(opcode),a);
         end;
         $80,$88,$90,$98,$a0,$a8,$b0,$b8:
         begin
              b := res(getbit(opcode),b);
         end;
         $81,$89,$91,$99,$a1,$a9,$b1,$b9:
         begin
              c := res(getbit(opcode),c);
         end;
         $82,$8a,$92,$9a,$a2,$aa,$b2,$ba:
         begin
              d := res(getbit(opcode),d);
         end;
         $83,$8b,$93,$9b,$a3,$ab,$b3,$bb:
         begin
              e := res(getbit(opcode),e);
         end;
         $84,$8c,$94,$9c,$a4,$ac,$b4,$bc:
         begin
              h := res(getbit(opcode),h);
         end;
         $85,$8d,$95,$9d,$a5,$ad,$b5,$bd:
         begin
              l := res(getbit(opcode),l);
         end;
         $86,$8e,$96,$9e,$a6,$ae,$b6,$be:
         begin
              store(hl,res(getbit(opcode),rdmem(hl)));
         end;
         $87,$8f,$97,$9f,$a7,$af,$b7,$bf:
         begin
              a := res(getbit(opcode),a);
         end;
         $c0,$c8,$d0,$d8,$e0,$e8,$f0,$f8:
         begin
              b := bset(getbit(opcode),b);
         end;
         $c1,$c9,$d1,$d9,$e1,$e9,$f1,$f9:
         begin
              c := bset(getbit(opcode),c);
         end;
         $c2,$ca,$d2,$da,$e2,$ea,$f2,$fa:
         begin
              d := bset(getbit(opcode),d);
         end;
         $c3,$cb,$d3,$db,$e3,$eb,$f3,$fb:
         begin
              e := bset(getbit(opcode),e);
         end;
         $c4,$cc,$d4,$dc,$e4,$ec,$f4,$fc:
         begin
              h := bset(getbit(opcode),h);
         end;
         $c5,$cd,$d5,$dd,$e5,$ed,$f5,$fd:
         begin
              l := bset(getbit(opcode),l);
         end;
         $c6,$ce,$d6,$de,$e6,$ee,$f6,$fe:
         begin
              store(hl,bset(getbit(opcode),rdmem(hl)));
         end;
         $c7,$cf,$d7,$df,$e7,$ef,$f7,$ff:
         begin
              a := bset(getbit(opcode),a);
         end;
    end;
end;

procedure ddfd_instructions(var reg: word);
var
//   h,l: byte;
   opcode: byte;
begin
    inc_register_r;
    opcode := fetch_pc;
    case (opcode) of
         $09: add_ixiy_reg16(reg, bc);                 // add ix/iy,bc
         $19: add_ixiy_reg16(reg,de);                  // add ix/iy,de
         $21: ld_ixiy_nn(reg);                         // ld ix/iy,nn
         $22: ld_mem16_ixiy(reg);                      // ld (nn),ix/iy
         $23: inc_ixiy(reg);                           // inc ix/iy
         $24: inc_high_ixiy(reg);                      // inc ix/iy.h
         $25: dec_high_ixiy(reg);                      // dec ix/iy.h
         $26: set_high_ixiy(reg, fetch_pc);            // ld ix/iy.h,n
         $29: add_ixiy_reg16(reg,reg);                 // add ix/iy,ix/iy
         $2a: ld_ixiy_mem16(reg);                      // ld ix/iy,(nn)
         $2b: dec_ixiy(reg);                           // dec ix/iy
         $2c: inc_low_ixiy(reg);
         $2d: dec_low_ixiy(reg);
         $2e: set_low_ixiy(reg, fetch_pc);

         $34: inc_mem(reg+signed_fetch_pc);
         $35: dec_mem(reg+signed_fetch_pc);
         $36: ld_mem_ixiy_nn(reg);                     // ld (ix/iy+nn),n
         $39: add_ixiy_reg16(reg,sp);

         $44: set_high_ixiy(bc, hi(reg));
         $45: set_high_ixiy(bc, lo(reg));
         $46: set_high_ixiy_mem(bc, reg);
         $4c: set_low_ixiy(bc, hi(reg));
         $4d: set_low_ixiy(bc, lo(reg));
         $4e: set_low_ixiy_mem(bc, reg);

         $54: set_high_ixiy(de, hi(reg));
         $55: set_high_ixiy(de, lo(reg));
         $56: set_high_ixiy_mem(de, reg);
         $5c: set_low_ixiy(de, hi(reg));
         $5d: set_low_ixiy(de, lo(reg));
         $5e: set_low_ixiy_mem(de, reg);

         $60: set_high_ixiy(reg, b);
         $61: set_high_ixiy(reg, c);
         $62: set_high_ixiy(reg, d);
         $63: set_high_ixiy(reg, e);
         $64: set_high_ixiy(reg, h);
         $65: set_high_ixiy(reg, l);
         $66: set_high_ixiy_mem(hl, reg);              // ¿H o high(IX)?
         $67: set_high_ixiy(reg, a);
         $68: set_low_ixiy(reg,b);
         $69: set_low_ixiy(reg,c);
         $6a: set_low_ixiy(reg,d);
         $6b: set_low_ixiy(reg,e);
         $6c: set_low_ixiy(reg,hi(reg));
         $6d: set_low_ixiy(reg,lo(reg));
         $6e: set_low_ixiy_mem(hl, reg);
         $6f: set_low_ixiy(reg,a);

         $70: ld_ixiy_reg8(reg,b);
         $71: ld_ixiy_reg8(reg,c);
         $72: ld_ixiy_reg8(reg,d);
         $73: ld_ixiy_reg8(reg,e);
         $74: ld_ixiy_reg8(reg,h);
         $75: ld_ixiy_reg8(reg,l);
         $77: ld_ixiy_reg8(reg,a);
         $7c: set_low_ixiy(af, hi(reg));
         $7d: set_low_ixiy(af, lo(reg));
         $7e: set_high_ixiy_mem(af, reg);

         $84: adda_ixiy_reg8(hi(reg));
         $85: adda_ixiy_reg8(lo(reg));
         $86: adda_ixiy_mem8(reg);
         $8c: adca_ixiy_reg8(hi(reg));
         $8d: adca_ixiy_reg8(lo(reg));
         $8e: adca_ixiy_mem8(reg);

         $94: suba_ixiy_reg8(hi(reg));
         $95: suba_ixiy_reg8(lo(reg));
         $96: suba_ixiy_mem8(reg);
         $9c: sbca_ixiy_reg8(hi(reg));
         $9d: sbca_ixiy_reg8(lo(reg));
         $9e: sbca_ixiy_mem8(reg);

         $a4: anda_ixiy_reg8(hi(reg));
         $a5: anda_ixiy_reg8(lo(reg));
         $a6: anda_ixiy_mem8(reg);
         $ac: xora_ixiy_reg8(hi(reg));
         $ad: xora_ixiy_reg8(lo(reg));
         $ae: xora_ixiy_mem8(reg);

         $b4: ora_ixiy_reg8(hi(reg));
         $b5: ora_ixiy_reg8(lo(reg));
         $b6: ora_ixiy_mem8(reg);
         $bc: cpa_ixiy_reg8(hi(reg));
         $bd: cpa_ixiy_reg8(lo(reg));
         $be: cpa_ixiy_mem8(reg);

         $cb: ddfd_cb_instructions(reg);

         $e1: pop_IXIY(reg);
         $e3: EX_mem_ixiy(reg);
         $e5: push_IXIY(reg);
         $e9: jp_IXIY(reg);
         $f9: ld_sp_ixiy(reg);
         else invalid_instruction;
    end;
end;

// IX/IY bit instructions
procedure ddfd_cb_instructions(var reg: word);
var
  opcode: byte;
  desp: int8;
  addr: word;
begin
    desp := fetch_pc;
    opcode := fetch_pc;
    addr := reg+desp8_to_16(desp);
    inc(t_states,23);
    case (opcode) of
         $00: b := rlc_ixiy(addr);
         $01: c := rlc_ixiy(addr);
         $02: d := rlc_ixiy(addr);
         $03: e := rlc_ixiy(addr);
         $04: h := rlc_ixiy(addr);
         $05: l := rlc_ixiy(addr);
         $06: store(addr,rlc_ixiy(addr));
         $07: a := rlc_ixiy(addr);
         $08: b := rrc_ixiy(addr);
         $09: c := rrc_ixiy(addr);
         $0a: d := rrc_ixiy(addr);
         $0b: e := rrc_ixiy(addr);
         $0c: h := rrc_ixiy(addr);
         $0d: l := rrc_ixiy(addr);
         $0e: store(addr,rrc_ixiy(addr));
         $0f: a := rrc_ixiy(addr);
         $10: b := rl_ixiy(addr);
         $11: c := rl_ixiy(addr);
         $12: d := rl_ixiy(addr);
         $13: e := rl_ixiy(addr);
         $14: h := rl_ixiy(addr);
         $15: l := rl_ixiy(addr);
         $16: store(addr,rl_ixiy(addr));
         $17: a := rl_ixiy(addr);
         $18: b := rr_ixiy(addr);
         $19: c := rr_ixiy(addr);
         $1a: d := rr_ixiy(addr);
         $1b: e := rr_ixiy(addr);
         $1c: h := rr_ixiy(addr);
         $1d: l := rr_ixiy(addr);
         $1e: store(addr,rr_ixiy(addr));
         $1f: a := rr_ixiy(addr);
         $20: b := sla_ixiy(addr);
         $21: c := sla_ixiy(addr);
         $22: d := sla_ixiy(addr);
         $23: e := sla_ixiy(addr);
         $24: h := sla_ixiy(addr);
         $25: l := sla_ixiy(addr);
         $26: store(addr,sla_ixiy(addr));
         $27: a := sla_ixiy(addr);
         $28: b := sra_ixiy(addr);
         $29: c := sra_ixiy(addr);
         $2a: d := sra_ixiy(addr);
         $2b: e := sra_ixiy(addr);
         $2c: h := sra_ixiy(addr);
         $2d: l := sra_ixiy(addr);
         $2e: store(addr,sra_ixiy(addr));
         $2f: a := sra_ixiy(addr);
         $30: b := sla_ixiy(addr);
         $31: c := sla_ixiy(addr);
         $32: d := sla_ixiy(addr);
         $33: e := sla_ixiy(addr);
         $34: h := sla_ixiy(addr);
         $35: l := sla_ixiy(addr);
         $36: store(addr,sla_ixiy(addr));
         $37: a := sla_ixiy(addr);
         $38: b := srl_ixiy(addr);
         $39: c := srl_ixiy(addr);
         $3a: d := srl_ixiy(addr);
         $3b: e := srl_ixiy(addr);
         $3c: h := srl_ixiy(addr);
         $3d: l := srl_ixiy(addr);
         $3e: store(addr,srl_ixiy(addr));
         $3f: a := srl_ixiy(addr);
         $40..$7f: bit_ixiy(getbit(opcode),addr);
         $80..$bf: res_ixiy(getbit(opcode),addr);
         $c0..$ff: bset_ixiy(getbit(opcode),addr);
    end;
end;

procedure do_Z80;
var
   addr, opcode: word;
// infinite loop
begin
    // this is some optimization for the IX and IY opcodes (DD/FD)
 //   ixoriy:=new_ixoriy;
 //   new_ixoriy:=0;
    // fetch opcode and execute
    inc_register_r;
    pc_before := pc;
    opcode := fetch_pc;
    case (opcode) of
         $00: inc(t_states,4);             // nop
         $01: ld_reg16_n(bc);              // ld bc,nn
         $02: ld_mem8r_reg(bc,a);          // ld (bc),a
         $03: inc16(bc);                   // inc bc
         $04: inc_8bit(b);                 // inc B
         $05: dec_8bit(b);                 // dec B
         $06: ld_reg8_n(b);                // ld B,n
         $07: rlca;                        // rlca
         $08: ex_af_af1;                   // ex AF,AF'
         $09: add_reg16_reg16(hl, bc);     // add HL,BC
         $0a: ld_reg8_mem8r(a,bc);         // ld A,(BC)
         $0b: dec16(bc);                   // dec BC
         $0c: inc_8bit(c);                 // inc C
         $0d: dec_8bit(c);                 // dec C
         $0e: ld_reg8_n(c);                // ld C,n
         $0f: rrca;                        // rrca
         $10: djnz;                        // djnz
         $11: ld_reg16_n(de);              // ld DE,nn
         $12: ld_mem8r_reg(de,a);          // ld (DE),A
         $13: inc16(de);                   // inc DE
         $14: inc_8bit(d);                 // inc D
         $15: dec_8bit(d);                 // dec D
         $16: ld_reg8_n(d);                // ld D,n
         $17: rla;                         // rla
         $18: jr;                          // jr
         $19: add_reg16_reg16(hl, de);     // add HL,DE
         $1a: ld_reg8_mem8r(a,de);         // ld A,(DE)
         $1b: dec16(de);                   // dec DE
         $1c: inc_8bit(e);                 // inc E
         $1d: dec_8bit(e);                 // dec E
         $1e: ld_reg8_n(e);                // ld E,n
         $1f: rra;                         // rra
         $20: jrc(NO_ZERO);                // jr NZ
         $21: ld_reg16_n(hl);              // ld HL,nn
         $22: ld_mem16_hl;                 // ld (nn),HL
         $23: inc16(hl);                   // inc HL
         $24: inc_8bit(h);                 // inc H
         $25: dec_8bit(h);                 // dec H
         $26: ld_reg8_n(h);                // ld H,n
         $27: daa();                       // daa
         $28: jrc(ZERO);                   // jr Z
         $29: add_reg16_reg16(hl,hl);      // add HL,HL
         $2a: ld_hl_mem16;                 // ld HL,(nn)
         $2b: dec16(hl);                   // dec HL
         $2c: inc_8bit(l);                 // inc L
         $2d: dec_8bit(l);                 // dec L
         $2e: ld_reg8_n(l);                // ld L,n
         $2f: cpl;                         // cpl
         $30: jrc(NO_CARRY);               // jr NC
         $31: ld_reg16_n(sp);              // ld SP,nn
         $32: ld_mem8_reg8(a);             // ld (nn),A
         $33: inc16(sp);                   // inc SP
         $34: inc_mem(hl);                 // inc (HL)
         $35: dec_mem(hl);                 // dec (HL)
         $36: ld_mem8r_n(hl);              // ld (HL),n
         $37: scf;                         // scf
         $38: jrc(CARRY);                  // jr C
         $39: add_reg16_reg16(hl,sp);      // add HL,SP
         $3a: ld_reg8_mem8(a);             // ld A,(nn)
         $3b: dec16(sp);                   // dec SP
         $3c: inc_8bit(a);                 // inc A
         $3d: dec_8bit(a);                 // dec A
         $3e: ld_reg8_n(a);                // ld A,n
         $3f: ccf;                         // ccf
         $40: ld_reg8_reg8(b,b);           // ld B,B
         $41: ld_reg8_reg8(b,c);           // ld B,C
         $42: ld_reg8_reg8(b,d);           // ld B,D
         $43: ld_reg8_reg8(b,e);           // ld B,E
         $44: ld_reg8_reg8(b,h);           // ld B,H
         $45: ld_reg8_reg8(b,l);           // ld B,L
         $46: ld_reg8_mem8r(b,hl);         // ld B,(HL)
         $47: ld_reg8_reg8(b,a);           // ld B,A
         $48: ld_reg8_reg8(c,b);           // ld C,B
         $49: ld_reg8_reg8(c,c);           // ld C,C
         $4a: ld_reg8_reg8(c,d);           // ld C,D
         $4b: ld_reg8_reg8(c,e);           // ld C,E
         $4c: ld_reg8_reg8(c,h);           // ld C,H
         $4d: ld_reg8_reg8(c,l);           // ld C,L
         $4e: ld_reg8_mem8r(c,hl);         // ld C,(HL)
         $4f: ld_reg8_reg8(c,a);           // ld C,A
         $50: ld_reg8_reg8(d,b);           // ld D,B
         $51: ld_reg8_reg8(d,c);           // ld D,C
         $52: ld_reg8_reg8(d,d);           // ld D,D
         $53: ld_reg8_reg8(d,e);           // ld D,E
         $54: ld_reg8_reg8(d,h);           // ld D,H
         $55: ld_reg8_reg8(d,l);           // ld D,L
         $56: ld_reg8_mem8r(d,hl);         // ld D,(HL)
         $57: ld_reg8_reg8(d,a);           // ld D,A
         $58: ld_reg8_reg8(e,b);           // ld E,B
         $59: ld_reg8_reg8(e,c);           // ld E,C
         $5a: ld_reg8_reg8(e,d);           // ld E,D
         $5b: ld_reg8_reg8(e,e);           // ld E,E
         $5c: ld_reg8_reg8(e,h);           // ld E,H
         $5d: ld_reg8_reg8(e,l);           // ld E,L
         $5e: ld_reg8_mem8r(e,hl);         // ld E,(HL)
         $5f: ld_reg8_reg8(e,a);           // ld E,A
         $60: ld_reg8_reg8(h,b);           // ld H,B
         $61: ld_reg8_reg8(h,c);           // ld H,C
         $62: ld_reg8_reg8(h,d);           // ld H,D
         $63: ld_reg8_reg8(h,e);           // ld H,E
         $64: ld_reg8_reg8(h,h);           // ld H,H
         $65: ld_reg8_reg8(h,l);           // ld H,L
         $66: ld_reg8_mem8r(h,hl);         // ld H,(HL)
         $67: ld_reg8_reg8(h,a);           // ld H,A
         $68: ld_reg8_reg8(l,b);           // ld L,B
         $69: ld_reg8_reg8(l,c);           // ld L,C
         $6a: ld_reg8_reg8(l,d);           // ld L,D
         $6b: ld_reg8_reg8(l,e);           // ld L,E
         $6c: ld_reg8_reg8(l,h);           // ld L,H
         $6d: ld_reg8_reg8(l,l);           // ld L,L
         $6e: ld_reg8_mem8r(l,hl);          // ld L,(HL)
         $6f: ld_reg8_reg8(l,a);           // ld L,A
         $70: ld_mem8r_reg(hl,b);          // LD (HL),B
         $71: ld_mem8r_reg(hl,c);          // LD (HL),C
         $72: ld_mem8r_reg(hl,d);          // LD (HL),D
         $73: ld_mem8r_reg(hl,e);          // LD (HL),E
         $74: ld_mem8r_reg(hl,h);          // LD (HL),h
         $75: ld_mem8r_reg(hl,l);          // LD (HL),l
         $76: halt;                        // HALT
         $77: ld_mem8r_reg(hl,a);          // LD (HL),A
         $78: ld_reg8_reg8(a,b);           // LD A,B
         $79: ld_reg8_reg8(a,c);           // LD A,C
         $7a: ld_reg8_reg8(a,d);           // LD A,D
         $7b: ld_reg8_reg8(a,e);           // LD A,E
         $7c: ld_reg8_reg8(a,h);           // LD A,h
         $7d: ld_reg8_reg8(a,l);           // LD A,l
         $7e: ld_reg8_mem8r(a,hl);         // LD A,(HL)
         $7f: ld_reg8_reg8(a,a);           // LD A,A
         $80: addareg(b);                  // ADD A,B
         $81: addareg(c);                  // ADD A,C
         $82: addareg(d);                  // ADD A,D
         $83: addareg(e);                  // ADD A,E
         $84: addareg(h);                  // ADD A,H
         $85: addareg(l);                  // ADD A,L
         $86: adda_mem8r(hl);              // ADD A,(HL)
         $87: addareg(a);                  // ADD A,A
         $88: adcareg(b);                  // ADC A,B
         $89: adcareg(c);                  // ADC A,C
         $8a: adcareg(e);                  // ADC A,D
         $8b: adcareg(r);                  // ADC A,E
         $8c: adcareg(h);                  // ADC A,H
         $8d: adcareg(l);                  // ADC A,L
         $8e: adca_mem8r(hl);              // ADC A,(HL)
         $8f: adcareg(a);                  // ADC A,A
         $90: subareg(b);                  // SUB A,B
         $91: subareg(c);                  // SUB A,C
         $92: subareg(d);                  // SUB A,D
         $93: subareg(e);                  // SUB A,E
         $94: subareg(h);                  // SUB A,H
         $95: subareg(l);                  // SUB A,L
         $96: suba_mem8r(hl);               // SUB A,(HL)
         $97: subareg(a);                  // SUB A,A
         $98: sbcareg(b);                  // SBC A,B
         $99: sbcareg(c);                  // SBC A,C
         $9a: sbcareg(d);                  // SBC A,D
         $9b: sbcareg(e);                  // SBC A,E
         $9c: sbcareg(h);                  // SBC A,H
         $9d: sbcareg(l);                  // SBC A,L
         $9e: sbca_mem8r(hl);              // SBC A,(HL)
         $9f: sbcareg(a);                  // SBC A,A
         $a0: andareg(b);                  // and A,B
         $a1: andareg(c);                  // and A,C
         $a2: andareg(d);                  // and A,D
         $a3: andareg(e);                  // and A,E
         $a4: andareg(h);                  // and A,H
         $a5: andareg(l);                  // and A,L
         $a6: anda_mem8r(hl);              // and A,(HL)
         $a7: andareg(a);                  // and A,A
         $a8: xorareg(b);                  // xor A,B
         $a9: xorareg(c);                  // xor A,C
         $aa: xorareg(d);                  // xor A,D
         $ab: xorareg(e);                  // xor A,E
         $ac: xorareg(h);                  // xor A,H
         $ad: xorareg(l);                  // xor A,L
         $ae: xora_mem8r(hl);              // xor A,(HL)
         $af: xorareg(a);                  // xor A,A
         $b0: orareg(b);                   // or A,B
         $b1: orareg(c);                   // or A,C
         $b2: orareg(d);                   // or A,D
         $b3: orareg(e);                   // or A,E
         $b4: orareg(h);                   // or A,H
         $b5: orareg(l);                   // or A,L
         $b6: ora_mem8r(hl);               // or A,(HL)
         $b7: orareg(a);                   // or A,A
         $b8: cpareg(b);                   // cp A,B
         $b9: cpareg(c);                   // cp A,C
         $ba: cpareg(d);                   // cp A,D
         $bb: cpareg(e);                   // cp A,E
         $bc: cpareg(h);                   // cp A,H
         $bd: cpareg(l);                   // cp A,L
         $be: cpa_mem8r(hl);               // cp A,(HL)
         $bf: cpareg(a);                   // cp A,A
         $c0: retc(NO_ZERO);               // RET NZ
         $c1: popr(bc);                    // POP BC
         $c2: jpc(NO_ZERO);                // JP NZ,NN
         $c3: jmp;                         // JP NN
         $c4: callc(NO_ZERO);              // CALL NZ,NN
         $c5: pushr(bc);                   // PUSH BC
         $c6: addan;                       // ADD A,N
         $c7: rst(0);                      // RST 0
         $c8: retc(ZERO);                  // RET Z
         $c9: ret;                         // RET
         $ca: jpc(ZERO);                   // JP Z,NN
         $cb: cb_instructions;             // prefijo CB
         $cc: callc(ZERO);                 // CALL Z,NN
         $cd: calln;                       // CALL NN
         $ce: adcan;                       // ADC A,N
         $cf: rst(8);                      // RST 8
         $d0: retc(NO_CARRY);              // RET NC
         $d1: popr(de);                    // POP DE
         $d2: jpc(NO_CARRY);               // JP NC,NN
         $d3: out_n;                       // OUT(N),A
         $d4: callc(NO_CARRY);             // CALL NC,NN
         $d5: pushr(de);                   // PUSH DE
         $d6: suban;                       // SUB A,N
         $d7: rst(16);                     // RST 16
         $d8: retc(CARRY);                 // RET C
         $d9: exx;                         // EXX
         $da: jpc(CARRY);                  // JP C,NN
         $db: in_n;                        // IN A,(N)
         $dc: callc(CARRY);                // CALL C,NN
         $dd: ddfd_instructions(ix);       // prefijo dd
         $de: sbcan;                       // SBC A,N
         $df: rst(24);                     // RST 24
         $e0: retc(PARITY_ODD);            // RET PO
         $e1: popr(hl);                    // POP HL
         $e2: jpc(PARITY_ODD);             // JP PO,NN
         $e3: EX_mem_hl;                   // EX (SP),HL
         $e4: callc(PARITY_ODD);           // CALL PO,NN
         $e5: pushr(hl);                   // PUSH HL
         $e6: anda_n;                       // AND N
         $e7: rst(32);                      // RST 32
         $e8: retc(PARITY_EVEN);            // RET PE
         $e9: jphl;                         // JP (HL)
         $ea: jpc(PARITY_EVEN);             // JP PE,NN
         $eb: EX_reg_reg(de,hl);            // EX DE,HL
         $ec: callc(PARITY_EVEN);           // CALL PE,NN
         $ed: ed_instructions;              // prefijo ed
         $ee: xoran;                        // XOR N
         $ef: rst(40);                      // RST 40
         $f0: retc(POSITIVE);               // RET POS
         $f1: popaf;                        // POP AF
         $f2: jpc(POSITIVE);                // JP P,NN
         $f3: disable_int;                  // DI
         $f4: callc(POSITIVE);              // CALL P,NN
         $f5: pushr(af);                    // PUSH AF
         $f6: oran;                         // OR N
         $f7: rst(48);                      // RST 48
         $f8: retc(NEGATIVE);               // RET NEG
         $f9: ld_SP_reg16(hl);              // LD SP,HL
         $fa: jpc(NEGATIVE);                // JP NEG,NN
         $fb: enable_int;                   // EI
         $fc: callc(NEGATIVE);              // CALL NEG,NN
         $fd: ddfd_instructions(iy);        // prefijo fd
         $fe: cpa(fetch_pc);                // CP N
         $ff: rst(56);                      // RST 56

    end;
    if (intpend or NMI) and halted then begin
       halted := false;
       inc(pc);
    end;
    if NMI then begin
       iff1 := false;
       t_states+=14;
       NMI := false;
       push2(pc);
       inc_register_r;
       t_states += 6;

       pc := $66;

       // temp????
       t_states -=15;
    end;
    if intpend and iff1 then begin
       intpend := false;
       push2(pc);
       inc_register_r;
       iff1 := false;
       if (im = 0) or (im = 1)then begin
           pc := $38;
           inc(t_states, 7);
       end else begin // IM 2
            addr := i*256+255;
            pc := rdmem2(addr);
            inc(t_states,7);
       end;
    end;
end;

procedure hot_reset_z80();
begin
    i:= 0;
    pc:=0;
    af:=$ffff;
    sp:=$ffff;

end;

procedure init_z80(coldboot: boolean);
var
   x: byte;
begin
    if coldboot then
       for x := 0 to 31 do
           fillchar(MemP[x], $4000, 0);
    //move(sp48rom, MemP[0,0], sizeof(sp48rom));
    af:=$ffff;
    bc:=$ffff;
    de:=$ffff;
    hl:=$ffff;

    af1:=$ffff;
    bc1:=$ffff;
    de1:=$ffff;
    hl1:=$ffff;

    i:= 0;
    iff1:=false;
    iff2:=false;
    im:=0;
    r:=0;
    r_bit7 := 0;

    ix:=$ffff;
    iy:=$ffff;
    sp:=$ffff;
    pc:=0;

    halted := false;

    explode_flags;

    t_states := 0;
    t_states_ini_frame := 0;

end;

end.

