/************************************/
/* TARGA image file format handling */
/************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include      "..\tools\xgem.h"
#include   "..\tools\logging.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\image_io.h"

typedef struct
{
  unsigned short origin ;
  unsigned short length ;
  unsigned char  depth ;
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
  unsigned short x_org ;
  unsigned short y_org ;
  unsigned short width ;
  unsigned short height ;
  unsigned char  depth ;
  unsigned char  descriptor ;
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


static void header_reverse(TARGA_HEADER* h)
{
  h->cmap.origin = int_reverse(h->cmap.origin) ;
  h->cmap.length = int_reverse(h->cmap.length) ;

  h->image.x_org  = int_reverse(h->image.x_org) ;
  h->image.y_org  = int_reverse(h->image.y_org) ;
  h->image.width  = int_reverse(h->image.width) ;
  h->image.height = int_reverse(h->image.height) ;
}

int targa_identify(char* nom, INFO_IMAGE* inf)
{
  char buffer[18] ; /* We need first 18 byte for identifying */
  int  ret ;

  ret = ImgFOpen( inf, nom, NULL ) ;
  if ( ret != EIMG_SUCCESS ) return ret ;

  ImgFRead( inf, buffer, 18 ) ;

  memcpy( &entete, buffer, 3 ) ;
  memcpy( &entete.cmap, &buffer[3], 5 ) ;
  memcpy( &entete.image, &buffer[3+5], 10 ) ;

  header_reverse( &entete ) ;

  inf->compress = entete.image_type ;
  /* Supported types:                  */
  /*  2:  Uncompressed, RGB images     */
  /* 10:  Runlength encoded RGB images */
  if ( (inf->compress != 2) && (inf->compress != 10) )
  {
    ImgFClose( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  inf->width   = entete.image.width ;
  inf->height  = entete.image.height ;
  inf->nplanes = entete.image.depth ;
  if ( (inf->nplanes != 16) && (inf->nplanes != 24) && (inf->nplanes != 32) )
  {
    ImgFClose( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  inf->lpix     = 0x152 ;
  inf->hpix     = 0x152 ;
  inf->palette  = NULL ;
  inf->nb_cpal  = 0 ;
  if ( (entete.image.descriptor & 0x20) == 0) inf->c.flipflop = FLIPFLOP_Y ;

  return EIMG_SUCCESS ;
}

typedef void (*TTCTARGA)(void);

static TTCTARGA getTCTarga(unsigned char depth, int nplanes_out)
{
  TTCTARGA TCTarga = NULL ;
 
  if ( depth == 32 )
  {
    switch( nplanes_out )
    {
      case 16 : TCTarga = tc32targato16 ;
                break ;
      case 24 : TCTarga = tc32targato24 ;
                break ;
      case 32 : TCTarga = tc32targato32 ;
                break ;
    }
  }
  else if ( depth == 24 )
  {
    switch( nplanes_out )
    {
      case 16 : TCTarga = tc24targato16 ;
                break ;
      case 24 : TCTarga = tc24targato24 ;
                break ;
      case 32 : TCTarga = tc24targato32 ;
                break ;
    }
  }
  else if ( depth == 16 )
  {
    switch( nplanes_out )
    {
      case 16 : TCTarga = tc16targato16 ;
                break ;
      case 24 : TCTarga = tc16targato24 ;
                break ;
      case 32 : TCTarga = tc16targato32 ;
                break ;
    }
  }

  return TCTarga ;
}

static int targa_read_raw(INFO_IMAGE* inf)
{
  GEM_WINDOW* wprog = (GEM_WINDOW*) inf->prog ;
  MFDB*       out = &inf->mfdb ;
  int         l ;
  int         lut_size ;
  int         ret = EIMG_SUCCESS ;
  long        offset, size ;
  void        (*TCTarga)(void) ;

  TCTarga = getTCTarga( entete.image.depth, out->fd_nplanes ) ;
  if ( TCTarga == NULL ) return EIMG_OPTIONNOTSUPPORTED ;

  i2r_init(out, entete.image.width, 1) ;
  i2r_nb = (long)entete.image.width*(long)(entete.image.depth >> 3) ;
  i2r_data = Xalloc(i2r_nb) ;
  if (i2r_data == NULL) return EIMG_NOMEMORY ;

  lut_size = entete.cmap.depth/3+entete.cmap.length ;
  offset   = 18+entete.length_of_identification+(lut_size >> 3) ;
  ImgFSeek( inf, offset, SEEK_SET ) ;

  for (l = 0; l < entete.image.height; l++)
  {
    perf_start( PERF_DISK, &inf->perf_info ) ;
    size = (long)entete.image.width * (long)(entete.image.depth >> 3) ;
    ImgFRead( inf, i2r_data, size ) ;
    perf_stop( PERF_DISK, &inf->perf_info ) ;

    perf_start( PERF_IND2RASTER, &inf->perf_info ) ;
    TCTarga() ;
    perf_stop( PERF_IND2RASTER, &inf->perf_info ) ;
    if ( PROG_CANCEL_CODE( GWProgRange( wprog, l, entete.image.height, NULL ) ) )
    {
      ret = EIMG_USERCANCELLED ;
      break ;
    }
  }
  Xfree( i2r_data ) ;

  return ret ;
}

static int targa_read_rle(INFO_IMAGE* inf)
{
  GEM_WINDOW* wprog = (GEM_WINDOW*) inf->prog ;
  MFDB*       out = &inf->mfdb ;
  size_t      nchunks = 0 ;
  int         done = 0 ;
  int         lut_size ;
  int         ret = EIMG_SUCCESS ;
  int         pattern_size = entete.image.depth >> 3 ;
  long        npix, npixmax, last_npix, prog_range_trigger ;
  long        offset ;
  void        (*TCTarga)(void) ;
  char        rle_buffer[128*4] ; /* Max 128 TC32 pixels */
  char        packet_header ;

  TCTarga = getTCTarga( entete.image.depth, out->fd_nplanes ) ;
  if ( TCTarga == NULL ) return EIMG_OPTIONNOTSUPPORTED ;

  i2r_init( out, entete.image.width, 1 ) ;
  i2r_data = rle_buffer ;

  lut_size = entete.cmap.depth/3+entete.cmap.length ;
  offset   = 18+entete.length_of_identification+(lut_size >> 3) ;
  ImgFSeek( inf, offset, SEEK_SET ) ;

  last_npix = npix = 0 ;
  npixmax            = (long)entete.image.width * (long)entete.image.height ;
  prog_range_trigger = npixmax >> 4 ;
  while ( !done )
  {
    /* Read header */
    if ( ImgFRead( inf, &packet_header, 1 ) == 1 )
    {
      int np = 1 + (packet_header & 0x7f) ;

      if ( npix + np > npixmax )
      {
        int new_np = (int)(npixmax-npix-1) ;

        if ( new_np < 0 ) break ;
        else
        {
          LoggingDo(LL_WARNING, "%ld + %d pixels to process would exceed %ld, limiting to %d", npix, np, npixmax, new_np) ;
          np = new_np ;
        }
      }
      nchunks++ ;
      i2r_nb = np*pattern_size ;
      if ( packet_header & 0x80 )
      {
        /* RLE packet */
        unsigned char pattern[4] ;

        if ( ImgFRead( inf, pattern, pattern_size ) == pattern_size )
        {
          if ( pattern_size == 2 ) /* TC16 */
          {
            unsigned int* pt = (unsigned int*) rle_buffer ;
            unsigned int  ipattern = *((unsigned int*) pattern) ;
            int  i ;

            for ( i = 0; i < np; i++ )
              *pt++ = ipattern ;
          }
          else if ( pattern_size == 3 ) /* TC24 */
          {
            unsigned char* pt = (unsigned char*) rle_buffer ;
            int            i ;

            for ( i = 0; i < np; i++ )
            {
              *pt++ = pattern[0] ;
              *pt++ = pattern[1] ;
              *pt++ = pattern[2] ;
            }
          }
          else if ( pattern_size == 4 ) /* TC32 */
          {
            unsigned long* pt = (unsigned long*) rle_buffer ;
            unsigned long  lpattern = *((unsigned long*) pattern) ;
            int  i ;

            for ( i = 0; i < np; i++ )
              *pt++ = lpattern ;
          }
          else ret = EIMG_OPTIONNOTSUPPORTED ;
          TCTarga() ;
          npix += np ;
        }
        else done = 1 ;
      }
      else
      {
        /* Raw packet */
        if ( ImgFRead( inf, rle_buffer, i2r_nb ) == i2r_nb )
        {
          TCTarga() ;
          npix += np ;
        }
        else done = 1 ;
      }
    }
    else done = 1 ;
    /* Normally we should call GWProgRange unconditionally as it takes care of not calling */
    /* ProgRange GUI update too often. However, here we may have *a lot* of chunks and     */
    /* GWProgRange calls will be an overkill, so here we call GWProgRange                  */
    /* Only if at least a minimum number of pixels is done.                                */
    if ( npix-last_npix > prog_range_trigger )
    {
      last_npix = npix ;
      if ( PROG_CANCEL_CODE( GWProgRange( wprog, npix, npixmax, NULL ) ) ) ret = EIMG_USERCANCELLED ;
    }
    if ( ret != EIMG_SUCCESS ) done = 1 ;
  }
  LoggingDo(LL_DEBUG, "targa_read_rle: %lu chunks decoded", nchunks) ;

  return ret ;
}

static int targa_read(INFO_IMAGE* inf)
{
  int ret ;

  switch( entete.image_type )
  {
    case 2:  ret = targa_read_raw( inf ) ;
             break ;
    case 10: ret = targa_read_rle( inf ) ;
             break ;
    default: ret = EIMG_OPTIONNOTSUPPORTED ;
             break ;
  }

  return ret ;
}

int targa_load(INFO_IMAGE* inf)
{
  MFDB* out = &inf->mfdb ;
  int   ret ;

  if ( !inf->xfile.valid )
  {
    LoggingDo(LL_ERROR, "targa_load: file descriptor is invalid") ;
    return EIMG_FILENOEXIST ;
  }

  out->fd_w = align16(entete.image.width) ;
  out->fd_h = (int) entete.image.height ;
  if ( entete.image.depth <= 8 ) out->fd_nplanes = entete.image.depth ;
  else
  {
    if ( inf->force_16b_load ) out->fd_nplanes = 16 ;
    else
    {
      if ( inf->final_nb_planes >= 16 )  out->fd_nplanes = inf->final_nb_planes ;
      else                               out->fd_nplanes = entete.image.depth ;
    }
  }

  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr )
  {
    out->fd_wdwidth = out->fd_w>>4 ;
    out->fd_stand   = 0 ;
    img_raz( out ) ;
    ret = targa_read( inf ) ;
  }
  else ret = EIMG_NOMEMORY ;

  img_post_loading( ret, inf ) ;

  return ret ;
}

static int targa_setsaveoption(INFO_IMAGE* inf, char* option, char* value)
{
  int ret = EIMG_OPTIONNOTSUPPORTED ;

  if ( memcmp( option, "flipflop", sizeof("flipflop")-1 ) == 0 )
  {
    int val = atoi( value ) ;

    if ( (val == 0) || (val == FLIPFLOP_Y) ) { inf->c.flipflop = val ; ret = EIMG_SUCCESS ; }
  }

  return ret ;
}

int targa_sauve(char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  TARGA_HEADER   header ;
  unsigned char* b24 ;
  void*          b ;
  FILE*          stream ;
  int*           pt_img ;
  int*           b16 ;
  long           larg ;
  int            l ;
  int            nb_bytes_per_sample ;
  int            nplanes ;

  if (img->fd_nplanes < 16) return EIMG_OPTIONNOTSUPPORTED ;

  stream = CreateFileR( name ) ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  img_setsaveoptions( info, targa_setsaveoption ) ;

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
  if (info->c.flipflop & FLIPFLOP_Y) header.image.descriptor = 0 ;
  else                               header.image.descriptor = 0x20 ;

  header_reverse(&header) ;

  if (img->fd_nplanes >= 24)
  {
    nb_bytes_per_sample = 3 ;
    b24 = (unsigned char *) Xalloc(nb_bytes_per_sample*img->fd_w) ;
    if (b24 == NULL)
    {
      fclose(stream) ;
      return EIMG_NOMEMORY ;
    }
    b = b24 ;
  }
  else
  {
    nb_bytes_per_sample = 2 ;
    b16 = (int *) Xalloc(nb_bytes_per_sample*img->fd_w) ;
    if (b16 == NULL)
    {
      fclose(stream) ;
      return EIMG_NOMEMORY ;
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
      Xfree(b) ;
      return EIMG_DATAINCONSISTENT ;
    }

    (void)GWProgRange( wprog, l, img->fd_h, NULL ) ;
    pt_img += larg ;
  }

  fclose(stream) ;
  Xfree(b) ;

  return EIMG_SUCCESS ;
}

void targa_getdrvcaps(INFO_IMAGE_DRIVER* caps)
{
  char kext[] = "TGA\0\0" ;

  caps->iid = IID_TARGA ;
  strcpy( caps->short_name, "Targa" ) ;
  strcpy( caps->file_extension, "TGA" ) ;
  strcpy( caps->name, "TrueVision Targa" ) ;
  caps->version = 0x0417 ;

  caps->import = IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE ;
  caps->export = IEF_P16 | IEF_P24 |           IEF_NOCOMP ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
