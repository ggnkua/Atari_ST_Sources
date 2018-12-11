#ifndef __IIINTERN_H
#define __IIINTERN_H

#include "gwindows.h"
#include "imgmodul.h"

typedef struct
{
  void (*GetDrvCaps)(INFO_IMAGE_DRIVER* caps) ;
  int  (*Identify)(char* name, INFO_IMAGE* inf) ;
  int  (*Load)(char* name, MFDB* out, GEM_WINDOW* wprog) ;
  int  (*Save)(char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog) ;
  void (*Terminate)(void) ; /* If necessary */
}
II_INTERNAL, *PII_INTERNAL ;



int iiinternal_init(IMG_MODULE* img_module, II_INTERNAL* ii_internal) ;


#endif
