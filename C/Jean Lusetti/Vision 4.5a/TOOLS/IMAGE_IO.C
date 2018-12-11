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
#define TCTRL_C  0x2E03

unsigned char palind[256] ; /* Nouveaux indices palette TOS des 256 couleurs */
char          img_analyse ; /* 1 si le remplacement des 16 indices GEM doit  */
                            /* Etre analys‚ et les indices modifi‚s au mieux */
PERF_INFO     PerfInfo ;    /* Infos performances en 1/1000 sec              */
void          *NaturalFormat ;
int           NaturalWidth ;
char          NbBitsIn[256] ;
char          InitNbBitsIn = 0 ;
char          Force16BitsLoad = 1 ; /* Force le chargement en 16 bits meme si image 24 bits */
char          CancelStdVDI ;
char          DitherMethod ;
char          HasBeenDithered ;
char          FinalNbPlanes ;
char          MultipleImages ;

size_t img_size(int w, int h, int nplanes)
{
  size_t taille ;
  int    wdwidth ;

  wdwidth = w/16 ;
  if (w % 16) wdwidth++ ;
  taille   = (size_t)(wdwidth << 4)*(size_t)nplanes*(size_t)h ;
  taille >>= 3 ; /* En octets */

  return( taille ) ;
}

/******************************************************************************/
/* Alloue la taille m‚moire pour une image de w colonnes, h lignes et n plans */
/******************************************************************************/
/*void *img_alloc(int w, int h, int n)
{
  return( Xalloc( img_size( w, h, n ) ) ) ;
}
*/
/****************************************************************/
/* Adapte la palette de couleurs pour un raster 8 ou 16 plans   */
/* Issu d'un raster 2 plans qui a ‚t‚ transform‚. On doit tenir */
/* Compte du fait que l'indice TOS %11 (2 plans) correspond aux */
/* Indices TOS %1111 (4 plans) et %11111111 (8 plans)           */
/****************************************************************/
void rtos2(MFDB *data)
{
  int i, j, nplan ;
  int mask, val ;
  int *pt1, *pt2, *pt ;

  nplan = data->fd_nplanes ;
  pt1   = data->fd_addr ;
  pt2   = pt1+1 ;
  for (j = 0; j < data->fd_h; j++)
    for (i = 0; i < data->fd_w; i+= 16)
    {
      mask = 0x8000 ;
      val  = 0 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask = 0x4000 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      if ((*pt1 & mask) && (*pt2 & mask)) val |= mask ;
      mask >>= 1 ;
      pt   = 1+pt2 ;
      pt1 += nplan ;
      pt2 += nplan ;
      if ( val )
      {
        if ( nplan == 4 )
        {
          *pt++ = val ;
          *pt   = val ;
        }
        else
        {
          *pt++ = val ;
          *pt++ = val ;
          *pt++ = val ;
          *pt++ = val ;
          *pt++ = val ;
          *pt   = val ;
        }
      }
    }
}

void raster2imgline(int *raster, int *img_line, size_t long_ligne, int nplanes)
{
  int i, j, lplan ;
  int *pt1, *pt2 ;
  
  if (nplanes == 1)
  {
    memcpy(img_line, raster, long_ligne) ;
    return ;
  }

  pt1   = raster ;
  pt2   = img_line ;
  lplan = (int) long_ligne/nplanes/2 ;
  for (i = 0; i < nplanes; i++)
  {
    pt1 = raster + i ;
    for (j = 0; j < lplan; j++)
    {
      *pt2++ = *pt1 ;
      pt1   += nplanes ;
    }
  }
}

void make_safepalette(INFO_IMAGE *inf)
{
  long n ;
  int  *pt ;

  if ( inf->palette )
  {
    pt = (int *) inf->palette ;
    for ( n = 0; n < 3*inf->nb_cpal; n++, pt++ )
    {
      if ( *pt > 1000 )   *pt = 1000 ;
      else if ( *pt < 0 ) *pt = 0 ;
    }
  }
}

int incnbplanes(MFDB *data, int nb_plan)
{
  MFDB temp ;

  if ( ( nb_plan > 8 ) &&  ( data->fd_nplanes != 1 ) ) return(0) ; /* Non valide, utiliser index2truecolor */

  memcpy(&temp, data, sizeof(MFDB)) ;
  data->fd_addr = img_alloc(data->fd_w, data->fd_h, nb_plan) ;
  if (data->fd_addr == NULL)
  {
    Xfree(temp.fd_addr) ;
    return EIMG_NOMEMORY ;
  }

  if (data->fd_nplanes == 1) /* Si l'image est monochrome, la */
  {                          /* VDI s'occupe de la conversion */
    int    xy[8] ;
    int    color_index[] = {1, 0} ;

    data->fd_nplanes = nb_plan ;
    xy[0] = 0 ; xy[1] = 0 ; xy[2] = temp.fd_w-1 ; xy[3] = temp.fd_h-1 ;
    xy[4] = 0 ; xy[5] = 0 ; xy[6] = temp.fd_w-1 ; xy[7] = temp.fd_h-1 ;
    vrt_cpyfm(handle, MD_REPLACE, xy, &temp, data, color_index) ;
    CancelStdVDI = 1 ;
  }
  else
  {
    int *pt_in, *pt_out ;
    int add_out, add_in ;
    int i, j, nb ;

    memset(data->fd_addr, 0, img_size(data->fd_w, data->fd_h, nb_plan)) ;
    add_in  = data->fd_nplanes ;
    add_out = nb_plan ;
    pt_in   = (int *) temp.fd_addr ;
    pt_out  = (int *) data->fd_addr ;
    nb      = 2*data->fd_nplanes ;
    for (j = 0; j < data->fd_h; j++)
      for (i = 0; i < data->fd_w; i += 16)
      {
        memcpy(pt_out, pt_in, nb) ;
        pt_out += add_out ;
        pt_in  += add_in ;
      }
    
    data->fd_nplanes = nb_plan ;
    if (add_in == 2) /* Cas particulier 2 plans, il     */
      rtos2(data) ;  /* Faut ajuster les couleurs       */
                     /* TOS 2 plans -> TOS 4 ou 8 plans */
  }
  
  Xfree(temp.fd_addr) ;
  return(0) ;
}

int decnbplanes(MFDB *in, MFDB *out)
{
  int  x, y ;
  int  *pt1, *pt2 ;
  int  inc_in ;
  int  i ;
  
  if (in->fd_nplanes <= out->fd_nplanes)  return(-1) ;
  out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL) return EIMG_NOMEMORY ;
  
  inc_in  = in->fd_nplanes-out->fd_nplanes ;
  pt1     = in->fd_addr ;
  pt2     = out->fd_addr ;
  for (y = 0; y < in->fd_h; y++)
    for (x = 0;  x < in->fd_w; x += 16)
    {
      for (i = 0; i < out->fd_nplanes; i++) *pt2++ = *pt1++ ;
      pt1 += inc_in ;
    }
  
  return(0) ;
}

void smart_fit(MFDB *in, MFDB *out, int *xy)
{
  MFDB          tmp ;
  long          lo_src, lo_dst ;
  int           *src, *dst ;
  int           l ;
  int           old_ignore_a16 = ignore_a16 ;
  unsigned char *pt_natural ;
  unsigned char buffer[2048] ;

  ignore_a16 = 1 ; /* On n'est pas forcemement aligne sur 16 bits */
  lo_src = img_size( in->fd_w, 1, in->fd_nplanes ) >> 1 ;   /* In words */
  lo_dst = img_size( out->fd_w, 1, out->fd_nplanes ) >> 1 ;   /* In words */
  src    = (int *) in->fd_addr ;
  src   += (long)xy[1]*lo_src ;
  dst    = (int *) out->fd_addr ;
  dst   += (long)xy[5]*lo_dst ;
  memcpy( &tmp, out, sizeof(MFDB) ) ;
  if ( in->fd_nplanes <= 8 )
  {
    tmp.fd_addr = dst ;
    i2r_init(&tmp, tmp.fd_w, 1) ;
    i2r_nb     = 1+xy[2]-xy[0] ;
    i2r_data   = buffer+xy[0] ;
    pt_natural = NaturalFormat ;
    if ( i2r_nb >= 16 ) /* Need a minimum */
    {
      for (l = xy[1]; l <= xy[3]; l++)
      {
        if ( NaturalFormat )
        {
          memcpy( buffer, pt_natural, NaturalWidth ) ;
          pt_natural += NaturalWidth ;
        }
        else
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
  if ( NaturalFormat )
  {
    /* L'image … traite n'est plus en format naturel */
    Xfree( NaturalFormat ) ;
    NaturalFormat = NULL ;
    NaturalWidth  = 0 ;
  }
}

/************************************************************/
/* Agrandit si n‚cessaire l'image … au moins 64x64 pour     */
/* Pouvoir ˆtre correctement affich‚e dans une fenˆtre GEM. */
/* En retour :  0 : OK                                      */
/*             -3 : M‚moire insuffisante                    */
/************************************************************/
int img_extend(MFDB *img)
{
  MFDB temp ;
  int  xy[8] ;

  if ( ( img->fd_w >= MINIW ) && ( img->fd_h >= MINIH ) ) return( 0 ) ;

  memcpy( &temp, img, sizeof(MFDB) ) ;
  if ( temp.fd_w < MINIW ) temp.fd_w = MINIW ;
  if ( temp.fd_h < MINIH ) temp.fd_h = MINIH ;
  temp.fd_wdwidth = temp.fd_w/16 ;
  if ( temp.fd_w % 16 ) temp.fd_wdwidth++ ;
  temp.fd_addr = img_alloc( temp.fd_w, temp.fd_h, temp.fd_nplanes ) ;
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
  memcpy( img, &temp, sizeof(MFDB) ) ;

  return( 0 ) ;
}

long rvbdist(int r1, int g1, int b1, int r2, int g2, int b2)
{
  long x, y, z ;

  x = r2-r1 ;
  x = x*x ;
  y = g2-g1 ;
  y = y*y ;
  z = b2-b1 ;
  z = z*z ;

  return(x+y+z) ;
}

void gem_protect(INFO_IMAGE *inf)
{
  long          min_acceptable = 3L*100L*100L ;
  long          min, d ;
  int           pal[3*256] ;
  int           i, j, newind, ind, tosind ;
  int           red, green, blue, r,v, b ;
  int           *iptpal, *pptpal, *pt ;
  int           must_remap_indexes = 1 ;
  unsigned char *vdi2tos ;

  for (i = 0; i < 256; i++) palind[i] = (unsigned char)i ;
  if ( inf->nplans != 8 ) return ;

  vdi2tos = get_ptvdi2tos( inf->nplans ) ;
  memcpy( pal, inf->palette, inf->nb_cpal*3*2 ) ;
  if ( old_pal ) memcpy( pal, old_pal, 16*3*2 ) ;
  pal[255*3] = pal[1+255*3] = pal[2+255*3] = 1000 ;
  pptpal = (int *) pal ;
  iptpal = (int *) inf->palette ;
  for (i = 0; i < 16; i++)
  {
    tosind = vdi2tos[i] ;
    red    = iptpal[3*tosind] ;
    green  = iptpal[1+3*tosind] ;
    blue   = iptpal[2+3*tosind] ;
    min    = 6000000L ;
    for (j = 16; j < inf->nb_cpal-1; j++)
    {
      ind = vdi2tos[j] ;
      pt  = pptpal+3*ind ;
      r   = *pt++ ;
      v   = *pt++ ;
      b   = *pt++ ;
      d   = rvbdist( red, green, blue, r, v, b ) ;
      if ( d < min )
      {
        min    = d ;
        newind = ind ;
      }
    }
    if ( min <= min_acceptable )
      palind[tosind] = (unsigned char)newind ;
    else must_remap_indexes = 0 ;
  }

  if ( must_remap_indexes )
  {
    tosind = vdi2tos[255] ;
    red    = iptpal[3*tosind] ;
    green  = iptpal[1+3*tosind] ;
    blue   = iptpal[2+3*tosind] ;
    min    = 6000000L ;
    for (j = 16; j < 254; j++)
    {
      ind = vdi2tos[j] ;
      pt  = pptpal+3*ind ;
      r   = *pt++ ;
      v   = *pt++ ;
      b   = *pt++ ;
      d   = rvbdist(red, green, blue, r, v, b) ;
      if (d < min)
      {
        min    = d ;
        newind = ind ;
      }
    }
    if ( min <= min_acceptable ) palind[tosind] = (unsigned char)newind ;
    else                         must_remap_indexes = 0 ;
  }

  if ( !must_remap_indexes )
    for (i = 0; i < 256; i++) palind[i] = (unsigned char)i ;
  else
    memcpy(inf->palette, pal, inf->nb_cpal*3*2) ;
}

static int AssertModuleForFile(IMG_MODULE* img_module, char* name, INFO_IMAGE* inf)
{
  int ret = IMIdentify( img_module, name, inf ) ;

  if ( ret == EIMG_SUCCESS )
  {
    inf->img_module = img_module ;
    inf->lformat    = img_module->Capabilities.iid ;
  }

  return ret ;
}

int ldv_img_format(char* name, INFO_IMAGE* inf)
{
  IMG_MODULE* img_module = NULL ;
  IID         lfmt ;
  int         ret = -1 ;
  char        ext[10] ;

  /* In case some extension can be handled by more than one module (e.g. IFF or RAW) */
  /* We need to try the module to make sure it can handle image file                 */
  if ( (inf->lformat == 0) && (get_ext( name, ext ) == 1) )
  {
    IMG_MODULE* start_module = NULL ;

    do
    {
      ret        = 0 ;
      img_module = DImgGetModuleForExtension( ext, start_module ) ;
      if ( img_module )
      {
        /* Potential candidate found for this extension */
        LoggingDo(LL_DEBUG, "Try to identify file %s with module %s type %c...", name, img_module->Capabilities.short_name, img_module->Type) ;
        ret = AssertModuleForFile( img_module, name, inf ) ;
        LoggingDo(LL_DEBUG, "Identifying file %s with module %s type %c returned %d", name, img_module->Capabilities.short_name, img_module->Type, ret) ;
        if ( ret )
        {
          /* Module recognizes extension but failed to identify, let's try again */
          start_module = 1+img_module ;
          lfmt         = inf->lformat ;
        }
        else
        {
          /* This module returns success on identifying, we have our image module */
        }
      }
    }
    while ( img_module && ret ) ;
  }

  if ( img_module == NULL )
  {
    img_module = DImgGetModuleFromIID( inf->lformat ) ;
    if ( img_module == NULL ) return EIMG_UNKOWNFORMAT ;
    LoggingDo(LL_DEBUG, "ldv_img_format: img_module=%p, ret=%d, fmt=%ld", img_module, ret, inf->lformat) ;
    ret = AssertModuleForFile( img_module, name, inf ) ;
  }

  if ( ret == 0 )
  {
    INFO_IMAGE_DRIVER *caps ;

    lfmt = inf->lformat ;
    if ( img_analyse && inf->palette )
      if ( ( lfmt != IID_DEGAS ) && ( lfmt != IID_ART ) && ( lfmt != IID_IMG ) ||
           ( lfmt != IID_MAC )   && ( lfmt != IID_NEO )
         )
      gem_protect( inf ) ;

    caps = &img_module->Capabilities ;
    switch( inf->nplans )
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

      default : ret = EIMG_OPTIONNOTSUPPORTED ;
                break ;
    }
  }

  return ret ;
}

int load_me_ldg(void)
{
  static char ret = -2 ;

  if ( ret == -2 )
  {
    ldg_me = ldg_exec( ap_id, "ME.LDG" ) ;
    if ( ldg_me == NULL ) ret = -1 ;
    else
    {
      ret = init_ldg_me( ldg_me ) ;
      if ( ret < 0 )
      {
        ldg_term( ap_id, ldg_me ) ;
        ldg_me = NULL ;
      }
    }
  }

  return( (int)ret ) ;
}

int cdecl me_img_format(char *nom, INFO_IMAGE *inf)
{
  long ret = -6 ;

  if ( load_me_ldg() == 0 )
  {
    MEIMG meimg ;

    memset( &meimg, 0, sizeof(MEIMG) ) ;
    ret = RIM_OpenImg( &meimg, nom, 0L ) ;
    if ( ret >= 0 )
    {
      inf->spec = Xalloc( sizeof(MEIMG) ) ;
      if ( inf->spec )
      {
        if ( meimg.size_DDpalette ) meimg.buff_DDpalette = Xalloc( meimg.size_DDpalette ) ;
        meimg.buff_DDimg = Xalloc( meimg.size_DDimg ) ;

        if ( meimg.buff_DDimg )
        {
          inf->lformat = IID_ME ;
          memcpy( inf->spec, &meimg, sizeof(MEIMG) ) ;
          inf->largeur = meimg.width ;
          inf->hauteur = meimg.height ;
          ret          = 0 ;
        }
        else
        {
          Xfree( inf->spec ) ;
          ret = EIMG_NOMEMORY ;
        }
      }
      else ret = EIMG_NOMEMORY ;
    }
  }

  return( (int) ret ) ;
}

int img_format(char *nom, INFO_IMAGE *inf)
{
  IMG_MODULE* img_module ;
  IID         lfmt = inf->lformat ;
  char        img_fmt[1+NB_MST_MAX] ;
  int         i, ret = -1 ;
  short       current_pref_type = DImgGetPrefType() ;

  perf_reset( PERF_ALL, &PerfInfo ) ;
  perf_start( PERF_LOAD, &PerfInfo ) ;

  memset( inf, 0, sizeof(INFO_IMAGE) ) ;
  strcpy( inf->nom, nom ) ;
  inf->lformat = lfmt ;

  memset( img_fmt, 0, sizeof(img_fmt) ) ;
  DImgGetPriorities( img_fmt, NB_MST_MAX ) ;
  for ( i = 0; img_fmt[i]; i++ )
  {
    DImgSetPrefType( img_fmt[i] ) ;
    ret = ldv_img_format( nom, inf ) ;
    img_module = inf->img_module ;
    LoggingDo(LL_IMG, "Identify picture (pref %c, match %c) for %s returned %d", DImgGetPrefType(), img_module ? img_module->Type:'?', nom, ret) ;
    if ( ret == 0 ) break ;
  }

  DImgSetPrefType( current_pref_type ) ;

  if ( ret == 0 )
  {
#ifndef __NO_LOGGING
    char* tiid = (char*) &inf->lformat ;

    LoggingDo(LL_IMG, "Image caracteristics for %s:", inf->nom) ;
    LoggingDo(LL_IMG, "  IID=%lx (%c%c%c)", inf->lformat, tiid[0], tiid[1], tiid[2]) ;
    LoggingDo(LL_IMG, "  width=%d, height=%d, depth=%d%s", inf->largeur, inf->hauteur, inf->nplans, (inf->flipflop & FLIPFLOP_Y) ? ", Y-Inverted":"") ;
    LoggingDo(LL_IMG, "  %ld colors for palette", (inf->palette && inf->nb_cpal) ? inf->nb_cpal:0) ;
#endif
    make_safepalette( inf ) ;
  }

  return ret ;
}

int fit_to_planes(MFDB *img, INFO_IMAGE *inf, int out_planes, GEM_WINDOW *wprog)
{
  if ( out_planes == -1 ) return( 0 ) ; /* Garder le nombre de plans de l'image */

  if ( img->fd_nplanes == out_planes ) return( 0 ) ;

  LoggingDo(LL_DEBUG, "fit_to_planes, fd_nplanes=%d, out_planes=%d, inf->nplans=%d", img->fd_nplanes, out_planes, inf->nplans) ;
  /* Si l'image charg‚e comporte moins de couleurs que l'‚cran, on */
  /* Fait une conversion raster n plans -> raster m plans (n < m)  */
  if ( ( img->fd_nplanes < out_planes ) && ( out_planes <= 8 ) )
  {
    if ( incnbplanes( img, out_planes ) != 0 ) return( -3 ) ;
  }

  if ( inf->nplans > out_planes )
  {
    MFDB temp ;

    if ( ( inf->nplans == 24 ) && ( out_planes == 16 ) ) /* Cas particulier trait‚ dans le driver meme */
      return( 0 ) ;

    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_DITHER)  ) ;
    temp.fd_nplanes = out_planes ;

    LoggingDo(LL_DEBUG, "fit_to_planes, Dithering with method %d", DitherMethod) ;
    if ( dither( DitherMethod, img, inf, &temp, wprog ) == -1 )
    {
      Xfree( img->fd_addr ) ;
      img->fd_addr = NULL ;
      return( -3 ) ;
    }
    Xfree( img->fd_addr ) ;
    memcpy( img, &temp, sizeof(MFDB) ) ;
    inf->nplans = out_planes ;
    if ( ( inf->palette == NULL ) && ( out_planes > 1 ) )
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
    HasBeenDithered = 1 ;
  }
  else HasBeenDithered = 0 ;

  if ( ( inf->nplans < out_planes ) && ( out_planes > 8 ) )
  {
    MFDB out ;

    out.fd_nplanes = out_planes ;
    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_TRSFFMTSTD)  ) ;
    LoggingDo(LL_DEBUG, "Calling index2truecolor...") ;
    if ( index2truecolor( img, inf, &out, wprog ) == -1 )
    {
      Xfree(img->fd_addr) ;
      return(-3) ;
    }
    inf->nplans = out_planes ;
    HasBeenDithered = 1 ;
    Xfree( img->fd_addr ) ;
    memcpy( img, &out, sizeof(MFDB) ) ;
  }

  return( 0 ) ;
}

void adapt_palette(INFO_IMAGE *info_img)
{
  if ( !Truecolor && ( info_img->nb_cpal < nb_colors ) && info_img->palette )
  {
    int *new_pal ;

    new_pal = (int *) Xalloc( nb_colors*6 ) ;
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

static int ldv_load_picture(char *name, MFDB *out, INFO_IMAGE *inf, GEM_WINDOW *wprog)
{
  IMG_MODULE* img_module ;
  MFDB        std_img ;
  int         out_planes ;
  int         ret = EIMG_SUCCESS ;

  out_planes = out->fd_nplanes ;
  if (out_planes == -1) out_planes = inf->nplans ;

  FinalNbPlanes = out_planes ;
  NaturalFormat = NULL ;
  NaturalWidth  = 0 ;
  CancelStdVDI  = 0 ;

  memset( &std_img, 0, sizeof(MFDB) ) ;
  if ( UseStdVDI && ( out_planes <= 8 ) )
  {
    perf_start( PERF_STDFORMAT, &PerfInfo ) ;
    /* img_extend call may then increase image size, get prepared */
    std_img.fd_addr = img_alloc( inf->largeur > MINIW ? inf->largeur:MINIW, inf->hauteur > MINIH ? inf->hauteur:MINIH, out_planes ) ;
    if ( std_img.fd_addr == NULL ) return( -3 ) ;
    std_img.fd_h = inf->hauteur ;
    std_img.fd_wdwidth = inf->largeur/16 ;
    if ( inf->largeur % 16 ) std_img.fd_wdwidth++ ;
    std_img.fd_w = 16*std_img.fd_wdwidth ;
    std_img.fd_nplanes = out_planes ;
    std_img.fd_stand = 1 ;
    perf_stop( PERF_STDFORMAT, &PerfInfo ) ;
  }

  img_module = DImgGetModuleFromIID( inf->lformat ) ;
  if ( inf->img_module && (img_module != inf->img_module) )
  {
    if ( inf->palette ) Xfree( inf->palette ) ;
    inf->palette = NULL ;
    ret = ldv_img_format( name, inf ) ; /* Will return img module for current priority */
    if ( img_module != inf->img_module )
    {
      /* Can't get same img_module for identifying & loading */
      /* Something is wrong, stop there                      */
      ret = EIMG_MODULERROR ;
    }
    else
    {
      /* Identify routine may have changed stuff */
      out_planes = out->fd_nplanes ;
      if (out_planes == -1) out_planes = inf->nplans ;
    }
  }

  if ( ret == EIMG_SUCCESS )
  {
    LoggingDo(LL_IMG, "Loading picture %s with image module type %c, out_planes=%d...", name, img_module ? img_module->Type:'?', out_planes) ;
    if ( img_module ) ret = IMLoad( img_module, name, out, wprog ) ;
    else              ret = EIMG_UNKOWNFORMAT ;
    LoggingDo(LL_IMG, "Picture loading returned %d", ret) ;
  }

  StdProgWText( wprog, 1, "" ) ;
  StdProgDisplayDSP( wprog, 0 ) ;
  StdProgDisplay030( wprog, 0 ) ;

  if ( ret == EIMG_SUCCESS ) ret = img_extend( out ) ;

  perf_start( PERF_DITHER, &PerfInfo ) ;
  if ( ret == EIMG_SUCCESS ) ret = fit_to_planes( out, inf, out_planes, wprog ) ; /* Augmente le nombre de plans ou trame */
  perf_stop( PERF_DITHER, &PerfInfo ) ;

  if ( NaturalFormat != NULL )
  {
    Xfree( NaturalFormat ) ;
    FinalNbPlanes = out_planes ;
    NaturalFormat = NULL ;
    NaturalWidth  = 0 ;
  }

  if ( UseStdVDI && ( ret == EIMG_SUCCESS ) && !CancelStdVDI )
  {
    LoggingDo(LL_IMG, "ldv_load_picture, UseStdVDI=%d, fd_nplanes=%d, nb_plane=%d", UseStdVDI, out->fd_nplanes, nb_plane) ;
    perf_start( PERF_STDFORMAT, &PerfInfo ) ;
    if ( out_planes <= 8 )
    {
      ClassicAtari2StdVDI( out, &std_img ) ;
      vr_trnfm( handle, &std_img, out ) ;
    }
    else if ( out->fd_nplanes == nb_plane ) tc_convert( out ) ;
    perf_stop( PERF_STDFORMAT, &PerfInfo ) ;
  }

  if ( std_img.fd_addr ) Xfree( std_img.fd_addr ) ;
  if ( (ret != EIMG_SUCCESS) && inf->palette )
  {
    Xfree( inf->palette ) ;
    inf->palette = NULL ;
  }

  return ret ;
}

int me_load_picture(MFDB *out, INFO_IMAGE *inf)
{
  MEIMG *me_img = inf->spec ;
  int    ret ;

  ret = (int) RIM_LoadImg( me_img, ME_FMT_DIRECTDISPLAY, 6L, handle, (short*)ldg_global ) ;
  if ( ret == 0 )
  {
 /*   int           i, j ;
    int           *pttos, *ptvdi, *pt ;
    unsigned char *pt_vdi2tos ;

    inf->nb_cpal = me_img->size_DDpalette / (3*sizeof(short)) ;
    inf->palette = Xalloc( me_img->size_DDpalette ) ;
    pt_vdi2tos   = get_ptvdi2tos( nb_plane ) ;
    if ( ( pt_vdi2tos == NULL ) || ( inf->palette == NULL ) )
    {
      Xfree( me_img->buff_DDimg ) ;
      ret = -3 ;
    }
    else
    {
      pttos = (int *) inf->palette ;
      ptvdi = (int *) me_img->buff_DDpalette ;
      for ( i = 0; i < (int) inf->nb_cpal; i++ )
      {
        j        = pt_vdi2tos[i] ;
        pt       = &ptvdi[j*3] ;
        *pttos++ = *pt++ ;
        *pttos++ = *pt++ ;
        *pttos++ = *pt++ ;
      }
      out->fd_w       = me_img->width ;
      out->fd_h       = me_img->height ;
      out->fd_wdwidth = me_img->wdwidth ;
      out->fd_stand   = me_img->stand ;
      out->fd_addr    = me_img->buff_DDimg ;
      out->fd_nplanes = nb_plane ;
      Xfree( me_img->buff_DDpalette ) ;
    }*/
    inf->nb_cpal     = me_img->size_DDpalette / (3*sizeof(short)) ;
    inf->palette     = me_img->buff_DDpalette ;
    inf->vdi_palette = 1 ;
    out->fd_w       = me_img->width ;
    out->fd_h       = me_img->height ;
    out->fd_wdwidth = me_img->wdwidth ;
    out->fd_stand   = me_img->stand ;
    out->fd_addr    = me_img->buff_DDimg ;
    out->fd_nplanes = nb_plane ;
  }

  RIM_CloseImg( me_img ) ;
  Xfree( inf->spec ) ;
  inf->spec = NULL ;

  return( ret ) ;
}

int load_picture(char* name, MFDB* out, INFO_IMAGE* inf, GEM_WINDOW* wprog)
{
  MFDB  sout ;
  char  img_fmt[1+NB_MST_MAX] ;
  short current_pref_type = DImgGetPrefType() ;
  int   i, ret ;

  MultipleImages = 0 ;

  memcpy( &sout, out, sizeof(MFDB) ) ;
  memset( img_fmt, 0, sizeof(img_fmt) ) ;
  DImgGetPriorities( img_fmt, NB_MST_MAX ) ;
  for ( i = 0; img_fmt[i]; i++ )
  {
    DImgSetPrefType( img_fmt[i] ) ;
    LoggingDo(LL_IMG, "Picture loading preference %c, out_planes=%d", DImgGetPrefType(), out->fd_nplanes) ;
    ret = ldv_load_picture( name, out, inf, wprog ) ;
    if ( ret == 0 ) break ;
    else            memcpy( out, &sout, sizeof(MFDB) ) ;
  }
  DImgSetPrefType( current_pref_type ) ;

  if ( (inf->flipflop & FLIPFLOP_Y) && (ret == 0) ) smart_hsym( out ) ;
  perf_stop( PERF_LOAD, &PerfInfo ) ;

  memcpy( &inf->perf_info, &PerfInfo, sizeof(PERF_INFO) ) ;
  perf_setunit( PERF_UNITMS, &inf->perf_info ) ;

  if ( ret == 0 ) adapt_palette( inf ) ;
  else
  {
    if ( out->fd_addr ) Xfree( out->fd_addr ) ;
    out->fd_addr = NULL ;
    if ( inf->palette ) Xfree( inf->palette ) ;
    inf->palette = NULL ;
    inf->nb_cpal = 0 ;
  }

  return ret ;
}

int save_picture(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wprog)
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
      memcpy(&std_img, img, sizeof(MFDB)) ;
      std_img.fd_addr = img_alloc(img->fd_w, img->fd_h, img->fd_nplanes) ;
      if (std_img.fd_addr == NULL) return(-3) ;
      std_img.fd_stand = 1 ;
      vr_trnfm(handle, img, &std_img) ;
      StdVDI2ClassicAtari(&std_img, img) ;
    }
    else if ( img->fd_nplanes == nb_plane ) tc_invconvert( img ) ;
  }

  memset( img_fmt, 0, sizeof(img_fmt) ) ;
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
        strcat( name, "." ) ;
        strcat( name, img_module->Capabilities.file_extension ) ;
      }
      ret = IMSave( img_module, name, img,inf,  wprog ) ;
    }
    else ret = -5 ;
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
    else if ( img->fd_nplanes == nb_plane ) tc_convert( img ) ;
  }

  return( ret ) ;
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

void make_vdigamma(int *rgamma_tab, int *vgamma_tab, int *bgamma_tab, void *palette, int nb)
{
  int pal[6*256] ;
  int *ptp, *ptpo ;
  int i, ind ;

  memcpy(pal, palette, 6*nb) ;
  ptp  = (int *) pal ;
  ptpo = (int *) palette ;
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

void set_tcgamma(float gamma, unsigned char *curve, int nb_bits)
{
  float         val, nbf, x ;
  unsigned char *pt ;
  unsigned int  v, max, i ;

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

int grey_level(INFO_IMAGE *info)
{
  int *r, *v, *b ;
  int i, start ;

  if (info->palette == NULL) return(0) ;

  if (info->nb_cpal == 256) start = 16 ;
  else                      start = 0 ;
  r = (int *)info->palette+3*start ;
  v = 1+r ;
  b = 1+v ;
  for (i = start; i < info->nb_cpal; i++)
  {
    if ((*r != *v) || (*v != *b)) return(0) ;
    r += 3 ;
    v += 3 ;
    b += 3 ;
  }

  return(1) ;
}

int set_greylevel(int nplanes, INFO_IMAGE *inf)
{
  long delta ;
  int  *pt ;
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
  if (inf->palette == NULL) return(-1) ;
  inf->nb_cpal = nc ;
  pt           = inf->palette ;
  if ( nc == 256 )
  {
    unsigned char *pt_vdi2tos ;
    int           b, v ;

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

  return(0) ;
}

int get_imgdrivercapabilities(long lfmt, INFO_IMAGE_DRIVER *cap)
{
  IMG_MODULE* img_module ;
  int         ret = 0 ;

  memset( cap, 0, sizeof(INFO_IMAGE_DRIVER) ) ;

  img_module = DImgGetModuleFromIID( lfmt ) ;
  if ( img_module ) IMGetDrvCaps( img_module, cap ) ;
  else              ret = -5 ;

  return( ret ) ;
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

  InitNbBitsIn = 1 ;
}

int compute_histo(MFDB *img, INFO_IMAGE *inf, HISTO *histo, GEM_WINDOW *wprog)
{
  MFDB          std_img ;
  unsigned long total, larg, sup ;
  int           tos_pal[256*3] ;
  unsigned int  *color ;
  int           *pt_img ;
  int           x, y, ind ;
  int           nbc, pc ;
  unsigned char hr, hv, hb ;
  unsigned char *std_data ;
  unsigned char *std_ptl, *ptl ;
  unsigned char std_level[3*HISTO_SIZE] ;
  unsigned char *occup_couleurs ;

  if ( UseStdVDI )
  {
    if ( img->fd_nplanes >= 16 ) tc_invconvert( img ) ;
    else
    {
      if ( MakeMFDBClassicAtari( img, &std_img ) == -3 )
        return( -3 ) ;
    }
  }

  std_data = (unsigned char *) Xalloc( 16+img->fd_w ) ;
  if ( std_data == NULL )
  {
    vr_trnfm( handle, &std_img, img ) ;
    Xfree( std_img.fd_addr ) ;

    return( -3 ) ;
  }

  memset( std_level, 0, HISTO_SIZE*sizeof(unsigned char) ) ;
  if ( img->fd_nplanes <= 8 )
  {
    if ( inf->palette == NULL )
    {
      get_tospalette( tos_pal ) ;
      nbc = nb_colors ;
    }
    else
    {
      memcpy(tos_pal, inf->palette, 6*inf->nb_cpal) ;
      nbc = (int) inf->nb_cpal ;
    }

    std_ptl = std_level ;
    color   = (unsigned int *) tos_pal ;
    for (x = 0; x < nbc; x++)
    {
      *std_ptl++ = *color++ >> 2 ;
      *std_ptl++ = *color++ >> 2 ;
      *std_ptl++ = *color++ >> 2 ;
    }
  }
  else if (img->fd_nplanes == 16)
  {
    /* Alloue la m‚moire pour compter le nombre exact de couleurs */
    occup_couleurs = (unsigned char *) Xcalloc( 65536UL, sizeof(unsigned char) ) ;
    if ( occup_couleurs == NULL )
    {
      Xfree( std_data ) ;
      return(-3) ;
    }
  }
  else if (img->fd_nplanes >= 24)
  {
    /* Alloue la m‚moire pour compter le nombre "exact" de couleurs */
    /* 7 bits par composante : 128 niveaux */
    /* 128*128*128 bits soit 262144 octets */
    long size = (128L*128L*128L)/8L ;

    occup_couleurs = (unsigned char *) Xcalloc( size, sizeof(unsigned char) ) ;
    if ( occup_couleurs == NULL )
    {
      Xfree( std_data ) ;
      return(-3) ;
    }
    if ( !InitNbBitsIn ) InitCountBits() ;
  }

  total   = (unsigned long)img->fd_w*(unsigned long)img->fd_h ;
  pt_img  = (int *) img->fd_addr ;
  larg    = img->fd_wdwidth*img->fd_nplanes ;
  memset(histo->rouge, 0, HISTO_SIZE*sizeof(unsigned long)) ;
  memset(histo->vert, 0, HISTO_SIZE*sizeof(unsigned long)) ;
  memset(histo->bleu, 0, HISTO_SIZE*sizeof(unsigned long)) ;
  memset(histo->gris, 0, HISTO_SIZE*sizeof(unsigned long)) ;
  memset(histo->index, 0, HISTO_SIZE*sizeof(unsigned long)) ;
  for (y = 0; y < img->fd_h; y++)
  {
    if (img->fd_nplanes <= 8)
    {
      raster2ind( pt_img, std_data, img->fd_w, img->fd_nplanes ) ;
      std_ptl = std_data ;
      for (x = 0; x < img->fd_w; x++)
      {
        ptl = std_level ;
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
    else if (img->fd_nplanes == 16)
    {
      color = (unsigned int *) pt_img ;
      for (x = 0; x < img->fd_w; x++)
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
        occup_couleurs[*color] = 1 ; /* Marque cette couleur utilis‚e */
        ind = (*color++) >> 8 ;
        histo->index[ind]++ ;
      }
    }
    else if (img->fd_nplanes == 24)
    {
      unsigned char *c ;
      unsigned long byte ;
      unsigned int  bit ;

      c = (unsigned char *) pt_img ;
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
        occup_couleurs[byte] |= 1 << bit ; /* Marque cette couleur utilis‚e */
      }
    }
    else if (img->fd_nplanes == 32)
    {
      unsigned char *c ;
      unsigned long byte ;
      unsigned int  bit ;

      c = (unsigned char *) pt_img ;
      for (x = 0; x < img->fd_w; x++)
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
        occup_couleurs[byte] |= 1 << bit ; /* Marque cette couleur utilis‚e */
      }
    }
    pt_img += larg ;
    if ( MAY_UPDATE( wprog, y ) )
    {
      pc = (int)(((long)y*100L)/(long)img->fd_h) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
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
    unsigned char *couleur = occup_couleurs ;
    
    for ( c = 0; c <= 65535U; c++, couleur++ )
      if ( *couleur > 0 ) histo->nb_colors_used++ ;
 
    Xfree( occup_couleurs ) ;
  }
  else if (img->fd_nplanes >= 24)
  {
    unsigned long c ;
    unsigned char *couleur = occup_couleurs ;
    
    for ( c = 0; c < (128L*128L*128L)/8L; c++, couleur++ )
      histo->nb_colors_used += NbBitsIn[*couleur] ;
 
    Xfree( occup_couleurs ) ;
  }

  /* Normalise les r‚sultats */
  sup = histo->rouge[0] ;
  for (x = 1; x < HISTO_SIZE; x++)
    if (histo->rouge[x] > sup) sup = histo->rouge[x] ;

  for (x = 1; x < HISTO_SIZE; x++)
    if (histo->vert[x] > sup) sup = histo->vert[x] ;

  for (x = 1; x < HISTO_SIZE; x++)
    if (histo->bleu[x] > sup) sup = histo->bleu[x] ;

  for (x = 1; x < HISTO_SIZE; x++)
    if (histo->gris[x] > sup) sup = histo->gris[x] ;

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

  if ( UseStdVDI )
  {
    if ( img->fd_nplanes >= 16 ) tc_convert( img ) ;
    else
    {
      vr_trnfm( handle, &std_img, img ) ;
      Xfree( std_img.fd_addr ) ;
    }
  }

  Xfree(std_data) ;

  return(0) ;
}

int get_nearest_vdi_index(int *rvb, void *tos_pal, long nb_cpal)
{
  unsigned char *vdi2tos ;
  long          dist, dist_mini ;
  int           *tos_palette = (int *) tos_pal ;
  int           vdi_color_index = 0 ;
  int           i, index_tos ;

  dist_mini = 3L*1000L*1000L ;
  vdi2tos = get_ptvdi2tos( nb_planes( (int)nb_cpal ) ) ;
  for ( i = 0; i < nb_cpal; i++ )
  {
    index_tos = 3*vdi2tos[i] ;
    if ( memcmp( rvb, &tos_palette[index_tos], 6 ) == 0 )
    {
      vdi_color_index = i ;
      break ;
    }
    else
    {
      dist = rvbdist( rvb[0], rvb[1], rvb[2], tos_palette[index_tos], tos_palette[1+index_tos], tos_palette[2+index_tos] ) ;
      if ( dist < dist_mini )
      {
        vdi_color_index = i ;
        dist_mini       = dist ;
      }
    }
  }

  return( vdi_color_index ) ;
}

int MakeMFDBClassicAtari(MFDB *in, MFDB *std)
{
  MFDB std_img ;
  int  ret = 0 ;

  if ( std != NULL ) memset( std, 0, sizeof(MFDB) ) ;

  if ( UseStdVDI && ( in->fd_nplanes <= 8 ) )
  {
    memcpy( &std_img, in, sizeof(MFDB) ) ;
    std_img.fd_addr = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
    if ( std_img.fd_addr == NULL ) return(-3) ;
    std_img.fd_stand = 1 ;
    vr_trnfm( handle, in, &std_img ) ;
    StdVDI2ClassicAtari( &std_img, in ) ;
    /* in est maintenant au format Atari Classic */
    if ( std != NULL )
      memcpy( std, &std_img, sizeof(MFDB) ) ;
    else
      Xfree( std_img.fd_addr ) ;
  }

  return( ret ) ;
}

void perf_reset(unsigned int perf, PERF_INFO *perf_info)
{
  perf_info->unit = PERF_UNITINTERNAL ;

  if ( perf & PERF_LOAD )       perf_info->total_load_time  = 0L ;
  if ( perf & PERF_DITHER )     perf_info->dither_time      = 0L ;
  if ( perf & PERF_DISK )       perf_info->disk_access_time = 0L ;
  if ( perf & PERF_COMPRESS )   perf_info->compress_time    = 0L ;
  if ( perf & PERF_IND2RASTER ) perf_info->ind2raster_time  = 0L ;
  if ( perf & PERF_STDFORMAT )  perf_info->stdformat_time   = 0L ;
}

void perf_start(unsigned int perf, PERF_INFO *perf_info)
{
  size_t t = clock() ;

  if ( perf & PERF_LOAD )       perf_info->itotal_load_time  = t ;
  if ( perf & PERF_DITHER )     perf_info->idither_time      = t ;
  if ( perf & PERF_DISK )       perf_info->idisk_access_time = t ;
  if ( perf & PERF_COMPRESS )   perf_info->icompress_time    = t ;
  if ( perf & PERF_IND2RASTER ) perf_info->iind2raster_time  = t ;
  if ( perf & PERF_STDFORMAT )  perf_info->istdformat_time   = t ;
  if ( perf & PERF_INTERNAL )   perf_info->iinternal_time    = t ;
}

void perf_stop(unsigned int perf, PERF_INFO *perf_info)
{
  size_t t = clock() ;

  if ( perf & PERF_LOAD )
    perf_info->total_load_time  += t-perf_info->itotal_load_time ;
  if ( perf & PERF_DITHER )
    perf_info->dither_time      += t-perf_info->idither_time ;
  if ( perf & PERF_DISK )
    perf_info->disk_access_time += t-perf_info->idisk_access_time ;
  if ( perf & PERF_COMPRESS )
    perf_info->compress_time    += t-perf_info->icompress_time ;
  if ( perf & PERF_IND2RASTER )
    perf_info->ind2raster_time  += t-perf_info->iind2raster_time ;
  if ( perf & PERF_STDFORMAT )
    perf_info->stdformat_time   += t-perf_info->istdformat_time ;
  if ( perf & PERF_INTERNAL )
    perf_info->internal_time   += t-perf_info->iinternal_time ;
}

void perf_setunit(int unit, PERF_INFO *perf_info)
{
  if ( unit != perf_info->unit )
  {
    if ( unit == PERF_UNITMS )
    {
      /* INTERNE --> Milli Secondes */
      perf_info->total_load_time  = (1000L*perf_info->total_load_time)/CLK_TCK ;
      perf_info->dither_time      = (1000L*perf_info->dither_time)/CLK_TCK ;
      perf_info->disk_access_time = (1000L*perf_info->disk_access_time)/CLK_TCK ;
      perf_info->compress_time    = (1000L*perf_info->compress_time)/CLK_TCK ;
      perf_info->ind2raster_time  = (1000L*perf_info->ind2raster_time)/CLK_TCK ;
      perf_info->stdformat_time   = (1000L*perf_info->stdformat_time)/CLK_TCK ;
      perf_info->internal_time    = (1000L*perf_info->internal_time)/CLK_TCK ;
    }
    else
    {
      /* Milli Secondes --> INTERNE */
      perf_info->total_load_time  = (CLK_TCK*perf_info->total_load_time)/1000L ;
      perf_info->dither_time      = (CLK_TCK*perf_info->dither_time)/1000L ;
      perf_info->disk_access_time = (CLK_TCK*perf_info->disk_access_time)/1000L ;
      perf_info->compress_time    = (CLK_TCK*perf_info->compress_time)/1000L ;
      perf_info->ind2raster_time  = (CLK_TCK*perf_info->ind2raster_time)/1000L ;
      perf_info->stdformat_time   = (CLK_TCK*perf_info->stdformat_time)/1000L ;
      perf_info->internal_time    = (CLK_TCK*perf_info->internal_time)/1000L ;
    }
    perf_info->unit = unit ;
  }
}

int may_use_natural_format(int final_nbplanes, int mfdb_nbplanes)
{
  if ( ( final_nbplanes <= 8 ) &&
       ( mfdb_nbplanes <= 8 ) &&
       ( mfdb_nbplanes > final_nbplanes )
     ) return( 1 ) ;
  else return( 0 ) ;
}

void TerminateImgLib(void)
{
  if ( ldg_me ) ldg_term( ap_id, ldg_me ) ;
  DImgFreeModules() ;
}