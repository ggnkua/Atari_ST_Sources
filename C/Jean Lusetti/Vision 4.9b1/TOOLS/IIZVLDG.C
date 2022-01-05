/***************************************************************************************/
/* IIZVSLB.C: wrapper for exposing LDI interface from ZVIEW LDG or IM plugin interface */
/***************************************************************************************/
#include <string.h>
#include <stdlib.h>

#include "xalloc.h"
#include "imgmodul.h"
#include "logging.h"
#include "iizview.h"
#include "zvlight.h"

/* Retturned by main() if IM module */
typedef struct _IM_INFOS
{
  long  InfoID ;                                                        /* +0   'GB32' */
  short InfoVersion ;                                                   /* +4   plugin version 0x0100 -> 1.00*/
  short InfoFlags ;                                                     /* +6   bit field, see below */
  char* Extensions ;                                                    /* +8   list of file extensions */
  long  InfoFormat ;                                                    /* +12  plugin format */
  char* InfoAuthor ;                                                    /* +16  author name */
  void* InfoMisc ;                                                      /* +20  misc extra info */
  long  InfoTimestamp ;                                                 /* +24  build data */
  void cdecl (*plugin_init)(void) ;                                     /* +28  plugin_init */
  void cdecl (*libshare_exit)(void) ;                                   /* +32  libshare_exit (optional) */
  long cdecl (*reader_init)(const char* name, ZVIMGINFO* info) ;        /* +36  reader_init */
  long cdecl (*reader_read)(ZVIMGINFO* info, unsigned char* buffer) ;   /* +40  reader_read */
  void cdecl (*reader_quit)(ZVIMGINFO* info) ;                          /* +44  reader_quit */
  void cdecl (*reader_get_txt)(ZVIMGINFO* info, txt_data* txtdata) ;    /* +48  reader_get_txt */
  long cdecl (*encoder_init)(const char* name, ZVIMGINFO* info) ;       /* +52  encoder_init */
  long cdecl (*encoder_write)(ZVIMGINFO* info, unsigned char* buffer) ; /* +56  encoder_write */
  void cdecl (*encoder_quit)(ZVIMGINFO* info) ;                         /* +60  encoder_quit */
  void cdecl (*encoder_option)(void) ;                                  /* +64  encoder_option (optional), watch out for parameters */
}
IM_INFOS, *PIM_INFOS ;


static int xzview_err(short zverr_ext)
{
  /* Call this function only if zView plugin returned an error (0 from reader_init or reader_read) */
  /* From Lonny's idea to get zView error code instead of the simple success/error                 */
  int   ret = EIMG_MODULERROR ; /* No more detail available */
  short i ;

  if ( zverr_ext >= 10 )
  {
    /* zView plugin has extended error code available  */
    /* Let's map it to an existing IMAGE_IO error code */
    char zview_errext[] = { EC_ResolutionType, EC_ImageType, EC_PixelDepth, EC_ColorMapDepth, EC_ColorMapType, EC_HeaderLength, EC_ColorSpace, EC_ColorMapLength,
                            EC_MaskType, EC_ChunkId, EC_ColorCount, EC_HeaderVersion, EC_HeightSmall, EC_FileId, EC_OrientationBad,
                            EC_Fread, EC_FileLength, EC_WidthNegative, EC_HeightNegative, EC_FileType, EC_FrameCount, EC_BitmapLength, EC_CompLength, EC_StructLength,
                            EC_OpenDriverJPD, EC_GetImageInfoJPD, EC_GetImageSizeJPD, EC_DecodeImageJPD,
                            EC_CompType, EC_Malloc, EC_Fopen, EC_DecompError, EC_RequiresJPD } ;
    char image_io_err[] = { EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED,
                            EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, EIMG_OPTIONNOTSUPPORTED, 
                            EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT,
                            EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, EIMG_DATAINCONSISTENT, 
                            EIMG_UNKNOWNCOMPRESSION, EIMG_NOMEMORY, EIMG_FILENOEXIST, EIMG_DECOMPRESERR, EIMG_NOJPEGDRIVER } ;

    for ( i = 0; (ret == EIMG_MODULERROR) && (i < ARRAY_SIZE(zview_errext)); i++ )
      if ( zverr_ext == zview_errext[i] ) ret = image_io_err[i] ;
  }

  LoggingDo(LL_INFO, "zView extended error %d mapped to %d", zverr_ext, ret ) ;

  return ret ;
}

void utest_xzview_err(void)
{
  ZVIMGINFO zvinf ;

  for ( zvinf.thumbnail = -10; zvinf.thumbnail <= EC_FuncNotDefined; zvinf.thumbnail++ )
    LoggingDo(LL_INFO, "zverr %d --> VISION err %d", zvinf.thumbnail, xzview_err( zvinf.thumbnail ) ) ;
}

static long iizv_ldg_plugin_init(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG plugin_init...") ;
  zvdata->ILdg.plugin_init() ; /* No return value, assume success */

  return EIMG_SUCCESS ;
}

static long xstatus(short type, ZVIEW_SPECIFIC* zvdata, long status)
{
  if ( type == MST_ZVLDG )
  {
    /* Extended zView error is reported in thumbnail field        */
    /* If module supports extended error defined by Lonny Pursell */
    /* Else (legacy zView format) thumbnail is still 0            */
    if ( status == 0 ) status = xzview_err( zvdata->ImgInfo.thumbnail ) ;
    else               status = 0 ;
  }
  else if ( (type == MST_IMGMOD) && (status != 0) )
    status = xzview_err( (short)status ) ;

  return status ;
}

static long iizv_ldg_reader_init(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG reader_init...") ;
  info->thumbnail = 0 ; /* For zView extended error reporting */

  return xstatus( img_module->Type, zvdata, zvdata->ILdg.reader_init( name, info ) ) ;
}

static long iizv_ldg_reader_read(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_TMP1, "Calling LDG reader_read...") ; /* LL_DEBUG would be too much here */
  info->thumbnail = 0 ; /* For zView extended error reporting */

  return xstatus( img_module->Type, zvdata, zvdata->ILdg.reader_read( info, buffer ) ) ;
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

static long iizv_ldg_encoder_init(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG encoder_init...") ;

  return xstatus( img_module->Type, zvdata, zvdata->ILdg.encoder_init( name, info ) ) ;
}

static long iizv_ldg_encoder_write(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  LoggingDo(LL_DEBUG, "Calling LDG encoder_write...") ;

  return xstatus( img_module->Type, zvdata, zvdata->ILdg.encoder_write( info, buffer ) ) ;
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
  char*           c ;
  char*           d ;
  char            lib_name[32] ;
  short           ke_size = (short) sizeof(caps->known_extensions) ;

  strncpy( lib_name, zvdata->lib_name, sizeof(lib_name) ) ;
  c = strrchr( lib_name, '.' ) ;
  if ( c ) *c = 0 ; /* Remove extension */
  strcpy( caps->short_name, lib_name ) ;
  strcpy( caps->name, lib_name ) ;

  if ( ImgModule->Type == MST_ZVLDG )
  {
    LDG*  Ldg = ImgModule->hLib ;

    caps->iid = iizview_GetIID( Ldg->infos ) ;
    memcpy( caps->file_extension, Ldg->infos, 3 ) ;
    caps->file_extension[3] = 0 ;
    caps->version = Ldg->vers ;

    c = Ldg->infos ;
    d = caps->known_extensions ;
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
  else if ( ImgModule->Type == MST_IMGMOD )
  {
    IM_INFOS* ImInfos = zvdata->IMInfos ;

    caps->iid = iizview_GetIID( ImInfos->Extensions ) ;
    memcpy( caps->file_extension, ImInfos->Extensions, 3 ) ;
    caps->file_extension[3] = 0 ;
    caps->version           = ImInfos->InfoVersion ;

    c = ImInfos->Extensions ;
    d = caps->known_extensions ;
    while ( *c && (ke_size > 5) ) /* 6 bytes at least must be free (3 for ext, 1 for \0 of ext and one for \0 terminating strings */
    {
      /* e.g. JPG JPE JPEG--> JPG\0JPE\0JPEG\0\0*/
      *d++ = *c++ ;
      *d++ = *c++ ;
      *d++ = *c++ ;
      if ( *c != ' ' ) { *d++ = *c ; ke_size-- ; }
      c++ ;
      *d++ = 0 ;
      ke_size -= 4 ;
    }
    *d++ = 0 ;
  }

  /* Common to LDG and IM interfaces                                      */
  /* There are no capabilities returned by zView LDG plugin interface,    */
  /* Let's assume all of them after sanity checks to not prevent anything */
  caps->import = caps->export = 0 ;
  if ( zvdata->ILdg.reader_init && zvdata->ILdg.reader_read && zvdata->ILdg.reader_quit )
    caps->import = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

  if ( zvdata->ILdg.encoder_init && zvdata->ILdg.encoder_write && zvdata->ILdg.encoder_quit )
    caps->export = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;
}

short iizvldg_init(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  if ( img_module->Type == MST_ZVLDG )
  {
    /* Legacy LDG module */
    zvdata->ILdg.plugin_init = ldg_find( "plugin_init", img_module->hLib ) ;
    if ( !zvdata->ILdg.plugin_init ) return EIMG_MODULERROR ;

    zvdata->ILdg.reader_init    = ldg_find( "reader_init",    img_module->hLib ) ;
    zvdata->ILdg.reader_read    = ldg_find( "reader_read",    img_module->hLib ) ;
    zvdata->ILdg.reader_get_txt = ldg_find( "reader_get_txt", img_module->hLib ) ;
    zvdata->ILdg.reader_quit    = ldg_find( "reader_quit",    img_module->hLib ) ;
    zvdata->ILdg.encoder_init   = ldg_find( "encoder_init",   img_module->hLib ) ;
    zvdata->ILdg.encoder_write  = ldg_find( "encoder_write",  img_module->hLib ) ;
    zvdata->ILdg.encoder_quit   = ldg_find( "encoder_quit",   img_module->hLib ) ;
  }
  else if ( img_module->Type == MST_IMGMOD )
  {
    /* IM module */
    BASEPAGE* basepage = (BASEPAGE*) img_module->hLib ;
    typedef long (*IMMAIN)(void) ;
    IMMAIN    main ;
    IM_INFOS* IMInfos ;

    main = (IMMAIN) (basepage->p_tbase) ;
    if ( main == NULL ) return EIMG_MODULERROR ;
    IMInfos = (IM_INFOS*) main() ;
    if ( (IMInfos == NULL) || (IMInfos->InfoID != 'GB32') ) return EIMG_MODULERROR ;
    zvdata->ILdg.plugin_init = IMInfos->plugin_init ;
    if ( !zvdata->ILdg.plugin_init ) return EIMG_MODULERROR ;

    zvdata->IMInfos = IMInfos ;
    zvdata->ILdg.reader_init    = IMInfos->reader_init ;
    zvdata->ILdg.reader_read    = IMInfos->reader_read ;
    zvdata->ILdg.reader_get_txt = IMInfos->reader_get_txt ;
    zvdata->ILdg.reader_quit    = IMInfos->reader_quit ;
    zvdata->ILdg.encoder_init   = IMInfos->encoder_init ;
    zvdata->ILdg.encoder_write  = IMInfos->encoder_write ;
    zvdata->ILdg.encoder_quit   = IMInfos->encoder_quit ;
  }

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
