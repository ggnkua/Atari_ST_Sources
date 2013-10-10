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
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"

#define DITHER_AUTO     0   /* Meilleur choix suivant r‚solution */
#define DITHER_SEUIL    1   /* M‚thode Matrice de seuil          */
#define DITHER_GRIS     2   /* Niveaux de gris                   */
#define DITHER_216      3   /* TC --> 216 couleurs               */


unsigned char pal_intense[256] ;
unsigned char dither_matrix[16][16] ;
unsigned char tc16[3*32] ;
unsigned char white, black ;
char          flag_init = 0 ;

/* Dans DITHER.S */
/* Dans DITHER.S */
void dither_rvb16to8planes(unsigned int *pt_rvb, int w, unsigned char *pt) ;
void dither_rvb24to8planes(unsigned char *pt_rvb, int w, unsigned char *pt) ;
extern unsigned char tab_grey[256*3] ;
extern unsigned char new_ind[256*3] ;

/* Dans DIT216.S : Tramage TC --> 216 couleurs  */
void dither_216c(MFDB *in, unsigned char *indexes) ;


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

  free( inf.palette ) ;
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

void init_dither_matrix(void)
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
  for (i = 0; i < 3*32; i++) tc16[i] = (unsigned char) ((float)i*coe) ;

  vdi2tos  = get_ptvdi2tos(nb_plane) ;
  white     = vdi2tos[0] ;
  black     = vdi2tos[1] ;

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

void init_intensity(MFDB *in, INFO_IMAGE *inf)
{
  float coe, fval ;
  int   current_pal[3*256] ;
  int   *red, *green, *blue ;
  int   i, nbc, val ;

  if (in->fd_nplanes <= 8)
  {
    coe = 256.0/1000.0/3.0 ;
    if (inf->palette != NULL)
    {
      red = (int *) inf->palette ;
      nbc = (int) inf->nb_cpal ;
    }
    else
    {
      get_tospalette(current_pal) ;
      red = current_pal ;
      nbc = nb_colors ;
    }
    green = red+1 ;
    blue  = green+1 ;
    for (i = 0; i < nbc; i++)
    {
      if (*red > 1000)   *red   = 1000 ;
      if (*green > 1000) *green = 1000 ;
      if (*blue > 1000)  *blue  = 1000 ;
      val  = *red+ *green+ *blue ;
      fval = (float)val*coe ;
      pal_intense[i] = (unsigned char) fval ;
      red   += 3 ;
      green += 3 ;
      blue  += 3 ;
    }
  }
}

int dither_seuil(MFDB *in, INFO_IMAGE *inf, MFDB *out, GEM_WINDOW *wprog)
{
  long          taille ;
  unsigned int  *pt_rvb ;
  int           *pt_ligne ;
  int           nplan ;
  int           i, j ;
  int           x, y ;
  int           ind ;
  int           pc ;
  int           nb_px ;
  unsigned char *buffer, *pt ;
  unsigned char *matrix_line ;
  unsigned char r, v, b ;
  unsigned char intensity ;

  nplan = out->fd_nplanes ;
  if (in->fd_nplanes <= nplan) return(-2) ;

  if ( NaturalFormat ) nb_px = NaturalWidth ;
  else                 nb_px = in->fd_w ;
  
  memcpy(out, in, sizeof(MFDB)) ;
  out->fd_nplanes = nplan ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL) return(-1) ;
  img_raz(out) ;

  if ( NaturalFormat )
  {
    buffer = NaturalFormat ;
    i2r_init( out, NaturalWidth, 1 ) ;
  }
  else
  {
    buffer = (unsigned char *) malloc(in->fd_w) ;
    if (buffer == NULL)
    {
      free(out->fd_addr) ;
      return(-1) ;
    }
    i2r_init(out, in->fd_w, 1) ;
  }
  i2r_nb = (long) nb_px ;
  i2r_data = buffer ;

  if (!flag_init) init_dither_matrix() ;

  if (in->fd_nplanes <= 8)
  {
    init_intensity(in, inf) ;
    pt_ligne = (int *) in->fd_addr ;
    taille   = (long)in->fd_wdwidth*(long)in->fd_nplanes ;
    for (y = 0; y < in->fd_h; y++)
    {
      if ( !NaturalFormat )
      {
        raster2ind( pt_ligne, buffer, (long)in->fd_w, in->fd_nplanes ) ;
        pt = buffer ;
      }
      else
        pt = i2r_data ;
      j = y & 0x0F ;
      matrix_line = &dither_matrix[0][0]+(j << 4) ;
      for (x = 0; x < nb_px; x++)
      {
        i   = x & 0x0F ;
        ind = *pt ;
        intensity = pal_intense[ind] ;
        if (intensity == 0) *pt++ = black ;
        else
        {
          if (intensity < matrix_line[i]) *pt++ = black ;
          else                            *pt++ = white ;
        }
      }

      ind2raster() ;
      if ( !NaturalFormat ) pt_ligne += taille ;
      else                  (unsigned char*)i2r_data += NaturalWidth ;

      if ( MAY_UPDATE( wprog, y ) )
      {
        pc = (int) ((100L*(long)y)/(long)in->fd_h) ;
        wprog->ProgPc( wprog, pc, NULL ) ;
      }
    }
  }
  else if (in->fd_nplanes == 16)
  {
    pt_rvb = (unsigned int *) in->fd_addr ;
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
        i = x & 0x0F ;
        if (intensity == 0) *pt++ = black ;
        else
        {
          if (intensity < matrix_line[i]) *pt++ = black ;
          else                            *pt++ = white ;
        }
        pt_rvb++ ;
      }
      ind2raster() ;
      pt_rvb += taille ;
      if ( MAY_UPDATE( wprog, y ) )
      {
        pc = (int) ((100L*(long)y)/(long)in->fd_h) ;
        wprog->ProgPc( wprog, pc, NULL ) ;
      }
    }
  }
  else if (in->fd_nplanes == 24)
  {
    unsigned char *pt_rvb24 ;
    unsigned int r, v, b ;

    pt_rvb24 = (unsigned char *) in->fd_addr ;
    taille = 3L*(long)( (in->fd_wdwidth << 4) - in->fd_w ) ;
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
        intensity = (r+v+b) >> 3 ;
        intensity = tc16[intensity] ;
        i = x & 0x0F ;
        if (intensity == 0) *pt++ = black ;
        else
        {
          if (intensity < matrix_line[i]) *pt++ = black ;
          else                            *pt++ = white ;
        }
      }
      ind2raster() ;
      pt_rvb += taille ;
      if ( MAY_UPDATE( wprog, y ) )
      {
        pc = (int) ((100L*(long)y)/(long)in->fd_h) ;
        wprog->ProgPc( wprog, pc, NULL ) ;
      }
    }
  }

  if ( !NaturalFormat ) free(buffer) ;

  return(0) ;
}

int dither_gris(MFDB *in, INFO_IMAGE *inf, MFDB *out, GEM_WINDOW *wprog)
{
  INFO_IMAGE    new_pal ;
  long          taille ;
  unsigned int  *pt_rvb ;
  int           *pt_pal ;
  int           *pt_ligne ;
  int           nplan ;
  int           x, y, vx ;
  int           ind, min ;
  int           pc ;
  int           nb_px ;
  unsigned char *buffer, *pt ;

  if (!flag_init) init_dither_matrix() ;

  if ( NaturalFormat ) nb_px = NaturalWidth ;
  else                 nb_px = in->fd_w ;
  
  nplan = out->fd_nplanes ;
  if (in->fd_nplanes <= nplan) return(-2) ;

  memcpy(out, in, sizeof(MFDB)) ;
  out->fd_nplanes = nplan ;
  out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL) return(-1) ;
  if ( nb_px & 0x0F ) img_raz( out ) ;

  if ( NaturalFormat )
  {
    buffer = NaturalFormat ;
    i2r_init(out, NaturalWidth, 1) ;
  }
  else
  {
    buffer = (unsigned char *) malloc(in->fd_w) ;
    if (buffer == NULL)
    {
      free(out->fd_addr) ;
      return(-1) ;
    }
    i2r_init(out, in->fd_w, 1) ;
  }
  i2r_nb = (long) nb_px ;
  i2r_data = buffer ;

  memcpy(&new_pal, inf, sizeof(INFO_IMAGE)) ;
  if ( set_greylevel( out->fd_nplanes, &new_pal ) < 0 )
  {
    if ( !NaturalFormat ) free(buffer) ;
    free(out->fd_addr) ;
    return(-1) ;
  }  

  if (in->fd_nplanes <= 8)
  {
    init_intensity(in, inf) ;
    for (x = 0; x < 256; x++)
    {
      pt_pal = new_pal.palette ;
      min    = 1000 ;
      vx     = (int) ((float)x*1000.0/256.0) ;
      for (y = 0; y < new_pal.nb_cpal; y++)
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
    for (x = 0; x < 256; x++) new_ind[x] = tab_grey[pal_intense[x]] ;

    pt_ligne = (int *) in->fd_addr ;
    taille   = (long)in->fd_wdwidth*(long)in->fd_nplanes ;
    for (y = 0; y < in->fd_h; y++)
    {
      if ( !NaturalFormat )
      {
        raster2ind( pt_ligne, buffer, (long)in->fd_w, in->fd_nplanes ) ;
        pt = buffer ;
      }
      else
        pt = i2r_data ;

      for (x = 0; x < nb_px; x++) *pt++ = new_ind[*pt] ;

      ind2raster() ;
      if ( !NaturalFormat ) pt_ligne += taille ;
      else                  (unsigned char*)i2r_data += NaturalWidth ;

      if ( MAY_UPDATE( wprog, y ) )
      {
        pc = (int) ((100L*(long)y)/(long)in->fd_h) ;
        wprog->ProgPc( wprog, pc, NULL ) ;
      }
    }
  }
  else if (in->fd_nplanes == 16)
  {
    if ( out->fd_nplanes == 8 ) memcpy( tab_grey, tg_16bto8b, 32*3 ) ;
    else                        memcpy( tab_grey, tg_16bto4b, 32*3 ) ;
    pt_rvb = (unsigned int *) in->fd_addr ;
    taille = 16*in->fd_wdwidth ;
    for (y = 0; y < in->fd_h; y++)
    {
      dither_rvb16to8planes( pt_rvb, in->fd_w, buffer ) ;
      ind2raster() ;
      pt_rvb += taille ;
      if ( MAY_UPDATE( wprog, y ) )
      {
        pc = (int) ((100L*(long)y)/(long)in->fd_h) ;
        wprog->ProgPc( wprog, pc, NULL ) ;
      }
    }
  }
  else if (in->fd_nplanes == 24)
  {
    unsigned char *ptc_rvb ;

    if ( out->fd_nplanes == 8 ) memcpy( new_ind, ni_24bto8b, 256*3 ) ;
    else                        memcpy( new_ind, ni_24bto4b, 256*3 ) ;
    ptc_rvb = (unsigned char *) in->fd_addr ;
    taille = 3L*(long)(in->fd_wdwidth << 4) ;
    for ( y = 0; y < in->fd_h; y++ )
    {
      dither_rvb24to8planes( ptc_rvb, in->fd_w, buffer ) ;
      ind2raster() ;
      ptc_rvb += taille ;
      if ( MAY_UPDATE( wprog, y ) )
      {
        pc = (int) ((100L*(long)y)/(long)in->fd_h) ;
        wprog->ProgPc( wprog, pc, NULL ) ;
      }
    }
  }

  if (inf->palette != NULL) free(inf->palette) ;
  memcpy(inf, &new_pal, sizeof(INFO_IMAGE)) ;
  if ( !NaturalFormat ) free(buffer) ;

  return(0) ;
}

void dither_line(unsigned char *buffer, int nb, unsigned char *intensity, int mline)
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

void dither_tc16line(int *buffer, unsigned char *out, int nb, unsigned char *tc16lum, int mline)
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
void ind_strech(unsigned char *in, unsigned char *out, int nb_out, int *table)
{
  int           x ;
  unsigned char *pt_out ;

  pt_out = out ;
  for (x = 0; x < nb_out; x++) *pt_out++ = in[table[x]] ;
}

void tc16_strech(int *pt_raster, int *out, int nb_out, int *table)
{
  int x ;
  int *pt_out ;

  pt_out = out ;
  for (x = 0; x < nb_out; x++) *pt_out++ = pt_raster[table[x]] ;
}

int dither_ratio(MFDB *in, INFO_IMAGE *inf, MFDB *out, int pc_x, int pc_y,
                 GEM_WINDOW *wprog)
{
  int           *pt_raster ;
  int           *strech_table ;
  int           nplan, pc ;
  int           lin, ligne ;
  int           *ibuffer_out ;
  unsigned char *buffer_in, *buffer_out ;
  
  nplan = out->fd_nplanes ;
  if (in->fd_nplanes <= nplan) return(-2) ;

  buffer_in = (unsigned char *) malloc(16*in->fd_wdwidth) ;
  if (buffer_in == NULL) return(-1) ;

  memcpy(out, in, sizeof(MFDB)) ;
  out->fd_nplanes = nplan ;
  out->fd_w       = (int) (((long)in->fd_w*(long)pc_x)/100L) ;
  out->fd_h       = (int) (((long)in->fd_h*(long)pc_y)/100L) ;
  out->fd_wdwidth = out->fd_w/16 ;
  if (out->fd_w % 16) out->fd_wdwidth++ ;
  buffer_out = (unsigned char *) malloc(16*out->fd_wdwidth) ;
  if (buffer_out == NULL)
  {
    free(buffer_in) ;
    return(-1) ;
  }
  if (in->fd_nplanes > 8)
  {
    ibuffer_out = (int *) malloc(32*out->fd_wdwidth) ;
    if (ibuffer_out == NULL)
    {
      free(buffer_out) ;
      free(buffer_in) ;
      return(-1) ;
    }
  }
  strech_table = (int *) malloc(32*out->fd_wdwidth) ;
  if (strech_table == NULL)
  {
    if (in->fd_nplanes > 8) free(ibuffer_out) ;
    free(buffer_out) ;
    free(buffer_in) ;
    return(-1) ;
  }

  out->fd_addr = img_alloc(out->fd_w, out->fd_h, nplan) ;
  if (out->fd_addr == NULL)
  {
    free(strech_table) ;
    if (in->fd_nplanes > 8) free(ibuffer_out) ;
    free(buffer_out) ;
    free(buffer_in) ;
    return(-1) ;
  }
  img_raz(out) ;

  for (lin = 0; lin < out->fd_w; lin++) strech_table[lin] = (int) (((long)lin*100L)/(long)pc_x) ;
  i2r_init(out, out->fd_w, 1) ;
  i2r_data = buffer_out ;
  i2r_nb   = out->fd_w ;
  if (!flag_init) init_dither_matrix() ;
  init_intensity(in, inf) ;
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
    if ( MAY_UPDATE( wprog, ligne ) )
    {
      pc = (int) ((100L*(long)ligne)/(long)out->fd_h) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
  }

  free(strech_table) ;
  free(buffer_out) ;
  if (in->fd_nplanes > 8) free(ibuffer_out) ;
  free(buffer_in) ;

  return(0) ;
}

int init_dt216_pal(INFO_IMAGE *inf)
{
  int           r, v, b ;
  int           *pt_pal ;
  int           val1000[6] = { 0, 200, 400, 600, 800, 1000 } ;
  unsigned char *pt_vdi2tos ;

  inf->nb_cpal = 256 ;
  inf->palette = calloc( inf->nb_cpal, 3*2 ) ;
  if ( inf->palette == NULL ) return( -1 ) ;

  pt_pal  = (int *) inf->palette ;
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

  return( 0 ) ;
}

int dither_tc_216(MFDB *in, INFO_IMAGE *inf, MFDB *out, GEM_WINDOW *wprog)
{
  MFDB          img ;
  int           packet_lines = 32 ; /* Obligatoire pour dither_216c */
  long          packet_size ;
  int           l, ret = 0 ;
  int           pc ;
  unsigned char *tmp_addr ;
  unsigned char *indexes ;

  memcpy( out, in, sizeof(MFDB) ) ;
  out->fd_nplanes = 8 ;
  out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return( -1 ) ;

  packet_size = (long) out->fd_w * (long)packet_lines ;
  indexes = (unsigned char *) malloc( packet_size ) ;
  if ( indexes == NULL )
  {
    free( out->fd_addr ) ;
    return( -1 ) ;
  }
  i2r_init( out, out->fd_w, 0 ) ;
  i2r_data = indexes ;
  i2r_nb   = packet_size ;

  if ( init_dt216_pal( inf ) )
  {
    free( indexes ) ;
    free( out->fd_addr ) ;
    return( -1 ) ;
  }

  memcpy( &img, in, sizeof(MFDB) ) ;
  tmp_addr    = img.fd_addr ;
  img.fd_h    = packet_lines ;
  packet_size = img_size( img.fd_w, img.fd_h, img.fd_nplanes ) ;
  for ( l = 0; l <= in->fd_h-packet_lines ; l += packet_lines )
  {
    dither_216c( &img, indexes ) ;
    ind2raster() ;
    tmp_addr   += packet_size ;
    img.fd_addr = tmp_addr ;
    if ( wprog )
    {
      pc = (int) ((100L*(long)l)/(long)out->fd_h) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
  }
  img.fd_h = in->fd_h % packet_lines ;
  if ( img.fd_h )
  {
    /* Il reste moins de packet_lines lignes … convertir */
    i2r_nb   = (long) out->fd_w * (long)img.fd_h ;
    dither_216c( &img, indexes ) ;
    ind2raster() ;
  }

  free( indexes ) ;
  
  return( ret ) ;
}

int is_grey(MFDB *in)
{
  int  is_grey = 1 ;
  int  step ;
  long offset ;
  long inc_x, inc_y ;
  unsigned int r, v, b ;
  unsigned int *pt16 ;
  unsigned char *pt24 ;

  /* On teste 16 pixels sur la diagonale descendante */
  inc_x  = in->fd_w >> 4 ;
  inc_y  = in->fd_h >> 4 ;
  switch( in->fd_nplanes )
  {
    case 16 : 
              offset  = inc_y * (long)in->fd_w ;
              offset += inc_x ;
              pt16 = (unsigned int *) in->fd_addr ;
              for ( step = 0 ; is_grey && ( step < 16); step++, pt16 += offset )
              {
                r = *pt16 >> 11 ;
                v = ( *pt16 >> 6 ) & 0x1F ;
                b = *pt16 & 0x1F ;
                if ( ( r != v ) || ( r != b ) || ( v != b ) ) is_grey = 0 ;
              }
              break ;

    case 24 : offset  = inc_y * (long)in->fd_w * 3L ;
              offset += inc_x * 3L ;
              pt24 = (unsigned char *) in->fd_addr ;
              for ( step = 0 ; is_grey && ( step < 16); step++, pt24 += offset )
              {
                r = *pt24 ;
                v = *( 1 + pt24 ) ;
                b = *( 2 + pt24 ) ;
                if ( ( r != v ) || ( r != b ) || ( v != b ) ) is_grey = 0 ;
              }
              break ;

    default : is_grey = 0 ;
              break ;
  }

  return( is_grey ) ;
}

int dither(int method, MFDB *in, INFO_IMAGE *inf, MFDB *out, GEM_WINDOW *wprog)
{
  int ret = -1 ;

  if (method == DITHER_AUTO)
  {
    switch( out->fd_nplanes )
    {
      case  8 : if ( is_grey( in ) ) method = DITHER_GRIS ;
                else                 method = DITHER_216 ;
                break ;

      case  1 : method = DITHER_SEUIL ;
                break ;

      default : method = DITHER_GRIS ;
                break ;
    }
  }

  switch( method )
  {
    case DITHER_216   : ret = dither_tc_216( in, inf, out, wprog ) ;
                        break ;

    case DITHER_SEUIL : ret = dither_seuil( in, inf, out, wprog ) ;
                        break ;

    case DITHER_GRIS  : ret = dither_gris( in, inf, out, wprog ) ;
                        break ;
 }

  return(ret) ;
}
