/********************************************/
/*          Gestion du format JPEG          */
/* La routine Brainstorm doit ˆtre pr‚sente */
/********************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include               "defs.h"
#include              "jpgdh.h"
#include      "..\tools\xgem.h"
#include   "..\tools\cookies.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\image_io.h"

GEM_WINDOW *wprogJPEG ;
JPGDDRV_PTR drv = NULL ;
int         total ;
char        UserAbort ;


int dsp_jpeg_identify(char *nom, INFO_IMAGE *inf)
{
  COOKIE *jpeg_driver ;
  JPGD_PTR jpgd ;
  FILE     *stream ;
  long     jpgdsize ;
  long     size ;
  void     *src ;
  char     pad[] = {-1, -1, -1, -1, -1, -1, -1, -1, 0, 0} ;

  jpeg_driver = cookie_find("_JPD") ;
  if (jpeg_driver == NULL) return(-9) ;
  drv = (JPGDDRV_PTR) jpeg_driver->data ;

  inf->byteorder = 0 ; /* Sans importance */
  inf->version   = 1 ;
  inf->compress  = 1 ;
  inf->predictor = 0 ;
  inf->palette   = NULL ;
  inf->nb_cpal   = 0 ;
  inf->nplans    = 24 ;
  inf->lpix      = 0x150 ;
  inf->hpix      = 0x150 ;

  size = file_size( nom ) ;
  if (size <= 0) return( -1 ) ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return(-1) ;

  src = malloc(size+sizeof(pad)) ;
  if (src == NULL)
  {
    fclose(stream) ;
    return(-3) ;
  }

  fread(src, size, 1L, stream) ;
  fclose(stream) ;

  memcpy((char *)src+size, pad, sizeof(pad)) ;

  jpgdsize = JPGDGetStructSize(drv) ;
  jpgd     = calloc(1, jpgdsize) ;
  if (jpgd == NULL)
  {
    free(src) ;
    return(-3) ;
  }

  if (JPGDOpenDriver(drv, jpgd) != 0)
  {
    free(jpgd) ;
    free(src) ;
    return(-3) ;
  }

  jpgd->InPointer = src ;
  jpgd->InSize    = size ;
  if (JPGDGetImageInfo(drv, jpgd) != 0)
  {
    JPGDCloseDriver(drv, jpgd) ;
    free(jpgd) ;
    free(src) ;
    return(-2) ;
  }

  inf->largeur = jpgd->MFDBStruct.fd_w ;
  inf->hauteur = jpgd->MFDBStruct.fd_h ;
  JPGDCloseDriver(drv, jpgd) ;
  free(jpgd) ;
  free(src) ;

  return(0) ;
}

short dsp_progress_routine(JPGD_PTR jpgd)
{
  int code, pc ;
  int ret = 0 ;

  if ( wprogJPEG == NULL ) return( 0 ) ;
  if (total == -1) total = jpgd->MCUsCounter ;
  pc = (int) (100L*(long)(total-jpgd->MCUsCounter)/(long)total) ;
  code = wprogJPEG->ProgPc( wprogJPEG, pc, NULL ) ;
  if ( STOP_CODE( code ) )
  {
    ret = 1 ; /* Stop */
    UserAbort = 1 ;
  }
  else
    ret = 0 ; /* Continue */

  return(ret) ;
}

int dsp_jpeg_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  JPGD_PTR jpgd ;
  FILE     *stream ;
  long     jpgdsize ;
  long     srcsize ;
  long     dstsize ;
  void     *src, *dst ;
  int      ret = 0 ;
  char     pad[] = {-1, -1, -1, -1, -1, -1, -1, -1, 0, 0} ;

  UserAbort = 0 ;
  perf_start( PERF_DISK, &PerfInfo ) ;
  srcsize = file_size( name ) ;
  if ( srcsize <= 0 ) return( -1 ) ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;

  src = malloc(srcsize+sizeof(pad)) ;
  if (src == NULL)
  {
    fclose(stream) ;
    return(-3) ;
  }

  fread(src, srcsize, 1L, stream) ;
  fclose(stream) ;
  perf_stop( PERF_DISK, &PerfInfo ) ;

  memcpy((char *)src+srcsize, pad, sizeof(pad)) ;

  jpgdsize = JPGDGetStructSize(drv) ;
  jpgd     = malloc(jpgdsize) ;
  if (jpgd == NULL)
  {
    free(src) ;
    return(-3) ;
  }

  memset(jpgd, 0, jpgdsize) ;

  if ( DspInfo.WhatToDoIfLocked != DSPLOCK_FORCE )
  {
    if ( Dsp_Lock() == -1 )
    {
      switch( DspInfo.WhatToDoIfLocked )
      {
        case DSPLOCK_IGNORE : 
        case DSPLOCK_CANCEL : free(jpgd) ;
                              free(src) ;
                              return(-10) ;
        case DSPLOCK_WARN   : if (form_interrogation(1, msg[MSG_DSPLOCK]) != 1)
                              {
                                free(jpgd) ;
                                free(src) ;
                                return(-10) ;
                              }
        case DSPLOCK_FORCE  : break ;
      }
    }
    else Dsp_Unlock() ;
  }

  if ( JPGDOpenDriver( drv, jpgd ) != 0 )
  {
    free(jpgd) ;
    free(src) ;
    return(-3) ;
  }

  jpgd->InPointer = src ;
  jpgd->InSize    = srcsize ;
  if (JPGDGetImageInfo(drv, jpgd) != 0)
  {
    JPGDCloseDriver(drv, jpgd) ;
    free(jpgd) ;
    free(src) ;
    return(-2) ;
  }

  jpgd->OutComponents = 3 ;
  jpgd->OutPixelSize  = ( Force16BitsLoad ? 2 : 3 ) ;
  if (JPGDGetImageSize(drv,jpgd) != 0)
  {
    JPGDCloseDriver(drv, jpgd) ;
    free(jpgd) ;
    free(src) ;
    return(-2) ;
  }

  dstsize = jpgd->OutSize ;
  dst     = malloc(dstsize) ;
  if (dst == NULL)
  {
    JPGDCloseDriver(drv, jpgd) ;
    free(jpgd) ;
    free(src) ;
    return(-3) ;
  }
  jpgd->OutPointer  = dst;
  jpgd->OutFlag     = 0;			 
  jpgd->UserRoutine = dsp_progress_routine ;
  wprogJPEG         = wprog ;
  total             = -1 ;

  StdProgDisplayDSP( wprog, 1 ) ;

  perf_start( PERF_COMPRESS, &PerfInfo ) ;
  JPGDDecodeImage(drv, jpgd) ;
  perf_stop( PERF_COMPRESS, &PerfInfo ) ;

  wprogJPEG = NULL ;
  if ( UserAbort )  ret = -8 ;

  memcpy( out, &jpgd->MFDBStruct, sizeof(MFDB) ) ;
  if ( out->fd_addr == NULL )
  {
    ret = -2 ;
    memset( out, 0, sizeof(MFDB) ) ;
  }
  else if ( ret == 0 )
  {
    out->fd_wdwidth = out->fd_w/16 ; /* Non pr‚cis‚ par Brainstorm ! */
    if ( out->fd_w % 16 ) out->fd_wdwidth++ ;
    RasterResetUnusedData( out ) ;
  }

  JPGDCloseDriver(drv, jpgd) ;
  free(jpgd) ;
  free(src) ;

  return( ret ) ;
}
