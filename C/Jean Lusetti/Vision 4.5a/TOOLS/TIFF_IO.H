/***********************/
/* Header de TIFF_IO.C */
/***********************/
#if !defined(__TIFF)
#define __TIFF

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif


#define MOTOROLA 0x4D4D
#define INTEL    0x4949


int  tiff_load(char *name, MFDB *out, GEM_WINDOW *wprog) ;
int  tiff_identify(char *nom, INFO_IMAGE *inf) ;
int  tiff_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog) ;
void tiff_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;


#endif
