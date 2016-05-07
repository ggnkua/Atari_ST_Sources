{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                                GRAF DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program Graf_Demo;

uses GemInterface, GemDecl, GemAES, GemVDI;

const
  MinWidth      = 0;            { smallest width of rubber box  }
  MinHeight     = 0;            { smallest height of rubber box }

var
  mouseButton   : integer;      { mouse button state            }
  mouseX        : integer;      { mouse X pos                   }
  mouseY        : integer;      { mouse Y pos                   }
  KbdState      : integer;      { kbd CTRL, SHIFT, ALT state    }
  endW          : integer;      { end width of rubber box       }
  endH          : integer;      { end height of rubber box      }

{ Set up our own mouse shape }
procedure SetOurOwnMouse;
var
  shape : Array_37;             { structure holding the mouse shape     }
begin
  shape[ 0] := 0;                            { hot spot = (0, 0)        }
  shape[ 1] := 0;
  shape[ 2] := 1;                            { must be so!              }
  shape[ 3] := Black;                        { use black for mouse      }
  shape[ 4] := Black;                        { use black for mask       }
  shape[ 5] := Binary('00000000 00000000');  { mouse shape :            }
  shape[ 6] := Binary('01110111 00011100');  { you can change it        }
  shape[ 7] := Binary('00100010 00001000');  { yourself if you want     }
  shape[ 8] := Binary('00100010 00001000');  { 1 = set pixel ;          }
  shape[ 9] := Binary('00100010 00001000');  { 0 = clear pixel          }
  shape[10] := Binary('00100010 00001000');
  shape[11] := Binary('00100010 00001000');
  shape[12] := Binary('00111110 00001000');
  shape[13] := Binary('00100010 00001000');
  shape[14] := Binary('00100010 00001000');
  shape[15] := Binary('00100010 00001000');
  shape[16] := Binary('00100010 00001000');
  shape[17] := Binary('00100010 00001000');
  shape[18] := Binary('00100010 00001000');
  shape[19] := Binary('01110111 00011100');
  shape[20] := Binary('00000000 00000000');

  shape[21] := Binary('00000000 00000000');  { the mask : }
  shape[22] := Binary('00000000 00000000');
  shape[23] := Binary('00000000 00000000');
  shape[24] := Binary('00000000 00000000');
  shape[25] := Binary('00000000 00000000');
  shape[26] := Binary('00000000 00000000');
  shape[27] := Binary('00000000 00000000');
  shape[28] := Binary('00000000 00000000');
  shape[29] := Binary('00000000 00000000');
  shape[30] := Binary('00000000 00000000');
  shape[31] := Binary('00000000 00000000');
  shape[32] := Binary('00000000 00000000');
  shape[33] := Binary('00000000 00000000');
  shape[34] := Binary('00000000 00000000');
  shape[35] := Binary('00000000 00000000');
  shape[36] := Binary('00000000 00000000');

  graf_mouse(USER_DEF, @shape)                  { set the shape!        }
end;

procedure WaitForLeftButton;
begin
  repeat
    graf_mkstate(mouseX, mouseY, mouseButton, KbdState)
  until mouseButton = 1
end;

{ Move (drag) a rectangle within another rectangle }
procedure MoveRectangle;
var
  x, y : integer;       { moved rectangle's end x,y }
begin
  OpenOutputWindow;
  Inform('Press left mouse button :');
  graf_mouse(M_ON, NIL);
  WaitForLeftButton;
  graf_mouse(M_OFF, NIL);
  Inform('Move the small rectangle :');
  graf_mouse(M_ON, NIL);
  with OutputWindow do
    graf_dragbox(50, 20,                          { small rect w, h       }
                 MouseX, MouseY,                  { start x, y            }
                 wX, wY,                          { big rect x, y         }
                 wW, wH,                          { big rect w, h         }
                 x, y);                           { small's end x, y      }
  graf_mouse(M_OFF, NIL);
  CloseOutputWindow
end;

begin { main }
  if Init_Gem then begin
    Message('Welcome to the Graf library demonstration!');
    Message('You know the growing box?');
    graf_growbox( MinX + (MaxW - 20) div 2,     { start x        }
                  MinY + (MaxH - 20) div 2,     { start y        }
                  40, 40,                       { start w, h     }
                  MinX, MinY, MaxW, MaxH );     { end x, y, w, h }

    Message('We can shrink it too...');
    graf_shrinkbox( MinX + (MaxW - 20) div 2, MinY + (MaxH - 20) div 2, 40, 40,
                    MinX, MinY, MaxW, MaxH );
    { note that the parameter order is the same as graf_growbox }

    Message('and move boxes around the screen fastly...');
    graf_movebox(30, 30,                        { w, h          }
                 MinX, MinY,                    { start x,y     }
                 MaxX - 50, MaxY - 50);         { end x,y       }

    Message('We can change the appearance of the mouse...');
    graf_mouse(POINT_HAND, NIL);

    Message('and set our own...');
    SetOurOwnMouse;

    Message('but we like the familiar arrow more, don''t we?');
    graf_mouse(ARROW, NIL);

    Inform('Let''s do a rubber box :');
    graf_mouse(M_ON, NIL);              { turn mouse on         }
    WaitForLeftButton;
    graf_rubbox(mouseX, mouseY, MinWidth, MinHeight, endW, endH);
    graf_mouse(M_OFF, NIL);             { turn mouse off        }

    MoveRectangle;

    Message('That''s all folks!');

    Exit_Gem
  end
end.
