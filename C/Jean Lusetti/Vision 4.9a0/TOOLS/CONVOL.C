/*************************/
/* Module de convolution */
/*************************/
#include   <math.h>
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>

#include  "stdprog.h"
#include     "xgem.h"
#include     "xfile.h"
#include "rasterop.h"
#include "image_io.h"


#define CONVOL_BADFILTERFILE -1
#define CONVOL_BADNBCOLORS   -2
#define CONVOL_MEMORY        -3
#define CONVOL_BADDSPFILE    -4
#define CONVOL_DSPERROR      -5
#define CONVOL_DSPBUSY       -6
#define CONVOL_LODNOTEXIST   -7


#define GET_PARAMETERS        0
#define EXECUTE_FILTER        1


typedef struct
{
  unsigned char w ;      /* Nombre de colonnes                  */
  unsigned char h ;      /* Nombre de lignes                    */
  char name[30] ;        /* Nom normalis‚                       */
  char description[30] ; /* BrŠve description                   */
  char rfu[20] ;         /* Future extension                    */
  char *data ;           /* Pointeur sur le tableau de donn‚ees */
}
CONVOLUTION_FILTRE ;


typedef struct
{
  unsigned char what_to_do ;
  unsigned char nplanes ;
  unsigned char filter_w ;
  unsigned char filter_h ;
  unsigned char filter_nbpts ;
}
CONVOLUTION_DSPDATA ;

typedef struct
{
  char ConvolDspCode[1000] ; /* Code binaire DSP    */
  long ConvolDspCodeSize ;   /* Taille de ce code   */
  int  ConvolDspAbility  ;   /* Ability du code DSP */
}
CONVOLUTION_DSP_CODE ;

CONVOLUTION_FILTRE  compute_filter ;        /* Filtre en cours d'application       */
int                 shift ;                 /* Pour le calcul                      */
int                 norme     ;             /* Norme du filtre                     */
int                 *int_buffer ;           /* M‚moire tampon pour mode 16 bits    */
unsigned char       *buffer ;               /* Tampon circulaire en entr‚e 8 plans */
unsigned char       *data_out ;             /* Buffer de sortie 8 plans            */

static int  ConvolDspAbility = -1 ; /* Ability du code DSP                 */


int convolution_loadfilter(char *filtername, CONVOLUTION_FILTRE *filter)
{
  FILE   *stream ;
  size_t check ;

  stream = fopen(filtername, "rb") ;
  if (stream == NULL) return CONVOL_BADFILTERFILE ;

  check = fread(filter, sizeof(CONVOLUTION_FILTRE), 1, stream) ;
  if (check != 1)
  {
    fclose(stream) ;
    return CONVOL_BADFILTERFILE ;
  }

  filter->data = (char *) Xalloc(filter->w*filter->h) ;
  if (filter->data == NULL)
  {
    fclose(stream) ;
    return CONVOL_MEMORY ;
  }

  check = fread(filter->data, sizeof(char), filter->w*filter->h, stream) ;
  fclose(stream) ;
  if (check != filter->w*filter->h) return CONVOL_BADFILTERFILE ;

  return 0 ;
}

int convolution_savefilter(char *filtername, CONVOLUTION_FILTRE *filter)
{
  FILE *stream ;

  stream = CreateFileR( filtername ) ;
  if (stream == NULL) return -1 ;

  fwrite(filter, sizeof(CONVOLUTION_FILTRE), 1, stream) ;
  fwrite(filter->data, 1, filter->w*filter->h, stream) ;
  if (fclose(stream)) return -1 ;

  return 0 ;
}

void filter_init(CONVOLUTION_FILTRE *filter)
{
  double x ;
  int    i ;
  char   *pt ;

  memcpy(&compute_filter, filter, sizeof(CONVOLUTION_FILTRE)) ;
  pt    = filter->data ;
  norme = 0 ;
  for (i = 0; i < filter->w*filter->h; i++) norme += *pt++ ;
  if (norme <= 0) shift = 0 ;
  else
  {
    x     = log((double)norme)/log(2.0) ;
    shift = (int) (0.5+x) ;
  }
}

void graylevel_init(INFO_IMAGE *info, unsigned char *tgray2index, unsigned char *tindex2gray)
{
  int           *pal ;
  int           i, j, min, ind, val ;
  unsigned char *pt, *vdi2tos ;

  pal     = (int *) info->palette ;
  vdi2tos = get_ptvdi2tos(info->nplanes) ;
  for (i = 0; i < 256; i++)
  {
    tindex2gray[vdi2tos[i]] = (unsigned char) (*pal >> 2) ;
    pal += 3 ;
  }

  for (i = 0; i < 256; i++)
  {
    min = 1000 ;
    pt  = &tindex2gray[16] ;
    for (j = 16; j < 255; j++)
    {
      val = abs(*pt-i) ;
      if (val < min)
      {
        min = val ;
        ind = j ;
      }
      pt++ ;
    }
    tgray2index[i] = ind ;
  }
}

void convolution_cpudo16(int w, int no_line, int *in_data, unsigned int *start_outline, long larg)
{
  int          j, m, n, idx, jdx ;
  unsigned int *out_line ;
  unsigned int col, val ;
  unsigned int r, g, b, rgb ;
  int          *pt_in ;
  int          red, green, blue, ms ;
  char         *filter_point ;

  out_line = start_outline ;
  for (j = 0; j < w; j++)
  {
    red = green = blue = 0 ;
    filter_point = compute_filter.data ;
    pt_in        = in_data ;
    for (m = 0; m < compute_filter.h; m++)
    {
      idx = no_line-m ;
      if (idx >= 0)
      {
        for (n = 0; n < compute_filter.w; n++)
        {
          ms  = *filter_point++ ;
          jdx = j-n ;
          if (jdx < 0) jdx = 0 ;
          rgb    = *(pt_in+jdx) ;
          r      = rgb >> 11 ;
          g      = (rgb >> 6) & 0x1F ;
          b      = rgb & 0x1F ;
          red   += ms*r ;
          green += ms*g ;
          blue  += ms*b ;
        }
      }
      pt_in -= larg ;
    }
    if (shift)
    {
      red >>= shift ;
      green >>= shift ;
      blue >>= shift ;
    }
    if (red > 31) red = 31 ;
    if (red < 0) red = 0 ;
    if (green > 31) green = 31 ;
    if (green < 0) green = 0 ;
    if (blue > 31) blue = 31 ;
    if (blue < 0) blue = 0 ;
    col  = (unsigned int) red ;
    val  = (col << 11) & 0xF800 ;
    col  = (unsigned int) green ;
    val |= ((col << 6) & 0x07C0) ;
    col  = (unsigned int) blue ;
    val |= col ;
    *out_line++ = val ;
  }
}

void convolution_cpudo32(int w, int no_line, unsigned long *in_data, unsigned long *start_outline, long larg)
{
  RGB           srgb ;
  unsigned long rgb ;
  int           j, m, n, idx, jdx ;
  unsigned long  *out_line ;
  unsigned int  r, g, b ;
  unsigned long *pt_in ;
  int           red, green, blue, ms ;
  char          *filter_point ;

  out_line = start_outline ;
  for (j = 0; j < w; j++)
  {
    red = green = blue = 0 ;
    filter_point = compute_filter.data ;
    pt_in        = in_data ;
    for (m = 0; m < compute_filter.h; m++)
    {
      idx = no_line-m ;
      if (idx >= 0)
      {
        for (n = 0; n < compute_filter.w; n++)
        {
          ms  = *filter_point++ ;
          jdx = j-n ;
          if (jdx < 0) jdx = 0 ;
          rgb    = *(pt_in+jdx) ;
          r      = (int) (rgb >> 24) ;
          g      = (int) ((rgb >> 16) & 0xFF) ;
          b      = (int) ((rgb >> 8 ) & 0xFF) ;
          red   += ms*r ;
          green += ms*g ;
          blue  += ms*b ;
        }
      }
      pt_in -= larg ;
    }
    if (shift)
    {
      red >>= shift ;
      green >>= shift ;
      blue >>= shift ;
    }
    if (red > 255) red = 255 ;
    if (red < 0) red = 0 ;
    if (green > 255) green = 255 ;
    if (green < 0) green = 0 ;
    if (blue > 255) blue = 255 ;
    if (blue < 0) blue = 0 ;
    srgb.Red   = red ;
    srgb.Green = green ;
    srgb.Blue  = blue ;
    *out_line++ = RVB32( &srgb ) ;
  }
}

void convolution_cpudogray(int w, int no_line, unsigned char *in_data, unsigned char *start_outline)
{
  int           lline ;
  int           j, m, n, jdx ;
  unsigned char *out_line ;
  int           g, gray, ms ;
  unsigned char *pt_in ;
  char          *filter_point ;

  lline     = no_line % compute_filter.h ;
  out_line = start_outline ;
  for (j = 0; j < w; j++)
  {
    gray         = 0 ;
    filter_point = compute_filter.data ;
    pt_in        = in_data ;
    for (m = 0; m < compute_filter.h; m++)
    {
      for (n = 0; n < compute_filter.w; n++)
      {
        ms  = *filter_point++ ;
        jdx = j-n ;
        if (jdx < 0) jdx = 0 ;
        g     = *(pt_in+jdx) ;
        gray += ms*g ;
      }
      lline-- ;
      pt_in -= w ;
      if (lline < 0)
      {
        lline  = compute_filter.h-1 ;
        pt_in = buffer+(long)lline*(long)w ;
      }
    }
    if (shift) gray >>= shift ;
    if (gray > 255) gray = 255 ;
    if (gray < 0)   gray = 0 ;
    *out_line++ = (unsigned char) gray ;
  }
}

void graylevel2index(unsigned char *buf, int nb, unsigned char *tgray2index)
{
  int           i ;
  unsigned char *pt ;

  pt = buf ;
  for (i = 0; i < nb; i++)
  {
    *pt = tgray2index[*pt] ;
    pt++ ;
  }
}

void index2graylevel(unsigned char *buf, int nb, unsigned char *tindex2gray)
{
  int           i ;
  unsigned char *pt ;

  pt = buf ;
  for (i = 0; i < nb; i++)
  {
    *pt = tindex2gray[*pt] ;
    pt++ ;
  }
}

int convolution_cpu(MFDB *in, INFO_IMAGE *info, MFDB *out, CONVOLUTION_FILTRE *filter, unsigned char *tgray2index, unsigned char *tindex2gray, GEM_WINDOW* wprog)
{
  long          larg ;
  unsigned int  *start_outline ;
  int           *in_data ;
  int           i, no_buffer ;
  int           nbpts, n ;
  unsigned char *index_in ;

  if (in->fd_nplanes < 8) return CONVOL_BADNBCOLORS ;

  filter_init(filter) ;

  nbpts = in->fd_w ;
  n     = 1+compute_filter.h>> 1 ;
  if (in->fd_nplanes == 8)
  {
    if (!grey_level(info)) return CONVOL_BADNBCOLORS ;

    in_data   = (int *) in->fd_addr ;
    larg      = in->fd_wdwidth << 3 ;
    i2r_init(out, out->fd_w, 1) ;
    i2r_data  = data_out+(compute_filter.w>> 1) ;
    i2r_nb    = out->fd_w ;
    no_buffer = 0 ;
    index_in  = buffer ;
    for (i = 0; i < in->fd_h+compute_filter.h; i++)
    {
      if (i < in->fd_h)
      {
        raster2ind(in_data, index_in, (long)in->fd_w, in->fd_nplanes) ;
        index2graylevel( index_in, in->fd_w, tindex2gray ) ;
      }
      convolution_cpudogray(nbpts, i, index_in, data_out) ;
      if ((i >= filter->h-n) && (i < in->fd_h+filter->h-n))
      {
        graylevel2index( data_out, in->fd_w, tgray2index ) ;
        ind2raster() ;
      }
      in_data += larg ;
      no_buffer++ ;
      index_in += in->fd_w ;
      if (no_buffer == filter->h)
      {
        no_buffer = 0 ;
        index_in  = buffer ;
      }
      (void)GWProgRange( wprog, i,  in->fd_h, NULL ) ;
    }
  }
  else if (in->fd_nplanes == 16)
  {
    unsigned int *last_line ;

    in_data  = (int *) in->fd_addr ;
    larg     = in->fd_wdwidth << 4 ;
    start_outline = (unsigned int *) out->fd_addr ;
    last_line     = start_outline+larg*(long)(in->fd_h-1) ;
    for (i = 0; i < in->fd_h+compute_filter.h; i++)
    {
      convolution_cpudo16(in->fd_w, i, in_data+(compute_filter.w >> 1), start_outline, larg) ;
      if (i >= filter->h-n) start_outline += larg ;
      if (start_outline > last_line) break ;
      if (i < in->fd_h) in_data += larg ;
      (void)GWProgRange( wprog, i, in->fd_h, NULL ) ;
    }
  }
  else if (in->fd_nplanes == 32)
  {
    unsigned long *last_line ;
    unsigned long *indata ;
    unsigned long *startoutline ;

    indata       = (unsigned long *) in->fd_addr ;
    larg         = in->fd_wdwidth << 4 ;
    startoutline = (unsigned long *) out->fd_addr ;
    last_line    = startoutline+larg*(long)(in->fd_h-1) ;
    for (i = 0; i < in->fd_h+compute_filter.h; i++)
    {
      convolution_cpudo32(in->fd_w, i, indata+(compute_filter.w >> 1), startoutline, larg) ;
      if (i >= filter->h-n) startoutline += larg ;
      if (startoutline > last_line) break ;
      if (i < in->fd_h) indata += larg ;
      (void)GWProgRange( wprog, i, in->fd_h, NULL ) ;
    }
  }

  return 0 ;
}

void dspdata_init(MFDB *in)
{
  CONVOLUTION_DSPDATA dsp_data ;
  long                scale ;
  int                 data[2] ;
  int                 i ;
  int                 filtre[256] ;
  int                 *pt2 ;
  char                *pt1 ;

  dsp_data.what_to_do   = GET_PARAMETERS ;
  dsp_data.nplanes      = in->fd_nplanes ;
  dsp_data.filter_w     = compute_filter.w ;
  dsp_data.filter_h     = compute_filter.h ;
  dsp_data.filter_nbpts = compute_filter.w*compute_filter.h ;

  pt1 = compute_filter.data ;
  pt2 = filtre ;
  for (i = 0; i < dsp_data.filter_nbpts; i++) *pt2++ = *pt1++ ;

  Dsp_BlkBytes(&dsp_data, 5, NULL, 0L) ;
  if (norme < 2) scale = 0L ; /* Evite un d‚passement de capacit‚ DSP */
  else           scale = (long) ((float)0x800000L/(float)norme) ;
  /* Valeur du mutiplicateur shift */
  Dsp_BlkUnpacked(&scale, 1, NULL, 0L) ;
  /* Il ne manque plus que la largeur d'une ligne */
  data[0] = in->fd_w+compute_filter.w ;
  /* Et le nombre de points attendus en retour */
  data[1] = in->fd_w ;
  Dsp_BlkWords(data, 2, NULL, 0L) ;

  /* Envoi le filtre lui mˆme */
  Dsp_BlkWords(filtre, dsp_data.filter_nbpts, NULL, 0L) ;
}

int convolution_dsp(MFDB *in, INFO_IMAGE *info, MFDB *out, CONVOLUTION_FILTRE *filter, CONVOLUTION_DSP_CODE *cdc, unsigned char *tgray2index, unsigned char *tindex2gray, GEM_WINDOW* wprog)
{
  long          nbpts ;
  long          larg ;
  unsigned int  *start_outline ;
  int           *in_data ;
  int           com ;
  int           i, pc ;
  int           lock_done = 0 ;
  unsigned char *ptc, valc ;

  if ( in->fd_nplanes < 8) return CONVOL_BADNBCOLORS ;

  if ( ( DspInfo.WhatToDoIfLocked != DSPLOCK_FORCE ) && Dsp_Lock() ) return CONVOL_DSPBUSY ;
  else                                                               lock_done = 1 ;

  Dsp_ExecProg( cdc->ConvolDspCode, cdc->ConvolDspCodeSize, cdc->ConvolDspAbility ) ;
  filter_init( filter ) ;
  dspdata_init( in ) ;

  StdProgDisplayDSP( wprog, 1 ) ;

  nbpts = (long)( in->fd_w+compute_filter.w ) ;
  if ( in->fd_nplanes == 8 )
  {
    if ( !grey_level( info ) )
    {
      if ( lock_done ) Dsp_Unlock() ;
      return( CONVOL_BADNBCOLORS ) ;
    }
    in_data  = (int *) in->fd_addr ;
    larg     = in->fd_wdwidth << 3 ;
    i2r_init(out, out->fd_w, 1) ;
    i2r_data = data_out ;
    i2r_nb   = out->fd_w ;
    com      = EXECUTE_FILTER ;

    for ( i = 0; i < in->fd_h+compute_filter.h; i++ )
    {
      if ( i < in->fd_h )
      {
        raster2ind( in_data, buffer+(compute_filter.w>> 1), (long)in->fd_w, in->fd_nplanes ) ;
        valc = buffer[in->fd_w-1] ;
        ptc  = buffer+(long)in->fd_w ;
        for ( pc = 0; pc < compute_filter.w>> 1; pc++ ) *ptc++ = valc ;
        index2graylevel( buffer+(compute_filter.w>> 1), in->fd_w, tindex2gray ) ;
      }
      Dsp_BlkWords( &com, 1, NULL, 0L ) ;
      Dsp_BlkBytes( buffer, nbpts, NULL, 0L ) ;
      if ( ( i >= compute_filter.h ) && ( i < in->fd_h+compute_filter.h ) )
      {
        graylevel2index( data_out, in->fd_w, tgray2index ) ;
        ind2raster() ;
      }
      Dsp_BlkBytes( NULL, 0L, data_out, in->fd_w ) ;
      in_data += larg ;
      (void)GWProgRange( wprog, i, in->fd_h, NULL ) ;
    }
  }
  else if ( in->fd_nplanes == 16 )
  {
    unsigned int *last_line ;
    int          *buf ;

    in_data = (int *) in->fd_addr ;
    larg    = in->fd_wdwidth << 4 ;
    start_outline = (unsigned int *) out->fd_addr ;
    last_line     = start_outline+(long)(in->fd_h-1)*larg ;
    buf           = int_buffer+(compute_filter.w >> 1) ;
    com           = EXECUTE_FILTER ;
    for ( i = 0; i < in->fd_h+compute_filter.h; i++ )
    {
      memcpy( buf, in_data, in->fd_w << 1 ) ;
      Dsp_BlkWords( &com, 1, NULL, 0L ) ;
      Dsp_BlkWords( int_buffer, nbpts, start_outline, in->fd_w ) ;
      in_data += larg ;
      if ( i >= compute_filter.h-1 ) start_outline += larg ;
      if ( start_outline > last_line ) break ;
      (void)GWProgRange( wprog, i, in->fd_h, NULL ) ;
    }
  }

  if ( lock_done ) Dsp_Unlock() ;

  return 0 ;
}

int convolution(MFDB *in, INFO_IMAGE *info, MFDB *out, char *DSPfile, CONVOLUTION_FILTRE *filter, GEM_WINDOW* wprog)
{
  CONVOLUTION_DSP_CODE cdc ;
  MFDB                 std_img ;
  int                  err ;
  unsigned char        tgray2index[256] ; /* Conversion niveaux de gris -> index */
  unsigned char        tindex2gray[256] ; /* Conversion index -> niveaux de gris */

  if ( in->fd_nplanes < 8 ) return CONVOL_BADNBCOLORS ;

  memzero( &cdc, sizeof(CONVOLUTION_DSP_CODE) ) ;
  CopyMFDB( out, in ) ;
  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return CONVOL_MEMORY ;

  if ( DSPfile[0] && DspInfo.use )
  {
    if ( ConvolDspAbility != Dsp_GetProgAbility() )
    {
      if ( !FileExist( DSPfile ) ) return CONVOL_LODNOTEXIST ;
      ConvolDspAbility      = Dsp_RequestUniqueAbility() ;
      cdc.ConvolDspCodeSize = Dsp_LodToBinary( DSPfile, cdc.ConvolDspCode ) ;
      if ( cdc.ConvolDspCodeSize <= 0 ) return CONVOL_BADDSPFILE ;
    }
    cdc.ConvolDspAbility = ConvolDspAbility ;
  }

  if ( in->fd_nplanes == 8 )
  {
    buffer = (unsigned char*) Xalloc( (in->fd_w+filter->w)*filter->h ) ;
    if ( buffer == NULL )
    {
      Xfree( out->fd_addr ) ;
      return CONVOL_MEMORY ;
    }
    data_out = (unsigned char*) Xalloc( in->fd_w+filter->w ) ;
    if ( data_out == NULL )
    {
      Xfree( buffer ) ;
      Xfree( out->fd_addr ) ;
      return CONVOL_MEMORY ;
    }
    img_raz( out ) ;
    graylevel_init( info, tgray2index, tindex2gray ) ;
  }
  else buffer = data_out = NULL ;

  if ( in->fd_nplanes >= 16 )
  {
    int_buffer = (int*) Xalloc( (in->fd_w+filter->w)*4L ) ;
    if ( int_buffer == NULL )
    {
      Xfree( out->fd_addr ) ;
      return CONVOL_MEMORY ;
    }
  }
  else int_buffer = NULL ;

  if ( UseStdVDI )
  {
    if ( in->fd_nplanes >= 16 ) tc_invconvert( in ) ;
    else
    {
      CopyMFDB( &std_img, in ) ;
      std_img.fd_addr = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
      if ( std_img.fd_addr == NULL )
      {
        Xfree( buffer) ;
        Xfree( out->fd_addr ) ;
        Xfree( data_out ) ;
        return CONVOL_MEMORY ;
      }
      std_img.fd_stand = 1 ;
      vr_trnfm( handle, in, &std_img ) ;
      StdVDI2ClassicAtari( &std_img, in ) ;
    }
  }

  if ( (DSPfile[0] == 0) || !DspInfo.use )
    err = convolution_cpu( in, info, out, filter, tgray2index, tindex2gray, wprog ) ;
  else
  {
    err = convolution_dsp( in, info, out, filter, &cdc, tgray2index, tindex2gray, wprog ) ;
    if ( (err == CONVOL_DSPBUSY) && (DspInfo.WhatToDoIfLocked == DSPLOCK_IGNORE) )
      err = convolution_cpu( in, info, out, filter, tgray2index, tindex2gray, wprog ) ;
  }

  if ( UseStdVDI )
  {
    if ( in->fd_nplanes >= 16 )
    {
      tc_convert( in ) ;
      if ( !err ) tc_convert( out ) ;
    }
    else
    {
      vr_trnfm( handle, &std_img, in ) ;
      ClassicAtari2StdVDI( out, &std_img ) ;
      vr_trnfm( handle, &std_img, out ) ;
      Xfree( std_img.fd_addr ) ;
    }
  }

  if ( err ) Xfree( out->fd_addr ) ;
  if ( buffer ) Xfree( buffer ) ;
  if ( data_out ) Xfree( data_out ) ;
  if ( int_buffer ) Xfree( int_buffer ) ;

  return err ;
}
