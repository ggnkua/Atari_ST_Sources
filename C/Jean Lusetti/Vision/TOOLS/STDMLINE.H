#ifndef __STDMLINES
#define __STDMLINES

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif
#include "..\tools\std.h"


typedef struct
{
  char msg[1+MLINES_LASTMSG-MLINES_FIRSTMSG][60] ;
  char ok_button ;
  char cancel_button ;
}
MLINES_PARAMS ;

GEM_WINDOW *DisplayStdMLines(MLINES_PARAMS *params) ;

#endif