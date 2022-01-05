#ifndef __VTOOLBAR
#define __VTOOLBAR

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

extern GEM_WINDOW* WndToolBar ;
extern OBJECT     *adr_icones ;

#define VTOOLBAR_CLASSNAME  "CN_VTOOLBAR"
void VToolBarInit(char high_res) ;
void VToolBarUpdate(char *flags) ;
void VToolBarShow(int show) ;

#endif
