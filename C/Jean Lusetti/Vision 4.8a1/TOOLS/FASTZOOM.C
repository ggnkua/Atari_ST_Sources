#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include   "..\tools\xgem.h"
#include   "..\tools\image_io.h"
#include   "..\tools\rasterop.h"
#include   "..\tools\fastzoom.h"

extern void* fz_tab2, *fz_tab4, *fz_tab8, *fz_tab16 ; /* Dans FASTZOOM.S */
extern void fast_zoom(FZOOM_DATA *fzdata) ;           /* Dans FASTZOOM.S */

#define NeedStdVDI(n) ( (UseStdVDI && ((n) <= 8 ) ) ? 1 : 0 )

void fztab_init(void *tab, int zoom)
{
  unsigned int  *pti = (unsigned int *) tab ;
  unsigned long *ptl = (unsigned long *) tab ;
  unsigned long lmask_out ;
  unsigned int  mask_in ;
  unsigned int  imask_out ;
  unsigned int  i ;
  int           bit ;

  switch( zoom )
  {
    case 2 : for ( i = 0; i < 256; i++ )
             {
               mask_in   = 0x80 ;
               imask_out = 0xC000 ;
               for ( bit = 7; bit >= 0; bit--, mask_in >>= 1, imask_out >>= 2 )
                 if ( i & mask_in ) *pti |= imask_out ;
               pti++ ;
             }
             break ;
    case 4 : for ( i = 0; i < 256; i++ )
             {
               mask_in   = 0x80 ;
               lmask_out = 0xF0000000L ;
               for ( bit = 7; bit >= 0; bit--, mask_in >>= 1, lmask_out >>= 4 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
             }
             break ;
    case 8 : for ( i = 0; i < 256; i++ )
             {
               mask_in   = 0x80 ;
               lmask_out = 0xFF000000L ;
               for ( bit = 7; bit >= 4; bit--, mask_in >>= 1, lmask_out >>= 8 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
               lmask_out = 0xFF000000L ;
               for ( bit = 3; bit >= 0; bit--, mask_in >>= 1, lmask_out >>= 8 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
             }
             break ;
    case 16: for ( i = 0; i < 256; i++ )
             {
               mask_in   = 0x80 ;
               lmask_out = 0xFFFF0000L ;
               for ( bit = 7; bit >= 6; bit--, mask_in >>= 1, lmask_out >>= 16 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
               lmask_out = 0xFFFF0000L ;
               for ( bit = 5; bit >= 4; bit--, mask_in >>= 1, lmask_out >>= 16 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
               lmask_out = 0xFFFF0000L ;
               for ( bit = 3; bit >= 2; bit--, mask_in >>= 1, lmask_out >>= 16 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
               lmask_out = 0xFFFF0000L ;
               for ( bit = 1; bit >= 0; bit--, mask_in >>= 1, lmask_out >>= 16 )
                 if ( i & mask_in ) *ptl |= lmask_out ;
               ptl++ ;
             }
             break ;
  }
}

int init_fztab(int zoom)
{
  void **fz_tab = NULL ;
  int  err = 0 ;

  switch( zoom )
  {
    case 2  : fz_tab = &fz_tab2 ;
              break ;
    case 4  : fz_tab = &fz_tab4 ;
              break ;
    case 8  : fz_tab = &fz_tab8 ;
              break ;
    case 16 : fz_tab = &fz_tab16 ;
              break ;
  }
  if ( fz_tab == NULL ) return( -1 ) ;
  if ( *fz_tab != NULL ) return( 0 ) ;

  if ( ( zoom > 1 ) && !Truecolor )
  {
    *fz_tab = Xcalloc( 256, zoom ) ; /* 1 Octet --> n octets */
    if ( *fz_tab == NULL ) err = -3 ;
    else                   fztab_init( *fz_tab, zoom ) ;
  }
  
  return( err ) ;
}

void terminate_fztab(void)
{
  if ( fz_tab2 )  Xfree( fz_tab2 ) ;
  if ( fz_tab4 )  Xfree( fz_tab4 ) ;
  if ( fz_tab8 )  Xfree( fz_tab8 ) ;
  if ( fz_tab16 ) Xfree( fz_tab16 ) ;
  fz_tab2 = fz_tab4 = fz_tab8 = fz_tab16 = NULL ;
}

int FastZoom(FZOOM_DATA *data)
{
  FZOOM_DATA fzdata ;
  MFDB       std_src, std_dst ;
  MFDB       *pstd_src, *pstd_dst ;
  int        use_std_vdi = NeedStdVDI(data->src->fd_nplanes) ;

  if ( use_std_vdi )
  {
    if ( data->std_src )
    {
      std_src.fd_addr = NULL ;
      pstd_src        = data->std_src ;
    }
    else
    {
      CopyMFDB( &std_src, data->src ) ;
      std_src.fd_addr  = img_alloc( std_src.fd_w, std_src.fd_h, std_src.fd_nplanes ) ;
      if ( std_src.fd_addr == NULL ) return( -3 ) ;
      std_src.fd_stand = 1 ;
      pstd_src         = &std_src ;
    }
    if ( data->std_dst )
    {
      std_dst.fd_addr = NULL ;
      pstd_dst        = data->std_dst ;
    }
    else
    {
      CopyMFDB( &std_dst, data->dst ) ;
      std_dst.fd_addr  = img_alloc( std_dst.fd_w, std_dst.fd_h, std_dst.fd_nplanes ) ;
      if ( std_dst.fd_addr == NULL )
      {
        if ( std_src.fd_addr ) Xfree( std_src.fd_addr ) ;
        return( -3 ) ;
      }
      std_dst.fd_stand = 1 ;
      pstd_dst         = &std_dst ;
    }
    vr_trnfm( handle, data->src, pstd_src ) ;
    StdVDI2ClassicAtari( pstd_src, data->src ) ;
    memcpy( &fzdata, data, sizeof(FZOOM_DATA) ) ;
    fzdata.std_src = pstd_src ;
    fzdata.std_dst = pstd_dst ;
  }
  else memcpy( &fzdata, data, sizeof(FZOOM_DATA) ) ;

  fast_zoom( &fzdata ) ;

  if ( use_std_vdi )
  {
    ClassicAtari2StdVDI( fzdata.dst, pstd_dst ) ;
    vr_trnfm( handle, pstd_dst, fzdata.dst ) ;
    vr_trnfm( handle, pstd_src, data->src ) ;
    if ( std_dst.fd_addr ) Xfree( std_dst.fd_addr ) ;
    if ( std_src.fd_addr ) Xfree( std_src.fd_addr ) ;
  }

  return( 0 ) ;
}

int FZNeedStdFormat(int nplanes)
{
  return( NeedStdVDI(nplanes) ) ;
}
