#ifndef __FLDV
#define __FLDV

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

#ifndef __LDVCOM
#include "..\ldv\ldvcom.h"
#endif

LDV_CAPS   *LDVGetNPlanesCaps(LDV_MODULE *mod, int nplanes) ;
LDV_MODULE *LDVSelect(GEM_WINDOW *wnd) ; 

void       LDVFreeAllModules(void) ;
void       LDVTerminate(LDG *ldg) ;


#endif
