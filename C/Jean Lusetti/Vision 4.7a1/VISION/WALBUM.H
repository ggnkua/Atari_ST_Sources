#ifndef __WALBUM
#define __WALBUM

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

#ifndef __CATALOG
#include "..\tools\catalog.h"
#endif

#define MSG_WALB_REFRESH (WM_USER_FIRST+0)

GEM_WINDOW* album_window(HCAT hCat, GEM_WINDOW* wnd_album, GEM_WINDOW** pwnd) ;

#endif