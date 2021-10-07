unit hardware;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType;

const
  user_up = 0;
  user_down = 1;
  user_left = 2;
  user_right = 3;
  user_fire = 4;

  kempston_right = 0;
  kempston_left  = 1;
  kempston_down  = 2;
  kempston_up    = 3;
  kempston_fire  = 4;


procedure setKempston(n: byte);
procedure ResetKempston(n: byte);
procedure setSinclairLeft(n: byte);
procedure ResetSinclairLeft(n: byte);
procedure setSinclairRight(n: byte);
procedure ResetSinclairRight(n: byte);
procedure AssignUserButton(dir: byte; key: word);

var
    Kempston: byte = 0;
    SinclairRight: byte = $FF;
    SinclairLeft: byte = $FF;
    user_buttons: array[0..4,0..1] of byte;

implementation

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

