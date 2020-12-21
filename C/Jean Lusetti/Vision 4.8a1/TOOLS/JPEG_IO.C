/********************************************/
/*          Gestion du format JPEG          */
/********************************************/
#include <string.h>

#include  "..\tools\cpujpeg.h"
#include  "..\tools\dsprjpeg.h"
#include   "..\tools\logging.h"

static char CanUseDsp ;


int jpeg_identify(char *nom, INFO_IMAGE *inf)
{
  int ret ;

  CanUseDsp = 1 ;
  ret = dsp_jpeg_identify( nom, inf ) ;
  if ( ret != 0 )
  {
    /* Driver Brainstorm non present ou ne reconnait pas */
    /* Le format ou le DSP ne doit pas etre utilise      */
    ret = cpu_jpeg_identify( nom, inf ) ;

    CanUseDsp = 0 ;
  }

  return ret ;
}

int jpeg_load(INFO_IMAGE *inf)
{
  int ret ;

  if ( CanUseDsp ) ret = dsp_jpeg_load( inf ) ;
  else             ret = cpu_jpeg_load( inf ) ;

  img_post_loading( ret, inf ) ;

  LoggingDo(LL_DEBUG, "jpeg_load(%s), fd_w=%d, fd_h=%d, fd_nplanes=%d", CanUseDsp ? "DSP":"CPU", inf->mfdb.fd_w, inf->mfdb.fd_h, inf->mfdb.fd_nplanes) ;

  return ret ;
}

int jpeg_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog)
{
  return cpu_jpeg_sauve( name, img, info, wprog ) ;
}

void jpeg_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "JPEG\0JPG\0JPE\0\0" ;

  caps->iid = IID_JPEG ;
  strcpy( caps->short_name, "JPEG" ) ;
  strcpy( caps->file_extension, "JPG" ) ;
  strcpy( caps->name, "Joint Photographic Expert Group" ) ;
  caps->version = 0x0407 ;

  caps->import = IEF_P8 | IEF_P24 | IEF_JPEG ;
  caps->export = IEF_P8 | IEF_P24 | IEF_JPEG ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
