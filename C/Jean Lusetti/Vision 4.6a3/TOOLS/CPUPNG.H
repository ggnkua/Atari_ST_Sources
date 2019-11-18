#ifndef __CPU_PNG
#define __CPU_PNG

#ifndef __IMAGE_IO
#include "..\tools\image_io.h"
#endif

int cpu_png_identify(char *name, INFO_IMAGE *inf) ;
int cpu_png_load(INFO_IMAGE* inf) ;
int cpu_png_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog) ;
void cpu_png_terminate(void) ;

#endif