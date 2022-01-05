/*******************/
/* PNG_IO.C Header */
/*******************/
#if !defined (__PNG)
#define __PNG

#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

int  png_identify(char *name, INFO_IMAGE *inf) ;
int  png_load(INFO_IMAGE* inf) ;
int  png_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog) ;
void png_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;
void png_terminate(void) ;

#endif
