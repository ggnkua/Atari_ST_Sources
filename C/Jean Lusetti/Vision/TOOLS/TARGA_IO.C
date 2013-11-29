/***************************/
/* Gestion du format TARGA */
/***************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include               "defs.h"
#include      "..\tools\xgem.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\image_io.h"


typedef struct
{
  unsigned int origin ;
  unsigned int length ;
  unsigned char depth ;
}
TGA_Cmap_Spec ;

typedef struct
{
  unsigned attribute  : 4 ;
  unsigned reserved   : 1 ;
  unsigned origin     : 1 ;
  unsigned interleave : 2 ;
}
TGA_Image_Descriptor ;

typedef struct
{
  unsigned int  x_org ;
  unsigned int  y_org ;
  unsigned int  width ;
  unsigned int  height ;
  unsigned char depth ;
  unsigned char descriptor ;
}
TGA_Image_Spec ;

typedef struct
{
  unsigned char  length_of_identification ;
  unsigned char  cmap_type ;
  unsigned char  image_type ;
  TGA_Cmap_Spec  cmap ;
  TGA_Image_Spec image ;
}
TARGA_HEADER ;

TARGA_HEADER entete ;


void header_reverse(TARGA_HEADER *h)
{
  h->cmap.origin = int_reverse(h->cmap.origin) ;
  h->cmap.length = int_reverse(h->cmap.length) ;

  h->image.x_org  = int_reverse(h->image.x_org) ;
  h->image.y_org  = int_reverse(h->image.y_org) ;
  h->image.width  = int_reverse(h->image.width) ;
  h->image.height = int_reverse(h->image.height) ;
}

int targa_identify(char *nom, INFO_IMAGE *inf)
{
  FILE *stream ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return(-1) ;

  fread(&entete, 3, 1, stream) ;
  fread(&entete.cmap, 5, 1, stream) ;
  fread(&entete.image, 10, 1, stream) ;
  fclose(stream) ;

  header_reverse(&entete) ;

  inf->version  = 0L ; /* Sans importance */
  inf->compress = entete.image_type ;
  if (inf->compress != 2) return(-6) ;
  inf->largeur  = entete.image.width ;
  inf->hauteur  = entete.image.height ;
  inf->nplans   = entete.image.depth ;
  if ((inf->nplans != 16) && (inf->nplans != 24)) return(-6) ;
  inf->lpix     = 0x152 ;  /* Non renseign‚ */
  inf->hpix     = 0x152 ;
  inf->palette  = NULL ;
  inf->nb_cpal  = 0 ;
  if (entete.image.descriptor & 0x20) inf->flipflop = FLIPFLOP_Y ;
  else                                inf->flipflop = 0 ;

  return(0) ;
}

int targa_read(FILE *stream, MFDB *out, GEM_WINDOW *wprog)
{
  int  l, pc ;
  int  lut_size ;
  int  code, ret = 0 ;
  long offset ;
  
  i2r_init(out, entete.image.width, 1) ;
  i2r_nb = (long)entete.image.width*(long)(entete.image.depth >> 3) ;
  i2r_data = malloc(i2r_nb) ;
  if (i2r_data == NULL) return(-3) ;

  lut_size = entete.cmap.depth/3+entete.cmap.length ;
  offset   = 18+entete.length_of_identification+(lut_size >> 3) ;
  fseek(stream, offset, SEEK_SET) ;

  for (l = 0; l < entete.image.height; l++)
  {
    perf_start( PERF_DISK, &PerfInfo ) ;
    fread(i2r_data, entete.image.depth >> 3, entete.image.width, stream) ;
    perf_stop( PERF_DISK, &PerfInfo ) ;

    perf_start( PERF_IND2RASTER, &PerfInfo ) ;
    if (entete.image.depth == 24)
    {
      switch( out->fd_nplanes )
      {
        case 16 : tc24targato16() ;
                  break ;
        case 24 : tc24targato24() ;
                  break ;
        case 32 : tc24targato32() ;
                  break ;
      }
    }
    else if (entete.image.depth == 16)
    {
      switch( out->fd_nplanes )
      {
        case 16 : tc16targato16() ;
                  break ;
        case 24 : tc16targato24() ;
                  break ;
        case 32 : tc16targato32() ;
                  break ;
      }
    }
    perf_stop( PERF_IND2RASTER, &PerfInfo ) ;
    if ( MAY_UPDATE( wprog, l ) )
    {
      pc = (int) ((100L*l)/(long)entete.image.height) ;
      code = wprog->ProgPc( wprog, pc, NULL ) ;
      if ( STOP_CODE( code ) )
      {
        ret = -8 ;
        break ;
      }
    }
  }
  free(i2r_data) ;

  return( ret ) ;
}

int targa_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  FILE *stream ;
  int  ret ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;

  if (entete.image.width % 16) out->fd_w = (int) (16+(entete.image.width & 0xFFFFFFF0L)) ;
  else                         out->fd_w = (int) entete.image.width ;
  out->fd_h = (int) entete.image.height ;
  if ( entete.image.depth <= 8 ) out->fd_nplanes = entete.image.depth ;
  else
  {
    if ( Force16BitsLoad ) out->fd_nplanes = 16 ;
    else
    {
      if ( FinalNbPlanes >= 16 )  out->fd_nplanes = FinalNbPlanes ;
      else                        out->fd_nplanes = entete.image.depth ;
    }
  }

  out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL)
  {
    fclose(stream) ;
    return(-3) ;
  }
  out->fd_wdwidth = out->fd_w/16 ;
  out->fd_stand   = 0 ;

  /* Remise … z‚ro de l'image */
  img_raz(out) ;

  ret = targa_read( stream, out, wprog ) ;
  fclose(stream) ;

  if ((entete.image.descriptor & 0x20) == 0)
    MustDoHSym = 1 ;

  return( ret ) ;
}

int targa_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  TARGA_HEADER  header ;
  FILE          *stream ;
  long          larg ;
  int           *pt_img, *b16 ;
  int           l, pc ;
  unsigned char *b24 ;
  void          *b ;
  int           nb_bytes_per_sample ;
  int           nplanes ;

  if (img->fd_nplanes < 16) return(-4) ;

  stream = fopen(name, "wb") ;
  if (stream == NULL) return(-1) ;

  if ( img->fd_nplanes >= 24 ) nplanes = 24 ;
  else                         nplanes = 16 ;

  header.length_of_identification = 0 ;
  header.cmap_type                = 0 ;
  header.image_type               = 2 ;
  header.cmap.origin              = 0 ;
  header.cmap.length              = 0 ;
  header.cmap.depth               = 0 ;
  header.image.x_org              = 0 ;
  header.image.y_org              = 0 ;
  header.image.width              = img->fd_w ;
  header.image.height             = img->fd_h ;
  header.image.depth              = nplanes ;
  if (info->flipflop & FLIPFLOP_Y) header.image.descriptor = 0 ;
  else                             header.image.descriptor = 0x20 ;

  header_reverse(&header) ;

  if (img->fd_nplanes >= 24)
  {
    nb_bytes_per_sample = 3 ;
    b24 = (unsigned char *) malloc(nb_bytes_per_sample*img->fd_w) ;
    if (b24 == NULL)
    {
      fclose(stream) ;
      return(-3) ;
    }
    b = b24 ;
  }
  else
  {
    nb_bytes_per_sample = 2 ;
    b16 = (int *) malloc(nb_bytes_per_sample*img->fd_w) ;
    if (b16 == NULL)
    {
      fclose(stream) ;
      return(-3) ;
    }
    b = b16 ;
  }

  fwrite(&header, 3, 1, stream) ;
  fwrite(&header.cmap, 5, 1, stream) ;
  fwrite(&header.image, 10, 1, stream) ;

  pt_img = (int *) img->fd_addr ;
  larg   = (long)(img->fd_wdwidth*img->fd_nplanes) ;
  for (l = 0; l < img->fd_h; l++)
  {
    switch( img->fd_nplanes )
    {
      case 16: tc16totarga16(pt_img, b, (long)img->fd_w) ;
               break ;
      case 24: tc24totarga24(pt_img, b, (long)img->fd_w) ;
               break ;
      case 32: tc32totarga24(pt_img, b, (long)img->fd_w) ;
               break ;
    }
    if (fwrite(b, nb_bytes_per_sample, img->fd_w, stream) != img->fd_w)
    {
      fclose(stream) ;
      free(b) ;
      return(-2) ;
    }

    if ( MAY_UPDATE( wprog, l ) )
    {
      pc = (int) ((100L*l)/(long)img->fd_h) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
    pt_img += larg ;
  }

  fclose(stream) ;
  free(b) ;

  return(0) ;
}

void targa_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "TGA\0\0" ;

  caps->iid = IID_TARGA ;
  strcpy( caps->short_name, "Targa" ) ;
  strcpy( caps->file_extension, "TGA" ) ;
  strcpy( caps->name, "TrueVision Targa" ) ;
  caps->version = 0x0400 ;

  caps->inport1         = 0 ;
  caps->inport2         = 0 ;
  caps->inport4         = 0 ;
  caps->inport8         = 0 ;
  caps->inport16        = 1 ;
  caps->inport24        = 1 ;
  caps->inport32        = 0 ;
  caps->inport_nocmp    = 1 ;
  caps->inport_rle      = 0 ;
  caps->inport_lzw      = 0 ;
  caps->inport_packbits = 0 ;
  caps->inport_jpeg     = 0 ;
  caps->inport_rfu      = 0 ;

  caps->export1         = 0 ;
  caps->export2         = 0 ;
  caps->export4         = 0 ;
  caps->export8         = 0 ;
  caps->export16        = 1 ;
  caps->export24        = 1 ;
  caps->export32        = 0 ;
  caps->export_nocmp    = 1 ;
  caps->export_rle      = 0 ;
  caps->export_lzw      = 0 ;
  caps->export_packbits = 0 ;
  caps->export_jpeg     = 0 ;
  caps->export_rfu      = 0 ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
