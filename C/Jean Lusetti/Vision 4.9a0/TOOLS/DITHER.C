/**************************/
/*------- DITHER.C -------*/
/* R‚duction du nombre de */
/* Couleurs d'une image   */
/**************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include "..\tools\stdprog.h"
#include "..\tools\tg.h"
#include "..\tools\ni.h"
#include "..\tools\xgem.h"
#include "..\tools\dither.h"
#include "..\tools\logging.h"
#include "..\tools\rasterop.h"


unsigned char pal_intense[256] ;
unsigned char dither_matrix[16][16] ;
unsigned char tc16[1+3*31] ;
unsigned char tc24[1+3*255] ;
unsigned char white, black ;
char          flag_init = 0 ;

/* Dans DITHER.S */
/* Dans DITHER.S */
void dither_rvb16to8planes(unsigned short* pt_rvb, short w, unsigned char* pt) ;
void dither_rvb24to8planes(unsigned char* pt_rvb, short w, unsigned char* pt, short b32) ;
void dither_rvb32to8planes(unsigned long* pt_rvb, short w, unsigned char* pt) ;
extern unsigned char tab_grey[256*3] ;
extern unsigned char new_ind[256*3] ;

/* Dans DIT216.S : Tramage TC --> 216 couleurs  */
void dither_216c(MFDB* in, unsigned char* indexes) ;


/* Array to map a 5bit color coding (TC16b, 0...31) to a VDI value (0...1000) */
#define rf (1000.0/31.0)
static short c5bto1000[32] = { (short)(0.5+0*rf),  (short)(0.5+1*rf),  (short)(0.5+2*rf),  (short)(0.5+3*rf),  (short)(0.5+4*rf),  (short)(0.5+5*rf),  (short)(0.5+6*rf),  (short)(0.5+7*rf),
                               (short)(0.5+8*rf),  (short)(0.5+9*rf),  (short)(0.5+10*rf), (short)(0.5+11*rf), (short)(0.5+12*rf), (short)(0.5+13*rf), (short)(0.5+14*rf), (short)(0.5+15*rf),
                               (short)(0.5+16*rf), (short)(0.5+17*rf), (short)(0.5+18*rf), (short)(0.5+19*rf), (short)(0.5+20*rf), (short)(0.5+21*rf), (short)(0.5+22*rf), (short)(0.5+23*rf),
                               (short)(0.5+24*rf), (short)(0.5+25*rf), (short)(0.5+26*rf), (short)(0.5+27*rf), (short)(0.5+28*rf), (short)(0.5+29*rf), (short)(0.5+30*rf), (short)(0.5+31*rf),
                             } ;

/*
FILE *stream_ni ;
unsigned char ni_24bto8b[256*3] ;
unsigned char ni_24bto4b[256*3] ;
unsigned char tg_24bto4b[32*3] ;
unsigned char tg_24bto8b[32*3] ;


void init_ni(int nplanes, unsigned char *new_ind)
{
  INFO_IMAGE inf ;
  int        start = 0 ;
  int        x, y, min, nc, ind ;
  int        *pt_pal ;
  float      vx ;

  nc = 1 << nplanes ;
  if ( nplanes == 8)
  {
    start = 16 ;
    nc-- ;
  }
  if ( set_greylevel( nplanes, &inf ) < 0 ) return ;
  for ( x = 0; x < 256; x++ )
  {
    pt_pal  = inf.palette ;
    pt_pal += 3*start ;
    min    = 1000 ;
    vx     = (int) ((float)x*1000.0/255.0) ;
    for ( y = start; y < nc; y++ )
    {
      if (abs(*pt_pal-vx) < min)
      {
        ind = y ;
        min = abs(*pt_pal-vx) ;
      }
      pt_pal += 3 ;
    }
    tab_grey[x] = ind ;
  }

  Xfree( inf.palette ) ;
  for ( x = 0, y = 0; x < 256; x++, y += 3 )
  {
    new_ind[y]   = tab_grey[x] ;
    new_ind[1+y] = tab_grey[x] ;
    new_ind[2+y] = tab_grey[x] ;
    fprintf( stream_ni, "0x%02x, 0x%02x, 0x%02x, ", new_ind[y], new_ind[1+y], new_ind[2+y] ) ;
    if ( (x & 0x03) == 0x03 ) fprintf( stream_ni, "\n" ) ;
  }
  fprintf( stream_ni, "\n\n\n" ) ;
}

void init_tg(int nplanes, unsigned char *tab_grey)
{
  INFO_IMAGE inf ;
  int        start = 0 ;
  int        x, y, min, nc, ind ;
  int        *pt_pal ;
  float      vx ;

  if ( set_greylevel( nplanes, &inf ) < 0 ) return ;
  nc = 1 << nplanes ;
  if ( nplanes == 8)
  {
    start = 16 ;
    nc-- ;
  }
  for ( x = 0; x < 96; x++ )
  {
    pt_pal  = inf.palette ;
    pt_pal += 3*start ;
    min    = 1000 ;
    vx     = (int) ((float)x*1000.0/96.0) ;
    for ( y = start; y < nc; y++ )
    {
      if ( abs(*pt_pal-vx) < min )
      {
        ind = y ;
        min = abs(*pt_pal-vx) ;
      }
      pt_pal += 3 ;
    }
    tab_grey[x] = ind ;
    fprintf( stream_ni, "0x%02x, ", tab_grey[x] ) ;
    if ( (x & 0x07) == 0x07 ) fprintf( stream_ni, "\n" ) ;
  }
  fprintf( stream_ni, "\n\n\n" ) ;
}
*/

static void init_dither_matrix(void)
{
  float         coe ;
  int           i, j, k, k1, k2 ;
  unsigned char D[8][8] ;
  unsigned char *vdi2tos ;

  /* Initialisation du premier bloc 8x8 */
  D[0][0] = 0 ;  D[0][1] = 32 ;
  D[0][2] = 8 ;  D[0][3] = 40 ;
  D[1][0] = 48 ; D[1][1] = 16 ;
  D[1][2] = 56 ; D[1][3] = 24 ;
  D[2][0] = 12 ; D[2][1] = 44 ;
  D[2][2] = 4 ;  D[2][3] = 36 ;
  D[3][0] = 60 ; D[3][1] = 28 ;
  D[3][2] = 52 ; D[3][3] = 20 ;

  /* Calcul de D(8,8) */
  for (j = 0; j < 4; j++)
    for (i = 0; i < 4; i++)
    {
      k         = D[i][j] ;
      k1        = j+4 ;
      k2        = i+4 ;
      D[i][k1]  = k+2 ;
      D[k2][j]  = k+3 ;
      D[k2][k1] = k+1 ;
    }

  /* D‚duction de D(16,16) */
  for (i = 0; i < 8; i++)
    for (j = 0; j < 8; j++) dither_matrix[i][j] = 4*D[i][j] ;

  for (i = 8; i < 16; i++)
    for (j = 0; j < 8; j++) dither_matrix[i][j] = 4*D[i-8][j]+2 ;

  for (i = 0; i < 8; i++)
    for (j = 8; j < 16; j++) dither_matrix[i][j] = 4*D[i][j-8]+3 ;

  for (i = 8; i < 16; i++)
    for (j = 8; j < 16; j++) dither_matrix[i][j] = 4*D[i-8][j-8]+1 ;

  coe = 255.0/3.0/31.0 ;
  for (i = 0; i <= 3*31; i++) tc16[i] = (unsigned char) (0.5+(float)i*coe) ;
  coe = 1/3.0 ;
  for (i = 0; i <= 3*255; i++) tc24[i] = (unsigned char) (0.5+(float)i*coe) ;

  vdi2tos = get_ptvdi2tos(1 /*screen.fd_nplanes*/) ;
  white   = vdi2tos[0] ;
  black   = vdi2tos[1] ;

/*
  init_ni( 4, ni_24bto4b ) ;
  init_ni( 8, ni_24bto8b ) ;

  stream_ni = fopen( "TG.H", "wb" ) ;
  init_tg( 4, tg_24bto4b ) ;
  init_tg( 8, tg_24bto8b ) ;

  fclose( stream_ni ) ;
*/
  flag_init = 1 ;
}

static void init_intensity(INFO_IMAGE* inf)
{
  float coe, fval ;
  int   current_pal[3*256] ;
  int   *red, *green, *blue ;
  int   i, nbc, val ;

  if ( inf->mfdb.fd_nplanes <= 8 )
  {
    unsigned char* vdi2tos = get_ptvdi2tos( inf->mfdb.fd_nplanes ) ;

    if ( vdi2tos == NULL ) return ;
    coe = 256.0/1000.0/3.0 ;
    if ( inf->palette )
    {
      red = (int*) inf->palette ;
      nbc = (int) inf->nb_cpal ;
    }
    else
    {
      get_tospalette(current_pal) ;
      red = current_pal ;
      nbc = nb_colors ;
    }
    green = red + 1 ;
    blue  = green + 1 ;
    for ( i = 0; i < nbc; i++ )
    {
      if ( *red > 1000 )   *red   = 1000 ;
      if ( *green > 1000 ) *green = 1000 ;
      if ( *blue > 1000 )  *blue  = 1000 ;
      val  = *red + *green + *blue ;
      fval = (float)val*coe ;
      pal_intense[i] = (unsigned char) fval ;
      red   += 3 ;
      green += 3 ;
      blue  += 3 ;
    }
  }
}

static int dither_seuil(INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  MFDB*          in = &inf_in->mfdb ;
  MFDB*          out = &inf_out->mfdb ;
  long           taille ;
  int*           pt_ligne ;
  int            nplan ;
  int            j, x, y ;
  int            ind ;
  int            nb_px ;
  unsigned char* buffer, *pt ;
  unsigned char* matrix_line ;
  unsigned char* vdi2tos ;
  unsigned char  r, v, b ;
  unsigned char  local_back, local_white ;
  unsigned char  intensity ;

  nplan = out->fd_nplanes ;
  if ( nplan > 8 ) nplan = 1 ;
  if ( in->fd_nplanes <= nplan ) return EIMG_DATAINCONSISTENT ;

  vdi2tos = get_ptvdi2tos( nplan ) ;
  if ( vdi2tos == NULL ) return EIMG_DATAINCONSISTENT ;
  local_white = vdi2tos[0] ;
  local_back  = vdi2tos[1] ;

  if ( inf_in->natural_format ) nb_px = inf_in->natural_width ;
  else                          nb_px = in->fd_w ;
  
  CopyMFDB( out, in ) ;
  out->fd_nplanes = nplan ;
  out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;
  img_raz( out ) ;

  if ( inf_in->natural_format )
  {
    buffer = inf_in->natural_format ;
    i2r_init( out, inf_in->natural_width, 1 ) ;
  }
  else
  {
    buffer = (unsigned char*) Xalloc( in->fd_w ) ;
    if ( buffer == NULL )
    {
      Xfree( out->fd_addr ) ;
      return EIMG_NOMEMORY ;
    }
    i2r_init(out, in->fd_w, 1) ;
  }
  i2r_nb = (long) nb_px ;
  i2r_data = buffer ;

  if ( !flag_init ) init_dither_matrix() ;

  if ( in->fd_nplanes <= 8 )
  {
    /*inf_out->palette = Xalloc( inf_in->nb_cpal*3*sizeof(short) ) ;
    if ( inf_out->palette == NULL )
    {
      Xfree( buffer ) ;
      Xfree(out->fd_addr) ;
      return EIMG_NOMEMORY ;
    }
    inf_out->nb_cpal = inf_in->nb_cpal ;*/
    init_intensity( inf_out ) ;
    pt_ligne = (int*) in->fd_addr ;
    taille   = (long)in->fd_wdwidth*(long)in->fd_nplanes ;
    for ( y = 0; y < in->fd_h; y++ )
    {
      if ( !inf_in->natural_format )
      {
        raster2ind( pt_ligne, buffer, (long)in->fd_w, in->fd_nplanes ) ;
        pt = buffer ;
      }
      else pt = i2r_data ;
      j = y & 0x0F ;
      matrix_line = &dither_matrix[0][0]+(j << 4) ;
      for (x = 0; x < nb_px; x++)
      {
        ind = *pt ;
        intensity = pal_intense[ind] ;
        if ( intensity == 0 ) *pt++ = local_back ;
        else
        {
          if (intensity < matrix_line[x & 0x0F]) *pt++ = local_back ;
          else                                   *pt++ = local_white ;
        }
      }

      ind2raster() ;
      if ( inf_in->natural_format ) (unsigned char*)i2r_data += inf_in->natural_width ;
      else                          pt_ligne += taille ;

      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 16 )
  {
    unsigned int* pt_rvb = (unsigned int *) in->fd_addr ;

    taille = 16*in->fd_wdwidth-in->fd_w ;
    for (y = 0; y < in->fd_h; y++)
    {
      pt = buffer ;
      j  = y & 0x0F ;
      matrix_line = &dither_matrix[0][0]+(j << 4) ;
      for (x = 0; x < in->fd_w; x++)
      {
        r = (unsigned char) *pt_rvb & 0x001F ;
        v = (unsigned char) ((*pt_rvb >> 6) & 0x001F) ;
        b = (unsigned char) ((*pt_rvb >> 11) & 0x001F) ;
        intensity = r+v+b ;
        intensity = tc16[intensity] ;
        if (intensity == 0) *pt++ = local_back ;
        else
        {
          if (intensity < matrix_line[x & 0x0F]) *pt++ = local_back ;
          else                                   *pt++ = local_white ;
        }
        pt_rvb++ ;
      }
      ind2raster() ;
      pt_rvb += taille ;
      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 24 )
  {
    unsigned char* pt_rvb24 ;

    pt_rvb24 = (unsigned char *) in->fd_addr ;
    for (y = 0; y < in->fd_h; y++)
    {
      pt = buffer ;
      j  = y & 0x0F ;
      matrix_line = &dither_matrix[0][0]+(j << 4) ;
      for (x = 0; x < in->fd_w; x++)
      {
        r = *pt_rvb24++ ;
        v = *pt_rvb24++ ;
        b = *pt_rvb24++ ;
        intensity = tc24[r+v+b] ;
        if (intensity == 0) *pt++ = local_back ;
        else
        {
          if (intensity < matrix_line[x & 0x0F]) *pt++ = local_back ;
          else                                   *pt++ = local_white ;
        }
      }
      ind2raster() ;
      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 32 )
  {
    unsigned long* pt_rvb = (unsigned long*) in->fd_addr ;

    taille = 16*in->fd_wdwidth-in->fd_w ;
    for (y = 0; y < in->fd_h; y++)
    {
      pt = buffer ;
      j  = y & 0x0F ;
      matrix_line = &dither_matrix[0][0]+(j << 4) ;
      for (x = 0; x < in->fd_w; x++)
      {
        b = (unsigned char) (*pt_rvb >> 8) & 0xFF ;
        v = (unsigned char) (*pt_rvb >> 16) & 0xFF ;
        r = (unsigned char) (*pt_rvb >> 24) ;
        intensity = tc24[r+v+b] ;
        if ( intensity == 0 ) *pt++ = local_back ;
        else
        {
          if ( intensity < matrix_line[x & 0x0F] ) *pt++ = local_back ;
          else                                     *pt++ = local_white ;
        }
        pt_rvb++ ;
      }
      ind2raster() ;
      pt_rvb += taille ;
      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }

  if ( !inf_in->natural_format ) Xfree(buffer) ;

  return EIMG_SUCCESS ;
}

static int dither_gris(INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog, int force_allocate)
{
  MFDB*         in = &inf_in->mfdb ;
  MFDB*         out = &inf_out->mfdb ;
  long          taille ;
  int           *pt_pal ;
  int           *pt_ligne ;
  int           nplan ;
  int           x, y, vx ;
  int           ind, min ;
  int           nb_px ;
  unsigned char *buffer, *pt ;

  if ( !flag_init ) init_dither_matrix() ;

  if ( inf_in->natural_format ) nb_px = inf_in->natural_width ;
  else                          nb_px = in->fd_w ;
  
  nplan = out->fd_nplanes ;
  CopyMFDB( out, in ) ;
  if ( in->fd_nplanes < nplan ) out->fd_nplanes = in->fd_nplanes ;
  else                          out->fd_nplanes = nplan ;

  if ( in->fd_nplanes <= nplan )
  {
    int ret ;

    if ( force_allocate ) out->fd_addr = NULL ;
    ret = info_image_duplicate( inf_in, inf_out ) ;

    if ( ret == EIMG_SUCCESS ) make_greyimage( inf_out, 1 ) ;
    return ret ;
  }
  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;

  if ( nb_px & 0x0F ) img_raz( out ) ;

  if ( inf_in->natural_format )
  {
    buffer = inf_in->natural_format ;
    i2r_init(out, inf_in->natural_width, 1) ;
  }
  else
  {
    buffer = (unsigned char*) Xalloc(in->fd_w) ;
    if (buffer == NULL)
    {
      Xfree(out->fd_addr) ;
      return EIMG_NOMEMORY ;
    }
    i2r_init(out, in->fd_w, 1) ;
  }
  i2r_nb = (long) nb_px ;
  i2r_data = buffer ;

  if ( set_greylevel( out->fd_nplanes, inf_out ) < 0 )
  {
    if ( !inf_in->natural_format ) Xfree(buffer) ;
    Xfree(out->fd_addr) ;
    return EIMG_NOMEMORY ;
  }  

  if ( in->fd_nplanes <= 8 )
  {
    init_intensity( inf_out ) ;
    for ( x = 0; x < 256; x++ )
    {
      pt_pal = inf_out->palette ;
      min    = 1000 ;
      vx     = (int) ((float)x*1000.0/256.0) ;
      for ( y = 0; y < inf_out->nb_cpal; y++ )
      {
        if (abs(*pt_pal-vx) < min)
        {
          ind = y ;
          min = abs(*pt_pal-vx) ;
        }
        pt_pal += 3 ;
      }
      tab_grey[x] = ind ;
    }
    for ( x = 0; x < 256; x++ ) new_ind[x] = tab_grey[pal_intense[x]] ;

    pt_ligne = (int *) in->fd_addr ;
    taille   = (long)in->fd_wdwidth*(long)in->fd_nplanes ;
    for ( y = 0; y < in->fd_h; y++ )
    {
      if ( !inf_in->natural_format )
      {
        raster2ind( pt_ligne, buffer, (long)in->fd_w, in->fd_nplanes ) ;
        pt = buffer ;
      }
      else pt = i2r_data ;

      for (x = 0; x < nb_px; x++, pt++) *pt = new_ind[*pt] ;

      ind2raster() ;
      if ( !inf_in->natural_format ) pt_ligne += taille ;
      else                           (unsigned char*)i2r_data += inf_in->natural_width ;

      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 16 )
  {
    unsigned short* pt_rvb = (unsigned short*) in->fd_addr ;

    if ( out->fd_nplanes == 8 ) memcpy( tab_grey, tg_16bto8b, 32*3 ) ;
    else                        memcpy( tab_grey, tg_16bto4b, 32*3 ) ;
    taille = 16*in->fd_wdwidth ;
    for ( y = 0; y < in->fd_h; y++ )
    {
      dither_rvb16to8planes( pt_rvb, in->fd_w, buffer ) ;
      ind2raster() ;
      pt_rvb += taille ;
      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 24 )
  {
    unsigned char *ptc_rvb ;

    if ( out->fd_nplanes == 8 ) memcpy( new_ind, ni_24bto8b, 256*3 ) ;
    else                        memcpy( new_ind, ni_24bto4b, 256*3 ) ;
    ptc_rvb = (unsigned char *) in->fd_addr ;
    taille = 3L*(long)(in->fd_wdwidth << 4) ;
    for ( y = 0; y < in->fd_h; y++ )
    {
      dither_rvb24to8planes( ptc_rvb, in->fd_w, buffer, 0 ) ;
      ind2raster() ;
      ptc_rvb += taille ;
      (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 32 )
  {
    if ( out->fd_nplanes == 16 ) tc32totc16grey( in, out ) ;
    else if ( out->fd_nplanes <= 8 )
    {
      unsigned long* pt_rvb = (unsigned long*) in->fd_addr ;

      if ( out->fd_nplanes == 8 ) memcpy( new_ind, ni_24bto8b, 256*3 ) ;
      else                        memcpy( new_ind, ni_24bto4b, 256*3 ) ;
      taille = 16*in->fd_wdwidth ;
      for (y = 0; y < in->fd_h; y++)
      {
        dither_rvb24to8planes( (unsigned char*) pt_rvb, in->fd_w, buffer, 1 ) ;
        ind2raster() ;
        pt_rvb += taille ;
        (void)GWProgRange( wprog, y, in->fd_h, NULL ) ;
      }
    }
  }

  if ( !inf_in->natural_format ) Xfree(buffer) ;

  return EIMG_SUCCESS ;
}

static void dither_line(unsigned char* buffer, int nb, unsigned char* intensity, int mline)
{
  int           x, i, j, ind ;
  unsigned char intense ;
  unsigned char *pt ;
  unsigned char *matrix_line ;

  pt          = buffer ;
  j           = mline & 0x0F ;
  matrix_line = &dither_matrix[0][0]+(j << 4) ;
  for (x = 0; x < nb; x++)
  {
    i       = x & 0x0F ;
    ind     = *pt ;
    intense = intensity[ind] ;
    if (intense == 0) *pt++ = black ;
    else
    {
      if (intense < matrix_line[i]) *pt++ = black ;
      else                          *pt++ = white ;
    }
  }
}

static void dither_tc16line(int* buffer, unsigned char* out, int nb, unsigned char* tc16lum, int mline)
{
  int           *pt_rvb ;
  int           x, i, j ;
  unsigned char *matrix_line ;
  unsigned char *pt_out ;
  unsigned char r, v, b ;
  unsigned char intensity ;

  pt_rvb      = buffer ;
  pt_out      = out ;
  j           = mline & 0x0F ;
  matrix_line = &dither_matrix[0][0]+(j << 4) ;
  for (x = 0; x < nb; x++)
  {
    r = (unsigned char) *pt_rvb & 0x001F ;
    v = (unsigned char) ((*pt_rvb >> 6) & 0x001F) ;
    b = (unsigned char) ((*pt_rvb >> 11) & 0x001F) ;
    intensity = r+v+b ;
    intensity = tc16lum[intensity] ;
    i = x & 0x0F ;
    if (intensity == 0) *pt_out++ = black ;
    else
    {
      if (intensity < matrix_line[i]) *pt_out++ = black ;
      else                            *pt_out++ = white ;
    }
    pt_rvb++ ;
  }
}

static void ind_strech(unsigned char* in, unsigned char* out, int nb_out, int* table)
{
  int           x ;
  unsigned char *pt_out ;

  pt_out = out ;
  for (x = 0; x < nb_out; x++) *pt_out++ = in[table[x]] ;
}

static void tc16_strech(int* pt_raster, int* out, int nb_out, int* table)
{
  int x ;
  int *pt_out ;

  pt_out = out ;
  for (x = 0; x < nb_out; x++) *pt_out++ = pt_raster[table[x]] ;
}

int dither_ratio(MFDB* in, INFO_IMAGE* inf, MFDB* out, int pc_x, int pc_y, GEM_WINDOW* wprog)
{
  int           *pt_raster ;
  int           *strech_table ;
  int           nplan ;
  int           lin, ligne ;
  int           *ibuffer_out ;
  unsigned char *buffer_in, *buffer_out ;
  
  nplan = out->fd_nplanes ;
  if (in->fd_nplanes <= nplan) return(-2) ;

  buffer_in = (unsigned char *) Xalloc(16*in->fd_wdwidth) ;
  if (buffer_in == NULL) return(-1) ;

  CopyMFDB( out, in ) ;
  out->fd_nplanes = nplan ;
  out->fd_w       = (int) (((long)in->fd_w*(long)pc_x)/100L) ;
  out->fd_h       = (int) (((long)in->fd_h*(long)pc_y)/100L) ;
  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
  buffer_out      = (unsigned char*) Xalloc(16*out->fd_wdwidth) ;
  if (buffer_out == NULL)
  {
    Xfree(buffer_in) ;
    return(-1) ;
  }
  if (in->fd_nplanes > 8)
  {
    ibuffer_out = (int *) Xalloc(32*out->fd_wdwidth) ;
    if (ibuffer_out == NULL)
    {
      Xfree(buffer_out) ;
      Xfree(buffer_in) ;
      return(-1) ;
    }
  }
  strech_table = (int *) Xalloc(32*out->fd_wdwidth) ;
  if (strech_table == NULL)
  {
    if (in->fd_nplanes > 8) Xfree(ibuffer_out) ;
    Xfree(buffer_out) ;
    Xfree(buffer_in) ;
    return(-1) ;
  }

  out->fd_addr = img_alloc(out->fd_w, out->fd_h, nplan) ;
  if (out->fd_addr == NULL)
  {
    Xfree(strech_table) ;
    if (in->fd_nplanes > 8) Xfree(ibuffer_out) ;
    Xfree(buffer_out) ;
    Xfree(buffer_in) ;
    return(-1) ;
  }
  img_raz(out) ;

  for (lin = 0; lin < out->fd_w; lin++) strech_table[lin] = (int) (((long)lin*100L)/(long)pc_x) ;
  i2r_init(out, out->fd_w, 1) ;
  i2r_data = buffer_out ;
  i2r_nb   = out->fd_w ;
  if (!flag_init) init_dither_matrix() ;
  init_intensity( inf ) ;
  for (ligne = 0; ligne < out->fd_h; ligne++)
  {
    lin        = (int) ((100L*(long)ligne)/pc_y) ;
    pt_raster  = (int *) in->fd_addr ;
    pt_raster += (long)lin*(long)in->fd_wdwidth*(long)in->fd_nplanes ;
    if (in->fd_nplanes <= 8)
    {
      raster2ind(pt_raster, buffer_in, (long)in->fd_w, in->fd_nplanes) ;
      ind_strech(buffer_in, buffer_out, out->fd_w, strech_table) ;
      dither_line(buffer_out, out->fd_w, pal_intense, ligne) ;
    }
    else if (in->fd_nplanes == 16)
    {
      tc16_strech(pt_raster, ibuffer_out, out->fd_w, strech_table) ;
      dither_tc16line(ibuffer_out, buffer_out, out->fd_w, tc16, ligne) ;
    }
    ind2raster() ;
    (void)GWProgRange( wprog, ligne, out->fd_h, NULL ) ;
  }

  Xfree(strech_table) ;
  Xfree(buffer_out) ;
  if (in->fd_nplanes > 8) Xfree(ibuffer_out) ;
  Xfree(buffer_in) ;

  return 0 ;
}

static int init_dt216_pal(INFO_IMAGE* inf)
{
  int           r, v, b ;
  int           *pt_pal ;
  int           val1000[6] = { 0, 200, 400, 600, 800, 1000 } ;
  unsigned char *pt_vdi2tos ;

  inf->nb_cpal = 256 ;
  inf->palette = Xcalloc( inf->nb_cpal, 3*2 ) ;
  if ( inf->palette == NULL ) return -1 ;

  pt_pal  = (int*) inf->palette ;
  pt_vdi2tos = get_ptvdi2tos( 8 ) ;
  for ( b = 0; b < 16; b++ )
  {
    v = 3*pt_vdi2tos[b] ;
    memcpy( &pt_pal[v], &vdi_sys_colors[3*b], 6 ) ;
  }
  pt_pal += 16*3 ;
  for ( b = 0; b < 6; b++ )
  {
    for ( v = 0; v < 6; v++ )
    {
      for ( r = 0; r < 6; r++ )
      {
        *pt_pal++ = val1000[r] ; /* Rouge */
        *pt_pal++ = val1000[v] ; /* Vert  */
        *pt_pal++ = val1000[b] ; /* Bleu  */
      }
    }
  }

  return 0 ;
}

static int dither_tc_216(INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  MFDB*          in = &inf_in->mfdb ;
  MFDB*          out = &inf_out->mfdb ;
  MFDB           img ;
  int            packet_lines = 32 ; /* Obligatoire pour dither_216c */
  long           packet_size ;
  int            l ;
  int            original_w ;
  unsigned char* tmp_addr ;
  unsigned char* indexes ;

  if ( in->fd_nplanes <= 8 ) return info_image_duplicate( inf_in, inf_out ) ;

  original_w = in->fd_w ;
  in->fd_w   = align16( in->fd_w ) ; /* We need image to be 16 pixels aligned */
  CopyMFDB( out, in ) ;
  out->fd_nplanes = 8 ;
  out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;

  packet_size = (long) out->fd_w * (long)packet_lines ;
  indexes = (unsigned char*) Xalloc( packet_size ) ;
  if ( indexes == NULL )
  {
    Xfree( out->fd_addr ) ;
    return EIMG_NOMEMORY ;
  }
  i2r_init( out, out->fd_w, 0 ) ;
  i2r_data = indexes ;
  i2r_nb   = packet_size ;

  if ( init_dt216_pal( inf_out ) )
  {
    Xfree( indexes ) ;
    Xfree( out->fd_addr ) ;
    return EIMG_NOMEMORY ;
  }

  CopyMFDB( &img, in ) ;
  tmp_addr    = img.fd_addr ;
  img.fd_h    = packet_lines ;
  packet_size = img_size( img.fd_w, img.fd_h, img.fd_nplanes ) ;
  for ( l = 0; l <= in->fd_h-packet_lines ; l += packet_lines )
  {
    dither_216c( &img, indexes ) ;
    ind2raster() ;
    tmp_addr   += packet_size ;
    img.fd_addr = tmp_addr ;
    (void)GWProgRange( wprog, l, out->fd_h, NULL ) ;
  }
  img.fd_h = in->fd_h % packet_lines ;
  if ( img.fd_h )
  {
    /* Il reste moins de packet_lines lignes … convertir */
    i2r_nb = (long) out->fd_w * (long)img.fd_h ;
    dither_216c( &img, indexes ) ;
    ind2raster() ;
  }

  in->fd_w  = original_w ;
  out->fd_w = original_w ;
  RasterResetUnusedData( out ) ;

  Xfree( indexes ) ;
  
  return EIMG_SUCCESS ;
}

static int is_grey(MFDB* in)
{
  int           is_grey = 1 ;
  int           step ;
  long          offset ;
  long          inc_x, inc_y, mult = 3 ;
  unsigned int  r, v, b ;
  unsigned int* pt16 ;
  unsigned char* pt24 ;

  /* On teste 16 pixels sur la diagonale descendante */
  inc_x  = in->fd_w >> 4 ;
  inc_y  = in->fd_h >> 4 ;
  switch( in->fd_nplanes )
  {
    case 16 : 
              offset  = inc_y * (long)in->fd_w ;
              offset += inc_x ;
              pt16 = (unsigned int *) in->fd_addr ;
              for ( step = 0 ; is_grey && (step < 16); step++, pt16 += offset )
              {
                r = *pt16 >> 11 ;
                v = ( *pt16 >> 6 ) & 0x1F ;
                b = *pt16 & 0x1F ;
                if ( (r != v) || (r != b) || (v != b) ) is_grey = 0 ;
              }
              break ;

    case 32 : mult = 4 ;
    case 24 : offset  = inc_y * (long)in->fd_w * mult ;
              offset += inc_x * mult ;
              pt24 = (unsigned char*) in->fd_addr ;
              for ( step = 0 ; is_grey && (step < 16); step++, pt24 += offset )
                if ( (pt24[0] != pt24[1]) || (pt24[0] != pt24[2]) || (pt24[1] != pt24[2]) ) is_grey = 0 ;
              break ;

    default : is_grey = 0 ;
              break ;
  }

  return is_grey ;
}

static int dither_bichro(INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  MFDB*           in = &inf_in->mfdb ;
  MFDB*           out = &inf_out->mfdb ;
  unsigned char*  ptc_line = in->fd_addr ;
  size_t          size_line = img_size( in->fd_w, 1, in->fd_nplanes ) ;
  int             ret = EIMG_DATAINCONSISTENT ;
  unsigned short* word_out ;
  unsigned short  cached_word_out, bitmask ;
  short           rgb_threshold = inf_in->dither_param ;
  short           x, ln ;

  /* output will be 1 plane */
  CopyMFDB( out, in ) ;
  out->fd_nplanes = 1 ;
  out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;

  word_out = out->fd_addr ;
  if ( in->fd_nplanes == 1 )
  {
    memcpy( out->fd_addr, in->fd_addr, size_line*in->fd_h ) ;
    ret = EIMG_SUCCESS ;
  }
  else if ( in->fd_nplanes <= 8 )
  {
    unsigned char  pal_val[256] ; /* 0: pixel has index pointing to palette < rgb_threshold */
    unsigned char* tos_indexes ;
    unsigned char* vdi2tos ;
    short*         vdi_palette = (short*) inf_in->palette ;
    short*         pal_item ;

    vdi2tos = get_ptvdi2tos( in->fd_nplanes) ;
    if ( vdi2tos == NULL ) return EIMG_DATAINCONSISTENT ;

    tos_indexes = Xalloc( align16(inf_in->mfdb.fd_w) ) ;
    if ( tos_indexes == NULL )
    {
      Xfree( out->fd_addr ) ;
      out->fd_addr = NULL ;
      return EIMG_NOMEMORY ;
    }
    if ( rgb_threshold < 0 ) rgb_threshold = 500*3 ;
    else                     rgb_threshold = (10*3*rgb_threshold) ; /* Passed as percentage of maximum value */

    /* Build pal_val telling if for this palette index, we have intensity > threshold */
    memzero( pal_val, sizeof(pal_val) ) ;
    for ( x = 0; x < (short)inf_in->nb_cpal; x++ )
    {
      pal_item = &vdi_palette[3*vdi2tos[x]] ;
      if ( pal_item[0]+pal_item[1]+pal_item[2] > rgb_threshold ) pal_val[x] = 1 ;
    }

    for ( ln = 0; ln < in->fd_h; ln++, ptc_line += size_line )
    {
      raster2ind( (int*)ptc_line, tos_indexes, (long)in->fd_w, in->fd_nplanes ) ;
      bitmask         = 0x8000 ;
      cached_word_out = 0 ;
      for ( x = 0; x < in->fd_w; x++ )
      {
        if ( pal_val[tos_indexes[x]] ) cached_word_out |= bitmask ;
        bitmask = bitmask >> 1 ;
        if ( bitmask == 0 )
        {
          bitmask         = 0x8000 ;
          *word_out++     = cached_word_out ;
          cached_word_out = 0 ;
        }
      }
      if ( out->fd_w & 0x0F ) *word_out++ = cached_word_out ;
      (void)GWProgRange( wprog, ln, out->fd_h, NULL ) ;
    }
    Xfree( tos_indexes ) ;
    ret = EIMG_SUCCESS ;
  }
  else if ( in->fd_nplanes == 16 )
  {
    unsigned short* pt_line ;
    unsigned short* pt_pixel ;
    unsigned short  r, g, b, pixel ;

    if ( rgb_threshold < 0 ) rgb_threshold = 16*3 ;
    else                     rgb_threshold = (32*3*rgb_threshold)/100 ; /* Passed as percentage of maximum value */
    for ( ln = 0; ln < in->fd_h; ln++, ptc_line += size_line )
    {
      pt_line         = (unsigned short*) ptc_line ;
      bitmask         = 0x8000 ;
      cached_word_out = 0 ;
      for ( pt_pixel = pt_line ; pt_pixel < pt_line+out->fd_w; pt_pixel++ )
      {
        pixel = *pt_pixel ;
        b     = pixel & 0x1F ; /* 5bit blue */
        pixel = pixel >> 6 ;
        g     = pixel & 0x1F ; /* 5bit green */
        r     = pixel >> 5 ;   /* 5bit red */
        if ( r+g+b < rgb_threshold ) /* Less than average grey on 3 5bit components */
          cached_word_out |= bitmask ;
        bitmask = bitmask >> 1 ;
        if ( bitmask == 0 )
        {
          bitmask         = 0x8000 ;
          *word_out++     = cached_word_out ;
          cached_word_out = 0 ;
        }
      }
      if ( out->fd_w & 0x0F ) *word_out++ = cached_word_out ;
      (void)GWProgRange( wprog, ln, out->fd_h, NULL ) ;
    }
    ret = EIMG_SUCCESS ;
  }
  else if ( in->fd_nplanes == 32 )
  {
    unsigned long* pt_line ;
    unsigned long* pt_pixel ;
    unsigned long  r, g, b, pixel ;

    if ( rgb_threshold < 0 ) rgb_threshold = 128*3 ;
    else                     rgb_threshold = (short)((255L*3L*rgb_threshold)/100L) ; /* Passed as percentage of maximum value */
    for ( ln = 0; ln < in->fd_h; ln++, ptc_line += size_line )
    {
      pt_line         = (unsigned long*) ptc_line ;
      bitmask         = 0x8000 ;
      cached_word_out = 0 ;
      for ( pt_pixel = pt_line ; pt_pixel < pt_line+out->fd_w; pt_pixel++ )
      {
        pixel = *pt_pixel >> 8 ; /* RGB0 --> 0RGB */
        b     = pixel & 0xFF ;
        pixel = pixel >> 8 ;
        g     = pixel & 0xFF ;
        pixel = pixel >> 8 ;
        r     = pixel & 0xFF ;
        if ( r+g+b < rgb_threshold ) /* Less than average grey on 3 8bit components */
          cached_word_out |= bitmask ;
        bitmask = bitmask >> 1 ;
        if ( bitmask == 0 )
        {
          bitmask         = 0x8000 ;
          *word_out++     = cached_word_out ;
          cached_word_out = 0 ;
        }
      }
      if ( out->fd_w & 0x0F ) *word_out++ = cached_word_out ;
      (void)GWProgRange( wprog, ln, out->fd_h, NULL ) ;
    }
    ret = EIMG_SUCCESS ;
  }

  return ret ;
}

static short add_color_in_pal16(unsigned short pixel, unsigned short* colors_in_pal, INFO_IMAGE* inf_out)
{
  short i ;

  /* Check if this color exists in the list we maintain towards the palette */
  for ( i = 0; colors_in_pal[i] != (unsigned short)-1; i++ )
    if ( pixel == colors_in_pal[i] ) break ;

  if ( colors_in_pal[i] != (unsigned short)-1 ) return i ; /* This color is already present in the palette */

  if ( i < (short)inf_out->nb_cpal )
  {
    /* This color is not yet in the list but we still have room for it */
    unsigned short  r, g, b ;
    short*          pal_element = (short*)inf_out->palette ;

    pal_element      = &pal_element[3*i] ;
    colors_in_pal[i] = pixel ;
    b                = pixel & 0x1F ; /* 5bit blue */
    *pal_element++   = c5bto1000[b] ;
    pixel            = pixel >> 6 ;
    g                = pixel & 0x1F ; /* 5bit green */
    *pal_element++   = c5bto1000[g] ;
    r                = pixel >> 5 ;   /* 5bit red */
    *pal_element++   = c5bto1000[r] ;
  }
  else i = -1 ; /* List is full */

  return i ;
}

static short add_color_in_pal32(unsigned long pixel, unsigned long* colors_in_pal, INFO_IMAGE* inf_out)
{
  short i ;

  /* Check if this color exists in the list we maintain towards the palette */
  for ( i = 0; colors_in_pal[i] != (unsigned long)-1L; i++ )
    if ( pixel == colors_in_pal[i] ) break ;

  if ( colors_in_pal[i] != (unsigned long)-1L ) return i ; /* This color is already present in the palette */

  if ( i < (short)inf_out->nb_cpal )
  {
    /* This color is not yet in the list but we still have room for it */
    short* pal_element = (short*)inf_out->palette ;

    pal_element      = &pal_element[3*i] ;
    colors_in_pal[i] = pixel ;
    *pal_element++   = RGB8BToRGBPM[pixel >> 24] ;
    *pal_element++   = RGB8BToRGBPM[(pixel >> 16) & 0xFF] ;
    *pal_element++   = RGB8BToRGBPM[(pixel >> 8) & 0xFF] ;
  }
  else i = -1 ; /* List is full */

  return i ;
}

static int dither_fixedpal(INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  MFDB*           in = &inf_in->mfdb ;
  MFDB*           out = &inf_out->mfdb ;
  unsigned char*  ptc_line = in->fd_addr ;
  unsigned char*  buffer, *pt_buffer ;
  void*           colors_in_pal ;
  size_t          size_line = img_size( in->fd_w, 1, in->fd_nplanes ) ;
  short           nplanes_out = out->fd_nplanes ;
  short           nmaxcolors_out = 1<<nplanes_out ;
  short           index, ln ;
  short           w16 ;
  int             ret = EIMG_SUCCESS ;

  LoggingDo(LL_INFO, "dither_fixedpal %d planes in, %d planes out", in->fd_nplanes, nplanes_out) ;
  if ( (nplanes_out != 4) && (nplanes_out != 8) ) return EIMG_OPTIONNOTSUPPORTED ;
  if ( in->fd_nplanes <= nplanes_out ) return EIMG_OPTIONNOTSUPPORTED ;

  /* Allocate room for image */
  CopyMFDB( out, in ) ;
  out->fd_nplanes = nplanes_out ;
  out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;
  img_raz( out ) ;

  /* Assuming that in contains no more than nmaxcolors_out colors */
  /* Else result will be ugly or error returned                   */
  nmaxcolors_out = 1 << nplanes_out ;
  w16            = align16( out->fd_w ) ;

  /* Allocate room for intermediate index buffer + list of colors already in palette */
  buffer = Xalloc( w16 + 1 + nmaxcolors_out*(in->fd_nplanes >> 3) ) ; /* +1 to indicate the end of current list */
  if ( buffer == NULL )
  {
    Xfree( out->fd_addr ) ;
    out->fd_addr = NULL ;
    return EIMG_NOMEMORY ;
  }
  colors_in_pal = buffer + w16 ;
  memset( colors_in_pal, -1, 1 + nmaxcolors_out*(in->fd_nplanes >> 3) ) ; ;

  /* Allocate room for palette */
  inf_out->palette = Xcalloc( nmaxcolors_out, 3*sizeof(short) ) ;
  if ( inf_out->palette == NULL )
  {
    Xfree( buffer ) ;
    Xfree( out->fd_addr ) ;
    out->fd_addr = NULL ;
    return EIMG_NOMEMORY ;
  }
  inf_out->nb_cpal = nmaxcolors_out ;

  i2r_init( out, w16, 1 ) ;
  i2r_nb   = w16 ;
  i2r_data = buffer ;

  for ( ln = 0; (ret == EIMG_SUCCESS) && (ln < in->fd_h); ln++, ptc_line += size_line )
  {
    if ( in->fd_nplanes == 16 )
    {
      unsigned short* pt_line ;
      unsigned short* pt_pixel ;

      pt_line = (unsigned short*) ptc_line ;
      for ( pt_buffer = buffer, pt_pixel = pt_line ; pt_pixel < pt_line+w16; pt_pixel++, pt_buffer++ )
      {
        index = add_color_in_pal16( *pt_pixel, colors_in_pal, inf_out ) ;
        if ( index < 0 ) { ret = EIMG_DATAINCONSISTENT ; break ; }
        *pt_buffer = (unsigned char) index ;
      }
    }
    else if ( in->fd_nplanes == 32 )
    {
      unsigned long* pt_line ;
      unsigned long* pt_pixel ;

      pt_line = (unsigned long*) ptc_line ;
      for ( pt_buffer = buffer, pt_pixel = pt_line ; pt_pixel < pt_line+w16; pt_pixel++, pt_buffer++ )
      {
        index = add_color_in_pal32( *pt_pixel, colors_in_pal, inf_out ) ;
        if ( index < 0 ) { ret = EIMG_DATAINCONSISTENT ; break ; }
        *pt_buffer = (unsigned char) index ;
      }
    }
    ind2raster() ;
    (void)GWProgRange( wprog, ln, out->fd_h, NULL ) ;
  }

  Xfree( buffer ) ;

  if ( ret != EIMG_SUCCESS )
  {
    Xfree( out->fd_addr ) ; out->fd_addr = NULL ;
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    if ( ret == EIMG_DATAINCONSISTENT )
      LoggingDo(LL_INFO, "dither_fixedpal failed because image has more than %ld colors", inf_out->nb_cpal ) ;
  }

  return ret ;
}

int dither(int method, INFO_IMAGE* inf_in,INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  short nplanes_out = inf_out->mfdb.fd_nplanes ;
  int   ret = -1 ;
  int   force_allocate = 0 ;

  /* inf_out->mfdb.fd_nplanes is the number of colors you want the image to be converted to */
  /* Everything is to be duplicated or initialized according to input image                 */
  memcpy( inf_out, inf_in, sizeof(INFO_IMAGE) ) ;
  inf_out->nplanes         = nplanes_out ;
  inf_out->mfdb.fd_nplanes = nplanes_out ;
  inf_out->mfdb.fd_addr    = NULL ;
  inf_out->palette         = NULL ;
  inf_out->nb_cpal         = 0 ;

  if ( method & 0x80 )
  {
    /* Bit 7 set: we must allocate memory and never make transformation in place, this has */
    /* Been added for LDV which does not know when dither_gris would work in place or not  */
    method &= ~0x80 ;
    force_allocate = 1 ;
  }

  if ( method == DITHER_AUTO )
  {
    switch( nplanes_out )
    {
      case  8 : if ( is_grey( &inf_in->mfdb ) ) method = DITHER_GREY ;
                else                            method = DITHER_216 ;
                break ;

      case  1 : method = DITHER_MATRIXMONO ;
                break ;

      default : method = DITHER_GREY ;
                break ;
    }
  }

  /* Dithering to 256 colors does not make sense if nplanes_out < 8 ) */
  if ( method == DITHER_216 )
  {
    if ( nplanes_out < 8 )
    {
      LoggingDo(LL_INFO, "Dither method is 256colors but planes out is %d, using dither grey", nplanes_out) ;
      method = DITHER_GREY ;
    } 
  }
  LoggingDo(LL_INFO, "DitherMethod=%d, in_planes=%d, out_planes=%d", method, inf_in->mfdb.fd_nplanes, nplanes_out) ;
  switch( method )
  {
    case DITHER_216:        ret = dither_tc_216( inf_in, inf_out, wprog ) ;
                            break ;

    case DITHER_MATRIXMONO: ret = dither_seuil( inf_in, inf_out, wprog ) ;
                             break ;

    case DITHER_GREY:       if ( nplanes_out == 1 ) ret = dither_bichro( inf_in, inf_out, wprog ) ; /* Grey makes no sense for 1 plane */
                            else                    ret = dither_gris( inf_in, inf_out, wprog, force_allocate ) ;
                            break ;

    case DITHER_DUALTONE:   ret = dither_bichro( inf_in, inf_out, wprog ) ;
                            break ;

    case DITHER_FIXEDPAL:   ret = dither_fixedpal( inf_in, inf_out, wprog ) ;
                            break ;
  }

  return ret ;
}
