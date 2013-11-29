#ifndef __FASTZOOM
#define __FASTZOOM

#if !defined(__VDI__)
#include <vdi.h>
#endif


typedef struct
{
  MFDB *src ;
  MFDB *dst ;
  int  zoom ;
  MFDB *std_src ;
  MFDB *std_dst ;
}
FZOOM_DATA ;


int  init_fztab(int zoom) ;
int  FastZoom(FZOOM_DATA *data) ;
void terminate_fztab(void) ;
int  FZNeedStdFormat(int nplanes) ;


#endif
