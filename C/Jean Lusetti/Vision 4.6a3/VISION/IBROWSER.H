#ifndef __IBROWSER
#define __IBROWSER

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

GEM_WINDOW *CreateImgBrowser(char *filename, char high_res) ;
int ObjectNotifyIBrowser(void *gw, int obj, void* external_call) ;

#endif
