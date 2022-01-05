#ifndef __FSPAT_H
#define __FSPAT_H

#include "..\tools\gwindows.h"
#include "..\tools\spattern.h"

typedef struct _SPAT_PARMS
{
  int    type ;
  int    count_them ;
  int    wrap_around ;
  char   pattern[256] ;
  size_t pattern_size ;
}
SPAT_PARMS, *PSPAT_PARMS ;

int FormGetSPattern(SPAT_PARMS* params) ;

#endif