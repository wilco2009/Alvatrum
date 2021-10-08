unit hardware;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType,global;


procedure setKempston(n: byte);
procedure ResetKempston(n: byte);
procedure setSinclairLeft(n: byte);
procedure ResetSinclairLeft(n: byte);
procedure setSinclairRight(n: byte);
procedure ResetSinclairRight(n: byte);
procedure AssignUserButton(dir: byte; key: word);
function getdircaption(x: byte): string;

var
    Kempston: byte = 0;
    SinclairRight: byte = $FF;
    SinclairLeft: byte = $FF;
    user_buttons: tUser_buttons;

implementation

function getdircaption(x: byte): string;
var
    row,col: byte;
begin
  row := user_buttons[x,0];
  col := user_buttons[x,1];
  case row of
    0: begin
       case col of
         0: getdircaption := '↑';
         1: getdircaption := 'Z';
         2: getdircaption := 'X';
         3: getdircaption := 'C';
         4: getdircaption := 'V';
       end;
    end;
    1: begin
       case col of
         0: getdircaption := 'A';
         1: getdircaption := 'S';
         2: getdircaption := 'D';
         3: getdircaption := 'F';
         4: getdircaption := 'G';
       end;
    end;
    2: begin
       case col of
         0: getdircaption := 'Q';
         1: getdircaption := 'W';
         2: getdircaption := 'E';
         3: getdircaption := 'R';
         4: getdircaption := 'T';
       end;
    end;
    3: begin
       case col of
         0: getdircaption := '1';
         1: getdircaption := '2';
         2: getdircaption := '3';
         3: getdircaption := '4';
         4: getdircaption := '5';
       end;
    end;
    4: begin
       case col of
         0: getdircaption := '0';
         1: getdircaption := '9';
         2: getdircaption := '8';
         3: getdircaption := '7';
         4: getdircaption := '6';
       end;
    end;
    5: begin
       case col of
         0: getdircaption := 'P';
         1: getdircaption := 'O';
         2: getdircaption := 'I';
         3: getdircaption := 'U';
         4: getdircaption := 'Y';
       end;
    end;
    6: begin
       case col of
         0: getdircaption := '┘';
         1: getdircaption := 'L';
         2: getdircaption := 'K';
         3: getdircaption := 'J';
         4: getdircaption := 'H';
       end;
    end;
    7: begin
       case col of
         0: getdircaption := '⌂';
         1: getdircaption := 'M';
         2: getdircaption := 'N';
         3: getdircaption := 'B';
         4: getdircaption := 'V';
       end;
    end;
  end;
end;

procedure AssignUserButton(dir: byte; key: word);
begin
     case key of
       VK_SHIFT,VK_Z,VK_X,VK_C,VK_V: user_buttons[dir,0] := 0;
       VK_A,VK_S,VK_D,VK_F,VK_G: user_buttons[dir,0] := 1;
       VK_Q,VK_W,VK_E,VK_R,VK_T: user_buttons[dir,0] := 2;
       VK_1,VK_2,VK_3,VK_4,VK_5: user_buttons[dir,0] := 3;
       VK_0,VK_9,VK_8,VK_7,VK_6: user_buttons[dir,0] := 4;
       VK_P,VK_O,VK_I,VK_U,VK_Y: user_buttons[dir,0] := 5;
       VK_RETURN,VK_L,VK_K,VK_J,VK_H: user_buttons[dir,0] := 6;
       VK_SPACE,VK_MENU,VK_M,VK_N,VK_B: user_buttons[dir,0] := 7;
     end;

     case key of
       VK_SHIFT,VK_A,VK_Q,VK_1,VK_0,VK_P,VK_RETURN,VK_SPACE: user_buttons[dir,1] := 0;
       VK_Z,VK_S,VK_W,VK_2,VK_9,VK_O,VK_L,VK_MENU: user_buttons[dir,1] := 1;
       VK_X,VK_D,VK_E,VK_3,VK_8,VK_I,VK_K,VK_M: user_buttons[dir,1] := 2;
       VK_C,VK_F,VK_R,VK_4,VK_7,VK_U,VK_J,VK_N: user_buttons[dir,1] := 3;
       VK_V,VK_G,VK_T,VK_5,VK_6,VK_Y,VK_H,VK_B: user_buttons[dir,1] := 4;
     end;

end;

procedure setSinclairLeft(n: byte);
begin
     SinclairLeft := SinclairLeft and not (1 << n);
end;

procedure ResetSinclairLeft(n: byte);
begin
     SinclairLeft := SinclairLeft or (1 << n);
end;

procedure setSinclairRight(n: byte);
begin
     SinclairRight := SinclairRight and not (1 << n);
end;

procedure ResetSinclairRight(n: byte);
begin
     SinclairRight := SinclairRight or (1 << n);
end;

procedure setKempston(n: byte);
begin
     Kempston := Kempston or (1 << n);
end;

procedure ResetKempston(n: byte);
begin
     Kempston := Kempston and not (1 << n);
end;

begin
  Kempston := 0;
  fillchar(user_buttons, sizeof(user_buttons),0);
end.

