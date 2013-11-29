/********************************************/
/*          Gestion du format JPEG          */
/********************************************/
#include <string.h>

#include  "..\tools\cpujpeg.h"
#include  "..\tools\dsprjpeg.h"

static char CanUseDsp ;

int jpeg_identify(char *nom, INFO_IMAGE *inf)
{
  int ret = -1 ;

  CanUseDsp = 1 ;
  if ( DspInfo.use ) ret = dsp_jpeg_identify( nom, inf ) ;
  if ( ret != 0 )
  {
    /* Driver Brainstorm non present ou ne reconnait pas */
    /* Le format ou le DSP ne soit pas etre utilise      */
    ret = cpu_jpeg_identify( nom, inf ) ;

    CanUseDsp = 0 ;
  }

  return( ret ) ;
}

int jpeg_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  int ret = 0 ;

  if ( CanUseDsp ) ret = dsp_jpeg_load( name, out, wprog ) ;
  else             ret = cpu_jpeg_load( out, wprog ) ;

  return( ret ) ;
}

int jpeg_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  int ret = 0 ;

  ret = cpu_jpeg_sauve( name, img, info, wprog ) ;

  return( ret ) ;
}

void jpeg_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "JPEG\0JPG\0JPE\0\0" ;

  caps->iid = IID_JPEG ;
  strcpy( caps->short_name, "JPEG" ) ;
  strcpy( caps->file_extension, "JPG" ) ;
  strcpy( caps->name, "Joint Photographic Expert Group" ) ;
  caps->version = 0x0400 ;

  caps->inport1         = 0 ;
  caps->inport2         = 0 ;
  caps->inport4         = 0 ;
  caps->inport8         = 1 ;
  caps->inport16        = 0 ;
  caps->inport24        = 1 ;
  caps->inport32        = 0 ;
  caps->inport_nocmp    = 0 ;
  caps->inport_rle      = 0 ;
  caps->inport_lzw      = 0 ;
  caps->inport_packbits = 0 ;
  caps->inport_jpeg     = 1 ;
  caps->inport_rfu      = 0 ;

  caps->export1         = 0 ;
  caps->export2         = 0 ;
  caps->export4         = 0 ;
  caps->export8         = 1 ;
  caps->export16        = 0 ;
  caps->export24        = 1 ;
  caps->export32        = 0 ;
  caps->export_nocmp    = 0 ;
  caps->export_rle      = 0 ;
  caps->export_lzw      = 0 ;
  caps->export_packbits = 0 ;
  caps->export_jpeg     = 1 ;
  caps->export_rfu      = 0 ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
