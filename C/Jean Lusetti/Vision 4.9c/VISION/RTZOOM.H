#ifndef __RTZOOM_H
#define __RTZOOM_H

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

extern char RTZoomDisable ;

#define RTZOOM_CLASSNAME "CN_RTZOOM"

int  rtzoom_init(void) ;
void rtzoom_free(void) ;
void rtzoom_display(int mx, int my, int from_screen) ;
void paint_rtzoom(int rtx, int rty, int rtw, int rth) ;
void rtzoom_change_level(int new_level) ;
int  pref_rtzoom(void) ;


#endif
