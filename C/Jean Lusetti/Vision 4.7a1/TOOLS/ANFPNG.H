#ifndef __ANF_PNG
#define __ANF_PNG

#ifndef __IMAGE_IO
#include "..\tools\image_io.h"
#endif

int anf_png_identify(char *name, INFO_IMAGE *inf) ;
int anf_png_load(INFO_IMAGE* inf) ;
int anf_png_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog) ;


#endif