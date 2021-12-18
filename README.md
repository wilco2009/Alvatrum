# Alvatrum
yet another spectrum emulator totally written in Pascal.

(c) Alejandro Valero Sebastian
ALejandro VAlero specTRUM emulator

alfa version 0.004
First public version

Implemented:
z80 core
screen
fisical and virtual keyboard
tape reading to .tap files
speaker sound
debuger

alfa version 0.005
Timing adjustments
Corrected CPI & CPD instructions, Jetsetwilly now works

alfa version 0.006
save to tap implemented

alfa version 0.007
implemented snapshot handle
 - support load .SNA and .Z80
 - support save .SNA

alfa version 0.008
joystick support in progress

alfa version 0.009
joystick support implemented
bug fixed in tape handle

alfa version0.010
Options handle

alfa version0.011
MultiROM support in progress....

alfa version0.012
Spectrum 48K/TK90/TK95 - working
Spectrum 128K - working
Spectrum +2 gray - working
Spectrum +2a/+3 - In progress.....

alfa version0.013
Spectrum 48K/TK90/TK95 - working
Spectrum 128K - working
Spectrum +2 gray - working
Spectrum +2a/+3 - working
fixing z80 snapshots for +3 in progress

alfa version 0.014
z80 and sna snapshots are now working in 128/+3 mode

alfa version 0.015
fixed some problems with save in 128K machines
AY chip implementation in progress

alfa version 0.016
AY chip implementation completed

beta version 0.100
corrected several bugs

beta version 0.1.01
corrected bugs in z80 loading procedure
modified default options

beta version 0.1.02
solved bug in z80 instruction ex (sp),ix/iy - Tirnanog now works
solved bug in z80 instructions ld a,ixh and ld a,ixl - Rambo III and Renegade II now works

beta version 0.1.02
solved a bug when screen page 7 is active
opcodes $82 and $83 fixed - La Abadia del Crimen now works

beta version 0.1.03
Fixed a bug in the loading path procedure
following games works now:
Robocop
Rtype now loads but work with trash in the screen
Addams Family

beta version 0.1.04
Fixed a bug in the loading path procedure
following games works now:
Fernando Martin Basket
Hero Returns
R-Type

alfa version 0.1.05
Spectrum +3 disk emulation in progress.....

alfa version 0.1.06
Spectrum +3 disk emulation in progress.....
some disks are working

alfa version 0.1.07
Spectrum +3 disk emulation in progress.....
more disks are working

beta version 0.1.08
Spectrum +3 disk emulation in progress.....
more disks are working

beta version 0.1.09
Spectrum +3 disk emulation near to be completed
many disks are working
bug in all RAM modes fixed

beta version 0.1.10
Spectrum +3 disk emulation is ready 
some bugs fixed
standard load without trapping implemented.
border effects are now supported.

beta version 0.1.11
tzx files support

Supported blocks:
ID 10 - Standard Speed Data Block
ID 11 - Turbo Speed Data Block
ID 12 - Pure Tone
ID 13 - Pulse sequence
ID 14 - Pure Data Block
ID 20 - Pause (silence) or 'Stop the Tape' command
ID 21 - Group start
ID 22 - Group end
ID 23 - Jump to block
ID 24 - Loop start
ID 25 - Loop end
ID 26 - Call sequence
ID 27 - Return from sequence
ID 28 - Select block
ID 2A - Stop the tape if in 48K mode
ID 30 - Text description
ID 31 - Message block
ID 32 - Archive info
ID 33 - Hardware type
ID 35 - Custom info block
ID 5A - "Glue" block

Not supported blocks:
ID 15 - Direct Recording
ID 18 - CSW Recording
ID 19 - Generalized Data Block
ID 2B - Set signal level

beta version 0.1.12
improved cassette and disk animations
Drag and drop files to the emulator
convert .BAS, .BIN and .SCR files droping them to the emulator window
Improved debugger breakpoints
multiline assembler window available while debugging

beta version 0.1.13
Keyboard issue 2 behaviour implemented
Memory and ports breakpoints implemented
Editable registers and memory values
Volume mixer
solved some bugs

beta version 0.1.14
Full screen mode implemented
Now is possible to keep or not original aspect ratio
some minor bugs solved


TO DO:
memory contention

Thanks to:
 - Cesar Hernandez (ZEsarUX coder) - For his help along the emulator development. 
   Thanks also, because the source code of his emulator (ZEsarUX) was a very good reference in many occasions.
- José Luis Sanchez (JSpeccy coder) - For his help in the AY emulator matters. I take his Java code as reference in this matter.