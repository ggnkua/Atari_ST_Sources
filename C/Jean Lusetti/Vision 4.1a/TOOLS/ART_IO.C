/**********************************/
/* Gestion du format Art Director */
/**********************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\image_io.h"

#pragma warn -par
int art_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  FILE *stream ;

  perf_start( PERF_DISK, &PerfInfo ) ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;
  
  out->fd_addr = Xalloc(32000) ;
  if (out->fd_addr == NULL)
  {
    form_error(8) ;
    fclose(stream) ;
    return(-4) ;
  }
  out->fd_w       = 320 ; 
  out->fd_h       = 200 ;
  out->fd_nplanes = 4 ;
  out->fd_stand   = 0 ;
  out->fd_wdwidth = out->fd_w/16 ;

  fread(out->fd_addr, 16000, sizeof(int), stream) ;
  fclose(stream) ;

  perf_stop( PERF_DISK, &PerfInfo ) ;

  return(0) ;
}
#pragma warn +par

int art_identify(char *nom, INFO_IMAGE *inf)
{
  FILE *stream ;
  long tcol ;
  int  pal[16] ;
  int  i, *pt ;
  int  ind ;
  int  coe ;
  unsigned char *tos2vdi ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return(-1) ;

  fseek(stream, 32000, SEEK_SET) ;
  fread(pal, 16, sizeof(int), stream) ;
  fclose(stream) ;

  inf->version  = 0 ;
  inf->compress = 0 ;
  inf->largeur = 320 ;
  inf->hauteur = 200 ;
  inf->nplans  = 4 ;
  inf->nb_cpal = 16 ;
  inf->lpix    = 72 ; /* On ne sait pas */
  inf->hpix    = 72 ;

  tcol = nb_colors ;
  if (inf->nb_cpal > tcol) tcol = inf->nb_cpal ;
  inf->palette = Xalloc(6*tcol) ;
  if (inf->palette == NULL) return(-3) ;

  tos2vdi = get_pttos2vdi(inf->nplans) ;
  if ( tos2vdi )
  {
    pt  = (int *) inf->palette ;
    coe = 1000/7 ;
    for (i = 0; i < 16; i++)
    {
      ind       = 3*tos2vdi[i] ;
      ind       = 3*i ;
      pt[ind]   = ((pal[i] >> 8) & 0x0007)*coe ; /* Rouge */
      pt[1+ind] = ((pal[i] >> 4) & 0x0007)*coe ; /* Vert  */
      pt[2+ind] = (pal[i] & 0x0007)*coe     ;    /* Bleu  */
    }
    inf->nb_cpal = 16 ;
  }

  return( 0 ) ;
}

#pragma warn -par
int art_sauve(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wnd)
{
  FILE *stream ;
  int  pal[16*16] ;
  int  i ;
  int  coe ;
  int  *pt ;

  if ((img->fd_w != 320) || (img->fd_h != 200) || (img->fd_nplanes != 4))
    return(-4) ;

  if (inf->palette != NULL)
  {
    coe = 1000/7 ;
    pt = (int *) inf->palette ;
    memset(pal, 0, 16*16*2) ;
    for (i = 0; i < inf->nb_cpal; i++)
    {
      pal[i] = (((pt[3*i]/coe) & 0x07) << 8) +
               (((pt[3*i+1]/coe) & 0x07) << 4) +
               ((pt[3*i+2]/coe) & 0x07) ;
    }
  }

  stream = fopen(name, "wb") ;
  if (stream == NULL) return(-1) ;

  fwrite(img->fd_addr, 16000, sizeof(int), stream) ;
  fwrite(pal, 16*2, 16, stream) ;
  if (fclose(stream)) return(-2) ;

  return(0) ;
}
#pragma warn +par

void art_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "ART\0\0" ;

  caps->iid = IID_ART ;
  strcpy( caps->short_name, "ART" ) ;
  strcpy( caps->file_extension, "ART" ) ;
  strcpy( caps->name, "Art Director" ) ;
  caps->version = 0x0400 ;

  caps->inport1         = 0 ;
  caps->inport2         = 0 ;
  caps->inport4         = 1 ;
  caps->inport8         = 0 ;
  caps->inport16        = 0 ;
  caps->inport24        = 0 ;
  caps->inport32        = 0 ;
  caps->inport_nocmp    = 0 ;
  caps->inport_rle      = 0 ;
  caps->inport_lzw      = 0 ;
  caps->inport_packbits = 0 ;
  caps->inport_jpeg     = 0 ;
  caps->inport_rfu      = 0 ;

  caps->export1         = 0 ;
  caps->export2         = 0 ;
  caps->export4         = 1 ;
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
