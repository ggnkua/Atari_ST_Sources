#ifndef __IIZVLDG_H
#define __IIZVLDG_H

#include "imgmodul.h"
#include "zvlight.h"

typedef struct
{
  /* This is the LDG interface exposed by legacy zView plugins, returned values are: */
  /* 1: OK                                                                           */
  /* 0: Error, extended error may be provided by thumail field if not 0              */
  /* Note that if the module is IM, returned values are: */
  /* 0: OK                                                                           */
  /* Anything else is an error code                                                  */
  void cdecl (*plugin_init)(void) ;
  long cdecl (*reader_init)(const char* name, ZVIMGINFO* info) ;
  long cdecl (*reader_read)(ZVIMGINFO* info, unsigned char* buffer) ;
  void cdecl (*reader_get_txt)(ZVIMGINFO* info, txt_data* txtdata) ;
  void cdecl (*reader_quit)(ZVIMGINFO* info) ;
  long cdecl (*encoder_init)(const char* name, ZVIMGINFO* info) ;
  long cdecl (*encoder_write)(ZVIMGINFO* info, unsigned char* buffer) ;
  void cdecl (*encoder_quit)(ZVIMGINFO* info) ;
}
ZV_ILDG, *PZVILDG ;


short iizvldg_init(IMG_MODULE* img_module) ; /* Fill in IMG_MODULE structure */
void  iizviewLDG_GetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps) ;

#endif
