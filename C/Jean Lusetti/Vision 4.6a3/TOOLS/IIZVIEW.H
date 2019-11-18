#ifndef __IIZVIEW_H
#define __IIZVIEW_H

#include "zvlight.h"
#include "iizvldg.h"
#include "imgmodul.h"

typedef struct
{
  ZVIMGINFO ImgInfo ;
  char      must_call_reader_quit ;
  char      must_call_encoder_quit ;
  char      lib_name[32] ;

  /* zView pluging interface  */
  /* Always check ImgModule->hLib before calling any of these  */
  /* As caller may have unloaded the module without any notice */
  /* This is the general interface (not LDG nor SLB dependent) */
  /* That iizvieww_... internal routines will call             */
  /* There is no ISlb interface as SLB function pointers are   */
  /* not accessible directly but calls go through SlbExec call */
  unsigned long (*plugin_init)(IMG_MODULE* img_module) ;
  unsigned long (*reader_init)(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info) ;
  unsigned long (*reader_read)(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer) ;
  void          (*reader_get_txt)(IMG_MODULE* img_module, ZVIMGINFO* info, txt_data* txtdata) ;
  void          (*reader_quit)(IMG_MODULE* img_module, ZVIMGINFO* info) ;
  unsigned long (*encoder_init)(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info) ;
  unsigned long (*encoder_write)(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer) ;
  void          (*encoder_quit)(IMG_MODULE* img_module, ZVIMGINFO* info) ;

  ZV_ILDG       ILdg ; /* LDG interface */
}
ZVIEW_SPECIFIC, *PZVIEW_SPECIFIC ;


short iizview_init(char type, IMG_MODULE* img_module) ; /* Fill in IMG_MODULE structure */
long  iizview_GetIID(char* infos) ;

#endif
