#include <vdi.h>
#include <stdlib.h>
#include <string.h>

#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\fastzoom.h"
#include "..\tools\image_io.h"
#include "..\tools\scalemem.h"
#include "..\tools\logging.h"


typedef struct
{
  MFDB*      in ;
  MFDB*      out ;
  long*      src_addr_line ;
  short*     xoffsets ;
  short*     yoffsets ;
  short      flags ;
  char*      indexes_in ;
  char*      indexes_out ;
  long       lout ;
  long       increment ;
  long       srcw16 ;
  long       dstw16 ;
  int        nplanes ;
  GEM_WINDOW *wprog ;
  void       *progress_function ;
  int        xoffset_jump ;  /* Pour sraster_zoom */
  int        xoffset_scale ; /* Pour sraster_zoom */
  long       prog_increment ;
  long       prog ;
}
RASTER_ZOOM ;
#define PROG_FREQ  32L

void sraster_zoom(RASTER_ZOOM* rz) ; /* Dans RZOOM.S */


int can_use_fast_zoom(MFDB *in, MFDB *out, FZOOM_DATA *fzoom_data)
{
  if (
       ( ( out->fd_w == (in->fd_w << 1) ) && ( ( out->fd_h == (in->fd_h << 1) ) ) ) ||
       ( ( out->fd_w == (in->fd_w << 2) ) && ( ( out->fd_h == (in->fd_h << 2) ) ) ) ||
       ( ( out->fd_w == (in->fd_w << 3) ) && ( ( out->fd_h == (in->fd_h << 3) ) ) ) ||
       ( ( out->fd_w == (in->fd_w << 4) ) && ( ( out->fd_h == (in->fd_h << 4) ) ) )
     )
  {
    fzoom_data->zoom = out->fd_w / in->fd_w ;
    if ( out->fd_wdwidth == fzoom_data->zoom * in->fd_wdwidth )
    {
      fzoom_data->src     = in ;
      fzoom_data->dst     = out ;
      fzoom_data->std_src = NULL ;
      fzoom_data->std_dst = NULL ;
      init_fztab( fzoom_data->zoom ) ;

      return( 1 ) ;
    }
  }

  return( 0 ) ;
}

int RasterZoom(MFDB *in, MFDB *out, GEM_WINDOW *wprog)
{
  FZOOM_DATA  fzoom_data ;
  RASTER_ZOOM rz ;
  long*       addr ;
  short*      offsets, *off ;
  short*      xoffsets, *yoffsets ;
  long        size, adr, lo_line ;
  int         nmax = 8192 ; /* Our routine can't go further */
  short       i ;
  char        local_alloc = 0 ;
  char        xoffset_precalc = 1 ;

  out->fd_nplanes = in->fd_nplanes ;
  out->fd_stand   = in->fd_stand ;
  if ( out->fd_addr == NULL )
  {
    if ( ( in->fd_w == out->fd_w ) && ( in->fd_h == out->fd_h ) ) return( raster_duplicate( in, out ) ) ;
    out->fd_addr    = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
    out->fd_wdwidth = out->fd_w / 16 ;
    if ( out->fd_w % 16 ) out->fd_wdwidth++ ;
    local_alloc = 1 ;
  }
  if ( out->fd_addr == NULL ) return( -3 ) ;

  if ( can_use_fast_zoom( in, out, &fzoom_data ) )
    return( FastZoom( &fzoom_data ) ) ;

  LoggingDo(LL_DEBUG, "RasterZoom: UseStdVDI=%d", UseStdVDI) ;
  rz.flags = 0 ;
  if ( UseStdVDI && ( in->fd_nplanes <= 8 ) ) rz.flags |= 0x01 ;
  if ( MachineInfo.cpu >= 30L ) rz.flags |= 0x02 ;

  if ( (in->fd_w > nmax) || (in->fd_h > nmax) || (out->fd_w > nmax) || (out->fd_h > nmax) )
  {
    if ( local_alloc ) Xfree( out->fd_addr ) ;
    out->fd_addr = NULL ;
    LoggingDo(LL_ERROR, "RasterZoom: can't deal with images w,h > %d", nmax) ;
    return-2 ;
  }

  size  = (long) (in->fd_w) ;
  size += (long) (out->fd_w) ;
  size += (long) (in->fd_h) ;
  size += (long) (out->fd_h) ;
  size *= sizeof(short) ;
  size += (long) (in->fd_h) * sizeof(long) ;
  if ( in->fd_nplanes <= 8 )
  {
    long increment ;
    long src_width = (long) in->fd_w ;

    rz.srcw16    = ALIGN16( in->fd_w ) ;
    size        += rz.srcw16 ;
    rz.dstw16    = ALIGN16( out->fd_w ) ;
    size        += rz.dstw16 ;
    increment    = src_width << 16 ;
    increment   /= (long) out->fd_w ;
    rz.increment = increment ;
    i2r_init( out, (int)rz.dstw16, 1 ) ;
  }
  offsets = (short*) Xalloc( size ) ;
  if ( offsets == NULL )
  {
    if ( local_alloc ) Xfree( out->fd_addr ) ;
    out->fd_addr = NULL ;
    return( -3 ) ;
  }

  xoffsets = offsets ;
  yoffsets = offsets + in->fd_w + out->fd_w ;
  addr     = (long*) (yoffsets + in->fd_h + out->fd_h) ;

  rz.xoffsets = offsets + in->fd_w ;
  if ( in->fd_nplanes < 16 ) xoffset_precalc = 0 ;
  else if ( ( in->fd_nplanes == 16 ) && ( rz.flags & 0x02 ) ) xoffset_precalc = 0 ;
  if ( xoffset_precalc )
  { /* La version 16 bits 030 n'a pas besoin des precalculs sur Xoffset   */
    /* De meme, en mode bit-plan il est plus rapide de travailler         */
    /* Avec ADDX.L que de precalculer l'echelle sur les largeurs          */
    off = xoffsets ;
    for ( i = 0; i < in->fd_w; i++ ) *off++ = i ;
    asm_smemcpy16( rz.xoffsets, xoffsets, (long)out->fd_w, (long)in->fd_w ) ;
    if ( in->fd_nplanes == 16 )
      for ( i = 0; i < out->fd_w; i++ ) rz.xoffsets[i] <<= 1 ;
    else if ( in->fd_nplanes == 32 )
      for ( i = 0; i < out->fd_w; i++ ) rz.xoffsets[i] <<= 2 ;
  }

  rz.yoffsets = yoffsets + in->fd_h ;
  off = yoffsets ;
  for ( i = 0; i < in->fd_h; i++ ) *off++ = i ;
  asm_smemcpy16( rz.yoffsets, yoffsets, (long)out->fd_h, (long)in->fd_h ) ;

  rz.src_addr_line = addr ;
  lo_line          = img_size( in->fd_w, 1, in->fd_nplanes ) ;
  adr              = (long)(in->fd_addr) ;
  for ( i = 0; i < in->fd_h; i++, adr += lo_line ) *addr++ = adr ;

  if ( in->fd_nplanes <= 8 )
  {
    rz.indexes_in  = (char*) (rz.src_addr_line + in->fd_h) ;
    rz.indexes_out = rz.indexes_in + rz.srcw16 ;
    memset( rz.indexes_in, 0, rz.srcw16 + rz.dstw16 ) ;
  }
  rz.lout    = img_size( out->fd_w, 1, out->fd_nplanes ) ;
  rz.wprog   = wprog ;
  rz.nplanes = in->fd_nplanes ;
  if ( wprog )
  {
    rz.progress_function = wprog->ProgPc ;
    rz.prog_increment    = ( 8L * 100L * PROG_FREQ / (long)out->fd_h ) ;
    rz.prog              = 0 ;
  }
  else
    rz.progress_function = NULL ;

  rz.in  = in ;
  rz.out = out ;
  if ( rz.flags & 0x01 ) /* use Std VDI */
  {
    MFDB std_src, std_dst ;

    memcpy( &std_src, in, sizeof(MFDB) ) ;
    std_src.fd_stand = 1 ;
    memcpy( &std_dst, out, sizeof(MFDB) ) ;
    std_dst.fd_stand = 1 ;
    std_src.fd_addr  = img_alloc( std_src.fd_w, std_src.fd_h, std_src.fd_nplanes ) ;
    if ( std_src.fd_addr == NULL )
    {
      Xfree( offsets ) ;
      return( -3 ) ;
    }
    std_dst.fd_addr = img_alloc( std_dst.fd_w, std_dst.fd_h, std_dst.fd_nplanes ) ;
    if ( std_dst.fd_addr == NULL )
    {
      Xfree( std_src.fd_addr ) ;
      Xfree( offsets ) ;
      return( -3 ) ;
    }

    vr_trnfm( handle, in, &std_src ) ;
    StdVDI2ClassicAtari( &std_src, in ) ;
    sraster_zoom( &rz ) ;
    ClassicAtari2StdVDI( out, &std_dst ) ;
    vr_trnfm( handle, &std_dst, out ) ;
    vr_trnfm( handle, &std_src, in ) ;
    Xfree( std_src.fd_addr ) ;
    Xfree( std_dst.fd_addr ) ;
  }
  else sraster_zoom( &rz ) ;

  Xfree( offsets ) ;

  if ( in->fd_nplanes > 8 ) RasterResetUnusedData( out ) ;

  return( 0 ) ;
}
