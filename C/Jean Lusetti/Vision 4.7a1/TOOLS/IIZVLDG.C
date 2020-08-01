/*********************************************************************************/
/* IIZVSLB.C: wrapper for exposing LDI interface from ZVIEW SLB plugin interface */
/*********************************************************************************/
#include <string.h>
#include <stdlib.h>

#include "xalloc.h"
#include "imgmodul.h"
#include "logging.h"
#include "iizview.h"
#include "zvlight.h"

static unsigned long iizv_ldg_plugin_init(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG plugin_init...") ;
  zvdata->ILdg.plugin_init() ; /* No return value, assume success */

  return 1 ;
}

static unsigned long iizv_ldg_reader_init(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG reader_init...") ;
  return zvdata->ILdg.reader_init( name, info ) ;
}

static unsigned long iizv_ldg_reader_read(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_TMP1, "Calling LDG reader_read...") ; /* LL_DEBUG would be too much here */
  return zvdata->ILdg.reader_read( info, buffer ) ;
}

static void iizv_ldg_reader_get_txt(IMG_MODULE* img_module, ZVIMGINFO* info, txt_data* txtdata)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG reader_get_txt...") ;
  zvdata->ILdg.reader_get_txt( info, txtdata ) ;
}

static void iizv_ldg_reader_quit(IMG_MODULE* img_module, ZVIMGINFO* info)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG reader_quit...") ;
  zvdata->ILdg.reader_quit( info ) ;
}

static unsigned long iizv_ldg_encoder_init(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG encoder_init...") ;
  return zvdata->ILdg.encoder_init( name, info ) ;
}

static unsigned long iizv_ldg_encoder_write(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG encoder_write...") ;
  return zvdata->ILdg.encoder_write( info, buffer ) ;
}

static void iizv_ldg_encoder_quit(IMG_MODULE* img_module, ZVIMGINFO* info)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG encoder_quit...") ;
  zvdata->ILdg.encoder_quit( info ) ;
}

void iizviewLDG_GetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  LDG*            Ldg = ImgModule->hLib ;
  int             ke_size ;
  char*           c, *d ;
  char            lib_name[32] ;

  strncpy( lib_name, zvdata->lib_name, sizeof(lib_name) ) ;
  c = strrchr( lib_name, '.' ) ;
  if ( c ) *c = 0 ; /* Remove extension */
  caps->iid = iizview_GetIID( Ldg->infos ) ;
  strcpy( caps->short_name, lib_name ) ;
  memcpy( caps->file_extension, Ldg->infos, 3 ) ;
  caps->file_extension[3] = 0 ;
  strcpy( caps->name, lib_name ) ;
  caps->version = Ldg->vers ;

  /* There are no capabilities returned by zView LDG plugin interface,    */
  /* Let's assume all of them after sanity checks to not prevent anything */
  caps->import = caps->export = 0 ;
  if ( zvdata->ILdg.reader_init && zvdata->ILdg.reader_read && zvdata->ILdg.reader_quit )
    caps->import = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

  if ( zvdata->ILdg.encoder_init && zvdata->ILdg.encoder_write && zvdata->ILdg.encoder_quit )
    caps->export = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

  c       = Ldg->infos ;
  d       = caps->known_extensions ;
  ke_size = (int) sizeof(caps->known_extensions) ;
  while ( *c && (ke_size > 4) ) /* 5 bytes at least must be free (3 for ext, 1 for \0 of ext and one for \0 terminating strings */
  {
    /* e.g. JPGJPE--> JPG\0JPE\0\0*/
    *d++ = *c++ ;
    *d++ = *c++ ;
    *d++ = *c++ ;
    *d++ = 0 ;
    ke_size -= 4 ;
  }
  *d++ = 0 ;
}

short iizvldg_init(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  zvdata->ILdg.plugin_init = ldg_find( "plugin_init", img_module->hLib ) ;
  if ( !zvdata->ILdg.plugin_init ) return EIMG_MODULERROR ;

  zvdata->ILdg.reader_init    = ldg_find( "reader_init",    img_module->hLib ) ;
  zvdata->ILdg.reader_read    = ldg_find( "reader_read",    img_module->hLib ) ;
  zvdata->ILdg.reader_get_txt = ldg_find( "reader_get_txt", img_module->hLib ) ;
  zvdata->ILdg.reader_quit    = ldg_find( "reader_quit",    img_module->hLib ) ;
  zvdata->ILdg.encoder_init   = ldg_find( "encoder_init",   img_module->hLib ) ;
  zvdata->ILdg.encoder_write  = ldg_find( "encoder_write",  img_module->hLib ) ;
  zvdata->ILdg.encoder_quit   = ldg_find( "encoder_quit",   img_module->hLib ) ;

  zvdata->plugin_init    = iizv_ldg_plugin_init ;
  zvdata->reader_init    = iizv_ldg_reader_init ;
  zvdata->reader_read    = iizv_ldg_reader_read ;
  zvdata->reader_get_txt = iizv_ldg_reader_get_txt ;
  zvdata->reader_quit    = iizv_ldg_reader_quit ;
  zvdata->encoder_init   = iizv_ldg_encoder_init ;
  zvdata->encoder_write  = iizv_ldg_encoder_write ;
  zvdata->encoder_quit   = iizv_ldg_encoder_quit ;

  return EIMG_SUCCESS ;
}