#ifndef __RTZOOM
#define __RTZOOM

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

#if !defined(__VDI__)
#include <vdi.h>
#endif

extern int  rtx, rty, rtw, rth ;
extern char RTZoomDisable ;

#define RTZOOM_CLASSNAME "CN_RTZOOM"
GEM_WINDOW* RTZoomCreateWindow(void) ;

int  rtzoom_init(void) ;
void rtzoom_free(void) ;
void rtzoom_display(int mx, int my, int from_screen) ;
void paint_rtzoom(int rtx, int rty, int rtw, int rth) ;
void rtzoom_change_level(int new_level) ;
int pref_rtzoom(void) ;


#endif
