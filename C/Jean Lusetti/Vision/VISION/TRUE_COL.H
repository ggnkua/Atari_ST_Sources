#ifndef __TRUECOL
#define __TRUECOL

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

void make_tcpal(unsigned char *rpal, unsigned char *vpal, unsigned char *bpal, GEM_WINDOW *gwnd) ;
void screen_tcpal(unsigned char *tcrpal, unsigned char *tcvpal, unsigned char *tcbpal, GEM_WINDOW *gwnd) ;

#endif
