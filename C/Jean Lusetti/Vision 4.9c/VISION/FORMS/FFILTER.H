#ifndef __FFILTER
#define __FFILTER

#ifndef __GWINDOWS_H
#include "gwindows.h"
#endif

#if !defined(__CONVOLUTION)
#include "..\tools\convol.h"
#endif

int GetFilterPathForLanguage(char* path, short refresh) ;
int choose_filter(CONVOLUTION_FILTRE* filtre, GEM_WINDOW* gwnd) ;
void cleanup_filters(void) ;


#endif
