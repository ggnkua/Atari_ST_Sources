{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                            EVENT LIBRARY DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program Events;

uses GemAES, GemVDI, GemDecl, GemInterface;

const
  Clicks        = 1;    { number of mouse clicks to wait for }
  Mask          = 3;    { left and right mouse buttons       }
  State         = Mask;

var
  key           : Integer;      { evnt_keybd key scan code      }
  s, s1         : String;       { multi-purpose                 }
  x, y          : Integer;      { mouse x,y coordinate          }
  buttons       : Integer;      { mouse button state            }
  keys          : Integer;      { keyboard state (ALT, CTRL etc)}
  times         : Integer;      { number of mouse clicks done   }
  speed         : Integer;      { double click speed            }

begin
  if Init_Gem then begin
    Message('Welcome to the event library demonstration!');

    Inform('We''re waiting for a keyboard event...');
    key := evnt_keybd;          { get scan code }
    Str(key, s);
    Message('The key''s scan code is : ' + s);

    Inform('Now we''re waiting for both mouse buttons...');
    graf_mouse(M_ON, NIL);
    times := evnt_button(Clicks, Mask, State, x, y, buttons, keys);
    graf_mouse(M_OFF, NIL);
    str(x, s);  str(y, s1);
    s := 'Mouse (x,y) = (' + s + ',' + s1 + ')';
    Message(s);

    Message('Please use the mouse to click "Ok" now!');
    Inform('Try to enter the Output window');
    OpenOutputWindow;
    graf_mouse(M_ON, NIL);
    with OutputWindow do
      evnt_mouse(0, wX, wY, wW, wH, x, y, buttons, keys);
    graf_mouse(M_OFF, NIL);
    CloseOutputWindow;
    str(x, s);  str(y, s1);
    s := 'You entered the work area at (x,y) = (' + s + ',' + s1 + ')';
    Message(s);

    Inform('Hang on 1.234 seconds!');
    evnt_timer(LoWord(1234), HiWord(1234));

    Message('We''re back!');
    Message('Now we''ll determine the mouse double click speed');
    speed := evnt_dclick(0, 0);
    case speed of
      0 : s := 'slow';
      1 : s := 'below medium';
      2 : s := 'medium';
      3 : s := 'above medium';
      4 : s := 'fast'
    else
      s := 'Should never come here!'
    end;
    Message('The double click speed is "' + s + '"');
    Message('That''s all folks!');

    Exit_Gem
  end
end.
