/**********************************************************************************/
/* IIZVSLB.C: wrapper for exposing LDI interface from ZVIEW SLB plugin interface  */
/* As per now (September 2019), it is NOT integrated into VISION                  */
/* This new SLB image plugin model has been designed to allow library sharing     */
/* Among applications and optimize memory consumption by enabling the plugin to   */
/* Use callbacks such as standard 'C' library functions provided by the app       */
/* However, it has several drawbacks for which I didn't add its support to VISION:*/
/* - If a SLB has a SLB dependency (e.g. JPEG,PNG requiring zlib SLB), the app    */
/*   must be aware of it and provide zlib SLB callbacks to the plugin             */
/* - App has to provide almost all the 'C' standard library functions such as     */
/*   memcpy, strcpy, malloc, fopen, sprintf, rand, localtime, sigsetjmp, ...      */
/* - Complexity is even added as qsort and bsearch have to be re-implemented to   */
/*   to deal with calling convention differences for PureC/gcc                    */
/* Complete thread discussion available at:                                       */
/* http://www.atari-forum.com/viewtopic.php?f=16&t=34298#p380609                  */
/**********************************************************************************/
#include <string.h>
#include <stdlib.h>

#include "xalloc.h"
#include "imgmodul.h"
#include "logging.h"
#include "iizview.h"
#include "zvlight.h"


#undef SLB_NARGS
#if defined(__MSHORT__) || defined(__PUREC__)
#define SLB_NARGS(_nargs) 0, _nargs
#else
#define SLB_NARGS(_nargs) _nargs
#endif


static void LogSlbExecStatus(char* func_name, long status)
{
  if ( status < 0 ) LoggingDo(LL_WARNING,"SLB call %s failed with %ld", func_name, status ) ;
}

static long zvSLB_get_option(IMG_MODULE* ImgModule, short which)
{
  long status ;

  LoggingDo(LL_DEBUG, "zvSLB_get_option(%d), hLib=%p, SlbExec=%p", which, ImgModule->hLib, ImgModule->SlbExec) ;
  status = ImgModule->SlbExec( ImgModule->hLib, 8L, SLB_NARGS(1), (long)which ) ; /* All parameters must be 4 byte long */
  LogSlbExecStatus( "zvSLB_get_option", status ) ;
  if ( status < 0 ) return 0 ; /* NULL actually */
  else              return status ;
}

#pragma warn -par
static unsigned long iizv_slb_plugin_init(IMG_MODULE* img_module)
{
  LoggingDo(LL_DEBUG, "Calling SLB plugin_init...") ;

  return 1 ;
}
#pragma warn +par

static unsigned long iizv_slb_reader_init(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info)
{
  long status ;

  LoggingDo(LL_DEBUG, "Calling SLB reader_init for %s, $%p...", name, info) ;
  status = img_module->SlbExec( img_module->hLib, 1L, SLB_NARGS(2), name, info ) ;
  LogSlbExecStatus( "reader_init", status ) ;

  if ( status < 0 ) return EIMG_MODULERROR ;
  else              return (unsigned long) status ;
}

static unsigned long iizv_slb_reader_read(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer)
{
  long status ;

  LoggingDo(LL_DEBUG, "Calling SLB reader_read...") ;
  status = img_module->SlbExec( img_module->hLib, 2L, SLB_NARGS(2), info, buffer ) ;
  LogSlbExecStatus( "reader_read", status ) ;

  if ( status < 0 ) return EIMG_MODULERROR ;
  else              return (unsigned long) status ;
}

static void iizv_slb_reader_get_txt(IMG_MODULE* img_module, ZVIMGINFO* info, txt_data* txtdata)
{
  LoggingDo(LL_DEBUG, "Calling SLB reader_get_txt...") ;
  LogSlbExecStatus( "reader_get_txt", img_module->SlbExec( img_module->hLib, 3L, SLB_NARGS(2), info, txtdata ) ) ;
}

static void iizv_slb_reader_quit(IMG_MODULE* img_module, ZVIMGINFO* info)
{
  LoggingDo(LL_DEBUG, "Calling SLB reader_quit...") ;
  LogSlbExecStatus( "reader_get_txt", img_module->SlbExec( img_module->hLib, 4L, SLB_NARGS(1), info ) ) ;
}

static unsigned long iizv_slb_encoder_init(IMG_MODULE* img_module, const char* name, ZVIMGINFO* info)
{
  long status ;

  LoggingDo(LL_DEBUG, "Calling SLB encoder_init...") ;
	status = img_module->SlbExec( img_module->hLib, 5L, SLB_NARGS(2), name, info ) ;
  LogSlbExecStatus( "encoder_init", status ) ;

  if ( status < 0 ) return EIMG_MODULERROR ;
  else              return (unsigned long) status ;
}

static unsigned long iizv_slb_encoder_write(IMG_MODULE* img_module, ZVIMGINFO* info, unsigned char* buffer)
{
  long status ;

  LoggingDo(LL_DEBUG, "Calling SLB encoder_write...") ;
	status = img_module->SlbExec( img_module->hLib, 6L, SLB_NARGS(2), info, buffer ) ;
  LogSlbExecStatus( "encoder_write", status ) ;

  if ( status < 0 ) return EIMG_MODULERROR ;
  else              return (unsigned long) status ;
}

static void iizv_slb_encoder_quit(IMG_MODULE* img_module, ZVIMGINFO* info)
{
  LoggingDo(LL_DEBUG, "Calling SLB encoder_quit...") ;
  LogSlbExecStatus( "encoder_quit", img_module->SlbExec( img_module->hLib, 7L, SLB_NARGS(1), info ) ) ;
}

void iizviewSLB_GetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  char*           ext ;
  char            lib_name[32] ;

  strncpy( lib_name, zvdata->lib_name, sizeof(lib_name)-1 ) ;
  ext = strrchr( lib_name, '.' ) ;
  if ( ext ) *ext = 0 ; /* Remove extension */

  ext = (char*) zvSLB_get_option( ImgModule, OPTION_EXTENSIONS ) ;
  if ( ext )
  {
    char*  s, *d ;
    size_t len ;
    long   status = zvSLB_get_option( ImgModule, OPTION_CAPABILITIES ) ;

    caps->import = caps->export = 0 ;
    /* Assume SLB can import any bitplane depth to not prevent anything if capability DECODE is reported */
    if ( status & CAN_DECODE ) caps->import = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

    /* Assume SLB can export any bitplane depth to not prevent anything if capability ENCODE is reported */
    if ( status & CAN_ENCODE ) caps->export = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

    caps->iid = iizview_GetIID( ext ) ; /* Use first extension to identify module */
    /* Copy every extension */
    s = ext ;
    d = caps->known_extensions ;
    while ( *s )
    {
      len = 1 + strlen(s) ;
      if ( len > (int) sizeof(caps->known_extensions) ) break ;
      strcpy( d, s ) ;
      s += len ;
      d += len ;
    }
    strcpy( caps->short_name, lib_name ) ;
    memcpy( caps->file_extension, ext, 3 ) ;
    caps->file_extension[3] = 0 ;
    status = zvSLB_get_option( ImgModule, INFO_NAME ) ;
    if ( status > 0 )
    {
       const char* name = (const char*) status ;
       const char* end = strchr( name, '\n' ) ;

       if ( end == NULL ) len = strlen(name) + 1 ;
       else               len = end - name + 1 ;
       if ( len >= sizeof(caps->name) ) len = sizeof(caps->name) ;
       strncpy( caps->name, name, len - 1 ) ;
       caps->name[len-1] = '\0' ;
    }
    else strcpy( caps->name, lib_name ) ;
    status = zvSLB_get_option( ImgModule, INFO_VERSION ) ;
    if ( status > 0 ) caps->version = (unsigned int) status ;
    else              caps->version = (unsigned int) ImgModule->SlbVersion ; /* Fallback choice */
  }
}

short iizvslb_init(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;

  zvdata->plugin_init    = iizv_slb_plugin_init ;
  zvdata->reader_init    = iizv_slb_reader_init ;
  zvdata->reader_read    = iizv_slb_reader_read ;
  zvdata->reader_get_txt = iizv_slb_reader_get_txt ;
  zvdata->reader_quit    = iizv_slb_reader_quit ;
  zvdata->encoder_init   = iizv_slb_encoder_init ;
  zvdata->encoder_write  = iizv_slb_encoder_write ;
  zvdata->encoder_quit   = iizv_slb_encoder_quit ;

  return EIMG_SUCCESS ;
}