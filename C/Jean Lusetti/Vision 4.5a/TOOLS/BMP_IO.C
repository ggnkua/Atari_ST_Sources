/*************************/
/* Gestion du format BMP */
/*************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include      "..\tools\xgem.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\image_io.h"


#define BMP_ID      0x4D42
#define INFOHEADER_SIZE 40


typedef struct
{
  unsigned int  type ;
  unsigned long file_size ;
  unsigned int  r1 ;
  unsigned int  r2 ;
  unsigned long off_bits ;

  unsigned long size ;
  unsigned long width ;
  unsigned long height ;
  unsigned int  planes ;
  unsigned int  bit_count ;
  unsigned long compression ;
  unsigned long size_image ;
  unsigned long xpix_meter ;
  unsigned long ypix_meter ;
  unsigned long clr_used ;
  unsigned long clr_important ;
}
BMP_HEADER ;

typedef struct
{
  unsigned char b ;
  unsigned char g ;
  unsigned char r ;
  unsigned char o ;
}
LUT32 ;

BMP_HEADER bmp_entete ;


void bmp_header_reverse(BMP_HEADER *h)
{
  h->type      = int_reverse(h->type) ;
  h->file_size = long_reverse(h->file_size) ;
  h->r1        = int_reverse(h->r1) ;
  h->r2        = int_reverse(h->r2) ;
  h->off_bits  = long_reverse(h->off_bits) ;

  h->size          = long_reverse(h->size) ;
  h->width         = long_reverse(h->width) ;
  h->height        = long_reverse(h->height) ;
  h->planes        = int_reverse(h->planes) ;
  h->bit_count     = int_reverse(h->bit_count) ;
  h->compression   = long_reverse(h->compression) ;
  h->size_image    = long_reverse(h->size_image) ;
  h->xpix_meter    = long_reverse(h->xpix_meter) ;
  h->ypix_meter    = long_reverse(h->ypix_meter) ;
  h->clr_used      = long_reverse(h->clr_used) ;
  h->clr_important = long_reverse(h->clr_important) ;
}

int bmp_identify(char *nom, INFO_IMAGE *inf)
{
  FILE *stream ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  fread(&bmp_entete, sizeof(bmp_entete), 1, stream) ;

  bmp_header_reverse(&bmp_entete) ;
  if (bmp_entete.type != BMP_ID)
  {
    fclose(stream) ;
    return EIMG_DATAINCONSISTENT ;
  }

  if (bmp_entete.planes != 1)
  {
    fclose(stream) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }

  inf->flipflop = FLIPFLOP_Y ;
  inf->version  = 0L ; /* Sans importance */
  inf->compress = (int) bmp_entete.compression ;
  if ( inf->compress != 0 )
  {
    fclose(stream) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  inf->largeur  = (int) bmp_entete.width ;
  inf->hauteur  = (int) bmp_entete.height ;
  inf->nplans   = bmp_entete.bit_count*bmp_entete.planes ;
  if ((inf->nplans != 1) && (inf->nplans != 4) &&
      (inf->nplans != 8) && (inf->nplans != 24))
  {
    fclose(stream) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  if (bmp_entete.xpix_meter > 0) inf->lpix = (int) (1000000.0/(float)bmp_entete.xpix_meter) ;
  else                           inf->lpix = 0x152 ;
  if (bmp_entete.ypix_meter > 0) inf->hpix = (int) (1000000.0/(float)bmp_entete.ypix_meter) ;
  else                           inf->hpix = 0x152 ;
  if (inf->nplans <= 8)
  {
    LUT32 lut ;
    int   *pal ;
    int   n, total ;

    if (bmp_entete.clr_used == 0) total = (int) inf->nb_cpal ;
    else                          total = (int) bmp_entete.clr_used ;
    inf->nb_cpal = 1 << inf->nplans ;
    inf->palette = (int *) Xalloc(6*total) ;
    if (inf->palette == NULL)
    {
      fclose(stream) ;
      return EIMG_NOMEMORY ;
    }
    pal = inf->palette ;
    for (n = 0; n < total; n++)
    {
      fread(&lut, sizeof(lut), 1, stream) ;
      *pal++ = RGB8BToRGBPM[lut.r] ;
      *pal++ = RGB8BToRGBPM[lut.g] ;
      *pal++ = RGB8BToRGBPM[lut.b] ;
    }
  }
  fclose(stream) ;

  return EIMG_SUCCESS ;
}

int bmp_read(FILE *stream, MFDB *out, GEM_WINDOW *wprog)
{
  long          lo_mligne, nb_octets, nb_bits ;
  long          *pt_outl ;
  int           *pt_out ;
  int           l, pc, code ;
  int           ret = EIMG_SUCCESS ;
  unsigned char *pt_natural, *pt_outc ;

  pt_natural = NaturalFormat ;
  nb_bits    = bmp_entete.width*bmp_entete.bit_count*bmp_entete.planes ;
  nb_octets  = nb_bits/8 ;
  if (nb_bits % 8) nb_octets++ ;
  i2r_nb = nb_octets ;
  if (nb_octets % 4) nb_octets = 4+4*(nb_octets/4) ;
  i2r_init(out, (int)bmp_entete.width, 1 ) ;
  i2r_data = Xalloc(nb_octets) ;
  if (i2r_data == NULL) return EIMG_NOMEMORY ;

  fseek(stream, bmp_entete.off_bits, SEEK_SET) ;

  pt_out  = (int *) out->fd_addr ;
  pt_outl = (long *) out->fd_addr ;
  pt_outc = (unsigned char *) out->fd_addr ;
  lo_mligne = out->fd_wdwidth*out->fd_nplanes ;
  for (l = 0; l < bmp_entete.height; l++)
  {
    perf_start( PERF_DISK, &PerfInfo ) ;
    fread(i2r_data, nb_octets, 1, stream) ;
    perf_stop( PERF_DISK, &PerfInfo ) ;

    perf_start( PERF_IND2RASTER, &PerfInfo ) ;
    switch(bmp_entete.bit_count)
    {
      case 1  : memcpy(pt_out, i2r_data, nb_octets) ;
                pt_out += lo_mligne ;
                break ;
      case 4  : 
                if ( NaturalFormat == NULL )
                 find2raster() ;
                else
                {
                  long          n ;
                  unsigned char *data ;
                 
                  data = (unsigned char *) i2r_data ;
                  for ( n = 0; n < i2r_nb ; n++ )
                  {
                    *pt_natural++ = *data & 0x0F ;
                    *pt_natural++ = (*data++ >> 4 ) ;
                  }
                }
                break ;
      case 8  :
                if (img_analyse) pal_ajust() ;
                if ( NaturalFormat == NULL )
                  ind2raster() ;
                else
                {
                  memcpy( pt_natural, i2r_data, i2r_nb ) ;
                  pt_natural += i2r_nb ;
                }
                break ;
      case 24 : if ( out->fd_nplanes == 16 ) tc24targato16() ;
                else if ( out->fd_nplanes == 24 )
                {
                  long          x ;
                  unsigned char *t, *tp ;

                  tp = (unsigned char *) i2r_data ;
                  t  = (unsigned char *) pt_outc ;
                  for ( x = 0; x < bmp_entete.width; x++ )
                  {
                    *t++ = tp[2] ;
                    *t++ = tp[1] ;
                    *t++ = *tp ;
                    tp   += 3 ;
                  }
                  pt_outc += 3L*(out->fd_wdwidth << 4) ;
                }
                else if ( out->fd_nplanes == 32 )
                {
                  long          x ;
                  unsigned char *t, *tp ;

                  tp = (unsigned char *) i2r_data ;
                  t  = (unsigned char *) pt_outl ;
                  for ( x = 0; x < bmp_entete.width; x++ )
                  {
                    *t++ = tp[2] ;
                    *t++ = tp[1] ;
                    *t++ = *tp ;
                    *t++ = 0 ;
                    tp   += 3 ;
                  }
                  pt_outl += out->fd_wdwidth << 4 ;
                }
                break ;
    }
    perf_stop( PERF_IND2RASTER, &PerfInfo ) ;

    if ( MAY_UPDATE( wprog, l ) )
    {
      pc = (int) ((100L*l)/(long)bmp_entete.height) ;
      code  = wprog->ProgPc( wprog, pc, NULL ) ;
      if ( STOP_CODE( code ) )
      {
        ret = EIMG_USERCANCELLED ;
        break ;
      }
    }
  }

  Xfree(i2r_data) ;

  return ret ;
}

int bmp_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  FILE *stream ;
  int  bmp_nplanes ;
  int  ret ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  if (bmp_entete.width % 16) out->fd_w = (int) (16+(bmp_entete.width & 0xFFFFFFF0L)) ;
  else                       out->fd_w = (int) bmp_entete.width ;
  out->fd_h = (int) bmp_entete.height ;
  bmp_nplanes = bmp_entete.bit_count*bmp_entete.planes ;
  if ( bmp_nplanes >= 16 )
  {
    if ( Force16BitsLoad ) out->fd_nplanes = 16 ;
    else
    {
      if ( FinalNbPlanes >= 16 )  out->fd_nplanes = FinalNbPlanes ;
      else                        out->fd_nplanes = bmp_nplanes ;
    }
  }
  else
    out->fd_nplanes = bmp_nplanes ;
  out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL)
  {
    fclose(stream) ;
    return EIMG_NOMEMORY ;
  }
  out->fd_wdwidth = out->fd_w/16 ;
  out->fd_stand   = 0 ;

  img_raz(out) ;

  if ( may_use_natural_format( FinalNbPlanes, out->fd_nplanes ) )
  {
    NaturalFormat = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
    NaturalWidth  = (int) bmp_entete.width ;
  }

  ret = bmp_read( stream, out, wprog ) ;
  fclose(stream) ;

  return ret ;
}

int bmp_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  BMP_HEADER    header ;
  LUT32         lut ;
  FILE          *stream ;
  long          larg ;
  long          nb_bits, nb_octets ;
  int           *pt_img ;
  int           *pal ;
  int           l, pc ;
  int           nb_fill ;
  int           nb_bytes_per_sample ;
  unsigned char *b24 = NULL ;
  unsigned char *buffer = NULL ;
  void          *b ;
  char          fill[3] = {0, 0, 0} ;

  if ( (img->fd_nplanes != 1) &&  (img->fd_nplanes != 4) && (img->fd_nplanes != 8) &&
       (img->fd_nplanes != 16) &&  (img->fd_nplanes != 24) &&  (img->fd_nplanes != 32)
     )
    return EIMG_DATAINCONSISTENT ;

  stream = fopen(name, "wb") ;
  if (stream == NULL) return(-1) ;

  if (img->fd_nplanes >= 16) info->nplans = 24 ;
  header.type     = BMP_ID ;
  header.r1       = 0 ;
  header.r2       = 0 ;
  header.off_bits = sizeof(BMP_HEADER) ;
  if (img->fd_nplanes <= 8)
    header.off_bits += info->nb_cpal*sizeof(LUT32) ;

  header.size        = INFOHEADER_SIZE ;
  header.width       = img->fd_w ;
  header.height      = img->fd_h ;
  header.planes      = 1 ;
  header.bit_count   = info->nplans ;
  header.compression = 0 ;
  header.size_image  = ((long)img->fd_w*(long)img->fd_h*(long)info->nplans)/8 ;
  
  header.xpix_meter    = (long) (1000000.0/(float)info->lpix) ;
  header.ypix_meter    = (long) (1000000.0/(float)info->hpix) ;
  if (info->nplans <= 8) header.clr_used = 1 << info->nplans ;
  else                   header.clr_used = 0 ;
  header.clr_important = 0 ;

  bmp_header_reverse(&header) ;

  if (info->nplans == 24)
  {
    nb_bytes_per_sample = 3 ;
    b24 = (unsigned char *) Xalloc(nb_bytes_per_sample*(3+img->fd_w)) ;
    if (b24 == NULL)
    {
      fclose(stream) ;
      return EIMG_NOMEMORY ;
    }
    b = b24 ;
  }
  else
  {
    nb_bytes_per_sample = 1 ;
    buffer = (unsigned char *) Xalloc(3+img->fd_w) ;
    if (buffer == NULL)
    {
      fclose(stream) ;
      return EIMG_NOMEMORY ;
    }
    b = buffer ;
  }

  fwrite(&header, sizeof(BMP_HEADER), 1, stream) ;
  pal = info->palette ;
  if ((img->fd_nplanes <= 8) && (pal != NULL))
  {
    lut.o = 0 ;
    for (l = 0; l < info->nb_cpal; l++)
    {
      lut.r = RGBPMToRGB8B[*pal++] ;
      lut.g = RGBPMToRGB8B[*pal++] ;
      lut.b = RGBPMToRGB8B[*pal++] ;
      fwrite(&lut, sizeof(LUT32), 1, stream) ;
    }
  }

  nb_bits   = (long)img->fd_w*(long)info->nplans ;
  nb_octets = nb_bits/8 ;
  if (nb_bits % 8) nb_octets++ ;
  nb_fill = (int) (nb_octets % 4) ;
  pt_img = (int *) img->fd_addr ;
  larg   = (long)(img->fd_wdwidth*img->fd_nplanes) ;
  /* On commence par la fin */
  pt_img += (long)(img->fd_h-1)*larg ;
  for (l = 0; l < img->fd_h; l++)
  {
    switch(info->nplans)
    {
      case  1 : if (fwrite(pt_img, 1, nb_octets, stream) != nb_octets)
                {
                  fclose(stream) ;
                  Xfree(buffer) ;
                  return EIMG_DATAINCONSISTENT ;
                }
                break ;
      case  4 : raster2ind(pt_img, buffer, img->fd_w, info->nplans) ;
                ind4plans(buffer, img->fd_w) ;
                if (fwrite(buffer, 1, nb_octets, stream) != nb_octets)
                {
                  fclose(stream) ;
                  Xfree(buffer) ;
                  return EIMG_DATAINCONSISTENT ;
                }
                break ;
      case  8 : raster2ind(pt_img, buffer, img->fd_w, info->nplans) ;
                if (fwrite(buffer, 1, nb_octets, stream) != nb_octets)
                {
                  fclose(stream) ;
                  Xfree(buffer) ;
                  return EIMG_DATAINCONSISTENT ;
                }
                break ;
      case 24 : switch(img->fd_nplanes)
                {
                  case 16: tc16totarga24(pt_img, b, (long)img->fd_w) ;
                           break ;
                  case 24: tc24totarga24(pt_img, b, (long)img->fd_w) ;
                           break ;
                  case 32: tc32totarga24(pt_img, b, (long)img->fd_w) ;
                           break ;
                }
                if (fwrite( b, 1, nb_octets, stream ) != nb_octets)
                {
                  fclose(stream) ;
                  Xfree(b24) ;
                  return EIMG_DATAINCONSISTENT ;
                }
                break ;
    }

    if (nb_fill != 0)  fwrite(fill, nb_fill, 1, stream) ;
    if ( MAY_UPDATE( wprog, l ) )
    {
      pc = (int) ((100L*l)/(long)img->fd_h) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
    pt_img -= larg ;
  }

  fclose(stream) ;
  Xfree(b) ;

  header.file_size  = long_reverse(file_size(name)) ;
  header.size_image = long_reverse((nb_octets+(long)nb_fill)*(long)img->fd_h) ;
  stream = fopen(name, "rb+") ;
  if (stream != NULL)
  {
    fwrite(&header, sizeof(BMP_HEADER), 1, stream) ;
    fclose(stream) ;
  }

  return EIMG_SUCCESS ;
}

void bmp_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "BMP\0\0" ;

  caps->iid = IID_BMP ;
  strcpy( caps->short_name, "BMP" ) ;
  strcpy( caps->file_extension, "BMP" ) ;
  strcpy( caps->name, "Windows 3.11 Bitmap" ) ;
  caps->version = 0x0404 ;

  caps->import = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P24 | IEF_NOCOMP ;
  caps->export = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P24 | IEF_NOCOMP ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
