#ifndef __IBROWSER
#define __IBROWSER

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

#define VIBROWSER_CLASSNAME "CN_IBROWSER"

GEM_WINDOW* CreateImgBrowser(char *filename, char high_res) ;
int ObjectNotifyIBrowser(void* gw, int obj, void* external_call) ;
int ControlListIBrowser(GEM_WINDOW* wnd, char* data, char** cmds, short ncmds, short recurse) ;

#endif
