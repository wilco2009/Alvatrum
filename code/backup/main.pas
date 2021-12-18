unit main;

{$mode objfpc}{$H+}
//{$MACRO ON}
//{$OPTIMIZATION LEVEL3}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, z80, Z80ops, BGRABitmap, BGRABitmapTypes, z80Globals,
  Z80Tools, LCLType, Grids, ComCtrls, Menus, Spin, acs_audio, acs_file,
  acs_misc, acs_mixer, BCListBox, CRT, BGRAGraphicControl, BGRASpriteAnimation,
  BGRAResizeSpeedButton, BGRAImageList, BCPanel, BGRAVirtualScreen,
  BGRAColorTheme, BCImageButton, BCButtonFocus, BCButton, BGRAShape,
  BCTrackbarUpdown, spectrum, SdpoJoystick, global, hardware, fileformats,
  Types, cassette, bgtools, ColorPalette, strutils, bas2tap, bin2tap,
  BGRAFilters,BGRATextFX, BGRAGradients;
type

  { TSpecEmu }

  TSpecEmu = class(TForm)
    BFocus: TBCButtonFocus;
    ButtonAddBrkLine: TBGRAResizeSpeedButton;
    ButtonAudio: TBGRAResizeSpeedButton;
    ButtonDelBrkLine: TBGRAResizeSpeedButton;
    ButtonDebug: TBGRAResizeSpeedButton;
    ButtonKeyboard: TBGRAResizeSpeedButton;
    CheckGroup1: TCheckGroup;
    ckAYSound: TCheckBox;
    ckIssue2: TCheckBox;
    ckaspect: TCheckBox;
    ckWriteEnabled: TCheckBox;
    AudioOut: TAcsAudioOut;
    ACSEar: TAcsMemoryIn;
    ApplicationProperties1: TApplicationProperties;
    AsciiSelection: TCheckBox;
    brueda: TBGRAGraphicControl;
    brueda1: TBGRAGraphicControl;
    bdriveAled: TBGRAGraphicControl;
    bDriveBLed: TBGRAGraphicControl;
    Button10: TButton;
    Button8: TButton;
    Button9: TButton;
    ButtonBlockdown1: TBGRAResizeSpeedButton;
    ButtonBlockUp1: TBGRAResizeSpeedButton;
    ButtonPrevMachine: TBGRAResizeSpeedButton;
    ButtonNextMachine2: TBGRAResizeSpeedButton;
    cktape_trap: TCheckBox;
    BkScrColor: TColorPalette;
    dispComp: TBGRAGraphicControl;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    ButtonConf: TBGRAResizeSpeedButton;
    ButtonFloppy: TBGRAResizeSpeedButton;
    ButtonFloppy2: TBGRAResizeSpeedButton;
    ButtonMedia: TBGRAResizeSpeedButton;
    ButtonCursorFire: TToggleBox;
    ButtonDeleteBlock: TBGRAResizeSpeedButton;
    ButtonDown: TToggleBox;
    ButtonEject: TBGRAResizeSpeedButton;
    ButtonFire: TToggleBox;
    ButtonFWD: TBGRAResizeSpeedButton;
    ButtonLeft: TToggleBox;
    ButtonPlay: TBGRAResizeSpeedButton;
    ButtonPlayPressed: TBGRAResizeSpeedButton;
    ButtonRec: TBGRAResizeSpeedButton;
    ButtonRecPressed: TBGRAResizeSpeedButton;
    ButtonRew: TBGRAResizeSpeedButton;
    ButtonRight: TToggleBox;
    ButtonSnapLoad: TBGRAResizeSpeedButton;
    Button_show_floppy: TBGRAResizeSpeedButton;
    Button_show_computone: TBGRAResizeSpeedButton;
    ButtonSnapSave: TBGRAResizeSpeedButton;
    ButtonStop: TBGRAResizeSpeedButton;
    ButtonTapeFirst: TBGRAResizeSpeedButton;
    ButonTapeEnd: TBGRAResizeSpeedButton;
    ButtonBlockdown: TBGRAResizeSpeedButton;
    ButtonBlockUp: TBGRAResizeSpeedButton;
    ButtonUp: TToggleBox;
    ButtonUp1: TToggleBox;
    Button_a: TBGRAResizeSpeedButton;
    Button_CS_LOCK: TBGRAResizeSpeedButton;
    Button_F: TBGRAResizeSpeedButton;
    Button_G: TBGRAResizeSpeedButton;
    Button_H: TBGRAResizeSpeedButton;
    Button_J: TBGRAResizeSpeedButton;
    Button_K: TBGRAResizeSpeedButton;
    Button_L: TBGRAResizeSpeedButton;
    Button_flush_drives: TBGRAResizeSpeedButton;
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
    Button_dos: TBGRAResizeSpeedButton;
    Button_E: TBGRAResizeSpeedButton;
    Button_U: TBGRAResizeSpeedButton;
    Button_X: TBGRAResizeSpeedButton;
    Button_C: TBGRAResizeSpeedButton;
    Button_V: TBGRAResizeSpeedButton;
    Button_B: TBGRAResizeSpeedButton;
    Button_N: TBGRAResizeSpeedButton;
    Button_M: TBGRAResizeSpeedButton;
    ckDiskA_prot: TCheckBox;
    ckDiskB_prot: TCheckBox;
    ckDiskB_active: TCheckBox;
    DebugPanel: TPanel;
    driveA: TImage;
    driveAfloppy: TImage;
    driveALed: TImage;
    DriveAPanel: TPanel;
    driveB: TImage;
    driveBFloppy: TImage;
    driveBLed: TImage;
    DriveBPanel: TPanel;
    DumpSource: TRadioGroup;
    EdBreak: TEdit;
    edAsm_addr: TEdit;
    EdMem: TEdit;
    FlagsPanel: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupJoystickProtocol: TRadioGroup;
    GroupRightJoystick: TRadioGroup;
    grUserJoy: TGroupBox;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    labelI: TLabel;
    lstAsm_window: TListBox;
    memgrid: TStringGrid;
    odROM: TOpenDialog;
    DiskFileDialog: TOpenDialog;
    OpenSnaFileDialog: TOpenDialog;
    Panel1: TPanel;
    GroupLeftJoystick: TRadioGroup;
    panelFloppy: TPanel;
    Panel3: TPanel;
    panelComputone: TPanel;
    AudioPanel: TPanel;
    pDebug1: TPanel;
    pDebug2: TPanel;
    pDebug3: TPanel;
    pDebug4: TPanel;
    ResetButton: TBGRAResizeSpeedButton;
    PlayButton: TBGRAResizeSpeedButton;
    PauseButton: TBGRAResizeSpeedButton;
    StepButton: TBGRAResizeSpeedButton;
    sgBreakpoints: TStringGrid;
    StaticText14: TStaticText;
    StaticText16: TStaticText;
    StaticText19: TStaticText;
    StepOverButton: TBGRAResizeSpeedButton;
    FullScreenButton: TBGRAResizeSpeedButton;
    ZoomOutButton: TBGRAResizeSpeedButton;
    TAPMenu: TPopupMenu;
    SaveSnaFileDialog: TSaveDialog;
    OptionsPanel: TPanel;
    //screen_timer: TEpikTimer;
    TecladoSpectrum: TImage;
    BlockGrid: TStringGrid;
    OpenTapFileDialog: TOpenDialog;
    PanelKeyboard: TPanel;
    Joystick1: TSdpoJoystick;
    Joystick2: TSdpoJoystick;
    SideButtons: TPanel;
    src_ix: TRadioButton;
    src_iy: TRadioButton;
    src_ptr: TRadioButton;
    stAF: TStaticText;
    stAF1: TStaticText;
    StaticText1: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText13: TStaticText;
    StaticText15: TStaticText;
    StaticText17: TStaticText;
    StaticText18: TStaticText;
    stDriveACreator: TStaticText;
    stDriveASides: TStaticText;
    stDriveASidest: TStaticText;
    stDriveATracks: TStaticText;
    stDriveATrackst: TStaticText;
    stDriveAVersion: TStaticText;
    stDriveBCreator: TStaticText;
    stDriveBSides: TStaticText;
    stDriveBSidest: TStaticText;
    stDriveBTracks: TStaticText;
    stDriveBTrackst: TStaticText;
    stDriveBVersion: TStaticText;
    stFileDriveAInfo: TStaticText;
    stFileDriveBInfo: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    stdiskMotor: TStaticText;
    stFileDriveA: TStaticText;
    stFileDriveB: TStaticText;
    stportoutFE: TStaticText;
    stportinFE: TStaticText;
    stportoutfffd: TStaticText;
    stportout7ffd: TStaticText;
    stportout1ffd: TStaticText;
    stportoutbffd: TStaticText;
    stportinfffd: TStaticText;
    stPrinterStrobe: TStaticText;
    stSamples: TStaticText;
    stScreenPage: TStaticText;
    stBC: TStaticText;
    stBC1: TStaticText;
    stBCc: TStaticText;
    stBreak: TStaticText;
    stDE: TStaticText;
    stDE1: TStaticText;
    stDEc: TStaticText;
    stFlags: TStaticText;
    stHL: TStaticText;
    stHL1: TStaticText;
    stHLc: TStaticText;
    stIff1: TStaticText;
    stII: TStaticText;
    stIM: TStaticText;
    stInstruction: TStaticText;
    stIX: TStaticText;
    stIY: TStaticText;
    stMem: TStaticText;
    stPC: TStaticText;
    MemPages: TStringGrid;
    stROM0: TStaticText;
    StatusJoystick1: TShape;
    StatusJoystick2: TShape;
    stROM1: TStaticText;
    stROM2: TStaticText;
    stROM3: TStaticText;
    stRR: TStaticText;
    stPaggingDisabled: TStaticText;
    stSP: TStaticText;
    stStack: TStaticText;
    stTstates: TStaticText;
    stTstatesFrame: TStaticText;
    TapeFileName: TStaticText;
    TapeImage: TImage;
    TapePanel: TPanel;
    JoyTimer: TTimer;
    TapePlayLed: TShape;
    TapeRecLed: TShape;
    TimerBottomBar: TTimer;
    TimerBottomBar1: TTimer;
    TimerSideBar: TTimer;
    TimerRueda: TTimer;
    TimerSideBar1: TTimer;
    TrackBar_AY: TTrackBar;
    TrackBar_Speaker: TTrackBar;
    TrackBar_Ear: TTrackBar;
    TrackBar_Mic: TTrackBar;
    Pantalla: TBGRAGraphicControl;
    BottomButtonsPanel: TPanel;
    Timer1: TTimer;
    ZoomInButton: TBGRAResizeSpeedButton;
    procedure ACSEarBufferDone(Sender: TComponent);
    procedure ApplicationProperties1Activate(Sender: TObject);
    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure AsciiSelectionChange(Sender: TObject);
    procedure BFocus1Click(Sender: TObject);
    procedure BFocus2Click(Sender: TObject);
    procedure BFocusClick(Sender: TObject);
    procedure BFocusdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BFocusdKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BkScrColorClick(Sender: TObject);
    procedure BkScrColorColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure BlockGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Button10Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button9Enter(Sender: TObject);
    procedure ButtonAddBrkLineClick(Sender: TObject);
    procedure ButtonAudioClick(Sender: TObject);
    procedure ButtonBlockdown1Click(Sender: TObject);
    procedure ButtonBlockUp1Click(Sender: TObject);
    procedure ButtonDebugClick(Sender: TObject);
    procedure ButtonDelBrkLineClick(Sender: TObject);
    procedure ButtonKeyboardClick(Sender: TObject);
    procedure ButtonPrevMachineClick(Sender: TObject);
    procedure ButtonNextMachine2Click(Sender: TObject);
    procedure ckaspectChange(Sender: TObject);
    procedure ckIssue2Change(Sender: TObject);
    procedure cktape_trapChange(Sender: TObject);
    procedure ckWriteEnabledChange(Sender: TObject);
    procedure DebugPanelClick(Sender: TObject);
    procedure dispCompPaint(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ButtonBlockdownClick(Sender: TObject);
    procedure ButtonBlockUpClick(Sender: TObject);
    procedure ButtonConf1Click(Sender: TObject);
    procedure ButtonConfClick(Sender: TObject);
    procedure ButtonDownChange(Sender: TObject);
    procedure ButtonDownClick(Sender: TObject);
    procedure ButtonEjectClick(Sender: TObject);
    procedure ButtonEjectMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonEjectMouseLeave(Sender: TObject);
    procedure ButtonFireChange(Sender: TObject);
    procedure ButtonFireClick(Sender: TObject);
    procedure ButtonFloppy2Click(Sender: TObject);
    procedure ButtonFloppyClick(Sender: TObject);
    procedure ButtonFWDClick(Sender: TObject);
    procedure ButtonLeftChange(Sender: TObject);
    procedure ButtonLeftClick(Sender: TObject);
    procedure ButtonLeftExit(Sender: TObject);
    procedure ButtonMediaClick(Sender: TObject);
    procedure ButtonPlayClick(Sender: TObject);
    procedure ButtonPlayPressedClick(Sender: TObject);
    procedure ButtonRecClick(Sender: TObject);
    procedure ButtonDeleteBlockClick(Sender: TObject);
    procedure ButtonRightChange(Sender: TObject);
    procedure ButtonRightClick(Sender: TObject);
    procedure ButtonRightExit(Sender: TObject);
    procedure Button_flush_drivesClick(Sender: TObject);
    procedure Button_show_floppyClick(Sender: TObject);
    procedure Button_show_computoneClick(Sender: TObject);
    procedure ButtonSnapSaveClick(Sender: TObject);
    procedure ButtonSnapLoadClick(Sender: TObject);
    procedure ButtonTapeFirstClick(Sender: TObject);
    procedure ButonTapeEndClick(Sender: TObject);
    procedure ButtonRecPressedClick(Sender: TObject);
    procedure ButtonRewClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonUpChange(Sender: TObject);
    procedure ButtonUpClick(Sender: TObject);
    procedure ButtonUpExit(Sender: TObject);
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
    procedure ckAYSoundChange(Sender: TObject);
    procedure ckDiskA_protChange(Sender: TObject);
    procedure ckDiskB_activeChange(Sender: TObject);
    procedure ckDiskB_protChange(Sender: TObject);
    procedure driveADragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure driveADragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure driveAMouseEnter(Sender: TObject);
    procedure driveBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure driveBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure driveBMouseEnter(Sender: TObject);
    procedure driveBMouseLeave(Sender: TObject);
    procedure edAsm_addrChange(Sender: TObject);
    procedure edAsm_addrKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormChangeBounds(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FullScreenButtonClick(Sender: TObject);
    procedure GroupJoystickProtocolClick(Sender: TObject);
    procedure GroupLeftJoystickClick(Sender: TObject);
    //procedure GroupMachineClick(Sender: TObject);
    procedure GroupRightJoystickClick(Sender: TObject);
    procedure grUserJoyClick(Sender: TObject);
    procedure KeyMouseEnter(Sender: TObject);
    procedure KeyMouseLeave(Sender: TObject);
    procedure BlockGridAfterSelection(Sender: TObject; aCol, aRow: Integer);
    procedure BlockGridBeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure ButtonTap1Click(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label20Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure memgridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure memgridEditingDone(Sender: TObject);
    procedure PanelKeyboardMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PantallaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PantallaPaint(Sender: TObject);
    procedure PauseButton2Click(Sender: TObject);
    procedure PauseButtonClick(Sender: TObject);
    procedure PlayButton2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure rbplus2aChange(Sender: TObject);
    procedure rbPlus2gChange(Sender: TObject);
    procedure rbplus3Change(Sender: TObject);
    procedure RbRightJoy1Change(Sender: TObject);
    procedure RbRightJoy2Change(Sender: TObject);
    procedure RbRightJoyCursorChange(Sender: TObject);
    procedure RbRightJoyNoneChange(Sender: TObject);
    procedure rbspec128Change(Sender: TObject);
    procedure rbspec48Change(Sender: TObject);
    procedure ResetButtonClick(Sender: TObject);
    procedure sgBreakpointsButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure sgBreakpointsEditingDone(Sender: TObject);
    procedure sgBreakpointsHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure stBCcClick(Sender: TObject);
    procedure stDEcClick(Sender: TObject);
    procedure StepButtonClick(Sender: TObject);
    procedure StepOverButtonClick(Sender: TObject);
    procedure stHLcClick(Sender: TObject);
    procedure stRegisterClick(Sender: TObject);
    procedure StepOverButton2Click(Sender: TObject);
    procedure stFileDriveBClick(Sender: TObject);
    procedure stROM0Click(Sender: TObject);
    procedure StatusJoystick2ChangeBounds(Sender: TObject);
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
    procedure ButtonDebug1Click(Sender: TObject);
    procedure src_ixChange(Sender: TObject);
    procedure src_iyChange(Sender: TObject);
    procedure src_ptrChange(Sender: TObject);
    procedure src_ptrSizeConstraintsChange(Sender: TObject);
    procedure stBreakClick(Sender: TObject);
    procedure stInstructionClick(Sender: TObject);
    procedure stIYClick(Sender: TObject);
    procedure stPCClick(Sender: TObject);
    procedure stROM1Click(Sender: TObject);
    procedure stROM2Click(Sender: TObject);
    procedure stROM3Click(Sender: TObject);
    procedure stStackClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure JoyTimerTimer(Sender: TObject);
    procedure TimerBottomBar1Timer(Sender: TObject);
    procedure TimerBottomBarTimer(Sender: TObject);
    procedure TimerRuedaTimer(Sender: TObject);
    procedure TimerSideBar1Timer(Sender: TObject);
    procedure TimerSideBarTimer(Sender: TObject);
    procedure TrackBar_AYChange(Sender: TObject);
    procedure TrackBar_EarChange(Sender: TObject);
    procedure TrackBar_SpeakerChange(Sender: TObject);
    procedure ZoomInButton2Click(Sender: TObject);
    procedure ZoomInButtonClick(Sender: TObject);
    procedure ZoomOutButton2Click(Sender: TObject);
    procedure selectjoystick(joyactive: boolean; var joysticksel: word; newsel: word);
    procedure tap_edit_controls_enabled(Enab: boolean);
    procedure ZoomOutButtonClick(Sender: TObject);

  private
    timer_floppyA, timer_floppyB: byte;
    saliendo, starting, pause, timed_pause, debugging, step, breakpoint_active: boolean;
    AYActive: boolean;
    SS_Status: Byte;
    breakpoint, mem_addr: word;
    empezando : boolean;
    Tape_blocks: word;
    SavedWidth: integer;
    SavedHeight: integer;
    SavedTop: integer;
    SavedLeft: integer;
    LeftJoystickSelection: word;
    RightJoystickSelection: word;
    diskA_filename: string;
    diskB_filename: string;
    grComputer: array [Tmachine] of TBGRABitmap;
    grrueda: array [0..3] of TBGRABitmap;
    grled: TBGRABitmap;
    grledApagado: TBGRABitmap;
    cont_rueda: byte;
    MenuItem: TMenuItem;
    cur_asm_addr: word;
    DriveSelected : byte;
    mem_col: integer;
    mem_row: integer;
    OriginalBounds: TRect;
    OriginalWindowState: TWindowState;
    ScreenBounds: TRect;

    procedure SwitchFullScreen;
    procedure draw_screen;
    procedure RunEmulation;
    procedure fill_asm_window(addr: word);
    procedure refresh_system;
    procedure refresh_register_labels;
    procedure UpdateRegistersFromLabels;
    procedure pause_emulation;
    procedure timed_pause_emulation;
    procedure restart_emulation;
    procedure start_debug;
    procedure stop_debug;
    procedure set_breakpoint;
    procedure set_mem_label;
    procedure set_mem;
    procedure set_stack_label;
    procedure set_memory_dump;
    procedure ClearSpectrumScreen(scr_color: integer);
    procedure RefreshScreen;
    procedure maximize_window;
    procedure adjust_window_size;
    procedure Hide_Tape;
    procedure Show_Tape;
    procedure Show_Debugger;
    procedure Hide_Debugger;
    procedure Show_Keyboard;
    procedure Hide_Keyboard;
    procedure Show_Options;
    procedure Hide_Options;
    procedure Hideall;
    procedure Hide_AudioPanel;
    procedure Show_AudioPanel;

    procedure move_tap_block(uno, dos: word);
    procedure Delete_Tape_Block(row: word);
    procedure Read_tap_blocs;
    procedure Read_tzx_blocs;
    procedure Tape_select(n: integer);
    procedure Set_tape_leds;

    function tap_checksum(flag: byte; addr,len: word): byte;
    function Load_Tape_block(addr, len: word; flag: byte): byte;
    function Save_Tape_block(addr, len: word; flag: byte): byte;
    procedure resetkeyb(fila, bit: byte);
    procedure reset_SS;
    procedure reset_CS;
    procedure setkeyb(fila, bit: byte);
    function FisicalJoyUsed: boolean;
    function KempstonUsed: boolean;
    function SinclairLeftUsed: boolean;
    function SinclairRightUsed: boolean;
    function UserJoyUsed: boolean;
    procedure UpdateJoystickPanels;
    procedure UserJoyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UserJoyKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UserJoyKeyPress(Sender: TObject; var Key: char);
    procedure UpdateOptions;
    procedure OpenJoysticks;
    procedure UpdateFromOptions;
    procedure DefaultOptions;
    procedure ReadOptions(filename: string);
    procedure ReadROM;
    procedure ReadROMPage(Machine: Tmachine; ROMPage, Membank: byte);
    procedure read_dsk_file(drive: byte);
    procedure write_dsk_file(drive: byte);
    procedure flush_drive(drive: byte);
    procedure Change_to_floppy;
    procedure Change_to_tape;
    procedure UpdateROMs;
    procedure Make_selection_menu(tap_block_num: word);
    procedure EventMenuClick(Sender: TObject);
    procedure compile_breakpoints;
    procedure load_tap_file(FileName: String);
    procedure Eject_Drive_A;
    procedure Eject_Drive_B;
    procedure Insert_Drive_A(FileName: String);
    procedure Insert_Drive_B(FileName: String);
    procedure ShowMessage(msg: String);
    procedure SetFocusToScreen;
    procedure SwitchAspectRatio;
  public

  end;

const
   sizex1x = 256+ancho_borde*2;
   sizey1x = 192+alto_borde*2;
   Visible_debug_width = 632;
   Visible_TapePanel_Width = 495;
   buttons_height = 44;
   SideButtons_width = 27;
   SideButtons_height = 22;
   BottomButtons_width = 32;
   BottomButtons_height = 28;


var
  sizex, sizey: word;
  scale_X,scale_Y,bak_scale_X,bak_scale_Y, OriginalSX, OriginalSY: Real;
  SpecEmu: TSpecEmu;
  jj: word = 0;
  frame_counter: word = 0;
  debug_width : integer = 0;
  TapePanelWidth: integer = 0;
  KeyboardWidth: integer = 0;
  OptionsWidth: integer = 0;
  AudioWidth: integer = 0;
  buff: Array[0..$ffff] of byte;
  tmp_delay: longint = 5000;
  status_saved: boolean;
  diskA_inserted: boolean = false;
  diskB_inserted: boolean = false;
  step_over_true, step_over_false: word;
  step_over_break: boolean = false;
  use_tapetraps: boolean = false;
  tap_file_selected: boolean = false;
  block: word;
  stX, stY: word;
  signal_refresh: boolean = false;

implementation

{$R *.lfm}

{ TSpecEmu }

procedure TSpecEmu.ShowMessage(msg: String);
begin
  pause_emulation;
  Dialogs.showmessage(msg);
end;

procedure TSpecEmu.move_tap_block(uno,dos: word);
Var
  F, FBak: File;
  tmp: Word;
begin
  if dos < uno then
  begin
    tmp := dos;
    dos := uno;
    uno := tmp;
  end;
  try
    CopyFile(OpenTapFileDialog.FileName, '$$$$$$$$.$$$');
    AssignFile (F, OpenTapFileDialog.FileName);
    Reset(F,1);
  except
     showmessage('Error opening tap file '+OpenTapFileDialog.FileName);
     exit;
  end;
  try
    AssignFile (FBak, '$$$$$$$$.$$$');
    Reset(FBak,1);
  except
     showmessage('Error opening temporary file');
     exit;
  end;
  try
    // copy block from fbak(dos) to f(uno)
    seek(Fbak, Tape_info[dos].Filepos);
    blockread(fbak,buff,Tape_info[dos].size+2);
    seek(F, Tape_info[uno].Filepos);
    blockwrite(f,buff,Tape_info[dos].size+2);

    // copy block from fbak(uno) to f(uno)+size(uno)+2
    seek(Fbak, Tape_info[uno].Filepos);
    blockread(fbak,buff,Tape_info[uno].size+2);
    seek(F, Tape_info[uno].Filepos+Tape_info[dos].size+2);
    blockwrite(f,buff,Tape_info[uno].size+2);

    closefile(F);
    closefile(Fbak);
  except
    showmessage('error moving tap block');
  end;
end;

procedure TSpecEmu.Delete_Tape_Block(row: word);
Var
  F: File;
  source_pos, dest_pos: Word;
  result: integer;
begin
  try
    //CopyFile(OpenTapFileDialog.FileName, '$$$$$$$$.$$$');
    AssignFile (F, OpenTapFileDialog.FileName);
    Reset(F,1);
    dest_pos := Tape_Info[row].Filepos;
    Source_pos := dest_pos + Tape_Info[row].Size+2;
    while Source_pos < filesize(F) do
    begin
      seek(f,source_pos);
      blockread(f, buff, sizeof(buff), result);
      seek(f,dest_pos);
      blockwrite(f,buff,result);
      inc(source_pos, result);
      inc(dest_pos, result);
    end;
    seek(f,dest_pos);
    truncate(f);
    closefile(F);
  except
    showmessage('Error deleting tap block');
  end;
end;

function TSpecEmu.tap_checksum(flag: byte; addr,len: word): byte;
var
  v: byte;
  x: word;
begin
  v := flag;
  for x := addr to addr+len-1 do
      v := v xor rdmem(x);
  tap_checksum := v;
end;

function TSpecEmu.Save_Tape_block(addr, len: word; flag: byte): byte; // IX: Addr; DE: Len; A: Flag byte
Var
  F, FBak: File;
  Size, pos,x: Word;
begin
  try
    CopyFile(OpenTapFileDialog.FileName, '$$$$$$$$.$$$');
    AssignFile (F, OpenTapFileDialog.FileName);
    Reset(F,1);
    pos := Blockgrid.Row;
    if pos = 1 then
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
  //  Blockwrite(F,mem[addr],len);
    //Blockwrite(F,memP[mem_page(addr),mem_offset(addr)],len);
    for x := addr to addr+len-1 do
        Blockwrite(F,rdmem(x),1);
    Blockwrite(F, tap_checksum(flag,addr,len),1);
    if pos <= Tape_Blocks then
    begin
      AssignFile (FBAK, '$$$$$$$$.$$$');
      Reset(FBAK,1);
      for x := pos to Tape_Blocks do
      begin
         seek(FBAK, Tape_Info[x].Filepos);
         blockread(FBAK, buff, Tape_info[x].Size+2);
         blockwrite(F, buff, Tape_info[x].Size+2);
      end;
      CloseFile(FBAK);
      Truncate(F);
    end;
    CloseFile(F);
  //  Tape_info_bak := Tape_info;
    read_tap_blocs;
    Blockgrid.Row := pos+1;
  except
    ShowMessage('Error saving tap block.');
  end;
end;

function TSpecEmu.Load_Tape_block(addr, len: word; flag: byte): byte; // IX: Addr; DE: Len; A: Flag byte
Var
  F: File;
  BT: Byte;
  Size,k: Word;
begin
  try
    if Blockgrid.Row <= Tape_blocks then
    begin
      AssignFile (F, OpenTapFileDialog.FileName);
      Reset(F,1);
      Seek(F,Tape_info[Blockgrid.Row].Filepos);
      Blockgrid.Row := Blockgrid.Row +1;
      BlockRead(F, size, sizeof(size));
      BlockRead(F,BT,1);
      BlockRead(F, buff, size-1);
      if (BT = flag) or ((BT <>0) and (flag <>0)) then
      begin
           for k := 0 to len-1 do
               wrmem(addr+k,buff[k]);
           //move(buff,memp[mem_page(addr),mem_offset(addr)],len);
      end;
      closefile(F);
      Load_Tape_block := FLAG_C; // devuelve FLAG_C=0 si error
    end else Load_Tape_block := 0;
    SetFocusToScreen;
  except
    Showmessage('Error loading tap block.');
    Load_Tape_block := 0; // devuelve FLAG_C=0 si error
  end;
end;

procedure TSpecEmu.Hideall;
begin
  Hide_Keyboard;
  Hide_Tape;
  Hide_Debugger;
  Hide_Options;
  Hide_AudioPanel;
end;

procedure TSpecEmu.Show_Options;
begin
  OptionsPanel.Visible := True;
  OptionsWidth := OptionsPanel.Width;
end;

procedure TSpecEmu.Hide_Options;
begin
  OptionsPanel.Visible := false;
  OptionsWidth := 0;
end;

procedure TSpecEmu.Show_AudioPanel;
begin
  AudioPanel.Visible := True;
  AudioWidth := AudioPanel.Width;
end;

procedure TSpecEmu.Hide_AudioPanel;
begin
  AudioPanel.Visible := false;
  AudioWidth := 0;
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
  grledapagado.Draw(bDriveALed.Canvas,0,0,True);
  grledapagado.Draw(bDriveBLed.Canvas,0,0,True);
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
  row, addr,org, corner: word;
  offset,x,y: byte;
begin
  if      src_ptr.Checked then begin org := mem_addr; addr := mem_addr; end
  else if src_ix.Checked then begin addr := ix-127; org := ix; end
  else if src_iy.Checked then begin addr := iy-127; org := iy; end;
  row := addr and not $f;
  for y := 1 to $10 do
  begin
    offset := 0;
    memgrid.Cells[0,y]:=HexStr(row,4);
    for x := 1 to $10 do
    begin
      if ASCIISelection.Checked then
        //memgrid.Cells[x,y]:=Chr(mem[row+offset])
        memgrid.Cells[x,y]:=Chr(memp[mem_page(row+offset),mem_offset(row+offset)])
      else
        //memgrid.Cells[x,y]:=HexStr(mem[row+offset],2);
        memgrid.Cells[x,y]:=HexStr(memp[mem_page(row+offset),mem_offset(row+offset)],2);
      inc(offset);
    end;
    inc(row,$10);
  end;
  //if memgrid.visible and memgrid.enabled then
  //   memgrid.SetFocus;
  corner := addr and $fff0;
  mem_col := ((org-corner) and $0f)+1;
  mem_row := (((org-corner) and $fff0) >> 4)+1;
end;

procedure TSpecEmu.set_mem;
  var
    value,code: word;
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
  sx, sy: integer;

  procedure resize_side_buttons;
  var
    w,h: integer;

    function distribute(i, num, s, max: integer): integer;
    begin
      distribute := i*(max div (num+1))-s div 2;
    end;

  begin
    w := SideButtons_width*sx;
    h := SideButtons_height*sy;
    SideButtons.Width := w+3;
    ButtonDebug.Width := w;
    ButtonDebug.Top := distribute(1, 5, h, height);
    ButtonDebug.Height := h;
    ButtonMedia.Width := w;
    ButtonMedia.Height := h;
    ButtonMedia.Top := distribute(2, 5, h, height);
    ButtonKeyboard.Width := w;
    ButtonKeyboard.Height := h;
    ButtonKeyboard.Top := distribute(3, 5, h, height);
    ButtonConf.Width := w;
    ButtonConf.Height := h;
    ButtonConf.Top := distribute(4, 5, h, height);
    ButtonAudio.Width := w;
    ButtonAudio.Height := h;
    ButtonAudio.Top := distribute(5, 5, h, height);
    w := BottomButtons_width*sx;
    h := BottomButtons_height*sy;
    BottomButtonsPanel.Left := 0;
    BottomButtonsPanel.width := SideButtons.Left-5;
    BottomButtonsPanel.Height := h;
    PlayButton.Width := w;
    PlayButton.Height := h;
    PlayButton.Left := distribute(1, 7, w, BottomButtonsPanel.width);
    PauseButton.Width := w;
    PauseButton.Height := h;
    PauseButton.Left := distribute(1, 7, w, BottomButtonsPanel.width);
    ResetButton.Width := w;
    ResetButton.Height := h;
    ResetButton.Left := distribute(2, 7, w, BottomButtonsPanel.width);
    StepButton.Width := w;
    StepButton.Height := h;
    StepButton.Left := distribute(3, 7, w, BottomButtonsPanel.width);
    StepOverButton.Width := w;
    StepOverButton.Height := h;
    StepOverButton.Left := distribute(4, 7, w, BottomButtonsPanel.width);
    ZoomOutButton.Width := w;
    ZoomOutButton.Height := h;
    ZoomOutButton.Left := distribute(5, 7, w, BottomButtonsPanel.width);
    ZoomInButton.Width := w;
    ZoomInButton.Height := h;
    ZoomInButton.Left := distribute(6, 7, w, BottomButtonsPanel.width);
    FullScreenButton.Width := w;
    FullScreenButton.Height := h;
    FullScreenButton.Left := distribute(7, 7, w, BottomButtonsPanel.width);
  end;

begin
  sizex := round(sizex1x*scale_X+stX);     //256+15=271
  sizey := round(sizey1x*scale_Y+stY);

  if Scale_X > 2 then sx := 2
  else sx := round(Scale_X);
  if Scale_Y > 2 then sy := 2
  else sy := round(Scale_Y);

  MainWindowWidth := round(352+sizex1x*scale_X-sizex1x);
  if BorderStyle = bsNone then
  begin
    Height := Screen.Height;
    Width := Screen.Width;
    pantalla.Height:=Height;
    pantalla.Width:=Width;
  end else begin
    if windowState = wsNormal then begin
      Height := sizey + BottomButtons_height*sy+2 +10; // Height - sizey1x;
      width := MainWindowWidth + AudioWidth+OptionsWidth+keyboardWidth + debug_width + TapePanelWidth+ SideButtons_width*sx+7;// 55; // width - sizex1x;
      pantalla.Height:=Height+stX*2;
      pantalla.Width:=Height+stY*2;
    end;
    pantalla.width := sizex+stX;
    pantalla.Height:= sizey+stY;
  end;
  SideButtons.Height := Height-1;
  SideButtons.Left := MainWindowWidth;
  if (width > screen.width) or ((windowState = wsMaximized) and not options.AspectRatio) then
  begin
    OptionsPanel.Left := SideButtons.Left - OptionsWidth;
    DebugPanel.Left := SideButtons.Left - debug_width;
    TapePanel.Left := SideButtons.Left - TapePanelWidth;
    AudioPanel.Left := SideButtons.Left - AudioWidth;
    PanelKeyboard.Left := SideButtons.Left - keyboardWidth;
  end else begin
    OptionsPanel.Left := SideButtons.Left + SideButtons_width*sx+3;
    DebugPanel.Left := SideButtons.Left + SideButtons_width*sx+3;
    TapePanel.Left := SideButtons.Left + SideButtons_width*sx+3;
    AudioPanel.Left := SideButtons.Left + SideButtons_width*sx+3;
    PanelKeyboard.Left := SideButtons.Left + SideButtons_width*sx+3;
  end;
  AudioPanel.Top := 2;
  PanelKeyboard.Top := 2;
  BottomButtonsPanel.Top := sizey + 8;
  resize_side_buttons;
  //BottomButtonsPanel.width := SideButtons.Left-2;
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

procedure TSpecEmu.PlayButton2Click(Sender: TObject);
begin

end;

function TSpecEmu.FisicalJoyUsed: boolean;
begin
  FisicalJoyUsed := (GroupLeftJoystick.ItemIndex = 1) or (GroupRightJoystick.ItemIndex = 1);
end;

function TSpecEmu.KempstonUsed: boolean;
begin
  KempstonUsed := GroupJoystickProtocol.ItemIndex = ord(joyp_kempston);
end;

function TSpecEmu.SinclairLeftUsed: boolean;
begin
  SinclairLeftUsed := (GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair)) and
                   (GroupLeftJoystick.ItemIndex = 1);
end;

function TSpecEmu.SinclairRightUsed: boolean;
begin
  SinclairRightUsed := (GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair)) and
  (GroupRightJoystick.ItemIndex = 1);
end;

function TSpecEmu.UserJoyUsed: boolean;
begin
  UserJoyUsed := (GroupJoystickProtocol.ItemIndex = ord(joyp_user)) and
  (GroupLeftJoystick.ItemIndex = 1);
end;

procedure TSpecEmu.resetkeyb(fila, bit: byte);
begin
  Keyboard[fila] := Keyboard[fila] or (%00000001 << bit);

end;

procedure TSpecEmu.setkeyb(fila, bit: byte);
begin
  Keyboard[fila] := Keyboard[fila] and not(%000000001 << bit);
end;

procedure TSpecEmu.ClearSpectrumScreen(scr_color: integer);
begin
  pantalla.color := bkScrColor.Colors[scr_color];
  pantalla.ColorOpacity:=255;
  pantalla.canvas.Brush.Color:=pantalla.color;
  pantalla.Canvas.FillRect(0,0,pantalla.width,pantalla.height);
end;

procedure TSpecEmu.RefreshScreen;
var
  sx, sy: real;
  w, h: word;
  c: TColor;
begin
  if BorderStyle = bsNone then begin
    // To full screen
    sidebuttons.visible := false;

    BorderStyle := bsNone;
    BoundsRect := Screen.MonitorFromWindow(Handle).BoundsRect;
    stX := 0;
    stY := 0;
    w := Screen.Width;
    h := Screen.height;
    pantalla.width := w;
    pantalla.Height := h;
    clearSpectrumScreen(options.ScrColor);
    sx := w / sizex1x;
    sy := h / sizey1x;
    if ckAspect.checked then
    begin
      if sx < sy then sy := sx
      else sx := sy;
      stX := round((Screen.Width-sizex1x*sx) / 2);
    end;
    scale_X := sx;
    scale_Y := sy;
    HideAll;
    adjust_window_size;
    //pantalla.canvas.Brush.Color:=clWhite;
    //pantalla.Canvas.FillRect(0,0,pantalla.Width,pantalla.height);
  end else begin
    // From full screen
    pantalla.color := bkScrColor.Colors[options.ScrColor];
    pantalla.ColorOpacity:=128;
    stX := 15;
    stY := 10;
    sidebuttons.visible := true;
    //bottomButtonsPanel.visible := true;
    BorderStyle := bsSizeable;
    if WindowState = wsMaximized then
      maximize_window;
    adjust_window_size;
  end;
end;

procedure TSpecEmu.SwitchFullScreen;
var
  sx, sy: real;
  w, h: word;
begin
  if BorderStyle <> bsNone then begin
    // To full screen
    sidebuttons.visible := false;
    //bottomButtonsPanel.visible := false;
    OriginalWindowState := WindowState;
    OriginalBounds := BoundsRect;
    OriginalSX := Scale_X;
    OriginalSY := Scale_Y;

    BorderStyle := bsNone;
    BoundsRect := Screen.MonitorFromWindow(Handle).BoundsRect;
    stX := 0;
    stY := 0;
    w := Screen.Width;
    h := Screen.height;
    pantalla.width := w;
    pantalla.Height := h;
    //pantalla.color := clBlack;
    //pantalla.ColorOpacity:=255;
    //pantalla.canvas.Brush.Color:=clBlack;
    //pantalla.Canvas.FillRect(0,0,w,h);
    clearSpectrumScreen(options.ScrColor);
    sx := w / sizex1x;
    sy := h / sizey1x;
    if ckAspect.checked then
    begin
      if sx < sy then sy := sx
      else sx := sy;
      stX := round((Screen.Width-sizex1x*sx) / 2);
    end;
    scale_X := sx;
    scale_Y := sy;
    HideAll;
    BottomButtonsPanel.Visible := false;
    SideButtons.Visible := false;
    adjust_window_size;
  end else begin
    // From full screen
    pantalla.color := clWhite;
    pantalla.ColorOpacity:=128;
    stX := 15;
    stY := 10;
    sidebuttons.visible := true;
    //bottomButtonsPanel.visible := true;
    BorderStyle := bsSizeable;
    if OriginalWindowState = wsMaximized then
    begin
      WindowState := wsMaximized;
      maximize_window;
      //sx := (width - debug_width-stX-sideButtons.width) / sizex1x;
      //sy := (height -stY - bottomButtonsPanel.Height) / sizey1x;
      //if ckAspect.checked then
      //begin
      //  if sx < sy then sy := sx
      //  else sx := sy;
      //end;
      //scale_X := sx;
      //scale_Y := sy;
    end
    else begin
      BoundsRect := OriginalBounds;
      Scale_X := OriginalSX;
      Scale_Y := OriginalSY;
    end;
    BottomButtonsPanel.Visible := true;
    SideButtons.Visible := true;
    adjust_window_size;
  end;
end;

procedure TSpecEmu.BFocusdKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  begin
       //if Key = VK_RETURN then
       //   enter_pulsado := true;
       if not BFocus.Focused then exit;
       case key of
            //VK_F8    : step := true;
            //VK_F11   : SwitchFullScreen;
            VK_LEFT  : if not FisicalJoyUsed then
                       begin
                         setkeyb(0,0);
                         setkeyb(3,4);
                       end else if KempstonUsed then setKempston(1)
                       else if SinclairLeftUsed then setSinclairLeft(0)
                       else if SinclairRightUsed then setSinclairRight(4)
                       else if UserJoyUsed then
                         setkeyb(user_buttons[user_left,0],user_buttons[user_left,1]);
            VK_DOWN  : if not FisicalJoyUsed then
                       begin
                         setkeyb(0,0); setkeyb(4,4);
                       end else if KempstonUsed then setKempston(2)
                       else if SinclairLeftUsed then setSinclairLeft(2)
                       else if SinclairRightUsed then setSinclairRight(2)
                       else if UserJoyUsed then
                         setkeyb(user_buttons[user_down,0],user_buttons[user_down,1]);

            VK_UP    : if not FisicalJoyUsed then
                       begin
                         setkeyb(0,0); setkeyb(4,3);
                       end else if KempstonUsed then setKempston(3)
                       else if SinclairLeftUsed then setSinclairLeft(3)
                       else if SinclairRightUsed then setSinclairRight(1)
                       else if UserJoyUsed then
                         setkeyb(user_buttons[user_up,0],user_buttons[user_up,1]);
            VK_RIGHT : if not FisicalJoyUsed then
                       begin
                         setkeyb(0,0); setkeyb(4,2);
                       end else if KempstonUsed then setKempston(0)
                       else if SinclairLeftUsed then setSinclairLeft(1)
                       else if SinclairRightUsed then setSinclairRight(3)
                       else if UserJoyUsed then
                         setkeyb(user_buttons[user_right,0],user_buttons[user_right,1]);
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
            VK_CONTROL:
                if KempstonUsed then setKempston(4)
                else if SinclairLeftUsed then setSinclairLeft(4)
                else if SinclairRightUsed then setSinclairRight(0)
                else if UserJoyUsed then
                  setkeyb(user_buttons[user_fire,0],user_buttons[user_fire,1]);
            VK_MENU  : setkeyb(7,1);
            VK_M     : setkeyb(7,2);
            VK_N     : setkeyb(7,3);
            VK_B     : setkeyb(7,4);
       end;
       key := 0;

end;

procedure TSpecEmu.AsciiSelectionChange(Sender: TObject);
begin
  set_memory_dump;
end;

procedure TSpecEmu.BFocus1Click(Sender: TObject);
begin

end;

procedure TSpecEmu.BFocus2Click(Sender: TObject);
begin

end;

procedure TSpecEmu.BFocusClick(Sender: TObject);
begin
  refresh_system;
end;

procedure TSpecEmu.ApplicationProperties1Activate(Sender: TObject);
begin
  clear_keyboard;
end;

procedure TSpecEmu.ApplicationProperties1Idle(Sender: TObject; var Done: Boolean
  );
begin
 a := a;
end;

procedure TSpecEmu.BFocusdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  begin
    if (Activecontrol = EdBreak) or (ActiveControl = EdMem) then exit;
    case key of
         VK_F8    : step := true;
         VK_LEFT  : if not FisicalJoyUsed then
                    begin
                      resetkeyb(0,0);
                      resetkeyb(3,4);
                    end else if KempstonUsed then resetKempston(1)
                    else if SinclairLeftUsed then resetSinclairLeft(0)
                    else if SinclairRightUsed then resetSinclairRight(4)
                    else if UserJoyUsed then
                      resetkeyb(user_buttons[user_left,0],user_buttons[user_left,1]);
         VK_DOWN  : if not FisicalJoyUsed then
                    begin
                      resetkeyb(0,0);
                      resetkeyb(4,4);
                    end else if KempstonUsed then resetKempston(2)
                    else if SinclairLeftUsed then resetSinclairLeft(2)
                    else if SinclairRightUsed then resetSinclairRight(2)
                    else if UserJoyUsed then
                      resetkeyb(user_buttons[user_down,0],user_buttons[user_down,1]);
         VK_UP    : if not FisicalJoyUsed then
                    begin
                      resetkeyb(0,0);
                      resetkeyb(4,3);
                    end else if KempstonUsed then resetKempston(3)
                    else if SinclairLeftUsed then resetSinclairLeft(3)
                    else if SinclairRightUsed then resetSinclairRight(1)
                    else if UserJoyUsed then
                      resetkeyb(user_buttons[user_up,0],user_buttons[user_up,1]);
         VK_RIGHT : if not FisicalJoyUsed then
                    begin
                      resetkeyb(0,0);
                      resetkeyb(4,2);
                    end else if KempstonUsed then resetKempston(0)
                    else if SinclairLeftUsed then resetSinclairLeft(1)
                    else if SinclairRightUsed then resetSinclairRight(3)
                    else if UserJoyUsed then
                      resetkeyb(user_buttons[user_right,0],user_buttons[user_right,1]);
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
         VK_CONTROL:
                if KempstonUsed then resetKempston(4)
                else if SinclairLeftUsed then resetSinclairLeft(4)
                else if SinclairRightUsed then resetSinclairRight(0)
                else if UserJoyUsed then
                  resetkeyb(user_buttons[user_fire,0],user_buttons[user_fire,1]);
         VK_MENU  : reset_SS;//resetkeyb(7,1);
         VK_M     : resetkeyb(7,2);
         VK_N     : resetkeyb(7,3);
         VK_B     : resetkeyb(7,4);
    end;
    key := 0;
end;

procedure TSpecEmu.BkScrColorClick(Sender: TObject);
begin

end;

procedure TSpecEmu.BkScrColorColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
  options.ScrColor:=BkScrColor.PickedIndex;
  RefreshScreen;
end;

procedure TSpecEmu.BlockGridDragDrop(Sender, Source: TObject; X, Y: Integer);
begin

end;

procedure TSpecEmu.Button10Click(Sender: TObject);
begin
  pDebug1.Visible:= false;
  pDebug2.Visible:= false;
  pDebug3.Visible:= false;
  pDebug4.Visible:= true;
end;

procedure TSpecEmu.Button8Click(Sender: TObject);
begin
  pDebug1.Visible:= false;
  pDebug2.Visible:= false;
  pDebug3.Visible:= true;
  pDebug4.Visible:= false;
end;

procedure TSpecEmu.Button9Click(Sender: TObject);
var
  code: integer;
begin
  val(edAsm_addr.text,cur_asm_addr,code);
  fill_asm_window(cur_asm_addr);
end;

procedure TSpecEmu.Button9Enter(Sender: TObject);
var
  code: integer;
begin
  val(edAsm_addr.text,cur_asm_addr,code);
  fill_asm_window(cur_asm_addr);
end;

procedure TSpecEmu.ButtonAddBrkLineClick(Sender: TObject);
begin
  if (sgBreakpoints.Row > 0) and (sgBreakpoints.RowCount > 1) then
     sgBreakpoints.DeleteRow(sgBreakpoints.Row);
end;

procedure TSpecEmu.ButtonAudioClick(Sender: TObject);
begin
  if AudioPanel.Visible then begin
    HideAll;
  end else begin
    HideAll;
    show_AudioPanel;
  end;
  adjust_window_size;
end;

procedure TSpecEmu.ButtonBlockdown1Click(Sender: TObject);
var
  s: string;
begin
  s := decode_instruction(cur_asm_addr);
  cur_asm_addr += get_instruction_len(s);
  fill_asm_window(cur_asm_addr);
  lstAsm_window.ItemIndex:=254;
end;

procedure TSpecEmu.ButtonBlockUp1Click(Sender: TObject);
var
  s: string;
begin
  s := decode_instruction(cur_asm_addr-4);
  if (copy(s,8,7) = 'invalid') or (get_instruction_len(s) <> 4) then
  begin
    s := decode_instruction(cur_asm_addr-3);
    if (copy(s,8,7) = 'invalid') or (get_instruction_len(s) <> 3)then
    begin
      s := decode_instruction(cur_asm_addr-2);
      if (copy(s,8,7) = 'invalid') or (get_instruction_len(s) <> 2) then
      begin
        s := decode_instruction(cur_asm_addr-1);
        cur_asm_addr -=1;
      end else cur_asm_addr -=2;
    end else cur_asm_addr -=3;
  end else cur_asm_addr -=4;
  fill_asm_window(cur_asm_addr);
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

procedure TSpecEmu.ButtonDelBrkLineClick(Sender: TObject);
begin
  sgBreakpoints.InsertColRow(false,sgBreakpoints.RowCount);
  //Rows.Add('');
  //InsertColRow(false,sg);
end;

procedure TSpecEmu.ButtonKeyboardClick(Sender: TObject);
begin
  if PanelKeyboard.Visible then begin
    HideAll;
  end else begin
    HideAll;
    show_keyboard;
  end;
  adjust_window_size;
end;


procedure TSpecEmu.updateROMs;
begin
  stROM0.Caption:= ExtractFileName(options.ROMFilename[ord(options.machine),0]);
  stROM1.Caption:= ExtractFileName(options.ROMFilename[ord(options.machine),1]);
  stROM2.Caption:= ExtractFileName(options.ROMFilename[ord(options.machine),2]);
  stROM3.Caption:= ExtractFileName(options.ROMFilename[ord(options.machine),3]);
  coldbootrequired := true;
end;

procedure TSpecEmu.ButtonPrevMachineClick(Sender: TObject);
begin
  if options.machine > Spectrum48 then
     dec(options.machine);
  dispComp.Repaint;
  updateROMs;
  ResetButtonClick(Sender);
end;

procedure TSpecEmu.ButtonNextMachine2Click(Sender: TObject);
begin
  if options.machine < Spectrum_plus3 then
     inc(options.machine);
  dispComp.Repaint;
  updateROMs;
  ResetButtonClick(Sender);
end;

procedure TSpecEmu.ckaspectChange(Sender: TObject);
begin
  Options.AspectRatio := ckAspect.Checked;
  RefreshScreen;
end;

procedure TSpecEmu.ckIssue2Change(Sender: TObject);
begin
  Options.Issue2 := ckIssue2.Checked;
  clear_keyboard;
end;

procedure TSpecEmu.cktape_trapChange(Sender: TObject);
begin
  use_tapetraps := cktape_trap.checked and tap_file_selected;
end;

procedure TSpecEmu.ckWriteEnabledChange(Sender: TObject);
begin
  if ckWriteEnabled.Checked then
     memgrid.Options := memgrid.Options+[goEditing]
  else
     memgrid.Options := memgrid.Options-[goEditing];
end;

procedure TSpecEmu.DebugPanelClick(Sender: TObject);
begin

end;

procedure TSpecEmu.dispCompPaint(Sender: TObject);
begin
  //grcomputer[options.machine].Draw(dispComp.Canvas,0,0,True);
  dispComp.Canvas.StretchDraw(rect(0,0,dispComp.width,dispComp.height),grcomputer[options.machine].Bitmap);
  //pantalla.canvas.StretchDraw(rect(stX,stY,round(sizex1x*scale_X+stX-1),round(sizey1x*scale_Y+stY-1)),bgra.Bitmap);
end;

procedure TSpecEmu.Button4Click(Sender: TObject);
var
   FF: File;
begin
  pause_emulation;
  UpdateOptions;
  Try
    AssignFile(FF,'OPTIONS.CFG');
    Rewrite(FF,1);
    Blockwrite(FF,options,sizeof(options));
    CloseFile(FF);
    ShowMessage('Options saved');
  except
    ShowMessage('Error saving options');
  end;
end;

procedure TSpecEmu.Button5Click(Sender: TObject);
begin
  DefaultOptions;
end;

procedure TSpecEmu.Button6Click(Sender: TObject);
begin
  pDebug1.Visible:= true;
  pDebug2.Visible:= false;
  pDebug3.Visible:= false;
  pDebug4.Visible:= false;
end;

procedure TSpecEmu.Button7Click(Sender: TObject);
begin
  pDebug1.Visible:= false;
  pDebug2.Visible:= true;
  pDebug3.Visible:= false;
  pDebug4.Visible:= false;
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
    blockgrid.row := pos+1;
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
    blockgrid.row := pos-1;
  end;
end;

procedure TSpecEmu.ButtonConf1Click(Sender: TObject);
var
   FileName: String;
begin
  fileName := 'PRUEBA';
  bin_to_tap(FileName+'.BIN',FileName+'.TAP',FileName,$8000);
end;


procedure TSpecEmu.ButtonConfClick(Sender: TObject);
begin
  if OptionsPanel.Visible then begin
    HideAll;
  end else begin
    HideAll;
    show_Options;
  end;
  adjust_window_size;
end;

procedure TSpecEmu.ButtonDownChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.ButtonDownClick(Sender: TObject);
begin
  ButtonUp.Checked := false;
  ButtonDown.Checked := false;
  ButtonLeft.Checked := false;
  ButtonRight.Checked := false;
  ButtonFire.Checked := false;
end;

procedure TSpecEmu.tap_edit_controls_enabled(Enab: boolean);
begin
  ButtonBlockdown.Enabled := Enab;
  ButtonBlockup.Enabled := Enab;
  ButtonDeleteblock.Enabled := Enab;
end;

procedure TSpecEmu.ZoomOutButtonClick(Sender: TObject);
begin
  pause_emulation;
  if (BorderStyle <> bsNone) and (scale_X > 1) and (WindowState = wsNormal) then begin
    scale_X := scale_X - 1;
    scale_Y := scale_Y - 1;
    adjust_window_size;
  end;
end;

procedure TSpecEmu.load_tap_file(FileName: String);
var
  Reply, BoxStyle: Integer;
  FF: THandle;
  ext: string;
begin
  OpenTapFileDialog.FileName := FileName;
  brueda.visible := true;
  brueda1.visible := true;
  //grrueda[cont_rueda].Draw(brueda.Canvas,0,0,True);
  //grrueda[cont_rueda].Draw(brueda1.Canvas,0,0,True);
  brueda.Canvas.StretchDraw(rect(0,0,brueda.width,brueda.height),grrueda[cont_rueda].Bitmap);
  brueda1.Canvas.StretchDraw(rect(0,0,brueda1.width,brueda1.height),grrueda[cont_rueda].Bitmap);
  TapeFileName.Caption := ExtractFileName(OpenTapFileDialog.FileName);

  TapeImage.Visible := true;
  TapeFileName.Visible := true;

  if not FileExists(OpenTapFileDialog.FileName) then
  begin
    pause_emulation;
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    Reply := Application.MessageBox('CREATE A EMPTY TAP FILE?', 'NEW TAP FILE', BoxStyle);
    if Reply = IDYES then
    begin
      FF := FileCreate(OpenTapFileDialog.FileName);
      FileClose(FF);
    end;
  end;

  if FileExists(OpenTapFileDialog.FileName) then
  begin
  ext := Upcase(extractFileExt(OpenTapFileDialog.filename));
  tap_file_selected := (ext = '.TAP');
  if tap_file_selected then
  begin
    tap_edit_controls_enabled(true);
    Read_tap_blocs
  end else if ext = '.TZX' then
    Read_tzx_blocs;
  end;
  use_tapetraps := cktape_trap.checked and tap_file_selected;
end;

procedure TSpecEmu.ButtonEjectClick(Sender: TObject);
begin
  pause_emulation;
  ear_value := 0;
  tap_edit_controls_enabled(false);
  tap_file_selected := false;
  use_tapetraps := false;
  if OpenTapFileDialog.FileName <> '' then
  begin
    brueda.visible := false;
    brueda1.visible := false;
    TapeFileName.Caption := ExtractFileName(OpenTapFileDialog.FileName);
    OpenTapFileDialog.FileName := '';
    TapeImage.Visible := false;
    TapeFileName.Visible := false;
    Blockgrid.Clean;
  end else
  if OpenTapFileDialog.Execute then
    load_tap_file(OpenTapFileDialog.FileName);
  use_tapetraps := cktape_trap.checked and tap_file_selected;
  //restart_emulation;
end;

procedure TSpecEmu.ButtonEjectMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TSpecEmu.ButtonEjectMouseLeave(Sender: TObject);
begin
end;

procedure TSpecEmu.ButtonFireChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.ButtonFireClick(Sender: TObject);
begin
  ButtonUp.Checked := false;
  ButtonDown.Checked := false;
  ButtonLeft.Checked := false;
  ButtonRight.Checked := false;
  ButtonFire.Checked := false;
end;

procedure TSpecEmu.ButtonFloppy2Click(Sender: TObject);
begin
  pause_emulation;
  if diskB_filename = '' then
  begin
    if diskFileDialog.Execute then
    begin
      if fileexists(diskFileDialog.filename) then
      begin
        Insert_Drive_B(diskFileDialog.filename);
      end else begin      // Aquí iria nuevo disco
        flush_drive(1);
        diskFileDialog.Filename := diskB_filename;
        disk_modified[1] := false;
        Drive_not_ready[1] := 1;
        driveBfloppy.visible := false;
        driveB.visible := true;
        stFileDriveB.caption := 'EMPTY';
        stDriveBVersion.caption := getdskversionstring(1);
        stDriveBCreator.caption := getdskcreator(1);
        stDriveBTracks.Caption := InttoStr(disk_info[1].Tracks);
        stDriveBSides.Caption := InttoStr(disk_info[1].Sides);
      end;
    end;
  end else begin
    Eject_drive_B;
  end;
  //restart_emulation;
end;

procedure TSpecemu.read_dsk_file(drive: byte);
var
  FF: file;
  tt,ss,hh: integer;
  S: string;
begin
  S := diskFileDialog.FileName;
  Assignfile(FF,S);
  Reset(FF,1);
  bsize_dsk[drive] := filesize(FF);
  blockread(FF,buffer_dsk[drive],bsize_dsk[drive]);
  closefile(ff);
  getdiskinfo(drive);
  for tt := 0 to disk_info[drive].tracks-1 do
    for hh := 0 to disk_info[drive].sides-1 do
    begin
      if disk_info[drive].track_size[tt] > 0 then
      begin
        getTrackblock(drive,hh,tt,track_block);
        for ss := 1 to track_block.sectors do
        begin
          getFisicalSectorBlock(drive,hh,tt,ss,sector_block);
          if buffer_dsk[0][0] <> ord('E') then
             a := a;
          getSectorData(drive,hh,tt,sector_block.sector_ID,sector_data);
          if buffer_dsk[0][0] <> ord('E') then
             a := a;
        end;
      end;
    end;
end;

procedure TSpecemu.write_dsk_file(drive: byte);
var
  FF: file;
  tt,ss,hh: integer;
begin
  Assignfile(FF,diskFileDialog.FileName);
  Reset(FF,1);
  bsize_dsk[drive] := filesize(FF);
  blockwrite(FF,buffer_dsk[drive],bsize_dsk[drive]);
  closefile(ff);
end;

procedure TSpecEmu.Eject_Drive_A;
begin
  diskA_filename := '';
  Drive_not_ready[0] := 1;
  driveAfloppy.visible := false;
  driveA.visible := true;
  stFileDriveA.caption := 'EMPTY';
  stDriveAVersion.caption := '---';
  stDriveACreator.caption := '---';
  stDriveATracks.Caption := '---';
  stDriveASides.Caption := '---';
end;

procedure TSpecEmu.Eject_Drive_B;
begin
  diskB_filename := '';
  Drive_not_ready[1] := 1;
  driveBfloppy.visible := false;
  driveB.visible := true;
  stFileDriveB.caption := 'EMPTY';
  stDriveBVersion.caption := '---';
  stDriveBCreator.caption := '---';
  stDriveBTracks.Caption := '---';
  stDriveBSides.Caption := '---';
end;

procedure TSpecEmu.Insert_Drive_A(FileName: String);
begin
  flush_drive(0);
  diskFileDialog.Filename := filename;
  disk_modified[0] := false;
  diskA_filename := diskFileDialog.filename;
  read_dsk_file(0);
  Drive_not_ready[0] := 0;
  driveAfloppy.visible := true;
  driveA.visible := false;
  stFileDriveA.caption := extractfilename(diskFileDialog.filename);
  stDriveAVersion.caption := getdskversionstring(0);
  stDriveACreator.caption := getdskcreator(0);
  stDriveATracks.Caption := InttoStr(disk_info[0].Tracks);
  stDriveASides.Caption := InttoStr(disk_info[0].Sides);
end;

procedure TSpecEmu.Insert_Drive_B(FileName: String);
begin
  flush_drive(1);
  diskFileDialog.Filename := filename;
  disk_modified[1] := false;
  diskB_filename := diskFileDialog.filename;
  read_dsk_file(1);
  Drive_not_ready[1] := 0;
  driveBfloppy.visible := true;
  driveB.visible := false;
  stFileDriveB.caption := extractfilename(diskFileDialog.filename);
  stDriveBVersion.caption := getdskversionstring(1);
  stDriveBCreator.caption := getdskcreator(1);
  stDriveBTracks.Caption := InttoStr(disk_info[1].Tracks);
  stDriveBSides.Caption := InttoStr(disk_info[1].Sides);
end;

procedure TSpecEmu.ButtonFloppyClick(Sender: TObject);
begin
  pause_emulation;
  if diskA_filename = '' then
  begin
    if diskFileDialog.Execute then
    begin
      if fileexists(diskFileDialog.filename) then
      begin
        Insert_Drive_A(diskFileDialog.filename);
      end else begin // Aquí iria nuevo disco
        flush_drive(0);
        diskFileDialog.Filename := diskA_filename;
        disk_modified[0] := false;
        Drive_not_ready[0] := 1;
        driveAfloppy.visible := false;
        driveA.visible := true;
        stFileDriveA.caption := 'EMPTY';
        stDriveAVersion.caption := getdskversionstring(0);
        stDriveACreator.caption := getdskcreator(0);
        stDriveATracks.Caption := InttoStr(disk_info[0].Tracks);
        stDriveASides.Caption := InttoStr(disk_info[0].Sides);
      end;
    end;
  end else Eject_Drive_A;
  //restart_emulation;
end;

procedure TSpecEmu.ButtonFWDClick(Sender: TObject);
begin
  Tape_Select(blockgrid.Row+1);
end;

procedure TSpecEmu.ButtonLeftChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.ButtonLeftClick(Sender: TObject);
begin
end;

procedure TSpecEmu.ButtonLeftExit(Sender: TObject);
begin
  ButtonDown.Checked := false;
  ButtonUp.Checked := false;
  ButtonLeft.Checked := false;
  ButtonRight.Checked := false;
  ButtonFire.Checked := false;
end;

procedure TSpecEmu.ButtonMediaClick(Sender: TObject);
begin
  if TapePanel.Visible then begin
    HideAll;
  end else begin
    HideAll;
    Show_Tape;
  end;
  adjust_window_size;
end;

procedure TSpecEmu.ButtonPlayClick(Sender: TObject);
begin
  if TapeImage.Visible then begin
    //grrueda[cont_rueda].Draw(brueda.Canvas,0,0,True);
    //grrueda[cont_rueda].Draw(brueda1.Canvas,0,0,True);
    brueda.Canvas.StretchDraw(rect(0,0,brueda.width,brueda.height),grrueda[cont_rueda].Bitmap);
    brueda1.Canvas.StretchDraw(rect(0,0,brueda1.width,brueda1.height),grrueda[cont_rueda].Bitmap);
    ButtonPlayPressed.Visible := true;
    ButtonPlay.Visible := false;
    Set_tape_leds;
    if not use_tapetraps then
      playtap(OpenTapFileDialog.FileName,Tape_info[blockgrid.Row].Filepos,blockgrid.row);
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
  pause_emulation;
  if (blockgrid.Row <= Tape_Blocks) and
    (Application.MessageBox('Are you sure?', 'Delete current tap block',
                                MB_ICONQUESTION + MB_YESNO) = IDYES) then
  begin
    Delete_Tape_Block(blockgrid.Row);
    read_tap_blocs;
  end;
end;

procedure TSpecEmu.ButtonRightChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.ButtonRightClick(Sender: TObject);
begin
end;

procedure TSpecEmu.ButtonRightExit(Sender: TObject);
begin
  ButtonDown.Checked := false;
  ButtonUp.Checked := false;
  ButtonLeft.Checked := false;
  ButtonRight.Checked := false;
  ButtonFire.Checked := false;
end;

procedure TSpecEmu.flush_drive(drive: byte);
var
  reply: boolean;
  S: String;
begin
   if disk_modified[drive] then
   begin
     pause_emulation;
     S := 'drive '+ chr(ord('A')+drive) + ' modified';
     reply := Application.MessageBox('Update DSK file?', PChar(S),
                              MB_ICONQUESTION + MB_YESNO) = IDYES;
     if reply then
     begin
       write_dsk_file(drive);
       disk_modified[1] := false;
     end;
   end;
end;

procedure TSpecEmu.Button_flush_drivesClick(Sender: TObject);
var
  kk: byte;
begin
  for kk := 0 to 1 do
    flush_drive(kk);
end;

procedure TSpecEmu.Change_to_floppy;
begin
  panelFloppy.Visible:=true;
  blockGrid.Visible := false;
  panelComputone.Visible:=false;
end;
procedure TSpecEmu.Change_to_tape;
begin
  panelFloppy.Visible:=false;
  blockGrid.Visible := true;
  panelComputone.Visible:=true;
end;

procedure TSpecEmu.Button_show_floppyClick(Sender: TObject);
begin
  change_to_floppy;
end;

procedure TSpecEmu.Button_show_computoneClick(Sender: TObject);
begin
  change_to_tape;
end;


procedure TSpecEmu.ButtonSnapLoadClick(Sender: TObject);
begin
  pause_emulation;
  if OpenSnaFileDialog.Execute then
  begin
    loadSnapshotfile(OpenSnaFileDialog.FileName);
    refresh_system;
  end;
  //restart_emulation;
  SetFocusToScreen;
end;

procedure TSpecEmu.ButtonSnapSaveClick(Sender: TObject);
var
   reply: boolean;
begin
  pause_emulation;
  if SaveSnaFileDialog.Execute then
  begin
    reply := true;
    if fileexists(SaveSnaFileDialog.FileName) then
      reply := Application.MessageBox('Are you sure?', 'overwrite existing file',
                               MB_ICONQUESTION + MB_YESNO) = IDYES;
    if reply = true then
      SaveSnapshotfile(SaveSnaFileDialog.FileName);
  end;
  SetFocusToScreen;
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
  if tapeImage.Visible then
  begin
    ButtonRecPressed.Visible := false;
    ButtonRec.Visible := true;
    Set_tape_leds;
  end;
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
  stoptap;
end;

procedure TSpecEmu.ButtonUpChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.ButtonUpClick(Sender: TObject);
begin
  ButtonUp.Checked := false;
  ButtonDown.Checked := false;
  ButtonLeft.Checked := false;
  ButtonRight.Checked := false;
  ButtonFire.Checked := false;
end;

procedure TSpecEmu.ButtonUpExit(Sender: TObject);
begin

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
  SetFocusToScreen;
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
procedure TSpecEmu.UpdateOptions;
begin
  Options.JL_Type:= TJoystickType(GroupLeftJoystick.ItemIndex);
  Options.JR_Type:= TJoystickType(GroupRightJoystick.ItemIndex);
  Options.joystick_Protocol:= TjoystickProtocol(GroupJoystickProtocol.ItemIndex);
  //Options.machine := Tmachine(Groupmachine.ItemIndex);
  Options.user_keys := user_buttons;
  fdc_present := is_fdc_machine;
  options.volume_AY := Trackbar_AY.Position;
  options.volume_ear := Trackbar_ear.Position;
  options.volume_speaker := Trackbar_speaker.Position;
  options.volume_mic:=Trackbar_mic.Position;
end;

procedure TSpecEmu.ckAYSoundChange(Sender: TObject);
begin
  UpdateOptions;
  AYCHA.enabled := ckAYSound.Checked;
  AYCHB.enabled := false;
  AYCHC.enabled := false;
  //restart_emulation;
end;

procedure TSpecEmu.ckDiskA_protChange(Sender: TObject);
begin
  drive_protected[0] := byte(ckDiskA_prot.checked) and 1;
end;

procedure TSpecEmu.ckDiskB_activeChange(Sender: TObject);
begin
     if ckDiskB_active.checked then
     begin
       //driveBFloppy.Visible := true;
       //driveB.Visible := true;
       //ButtonFloppy2.Visible := true;
       //StaticText18.Visible:= true;
       drive_connected[1] := 1;
       driveBPanel.Visible := true;
     end else begin
       drive_connected[1] := 0;
       driveBPanel.Visible := false;
       //driveBFloppy.Visible := false;
       //driveB.Visible := false;
       //ButtonFloppy2.Visible := false;
       //driveBLed.Visible := false;
       //StaticText18.Visible:= false;
     end;
end;

procedure TSpecEmu.ckDiskB_protChange(Sender: TObject);
begin
  drive_protected[1] := byte(ckDiskB_prot.checked) and 1;
end;

procedure TSpecEmu.driveADragDrop(Sender, Source: TObject; X, Y: Integer);
begin

end;

procedure TSpecEmu.driveADragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  DriveSelected := 1;
end;

procedure TSpecEmu.driveAMouseEnter(Sender: TObject);
begin

end;

procedure TSpecEmu.driveBDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  DriveSelected := 1;
end;

procedure TSpecEmu.driveBDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin

end;

procedure TSpecEmu.driveBMouseEnter(Sender: TObject);
begin

end;

procedure TSpecEmu.driveBMouseLeave(Sender: TObject);
begin

end;

procedure TSpecEmu.edAsm_addrChange(Sender: TObject);
begin

end;

procedure TSpecEmu.edAsm_addrKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
    button9click(self);

end;


procedure TSpecEmu.FormChangeBounds(Sender: TObject);
begin
  timed_pause_emulation;
end;

procedure TSpecEmu.FormClick(Sender: TObject);
begin

end;

procedure TSpecEmu.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var
   ext, FileName: String;
   fname: string;
   coord: TPoint;
   BR: TRect;
   question: string;
   txt: pchar;
begin
  pause_emulation;
  for FileName in FileNames do
  begin
    ext := Upcase(extractfileext(FileName));
    fname := ChangeFileExt(extractfilename(filename),EmptyStr);
    if (ext = '.TAP') or (ext = '.TZX') then
    begin
      load_tap_file(FileName);
    end else
    if (ext = '.DSK') then
    begin
      coord := ScreenToClient(Mouse.CursorPos);
      BR :=DriveBPanel.BoundsRect;
      BR.SetLocation(DriveBPanel.Left+PanelFloppy.Left+TapePanel.Left, DriveBPanel.Top+PanelFloppy.Top+TapePanel.Top);
      if BR.Contains(coord) then
        Insert_Drive_B(FileName)
      else
        Insert_Drive_A(FileName);
    end else
    if (ext = '.BAS') or (ext = '.BIN') or (ext = '.SCR') then
    begin
      if OpenTapFileDialog.Filename = '' then
      begin
        OpenTapFileDialog.Filename := fname+'.TAP';
        if OpenTapFileDialog.Execute then
        begin
          if fileexists(OpenTapFileDialog.Filename) then
          begin
            question := 'OVERWRITE '+ OpenTapFileDialog.Filename + '?';
            txt := StrAlloc(Length(question) + 1);
            StrPCopy(txt, question);
            pause_emulation;
            if Application.MessageBox(txt, 'FILE EXISTS', MB_ICONQUESTION + MB_YESNO)=IDYES then
            begin
              if (ext = '.BAS') then
                 bas_to_tap(FileName,OpenTapFileDialog.Filename,$8000,fname)
              else
              if (ext = '.BIN') then
                 bin_to_tap(FileName,OpenTapFileDialog.Filename,fname, $8000)
              else
              if (ext = '.SCR') then
                 bin_to_tap(FileName,OpenTapFileDialog.Filename,fname, $4000);
              load_tap_file(OpenTapFileDialog.Filename);
            end;
            StrDispose(txt);
          end else begin
            if (ext = '.BAS') then
               bas_to_tap(FileName,OpenTapFileDialog.Filename,$8000,fname)
            else
            if (ext = '.BIN') then
               bin_to_tap(FileName,OpenTapFileDialog.Filename,fname, $8000)
            else
            if (ext = '.SCR') then
               bin_to_tap(FileName,OpenTapFileDialog.Filename,fname, $4000);
            load_tap_file(OpenTapFileDialog.Filename);
          end;
        end;
      end else begin
        //OpenTapFileDialog.Filename := fname+'.TAP';
        deletefile('$$$$$$$$.001');
        deletefile('$$$$$$$$.002');
        if (ext = '.BAS') then
          bas_to_tap(FileName,'$$$$$$$$.002',$8000,fname)
        else
        if (ext = '.BIN') then
           bin_to_tap(FileName,'$$$$$$$$.002',fname, $8000)
        else
        if (ext = '.SCR') then
          bin_to_tap(FileName,'$$$$$$$$.002',fname, $4000);
        renamefile(OpenTapFileDialog.Filename,'$$$$$$$$.001');
        UnirArchivo('$$$$$$$$.001',OpenTapFileDialog.Filename);
        load_tap_file(OpenTapFileDialog.Filename);
      end;
    end else
    if (ext = '.Z80') or (ext = '.SNA') then
    begin
      loadSnapshotfile(FileName);
    end;
  end;
  //restart_emulation;
end;

procedure TSpecEmu.SwitchAspectRatio;
begin
  ckAspect.Checked := not ckAspect.Checked;
  options.AspectRatio:= ckAspect.checked;
  RefreshScreen;
  if debugging then
  begin
    pantalla.ColorOpacity:=255;
    //clearSpectrumScreen(options.ScrColor);
    draw_screen;
  end;
end;


procedure TSpecEmu.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_NEXT  : ZoomOutButtonClick(self);
    VK_PRIOR : ZoomInButtonClick(self);
    VK_F6    : SwitchAspectRatio;
    VK_F7    : StepOverButtonclick(self);
    VK_F8    : step := true;
    VK_F9    : begin
      if debugging then PlayButtonClick(self)
      else begin
        start_debug;
        if BorderStyle = bsNone then
        begin
          pantalla.ColorOpacity:=255;
          draw_screen;
        end;
      end;
      SetFocusToScreen;
    end;
    VK_F11   : begin
      signal_refresh := true;
      SwitchFullScreen;
      if (BorderStyle = bsNone) and debugging then
      begin
        //clearSpectrumScreen(options.ScrColor);
        draw_screen;
        pantalla.ColorOpacity:=255;
      end;
      SetFocusToScreen;
    end;
  end;
  if (BorderStyle = bsNone) or Bfocus.focused then
  begin
    BFocusdKeyDown(Sender, Key, Shift);
  end;
end;

procedure TSpecEmu.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if (BorderStyle = bsNone) or Bfocus.focused then
  begin
    BFocusdKeyUp(Sender, Key, Shift);
  end;
end;

procedure TSpecEmu.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  a:=a;
end;

procedure TSpecEmu.FormMouseLeave(Sender: TObject);
begin

end;

procedure TSpecEmu.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
end;

procedure TSpecEmu.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  a:=a;
end;

procedure TSpecEmu.FullScreenButtonClick(Sender: TObject);
begin
  SwitchFullScreen;
  SetFocusToScreen;
end;

procedure TSpecEmu.GroupJoystickProtocolClick(Sender: TObject);
begin
  UpdateJoystickPanels;
end;

procedure TSpecEmu.UserJoyKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
end;
procedure TSpecEmu.UserJoyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ButtonUp.Checked then
  begin
    AssignUserButton(user_up, Key);
    ButtonUp.checked := false;
    if key = VK_SHIFT then
        ButtonUp.caption := '↑'
    else if key = VK_RETURN then
        ButtonUp.caption := '┘'
    else if key = VK_CONTROL then
        ButtonUp.caption := '©'
    else if key = VK_MENU then
        ButtonUp.caption := '⌂'
    else if key = VK_SPACE then
        ButtonUp.caption := '_'
    else ButtonUp.checked := true;
  end else
  if ButtonDown.Checked then
  begin
    AssignUserButton(user_down, Key);
    Buttondown.checked := false;
    if key = VK_SHIFT then
        Buttondown.caption := '↑'
    else if key = VK_CONTROL then
        ButtonDown.caption := '©'
    else if key = VK_RETURN then
        Buttondown.caption := '┘'
    else if key = VK_MENU then
        ButtonDown.caption := '⌂'
    else if key = VK_SPACE then
        Buttondown.caption := '_'
    else
       Buttondown.checked := true;
  end else
  if ButtonLeft.Checked then
  begin
    AssignUserButton(user_left, Key);
    ButtonLeft.checked := false;
    if key = VK_SHIFT then
        ButtonLeft.caption := '↑'
    else if key = VK_CONTROL then
        ButtonLeft.caption := '©'
    else if key = VK_RETURN then
        ButtonLeft.caption := '┘'
    else if key = VK_MENU then
        ButtonLeft.caption := '⌂'
    else if key = VK_SPACE then
        ButtonLeft.caption := '_'
    else
       ButtonLeft.checked := true;

  end else
  if ButtonRight.Checked then
  begin
    AssignUserButton(user_right, Key);
    ButtonRight.checked := false;
    if key = VK_SHIFT then
        Buttonright.caption := '↑'
    else if key = VK_CONTROL then
        ButtonRight.caption := '©'
    else if key = VK_RETURN then
        Buttonright.caption := '┘'
    else if key = VK_MENU then
        ButtonRight.caption := '⌂'
    else if key = VK_SPACE then
        ButtonRight.caption := '_'
    else
       ButtonRight.checked := true;
  end else
  if ButtonFire.Checked then
  begin
    AssignUserButton(user_fire, Key);
    ButtonFire.checked := false;
    if key = VK_SHIFT then
        ButtonFire.caption := '↑'
    else if key = VK_CONTROL then
        ButtonFire.caption := '©'
    else if key = VK_RETURN then
        ButtonFire.caption := '┘'
    else if key = VK_MENU then
        ButtonFire.caption := '⌂'
    else if key = VK_SPACE then
        ButtonFire.caption := '_'
    else
       ButtonFire.checked := true;
  end;
end;

procedure TSpecEmu.UserJoyKeyPress(Sender: TObject; var Key: char);
begin
  key := Upcase(key);
  if ButtonUp.Checked then
  begin
    if key >= ' ' then
       ButtonUp.caption := key;
  end else
  if ButtonDown.Checked then
  begin
    if key >= ' ' then
       ButtonDown.caption := Key;
  end else
  if ButtonLeft.Checked then
  begin
    if key >= ' ' then
       ButtonLeft.caption := Key;
  end else
  if ButtonRight.Checked then
  begin
    if key >= ' ' then
       ButtonRight.caption := Key;
  end else
  if ButtonFire.Checked then
  begin
    if key >= ' ' then
       ButtonFire.caption := Key;
  end;
end;

procedure TSpecEmu.GroupLeftJoystickClick(Sender: TObject);
begin
  OpenJoysticks;
  UpdateJoystickPanels;
end;

//procedure TSpecEmu.GroupMachineClick(Sender: TObject);
//begin
//  stROM0.Caption:= ExtractFileName(options.ROMFilename[groupmachine.ItemIndex,0]);
//  stROM1.Caption:= ExtractFileName(options.ROMFilename[groupmachine.ItemIndex,1]);
//  stROM2.Caption:= ExtractFileName(options.ROMFilename[groupmachine.ItemIndex,2]);
//  stROM3.Caption:= ExtractFileName(options.ROMFilename[groupmachine.ItemIndex,3]);
//  coldbootrequired := true;
//end;
//
procedure TSpecEmu.GroupRightJoystickClick(Sender: TObject);
begin
  OpenJoysticks;
  UpdateJoystickPanels;
end;

procedure TSpecEmu.grUserJoyClick(Sender: TObject);
begin

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

procedure TSpecEmu.ButtonTap1Click(Sender: TObject);
begin

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

procedure TSpecEmu.maximize_window;
var
  sx, sy: Real;
begin
  //bak_scale_X := scale_X;
  //bak_scale_Y := scale_Y;
  sx := (width - debug_width-stX*2-SideButtons.width) / sizex1x;
  sy := (height -stY*2 - bottomButtonsPanel.Height) / sizey1x;
  if ckAspect.checked then
  begin
    if sx < sy then sy := sx
    else sx := sy;
  end;
  scale_X := sx;
  scale_Y := sy;
end;

procedure TSpecEmu.FormWindowStateChange(Sender: TObject);
begin
  if (WindowState=wsMaximized) then begin
    //        bak_scale := scale;
    maximize_window;
    adjust_window_size;
    //        draw_screen;
  end else if (WindowState=wsNormal) then begin
    scale_X := bak_scale_X;
    scale_Y := bak_scale_Y;
    adjust_window_size;
    bak_scale_X := scale_X;
    bak_scale_Y := scale_Y;
  end;
  signal_refresh := true;
end;

procedure TSpecEmu.Label18Click(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(hl);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.Label19Click(Sender: TObject);
var
  v: word;
begin
  v := rdmem2(bc);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.Label1Click(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(pc);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.Label20Click(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(de);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.Label2Click(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(sp);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.memgridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (aCol=mem_col) and (aRow=mem_row) then
  with TStringGrid(Sender) do
  begin
    //paint the background Green
    Canvas.Brush.Color := clSkyBlue;
    Canvas.FillRect(aRect);
    Canvas.TextOut(aRect.Left+2,aRect.Top+2,Cells[ACol, ARow]);
  end;
end;

procedure TSpecEmu.memgridEditingDone(Sender: TObject);
var
  addr: word;
  v,code: byte;
  s: string[2];
begin
  if      src_ptr.Checked then addr := mem_addr
  else if src_ix.Checked then addr := ix-127
  else if src_iy.Checked then addr := iy-127;
  addr := addr and not $f;
  addr+=(memgrid.Row-1)*$10+(memgrid.Col-1);
  S := memgrid.Cells[memgrid.Col,memgrid.Row];
  if S = '' then S := #0;
  if asciiselection.Checked then
    v := ord(s[1])
  else
    v := Hex2Dec(S);
  wrmem(addr,v);
  set_memory_dump;
end;

procedure TSpecEmu.Read_tap_blocs;
var
  F: File;
  n,size,Proglen,startAddr: word;
  AutoStart: word absolute StartAddr;
  Variable: String[2];
  BlockType: String[6];
  DataType: String[6];
  FileName: String[10];
  BSize: String[6];
  BT: Byte;
  Blocklen: word;
begin
  try
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
               Blockgrid.InsertRowWithValues(n,['','Data at '+IntToStr(startAddr),BSize,DataType,IntToStr(ProgLen)])
            else if(DataType='BYTES') or (DataType='SCR') then
               Blockgrid.InsertRowWithValues(n,['','Data at '+IntToStr(startAddr),BSize,DataType,''])
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
  except
    ShowMessage('Error reading tap blocks');
  end;
end;

procedure TSpecEmu.EventMenuClick(Sender: TObject);
begin
  option := TMenuItem(Sender).Tag;
end;

procedure TSpecEmu.Make_selection_menu(tap_block_num: word);
var
  F: File;
  result: longint;
  nn: byte;
begin
  try
    AssignFile (F, OpenTapFileDialog.FileName);
    Reset(F,1);
    Seek(F, Tape_info[tap_block_num].Filepos); // skeep tzx header
    BlockRead(F, Block_ID, sizeof(Block_ID),result);
    BlockRead(F, Blocklen, sizeof(Blocklen),result);
    BlockRead(F, num_options, sizeof(num_options),result);
    TAPMenu.items.Clear;
    for nn := 0 to num_options-1 do
    begin
      BlockRead(F, select_option.offset,2,result);
      BlockRead(F, select_option.text[0],1,result);
      BlockRead(F, select_option.text[1],byte(select_option.text[0]),result);
      select_options[nn] := select_option;
      MenuItem := TMenuItem.Create(TAPMenu);
      MenuItem.Caption := select_option.text;
      MenuItem.OnClick := @EventMenuClick;
      MenuItem.Tag := nn;                  // this is the integer which is passed with TMenuItem
      TAPMenu.items.Add(MenuItem);
    end;
    closefile(f);
  except
  end;
end;

procedure TSpecEmu.Read_tzx_blocs;
var
  F: File;
  n,size,Proglen,startAddr,rep: word;
  AutoStart: word absolute StartAddr;
  Variable: String[2];
  BlockType: String[6];
  DataType: String[6];
  FileName: String[10];
  BSize: String[6];
  BT: Byte;
  Blocklen: word;

  block_id: byte;
  result: longint;
  tzx_end: boolean = false;
  S: String[255];
  nn: byte;
  time: word;
  machine: HW_type;
  new_block: word;
  addr: longint;

  procedure insert_datablock_row(block_id: byte; size: longint);
  var
    sbid: string;
  begin
    if size > 0 then
    begin
      if block_id <> 0 then
        sbid := '0x'+IntToHex(block_id,2)
      else
        sbid := '';
      Tape_info[n].Flag := BT;
      Tape_info[n].Size := size;
      if BT=0 then begin                     // HEADER
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
        Blockgrid.InsertRowWithValues(n,['',FileName,BSize,BlockType,'',sBID]);
      end else begin
        BlockType := 'DATA';
        if (DataType='BAS') then
          Blockgrid.InsertRowWithValues(n,['','Data block',BSize,DataType,IntToStr(ProgLen),sBID])
        else if(DataType='BYTES') or (DataType='SCR') then
          Blockgrid.InsertRowWithValues(n,['','Data block',BSize,DataType,'',sBID])
        else
          Blockgrid.InsertRowWithValues(n,['',Variable,BSize,DataType,'','','',sBID]);
        DataType := 'BYTES';
      end;
    end;
  end;

begin
  try
    DataType := 'BYTES';                       // If not header next block is RAW
    n := 1;
    Blockgrid.Clean;
    AssignFile (F, OpenTapFileDialog.FileName);
    Reset(F,1);
    Seek(F,10);                                // skeep tzx header
    tzx_end := false;
    while (FilePos(F) < FileSize(F)) and not tzx_end do
    begin
      Tape_info[n].FilePos := FilePos(F);
      result := FilePos(F);
      BlockRead(F, block_id, sizeof(block_id));
      case block_id of
        $10: // Standard Speed Data Block
        begin
          blockread(f,buff,2,result);
          blockread(f,size, sizeof(size),result);
          BlockRead(F,BT,1,result);
          BlockRead(F, buff, size-1,result);
          Str(size,BSize);
          insert_datablock_row(block_id,size);
        end;
        $11: // Turbo Speed Data Block
        begin
          blockread(f,buff,15,result);
          BlockRead(F, data_size3, sizeof(data_size3),result);
          data_size := data_size3[2]*65536+data_size3[1]*256+data_size3[0];
          BlockRead(F,BT,1,result);
          BlockRead(F, buff, data_size-1,result);
          Str(data_size,BSize);
          insert_datablock_row(block_id,data_size);
        end;
        $12: begin
          BlockRead(F, pilot_pulse_len, sizeof(pilot_pulse_len),result);
          BlockRead(F, PILOT_pulses, sizeof(PILOT_pulses),result);
          Blockgrid.InsertRowWithValues(n,['','Pure tone',IntToStr(pilot_pulse_len),'',IntToStr(PILOT_pulses),'0x'+IntToHex(block_id,2)]);
        end;
        $13: // Pulse sequence
        begin
          BlockRead(F, pulse_number, sizeof(pulse_number),result);
          for nn := 0 to pulse_number-1 do
          begin
            BlockRead(F, pulses_len[nn], sizeof(pulses_len[nn]),result);
          end;
          Blockgrid.InsertRowWithValues(n,['','Pulse sequence',InttoStr(pulse_number),'','','0x'+IntToHex(block_id,2)]);
        end;
        $14: // Pure Data Block
        begin
          BlockRead(F, BIT0_len, sizeof(BIT0_len),result);
          BlockRead(F, BIT1_len, sizeof(BIT1_len),result);
          BlockRead(F, bits_in_last_byte, sizeof(bits_in_last_byte),result);
          BlockRead(F, pause_len, sizeof(pause_len),result);
          BlockRead(F, data_size3, sizeof(data_size3),result);
          data_size := data_size3[2]*65536+data_size3[1]*256+data_size3[0];
          BlockRead(F, data, data_size,result);
          Blockgrid.InsertRowWithValues(n,['','Data block',InttoStr(data_size),'','','0x'+IntToHex(block_id,2)]);
        end;
        $20: // Pause (silence) or 'Stop the Tape' command
        begin
          BlockRead(F, pause, sizeof(time),result);
          Blockgrid.InsertRowWithValues(n,['','Pause '+InttoStr(time)+' ms','','','','0x'+IntToHex(block_id,2)]);
        end;
        $21: // Group start
        begin
          blockread(f,s[0],1,result);
          blockread(f,s[1],byte(s[0]),result);
          Blockgrid.InsertRowWithValues(n,['','Group '+s,'','','','0x'+IntToHex(block_id,2)]);
        end;
        $22: // Group end
        begin
          Blockgrid.InsertRowWithValues(n,['','Group end','','','','0x'+IntToHex(block_id,2)]);
        end;
        $23: // Jump to block
        begin
          BlockRead(F, new_block, sizeof(new_block),result);
          Blockgrid.InsertRowWithValues(n,['','JUMP '+InttoStr(new_block),'','','','0x'+IntToHex(block_id,2)]);
        end;
        $24: // Loop start
        begin
          BlockRead(F, rep, sizeof(rep),result);
          Blockgrid.InsertRowWithValues(n,['','Loop('+InttoStr(rep)+')','','','','0x'+IntToHex(block_id,2)]);
        end;
        $25: // Loop end
        begin
          Blockgrid.InsertRowWithValues(n,['','Loop End','','','','0x'+IntToHex(block_id,2)]);
        end;
        $26: // Call sequence
        begin
          BlockRead(F, num_calls, sizeof(num_calls),result);
          S := 'CALL ';
          for nn := 0 to num_calls-1 do
          begin
            BlockRead(F, call_block, sizeof(call_block),result);
            call_blocks[nn] := call_block;
            S := S + IntToStr(call_block)+ ' ' ;
          end;
          Blockgrid.InsertRowWithValues(n,['',S,'','','','0x'+IntToHex(block_id,2)]);
        end;
        $27: // Return from sequence
        begin
          Blockgrid.InsertRowWithValues(n,['','RETURN','','','','0x'+IntToHex(block_id,2)]);
        end;
        $28: // Select block
        begin
          BlockRead(F, Blocklen, sizeof(Blocklen),result);
          BlockRead(F, num_options, sizeof(num_options),result);
          S := 'SELECT ';
          //TAPMenu.items.Clear;
          for nn := 0 to num_options-1 do
          begin
            BlockRead(F, select_option.offset,2,result);
            BlockRead(F, select_option.text[0],1,result);
            BlockRead(F, select_option.text[1],byte(select_option.text[0]),result);
            select_options[nn] := select_option;
            S := S + select_option.text +' ';
            //MenuItem := TMenuItem.Create(TAPMenu);
            //MenuItem.Caption := select_option.text;
            //TAPMenu.items.Add(MenuItem);
          end;
          Blockgrid.InsertRowWithValues(n,['',S,'','','','0x'+IntToHex(block_id,2)]);
        end;
        $2A: // Stop the tape if in 48K mode
        begin
          BlockRead(F, block_len, 4,result);
          Blockgrid.InsertRowWithValues(n,['','STOP IN 48K','','','','0x'+IntToHex(block_id,2)]);
        end;
        $30: // Text description
        begin
          blockread(f,s[0],1,result);
          blockread(f,s[1],byte(s[0]),result);
          Blockgrid.InsertRowWithValues(n,['',s,'','','','0x'+IntToHex(block_id,2)]);
        end;
        $31: // Message block
        begin
          blockread(f,show_time,1,result);
          blockread(f,s[0],1,result);
          blockread(f,s[1],byte(s[0]),result);
          Blockgrid.InsertRowWithValues(n,['','MSG('+IntToStr(show_time)+')='+S,'','','','0x'+IntToHex(block_id,2)]);
        end;
        $32: // Archive info
        begin
          BlockRead(F, size, sizeof(size),result);
          BlockRead(F, data, size,result);
          Blockgrid.InsertRowWithValues(n,['','Arch.info','','','','0x'+IntToHex(block_id,2)]);
        end;
        $33: // Hardware type
        begin
          BlockRead(F, num_machines, sizeof(num_machines),result);
          for nn := 0 to num_machines-1 do
          begin
            BlockRead(F, machine, sizeof(machine),result);
          end;
          Blockgrid.InsertRowWithValues(n,['','Hardware type','','','','0x'+IntToHex(block_id,2)]);
        end;
        $35: // Custom info
        begin
         S[0] := #10;
         BlockRead(F,S[1], 10,result);
         BlockRead(F,Infolen, 4,result);
         BlockRead(F,data,Infolen,result);
         Blockgrid.InsertRowWithValues(n,['','CInfo:'+S,'','','','0x'+IntToHex(block_id,2)]);
         if result < size then
           stoptap;
        end;
        $5A: // "Glue" block
        begin
          BlockRead(F, data, 9,result);
          Blockgrid.InsertRowWithValues(n,['','Glue block','','','','0x'+IntToHex(block_id,2)]);
        end;
        $15,$18,$19:
        begin
          Blockgrid.InsertRowWithValues(n,['','NOT SUPPORTED'+IntToHex(addr,6),'','','','0x'+IntToHex(block_id,2)]);
          tzx_end := true;
        end
        else begin
          BlockRead(F, block_len, 4,result);
          BlockRead(F, data, block_len,result);
          addr := FilePos(F);
          Blockgrid.InsertRowWithValues(n,['','UNK '+IntToHex(addr,6),'','','','0x'+IntToHex(block_id,2)]);
          //tzx_end := true;
        end;
      end;
      inc(n);
    end;
    Tape_Blocks := n-1;
    Blockgrid.cells[0,1] := '>';
    Blockgrid.row := 1;
    CloseFile(F);
  except
    ShowMessage('Error reading tap blocks');
  end;
end;

procedure TSpecEmu.PanelKeyboardMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin

end;

procedure TSpecEmu.PantallaMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //if (BorderStyle = bsNone) and (y < (screen.height -10)) then
  //begin
  //  TimerBottomBar1.Enabled := true;
  //  TimerBottomBar.Enabled := false;
  //end
  //else
  //  TimerBottomBar1.Enabled := false;
  //if (BorderStyle = bsNone) and (y > (screen.height -10)) then
  //begin
  //  TimerBottomBar.Enabled := true;
  //  TimerBottomBar1.Enabled := false;
  //end
  //else
  //  TimerBottomBar.Enabled := false;
  //
  //if (BorderStyle = bsNone) and (x < (screen.width -10)) then
  //begin
  //  TimerSideBar1.Enabled := true;
  //  TimerSideBar.Enabled := false;
  //end
  //else
  //  TimerSideBar1.Enabled := false;
  //if (BorderStyle = bsNone) and (x > (screen.width -10)) then
  //begin
  //  TimerSideBar.Enabled := true;
  //  TimerSideBar1.Enabled := false;
  //end
  //else
  //  TimerSideBar.Enabled := false;
end;

procedure TSpecEmu.PantallaPaint(Sender: TObject);
begin
  draw_screen;
end;

procedure TSpecEmu.PauseButton2Click(Sender: TObject);
begin

end;

procedure TSpecEmu.PauseButtonClick(Sender: TObject);
begin
  start_debug;
  draw_screen;
end;

procedure TSpecEmu.restart_emulation;
begin
  if not debugging then
  begin
    AudioOut.resume();
    pause := false;
    //stPaused.visible := false;
  end;
end;

procedure TSpecEmu.stop_debug;
begin
  empezando := true;
  debugging := false;
  restart_emulation;
  PauseButton.Visible := not pause;
  PlayButton.Visible := pause;
  if starting then begin
     starting := false;
     RunEmulation;
  end;
  DebugPanel.Enabled := false;
  StepButton.Enabled := false;
end;

procedure TSpecEmu.pause_emulation;
begin
  AudioOut.pause();
  pause := true;
  //stPaused.visible := true;
end;

procedure TSpecEmu.timed_pause_emulation;
begin
  AudioOut.pause();
  pause := true;
end;

procedure TSpecEmu.start_debug;
begin
  pause_emulation;
  debugging := true;
  empezando := false;
  PauseButton.Visible := not pause;
  PlayButton.Visible := pause;
  stInstruction.caption := decode_instruction(pc);
  draw_screen;
  refresh_register_labels;
  DebugPanel.Enabled := true;
  StepButton.Enabled := true;
  //StepButton.SetFocus;
  debugging := true;
  step_over_break := false;
  clear_keyboard;
end;

procedure TSpecEmu.BitBtn3Click(Sender: TObject);
begin

end;

procedure TSpecEmu.PlayButtonClick(Sender: TObject);
begin
  stop_debug;
end;

procedure TSpecEmu.UpdateJoystickPanels;
begin
  GroupRightJoystick.Enabled := GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair);
  GroupLeftJoystick.Enabled := GroupJoystickProtocol.ItemIndex <> ord(joyp_none);
  If joystick1.Active then
     StatusJoystick1.Brush.Color:= clLime
  else
     StatusJoystick1.Brush.Color:= clGray;

  If joystick2.Active then
     StatusJoystick2.Brush.Color:= clLime
  else
     StatusJoystick2.Brush.Color:= clGray;

  grUserJoy.Enabled := GroupJoystickProtocol.ItemIndex = ord(joyp_user);
end;

procedure TSpecEmu.selectjoystick(joyactive: boolean; var joysticksel: word; newsel: word);
begin
  if not joyactive then
  begin
     if joysticksel = 2 then
        Joystick1.Close;
     if joysticksel = 3 then
        Joystick2.Close;
     joysticksel := newsel;
     case newsel of
       2: If not Joystick1.Init then
             ShowMessage('Joystick not found');
       3: If not Joystick2.Init then
             ShowMessage('Joystick not found');
     end;

  end;
end;

procedure TSpecEmu.rbplus2aChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.rbPlus2gChange(Sender: TObject);
begin
  UpdateOptions;
end;

procedure TSpecEmu.rbplus3Change(Sender: TObject);
begin
  Options.Machine := Spectrum_plus3;
end;

procedure TSpecEmu.RbRightJoy1Change(Sender: TObject);
begin

end;

procedure TSpecEmu.RbRightJoy2Change(Sender: TObject);
begin

end;

procedure TSpecEmu.RbRightJoyCursorChange(Sender: TObject);
begin

end;

procedure TSpecEmu.RbRightJoyNoneChange(Sender: TObject);
begin

end;

procedure TSpecEmu.rbspec128Change(Sender: TObject);
begin

end;

procedure TSpecEmu.rbspec48Change(Sender: TObject);
begin

end;

procedure TSpecEmu.OpenJoysticks;
begin
  if (GroupLeftJoystick.ItemIndex = ord(joyt_j1)) or
    (GroupRightJoystick.ItemIndex = ord(joyt_j1)) then
  begin
    try
      if not Joystick1.Init then
        ShowMessage('Joystick 1 not found');
      //else
      //  ShowMessage('Joystick 1 activated');
    except
           ShowMessage('Joystick 1 not connected')
    end;
  end else begin
       joystick1.close;
    //ShowMessage('Joystick1 deactivated');
  end;
  if (GroupLeftJoystick.ItemIndex = ord(joyt_j2)) or
    (GroupRightJoystick.ItemIndex = ord(joyt_j2)) then
  begin
    try
      if not Joystick2.Init then
        ShowMessage('Joystick 2 not found');
      //else
      //  ShowMessage('Joystick 2 activated');
    except
       ShowMessage('Joystick 2 not connected')
    end;
  end else begin
       joystick2.close;
    //ShowMessage('Joystick2 deactivated');
  end;
  UpdateJoystickPanels;
//  UpdateOptions;
end;

procedure TSpecEmu.ACSEarBufferDone(Sender: TComponent);
var
  bytes_readed: word;
begin
   if (sound_bytes >= 0) then begin
      if sound_bytes >= bufsize then
         bytes_readed := bufsize
      else
         bytes_readed := sound_bytes;

      if soundpos_read + bytes_readed >= spec_buffer_size then
      begin
         move(speaker_data[soundpos_read], speaker_buffer[0], spec_buffer_size-soundpos_read);
         soundpos_read := bytes_readed-(spec_buffer_size-soundpos_read);
         move(speaker_data[0], speaker_buffer[0], soundpos_read);
      end else begin
         move(speaker_data[soundpos_read], speaker_buffer[0], bufsize);
         inc(soundpos_read,bufsize);
      end;
      dec(sound_bytes,bytes_readed);

      AYCHA.paused := false;
      AYCHB.paused := false;
      AYCHC.paused := false;
      ACSEar.DataBuffer :=@speaker_buffer;
      ACSEar.DataSize := bufsize;
   end else begin
     AYCHA.paused := true;
     AYCHB.paused := true;
     AYCHC.paused := true;
     fillchar(speaker_buffer, 1, 128);
     ACSEar.DataBuffer :=@speaker_buffer;
     ACSEar.DataSize := 1;
   end;
end;


procedure TSpecEmu.ResetButtonClick(Sender: TObject);
begin
  UpdateOptions;
  UpdateFromOptions;
  ReadROM;
  step_over_break := false;
  //breakpoint_active := false;
  init_spectrum;
  reset_fdc;
  init_z80(coldbootrequired);
  reset_memory_banks;
  status_saved := false;
  pc := 0;
  if pause then begin
    draw_screen;
    refresh_register_labels;
  end;
  SetFocusToScreen;
end;

procedure TSpecEmu.sgBreakpointsButtonClick(Sender: TObject; aCol, aRow: Integer
  );
begin

end;

procedure TSpecEmu.compile_breakpoints;
var
  nn: byte;
  code: byte;

{
PC
A
F
B
C
D
E
H
L
AF
BC
DE
HL
IX
IY
SP
R
I
MEM()
READMEM
WRITEMEM
xxFE_in
xxFE_out
7FFD_out
1FFD_out
FFFD_in
FFFD_out
BFFD_out
}

  procedure compile_cond(r: string; o: string; v: string; index: byte; c: byte);
  var
    s: string;
    code: integer;
  begin
    with breakpoints[index].cond[c] do
    begin
      active := true;
      S := trim(upcase(r));
      if      s = 'F' then reg := REG_F
      else if s = 'A' then reg := REG_A
      else if s = 'C' then reg := REG_C
      else if s = 'B' then reg := REG_B
      else if s = 'E' then reg := REG_E
      else if s = 'D' then reg := REG_D
      else if s = 'L' then reg := REG_L
      else if s = 'H' then reg := REG_H
      else if s = 'F''' then reg := REG_F1
      else if s = 'A''' then reg := REG_A1
      else if s = 'C''' then reg := REG_C1
      else if s = 'B''' then reg := REG_B1
      else if s = 'E''' then reg := REG_E1
      else if s = 'D''' then reg := REG_D1
      else if s = 'L''' then reg := REG_L1
      else if s = 'H''' then reg := REG_H1
      else if s = 'AF' then reg := REG_AF
      else if s = 'BC' then reg := REG_BC
      else if s = 'DE' then reg := REG_DE
      else if s = 'HL' then reg := REG_HL
      else if s = 'AF''' then reg := REG_AF1
      else if s = 'BC''' then reg := REG_BC1
      else if s = 'DE''' then reg := REG_DE1
      else if s = 'HL''' then reg := REG_HL1
      else if s = 'PC' then reg := REG_PC
      else if s = 'SP' then reg := REG_SP
      else if s = 'I' then reg := REG_I
      else if s = 'R' then reg := REG_R
      else if copy(s,1,4) = 'MEMW' then
           reg := REG_MEMW
      else if copy(s,1,4) = 'MEMR' then
           reg := REG_MEMR
      else if copy(s,1,3) = 'MEM' then
      begin
        reg := REG_MEM;
        s := copy(s,5,length(s)-5);
        val(s,addr,code);
      end
      else if copy(s,1,2) = 'IN' then
      begin
        reg := REG_IN;
        s := copy(s,4,length(s)-4);
        val(s,addr,code);
      end
      else if copy(s,1,3) = 'OUT' then
      begin
        reg := REG_OUT;
        s := copy(s,5,length(s)-5);
        val(s,addr,code);
      end
      else active := false;
      S := trim(upcase(o));
      if      s='=' then op := OP_EQ
      else if s='>' then op := OP_GT
      else if s='<' then op := OP_LT
      else if s='<>' then op := OP_NEQ
      else if s='>=' then op := OP_GET
      else if s='<=' then op := OP_LET
      else active := false;
      val(v,value,code);
    end;
  end;

begin
  grid_breakpoint_active := false;
  max_breakpoint := sgBreakpoints.RowCount-1;
  for nn := 1 to max_breakpoint do
  begin
    compile_cond(sgBreakpoints.Cells[1,nn],sgBreakpoints.Cells[2,nn],sgBreakpoints.Cells[3,nn],nn,0);
    compile_cond(sgBreakpoints.Cells[4,nn],sgBreakpoints.Cells[5,nn],sgBreakpoints.Cells[6,nn],nn,1);
    compile_cond(sgBreakpoints.Cells[7,nn],sgBreakpoints.Cells[8,nn],sgBreakpoints.Cells[9,nn],nn,2);
    breakpoints[nn].active:=(sgBreakpoints.Cells[0,nn]<>'OFF') and
       (breakpoints[nn].cond[0].active or breakpoints[nn].cond[1].active or breakpoints[nn].cond[2].active);
    if breakpoints[nn].active then grid_breakpoint_active := true;
  end;
end;

procedure TSpecEmu.sgBreakpointsEditingDone(Sender: TObject);
begin
  compile_breakpoints;
end;

procedure TSpecEmu.sgBreakpointsHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
begin
  if not IsColumn then
    if sgBreakpoints.Cells[0,index] = 'OFF' then
      sgBreakpoints.Cells[0,index]:=' '
    else
      sgBreakpoints.Cells[0,index]:='OFF'
end;

procedure TSpecEmu.stBCcClick(Sender: TObject);
var
  v: word;
begin
  v := rdmem2(bc);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
  set_mem;
end;

procedure TSpecEmu.stDEcClick(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(de);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.StepButtonClick(Sender: TObject);
begin
  step := true;
end;

procedure TSpecEmu.StepOverButtonClick(Sender: TObject);
var
  S: string;
  len: byte;
  inst: string;
begin
  if pause then
  begin
    step_over_break := true;
    S := decode_instruction(pc);
    len := get_instruction_len(s);
    inst := get_instruction(s);
    step_over_true := pc + len;
    empezando := true;
    stop_debug;
    clear_keyboard;
  end;
  SetFocusToScreen;
end;

procedure TSpecEmu.stHLcClick(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(hl);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.UpdateRegistersFromLabels;
begin
  pc := hex2dec(stPC.caption);
  sp := hex2dec(stSP.caption);
  af := hex2dec(stAF.caption);
  bc := hex2dec(stBC.caption);
  de := hex2dec(stDE.caption);
  hl := hex2dec(stHL.caption);
  af1 := hex2dec(stAF1.caption);
  bc1 := hex2dec(stBC1.caption);
  de1 := hex2dec(stDE1.caption);
  hl1 := hex2dec(stHL1.caption);
  ix := hex2dec(stIX.caption);
  iy := hex2dec(stIY.caption);
  r := hex2dec(stRR.caption);
  i := hex2dec(stii.caption);
end;

procedure TSpecEmu.stRegisterClick(Sender: TObject);
var
  v: word;
  code: integer;
  s,regname: String;
  ww: byte;
begin
  if (TStaticText(Sender).Name <> 'stRR') and (TStaticText(Sender).Name <> 'stII') then
  begin
    ww := 4;
    regname := copy(TStaticText(Sender).Name,3,255);
  end
  else begin
    ww := 2;
    regname := copy(TStaticText(Sender).Name,4,255);
  end;
  s := InputBox('Register ' + regname,'New value?', 'x'+TStaticText(Sender).caption);
  val(s,v,code);
  if code = 0 then
    TStaticText(Sender).Caption := hexstr(v,ww);
  UpdateRegistersFromLabels;
  refresh_register_labels;
end;

procedure TSpecEmu.StepOverButton2Click(Sender: TObject);
begin

end;

procedure TSpecEmu.stFileDriveBClick(Sender: TObject);
begin

end;

procedure TSpecEmu.stROM0Click(Sender: TObject);
begin
  pause_emulation;
  odROM.FileName := Options.ROMFileName[ord(options.machine),0];
  if odROM.Execute then
  begin
    stROM0.Caption := ExtractFileName(odROM.FileName);
    options.ROMFilename[ord(options.machine),0] := odROM.FileName;
  end;
  //restart_emulation;
end;

procedure TSpecEmu.StatusJoystick2ChangeBounds(Sender: TObject);
begin

end;

procedure TSpecEmu.refresh_system;
begin
  clear_keyboard;
  draw_screen;
  refresh_register_labels;
end;

procedure TSpecEmu.fill_asm_window(addr: word);
var
  nn: word;
  S: string;
  len: byte;
begin
  nn := 0;
  lstasm_window.Clear;
  while nn < 255 do
  begin
    s := decode_instruction(addr);
    len := get_instruction_len(s);
    s := HexStr(addr,4)+ s;
    lstasm_window.items.Append(s);
    addr += len;
    inc(nn);
  end;
end;

procedure TSpecEmu.refresh_register_labels;
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
  MemPages.Cells[0,0] := 'C000-FFFF';
  MemPages.Cells[0,1] := '8000-BFFF';
  MemPages.Cells[0,2] := '4000-7FFF';
  MemPages.Cells[0,3] := '0000-3FFF';
  MemPages.Cells[1,0] := PageToStr(Mem_banks[3]);
  MemPages.Cells[1,1] := PageToStr(Mem_banks[2]);
  MemPages.Cells[1,2] := PageToStr(Mem_banks[1]);
  MemPages.Cells[1,3] := PageToStr(Mem_banks[0]);
  stScreenPage.Caption := 'SCREEN=RAM'+IntToStr(screen_page);
  if is_48k_machine then
  begin
    stPaggingDisabled.caption := 'NO PAGGING';
    stDiskMotor.caption := 'DISK MOTOR: N/A';
    stprinterStrobe.caption := 'PRINT STRB: N/A';
  end else begin
    if disable_pagging then
      stPaggingDisabled.caption := 'PAG DISABLED'
    else
      stPaggingDisabled.caption := 'PAG ENABLED';
    if is_plus3type_machine then
      stDiskMotor.caption := 'DISK MOTOR: N/A'
    else if disk_motor_on then
      stDiskMotor.caption := 'DISK MOTOR: ON'
    else
      stDiskMotor.caption := 'DISK MOTOR: OFF';
    if is_plus3type_machine then
      stprinterStrobe.caption := 'PRINT STRB: N/A'
    else if printer_strobe then
      stprinterStrobe.caption := 'PRINT STRB: ON'
    else
      stprinterStrobe.caption := 'PRINT STRB: OFF';
    stportout7ffd.caption := HexStr(last_out_7ffd,4);
    stportout1ffd.caption := HexStr(last_out_1ffd,4);
    stportoutfffd.caption := HexStr(last_out_fffd,4);
    stportinfffd.caption := HexStr(last_out_fffd,4);
    stportoutbffd.caption := HexStr(last_out_bffd,4);
    stportoutfe.caption := HexStr(last_out_fe,4);
    stportinfe.caption := HexStr(last_in_fe,4);
  end;
  cur_asm_addr := pc;
  fill_asm_window(cur_asm_addr);
  edAsm_addr.text := 'x'+HexStr(cur_asm_addr,4);
end;

procedure TSpecEmu.RunEmulation;
var
   ii: word = 0;
   ss: word;
   basicrom: boolean;
   flag: byte;
   yadormido : boolean = false;
   dummy: byte;
begin
  AudioOut.Run();
  init_z80(true);
  init_spectrum;
  reset_memory_banks;
  draw_screen;
  repaint_screen := false;
  prev_sound_bytes := sound_bytes;
  status_saved := false;
  while (not saliendo) do begin
    if signal_refresh then
    begin
      SwitchAspectRatio;
      SwitchAspectRatio;
      signal_refresh := false;
    end;
    if not pause and
      (((breakpoint_active and (breakpoint = pc)) or (grid_breakpoint_active and test_breakpoints)) and not empezando) or
      (step_over_break and (step_over_true = pc) and not empezando)
      then
    begin
      start_debug;
    end else if pause and not debugging then
    begin
      restart_emulation;
    end;
    if not pause or step or step_over_break then
    begin
      empezando := false;
      basicrom := is_48k_machine or
        (is_plus2type_machine and (Mem_banks[0]=ROMPAGE1)) or
         (is_plus3type_machine and (Mem_banks[0]=ROMPAGE3));

      if ((pc = $556) or ((pc >= $04c2) and (pc <= $04c6)))
        and not status_saved and basicrom and use_tapetraps then
      begin
        status_saved := true;
        save_cpu_status;
      end;
      if (pc >= $04c2) and (pc <= $04d8)
        and use_tapetraps
        and tap_file_selected
        and TapeRecLed.Visible and basicrom then // SAVE ROUTINE
      begin
        if status_saved then
           restore_cpu_status;
        status_saved := false;
        c_flag := Save_tape_block(IX,DE,A);
        compose_flags;
        ret;
        clear_keyboard;
        Application.ProcessMessages;
        speaker_out := false;
      end else if (pc >= $556) and (pc < $05e3) and
        TapePlayLed.Visible and basicrom
        and use_tapetraps then // LOAD ROUTINE
      begin
        Application.ProcessMessages;
        if status_saved then
        begin
          restore_cpu_status;
          flag := A;
        end else if pc = $562 then
        begin
          flag := A1;
        end;
        status_saved := false;
        spectrum_out($fe,A);                     // border color
        c_flag := Load_Tape_block(IX, DE, Flag); // IX: Addr; DE: Len; A: Flag byte
        compose_flags;
        ix+=de;
        ret;
        clear_keyboard;
        Application.ProcessMessages;
        restart_emulation;
        sonido_acumulado := 0;
        load_sound := 0;
        speaker_out := false;
      end else if not screen_tstates_reached or step then
         do_z80
      {else sleep(1)};
      if pause then
      begin
        stInstruction.caption := decode_instruction(pc);
        refresh_register_labels;
        draw_screen;
        Application.ProcessMessages;
      end;
      step := false;
    end;
    inc(ii);
    if (ii >= 2048) then begin
      Application.ProcessMessages;
      ii := 0;
    end;
    if stop_signal then
    begin
       ButtonStopClick(self);
       stop_signal := false;
    end;
    if playing_tap then
    begin
       handle_load_sound(block);
       if show_selection_menu then
       begin
         option := $ffff;
         Make_selection_menu(tap_block_num);
         TAPMenu.PopUp;
         while option = $ffff do
           Application.ProcessMessages;
         show_selection_menu := false;
       end;
       if block <> blockgrid.Row then
          blockgrid.row := block;
    end;
    t_states_cur_half_scanline := t_states - t_states_ini_half_scanline;
    t_states_cur_instruction := t_states - t_states_prev_instruction;
    if speaker_out then
       inc(sonido_acumulado, t_states_cur_instruction);
    t_states_prev_instruction := t_states;
    if t_states_cur_half_scanline >= t_states_sound_bit then
    begin
      AYActive := ckAYSound.checked or AYMachine;
      if ckAYSound.checked then
      begin
        Run_AY_Channel(AYCHA);
        Run_AY_Channel(AYCHB);
        Run_AY_Channel(AYCHC);
      end;


      t_states_ini_half_scanline :=  t_states; //-(t_states_cur_half_scanline-t_states_sound_bit);
      ss := ((sonido_acumulado * {8*}volume_speaker *2) div t_states_sound_bit+
              (load_sound * {8*}volume_ear)+
              (AYCHA.sound_level+AYCHB.sound_level+AYCHC.sound_level) * volume_AY div 4) div 4;
      if ss > 127 then
         ss := 127;
      speaker_data[soundpos_write] := 128 + ss;

      //speaker_data[soundpos_write] := 128 + AYCHA.sound_level;
      sonido_acumulado := 0;
      inc(soundpos_write);
      if soundpos_write > spec_buffer_size-1 then soundpos_write := 0;
      inc(sound_bytes);
    end;
    t_states_cur_frame := t_states - t_states_ini_frame;
    screen_line := t_states_cur_frame div t_states_scanline;
    bcolor[screen_line] := border_color;
//    time := screen_timer.Elapsed;
    screen_tstates_reached := (t_states_cur_frame >= screen_testados_total);
    repaint_screen := screen_tstates_reached and (sound_bytes <= 2048);//screen_timer.Elapsed >= 0.020;
    if screen_tstates_reached and not repaint_screen and not yadormido then
    begin
      sleep(5);
      yadormido := true;
    end;
    if disk_motor[0] then
       led_motor_on[0] := true;
    if disk_motor[1] then
       led_motor_on[1] := true;
    if repaint_screen and screen_tstates_reached then
    begin
      if timer_floppyA > 0 then
         dec(timer_floppyA);
      if timer_floppyB > 0 then
         dec(timer_floppyB);
      if (frames mod 10 = 0) and (timer_floppyA = 0) then
      begin
        timer_floppyA := 50;
        //driveALed.Visible := led_motor_on[0];
        if led_motor_on[0] then
          grled.Draw(bDriveALed.Canvas,0,0,True)
        else
           grledapagado.Draw(bDriveALed.Canvas,0,0,True);
        disk_motor[0] := false;
        led_motor_on[0] := false;
      end;
      if (frames mod 10 = 0) and (timer_floppyB = 0) and (drive_connected[1]=1) then
      begin
        timer_floppyB := 50;
        if led_motor_on[1] then
          grled.Draw(bDriveBLed.Canvas,0,0,True)
        else
           grledapagado.Draw(bDriveBLed.Canvas,0,0,True);
        //driveBLed.Visible := led_motor_on[1];
        disk_motor[1] := false;
        led_motor_on[1] := false;
      end;
      yadormido := false;
      prev_sound_bytes := sound_bytes;
      t_states_ini_frame := t_states-(t_states_cur_frame-screen_testados_total);
      intpend := true;
      draw_screen;
      repaint_screen := false;
      inc(frames);
      if (frames mod 50) = 0 then begin
        stsamples.caption := intToStr(sound_bytes);
      end;
    end;
  end;
end;

procedure TSpecEmu.UpdateFromOptions;
begin
  //GroupMachine.ItemIndex := ord(options.machine);
  GroupLeftJoystick.ItemIndex := ord(options.JL_Type);
  GroupRightJoystick.ItemIndex := ord(options.JR_Type);
  GroupJoystickProtocol.ItemIndex := ord(options.joystick_Protocol);
  user_buttons := Options.user_keys;
//  UpdateOptions;
  ButtonUp.caption := getdircaption(user_up);
  ButtonDown.caption := getdircaption(user_down);
  ButtonLeft.caption := getdircaption(user_left);
  ButtonRight.caption := getdircaption(user_right);
  ButtonFire.caption := getdircaption(user_fire);
  stROM0.caption := ExtractFileName(options.ROMFileName[ord(options.machine),0]);
  stROM1.caption := ExtractFileName(options.ROMFileName[ord(options.machine),1]);
  stROM2.caption := ExtractFileName(options.ROMFileName[ord(options.machine),2]);
  stROM3.caption := ExtractFileName(options.ROMFileName[ord(options.machine),3]);
  ckIssue2.checked := options.Issue2;
  ckAspect.Checked := Options.AspectRatio;
  Trackbar_AY.Position := options.volume_AY;
  Trackbar_ear.Position := options.volume_ear;
  Trackbar_speaker.Position := options.volume_speaker;
  Trackbar_mic.Position := options.volume_mic;
  if is_fdc_machine then
  begin
    drive_connected[0] := 1;
    Button_show_floppy.Enabled:=true;
    if ckDiskB_active.checked then
       drive_connected[1] := 1;
    change_to_floppy;
  end else begin
    drive_connected[0] := 0;
    drive_connected[1] := 0;
    Button_show_floppy.Enabled:=false;
    change_to_tape;
  end;
end;

procedure TSpecEmu.DefaultOptions;
begin
  // Default Options
  options.machine := Spectrum48;
  options.joystick_Protocol := joyp_none;
  options.JL_Type := joyt_none;
  options.JR_Type := joyt_none;
  AssignUserButton(user_up,VK_Q);
  AssignUserButton(user_down,VK_A);
  AssignUserButton(user_left,VK_O);
  AssignUserButton(user_right,VK_P);
  AssignUserButton(user_fire,VK_SPACE);
  options.user_keys := user_buttons;
  options.ROMFilename[ord(spectrum48),0]:='ROM\48.rom';
  options.ROMFilename[ord(spectrum48),1]:='';
  options.ROMFilename[ord(spectrum48),2]:='';
  options.ROMFilename[ord(spectrum48),3]:='';
  options.ROMFilename[ord(TK90x),0]:='ROM\tk90x.rom';
  options.ROMFilename[ord(TK90x),1]:='';
  options.ROMFilename[ord(TK90x),2]:='';
  options.ROMFilename[ord(TK90x),3]:='';
  options.ROMFilename[ord(TK95),0]:='ROM\tk95.rom';
  options.ROMFilename[ord(TK95),1]:='';
  options.ROMFilename[ord(TK95),2]:='';
  options.ROMFilename[ord(TK95),3]:='';
  options.ROMFilename[ord(inves),0]:='ROM\inves.rom';
  options.ROMFilename[ord(inves),1]:='';
  options.ROMFilename[ord(inves),2]:='';
  options.ROMFilename[ord(inves),3]:='';
  options.ROMFilename[ord(spectrum128),0]:='ROM\128ROM0.rom';
  options.ROMFilename[ord(spectrum128),1]:='ROM\128ROM1.rom';
  options.ROMFilename[ord(spectrum128),2]:='';
  options.ROMFilename[ord(spectrum128),3]:='';
  options.ROMFilename[ord(spectrum_plus2),0]:='ROM\plus2ROM0.rom';
  options.ROMFilename[ord(spectrum_plus2),1]:='ROM\plus2ROM1.rom';
  options.ROMFilename[ord(spectrum_plus2),2]:='';
  options.ROMFilename[ord(spectrum_plus2),3]:='';
  options.ROMFilename[ord(spectrum_plus2a),0]:='ROM\plus3ROM0_4-1.rom';
  options.ROMFilename[ord(spectrum_plus2a),1]:='ROM\plus3ROM1_4-1.rom';
  options.ROMFilename[ord(spectrum_plus2a),2]:='ROM\plus3ROM2_4-1.rom';
  options.ROMFilename[ord(spectrum_plus2a),3]:='ROM\plus3ROM3_4-1.rom';
  options.ROMFilename[ord(spectrum_plus3),0]:='ROM\plus3ROM0_4-1.rom';
  options.ROMFilename[ord(spectrum_plus3),1]:='ROM\plus3ROM1_4-1.rom';
  options.ROMFilename[ord(spectrum_plus3),2]:='ROM\plus3ROM2_4-1.rom';
  options.ROMFilename[ord(spectrum_plus3),3]:='ROM\plus3ROM3_4-1.rom';

  options.volume_AY:=100;
  options.volume_ear:=100;
  options.volume_speaker:=100;
  options.volume_mic:=100;
  options.AspectRatio:=true;
  options.ScrColor:=clWhite;

  UpdateFromOptions;

  LeftJoystickSelection := 0;
  RightJoystickSelection := 0;
  UpdateJoystickPanels;
end;

procedure TSpecEmu.ReadROMPage(Machine: Tmachine; ROMPage, Membank: byte);
var
   FF: File;
   r: longint;
   filename: string;
begin
  filename := Options.ROMFilename[ord(machine),ROMPage];
  if fileExists(filename) then
  begin
    Try
      AssignFile(FF,Filename);
      Reset(FF,1);
      blockread(FF,memP[membank],$4000,r);
      CloseFile(FF);
    except
       showmessage('Error reading ROM ' + filename);
    end;
    Init_Z80(true);
    reset_memory_banks
  end;
end;

procedure TSpecEmu.ReadROM;
begin
  ReadROMPage(options.machine, 0,ROMPAGE0);
  ReadROMPage(options.machine, 1,ROMPAGE1);
  ReadROMPage(options.machine, 2,ROMPAGE2);
  ReadROMPage(options.machine, 3,ROMPAGE3);
end;

procedure TSpecEmu.ReadOptions(Filename: string);
var
   FF: File;
   r: longint;
begin
  if fileExists(filename) then
  begin
    Try
      AssignFile(FF,Filename);
      Reset(FF,1);
      blockread(FF,options,sizeof(options),r);
      UpdateFromOptions;
      CloseFile(FF);
      except
         showmessage('Error reading options file');
    end;
  end else DefaultOptions;
  UpdateJoystickPanels;
end;

procedure TSpecEmu.SetFocusToScreen;
begin
  if (BorderStyle <> bsNone) then
  begin
    BFocus.SetFocus;
  end;
end;

procedure TSpecEmu.FormActivate(Sender: TObject);
begin

  stX := 15;
  stY := 10;

  mem_col := -1;
  mem_row := -1;

  DriveSelected := 0;
  cont_rueda := 0;
  brueda.visible := false;
  brueda1.visible := false;
  drive_protected[0] := byte(ckdiskA_prot.Checked) and 1;
  drive_protected[1] := byte(ckdiskB_prot.Checked) and 1;
  DebugPanel.Enabled := false;
  Button6Click(self);  // Activate debug panel 1
  TapePanel.Visible := false;
  DebugPanel.Visible := false;
  memgrid.ColWidths[0] := 35;
  adjust_window_size;
  fillchar(speaker_buffer,sizeof(speaker_buffer),0);
  //AudioOut.Run();
  Init_AY_Channel(AYCHA);
  Init_AY_Channel(AYCHB);
  Init_AY_Channel(AYCHC);
  CONFIG_AY_Channel(AYCHA,440,8,false,1,false,444,0,false);
  CONFIG_AY_Channel(AYCHB,16,8,false,1,false,444,0,false);
  CONFIG_AY_Channel(AYCHC,16,8,false,1,false,444,0,false);
  ACSEar.DataBuffer :=@speaker_buffer;
  ACSEar.DataSize := bufsize;
  sound_bytes := 2048;
  soundpos_write := sound_bytes;

  ReadOptions('OPTIONS.CFG');
  volume_AY:=calcVolumen(trackbar_AY.position);
  volume_ear := calcVolumen(trackbar_ear.position);
  volume_speaker := calcVolumen(trackbar_Speaker.Position,50,100);
  ReadROM;

  ButtonUp.OnKeyPress:=@UserJoyKeypress;
  ButtonDown.OnKeyPress:=@UserJoyKeypress;
  ButtonLeft.OnKeyPress:=@UserJoyKeypress;
  ButtonRight.OnKeyPress:=@UserJoyKeypress;
  ButtonFire.OnKeyPress:=@UserJoyKeypress;

  ButtonUp.OnKeyDown:=@UserJoyKeyDown;
  ButtonDown.OnKeyDown:=@UserJoyKeyDown;
  ButtonLeft.OnKeyDown:=@UserJoyKeyDown;
  ButtonRight.OnKeyDown:=@UserJoyKeyDown;
  ButtonFire.OnKeyDown:=@UserJoyKeyDown;

  ButtonUp.OnKeyUp:=@UserJoyKeyUp;
  ButtonDown.OnKeyUp:=@UserJoyKeyUp;
  ButtonLeft.OnKeyUp:=@UserJoyKeyUp;
  ButtonRight.OnKeyUp:=@UserJoyKeyUp;
  ButtonFire.OnKeyUp:=@UserJoyKeyUp;

  //img := TImage.Create(self);
  grComputer[Spectrum48] := TBGRABitmap.Create('spectrum_c.png');
  grComputer[tk90x] := TBGRABitmap.Create('tk90x.png');
  grComputer[tk95] := TBGRABitmap.Create('tk95_c.png');
  grComputer[inves] := TBGRABitmap.Create('inves_c.png');
  grComputer[Spectrum128] := TBGRABitmap.Create('spectrum128_c.png');
  grComputer[Spectrum_plus2] := TBGRABitmap.Create('spectrum_plus2_c.png');
  grComputer[Spectrum_plus2a] := TBGRABitmap.Create('spectrum_plus2a_c.png');
  grComputer[Spectrum_plus3] := TBGRABitmap.Create('spectrum_plus3_c.png');

  grrueda[0] := TBGRABitmap.Create('rueda1.png');
  grrueda[1] := TBGRABitmap.Create('rueda2.png');
  grrueda[2] := TBGRABitmap.Create('rueda3.png');
  grrueda[3] := TBGRABitmap.Create('rueda4.png');

  grled := TBGRABitmap.Create('led floppy.png');
  grledapagado := TBGRABitmap.Create('led floppy apagado.png');
  grledapagado.Draw(bDriveBLed.Canvas,0,0,True);
  grledapagado.Draw(bDriveALed.Canvas,0,0,True);

  tap_edit_controls_enabled(false);

  bkScrColor.PickedIndex:=options.ScrColor;
end;

procedure TSpecEmu.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  saliendo := true;
  AudioOut.Stop();
  Button_flush_drivesClick(self);
end;

procedure TSpecEmu.FormCreate(Sender: TObject);
begin
     saliendo := false;
     starting := true;
     pause := false;
     debugging := false;
     step := false;
     mem_addr := 0;
     scale_X := 1;
     scale_Y := 1;
     bak_scale_X := scale_X;
     bak_scale_Y := scale_Y;
     sizex := round(sizex1x*scale_X+15);
     sizey := round(sizey1x*scale_Y+5);
     SS_Status := 0;
end;

procedure TSpecEmu.PantallaClick(Sender: TObject);
begin
  SetFocusToScreen;
  draw_screen;
  clear_keyboard;
end;

procedure TSpecEmu.ScreenClick(Sender: TObject);
begin

end;

procedure TSpecEmu.ButtonDebug1Click(Sender: TObject);
begin

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
var
   v: word;
   s: string;
   code: integer;
begin
  s := stInstruction.caption;
  if s[length(s)] = ']' then
  begin
    s := 'x'+copy(s,length(s)-4,4);
    //val(s,v,code);
    EdMem.Text := s;//'x'+InttoHex(v,4);
    set_mem;
  end;
end;

procedure TSpecEmu.stIYClick(Sender: TObject);
begin

end;

procedure TSpecEmu.stPCClick(Sender: TObject);
begin

end;

procedure TSpecEmu.stROM1Click(Sender: TObject);
begin
  odROM.FileName := Options.ROMFileName[ord(options.machine),1];
  if odROM.Execute then
  begin
    stROM1.Caption := ExtractFileName(odROM.FileName);
    options.ROMFilename[ord(options.machine),1] := odROM.FileName;
  end;
end;

procedure TSpecEmu.stROM2Click(Sender: TObject);
begin
  odROM.FileName := Options.ROMFileName[ord(options.machine),2];
  if odROM.Execute then
  begin
    stROM2.Caption := ExtractFileName(odROM.FileName);
    options.ROMFilename[ord(options.machine),2] := odROM.FileName;
  end;
end;

procedure TSpecEmu.stROM3Click(Sender: TObject);
begin
  odROM.FileName := Options.ROMFileName[ord(options.machine),3];
  if odROM.Execute then
  begin
    stROM3.Caption := ExtractFileName(odROM.FileName);
    options.ROMFilename[ord(options.machine),3] := odROM.FileName;
  end;
end;

procedure TSpecEmu.stStackClick(Sender: TObject);
var
   v: word;
begin
  v := rdmem2(sp);
  EdMem.Text := 'x'+InttoHex(v,4);
  set_mem;
end;

procedure TSpecEmu.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  starting := true;
  stop_debug;
end;

procedure TSpecEmu.JoyTimerTimer(Sender: TObject);
var
   left1,up1,right1,down1,fire1,left2,up2,right2,down2,fire2: boolean;

    procedure getjoystick1;
   begin
     down1 := (joystick1.axis[1] > 48000);
     up1 := joystick1.axis[1] < 10000;
     right1 := joystick1.axis[0] > 48000;
     left1 := joystick1.axis[0] < 10000;
     fire1 := (Joystick1.Buttons[0] <> 0) or
              (Joystick1.Buttons[1] <> 0) or
              (Joystick1.Buttons[2] <> 0) or
              (Joystick1.Buttons[3] <> 0);
   end;

   procedure getjoystick2;
   begin
     down2 := joystick2.axis[1] > 48000;
     up2 := joystick2.axis[1] < 10000;
     right2 := joystick2.axis[0] > 48000;
     left2 := joystick2.axis[0] < 10000;
     fire2 := (Joystick2.Buttons[0] <> 0) or
              (Joystick2.Buttons[1] <> 0) or
              (Joystick2.Buttons[2] <> 0) or
              (Joystick2.Buttons[3] <> 0);
   end;
begin
  left1 := false;
  up1 := false;
  right1 := false;
  down1 := false;
  fire1 := false;
  left2 := false;
  up2 := false;
  right2 := false;
  down2 := false;
  fire2:= false;
  if Joystick1.Active then
     getjoystick1;
  if Joystick2.Active then
     getjoystick2;

  if (GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair)) and
  (GroupLeftJoystick.ItemIndex = ord(joyt_j1)) then
  begin
    if left1 then
       setSinclairLeft(0)
    else
       resetSinclairLeft(0);
    if right1 then
       setSinclairLeft(1)
    else
       resetSinclairLeft(1);
    if up1 then
       setSinclairLeft(3)
    else
       resetSinclairLeft(3);
    if down1 then
       setSinclairLeft(2)
    else
       resetSinclairLeft(2);
    if fire1 then
       setSinclairLeft(4)
    else
       resetSinclairLeft(4);
  end;

  if (GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair)) and
  (GroupLeftJoystick.ItemIndex = ord(joyt_j2)) then
  begin
    if left2 then
       setSinclairLeft(0)
    else
       resetSinclairLeft(0);
    if right2 then
       setSinclairLeft(1)
    else
       resetSinclairLeft(1);
    if up2 then
       setSinclairLeft(3)
    else
       resetSinclairLeft(3);
    if down2 then
       setSinclairLeft(2)
    else
       resetSinclairLeft(2);
    if fire2 then
       setSinclairLeft(4)
    else
       resetSinclairLeft(4);
  end;

  if (GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair)) and
  (GroupRightJoystick.ItemIndex = ord(joyt_j1)) then
  begin
    if left1 then
       setSinclairRight(4)
    else
       resetSinclairRight(4);
    if right1 then
       setSinclairLeft(3)
    else
       resetSinclairLeft(3);
    if up1 then
       setSinclairRight(1)
    else
       resetSinclairRight(1);
    if down1 then
       setSinclairRight(2)
    else
       resetSinclairRight(2);
    if fire1 then
       setSinclairRight(0)
    else
       resetSinclairRight(0);
  end;

  if (GroupJoystickProtocol.ItemIndex = ord(joyp_sinclair)) and
  (GroupRightJoystick.ItemIndex = ord(joyt_j2)) then
  begin
    if left2 then
       setSinclairRight(4)
    else
       resetSinclairRight(4);
    if right2 then
       setSinclairRight(3)
    else
       resetSinclairRight(3);
    if up2 then
       setSinclairRight(1)
    else
       resetSinclairRight(1);
    if down2 then
       setSinclairRight(2)
    else
       resetSinclairRight(2);
    if fire2 then
       setSinclairRight(0)
    else
       resetSinclairRight(0);
  end;

  if (GroupJoystickProtocol.ItemIndex = ord(joyp_kempston)) and
  (GroupLeftJoystick.ItemIndex = ord(joyt_j1)) then
  begin
    if left1 then
       setkempston(kempston_left)
    else
       resetkempston(kempston_left);
    if right1 then
       setkempston(kempston_right)
    else
       resetkempston(kempston_right);
    if up1 then
       setkempston(kempston_up)
    else
       resetkempston(kempston_up);
    if down1 then
       setkempston(kempston_down)
    else
       resetkempston(kempston_down);
    if fire1 then
       setkempston(kempston_fire)
    else
       resetkempston(kempston_fire);
  end;
  if (GroupJoystickProtocol.ItemIndex = ord(joyp_kempston)) and
  (GroupLeftJoystick.ItemIndex = ord(joyt_j2)) then
  begin
    if left2 then
       setkempston(kempston_left)
    else
       resetkempston(kempston_left);
    if right2 then
       setkempston(kempston_right)
    else
       resetkempston(kempston_right);
    if up2 then
       setkempston(kempston_up)
    else
       resetkempston(kempston_up);
    if down2 then
       setkempston(kempston_down)
    else
       resetkempston(kempston_down);
    if fire2 then
       setkempston(kempston_fire)
    else
       resetkempston(kempston_fire);
  end;
  if (GroupJoystickProtocol.ItemIndex = ord(joyp_user)) and
  (GroupLeftJoystick.ItemIndex = ord(joyt_j1)) then
  begin
    if left1 then
       setkeyb(user_buttons[user_left,0],user_buttons[user_left,1])
    else
       resetkeyb(user_buttons[user_left,0],user_buttons[user_left,1]);
    if right1 then
       setkeyb(user_buttons[user_right,0],user_buttons[user_right,1])
    else
       resetkeyb(user_buttons[user_right,0],user_buttons[user_right,1]);
    if up1 then
       setkeyb(user_buttons[user_up,0],user_buttons[user_up,1])
    else
       resetkeyb(user_buttons[user_up,0],user_buttons[user_up,1]);
    if down1 then
       setkeyb(user_buttons[user_down,0],user_buttons[user_down,1])
    else
       resetkeyb(user_buttons[user_down,0],user_buttons[user_down,1]);
    if fire1 then
       setkeyb(user_buttons[user_fire,0],user_buttons[user_fire,1])
    else
       resetkeyb(user_buttons[user_fire,0],user_buttons[user_fire,1]);
  end;
  if (GroupJoystickProtocol.ItemIndex = ord(joyp_user)) and
  (GroupLeftJoystick.ItemIndex = ord(joyt_j2)) then
  begin
    if left2 then
       setkeyb(user_buttons[user_left,0],user_buttons[user_left,1])
    else
       resetkeyb(user_buttons[user_left,0],user_buttons[user_left,1]);
    if right2 then
       setkeyb(user_buttons[user_right,0],user_buttons[user_right,1])
    else
       resetkeyb(user_buttons[user_right,0],user_buttons[user_right,1]);
    if up2 then
       setkeyb(user_buttons[user_up,0],user_buttons[user_up,1])
    else
       resetkeyb(user_buttons[user_up,0],user_buttons[user_up,1]);
    if down2 then
       setkeyb(user_buttons[user_down,0],user_buttons[user_down,1])
    else
       resetkeyb(user_buttons[user_down,0],user_buttons[user_down,1]);
    if fire2 then
       setkeyb(user_buttons[user_fire,0],user_buttons[user_fire,1])
    else
       resetkeyb(user_buttons[user_fire,0],user_buttons[user_fire,1]);
  end;
end;

procedure TSpecEmu.TimerBottomBar1Timer(Sender: TObject);
begin
  BottomButtonsPanel.Top := sizey + 8;
end;

procedure TSpecEmu.TimerBottomBarTimer(Sender: TObject);
begin
  BottomButtonsPanel.Top := screen.Height-BottomButtonsPanel.Height;
  //if not debugging then
  //begin
  //  restart_emulation;
  //  //Audioout.Resume();
  //  //pause := false;
  //end;
  //TimerBottomBar.Enabled := false;
end;

procedure TSpecEmu.TimerRuedaTimer(Sender: TObject);
begin
  if TapeImage.Visible then
  begin
    //grrueda[cont_rueda].Draw(brueda.Canvas,0,0,True);
    //grrueda[cont_rueda].Draw(brueda1.Canvas,0,0,True);
    brueda.Canvas.StretchDraw(rect(0,0,brueda.width,brueda.height),grrueda[cont_rueda].Bitmap);
    brueda1.Canvas.StretchDraw(rect(0,0,brueda1.width,brueda1.height),grrueda[cont_rueda].Bitmap);
  end else begin
  end;
  if TapePlayLed.Visible or TapeRecLed.Visible then
  begin
    if cont_rueda < 3 then
      inc(cont_rueda)
    else
      cont_rueda := 0;
  end;
end;

procedure TSpecEmu.TimerSideBar1Timer(Sender: TObject);
begin
  sidebuttons.visible := false;
  SideButtons.Left := round(352+sizex1x*scale_X-sizex1x);
end;

procedure TSpecEmu.TimerSideBarTimer(Sender: TObject);
begin
  sidebuttons.visible := true;
  SideButtons.Left := screen.Width-SideButtons.Width;
end;

procedure TSpecEmu.TrackBar_AYChange(Sender: TObject);
begin
  volume_AY:=calcVolumen(trackbar_AY.position);
end;

procedure TSpecEmu.TrackBar_EarChange(Sender: TObject);
begin
  volume_ear := calcVolumen(trackbar_ear.position);
end;

procedure TSpecEmu.TrackBar_SpeakerChange(Sender: TObject);
begin
  volume_speaker := calcVolumen(trackbar_Speaker.Position,50,100);
end;

procedure TSpecEmu.ZoomInButton2Click(Sender: TObject);
begin

end;

procedure TSpecEmu.ZoomInButtonClick(Sender: TObject);
var
   new_height: word;
begin
  new_height := round((scale_Y+1)*sizey1x);
  pause_emulation;
  if (BorderStyle <> bsNone) and (new_height < screen.height) and (WindowState = wsNormal) then begin
    scale_X := scale_X + 1;
    scale_Y := scale_Y + 1;
    adjust_window_size;
  end;
end;

procedure TSpecEmu.ZoomOutButton2Click(Sender: TObject);
begin

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
    x, y, curline: Integer;
    bgra: TBGRABitmap;
    bgrac: TBGRACustomBitmap;
    // bitmap: TBitmap;
    p: PBGRAPixel;
    v, bit, attr_offset: byte;
    pmem, pattr: word;
    desp: byte;

    function getColor(attr: byte; pixel: boolean): byte;
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

    procedure linea_borde(start,pixels: word);
    var
       x: word;
    begin
      inc(p,start);
      for x := start to pixels-1 do
      begin
        v := bcolor[curline];{border_color;}
        p^.red:= getRedComponent(v);
        p^.blue:= getBlueComponent(v);
        p^.green:= getGreenComponent(v);
        Inc(p);
      end;
    end;

    function rdshadow(addr: word): byte;
    begin
      rdshadow := memp[7,addr and $3FFF];
    end;

    function rdscreen(addr: word): byte;
    begin
      rdscreen := memp[5,addr and $3FFF];
    end;

    procedure show_pause;
    var
      shader: TPhongShading;
      renderer: TBGRATextEffectFontRenderer;
    begin
      //if (BorderStyle = bsNone) then
      //begin
        shader := TPhongShading.Create;
        renderer := TBGRATextEffectFontRenderer.Create(shader,True);
        bgra.FontRenderer := renderer;
        renderer.ShadowVisible := True;
        bgra.FontFullHeight := 5+round(5*Scale_Y);
        bgra.FontQuality:= fqFineAntialiasing;
        bgra.TextOut(120,1,'PAUSE',CSSRed);
    //  end {else stPaused.visible := true};
    end;

begin
  if debugging and (BorderStyle <> bsNone)then
    pantalla.ColorOpacity:=64
  else begin
    pantalla.ColorOpacity:=255;
    //stPaused.visible := false;
  end;
  inc(frame);
  bgra := TBGRABitmap.Create(sizex1x, sizey1x, BGRABlack);
  p := bgra.Data;
  x := 0;
  y := 0;
  bit := 128;
  pattr := 16384+6144;
  attr_offset := 0;
  curline := 0;
  if BorderEffect then
  begin
    desp := 50;
    for y := 0 to alto_borde-1 do
    begin
      p := bgra.Scanline[y];
      linea_borde(desp,ancho_borde*2+256-desp);
      if desp > 0 then
         desp := desp div 2;
      inc(curline);
    end;
  end else begin
    for y := 0 to alto_borde-1 do
    begin
      p := bgra.Scanline[y];
      linea_borde(0,ancho_borde*2+256);
      inc(curline);
    end;
  end;
  for y := 0 to 191 do
  begin
    p := bgra.Scanline[y+alto_borde];
    linea_borde(0,ancho_borde);
    pmem := lines[y];
    for x := 0 to 255 do
    begin
      if is_48k_machine then
         v := getColor(rdmem(pattr+attr_offset), (rdmem(pmem) and bit) <> 0)
      else if (screen_page = SCREENPAGE) then
         v := getColor(rdscreen(pattr+attr_offset), (rdscreen(pmem) and bit) <> 0)
      else // SHADOW SCREEN SELECTED
         v := getColor(rdshadow(pattr+attr_offset), (rdshadow(pmem) and bit) <> 0);
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
    linea_borde(0,ancho_borde);
    if y mod 8 = 7 then
       inc(pattr,32);
    attr_offset := 0;
    inc(curline);
  end;
  if BorderEffect then
  begin
    desp := 1;
    for y := 0 to alto_borde-1 do
    begin
      p := bgra.Scanline[y+192+alto_borde];
      linea_borde(desp-1,ancho_borde*2+256-desp+1);
      if y > alto_borde-9 then
         desp := desp * 2;
      inc(curline);
    end;
  end else begin
    for y := 0 to alto_borde-1 do
    begin
      p := bgra.Scanline[y+192+alto_borde];
      linea_borde(0,ancho_borde*2+256);
      inc(curline);
    end;
  end;
  if debugging then
    show_pause;
  if BFocus.Focused and (BorderStyle <> bsNone) then
     bgra.canvas.DrawFocusRect(rect(0,0,sizex1x-1,sizey1x-1));
  // bgra.InvalidateBitmap;
//  pantalla.canvas.StretchDraw(rect(stX,stY,round(sizex1x*scale_X+stX-1),round(sizey1x*scale_Y+stY-1)),bgra.Bitmap);
  //bgrac := FilterBlurRadial(bgra,2,rbFast);
  pantalla.canvas.StretchDraw(rect(stX,stY,round(sizex1x*scale_X+stX-1),round(sizey1x*scale_Y+stY-1)),bgra.Bitmap);
  bgra.Free;
end;

end.

