/**********************************/
/* Gestion du format Art Director */
/**********************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"


int art_load(INFO_IMAGE* inf)
{
  FILE* stream ;
  MFDB* out = &inf->mfdb ;

  perf_start( PERF_DISK, &inf->perf_info ) ;

  stream = fopen(inf->filename, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;
  
  out->fd_addr = Xalloc(32000) ;
  if (out->fd_addr == NULL)
  {
    fclose(stream) ;
    return EIMG_NOMEMORY ;
  }
  out->fd_w       = 320 ; 
  out->fd_h       = 200 ;
  out->fd_nplanes = 4 ;
  out->fd_stand   = 0 ;
  out->fd_wdwidth = out->fd_w/16 ;

  fread(out->fd_addr, 16000, sizeof(int), stream) ;
  fclose(stream) ;

  perf_stop( PERF_DISK, &inf->perf_info ) ;

  return EIMG_SUCCESS ;
}

int art_identify(char *nom, INFO_IMAGE *inf)
{
  FILE*          stream ;
  size_t         fsize ;
  long           tcol ;
  int            pal[16] ;
  int            i, *pt ;
  unsigned char* tos2vdi ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  fseek( stream, 0, SEEK_END ) ;
  fsize = ftell( stream ) ;
  if ( fsize != 32512 )
  {
    fclose(stream) ;
    return EIMG_UNKOWNFORMAT ;
  }
  fseek(stream, 32000, SEEK_SET) ;
  fread(pal, 16, sizeof(int), stream) ;
  fclose(stream) ;

  inf->compress = 0 ;
  inf->width    = 320 ;
  inf->height   = 200 ;
  inf->nplanes  = 4 ;
  inf->nb_cpal  = 16 ;
  inf->lpix     = 72 ; /* On ne sait pas */
  inf->hpix     = 72 ;

  tcol = nb_colors ;
  if (inf->nb_cpal > tcol) tcol = inf->nb_cpal ;
  inf->palette = Xalloc(6*tcol) ;
  if (inf->palette == NULL) return EIMG_NOMEMORY ;

  tos2vdi = get_pttos2vdi(inf->nplanes) ;
  if ( tos2vdi )
  {
    pt  = (int *) inf->palette ;
    for (i = 0; i < 16; i++)
    {
      *pt++ = rgb3b2rgbm( pal[i] >> 8 ) ; /* Red   */
      *pt++ = rgb3b2rgbm( pal[i] >> 4 ) ; /* Green */
      *pt++ = rgb3b2rgbm( pal[i] ) ;      /* Blue  */
    }
    inf->nb_cpal = 16 ;
  }

  return EIMG_SUCCESS ;
}

#pragma warn -par
int art_sauve(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wnd)
{
  FILE *stream ;
  int  pal[16*16] ;
  int  i ;
  int  *pt, *p ;

  if ((img->fd_w != 320) || (img->fd_h != 200) || (img->fd_nplanes != 4))
    return EIMG_OPTIONNOTSUPPORTED ;

  if (inf->palette != NULL)
  {
    pt = (int *) inf->palette ;
    p  = pal ;
    memset(pal, 0, sizeof(pal)) ;
    for (i = 0; i < inf->nb_cpal; i++)
    {
      *p  = rgbm2rgb3b(*pt++) << 8 ; /* Red   */
	  *p += rgbm2rgb3b(*pt++) << 4 ; /* Green */
	  *p += rgbm2rgb3b(*pt++) ;      /* Blue  */
	  p++ ;
    }
  }

  stream = fopen(name, "wb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  fwrite(img->fd_addr, 16000, sizeof(int), stream) ;
  fwrite(pal, 16*2, 16, stream) ;
  if (fclose(stream)) return EIMG_DATAINCONSISTENT ;

  return EIMG_SUCCESS ;
}
#pragma warn +par

void art_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "ART\0\0" ;

  caps->iid = IID_ART ;
  strcpy( caps->short_name, "ART" ) ;
  strcpy( caps->file_extension, "ART" ) ;
  strcpy( caps->name, "Art Director" ) ;
  caps->version = 0x0403 ;

  caps->import = IEF_P4 ;
  caps->export = IEF_P4 ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
