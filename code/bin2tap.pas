unit bin2tap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure bin_to_tap(FileNameIn: String; FileNameOut: String; blockName: String; start_addr: word);

implementation
{$ALIGN 1}

type
  THeader = record
    len: word;
    flag1: byte;
    HType: byte;
    HName: array[1..10] of char;
    data_block_len: word;
    data_block_start: word;
    param2: word;
    parity: byte;
    len2: word;
    flag2: byte;
  end;

var
  FIn, FOut: File;
  Header: THeader;
  HeaderA: array[1..19] of byte absolute Header;
  Parity: byte;


procedure bin_to_tap(FileNameIn: String; FileNameOut: String; blockName: String; start_addr: word);
  procedure write_header_block;
  var
    j: byte;
  begin
    Header.len      := $13;
    Header.flag1    := $00; // header flag
    Header.HType    := $03; // code block
    for j := 1 to 10 do
      if j <= length(BlockName) then
        Header.HName[j] := BlockName[j]
      else
        Header.HName[j] := ' ';
    Header.data_block_len:= filesize(FIn);
    Header.data_block_start := start_addr;
    Header.param2 := $8000;
    Parity := 0;
    for j := 2 to 19 do
      Parity := Parity xor HeaderA[j];
    Header.parity:=Parity;
    Header.len2:= Header.data_block_len+2;
    Header.flag2 := $ff;
    Blockwrite(FOut,Header,sizeof(Header));
  end;

  procedure write_data_block;
  var
    din: byte;
    j: longint;
  begin
    Parity := Header.flag2;
    for j := 0 to filesize(FIn)-1 do
    begin
      Blockread(Fin,din,1);
      Blockwrite(FOut,din,1);
      Parity := Parity xor din;
    end;
    Blockwrite(FOut,Parity,1);
  end;

begin
  AssignFile(FIn, FileNameIn);
  Reset(FIn,1);
  AssignFile(Fout,FileNameOut);
  Rewrite(FOut,1);
  write_header_block;
  write_data_block;
  Closefile(FIn);
  Closefile(FOut);
end;

begin
end.
