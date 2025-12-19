/*******************************/
/* Gestion du format MAC-PAINT */
/*******************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\rasterop.h"
#include "..\tools\image_io.h"
#include "..\tools\packbits.h"

typedef struct
{
  long check ;
  char pattern[304] ;
  char reserved[204] ;
}
MACPAINT_SOF ;


int mac_load(INFO_IMAGE* inf)
{
  PACKBITS_STR pb_str ;
  MFDB*        out = &inf->mfdb ;

  out->fd_nplanes = 1 ;
  out->fd_w       = 576 ; 
  out->fd_h       = 720 ;
  out->fd_stand   = 0 ;
  out->fd_wdwidth = out->fd_w>>4 ;
  out->fd_addr    = img_alloc( 576, 720, 1 ) ;
  if ( out->fd_addr == NULL ) return EIMG_NOMEMORY ;

  pb_str.pbadr_in   = inf->gen_ptr ;
  pb_str.pbadr_out  = out->fd_addr ;
  pb_str.pbnb_pixel = out->fd_w ;
  pb_str.pbnb_ligne = out->fd_h ;
  pb_str.pbnb_plan  = out->fd_nplanes ;

  perf_start( PERF_COMPRESS, &inf->perf_info ) ;
  packbits_dcmps( &pb_str ) ;
  perf_stop( PERF_COMPRESS, &inf->perf_info ) ;

  return EIMG_SUCCESS ;
}

int mac_identify(char* nom, INFO_IMAGE* inf)
{
  MACPAINT_SOF* start_of_file ;
  int           err ;

  perf_start( PERF_DISK, &inf->perf_info ) ;
  err = ImgFOpen( inf, nom, &inf->file_size ) ; 
  if ( err != EIMG_SUCCESS ) return err ;

  inf->file_contents = Xalloc( inf->file_size ) ;
  if ( inf->file_contents == NULL )
  {
    ImgFClose( inf ) ;
    return EIMG_NOMEMORY ;
  }

  ImgFRead( inf, inf->file_contents, inf->file_size ) ;
  ImgFClose( inf ) ;
  perf_stop( PERF_DISK, &inf->perf_info ) ;

  start_of_file = (MACPAINT_SOF*) inf->file_contents ;
  if ( start_of_file->check != 0x02L )
    start_of_file = (MACPAINT_SOF*) ((char*)inf->file_contents + 128) ; /* Skip file header */

  if ( start_of_file->check != 0x02L ) return EIMG_DATAINCONSISTENT ;

  inf->gen_ptr  = (void*) (start_of_file+1) ; /* Points to image data */
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
  caps->version = 0x0402 ;

  caps->import = IEF_P1 | IEF_PBIT ;
  caps->export = 0 ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
