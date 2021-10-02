program Spectrum_Emulator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, Z80, Z80ops, Z80Globals, z80bitops, Z80bitops_ixiy, roms, Screen,
  fastbitmap, Z80Tools
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TSpecEmu, SpecEmu);
  Application.Run;
end.

