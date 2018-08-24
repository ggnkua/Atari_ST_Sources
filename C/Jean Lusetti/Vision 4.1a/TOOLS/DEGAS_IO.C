/*********************************/
/* Gestion du format DEGAS ELITE */
/*********************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\packbits.h"
#include "..\tools\image_io.h"


typedef struct
{
  int resolution ;  /* 0 : Basse ST   320x200  16 couleurs      */
                    /* 1 : Moyenne ST 640x200   4 couleurs      */
                    /* 2 : Haute ST   640x400   2 couleurs      */
                    /* Si resolution < 0, l'image est compact‚e */
  int palette[16] ; /* Le mot est cod‚ ainsi :                  */
                    /* Bits FEDCBA9876543210                    */
                    /*      00000RRR0VVV0BBB                    */
}
DEGAS_HEADER ;


#pragma warn -par
int degas_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  DEGAS_HEADER header ;
  FILE         *stream ;

  perf_start( PERF_DISK, &PerfInfo ) ;
  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;
  
  fread(&header, sizeof(DEGAS_HEADER), 1, stream) ;
  switch(header.resolution & 0x7FFF)  
  {
    case 0  : out->fd_w       = 320 ; 
              out->fd_h       = 200 ;
              out->fd_nplanes = 4 ;
              out->fd_stand   = 0 ;
              break ;
    case 1  : out->fd_w       = 640 ; 
              out->fd_h       = 200 ;
              out->fd_nplanes = 2 ;
              out->fd_stand   = 0 ;
              break ;
    case 2  : out->fd_w       = 640 ; 
              out->fd_h       = 400 ;
              out->fd_nplanes = 1 ;
              out->fd_stand   = 0 ;
              break ;
    default : fclose(stream) ;
              return(-2) ;
  }

  out->fd_wdwidth = out->fd_w/16 ;
  out->fd_addr    = Xalloc(32000) ;
  if (out->fd_addr == NULL)
  {
    fclose(stream) ;
    return(-3) ;
  }

  fseek(stream, 2+2*16, SEEK_SET) ;
  if (header.resolution >= 0)
  {
    fread(out->fd_addr, 32000, 1, stream) ;
    perf_stop( PERF_DISK, &PerfInfo ) ;
  }
  else
  {
    size_t taille ;
    void   *in ;

    taille = file_size(name)-sizeof(DEGAS_HEADER) ;
    in     = Xalloc(taille) ;
    if (in == NULL)
    {
      fclose(stream) ;
      Xfree(out->fd_addr) ;
      return(-3) ;
    }
    fread(in, taille, 1, stream) ;
    perf_stop( PERF_DISK, &PerfInfo ) ;
    packbits_dcmps(in, out->fd_addr, out->fd_w, out->fd_h, out->fd_nplanes) ;
    Xfree(in) ;
  }
  fclose(stream) ;

  return(0) ;
}
#pragma warn +par

int degas_identify(char *nom, INFO_IMAGE *inf)
{
  DEGAS_HEADER degas_inf ;
  FILE         *stream ;
  long         tcol ;
  int          i, *pt ;
  int          ind ;
  int          coe ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return(-1) ;

  fread(&degas_inf, sizeof(DEGAS_HEADER), 1, stream) ;
  fclose(stream) ;

  inf->version  = (degas_inf.resolution < 0) ;
  inf->compress = (degas_inf.resolution < 0) ;
  switch(degas_inf.resolution & 0x7FFF)
  {
    case 0 : inf->largeur = 320 ;
             inf->hauteur = 200 ;
             inf->nplans  = 4 ;
             inf->nb_cpal = 16 ;
             break ;
    case 1 : inf->largeur = 640 ;
             inf->hauteur = 200 ;
             inf->nplans  = 2 ;
             inf->nb_cpal = 4 ;
             break ;
    case 2 : inf->largeur = 640 ;
             inf->hauteur = 400 ;
             inf->nplans  = 1 ;
             inf->nb_cpal = 2 ;
             break ;
  }
  inf->lpix     = 72 ; /* On ne sait pas */
  inf->hpix     = 72 ;

  tcol = nb_colors ;
  if (inf->nb_cpal > tcol) tcol = inf->nb_cpal ;
  inf->palette = Xalloc(6*tcol) ;
  if (inf->palette == NULL) return(-3) ;

  pt  = (int *) inf->palette ;
  coe = 1000/7 ;
  for (i = 0; i < inf->nb_cpal; i++)
  {
    ind       = 3*i ;
    pt[ind]   = ((degas_inf.palette[i] >> 8) & 0x0007)*coe ; /* Rouge */
    pt[1+ind] = ((degas_inf.palette[i] >> 4) & 0x0007)*coe ; /* Vert  */
    pt[2+ind] = (degas_inf.palette[i] & 0x0007)*coe     ;    /* Bleu  */
  }

  return(0) ;
}

#pragma warn -par
int degas_sauve(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wprog)
{
  DEGAS_HEADER header ;
  FILE         *stream ;
  int          i ;
  int          coe ;
  int          *pt ;

  if ((img->fd_w == 320) && (img->fd_h == 200) && (img->fd_nplanes == 4)) header.resolution = 0 ;
  else
  {
    if ((img->fd_w == 640) && (img->fd_h == 200) && (img->fd_nplanes == 2)) header.resolution = 1 ;
    else
    {
      if ((img->fd_w == 640) && (img->fd_h == 400) && (img->fd_nplanes == 1)) header.resolution = 2 ;
      else
        return(-4) ;
    }
  }

  if (inf->palette != NULL)
  {
    coe = 1000/7 ;
    pt = (int *) inf->palette ;
    memset(&header.palette, 0, 16*2) ;
    for (i = 0; i < inf->nb_cpal; i++)
    {
      header.palette[i] = (((pt[3*i]/coe) & 0x07) << 8) +
                          (((pt[3*i+1]/coe) & 0x07) << 4) +
                          ((pt[3*i+2]/coe) & 0x07) ;
    }
  }

  stream = fopen(name, "wb") ;
  if (stream == NULL) return(-1) ;

  fwrite(&header, sizeof(DEGAS_HEADER), 1, stream) ;
  if (fwrite(img->fd_addr, 32000, 1, stream) != 1)
  {
    fclose(stream); 
    return(-2) ;
  }

  if (fclose(stream)) return(-2) ;

  return(0) ;
}
#pragma warn +par

void degas_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "PI1\0PI2\0PI3\0PC1\0PC2\0PC3\0\0" ;

  caps->iid = IID_DEGAS ;
  strcpy( caps->short_name, "Degas" ) ;
  strcpy( caps->file_extension, "PI1" ) ;
  strcpy( caps->name, "Degas Elite" ) ;
  caps->version = 0x0400 ;

  caps->inport1         = 1 ;
  caps->inport2         = 1 ;
  caps->inport4         = 1 ;
  caps->inport8         = 0 ;
  caps->inport16        = 0 ;
  caps->inport24        = 0 ;
  caps->inport32        = 0 ;
  caps->inport_nocmp    = 1 ;
  caps->inport_rle      = 0 ;
  caps->inport_lzw      = 0 ;
  caps->inport_packbits = 0 ;
  caps->inport_jpeg     = 0 ;
  caps->inport_rfu      = 0 ;

  caps->export1         = 1 ;
  caps->export2         = 1 ;
  caps->export4         = 1 ;
  caps->export8         = 0 ;
  caps->export16        = 0 ;
  caps->export24        = 0 ;
  caps->export32        = 0 ;
  caps->export_nocmp    = 1 ;
  caps->export_rle      = 0 ;
  caps->export_lzw      = 0 ;
  caps->export_packbits = 0 ;
  caps->export_jpeg     = 0 ;
  caps->export_rfu      = 0 ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
