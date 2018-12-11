/*****************************************/
/*          PNG Format Handling          */
/*****************************************/
#include <string.h>

#include  "..\tools\cpupng.h"
#include  "..\tools\anfpng.h"
#include   "..\tools\logging.h"

static char CanUseAraNF ; /* 1 if we can use Aranym Native Feature (a bit similar to DSP JPEG for Falcon) */

int png_identify(char *name, INFO_IMAGE *inf)
{
  int ret ;

  CanUseAraNF = 1 ;
  ret = anf_png_identify( name, inf ) ;
  if ( ret != 0 )
  {
    /* Aranym Native Feature not available,   */
    /* Switch to CPU using PNG shared library */
    ret = cpu_png_identify( name, inf ) ;

    CanUseAraNF = 0 ;
  }

  return ret ;
}

int png_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  int ret = 0 ;

  if ( CanUseAraNF ) ret = anf_png_load( name, out, wprog ) ;
  else               ret = cpu_png_load( name, out, wprog ) ;

  LoggingDo(LL_DEBUG, "png_load(%s), fd_addr=%p, fd_w=%d, fd_h=%d, fd_nplanes=%d", CanUseAraNF ? "NativeFeature":"CPU", out->fd_addr, out->fd_w, out->fd_h, out->fd_nplanes) ;

  return ret ;
}

int png_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  int ret = 0 ;

  ret = cpu_png_sauve( name, img, info, wprog ) ;

  return ret ;
}

void png_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "PNG\0\0" ;

  caps->iid = IID_PNG ;
  strcpy( caps->short_name, "PNG" ) ;
  strcpy( caps->file_extension, "PNG" ) ;
  strcpy( caps->name, "Portable Network Graphics" ) ;
  caps->version = 0x0100 ;

  caps->import = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_JPEG ;
  caps->export = 0 ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}

void png_terminate(void)
{
  if ( !CanUseAraNF ) cpu_png_terminate() ;
}
