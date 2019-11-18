#ifndef __IIZVLDG_H
#define __IIZVLDG_H

#include "imgmodul.h"
#include "zvlight.h"

typedef struct
{
  void          cdecl (*plugin_init)(void) ;
  unsigned long cdecl (*reader_init)(const char* name, ZVIMGINFO* info) ;
  unsigned long cdecl (*reader_read)(ZVIMGINFO* info, unsigned char* buffer) ;
  void          cdecl (*reader_get_txt)(ZVIMGINFO* info, txt_data* txtdata) ;
  void          cdecl (*reader_quit)(ZVIMGINFO* info) ;
  unsigned long cdecl (*encoder_init)(const char* name, ZVIMGINFO* info) ;
  unsigned long cdecl (*encoder_write)(ZVIMGINFO* info, unsigned char* buffer) ;
  void          cdecl (*encoder_quit)(ZVIMGINFO* info) ;
}
ZV_ILDG, *PZVILDG ;


short iizvldg_init(IMG_MODULE* img_module) ; /* Fill in IMG_MODULE structure */
void iizviewLDG_GetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps) ;

#endif
