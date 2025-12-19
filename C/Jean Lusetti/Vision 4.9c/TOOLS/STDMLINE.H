#ifndef __STDMLINES_H
#define __STDMLINES_H

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif
#include "..\tools\std.h"

#define MLP_NLINES  (1+MLINES_LASTMSG-MLINES_FIRSTMSG)
#define MLP_LINEMAX 128

typedef struct
{
  char  mesg[MLP_NLINES][MLP_LINEMAX] ;
  char  title[64] ;
  char  ok_caption[16] ;
  char  cancel_caption[16] ;
  char  templates_caption[16] ;
  char  templates_filemask[256] ;
  unsigned int read_only:1 ;
  unsigned int show_alllines:1 ;
  unsigned int rfu:14 ;
}
MLINES_PARAMS ;

int FormStdMLines(MLINES_PARAMS *params) ;

#endif