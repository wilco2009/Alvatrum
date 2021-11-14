unit Z80Tools;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,z80Globals;

function decode_instruction(addr: word): string;
function get_instruction_len(s: string): byte;
function get_instruction(s: string): string;

implementation

function val3bit(v: word; desp: byte): string;
var
   S: String;
begin
  str((rdmem(v) >> desp) and 7,S);
  val3bit := S;
end;

function cond(v: word; desp: byte): string;
var
  r: array[0..7] of string = ('NZ', 'Z', 'NC', 'C', 'PO', 'PE', 'P', 'M');
begin
  cond := r[(rdmem(v) >> desp) and 7];
end;

function reg8(v: word; desp: byte): string;
var
  r: array[0..7] of string = ('B', 'C', 'D', 'E', 'H', 'L', '(HL)', 'A');
begin
  reg8 := r[(rdmem(v) >> desp) and 7];
end;

function reg16(v: word; desp: byte): string;
var
  r: array[0..3] of string = ('BC', 'DE', 'HL', 'SP');
begin
  reg16 := r[(rdmem(v)>>desp) and 3];
end;

function reg16pp(v: word; desp: byte): string;
var
  r: array[0..3] of string = ('BC', 'DE', 'HL', 'AF');
begin
  reg16pp := r[(rdmem(v)>>desp) and 3];
end;

function reg16ixiy(v: word; desp: byte;reg:string): string;
var
  r: array[0..3] of string = ('BC', 'DE', 'IX', 'AF');
  n: byte;
begin
  n := (rdmem(v)>>desp) and 3;
  if n = 2 then reg16ixiy := reg
  else reg16ixiy := r[n];
end;

function get_instruction_len(s: string): byte;
var
  rr, ss: byte;
begin
  rr := 1;
  while (rr <= length(s)) and (s[rr] = ' ') do
    inc(rr);
  ss := rr;
  while (rr <= length(s)) and (s[rr] <> ':') do
    inc(rr);
  get_instruction_len := (rr-ss) div 2;
end;

function get_instruction(s: string): string;
var
  len,rr: byte;
begin
  //len := get_instruction_len(s);
  rr := 13;
  while (rr <= length(s)) and (s[rr] = ' ') do
    inc(rr);
  get_instruction := copy(s,14,rr-12+1);
end;
function decode_instruction(addr: word): string;
var
  byte1, byte2, byte3, byte4: byte;
  res: string;

  function comp(command, param1, param2: string; size: byte): string;
  const
    S = '            ';
  var
    Tmp: String;
    i: word;
  begin
       Tmp := Copy(S,0,10-size*2);
       for i := addr to addr+size-1 do
           Tmp := Tmp + HexStr(rdmem(i),2);
       Tmp := Tmp + ':  '+command;
       if param1 <> '' then
          Tmp := Tmp+' '+param1;
       if param2 <> '' then
          Tmp := Tmp + ','+param2;
       comp := Tmp;
  end;

  function mem_w(addr: word): string;
  begin
       mem_w := HexStr(rdmem2(addr),4);
  end;

  function rel_addr(org, addr_desp: word): string;
  var
    addr: word;
    desp_b: byte;
    desp_i: integer;
  begin
       desp_b := rdmem(addr_desp)+2;
       if desp_b > 127 then desp_i := -(byte(not desp_b)+1)
       else desp_i := desp_b;
       addr := org + desp_i;
       rel_addr := HexStr(addr,4);
  end;

  function mem_b_s(addr_desp: word): string;
  var
     S: String;
     s_v: shortint;
  begin
       s_v := rdmem_signed(addr_desp);
       S := HexStr(abs(s_v),2);
       if s_v < 0 then
          S := '-' + S
       else
           S := '+' + S;
       mem_b_s := S;
  end;

  function mem_b(addr: word): string;
  begin
       mem_b := HexStr(rdmem(addr),2);
  end;

  function ixiy_addr(reg: word;desp: word): string;
  var
    v: word;
    s_v: integer;
  begin
    s_v := rdmem_signed(desp);
    v := reg+s_v;
    ixiy_addr := ' --> ['+HexStr(v,4)+']';
  end;

  function extended_opcodes: string;
  begin
    case byte2 of
         $43,$53,
         $63,$73  : res := comp('LD','('+mem_w(addr+2)+')',reg16(addr+1,4),4);
         $4B,$5B,
         $6B,$7B  : res := comp('LD',reg16(addr+1,4),'('+mem_w(addr+2)+')',4);
         $47      : res := comp('LD','I','A',2);
         $4f      : res := comp('LD','R','A',2);
         $57      : res := comp('LD','A','I',2);
         $5f      : res := comp('LD','A','R',2);
         $a0      : res := comp('LDI','','',2);
         $b0      : res := comp('LDIR','','',2);
         $a8      : res := comp('LDD','','',2);
         $b8      : res := comp('LDDR','','',2);
         $a1      : res := comp('CPI','','',2);
         $b1      : res := comp('CPIR','','',2);
         $a9      : res := comp('CPD','','',2);
         $b9      : res := comp('CPDR','','',2);
         $44      : res := comp('NEG','','',2);
         $46      : res := comp('IM 0','','',2);
         $56      : res := comp('IM 1','','',2);
         $5E      : res := comp('IM 2','','',2);
         $4a,$5a,
         $6a,$7a  : res := comp('ADC','HL',reg16(addr+1,4),2);
         $42,$52,
         $62,$72  : res := comp('SBC','HL',reg16(addr+1,4),2);
         $6f      : res := comp('RLD','','',2);
         $67      : res := comp('RRD','','',2);
         $40,$48,
         $50,$58,
         $60,$68,
         $70,$78  : res := comp('IN',reg8(addr+1,3),'(C)',2);
         $a2      : res := comp('INI','','',2);
         $b2      : res := comp('INIR','','',2);
         $aa      : res := comp('IND','','',2);
         $ba      : res := comp('INDR','','',2);
         $41,$49,
         $51,$59,
         $61,$69,
         $71,$79  : res := comp('OUT','(C)',reg8(addr+1,3),2);
         $a3      : res := comp('OUTI','','',2);
         $b4      : res := comp('OTIR','','',2);
         $ab      : res := comp('OUTD','','',2);
         $bb      : res := comp('OTDR','','',2);
         else     res := comp('invalid opcode','','',5);
    end;
    extended_opcodes := res;
  end;

  function bit_IX_IY_instructions(reg: string): string;
  var
    wreg: word;
  begin  // IX/IY
    if reg='IX' then wreg := ix
    else wreg := iy;
    case byte4 of
         $06      : res := comp('RLC','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $16      : res := comp('RL','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $0e      : res := comp('RRC','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $1e      : res := comp('RR','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $26      : res := comp('SLA','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $2e      : res := comp('SRA','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $3e      : res := comp('SRL','('+reg+mem_b_s(addr+2)+')','',4)+ ixiy_addr(wreg,addr+2);
         $46,$4e,
         $56,$5e,
         $66,$6e,
         $76,$7e  : res := comp('BIT',val3bit(addr+3,3),'('+reg+mem_b_s(addr+2)+')',4)+ ixiy_addr(wreg,addr+2);
         $c6,$ce,
         $d6,$de,
         $e6,$ee,
         $f6,$fe: res := comp('SET',val3bit(addr+3,3),'('+reg+mem_b_s(addr+2)+')',4)+ ixiy_addr(wreg,addr+2);
         $86,$8e,
         $96,$9e,
         $a6,$ae,
         $b6,$be  : res := comp('RES',val3bit(addr+3,3),'('+reg+mem_b_s(addr+2)+')',4)+ ixiy_addr(wreg,addr+2);
         $4d      : res := comp('RETI', '','',2);
         $45      : res := comp('RETN', '','',2);
         else     res := comp('invalid opcode','','',5);
    end;
    bit_IX_IY_instructions := res;
  end;

  function IX_IY_Instructions(reg: String): String;
  var
    wreg: word;
  begin  // IX/IY
    if reg='IX' then wreg := ix
    else wreg := iy;
     case byte2 of
          $21      : res := comp('LD',reg,mem_w(addr+2), 4);
          $22      : res := comp('LD','('+mem_w(addr+2)+')',reg,4);
          $2A      : res := comp('LD',reg,'('+mem_w(addr+2)+')',4);
          $46,$4E,
          $56,$5E,
          $66,$6E,
              $7E  : res := comp('LD',reg8(addr+1,3),'('+reg+mem_b_s(addr+2)+')',3)+ ixiy_addr(wreg,addr+2);

          $70..$77 : res := comp('LD','('+reg+mem_b_s(addr+2)+')',reg8(addr+1,0),3)+ ixiy_addr(wreg,addr+2);

          $36      : res := comp('LD','('+reg+mem_b_s(addr+2)+')',mem_b(addr+3),4)+ ixiy_addr(wreg,addr+2);
          $e1      : res := comp('POP',reg,'',2);
          $e5      : res := comp('PUSH',reg,'',2);
          $f9      : res := comp('LD','SP',reg,2);
          $e3      : res := comp('EX','(SP)',reg,2);
          $86      : res := comp('ADD','A','('+reg+mem_b_s(addr+2)+')',3)+ ixiy_addr(wreg,addr+2);
          $8e      : res := comp('ADC','A','('+reg+mem_b_s(addr+2)+')',3)+ ixiy_addr(wreg,addr+2);
          $96      : res := comp('SUB','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $9e      : res := comp('SBC','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $a6      : res := comp('AND','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $b6      : res := comp('OR','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $ae      : res := comp('XOR','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $be      : res := comp('CP','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $34      : res := comp('INC','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $35      : res := comp('DEC','('+reg+mem_b_s(addr+2)+')','',3)+ ixiy_addr(wreg,addr+2);
          $9,$19,
          $29,$39  : res := comp('ADD',reg,reg16ixiy(addr,4,reg),2);
          $23      : res := comp('INC',reg,'',2);
          $2b      : res := comp('DEC',reg,'',2);
          $cb      : res := bit_ix_iy_instructions(reg);
          $e9      : res := comp('JP', '('+reg+')','',2);
          else     res := comp('invalid opcode','','',5);
     end;
     IX_IY_Instructions := res;
  end;

  function bit_instructions: string;
  begin
    case byte2 of
         $00..$07  : res := comp('RLC',reg8(addr+1,0),'',2);
         $10..$17  : res := comp('RL',reg8(addr+1,0),'',2);
         $08..$0f  : res := comp('RRC',reg8(addr+1,0),'',2);
         $18..$1f  : res := comp('RR',reg8(addr+1,0),'',2);
         $20..$27  : res := comp('SLA',reg8(addr+1,0),'',2);
         $30..$37  : res := comp('SLL',reg8(addr+1,0),'',2);
         $28..$2f  : res := comp('SRA',reg8(addr+1,0),'',2);
         $38..$3f  : res := comp('SRL',reg8(addr+1,0),'',2);
         $40..$7f  : res := comp('BIT',val3bit(addr+1,3),reg8(addr+1,0),2);
         $c0..$ff  : res := comp('SET',val3bit(addr+1,3),reg8(addr+1,0),2);
         $80..$bf  : res := comp('RES',val3bit(addr+1,3),reg8(addr+1,0),2);
         else     res := comp('invalid opcode','','',5);
    end;
    bit_instructions := res;
  end;


begin
  byte1 := rdmem(addr);
  byte2 := rdmem(addr+1);
  byte3 := rdmem(addr+2);
  byte4 := rdmem(addr+3);
  case byte1 of
       $22      : res := comp('LD','('+mem_w(addr+1)+')','HL',3);
       $2A      : res := comp('LD','HL','('+mem_w(addr+1)+')',3);
       $40..$75,
       $77..$7f : res := comp('LD',reg8(addr,3),reg8(addr,0),1);
       $01,$11,
       $21,$31  : res := comp('LD',reg16(addr,4),mem_w(addr+1),3);
       $06,$0E,
       $16,$1E,
       $26,$2E,
       $36,$3E  : res := comp('LD',reg8(addr,3),mem_b(addr+1),2);
       $02      : res := comp('LD','(BC)','A',1);
       $12      : res := comp('LD','(DE)','A',1);
       $0a      : res := comp('LD','A','(BC)',1);
       $1a      : res := comp('LD','A','(DE)',1);
       $32      : res := comp('LD','('+mem_w(addr+1)+')','A',3);
       $3a      : res := comp('LD','A','('+mem_w(addr+1)+')',3);
       $c1,$d1,
       $e1,$f1  : res := comp('POP', reg16pp(addr,4),'',1);
       $c5,$d5,
       $e5,$f5  : res := comp('PUSH', reg16pp(addr,4),'',1);
       $f9      : res := comp('LD','SP','HL',1);

       $eb      : res := comp('EX','DE','HL',1);
       $08      : res := comp('EX','AF','AF''',1);
       $d9      : res := comp('EXX','','',1);
       $e3      : res := comp('EX','(SP)','HL',1);

       $80..$87 : res := comp('ADD','A',reg8(addr,0),1);

       $c6      : res := comp('ADD','A',mem_b(addr+1),2);

       $dd      : res := IX_IY_instructions('IX');
       $ed      : res := extended_opcodes;
       $fd      : res := IX_IY_instructions('IY');

       $88..$8f : res := comp('ADC','A',reg8(addr,0),1);
       $ce      : res := comp('ADC','A',mem_b(addr+1),2);

       $90..$97 : res := comp('SUB',reg8(addr,0),'',1);
       $d6      : res := comp('SUB',mem_b(addr+1),'',2);
       $98..$9f : res := comp('SBC','A',reg8(addr,0),1);
       $de      : res := comp('SBC',mem_b(addr+1),'',2);
       $a0..$a7 : res := comp('AND',reg8(addr,0),'',1);
       $e6      : res := comp('AND',mem_b(addr+1),'',2);
       $b0..$b7 : res := comp('OR',reg8(addr,0),'',1);
       $f6      : res := comp('OR',mem_b(addr+1),'',2);
       $a8..$af : res := comp('XOR',reg8(addr,0),'',1);
       $ee      : res := comp('XOR',mem_b(addr+1),'',2);
       $b8..$bf : res := comp('CP',reg8(addr,0),'',1);
       $fe      : res := comp('CP',mem_b(addr+1),'',2);
       $04,$0c,
       $14,$1c,
       $24,$2c,
       $34,$3c  : res := comp('INC',reg8(addr,3),'',1);
       $05,$0d,
       $15,$1d,
       $25,$2d,
       $35,$3d  : res := comp('DEC',reg8(addr,3),'',1);
       $27      : res := comp('DAA','','',1);
       $2f      : res := comp('CPL','','',1);
       $3f      : res := comp('CCF','','',1);
       $37      : res := comp('SCF','','',1);
       $00      : res := comp('NOP','','',1);
       $76      : res := comp('HALT','','',1);
       $f3      : res := comp('DI','','',1);
       $fb      : res := comp('EI','','',1);
       $09,$19,
       $29,$39  : res := comp('ADD','HL',reg16(addr,4),1);
       $03,$13,
       $23,$33  : res := comp('INC',reg16(addr,4),'',1);
       $0b,$1b,
       $2b,$3b  : res := comp('DEC',reg16(addr,4),'',1);
       $07      : res := comp('RLCA','','',1);
       $17      : res := comp('RLA','','',1);
       $0f      : res := comp('RRCA','','',1);
       $1f      : res := comp('RRA','','',1);
       $cb      : res := bit_instructions;

       $c3      : res := comp('JP', mem_w(addr+1),'',3);
       $c2,$ca,
       $d2,$da,
       $e2,$ea,
       $f2,$fa  : res := comp('JP', cond(addr,3),mem_w(addr+1),3);
       $18      : res := comp('JR', rel_addr(addr,addr+1),'',2);
       $38      : res := comp('JR', 'C',rel_addr(addr,addr+1),2);
       $30      : res := comp('JR', 'NC',rel_addr(addr,addr+1),2);
       $28      : res := comp('JR', 'Z',rel_addr(addr,addr+1),2);
       $20      : res := comp('JR', 'NZ',rel_addr(addr,addr+1),2);
       $e9      : res := comp('JP', '(HL)','',1);
       $10      : res := comp('DJNZ', rel_addr(addr,addr+1),'',2);
       $cd      : res := comp('CALL', mem_w(addr+1),'',3);
       $c4,$cc,
       $d4,$dc,
       $e4,$ec,
       $f4,$fc  : res := comp('CALL', cond(addr,3),mem_w(addr+1),3);
       $c9      : res := comp('RET','','',1);
       $c0,$c8,
       $d0,$d8,
       $e0,$e8,
       $f0,$f8  : res := comp('RET', cond(addr,3),'',1);
       $c7,$cf,
       $d7,$df,
       $e7,$ef,
       $f7,$ff  : res := comp('RST', HexStr(rdmem(addr) and $38,2),'',1);
       $db      : res := comp('IN', 'A','('+mem_b(addr+1)+')',2);
       $d3      : res := comp('OUT', '('+mem_b(addr+1)+')','A',2);
       else     res := comp('invalid opcode','','',5);
  end;
  decode_instruction := res;
end;

end.

