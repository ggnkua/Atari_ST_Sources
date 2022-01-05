/*****************************************************************************/
/* IIZVIEW.C: wrapper for exposing LDI interface from ZVIEW plugin interface */
/*            Both LDG, IM and SLB interfaces are mapped                     */
/*****************************************************************************/
#include <string.h>
#include <stdlib.h>

#include "xalloc.h"
#include "imgmodul.h"
#include "rasterop.h"
#include "iizview.h"
#include "iizvldg.h"
#include "iizvslb.h"
#include "logging.h"
#include "zvlight.h"


static short get_zvnplanes_out(ZVIMGINFO* zvinf)
{
  short zv_nplanes ;

  /* Number of planes returned by reader_read function is NOT zvinf->planes */
  /* From lp (atari-forum.org): */
  /* IF components=1 
       @mono
     ELSE IF indexed_color
       @color_mapped
     ELSE
       @true_color
     ENDIF
  */
  if ( zvinf->components == 1 )    zv_nplanes = 1 ;
  else if ( zvinf->indexed_color ) zv_nplanes = zvinf->planes ;
  else                             zv_nplanes = 24 ;

  return zv_nplanes ;
}

long iizview_GetIID(char* infos)
{
  char* fmts[] = {   "BMP",     "PI1",   "GIF",   "IMG",   "NEO",    "JPG",   "PNG",     "TGA",    "TIF" } ;
  long  iids[] = { IID_BMP, IID_DEGAS, IID_GIF, IID_IMG, IID_NEO, IID_JPEG, IID_PNG, IID_TARGA, IID_TIFF } ;
  short i ;
  long  iid = 0 ;

  /* First let's try to match internal's IIDs for common image support */
  for ( i = 0; (iid == 0) && (i < ARRAY_SIZE(fmts)); i++ )
    if ( memcmp( infos, fmts[i], 3 ) == 0 ) iid = iids[i] ;

  if ( iid == 0 )
  {
    /* Infos field holds all extensions padded on 3 characters   */
    /* Let's use this information to guess the format, hopefully */
    /* It is looking like internal IIDs but in reverse order     */
    iid |= infos[0] ; iid <<= 8 ;
    iid |= infos[1] ; iid <<= 8 ;
    iid |= infos[2] ; iid <<= 8 ;
  }

  return iid ;
}

static void iizview_GetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps)
{
  memzero( caps, sizeof(INFO_IMAGE_DRIVER) ) ;
  if ( (ImgModule->Type == MST_ZVLDG) || (ImgModule->Type == MST_IMGMOD) ) iizviewLDG_GetDrvCaps( ImgModule, caps ) ;
#ifdef MST_ZVSLB
  else if ( ImgModule->Type == MST_ZVSLB ) iizviewSLB_GetDrvCaps( ImgModule, caps ) ;
#endif
}

static int iizview_Identify(IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf)
{
  ZVIEW_SPECIFIC* zvdata ;
  ZVIMGINFO*      zvinf ;
  unsigned long   status ;
  int             ret = EIMG_SUCCESS ;

  /* Sanity checks */
  if ( !ImgModule || (ImgModule->Specific == NULL) || (ImgModule->hLib == NULL) ) return EIMG_MODULERROR ;
  zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  zvinf  = &zvdata->ImgInfo ;

  /* As we are about to ask zView plugin to allocate stuff */
  /* Free any previous one in case call sequence           */
  /* Identify/Load  was not respected                      */
  if ( zvdata->must_call_reader_quit )
  {
    LoggingDo(LL_INFO, "iizview_Identify calling reader_quit to clean-up") ;
    zvdata->reader_quit( ImgModule, zvinf ) ;
  }
  zvdata->must_call_reader_quit = 0 ; /* We will call reader_quit only if reader_init succeeds */

  status = zvdata->reader_init( ImgModule, name, zvinf ) ;
  LoggingDo(LL_DEBUG, "iizview_Identify reader_init done with %lx", status) ;
  if ( status ) return (int)status ;

  /* Is there a palette to allocate ? */
  inf->palette = NULL ;
  inf->nb_cpal = 0 ;
  inf->nplanes = get_zvnplanes_out( zvinf ) ;

  if ( zvinf->indexed_color || (zvinf->components == 1) ) /* Palette or Monochrome image */
  {
    if ( zvinf->components == 1 )
    {
      inf->nb_cpal = 2 ;
      /* Now change zView fields to let internals know it has (mono) palette */
      zvinf->indexed_color  = 1 ;
      zvinf->palette[0].red = zvinf->palette[0].green = zvinf->palette[0].blue = 1000 ;
      zvinf->palette[1].red = zvinf->palette[1].green = zvinf->palette[1].blue = 0 ;
    }
    else inf->nb_cpal = 1 << zvinf->planes ;
    inf->palette = Xalloc( 6*inf->nb_cpal ) ;
    if ( inf->palette == NULL )
    {
      inf->nb_cpal = 0 ;
      zvdata->reader_quit( ImgModule, zvinf ) ;
      ret = EIMG_NOMEMORY ;
    }
    else
    {
      ZVCOLOR_MAP* rgb ;
      short*       pt_pal = inf->palette ;
      short        i ;

      for ( i = 0, rgb = &zvinf->palette[0]; i < inf->nb_cpal; i++, rgb++ )
      {
        *pt_pal++ = RGB8BToRGBPM[rgb->red] ;
        *pt_pal++ = RGB8BToRGBPM[rgb->green] ;
        *pt_pal++ = RGB8BToRGBPM[rgb->blue] ;
      }
    }
  }

  if ( ret == EIMG_SUCCESS )
  {
    strcpy( inf->filename, name ) ;
    inf->lformat  = ImgModule->Capabilities.iid ;
    inf->compress = 0 ; /* Don't care */
    inf->width    = zvinf->width ;
    inf->height   = zvinf->height ;
    inf->lpix     = 0x150 ; /* zView plugin does not report this information */
    inf->hpix     = 0x150 ; /* zView plugin does not report this information */
    zvdata->must_call_reader_quit = 1 ;
    if ( zvinf->orientation == DOWN_TO_UP ) inf->c.flipflop = FLIPFLOP_Y ;
    LoggingDo(LL_IMG, "iizview_Identify: w=%d, h=%d, planes=%d, components=%d, %ld colors for palette, orientation %d, compression %s", inf->width, inf->height, inf->nplanes, zvinf->components, inf->nb_cpal, zvinf->orientation, zvinf->compression) ;
  }
  else LoggingDo(LL_ERROR, "iizview_Identify for %s: returned error %d", ImgModule->LibFilename, ret) ;

  return ret ;
}

static long fill_mfdb_out(MFDB* out, short zvnplanes_out, unsigned char* mfdb_buffer_out, unsigned char* ibuffer, unsigned long* tctabl)
{
  unsigned long* out32 = (unsigned long*) mfdb_buffer_out ;
  short*         out16 = (short*) mfdb_buffer_out ;
  short          i ;
  long           status = 0 ;

  switch( out->fd_nplanes )
  {
    case 1:
    case 2:
    case 4:
    case 8:  /* We can't have TC as input here as we need dither */
             if ( zvnplanes_out > 8 )
             {
               LoggingDo(LL_ERROR, "iizview_Load %d planes not expected", zvnplanes_out) ;
               status = EIMG_MODULERROR ;
             }
             else ind2raster() ;
             break ;

    case 16: if ( zvnplanes_out <= 8 )
             {
               unsigned short* tctabs = (unsigned short*) tctabl ;

               for ( i = 0; i < out->fd_w; i++ )
                 *out16++ = tctabs[*ibuffer++] ;
             }
             else tc24to16( ibuffer, out16, out->fd_w ) ;
             break ;

    case 24: memcpy( mfdb_buffer_out, ibuffer, 3L*out->fd_w ) ;
             break ;

    case 32: if ( zvnplanes_out <= 8 )
             {
               for ( i = 0; i < out->fd_w; i++ )
                 *out32++ = tctabl[*ibuffer++] ;
             }
             else tc24to32( ibuffer, out32, out->fd_w ) ;
             break ;

    default: status = EIMG_MODULERROR ;
             break ;
  }

  return status ;
}

static int iizview_Load(IMG_MODULE* ImgModule, INFO_IMAGE* inf)
{
  ZVIEW_SPECIFIC* zvdata ;
  ZVIMGINFO*      zvinf ;
  MFDB*           out = &inf->mfdb ;
  unsigned long   tctab[256] ; /* Max */
  unsigned char*  ibuffer = NULL ;
  short           zvnplanes_out ;
  int             ret = EIMG_SUCCESS ;

  /* Sanity checks */
  if ( !ImgModule || (ImgModule->Specific == NULL) || (ImgModule->hLib == NULL) ) return EIMG_MODULERROR ;
  zvdata        = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  zvinf         = &zvdata->ImgInfo ;
  zvnplanes_out = get_zvnplanes_out( zvinf ) ;

  /* We expect to call reader_quit when done with load,   */
  /* If not, Identify was not called or returned an error */
  if ( !zvdata->must_call_reader_quit ) return EIMG_MODULERROR ;

  /* Setup output MFDB */
  if ( zvnplanes_out >= 16 )
  {
    if ( inf->force_16b_load ) out->fd_nplanes = 16 ;
    else if ( inf->final_nb_planes >= 16 )  out->fd_nplanes = inf->final_nb_planes ;
    else                                    out->fd_nplanes = zvnplanes_out ;
  }
  if ( out->fd_nplanes == -1 ) out->fd_nplanes = zvnplanes_out ;
  if ( !zvinf->indexed_color && (out->fd_nplanes == 8) && (zvnplanes_out == 24) ) out->fd_nplanes = inf->force_16b_load ? 16:32 ;
  out->fd_w       = zvinf->width ;
  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
  out->fd_h       = zvinf->height ;
  out->fd_addr    = img_alloc( out->fd_w, 1+out->fd_h, out->fd_nplanes ) ; /* Allocate 1 more line to limit a zview codec buffer overflow */
  if ( out->fd_addr == NULL ) ret = EIMG_NOMEMORY ;
  else                        img_raz( out ) ; /* Might not be required every time, we could optimize */

  if ( ret == EIMG_SUCCESS )
  {
    size_t size = (zvnplanes_out <= 8) ? zvinf->width : 3*zvinf->width ; /* Indexes on 1 byte or TC24 */

    ibuffer = Xcalloc( 1, 1024 + size ) ; /* Allocate 1KB more to limit a zView codec buffer overflow */
    if ( ibuffer == NULL ) ret = EIMG_NOMEMORY ;
    else
    {
      /* The following is required if we deal with index-->bitplanes conversions */
      i2r_init( out, out->fd_w, 1 ) ;
      i2r_nb   = out->fd_w ;
      i2r_data = ibuffer ;
      if ( (zvnplanes_out <= 8) && (out->fd_nplanes > 8) )
      {
        /* If output MFDB is True Color, we need to setup palette to TC */
        make_rgbpal2tc( (unsigned char*)&zvinf->palette[0], zvinf->indexed_color ?  (1<<zvinf->planes):0, (void*)tctab, out->fd_nplanes ) ;
      }
    }
  }

  LoggingDo(LL_IMG, "iizview_Load, MFDB out w=%d, h=%d, nplanes=%d, zvnplanes_out=%d, ibuffer=$%p", out->fd_w, out->fd_h, out->fd_nplanes, zvnplanes_out, ibuffer) ;
  if ( ret == EIMG_SUCCESS )
  {
    unsigned char* mfdb_buffer_out = out->fd_addr ;
    unsigned long  lo_line = img_size( out->fd_w, 1, out->fd_nplanes ) ;
    short          y ;
    long           status = 0 ;
    int            code ;

    for ( y = 0 ; (status == 0) && (y < out->fd_h); y++ )
    {
      /* Get data line from plugin */
      status = zvdata->reader_read( ImgModule, zvinf, ibuffer ) ;
      /* And fill out MFDB from it */
      if ( status == 0 ) status = fill_mfdb_out( out, zvnplanes_out, mfdb_buffer_out, ibuffer, tctab ) ;
      else               ret = (int) status ;
      /* Update pointer to MFDB out for next line */
      mfdb_buffer_out += lo_line ;
      i2rout           = mfdb_buffer_out ; /* Useful only if bitplanes */
      code = GWProgRange( inf->prog, y, out->fd_h, NULL ) ;
      if ( PROG_CANCEL_CODE( code ) )
      {
        ret = EIMG_USERCANCELLED ;
        LoggingDo(LL_INFO, "iizview_Load, user cancelled loading, not commiting this as it would crash reader_quit") ;
      }
    }
  }

  zvdata->reader_quit( ImgModule, &zvdata->ImgInfo ) ;
  zvdata->must_call_reader_quit = 0 ;

  if ( ibuffer ) Xfree( ibuffer ) ;

  if ( ret == EIMG_USERCANCELLED )
  {
    Xfree( out->fd_addr ) ;
    ZeroMFDB( out ) ;
  }
  else if ( ret == EIMG_SUCCESS ) RasterResetUnusedData( out ) ; /* width has to be 16 aligned */
  else                            LoggingDo(LL_ERROR, "iizview_Load returned error %d", ret) ;

  LoggingDo(LL_IMG, "iizview_Load, returns %d", ret) ;
  return ret ;
}

#pragma warn -par
static int iizview_Save(IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  int             ret = EIMG_OPTIONNOTSUPPORTED ;

  /* Not supported right now; must_call_encoder_quit is never set to 1 for safety */
  if ( ImgModule->hLib && zvdata && zvdata->must_call_encoder_quit )
  {
    zvdata->encoder_quit( ImgModule, &zvdata->ImgInfo ) ;
    zvdata->must_call_encoder_quit = 0 ;
  }

  return ret ;
}
#pragma warn +par

static void iizview_Terminate(IMG_MODULE* ImgModule)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;

  if ( ImgModule->hLib && zvdata )
  {
    if ( zvdata->must_call_reader_quit ) zvdata->reader_quit( ImgModule, &zvdata->ImgInfo ) ;
    if ( zvdata->must_call_encoder_quit ) zvdata->encoder_quit( ImgModule, &zvdata->ImgInfo ) ;
  }

  Xfree( zvdata ) ;
  ImgModule->Specific = NULL ;
}

static short iizview_InitPlugin(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata ;
  short           ret = EIMG_MODULERROR ;

  if ( (img_module == NULL) || (img_module->hLib == NULL) ) return EIMG_MODULERROR ;
  zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;
  if ( zvdata == NULL ) return EIMG_MODULERROR ;

  LoggingDo(LL_DEBUG, "Retrieving zView plugin functions from %s...", img_module->LibFilename) ;
  if ( (img_module->Type == MST_ZVLDG) || (img_module->Type == MST_IMGMOD) ) ret = iizvldg_init( img_module ) ;
#ifdef MST_ZVSLB
  else if ( img_module->Type == MST_ZVSLB )                                  ret = iizvslb_init( img_module ) ;
#endif

  if ( ret == EIMG_SUCCESS )
  {
    if ( zvdata->plugin_init ) ret = (short) zvdata->plugin_init( img_module ) ;
    else                       ret = EIMG_MODULERROR ;
  }

  LoggingDo(LL_DEBUG, "zView plugin initialization returned %d", ret) ;

  return ret ;
}

short iizview_init(char type, IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata ;
  int             ret = EIMG_MODULERROR ;

  /* First allocate room for zView own stuff and free previous one if any */
  if ( img_module->Specific ) Xfree( img_module->Specific ) ;
  img_module->Specific = Xcalloc( 1, sizeof(ZVIEW_SPECIFIC) ) ;
  zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;
  if ( zvdata == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate %ld bytes for zView module", sizeof(ZVIEW_SPECIFIC)) ;
    return EIMG_NOMEMORY ;
  }

  if ( img_module->hLib && img_module->LibFilename )
  {
    char* c = strrchr( img_module->LibFilename, '\\' ) ;

    if ( c ) strncpy( zvdata->lib_name, 1+c, sizeof(zvdata->lib_name)-1 ) ;
    else     strncpy( zvdata->lib_name, img_module->LibFilename, sizeof(zvdata->lib_name)-1 ) ;

    /* Initialize IMG_MODULE interface */
    img_module->Type       = type ;
    img_module->IsDynamic  = 1 ;
    img_module->GetDrvCaps = iizview_GetDrvCaps ;
    img_module->Identify   = iizview_Identify ;
    img_module->Load       = iizview_Load ; 
    img_module->Save       = iizview_Save ;
    img_module->Terminate  = iizview_Terminate ;

    /* Initialize zView plugin interface */
    ret = iizview_InitPlugin( img_module ) ;
  }

  if ( ret != EIMG_SUCCESS ) LoggingDo(LL_ERROR, "iizview_init for %s: error %d", img_module->LibFilename, ret) ;

  return ret ;
}
