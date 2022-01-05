/*************************/
/* Gestion du format BMP */
/*************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include      "..\tools\xgem.h"
#include   "..\tools\logging.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\image_io.h"


#define BMP_ID      0x4D42
#define INFOHEADER_SIZE 40


typedef struct
{
  unsigned short type ;
  unsigned long  file_size ;
  unsigned short r1 ;
  unsigned short r2 ;
  unsigned long off_bits ;

  unsigned long  size ;
  unsigned long  width ;
  unsigned long  height ;
  unsigned short planes ;
  unsigned short bit_count ;
  unsigned long  compression ;
  unsigned long  size_image ;
  unsigned long  xpix_meter ;
  unsigned long  ypix_meter ;
  unsigned long  clr_used ;
  unsigned long  clr_important ;
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


void bmp_header_reverse(BMP_HEADER* h)
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

static int swap_pix_meter_micron(long x)
{
  return (int) (1000000.0/(float)x) ;
}

int bmp_identify(char* nom, INFO_IMAGE* inf)
{
  BMP_HEADER* header ;
  int         ret ;

  ret = ImgFOpen( inf, nom, NULL ) ;
  if ( ret != EIMG_SUCCESS ) return ret ;

  inf->specific = Xalloc( sizeof(BMP_HEADER) ) ;
  header = (BMP_HEADER*) inf->specific ;
  if ( header == NULL )
  {
    free_info( inf ) ;
    return EIMG_NOMEMORY ;
  }

  ImgFRead( inf, header, sizeof(BMP_HEADER) ) ;

  bmp_header_reverse( header ) ;
  if ( header->type != BMP_ID )
  {
    free_info( inf ) ;
    return EIMG_DATAINCONSISTENT ;
  }

  if ( header->planes != 1 )
  {
    free_info( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }

  inf->c.flipflop = FLIPFLOP_Y ;
  inf->compress = (int) header->compression ;
  if ( inf->compress != 0 )
  {
    free_info( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  inf->width   = (int) header->width ;
  inf->height  = (int) header->height ;
  inf->nplanes = header->bit_count*header->planes ;
  if ((inf->nplanes != 1) && (inf->nplanes != 4) &&
      (inf->nplanes != 8) && (inf->nplanes != 24))
  {
    free_info( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  inf->lpix = inf->hpix = 0x152 ;
  if ( header->xpix_meter > 0 ) inf->lpix = swap_pix_meter_micron( header->xpix_meter ) ;
  if ( header->ypix_meter > 0 ) inf->hpix = swap_pix_meter_micron( header->ypix_meter ) ;
  if ( inf->nplanes <= 8 )
  {
    LUT32  lut[256] ;
    LUT32* plut ;
    int*   pal ;
    int    n, total ;

    inf->nb_cpal = 1 << inf->nplanes ;
    if ( header->clr_used == 0 ) total = (int) inf->nb_cpal ;
    else                         total = (int) header->clr_used ;
    inf->palette = (int*) Xcalloc(6, total) ;
    if ( inf->palette == NULL )
    {
      free_info( inf ) ;
      return EIMG_NOMEMORY ;
    }
    /* 14 is Bitmap file header, DIB (Device independant Bitmap)    */
    /* Header size may vary, jump over DIB header to locate palette */
    ImgFSeek( inf, 14+header->size, SEEK_SET ) ;
    ImgFRead( inf, lut, total*sizeof(LUT32) ) ;
    pal = inf->palette ;
    for ( plut = lut, n = 0; n < total; n++, plut++ )
    {
      *pal++ = RGB8BToRGBPM[plut->r] ;
      *pal++ = RGB8BToRGBPM[plut->g] ;
      *pal++ = RGB8BToRGBPM[plut->b] ;
    }
  }

  return EIMG_SUCCESS ;
}

static int bmp_read(INFO_IMAGE* inf)
{
  GEM_WINDOW*   wprog = (GEM_WINDOW*) inf->prog ;
  MFDB*         out = &inf->mfdb ;
  BMP_HEADER*   header = (BMP_HEADER*) inf->specific ;
  long          lo_mligne, nb_octets, nb_bits ;
  long          *pt_outl ;
  int           *pt_out ;
  int           l, code ;
  int           ret = EIMG_SUCCESS ;
  unsigned char *pt_natural, *pt_outc ;

  pt_natural = inf->natural_format ;
  nb_bits    = header->width*header->bit_count*header->planes ;
  nb_octets  = nb_bits/8 ;
  if (nb_bits % 8) nb_octets++ ;
  i2r_nb = nb_octets ;
  if (nb_octets % 4) nb_octets = 4+4*(nb_octets>>2) ;
  i2r_init(out, (int)header->width, 1 ) ;
  i2r_data = Xalloc(nb_octets) ;
  if (i2r_data == NULL) return EIMG_NOMEMORY ;

  ImgFSeek( inf, header->off_bits, SEEK_SET) ;

  pt_out  = (int*) out->fd_addr ;
  pt_outl = (long*) out->fd_addr ;
  pt_outc = (unsigned char*) out->fd_addr ;
  lo_mligne = out->fd_wdwidth*out->fd_nplanes ;
  LoggingDo(LL_DEBUG, "bmp_read: bit_count=%d, nplanes=%d, NaturalFormat=%p, img_analyse=%d", header->bit_count, out->fd_nplanes, inf->natural_format, inf->img_analyse) ;
  for (l = 0; l < header->height; l++)
  {
    perf_start( PERF_DISK, &inf->perf_info ) ;
    ImgFRead( inf, i2r_data, nb_octets ) ;
    perf_stop( PERF_DISK, &inf->perf_info ) ;

    perf_start( PERF_IND2RASTER, &inf->perf_info ) ;
    switch(header->bit_count)
    {
      case 1  : memcpy(pt_out, i2r_data, nb_octets) ;
                pt_out += lo_mligne ;
                break ;
      case 4  : 
                if ( inf->natural_format == NULL ) find2raster() ;
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
                if (inf->img_analyse) pal_ajust() ;
                if ( inf->natural_format == NULL ) ind2raster() ;
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
                  for ( x = 0; x < header->width; x++ )
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
                  for ( x = 0; x < header->width; x++ )
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
    perf_stop( PERF_IND2RASTER, &inf->perf_info ) ;

    code = GWProgRange( wprog, l, header->height, NULL ) ;
    if ( PROG_CANCEL_CODE( code ) )
    {
      ret = EIMG_USERCANCELLED ;
      break ;
    }
  }

  Xfree( i2r_data ) ;

  return ret ;
}

int bmp_load(INFO_IMAGE* inf)
{
  MFDB*       out = &inf->mfdb ;
  BMP_HEADER* header = (BMP_HEADER*) inf->specific ;
  int         bmp_nplanes ;
  int         ret ;

  if ( header == NULL ) return EIMG_NOMEMORY ;
  if ( !inf->xfile.valid ) return EIMG_FILENOEXIST ;

  if ( header->width & 0x0F ) out->fd_w = (int) (16+(header->width & 0xFFFFFFF0L)) ;
  else                        out->fd_w = (int) header->width ;
  out->fd_h   = (int) header->height ;
  bmp_nplanes = header->bit_count*header->planes ;
  if ( bmp_nplanes >= 16 )
  {
    if ( inf->force_16b_load ) out->fd_nplanes = 16 ;
    else
    {
      if ( inf->final_nb_planes >= 16 )  out->fd_nplanes = inf->final_nb_planes ;
      else                               out->fd_nplanes = bmp_nplanes ;
    }
  }
  else out->fd_nplanes = bmp_nplanes ;
  out->fd_addr = img_alloc( out->fd_w, 1+out->fd_h, out->fd_nplanes ) ; /* +1 line because last line may be too long as nb bytes per line is aligned on 4 bytes */
  if ( out->fd_addr )
  {
    out->fd_wdwidth = out->fd_w>>4 ;
    out->fd_stand   = 0 ;
    img_raz(out) ;
    if ( may_use_natural_format( inf->final_nb_planes, out->fd_nplanes ) )
    {
      inf->natural_format = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
      inf->natural_width  = (int) header->width ;
    }
    ret = bmp_read( inf ) ;
  }
  else ret = EIMG_NOMEMORY ;

  img_post_loading( ret, inf ) ;

  return ret ;
}

int bmp_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog)
{
  BMP_HEADER header ;
  LUT32      lut ;
  FILE*      stream ;
  long       larg ;
  long       nb_bits, nb_octets ;
  int*       pt_img ;
  int*       pal ;
  int        l ;
  int        nb_fill ;
  int        nb_bytes_per_sample ;
  int        ret = EIMG_SUCCESS ;
  void*      b ;
  char       fill[3] = {0, 0, 0} ;

  if ( (img->fd_nplanes != 1) &&  (img->fd_nplanes != 4) && (img->fd_nplanes != 8) &&
       (img->fd_nplanes != 16) &&  (img->fd_nplanes != 24) &&  (img->fd_nplanes != 32)
     )
    return EIMG_DATAINCONSISTENT ;

  stream = CreateFileR( name ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  if ( img->fd_nplanes >= 16 ) info->nplanes = 24 ;
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
  header.bit_count   = info->nplanes ;
  header.compression = 0 ;
  header.size_image  = ((long)img->fd_w*(long)img->fd_h*(long)info->nplanes)/8 ;
  
  header.xpix_meter    = (long) swap_pix_meter_micron( info->lpix ) ;
  header.ypix_meter    = (long) swap_pix_meter_micron( info->hpix ) ;
  if ( info->nplanes <= 8 ) header.clr_used = 1 << info->nplanes ;
  else                      header.clr_used = 0 ;
  header.clr_important = 0 ;

  bmp_header_reverse( &header ) ;

  if ( info->nplanes == 24 ) nb_bytes_per_sample = 3 ;
  else                       nb_bytes_per_sample = 1 ;
  b = Xalloc( nb_bytes_per_sample*(3+img->fd_w) ) ;
  if ( b == NULL )
  {
    fclose( stream ) ;
    return EIMG_NOMEMORY ;
  }

  fwrite( &header, sizeof(BMP_HEADER), 1, stream ) ;
  pal = info->palette ;
  if ((img->fd_nplanes <= 8) && (pal != NULL))
  {
    lut.o = 0 ;
    for (l = 0; l < info->nb_cpal; l++)
    {
      lut.r = RGBPMToRGB8B[*pal++] ;
      lut.g = RGBPMToRGB8B[*pal++] ;
      lut.b = RGBPMToRGB8B[*pal++] ;
      fwrite( &lut, sizeof(LUT32), 1, stream ) ;
    }
  }

  nb_bits   = (long)img->fd_w*(long)info->nplanes ;
  nb_octets = nb_bits/8 ;
  if (nb_bits % 8) nb_octets++ ;
  nb_fill = (int) (nb_octets % 4) ;
  pt_img  = (int*) img->fd_addr ;
  larg    = (long)(img->fd_wdwidth*img->fd_nplanes) ;
  /* On commence par la fin */
  pt_img += (long)(img->fd_h-1)*larg ;
  for ( l = 0; (ret == EIMG_SUCCESS) && (l < img->fd_h); l++ )
  {
    switch(info->nplanes)
    {
      case  1 : 
                break ;
      case  4 : raster2ind( pt_img, (unsigned char*) b, img->fd_w, info->nplanes ) ;
                ind4plans( (unsigned char*) b, img->fd_w ) ;
                break ;
      case  8 : raster2ind( pt_img, (unsigned char*) b, img->fd_w, info->nplanes ) ;
                break ;
      case 24 : switch( img->fd_nplanes )
                {
                  case 16: tc16totarga24( pt_img, b, (long)img->fd_w ) ;
                           break ;
                  case 24: tc24totarga24( pt_img, b, (long)img->fd_w ) ;
                           break ;
                  case 32: tc32totarga24( pt_img, b, (long)img->fd_w ) ;
                           break ;
                }
                break ;
    }

    if ( fwrite( b, 1, nb_octets, stream ) != nb_octets ) ret = EIMG_DATAINCONSISTENT ;
    if ( nb_fill != 0 )  fwrite( fill, nb_fill, 1, stream ) ;
    (void)GWProgRange( wprog, l, img->fd_h, NULL ) ;
    pt_img -= larg ;
  }

  fclose( stream ) ;
  Xfree( b ) ;

  header.file_size  = long_reverse( file_size(name) ) ;
  header.size_image = long_reverse( (nb_octets+(long)nb_fill)*(long)img->fd_h ) ;
  stream = fopen(name, "rb+") ;
  if ( stream )
  {
    fwrite( &header, sizeof(BMP_HEADER), 1, stream ) ;
    fclose( stream ) ;
  }

  return ret ;
}

void bmp_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "BMP\0\0" ;

  caps->iid = IID_BMP ;
  strcpy( caps->short_name, "BMP" ) ;
  strcpy( caps->file_extension, "BMP" ) ;
  strcpy( caps->name, "Windows Bitmap" ) ;
  caps->version = 0x0411 ;

  caps->import = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P24 | IEF_NOCOMP ;
  caps->export = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P24 | IEF_NOCOMP ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
