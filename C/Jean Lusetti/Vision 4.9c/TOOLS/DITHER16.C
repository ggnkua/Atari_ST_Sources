/* DITHER16.C:                                             */
/* Dithers a 16bit image Falcon format to a 16 color image */
/* Using a given palette (GEM system palette typically)    */
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\logging.h"

/* From https://en.wikipedia.org/wiki/Ordered_dithering */
#define N(x) ((short)((31.0/4.0)*((x/16.0)-0.5)))
unsigned short threshold_map4[4][4] =  {
                                         N(0),  N(8),  N(2),  N(10),
                                         N(12), N(4),  N(14), N(6),
                                         N(3),  N(11), N(1),  N(9),
                                         N(15), N(7),  N(13), N(5)
                                       } ;


static short is_grey(unsigned short* pal_rgb)
{
  return( (*pal_rgb == *(pal_rgb+1)) && (*pal_rgb == *(pal_rgb+2)) ) ;
}
/*
static unsigned short CLIEnorm(short n, float r)
{
  return (unsigned short)(0.5+n*n*r) ;
}
*/
static unsigned char get_nearest_index(unsigned short rgb16, unsigned short* palette16c)
{
  unsigned short*       p ;
  unsigned short        i, dmin, dmin2, r, g, b, d ;
  unsigned char         index = 0 ;
  unsigned char         index2 = 0 ;
  static unsigned short squares5b[64] ;

  if ( squares5b[0] == 0 )
  {
    short n ;

    /* Pre-compute squares of [-31;31] */
    for ( n = -31; n < 32; n++ )
      squares5b[31+n] = n*n ;
  }

  dmin = dmin2 = 0xFFFF ;
  b    = rgb16 & 0x1F ;
  rgb16 >>= 6 ;
  g    = rgb16 & 0x1F ;
  r    = rgb16 >> 5 ;

  for ( i = 0, p = palette16c; i < 16; i++ )
  {
    d  = squares5b[31+r-(*p++)] ;
    d += squares5b[31+g-(*p++)] ;
    d += squares5b[31+b-(*p++)] ;

    if ( d < dmin )
    {
      index2 = index ;
      index  = i ;
      dmin2  = dmin ;
      dmin   = d ;
      if ( dmin == 0 ) break ; /* Exact match */
    }
  }

  /* Pick previous nearest color if first one is not exact and grey level */
  if ( dmin && (index != index2) && (dmin2-dmin < 10000) && is_grey( &palette16c[3*index] ) && !is_grey( &palette16c[3*index2] ) )
  {
/*    LoggingDo(LL_INFO,"get_nearest_index: changing index %d to %d for Red=%d, Green=%d, Blue=%d", (short)index, (short)index2, r, g, b ) ;
    LoggingDo(LL_INFO,"[%d,%d,%d]-->[%d,%d,%d]", palette16c[3*index], palette16c[3*index+1], palette16c[3*index+2], palette16c[3*index2], palette16c[3*index2+1], palette16c[3*index2+2] ) ;*/
    index = index2 ;
  }

  return index ;
}

/* Reeturns a table of nearest color index for a given RGB16 color */
static unsigned char* get_nearest_palette_color_map(int* vdi_palette16c)
{
  unsigned char* tab ;

  tab = (unsigned char*) Xalloc( 65536L ) ; /* All possible 16 bit values */
  if ( tab )
  {
    FILE* stream ;
    char* name = "D15B.DAT" ; /* 15 = 3x5 bpp */
    char  must_compute = 1 ;

    stream = fopen( name, "rb" ) ;
    if ( stream )
    {
      LoggingDo(LL_INFO, "reading color map from %s", name) ;
      if ( fread( tab, 65536L, 1, stream ) == 1 ) must_compute = 0 ;
      fclose( stream ) ;
    }
    if ( must_compute )
    {
      unsigned short pal5b[1001] ;
      unsigned char* t = tab ;
      clock_t        t0 ;
      short          i ;
      unsigned short rgb16 = 0 ;

      LoggingDo(LL_INFO, "Computing color map...") ;
      t0 = clock() ;

      for ( i = 0; i <= 1000; i++ )
      {
        /* 0..31 --> 0...1000 */
        pal5b[i] = (short) (0.5+(float)(vdi_palette16c[i]*31.0)/1000.0) ;
      }

      /* Pre-compute mapping of any 16bit TC16 color to palette index */
      for ( t = tab ; t < tab + 65536UL; rgb16++ )
        *t++ = get_nearest_index( rgb16, pal5b ) ;

      LoggingDo(LL_INFO, "Computation took %ldms", (1000L*(clock()-t0))/CLK_TCK) ;
      stream = fopen( name, "wb" ) ;
      if ( stream )
      {
        fwrite( tab, 65536L, 1, stream ) ;
        fclose( stream ) ;
      }
    }
  }

  return tab ;
}

int _dither16(short alg_msize, MFDB* img16, INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  unsigned char*  npc ;
  unsigned char*  indexes ;
  unsigned short* prgb16 ;
  short*          threshold_line ;
  short           x, y, misize ;

  inf_out->nb_cpal = 16 ;
  inf_out->palette = Xcalloc( inf_out->nb_cpal, 3*2 ) ;
  if ( inf_out->palette == NULL ) return EIMG_NOMEMORY ;

  memcpy( inf_out->palette, vdi_sys_colors, 16*3*2 ) ;
  CopyMFDB( &inf_out->mfdb, img16 ) ;
  inf_out->mfdb.fd_nplanes = 4 ;
  inf_out->mfdb.fd_addr    = img_alloc( inf_out->mfdb.fd_w, inf_out->mfdb.fd_h, inf_out->mfdb.fd_nplanes ) ;
  if ( inf_out->mfdb.fd_addr == NULL )
  {
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    return EIMG_NOMEMORY ;
  }

  npc = get_nearest_palette_color_map( inf_out->palette ) ;
  if ( npc == NULL )
  {
    Xfree( inf_out->mfdb.fd_addr ) ; inf_out->mfdb.fd_addr = NULL ;
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    return EIMG_NOMEMORY ;
  }

  indexes = (unsigned char*) Xcalloc( ALIGN16(img16->fd_w), sizeof(unsigned char) ) ;
  if ( indexes == NULL )
  {
    Xfree( npc ) ;
    Xfree( inf_out->mfdb.fd_addr ) ; inf_out->mfdb.fd_addr = NULL ;
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    return EIMG_NOMEMORY ;
  }
  i2r_init( &inf_out->mfdb, inf_out->mfdb.fd_w, 0 ) ;
  i2r_data = indexes ;
  i2r_nb   = inf_out->mfdb.fd_w ;

  prgb16 = img16->fd_addr ;
  for ( y = 0; y < inf_out->mfdb.fd_h; y++ )
  {
    /* Get pointer to current line to avoid computing offsets on 2 dimmensional array (multiplies) in every iteration of next loop */
    threshold_line = (short*) &threshold_map4[0][y & 0x03] ;
    for ( x = 0; x < inf_out->mfdb.fd_w; x++, prgb16++ )
    {
      if ( alg_msize == 0 ) indexes[x] = npc[*prgb16] ;
      else
      {
        /* Assuming that if  alg_msize is not zero, we want a 4x4 matrix */
        short          r, g, b ;
        short          delta = threshold_line[x & 0x03] ;
        unsigned short old_rgb16, new_rgb16 ;

        old_rgb16 = *prgb16 ;
        r = (old_rgb16 >> 11) + delta ;          /* Red */
        if ( r < 0 )       r = 0 ;
        else if ( r > 31 ) r = 31 ;
        g = ((old_rgb16 >> 6) & 0x1F) + delta ;  /* Green */
        if ( g < 0 )       g = 0 ;
        else if ( g > 31 ) g = 31 ;
        b = (old_rgb16 & 0x1F) + delta ;         /* Blue */
        if ( b < 0 )       b = 0 ;
        else if ( b > 31 ) b = 31 ;
        new_rgb16  = (r<<11) + (g<<6) + b ;
        indexes[x] = npc[new_rgb16] ;
      }
    }
    ind2raster() ;
    (void)GWProgRange( wprog, y, inf_out->mfdb.fd_h, NULL ) ;
  }

  Xfree( indexes ) ;
  Xfree( npc ) ;

  return EIMG_SUCCESS ;
}

int dither16(short alg_msize, INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog)
{
  MFDB            in, ltmp16 ;
  unsigned char*  src ;
  unsigned char*  npc ;
  unsigned char*  indexes ;
  unsigned short* prgb16 ;
  unsigned long   lsrc_line ;
  short*          threshold_line ;
  short           x, y, misize ;
  int             err = EIMG_SUCCESS ;

  CopyMFDB( &in, &inf_in->mfdb ) ;
  if ( (in.fd_nplanes != 8) && (in.fd_nplanes != 16) && (in.fd_nplanes != 24) && (in.fd_nplanes != 32) ) return EIMG_DATAINCONSISTENT ;

  inf_out->nb_cpal = 16 ;
  inf_out->palette = Xcalloc( inf_out->nb_cpal, 3*2 ) ;
  if ( inf_out->palette == NULL ) return EIMG_NOMEMORY ;

  memcpy( inf_out->palette, vdi_sys_colors, 16*3*2 ) ;
  CopyMFDB( &inf_out->mfdb, &in ) ;
  inf_out->mfdb.fd_nplanes = 4 ;
  inf_out->mfdb.fd_addr    = img_alloc( inf_out->mfdb.fd_w, inf_out->mfdb.fd_h, inf_out->mfdb.fd_nplanes ) ;
  if ( inf_out->mfdb.fd_addr == NULL )
  {
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    return EIMG_NOMEMORY ;
  }

  npc = get_nearest_palette_color_map( inf_out->palette ) ;
  if ( npc == NULL )
  {
    Xfree( inf_out->mfdb.fd_addr ) ; inf_out->mfdb.fd_addr = NULL ;
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    return EIMG_NOMEMORY ;
  }

  ZeroMFDB( &ltmp16 ) ;
  ltmp16.fd_w       = inf_out->mfdb.fd_w ;
  ltmp16.fd_h       = 1 ;
  ltmp16.fd_nplanes = 16 ;
  indexes           = (unsigned char*) Xcalloc( ALIGN16(inf_out->mfdb.fd_w), sizeof(unsigned char) ) ;
  if ( indexes == NULL )
  {
    if ( indexes ) Xfree( indexes ) ;
    Xfree( npc ) ;
    Xfree( inf_out->mfdb.fd_addr ) ; inf_out->mfdb.fd_addr = NULL ;
    Xfree( inf_out->palette ) ; inf_out->palette = NULL ;
    return EIMG_NOMEMORY ;
  }
  i2r_init( &inf_out->mfdb, inf_out->mfdb.fd_w, 0 ) ;
  i2r_data = indexes ;
  i2r_nb   = inf_out->mfdb.fd_w ;

  src       = in.fd_addr ;
  lsrc_line = img_size( in.fd_w, 1, in.fd_nplanes ) ;
  in.fd_h   = 1 ;
  for ( y = 0; !err && (y < inf_out->mfdb.fd_h); y++, src += lsrc_line )
  {
    /* Convert line to 16bit True Color */
    in.fd_addr = src ;
    switch( in.fd_nplanes )
    {
      case  8: ltmp16.fd_nplanes = 16 ;
               err = index2truecolor( &in, inf_in, &ltmp16, NULL ) ;
               break ;

      case 16: CopyMFDB( &ltmp16, &in ) ;
               break ;

      case 24: err = tc24totc16( &in, &ltmp16 ) ;
               break ;

      case 32: err = tc32totc16( &in, &ltmp16 ) ;
               break ;

      /* No default as inf_in->mfdb.fd_nplanes has already been checked */
    }

    prgb16 = ltmp16.fd_addr ;
    /* Get pointer to current line to avoid computing offsets on 2 dimmensional array (multiplies) in every iteration of next loop */
    threshold_line = (short*) &threshold_map4[0][y & 0x03] ;
    for ( x = 0; x < inf_out->mfdb.fd_w; x++, prgb16++ )
    {
      if ( alg_msize == 0 ) indexes[x] = npc[*prgb16] ;
      else
      {
        /* Assuming thazt if  alg_msize is not zero, we want a 4x4 matrix */
        short          r, g, b ;
        short          delta = threshold_line[x & 0x03] ;
        unsigned short old_rgb16, new_rgb16 ;

        old_rgb16 = *prgb16 ;
        r = (old_rgb16 >> 11) + delta ;          /* Red */
        if ( r < 0 )       r = 0 ;
        else if ( r > 31 ) r = 31 ;
        g = ((old_rgb16 >> 6) & 0x1F) + delta ;  /* Green */
        if ( g < 0 )       g = 0 ;
        else if ( g > 31 ) g = 31 ;
        b = (old_rgb16 & 0x1F) + delta ;         /* Blue */
        if ( b < 0 )       b = 0 ;
        else if ( b > 31 ) b = 31 ;
        new_rgb16  = (r<<11) + (g<<6) + b ;
        indexes[x] = npc[new_rgb16] ;
      }
    }
    if ( in.fd_nplanes != 16 ) Xfree( ltmp16.fd_addr ) ; /* If 16 planes there is no allocation, just CopyMFDB */
    ind2raster() ;
    (void)GWProgRange( wprog, y, inf_out->mfdb.fd_h, NULL ) ;
  }

  Xfree( indexes ) ;
  Xfree( npc ) ;

  if ( err != EIMG_SUCCESS ) err = EIMG_NOMEMORY ; /* index2truecolor, tc24totc16, tc32totc16 don't return EIMG_xxxx */

  return err ;
}
