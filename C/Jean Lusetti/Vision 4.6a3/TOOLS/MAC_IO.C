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


int mac_load(INFO_IMAGE* inf)
{
  FILE*  stream ;
  size_t taille ;
  MFDB*  out = &inf->mfdb ;
  void*  in ;

  perf_start( PERF_DISK, &inf->perf_info ) ;
  stream = fopen(inf->filename, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;
  
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
    return EIMG_NOMEMORY ;
  }

  taille = file_size(inf->filename)-sizeof(MACPAINT_HEADER) ;
  in     = Xalloc(taille) ;
  if (in == NULL)
  {
    fclose(stream) ;
    Xfree(out->fd_addr) ;
    return EIMG_NOMEMORY ;
  }
  fread(in, taille, 1, stream) ;
  fclose(stream) ;
  perf_stop( PERF_DISK, &inf->perf_info ) ;

  perf_start( PERF_COMPRESS, &inf->perf_info ) ;
  packbits_dcmps(in, out->fd_addr, out->fd_w, out->fd_h, out->fd_nplanes) ;
  perf_stop( PERF_COMPRESS, &inf->perf_info ) ;

  Xfree(in) ;

  return EIMG_SUCCESS ;
}

int mac_identify(char *nom, INFO_IMAGE *inf)
{
  FILE *stream ;

  stream = fopen( nom, "rb" ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;
  fclose( stream ) ;

  inf->compress = 0 ;
  inf->width    = 576 ;
  inf->height   = 720 ;
  inf->nplanes  = 1 ;
  inf->nb_cpal  = 0 ;
  inf->lpix     = 72 ;
  inf->hpix     = 72 ;
  inf->palette  = NULL ;

  return EIMG_SUCCESS ;
}

void mac_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "MAC\0\0" ;

  caps->iid = IID_MAC ;
  strcpy( caps->short_name, "MAC" ) ;
  strcpy( caps->file_extension, "MAC" ) ;
  strcpy( caps->name, "MAC Paint" ) ;
  caps->version = 0x0401 ;

  caps->import = IEF_P1 | IEF_PBIT ;
  caps->export = 0 ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
