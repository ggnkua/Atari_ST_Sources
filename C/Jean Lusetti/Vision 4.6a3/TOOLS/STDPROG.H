#ifndef __STDPROG
#define __STDPROG

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

GEM_WINDOW* DisplayStdProg(char* t1, char* t2, char* t3, int nflags) ;
void        StdProgWText(GEM_WINDOW* wnd, int num, char *text) ;
void        StdProgDisplayDSP(GEM_WINDOW* wnd, int display) ;
void        StdProgDisplay030(GEM_WINDOW* wnd, int display) ;
void        StdProgDisplayFPU(GEM_WINDOW* wnd, int display) ;

#endif