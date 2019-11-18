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


static void header_reverse(TARGA_HEADER *h)
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
  if (stream == NULL) return EIMG_FILENOEXIST ;

  fread(&entete, 3, 1, stream) ;
  fread(&entete.cmap, 5, 1, stream) ;
  fread(&entete.image, 10, 1, stream) ;
  fclose(stream) ;

  header_reverse(&entete) ;

  inf->compress = entete.image_type ;
  /* Supported types:                  */
  /*  2:  Uncompressed, RGB images     */
  /* 10:  Runlength encoded RGB images */
  if ( (inf->compress != 2) && (inf->compress != 10) ) return EIMG_OPTIONNOTSUPPORTED ;
  inf->width   = entete.image.width ;
  inf->height  = entete.image.height ;
  inf->nplanes = entete.image.depth ;
  if ( (inf->nplanes != 16) && (inf->nplanes != 24) && (inf->nplanes != 32) ) return EIMG_OPTIONNOTSUPPORTED ;
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

static int targa_read_raw(FILE *stream, INFO_IMAGE* inf)
{
  GEM_WINDOW* wprog = (GEM_WINDOW*) inf->prog ;
  MFDB*       out = &inf->mfdb ;
  int         l ;
  int         lut_size ;
  int         code, ret = EIMG_SUCCESS ;
  long        offset ;
  void        (*TCTarga)(void) ;

  TCTarga = getTCTarga( entete.image.depth, out->fd_nplanes ) ;
  if ( TCTarga == NULL ) return EIMG_OPTIONNOTSUPPORTED ;

  i2r_init(out, entete.image.width, 1) ;
  i2r_nb = (long)entete.image.width*(long)(entete.image.depth >> 3) ;
  i2r_data = Xalloc(i2r_nb) ;
  if (i2r_data == NULL) return EIMG_NOMEMORY ;

  lut_size = entete.cmap.depth/3+entete.cmap.length ;
  offset   = 18+entete.length_of_identification+(lut_size >> 3) ;
  fseek(stream, offset, SEEK_SET) ;

  for (l = 0; l < entete.image.height; l++)
  {
    perf_start( PERF_DISK, &inf->perf_info ) ;
    fread(i2r_data, entete.image.depth >> 3, entete.image.width, stream) ;
    perf_stop( PERF_DISK, &inf->perf_info ) ;

    perf_start( PERF_IND2RASTER, &inf->perf_info ) ;
    TCTarga() ;
    perf_stop( PERF_IND2RASTER, &inf->perf_info ) ;
    code = GWProgRange( wprog, l, entete.image.height, NULL ) ;
    if ( STOP_CODE( code ) )
    {
      ret = EIMG_USERCANCELLED ;
      break ;
    }
  }
  Xfree(i2r_data) ;

  return ret ;
}

static int targa_read_rle(FILE *stream, INFO_IMAGE* inf)
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
  fseek(stream, offset, SEEK_SET) ;

  last_npix = npix = 0 ;
  npixmax            = (long)entete.image.width * (long)entete.image.height ;
  prog_range_trigger = npixmax >> 4 ;
  while ( !done )
  {
    /* Read header */
    if ( fread( &packet_header, 1, 1, stream ) == 1 )
    {
      int np = 1 + (packet_header & 0x7f) ;

      nchunks++ ;
      i2r_nb = np*pattern_size ;
      if ( packet_header & 0x80 )
      {
        /* RLE packet */
        unsigned char pattern[4] ;

        /* Note that following fread calls are VERY slow on Aranym, image europa.tga takes */
        /* About 1min to load on Aranym but only 1s on MagicPC ! */
        if ( fread( pattern, pattern_size, 1, stream ) == 1 )
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
        else ret = EIMG_DECOMPRESERR ;
      }
      else
      {
        /* Raw packet */
        if ( fread( rle_buffer, i2r_nb, 1, stream ) == 1 )
        {
          TCTarga() ;
          npix += np ;
        }
        else ret = EIMG_DECOMPRESERR ;
      }
    }
    else done = 1 ;
    if ( npix > npixmax ) ret = EIMG_DECOMPRESERR ; /* However raster memory is already corrupted... */
    else
    {
      /* Normally we should call GWProgRange unconditionally as it takes care of not calling   */
      /* ProgRange GUI update too often. However, here we may have *a lot* of chunks and       */
      /* GWProgRange will call clock() which is very time consuming in Aranym/Mint, so here we */
      /* Call GWProgRange only if at least a minimum of pixels is done.                        */
      if ( npix-last_npix > prog_range_trigger )
      {
        last_npix = npix ;
        if ( STOP_CODE( GWProgRange( wprog, npix, npixmax, NULL ) ) ) ret = EIMG_USERCANCELLED ;
      }
    }
    if ( ret != EIMG_SUCCESS ) done = 1 ;
  }
  LoggingDo(LL_DEBUG, "targa_read_rle: %lu chunks decoded", nchunks) ;

  return ret ;
}

static int targa_read(FILE *stream, INFO_IMAGE* inf)
{
  int ret ;

  switch( entete.image_type )
  {
    case 2:  ret = targa_read_raw( stream, inf ) ;
             break ;
    case 10: ret = targa_read_rle( stream, inf ) ;
             break ;
    default: ret = EIMG_OPTIONNOTSUPPORTED ;
             break ;
  }

  return ret ;
}

int targa_load(INFO_IMAGE* inf)
{
  FILE* stream ;
  MFDB* out = &inf->mfdb ;
  int   ret ;

  stream = fopen(inf->filename, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  out->fd_w = ALIGN16(entete.image.width) ;
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
    return EIMG_NOMEMORY ;
  }
  out->fd_wdwidth = out->fd_w/16 ;
  out->fd_stand   = 0 ;

  img_raz(out) ;

  ret = targa_read( stream, inf ) ;
  fclose(stream) ;

  if ( ret != EIMG_SUCCESS )
  {
    if ( out->fd_addr ) Xfree( out->fd_addr ) ;
    out->fd_addr = NULL ;
  }

  return ret ;
}

int targa_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  TARGA_HEADER  header ;
  FILE          *stream ;
  long          larg ;
  int           *pt_img, *b16 ;
  int           l ;
  unsigned char *b24 ;
  void          *b ;
  int           nb_bytes_per_sample ;
  int           nplanes ;

  if (img->fd_nplanes < 16) return EIMG_OPTIONNOTSUPPORTED ;

  stream = fopen(name, "wb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

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

void targa_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "TGA\0\0" ;

  caps->iid = IID_TARGA ;
  strcpy( caps->short_name, "Targa" ) ;
  strcpy( caps->file_extension, "TGA" ) ;
  strcpy( caps->name, "TrueVision Targa" ) ;
  caps->version = 0x0412 ;

  caps->import = IEF_P16 | IEF_P24 | IEF_P32 | IEF_NOCOMP | IEF_RLE ;
  caps->export = IEF_P16 | IEF_P24 |           IEF_NOCOMP ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
