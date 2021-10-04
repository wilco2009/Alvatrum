unit main;

{$mode objfpc}{$H+}
{$MACRO ON}
{$OPTIMIZATION LEVEL2}

interface

uses
  Classes, SysUtils, FileUtil, uPSComponent, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, z80, Z80ops, BGRABitmap, BGRABitmapTypes,
  z80Globals, Z80Tools, LCLType, Grids, ComCtrls, acs_audio, acs_file, acs_misc,
  acs_streams, BCListBox, BCGameGrid, CRT, BGRAGraphicControl,
  BGRASpriteAnimation, BGRAResizeSpeedButton, spectrum, SDL, epiktimer;
type

  { TSpecEmu }

  TSpecEmu = class(TForm)
    AcsAudioOut1: TAcsAudioOut;
    AcsMemoryIn1: TAcsMemoryIn;
    ApplicationProperties1: TApplicationProperties;
    AsciiSelection: TCheckBox;
    BFocus: TBitBtn;
    ButtonDeleteBlock: TBGRAResizeSpeedButton;
    ButtonTapeFirst: TBGRAResizeSpeedButton;
    ButonTapeEnd: TBGRAResizeSpeedButton;
    ButtonRew: TBGRAResizeSpeedButton;
    ButtonFWD: TBGRAResizeSpeedButton;
    ButtonEject: TBGRAResizeSpeedButton;
    ButtonStop: TBGRAResizeSpeedButton;
    ButtonPlay: TBGRAResizeSpeedButton;
    ButtonPlayPressed: TBGRAResizeSpeedButton;
    ButtonRec: TBGRAResizeSpeedButton;
    ButtonRecPressed: TBGRAResizeSpeedButton;
    ButtonBlockdown: TBGRAResizeSpeedButton;
    ButtonBlockUp: TBGRAResizeSpeedButton;
    Button_a: TBGRAResizeSpeedButton;
    Button_CS_LOCK: TBGRAResizeSpeedButton;
    Button_F: TBGRAResizeSpeedButton;
    Button_G: TBGRAResizeSpeedButton;
    Button_H: TBGRAResizeSpeedButton;
    Button_J: TBGRAResizeSpeedButton;
    Button_K: TBGRAResizeSpeedButton;
    Button_L: TBGRAResizeSpeedButton;
    Button_SS_LOCK: TBGRAResizeSpeedButton;
    Button_Z: TBGRAResizeSpeedButton;
    Button_s: TBGRAResizeSpeedButton;
    Button_d: TBGRAResizeSpeedButton;
    Button_SPACE: TBGRAResizeSpeedButton;
    Button_SS: TBGRAResizeSpeedButton;
    Button_CS: TBGRAResizeSpeedButton;
    Button_O: TBGRAResizeSpeedButton;
    Button_P: TBGRAResizeSpeedButton;
    Button_ENTER: TBGRAResizeSpeedButton;
    Button_R: TBGRAResizeSpeedButton;
    Button_q: TBGRAResizeSpeedButton;
    Button_nueve: TBGRAResizeSpeedButton;
    Button_cero: TBGRAResizeSpeedButton;
    Button_T: TBGRAResizeSpeedButton;
    Button_I: TBGRAResizeSpeedButton;
    Button_Y: TBGRAResizeSpeedButton;
    Button_w: TBGRAResizeSpeedButton;
    Button_seis: TBGRAResizeSpeedButton;
    Button_siete: TBGRAResizeSpeedButton;
    Button_ocho: TBGRAResizeSpeedButton;
    Button_tres: TBGRAResizeSpeedButton;
    Button_cuatro: TBGRAResizeSpeedButton;
    Button_cinco: TBGRAResizeSpeedButton;
    Button_uno: TBGRAResizeSpeedButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ButtonDebug: TSpeedButton;
    ButtonTap: TSpeedButton;
    ButtonTap1: TSpeedButton;
    Button_dos: TBGRAResizeSpeedButton;
    Button_E: TBGRAResizeSpeedButton;
    Button_U: TBGRAResizeSpeedButton;
    Button_X: TBGRAResizeSpeedButton;
    Button_C: TBGRAResizeSpeedButton;
    Button_V: TBGRAResizeSpeedButton;
    Button_B: TBGRAResizeSpeedButton;
    Button_N: TBGRAResizeSpeedButton;
    Button_M: TBGRAResizeSpeedButton;
    DumpSource: TRadioGroup;
    EdBreak: TEdit;
    EdMem: TEdit;
    screen_timer: TEpikTimer;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    BlockGrid: TStringGrid;
    OpenTapFileDialog: TOpenDialog;
    FlagsPanel: TPanel;
    PanelKeyboard: TPanel;
    SideButtons: TPanel;
    src_ix: TRadioButton;
    src_iy: TRadioButton;
    src_ptr: TRadioButton;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    stBreak: TStaticText;
    stFlags: TStaticText;
    stMem: TStaticText;
    stTstates: TStaticText;
    stTstatesFrame: TStaticText;
    TapeRecLed: TShape;
    TapeFileName: TStaticText;
    TapePanel: TPanel;
    TapePlayLed: TShape;
    ZoomOutButton: TBitBtn;
    ZoomInButton: TBitBtn;
    Pantalla: TBGRAGraphicControl;
    PauseButton: TBitBtn;
    PlayButton: TBitBtn;
    ResetButton: TBitBtn;
    StepButton: TBitBtn;
    TapeImage: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    labelI: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    BottomButtonsPanel: TPanel;
    DebugPanel: TPanel;
    Panel3: TPanel;
    stAF1: TStaticText;
    stBCc: TStaticText;
    stHLc: TStaticText;
    stDEc: TStaticText;
    stIM: TStaticText;
    stIff1: TStaticText;
    stInstruction: TStaticText;
    stBC1: TStaticText;
    stDE1: TStaticText;
    stHL1: TStaticText;
    stPC: TStaticText;
    stAF: TStaticText;
    stBC: TStaticText;
    stDE: TStaticText;
    stHL: TStaticText;
    stIX: TStaticText;
    memgrid: TStringGrid;
    stStack: TStaticText;
    stRR: TStaticText;
    stSP: TStaticText;
    stIY: TStaticText;
    stII: TStaticText;
    Timer1: TTimer;
    procedure AcsMemoryIn1BufferDone(Sender: TComponent);
    procedure ApplicationProperties1Activate(Sender: TObject);
    procedure AsciiSelectionChange(Sender: TObject);
    procedure BFocusClick(Sender: TObject);
    procedure BFocusdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BFocusdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ButtonBlockdownClick(Sender: TObject);
    procedure ButtonBlockUpClick(Sender: TObject);
    procedure ButtonEjectClick(Sender: TObject);
    procedure ButtonFWDClick(Sender: TObject);
    procedure ButtonPlayClick(Sender: TObject);
    procedure ButtonPlayPressedClick(Sender: TObject);
    procedure ButtonRecClick(Sender: TObject);
    procedure ButtonDeleteBlockClick(Sender: TObject);
    procedure ButtonTapeFirstClick(Sender: TObject);
    procedure ButonTapeEndClick(Sender: TObject);
    procedure ButtonRecPressedClick(Sender: TObject);
    procedure ButtonRewClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure Button_aMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_aMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_BMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_BMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ceroMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ceroMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_cincoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_cincoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_CMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_CMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_CSClick(Sender: TObject);
    procedure Button_CSMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_CSMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_CS_LOCKClick(Sender: TObject);
    procedure Button_cuatroMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_cuatroMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_dMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_dMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_dosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_dosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_EMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_EMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ENTERMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ENTERMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_FMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_FMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_GMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_GMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_HMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_HMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_IMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_IMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_JMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_JMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_KMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_KMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_LMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_LMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_MMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_MMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_NMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_NMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_nueveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_nueveMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ochoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ochoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_OMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_OMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_PMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_PMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_qMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_qMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_RMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_RMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_seisMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_seisMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_sieteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_sieteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_sMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_sMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_SPACEMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_SPACEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_SSClick(Sender: TObject);
    procedure Button_SSMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_SSMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_SS_LOCKClick(Sender: TObject);
    procedure Button_TMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_TMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_tresMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_tresMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_UMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_UMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_unoClick(Sender: TObject);
    procedure Button_unoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_unoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_VMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_VMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_wMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_wMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_XMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_XMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_YMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_YMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ZClick(Sender: TObject);
    procedure Button_ZMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_ZMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure KeyMouseEnter(Sender: TObject);
    procedure KeyMouseLeave(Sender: TObject);
    procedure BlockGridAfterSelection(Sender: TObject; aCol, aRow: Integer);
    procedure BlockGridBeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure ButtonTap1Click(Sender: TObject);
    procedure ButtonTapClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure OpenTapFileDialogClose(Sender: TObject);
    procedure OpenTapFileDialogSelectionChange(Sender: TObject);
    procedure PanelKeyboardMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PantallaPaint(Sender: TObject);
    procedure PauseButtonClick(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure ResetButtonClick(Sender: TObject);
    procedure StepButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure DumpSourceSelectionChanged(Sender: TObject);
    procedure DumpSourceSizeConstraintsChange(Sender: TObject);
    procedure EdBreakKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure EdMemKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure PantallaClick(Sender: TObject);
    procedure ScreenClick(Sender: TObject);
    procedure ButtonDebugClick(Sender: TObject);
    procedure src_ixChange(Sender: TObject);
    procedure src_iyChange(Sender: TObject);
    procedure src_ptrChange(Sender: TObject);
    procedure src_ptrSizeConstraintsChange(Sender: TObject);
    procedure stBreakClick(Sender: TObject);
    procedure stInstructionClick(Sender: TObject);
    procedure stIYClick(Sender: TObject);
    procedure stPCClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ZoomInButtonClick(Sender: TObject);
    procedure ZoomOutButtonClick(Sender: TObject);
  private
    saliendo, starting, pause, step, breakpoint_active: boolean;
    SS_Status: Byte;
    breakpoint, mem_addr: word;
    empezando : boolean;
    Tape_blocks: word;
    SavedWidth: integer;
    SavedHeight: integer;
    SavedTop: integer;
    SavedLeft: integer;
    procedure draw_screen;
    procedure RunEmulation;
    procedure refresh_registers;
    procedure start_debug;
    procedure stop_debug;
    procedure set_breakpoint;
    procedure set_mem_label;
    procedure set_mem;
    procedure set_stack_label;
    procedure set_memory_dump;
    procedure adjust_window_size;
    procedure Hide_Tape;
    procedure Show_Tape;
    procedure Show_Debugger;
    procedure Hide_Debugger;
    procedure Show_Keyboard;
    procedure Hide_Keyboard;
    procedure Hideall;

    procedure move_tap_block(uno, dos: word);
    procedure Delete_Tape_Block(row: word);
    procedure Read_tap_blocs;
    procedure Tape_select(n: integer);
    procedure Set_tape_leds;

    function tap_checksum(flag: byte; addr,len: word): byte;
    function Load_Tape_block(addr, len: word; flag: byte): byte;
    function Save_Tape_block(addr, len: word; flag: byte): byte;
    procedure resetkeyb(fila, bit: byte);
    procedure reset_SS;
    procedure reset_CS;
    procedure setkeyb(fila, bit: byte);
  public

  end;

const
   sizex1x = 256+ancho_borde*2;
   sizey1x = 192+alto_borde*2;
   Visible_debug_width = 632;
   Visible_TapePanel_Width = 495;
   buttons_height = 44;


var
   sizex, sizey, scale,bak_scale: word;
  SpecEmu: TSpecEmu;
  jj: word = 0;
  frame_counter: word = 0;
  debug_width : integer = 0;
  TapePanelWidth: integer = 0;
  KeyboardWidth: integer = 0;
  RegulatedSpeed: Boolean = True;
  buff: Array[0..$ffff] of byte;
  tmp_delay: longint = 5000;

implementation

{$R *.lfm}

{ TSpecEmu }

procedure TSpecEmu.move_tap_block(uno,dos: word);
Var
  F, FBak: File;
  tmp: Word;
  result: integer;
begin
  if dos < uno then
  begin
    tmp := dos;
    dos := uno;
    uno := tmp;
  end;
  CopyFile(OpenTapFileDialog.FileName, '$$$$$$$$.$$$');
  AssignFile (F, OpenTapFileDialog.FileName);
  Reset(F,1);
  AssignFile (FBak, '$$$$$$$$.$$$');
  Reset(FBak,1);

  // copy block from fbak(dos) to f(uno)
  seek(Fbak, Tape_info[dos].Filepos);
  blockread(fbak,buffer,Tape_info[dos].size+2);
  seek(F, Tape_info[uno].Filepos);
  blockwrite(f,buffer,Tape_info[dos].size+2);

  // copy block from fbak(uno) to f(uno)+size(uno)+2
  seek(Fbak, Tape_info[uno].Filepos);
  blockread(fbak,buffer,Tape_info[uno].size+2);
  seek(F, Tape_info[uno].Filepos+Tape_info[dos].size+2);
  blockwrite(f,buffer,Tape_info[uno].size+2);

  closefile(F);
  closefile(Fbak);
end;

procedure TSpecEmu.Delete_Tape_Block(row: word);
Var
  F: File;
  source_pos, dest_pos: Word;
  result: integer;
begin
  //CopyFile(OpenTapFileDialog.FileName, '$$$$$$$$.$$$');
  AssignFile (F, OpenTapFileDialog.FileName);
  Reset(F,1);
  dest_pos := Tape_Info[row].Filepos;
  Source_pos := dest_pos + Tape_Info[row].Size+2;
  while Source_pos < filesize(F) do
  begin
    seek(f,source_pos);
    blockread(f, buffer, sizeof(buffer), result);
    seek(f,dest_pos);
    blockwrite(f,buffer,result);
    inc(source_pos, result);
    inc(dest_pos, result);
  end;
  seek(f,dest_pos);
  truncate(f);
  closefile(F);
end;

function TSpecEmu.tap_checksum(flag: byte; addr,len: word): byte;
var
  v: byte;
  x: word;
begin
  v := flag;
  for x := addr to addr+len-1 do
      v := v xor mem[x];
  tap_checksum := v;
end;

function TSpecEmu.Save_Tape_block(addr, len: word; flag: byte): byte; // IX: Addr; DE: Len; A: Flag byte
Var
  F, FBak: File;
  BT,x: Byte;
  Size, pos: Word;
begin
  CopyFile(OpenTapFileDialog.FileName, '$$$$$$$$.$$$');
  AssignFile (F, OpenTapFileDialog.FileName);
  Reset(F,1);
  pos := Blockgrid.Row;
  if pos = 0 then
    seek(F, 0)
  else if pos <= Tape_Blocks then
    seek(F, Tape_Info[pos].Filepos)
  else
    seek(F, Tape_Info[pos-1].Filepos+Tape_Info[pos-1].size+2);

  if flag = 0 then // Es una cabecera
  begin
    size := 19;
  end else begin // Es un bloque de datos
    size := len+2;
  end;
  Blockwrite(F, size, sizeof(size));
  Blockwrite(F, flag, sizeof(flag));
  Blockwrite(F,mem[addr],len);
  Blockwrite(F, tap_checksum(flag,addr,len),1);
  if pos <= Tape_Blocks then
  begin
    AssignFile (FBAK, '$$$$$$$$.$$$');
    Reset(FBAK,1);
    for x := pos to Tape_Blocks do
    begin
       seek(FBAK, Tape_Info[x].Filepos);
       blockread(FBAK, buffer, Tape_info[x].Size+2);
       blockwrite(F, buffer, Tape_info[x].Size+2);
    end;
    CloseFile(FBAK);
    Truncate(F);
  end;
  CloseFile(F);
//  Tape_info_bak := Tape_info;
  read_tap_blocs;
  Blockgrid.Row := pos+1;
end;

function TSpecEmu.Load_Tape_block(addr, len: word; flag: byte): byte; // IX: Addr; DE: Len; A: Flag byte
Var
  F: File;
  BT: Byte;
  Size: Word;
begin
  AssignFile (F, OpenTapFileDialog.FileName);
  Reset(F,1);
  Seek(F,Tape_info[Blockgrid.Row].Filepos);
  Blockgrid.Row := Blockgrid.Row +1;
  BlockRead(F, size, sizeof(size));
  BlockRead(F,BT,1);
  BlockRead(F, buff, size-1);
  if BT = flag then
  begin
       move(buff,mem[addr],len);
  end;
  closefile(F);
  result := FLAG_C; // devuelve FLAG_C=0 si error
end;

procedure TSpecEmu.Hideall;
begin
  Hide_Keyboard;
  Hide_Tape;
  Hide_Debugger;
end;

procedure TSpecEmu.Hide_Keyboard;
begin
  PanelKeyboard.Visible:= false;
  KeyboardWidth := 0;
end;

procedure TSpecEmu.Show_Keyboard;
begin
  PanelKeyboard.Visible:= True;
  KeyboardWidth := PanelKeyboard.Width;
end;

procedure TSpecEmu.Hide_Tape;
begin
  TapePanel.Visible:= false;
  TapePanelWidth := 0;
end;

procedure TSpecEmu.Show_Tape;
begin
  TapePanel.Visible:= true;
  TapePanelWidth := TapePanel.Width;//Visible_TapePanel_Width;
end;

procedure TSpecEmu.Show_Debugger;
begin
  DebugPanel.Visible := true;
  debug_width := DebugPanel.Width;// Visible_debug_width;
end;

procedure TSpecEmu.Hide_Debugger;
begin
  DebugPanel.Visible := false;
  debug_width := 0;
end;



procedure TSpecEmu.set_breakpoint;
  var
    value,code: word;
    S: String;
begin
  val(EdBreak.Text,value,code);
  if code = 0 then
  begin
       breakpoint := value;
       S := HexStr(value,4);
       stBreak.Caption:= S;
       breakpoint_active := true;
  end;
end;

procedure TSpecEmu.set_mem_label;
  var
    S: String;
begin
  if      src_ptr.Checked then S := HexStr(mem_addr,4)
 else if src_ix.Checked then S := HexStr(ix,4)
 else if src_iy.Checked then S := HexStr(iy,4);
  {+'='+HexStr(mem[mem_addr],2)+HexStr(mem[mem_addr+1],2)};
  stMem.Caption:= S;
end;

procedure TSpecEmu.set_stack_label;
  var
    S: String;
    a,e: word;
begin
     S := '';
     if $ffff-sp > $56 then e := sp + $55
     else e := $ffff;
     for a := sp to e do
     begin
       S := S + HexStr(rdmem(a),2) + ' ';
     end;
     stStack.caption := S;
end;

procedure TSpecEmu.set_memory_dump;
var
  row, addr: word;
  offset,x,y,n: byte;
begin
      if      src_ptr.Checked then addr := mem_addr
     else if src_ix.Checked then addr := ix-127
     else if src_iy.Checked then addr := iy-127;
     row := addr and not $f;
     for y := 1 to $10 do
     begin
      offset := 0;
      memgrid.Cells[0,y]:=HexStr(row,4);
      for x := 1 to $10 do
      begin
       if ASCIISelection.Checked then
          memgrid.Cells[x,y]:=Chr(mem[row+offset])
       else
           memgrid.Cells[x,y]:=HexStr(mem[row+offset],2);
       inc(offset);
      end;
      inc(row,$10);
     end;
end;

procedure TSpecEmu.set_mem;
  var
    value,code: word;
    S: String;
begin
  val(EdMem.Text,value,code);
  if code = 0 then
  begin
    mem_addr := value;
    set_mem_label;
    set_memory_dump;
  end;
end;

procedure TSpecEmu.Button1Click(Sender: TObject);
begin
     set_breakpoint;
end;

procedure TSpecEmu.Button2Click(Sender: TObject);
begin
  breakpoint_active := false;
  EdBreak.Text := '';
  stBreak.Caption := '';
end;

procedure TSpecEmu.Button3Click(Sender: TObject);
begin
  set_mem;
end;

procedure TSpecEmu.adjust_window_size;
var
  MainWindowWidth: Integer;
begin
  sizex := sizex1x*scale+15;     //256+15=271
  sizey := sizey1x*scale+5;
  MainWindowWidth := 352+sizex1x*scale-sizex1x;
  if windowState = wsNormal then begin
    Height := sizey + buttons_height +10; // Height - sizey1x;
    width := MainWindowWidth + keyboardWidth + debug_width + TapePanelWidth+ SideButtons.width+7;// 55; // width - sizex1x;
  end;
  SideButtons.Height := Height-1;
  SideButtons.Left := MainWindowWidth;
  pantalla.width := sizex+17;   //271+38= 288
  pantalla.Height:= sizey+15;
  DebugPanel.Left := sizex + 60;
  TapePanel.Left := sizex + 60;
  PanelKeyboard.Left := sizex + 60;
  PanelKeyboard.Top := 2;
  BottomButtonsPanel.Top := sizey + 15;
  BottomButtonsPanel.width := pantalla.width;
end;

procedure TSpecEmu.DumpSourceSelectionChanged(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.DumpSourceSizeConstraintsChange(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.EdBreakKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
     set_breakpoint;
end;

procedure TSpecEmu.EdMemKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
     set_mem;
end;

procedure TSpecEmu.PauseButtonClick(Sender: TObject);
begin
  start_debug;
  draw_screen;
end;

procedure TSpecEmu.resetkeyb(fila, bit: byte);
begin
  Keyboard[fila] := Keyboard[fila] or (%00000001 << bit);

end;

procedure TSpecEmu.setkeyb(fila, bit: byte);
begin
  Keyboard[fila] := Keyboard[fila] and not(%000000001 << bit);
end;

procedure TSpecEmu.BFocusdKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  begin
       //if Key = VK_RETURN then
       //   enter_pulsado := true;
       if (Activecontrol = EdBreak) or (ActiveControl = EdMem) then exit;
       case key of
            VK_F8    : step := true;
            VK_LEFT  : begin setkeyb(0,0); setkeyb(3,4);end;
            VK_DOWN  : begin setkeyb(0,0); setkeyb(4,4);end;
            VK_UP    : begin setkeyb(0,0); setkeyb(4,3);end;
            VK_RIGHT : begin setkeyb(0,0); setkeyb(4,2);end;
            VK_OEM_PLUS : begin setkeyb(7,1); setkeyb(6,2);end;
            VK_OEM_MINUS : begin setkeyb(7,1); setkeyb(6,3);end;
            VK_OEM_COMMA : begin setkeyb(7,1); setkeyb(7,3);end;
            VK_OEM_PERIOD : begin setkeyb(7,1); setkeyb(7,2);end;
            VK_CAPITAL: begin setkeyb(0,0); setkeyb(3,1);end;
            VK_F1    : begin setkeyb(0,0); setkeyb(3,0);end;
            VK_BACK  : begin setkeyb(0,0); setkeyb(4,0);end;
            VK_SHIFT : setkeyb(0,0);
            VK_Z     : setkeyb(0,1);
            VK_X     : setkeyb(0,2);
            VK_C     : setkeyb(0,3);
            VK_V     : setkeyb(0,4);
            VK_A     : setkeyb(1,0);
            VK_S     : setkeyb(1,1);
            VK_D     : setkeyb(1,2);
            VK_F     : setkeyb(1,3);
            VK_G     : setkeyb(1,4);
            VK_Q     : setkeyb(2,0);
            VK_W     : setkeyb(2,1);
            VK_E     : setkeyb(2,2);
            VK_R     : setkeyb(2,3);
            VK_T     : setkeyb(2,4);
            VK_1,
            VK_NUMPAD1: setkeyb(3,0);
            VK_2,
            VK_NUMPAD2: setkeyb(3,1);
            VK_3,
            VK_NUMPAD3: setkeyb(3,2);
            VK_4,
            VK_NUMPAD4: setkeyb(3,3);
            VK_5,
            VK_NUMPAD5: setkeyb(3,4);
            VK_0,
            VK_NUMPAD0: setkeyb(4,0);
            VK_9,
            VK_NUMPAD9: setkeyb(4,1);
            VK_8,
            VK_NUMPAD8: setkeyb(4,2);
            VK_7,
            VK_NUMPAD7: setkeyb(4,3);
            VK_6,
            VK_NUMPAD6: setkeyb(4,4);
            VK_P     : setkeyb(5,0);
            VK_O     : setkeyb(5,1);
            VK_I     : setkeyb(5,2);
            VK_U     : setkeyb(5,3);
            VK_Y     : setkeyb(5,4);
            VK_RETURN: setkeyb(6,0);
            VK_L     : setkeyb(6,1);
            VK_K     : setkeyb(6,2);
            VK_J     : setkeyb(6,3);
            VK_H     : setkeyb(6,4);
            VK_SPACE : setkeyb(7,0);
            VK_MENU  : setkeyb(7,1);
            VK_M     : setkeyb(7,2);
            VK_N     : setkeyb(7,3);
            VK_B     : setkeyb(7,4);
       end;
       key := 0;

end;

procedure TSpecEmu.BFocusClick(Sender: TObject);
begin
  clear_keyboard;
  draw_screen;
end;

procedure TSpecEmu.AsciiSelectionChange(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.ApplicationProperties1Activate(Sender: TObject);
begin
  clear_keyboard;
end;

procedure TSpecEmu.BFocusdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  begin
    if (Activecontrol = EdBreak) or (ActiveControl = EdMem) then exit;
    case key of
         VK_F8    : step := true;
         VK_LEFT  : begin resetkeyb(0,0); resetkeyb(3,4);end;
         VK_DOWN  : begin resetkeyb(0,0); resetkeyb(4,4);end;
         VK_UP    : begin resetkeyb(0,0); resetkeyb(4,3);end;
         VK_RIGHT : begin resetkeyb(0,0); resetkeyb(4,2);end;
         VK_OEM_PLUS : begin resetkeyb(7,1); resetkeyb(6,2);end;
         VK_OEM_MINUS : begin resetkeyb(7,1); resetkeyb(6,3);end;

         VK_OEM_COMMA : begin resetkeyb(7,1); resetkeyb(7,3);end;
         VK_OEM_PERIOD : begin resetkeyb(7,1); resetkeyb(7,2);end;
         VK_CAPITAL: begin resetkeyb(0,0); resetkeyb(3,1);end;
         VK_F1    : begin resetkeyb(0,0); resetkeyb(3,0);end;
         VK_BACK  : begin resetkeyb(0,0); resetkeyb(4,0);end;
         VK_SHIFT : reset_CS;//resetkeyb(0,0);
         VK_Z     : resetkeyb(0,1);
         VK_X     : resetkeyb(0,2);
         VK_C     : resetkeyb(0,3);
         VK_V     : resetkeyb(0,4);
         VK_A     : resetkeyb(1,0);
         VK_S     : resetkeyb(1,1);
         VK_D     : resetkeyb(1,2);
         VK_F     : resetkeyb(1,3);
         VK_G     : resetkeyb(1,4);
         VK_Q     : resetkeyb(2,0);
         VK_W     : resetkeyb(2,1);
         VK_E     : resetkeyb(2,2);
         VK_R     : resetkeyb(2,3);
         VK_T     : resetkeyb(2,4);
         VK_1,
         VK_NUMPAD1: resetkeyb(3,0);
         VK_2,
         VK_NUMPAD2: resetkeyb(3,1);
         VK_3,
         VK_NUMPAD3: resetkeyb(3,2);
         VK_4,
         VK_NUMPAD4: resetkeyb(3,3);
         VK_5,
         VK_NUMPAD5: resetkeyb(3,4);
         VK_0,
         VK_NUMPAD0: resetkeyb(4,0);
         VK_9,
         VK_NUMPAD9: resetkeyb(4,1);
         VK_8,
         VK_NUMPAD8: resetkeyb(4,2);
         VK_7,
         VK_NUMPAD7: resetkeyb(4,3);
         VK_6,
         VK_NUMPAD6: resetkeyb(4,4);
         VK_P     : resetkeyb(5,0);
         VK_O     : resetkeyb(5,1);
         VK_I     : resetkeyb(5,2);
         VK_U     : resetkeyb(5,3);
         VK_Y     : resetkeyb(5,4);
         VK_RETURN: resetkeyb(6,0);
         VK_L     : resetkeyb(6,1);
         VK_K     : resetkeyb(6,2);
         VK_J     : resetkeyb(6,3);
         VK_H     : resetkeyb(6,4);
         VK_SPACE : resetkeyb(7,0);
         VK_MENU  : reset_SS;//resetkeyb(7,1);
         VK_M     : resetkeyb(7,2);
         VK_N     : resetkeyb(7,3);
         VK_B     : resetkeyb(7,4);
    end;
    key := 0;
end;

procedure TSpecEmu.ButtonBlockdownClick(Sender: TObject);
var
   pos: word;
begin
  if (blockgrid.Row < Tape_Blocks) then
  begin
       pos := blockgrid.row;
       move_tap_block(blockgrid.row, blockgrid.row+1);
       read_tap_blocs;
       blockblockgrid.row := pos+1;
  end;
end;

procedure TSpecEmu.ButtonBlockUpClick(Sender: TObject);
var
   pos: word;
begin
  if (blockgrid.Row > 1) then
  begin
    pos := blockgrid.row;
       move_tap_block(blockgrid.row, blockgrid.row-1);
       read_tap_blocs;
       blockblockgrid.row := pos-1;
  end;
end;

procedure TSpecEmu.ButtonEjectClick(Sender: TObject);
begin
  OpenTapFileDialog.Execute;
end;

procedure TSpecEmu.ButtonFWDClick(Sender: TObject);
begin
  Tape_Select(blockgrid.Row+1);
end;

procedure TSpecEmu.ButtonPlayClick(Sender: TObject);
begin
  if TapeImage.Visible then begin
    ButtonPlayPressed.Visible := true;
    ButtonPlay.Visible := false;
    Set_tape_leds;
  end;
end;

procedure TSpecEmu.ButtonRecClick(Sender: TObject);
begin
  if TapeImage.Visible then begin
    ButtonRecPressed.Visible := true;
    ButtonRec.Visible := false;
    Set_tape_leds;
  end;
end;

procedure TSpecEmu.ButtonDeleteBlockClick(Sender: TObject);
begin
     if (blockgrid.Row <= Tape_Blocks) and
        (Application.MessageBox('Are you sure?', 'Delete current tap block',
                                    MB_ICONQUESTION + MB_YESNO) = IDYES) then
     begin
          Delete_Tape_Block(blockgrid.Row);
          read_tap_blocs;
     end;
end;

procedure TSpecEmu.ButtonTapeFirstClick(Sender: TObject);
begin
    Tape_Select(1);
end;

procedure TSpecEmu.ButonTapeEndClick(Sender: TObject);
begin
  Tape_Select(Tape_blocks);
end;

procedure TSpecEmu.ButtonRecPressedClick(Sender: TObject);
begin
  ButtonRecPressed.Visible := false;
  ButtonRec.Visible := true;
  Set_tape_leds;
end;

procedure TSpecEmu.ButtonRewClick(Sender: TObject);
begin
  Tape_Select(blockgrid.Row-1);
end;

procedure TSpecEmu.ButtonStopClick(Sender: TObject);
begin
  ButtonPlayPressedClick(Sender);
  ButtonRecPressedClick(Sender);
  Set_tape_leds;
end;

procedure TSpecEmu.Button_aMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(1,0);
end;

procedure TSpecEmu.Button_aMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(1,0);
end;

procedure TSpecEmu.Button_BMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(7,4);
end;

procedure TSpecEmu.Button_BMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(7,4);
end;

procedure TSpecEmu.Button_ceroMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(4,0);
end;

procedure TSpecEmu.Button_ceroMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(4,0);
end;

procedure TSpecEmu.Button_cincoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(3,4);
end;

procedure TSpecEmu.Button_cincoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(3,4);
end;

procedure TSpecEmu.Button_CMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(0,3);
end;

procedure TSpecEmu.Button_CMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(0,3);
end;

procedure TSpecEmu.Button_CSClick(Sender: TObject);
begin
  if Button_SS.Visible then
  begin
    Button_CS.Visible := false;
    Button_CS_LOCK.Visible := true;
    setkeyb(0,0);
  end;
end;

procedure TSpecEmu.Button_CSMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(0,0);
end;

procedure TSpecEmu.Button_CSMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(0,0);
end;

procedure TSpecEmu.reset_CS;
begin
  Button_CS.Visible := true;
  Button_CS_LOCK.Visible := false;
  resetkeyb(0,0);
end;

procedure TSpecEmu.Button_CS_LOCKClick(Sender: TObject);
begin
     reset_CS;
end;

procedure TSpecEmu.Button_cuatroMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(3,3);
end;

procedure TSpecEmu.Button_cuatroMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(3,3);
end;

procedure TSpecEmu.Button_dMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(1,2);
end;

procedure TSpecEmu.Button_dMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(1,2);
end;

procedure TSpecEmu.Button_dosMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(3,1);
  BFocus.setfocus;
end;

procedure TSpecEmu.Button_dosMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(3,1);
end;

procedure TSpecEmu.Button_EMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(2,2);
end;

procedure TSpecEmu.Button_EMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(2,2);
end;

procedure TSpecEmu.Button_ENTERMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(6,0);
end;

procedure TSpecEmu.Button_ENTERMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(6,0);
end;

procedure TSpecEmu.Button_FMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(1,3);
end;

procedure TSpecEmu.Button_FMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(1,3);
end;

procedure TSpecEmu.Button_GMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(1,4);
end;

procedure TSpecEmu.Button_GMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(1,4);
end;

procedure TSpecEmu.Button_HMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(6,4);
end;

procedure TSpecEmu.Button_HMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(6,4);
end;

procedure TSpecEmu.Button_IMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(5,2);
end;

procedure TSpecEmu.Button_IMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(5,2);
end;

procedure TSpecEmu.Button_JMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(6,3);
end;

procedure TSpecEmu.Button_JMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(6,3);
end;

procedure TSpecEmu.Button_KMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(6,2);
end;

procedure TSpecEmu.Button_KMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(6,2);
end;

procedure TSpecEmu.Button_LMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(6,1);
end;

procedure TSpecEmu.Button_LMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(6,1);
end;

procedure TSpecEmu.Button_MMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(7,2);
end;

procedure TSpecEmu.Button_MMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(7,2);
end;

procedure TSpecEmu.Button_NMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(7,3);
end;

procedure TSpecEmu.Button_NMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(7,3);
end;

procedure TSpecEmu.Button_nueveMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(4,1);
end;

procedure TSpecEmu.Button_nueveMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(4,1);
end;

procedure TSpecEmu.Button_ochoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(4,2);
end;

procedure TSpecEmu.Button_ochoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(4,2);
end;

procedure TSpecEmu.Button_OMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(5,1);
end;

procedure TSpecEmu.Button_OMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(5,1);
end;

procedure TSpecEmu.Button_PMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(5,0);
end;

procedure TSpecEmu.Button_PMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(5,0);
end;

procedure TSpecEmu.Button_qMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(2,0);
end;

procedure TSpecEmu.Button_qMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(2,0);
end;

procedure TSpecEmu.Button_RMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(2,3);
end;

procedure TSpecEmu.Button_RMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(2,3);
end;

procedure TSpecEmu.Button_seisMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(4,4);
end;

procedure TSpecEmu.Button_seisMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(4,4);
end;

procedure TSpecEmu.Button_sieteMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(4,3);
end;

procedure TSpecEmu.Button_sieteMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(4,3);
end;

procedure TSpecEmu.Button_sMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(1,1);
end;

procedure TSpecEmu.Button_sMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(1,1);
end;

procedure TSpecEmu.Button_SPACEMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(7,0);
end;

procedure TSpecEmu.Button_SPACEMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(7,0);
end;

procedure TSpecEmu.Button_SSClick(Sender: TObject);
begin
  if Button_CS.Visible then
  begin
    Button_SS.Visible := false;
    Button_SS_LOCK.Visible := true;
    setkeyb(7,1);
  end else begin
    Button_CS_LOCK.Visible := false;
    Button_CS.Visible := true;
    resetkeyb(0,0);
  end;
end;

procedure TSpecEmu.Button_SSMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(7,1);
end;

procedure TSpecEmu.Button_SSMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(7,1);
end;

procedure TSpecEmu.reset_SS;
begin
  Button_SS.Visible := true;
  Button_SS_LOCK.Visible := false;
  resetkeyb(7,1);
end;

procedure TSpecEmu.Button_SS_LOCKClick(Sender: TObject);
begin
  reset_SS;
end;

procedure TSpecEmu.Button_TMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(2,4);
end;

procedure TSpecEmu.Button_TMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(2,4);
end;

procedure TSpecEmu.Button_tresMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(3,2);
end;

procedure TSpecEmu.Button_tresMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(3,2);
end;

procedure TSpecEmu.Button_UMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(5,3);
end;

procedure TSpecEmu.Button_UMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(5,3);
end;

procedure TSpecEmu.Button_unoClick(Sender: TObject);
begin

end;

procedure TSpecEmu.Button_unoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(3,0);
end;

procedure TSpecEmu.Button_unoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(3,0);
end;

procedure TSpecEmu.Button_VMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(0,4);
end;

procedure TSpecEmu.Button_VMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(0,4);
end;

procedure TSpecEmu.Button_wMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(2,1);
end;

procedure TSpecEmu.Button_wMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(2,1);
end;

procedure TSpecEmu.Button_XMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(0,2);
end;

procedure TSpecEmu.Button_XMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   setkeyb(0,2);
end;

procedure TSpecEmu.Button_YMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(5,4);
end;

procedure TSpecEmu.Button_YMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(5,4);
end;

procedure TSpecEmu.Button_ZClick(Sender: TObject);
begin

end;

procedure TSpecEmu.Button_ZMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  setkeyb(0,1);
end;

procedure TSpecEmu.Button_ZMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  resetkeyb(0,1);
end;

procedure TSpecEmu.KeyMouseEnter(Sender: TObject);
begin
  with TBGRAResizeSpeedButton(Sender) do
  begin
       SavedWidth := Width;
       SavedHeight := Height;
       SavedTop := Top;
       SavedLeft := Left;
       Width := SavedWidth + (SavedWidth div 2);
       Height := SavedHeight + (SavedHeight div 2);
       Left := SavedLeft - (SavedWidth div 4);
       Top := SavedTop - (SavedHeight div 4);
       BringToFront;
  end;
end;

procedure TSpecEmu.KeyMouseLeave(Sender: TObject);
begin
  with TBGRAResizeSpeedButton(Sender) do
  begin
    Left := SavedLeft;
    Top := SavedTop;
    Width := SavedWidth;
    Height := SavedHeight;
  end;
end;

procedure TSpecEmu.BlockGridAfterSelection(Sender: TObject; aCol, aRow: Integer
  );
begin
     blockgrid.cells[0,blockgrid.Row] := '>';
end;

procedure TSpecEmu.BlockGridBeforeSelection(Sender: TObject; aCol, aRow: Integer
  );
begin
  blockgrid.cells[0,blockgrid.Row] := '';
end;

procedure TSpecEmu.Set_tape_leds;
begin
  TapeRecLed.Visible := ButtonPlayPressed.Visible and ButtonRecPressed.Visible;
  TapePlayLed.Visible := ButtonPlayPressed.Visible and not ButtonRecPressed.Visible;
end;

procedure TSpecEmu.Tape_select(n: integer);
begin
  if TapeImage.Visible and (n > 0) and (n < blockgrid.RowCount) then begin
    blockgrid.cells[0,blockgrid.Row] := '';
    blockgrid.cells[0,n] := '>';
    blockgrid.Row := n;
  end;
end;

procedure TSpecEmu.ButtonPlayPressedClick(Sender: TObject);
begin
  ButtonPlayPressed.Visible := false;
  ButtonPlay.Visible := true;
  Set_tape_leds;
end;

procedure TSpecEmu.ButtonTap1Click(Sender: TObject);
begin
  if PanelKeyboard.Visible then begin
    HideAll;
  end else begin
    HideAll;
    show_keyboard;
  end;
  adjust_window_size;
end;

procedure TSpecEmu.ButtonTapClick(Sender: TObject);
begin
  if TapePanel.Visible then begin
    HideAll;
  end else begin
    HideAll;
    Show_Tape;
  end;
  adjust_window_size;
end;

procedure TSpecEmu.FormDeactivate(Sender: TObject);
begin
end;

procedure TSpecEmu.FormWindowStateChange(Sender: TObject);
var
  sx, sy: integer;
begin
     if (WindowState=wsMaximized) then begin
//        bak_scale := scale;
        sx := (width - debug_width-15) div sizex1x;
        sy := (height -5) div sizey1x;
        if sx < sy then scale := sx
        else scale := sy;
        adjust_window_size;
//        draw_screen;
     end else if (WindowState=wsNormal) then begin
         scale := bak_scale;
         adjust_window_size;
         bak_scale := scale;
     end;
end;

procedure TSpecEmu.Read_tap_blocs;
var
  F: File;
  n,size,i,Proglen,blocklen,startAddr: word;
  AutoStart: word absolute StartAddr;
  Variable: String[2];
  S: String;
  BlockType: String[6];
  DataType: String[6];
  FileName: String[10];
  BSize: String[6];
  BT: Byte;
begin
  DataType := 'BYTES';     // If not header next block is RAW
  n := 1;
  Blockgrid.Clean;
  AssignFile (F, OpenTapFileDialog.FileName);
  Reset(F,1);
  Seek(F,0);
  while FilePos(F) < FileSize(F) do
  begin
    Tape_info[n].FilePos := FilePos(F);
    BlockRead(F, size, sizeof(size));
    Str(size,BSize);
    if size > 0 then
    begin
      BlockRead(F,BT,1);
      BlockRead(F, buff, size-1);
      Tape_info[n].Flag := BT;
      Tape_info[n].Size := size;
      if BT=0 then begin               // HEADER
         BlockType := 'HEADER';
         autostart := Buff[14]*256+Buff[13];
         case buff[0] of
           0: DataType := 'BAS';
           1: DataType := 'NVAR';
           2: DataType := 'SVAR';
           3: if startAddr=$4000 then DataType := 'SCR' else DataType := 'BYTES';
         end;
         move(buff[1],FileName[1],10);
         FileName[0]:= #10;
         Blocklen := Buff[12]*256+Buff[11];
         if DataType='NVAR' then
            Variable := chr(byte('A')+buff[14])
         else if DataType='SVAR' then
              Variable := chr(byte('A')+buff[14])+'$';
         Proglen := Buff[16]*256+Buff[15];
         Blockgrid.InsertRowWithValues(n,['',FileName,BSize,BlockType]);
      end
      else begin
          BlockType := 'DATA';
          if (DataType='BAS') then
             Blockgrid.InsertRowWithValues(n,['','ST='+IntToStr(startAddr),BSize,DataType,IntToStr(ProgLen)])
          else if(DataType='BYTES') or (DataType='SCR') then
             Blockgrid.InsertRowWithValues(n,['','ST='+IntToStr(startAddr),BSize,DataType,''])
          else
             Blockgrid.InsertRowWithValues(n,['',Variable,BSize,DataType,'']);
          DataType := 'BYTES';
      end;
    end;
    inc(n);
  end;
  Tape_Blocks := n-1;
  Blockgrid.cells[0,1] := '>';
  Blockgrid.row := 1;
  CloseFile(F);
end;

procedure TSpecEmu.OpenTapFileDialogClose(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  F: THandle;
begin
  if OpenTapFileDialog.FileName <> '' then begin
     TapeFileName.Caption := ExtractFileName(OpenTapFileDialog.FileName);
     TapeImage.Visible := true;
     TapeFileName.Visible := true;

     if not FileExists(OpenTapFileDialog.FileName) then
     begin
       BoxStyle := MB_ICONQUESTION + MB_YESNO;
       Reply := Application.MessageBox('CREATE A EMPTY TAP FILE?', 'NEW TAP FILE', BoxStyle);
       if Reply = IDYES then
          F := FileCreate(OpenTapFileDialog.FileName);
          FileClose(F);
     end;

     if FileExists(OpenTapFileDialog.FileName) then
        Read_tap_blocs;
  end;
end;

procedure TSpecEmu.OpenTapFileDialogSelectionChange(Sender: TObject);
begin

end;

procedure TSpecEmu.PanelKeyboardMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin

end;

procedure TSpecEmu.PantallaPaint(Sender: TObject);
begin
  draw_screen;
end;

procedure TSpecEmu.PlayButtonClick(Sender: TObject);
begin
  stop_debug;
end;

procedure TSpecEmu.stop_debug;
begin
  empezando := true;
  pause := false;
  PauseButton.Visible := not pause;
  PlayButton.Visible := pause;
  if starting then begin
     starting := false;
     RunEmulation;
  end;
  DebugPanel.Enabled := false;
  StepButton.Enabled := false;
end;

procedure TSpecEmu.start_debug;
begin
  empezando := false;
  pause := true;
  PauseButton.Visible := not pause;
  PlayButton.Visible := pause;
  stInstruction.caption := decode_instruction(pc);
  draw_screen;
  refresh_registers;
  DebugPanel.Enabled := true;
  StepButton.Enabled := true;
  stepbutton.SetFocus;
end;

procedure TSpecEmu.BitBtn3Click(Sender: TObject);
begin

end;

procedure TSpecEmu.AcsMemoryIn1BufferDone(Sender: TComponent);
var
  k: word;
  bytes_readed: word;
begin
   if (sound_bytes >= 0) then begin
      if sound_bytes >= bufsize then
         bytes_readed := bufsize
      else
         bytes_readed := sound_bytes;

      if soundpos_read + bytes_readed >= spec_buffer_size then
      begin
         move(data[soundpos_read], buffer[nb,0], spec_buffer_size-soundpos_read);
         soundpos_read := bytes_readed-(spec_buffer_size-soundpos_read);
         move(data[0], buffer[nb,0], soundpos_read);
      end else begin
         move(data[soundpos_read], buffer[nb,0], bufsize);
         inc(soundpos_read,bufsize);
      end;
      dec(sound_bytes,bytes_readed);
      ACSMemoryIn1.DataBuffer :=@buffer[nb];
      ACSMemoryIn1.DataSize := bufsize;
   end else begin
     fillchar(buffer[nb], 1, 128);
     ACSMemoryIn1.DataBuffer :=@buffer[nb];
     ACSMemoryIn1.DataSize := 1;
   end;
end;


procedure TSpecEmu.ResetButtonClick(Sender: TObject);
var
  bits: byte;
  channels: byte;
  SampleRate:integer;
  size: integer;
  F: File of byte;
  r: integer;
begin
  init_z80;
  init_spectrum;
  pc := 0;
  if pause then begin
    draw_screen;
    refresh_registers;
  end;
end;

procedure TSpecEmu.StepButtonClick(Sender: TObject);
begin
  step := true;
end;

procedure TSpecEmu.refresh_registers;
var
  S: String;
begin
  stPC.caption := HexStr(pc,4);
  stSP.caption := HexStr(sp,4);
  stAF.caption := HexStr(af,4);
  stBC.caption := HexStr(bc,4);
  stDE.caption := HexStr(de,4);
  stHL.caption := HexStr(hl,4);
  stAF1.caption := HexStr(af1,4);
  stBC1.caption := HexStr(bc1,4);
  stDE1.caption := HexStr(de1,4);
  stHL1.caption := HexStr(hl1,4);
  stIX.caption := HexStr(ix,4);
  stIY.caption := HexStr(iy,4);
  stRR.caption := HexStr(r,2);
  stII.caption := HexStr(i,2);
  stIM.caption := 'IM'+HexStr(im,1);
  stBCc.caption := HexStr(rdmem2(bc),4);
  stDEc.caption := HexStr(rdmem2(de),4);
  stHLc.caption := HexStr(rdmem2(hl),4);
  if iff1 then stiff1.caption := 'EI'
  else stiff1.caption := 'DI';
  stIM.caption := 'IM'+HexStr(im,1);

  S := '                ';
  S[2] := iffc(s_flag<>0,'S',' ');
  S[4] := iffc(z_flag<>0,'Z',' ');
  S[6] := iffc(n5_flag<>0,'5',' ');
  S[8] := iffc(h_flag<>0,'H',' ');
  S[10] := iffc(n3_flag<>0,'3',' ');
  S[12] := iffc(pv_flag<>0,'P',' ');
  S[14] := iffc(n_flag<>0,'N',' ');
  S[16] := iffc(c_flag<>0,'C',' ');
  stFlags.caption := S;
  str(t_states,S);
  stTStates.caption := S;
  str(t_states_cur_frame,S);
  stTStatesFrame.caption := S;
  set_stack_label;
  set_memory_dump;
  set_mem_label;
end;

procedure TSpecEmu.RunEmulation;
var
   i: word = 0;
   dd: longint;

begin
  init_z80;
  init_spectrum;
  draw_screen;
  screen_timer.Start;
  repaint_screen := false;
  prev_sound_bytes := sound_bytes;
  while (not saliendo) do begin
    if not pause and (breakpoint_active) and ((breakpoint = pc) and not empezando) then begin
       start_debug;
    end;
    if not pause or step then begin
       empezando := false;
       if (pc = $556) then
          save_cpu_status;
       if (pc = $04c2) and TapeRecLed.Visible then // SAVE ROUTINE
       begin
            c_flag := Save_tape_block(IX,DE,A);
            compose_flags;
            ret;
            clear_keyboard;
       end else if (pc >= $556) and (pc < $05e3) and TapePlayLed.Visible then // LOAD ROUTINE
       begin
          restore_cpu_status;
          c_flag := Load_Tape_block(IX, DE, A); // IX: Addr; DE: Len; A: Flag byte
          compose_flags;
          ix+=de;
          ret;
          clear_keyboard;
       end else if not screen_tstates_reached then do_z80;
       if pause then
       begin
          stInstruction.caption := decode_instruction(pc);
          refresh_registers;
          draw_screen;
       end;
       step := false;
    end;
    inc(i);
    if (i >= 2048) then begin
      Application.ProcessMessages;
      i := 0;
    end;
    t_states_cur_half_scanline := t_states - t_states_ini_half_scanline;
    t_states_cur_instruction := t_states - t_states_prev_instruction;
    if speaker_out then
       inc(sonido_acumulado, t_states_cur_instruction);
    t_states_prev_instruction := t_states;
    if t_states_cur_half_scanline >= t_states_sound_bit then
    begin
      if sonido_acumulado > 0 then
         a := a;
      t_states_ini_half_scanline :=  t_states; //-(t_states_cur_half_scanline-t_states_sound_bit);
      data[soundpos_write] := 128 + (sonido_acumulado * 32) div t_states_sound_bit;
      sonido_acumulado := 0;
      inc(soundpos_write);
      if soundpos_write > spec_buffer_size-1 then soundpos_write := 0;
      inc(sound_bytes);
    end;
    t_states_cur_frame := t_states - t_states_ini_frame;
    time := screen_timer.Elapsed;
    screen_tstates_reached := (t_states_cur_frame >= screen_testados_total);
    repaint_screen := screen_tstates_reached and (sound_bytes <= 2048);//screen_timer.Elapsed >= 0.020;
    if repaint_screen and screen_tstates_reached then begin
        prev_sound_bytes := sound_bytes;
        screen_timer.clear;
        screen_timer.start;
        t_states_ini_frame := t_states-(t_states_cur_frame-screen_testados_total);
        intpend := true;
        draw_screen;
        repaint_screen := false;
        inc(frames);
        //if (frames mod 50) = 0 then begin
        //  stsamples.caption := intToStr(sound_bytes);
        //  ststatessound.caption := intToStr(t_states_sound_bit);
        //end;
    end;
  end;
end;

procedure TSpecEmu.FormActivate(Sender: TObject);
begin
  DebugPanel.Enabled := false;
  TapePanel.Visible := false;
  DebugPanel.Visible := false;
  memgrid.ColWidths[0] := 35;
  adjust_window_size;
  fillchar(buffer,sizeof(buffer),0);
  ACSAudioOut1.Run();
  ACSMemoryIn1.DataBuffer :=@buffer[nb];
  ACSMemoryIn1.DataSize := bufsize;
  sound_bytes := 2048;
  soundpos_write := sound_bytes;
end;

procedure TSpecEmu.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  saliendo := true;
  ACSAudioOut1.Stop();

end;

procedure TSpecEmu.FormCreate(Sender: TObject);
begin
     saliendo := false;
     starting := true;
     pause := false;
     step := false;
     mem_addr := 0;
     scale := 1;
     bak_scale := scale;
     sizex := sizex1x*scale+15;
     sizey := sizey1x*scale+5;
     SS_Status := 0;
end;

procedure TSpecEmu.PantallaClick(Sender: TObject);
begin
  BFocus.SetFocus;
  draw_screen;
  clear_keyboard;
end;

procedure TSpecEmu.ScreenClick(Sender: TObject);
begin

end;

procedure TSpecEmu.ButtonDebugClick(Sender: TObject);
begin
  if DebugPanel.Visible then begin
    HideAll;
  end else begin
    HideAll;
    Show_Debugger;
  end;
  adjust_window_size;
end;

procedure TSpecEmu.src_ixChange(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.src_iyChange(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.src_ptrChange(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.src_ptrSizeConstraintsChange(Sender: TObject);
begin

end;

procedure TSpecEmu.stBreakClick(Sender: TObject);
begin

end;

procedure TSpecEmu.stInstructionClick(Sender: TObject);
begin

end;

procedure TSpecEmu.stIYClick(Sender: TObject);
begin

end;

procedure TSpecEmu.stPCClick(Sender: TObject);
begin

end;

procedure TSpecEmu.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  starting := true;
  stop_debug;
end;

procedure TSpecEmu.ZoomInButtonClick(Sender: TObject);
begin
    if (scale < 10) and (WindowState = wsNormal) then begin
      inc(scale);
      adjust_window_size;
    end;
end;

procedure TSpecEmu.ZoomOutButtonClick(Sender: TObject);
begin
  if (scale > 1) and (WindowState = wsNormal) then begin
    dec(scale);
    adjust_window_size;
  end;
end;

procedure TSpecEmu.draw_screen;
  const
     lines: array[0..191] of word =
            (
        $4000, $4100, $4200, $4300, $4400, $4500, $4600, $4700,
        $4020, $4120, $4220, $4320, $4420, $4520, $4620, $4720,
        $4040, $4140, $4240, $4340, $4440, $4540, $4640, $4740,
        $4060, $4160, $4260, $4360, $4460, $4560, $4660, $4760,
        $4080, $4180, $4280, $4380, $4480, $4580, $4680, $4780,
        $40A0, $41A0, $42A0, $43A0, $44A0, $45A0, $46A0, $47A0,
        $40C0, $41C0, $42C0, $43C0, $44C0, $45C0, $46C0, $47C0,
        $40E0, $41E0, $42E0, $43E0, $44E0, $45E0, $46E0, $47E0,
        $4800, $4900, $4A00, $4B00, $4C00, $4D00, $4E00, $4F00,
        $4820, $4920, $4A20, $4B20, $4C20, $4D20, $4E20, $4F20,
        $4840, $4940, $4A40, $4B40, $4C40, $4D40, $4E40, $4F40,
        $4860, $4960, $4A60, $4B60, $4C60, $4D60, $4E60, $4F60,
        $4880, $4980, $4A80, $4B80, $4C80, $4D80, $4E80, $4F80,
        $48A0, $49A0, $4AA0, $4BA0, $4CA0, $4DA0, $4EA0, $4FA0,
        $48C0, $49C0, $4AC0, $4BC0, $4CC0, $4DC0, $4EC0, $4FC0,
        $48E0, $49E0, $4AE0, $4BE0, $4CE0, $4DE0, $4EE0, $4FE0,
        $5000, $5100, $5200, $5300, $5400, $5500, $5600, $5700,
        $5020, $5120, $5220, $5320, $5420, $5520, $5620, $5720,
        $5040, $5140, $5240, $5340, $5440, $5540, $5640, $5740,
        $5060, $5160, $5260, $5360, $5460, $5560, $5660, $5760,
        $5080, $5180, $5280, $5380, $5480, $5580, $5680, $5780,
        $50A0, $51A0, $52A0, $53A0, $54A0, $55A0, $56A0, $57A0,
        $50C0, $51C0, $52C0, $53C0, $54C0, $55C0, $56C0, $57C0,
        $50E0, $51E0, $52E0, $53E0, $54E0, $55E0, $56E0, $57E0
            );

  var
    i, x, y: Integer;
    bgra: TBGRABitmap;
    // bitmap: TBitmap;
    p: PBGRAPixel;
    v, bit, attr_offset: byte;
    pmem, pattr: word;

    function getColor(attr: byte; pixel: boolean): byte;
    var
       brigth: byte;
    begin
      if ((attr and 128) <> 0) and ((frame and 16)=0) then begin // flash........
        if pixel then begin
          getColor := (attr >> 3) and $f;
        end else begin
          getColor := (attr and $7) or (attr >> 3) and $8;
        end;
      end else begin
        if pixel then begin
          getColor := (attr and $7) or (attr >> 3) and $8;
        end else begin
          getColor := (attr >> 3) and $f;
        end;
      end;
    end;

    function getRedComponent(color: byte): byte;
    const
       red_comp: array[0..15] of byte =
         ($00,$00,$d7,$d7,$00,$00,$d7,$d7,$00,$00,$ff,$ff,$00,$00,$ff,$ff);
    begin
         getRedComponent := red_comp[color];
    end;

    function getGreenComponent(color: byte): byte;
    const
       green_comp: array[0..15] of byte =
         ($00,$00,$00,$00,$d7,$d7,$d7,$d7,$00,$00,$00,$00,$ff,$ff,$ff,$ff);
    begin
      getGreenComponent := green_comp[color];
    end;

    function getBlueComponent(color: byte): byte;
    const
       blue_comp: array[0..15] of byte =
         ($00,$d7,$00,$d7,$00,$d7,$00,$d7,$00,$ff,$00,$ff,$00,$ff,$00,$ff);
    begin
      getBlueComponent := blue_comp[color];
    end;

    procedure linea_borde(pixels: word);
    var
       x: word;
    begin
      for x := 0 to pixels-1 do
      begin
           v := border_color;
           p^.red:= getRedComponent(v);
           p^.blue:= getBlueComponent(v);
           p^.green:= getGreenComponent(v);
           Inc(p);
      end;
    end;

begin
    inc(frame);
    bgra := TBGRABitmap.Create(sizex1x, sizey1x, BGRABlack);
    p := bgra.Data;
    x := 0;
    y := 0;
    bit := 128;
    pattr := 16384+6144;
    attr_offset := 0;
    for y := 0 to alto_borde-1 do
    begin
      p := bgra.Scanline[y];
      linea_borde(ancho_borde*2+256);
    end;
    for y := 0 to 191 do
    begin
      p := bgra.Scanline[y+alto_borde];
      linea_borde(ancho_borde);
      pmem := lines[y];
      for x := 0 to 255 do
      begin
        v := getColor(mem[pattr+attr_offset], (mem[pmem] and bit) <> 0);
        p^.red:= getRedComponent(v);
        p^.blue:= getBlueComponent(v);
        p^.green:= getGreenComponent(v);
        Inc(p);
        if bit > 1 then bit := bit >> 1
        else begin
          bit := 128;
          inc(pmem);
          inc(attr_offset);
        end;
      end;
      linea_borde(ancho_borde);
      if y mod 8 = 7 then
         inc(pattr,32);
      attr_offset := 0;
    end;
    for y := 0 to alto_borde-1 do
    begin
      p := bgra.Scanline[y+192+alto_borde];
      linea_borde(ancho_borde*2+256);
    end;
    if bfocus.Focused then
       bgra.canvas.DrawFocusRect(rect(0,0,sizex1x-1,sizey1x-1));
    bgra.InvalidateBitmap;
//    bgra.Draw(pantalla.Canvas, 15, 5, False);
    pantalla.canvas.StretchDraw(rect(15,15,sizex1x*scale+15-1,sizey1x*scale+15-1),bgra.Bitmap);
    bgra.Free;
end;
end.

