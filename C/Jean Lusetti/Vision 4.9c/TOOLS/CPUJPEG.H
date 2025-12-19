#ifndef __CPU_JPEG
#define __CPUJPEG

#ifndef __IMAGE_IO_H
#include "..\tools\image_io.h"
#endif

int cpu_jpeg_identify(char *nom, INFO_IMAGE *inf) ;
int cpu_jpeg_load(INFO_IMAGE *inf) ;
int cpu_jpeg_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog) ;


#endif