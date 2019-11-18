#ifndef __DSP_JPEG
#define __DSP_JPEG

#ifndef __XGEM
#include  "..\tools\xgem.h"
#endif

#ifndef __IMAGE_IO
#include  "..\tools\image_io.h" /* Pour INFO_IMAGE */
#endif

int dsp_jpeg_identify(char *nom, INFO_IMAGE *inf) ;
int dsp_jpeg_load(INFO_IMAGE *inf) ;
void dsp_jpeg_getdrvcaps(INFO_IMAGE_DRIVER *caps) ;


#endif
