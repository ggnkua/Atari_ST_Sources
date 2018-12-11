/******************************************************************************/
/* ZVIEWMOD.C: wrapper for exposing LDI interface from ZVIEW plugin interface */
/******************************************************************************/

#include <string.h>
#include <stdlib.h>

#include "xalloc.h"
#include "imgmodul.h"
#include "rasterop.h"
#include "iizview.h"
#include "logging.h"


/* This is extracted from zview.h and arranged for VISION */
#define UP_TO_DOWN 		0
#define DOWN_TO_UP		1

typedef struct
{
  unsigned char	red ;
  unsigned char	green ;
  unsigned char	blue ;
  /* Note that compiler includes a char filed here to align each structure element on 16bit */
}
ZVCOLOR_MAP ;


typedef struct _img_info
{
  /* Data returned by the decoder Picture's initialisation */
  unsigned short width ;               /* Picture width                                          */
  unsigned short height ;              /* Picture Height                                         */
  unsigned short components ;          /* Picture components                                     */
  unsigned short planes ;              /* Picture bits by pixel                                  */
  unsigned long  colors ;              /* Picture colors number                                  */
  short         orientation ;          /* Picture orientation: UP_TO_DOWN or DONW_TO_UP (ex TGA) */
  unsigned short page ;                /* Number of page/image in the file                       */
  unsigned short delay ;               /* Animation delay in 200th sec. between each frame.      */
  unsigned short num_comments ;        /* Lines in the file's comment. ( 0 if none)              */
  unsigned short max_comments_length ; /* The length of the greater line in the comment          */
  short          indexed_color ;       /* Picture has a palette: 0) No 1) Yes                    */
  short          memory_alloc ;        /* where to do the memory allocation for the reader_read 
                                          function buffer, possible values are ST_RAM or TT_RAM  */
  ZVCOLOR_MAP    palette[256] ;        /* Palette in standard RGB format                         */

  /* data send to the codec */
  unsigned long  background_color ;    /* The wanted background's color in hexa                  */
  short          thumbnail ;           /* 1 if true else 0.
                                          Some format have thumbnail inside the picture, if 1, we
                                          want only this thumbnail and not the image itself      */
  unsigned short page_wanted ;         /* The wanted page to get for the reader_read() function
                                          The first page is 0 and the last is img_info->page - 1 */

  /* The following variable are only for Information Prupose, the zview doesn't
     use it for decoding routine but only for the information dialog								             */ 
  char           info[40] ;            /* Picture's info, for ex: "Gif 87a" 						         */
  char           compression[5] ;      /* Compression type, ex: "LZW" 								           */
  unsigned short real_width ;          /* Real picture width( if the thumbnail variable is 1)		 */
  unsigned short real_height ;         /* Ral picture Height( if the thumbnail variable is 1)		 */


  /* Private data for the plugin */
  void* _priv_ptr ;
  void* _priv_ptr_more ;
  void* __priv_ptr_more ;

  long  _priv_var ;
  long  _priv_var_more ;
}
ZVIMGINFO, *PZVIMGINFO ;

typedef struct _txt_data
{
	short	lines ;             /* Number of lines in the text                   */
	short	max_lines_length ;  /* The length of the greater line ( in nbr char) */
	char* txt[256] ;
}
txt_data ;

typedef struct
{
  ZVIMGINFO ImgInfo ;
  char      must_call_reader_quit ;
  char      must_call_encoder_quit ;
  char      ldg_name[32] ;

  /* zView pluging interface  */
  /* Always check ImgModule->Ldg before calling any of these */
  /* As caller may have unloaded LDG without any notice      */
  void          cdecl (*plugin_init)(void) ;
  unsigned long cdecl (*reader_init)(const char* name, ZVIMGINFO* info) ;
  unsigned long cdecl (*reader_read)(ZVIMGINFO* info, unsigned char* buffer) ;
  void          cdecl (*reader_get_txt)(ZVIMGINFO* info, txt_data* txtdata);
  void          cdecl (*reader_quit)(ZVIMGINFO* info) ;
  unsigned long cdecl (*encoder_init)(const char* name, ZVIMGINFO* info) ;
  unsigned long cdecl (*encoder_write)(ZVIMGINFO* info, unsigned char* buffer) ;
  void          cdecl (*encoder_quit)(ZVIMGINFO* info) ;
}
ZVIEW_SPECIFIC, *PZVIEW_SPECIFIC ;


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

static long iizview_GetIID(LDG* ldg)
{
  long iid = 0 ;

  /* First let's try to match VISION's IIDs for common image support */
  if ( memcmp( ldg->infos, "BMP", 3 ) == 0 ) iid = IID_BMP ;
  else if ( memcmp( ldg->infos, "PI1", 3 ) == 0 ) iid = IID_DEGAS ;
  else if ( memcmp( ldg->infos, "GIF", 3 ) == 0 ) iid = IID_GIF ;
  else if ( memcmp( ldg->infos, "IMG", 3 ) == 0 ) iid = IID_IMG ;
  else if ( memcmp( ldg->infos, "NEO", 3 ) == 0 ) iid = IID_NEO ;
  else if ( memcmp( ldg->infos, "JPG", 3 ) == 0 ) iid = IID_JPEG ;
  else if ( memcmp( ldg->infos, "PNG", 3 ) == 0 ) iid = IID_PNG ;
  else if ( memcmp( ldg->infos, "TGA", 3 ) == 0 ) iid = IID_TARGA ;
  else if ( memcmp( ldg->infos, "TIF", 3 ) == 0 ) iid = IID_TIFF ;

  if ( iid == 0 )
  {
    /* LDG infos field holds all extensions padded on 3 characters */
    /* Let's use this information to guess the format, hopefully   */
    /* It is looking like VISION IIDs but in reverse order         */
    iid |= ldg->infos[0] ; iid <<= 8 ;
    iid |= ldg->infos[1] ; iid <<= 8 ;
    iid |= ldg->infos[2] ; iid <<= 8 ;
  }

  return iid ;
}

static void iizview_GetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  int             ke_size ;
  char*           c, *d ;
  char            ldg_name[32] ;

  strncpy( ldg_name, zvdata->ldg_name, sizeof(ldg_name) ) ;
  c = strrchr( ldg_name, '.' ) ;
  if ( c ) *c = 0 ; /* Remove extension */
  caps->iid = iizview_GetIID( ImgModule->Ldg ) ;
  strcpy( caps->short_name, ldg_name ) ;
  memcpy( caps->file_extension, ImgModule->Ldg->infos, 3 ) ;
  caps->file_extension[3] = 0 ;
  strcpy( caps->name, ldg_name ) ;
  caps->version = ImgModule->Ldg->vers ;

  /* There are no capabilities returned by zView plugin interface,        */
  /* Let's assume all of them after sanity checks to not prevent anything */
  caps->import = caps->export = 0 ;
  if ( zvdata->reader_init && zvdata->reader_read && zvdata->reader_quit )
    caps->import = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

  if ( zvdata->encoder_init && zvdata->encoder_write && zvdata->encoder_quit )
    caps->export = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE | IEF_LZW | IEF_PBIT | IEF_JPEG ;

  c       = ImgModule->Ldg->infos ;
  d       = caps->known_extensions ;
  ke_size = (int) sizeof(caps->known_extensions) ;
  while ( *c && (ke_size > 2) )
  {
    /* JPGJPE--> JPG\0JPE\0\0*/
    *d++ = *c++ ;
    *d++ = *c++ ;
    *d++ = *c++ ;
    *d++ = 0 ;
    ke_size -= 4 ;
  }
  *d++ = 0 ;
}

static int iizview_Identify(IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf)
{
  ZVIEW_SPECIFIC* zvdata ;
  ZVIMGINFO*      zvinf ;
  unsigned long   status_ok = 0 ;
  int             ret = EIMG_SUCCESS ;

  /* Sanity checks */
  if ( !ImgModule || (ImgModule->Specific == NULL) || (ImgModule->Ldg == NULL) ) return EIMG_MODULERROR ;
  zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  if ( zvdata == NULL ) return EIMG_MODULERROR ;
  zvinf  = &zvdata->ImgInfo ;

  /* As we are about to ask zView plugin to allocate stuff */
  /* Free any previous one in case call sequence           */
  /* Identify/Load  was not respected                      */
  if ( zvdata->must_call_reader_quit && zvdata->reader_quit )
    zvdata->reader_quit( zvinf ) ;
  zvdata->must_call_reader_quit = 0 ;

  if ( zvdata->reader_init ) status_ok = zvdata->reader_init( name, zvinf ) ;
  else                       LoggingDo(LL_ERROR, "iizview_Identify: reader_init is NULL") ;
  if ( !status_ok ) return EIMG_MODULERROR ;

  /* Is there a palette to allocate ? */
  inf->palette = NULL ;
  inf->nb_cpal = 0 ;
  inf->nplans  = get_zvnplanes_out( zvinf ) ;

  if ( zvinf->indexed_color || (zvinf->components == 1) ) /* Palette or Monochrome image */
  {
    short* pt_pal ;

    if ( zvinf->components == 1 )
    {
      inf->nb_cpal = 2 ;
      /* Now change zView fields to let VISION know it has (mono) palette */
      zvinf->indexed_color  = 1 ;
      zvinf->palette[0].red = zvinf->palette[0].green = zvinf->palette[0].blue = 1000 ;
      zvinf->palette[1].red = zvinf->palette[1].green = zvinf->palette[1].blue = 0 ;
    }
    else inf->nb_cpal = 1 << zvinf->planes ;
    inf->palette = Xalloc( 6*inf->nb_cpal ) ;
    pt_pal       = inf->palette ;
    if ( inf->palette == NULL )
    {
      inf->nb_cpal = 0 ;
      if ( zvdata->reader_quit ) zvdata->reader_quit( zvinf ) ;
      ret = EIMG_NOMEMORY ;
    }
    else
    {
      ZVCOLOR_MAP* rgb ;
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
    strcpy( inf->nom, name ) ;
    inf->lformat     = ImgModule->Capabilities.iid ;
    inf->compress    = 0 ; /* Don't care */
    inf->largeur     = zvinf->real_width ;
    inf->hauteur     = zvinf->real_height ;
    inf->lpix        = 0x150 ; /* zView plugin does not report this information */
    inf->hpix        = 0x150 ; /* zView plugin does not report this information */
    inf->vdi_palette = 0 ;
    zvdata->must_call_reader_quit = 1 ;
    if ( zvinf->orientation == DOWN_TO_UP ) inf->flipflop = FLIPFLOP_Y ;
    LoggingDo(LL_IMG, "iizview_Identify: w=%d, h=%d, planes=%d, components=%d, %ld colors for palette, orientation %d", inf->largeur, inf->hauteur, inf->nplans, zvinf->components, inf->nb_cpal, zvinf->orientation) ;
  }

  if ( ret != EIMG_SUCCESS ) LoggingDo(LL_ERROR, "iizview_Identify for %s: returned error %d", ImgModule->LdgFilename, ret) ;

  return ret ;
}

static short fill_mfdb_out(MFDB* out, short zvnplanes_out, unsigned char* mfdb_buffer_out, unsigned char* ibuffer, unsigned long* tctabl)
{
  unsigned long* out32 = (unsigned long*) mfdb_buffer_out ;
  short*         out16 = (short*) mfdb_buffer_out ;
  short          i ;
  short          status_ok = 1 ;

  switch( out->fd_nplanes )
  {
    case 1:
    case 2:
    case 4:
    case 8:  /* We can't have TC as input here as we need dither */
             if ( zvnplanes_out > 8 )
             {
               LoggingDo(LL_ERROR, "iizview_Load %d planes not expected", zvnplanes_out) ;
               status_ok = 0 ;
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

    default: status_ok = 0 ;
             break ;
  }

  return status_ok ;
}

#pragma warn -par
static int iizview_Load(IMG_MODULE* ImgModule, char* name, MFDB* out, GEM_WINDOW* wprog)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  ZVIMGINFO*      zvinf ;
  unsigned long   tctab[256] ; /* Max */
  unsigned char*  ibuffer = NULL ;
  short           zvnplanes_out ;
  int             ret = EIMG_SUCCESS ;

  /* Sanity checks */
  if ( !ImgModule || (ImgModule->Specific == NULL) || (ImgModule->Ldg == NULL) ) return EIMG_MODULERROR ;
  zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  if ( zvdata == NULL ) return EIMG_MODULERROR ;
  zvinf         = &zvdata->ImgInfo ;
  zvnplanes_out = get_zvnplanes_out( zvinf ) ;

  /* We expect to call reader_quit when done with load,   */
  /* If not, Identify was not called or returned an error */
  if ( !zvdata->must_call_reader_quit ) return EIMG_MODULERROR ;
  if ( !zvdata->reader_read ) return EIMG_MODULERROR ;

  /* Setup output MFDB */
  if ( zvnplanes_out >= 16 )
  {
    if ( Force16BitsLoad ) out->fd_nplanes = 16 ;
    else if ( FinalNbPlanes >= 16 )  out->fd_nplanes = FinalNbPlanes ;
    else out->fd_nplanes = zvnplanes_out ;
  }
  if ( out->fd_nplanes == -1 ) out->fd_nplanes = zvnplanes_out ;
  if ( !zvinf->indexed_color && (out->fd_nplanes == 8) && (zvnplanes_out == 24) ) out->fd_nplanes = Force16BitsLoad ? 16:32 ;
  out->fd_w       = zvinf->real_width ;
  out->fd_wdwidth = out->fd_w / 16 ;
  if ( out->fd_w % 16 ) out->fd_wdwidth++ ;
  out->fd_h    = zvinf->real_height ;
  out->fd_addr = img_alloc( out->fd_w, 1+out->fd_h, out->fd_nplanes ) ; /* Allocate 1 more line to limit a view codec buffer overflow */
  if ( out->fd_addr == NULL ) ret = EIMG_NOMEMORY ;
  else                        img_raz( out ) ; /* Might not be required every time, we could optimize */

  if ( ret == EIMG_SUCCESS )
  {
    size_t size = (zvnplanes_out <= 8) ? zvinf->real_width : 3*zvinf->real_width ; /* Indexes on 1 byte or TC24 */

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
    short          status_ok = 1 ;

    for ( y = 0 ; status_ok && (y < out->fd_h); y++ )
    {
      /* Get data line from plugin */
      status_ok = (int) zvdata->reader_read( zvinf, ibuffer ) ;
      /* And fill out MFDB from it */
      if ( status_ok  )
        status_ok = fill_mfdb_out( out, zvnplanes_out, mfdb_buffer_out, ibuffer, tctab ) ;
      /* Update pointer to MFDB out for next line */
      mfdb_buffer_out += lo_line ;
      i2rout           = mfdb_buffer_out ; /* Useful only if bitplanes */
    }
  }

  if ( ibuffer ) Xfree( ibuffer ) ;
  if ( zvdata->reader_quit )
  {
    LoggingDo(LL_DEBUG, "iizview_Load:reader_quit") ;
    zvdata->reader_quit( &zvdata->ImgInfo ) ;
    zvdata->must_call_reader_quit = 0 ;
  }

  if ( ret == EIMG_SUCCESS )
  {
    RasterResetUnusedData( out ) ; /* VISION expects width to be 16 aligned */
  }
  else LoggingDo(LL_ERROR, "iizview_Load returned error %d", ret) ;

  LoggingDo(LL_IMG, "iizview_Load, returns %d", ret) ;
  return ret ;
}

static int iizview_Save(IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;
  int             ret = -3 ;

  if ( ImgModule->Ldg && zvdata && zvdata->must_call_encoder_quit && zvdata->encoder_quit )
  {
    LoggingDo(LL_DEBUG, "encoder_quit") ;
    zvdata->encoder_quit( &zvdata->ImgInfo ) ;
    zvdata->must_call_encoder_quit = 0 ;
  }

  return ret ;
}

static void iizview_Terminate(IMG_MODULE* ImgModule)
{
  ZVIEW_SPECIFIC* zvdata = (ZVIEW_SPECIFIC*) ImgModule->Specific ;

  if ( ImgModule->Ldg && zvdata && zvdata->must_call_reader_quit && zvdata->reader_quit )
  {
    LoggingDo(LL_DEBUG, "reader_quit") ;
    zvdata->reader_quit( &zvdata->ImgInfo ) ;
    zvdata->must_call_reader_quit = 0 ;
  }
  if ( ImgModule->Ldg && zvdata && zvdata->must_call_encoder_quit && zvdata->encoder_quit )
  {
    LoggingDo(LL_DEBUG, "encoder_quit") ;
    zvdata->encoder_quit( &zvdata->ImgInfo ) ;
    zvdata->must_call_encoder_quit = 0 ;
  }
  if ( ImgModule->Specific ) Xfree( ImgModule->Specific ) ;
  ImgModule->Specific = NULL ;
}
#pragma warn +par

static int iizview_InitPlugin(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata ;

  if ( (img_module == NULL) || (img_module->Ldg == NULL) ) return EIMG_MODULERROR ;
  zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;
  if ( zvdata == NULL ) return EIMG_MODULERROR ;

  zvdata->plugin_init    = ldg_find( "plugin_init",    img_module->Ldg ) ;
  zvdata->reader_init    = ldg_find( "reader_init",    img_module->Ldg ) ;
  zvdata->reader_read    = ldg_find( "reader_read",    img_module->Ldg ) ;
  zvdata->reader_get_txt = ldg_find( "reader_get_txt", img_module->Ldg ) ;
  zvdata->reader_quit    = ldg_find( "reader_quit",    img_module->Ldg ) ;
  zvdata->encoder_init   = ldg_find( "encoder_init",   img_module->Ldg ) ;
  zvdata->encoder_write  = ldg_find( "encoder_write",  img_module->Ldg ) ;
  zvdata->encoder_quit   = ldg_find( "encoder_quit",   img_module->Ldg ) ;

  if ( zvdata->plugin_init ) zvdata->plugin_init() ;
  else                       return EIMG_MODULERROR ;

  return EIMG_SUCCESS ;
}

int iizview_init(IMG_MODULE* img_module)
{
  ZVIEW_SPECIFIC* zvdata ;
  int             ret = EIMG_MODULERROR ;

  /* First allocate room for ZView own stuff and free previous one if any */
  if ( img_module->Specific ) Xfree( img_module->Specific ) ;
  img_module->Specific = Xcalloc( 1, sizeof(ZVIEW_SPECIFIC) ) ;
  zvdata = (ZVIEW_SPECIFIC*) img_module->Specific ;
  if ( zvdata == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate %ld bytes for ZView module", sizeof(ZVIEW_SPECIFIC)) ;
    return EIMG_NOMEMORY ;
  }

  if ( img_module->Ldg && img_module->LdgFilename )
  {
    char* c = strrchr( img_module->LdgFilename, '\\' ) ;

    if ( c ) strncpy( zvdata->ldg_name, 1+c, sizeof(zvdata->ldg_name)-1 ) ;
    else     strncpy( zvdata->ldg_name, img_module->LdgFilename, sizeof(zvdata->ldg_name)-1 ) ;
	/* Initialize IMG_MODULE interface */
    img_module->Type       = MST_ZVLDG ;
    img_module->IsDynamic  = 1 ;
    img_module->GetDrvCaps = iizview_GetDrvCaps ;
    img_module->Identify   = iizview_Identify ;
    img_module->Load       = iizview_Load ; 
    img_module->Save       = iizview_Save ;
    img_module->Terminate  = iizview_Terminate ;
	/* Initialize zView plugin interface */
    ret = iizview_InitPlugin( img_module ) ;
  }

  if ( ret != EIMG_SUCCESS ) LoggingDo(LL_ERROR, "iizview_init for %s: returned error %d", img_module->LdgFilename, ret) ;

  return ret ;
}
