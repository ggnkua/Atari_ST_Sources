/**************************/
/*------ RASTEROP.C ------*/
/* Routines de traitement */
/* De blocs images MFDB   */
/**************************/
#include   <math.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>

#include  "..\tools\stdprog.h"
#include     "..\tools\xgem.h"
#include  "..\tools\cookies.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\fastzoom.h"
#include "..\tools\logging.h"
#include "..\tools\rzoom.h"


int           RGB8BToRGBPM[256] ;
unsigned char RGBPMToRGB8B[1001] ;

/* In RASTEROP.S */
char          flag_sym = 0 ;
unsigned char xsym_tab[256] ;

void img_raz(MFDB* img) ;

void ind2raster(void) ;
void row2dind(MFDB* in, int col, unsigned char* buffer) ;
void row2find(MFDB* in, int col, unsigned char* buffer) ;

void ClassicAtari2StdVDI(MFDB* in, MFDB* out) ;
void StdVDI2ClassicAtari(MFDB* in, MFDB* out) ;

void tc_invconvert(MFDB* img) ;
int  GetRolw(int w, int motif) ;
int  GetRoll(long w, int motif) ;


void raster2ind(int* pt_raster, unsigned char* out, long nb_pts, int nplans) ; /* Dans RASTEROP.S */
void   *i2r_data ; /* Adresse d‚but des donn‚es pour ind2raster */
size_t i2r_nb ;    /* Nombre d'indices … transf‚rer             */
void   *i2rout ;
void   *i2rout_sl ; /* Pointer to current line for targa routines */
int    i2rnbplan ;
int    i2rmaxx ;
int    i2rx ;
long   i2rlo ;
int    i2r_a16 = 1 ; /* Alignement sur 16 bits */
char   ignore_a16 = 0 ; /* D‚sactive l'optimation automatique */
int    i2r_use030 ;

unsigned char *pixel_adrin ; /* Tableau des indices TOS si m‚moire suffisante  */
void          *pixel_adr ;   /* Identique … img->fd_addr dans le cas contraire */
long          *pixel_lgoff ; /* Offset des lignes en octets */
int           pixel_mode ;   /* Type de pr‚calcul */
int           (*pixel_get)(int x, int y) ; /* Pointeur sur la fonction appropri‚e */

int  pixel_getmode1(int x, int y) ; /* Dans RASTEROP.S */
int  pixel_getmode2(int x, int y) ; /* Dans RASTEROP.S */
int  pixel_getmode4(int x, int y) ; /* Dans RASTEROP.S */
int  pixel_getmode8(int x, int y) ; /* Dans RASTEROP.S */
int  pixel_tcget(int x, int y) ;    /* Dans RASTEROP.S */
int  pixel_030tcget(int x, int y) ; /* Dans RASTEROP.S */
long pixel_030tcget32(int x, int y) ; /* Dans RASTEROP.S */
long pixel_tcget32(int x, int y) ;    /* Dans RASTEROP.S */
long pixel_tcget24(int x, int y) ;    /* Dans RASTEROP.S */
extern char r2i_bitarray[8*256] ;     /* Dans RASTEROP.S */


int align16(int x)
{
  return ALIGN16( x ) ;
}

void i2r_init(MFDB *out, int max_x, int raz_done)
/*void i2r_init(void *start_out, int max_x, int nplan)*/
{
  int nplan = out->fd_nplanes ;
  int wdwidth ;

  i2rout    = out->fd_addr ;
  i2rnbplan = nplan ;
  i2rmaxx   = max_x ;
  i2rx      = 0 ;
  i2rout_sl = out->fd_addr ;
  i2r_a16   = 0 ;
  wdwidth   = w2wdwidth( max_x ) ;
  if ( ((max_x & 0x0F) == 0) && !ignore_a16 ) i2r_a16 = 1 ; /* Optimisation ind2raster */

  if ( !i2r_a16 && !raz_done ) img_raz( out ) ;

  i2rlo = 2L*(long)wdwidth*(long)nplan ;
}

void zoom_cup(MFDB *in, MFDB *out, int *xy, int x_level)
{
  int xyarray[8] ;
  int i, j ;

  if (x_level == 1)
  {
    xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
    xyarray[2] = xy[2] ; xyarray[3] = xy[3] ;
    xyarray[4] = xyarray[5] = 0 ;
    xyarray[6] = xy[2]-xy[0] ;
    xyarray[7] = xy[3]-xy[1] ;
    vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;

    return ;
  }

  xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
  xyarray[2] = xy[0] ; xyarray[3] = xy[3] ;
  xyarray[4] = xyarray[5] = xyarray[6] =0 ;
  xyarray[7] = xy[3]-xy[1] ;
  for (j = xy[0]; j <= xy[2]; j++)
  {
    for (i = 0; i < x_level; i++)
    {
      vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;
      xyarray[4]++ ;
      xyarray[6]++ ;
    }
    xyarray[0]++ ;
    xyarray[2]++ ;
  }   
}

void zoom_cdown(MFDB *in, MFDB *out, int *xy, int x_level)
{
  int xyarray[8] ;
  int j ;

  if (x_level == 1)
  {
    xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
    xyarray[2] = xy[2] ; xyarray[3] = xy[3] ;
    xyarray[4] = xyarray[5] = 0 ;
    xyarray[6] = xy[2]-xy[0] ;
    xyarray[7] = xy[3]-xy[1] ;
    vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;

    return ;
  }

  xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
  xyarray[2] = xy[0] ; xyarray[3] = xy[3] ;
  xyarray[4] = xyarray[5] = xyarray[6] =0 ;
  xyarray[7] = xy[3]-xy[1] ;
  for (j = xy[0]; j <= xy[2]; j += x_level)
  {
    vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;
    xyarray[4]++ ;
    xyarray[6]++ ;
    xyarray[0] += x_level ;
    xyarray[2] += x_level ;
  }   
}

void zoom_lup(MFDB *in, MFDB *out, int *xy, int y_level)
{
  int xyarray[8] ;
  int i, j ;

  if (y_level == 1)
  {
    xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
    xyarray[2] = xy[2] ; xyarray[3] = xy[3] ;
    xyarray[4] = xyarray[5] = 0 ;
    xyarray[6] = xy[2]-xy[0] ;
    xyarray[7] = xy[3]-xy[1] ;
    vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;

    return ;
  }

  xyarray[0] = xy[0] ; xyarray[1] = xy[3] ;
  xyarray[2] = xy[2] ; xyarray[3] = xy[3] ;
  xyarray[4] = xy[0] ; xyarray[5] = out->fd_h-1 ;
  xyarray[6] = xy[2] ; xyarray[7] = out->fd_h-1 ;
  for (j = xy[3]; j >= xy[1]; j--)
  {
    for (i = 0; i < y_level; i++)
    {
      vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;
      xyarray[5]-- ;
      xyarray[7]-- ;
    }
    xyarray[3]-- ;
    xyarray[1]-- ;
  }
}

void zoom_ldown(MFDB *in, MFDB *out, int *xy, int y_level)
{
  int xyarray[8] ;
  int j ;

  if (y_level == 1)
  {
    xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
    xyarray[2] = xy[2] ; xyarray[3] = xy[3] ;
    xyarray[4] = xyarray[5] = 0 ;
    xyarray[6] = xy[2]-xy[0] ;
    xyarray[7] = xy[3]-xy[1] ;
    vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;

    return ;
  }

  xyarray[0] = xy[0] ; xyarray[1] = xy[1] ;
  xyarray[2] = xy[2] ; xyarray[3] = xy[1] ;
  xyarray[4] = xyarray[5] = xyarray[7] = 0 ;
  xyarray[6] = xy[2]-xy[0] ;
  for (j = xy[1]; j <= xy[3]; j += y_level)
  {
    vro_cpyfm(handle, S_ONLY, xyarray, in, out) ;
    xyarray[5]++ ;
    xyarray[7]++ ;
    xyarray[1] += y_level ;
    xyarray[3] += y_level ;
  }   
}

int raster_zoom(MFDB *in, MFDB *out, int xy[4], int x_level, int y_level)
{
  MFDB temp ;
  int  err ;
  char local_alloc = 0 ;

  CopyMFDB( &temp, in ) ;
  temp.fd_w = 1+xy[2]-xy[0] ;
  temp.fd_h = 1+xy[3]-xy[1] ;
  if ( (temp.fd_w != in->fd_w) || (temp.fd_h != in->fd_h) )
  {
    int  pxy[8] ;

    temp.fd_addr = img_alloc( temp.fd_w, temp.fd_h, temp.fd_nplanes ) ;
    if ( temp.fd_addr == NULL ) return( -1 ) ;
    temp.fd_wdwidth = w2wdwidth( temp.fd_w ) ;
    memcpy( pxy, xy, 4 * sizeof(int) ) ;
    pxy[4] = 0 ;
    pxy[5] = 0 ;
    pxy[6] = temp.fd_w - 1 ;
    pxy[7] = temp.fd_h - 1 ;
    vro_cpyfm( handle, S_ONLY, pxy, in, &temp ) ;
    local_alloc = 1 ;
  }

  CopyMFDB( out, &temp ) ;
  out->fd_addr = NULL ;
  if ( x_level >= 0 ) out->fd_w = temp.fd_w * x_level ;
  else                out->fd_w = temp.fd_w / (-x_level) ;
  if ( y_level >= 0 ) out->fd_h = temp.fd_h * y_level ;
  else                out->fd_h = temp.fd_h / (-y_level) ;

  err = RasterZoom( &temp, out, NULL ) ;

  if ( local_alloc ) Xfree ( temp.fd_addr ) ;

  return err ;
}

void zoom_pcxstdplane(MFDB *in, MFDB *out, int pc, GEM_WINDOW* wprog)
{
  float         ratio ;
  long          lo_in, lo_out ;
  int           *pt_in, *pt_out ;
  int           *tab ;
  int           i, l ;
  unsigned char *src, *dst ;

  tab = (int*) Xalloc( (out->fd_w << 1) + in->fd_w + out->fd_w ) ;
  if ( tab == NULL ) return ;
  src = (unsigned char*) (tab + out->fd_w ) ;
  dst = src + in->fd_w ;
  
  lo_in  = (long) (in->fd_wdwidth*in->fd_nplanes) ;   /* En mots */
  lo_out = (long) (out->fd_wdwidth*out->fd_nplanes) ; /* En mots */
  ratio  = 100.0/(float)pc ;
  for (l = 0; l < out->fd_w; l++) tab[l] = (int) (0.5+(float)l*ratio) ;

  pt_in  = (int*) in->fd_addr ;
  pt_out = (int*) out->fd_addr ;
  i2r_init( out, out->fd_w, 0 ) ;
  i2r_nb   = out->fd_w ;
  i2r_data = dst ;
  for (l = 0; l < out->fd_h; l++)
  {
    raster2ind(pt_in, src, in->fd_w, in->fd_nplanes) ;
    for (i = 0; i < out->fd_w; i++) dst[i] = src[tab[i]] ;
    i2rout = pt_out ;
    i2rx   = 0 ;
    ind2raster() ;
    pt_in  += lo_in ;
    pt_out += lo_out ;
    (void)GWProgRange( wprog, l, out->fd_w, NULL ) ;
  }

  Xfree(tab) ;
}

void zoom_pcxstd(MFDB *in, MFDB *out, int pc, GEM_WINDOW* wprog)
{
  float ratio ;
  long  val ;
  int   cout ;
  int   i ;

  if ( pc == 100 ) return ;

  if ( in->fd_nplanes == 16 )
  {
    long lo_in, lo_out ;
    int  *pt_in, *pt_out, *pin, *pout ;

    ratio  = 100.0/(float)pc ;
    lo_in  = (long) (in->fd_wdwidth << 4) ;
    lo_out = (long) (out->fd_wdwidth << 4) ;
    pt_in  = (int *) in->fd_addr ;
    pt_out = (int *) out->fd_addr ;
    for (cout = 0; cout < out->fd_w; cout++)
    {
      val  = (long)((float)cout*ratio) ;
      pin  = pt_in+val ;
      pout = pt_out ;
      for (i = 0; i < out->fd_h; i++)
      {
        *pout = *pin ;
        pin  += lo_in ;
        pout += lo_out ;
      }
      pt_out++ ;
      (void)GWProgRange( wprog, cout, out->fd_w, NULL ) ;
    }
  }
  else zoom_pcxstdplane(in, out, pc, wprog) ;
}

void zoom_pcxspec(MFDB *in, MFDB *out, int pc, GEM_WINDOW* wprog)
{
  float val, ratio ;
  int   xy[8] ;
  int   cout ;

  if (pc == 100) return ;

  xy[1] = xy[5] = 0 ;
  xy[3] = xy[7] = in->fd_h-1 ;
  ratio = 100.0/(float)pc ;
  for (cout = 0; cout < out->fd_w; cout++)
  {
    val = (float)cout*ratio ;
    xy[0] = xy[2] = (int) val ;
    xy[4] = xy[6] = cout ;
    vro_cpyfm(handle, S_ONLY, xy, in, out) ;
    (void)GWProgRange( wprog, cout, out->fd_w, NULL ) ;
  }
}

void zoom_pcx(MFDB *in, MFDB *out, int pc, GEM_WINDOW* wprog)
{
  if ( !can_usevro( in->fd_nplanes ) ) zoom_pcxstd(in, out, pc, wprog) ;
  else                                 zoom_pcxspec(in, out, pc, wprog) ;
}

void zoom_pcystd(MFDB *in, MFDB *out, int pc, GEM_WINDOW* wprog)
{
  float ratio ;
  long  val ;
  long  lo_in, lo_out ;
  int   *pt_in, *pt_out, *pin ;
  int   lout ;

  if ( pc == 100 ) return ;

  ratio  = 100.0/(float)pc ;
  lo_in  = (long) (in->fd_wdwidth*in->fd_nplanes) ;   /* En mots */
  lo_out = (long) (out->fd_wdwidth*out->fd_nplanes) ; /* En mots */
  pt_in  = (int*) in->fd_addr ;
  pt_out = (int*) out->fd_addr ;
  for (lout = 0; lout < out->fd_h; lout++)
  {
    val = (long) ((float)lout*ratio) ;
    pin = pt_in+val*lo_in ;
    memcpy(pt_out, pin, lo_out << 1) ;
    pt_out += lo_out ;
    (void)GWProgRange( wprog, lout, out->fd_h, NULL ) ;
  }
}

void zoom_pcyspec(MFDB *in, MFDB *out, int pc, GEM_WINDOW* wprog)
{
  float val, ratio ;
  int   xy[8] ;
  int   lout ;

  if (pc == 100) return ;

  xy[0] = xy[4] = 0 ;
  xy[2] = xy[6] = in->fd_w-1 ;
  ratio = 100.0/(float)pc ;
  for (lout = 0; lout < out->fd_h; lout++)
  {
    val = (float)lout*ratio ;
    xy[1] = xy[3] = (int) val ;
    xy[5] = xy[7] = lout ;
    vro_cpyfm(handle, S_ONLY, xy, in, out) ;
    (void)GWProgRange( wprog, lout, out->fd_h, NULL ) ;
  }
}

void zoom_pcy(MFDB* in, MFDB* out, int pc, GEM_WINDOW* wprog)
{
  if ( !can_usevro( in->fd_nplanes ) ) zoom_pcystd(in, out, pc, wprog) ;
  else                                 zoom_pcyspec(in, out, pc, wprog) ;
}

int raster_duplicate(MFDB* in, MFDB* out)
{
  long size ;

  if ( out->fd_addr == NULL )
  {
    CopyMFDB( out, in ) ;
    out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
    if ( out->fd_addr == NULL ) return -1 ;
  }

  size = img_size( out->fd_w,out->fd_h, out->fd_nplanes ) ;
  memcpy( out->fd_addr, in->fd_addr, size ) ;

  return 0 ;
}

int raster_pczoom(MFDB* in, MFDB* out, int pcx, int pcy, GEM_WINDOW* wprog)
{
  MFDB  temp ;
  float wf, hf ;
  int   w, h ;

  out->fd_addr = NULL ;
  if ( (pcx == 100) && (pcy == 100) ) return( raster_duplicate(in, out) ) ;

  wf = 0.5+(float)pcx*(float)in->fd_w/100.0 ;
  w  = (int) wf ;
  hf = 0.5+(float)pcy*(float)in->fd_h/100.0 ;
  h  = (int) hf ;

  if ( pcy >= 100 ) /* Il est plus rentable de distinguer 2 cas */
  {
    CopyMFDB( &temp, in ) ;
    if ( pcx != 100 )
    {
      temp.fd_w       = w ;
      w               = align16( w ) ;
      temp.fd_wdwidth = w2wdwidth( w ) ;
      temp.fd_addr    = img_alloc( w, temp.fd_h, temp.fd_nplanes ) ;
      if ( temp.fd_addr == NULL ) return -1 ;
      img_raz( &temp ) ;
      /* Traitememt des colonnes */
      zoom_pcx( in, &temp, pcx, wprog ) ;
    }

    /* Traitement des lignes */
    temp.fd_w = w ;
    CopyMFDB( out, &temp ) ;
    if ( pcy != 100 )
    {
      out->fd_h    = h ;
      out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
      if ( out->fd_addr == NULL )
      {
        if ( pcx != 100 ) Xfree(temp.fd_addr) ;
        ZeroMFDB( out ) ;
        return -1 ;
      }
      zoom_pcy( &temp, out, pcy, wprog ) ;
    }
    else CopyMFDB( out, &temp ) ;
  }
  else
  {
    CopyMFDB( &temp, in ) ;
    temp.fd_h    = h ;
    temp.fd_addr = img_alloc( temp.fd_w, temp.fd_h, temp.fd_nplanes ) ;
    if ( temp.fd_addr == NULL ) return -1 ;
    /* Traitememt des lignes */
    zoom_pcy( in, &temp, pcy, wprog ) ;

    /* Traitement des colonnes */
    CopyMFDB( out, &temp ) ;
    if ( pcx != 100 )
    {
      out->fd_w       = w ;
      out->fd_wdwidth = w2wdwidth( w ) ;
      out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
      if ( out->fd_addr == NULL )
      {
        Xfree( temp.fd_addr ) ;
        ZeroMFDB( out ) ;
        return -1 ;
      }
      img_raz( out ) ;
      zoom_pcx( &temp, out, pcx, wprog ) ;
      out->fd_w = align16( out->fd_w ) ;
    }
    else CopyMFDB( out, &temp ) ;
  }

  if ( (pcx != 100) && (pcy != 100) ) Xfree( temp.fd_addr ) ;

  return 0 ;
}

int smart_hsym(MFDB* img)
{
  long lo_ligne ;
  int* buffer ;
  int  s ;
  char *pts, *ptd ;

  lo_ligne = (16L*(long)img->fd_wdwidth*(long)img->fd_nplanes) >> 3 ;
  buffer   = img_alloc(img->fd_w, 1, img->fd_nplanes) ;
  if ( buffer == NULL ) return -1 ;

  pts = (char*) img->fd_addr ;
  ptd = pts+(long)(img->fd_h-1)*lo_ligne ;
  for ( s = 0; s < (img->fd_h>>1); s++ )
  {
    memcpy( buffer, ptd, lo_ligne ) ;
    memcpy( ptd, pts, lo_ligne ) ;
    memcpy( pts, buffer, lo_ligne ) ;
    pts += lo_ligne ;
    ptd -= lo_ligne ;
  }
  Xfree( buffer ) ;

  return 0 ;
}

int raster_hsym(MFDB* img, int* pxy)
{
  MFDB virtuel ;
  int  xy[8] ;
  int  ls, ld ;

  if ( !can_usevro( img->fd_nplanes ) )
  {
    /* Merci le GEM et NVDI ! */
    /* Attention pxy est ignor‚, toute l'image est invers‚e */
    return( smart_hsym( img ) ) ;
  }
  CopyMFDB( &virtuel, img ) ;
  virtuel.fd_w    = 1 + pxy[2] - pxy[0] ;
  virtuel.fd_h    = 1 ;
  virtuel.fd_addr = img_alloc( virtuel.fd_w, virtuel.fd_h, virtuel.fd_nplanes ) ;
  if ( virtuel.fd_addr == NULL ) return -1 ;
  virtuel.fd_wdwidth = w2wdwidth( virtuel.fd_w ) ;

  ld = pxy[1] ;
  for ( ls = pxy[3] ; ls > ((pxy[1]+pxy[3])>>1); ls--, ld++ )
  {
    xy[0] = pxy[0] ;
    xy[1] = ld ;
    xy[2] = pxy[2] ;
    xy[3] = ld ;
    xy[4] = 0 ;
    xy[5] = 0 ;
    xy[6] = virtuel.fd_w - 1 ;
    xy[7] = 0 ;
    vro_cpyfm( handle, S_ONLY, xy, img, &virtuel ) ;

    xy[0] = pxy[0] ;
    xy[1] = ls ;
    xy[2] = pxy[2] ;
    xy[3] = ls ;
    xy[4] = pxy[0] ;
    xy[5] = ld ;
    xy[6] = pxy[2] ;
    xy[7] = ld ;
    vro_cpyfm( handle, S_ONLY, xy, img, img ) ;

    xy[0] = 0 ;
    xy[1] = 0 ;
    xy[2] = virtuel.fd_w - 1 ;
    xy[3] = 0 ;
    xy[4] = pxy[0] ;
    xy[5] = ls ;
    xy[6] = pxy[2] ;
    xy[7] = ls ;
    vro_cpyfm( handle, S_ONLY, xy, &virtuel, img ) ;
  }

  Xfree( virtuel.fd_addr ) ;

  return 0 ;
}

int raster_symvrt(int handle, int *xyarray, MFDB *src, MFDB *dest)
{
  int xy[8] ;
  int ls, ld ;

  if ( (src->fd_addr == NULL) || (dest->fd_addr == NULL) ) v_hide_c( handle ) ;
  xy[0] = xyarray[0] ;
  xy[2] = xyarray[2] ;
  xy[4] = xyarray[0] ;
  xy[6] = xyarray[2] ;
  ld    = xyarray[5] ;
  for (ls = xyarray[3] ; ls >= xyarray[1]; ls--)
  {
    if (ls < 0) break ;
    if (ls >= src->fd_h) break ;
    if (ld >= dest->fd_h) break ;
    xy[1] = xy[3] = ls ;
    xy[5] = xy[7] = ld ;
    vro_cpyfm( handle, S_ONLY, xy, src, dest ) ;
    ld++ ;
  }

  if ( (src->fd_addr == NULL) || (dest->fd_addr == NULL) ) v_show_c( handle, 1 ) ;

  return 0 ;
}

void bitinv_init(void)
{
  int           i ;
  unsigned char inv ;

  for (i = 0; i < 256; i++)
  {
    inv = 0 ;
    if (i & 0x01) inv |= 0x80 ;
    if (i & 0x02) inv |= 0x40 ;
    if (i & 0x04) inv |= 0x20 ;
    if (i & 0x08) inv |= 0x10 ;
    if (i & 0x10) inv |= 0x08 ;
    if (i & 0x20) inv |= 0x04 ;
    if (i & 0x40) inv |= 0x02 ;
    if (i & 0x80) inv |= 0x01 ;
    xsym_tab[i] = inv ;
  }

  flag_sym = 1 ;
}

void membsym(unsigned char* buffer, long nb)
{
  unsigned char* middle ;
  unsigned char *pos1, *pos2 ;
  unsigned char temp ;

  middle = buffer+(nb >> 1) ;
  pos2   = buffer+nb-1 ;
  for (pos1 = buffer; pos1 < middle; pos1++)
  {
    temp    = *pos1 ;
    *pos1   = *pos2 ;
    *pos2-- = temp ;
  }
}

int raster_xlsym(MFDB *img)
{
  MFDB          std_img ;
  long          dec_end ;
  int           nbp, nump ;
  unsigned char *pt_start, *pt_end ;
  unsigned char vals, vale ;

  MakeMFDBClassicAtari( img, &std_img ) ;

  pt_start = (unsigned char*) img->fd_addr ;
  pt_end  = pt_start+((img->fd_wdwidth-1)*img->fd_nplanes)*2 ;
  pt_end++ ;
  nbp     = img->fd_nplanes ;
  dec_end = (long) (4*nbp) ;
  while (pt_start < pt_end-1)
  {
    for (nump = 0; nump < nbp; nump++)
    {
      vale        = xsym_tab[*pt_end] ;
      vals        = xsym_tab[*pt_start] ;
      *pt_end--   = vals ;
      *pt_start++ = vale ;
      vale        = xsym_tab[*pt_end] ;
      vals        = xsym_tab[*pt_start] ;
      *pt_end     = vals ;
      pt_end     += 3 ;
      *pt_start++ = vale ;
    }
    pt_end -= dec_end ;
  }

  if (pt_start == pt_end-1)
  {
    for (nump = 0; nump < nbp; nump++)
    {
      vale      = xsym_tab[*pt_end] ;
      vals      = xsym_tab[*pt_start] ;
      *pt_end   = vals ;
      *pt_start = vale ;
      pt_start  = pt_start+2 ;
      pt_end    = pt_end+2 ;
    }
  }

  if (UseStdVDI && (img->fd_nplanes <= 8))
  {
    ClassicAtari2StdVDI( img, &std_img ) ;
    vr_trnfm( handle, &std_img, img ) ;
    Xfree( std_img.fd_addr ) ;
  }

  return 0 ;
}

int raster_vsym(MFDB *img, int *pxy)
{
  MFDB temp ;
  long ltc, nl, add ;
  int  xy[8] ;
  int  rcxy[8] ;
  int  c, i, l ;

  if (img->fd_nplanes == 16)
  {
    unsigned int val ;
    unsigned int *pti1, *pti2, *pt1, *pt2 ;

    i    = (pxy[0]+pxy[2]) >> 1 ;
    nl   = img->fd_w ;
    if (img->fd_addr != NULL)
    {
      pti1 = (unsigned int*)img->fd_addr+pxy[0] ;
      pti2 = (unsigned int*)img->fd_addr+pxy[2] ;
    }
    else
    {
      pti1 = (unsigned int*)Physbase()+pxy[0] ;
      pti2 = (unsigned int*)Physbase()+pxy[2] ;
      v_hide_c(handle) ;
    }
    for (ltc = pxy[1]; ltc <= pxy[3]; ltc++)
    {
      add = ltc*nl ;
      pt1 = pti1+add ;
      pt2 = pti2+add ;
      for (c = pxy[0]; c < i; c++)
      {
        val    = *pt1 ;
        *pt1++ = *pt2 ;
        *pt2-- = val ;
      }
    }
    if (img->fd_addr == NULL) v_show_c(handle, 1) ;

    return 0 ;
  }
  else if (img->fd_nplanes == 24)
  {
    unsigned char r, v, b ;
    unsigned char *pti1, *pti2, *pt1, *pt2 ;

    i    = (pxy[0]+pxy[2]) >> 1 ;
    nl   = img->fd_w ;
    if (img->fd_addr != NULL)
    {
      pti1 = (unsigned char *)img->fd_addr+pxy[0] ;
      pti2 = (unsigned char *)img->fd_addr+pxy[2] ;
    }
    else
    {
      pti1 = (unsigned char *)Physbase()+pxy[0] ;
      pti2 = (unsigned char *)Physbase()+pxy[2] ;
      v_hide_c(handle) ;
    }
    for (ltc = pxy[1]; ltc <= pxy[3]; ltc++)
    {
      add = ltc*nl ;
      pt1 = pti1+add ;
      pt2 = pti2+add ;
      for (c = pxy[0]; c < i; c++)
      {
        r      = *pt1 ;
        v      = *(1+pt1) ;
        b      = *(2+pt1) ;
        *pt1++ = *pt2 ;
        *pt1++ = *(1+pt2) ;
        *pt1++ = *(2+pt2) ;
        *pt2++ = r ;
        *pt2++ = v ;
        *pt2++ = b ;
      }
    }
    if (img->fd_addr == NULL) v_show_c(handle, 1) ;

    return 0 ;
  }
  else if (img->fd_nplanes == 32)
  {
    unsigned long val ;
    unsigned long *pti1, *pti2, *pt1, *pt2 ;

    i    = (pxy[0]+pxy[2]) >> 1;
    nl   = img->fd_w ;
    if (img->fd_addr != NULL)
    {
      pti1 = (unsigned long *)img->fd_addr+pxy[0] ;
      pti2 = (unsigned long *)img->fd_addr+pxy[2] ;
    }
    else
    {
      pti1 = (unsigned long *)Physbase()+pxy[0] ;
      pti2 = (unsigned long *)Physbase()+pxy[2] ;
      v_hide_c(handle) ;
    }
    for (ltc = pxy[1]; ltc <= pxy[3]; ltc++)
    {
      add = ltc*nl ;
      pt1 = pti1+add ;
      pt2 = pti2+add ;
      for (c = pxy[0]; c < i; c++)
      {
        val    = *pt1 ;
        *pt1++ = *pt2 ;
        *pt2-- = val ;
      }
    }
    if (img->fd_addr == NULL) v_show_c(handle, 1) ;

    return 0 ;
  }

  CopyMFDB( &temp, img ) ;
  temp.fd_w       = align16( 1+pxy[2]-pxy[0] ) ;
  temp.fd_wdwidth = temp.fd_w >> 4 ;
  temp.fd_h       = 1 ;
  temp.fd_addr    = img_alloc(temp.fd_w, 1, temp.fd_nplanes) ;
  if (temp.fd_addr == NULL) return -1 ;

  if ( !flag_sym ) bitinv_init() ;
  xy[0] = pxy[0] ;
  xy[2] = pxy[2] ;
  xy[4] = 0 ;
  xy[5] = 0 ;
  xy[6] = pxy[2]-pxy[0] ;
  xy[7] = 0 ;
  rcxy[0] = 15-(xy[6] & 0x0F) ;
  rcxy[1] = 0 ;
  rcxy[2] = rcxy[0]+pxy[2]-pxy[0] ;
  rcxy[3] = 0 ;
  rcxy[4] = pxy[0] ;
  rcxy[6] = pxy[2] ;
  img_raz(&temp) ;
  if (img->fd_addr == NULL) v_hide_c(handle) ;
  for (l = pxy[1]; l <= pxy[3]; l++)
  {
    xy[1] = xy[3] = l ;
    vro_cpyfm(handle, S_ONLY, xy, img, &temp) ;
    if (raster_xlsym(&temp) != 0)
    {
      Xfree(temp.fd_addr) ;
      return(-1) ;
    }
    rcxy[5] = rcxy[7] = l ;
    vro_cpyfm(handle, S_ONLY, rcxy, &temp, img) ;
  }
  if (img->fd_addr == NULL) v_show_c(handle, 1) ;

  Xfree(temp.fd_addr) ;
  return 0 ;
}

void pal_ajust(void)
{
  long          i ;
  unsigned char *pt, val ;

  pt = i2r_data ;
  for (i = 0; i < i2r_nb; i++)
  {
    val   = *pt ;
    *pt++ = palind[val] ;
  }
}

void ind4plans(unsigned char *buffer, unsigned long nb)
{
  unsigned long i ;
  unsigned char *pt1, *pt2 ;
  unsigned char val1, val2 ;

  pt1 = pt2 = buffer ;
  for (i = 0; i < nb; i += 2)
  {
    val1   = *pt2++ ;
    val1 <<= 4 ;
    val2   = *pt2++ ;
    *pt1++ = val1 | val2 ;
  }
}

int pixel_getmode0(int x, int y) /* Mieux vaut l'int‚grer directemment … l'endroit voulu */
{
  return(*(pixel_adrin+pixel_lgoff[y]+x)) ;
}

int pixel_init(MFDB *img)
{
  long *adr ;
  long val ;
  long nbpts ;
  long lo_ligne ;
  int  l ;

  pixel_mode = 0 ;
  pixel_lgoff = (long*) Xalloc(img->fd_h*sizeof(long)) ;
  if (pixel_lgoff == NULL)
  {
    pixel_mode = -1 ;
    return(pixel_mode) ; /* M‚moire insuffisante */
  }

  if (img->fd_nplanes <= 8)
  {
    nbpts  = (long)img->fd_wdwidth*(long)img->fd_h ;
    nbpts <<= 4 ;
  }
  else nbpts = (long)img->fd_w*(long)img->fd_h ;
  if (img->fd_nplanes <= 8)
    pixel_adrin = (unsigned char *) Xalloc(nbpts) ;
  else
    pixel_adr = img->fd_addr ;
  
  if ((pixel_adrin == NULL) && (img->fd_nplanes <= 8))
  {
    Xfree(pixel_lgoff) ;

    return(-1) ;
  }
  else if (img->fd_nplanes <= 8)
  {
  /* Si possible, on convertit toute l'image en indices TOS (si non True Color) */
    raster2ind(img->fd_addr, pixel_adrin, nbpts, img->fd_nplanes) ;
    /* L'indice TOS correspondant au pixel (x,y) est donn‚e par */
    /* L'adresse pixel_adrin+pixel_lgoff[y]+x                   */
    pixel_mode = 0 ;
    pixel_get  = pixel_getmode0 ;
  }

  /* Pr‚calcul des offsets ligne */
  if (img->fd_nplanes <= 8) lo_ligne = 16*img->fd_wdwidth ;
  else                      lo_ligne = 16L*(img->fd_nplanes>>3)*(long)img->fd_wdwidth ;

  val = 0 ;
  adr = pixel_lgoff ;
  for (l = 0; l < img->fd_h; l++)
  {
    *adr++ = val ;
    val   += lo_ligne ;
  }

  return(pixel_mode) ;
}

void pixel_free(void)
{
  if ( pixel_adrin ) Xfree( pixel_adrin ) ;
  Xfree( pixel_lgoff ) ;
}

static int cs(int x, float c, int y, float s)
{
  return (int) (0.5+(float)x*c+(float)y*s) ;
}

void raster_rgetdstmfdb(int angle, MFDB *in, MFDB *out, float *c, float *s)
{
  float ar ;
  int   xc, yc ;
  int   w, h ;
  int   x1, x2, x3, x4 ;
  int   y1, y2, y3, y4 ;
  int   xm, ym, xp, yp ;

  out->fd_nplanes = in->fd_nplanes ;
  out->fd_stand   = in->fd_stand ;

  switch( angle % 360 )
  {
    case 0    :
    case -180 :
    case 180  : out->fd_w = in->fd_w ;
                out->fd_h = in->fd_h ;
                break ;

    case -90  :
    case 90   :
    case -270 :
    case 270  : out->fd_w = in->fd_h ; 
                out->fd_h = in->fd_w ;
                break ;

    default   : ar = (float)angle*M_PI/180.0 ;
                *c = cos( ar ) ;
                *s = sin( ar ) ;
                xc = in->fd_w>>1 ;
                yc = in->fd_h>>1 ;
                x1 = xc + cs( -xc, *c, -yc, *s ) ;                                                  /* (int) (0.5+(float)(0-xc)*(*c)+(float)(0-yc)*(*s)) ; */
                y1 = yc + cs(  xc, *s, -yc, *c ) ;                                                  /* (int) (0.5-(float)(0-xc)*(*s)+(float)(0-yc)*(*c)) ; */

                x2 = xc + cs( in->fd_w-1-xc, *c, -yc, *s ) ;                                        /* (int) (0.5+(float)(in->fd_w-1-xc)*(*c)+(float)(0-yc)*(*s)) ; */
                y2 = yc + cs( xc+1-in->fd_w, *s, -yc, *c ) ;                                        /* (int) (0.5-(float)(in->fd_w-1-xc)*(*s)+(float)(0-yc)*(*c)) ; */

                x3 = xc + cs( in->fd_w-1-xc, *c, in->fd_h-1-yc, *s ) ;                              /* (int) (0.5+(float)(in->fd_w-1-xc)*(*c)+(float)(in->fd_h-1-yc)*(*s)) ; */
                y3 = yc + cs( xc+1-in->fd_w, *s, in->fd_h-1-yc, *c ) ;                              /* (int) (0.5-(float)(in->fd_w-1-xc)*(*s)+(float)(in->fd_h-1-yc)*(*c)) ; */

                x4 = xc + cs( -xc, *c, in->fd_h-1-yc, *s ) ;                                        /* (int) (0.5+(float)(0-xc)*(*c)+(float)(in->fd_h-1-yc)*(*s)) ; */
                y4 = yc + cs(  xc, *s, in->fd_h-1-yc, *c ) ;                                        /* (int) (0.5-(float)(0-xc)*(*s)+(float)(in->fd_h-1-yc)*(*c)) ; */

                xm = x1 ;
                if ( xm > x2 ) xm = x2 ;
                if ( xm > x3 ) xm = x3 ;
                if ( xm > x4 ) xm = x4 ;
                ym = y1 ;
                if ( ym > y2 ) ym = y2 ;
                if ( ym > y3 ) ym = y3 ;
                if ( ym > y4 ) ym = y4 ;
                xp = x1 ;
                if ( xp < x2 ) xp = x2 ;
                if ( xp < x3 ) xp = x3 ;
                if ( xp < x4 ) xp = x4 ;
                yp = y1 ;
                if ( yp < y2 ) yp = y2 ;
                if ( yp < y3 ) yp = y3 ;
                if ( yp < y4 ) yp = y4 ;

                w = abs(xp-xm) ;
                h = abs(yp-ym) ;
                out->fd_w = align16( w ) ;
                out->fd_h = h ;
                break ;
  }
  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
}

int raster_r90(MFDB *in, MFDB *out, GEM_WINDOW* wprog)
{
  int  col, l ;
  int  cancel = 0 ;
  void *buffer ;

  raster_rgetdstmfdb( 90, in, out, NULL, NULL ) ;
  if ( out->fd_addr == NULL ) out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return -1 ;

  buffer = Xalloc( align16( in->fd_h ) ) ;
  if (buffer == NULL)
  {
    Xfree(out->fd_addr) ;
    return(-1) ;
  }

  img_raz( out ) ;

  if ( out->fd_nplanes <= 8 )
  {
    i2r_data = buffer ;
    i2r_nb   = in->fd_h ;
    i2r_init( out, in->fd_h, 1 ) ;

    for ( col = 0; !cancel && (col < in->fd_w); col++ )
    {
      row2find( in, col, (unsigned char *)buffer ) ;
      ind2raster() ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, col, in->fd_w, NULL ) ) ;
    }
  }
  else if (out->fd_nplanes == 16)
  {
    int  *st_src, *src, *st_dest, *dest ;
    long taille ;

    st_src  = in->fd_addr ;
    st_src += (long)in->fd_w*(long)(in->fd_h-1L) ;
    st_dest = out->fd_addr ;
    taille  = (long)in->fd_wdwidth*16L ;
    for (col = 0; !cancel && (col < in->fd_w); col++)
    {
      src  = st_src ;
      dest = st_dest ;
      for (l = 0; l < in->fd_h; l++, src -= taille) *dest++ = *src ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, col, in->fd_w, NULL ) ) ;
      st_src++ ;
      st_dest += (long)(out->fd_wdwidth<<4) ;
    }
  }
  else if (out->fd_nplanes == 24)
  {
    long taille ;
    char *st_src, *src, *st_dest, *dest ;

    st_src  = in->fd_addr ;
    st_src += 3L*(long)in->fd_w*(long)(in->fd_h-1L) ;
    st_dest = out->fd_addr ;
    taille  = 3L*(long)in->fd_wdwidth*16L ;
    for (col = 0; !cancel && (col < in->fd_w); col++)
    {
      src  = st_src ;
      dest = st_dest ;
      for (l = 0; l < in->fd_h; l++, src -= taille)
      {
        *dest++ = src[0] ;
        *dest++ = src[1] ;
        *dest++ = src[2] ;
      }
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, col, in->fd_w, NULL ) ) ;
      st_src++ ;
      st_dest += 3L*(long)(out->fd_wdwidth<<4) ;
    }
  }
  else if (out->fd_nplanes == 32)
  {
    long taille ;
    long *st_src, *src, *st_dest, *dest ;

    st_src  = in->fd_addr ;
    st_src += (long)in->fd_w*(long)(in->fd_h-1L) ;
    st_dest = out->fd_addr ;
    taille  = (long)in->fd_wdwidth*16L ;
    for (col = 0; !cancel && (col < in->fd_w); col++)
    {
      src  = st_src ;
      dest = st_dest ;
      for (l = 0; l < in->fd_h; l++, src -= taille) *dest++ = *src ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, col, in->fd_w, NULL ) ) ;
      st_src++ ;
      st_dest += (long)(out->fd_wdwidth<<4) ;
    }
  }

  Xfree( buffer ) ;
  return cancel ;
}

#pragma warn -parm
int raster_r180(MFDB* in, MFDB *out, GEM_WINDOW* wprog)
{
  int xy[8] ;

  /* Duplication de in car raster_?sym font l'operation sur place */
  if ( raster_duplicate( in, out ) != 0 ) return -1 ;

  xy[0] = xy[1] = 0 ;
  xy[2] = out->fd_w-1 ;
  xy[3] = out->fd_h-1 ;

  if ( raster_vsym( out, xy ) == -1 ) return -1 ;
  if ( raster_hsym( out, xy ) == -1 ) return -1 ;

  return(0) ;
}
#pragma warn +parm

int raster_r270(MFDB* in, MFDB *out, GEM_WINDOW* wprog)
{
  int  col, l ;
  int  cancel = 0 ;
  void *buffer ;

  raster_rgetdstmfdb( 270, in, out, NULL, NULL ) ;
  if ( out->fd_addr == NULL ) out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if ( out->fd_addr == NULL ) return( -1 ) ;

  buffer = Xalloc( align16( in->fd_h ) ) ;
  if ( buffer == NULL )
  {
    Xfree( out->fd_addr ) ;
    return( -1 ) ;
  }

  img_raz( out ) ;
  if ( out->fd_nplanes <= 8 )
  {
    i2r_data = buffer ;
    i2r_nb   = in->fd_h ;
    i2r_init( out, in->fd_h, 1 ) ;

    for ( col = in->fd_w-1; !cancel && (col >= 0); col-- )
    {
      row2dind( in, col, (unsigned char *)buffer ) ;
      ind2raster() ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, in->fd_w-1-col, in->fd_w, NULL ) ) ;
    }
  }
  else if (out->fd_nplanes == 16)
  {
    int  *st_src, *src, *st_dest, *dest ;
    long taille ;

    st_src  = in->fd_addr ;
    st_src += (long)in->fd_w-1 ;
    st_dest = out->fd_addr ;
    taille  = (long)in->fd_wdwidth*16L ;
    for (col = in->fd_w-1; !cancel && (col >= 0); col--)
    {
      src  = st_src ;
      dest = st_dest ;
      for (l = 0; l < in->fd_h; l++, src += taille) *dest++ = *src ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, in->fd_w-1-col, in->fd_w, NULL ) ) ;
      st_src-- ;
      st_dest += (long)(out->fd_wdwidth<<4) ;
    }
  }
  else if (out->fd_nplanes == 24)
  {
    long taille ;
    char *st_src, *src, *st_dest, *dest ;

    st_src  = in->fd_addr ;
    st_src += 3L*(long)in->fd_w-1 ;
    st_dest = out->fd_addr ;
    taille  = 3L*(long)in->fd_wdwidth*16L ;
    for (col = in->fd_w-1; !cancel && (col >= 0); col--)
    {
      src  = st_src ;
      dest = st_dest ;
      for (l = 0; l < in->fd_h; l++, src += taille)
      {
        *dest++ = src[0] ;
        *dest++ = src[1] ;
        *dest++ = src[2] ;
      }
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, in->fd_w-1-col, in->fd_w, NULL ) ) ;
      st_src-- ;
      st_dest += 3L*(long)(out->fd_wdwidth<<4) ;
    }
  }
  else if (out->fd_nplanes == 32)
  {
    long taille ;
    long *st_src, *src, *st_dest, *dest ;

    st_src  = in->fd_addr ;
    st_src += (long)in->fd_w-1 ;
    st_dest = out->fd_addr ;
    taille  = (long)in->fd_wdwidth*16L ;
    for (col = in->fd_w-1; !cancel && (col >= 0); col--)
    {
      src  = st_src ;
      dest = st_dest ;
      for (l = 0; l < in->fd_h; l++, src += taille) *dest++ = *src ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, in->fd_w-1-col, in->fd_w, NULL ) ) ;
      st_src-- ;
      st_dest += (long)(out->fd_wdwidth<<4) ;
    }
  }

  Xfree(buffer) ;
  return(cancel) ;
}

int raster_rfree(MFDB *in, MFDB *out, int angle, GEM_WINDOW* wprog)
{
  float c, s ;
  int   *tincx, *tincy, *tx, *ty ;
  int   x, y ;
  int   xc, yc, xc1, yc1 ;
  int   x0, y0, maxwh ;
  int   col, ligne ;
  int   cancel = 0 ;

  raster_rgetdstmfdb( angle, in, out, &c, &s ) ;
  if ( out->fd_addr == NULL ) out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if ( out->fd_addr == NULL ) return -1 ;

  maxwh = out->fd_w ;
  if ( out->fd_h > maxwh ) maxwh = out->fd_h ;
  tincx = (int*) Xalloc( 2*sizeof(int)*maxwh + ((out->fd_nplanes <= 8) ? out->fd_w:0) ) ;
  if ( tincx == NULL )
  {
    Xfree( out->fd_addr ) ;
    return -1 ;
  }

  tincy  = tincx + maxwh ;
  if (pixel_init(in) < 0)
  {
    Xfree( tincx ) ;
    Xfree( out->fd_addr ) ;
    return -1 ;
  }

  xc = out->fd_w>>1 ;
  yc = out->fd_h>>1 ;
  tx = tincx ;
  ty = tincy ;
  for (col = 0; col < out->fd_w; col++)
  {
    *tx++ = (int) (0.5+(float)col*c) ;
    *ty++ = (int) (0.5-(float)col*s) ;
  }

  xc1  = xc + (int) (0.5-(float)xc*c) ;
  xc1 -= (out->fd_w-in->fd_w) >> 1 ;
  yc1 = yc + (int) (0.5+(float)xc*s) ;
  yc1 -= (out->fd_h-in->fd_h) >> 1 ;

  img_raz(out) ;
  if (out->fd_nplanes <= 8)
  {
    unsigned char *buffer ;
    unsigned char *pt_buffer ;

    buffer   = (unsigned char*) (tincy + maxwh) ;
    i2r_data = buffer ;
    i2r_nb   = out->fd_w ;
    i2r_init(out, out->fd_w, 1 ) ;

    for (ligne = 0; !cancel && (ligne < out->fd_h); ligne++)
    {
      memzero(buffer, out->fd_w) ;
      pt_buffer = buffer ;
      x0   = xc1 + (int) ((float)(ligne-yc)*s) ;
      y0   = yc1 + (int) ((float)(ligne-yc)*c) ;
      tx   = tincx ;
      ty   = tincy ;
      for (col = 0; col < out->fd_w; col++)
      {
        x = x0 + *tx++ ;
        y = y0 + *ty++ ;
        if ((x >= 0) && (x < in->fd_w) && (y >= 0) && (y < in->fd_h))
          *pt_buffer = *(pixel_adrin+pixel_lgoff[y]+x) ; 
        pt_buffer++ ;
      }
      ind2raster() ;
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, ligne, out->fd_h, NULL ) ) ;
    }
  }
  else if (out->fd_nplanes == 16)
  {
    int *pt_img ;
    int (*get_pixel)(int x, int y) ;

    if (MachineInfo.cpu >= 30L)
    {
      get_pixel = pixel_030tcget ;
      if ( wprog ) StdProgDisplay030( wprog, 1 ) ;
    }
    else get_pixel = pixel_tcget ;
    pt_img = (int *) out->fd_addr ;
    for (ligne = 0; !cancel && (ligne < out->fd_h); ligne++)
    {
      x0   = xc1 + (int) ((float)(ligne-yc)*s) ;
      y0   = yc1 + (int) ((float)(ligne-yc)*c) ;
      tx   = tincx ;
      ty   = tincy ;
      for (col = 0; col < out->fd_w; col++)
      {
        x = x0 + *tx++ ;
        y = y0 + *ty++ ;
        if ((x >= 0) && (x < in->fd_w) && (y >= 0) && (y < in->fd_h))
          *pt_img = get_pixel(x, y) ;
        pt_img++ ;
      }
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, ligne, out->fd_h, NULL ) ) ;
    }
  }
  else if (out->fd_nplanes == 24)
  {
    unsigned char *pt_img ;
    long          pixel ;
    unsigned char *pt_pixel = (unsigned char *) &pixel ; /* --> 0RVB */

    pt_img = (unsigned char *) out->fd_addr ;
    for ( ligne = 0; !cancel && (ligne < out->fd_h); ligne++ )
    {
      x0   = xc1 + (int) ((float)(ligne-yc)*s) ;
      y0   = yc1 + (int) ((float)(ligne-yc)*c) ;
      tx   = tincx ;
      ty   = tincy ;
      for ( col = 0; col < out->fd_w; col++ )
      {
        x = x0 + *tx++ ;
        y = y0 + *ty++ ;
        if ((x >= 0) && (x < in->fd_w) && (y >= 0) && (y < in->fd_h))
        {
          pixel     = pixel_tcget24(x, y) ;
          *pt_img++ = pt_pixel[1] ;
          *pt_img++ = pt_pixel[2] ;
          *pt_img++ = pt_pixel[3] ;
        }
      }
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, ligne, out->fd_h, NULL ) ) ;
    }
  }
  else if (out->fd_nplanes == 32)
  {
    long *pt_img ;
    long (*get_pixel)(int x, int y) ;

    if (MachineInfo.cpu >= 30L)
    {
      get_pixel = pixel_030tcget32 ;
      if ( wprog ) StdProgDisplay030( wprog, 1 ) ;
    }
    else 
      get_pixel = pixel_tcget32 ;
    pt_img = (long *) out->fd_addr ;
    for (ligne = 0; !cancel && (ligne < out->fd_h); ligne++)
    {
      x0   = xc1 + (int) ((float)(ligne-yc)*s) ;
      y0   = yc1 + (int) ((float)(ligne-yc)*c) ;
      tx   = tincx ;
      ty   = tincy ;
      for (col = 0; col < out->fd_w; col++)
      {
        x = x0 + *tx++ ;
        y = y0 + *ty++ ;
        if ((x >= 0) && (x < in->fd_w) && (y >= 0) && (y < in->fd_h))
          *pt_img = get_pixel(x, y) ;
        pt_img++ ;
      }
      cancel = PROG_CANCEL_CODE( GWProgRange( wprog, ligne, out->fd_h, NULL ) ) ;
    }
  }

  Xfree( tincx ) ;
  pixel_free() ;

  return cancel ;
}

int raster_rotate(MFDB *in, MFDB *out, int angle, GEM_WINDOW* wprog)
{
  MFDB std_img ;
  int  ret ;

  if ( out->fd_addr == NULL ) ZeroMFDB( out ) ;
  if ( UseStdVDI && (in->fd_nplanes <= 8) )
    if ( MakeMFDBClassicAtari( in, &std_img ) == -3 )
      return -3 ;

  switch(angle)
  {
    case 0    : ret = raster_duplicate( in, out ) ;
                break ;

    case 90   : ret = raster_r90( in, out, wprog ) ;
                break ;

    case -180 :
    case 180  : ret = raster_r180( in, out, wprog ) ;
                break ;

    case -90  :
    case 270  : ret = raster_r270( in, out, wprog ) ;
                break ;

    default   : ret = raster_rfree( in, out, angle, wprog ) ;
                break ;
  }

  if ( UseStdVDI && (in->fd_nplanes <= 8) )
  {
    /* Restaure l'image source */
    vr_trnfm( handle, &std_img, in ) ;
    Xfree( std_img.fd_addr ) ;
    if ( ret == 0 )
    {
      CopyMFDB( &std_img, out ) ;
      std_img.fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
      if ( std_img.fd_addr == NULL )
      {
        Xfree( out->fd_addr ) ;
        ret = -3 ;
      }
      else
      {
        std_img.fd_stand = 1 ;
        ClassicAtari2StdVDI( out, &std_img ) ;
        vr_trnfm( handle, &std_img, out ) ;
        Xfree( std_img.fd_addr ) ;
      }
    }
  }

  return ret ;
}

static int* prepare_pal(INFO_IMAGE *inf, int* pal, int* nb_pal_colors)
{
  int* pt_pal ;

  if ( inf && inf->palette )
  {
    pt_pal         = inf->palette ;
    *nb_pal_colors = (int) inf->nb_cpal ;
  }
  else
  {
    get_tospalette( pal ) ;
    pt_pal         = pal ;
    *nb_pal_colors = nb_colors ;
  }

  return pt_pal ;
}

void make_pal2tc(INFO_IMAGE *inf, unsigned int *tab)
{
  int          pal[256*6] ;
  int          *pt_pal ;
  unsigned int *pt_tab ;
  unsigned int r, v, b ;
  int          i, nb ;

  pt_pal = prepare_pal( inf, pal, &nb ) ;
  pt_tab = tab ;
  for ( i = 0; i < nb; i++ )
  {
    r = RGBPMToRGB8B[*pt_pal++] >> 3 ; /* *pt_pal++ >> 5 ;*/
    v = RGBPMToRGB8B[*pt_pal++] >> 3 ;
    b = RGBPMToRGB8B[*pt_pal++] >> 3 ;
    *pt_tab++ = (r << 11) + (v << 6) + b ;
  }
}

void make_pal2tc32(INFO_IMAGE *inf, unsigned long *tab)
{
  int           pal[256*3] ;
  int           *pt_pal ;
  unsigned long *pt_tab ;
  unsigned long r, v, b ;
  int           i, nb ;

  pt_pal = prepare_pal( inf, pal, &nb ) ;
  pt_tab = tab ;
  for (i = 0; i < nb; i++)
  {
    r = RGBPMToRGB8B[*pt_pal++] ;
    v = RGBPMToRGB8B[*pt_pal++] ;
    b = RGBPMToRGB8B[*pt_pal++] ;
    *pt_tab++ = (r << 24) + (v << 16) + (b<<8) ;
  }
}

void make_pal2tc24(INFO_IMAGE *inf, unsigned char *tab)
{
  int           pal[256*3] ;
  int           *pt_pal ;
  unsigned char *pt_tab ;
  int           i, nb ;
  float         coe = 255.0/1000.0 ;

  pt_pal = prepare_pal( inf, pal, &nb ) ;
  pt_tab = tab ;
  for (i = 0; i < nb; i++)
  {
    *pt_tab++ = (unsigned char) (*pt_pal++ * coe) ;
    *pt_tab++ = (unsigned char) (*pt_pal++ * coe) ;
    *pt_tab++ = (unsigned char) (*pt_pal++ * coe) ;
  }
}

void pal2tc(unsigned char *buf, unsigned int *tab, long nb, int *out)
{
  long          i ;
  int           *pt_out ;
  unsigned char *pt ;

  pt = buf ;
  pt_out = out ;
  for (i = 0; i < nb; i++)
  {
    *pt_out = tab[*pt] ;
    pt_out++ ;
    pt++ ;
  }
}

void pal2tc24(unsigned char *buf, unsigned char *tab, long nb, unsigned char *out)
{
  long          i ;
  unsigned char *pt_out ;
  unsigned char *pt ;
  int           index ;

  pt     = buf ;
  pt_out = out ;
  for ( i = 0; i < nb; i++ )
  {
    index = *pt + ( *pt << 1 ) ; /* index = 3*indice TOS */
    *pt_out++ = tab[index++] ;
    *pt_out++ = tab[index++] ;
    *pt_out++ = tab[index] ;
    pt++ ;
  }
}

void pal2tc32(unsigned char *buf, unsigned long *tab, long nb, long *out)
{
  long          i ;
  long          *pt_out ;
  unsigned char *pt ;

  pt = buf ;
  pt_out = out ;
  for (i = 0; i < nb; i++)
  {
    *pt_out = tab[*pt] ;
    pt_out++ ;
    pt++ ;
  }
}

int index2truecolor(MFDB *in, INFO_IMAGE *inf, MFDB *out, GEM_WINDOW* wprog)
{
  long          larg_in, larg_out ;
  int           *pt_imgin ;
  int           i ;
  unsigned char *buffer ;

  if ( in->fd_nplanes >= 16 ) return -1 ;

  out->fd_w       = in->fd_w ;
  out->fd_h       = in->fd_h ;
  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
  out->fd_stand   = 0 ;
  out->fd_r1      = out->fd_r2 = out->fd_r3 = 0 ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if ( out->fd_addr == NULL ) return -1 ;

  buffer = (unsigned char*) Xalloc(in->fd_w) ;
  if (buffer == NULL)
  {
    Xfree(out->fd_addr) ;
    return(-1) ;
  }

  larg_in   = ((16L*in->fd_wdwidth*in->fd_nplanes)/8L) >> 1 ;
  pt_imgin  = (int*) in->fd_addr ;

  if ( out->fd_nplanes == 16 )
  {
    unsigned int  ind2tc[256] ;
    int      *pt_imgout = (int*) out->fd_addr ;

    larg_out  = ((16L*out->fd_wdwidth*out->fd_nplanes)/8L) >> 1 ;
    make_pal2tc( inf, ind2tc ) ;
    for (i = 0; i < out->fd_h; i++)
    {
      raster2ind( pt_imgin, buffer, (long)in->fd_w, in->fd_nplanes ) ;
      pal2tc( buffer, ind2tc, (long)in->fd_w, pt_imgout ) ;
      pt_imgin  += larg_in ;
      pt_imgout += larg_out ;
      (void)GWProgRange( wprog, i, out->fd_h, NULL ) ;
    }
  }
  else if ( out->fd_nplanes == 32 )
  {
    unsigned long  ind2tc[256] ;
    long     *pt_imgout = (long*) out->fd_addr ;

    larg_out  = ((16L*out->fd_wdwidth*out->fd_nplanes)/8L) >> 2 ;
    make_pal2tc32( inf, ind2tc ) ;
    for (i = 0; i < out->fd_h; i++)
    {
      raster2ind( pt_imgin, buffer, (long)in->fd_w, in->fd_nplanes ) ;
      pal2tc32( buffer, ind2tc, (long)in->fd_w, pt_imgout ) ;
      pt_imgin  += larg_in ;
      pt_imgout += larg_out ;
      (void)GWProgRange( wprog, i, out->fd_h, NULL ) ;
    }
  }
  else if ( out->fd_nplanes == 24 )
  {
    unsigned char ind2tc[256*3] ;
    unsigned char *pt_imgout = (unsigned char*) out->fd_addr ;

    larg_out  = img_size( out->fd_w, 1, out->fd_nplanes ) ;
    make_pal2tc24( inf, ind2tc ) ;
    for (i = 0; i < out->fd_h; i++)
    {
      raster2ind( pt_imgin, buffer, (long)in->fd_w, in->fd_nplanes ) ;
      pal2tc24( buffer, ind2tc, (long)in->fd_w, pt_imgout ) ;
      pt_imgin  += larg_in ;
      pt_imgout += larg_out ;
      (void)GWProgRange( wprog, i, out->fd_h, NULL ) ;
    }
  }

  Xfree( buffer ) ;

  return 0 ;
}

void GetPixel(MFDB* img, int x, int y, int* rgb)
{
  /* TRES LENT !!! */
  if ( (x >= 0) && (y >= 0) && (x < img->fd_w) && (y < img->fd_h) )
  {
    MFDB          point ;
    unsigned long *ptl ;
    unsigned long pnt ;
    unsigned int  pnti ;
    unsigned int  *pti ;
    unsigned char *ptc ;

    point.fd_nplanes = img->fd_nplanes ;
    switch( img->fd_nplanes )
    {
      case 16 :  pti  = (unsigned int*) img->fd_addr ;
                 pti += (long)y*(long)(img->fd_wdwidth << 4) ;
                 pti += x ;
                 pnti = *pti ;
                 point.fd_addr = &pnti ;
                 point.fd_w    = 1 ;
                 point.fd_h    = 1 ;
                 if ( UseStdVDI ) tc_invconvert( &point ) ;
                 rgb[0] = pnti >> 11 ;
                 rgb[0] = rgb[0] << 3 ;
                 rgb[1] = (pnti >> 6) & 0x1F ;
                 rgb[1] = rgb[1] << 3 ;
                 rgb[1] &= 0xFF ;
                 rgb[2] = pnti & 0x1F ;
                 rgb[2] = rgb[2] << 3 ;
                 break ;

      case 24 :  ptc  = (unsigned char*) img->fd_addr ;
                 ptc += (long)y*(long)(img->fd_wdwidth << 4) ;
                 ptc += x ;
                 point.fd_addr = &pnt ;
                 point.fd_w    = 1 ;
                 point.fd_h    = 1 ;
                 if ( UseStdVDI ) tc_invconvert( &point ) ;
                 rgb[0] = (int) *ptc++ ;
                 rgb[1] = (int) *ptc++ ;
                 rgb[2] = (int) *ptc ;
                 break ;

      case 32 :  ptl  = (unsigned long*) img->fd_addr ;
                 ptl += (long)y*(long)(img->fd_wdwidth << 4) ;
                 ptl += x ;
                 pnt = *ptl ;
                 point.fd_addr = &pnt ;
                 point.fd_w    = 1 ;
                 point.fd_h    = 1 ;
                 if ( UseStdVDI ) tc_invconvert( &point ) ;
                 rgb[0] = (int) (pnt >> 24) ;
                 rgb[1] = (int) (pnt >> 16) ;
                 rgb[1] &= 0xFF ;
                 rgb[2] = (int)pnt >> 8 ;
                 rgb[2] &= 0xFF ;
                 break ;
      default :  memzero( rgb, 3*sizeof(int) ) ;
                 break ;
    }
  }
  else memzero( rgb, 3*sizeof(int) ) ;
}

int find_rgb24(unsigned char *rvb24)
{
  int org = -1 ;

  LoggingDo(LL_DEBUG, "find_rgb24 on %02X%02X%02X", rvb24[0], rvb24[1], rvb24[2]) ;
  if ( rvb24[0] == 0xFF ) org = 0 ;
  else if ( rvb24[1] == 0xFF ) org = 1 ;
  else if ( rvb24[2] == 0xFF ) org = 2 ;

  return org ;
}

int find_rgb32(long rvb32)
{
  int org = -1 ;

  LoggingDo(LL_DEBUG, "find_rgb32 on %08lX", rvb32) ;
  if ( rvb32 == 0xFF000000L ) org = 0 ;
  else if ( rvb32 == 0x00FF0000L ) org = 1 ;
  else if ( rvb32 == 0x0000FF00L ) org = 2 ;
  else if ( rvb32 == 0x000000FFL ) org = 3 ;

  return org ;
}

void InitRGB8BPM(void)
{
  unsigned char* p8 ;
  int*           p16 ;
  long           j ;

  for ( p8 = RGBPMToRGB8B, j = 0; j <= 1000L*256L; p8++, j += 255L )
  {
    *p8 = (unsigned char) ( j/1000L ) ;
    if ( (j % 1000) > 499 ) (*p8)++ ;
  }

  for ( p16 = RGB8BToRGBPM, j = 0; j < 256L*1000L; p16++, j += 1000L )
  {
    *p16 = (int) ( j/255L ) ;
    if ( (j % 255) > 127 ) (*p16)++ ;
  }
}

int FindScreenOrg(RVB_ORG* rvb_org)
{
  RVB_ORG* def_rvborg ;
  MFDB     mfdb ;
  int      xy[8] ;
  int      red[]   = { 1000, 0, 0 } ;
  int      green[] = { 0, 1000, 0 } ;
  int      blue[]  = { 0, 0, 1000 } ;
  int      white[] = { 1000, 1000, 1000 } ;
  int      black[] = { 0, 0, 0 } ;
  int      found = 0 ;
  int      x, y ;
#define PLOT_INDEX_COLOR 16

  InitRGB8BPM() ;

  memzero( rvb_org, sizeof(RVB_ORG) ) ;
  ZeroMFDB( &mfdb ) ;
  mfdb.fd_w       = 16 ;
  mfdb.fd_h       = 2 ;
  mfdb.fd_nplanes = screen.fd_nplanes ;
  mfdb.fd_wdwidth = 1 ;
  x               = ( Xmax >> 1 ) & 0xFFF0 ;
  y               = Ymax >> 1 ;

  vswr_mode( handle, MD_REPLACE ) ;
  vsm_color( handle, PLOT_INDEX_COLOR ) ;
  vsm_type ( handle, 1 ) ;
  vsm_height( handle, 1 ) ;
  UseStdVDI = 0 ;
  xy[0] = x ; xy[1] = y ;
  xy[2] = x + 15 ;
  xy[3] = y + 1 ;
  xy[4] = xy[5] = 0 ;
  xy[6] = 15 ; /* 1 should be enough but Radeon driver is buggy if set to 1, thanks to Guillaume Tello, see https://groups.google.com/g/atari-mon-amour/c/ckRQcf7tK28 */
  xy[7] = 1 ;  /* Should be 0, but who cares taking risk for 16 longs... */
  (void)sform_dial( FMD_START, x, y, 16, 16 ) ;
  wind_update( BEG_UPDATE ) ;
  if ( Truecolor )
  {
    long tested_pixel[2*16 + 16] ;   /* Max 2 lines of 16 pixels TC32 + some buffer in case video driver copies too much data */
    int  motif = 0x3F ;

    memzero( tested_pixel, sizeof(tested_pixel) ) ;
    mfdb.fd_addr = tested_pixel ;
    switch( screen.fd_nplanes )
    {
      case 16 : vs_color( handle, PLOT_INDEX_COLOR, white ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                if ( (tested_pixel[0] & 0xFFFF0000L) != 0xFFFF0000L )
                {
                  rvb_org->Is15Bits = 1 ; 
                  motif = 0x1F ;
                }

                vs_color( handle, PLOT_INDEX_COLOR, red ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RRed = GetRolw( (int) (tested_pixel[0] >> 16), 0x1F ) ;

                vs_color( handle, PLOT_INDEX_COLOR, green ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RGreen = GetRolw( (int) (tested_pixel[0] >> 16), motif ) ;

                vs_color( handle, PLOT_INDEX_COLOR, blue ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RBlue = GetRolw( (int) (tested_pixel[0] >> 16), 0x1F ) ;
                def_rvborg = &FRVBOrg16 ;
                if ( rvb_org->Is15Bits == 0 ) def_rvborg->RGreen-- ;
                break ;

      case 24 :
                vs_color( handle, PLOT_INDEX_COLOR, red ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RRed = find_rgb24( (unsigned char*) mfdb.fd_addr ) ;

                vs_color( handle, PLOT_INDEX_COLOR, green ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RGreen = find_rgb24( (unsigned char*) mfdb.fd_addr ) ;

                vs_color( handle, PLOT_INDEX_COLOR, blue ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RBlue = find_rgb24( (unsigned char*) mfdb.fd_addr ) ;
                def_rvborg = &FRVBOrg24 ;
                break ;

      case 32 :
                vs_color( handle, PLOT_INDEX_COLOR, red ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RRed = find_rgb32( tested_pixel[0] ) ;

                vs_color( handle, PLOT_INDEX_COLOR, green ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RGreen = find_rgb32( tested_pixel[0] ) ;

                vs_color( handle, PLOT_INDEX_COLOR, blue ) ;
                pset( x, y ) ;
                vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
                rvb_org->RBlue = find_rgb32( tested_pixel[0] ) ;
                def_rvborg = &FRVBOrg32 ;
                break ;
    }
    found = ( (rvb_org->RRed >= 0) && (rvb_org->RGreen >= 0) && (rvb_org->RBlue >= 0) ) ;
    if ( !found )
    {
      LoggingDo(LL_WARNING, "Unable to detect screen organization; assuming ARGB" ) ;
      rvb_org->RRed     = 1 ;
      rvb_org->RGreen   = 2 ;
      rvb_org->RBlue    = 3 ;
      rvb_org->Is15Bits = 0 ; 
    }
    if ( (rvb_org->RRed != def_rvborg->RRed) ||
         (rvb_org->RGreen != def_rvborg->RGreen) ||
         (rvb_org->RBlue != def_rvborg->RBlue) 
       ) UseStdVDI = 1 ;
    vs_color( handle, 1, black ) ;
    LoggingDo( LL_INFO, "FindScreenOrg(TC%d): UseStdVDI=%d, This machine org.: (%d %d %d) Default org.: (%d %d %d) 32K:%d", screen.fd_nplanes, UseStdVDI,
               rvb_org->RRed, rvb_org->RGreen, rvb_org->RBlue,
               def_rvborg->RRed, def_rvborg->RGreen, def_rvborg->RBlue, rvb_org->Is15Bits ) ;
  }
  else
  {
    unsigned char* tos2vdi = get_pttos2vdi( screen.fd_nplanes ) ;
    char           test_bit_plane[50] ;

    if ( tos2vdi )
    {
      mfdb.fd_addr = test_bit_plane ;
      vsm_color( handle, tos2vdi[1] ) ;
      pset( x, y ) ;
      vro_cpyfm( handle, S_ONLY, xy, &screen, &mfdb ) ;
      if ( (test_bit_plane[0] & 0x80) != 0x80 ) UseStdVDI = 1 ;
      found = 1 ;
    }
    LoggingDo(LL_INFO, "FindScreenOrg(bitplanes#%d): StdVDI=%d", screen.fd_nplanes, UseStdVDI) ;
  }

  (void)sform_dial( FMD_FINISH, x, y, 16, 16 ) ;
  wind_update( END_UPDATE ) ;

  return found ;
}

void make_greyimage(INFO_IMAGE* inf, short no_std_vdi)
{
  MFDB*    img = &inf->mfdb ; 
  long     nb_pts ;    
  long     i ;
  int      *pt ;
  int      gris ;
  int      ind ;
  unsigned char *vdi2tos ;

  nb_pts = align16( img->fd_w ) ;
  nb_pts = nb_pts*(long)img->fd_h ;
  if ( (img->fd_nplanes <= 8) && inf->palette )
  {
    vdi2tos = get_ptvdi2tos( img->fd_nplanes ) ;
    pt = inf->palette ;
    for ( i = 0; i < inf->nb_cpal; i++ )
    {
      ind     = 3*vdi2tos[i] ;
      gris    = pt[ind] ;
      gris   += pt[1+ind] ;
      gris   += pt[2+ind] ;
      gris    = gris/3 ;
      pt[ind] = pt[1+ind] = pt[2+ind] = gris ;
    }
  }
  else
  {
    RGB rgb ;

    if ( !no_std_vdi ) tc_invconvert( img ) ;

    if ( img->fd_nplanes == 16 )
    {
      unsigned int *ptu, red, green, blue, ugris, val ;

      ptu = (unsigned int*) img->fd_addr ;
      for ( i = 0; i < nb_pts; i++ )
      {
        val    = *ptu ;
        red    = ( val & 0x01F ) << 3 ;
        green  = ( val >> 3 ) & 0xFB ;
        blue   = ( val >> 8 ) & 0xF8 ;
        ugris  = ( red + green + blue ) / 3 ;
/*        ubr    = ( ugris >> 1 ) ;*/
        rgb.Red   = ugris ;
        rgb.Green = ugris ;
        rgb.Blue  = ugris ;
        *ptu++    = RVB16( &rgb ) ;
      }
    }
    else if ( img->fd_nplanes == 24 )
    {
      unsigned char *ptu ;
      unsigned int  red, green, blue, ugris ;

      ptu = (unsigned char *)img->fd_addr ;
      for ( i = 0; i < nb_pts; i++ )
      {
        red    = (unsigned int) (*ptu++) ;
        green  = (unsigned int) (*ptu++) ;
        blue   = (unsigned int) (*ptu++) ;
        ugris  = ( red + green + blue ) / 3 ;
        *ptu-- = ugris ;
        *ptu-- = ugris ;
        *ptu-- = ugris ;
        ptu   += 3 ;
      }
    }
    else if ( img->fd_nplanes == 32 )
    {
      unsigned long *ptu, val ;
      unsigned int  red, green, blue, ugris ;

      ptu = (unsigned long *)img->fd_addr ;
      for ( i = 0; i < nb_pts; i++ )
      {
        val    = *ptu ;
        val  >>= 8 ;
        blue   = (unsigned int) (val & 0xFF) ;
        val  >>= 8 ;
        green  = (unsigned int) (val & 0xFF) ;
        val  >>= 8 ;
        red    = (unsigned int) (val & 0xFF) ;
        ugris  = ( red + green + blue ) / 3 ;
        rgb.Red = rgb.Green = rgb.Blue = ugris ;
        *ptu++ = RVB32( &rgb ) ;
      }
    }
    if ( !no_std_vdi ) tc_convert( img ) ;
  }
}

void init_r2i(void)
{
  int   i, mask ;
  char* pt_bitarray = r2i_bitarray ;

  for ( i = 0; i < 256; i++ )
  {
    for ( mask = 0x80; mask > 0; mask >>= 1, pt_bitarray++ )
      if ( i & mask ) *pt_bitarray = 1 ;
  }
}

void rasterop_init(void)
{
  init_r2i() ;
  
/* Test de perfs
{
  void raster2ind_old(int *pt_raster, unsigned char *out, long nb_pts, int nplans) ;

  long nb_pts = 65535L * 2L ;
  int  nb_planes = 8 ;
  clock_t t0 ;
  clock_t times[10] ; 
  int           *pti = (int *) Xalloc( 2L * nb_pts ) ;
  unsigned char *ptc = (unsigned char *) Xalloc( nb_pts ) ;
  
  memset( pti, 0, 2L * nb_pts ) ;
  t0 = clock() ;
  raster2ind_old( pti, ptc, nb_pts, nb_planes ) ;
  times[0] = clock() - t0 ;
  t0 = clock() ;
  raster2ind( pti, ptc, nb_pts, nb_planes ) ;
  times[1] = clock() - t0 ;
  
  memset( pti, 0xFF, 2L * nb_pts ) ;
  t0 = clock() ;
  raster2ind_old( pti, ptc, nb_pts, nb_planes ) ;
  times[2] = clock() - t0 ;
  t0 = clock() ;
  raster2ind( pti, ptc, nb_pts, nb_planes ) ;
  times[3] = clock() - t0 ;

  memset( pti, 0xA3, 2L * nb_pts ) ;
  t0 = clock() ;
  raster2ind_old( pti, ptc, nb_pts, nb_planes ) ;
  times[4] = clock() - t0 ;
  t0 = clock() ;
  raster2ind( pti, ptc, nb_pts, nb_planes ) ;
  times[5] = clock() - t0 ;

  Xfree( ptc ) ;
  Xfree( pti ) ;
}*/
}

void rasterop_exit(void)
{
  terminate_fztab() ;
}


void RasterResetUnusedData(MFDB* img)
{
  int dw = 16 - (img->fd_w & 0x0F) ;

  LoggingDo(LL_DEBUG, "RasterResetUnusedData: w=%d, h=%d, nplanes=%d", img->fd_w, img->fd_h, img->fd_nplanes) ;
  if ( dw != 16 )
  {
    int  l, nb ;
    long lo ;

    if ( img->fd_nplanes <= 8 )
    {
      unsigned int  motif  = 0 ;
      unsigned int  mask = 0x8000 ;
      unsigned int  i, *pt ;

      for ( i = 0 ; i < 16-dw; i++, mask >>= 1 ) motif |= mask ;
      /* Efface les parasites avant de passer en largeur multiple de 16 */
      pt = (unsigned int *)img->fd_addr + (img->fd_wdwidth-1)*img->fd_nplanes ;
      lo = img_size(img->fd_w, 1, img->fd_nplanes) >> 1 ; /* In 16bit words */
      for ( l = 0; l < img->fd_h ; l++, pt += lo )
        for ( nb = 0; nb < img->fd_nplanes; nb++ ) pt[nb] &= motif ;
    }
    else if ( img->fd_nplanes == 16 )
    {
      int* pt ;

      /* Efface les parasites avant de passer en largeur multiple de 16 */
      pt = (int *)img->fd_addr + img->fd_w ;
      nb = dw * 2 ; /* 1 pixel = 2 octets */
      lo = img->fd_wdwidth*16 ;
      for ( l = 0; l < img->fd_h ; l++ )
      {
        memset( pt, 0xFF, nb ) ;
        pt  += lo ;
      }
    }
    else if ( img->fd_nplanes == 24 )
    {
      unsigned char* pt ;

      /* Efface les parasites avant de passer en largeur multiple de 16 */
      pt = (unsigned char *)img->fd_addr + 3*img->fd_w ;
      nb = 3 * dw ; /* 1 pixel = 3 octets */
      lo = ( img->fd_wdwidth << 4 ) * 3 ;
      for ( l = 0; l < img->fd_h ; l++ )
      {
        memset( pt, 0xFF, nb ) ;
        pt  += lo ;
      }
    }
    else if ( img->fd_nplanes == 32 )
    {
      long* pt ;

      /* Efface les parasites avant de passer en largeur multiple de 16 */
      pt = (long *)img->fd_addr + img->fd_w ;
      nb = 4 * dw ;
      lo = img->fd_wdwidth*16 ;
      for ( l = 0; l < img->fd_h ; l++ )
      {
        memset( pt, 0xFF, nb ) ;
        pt  += lo ;
      }
    }
    img->fd_w = align16( img->fd_w ) ;
  }
}

/* A bit similar to make_pal2tc... but with RGB values on a byte */
void make_rgbpal2tc(unsigned char* rgbapal, int nb_cpal, void* tctab, int nplanes)
{
  unsigned char mono_palette[2*4] ;
  int nc = 4*nb_cpal ; /* Yes, 4 and i++ because of 16bit alignement */
  int i ;

  if ( nb_cpal == 0 )
  {
    /* For monochrome images, there is no palette attached */
    /* But we need one to output to a True Color MFDB      */
    rgbapal  = mono_palette ;
    /* nb_cpal = 2 ; */ /* Does caller need this? Hope not */
    rgbapal[0] = rgbapal[1] = rgbapal[2] = 255 ;
    rgbapal[3] = 0 ;
    rgbapal[4] = rgbapal[5] = rgbapal[6] = 0 ;
    rgbapal[7] = 0 ;
  }

  if ( nplanes == 16 )
  {
    unsigned short* pt = (unsigned short*) tctab ;
    unsigned short  r, g, b ;

    for ( i = 0; i < nc; i++)
    {
      r     = rgbapal[i++] >> 3 ;
      g     = rgbapal[i++] >> 3 ;
      b     = rgbapal[i++] >> 3 ;
      *pt++ = (r << 11) + (g << 6) + b ;
    }
  }
  else if ( nplanes == 24 ) 
  {
    unsigned char* pt = (unsigned char*) tctab ;

    for ( i = 0; i < nc; i++)
    {
      *pt++ = rgbapal[i++] ;
      *pt++ = rgbapal[i++] ;
      *pt++ = rgbapal[i++] ;
    }
  }
  else if ( nplanes == 32 ) 
  {
    unsigned long* pt = (unsigned long*) tctab ;
    unsigned long  r, g, b ;

    for ( i = 0; i < nc; i++)
    {
      r     = rgbapal[i++] ;
      g     = rgbapal[i++] ;
      b     = rgbapal[i++] ;
      *pt++ = (r << 24) + (g << 16) + (b<<8) ;
    }
  }
}

/* Convert RGB (0...7) to RGB (0...1000)          */
/* In such a way that rgbm2rgb3b(rgb3b2rgbm(x))=x */
short rgb3b2rgbm(short rgb3b)
{
  short rgbm ;
  short r ;

  rgb3b &= 0x07 ; /* Make sure we are on 3bits */
  rgbm   = rgb3b * 1000 ;
  r      = rgbm % 7 ;
  rgbm  /= 7 ;
  if ( r > 3 ) rgbm++ ;

  return rgbm ;
}

/* Convert RGB (0...1000) to RGB (0...7)          */
/* In such a way that rgbm2rgb3b(rgb3b2rgbm(x))=x */
short rgbm2rgb3b(short rgbm)
{
  short rgb3b;
  short r;

  rgb3b  = rgbm * 7 ;
  r      = rgb3b % 1000 ;
  rgb3b /= 1000 ;
  if ( r > 500 ) rgb3b++ ;

  return rgb3b ;
}

void ZeroMFDB(MFDB* mfdb)
{
  memzero( mfdb, sizeof(MFDB) ) ;
}

void CopyMFDB(MFDB* out, MFDB* in)
{
  memcpy( out, in, sizeof(MFDB) ) ;
}

void tc32totc16grey(MFDB* in, MFDB* out)
{
  /* TC32 RGB0 --> TC16 Falcon format */
  RGB             rgb ;
  unsigned char   grey3[3*256] ;
  unsigned char*  pgrey3 = grey3 ;
  unsigned char*  rgb32 ;
  unsigned short* rgb16 ;
  unsigned long   n, nb_pixels ;
  unsigned short  igrey ;
  short           i, j ;

  if ( (in->fd_nplanes != 32) || (out->fd_nplanes != 16) ) return ;
  if ( in->fd_wdwidth != out->fd_wdwidth ) return ;
  if ( in->fd_h != out->fd_h ) return ;

  nb_pixels  = in->fd_h ;
  nb_pixels *= align16(in->fd_w) ;
  /* Initialize array of r+g+b --> grey value */
  for ( i = 0, j = 0; i < 3*256; i += 3, j++ )
  {
    *pgrey3++ = j ;
    *pgrey3++ = j ;
    *pgrey3++ = j ;
  }

  rgb32 = in->fd_addr ;
  rgb16 = out->fd_addr ;
  for ( n = 0; n < nb_pixels; n++ )
  {
    igrey    = rgb32[0] ;
    igrey   += rgb32[1] ;
    igrey   += rgb32[2] ;
    rgb.Red  = rgb.Green = rgb.Blue = grey3[igrey] ;
    rgb32   += 4 ;
    *rgb16++ = RVB16( &rgb ) ;
  }
}

short tc16totc32(MFDB*in, MFDB* out)
{
  /* TC16 Falcon --> TC32 RGB0 */
  unsigned short* rgb16 ;
  unsigned short  component ;
  unsigned long   n, nb_pixels ;
  unsigned char*  rgb32 ;

  if ( (in->fd_nplanes != 16) || (out->fd_nplanes != 32) ) return -1 ;
  out->fd_addr = img_alloc( in->fd_w, in->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL ) return -3 ;

  nb_pixels  = in->fd_h ;
  nb_pixels *= align16(in->fd_w) ;

  out->fd_w       = in->fd_w ;
  out->fd_h       = in->fd_h ;
  out->fd_wdwidth = in->fd_wdwidth ;
  rgb16           = in->fd_addr ;
  rgb32           = out->fd_addr ;
  for ( n = 0; n < nb_pixels; n++ )
  {
    component = *rgb16++ ;
    *rgb32++ = (component & 0x1F) << 3 ; /* Red */
    component >>= 6 ;
    *rgb32++ = (component & 0x1F) << 3 ; /* Green */
    component >>= 5 ;
    *rgb32++ = component << 3 ;          /* Blue */
    *rgb32++ = 0 ;                       /* Alpha */
  }

  return 0 ;
}
