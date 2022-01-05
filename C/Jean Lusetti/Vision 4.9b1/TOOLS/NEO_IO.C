/*******************************/
/* Gestion du format Neochrome */
/*******************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"


typedef struct
{
  int  zero ;     /* Toujours nul */
  int  resol ;    /* 0 : basse, 1 : Moyenne, 2 : Haute */
  int  pal[16] ;  /* Palette RVB 3 bits */
  char anim[12] ;
  int  v_anim ;
  int  nb_pas ;
  int  off_x ;    /* Toujours 0 */
  int  off_y ;    /* Toujours 0 */
  int  largeur ;  /* Toujours 320 */
  int  hauteur ;  /* Toujours 200 */
  int  reserved[34] ;
}
NEO_HEADER ;


int neo_load(INFO_IMAGE* inf)
{
  NEO_HEADER header ;
  FILE*      stream ;
  MFDB*      out = &inf->mfdb ;

  perf_start( PERF_DISK, &inf->perf_info ) ;
  stream = fopen( inf->filename, "rb" ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;
  
  fread( &header, sizeof(NEO_HEADER), 1, stream ) ;
  out->fd_nplanes = 4 ;
  out->fd_w       = 320 ; 
  out->fd_h       = 200 ;
  out->fd_stand   = 0 ;
  out->fd_wdwidth = out->fd_w>>4 ;
  out->fd_addr    = Xalloc( 32000 ) ;
  if ( out->fd_addr == NULL )
  {
    fclose( stream ) ;
    return EIMG_NOMEMORY ;
  }

  fread( out->fd_addr, 32000, 1, stream ) ;
  fclose( stream ) ;
  perf_stop( PERF_DISK, &inf->perf_info ) ;

  return EIMG_SUCCESS ;
}

int neo_identify(char* nom, INFO_IMAGE* inf)
{
  NEO_HEADER header ;
  FILE*      stream ;
  long       tcol ;
  int        i, *pt ;

  stream = fopen(nom, "rb") ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  fread( &header, sizeof(NEO_HEADER), 1, stream ) ;
  fclose( stream ) ;

  inf->compress = 0 ;
  inf->width    = 320 ;
  inf->height   = 200 ;
  inf->nplanes  = 4 ;
  inf->nb_cpal  = 16 ;
  inf->lpix     = 72 ; /* No idea */
  inf->hpix     = 72 ;

  tcol = nb_colors ;
  if ( inf->nb_cpal > nb_colors ) tcol = inf->nb_cpal ;
  inf->palette = Xalloc( 6*tcol ) ;
  if ( inf->palette == NULL ) return EIMG_NOMEMORY ;

  pt  = (int*) inf->palette ;
  for ( i = 0; i < inf->nb_cpal; i++ )
  {
    *pt++ = rgb3b2rgbm( header.pal[i] >> 8 ) ; /* Red   */
    *pt++ = rgb3b2rgbm( header.pal[i] >> 4 ) ; /* Green */
    *pt++ = rgb3b2rgbm( header.pal[i] ) ;      /* Blue  */
  }

  return EIMG_SUCCESS ;
}

int neo_sauve(char* name, MFDB* img, INFO_IMAGE* inf)
{
  NEO_HEADER header ;
  FILE*      stream ;
  int        i ;
  int*       pt ;

  memzero( &header, sizeof(header) ) ;
  if ( (img->fd_w != 320) || (img->fd_h != 200) || (img->fd_nplanes != 4) )
    return EIMG_OPTIONNOTSUPPORTED ;

  if ( inf->palette )
  {
    pt = (int*) inf->palette ;
    memzero( &header.pal, 16*2 ) ;
    for ( i = 0; i < inf->nb_cpal; i++ )
    {
      header.pal[i]  = rgbm2rgb3b(*pt++) << 8 ; /* Red   */
      header.pal[i] += rgbm2rgb3b(*pt++) << 4 ; /* Green */
      header.pal[i] += rgbm2rgb3b(*pt++) ;      /* Blue  */
    }
  }

  stream = CreateFileR( name ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  fwrite( &header, sizeof(NEO_HEADER), 1, stream) ;
  fwrite( img->fd_addr, 32000, 1, stream ) ;

  if ( fclose( stream ) ) return EIMG_DATAINCONSISTENT ;

  return EIMG_SUCCESS ;
}

void neo_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "NEO\0\0" ;

  caps->iid = IID_NEO ;
  strcpy( caps->short_name, "NEO" ) ;
  strcpy( caps->file_extension, "NEO" ) ;
  strcpy( caps->name, "Neochrome" ) ;
  caps->version = 0x0404 ;

  caps->import = IEF_P4 | IEF_NOCOMP ;
  caps->export = IEF_P4 | IEF_NOCOMP ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
