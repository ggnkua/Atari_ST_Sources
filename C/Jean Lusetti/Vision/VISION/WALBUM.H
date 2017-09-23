#ifndef __WALBUM
#define __WALBUM

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

void album_window(void) ;

extern GEM_WINDOW *WndAlbum ;
#define VWALB_CLASSNAME  "CN_VWALBUM"
GEM_WINDOW *VWAlbCreateWindow(void) ;

#endif