#ifndef __FFILTER
#define __FFILTER

#ifndef __GWINDOWS
#include "gwindows.h"
#endif

#if !defined(__CONVOLUTION)
#include "..\tools\convol.h"
#endif

int GetFilterPathForLanguage(char *path) ;
int choose_filter(CONVOLUTION_FILTRE *filtre, GEM_WINDOW *gwnd) ;
void cleanup_filters(void) ;


#endif
