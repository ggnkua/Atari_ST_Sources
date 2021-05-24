/**************************/
/* Gestion du format TIFF */
/**************************/
#include    <ext.h>
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include               "defs.h"
#include       "..\tools\lzw.h"
#include      "..\tools\xgem.h"
#include  "..\tools\packbits.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\image_io.h"
#include  "..\tools\msgtxt.h"
#include  "..\tools\logging.h"

/* Byte ordering as stated in first 2 bytes of file */
#define MOTOROLA 0x4D4D
#define INTEL    0x4949

/* Tag type */
#define TBYTE     1
#define TASCII    2
#define TSHORT    3
#define TLONG     4
#define TRATIONAL 5

/* Tag purpose */
#define NEW_SUBFILE_TYPE    254
#define IMAGE_WIDTH         256
#define IMAGE_LENGTH        257
#define BITS_PER_SAMPLE     258
#define COMPRESSION         259
#define PHOTOMETRIC         262
#define DOCUMENTNAME        269
#define IMAGEDESCRIPTION    270
#define MAKE                271
#define MODEL               272
#define STRIP_OFFSETS       273
#define ROWS_PER_STRIP      278
#define SAMPLES_PER_PIXEL   277
#define STRIP_BYTE_COUNTS   279
#define X_RESOLUTION        282
#define Y_RESOLUTION        283
#define PLANAR_CONFIG       284
#define PAGENAME            285
#define RESOLUTION_UNIT     296
#define SOFTWARE            305
#define DATETIME            306
#define ARTIST              315
#define HOSTCOMPUTER        316
#define PREDICTOR           317
#define COLOR_MAP           320
#define TILE_WIDTH          322
#define TILE_LENGTH         323
#define TILE_OFSETS         324
#define TILE_BYTECOUNTS     325
#define COPYRIGHT           33432U

/* Supported compressions */
#define TC_NONE             1
#define TC_LZW              5
#define TC_PACKBITS         32773U

extern HMSG hMsg ; /* For accessing messages */


typedef struct
{
  unsigned long numerateur ;
  unsigned long denominateur ;
}
FRACTION ;

typedef struct
{
  unsigned int  byte_order ;
  unsigned int  version ;
  unsigned long ifd_offset ;
}
TIFF_HEADER ;

typedef struct
{
  unsigned int  tag ;
  unsigned int  type ;
  unsigned long length ;
  unsigned long offset ;
}
TIFF_TAG ;

typedef struct _TIFF_SPECIFIC
{
  unsigned int  BitsPerSample ;
  unsigned int  SamplesPerPixel ;
  unsigned int  ResolutionUnit ;
  unsigned int  Compression ;
  unsigned int  PhotometricInterpretation ;
  unsigned int  TStripOffsets ;
  unsigned int  TStripByteCounts ;
  unsigned int  Predictor ;
  unsigned int  ByteOrder ;
  unsigned int  StripsPerImage ;
  unsigned int  PlanarConfiguration ;
  unsigned long ImageWidth ;
  unsigned long ImageLength ;
  unsigned long StripOffsets ;
  unsigned long RowsPerStrip ;
  unsigned long StripByteCounts ;
  unsigned long XResolution ; /* Offset to data */
  unsigned long YResolution ; /* Offset to data */
  unsigned long ColorMap ;
  unsigned long NewSubfileType ;
  FRACTION      XRatio ;
  FRACTION      YRatio ;

  /* Dynamically allocated data for load/save processing */
  unsigned char* buffer ;
  unsigned char* dcp_out ;
  unsigned long* ltab_sbc, *ltab_so ;
  unsigned int*  itab_sbc, *itab_so ;
}
TIFF_SPECIFIC, *PTIFF_SPECIFIC ;


/* Limited to informational tags */
static int   tag_ids[] =   {    DOCUMENTNAME, IMAGEDESCRIPTION,   MAKE,   MODEL,    PAGENAME,   SOFTWARE,    DATETIME,   ARTIST,    HOSTCOMPUTER,   COPYRIGHT } ;
static char* tag_names[] = { "Document Name",    "Description", "Make", "Model", "Page Name", "Software", "Date Time", "Artist", "Host Computer", "Copyright" } ;


static void tag_file2mem(int byte_order, TIFF_TAG* tag)
{
/*  long original_offset = tag->offset ;*/

  if ( byte_order == INTEL )
  {
    tag->tag    = int_reverse(tag->tag) ;
    tag->type   = int_reverse(tag->type) ;
    tag->length = long_reverse(tag->length) ;
    if ( tag->type == TSHORT ) tag->offset = int_reverse( (int) (tag->offset >> 16) ) ;
    else                       tag->offset = long_reverse(tag->offset) ;
  }
  else if ( (tag->type == TSHORT) && (tag->length == 1) ) tag->offset = (int)(tag->offset >> 16) ;
/*
  LoggingDo(LL_DEBUG, "Tag value %u", tag->tag);
  LoggingDo(LL_DEBUG, "     type %u", tag->type);
  LoggingDo(LL_DEBUG, "   length %ld", tag->length);
  LoggingDo(LL_DEBUG, "   offset %ld", tag->offset);
  LoggingDo(LL_DEBUG, " --offset %ld", original_offset);*/
}

static void tag_mem2file(int byte_order, TIFF_TAG* tag)
{
  if ( byte_order == INTEL )
  {
    tag->tag    = int_reverse(tag->tag) ;
    tag->type   = int_reverse(tag->type) ;
    tag->length = long_reverse(tag->length) ;
    if ( tag->type == TSHORT ) tag->offset = int_reverse( (int)(tag->offset << 16) ) ;
    else                       tag->offset = long_reverse(tag->offset) ;
  }
  else if ( (tag->type == TSHORT) && (tag->length == 1) ) tag->offset = (long)tag->offset << 16 ;
}

static void fraction_reverse(FRACTION* frac)
{
  frac->numerateur   = long_reverse(frac->numerateur) ;
  frac->denominateur = long_reverse(frac->denominateur) ;
}

static void tiff2vdipalette(unsigned int* tiffpal, INFO_IMAGE* inf)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) inf->specific ;
  unsigned int*  pttiff ;
  int*           ptvdi ;
  int            nb_col, tcol, i, j ;
  int            ind ;

  nb_col = 1 << tiff_spec->BitsPerSample ;
  tcol   = nb_col ;
  if (tcol < nb_colors) tcol = nb_colors ;
  inf->palette = (int *) Xalloc(tcol*6) ;
  if (inf->palette == NULL) return ;
  inf->nb_cpal = nb_col ;

  pttiff = tiffpal ;
  ptvdi  = inf->palette ;
  for (i = 0; i < nb_col; i++)
  {
    for ( ind = i, j = 0; j < 3; j++, ind += nb_col )
    {
      if ( tiff_spec->ByteOrder == INTEL ) pttiff[ind] = int_reverse(pttiff[ind]) ;
      *ptvdi = (int) (pttiff[ind] >> 6) ;
      if ( *ptvdi > 1000 ) *ptvdi = 1000 ;
      ptvdi++ ;
    }
  }
}

static int resol(FRACTION* frac, TIFF_SPECIFIC* tiff_spec)
{
  double val = 1.0 ;
 
  if ( frac->numerateur )
  {
    val = (double)frac->denominateur/(double)frac->numerateur ; /* Size of a pixel per unit */
    if ( tiff_spec->ResolutionUnit == 2 ) val *= 25400.0 ;      /* inches->microns          */
    else                                  val *= 10000.0 ;      /* cm->microns              */
  }

  return (int) val ;
}

static int set_bwpal(INFO_IMAGE* inf)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) inf->specific ;
  double         coe ;
  int*           pt ;
  int            i ;
  int            tcol, val ;

  tcol = 1 << tiff_spec->BitsPerSample ;
  coe  = 1000.0/(double)(tcol-1) ;
  if (nb_colors > tcol) tcol = nb_colors ;
  inf->palette = Xalloc(6*tcol) ;
  if (inf->palette == NULL) return EIMG_NOMEMORY ;
  inf->nb_cpal = 1 << tiff_spec->BitsPerSample ;
  memzero(inf->palette, tcol*6) ;

  pt = (int*) inf->palette ;
  for (i = 0; i < inf->nb_cpal; i++)
  {
    val   = (int) ((double)i*coe);
    *pt++ = val ;
    *pt++ = val ;
    *pt++ = val ;
  }

  inf->nb_cpal = 256 ;

  return 0 ;
}

static int set_wbpal(INFO_IMAGE* inf)
{
  int ret = set_bwpal(inf ) ;

  if ( ret == 0 )
  {
    /* Just revert the scale 0 ---> 1000 */
    int* pt = (int*) inf->palette ;
    int  i ;

    for (i = 0; i < 3*inf->nb_cpal; i++, pt++)
      *pt = 1000 - (*pt) ;
  }

  return ret ;
}

static void dcp_predictor(unsigned char *data, long nb, unsigned long width)
{
  long          i, nbx ;
  int           val ;
  int           red, green, blue ;
  unsigned char *pt ;

  pt    = data ;
  red   = *pt++ ;
  green = *pt++ ;
  blue  = *pt++ ;
  nbx   = 1 ;
  for (i = 3; i < nb; i = i+3)
  {
    val   = (char)*pt ;
    val   = val+red ;
    red   = val ;
    *pt++ = (unsigned char) val ;
    val   = (char)*pt ;
    val   = val+green ;
    green = val ;
    *pt++ = (unsigned char) val ;
    val   = (char)*pt ;
    val   = val+blue ;
    blue  = val ;
    *pt++ = (unsigned char) val ;
    nbx++ ;
    if (nbx == width)
    {
      i = i+3 ;
      if (i < nb)
      {
        red   = *pt++ ;
        green = *pt++ ;
        blue  = *pt++ ;
        nbx   = 1 ;
      }
    }
  }
}

static void cpi_predictor(unsigned char *data, long nb, unsigned long width)
{
  long i, nbx ;
  int  val ;
  int  index ;
  char *pt ;

  pt    = (char *) data ;
  index = *pt++ ;
  nbx   = 1 ;
  for (i = 1; i < nb; i++)
  {
    val   = *pt ;
    val   = val-index ;
    index = *pt ;
    *pt++ = val ;
    nbx++ ;
    if (nbx == width)
    {
      i++ ;
      if (i < nb)
      {
        index = *pt++ ;
        nbx   = 1 ;
      }
    }
  }
}

static void dcpi_predictor(unsigned char *data, long nb, unsigned long width)
{
  long          i, nbx ;
  int           val ;
  int           index ;
  unsigned char *pt ;

  pt    = data ;
  index = *pt++ ;
  nbx   = 1 ;
  for (i = 1; i < nb; i++)
  {
    val   = (char)*pt ;
    val   = val+index ;
    *pt++ = val ;
    index = val ;
    nbx++ ;
    if (nbx == width)
    {
      i++ ;
      if (i < nb)
      {
        index = *pt++ ;
        nbx   = 1 ;
      }
    }
  }
}

static void cp_predictor(unsigned char *data, long nb, unsigned long width)
{
  long i, nbx ;
  int  val ;
  int  red, green, blue ;
  char *pt ;

  pt    = (char *) data ;
  red   = *pt++ ;
  green = *pt++ ;
  blue  = *pt++ ;
  nbx   = 1 ;
  for (i = 3; i < nb; i = i+3)
  {
    val   = *pt ;
    val   = val-red ;
    red   = *pt ;
    *pt++ = val ;
    val   = *pt ;
    val   = val-green ;
    green = *pt ;
    *pt++ = val ;
    val   = *pt ;
    val   = val-blue ;
    blue  = *pt ;
    *pt++ = val ;
    nbx++ ;
    if (nbx == width)
    {
      i = i+3 ;
      if (i < nb)
      {
        red   = *pt++ ;
        green = *pt++ ;
        blue  = *pt++ ;
        nbx   = 1 ;
      }
    }
  }
}

static char* GetTagName(int tag)
{
  char* tag_name = NULL ;
  int   i ;

  for ( i = 0; (tag_name == NULL) && (i < ARRAY_SIZE(tag_ids)); i++ )
    if ( tag == tag_ids[i] ) tag_name = tag_names[i] ;

  if ( tag_name == NULL ) tag_name = "???" ;

  return tag_name ;
}

static int GetTagId(char* tag_name)
{
  int i, tag_id = 0 ;

  for ( i = 0; (tag_id == 0) && (i < ARRAY_SIZE(tag_ids)); i++ )
    if ( strcmpi( tag_names[i], tag_name ) == 0 ) tag_id = tag_ids[i] ; ;

  return tag_id ;
}

static int tag_interpret(TIFF_TAG* tag, INFO_IMAGE* inf)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) inf->specific ;
  unsigned long  tag_value ;
  unsigned int   buffer[768] ; /* For palette but can hold some informational data */
  int            storeko = 0 ;
  int            ret = EIMG_SUCCESS ;

  tag_value = tag->offset ;
  switch( tag->tag )
  {
    case BITS_PER_SAMPLE   : if (tag->length == 1) tiff_spec->BitsPerSample = (unsigned int) tag_value ;
                             else                  tiff_spec->BitsPerSample = 8 ;
                             if ((tiff_spec->BitsPerSample != 1) && (tiff_spec->BitsPerSample != 4) && (tiff_spec->BitsPerSample != 8))
                               ret = EIMG_OPTIONNOTSUPPORTED ;
                             inf->nplanes = (short)tiff_spec->BitsPerSample*(short)tiff_spec->SamplesPerPixel ;
                             LoggingDo(LL_DEBUG,"TIFF BitsPerSample=%d", tiff_spec->BitsPerSample) ;
                             break ;
    case SAMPLES_PER_PIXEL : tiff_spec->SamplesPerPixel = (unsigned int) tag_value ;
                             if ((tiff_spec->SamplesPerPixel != 1) && (tiff_spec->SamplesPerPixel != 3))
                               ret = EIMG_OPTIONNOTSUPPORTED ;
                             inf->nplanes = (short)tiff_spec->BitsPerSample*(short)tiff_spec->SamplesPerPixel ;
                             LoggingDo(LL_DEBUG,"TIFF SamplesPerPixel=%d", tiff_spec->SamplesPerPixel) ;
                             break ;
    case COLOR_MAP         : ImgFSeek( inf, tag->offset, SEEK_SET ) ;
                             ImgFRead( inf, buffer, 6*(1 << tiff_spec->BitsPerSample) ) ;
                             tiff2vdipalette(buffer, inf) ;
                             if (inf->palette == NULL) ret = EIMG_NOMEMORY ;
                             break ;
    case IMAGE_WIDTH       : tiff_spec->ImageWidth = tag_value ;
                             if (tiff_spec->ImageWidth > 32767L) ret = EIMG_OPTIONNOTSUPPORTED ;
                             inf->width = (int) tiff_spec->ImageWidth ;
                             break ;
    case IMAGE_LENGTH      : tiff_spec->ImageLength  = tag_value ;
                             if (tiff_spec->ImageLength > 32767L) ret = EIMG_OPTIONNOTSUPPORTED ;
                             inf->height = (int) tiff_spec->ImageLength ;
                             break ;
    case COMPRESSION       : tiff_spec->Compression = (unsigned int) tag_value ;
                             inf->compress          = tiff_spec->Compression ;
                             if ( (tiff_spec->Compression != TC_NONE) && (tiff_spec->Compression != TC_LZW)  && (tiff_spec->Compression != TC_PACKBITS) )
                               ret = EIMG_UNKNOWNCOMPRESSION ;
                             break ;
    case STRIP_OFFSETS     : tiff_spec->TStripOffsets = tag->type ;
                             tiff_spec->StripOffsets  = tag->offset ;
                             break ;
    case ROWS_PER_STRIP    : tiff_spec->RowsPerStrip = tag_value ;
                             break ;
    case STRIP_BYTE_COUNTS : tiff_spec->TStripByteCounts = tag->type ;
                             tiff_spec->StripByteCounts = tag->offset ;
                             break ;
    case RESOLUTION_UNIT   : tiff_spec->ResolutionUnit = (unsigned int) tag_value ;
                             inf->lpix = resol( &tiff_spec->XRatio, tiff_spec ) ;
                             inf->hpix = resol( &tiff_spec->YRatio, tiff_spec ) ;
                             break ;
    case X_RESOLUTION      : ImgFSeek( inf, tag->offset, SEEK_SET ) ;
                             ImgFRead( inf, &tiff_spec->XRatio, sizeof(FRACTION) ) ;
                             if ( tiff_spec->ByteOrder == INTEL ) fraction_reverse( &tiff_spec->XRatio ) ;
                             break ;
    case Y_RESOLUTION      : ImgFSeek( inf, tag->offset, SEEK_SET ) ;
                             ImgFRead( inf, &tiff_spec->YRatio, sizeof(FRACTION) ) ;
                             if ( tiff_spec->ByteOrder == INTEL ) fraction_reverse( &tiff_spec->YRatio ) ;
                             break ;
    case PHOTOMETRIC       : tiff_spec->PhotometricInterpretation = (unsigned int) tag_value ;
                             if ( tiff_spec->PhotometricInterpretation > 3 ) ret = EIMG_OPTIONNOTSUPPORTED ;
                             break ;
    case PLANAR_CONFIG     : tiff_spec->PlanarConfiguration = (unsigned int) tag_value ;
                             if ( tiff_spec->PlanarConfiguration != 1 )
                               ret = EIMG_OPTIONNOTSUPPORTED ;
                             break ;
    case PREDICTOR         : tiff_spec->Predictor = (unsigned int) tag_value ;
                             if ( (tiff_spec->Predictor != 1) && (tiff_spec->Predictor != 2) )
                               ret = EIMG_OPTIONNOTSUPPORTED ;
                             inf->c.f.tif.predictor = tiff_spec->Predictor ;
                             break ;
    case NEW_SUBFILE_TYPE  : tiff_spec->NewSubfileType = tag_value ;
                             if ( tiff_spec->NewSubfileType != 0 )
                               ret = EIMG_OPTIONNOTSUPPORTED ;
                             break ;
    case DOCUMENTNAME      :
    case IMAGEDESCRIPTION  :
    case MAKE              :
    case MODEL             :
    case SOFTWARE          :
    case DATETIME          :
    case ARTIST            :
    case HOSTCOMPUTER      :
    case COPYRIGHT         : if ( tag->length < sizeof(buffer) )
                             {
                               ImgFSeek( inf, tag->offset, SEEK_SET ) ;
                               ImgFRead( inf, buffer, tag->length ) ;
                               if ( add_informations( inf, GetTagName(tag->tag), (char*)buffer ) == NULL ) storeko = 1 ;
                             }
                             else storeko = 1 ;
                             if ( storeko ) LoggingDo(LL_INFO, "Can't store information for TIFF tag %u length %ld", tag->tag, tag->length) ;
                             break ;
    case TILE_WIDTH:
    case TILE_LENGTH:
    case TILE_OFSETS:
    case TILE_BYTECOUNTS:    LoggingDo(LL_WARNING, "TIFF tag %u related to tiles is not supported", tag->tag) ;
                             ret = EIMG_OPTIONNOTSUPPORTED ;
    default:                 LoggingDo(LL_INFO, "Unknown TIFF tag %u, value %lu", tag->tag, tag_value) ;
                             break ;
  }

  return ret ;
}

static int tiff_tags(INFO_IMAGE* inf)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) inf->specific ;
  TIFF_TAG*      tags ;
  unsigned int   nb_tags, i ;
  int            ret = EIMG_SUCCESS ;

  tiff_spec->BitsPerSample       = 1 ;
  tiff_spec->SamplesPerPixel     = 1 ;
  inf->nplanes                   = tiff_spec->BitsPerSample*tiff_spec->SamplesPerPixel ;
  tiff_spec->ResolutionUnit      = 2 ;
  tiff_spec->Compression         = TC_NONE ;
  tiff_spec->StripByteCounts     = 0 ;
  tiff_spec->RowsPerStrip        = 0xFFFFFFFFUL ;
  tiff_spec->PlanarConfiguration = 1 ;
  tiff_spec->Predictor           = 1 ;

  ImgFRead( inf, &nb_tags, 2 ) ;
  if ( tiff_spec->ByteOrder == INTEL ) nb_tags = int_reverse( nb_tags ) ;

  tags = (TIFF_TAG*) Xcalloc( nb_tags, sizeof(TIFF_TAG) ) ;
  if ( tags == NULL ) return EIMG_NOMEMORY ;
  ImgFRead( inf, tags, nb_tags*sizeof(TIFF_TAG) ) ;

  inf->lpix = inf->hpix = 0x152 ; /* By default */
  for ( i = 0; i < nb_tags; i++ )
  {
    tag_file2mem( tiff_spec->ByteOrder, &tags[i] ) ;
    ret = tag_interpret( &tags[i], inf ) ;
    if ( ret != EIMG_SUCCESS )
    {
      LoggingDo(LL_INFO, "TIFF tag %u, value %lu prevented image loading", tags[i].tag, tags[i].offset) ;
      break ;
    }
  }

  Xfree( tags ) ;

  return ret ;
}

int tiff_identify(char* nom, INFO_IMAGE* inf)
{
  TIFF_HEADER    entete ;
  TIFF_SPECIFIC* tiff_spec ;
  int            ret ;

  ret = ImgFOpen( inf, nom, &inf->file_size ) ;
  if ( ret != EIMG_SUCCESS ) return ret ;

  ImgFRead( inf, &entete, sizeof(TIFF_HEADER) ) ;
  if ( (entete.byte_order != MOTOROLA) && (entete.byte_order != INTEL) )
  {
    free_info( inf ) ;
    return EIMG_DATAINCONSISTENT ;
  }

  if ( entete.byte_order == INTEL ) entete.version = int_reverse( entete.version ) ;
  if ( entete.version != 0x2A ) return EIMG_DATAINCONSISTENT ;

  inf->specific = Xcalloc( 1, sizeof(TIFF_SPECIFIC) ) ;
  tiff_spec     = (TIFF_SPECIFIC*) inf->specific ;
  if ( tiff_spec == NULL )
  {
    free_info( inf ) ;
    return EIMG_NOMEMORY ;
  }
  tiff_spec->ByteOrder   = entete.byte_order ;
  inf->c.f.tif.byteorder = tiff_spec->ByteOrder ;

  if ( tiff_spec->ByteOrder == INTEL )
  {
    entete.version    = int_reverse( entete.version ) ;
    entete.ifd_offset = long_reverse( entete.ifd_offset ) ;
  }

  ImgFSeek( inf, entete.ifd_offset, SEEK_SET ) ;
  ret = tiff_tags( inf ) ;
  if ( ret != EIMG_SUCCESS ) free_info( inf ) ;
  else
  {
    inf->compress          = tiff_spec->Compression ;
    inf->c.f.tif.predictor = tiff_spec->Predictor ;

    if ( tiff_spec->BitsPerSample != 1 )
    {
      if ( tiff_spec->PhotometricInterpretation == 0 )      ret = set_wbpal( inf ) ;
      else if ( tiff_spec->PhotometricInterpretation == 1 ) ret = set_bwpal( inf ) ;
    }
    else
    {
      inf->nb_cpal = 0 ;
      inf->palette = NULL ;
    }

    if ( tiff_spec->StripByteCounts == 0 )
      tiff_spec->StripByteCounts = tiff_spec->ImageWidth*tiff_spec->ImageLength*tiff_spec->SamplesPerPixel ;
  }

  return ret ;
}

static void tiff_release_dynamic(TIFF_SPECIFIC* tiff_spec)
{
  if ( tiff_spec->buffer ) Xfree( tiff_spec->buffer ) ;
  if ( tiff_spec->dcp_out ) Xfree( tiff_spec->dcp_out ) ;
  if ( tiff_spec->ltab_sbc ) Xfree( tiff_spec->ltab_sbc ) ; /* Note ltab_sbc = itab_sbc */
  if ( tiff_spec->ltab_so ) Xfree( tiff_spec->ltab_so ) ;   /* Note ltab_so = itab_so   */
  tiff_spec->buffer   = NULL ;
  tiff_spec->dcp_out  = NULL ;
  tiff_spec->ltab_sbc = NULL ;
  tiff_spec->ltab_so  = NULL ;
  tiff_spec->itab_sbc = NULL ;
  tiff_spec->itab_so  = NULL ;
}

static int tiff_read(INFO_IMAGE* inf)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) inf->specific ;
  GEM_WINDOW*    wprog = (GEM_WINDOW*) inf->prog ;
  MFDB*          out = &inf->mfdb ;
  size_t         size ;
  unsigned char* temp ;
  unsigned char* pt_natural ;
  int*           last_line ;
  long           taille ;
  unsigned long  nb_strip, i, offset ;
  unsigned long  nb_pts, num_pts ;
  unsigned long  num ;
  int            code ;
  int            nl ;

  pt_natural = (unsigned char*) inf->natural_format ;
  i2r_init( out, (int) tiff_spec->ImageWidth, 1 ) ;
  if ( tiff_spec->RowsPerStrip != 0xFFFFFFFFUL ) nb_strip = (tiff_spec->ImageLength+tiff_spec->RowsPerStrip-1)/tiff_spec->RowsPerStrip ;
  else
  {
    nb_strip                = 1 ;
    tiff_spec->RowsPerStrip = tiff_spec->ImageLength ;
  }

  LoggingDo(LL_DEBUG, "TIFFRead, RowsPerStrip=%lu, nb_strip=%lu", tiff_spec->RowsPerStrip, nb_strip) ;
  if (tiff_spec->TStripByteCounts == TSHORT) taille = nb_strip*2 ;
  else                                       taille = nb_strip*4 ;
  tiff_spec->itab_sbc = (unsigned int*) Xalloc(taille) ;
  if (tiff_spec->itab_sbc == NULL) return EIMG_NOMEMORY ;
  tiff_spec->ltab_sbc = (unsigned long*) tiff_spec->itab_sbc ;
  if (taille > 4)
  {
    ImgFSeek( inf, tiff_spec->StripByteCounts, SEEK_SET) ;
    ImgFRead( inf, tiff_spec->itab_sbc, taille ) ;
  }
  else
    memcpy(tiff_spec->itab_sbc, &tiff_spec->StripByteCounts, taille) ;

  if (tiff_spec->TStripOffsets == TSHORT) taille = nb_strip*2*tiff_spec->SamplesPerPixel ;
  else                                    taille = nb_strip*4*tiff_spec->SamplesPerPixel ;
  tiff_spec->itab_so = (unsigned int*) Xalloc(taille) ;
  if (tiff_spec->itab_so == NULL) return EIMG_NOMEMORY ;

  tiff_spec->ltab_so = (unsigned long*) tiff_spec->itab_so ;
  if (taille > 4*tiff_spec->SamplesPerPixel)
  {
    ImgFSeek( inf, tiff_spec->StripOffsets, SEEK_SET) ;
    ImgFRead( inf, tiff_spec->itab_so, taille ) ;
  }
  else
    memcpy(tiff_spec->itab_so, &tiff_spec->StripOffsets, taille) ;

  if ( (tiff_spec->ByteOrder == INTEL) && (taille > 4*tiff_spec->SamplesPerPixel) )
  {
    for (i = 0; i < nb_strip; i++)
    {
      if (tiff_spec->TStripByteCounts == TSHORT) tiff_spec->itab_sbc[i] = int_reverse(tiff_spec->itab_sbc[i]) ;
      else                                       tiff_spec->ltab_sbc[i] = long_reverse(tiff_spec->ltab_sbc[i]) ;
      if (tiff_spec->TStripOffsets == TSHORT)    tiff_spec->itab_so[i]  = int_reverse(tiff_spec->itab_so[i]) ;
      else                                       tiff_spec->ltab_so[i]  = long_reverse(tiff_spec->ltab_so[i]) ;
    }
  }

  if (nb_strip > 1)
  {
    taille = 0 ;
    for (i = 0; i < nb_strip; i++)
    {
      if (tiff_spec->TStripByteCounts == TSHORT) i2r_nb = tiff_spec->itab_sbc[i] ;
      else                                       i2r_nb = tiff_spec->ltab_sbc[i] ;
      if (i2r_nb > taille) taille = i2r_nb ;
    }
  }
  else
  {
    taille = inf->file_size ;
    if (taille == -1) return EIMG_DATAINCONSISTENT ;
  }
  tiff_spec->buffer = (unsigned char*) Xalloc(taille) ;
  if (tiff_spec->buffer == NULL) return EIMG_NOMEMORY ;

  num_pts = 0 ;
  if (tiff_spec->BitsPerSample == 1)
  {
    nb_pts = tiff_spec->ImageWidth/8 ;
    if (tiff_spec->ImageWidth % 8) nb_pts++ ;
    nb_pts *= 8 ;
    nb_pts *= tiff_spec->ImageLength ;
    
  }
  else nb_pts = tiff_spec->ImageWidth*tiff_spec->ImageLength ;

  if ( tiff_spec->Compression == TC_PACKBITS )
  {
    LoggingDo(LL_INFO, "Image compression: PACKBITS") ;
    size    = 16L*(long)out->fd_wdwidth*(tiff_spec->RowsPerStrip << 1) ;
    tiff_spec->dcp_out = (unsigned char*) Xalloc(size) ;
    if (tiff_spec->dcp_out == NULL) return EIMG_NOMEMORY ;
  }
  else if ( tiff_spec->Compression == TC_LZW )
  {
    LoggingDo(LL_INFO, "Image compression: LZW") ;
    if (tiff_spec->RowsPerStrip != 0xFFFFFFFFUL)
      size = (size_t)tiff_spec->ImageWidth*(size_t)(1+tiff_spec->RowsPerStrip)*(size_t)tiff_spec->SamplesPerPixel ;
    else
      size = (size_t)tiff_spec->ImageWidth*(size_t)tiff_spec->ImageLength*(size_t)tiff_spec->SamplesPerPixel ;
    tiff_spec->dcp_out = (unsigned char*) Xalloc( size+10240 ) ; /* LZW decompress may overflow */
    if (tiff_spec->dcp_out == NULL) return EIMG_NOMEMORY ;
    if (lzw_init(8, tiff_spec->buffer, 0) != 0) return EIMG_NOMEMORY ;
  }

  if ( tiff_spec->Compression == TC_LZW )
  {
    StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_DECODAGELZW) ) ;
    if ( MachineInfo.cpu >= 30L ) StdProgDisplay030( wprog, 1 ) ;
  }
  else if ( tiff_spec->Compression == TC_PACKBITS ) StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_DECODAGEPCB)  ) ;

  temp  = (unsigned char*) out->fd_addr ;
  temp += img_size( out->fd_w, out->fd_h-1, out->fd_nplanes ) ;
  last_line  = (int*) temp ;

  for (i = 0; i < nb_strip; i++)
  {
    LoggingDo(LL_DEBUG, "Tiff strip %lu/%lu", 1+i, nb_strip) ;
    if (tiff_spec->StripByteCounts != 0)
    {
      if (tiff_spec->TStripByteCounts == TSHORT) i2r_nb = tiff_spec->itab_sbc[i] ;
      else                                       i2r_nb = tiff_spec->ltab_sbc[i] ;
      if (tiff_spec->TStripOffsets == TSHORT)    offset = tiff_spec->itab_so[i] ;
      else                                       offset = tiff_spec->ltab_so[i] ;
    }
    else
    {
      i2r_nb = nb_pts*(unsigned long)tiff_spec->SamplesPerPixel ;
      offset = tiff_spec->StripOffsets ;
    }

    switch( tiff_spec->BitsPerSample )
    {
      case 1 : num = i2r_nb << 3 ;
               if ( (tiff_spec->Compression == TC_NONE) && ( num_pts+num > nb_pts ) )
                 i2r_nb = (nb_pts-num_pts) >> 3 ;
               num = i2r_nb << 3 ;
               break ;
      case 4 : num = i2r_nb << 1 ;
               if ( (tiff_spec->Compression == TC_NONE) && ( num_pts+num > nb_pts ) )
                 i2r_nb = (nb_pts-num_pts) >> 1 ;
               num = i2r_nb << 1 ;
               break ;
      case 8 : num = i2r_nb/tiff_spec->SamplesPerPixel ;
               if ( (tiff_spec->Compression == TC_NONE) && ( num_pts+num > nb_pts ) )
                 i2r_nb = (nb_pts-num_pts)*tiff_spec->SamplesPerPixel ;
               num = i2r_nb/tiff_spec->SamplesPerPixel ;
               break ;
    }

    perf_start( PERF_DISK, &inf->perf_info ) ;
    ImgFSeek( inf, offset, SEEK_SET) ;
    i2r_nb = ImgFRead( inf, tiff_spec->buffer, i2r_nb ) ;
    perf_stop( PERF_DISK, &inf->perf_info ) ;

    perf_start( PERF_COMPRESS, &inf->perf_info ) ;
    if ( tiff_spec->Compression == TC_LZW )
    {
      bit1      = 7 ;
      code_size = 9 ;
      pt_in     = tiff_spec->buffer ;
      bit_shift = 0 ;
      LoggingDo(LL_DEBUG, "LZW decompress for %ld bytes", i2r_nb) ;
      i2r_nb    = lzw_decompress(tiff_spec->buffer, i2r_nb, tiff_spec->dcp_out, size) ;
      LoggingDo(LL_DEBUG, "LZW decompressed %ld bytes", i2r_nb) ;
      if ( i2r_nb > size )
      {
        LoggingDo(LL_WARNING, "LZW overflow on row #%lu/%lu: buffer is %ld bytes, %ld inflated %s", i, nb_strip, size, i2r_nb, (i2r_nb < size+10240) ? "(still safe)":"") ;
        i2r_nb = 0 ;
      }
      if ( i2r_nb == 0 )
      {
        (void)lzw_end() ;
        return EIMG_DECOMPRESERR ;
      }
      i2r_data = tiff_spec->dcp_out ;
      if (tiff_spec->BitsPerSample == 1) num = i2r_nb << 3 ;
      else                               num = i2r_nb/tiff_spec->SamplesPerPixel ;
    }
    else if ( tiff_spec->Compression == TC_PACKBITS )
    {
      num      = out->fd_wdwidth*out->fd_nplanes ;
      i2r_nb   = num ;
      i2r_nb  *= tiff_spec->RowsPerStrip ;
      nl       = (int)tiff_spec->RowsPerStrip ;
      while ((int*)i2rout+i2r_nb >= last_line+num)
      {
        nl-- ;
        i2r_nb -= num ;
      }
      if ( nl > 0 )
      {
        PACKBITS_STR pb_str ;

        pb_str.pbadr_in   = tiff_spec->buffer ;
        pb_str.pbadr_out  = tiff_spec->dcp_out ;
        pb_str.pbnb_pixel = (int)tiff_spec->ImageWidth ;
        pb_str.pbnb_ligne = nl ;
        pb_str.pbnb_plan  = out->fd_nplanes ;
        if (tiff_spec->BitsPerSample == 1) packbits_dcmps( &pb_str ) ;
        else                               packbits_idcmps( &pb_str ) ;
      }
      else break ;
      i2r_data = tiff_spec->dcp_out ;
      switch(tiff_spec->BitsPerSample)
      {
        case 1 : i2r_nb <<= 1 ;
                 break ;
        case 4 : i2r_nb = (tiff_spec->ImageWidth*nl) >> 1 ;
                 break ;
        case 8 : i2r_nb = tiff_spec->ImageWidth*nl ;
                 break ;
      }
    }
    else i2r_data = tiff_spec->buffer ;
    perf_stop( PERF_COMPRESS, &inf->perf_info ) ;

/*    if ( (tiff_spec->Compression == TC_PACKBITS) && (nl <= 0) ) break ; --> replaced par 'else break' of  'if ( nl > 0 )' */

    perf_start( PERF_IND2RASTER, &inf->perf_info ) ;
    switch(tiff_spec->BitsPerSample)
    {
      case 1 : temp = (unsigned char*) i2rout ;
               if ( tiff_spec->Compression == TC_NONE )
               {
                 if (out->fd_w-tiff_spec->ImageWidth < 8)
                 {
                   if (temp+i2r_nb > (unsigned char*)last_line) i2r_nb = (unsigned char*)last_line-temp ;
                   memcpy(temp, tiff_spec->buffer, i2r_nb) ;
                   temp  += (tiff_spec->RowsPerStrip*out->fd_wdwidth) << 1 ;
                   i2rout = temp ;
                 }
                 else
                 {
                   long          j, nb ;
                   int           *pt1 ;
                   unsigned char *pt2 ;

                   pt1 = (int *) i2rout ;
                   pt2 = tiff_spec->buffer ;
                   nb  = (tiff_spec->ImageWidth+7) >> 3 ;
                   for (j = 0; j < tiff_spec->RowsPerStrip; j++)
                   {
                     if (pt1 > last_line) break ;
                     memcpy(pt1, pt2, nb) ;
                     pt1 += out->fd_wdwidth ;
                     pt2 += nb ;
                   }
                   i2rout = pt1 ;
                 }
               }
               else
               {
                 long           nrow ;
                 long           nb_octets ;
                 unsigned char* pt ;

                 pt        = tiff_spec->dcp_out ;
                 nb_octets = out->fd_wdwidth << 1 ;
                 for ( nrow = 0; (nrow < tiff_spec->RowsPerStrip) && (temp <= (unsigned char*) last_line) ; nrow++ )
                 {
                   memcpy( temp, pt, nb_octets ) ;
                   temp += nb_octets ;
                   pt   += nb_octets ;
                 }
                 i2rout = temp ;
               }
               break ;
      case 4 : if ( inf->natural_format == NULL ) find2raster() ;
               else
               {
                 long           n ;
                 unsigned char* data ;
                 
                 data = (unsigned char*) i2r_data ;
                 for ( n = 0; n < i2r_nb ; n++ )
                 {
                   *pt_natural++ = *data >> 4 ;
                   *pt_natural++ = *data++ & 0x0F ;
                 }
               }
               break ;
      case 8 : temp = (unsigned char*) i2rout ;
               if ( tiff_spec->Predictor == 2 ) dcp_predictor( tiff_spec->dcp_out, i2r_nb, tiff_spec->ImageWidth ) ;
               if ( tiff_spec->SamplesPerPixel == 1 )
               {
                 if (inf->img_analyse) pal_ajust() ;
                 if ( inf->natural_format == NULL ) ind2raster() ;
                 else
                 {
                   memcpy( pt_natural, i2r_data, i2r_nb ) ;
                   pt_natural += i2r_nb ;
                 }
               }
               else
               {
                 if ( out->fd_nplanes == 16 )
                 {
                   tc24to16_i2r() ;
                   temp  += ((size_t)out->fd_w*(size_t)tiff_spec->RowsPerStrip) << 1 ;
                   i2rout = temp ;
                   i2rx   = 0 ; /* If LZW does not return all strips, we are then un-aligned for next strips */
                 }
                 else if ( out->fd_nplanes == 24 )
                 {
                   long          nrow ;
                   long          nb_octets = tiff_spec->ImageWidth*3 ;
                   unsigned char *pt ;
             
                   pt = i2r_data ;
                   for ( nrow = 0; ( nrow < tiff_spec->RowsPerStrip ) && ( temp <= (unsigned char*) last_line) ; nrow++ )
                   {
                     memcpy( temp, pt, nb_octets ) ;
                     temp += 3L*(long)out->fd_w ;
                     pt   += nb_octets ;
                   }
                   i2rout = temp ;
                 }
                 else if ( out->fd_nplanes == 32 )
                 {
                   long          nrow ;
                   long          nb_octets = tiff_spec->ImageWidth*3 ;
                   long          x ;
                   unsigned char *pt, *t, *tp ;
               
                   pt = i2r_data ;
                   for ( nrow = 0; ( nrow < tiff_spec->RowsPerStrip ) && ( temp <= (unsigned char*) last_line) ; nrow++ )
                   {
                     t  = temp ;
                     tp = pt ;
                     for ( x = 0; x < tiff_spec->ImageWidth; x++ )
                     {
                       *t++ = *tp++ ;
                       *t++ = *tp++ ;
                       *t++ = *tp++ ;
                       *t++ = 0 ;
                     }
                     temp += 4L*(long)out->fd_w ;
                     pt   += nb_octets ;
                   }
                   i2rout = temp ;
                 }
               }
               break ;
    }
    num_pts = num_pts+num ;
    perf_stop( PERF_IND2RASTER, &inf->perf_info ) ;

    if ( nb_strip != 1 )
    {
      code = GWProgRange( wprog, i, nb_strip-1, NULL ) ;
      if ( PROG_CANCEL_CODE( code ) )
      {
        if ( tiff_spec->Compression == TC_LZW ) (void)lzw_end() ;
        return EIMG_USERCANCELLED ;
      }
    }
  }

  if ( tiff_spec->Compression == TC_LZW ) (void)lzw_end() ;

  if ( tiff_spec->BitsPerSample == 1 )
  {
    int xy[8] ;

    /* If Min Is Black, we have to invert 0s and 1s */    
    if ( tiff_spec->PhotometricInterpretation == 1 )
    {
      long *pt = (long*) out->fd_addr ;
      long* pt_last = pt + (((long)out->fd_wdwidth*(long)out->fd_nplanes*(long)out->fd_h) >> 1) ;

      while ( pt < pt_last ) { *pt = ~(*pt) ; pt++; }
/*    For some reason, the code below does not 
      work on Aranym/Mint/FVDI
      xy[0] = xy[4] = xy[1] = xy[5] = 0 ;
      xy[2] = xy[6] = out->fd_w-1 ;
      xy[3] = xy[7] = out->fd_h-1 ;
      vro_cpyfm( handle, D_INVERT, xy, out, out ) ;*/
    }

    /* Elimine les points de bourrage dus au codage sur un octet */
    if ( (int)tiff_spec->ImageWidth < out->fd_w )
    {
      xy[0] = xy[4] = (int)tiff_spec->ImageWidth ;
      xy[1] = xy[5] = 0 ;
      xy[2] = xy[6] = out->fd_w-1 ;
      xy[3] = xy[7] = out->fd_h-1 ;
      vro_cpyfm( handle, ALL_WHITE, xy, out, out ) ;
    }
  }

  return EIMG_SUCCESS ;
}

int tiff_load(INFO_IMAGE* inf)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) inf->specific ;
  MFDB*          out = &inf->mfdb ;
  int            nlines_to_allocate ;
  int            ret ;

  if ( !inf->xfile.valid ) return EIMG_FILENOEXIST ;
  if ( tiff_spec == NULL ) return EIMG_NOMEMORY ;

  if ( tiff_spec->ImageWidth & 0x0F ) out->fd_w = (int) (16+(tiff_spec->ImageWidth & 0xFFFFFFF0L)) ;
  else                                out->fd_w = (int) tiff_spec->ImageWidth ;
  out->fd_h = (int) tiff_spec->ImageLength ;
  if (tiff_spec->SamplesPerPixel == 1) out->fd_nplanes = tiff_spec->BitsPerSample ;
  else
  {
    if ( inf->force_16b_load ) out->fd_nplanes = 16 ;
    else
    {
      if ( inf->final_nb_planes >= 16 )  out->fd_nplanes = inf->final_nb_planes ;
      else                               out->fd_nplanes = tiff_spec->SamplesPerPixel*tiff_spec->BitsPerSample ;
    }
  }

  /* FIXME: LZW decompression may overflow output buffer */
  /* For safety, let's allocate a bit more memory...     */
  nlines_to_allocate = out->fd_h ;
  if ( tiff_spec->Compression == TC_LZW ) nlines_to_allocate++ ;
  out->fd_addr = img_alloc( out->fd_w, nlines_to_allocate, out->fd_nplanes ) ;
  if ( out->fd_addr )
  {
    out->fd_wdwidth = out->fd_w>>4 ;
    out->fd_stand   = 0 ;
    img_raz( out ) ;
    if ( may_use_natural_format( inf->final_nb_planes, out->fd_nplanes ) )
    {
      inf->natural_format = Xalloc( (long)out->fd_w*(long)out->fd_h ) ;
      inf->natural_width  = (int) tiff_spec->ImageWidth ;
    }
    ret = tiff_read( inf ) ;
  }
  else ret = EIMG_NOMEMORY ;

  tiff_release_dynamic( inf->specific ) ;
  img_post_loading( ret, inf ) ;

  return ret ;
}

static void tag_write(TIFF_TAG* tag, int byte_order, FILE* stream)
{
  TIFF_TAG file_tag ;

  memcpy( &file_tag, tag, sizeof(TIFF_TAG) ) ;
  tag_mem2file( byte_order, &file_tag ) ;
  fwrite( &file_tag, sizeof(TIFF_TAG), 1, stream ) ;
}

static void fraction_write(FRACTION* frac, int byte_order, FILE* stream)
{
  FRACTION intel_frac ;

  if ( byte_order == INTEL )
  {
    memcpy( &intel_frac, frac, sizeof(FRACTION) ) ;
    frac = &intel_frac ;
    fraction_reverse( frac ) ;
  }
  fwrite( frac, sizeof(FRACTION), 1, stream ) ;
}

static int tiff_wrpal(INFO_IMAGE *info, FILE *stream)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) info->specific ;
  unsigned int*  pal, *ptiff ;
  unsigned int   tiffpal[3*256] ;
  unsigned int   color ;
  int            i, j, ind ;
  int            nb_col ;

  pal    = (unsigned int*) info->palette ;
  nb_col = 1 << tiff_spec->BitsPerSample ;
  ptiff  = tiffpal ;
  for (j = 0; j < 3; j++)
  {
    for (i = 0; i < nb_col; i++)
    {
      ind   = j+3*i ;
      color = pal[ind] ;
      if (color > 1000) color = 1000 ;
      *ptiff = color << 6 ;
      if (info->c.f.tif.byteorder == INTEL) *ptiff = int_reverse(*ptiff) ;
      ptiff++ ;
    }
  }

  if ( fwrite( tiffpal, 6, nb_col, stream ) != nb_col ) return EIMG_DATAINCONSISTENT ;

  return EIMG_SUCCESS ;
}

/* Structure of generated TIFF file:                               */
/* Data           | #bytes|    Comment                             */
/* Always present -------->                                        */
/*-----Header-----|-----8-|----------------------------------------*/
/* Identifier     |     2 | 'MM' or 'II'                           */
/* Version        |     2 | $2A                                    */
/* IFDOffset      |     4 | 8 (IFD follows)                        */
/*------IFD-------|--12xN-|-----------*****------------------------*/
/* NbTags         |     N |                                        */
/*---Tag#0--------|----12-|----------------------------------------*/
/*  Id            |     2 |                                        */
/*  Type          |     2 |                                        */
/*  Count         |     4 |                                        */
/*  Offset        |     4 | Offset to file or direct value         */
/*    .................................................            */
/*---Tag#n--------|----12-|----------------------------------------*/
/*  Id            |     2 |                                        */
/*  Type          |     2 |                                        */
/*  Count         |     4 |                                        */
/*  Offset        |     4 | Offset to file or direct value         */
/* NextIFDOffset  |     4 | 0 (no more image)                      */
/*----------------|-------|----------------------------------------*/
/* StripOffsets   |   4xN | Location of strip offsets              */
/* StripByteCounts|   4xN | Location of strip byte counts          */
/* X-Resolution   |     8 | Fractional for x-resolution            */
/* Y-Resolution   |     8 | Fractional for y-resolution            */
/* May or may not be present -------->                             */
/* BitPerSample   |     6 | TC24: 3 16 int with value 8 -OR-       */
/* ColorMap       |   6xN | Palette: 3 x 2^BitPerSample items -OR- */
/* Nothing        |     0 | Monochrome image                       */
/* Informations   |     N | Strings holding informational data     */
/*                |       | Software Name, Description, ...        */
/* +++++++++++++++++++++ Image data +++++++++++++++++++++++++++++  */
#define TAG_OFFSET(n) (10 + n*sizeof(TIFF_TAG))
static int tags_make(INFO_IMAGE* info, FILE* stream)
{
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) info->specific ;
  char*          informations ;
  char*          sep ;
  FRACTION       rsol ;
  TIFF_TAG       tag ;
                                         /* Informational tags offset need to be updated as we don't know where data is located at the time we generated the tag array to file */
  unsigned long  u_tag_offset[16] ;      /* Where the offset field of TIFF tag is in the file */
  unsigned long  u_tag_data_offset[16] ; /* Where the data is in the file                     */
  char*          u_tag_data[16] ;        /* Where the data is in memory                       */
  short          nb_opt_tags, nb_tags2update ;
  unsigned int   i, nb_tags =0 ;
  unsigned long  next_ifd_offset = 0L ; /* One image only */
  int            byte_order = info->c.f.tif.byteorder ;

  /* Adjust INFO_IMAGE data if required */
  if ( info->nplanes >= 16 ) info->nplanes = 24 ; /* We generate only RGB24 images for True Color */

  /* Write fake number of tags, we'll update this field at the end */
  fwrite( &nb_tags, 2, 1, stream ) ;

  nb_tags = 13 ;
  if ( info->c.f.tif.predictor == 2 ) nb_tags++ ;

  /* Initialize TIFF specific structure from INFO_IMAGE */
  if ( info->nplanes == 24 )
  {
    tiff_spec->SamplesPerPixel           = 3 ;
    tiff_spec->BitsPerSample             = 8 ;
    tiff_spec->PhotometricInterpretation = 2 ;
  }
  else
  {
    tiff_spec->BitsPerSample   = info->nplanes ;
    tiff_spec->SamplesPerPixel = 1 ;
    if ( info->palette && (info->nplanes != 1) )
    {
      tiff_spec->PhotometricInterpretation = 3 ;
      nb_tags++ ;
    }
    else tiff_spec->PhotometricInterpretation = 0 ;
  }
  tiff_spec->ResolutionUnit = 3 ; /* cm */
  tiff_spec->Compression    = info->compress ;
  if ( tiff_spec->Compression == TC_PACKBITS ) tiff_spec->Compression = TC_LZW ; /* PackBits --> LZW */
  if ( tiff_spec->Compression != TC_LZW ) tiff_spec->Compression = TC_NONE ;     /* No compression   */
  tiff_spec->ImageWidth   = align16(info->width) ;
  tiff_spec->ImageLength  = info->height ;
  tiff_spec->StripOffsets = 14+nb_tags*sizeof(TIFF_TAG) ;
  tiff_spec->RowsPerStrip = 16384L/img_size((int) tiff_spec->ImageWidth, 1, info->nplanes) ;
  if ( tiff_spec->Compression == TC_LZW ) tiff_spec->RowsPerStrip = tiff_spec->RowsPerStrip*2 ;
  if ( tiff_spec->RowsPerStrip > tiff_spec->ImageLength ) tiff_spec->RowsPerStrip = tiff_spec->ImageLength >> 1 ;
  if ( tiff_spec->RowsPerStrip == 0 ) tiff_spec->RowsPerStrip = 1 ;
  tiff_spec->StripsPerImage   = (unsigned int) ((tiff_spec->ImageLength+tiff_spec->RowsPerStrip-1)/tiff_spec->RowsPerStrip) ;
  tiff_spec->StripByteCounts  = tiff_spec->StripOffsets+tiff_spec->StripsPerImage*4 ;
  tiff_spec->TStripOffsets    = TLONG ;
  tiff_spec->TStripByteCounts = TLONG ;
  tiff_spec->Predictor        = info->c.f.tif.predictor ;
  tiff_spec->ByteOrder        = byte_order ;
  tiff_spec->XResolution      = tiff_spec->StripByteCounts+tiff_spec->StripsPerImage*4 ;
  tiff_spec->YResolution      = tiff_spec->XResolution+sizeof(FRACTION) ;

  /* Allocate StripOffsets and StripByteCounts arrays now to return asap if we are running out of memory */
  tiff_spec->ltab_so = (unsigned long*) Xcalloc( sizeof(long), tiff_spec->StripsPerImage ) ;
  if ( tiff_spec->ltab_so == NULL ) return EIMG_NOMEMORY ;

  tiff_spec->ltab_sbc = (unsigned long*) Xcalloc( sizeof(long), tiff_spec->StripsPerImage ) ;
  if ( tiff_spec->ltab_sbc == NULL ) return EIMG_NOMEMORY ; /* Caller will call stiff_release to free ltab_so anyway, no need to do it */

  if ( info->nplanes == 24 )
  {
    tiff_spec->BitsPerSample = (unsigned int) (tiff_spec->YResolution+sizeof(FRACTION)) ;
    tiff_spec->ColorMap      = tiff_spec->BitsPerSample+6 ;
  }
  else tiff_spec->ColorMap = tiff_spec->YResolution+sizeof(FRACTION) ;

  /* Tag #n: offset 10+n*12 */
  tag.tag    = NEW_SUBFILE_TYPE ; /* Tag #0 */
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = 0 ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = IMAGE_WIDTH ; /* Tag #1 */
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = tiff_spec->ImageWidth ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = IMAGE_LENGTH ; /* Tag #2 */
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = tiff_spec->ImageLength ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag  = BITS_PER_SAMPLE ; /* Tag #3, holds the value for bitplanes, is an offset for 24b */
  tag.type = TSHORT ;
  if ( info->nplanes == 24 )
  {
    tag.length = tiff_spec->SamplesPerPixel ;
    tag.offset = tiff_spec->BitsPerSample ;
  }
  else
  {
    tag.length = 1 ;
    tag.offset = (unsigned long)info->nplanes ;
  }
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = COMPRESSION ; /* Tag #4 */
  tag.type   = TSHORT ;
  tag.length = 1 ;
  tag.offset = (unsigned long)tiff_spec->Compression ;
  tag_write(&tag, byte_order, stream) ;
 
  tag.tag    = PHOTOMETRIC ;  /* Tag #5 */
  tag.type   = TSHORT ;
  tag.length = 1 ;
  tag.offset = tiff_spec->PhotometricInterpretation ; 
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = STRIP_OFFSETS ; /* Tag #6 */
  tag.type   = TLONG ;
  tag.length = tiff_spec->StripsPerImage ;
  tag.offset = tiff_spec->StripOffsets ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = SAMPLES_PER_PIXEL ; /* Tag #7 */
  tag.type   = TSHORT ;
  tag.length = 1 ;
  tag.offset = tiff_spec->SamplesPerPixel ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = ROWS_PER_STRIP ; /* Tag #8 */
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = tiff_spec->RowsPerStrip ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = STRIP_BYTE_COUNTS ; /* Tag #9 */
  tag.type   = TLONG ;
  tag.length = tiff_spec->StripsPerImage ;
  tag.offset = tiff_spec->StripByteCounts ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = X_RESOLUTION ; /* Tag #10 */
  tag.type   = TRATIONAL ;
  tag.length = 1 ;
  tag.offset = tiff_spec->XResolution ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = Y_RESOLUTION ; /* Tag #11 */
  tag.type   = TRATIONAL ;
  tag.length = 1 ;
  tag.offset = tiff_spec->YResolution ;
  tag_write(&tag, byte_order, stream) ;

  tag.tag    = RESOLUTION_UNIT ; /* Tag #12 */
  tag.type   = TSHORT ;
  tag.length = 1 ;
  tag.offset = (unsigned long)tiff_spec->ResolutionUnit ;
  tag_write(&tag, byte_order, stream) ;

  if ( tiff_spec->PhotometricInterpretation == 3 ) /* Palette */
  {
    tag.tag    = COLOR_MAP ; /* Tag #13 */
    tag.type   = TSHORT ;
    tag.length = 3*(1 << tiff_spec->BitsPerSample) ;
    tag.offset = tiff_spec->ColorMap ;
    tag_write(&tag, byte_order, stream) ;
  }

  if ( tiff_spec->Predictor == 2 )
  {
    tag.tag    = PREDICTOR ; /* Tag #13 or #14 */
    tag.type   = TSHORT ;
    tag.length = 1 ;
    tag.offset = (unsigned long) tiff_spec->Predictor ;
    tag_write(&tag, byte_order, stream) ;
  }

  /* Let's mark now tags we need to come back to when we know the offset for their data */
  nb_opt_tags = 0 ;
  if ( info->SoftwareName )
  {
    tag.tag    = SOFTWARE ;
    tag.type   = TASCII ;
    tag.length = 1+strlen(info->SoftwareName) ;
    tag.offset = 0 ;
    u_tag_offset[nb_opt_tags] = ftell( stream ) + 8 ;
    u_tag_data[nb_opt_tags]   = info->SoftwareName ;
    nb_opt_tags++ ;
    tag_write(&tag, byte_order, stream) ;
  }

  /* Go through the list of informations */
  informations = get_informations_first( info ) ;
  while ( informations )
  {
    /* Returns informations in format label:information */
    sep = strchr( informations, ':' ) ;
    if ( sep )
    {
      int tag_id ;

      *sep = 0 ;
      tag_id = GetTagId( informations ) ;
      if ( tag_id && (tag_id != SOFTWARE) ) /* Software forced to SoftwareName */
      {
        tag.tag    = tag_id ;
        tag.type   = TASCII ;
        tag.length = 1+strlen(1+sep) ;
        tag.offset = 0 ;
        u_tag_offset[nb_opt_tags] = ftell( stream ) + 8 ;
        u_tag_data[nb_opt_tags]   = 1+sep ;
        nb_opt_tags++ ;
        tag_write(&tag, byte_order, stream) ;
      }
      *sep = ':' ;
      informations = get_informations_next( informations ) ;
    }
    else break ;
  }

  nb_tags       += nb_opt_tags ;
  nb_tags2update = nb_opt_tags ; /* StripOffsets, StripByteCounts, XResolution, YResolution, BitsPerSample(if TC24) -OR- ColorMap (if palette) */
  
  /* No need to check Intel as next_ifd_offset is 0 */
  fwrite( &next_ifd_offset, 4, 1, stream ) ;

  /* Write StripOffsets array (set to zero, no need for Intel check ) */
  tiff_spec->StripOffsets      = ftell( stream ) ;
  u_tag_offset[nb_tags2update] = 8 + TAG_OFFSET(6) ; /* StripOffsets: Tag#6 */
  u_tag_data_offset[nb_tags2update++] = tiff_spec->StripOffsets ;
  if ( fwrite( tiff_spec->ltab_so, sizeof(long), tiff_spec->StripsPerImage, stream ) != tiff_spec->StripsPerImage ) return EIMG_DATAINCONSISTENT ;

  /* Write StripByteCounts array (set to zero, no need for Intel check ) */
  tiff_spec->StripByteCounts = ftell( stream ) ;
  u_tag_offset[nb_tags2update]  = 8 + TAG_OFFSET(9) ; /* StripByteCounts: Tag#6 */
  u_tag_data_offset[nb_tags2update++]  = tiff_spec->StripByteCounts ;
  if ( fwrite( tiff_spec->ltab_sbc, sizeof(long), tiff_spec->StripsPerImage, stream ) != tiff_spec->StripsPerImage ) return EIMG_DATAINCONSISTENT ;

  /* Write X-Resolution fractional */
  tiff_spec->XResolution    = ftell( stream ) ;
  u_tag_offset[nb_tags2update] = 8 + TAG_OFFSET(10) ; /* XResolution: Tag#10 */
  u_tag_data_offset[nb_tags2update++] = tiff_spec->XResolution ;  
  rsol.numerateur           = 10000 ; /* Init once as value does not change */
  rsol.denominateur         = info->lpix ;
  fraction_write( &rsol, byte_order, stream ) ;

  /* Write Y-Resolution fractional */
  tiff_spec->YResolution    = ftell( stream ) ;
  u_tag_offset[nb_tags2update] = 8 + TAG_OFFSET(11) ; /* YResolution: Tag#11 */
  u_tag_data_offset[nb_tags2update++] = tiff_spec->YResolution ;  
  rsol.denominateur         = info->hpix ;
  fraction_write( &rsol, byte_order, stream ) ;

  /* Write: BitsPerSample 8,8,8 if True Color */
  /*  -OR-  Palette if available              */
  /*  -OR-  Nothing (monochrome image)        */
  if ( tiff_spec->PhotometricInterpretation == 2 )
  {
    unsigned int nbits = 8 ;

    tiff_spec->BitsPerSample   = 8 ;
    tiff_spec->SamplesPerPixel = 3 ;
    if ( byte_order == INTEL ) nbits = int_reverse( nbits ) ;
    u_tag_offset[nb_tags2update] = 8 + TAG_OFFSET(3) ; /* BitsPerSample: Tag#3 */
    u_tag_data_offset[nb_tags2update++] = ftell( stream ) ;
    for ( i = 0; i < tiff_spec->SamplesPerPixel; i++ )
      fwrite( &nbits, 2, 1, stream ) ;
  }
  else if ( tiff_spec->PhotometricInterpretation == 3 )
  {
    tiff_spec->ColorMap          = ftell( stream ) ;
    u_tag_offset[nb_tags2update] = 8 + TAG_OFFSET(13) ; /* ColorMap: Tag#6 */
    u_tag_data_offset[nb_tags2update++] = tiff_spec->ColorMap ;
    if ( tiff_wrpal( info, stream ) != EIMG_SUCCESS ) return EIMG_DATAINCONSISTENT ;
  }

  /* Now come the informational tags                      */
  /* Update offset as stored in TIFF TAG array in file    */
  /* Do this in same order as when this array was created */

  /* Write all information we have */
  for ( i = 0; i < nb_opt_tags; i++ )
  {
    u_tag_data_offset[i] = ftell( stream ) ;
    if ( fwrite( u_tag_data[i], 1, 1+strlen(u_tag_data[i]), stream ) & 0x01 )
      fwrite( &i, 1, 1, stream ) ; /* Padding */
  }

  /* Update all tags in TIFF tag array in IFD */
  for ( i = 0; i < nb_tags2update; i++ )
  {
    fseek( stream, u_tag_offset[i], SEEK_SET ) ;
    if ( byte_order == INTEL ) u_tag_data_offset[i] = long_reverse( u_tag_data_offset[i] ) ;
    fwrite( &u_tag_data_offset[i], sizeof(long), 1, stream ) ;
  }

  /* Now write the number of tags */
  fseek( stream, sizeof(TIFF_HEADER), SEEK_SET ) ;
  if ( byte_order == INTEL ) nb_tags = int_reverse( nb_tags ) ;
  fwrite( &nb_tags, sizeof(short), 1, stream ) ;

  /* Ready for caller to write raster data */
  fseek( stream, 0, SEEK_END ) ;

  return EIMG_SUCCESS ;
}

static void stiff_release(INFO_IMAGE* inf, FILE* stream)
{
  tiff_release_dynamic( inf->specific ) ;
  inf->specific = NULL ; /* In case someone would free it */
  fclose( stream ) ;
}

static int tlzw_compress(void* adr, unsigned long nbytes, FILE* stream, long* nb_out)
{
  int ret ;

  code_size = 9 ;
  ret = lzw_init( 8, NULL, 0 ) ;
  if ( !ret ) ret = lzw_compress( (unsigned char*)adr, nbytes, stream, nb_out ) ;
  switch( ret )
  {
    case -3 : ret = EIMG_NOMEMORY ;
              break ;
    case -2 : ret = EIMG_DATAINCONSISTENT ;
              break ;
    case -1 : ret = EIMG_FILENOEXIST ;
              break ;
  }

  if ( ret ) LoggingDo(LL_WARNING, "tlzw_compress returned %d", ret ) ;

  return ret ;
}

static int tiff_setsaveoption(INFO_IMAGE* inf, char* option, char* value)
{
  int ret = EIMG_SUCCESS ;

  if ( memcmp( option, "compression", sizeof("compression")-1 ) == 0 )
  {
    if ( memcmp( value, "lzw", sizeof("lzw")-1 ) == 0 )           inf->compress = TC_LZW ;
    else if ( memcmp( value, "packbits", sizeof("lzw")-1 ) == 0 ) inf->compress = TC_PACKBITS ;
    else if ( memcmp( value, "none", sizeof("none")-1 ) == 0 )    inf->compress = TC_NONE ;
    else                                                          ret = EIMG_OPTIONNOTSUPPORTED ;
  }
  else if ( memcmp( option, "predictor", sizeof("predictor")-1 ) == 0 )
  {
    if ( memcmp( value, "rle", sizeof("rle")-1 ) == 0 ) inf->c.f.tif.predictor = 2 ;
    else                                                inf->c.f.tif.predictor = 1 ;
  }
  else if ( memcmp( option, "byteorder", sizeof("byteorder")-1 ) == 0 )
  {
    if ( memcmp( value, "intel", sizeof("intel")-1 ) == 0 ) inf->c.f.tif.byteorder = INTEL ;
    else                                                    inf->c.f.tif.byteorder = MOTOROLA ;
  }
  else ret = EIMG_OPTIONNOTSUPPORTED ;

  return ret ;
}

int tiff_sauve(char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  TIFF_HEADER    header ;
  TIFF_SPECIFIC  local_tiff_spec ;
  TIFF_SPECIFIC* tiff_spec = (TIFF_SPECIFIC*) &local_tiff_spec ; /* No need for dynamic allocation as life time of tiff_spec is this function */
  FILE*          stream ;
  int*           pt_img ;
  char*          adr ;
  unsigned long  nb_pts, num_pts, num ;
  unsigned long  nb_octet ;
  long           lo_ligne ;
  long           nb_out ;
  int            i ;
  int            ret ;

  if ( img->fd_nplanes == 2 ) return EIMG_OPTIONNOTSUPPORTED ;

  stream = CreateFileR( name ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  memzero( &local_tiff_spec, sizeof(TIFF_SPECIFIC) ) ;
  info->specific = tiff_spec ;
  img_setsaveoptions( info, tiff_setsaveoption ) ;
  if ( info->c.f.tif.byteorder != INTEL ) info->c.f.tif.byteorder = MOTOROLA ;
  header.byte_order = info->c.f.tif.byteorder ;
  header.version    = 0x2A ;
  header.ifd_offset = 0x08UL ;
  if ( info->c.f.tif.byteorder == INTEL )
  {
    header.version    = int_reverse(header.version) ;
    header.ifd_offset = long_reverse(header.ifd_offset) ;
  }
  fwrite( &header, sizeof(TIFF_HEADER), 1, stream ) ;

  ret = tags_make( info, stream ) ;
  if ( ret != EIMG_SUCCESS )
  {
    stiff_release( info, stream ) ;
    return ret ;
  }

  if ( tiff_spec->BitsPerSample != 1 )
  {
    tiff_spec->buffer = (unsigned char*) Xcalloc( tiff_spec->RowsPerStrip, tiff_spec->ImageWidth*tiff_spec->SamplesPerPixel ) ;
    if ( tiff_spec->buffer == NULL )
    {    
      stiff_release( info, stream ) ;
      return EIMG_NOMEMORY ;
    }
  }

  lo_ligne = img_size( (int)tiff_spec->ImageWidth, 1, tiff_spec->BitsPerSample*tiff_spec->SamplesPerPixel ) ;
  num_pts  = 0 ;
  nb_pts   = tiff_spec->ImageWidth*tiff_spec->ImageLength ;
  adr      = (char*) img->fd_addr ;
  pt_img   = (int*) img->fd_addr ;

  if ( tiff_spec->Compression == TC_LZW )
  {
    StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_ENCODAGELZW)  ) ;
    if ( MachineInfo.cpu >= 30L ) StdProgDisplay030( wprog, 1 ) ;
  }

  LoggingDo(LL_DEBUG,"RowsPerStrip=%ld, StripsPerImage=%d", tiff_spec->RowsPerStrip, tiff_spec->StripsPerImage) ;
  for (i = 0; (ret == EIMG_SUCCESS) && (i < tiff_spec->StripsPerImage); i++)
  {
    switch(tiff_spec->BitsPerSample)
    {
      case 1 : num = (tiff_spec->RowsPerStrip*lo_ligne) << 3 ;
               if (num_pts+num > nb_pts) num = nb_pts-num_pts ;
               nb_octet    = num >> 3 ;
               num_pts     = num_pts+num ;
               tiff_spec->ltab_sbc[i] = nb_octet ;
               tiff_spec->ltab_so[i]  = ftell(stream) ;
               if ( tiff_spec->Compression == TC_NONE )
               {
                 if ( fwrite(adr, 1, nb_octet, stream) != nb_octet ) ret = EIMG_DATAINCONSISTENT ;
                 tiff_spec->ltab_sbc[i] = nb_octet ;
               }
               else if ( tiff_spec->Compression == TC_LZW )
               {
                 ret = tlzw_compress( adr, nb_octet, stream, &nb_out ) ;
                 if ( ret == EIMG_SUCCESS) tiff_spec->ltab_sbc[i] = nb_out ;
               }
               adr = adr+nb_octet ;
               break ;
      case 4 : num = (tiff_spec->RowsPerStrip*lo_ligne) << 1 ;
               if (num_pts+num > nb_pts) num = nb_pts-num_pts ;
               nb_octet = num >> 1 ;
               num_pts  = num_pts+num ;
               raster2ind(pt_img, tiff_spec->buffer, num, 4) ;
               ind4plans(tiff_spec->buffer, num) ;
               tiff_spec->ltab_so[i] = ftell(stream) ;
               if ( tiff_spec->Compression == TC_NONE )
               {
                 if (fwrite(tiff_spec->buffer, 1, nb_octet, stream) != nb_octet) ret = EIMG_DATAINCONSISTENT ;
                 tiff_spec->ltab_sbc[i] = nb_octet ;
               }
               else if ( tiff_spec->Compression == TC_LZW )
               {
                 ret = tlzw_compress( tiff_spec->buffer, nb_octet, stream, &nb_out ) ;
                 if ( ret == EIMG_SUCCESS) tiff_spec->ltab_sbc[i] = nb_out ;
               }
               pt_img = pt_img+(nb_octet >> 1) ;
               break ;
      case 8 : num = tiff_spec->RowsPerStrip*tiff_spec->ImageWidth ;
               if (num_pts+num > nb_pts) num = nb_pts-num_pts ;
               nb_octet               = num*tiff_spec->SamplesPerPixel ;
               num_pts                = num_pts+num ;
               tiff_spec->ltab_sbc[i] = nb_octet ;
               tiff_spec->ltab_so[i]  = ftell(stream) ;
               if (img->fd_nplanes <= 8)
               {
                 raster2ind(pt_img, tiff_spec->buffer, num, 8) ;
                 if (tiff_spec->Predictor == 2) cpi_predictor(tiff_spec->buffer, nb_octet, tiff_spec->ImageWidth) ;
               }
               else
               {
                 if ( img->fd_nplanes == 16 )      tc16to24( pt_img, tiff_spec->buffer, num ) ;
                 else if ( img->fd_nplanes == 24 ) memcpy( tiff_spec->buffer, pt_img, nb_octet ) ;
                 else if ( img->fd_nplanes == 32 ) tc32to24( (long*)pt_img, tiff_spec->buffer, num ) ;

                 if (tiff_spec->Predictor == 2) cp_predictor(tiff_spec->buffer, nb_octet, tiff_spec->ImageWidth) ;
               }
               if ( tiff_spec->Compression == TC_LZW )
               {
                 ret = tlzw_compress( tiff_spec->buffer, nb_octet, stream, &nb_out ) ;
                 if ( ret == EIMG_SUCCESS) tiff_spec->ltab_sbc[i] = nb_out ;
               }
               else if ( fwrite(tiff_spec->buffer, 1, nb_octet, stream) != nb_octet ) ret = EIMG_DATAINCONSISTENT ;

               if ( img->fd_nplanes <= 8 )     pt_img = pt_img+(nb_octet>>1) ;
               else if (img->fd_nplanes == 16) pt_img = pt_img+num ;
               else if (img->fd_nplanes == 24) pt_img = pt_img+ ((3*num)>>1) ;
               else if (img->fd_nplanes == 32) pt_img = pt_img+(num<<1) ;
                
               break ;
    }
    (void)GWProgRange( wprog, 1+i, tiff_spec->StripsPerImage, NULL ) ;
  }

  if ( tiff_spec->Compression == TC_LZW ) (void)lzw_end() ;

  if ( info->c.f.tif.byteorder == INTEL )
  {
    for ( i = 0; i < tiff_spec->StripsPerImage; i++ )
    {
      tiff_spec->ltab_so[i]  = long_reverse(tiff_spec->ltab_so[i]) ;
      tiff_spec->ltab_sbc[i] = long_reverse(tiff_spec->ltab_sbc[i]) ;
    }
  }
  fseek( stream, tiff_spec->StripOffsets, SEEK_SET ) ;
  fwrite( tiff_spec->ltab_so, sizeof(long), tiff_spec->StripsPerImage, stream ) ;
  fseek( stream, tiff_spec->StripByteCounts, SEEK_SET ) ;
  fwrite( tiff_spec->ltab_sbc, sizeof(long), tiff_spec->StripsPerImage, stream ) ;

  stiff_release( info, stream ) ;

  return EIMG_SUCCESS ;
}

void tiff_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "TIF\0TIFF\0\0" ;

  caps->iid = IID_TIFF ;
  strcpy( caps->short_name, "TIFF" ) ;
  strcpy( caps->file_extension, "TIF" ) ;
  strcpy( caps->name, "Tagged Image File Format 5.0" ) ;
  caps->version = 0x0411 ;

  caps->import = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P24 | IEF_NOCOMP | IEF_LZW | IEF_PBIT ;
  caps->export = IEF_P1 | IEF_P4 | IEF_P8 | IEF_P24 | IEF_NOCOMP | IEF_LZW ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
