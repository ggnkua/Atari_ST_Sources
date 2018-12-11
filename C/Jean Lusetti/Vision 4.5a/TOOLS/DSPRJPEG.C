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
#include   "..\tools\logging.h"

GEM_WINDOW *wprogJPEG ;
JPGDDRV_PTR drv = NULL ;
int         total ;
int         dminMCUs ;
int         lastMCU ;
char        UserAbort ;

extern HMSG hMsg ; /* For accessing messages */


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
  if (jpeg_driver == NULL) return EIMG_NOJPEGDRIVER ;
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
  if (size <= 0) return EIMG_FILENOEXIST ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  src = Xalloc(size+sizeof(pad)) ;
  if (src == NULL)
  {
    fclose(stream) ;
    return EIMG_NOMEMORY ;
  }

  fread(src, size, 1L, stream) ;
  fclose(stream) ;

  memcpy((char *)src+size, pad, sizeof(pad)) ;

  jpgdsize = JPGDGetStructSize(drv) ;
  jpgd     = Xcalloc(1, jpgdsize) ;
  if (jpgd == NULL)
  {
    Xfree(src) ;
    return EIMG_NOMEMORY ;
  }

  if (JPGDOpenDriver(drv, jpgd) != 0)
  {
    Xfree(jpgd) ;
    Xfree(src) ;
    return EIMG_NOMEMORY ;
  }

  jpgd->InPointer = src ;
  jpgd->InSize    = size ;
  if (JPGDGetImageInfo(drv, jpgd) != 0)
  {
    JPGDCloseDriver(drv, jpgd) ;
    Xfree(jpgd) ;
    Xfree(src) ;
    return EIMG_DATAINCONSISTENT ;
  }

  inf->largeur = jpgd->MFDBStruct.fd_w ;
  inf->hauteur = jpgd->MFDBStruct.fd_h ;
  JPGDCloseDriver(drv, jpgd) ;
  Xfree(jpgd) ;
  Xfree(src) ;

  return EIMG_SUCCESS ;
}

short dsp_progress_routine(JPGD_PTR jpgd)
{
  int ret = EIMG_SUCCESS ;

  if ( wprogJPEG == NULL ) return EIMG_SUCCESS ;

  if (total == -1)
  {
    total    = lastMCU = jpgd->MCUsCounter ;
    dminMCUs = total/20 ; /* No more than 20 updates */
  }

  if (lastMCU-jpgd->MCUsCounter >= dminMCUs)
  {
    int pc = (int) (100L*(long)(total-jpgd->MCUsCounter)/(long)total) ;

    if ( (pc > 0) && (pc < 100) )
    {
      int code = wprogJPEG->ProgPc( wprogJPEG, pc, NULL ) ;

      if ( STOP_CODE( code ) )
      {
        ret = 1 ; /* Stop */
        UserAbort = 1 ;
      }
    }
    lastMCU = jpgd->MCUsCounter ;
  }

  return ret ;
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
  int      brainstorm_decoder = (int)(MachineInfo.sound & 0x08) ; /* Bit 3: DSP, way to identify 'true' Brainstorm decoder as JPGDVersion field is also 1 in Aranym native JPEG decoder */
  char     pad[] = {-1, -1, -1, -1, -1, -1, -1, -1, 0, 0} ;

  UserAbort = 0 ;
  perf_start( PERF_DISK, &PerfInfo ) ;
  srcsize = file_size( name ) ;
  if ( srcsize <= 0 ) return EIMG_FILENOEXIST ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  src = Xalloc(srcsize+sizeof(pad)) ;
  if (src == NULL)
  {
    fclose(stream) ;
    return EIMG_NOMEMORY ;
  }

  fread(src, srcsize, 1L, stream) ;
  fclose(stream) ;
  perf_stop( PERF_DISK, &PerfInfo ) ;

  memcpy((char *)src+srcsize, pad, sizeof(pad)) ;

  jpgdsize = JPGDGetStructSize(drv) ;
  jpgd     = Xalloc(jpgdsize) ;
  if (jpgd == NULL)
  {
    Xfree(src) ;
    return EIMG_NOMEMORY ;
  }

  memset(jpgd, 0, jpgdsize) ;

  if ( DspInfo.WhatToDoIfLocked != DSPLOCK_FORCE )
  {
    if ( Dsp_Lock() == -1 )
    {
      switch( DspInfo.WhatToDoIfLocked )
      {
        case DSPLOCK_IGNORE : 
        case DSPLOCK_CANCEL : Xfree(jpgd) ;
                              Xfree(src) ;
                              return EIMG_USERCANCELLED ;
        case DSPLOCK_WARN   : if (form_interrogation(1, MsgTxtGetMsg(hMsg, MSG_DSPLOCK) ) != 1)
                              {
                                Xfree(jpgd) ;
                                Xfree(src) ;
                                return EIMG_USERCANCELLED ;
                              }
        case DSPLOCK_FORCE  : break ;
      }
    }
    else Dsp_Unlock() ;
  }

  if ( JPGDOpenDriver( drv, jpgd ) != 0 )
  {
    Xfree(jpgd) ;
    Xfree(src) ;
    return EIMG_NOMEMORY ;
  }

  jpgd->InPointer = src ;
  jpgd->InSize    = srcsize ;
  if (JPGDGetImageInfo(drv, jpgd) != 0)
  {
    JPGDCloseDriver(drv, jpgd) ;
    Xfree(jpgd) ;
    Xfree(src) ;
    return EIMG_DATAINCONSISTENT ;
  }

  jpgd->OutComponents = 3 ;

  if (brainstorm_decoder) { LoggingDo(LL_DEBUG, "Running with Brainstorm JPEG Decoder version %lX", drv->JPGDVersion) ; }
  else                    { LoggingDo(LL_DEBUG, "Running with Aranym NFJPEG feature version", drv->JPGDVersion) ; }

  /* Here is the deal: */
  /* NFJPEG native JPEG feature on Aranym is only working with 24bit TC mode */
  /* Old Brainstorm DSP 56001 JPEG decoder can handle 16, 24 and 32bit       */
  /* So in order to minimize allocated memory and speed:                     */
  /* If current resolution is 16bit deep:                                    */
  /* Brainstorm decoder --> OutPixelSize=2                                   */
  /* NFJPEG     decoder --> OutPixelSize=3, then do our best                 */
  /* If current resolution is 32bit deep:                                    */
  /* NFJPEG     decoder --> OutPixelSize=3, then do our best                 */
  /* We don't care about TC24 resolutions; they are not supported here       */
  if ( brainstorm_decoder ) jpgd->OutPixelSize = ( Force16BitsLoad ? 2 : 3 ) ; /* 3 should never happen on a Falcon */
  else                      jpgd->OutPixelSize = 3 ;

  if (JPGDGetImageSize(drv,jpgd) != 0)
  {
    JPGDCloseDriver(drv, jpgd) ;
    Xfree(jpgd) ;
    Xfree(src) ;
    return EIMG_DATAINCONSISTENT ;
  }

  if ( brainstorm_decoder ) dstsize = jpgd->OutSize ;
  else
  {
    /* 32bit --> allocate TC32 size even if decoder returns TC24, anyway we need TC32 for display */
    /* 16 bit --> we need 24bit as decoder output anyway */
    dstsize = img_size( jpgd->MFDBStruct.fd_w, jpgd->MFDBStruct.fd_h, (nb_plane == 32) ? 32:24 ) ;
  }
  dst = Xalloc(dstsize) ;
  if (dst == NULL)
  {
    JPGDCloseDriver(drv, jpgd) ;
    Xfree(jpgd) ;
    Xfree(src) ;
    return EIMG_NOMEMORY ;
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
  if ( UserAbort )  ret = EIMG_USERCANCELLED ;

  memcpy( out, &jpgd->MFDBStruct, sizeof(MFDB) ) ;
  if ( out->fd_addr == NULL )
  {
    ret = EIMG_DATAINCONSISTENT ;
    memset( out, 0, sizeof(MFDB) ) ;
    LoggingDo(LL_ERROR, "dsp_jpeg_load, fd_addr=NULL") ;
  }
  else if ( ret == EIMG_SUCCESS )
  {
    out->fd_wdwidth = out->fd_w/16 ;
    if ( out->fd_w % 16 ) out->fd_wdwidth++ ;
    if ( !brainstorm_decoder )
    {
      /* We need additional work as decoder output is always 24 bits */
      char*         o24   = (char*) out->fd_addr + img_size( out->fd_w, out->fd_h, 24 ) ; /* 1+last byte of 24bit image */
      unsigned long nbpix = out->fd_wdwidth*16L*out->fd_h ;

      if ( !Force16BitsLoad && (nb_plane == 32 ) )
      {
        char* o32 = (char*) out->fd_addr + img_size( out->fd_w, out->fd_h, 32 ) ; /* 1+last byte of 32bit image */;

        /* We allocate a 32bit image holding now a 24bit image */
        /* So we can make the conversion in place              */
        LoggingDo(LL_DEBUG, "dsp_jpeg_load, converting from 24 to 32bit in place") ;
        tc24to32ip(o24, o32, nbpix);
        out->fd_nplanes = 32 ;
      }
      else
      {
        void* o16 ;

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
    }
    RasterResetUnusedData( out ) ;
  }

  JPGDCloseDriver(drv, jpgd) ;
  Xfree(jpgd) ;
  Xfree(src) ;

  return ret ;
}
