program Alvatrum;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, etpackage, laz_acs_lib, pascalscript, main, Z80, Z80ops, Z80Globals,
  z80bitops, Z80bitops_ixiy, roms, Screen, fastbitmap, Z80Tools, exops,
  spectrum, TAP, Global, hardware, FileFormats;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.ExtendedKeysSupport:= true;
  Application.CreateForm(TSpecEmu, SpecEmu);
  Application.Run;
end.

