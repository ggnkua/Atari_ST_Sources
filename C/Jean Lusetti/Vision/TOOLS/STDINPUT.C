#include <stddef.h>
#include <string.h>

#include "xgem.h"
#include "std.h"
/* Pour eviter #include "std.rsh" */
extern OBJECT *rs_trindex[] ;

OBJECT *stdinput ;


void stdinput_fix(void)
{
  stdinput = rs_trindex[FORM_INPUT] ;
  Xrsrc_obfix(stdinput, 0) ;
  Xrsrc_obfix(stdinput, INPUT_TITLE) ;
  Xrsrc_obfix(stdinput, INPUT_TEXT) ;
  Xrsrc_obfix(stdinput, INPUT_OK) ;
  Xrsrc_obfix(stdinput, INPUT_CANCEL) ;
}

void std_input(char *title, char *text, char *txt_cancel)
{
  int x, y, w, h ;
  int button ;

  if ( stdinput == NULL ) stdinput_fix() ;

  if ( txt_cancel != NULL ) strcpy( stdinput[INPUT_CANCEL].ob_spec.free_string, txt_cancel ) ;
  write_text(stdinput, INPUT_TEXT, "") ;
  write_text(stdinput, INPUT_TITLE, title) ;
  form_center(stdinput, &x, &y, &w, &h) ;
  form_dial(0, x, y, w, h, x, y, w, h) ;
  objc_draw(stdinput, 0, 200, x, y, w, h) ;
  button = form_do(stdinput, INPUT_TEXT) ;
  deselect(stdinput, button) ;
  form_dial(3, x, y, w, h, x, y, w, h) ;
  if (button == INPUT_OK) read_text(stdinput, INPUT_TEXT, text) ;
  else                    text[0] = 0 ;
}
