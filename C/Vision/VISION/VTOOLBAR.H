#ifndef __VTOOLBAR
#define __VTOOLBAR

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

extern GEM_WINDOW *WndToolBar ;
extern OBJECT     *adr_icones ;

#define VTOOLBAR_CLASSNAME  "CN_VTOOLBAR"
GEM_WINDOW *VToolBarCreateWindow(void) ;
void VToolBarInit(int haute_resolution) ;
void VToolBarUpdate(char *flags) ;
void VToolBarShow(int show) ;

#endif
