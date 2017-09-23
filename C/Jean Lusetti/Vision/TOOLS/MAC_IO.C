/*******************************/
/* Gestion du format MAC-PAINT */
/*******************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\image_io.h"
#include "..\tools\packbits.h"

typedef struct
{
  long version ;
  char pattern[304] ;
  char reserved[204] ;
}
MACPAINT_HEADER ;


#pragma warn -par
int mac_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  FILE   *stream ;
  size_t taille ;
  void   *in ;

  perf_start( PERF_DISK, &PerfInfo ) ;
  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;
  
  fseek(stream, 0x280, SEEK_SET) ;
  out->fd_nplanes = 1 ;
  out->fd_w       = 576 ; 
  out->fd_h       = 720 ;
  out->fd_stand   = 0 ;
  out->fd_wdwidth = out->fd_w/16 ;
  out->fd_addr    = img_alloc(576, 720, 1) ;
  if (out->fd_addr == NULL)
  {
    fclose(stream) ;
    return(-3) ;
  }

  taille = file_size(name)-sizeof(MACPAINT_HEADER) ;
  in     = malloc(taille) ;
  if (in == NULL)
  {
    fclose(stream) ;
    free(out->fd_addr) ;
    return(-3) ;
  }
  fread(in, taille, 1, stream) ;
  fclose(stream) ;
  perf_stop( PERF_DISK, &PerfInfo ) ;

  perf_start( PERF_COMPRESS, &PerfInfo ) ;
  packbits_dcmps(in, out->fd_addr, out->fd_w, out->fd_h, out->fd_nplanes) ;
  perf_stop( PERF_COMPRESS, &PerfInfo ) ;

  free(in) ;

  return(0) ;
}
#pragma warn +par

int mac_identify(char *nom, INFO_IMAGE *inf)
{
  FILE *stream ;

  stream = fopen( nom, "rb" ) ;
  if ( stream == NULL ) return( -1 ) ;
  fclose( stream ) ;

  inf->version  = 0 ;
  inf->compress = 0 ;
  inf->largeur  = 576 ;
  inf->hauteur  = 720 ;
  inf->nplans   = 1 ;
  inf->nb_cpal  = 0 ;
  inf->lpix     = 72 ; /* On ne sait pas */
  inf->hpix     = 72 ;
  inf->palette  = NULL ;
  inf->nb_cpal  = 0 ;

  return( 0 ) ;
}

void mac_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "MAC\0\0" ;

  caps->iid = IID_MAC ;
  strcpy( caps->short_name, "MAC" ) ;
  strcpy( caps->name, "MAC Paint" ) ;
  caps->version = 0x0400 ;

  caps->inport1         = 1 ;
  caps->inport2         = 0 ;
  caps->inport4         = 0 ;
  caps->inport8         = 0 ;
  caps->inport16        = 0 ;
  caps->inport24        = 0 ;
  caps->inport32        = 0 ;
  caps->inport_nocmp    = 0 ;
  caps->inport_rle      = 0 ;
  caps->inport_lzw      = 0 ;
  caps->inport_packbits = 1 ;
  caps->inport_jpeg     = 0 ;
  caps->inport_rfu      = 0 ;

  caps->export1         = 0 ;
  caps->export2         = 0 ;
  caps->export4         = 0 ;
  caps->export8         = 0 ;
  caps->export16        = 0 ;
  caps->export24        = 0 ;
  caps->export32        = 0 ;
  caps->export_nocmp    = 0 ;
  caps->export_rle      = 0 ;
  caps->export_lzw      = 0 ;
  caps->export_packbits = 0 ;
  caps->export_jpeg     = 0 ;
  caps->export_rfu      = 0 ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
