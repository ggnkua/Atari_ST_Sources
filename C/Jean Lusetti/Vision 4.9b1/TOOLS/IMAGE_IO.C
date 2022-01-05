/****************************************/
/*------------- IMAGE_IO.C -------------*/
/* Ensemble de routines d'entr‚e-sortie */
/* D'images sp‚cifiques Atari           */
/****************************************/
#include   <math.h>
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include      "xgem.h"
#include     "xfile.h"
#include  "gwindows.h"
#include   "cookies.h"
#include    "dither.h"
#include  "rasterop.h"
#include  "imgmodul.h"
#include    "me_ldg.h"
#include   "logging.h"

#include  "defs.h"

#define MINIW 16
#define MINIH 16

typedef struct _RSC_HISTO
{
  MFDB           std_img ;
  int            tos_pal[256*3] ;
  unsigned char  std_level[3*HISTO_SIZE] ;
  unsigned char* std_data ;
  unsigned char* occup_couleurs ;
}
RSC_HISTO, *PRSC_HISTO ;

unsigned char palind[256] ; /* Nouveaux indices palette TOS des 256 couleurs */
char          NbBitsIn[256] ;


/****************************************************************/
/* Adapte la palette de couleurs pour un raster 8 ou 16 plans   */
/* Issu d'un raster 2 plans qui a ‚t‚ transform‚. On doit tenir */
/* Compte du fait que l'indice TOS %11 (2 plans) correspond aux */
/* Indices TOS %1111 (4 plans) et %11111111 (8 plans)           */
/****************************************************************/
void rtos2(MFDB* data)
{
  short          i, j, nplan ;
  unsigned short mask, val ;
  short          *pt1, *pt2, *pt ;

  nplan = data->fd_nplanes ;
  pt1   = data->fd_addr ;
  pt2   = pt1+1 ;
  for (j = 0; j < data->fd_h; j++)
    for (i = 0; i < data->fd_w; i+= 16)
    {
      for ( val = 0, mask = 0x8000; mask != 0; mask >>= 1 )
      {
        if ( (*pt1 & mask) && (*pt2 & mask) ) val |= mask ;
      }
      pt   = 1+pt2 ;
      pt1 += nplan ;
      pt2 += nplan ;
      if ( val )
      {
        if ( nplan != 4 )
        {
          *pt++ = val ;
          *pt++ = val ;
          *pt++ = val ;
          *pt++ = val ;
        }
        *pt++ = val ;
        *pt   = val ;
      }
    }
}

void raster2imgline(int* raster, int* img_line, size_t long_ligne, int nplanes)
{
  int i, j, lplan ;
  int *pt1, *pt2 ;
  
  if ( nplanes == 1 )
  {
    memcpy( img_line, raster, long_ligne ) ;
    return ;
  }

  pt2   = img_line ;
  lplan = (int) long_ligne/nplanes/2 ;
  for ( i = 0; i < nplanes; i++ )
  {
    pt1 = raster + i ;
    for ( j = 0; j < lplan; j++ )
    {
      *pt2++ = *pt1 ;
      pt1   += nplanes ;
    }
  }
}

void make_safepalette(INFO_IMAGE* inf)
{
  long n ;
  int* pt ;

  if ( inf->palette )
  {
    pt = (int*) inf->palette ;
    for ( n = 0; n < 3*inf->nb_cpal; n++, pt++ )
    {
      if ( *pt > 1000 )   *pt = 1000 ;
      else if ( *pt < 0 ) *pt = 0 ;
    }
  }
}

int incnbplanes(MFDB* data, int nb_plan, int* cancel_stdvdi)
{
  MFDB temp ;

  if ( (nb_plan > 8) && (data->fd_nplanes != 1) ) return 0 ; /* Non valide, utiliser index2truecolor */

  CopyMFDB( &temp, data ) ;
  data->fd_addr = img_alloc( data->fd_w, data->fd_h, nb_plan ) ;
  if ( data->fd_addr == NULL )
  {
    Xfree( temp.fd_addr ) ;
    return EIMG_NOMEMORY ;
  }

  if ( data->fd_nplanes == 1 ) /* Si l'image est monochrome, la */
  {                            /* VDI s'occupe de la conversion */
    int   pal[3*256] ;
    int*  pt_pal = pal ;
    int   xy[8] ;
    int   color_index[2] ;
    short val, cmin, cmax ; /* min/max values for color intensity */
    short imin, imax ;      /* Corresponding indexes in palette   */
    short i ;

    get_vdipalette( pal ) ;
    cmin = 3*1000 ; cmax = 0 ;
    imin = imax = 0 ;
    for ( i = 0; i < screen.fd_nplanes; i++ )
    {
      val  = *pt_pal++ ;
      val += *pt_pal++ ;
      val += *pt_pal++ ;
      if ( val < cmin ) { cmin = val ; imin = i ; } ;
      if ( val > cmax ) { cmax = val ; imax = i ; } ;
    }
    color_index[0] = imax ; /* Color index for pixel set     */
    color_index[1] = imin ; /* Color index for pixel not set */
    LoggingDo( LL_DEBUG, "incnbplanes with 1 plane source, index black=%d, index_white=%d", imin, imax ) ;
    data->fd_nplanes = nb_plan ;
    xy[0] = 0 ; xy[1] = 0 ; xy[2] = temp.fd_w-1 ; xy[3] = temp.fd_h-1 ;
    xy[4] = 0 ; xy[5] = 0 ; xy[6] = temp.fd_w-1 ; xy[7] = temp.fd_h-1 ;
    vrt_cpyfm( handle, MD_REPLACE, xy, &temp, data, color_index ) ;
    if ( cancel_stdvdi ) *cancel_stdvdi = 1 ;
  }
  else
  {
    int *pt_in, *pt_out ;
    int add_out, add_in ;
    int i, j, nb ;

    memzero( data->fd_addr, img_size(data->fd_w, data->fd_h, nb_plan) ) ;
    add_in  = data->fd_nplanes ;
    add_out = nb_plan ;
    pt_in   = (int*) temp.fd_addr ;
    pt_out  = (int*) data->fd_addr ;
    nb      = 2*data->fd_nplanes ;
    for (j = 0; j < data->fd_h; j++)
      for (i = 0; i < data->fd_w; i += 16)
      {
        memcpy( pt_out, pt_in, nb ) ;
        pt_out += add_out ;
        pt_in  += add_in ;
      }
    
    data->fd_nplanes = nb_plan ;
    if ( add_in == 2 ) /* Cas particulier 2 plans, il     */
      rtos2(data) ;  /* Faut ajuster les couleurs       */
                     /* TOS 2 plans -> TOS 4 ou 8 plans */
  }
  
  Xfree( temp.fd_addr ) ;
  return 0 ;
}

int decnbplanes(MFDB* in, MFDB* out)
{
  int x, y ;
  int *pt1, *pt2 ;
  int inc_in ;
  int i ;
  
  if ( in->fd_nplanes <= out->fd_nplanes )  return -1 ;
  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;
  
  inc_in = in->fd_nplanes-out->fd_nplanes ;
  pt1    = in->fd_addr ;
  pt2    = out->fd_addr ;
  for ( y = 0; y < in->fd_h; y++ )
    for ( x = 0;  x < in->fd_w; x += 16 )
    {
      for ( i = 0; i < out->fd_nplanes; i++ ) *pt2++ = *pt1++ ;
      pt1 += inc_in ;
    }
  
  return 0 ;
}

void smart_fit(MFDB* in, MFDB* out, int* xy)
{
  MFDB          tmp ;
  long          lo_src, lo_dst ;
  int           *src, *dst ;
  int           l ;
  char          old_ignore_a16 = ignore_a16 ;
  unsigned char buffer[2048] ;

  ignore_a16 = 1 ; /* On n'est pas forcemement aligne sur 16 bits */
  lo_src = img_size( in->fd_w, 1, in->fd_nplanes ) >> 1 ;   /* In words */
  lo_dst = img_size( out->fd_w, 1, out->fd_nplanes ) >> 1 ;   /* In words */
  src    = (int*) in->fd_addr ;
  src   += (long)xy[1]*lo_src ;
  dst    = (int*) out->fd_addr ;
  dst   += (long)xy[5]*lo_dst ;
  CopyMFDB( &tmp, out ) ;
  if ( in->fd_nplanes <= 8 )
  {
    tmp.fd_addr = dst ;
    i2r_init(&tmp, tmp.fd_w, 1) ;
    i2r_nb     = 1+xy[2]-xy[0] ;
    i2r_data   = buffer+xy[0] ;
    if ( i2r_nb >= 16 ) /* Need a minimum */
    {
      for (l = xy[1]; l <= xy[3]; l++)
      {
        raster2ind( src, buffer, in->fd_w, in->fd_nplanes ) ;
        i2rout = dst ;
        i2rx   = xy[4] ;
        ind2raster() ;
        dst += lo_dst ;
        src += lo_src ;
      }
    }
  }
  else
  {
    for ( l = xy[1]; l <= xy[3]; l++ )
    {
      memcpy( dst, src, lo_src << 1 ) ;
      dst += lo_dst ; /* Was: these 2 lines after the loop ?? */
      src += lo_src ;
    }
  }

  ignore_a16 = old_ignore_a16 ;
}

/************************************************************/
/* Agrandit si n‚cessaire l'image … au moins 64x64 pour     */
/* Pouvoir ˆtre correctement affich‚e dans une fenˆtre GEM. */
/* En retour :  0 : OK                                      */
/*             EIMG_NOMEMORY : M‚moire insuffisante         */
/************************************************************/
int img_extend(INFO_IMAGE* inf)
{
  MFDB* img = &inf->mfdb ;
  MFDB  temp ;
  int   xy[8] ;

  if ( (img->fd_w >= MINIW) && (img->fd_h >= MINIH) ) return 0 ;

  CopyMFDB( &temp, img ) ;
  if ( temp.fd_w < MINIW ) temp.fd_w = MINIW ;
  if ( temp.fd_h < MINIH ) temp.fd_h = MINIH ;
  temp.fd_wdwidth = w2wdwidth( temp.fd_w ) ;
  temp.fd_addr    = img_alloc( temp.fd_w, temp.fd_h, temp.fd_nplanes ) ;
  if ( temp.fd_addr == NULL )
  {
    Xfree( img->fd_addr ) ;
    img->fd_addr = NULL ;
    return EIMG_NOMEMORY ;
  }

  img_raz( &temp ) ;
  xy[0] = xy[1] = xy[4] = xy[5] = 0 ;
  xy[2] = xy[6] = img->fd_w-1 ;
  xy[3] = xy[7] = img->fd_h-1 ;
  if ( img->fd_nplanes <= 8 ) smart_fit( img, &temp, xy ) ;
  else  if ( img->fd_nplanes == 16 ) vro_cpyfmtc16(xy, img, &temp ) ;
  else  if ( img->fd_nplanes == 24 ) vro_cpyfmtc24(xy, img, &temp ) ;
  else vro_cpyfm( handle, S_ONLY, xy, img, &temp ) ;

  Xfree( img->fd_addr ) ;
  CopyMFDB( img, &temp ) ;
  inf->width  = img->fd_w ;
  inf->height = img->fd_h ;

  return 0 ;
}

/*static long rvbdist(int r1, int g1, int b1, int r2, int g2, int b2)*/
static long rvbdist(int* rgb1, int* rgb2)
{
  long d, cd ;

  d  = *rgb2 - *rgb1 ;
  d *= d ;
  rgb1++ ; rgb2++ ;
  cd = *rgb2 - *rgb1 ;
  d += cd*cd ;
  rgb1++ ; rgb2++ ;
  cd = *rgb2 - *rgb1 ;
  d += cd*cd ;

  return d ;
}

void gem_protect(INFO_IMAGE* inf)
{
  long          min_acceptable = 3L*100L*100L ;
  long          min, d ;
  int           pal[3*256] ;
  int           i, j, newind, ind, tosind ;
  int           *iptpal, *pptpal ;
  int           must_remap_indexes = 1 ;
  unsigned char *vdi2tos ;

  for (i = 0; i < 256; i++) palind[i] = (unsigned char)i ;
  if ( inf->nplanes != 8 ) return ;

  vdi2tos = get_ptvdi2tos( inf->nplanes ) ;
  memcpy( pal, inf->palette, inf->nb_cpal*3*2 ) ;
  if ( old_pal ) memcpy( pal, old_pal, 16*3*2 ) ;
  pal[255*3] = pal[1+255*3] = pal[2+255*3] = 1000 ;
  pptpal = (int*) pal ;
  iptpal = (int*) inf->palette ;
  for (i = 0; i < 16; i++)
  {
    tosind = vdi2tos[i] ;
    min    = 6000000L ;
    for (j = 16; j < inf->nb_cpal-1; j++)
    {
      ind = vdi2tos[j] ;
      d   = rvbdist( &iptpal[3*tosind], pptpal+3*ind ) ;
      if ( d < min )
      {
        min    = d ;
        newind = ind ;
      }
    }
    if ( min <= min_acceptable ) palind[tosind] = (unsigned char)newind ;
    else                         must_remap_indexes = 0 ;
  }

  if ( must_remap_indexes )
  {
    tosind = vdi2tos[255] ;
    min    = 6000000L ;
    for (j = 16; j < 254; j++)
    {
      ind = vdi2tos[j] ;
      d   = rvbdist( &iptpal[3*tosind], pptpal+3*ind) ;
      if ( d < min )
      {
        min    = d ;
        newind = ind ;
      }
    }
    if ( min <= min_acceptable ) palind[tosind] = (unsigned char)newind ;
    else                         must_remap_indexes = 0 ;
  }

  if ( !must_remap_indexes ) 
    for ( i = 0; i < 256; i++ ) palind[i] = (unsigned char)i ;
  else
    memcpy(inf->palette, pal, inf->nb_cpal*3*2) ;
}

static int AssertModuleForFile(IMG_MODULE* img_module, char* name, INFO_IMAGE* inf)
{
  int ret = IMIdentify( img_module, name, inf ) ;

  if ( ret == EIMG_SUCCESS ) inf->lformat = img_module->Capabilities.iid ;

  return ret ;
}

static int check_module_caps(IMG_MODULE* img_module, INFO_IMAGE* inf)
{
  INFO_IMAGE_DRIVER* caps ;
  IID                lfmt = inf->lformat ;
  int                ret = EIMG_SUCCESS ;

  if ( inf->img_analyse && inf->palette )
    if ( ( lfmt != IID_DEGAS ) && ( lfmt != IID_ART ) && ( lfmt != IID_IMG ) ||
         ( lfmt != IID_MAC )   && ( lfmt != IID_NEO )
       )
    gem_protect( inf ) ;

  caps = &img_module->Capabilities ;
  /* Make sure returned number of planes is supported by module */
  switch( inf->nplanes )
  {
    case 1  : if ( (caps->import & IEF_P1) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    case 2  : if ( (caps->import & IEF_P2) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    case 4  : if ( (caps->import & IEF_P4) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    case 8  : if ( (caps->import & IEF_P8) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    case 16 : if ( (caps->import & IEF_P16) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    case 24 : if ( (caps->import & IEF_P24) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    case 32 : if ( (caps->import & IEF_P32) == 0 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
    default : /* Don't fail if nplanes <= 16 as nplanes=7 (128color) is possible (e.g. QPAINT) */
              /* But caller does not have support for this exotic number of planes             */
              if ( inf->nplanes > 16 ) ret = EIMG_OPTIONNOTSUPPORTED ;
              break ;
  }

  /* Don't forget to free stuff if we failed at this stage */
  if ( ret != EIMG_SUCCESS ) free_info( inf ) ;

  return ret ;
}

static void init_info(char* name, INFO_IMAGE* inf)
{
  INFO_IMAGE inf_cpy ;

  /* Backup all information before erasing the structure */
  memcpy( &inf_cpy, inf, sizeof(INFO_IMAGE) ) ;

  /* Now initialize the structure with reset values */
  memzero( inf, sizeof(INFO_IMAGE) ) ;
  strcpy( inf->filename, name ) ;
  perf_reset( PERF_ALL, &inf->perf_info ) ;
  inf->c.f.jpg.quality = 85 ; /* Set a fair JPEG quality by default */

  /* And restore back the relevant information */
  inf->lformat       = inf_cpy.lformat ;
  inf->dither_method = inf_cpy.dither_method ;
  inf->img_analyse   = inf_cpy.img_analyse ;
}

int img_format(char* name, INFO_IMAGE* inf)
{
  IMG_MODULE* img_module ;
  char        ext[10] ;
  int         i, j, ret = EIMG_UNKOWNFORMAT ;

  init_info( name, inf ) ;

  perf_start( PERF_LOAD|PERF_IDENTIFY, &inf->perf_info ) ;

  /* Build the list of potential candidates */
  if ( inf->lformat != IID_UNKNOWN )    inf->nb_modules = DImgGetModulesCandidates( NULL, inf->lformat, inf->img_modules, ARRAY_SIZE(inf->img_modules) ) ;
  else if ( get_ext( name, ext ) == 1 ) inf->nb_modules = DImgGetModulesCandidates( ext, IID_UNKNOWN, inf->img_modules, ARRAY_SIZE(inf->img_modules) ) ;

  LoggingDo(LL_IMG, "%d candidate modules available for loading %s", inf->nb_modules, name ) ;
  /* Try candidates, bail-out as soon as one returns valid identification */
  for ( i = 0; i < inf->nb_modules; i++ )
  {
    img_module = inf->img_modules[i] ;
    LoggingDo(LL_IMG, "Identify picture (type %c) for %s...", img_module->Type, name) ;
    ret = AssertModuleForFile( img_module, name, inf ) ;
    if ( ret == EIMG_SUCCESS ) ret = check_module_caps( img_module, inf ) ; /* Free stuff if required */
    LoggingDo(LL_IMG, "Identify picture (type %c) for %s returned %d", img_module->Type, name, ret) ;
    if ( ret == EIMG_SUCCESS ) break ;
    /* This module failed identification; let's remove it from list */
    inf->img_modules[i] = NULL ;
  }

  /* Clean-up list in case some modules failed identification */
  j = 0 ;
  for ( i = 0; i < inf->nb_modules; i++ )
    if ( inf->img_modules[i] ) inf->img_modules[j++] = inf->img_modules[i] ;
  inf->nb_modules = j ;
  LoggingDo(LL_IMG, "%d modules available for loading %s", inf->nb_modules, name ) ;
/*  if ( inf->nb_modules == 0 ) ret = EIMG_UNKOWNFORMAT ;*/

  if ( ret == EIMG_SUCCESS )
  {
#ifndef __NO_LOGGING
    char* tiid = (char*) &inf->lformat ;

    LoggingDo(LL_IMG, "Image caracteristics for %s:", inf->filename) ;
    LoggingDo(LL_IMG, "  IID=%lx (%c%c%c)", inf->lformat, tiid[0], tiid[1], tiid[2]) ;
    LoggingDo(LL_IMG, "  width=%d, height=%d, depth=%d%s", inf->width, inf->height, inf->nplanes, (inf->c.flipflop & FLIPFLOP_Y) ? ", Y-Inverted":"") ;
    LoggingDo(LL_IMG, "  %ld colors for palette", (inf->palette && inf->nb_cpal) ? inf->nb_cpal:0) ;
#endif
    make_safepalette( inf ) ;
  }

  perf_stop( PERF_IDENTIFY, &inf->perf_info ) ;

  return ret ;
}

void free_imgpal(INFO_IMAGE* inf)
{
  if ( inf->palette )
  {
    Xfree( inf->palette ) ;
    inf->palette = NULL ;
    inf->nb_cpal = 0 ;
  }
  if ( inf->mfdb.fd_addr )
  {
    Xfree( inf->mfdb.fd_addr ) ;
    inf->mfdb.fd_addr = NULL ;
  }
}

int fit_to_planes(INFO_IMAGE* inf, int out_planes, GEM_WINDOW* wprog)
{
  MFDB* img = &inf->mfdb ;

  if ( (out_planes == -1) || (img->fd_nplanes == out_planes) ) return EIMG_SUCCESS ;

  LoggingDo(LL_IMG, "fit_to_planes, fd_nplanes=%d, out_planes=%d, inf->nplans=%d, %d colors for palette=%p", img->fd_nplanes, out_planes, inf->nplanes, (short)inf->nb_cpal, inf->palette) ;
  /* Si l'image charg‚e comporte moins de couleurs que l'‚cran, on */
  /* Fait une conversion raster n plans -> raster m plans (n < m)  */
  if ( (img->fd_nplanes < out_planes) && (out_planes <= 8) )
  {
    if ( incnbplanes( img, out_planes, &inf->cancel_stdvdi ) != 0 ) return EIMG_NOMEMORY ;
  }

  if ( inf->nplanes > out_planes )
  {
    INFO_IMAGE inf2 ;

    if ( (inf->nplanes == 24) && (out_planes == 16) ) /* Cas particulier trait‚ dans le driver meme */
      return EIMG_SUCCESS ;

    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_DITHER)  ) ;
    inf2.mfdb.fd_nplanes = out_planes ;

    LoggingDo(LL_DEBUG, "fit_to_planes, Dithering with method %d", inf->dither_method) ;
    if ( dither( inf->dither_method, inf, &inf2, wprog ) != EIMG_SUCCESS )
    {
      free_imgpal( inf ) ;
      return EIMG_NOMEMORY ;
    }
    free_imgpal( inf ) ;
    memcpy( inf, &inf2, sizeof(INFO_IMAGE) ) ;
    if ( (inf->palette == NULL) && (out_planes > 1) )
    {
      inf->palette = Xalloc( 6*nb_colors ) ;
      if ( inf->palette ) get_tospalette( inf->palette ) ;
    }
    else if ( out_planes == 1 )
    {
      if ( inf->palette )
      {
        Xfree( inf->palette ) ;
        inf->palette = NULL ;
        inf->nb_cpal = 0 ;
      }
    }
    inf->has_been_dithered = 1 ;
  }

  if ( (inf->nplanes < out_planes) && (out_planes > 8) )
  {
    MFDB out ;
    int  err ;

    out.fd_nplanes = out_planes ;
    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_TRSFFMTSTD)  ) ;
    if ( inf->nplanes <= 8 ) err = index2truecolor( img, inf, &out, wprog ) ;
    else                     err = tc16totc32( img, &out ) ; /* TC15,16 --> TC32 */
    if ( err )
    {
      Xfree( img->fd_addr ) ; img->fd_addr = NULL ;
      return EIMG_NOMEMORY ;
    }
    inf->nplanes = out_planes ;
    inf->has_been_dithered = 1 ;
    Xfree( img->fd_addr ) ;
    CopyMFDB( img, &out ) ;
  }

  return EIMG_SUCCESS ;
}

void adapt_palette(INFO_IMAGE* info_img)
{
  if ( !Truecolor && (info_img->nb_cpal < nb_colors) && info_img->palette )
  {
    int* new_pal ;

    new_pal = (int*) Xalloc( nb_colors*6 ) ;
    if ( new_pal )
    {
      get_tospalette( new_pal ) ;
      memcpy( new_pal, info_img->palette, info_img->nb_cpal*6 ) ;
      Xfree( info_img->palette ) ;
      info_img->palette = new_pal ;
      info_img->nb_cpal = nb_colors ;
    }
  }
}

static int ldv_load_picture(INFO_IMAGE* inf, IMG_MODULE* img_module)
{
  GEM_WINDOW* wprog = (GEM_WINDOW*) inf->prog ;
  MFDB        std_img ;
  MFDB*       out = &inf->mfdb ;
  int         out_planes ;
  int         ret = EIMG_SUCCESS ;
  char*       name = inf->filename ;

  out_planes = out->fd_nplanes ;
  if ( out_planes == -1 ) out_planes = inf->nplanes ;

  inf->final_nb_planes = out_planes ;

  ZeroMFDB( &std_img ) ;
  if ( UseStdVDI && (out_planes <= 8) )
  {
    perf_start( PERF_STDFORMAT, &inf->perf_info ) ;
    /* img_extend call may then increase image size, get prepared */
    std_img.fd_addr = img_alloc( inf->width > MINIW ? inf->width:MINIW, inf->height > MINIH ? inf->height:MINIH, out_planes ) ;
    if ( std_img.fd_addr == NULL ) return EIMG_NOMEMORY ;
    std_img.fd_h       = inf->height ;
    std_img.fd_wdwidth = w2wdwidth( inf->width ) ;
    std_img.fd_w       = 16*std_img.fd_wdwidth ;
    std_img.fd_nplanes = out_planes ;
    std_img.fd_stand   = 1 ;
    perf_stop( PERF_STDFORMAT, &inf->perf_info ) ;
  }

  LoggingDo(LL_IMG, "Loading picture %s with image module type %c, out_planes=%d...", name, img_module->Type, out_planes) ;
  ret = IMLoad( img_module, inf ) ;
  LoggingDo(LL_IMG, "Picture loading returned %d", ret) ;

  if ( GWIsWindowValid( wprog ) )
  {
    StdProgWText( wprog, 1, "" ) ;
    StdProgDisplayDSP( wprog, 0 ) ;
    StdProgDisplay030( wprog, 0 ) ;
  }

  if ( ret == EIMG_SUCCESS ) ret = img_extend( inf ) ;

  perf_start( PERF_DITHER, &inf->perf_info ) ;
  if ( ret == EIMG_SUCCESS ) ret = fit_to_planes( inf, out_planes, wprog ) ; /* Augmente le nombre de plans ou trame */
  perf_stop( PERF_DITHER, &inf->perf_info ) ;

  if ( inf->natural_format )
  {
    Xfree( inf->natural_format ) ;
    inf->final_nb_planes = out_planes ;
    inf->natural_format  = NULL ;
    inf->natural_width   = 0 ;
  }

  if ( UseStdVDI && (ret == EIMG_SUCCESS) && !inf->cancel_stdvdi )
  {
    LoggingDo(LL_IMG, "ldv_load_picture(UseStdVDI), fd_nplanes=%d, screen.fd_nplanes=%d", out->fd_nplanes, screen.fd_nplanes) ;
    perf_start( PERF_STDFORMAT, &inf->perf_info ) ;
    if ( out_planes <= 8 )
    {
      ClassicAtari2StdVDI( out, &std_img ) ;
      vr_trnfm( handle, &std_img, out ) ;
    }
    else if ( out->fd_nplanes == screen.fd_nplanes ) tc_convert( out ) ;
    perf_stop( PERF_STDFORMAT, &inf->perf_info ) ;
  }

  if ( std_img.fd_addr ) Xfree( std_img.fd_addr ) ;

  return ret ;
}

static void LogPerf(char* fmt_txt, size_t tms)
{
  if ( tms == PERF_NA )
  {
    char  buffer[256] ;
    char* pc ;

    strcpy( buffer, fmt_txt ) ;
    pc = strchr( buffer, '%' ) ;
    if ( pc ) { *pc = 0 ; strcat( buffer, "NA") ; }
    LoggingDo(LL_PERF, buffer) ;
  }
  else LoggingDo(LL_PERF, fmt_txt, tms) ;
}

int load_picture(INFO_IMAGE* inf)
{
  IMG_MODULE** img_modules ;
  MFDB         sout ;
  MFDB*        out = &inf->mfdb ;
  int          i, ret = EIMG_MODULERROR ;

  img_modules = (IMG_MODULE**) inf->img_modules ;
  CopyMFDB( &sout, out ) ;
  for ( i = 0 ; i < inf->nb_modules; i++ )
  {
    IMG_MODULE* img_module = (IMG_MODULE*) img_modules[i] ;

    if ( i != 0 )
    {
      int out_planes ;

      /* Only first module has beeen used for identification */
      ret = AssertModuleForFile( img_module, inf->filename, inf ) ;
      if ( ret == EIMG_SUCCESS ) ret = check_module_caps( img_module, inf ) ; /* Free stuff if required */
      out_planes = out->fd_nplanes ;
      if ( out_planes == -1 ) out_planes = inf->nplanes ;
    }
    else ret = EIMG_SUCCESS ;
    
    if ( ret == EIMG_SUCCESS ) ret = ldv_load_picture( inf, img_module ) ;
    img_post_loading( ret, inf ) ; /* Probably done by module itself to free resources as soon as possible but let's make sure */
    /* There is still a specific case:               */
    /* The file reported an image with palette       */
    /* But we converted it to True Color, so in      */
    /* This case it's legitimate to free the palette */
    if ( inf->palette && (inf->mfdb.fd_nplanes > 8) )
    {
      Xfree( inf->palette ) ;
      inf->palette = NULL ;
      inf->nb_cpal = 0 ;
    }
    if ( (ret == EIMG_SUCCESS) || (ret == EIMG_USERCANCELLED) ) break ; /* Treat cancel as valid for all modules */
    else                                                        CopyMFDB( out, &sout ) ;
  }
  if ( (inf->c.flipflop & FLIPFLOP_Y) && (ret == EIMG_SUCCESS) ) smart_hsym( out ) ;
  perf_stop( PERF_LOAD, &inf->perf_info ) ;

  perf_setunit( PERF_UNITMS, &inf->perf_info ) ;
  if ( ret == EIMG_SUCCESS )
  {
    adapt_palette( inf ) ;
    if ( inf->informations )
    {
      char* info = inf->informations ;

      LoggingDo(LL_INFO, "Additional information for %s:", inf->filename) ;
      while ( *info )
      {
        LoggingDo(LL_INFO, "%s", info) ;
        info += 1+strlen(info) ;
      }
    }
    LoggingDo(LL_PERF, "Image loading performances for %s:", inf->filename) ;
    LogPerf( "  Identifying:    %lums", inf->perf_info.identify_time ) ;
    LogPerf( "  Disk access:    %lums", inf->perf_info.disk_access_time ) ;
    LogPerf( "  Decompression:  %lums", inf->perf_info.compress_time ) ;
    LogPerf( "  Index to Raster:%lums", inf->perf_info.ind2raster_time ) ;
    LogPerf( "  Adapt planes# : %lums", inf->perf_info.dither_time ) ;
    LogPerf( "  Std/Spec format:%lums", inf->perf_info.stdformat_time ) ;
    LogPerf( "  Grand Total:    %lums", inf->perf_info.total_load_time ) ;
    if ( out->fd_w & 0x0F )
    {
      LoggingDo(LL_WARNING, "Image width is not aligned on 16 pixels (%d), forcing alignment", out->fd_w) ;
      out->fd_w = align16( out->fd_w ) ;
    }
  }

  return ret ;
}

int save_picture(char* name, MFDB* img, INFO_IMAGE* inf, GEM_WINDOW* wprog)
{
  IMG_MODULE* img_module ;
  MFDB        std_img ;
  short       current_pref_type = DImgGetPrefType() ;
  int         i, ret = -5 ;
  char        img_fmt[1+NB_MST_MAX] ;
  char        ext[10] ;

  make_safepalette( inf ) ;

  if ( UseStdVDI )
  {
    if ( img->fd_nplanes <= 8 )
    {
      CopyMFDB( &std_img, img ) ;
      std_img.fd_addr = img_alloc(img->fd_w, img->fd_h, img->fd_nplanes) ;
      if (std_img.fd_addr == NULL) return EIMG_NOMEMORY ;
      std_img.fd_stand = 1 ;
      vr_trnfm(handle, img, &std_img) ;
      StdVDI2ClassicAtari(&std_img, img) ;
    }
    else if ( img->fd_nplanes == screen.fd_nplanes ) tc_invconvert( img ) ;
  }

  memzero( img_fmt, sizeof(img_fmt) ) ;
/*  DImgGetPriorities( img_fmt, NB_MST_MAX ) ;*/
  img_fmt[0] = MST_LDI ; /* Only use Vision's internal moduls for saving as per now */
  for ( i = 0; img_fmt[i]; i++ )
  {
    DImgSetPrefType( img_fmt[i] ) ;
    img_module = DImgGetModuleFromIID( inf->lformat ) ;
    if ( img_module )
    {
      if ( get_ext( name, ext ) == 0 )
      {
        /* Passed filename has no extension; let's add it */
        strcat( name, "." ) ;
        strcat( name, img_module->Capabilities.file_extension ) ;
      }
      else if ( DImgGetIIDFromFile( name ) != inf->lformat )
      {
        /* There is an extension which is not expected, let's force a known extension */
        char* pext = strrchr( name, '.' ) ;

        if ( pext )
        {
          LoggingDo(LL_INFO, "File extension is %s, inconsistent with IID %08lX, enforcing default format extension %s", pext, img_module->Capabilities.iid, img_module->Capabilities.file_extension) ;
          *pext = 0 ;
          strcat( name, "." ) ;
          strcat( name, img_module->Capabilities.file_extension ) ;
        }
      }
      ret = IMSave( img_module, name, img, inf, wprog ) ;
      LoggingDo(LL_INFO, "IMSave for module IID %08lX file %s type %c returned %d", img_module->Capabilities.iid, name, img_module->Type, ret) ;
    }
    else ret = EIMG_UNKOWNFORMAT ;
    if ( ret == 0 ) break ;
  }
  DImgSetPrefType( current_pref_type ) ;

  if ( UseStdVDI )
  {
    if ( img->fd_nplanes <= 8 )
    {
      vr_trnfm( handle, &std_img, img ) ;
      Xfree( std_img.fd_addr ) ;
    }
    else if ( img->fd_nplanes == screen.fd_nplanes ) tc_convert( img ) ;
  }

  return ret ;
}

void set_gamma(float gamma, int tab[1024])
{
  float x, y ;
  float i ;
  int   ctab[320] ;
  int   y1, y2, y3, y4, y5 ;
  int   *pt_tab ;

  ctab[0] = 0 ;
  pt_tab = ctab ;
  for (i = 8.0; i <= 256.0; i = i+8.0)
  {
    x          = i/256.0 ;
#if defined( __68881__ ) && !defined( __NFPUIN__ )
    y          = 1000.0*exp(gamma*log(x)) ;
#else
    y          = 1000.0*pow(x, gamma) ;
#endif
    y1         = (int) y ;
    y2         = *pt_tab++ ;
    y3         = (y2+y1) >> 1 ;
    y4         = (y2+y3) >> 1 ;
    y5         = (y1+y3) >> 1 ;
    *pt_tab++  = (y2+y4) >> 1 ;
    *pt_tab++  = y4 ;
    *pt_tab++  = (y3+y4) >> 1 ;
    *pt_tab++  = y3 ;
    *pt_tab++  = (y3+y5) >> 1 ;
    *pt_tab++  = y5 ;
    *pt_tab++  = (y1+y5) >> 1 ;
    *pt_tab    = y1 ;
  }
  
  pt_tab = tab ;
  for (y1 = 0; y1 <= 1000; y1++) *pt_tab++ = ctab[y1 >> 2] ;
}

void make_vdigamma(int* rgamma_tab, int* vgamma_tab, int* bgamma_tab, void* palette, int nb)
{
  int pal[6*256] ;
  int *ptp, *ptpo ;
  int i, ind ;

  memcpy(pal, palette, 6*nb) ;
  ptp  = (int*) pal ;
  ptpo = (int*) palette ;
  for (i = 0; i < nb; i++)
  {
    if (*ptp > 1000) *ptp = 1000 ;
    ind     = *ptp++ ;
    *ptpo++ = rgamma_tab[ind] ;
    if (*ptp > 1000) *ptp = 1000 ;
    ind     = *ptp++ ;
    *ptpo++ = vgamma_tab[ind] ;
    if (*ptp > 1000) *ptp = 1000 ;
    ind     = *ptp++ ;
    *ptpo++ = bgamma_tab[ind] ;
  }
}

void set_tcgamma(float gamma, unsigned char* curve, int nb_bits)
{
  float          val, nbf, x ;
  unsigned char* pt ;
  unsigned int   v, max, i ;

  max = 1 << nb_bits ;
  nbf = (float) (max) ;
  pt  = curve ;
  for (i = 0; i < max; i++)
  {
    x     = (float)i/nbf ;
#if defined( __68881__ ) && !defined( __NFPUIN__ )
    val   = nbf*exp(gamma*log(x)) ;
#else
    val   = nbf*pow(x, gamma) ;
#endif
    v = (int) (0.5+val) ;
    if (v >= max) v = max-1 ;
    *pt++ = (unsigned char) v ;
  }
}

int grey_level(INFO_IMAGE* info)
{
  int *r, *v, *b ;
  int i, start ;

  if ( info->palette == NULL ) return 0 ;

  if ( info->nb_cpal == 256 ) start = 16 ;
  else                        start = 0 ;
  r = (int*) info->palette+3*start ;
  v = 1+r ;
  b = 1+v ;
  for ( i = start; i < info->nb_cpal; i++ )
  {
    if ( (*r != *v) || (*v != *b) ) return 0 ;
    r += 3 ;
    v += 3 ;
    b += 3 ;
  }

  return 1 ;
}

int set_greylevel(int nplanes, INFO_IMAGE* inf)
{
  long delta ;
  int* pt ;
  int  i, val ;
  int  min, max ;
  int  start, nc ;

  inf->nb_cpal = 0 ;
  min          = 0 ;
  max          = 1000 ;
  delta        = max-min ;
  start        = 0 ;
  nc           = 1 << nplanes ;
  inf->palette = Xalloc(nc*6) ;
  if (inf->palette == NULL) return -1 ;
  inf->nb_cpal = nc ;
  pt           = inf->palette ;
  if ( nc == 256 )
  {
    unsigned char* pt_vdi2tos ;
    int            b, v ;

    start = 16 ;
    nc-- ;
    pt_vdi2tos = get_ptvdi2tos( 8 ) ;
    for ( b = 0; b < 16; b++ )
    {
      v = 3*pt_vdi2tos[b] ;
      memcpy( &pt[v], &vdi_sys_colors[3*b], 6 ) ;
    }
  }
  pt += start*3 ;
  for ( i = start; i < nc; i++ )
  {
    val  = min ;
    val += (int) (((long)i*delta)/nc) ;
    *pt++ = val ;
    *pt++ = val ;
    *pt++ = val ;
  }

  return 0 ;
}

int get_imgdrivercapabilities(long lfmt, INFO_IMAGE_DRIVER* cap)
{
  IMG_MODULE* img_module ;
  int         ret = 0 ;

  memzero( cap, sizeof(INFO_IMAGE_DRIVER) ) ;

  img_module = DImgGetModuleFromIID( lfmt ) ;
  if ( img_module ) ret = IMGetDrvCaps( img_module, cap ) ;
  else              ret = EIMG_UNKOWNFORMAT ;

  return ret ;
}

void InitCountBits(void)
{
  unsigned int  i, j ;
  unsigned char mask ;

  for ( i = 0; i <= 255; i++ )
  {
    mask = 1 ;
    for ( j = 0; j < 8; j++, mask = mask << 1 )
    {
      if ( i & mask ) NbBitsIn[i]++ ;
    }
  }
}

void FreeRscHisto(RSC_HISTO* rsc_histo)
{
  if ( rsc_histo )
  {
    if ( rsc_histo->std_data )        Xfree( rsc_histo->std_data ) ;
    if ( rsc_histo->occup_couleurs )  Xfree( rsc_histo->occup_couleurs ) ;
    if ( rsc_histo->std_img.fd_addr ) Xfree( rsc_histo->std_img.fd_addr ) ;
    Xfree( rsc_histo ) ;
  }
}

RSC_HISTO* InitRscHisto(int width, int nplanes)
{
  RSC_HISTO* rsc_histo ;
  int        suberr = 0 ;

  rsc_histo = (RSC_HISTO*) Xcalloc( 1, sizeof(RSC_HISTO) ) ;
  if ( rsc_histo )
  {
    if ( nplanes <= 8 ) rsc_histo->std_data = (unsigned char*) Xalloc( 16+width ) ;
    else if ( nplanes == 16 )
    {
      /* Allocate memory to hold exact number of colors */
      rsc_histo->occup_couleurs = (unsigned char*) Xcalloc( 65536UL, sizeof(unsigned char) ) ;
      if ( rsc_histo->occup_couleurs == NULL ) suberr = 1 ;
    }
    else if ( nplanes >= 24 )
    {
      /* Allocate memory to hold "exact" number of colors */
      /* 7 bits per composent : 128 levels  */
      /* 128*128*128 bits i.e. 262144 bytes */
      rsc_histo->occup_couleurs = (unsigned char*) Xcalloc( (128L*128L*128L)/8L, sizeof(unsigned char) ) ;
      if ( rsc_histo->occup_couleurs == NULL ) suberr = 1 ;
      else if ( NbBitsIn[1] == 0 ) InitCountBits() ;
    }
  }
  if ( suberr )
  {
    FreeRscHisto( rsc_histo ) ;
    rsc_histo = NULL ;
  }

  return rsc_histo ;
}

int compute_histo(INFO_IMAGE* inf, HISTO* histo, GEM_WINDOW* wprog, int use_stdvdi)
{
  RSC_HISTO*     rsc_histo ;
  MFDB*          img = &inf->mfdb ;
  unsigned long  total, larg, sup ;
  unsigned int*  color ;
  int*           pt_img ;
  int            x, y, ind ;
  int            nbc ;
  unsigned char* couleur = NULL ;
  unsigned char* std_ptl, *ptl ;
  unsigned char  hr, hv, hb ;

  rsc_histo = InitRscHisto( img->fd_w, img->fd_nplanes ) ;
  if ( rsc_histo == NULL ) return EIMG_NOMEMORY ;

  couleur = rsc_histo->occup_couleurs ;
  if ( use_stdvdi )
  {
    if ( img->fd_nplanes >= 16 ) tc_invconvert( img ) ;
    else if ( MakeMFDBClassicAtari( img, &rsc_histo->std_img ) == EIMG_NOMEMORY )
      return EIMG_NOMEMORY ;
  }

  if ( img->fd_nplanes <= 8 )
  {
    if ( inf->palette == NULL )
    {
      get_tospalette( rsc_histo->tos_pal ) ;
      nbc = nb_colors ;
    }
    else
    {
      memcpy(rsc_histo->tos_pal, inf->palette, 6*inf->nb_cpal) ;
      nbc = (int) inf->nb_cpal ;
    }

    std_ptl = rsc_histo->std_level ;
    color   = (unsigned int*) rsc_histo->tos_pal ;
    for (x = 0; x < nbc; x++)
    {
      *std_ptl++ = *color++ >> 2 ;
      *std_ptl++ = *color++ >> 2 ;
      *std_ptl++ = *color++ >> 2 ;
    }
  }

  total  = (unsigned long)img->fd_w*(unsigned long)img->fd_h ;
  pt_img = (int*) img->fd_addr ;
  larg   = img->fd_wdwidth*img->fd_nplanes ;
  sup    = histo->norm ; /* Setup by caller */
  memzero( histo, sizeof(HISTO) ) ;
  histo->norm = sup ; /* Restore norm */
  for ( y = 0; y < img->fd_h; y++ )
  {
    if ( img->fd_nplanes <= 8 )
    {
      raster2ind( pt_img, rsc_histo->std_data, img->fd_w, img->fd_nplanes ) ;
      std_ptl = rsc_histo->std_data ;
      for ( x = 0; x < img->fd_w; x++ )
      {
        ptl = rsc_histo->std_level ;
        ptl += *std_ptl ;
        ptl += (*std_ptl) << 1 ;
        hr = *ptl++ ;
        hv = *ptl++ ;
        hb = *ptl++ ;
        histo->rouge[hr]++ ;
        histo->vert[hv]++ ;
        histo->bleu[hb]++ ;
        histo->index[*std_ptl]++ ;
        std_ptl++ ;
      }
    }
    else if ( img->fd_nplanes == 16 )
    {
      color = (unsigned int*) pt_img ;
      for ( x = 0; x < img->fd_w; x++ )
      {
        hr  = (unsigned char) (*color >> 11) ;
        hr <<= 3 ;
        hv  = (unsigned char) ((*color >> 6) & 0x01F) ;
        hv <<= 3 ;
        hb  = (unsigned char) (*color & 0x1F) ;
        hb <<= 3 ;
        for (ind = 0; ind < 8; ind++)
        {
          histo->rouge[hr+ind]++ ;
          histo->vert[hv+ind]++ ;
          histo->bleu[hb+ind]++ ;
        }
        couleur[*color] = 1 ; /* Marque cette couleur utilis‚e */
        ind = (*color++) >> 8 ;
        histo->index[ind]++ ;
      }
    }
    else if ( img->fd_nplanes == 24 )
    {
      unsigned char* c ;
      unsigned long  byte ;
      unsigned int   bit ;

      c = (unsigned char*) pt_img ;
      for (x = 0; x < img->fd_w; x++)
      {
        hr  = *c++ ;
        hv  = *c++ ;
        hb  = *c++ ;
        histo->rouge[hr]++ ;
        histo->vert[hv]++ ;
        histo->bleu[hb]++ ;
        hr = hr >> 1 ; /* Revient sur 7 bits pour compter les couleurs */
        hv = hv >> 1 ; /* Revient sur 7 bits pour compter les couleurs */
        hb = hb >> 1 ; /* Revient sur 7 bits pour compter les couleurs */
        byte = ((long)hr << 14) + ((long)hv << 7) + ((long)hb) ;
        byte = byte >> 3 ;
        bit  = (int)byte & 0x07 ;
        couleur[byte] |= 1 << bit ; /* Marque cette couleur utilis‚e */
      }
    }
    else if ( img->fd_nplanes == 32 )
    {
      unsigned char* c ;
      unsigned long  byte ;
      unsigned int   bit ;

      c = (unsigned char *) pt_img ;
      for ( x = 0; x < img->fd_w; x++ )
      {
        hr  = *c++ ;
        hv  = *c++ ;
        hb  = *c++ ;
        c++ ;
        histo->rouge[hr]++ ;
        histo->vert[hv]++ ;
        histo->bleu[hb]++ ;
        hr = hr >> 1 ; /* Revient sur 7 bits pour compter les couleurs */
        hv = hv >> 1 ; /* Revient sur 7 bits pour compter les couleurs */
        hb = hb >> 1 ; /* Revient sur 7 bits pour compter les couleurs */
        byte = ((long)hr << 14) + ((long)hv << 7) + ((long)hb) ;
        byte = byte >> 3 ;
        bit  = (int)byte & 0x07 ;
        couleur[byte] |= 1 << bit ; /* Marque cette couleur utilis‚e */
      }
    }
    pt_img += larg ;
    (void)GWProgRange( wprog, y, img->fd_h, NULL ) ;
  }

  /* D‚duction de l'histogramme des gris */
  for (x = 0; x < HISTO_SIZE; x++)
    histo->gris[x] = (histo->rouge[x]+histo->vert[x]+histo->bleu[x])/3 ;

  histo->nb_colors = total ;
  /* Trouve le nombre de couleurs r‚ellement utilis‚es */
  histo->nb_colors_used = 0 ;
  if ( img->fd_nplanes <= 8 )
  {
    int c ;
    
    for ( c = 0; c < (1 << img->fd_nplanes); c++ )
      if ( histo->index[c] > 0 ) histo->nb_colors_used++ ;
  }
  else if (img->fd_nplanes == 16)
  {
    unsigned long c ;
    
    for ( c = 0; c <= 65535U; c++, couleur++ )
      if ( *couleur > 0 ) histo->nb_colors_used++ ;
  }
  else if (img->fd_nplanes >= 24)
  {
    unsigned long c ;
    
    for ( c = 0; c < (128L*128L*128L)/8L; c++, couleur++ )
      histo->nb_colors_used += NbBitsIn[*couleur] ;
  }

  /* Normalise les r‚sultats */
  sup = histo->rouge[0] ;
  for ( x = 0; x < HISTO_SIZE; x++ )
  {
    if ( histo->rouge[x] > sup ) sup = histo->rouge[x] ;
    if ( histo->vert[x] > sup )  sup = histo->vert[x] ;
    if ( histo->bleu[x] > sup )  sup = histo->bleu[x] ;
    if ( histo->gris[x] > sup )  sup = histo->gris[x] ;
  }

  for (x = 0; x < HISTO_SIZE; x++)
  {
    histo->rouge[x] = (histo->norm*histo->rouge[x])/sup ;
    histo->vert[x]  = (histo->norm*histo->vert[x])/sup ;
    histo->bleu[x]  = (histo->norm*histo->bleu[x])/sup ;
    histo->gris[x]  = (histo->norm*histo->gris[x])/sup ;
  }

  if ( img->fd_nplanes <= 8 )
  {
    sup = histo->index[0] ;
    for (x = 1; x < HISTO_SIZE; x++)
      if (histo->index[x] > sup) sup = histo->index[x] ;
    for (x = 0; x < HISTO_SIZE; x++)
      histo->index[x] = (histo->norm*histo->index[x])/sup ;
  }

  if ( use_stdvdi )
  {
    if ( img->fd_nplanes >= 16 ) tc_convert( img ) ;
    else                         vr_trnfm( handle, &rsc_histo->std_img, img ) ;
  }
  FreeRscHisto( rsc_histo ) ;

  return 0 ;
}

int get_nearest_vdi_index(int* rvb, void* tos_pal, long nb_cpal)
{
  unsigned char* vdi2tos ;
  long           dist, dist_mini ;
  int*           tos_palette = (int*) tos_pal ;
  int            vdi_color_index = 0 ;
  int            i, index_tos ;

  dist_mini = 3L*1000L*1000L ;
  vdi2tos = get_ptvdi2tos( nb_planes( (int)nb_cpal ) ) ;
  for ( i = 0; i < nb_cpal; i++ )
  {
    index_tos = 3*vdi2tos[i] ;
    dist = rvbdist( rvb, &tos_palette[index_tos] ) ;
    if ( dist < dist_mini )
    {
      vdi_color_index = i ;
      if ( dist == 0 ) break ;
      else             dist_mini = dist ;
    }
  }

  return vdi_color_index ;
}

int MakeMFDBClassicAtari(MFDB* in, MFDB* std)
{
  MFDB std_img ;

  if ( std != NULL ) ZeroMFDB( std ) ;

  if ( UseStdVDI && (in->fd_nplanes <= 8) )
  {
    CopyMFDB( &std_img, in ) ;
    std_img.fd_addr = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
    if ( std_img.fd_addr == NULL ) return EIMG_NOMEMORY ;
    std_img.fd_stand = 1 ;
    vr_trnfm( handle, in, &std_img ) ;
    StdVDI2ClassicAtari( &std_img, in ) ;
    /* in est maintenant au format Atari Classic */
    if ( std ) CopyMFDB( std, &std_img ) ;
    else       Xfree( std_img.fd_addr ) ;
  }

  return EIMG_SUCCESS ;
}

/* Atari classic --> spec */
int MakeMFDBSpec(MFDB* in, MFDB* std)
{
  MFDB std_img ;

  if ( std != NULL ) ZeroMFDB( std ) ;

  if ( UseStdVDI && (in->fd_nplanes <= 8) )
  {
    CopyMFDB( &std_img, in ) ;
    std_img.fd_addr = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
    if ( std_img.fd_addr == NULL ) return EIMG_NOMEMORY ;
    std_img.fd_stand = 1 ;
    in->fd_stand     = 0 ;
    ClassicAtari2StdVDI( in, &std_img ) ;
    vr_trnfm( handle, &std_img, in ) ;
    /* in now has specific format */
    if ( std ) CopyMFDB( std, &std_img ) ;
    else       Xfree( std_img.fd_addr ) ;
  }

  return EIMG_SUCCESS ;
}

void perf_reset(unsigned int perf, PERF_INFO* perf_info)
{
  perf_info->unit = PERF_UNITINTERNAL ;

  if ( perf & PERF_LOAD )       perf_info->total_load_time  = PERF_NA ;
  if ( perf & PERF_DITHER )     perf_info->dither_time      = PERF_NA ;
  if ( perf & PERF_DISK )       perf_info->disk_access_time = PERF_NA ;
  if ( perf & PERF_COMPRESS )   perf_info->compress_time    = PERF_NA ;
  if ( perf & PERF_IND2RASTER ) perf_info->ind2raster_time  = PERF_NA ;
  if ( perf & PERF_STDFORMAT )  perf_info->stdformat_time   = PERF_NA ;
  if ( perf & PERF_IDENTIFY )   perf_info->identify_time    = PERF_NA ;
}

void perf_start(unsigned int perf, PERF_INFO* perf_info)
{
  size_t t = clock() ;

  if ( perf & PERF_LOAD )       perf_info->itotal_load_time  = t ;
  if ( perf & PERF_DITHER )     perf_info->idither_time      = t ;
  if ( perf & PERF_DISK )       perf_info->idisk_access_time = t ;
  if ( perf & PERF_COMPRESS )   perf_info->icompress_time    = t ;
  if ( perf & PERF_IND2RASTER ) perf_info->iind2raster_time  = t ;
  if ( perf & PERF_STDFORMAT )  perf_info->istdformat_time   = t ;
  if ( perf & PERF_IDENTIFY )   perf_info->iidentify_time    = t ;
}

void perf_stop(unsigned int perf, PERF_INFO* perf_info)
{
  size_t t = clock() ;

  if ( perf & PERF_LOAD )       perf_info->total_load_time  += t-perf_info->itotal_load_time ;
  if ( perf & PERF_DITHER )     perf_info->dither_time      += t-perf_info->idither_time ;
  if ( perf & PERF_DISK )       perf_info->disk_access_time += t-perf_info->idisk_access_time ;
  if ( perf & PERF_COMPRESS )   perf_info->compress_time    += t-perf_info->icompress_time ;
  if ( perf & PERF_IND2RASTER ) perf_info->ind2raster_time  += t-perf_info->iind2raster_time ;
  if ( perf & PERF_STDFORMAT )  perf_info->stdformat_time   += t-perf_info->istdformat_time ;
  if ( perf & PERF_IDENTIFY )   perf_info->identify_time    += t-perf_info->iidentify_time ;
}

static size_t internal2ms(size_t internal)
{
  return (1000L*internal)/CLK_TCK ;
}

static size_t ms2internal(size_t ms)
{
  return (CLK_TCK*ms)/1000L ;
}

void perf_setunit(int unit, PERF_INFO* perf_info)
{
  if ( unit != perf_info->unit )
  {
    if ( unit == PERF_UNITMS )
    {
      /* INTERNAL --> Milli Seconds */
      if ( perf_info->total_load_time != PERF_NA )  perf_info->total_load_time  = internal2ms( perf_info->total_load_time ) ;
      if ( perf_info->dither_time != PERF_NA )      perf_info->dither_time      = internal2ms( perf_info->dither_time ) ;
      if ( perf_info->disk_access_time != PERF_NA ) perf_info->disk_access_time = internal2ms( perf_info->disk_access_time ) ;
      if ( perf_info->compress_time != PERF_NA )    perf_info->compress_time    = internal2ms( perf_info->compress_time ) ;
      if ( perf_info->ind2raster_time != PERF_NA )  perf_info->ind2raster_time  = internal2ms( perf_info->ind2raster_time ) ;
      if ( perf_info->stdformat_time != PERF_NA )   perf_info->stdformat_time   = internal2ms( perf_info->stdformat_time ) ;
      if ( perf_info->identify_time != PERF_NA )    perf_info->identify_time    = internal2ms( perf_info->identify_time ) ;
    }
    else
    {
      /* Milli Seconds --> INTERNAL */
      if ( perf_info->total_load_time != PERF_NA )  perf_info->total_load_time  = ms2internal( perf_info->total_load_time ) ;
      if ( perf_info->dither_time != PERF_NA )      perf_info->dither_time      = ms2internal( perf_info->dither_time ) ;
      if ( perf_info->disk_access_time != PERF_NA ) perf_info->disk_access_time = ms2internal( perf_info->disk_access_time ) ;
      if ( perf_info->compress_time != PERF_NA )    perf_info->compress_time    = ms2internal( perf_info->compress_time ) ;
      if ( perf_info->ind2raster_time != PERF_NA )  perf_info->ind2raster_time  = ms2internal( perf_info->ind2raster_time ) ;
      if ( perf_info->stdformat_time != PERF_NA )   perf_info->stdformat_time   = ms2internal( perf_info->stdformat_time ) ;
      if ( perf_info->identify_time != PERF_NA )    perf_info->identify_time    = ms2internal( perf_info->identify_time ) ;
    }
    perf_info->unit = unit ;
  }
}

int may_use_natural_format(int final_nbplanes, int mfdb_nbplanes)
{
  if ( (final_nbplanes <= 8) && (mfdb_nbplanes <= 8) &&
       (mfdb_nbplanes > final_nbplanes) ) return 1 ;

  return 0 ;
}

static int FileErr2ImgErr(long result)
{
  if ( result < 0 ) return EIMG_DATAINCONSISTENT ;
  return EIMG_SUCCESS ;
}

long ImgFSeek(INFO_IMAGE* inf, long offset, int whence)
{
  return XFseek( &inf->xfile, offset, whence ) ;
}

int ImgFOpen(INFO_IMAGE* inf, char* name, size_t* file_size)
{
  long ret ;

  if ( inf->xfile.valid ) { LoggingDo(LL_WARNING, "file is already allocated") ; }
  ret = XFopen( &inf->xfile, name, 0, file_size ? -2:0 ) ; /* -2 means XFopen returns file size but use default cache size */
  if ( ret < 0 )
  {
    if ( ret == -39 ) return EIMG_NOMEMORY ; /* ENSMEM(-39) in atarierr.h conflicting with errno.h */
    else              return EIMG_FILENOEXIST ;
  }

  if ( file_size ) *file_size = inf->xfile.file_size ;

  return EIMG_SUCCESS ;
}

long ImgFRead(INFO_IMAGE* inf, void* buffer, long size)
{
  return XFread( &inf->xfile, buffer, size ) ;
}

int ImgFGetc(INFO_IMAGE* inf)
{
  int           c = EOF ;
  unsigned char cc ;

  if ( ImgFRead( inf, &cc, 1 ) == 1 ) c = cc ;

  return c ;  
}

int ImgFClose(INFO_IMAGE* inf)
{  
  return FileErr2ImgErr( XFclose( &inf->xfile ) ) ;
}

char* add_informations(INFO_IMAGE* inf, char* title, char* info)
{
  char*  new_info ;
  size_t size2add ;
  size_t offset = 0 ;

  size2add = 1 + strlen(title) + 1 + strlen(info) ;
  if ( inf->informations == NULL ) size2add++ ; /* We need to add double \0 for ending */
  new_info = (char*) Xrealloc( inf->informations, inf->informations_size + size2add ) ;
  if ( new_info )
  {
    inf->informations = new_info ;
    if ( inf->informations_size > 1 ) offset = inf->informations_size-1 ;
    sprintf( &inf->informations[offset], "%s:%s", title, info ) ;
    inf->informations_size                     += size2add ;
    inf->informations[inf->informations_size-2] = 0 ; /* Should be done by Xrealloc but let's not assume too much on realloc function */
    inf->informations[inf->informations_size-1] = 0 ; /* Should be done by Xrealloc but let's not assume too much on realloc function */
    memrep( inf->informations, inf->informations_size, '\r', ' ' ) ;
    memrep( inf->informations, inf->informations_size, '\n', ' ' ) ;
    LoggingDo(LL_DEBUG,"Image information %s added", &inf->informations[offset] ) ;
  }

  return new_info ;
}

void release_informations(INFO_IMAGE* inf)
{
  if ( inf->informations )
  {
    Xfree( inf->informations ) ;
    inf->informations      = NULL ;
    inf->informations_size = 0 ;
  }
}

char* get_informations_next(char* informations)
{
  if ( informations )
  {
    while ( *informations ) informations++ ;
    informations++ ;
    if ( *informations == 0 ) informations = NULL ;
  }

  return informations ;
}

void img_post_loading(int status, INFO_IMAGE* inf)
{
  /* Release any resource used for loading/saving */
  ImgFClose( inf ) ;
  if ( inf->specific )
  {
    Xfree( inf->specific ) ;
    inf->specific = NULL ;
  }
  if ( inf->file_contents )
  {
    Xfree( inf->file_contents ) ;
    inf->file_contents = NULL ;
  }

  /* Now release all resources used as image is disposed (upon an error or a user action) */
  if ( status != EIMG_SUCCESS )
  {
    free_imgpal( inf ) ;
    release_informations( inf ) ;
  }
}

void free_info(INFO_IMAGE* inf)
{
  img_post_loading( EIMG_USERCANCELLED, inf ) ; /* Force img_post_loading to free everything that might have been allocated */
}

short info_image_duplicate(INFO_IMAGE* in, INFO_IMAGE* out)
{
  short ret ;

  ret = raster_duplicate( &in->mfdb, &out->mfdb ) ;
  if ( ret ) ret = EIMG_NOMEMORY ;
  else
  {
    if ( in->palette && in->nb_cpal )
    {
      out->palette = Xalloc( in->nb_cpal*3*sizeof(short) ) ;
      if ( out->palette == NULL )
      {
        Xfree( out->mfdb.fd_addr ) ;
        out->mfdb.fd_addr = NULL ;
        ret = EIMG_NOMEMORY ;
      }
      else
      {
        memcpy( out->palette, in->palette, in->nb_cpal*3*sizeof(short) ) ;
        out->nb_cpal = in->nb_cpal ;
      }
    }
  }

  return ret ;
}

void TerminateImgLib(void)
{
  if ( ldg_me ) ldg_term( ap_id, ldg_me ) ;
  DImgFreeModules() ;
  ImgFTrackExit() ;
}

int img_setsaveoptions(INFO_IMAGE* inf, int (*fct_setsaveoption)(INFO_IMAGE* inf, char* option, char* value))
{
  int   this_ret, ret = EIMG_SUCCESS ;
  char* save_option ;

  if ( (inf->save_options == NULL) || (fct_setsaveoption == NULL) ) return ret ;

  save_option = get_saveoptions_first( inf ) ;
  while ( save_option )
  {
    if ( memcmp( save_option, "fmt", 3 ) != 0 ) /* Ignore format option as we are already in module of interest */
    {
      char* option_val ;

      option_val = strchr( save_option, '=' ) ;
      if ( option_val )
      {
        char* equal = option_val ;

        *equal     = 0 ;
        option_val = ignore_spaces( 1+equal ) ;
        this_ret = fct_setsaveoption( inf, save_option, option_val ) ;
        if ( this_ret != EIMG_SUCCESS ) LoggingDo(LL_INFO, "Option %s=%s not available for saving", save_option, option_val ) ;
        if ( ret == EIMG_SUCCESS ) ret = this_ret ;
        *equal = '=' ;
      }
    }
    save_option = get_saveoptions_next( save_option ) ;
  }

  return ret ;
}

int img_getstddata(INFO_IMAGE* inf, char* query, char* out_data, long out_data_size)
{
  int err = EIMG_OPTIONNOTSUPPORTED ;

  if ( strcmpi( query, "filename" ) == 0 )
  {
    if ( strlen(inf->filename) < out_data_size ) { strcpy( out_data, inf->filename ) ; err = EIMG_SUCCESS ; }
    else                                         err = EIMG_NOMEMORY ;
  }

  return err ;
}
