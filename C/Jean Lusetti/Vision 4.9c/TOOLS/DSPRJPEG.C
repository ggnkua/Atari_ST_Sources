/********************************************/
/*          Gestion du format JPEG          */
/* La routine Brainstorm doit ˆtre pr‚sente */
/********************************************/
#include <string.h>

#include   "jpgdh.h"
#include   "xgem.h"
#include   "cookies.h"
#include   "rasterop.h"
#include   "image_io.h"
#include   "logging.h"
#include   "stdprog.h"

GEM_WINDOW*  wprogJPEG ;
JPGDDRV_PTR  drv = NULL ;
unsigned int total ;
unsigned int dminMCUs ;
unsigned int lastMCU ;
char         UserAbort ;


int dsp_jpeg_identify(char *nom, INFO_IMAGE *inf)
{
  JPGD_PTR jpgd ;
  long     jpgdsize ;
  int      err ;
  char     pad[] = {-1, -1, -1, -1, -1, -1, -1, -1, 0, 0} ;

  if ( drv == NULL )
  {
    COOKIE* jpeg_driver = cookie_find("_JPD") ;

    if ( jpeg_driver == NULL ) return EIMG_NOJPEGDRIVER ;
    drv = (JPGDDRV_PTR) jpeg_driver->data ;
  }

  inf->compress        = 1 ;
  inf->palette         = NULL ;
  inf->nb_cpal         = 0 ;
  inf->nplanes         = 24 ;
  inf->lpix            = 0x150 ;
  inf->hpix            = 0x150 ;
  inf->c.f.jpg.quality = 90 ; /* Let's have a non too bad value here */

  perf_start( PERF_DISK, &inf->perf_info ) ;
  err = ImgFOpen( inf, nom, &inf->file_size ) ; 
  if ( err != EIMG_SUCCESS ) return err ;

  inf->file_contents = Xalloc( inf->file_size+sizeof(pad) ) ;
  if ( inf->file_contents == NULL )
  {
    ImgFClose( inf ) ;
    return EIMG_NOMEMORY ;
  }

  ImgFRead( inf, inf->file_contents, inf->file_size ) ;
  ImgFClose( inf ) ;
  perf_stop( PERF_DISK, &inf->perf_info ) ;

  memcpy( (char*)inf->file_contents+inf->file_size, pad, sizeof(pad) ) ;

  jpgdsize = JPGDGetStructSize( drv ) ;
  jpgd     = Xcalloc( 1, jpgdsize ) ;
  if ( jpgd == NULL )
  {
    Xfree( inf->file_contents ) ; inf->file_contents = NULL ;
    return EIMG_NOMEMORY ;
  }

  if ( JPGDOpenDriver( drv, jpgd ) != 0 )
  {
    Xfree( jpgd ) ;
    Xfree( inf->file_contents ) ; inf->file_contents = NULL ;
    return EIMG_NOMEMORY ;
  }

  jpgd->InPointer = inf->file_contents ;
  jpgd->InSize    = inf->file_size ;
  if ( JPGDGetImageInfo( drv, jpgd ) != 0 )
  {
    JPGDCloseDriver( drv, jpgd ) ;
    Xfree( jpgd ) ;
    Xfree( inf->file_contents ) ; inf->file_contents = NULL ;
    return EIMG_DATAINCONSISTENT ;
  }

  inf->width    = jpgd->MFDBStruct.fd_w ;
  inf->height   = jpgd->MFDBStruct.fd_h ;
  inf->specific = jpgd ;

  return EIMG_SUCCESS ;
}

short dsp_progress_routine(JPGD_PTR jpgd)
{
  int ret = EIMG_SUCCESS ;

  if ( wprogJPEG == NULL ) return EIMG_SUCCESS ;

  if ( total == (unsigned int)-1 )
  {
    /* MCUsCounter is defined as int in JPEF_PTR struct, Let's consider it */
    /* As unsigned as if image is big enough, this will go above 32767     */
    total    = lastMCU = (unsigned int) jpgd->MCUsCounter ;
    dminMCUs = total/20 ; /* No more than 20 updates */
  }

  if ( lastMCU-jpgd->MCUsCounter >= dminMCUs )
  {
    int code = GWProgRange( wprogJPEG, total-jpgd->MCUsCounter, total, NULL ) ;

    if ( PROG_CANCEL_CODE( code ) )
    {
      ret = 1 ; /* Stop */
      UserAbort = 1 ;
    }
    lastMCU = jpgd->MCUsCounter ;
  }

  return ret ;
}

static void RGB24to32(char* o24, MFDB* out, unsigned long nbpix)
{
  char* o32 = (char*) out->fd_addr + img_size( out->fd_w, out->fd_h, 32 ) ; /* 1+last byte of 32bit image */;

  /* We allocated a 32bit image holding now a 24bit image */
  /* So we can make the conversion in place               */
  LoggingDo(LL_DEBUG, "RGB24to32, converting from 24 to 32bit in place") ;
  tc24to32ip( o24, o32, nbpix ) ;
  out->fd_nplanes = 32 ;
}

int dsp_jpeg_load(INFO_IMAGE* inf)
{
  JPGD_PTR    jpgd = inf->specific ;
  MFDB*       out = &inf->mfdb ;
  GEM_WINDOW* wprog = (GEM_WINDOW*) inf->prog ;
  long        dstsize ;
  void*       dst ;
  int         ret = 0 ;
  int         brainstorm_decoder = DspInfo.type ; /* Bit 3: DSP, way to identify 'true' Brainstorm decoder as JPGDVersion field is also 1 in Aranym native JPEG decoder --> not working on Aranym 1.1.0, use DspInfo.type */

  if ( (drv == NULL) || (jpgd == NULL) )
  {
    LoggingDo(LL_ERROR, "dsp_jpeg_load: drv=%p, jpgd=%p", drv, jpgd) ;
    return EIMG_DATAINCONSISTENT ;
  }
  UserAbort = 0 ;

  if ( DspInfo.WhatToDoIfLocked != DSPLOCK_FORCE )
  {
    if ( Dsp_Lock() == -1 )
    {
      switch( DspInfo.WhatToDoIfLocked )
      {
        case DSPLOCK_IGNORE : 
        case DSPLOCK_CANCEL : JPGDCloseDriver( drv, jpgd ) ;
                              return EIMG_USERCANCELLED ;
        case DSPLOCK_WARN   : if (form_interrogation(1, ImgMsgGeTxt(IMGMID_DSPLOCK)) != 1)
                              {
                                JPGDCloseDriver( drv, jpgd ) ;
                                return EIMG_USERCANCELLED ;
                              }
        case DSPLOCK_FORCE  : break ;
      }
    }
    else Dsp_Unlock() ;
  }

  jpgd->OutComponents = 3 ;

  LoggingDo(LL_INFO, "Running with %s decoder version %lX", brainstorm_decoder ? "Brainstorm JPEG":"Aranym NFJPEG", drv->JPGDVersion) ;

  /* Here is the deal: */
  /* NFJPEG native JPEG feature on Aranym is only working with 24bit TC mode */
  /* Old Brainstorm DSP 56001 JPEG decoder can handle 16, 24 and 32bit       */
  /* So in order to minimize allocated memory and speed:                     */
  /* If current resolution is 16bit deep:                                    */
  /* Brainstorm decoder --> OutPixelSize=2                                   */
  /* NFJPEG     decoder --> OutPixelSize=3, then do our best                 */
  /* If current resolution is 32bit deep:                                    */
  /* Brainstorm decoder --> OutPixelSize=3                                   */
  /* NFJPEG     decoder --> OutPixelSize=3, then do our best                 */
  /* We don't care about TC24 resolutions; they are not supported here       */
  if ( brainstorm_decoder ) jpgd->OutPixelSize = ( inf->force_16b_load ? 2 : 3 ) ; /* yes, 3 can happen on a Falcon with a graphic card */
  else                      jpgd->OutPixelSize = 3 ;

  if ( JPGDGetImageSize( drv, jpgd ) != 0 )
  {
    JPGDCloseDriver( drv, jpgd ) ;
    return EIMG_DATAINCONSISTENT ;
  }

  if ( brainstorm_decoder ) dstsize = jpgd->OutSize ;
  else
  {
    /* 32bit --> allocate TC32 size even if decoder returns TC24, anyway we need TC32 for display */
    /* 16 bit --> we need 24bit as decoder output anyway */
    dstsize = img_size( jpgd->MFDBStruct.fd_w, jpgd->MFDBStruct.fd_h, (screen.fd_nplanes == 32) ? 32:24 ) ;
  }
  dst = Xalloc( dstsize ) ;
  if ( dst == NULL )
  {
    JPGDCloseDriver( drv, jpgd ) ;
    return EIMG_NOMEMORY ;
  }
  jpgd->OutPointer  = dst;
  jpgd->OutFlag     = 0;			 
  jpgd->UserRoutine = dsp_progress_routine ;
  wprogJPEG         = wprog ;
  total             = (unsigned int)-1 ;

  StdProgDisplayDSP( wprog, 1 ) ;

  perf_start( PERF_COMPRESS, &inf->perf_info ) ;
  JPGDDecodeImage( drv, jpgd ) ;
  perf_stop( PERF_COMPRESS, &inf->perf_info ) ;

  wprogJPEG = NULL ;
  if ( UserAbort )
  {
    ret = EIMG_USERCANCELLED ;
    /* Xfree( dst ) ; Responsibility of caller (IMLoad) to free partially decoded image */ 
  }

  CopyMFDB( out, &jpgd->MFDBStruct ) ;
  if ( out->fd_addr == NULL )
  {
    ret = EIMG_DATAINCONSISTENT ;
    ZeroMFDB( out ) ;
    LoggingDo(LL_ERROR, "dsp_jpeg_load, fd_addr=NULL") ;
  }
  else if ( ret == EIMG_SUCCESS )
  {
    char*         o24 = (char*) out->fd_addr + img_size( out->fd_w, out->fd_h, 24 ) ; /* 1+last byte of 24bit image */
    unsigned long nbpix ;

    out->fd_wdwidth = W2WDWIDTH( out->fd_w ) ;
    nbpix           = out->fd_wdwidth*16L*out->fd_h ;
    if ( !inf->force_16b_load && (screen.fd_nplanes == 32) ) RGB24to32( o24, out, nbpix ) ;
    else if ( !brainstorm_decoder )
    {
      void* o16 ;

      /* We need additional work as decoder output is always 24 bits */
      /* A bit more complicated here, let's first try allocate a 16bit image */
      o16 = img_alloc( out->fd_w, out->fd_h, 16 ) ;
      if ( o16 != NULL )
      {
        /* Great, let's make a simple TC24-->TC16 conversion */
        /* And then free the TC24 image */
        LoggingDo(LL_DEBUG, "dsp_jpeg_load, converting from 24 to 16bit in new image") ;
        tc24to16ip(out->fd_addr, o16, nbpix);
        Xfree( out->fd_addr ) ;
        out->fd_addr = o16 ;
      }
      else
      {
        /* Not enough memory; keep the TC24 image */
        /* And convert it in place to TC16        */
        /* We will be wasting some memory but     */
        /* That's the best we can do              */
        LoggingDo(LL_DEBUG, "dsp_jpeg_load, converting from 24 to 16bit in place") ;
        tc24to16ip(out->fd_addr, out->fd_addr, nbpix);
      }
      out->fd_nplanes = 16 ;
    }
    RasterResetUnusedData( out ) ;
  }

  JPGDCloseDriver( drv, jpgd ) ;

  return ret ;
}
