#ifndef __STDMLINES
#define __STDMLINES

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif
#include "..\tools\std.h"

#define MLP_NLINES  (1+MLINES_LASTMSG-MLINES_FIRSTMSG)
#define MLP_LINEMAX 128

typedef struct
{
  char mesg[MLP_NLINES][MLP_LINEMAX] ;
  char title[64] ;
  char ok_caption[16] ;
  char cancel_caption[16] ;
  char read_only ;
}
MLINES_PARAMS ;

int FormStdMLines(MLINES_PARAMS *params) ;

#endif