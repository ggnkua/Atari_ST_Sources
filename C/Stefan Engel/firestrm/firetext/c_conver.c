#include "firetext.h"
/********************************************************************/
/********************************************************************/
void init_convertwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,CONVERT,&convert_win.dialog);
  strncpy(convert_win.w_name,alerts[W_CONVERT],MAXWINSTRING);
  convert_win.attr=NAME|MOVE;
  convert_win.icondata=NULL;
  convert_win.status=WINDOW_CLOSED;
  form_center(convert_win.dialog, &dummy, &dummy, &dummy, &dummy);
}
