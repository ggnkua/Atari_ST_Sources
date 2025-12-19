#ifndef __DITHER16_H
#define __DITHER16_H

#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

int _dither16(short alg_msize, MFDB* img16, INFO_IMAGE* inf_out, GEM_WINDOW* wprog) ;
int dither16(short alg_msize, INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog) ;


#endif
