{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                             FORM LIBRARY DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program Forms;

uses GemAES, GemVDI, GemDecl, GemInterface;

var
  x, y, w, h    : Integer;      { message box' centered position }
  smallX,
  smallY,
  smallW,
  smallH        : Integer;      { reduced x, y, w, h values     }
  button        : Integer;      { return value from form_alert  }
  msg           : String;       { form_alert message string     }

begin
  if Init_Gem then begin
    Message('Welcome to the Form library demonstration!');

    Message('First, we''ll look at an alert box');
    msg := '[2][ | Nice, isn''t it? ][ Yeah | Oh no! ]'#0;
    button := form_alert(1, msg[1]);    { the "Yeah" button is default }

    Message('then at an error box');
    button := form_error(1);            { error code is 1 }

    Message('Why don''t we center this box on the screen?');
    form_center(GemInterface.MessageBox, x, y, w, h);
    Inform('');                         { redraw frame rectangle }
    Message('How about that!');

    Message('Now, we''ll redo this dialog with the help');
    Message('of form_dial and form_do');
    Message('This message will be redone!');

    { the OK button from the message box must be deselected before }
    { we activate the dialog box again; otherwise it will be drawn }
    { in a selected state. You can try to comment the following    }
    { line out to see the difference :                             }
    GemInterface.MessageBox^[OKBUTTON].ob_state := NORMAL;

    smallX := x + w div 2;      { set up small representation of }
    smallY := y + h div 2;      { the message box                }
    smallW := w div 2;
    smallH := h div 2;

    { first, we reserve memory space for the image of the border }
    { of the box : }
    form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);

    { then we draw a growing rectangle (the one from the desktop) }
    form_dial(FMD_GROW, smallX, smallY, smallW, smallH, x, y, w, h);

    { after that, we draw the dialog box on the screen }
    objc_draw(GemInterface.MessageBox, FRAMEBOX, $7FFF, 0, 0, 0, 0);

    { so now we're ready to do the dialog }
    graf_mouse(M_ON, NIL);
    button := form_do(GemInterface.MessageBox, -1);
    graf_mouse(M_OFF, NIL);

    { after that's completed, we draw the shrinking box }
    form_dial(FMD_SHRINK, smallX, smallY, smallW, smallH, x, y, w, h);

    { and restore the border area image from memory }
    form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

    Inform('');                         { redraw frame rectangle }
    Message('That''s all folks!');
    Exit_Gem
  end
end.
