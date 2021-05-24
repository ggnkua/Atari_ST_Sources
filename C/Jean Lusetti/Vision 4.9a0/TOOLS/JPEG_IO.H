/***********************/
/* Header de JPEG_IO.C */
/***********************/
#if !defined (__JPEG_H)
#define __JPEG_H

#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

int  jpeg_identify(char *nom, INFO_IMAGE *inf) ;
int  jpeg_load(INFO_IMAGE *inf) ;
int  jpeg_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog) ;
void jpeg_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;

#endif
