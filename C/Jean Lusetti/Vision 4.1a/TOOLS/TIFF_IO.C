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

#define MOTOROLA 0x4D4D
#define INTEL    0x4949

#define TBYTE     1
#define TASCII    2
#define TSHORT    3
#define TLONG     4
#define TRATIONAL 5

#define NEW_SUBFILE_TYPE    254
#define BITS_PER_SAMPLE     258
#define IMAGE_WIDTH         256
#define IMAGE_LENGTH        257
#define COMPRESSION         259
#define PHOTOMETRIC         262
#define STRIP_OFFSETS       273
#define ROWS_PER_STRIP      278
#define SAMPLES_PER_PIXEL   277
#define STRIP_BYTE_COUNTS   279
#define X_RESOLUTION        282
#define Y_RESOLUTION        283
#define PLANAR_CONFIG       284
#define RESOLUTION_UNIT     296
#define PREDICTOR           317
#define COLOR_MAP           320

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
unsigned int  NbTags ;
unsigned int  PlanarConfiguration ;
unsigned long ImageWidth ;
unsigned long ImageLength ;
unsigned long StripOffsets ;
unsigned long RowsPerStrip ;
unsigned long StripByteCounts ;
unsigned long XResolution ;
unsigned long YResolution ;
unsigned long ColorMap ;


void tag_reverse(TIFF_TAG *tag)
{
  tag->tag    = int_reverse(tag->tag) ;
  tag->type   = int_reverse(tag->type) ;
  tag->length = long_reverse(tag->length) ;
  if ((tag->length > 1) || (tag->type == TASCII) || (tag->type == TRATIONAL))
    tag->offset = long_reverse(tag->offset) ;
}

void fraction_reverse(FRACTION *frac)
{
  frac->numerateur   = long_reverse(frac->numerateur) ;
  frac->denominateur = long_reverse(frac->denominateur) ;
}

void tiff2vdipalette(unsigned int *tiffpal, INFO_IMAGE *inf)
{
  unsigned int *pttiff ;
  int          *ptvdi ;
  int          nb_col, tcol, i ;
  int          ind ;

  nb_col = 1 << BitsPerSample ;
  tcol   = nb_col ;
  if (tcol < nb_colors) tcol = nb_colors ;
  inf->palette = (int *) Xalloc(tcol*6) ;
  if (inf->palette == NULL) return ;
  inf->nb_cpal = nb_col ;

  pttiff = tiffpal ;
  ptvdi  = inf->palette ;
  for (i = 0; i < nb_col; i++)
  {
    ind = i ;
    if (ByteOrder == INTEL) pttiff[ind] = int_reverse(pttiff[ind]) ;
    *ptvdi = (int) (pttiff[ind] >> 6) ;
    if (*ptvdi > 1000) *ptvdi = 1000 ;
    ptvdi++ ;
    ind = ind+nb_col ;
    if (ByteOrder == INTEL) pttiff[ind] = int_reverse(pttiff[ind]) ;
    *ptvdi = (int) (pttiff[ind] >> 6) ;
    if (*ptvdi > 1000) *ptvdi = 1000 ;
    ptvdi++ ;
    ind = ind+nb_col ;
    if (ByteOrder == INTEL) pttiff[ind] = int_reverse(pttiff[ind]) ;
    *ptvdi = (int) (pttiff[ind] >> 6) ;
    if (*ptvdi > 1000) *ptvdi = 1000 ;
    ptvdi++ ;
  }
}

int resol(FRACTION *frac)
{
  double val, coe ;
  int    nb ;

  if (ByteOrder == INTEL) fraction_reverse(frac) ;

  val = (double)frac->numerateur/(double)frac->denominateur ;
  val = 1.0/val ; /* Taille d'un point en unit‚s */
  /* coe : valeur d'une unit‚ en microns */
  switch(ResolutionUnit)
  {
    case 1 : return(0) ;
    case 2 : coe = 27070.0 ; /* pouces->microns */
             break ;
    case 3 : coe = 10000.0 ; /* cm->microns */
             break ;
  }

  val = val*coe ;
  nb  = (int) val ;
  return(nb) ;
}

int set_bwpal(INFO_IMAGE *inf)
{
  double coe ;
  int    *pt ;
  int    ind, i ;
  int    tcol, val ;

  tcol = 1 << BitsPerSample ;
  coe  = 1000.0/(double)(tcol-1) ;
  if (nb_colors > tcol) tcol = nb_colors ;
  inf->palette = Xalloc(6*tcol) ;
  if (inf->palette == NULL) return(-3) ;
  inf->nb_cpal = 1 << BitsPerSample ;
  memset(inf->palette, 0, tcol*6) ;

  pt = (int *) inf->palette ;
  for (i = 0; i < inf->nb_cpal; i++)
  {
    val       = (int) ((double)i*coe);
    ind       = 3*i ;
    pt[ind]   = val ;
    pt[1+ind] = val ;
    pt[2+ind] = val ;
  }

  inf->nb_cpal = 256 ;

  return(0) ;
}

int set_wbpal(INFO_IMAGE *inf)
{
  double coe ;
  int    *pt ;
  int    ind, i ;
  int    tcol, val ;

  tcol = 1 << BitsPerSample ;
  coe  = 1000.0/(double)(tcol-1) ;
  if (nb_colors > tcol) tcol = nb_colors ;
  inf->palette = Xalloc(6*tcol) ;
  if (inf->palette == NULL) return(-3) ;
  inf->nb_cpal = 1 << BitsPerSample ;
  memset(inf->palette, 0, tcol*6) ;

  pt = (int *) inf->palette ;
  for (i = 0; i < inf->nb_cpal; i++)
  {
    val       = (int) ((double)i*coe);
    val       = 1000-val ;
    ind       = 3*i ;
    pt[ind]   = val ;
    pt[1+ind] = val ;
    pt[2+ind] = val ;
  }

  inf->nb_cpal = 256 ;

  return(0) ;
}

unsigned long get_dim(TIFF_TAG *tag)
{
  unsigned long result ;

  if (tag->type == TSHORT)
  {
    result = tag->offset >> 16 ;
    if (ByteOrder == INTEL) result = int_reverse((unsigned int) result) ;
  }
  else
  {
    result = tag->offset ;
    if (ByteOrder == INTEL) result = long_reverse(result) ;
  }

  return(result) ;
}

void get_stripoffsets(TIFF_TAG *tag)
{
  TStripOffsets = tag->type ;
  if ((tag->length > 1) || (tag->type == TASCII) || (tag->type == TRATIONAL))
    StripOffsets = tag->offset ;
  else
    StripOffsets = get_dim(tag) ;
}

void get_stripbytecounts(TIFF_TAG *tag)
{
  TStripByteCounts = tag->type ;
  if ((tag->length > 1) || (tag->type == TASCII) || (tag->type == TRATIONAL))
    StripByteCounts = tag->offset ;
  else
    StripByteCounts = get_dim(tag) ;
}

void dcp_predictor(unsigned char *data, long nb)
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
    if (nbx == ImageWidth)
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

void cpi_predictor(unsigned char *data, long nb)
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
    if (nbx == ImageWidth)
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

void dcpi_predictor(unsigned char *data, long nb)
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
    if (nbx == ImageWidth)
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

void cp_predictor(unsigned char *data, long nb)
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
    if (nbx == ImageWidth)
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

int tag_interpret(FILE *stream, TIFF_TAG *tag, INFO_IMAGE *inf)
{
  FRACTION     xrational, yrational ;
  unsigned int pal[768] ;

  if (ByteOrder == INTEL) tag_reverse(tag) ;

  switch(tag->tag)
  {
    case BITS_PER_SAMPLE   : if (tag->length == 1) BitsPerSample = (unsigned int) get_dim(tag) ;
                             else BitsPerSample = 8 ;
                             if ((BitsPerSample != 1) && (BitsPerSample != 4) && (BitsPerSample != 8))
                               return(-6) ;
                             inf->nplans   = (int)BitsPerSample*(int)SamplesPerPixel ;
                             break ;
    case SAMPLES_PER_PIXEL : SamplesPerPixel = (unsigned int) get_dim(tag) ;
                             if ((SamplesPerPixel != 1) && (SamplesPerPixel != 3))
                               return(-6) ;
                             inf->nplans = (int)BitsPerSample*(int)SamplesPerPixel ;
                             break ;
    case COLOR_MAP         : fseek(stream, tag->offset, SEEK_SET) ;
                             fread(pal, 1 << BitsPerSample, 6, stream) ;
                             tiff2vdipalette(pal, inf) ;
                             if (inf->palette == NULL) return(-3) ;
                             break ;
    case IMAGE_WIDTH       : ImageWidth = get_dim(tag) ;
                             if (ImageWidth > 32767L) return(-6) ;
                             inf->largeur = (int) ImageWidth ;
                             break ;
    case IMAGE_LENGTH      : ImageLength  = get_dim(tag) ;
                             if (ImageLength > 32767L) return(-6) ;
                             inf->hauteur = (int) ImageLength ;
                             break ;
    case COMPRESSION       : Compression   = (unsigned int) get_dim(tag) ;
                             inf->compress = Compression ;
                             if ((Compression != 1) && (Compression != 5)  && (Compression !=32773U))
                               return(-7) ;
                             break ;
    case STRIP_OFFSETS     : get_stripoffsets(tag) ;
                             break ;
    case ROWS_PER_STRIP    : RowsPerStrip = get_dim(tag) ;
                             break ;
    case STRIP_BYTE_COUNTS : get_stripbytecounts(tag) ;
                             break ;
    case RESOLUTION_UNIT   : ResolutionUnit = (unsigned int) get_dim(tag) ;
                             inf->lpix = resol(&xrational) ;
                             inf->hpix = resol(&yrational) ;
                             break ;
    case X_RESOLUTION      : fseek(stream, tag->offset, SEEK_SET) ;
                             fread(&xrational, sizeof(FRACTION), 1, stream) ;
                             break ;
    case Y_RESOLUTION      : fseek(stream, tag->offset, SEEK_SET) ;
                             fread(&yrational, sizeof(FRACTION), 1, stream) ;
                             break ;
    case PHOTOMETRIC       : PhotometricInterpretation = (unsigned int) get_dim(tag) ;
                             if ((PhotometricInterpretation != 0) &&
                                 (PhotometricInterpretation != 1) &&
                                 (PhotometricInterpretation != 2) &&
                                 (PhotometricInterpretation != 3))
                             return(-6) ;
                             break ;
    case PLANAR_CONFIG     : PlanarConfiguration = (unsigned int) get_dim(tag) ;
                             if ((PlanarConfiguration != 1) && (PlanarConfiguration != 2))
                               return(-6) ;
                             break ;
    case PREDICTOR         : Predictor = (unsigned int) get_dim(tag) ;
                             if ((Predictor != 1) && (Predictor != 2))
                               return(-6) ;
                             inf->predictor = Predictor ;
                             break ;
  }

  return(0) ;
}

int tiff_tags(FILE *stream, INFO_IMAGE *inf)
{
  TIFF_TAG     *tags ;
  unsigned int nb_tags, i ;
  int          ret = 0 ;

  BitsPerSample       = 1 ; /* Peut etre omis */
  SamplesPerPixel     = 1 ; /* Peut etre omis */
  inf->nplans         = BitsPerSample*SamplesPerPixel ;
  ResolutionUnit      = 2 ;
  Compression         = 1 ;
  StripByteCounts     = 0 ;
  RowsPerStrip        = 0xFFFFFFFFUL ;
  PlanarConfiguration = 1 ;
  Predictor           = 1 ;

  fread(&nb_tags, 2, 1, stream) ;
  if (ByteOrder == INTEL) nb_tags = int_reverse(nb_tags) ;

  tags = (TIFF_TAG *) Xalloc(nb_tags*sizeof(TIFF_TAG)) ;
  if (tags == NULL) return(-3) ;
  fread(tags, sizeof(TIFF_TAG), nb_tags, stream) ;
  for (i = 0; i < nb_tags; i++)
  {
    ret = tag_interpret(stream, &tags[i], inf) ;
    if (ret != 0)
    {
      Xfree(tags) ;
      return(ret) ;
    }
  }

  if (inf->lpix == 0) inf->lpix = 0x152 ;
  if (inf->hpix == 0) inf->hpix = 0x152 ;
  Xfree(tags) ;

  return(0) ;
}

int tiff_identify(char *nom, INFO_IMAGE *inf)
{
  TIFF_HEADER entete ;
  FILE        *stream ;
  int         ret ;

  stream = fopen(nom, "rb") ;
  if (stream == NULL) return(-1) ;

  fread(&entete, sizeof(TIFF_HEADER), 1, stream) ;
  if ((entete.byte_order != MOTOROLA) && (entete.byte_order != INTEL))
  {
    fclose(stream) ;
    return(-2) ;
  }
  ByteOrder      = entete.byte_order ;
  inf->byteorder = ByteOrder ;

  if (ByteOrder == INTEL) entete.version    = int_reverse(entete.version) ;
  if (ByteOrder == INTEL) entete.ifd_offset = long_reverse(entete.ifd_offset) ;

  if (entete.version != 0x2A)
  {
    fclose(stream) ;
    return(-6) ;
  }

  inf->version = entete.version ;
  fseek(stream, entete.ifd_offset, SEEK_SET) ;
  ret = tiff_tags(stream, inf) ;
  fclose(stream) ;
  if (ret != 0) return(ret) ;

  inf->compress  = Compression ;
  inf->predictor = Predictor ;

  if (BitsPerSample != 1)
  {
    if (PhotometricInterpretation == 0) ret = set_wbpal(inf) ;
    else
    if (PhotometricInterpretation == 1) ret = set_bwpal(inf) ;
  }
  else
  {
    inf->nb_cpal = 0 ;
    inf->palette = NULL ;
  }

  if (StripByteCounts == 0)
    StripByteCounts = ImageWidth*ImageLength*SamplesPerPixel ;

  return(ret) ;
}

int tiff_read(FILE *stream, MFDB *out, GEM_WINDOW *wprog)
{
  long          taille ;
  unsigned long nb_strip, i, offset ;
  unsigned long nb_pts, num_pts ;
  unsigned long num ;
  unsigned long *ltab_sbc, *ltab_so ;
  long          dummy ;
  int           *last_line ;
  unsigned int  *itab_sbc, *itab_so ;
  int           code, pc ;
  int           nl ;
  unsigned char *buffer ;
  unsigned char *dcp_out ;
  unsigned char *temp ;
  unsigned char *pt_natural ;

  pt_natural = (unsigned char *) NaturalFormat ;
  i2r_init(out, (int) ImageWidth, 1) ;
  if (RowsPerStrip != 0xFFFFFFFFUL)
    nb_strip = (ImageLength+RowsPerStrip-1)/RowsPerStrip ;
  else
  {
    nb_strip     = 1 ;
    RowsPerStrip = ImageLength ;
  }

  if (TStripByteCounts == TSHORT) taille = nb_strip*2 ;
  else                            taille = nb_strip*4 ;
  itab_sbc = (unsigned int *) Xalloc(taille) ;
  if (itab_sbc == NULL) return(-3) ;
  ltab_sbc = (unsigned long *) itab_sbc ;
  if (taille > 4)
  {
    fseek(stream, StripByteCounts, SEEK_SET) ;
    fread(itab_sbc, 1, taille, stream) ;
  }
  else
    memcpy(itab_sbc, &StripByteCounts, taille) ;

  if (TStripOffsets == TSHORT) taille = nb_strip*2*SamplesPerPixel ;
  else                         taille = nb_strip*4*SamplesPerPixel ;
  itab_so = (unsigned int *) Xalloc(taille) ;
  if (itab_so == NULL)
  {
    Xfree(itab_sbc) ;
    return(-3) ;
  }
  ltab_so = (unsigned long *) itab_so ;
  if (taille > 4*SamplesPerPixel)
  {
    fseek(stream, StripOffsets, SEEK_SET) ;
    fread(itab_so, 1, taille, stream) ;
  }
  else
    memcpy(itab_so, &StripOffsets, taille) ;

  if ((ByteOrder == INTEL) && (taille > 4*SamplesPerPixel))
  {
    for (i = 0; i < nb_strip; i++)
    {
      if (TStripByteCounts == TSHORT) itab_sbc[i] = int_reverse(itab_sbc[i]) ;
      else                            ltab_sbc[i] = long_reverse(ltab_sbc[i]) ;
      if (TStripOffsets == TSHORT)    itab_so[i]  = int_reverse(itab_so[i]) ;
      else                            ltab_so[i]  = long_reverse(ltab_so[i]) ;
    }
  }

  if (nb_strip > 1)
  {
    taille = 0 ;
    for (i = 0; i < nb_strip; i++)
    {
      if (TStripByteCounts == TSHORT) i2r_nb = itab_sbc[i] ;
      else                            i2r_nb = ltab_sbc[i] ;
      if (i2r_nb > taille) taille = i2r_nb ;
    }
  }
  else
  {
    taille = filelength( fileno(stream) ) ;
    if (taille == -1)
    {
      Xfree(itab_sbc) ;
      Xfree(itab_so) ;
      return(-2) ;
    }
  }
  buffer = (unsigned char *) Xalloc(taille) ;
  if (buffer == NULL)
  {
    Xfree(itab_sbc) ;
    Xfree(itab_so) ;
    return(-3) ;
  }

  num_pts = 0 ;
  if (BitsPerSample == 1)
  {
    nb_pts = ImageWidth/8 ;
    if (ImageWidth % 8) nb_pts++ ;
    nb_pts *= 8 ;
    nb_pts *= ImageLength ;
    
  }
  else nb_pts = ImageWidth*ImageLength ;

  if (Compression == 32773U)
  {
    size_t size ;

    size    = 16L*(long)out->fd_wdwidth*(RowsPerStrip << 1) ;
    dcp_out = (unsigned char *) Xalloc(size) ;
    if (dcp_out == NULL)
    {
      Xfree(itab_sbc) ;
      Xfree(itab_so) ;
      Xfree(buffer) ;
      return(-3) ;
    }
  }
  else
  if (Compression == 5)
  {
    size_t size ;

    if (RowsPerStrip != 0xFFFFFFFFUL)
      size = (size_t)ImageWidth*(size_t)(1+RowsPerStrip)*(size_t)SamplesPerPixel ;
    else
      size = (size_t)ImageWidth*(size_t)ImageLength*(size_t)SamplesPerPixel ;
    dcp_out = (unsigned char *) Xalloc(size) ;
    if (dcp_out == NULL)
    {
      Xfree(itab_sbc) ;
      Xfree(itab_so) ;
      Xfree(buffer) ;
      return(-3) ;
    }
    if (lzw_init(8, buffer, 0) != 0)
    {
      /* NB : ici buffer sert uniquement … indiquer la d‚compression */
      Xfree(itab_sbc) ;
      Xfree(itab_so) ;
      Xfree(buffer) ;
      Xfree(dcp_out) ;
      return(-3) ;
    }
    code_size = 9 ;
  }

  if (Compression == 5) StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_DECODAGELZW)  ) ;
  else if (Compression == 32773U) StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_DECODAGEPCB)  ) ;
  if ((Compression == 5) && (MachineInfo.cpu >= 30L)) StdProgDisplay030( wprog, 1 ) ;

  temp  = (unsigned char *) out->fd_addr ;
  temp += img_size( out->fd_w, out->fd_h-1, out->fd_nplanes ) ;
  last_line  = (int *) temp ;

  for (i = 0; i < nb_strip; i++)
  {
    if (StripByteCounts != 0)
    {
      if (TStripByteCounts == TSHORT) i2r_nb = itab_sbc[i] ;
      else                            i2r_nb = ltab_sbc[i] ;
      if (TStripOffsets == TSHORT)    offset = itab_so[i] ;
      else                            offset = ltab_so[i] ;
    }
    else
    {
      i2r_nb = nb_pts*(unsigned long)SamplesPerPixel ;
      offset = StripOffsets ;
    }

    switch(BitsPerSample)
    {
      case 1 : num = i2r_nb << 3 ;
               if ( ( Compression == 1 ) && ( num_pts+num > nb_pts ) )
                 i2r_nb = (nb_pts-num_pts) >> 3 ;
               num = i2r_nb << 3 ;
               break ;
      case 4 : num = i2r_nb << 1 ;
               if ( ( Compression == 1 ) && ( num_pts+num > nb_pts ) )
                 i2r_nb = (nb_pts-num_pts) >> 1 ;
               num = i2r_nb << 1 ;
               break ;
      case 8 : num = i2r_nb/SamplesPerPixel ;
               if ( ( Compression == 1 ) && ( num_pts+num > nb_pts ) )
                 i2r_nb = (nb_pts-num_pts)*SamplesPerPixel ;
               num = i2r_nb/SamplesPerPixel ;
               break ;
    }

    perf_start( PERF_DISK, &PerfInfo ) ;
    fseek(stream, offset, SEEK_SET) ;
    i2r_nb = fread( buffer, 1, i2r_nb, stream ) ;
    perf_stop( PERF_DISK, &PerfInfo ) ;

    if (Compression == 5)
    {
      perf_start( PERF_COMPRESS, &PerfInfo ) ;
      bit1      = 7 ;
      code_size = 9 ;
      pt_in     = buffer ;
      bit_shift = 0 ;
      i2r_nb    = lzw_decompress(buffer, dcp_out, i2r_nb) ;
      if (i2r_nb == 0)
      {
        fclose(stream) ;
        Xfree(itab_sbc) ;
        Xfree(itab_so) ;
        Xfree(buffer) ;
        Xfree(dcp_out) ;
        lzw_end(&dummy) ;
        return(-4) ;
      }
      i2r_data = dcp_out ;
      if (BitsPerSample == 1) num = i2r_nb << 3 ;
      else                    num = i2r_nb/SamplesPerPixel ;
      perf_stop( PERF_COMPRESS, &PerfInfo ) ;
    }
    else if (Compression == 32773U)
    {
      perf_start( PERF_COMPRESS, &PerfInfo ) ;
      num      = out->fd_wdwidth*out->fd_nplanes ;
      i2r_nb   = num ;
      i2r_nb  *= RowsPerStrip ;
      nl       = (int)RowsPerStrip ;
      while ((int *)i2rout+i2r_nb >= last_line+num)
      {
        nl-- ;
        i2r_nb -= num ;
      }
      if (nl > 0)
      {
        if (BitsPerSample == 1) packbits_dcmps(buffer, dcp_out, (int)ImageWidth, nl, out->fd_nplanes) ;
        else                    packbits_idcmps(buffer, dcp_out, (int)ImageWidth, nl, out->fd_nplanes) ;
      }
      i2r_data = dcp_out ;
      switch(BitsPerSample)
      {
        case 1 : i2r_nb <<= 1 ;
                 break ;
        case 4 : i2r_nb = (ImageWidth*nl) >> 1 ;
                 break ;
        case 8 : i2r_nb = ImageWidth*nl ;
                 break ;
      }
      perf_stop( PERF_COMPRESS, &PerfInfo ) ;
    }
    else
      i2r_data = buffer ;

    if ((Compression == 32773U) && (nl <= 0)) break ;

    perf_start( PERF_IND2RASTER, &PerfInfo ) ;
    switch(BitsPerSample)
    {
      case 1 : temp = (unsigned char *) i2rout ;
               if (Compression == 1)
               {
                 if (out->fd_w-ImageWidth < 8)
                 {
                   if (temp+i2r_nb > (unsigned char *)last_line) i2r_nb = (unsigned char *)last_line-temp-1 ;
                   memcpy(temp, buffer, i2r_nb) ;
                   temp  += (RowsPerStrip*out->fd_wdwidth) << 1 ;
                   i2rout = temp ;
                 }
                 else
                 {
                   long          nb ;
                   int           *pt1 ;
                   int           i ;
                   unsigned char *pt2 ;

                   pt1 = (int *) i2rout ;
                   pt2 = buffer ;
                   nb  = (ImageWidth+7) >> 3 ;
                   for (i = 0; i < RowsPerStrip; i++)
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
                 long          nrow ;
                 long          nb_octets = ImageWidth >> 3 ;
                 unsigned char *pt ;
               
                 pt = dcp_out ;
                 if ( ImageWidth % 8 ) nb_octets++ ;
                 for ( nrow = 0; ( nrow < RowsPerStrip ) && ( temp <= (unsigned char *) last_line) ; nrow++ )
                 {
                   memcpy( temp, pt, nb_octets ) ;
                   temp += out->fd_wdwidth << 1 ;
                   pt   += nb_octets ;
                 }
                 i2rout = temp ;
               }
               break ;
      case 4 :
               if ( NaturalFormat == NULL )
                 find2raster() ;
               else
               {
                 long          n ;
                 unsigned char *data ;
                 
                 data = (unsigned char *) i2r_data ;
                 for ( n = 0; n < i2r_nb ; n++ )
                 {
                   *pt_natural++ = *data >> 4 ;
                   *pt_natural++ = *data++ & 0x0F ;
                 }
               }
               break ;
      case 8 : temp = (unsigned char *) i2rout ;
               if (SamplesPerPixel == 1)
               {
                 if (Predictor == 2) dcpi_predictor(dcp_out, i2r_nb) ;
                 if (img_analyse) pal_ajust() ;
                 if ( NaturalFormat == NULL )
                   ind2raster() ;
                 else
                 {
                   memcpy( pt_natural, i2r_data, i2r_nb ) ;
                   pt_natural += i2r_nb ;
                 }
               }
               else
               {
                 if (Predictor == 2) dcp_predictor(dcp_out, i2r_nb) ;
                 if (PlanarConfiguration == 1)
                 {
                   if ( out->fd_nplanes == 16 ) tc24to16() ;
                   else if ( out->fd_nplanes == 24 )
                   {
                     long          nrow ;
                     long          nb_octets = ImageWidth*3 ;
                     unsigned char *pt ;
               
                     pt = i2r_data ;
                     for ( nrow = 0; ( nrow < RowsPerStrip ) && ( temp <= (unsigned char *) last_line) ; nrow++ )
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
                     long          nb_octets = ImageWidth*3 ;
                     long          x ;
                     unsigned char *pt, *t, *tp ;
               
                     pt = i2r_data ;
                     for ( nrow = 0; ( nrow < RowsPerStrip ) && ( temp <= (unsigned char *) last_line) ; nrow++ )
                     {
                       t  = temp ;
                       tp = pt ;
                       for ( x = 0; x < ImageWidth; x++ )
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
                 else
                 {
                   if ( out->fd_nplanes == 16 ) tc24ito16(i2r_nb/3L) ;
/*                   else*/
                 }
               }
               break ;
    }
    num_pts = num_pts+num ;
    perf_stop( PERF_IND2RASTER, &PerfInfo ) ;

    if ( wprog && ( nb_strip != 1 ) )
    {
      pc = (int) (100L*(i+1)/(nb_strip-1)) ;
      code = wprog->ProgPc( wprog, pc, NULL ) ;
      if ( STOP_CODE( code ) )
      {
        fclose(stream) ;
        Xfree(itab_sbc) ;
        Xfree(itab_so) ;
        Xfree(buffer) ;
        if (Compression != 1) Xfree(dcp_out) ;
        if (Compression == 5) lzw_end(&dummy) ;
        return(-8) ;
      }
    }
  }

  fclose(stream) ;
  if (Compression != 1) Xfree(dcp_out) ;
  if (Compression == 5) lzw_end(&dummy) ;
  Xfree(buffer) ;
  Xfree(itab_so) ;
  Xfree(itab_sbc) ;

  if (BitsPerSample == 1)
  {
    int xy[8] ;

    /* Si Min Is Black, cela revient … 'n‚gativer' l'image */    
    if ( PhotometricInterpretation == 1 )
    {
      xy[0] = xy[4] = xy[1] = xy[5] = 0 ;
      xy[2] = xy[6] = out->fd_w-1 ;
      xy[3] = xy[7] = out->fd_h-1 ;
      vro_cpyfm( handle, D_INVERT, xy, out, out ) ;
    }

    /* Elimine les points de bourrage dus au codage sur un octet */
    if ( (int)ImageWidth < out->fd_w )
    {
      xy[0] = xy[4] = (int)ImageWidth ;
      xy[1] = xy[5] = 0 ;
      xy[2] = xy[6] = out->fd_w-1 ;
      xy[3] = xy[7] = out->fd_h-1 ;
      vro_cpyfm( handle, ALL_WHITE, xy, out, out ) ;
    }
  }

  return( 0 ) ;
}

int tiff_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  FILE *stream ;
  int  ret ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return(-1) ;

  if (ImageWidth % 16) out->fd_w = (int) (16+(ImageWidth & 0xFFFFFFF0L)) ;
  else                 out->fd_w = (int) ImageWidth ;
  out->fd_h = (int) ImageLength ;
  if (SamplesPerPixel == 1) out->fd_nplanes = BitsPerSample ;
  else
  {
    if ( Force16BitsLoad ) out->fd_nplanes = 16 ;
    else
    {
      if ( FinalNbPlanes >= 16 )  out->fd_nplanes = FinalNbPlanes ;
      else                        out->fd_nplanes = SamplesPerPixel*BitsPerSample ;
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

  if ( may_use_natural_format( FinalNbPlanes, out->fd_nplanes ) )
  {
    NaturalFormat = Xalloc( (long)out->fd_w*(long)out->fd_h ) ;
    NaturalWidth  = (int) ImageWidth ;
  }

  ret = tiff_read( stream, out, wprog ) ;
  fclose(stream) ;

  return( ret ) ;
}

void tag_write(TIFF_TAG *tag, INFO_IMAGE *info, FILE *stream)
{
  TIFF_TAG intel_tag ;

  if (info->byteorder == INTEL)
  {
    memcpy(&intel_tag, tag, sizeof(TIFF_TAG)) ;
    tag_reverse(&intel_tag) ;
    fwrite(&intel_tag, sizeof(TIFF_TAG), 1, stream) ;
  }
  else
    fwrite(tag, sizeof(TIFF_TAG), 1, stream) ;
}

int tags_make(INFO_IMAGE *info, FILE *stream)
{
  TIFF_TAG      tag ;
  unsigned long taille ;
  unsigned long next_ifd_offset = 0L ; /* Une seule image */

  NbTags = 13 ;
  if (info->nplans >= 16) info->nplans = 24 ;

  if ((info->palette != NULL) && (info->nplans != 1)) NbTags++ ;
  if ((info->compress != 5) || (BitsPerSample < 8)) info->predictor = 1 ;
  if (info->predictor == 2) NbTags++ ;
  if (info->byteorder == INTEL)
  {
    unsigned int nbtagsintel ;

    nbtagsintel = int_reverse(NbTags) ;
    fwrite(&nbtagsintel, 2, 1, stream) ;
  }
  else
    fwrite(&NbTags, 2, 1, stream) ;

  if (info->nplans != 24)
  {
    BitsPerSample   = info->nplans ;
    SamplesPerPixel = 1 ;
    if ((info->palette != NULL) && (info->nplans != 1))
      PhotometricInterpretation = 3 ;
    else
      PhotometricInterpretation = 0 ;
  }
  else
  {
    SamplesPerPixel           = 3 ;
    BitsPerSample             = 8 ;
    PhotometricInterpretation = 2 ;
  }
  ResolutionUnit = 3 ; /* En cm */
  Compression = info->compress ;
  if ( Compression == 32773U ) Compression = 5 ; /* Transforme la compression PackBits  */
                                                 /* En compression LZW plus performante */
  if ( Compression != 5 ) Compression = 1 ;      /* Si inconnu, on ne compresse pas     */
  ImageWidth  = info->largeur ;
  if (ImageWidth % 16) ImageWidth = (16+ImageWidth) & 0xFFFFFFF0UL ;
  ImageLength  = info->hauteur ;
  StripOffsets = 14+NbTags*sizeof(TIFF_TAG) ;
  taille = img_size((int) ImageWidth, 1, info->nplans) ;
  RowsPerStrip = 16384/taille ;
  if (Compression == 5) RowsPerStrip = RowsPerStrip*2 ;
  if (RowsPerStrip > ImageLength) RowsPerStrip = ImageLength/2 ;
  if (RowsPerStrip == 0) RowsPerStrip = 1 ;
  StripsPerImage   = (unsigned int) ((ImageLength+RowsPerStrip-1)/RowsPerStrip) ;
  StripByteCounts  = StripOffsets+StripsPerImage*4 ;
  TStripOffsets    = TLONG ;
  TStripByteCounts = TLONG ;
  Predictor        = info->predictor ;
  ByteOrder        = info->byteorder ;
  XResolution      = StripByteCounts+StripsPerImage*4 ;
  YResolution      = XResolution+sizeof(FRACTION) ;
  if (info->nplans == 24)
  {
    BitsPerSample = (unsigned int) (YResolution+sizeof(FRACTION)) ;
    ColorMap      = BitsPerSample+6 ;
  }
  else
    ColorMap = YResolution+sizeof(FRACTION) ;

  tag.tag    = NEW_SUBFILE_TYPE ;
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = 0 ;
  tag_write(&tag, info, stream) ;

  tag.tag    = IMAGE_WIDTH ;
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = ImageWidth ;
  tag_write(&tag, info, stream) ;

  tag.tag    = IMAGE_LENGTH ;
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = ImageLength ;
  tag_write(&tag, info, stream) ;

  tag.tag  = BITS_PER_SAMPLE ;
  tag.type = TSHORT ;
  if (info->nplans != 24)
  {
    tag.length = 1 ;
    if (info->byteorder == INTEL)
      tag.offset = (unsigned long)info->nplans ;
    else
      tag.offset = ((unsigned long)info->nplans) << 16 ;
  }
  else
  {
    tag.length = SamplesPerPixel ;
    tag.offset = BitsPerSample ;
  }
  tag_write(&tag, info, stream) ;

  tag.tag    = COMPRESSION ;
  tag.type   = TSHORT ;
  tag.length = 1 ;
  if (info->byteorder == INTEL)
    tag.offset = (unsigned long)Compression ;
  else
    tag.offset = (unsigned long)Compression << 16 ;
  tag_write(&tag, info, stream) ;
 
  tag.tag    = PHOTOMETRIC ;
  tag.type   = TSHORT ;
  tag.length = 1 ;
  if (info->nplans != 24)
  {
    if ((info->palette != NULL) && (info->nplans != 1))
    {
      if (info->byteorder == INTEL)
       tag.offset = 0x00000003UL ;
      else
       tag.offset = 0x00030000UL ;
    }
    else
     tag.offset = 0 ;
  }
  else
  {
    if (info->byteorder == INTEL)
      tag.offset = 0x00000002UL ;
    else
      tag.offset = 0x00020000UL ;
  }
  tag_write(&tag, info, stream) ;

  tag.tag    = STRIP_OFFSETS ;
  tag.type   = TLONG ;
  tag.length = StripsPerImage ;
  tag.offset = StripOffsets ;
  tag_write(&tag, info, stream) ;

  tag.tag    = SAMPLES_PER_PIXEL ;
  tag.type   = TSHORT ;
  tag.length = 1 ;
  if (info->nplans != 24)
  {
    if (info->byteorder == INTEL)
      tag.offset = 0x00000001UL ;
    else
      tag.offset = 0x00010000UL ;
  }
  else
  {
    if (info->byteorder == INTEL)
      tag.offset = 0x00000003UL ;
    else
      tag.offset = 0x00030000UL ;
  }
  tag_write(&tag, info, stream) ;

  tag.tag    = ROWS_PER_STRIP ;
  tag.type   = TLONG ;
  tag.length = 1 ;
  tag.offset = RowsPerStrip ;
  tag_write(&tag, info, stream) ;

  tag.tag    = STRIP_BYTE_COUNTS ;
  tag.type   = TLONG ;
  tag.length = StripsPerImage ;
  tag.offset = StripByteCounts ;
  tag_write(&tag, info, stream) ;

  tag.tag    = X_RESOLUTION ;
  tag.type   = TRATIONAL ;
  tag.length = 1 ;
  tag.offset = XResolution ;
  tag_write(&tag, info, stream) ;

  tag.tag    = Y_RESOLUTION ;
  tag.type   = TRATIONAL ;
  tag.length = 1 ;
  tag.offset = YResolution ;
  tag_write(&tag, info, stream) ;

  tag.tag    = RESOLUTION_UNIT ;
  tag.type   = TSHORT ;
  tag.length = 1 ;
  if (info->byteorder == INTEL)
    tag.offset = (unsigned long)ResolutionUnit ;
  else
    tag.offset = ((unsigned long)ResolutionUnit) << 16 ;
  tag_write(&tag, info, stream) ;

  if (Predictor == 2)
  {
    tag.tag    = PREDICTOR ;
    tag.type   = TSHORT ;
    tag.length = 1 ;
    if (info->byteorder == INTEL)
      tag.offset = (unsigned long) Predictor ;
    else
      tag.offset = (unsigned long)Predictor << 16 ;
    tag_write(&tag, info, stream) ;
  }

  if ((info->palette != NULL) && (info->nplans != 1) && (info->nplans != 24))
  {
    tag.tag    = COLOR_MAP ;
    tag.type   = TSHORT ;
    tag.length = 3*(1 << BitsPerSample) ;
    tag.offset = ColorMap ;
    tag_write(&tag, info, stream) ;
  }

  fwrite(&next_ifd_offset, 4, 1, stream) ;

  return(0) ;
}

int tiff_wrpal(INFO_IMAGE *info, FILE *stream)
{
  unsigned int *pal, *ptiff ;
  unsigned int tiffpal[3*256] ;
  unsigned int color ;
  int          i, j, ind ;
  int          nb_col ;

  pal    = (unsigned int *) info->palette ;
  nb_col = 1 << BitsPerSample ;
  ptiff  = tiffpal ;
  for (j = 0; j < 3; j++)
  {
    for (i = 0; i < nb_col; i++)
    {
      ind   = j+3*i ;
      color = pal[ind] ;
      if (color > 1000) color = 1000 ;
      *ptiff = color << 6 ;
      if (info->byteorder == INTEL) *ptiff = int_reverse(*ptiff) ;
      ptiff++ ;
    }
  }

  if (fwrite(tiffpal, 6, nb_col, stream) != nb_col) return(-2) ;

  return(0) ;
}

int tiff_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  TIFF_HEADER   header ;
  FRACTION      resol, intel_resol ;
  FILE          *stream ;
  unsigned long *ltab_so ;
  unsigned long *ltab_sbc ;
  unsigned long nb_pts, num_pts, num ;
  unsigned long nb_octet ;
  long          lo_ligne ;
  long          nb_out ;
  unsigned int  nbits ;
  int           pc ;
  int           *pt_img ;
  int           i ;
  int           ret ;
  unsigned char *buffer ;
  char          *adr ;

  if (img->fd_nplanes == 2) return(-4) ;

  stream = fopen(name, "wb") ;
  if (stream == NULL) return(-1) ;

  if ((info->byteorder != MOTOROLA) && (info->byteorder != INTEL))
    info->byteorder = MOTOROLA ;
  header.byte_order = info->byteorder ;
  header.version    = 0x2A ;
  header.ifd_offset = 0x08UL ;
  if (info->byteorder == INTEL)
  {
    header.version    = int_reverse(header.version) ;
    header.ifd_offset = long_reverse(header.ifd_offset) ;
  }
  fwrite(&header, sizeof(TIFF_HEADER), 1, stream) ;

  ret = tags_make(info, stream) ;
  if (ret != 0)
  {
    fclose(stream) ;
    return(ret) ;
  }

  ltab_so = (unsigned long *) Xalloc(sizeof(long)*StripsPerImage) ;
  if (ltab_so == NULL)
  {
    fclose(stream) ;
    return(-3) ;
  }

  ltab_sbc = (unsigned long *) Xalloc(4*StripsPerImage) ;
  if (ltab_sbc == NULL)
  {
    Xfree(ltab_so) ;
    fclose(stream) ;
    return(-3) ;
  }

  memset(ltab_so, 0, 4*StripsPerImage) ;
  memset(ltab_sbc, 0, 4*StripsPerImage) ;
  if (fwrite(ltab_so, 4, StripsPerImage, stream) != StripsPerImage)
  {
    Xfree(ltab_sbc) ;
    Xfree(ltab_so) ;
    fclose(stream) ;
    return(-1) ;
  }
  if (fwrite(ltab_sbc, 4, StripsPerImage, stream) != StripsPerImage)
  {
    Xfree(ltab_sbc) ;
    Xfree(ltab_so) ;
    fclose(stream) ;
    return(-1) ;
  }

  resol.numerateur   = 10000 ;
  resol.denominateur = info->lpix ;
  if (info->byteorder == INTEL)
  {
    memcpy(&intel_resol, &resol, sizeof(FRACTION)) ;
    fraction_reverse(&intel_resol) ;
    fwrite(&intel_resol, sizeof(FRACTION), 1, stream) ;
  }
  else
    fwrite(&resol, sizeof(FRACTION), 1, stream) ;

  resol.numerateur   = 10000 ;
  resol.denominateur = info->hpix ;
  if (info->byteorder == INTEL)
  {
    memcpy(&intel_resol, &resol, sizeof(FRACTION)) ;
    fraction_reverse(&intel_resol) ;
    fwrite(&intel_resol, sizeof(FRACTION), 1, stream) ;
  }
  else
    fwrite(&resol, sizeof(FRACTION), 1, stream) ;

  if (info->nplans == 24)
  {
    BitsPerSample   = 8 ;
    SamplesPerPixel = 3 ;
    nbits           = 8 ;
    if (info->byteorder == INTEL) nbits = int_reverse(nbits) ;
    for (i = 0; i < SamplesPerPixel; i++)
      fwrite(&nbits, 2, 1, stream) ;
  }
  else
  {
    if ((info->palette != NULL) && (info->nplans != 1))
      if (tiff_wrpal(info, stream) != 0)
      {
        Xfree(ltab_sbc) ;
        Xfree(ltab_so) ;
        fclose(stream) ;
        return(-1) ;
      }
  }

  if (BitsPerSample != 1)
  {
    long taille ;

    taille = ImageWidth*RowsPerStrip*SamplesPerPixel ;
    buffer = (unsigned char *) Xalloc(taille) ;
    if (buffer == NULL)
    {    
      Xfree(ltab_sbc) ;
      Xfree(ltab_so) ;
      fclose(stream) ;
      return(-3) ;
    }
    memset(buffer, 0, taille) ;
  }

  lo_ligne = img_size((int)ImageWidth, 1, BitsPerSample*SamplesPerPixel) ;
  num_pts  = 0 ;
  nb_pts   = ImageWidth*ImageLength ;
  adr      = (char *) img->fd_addr ;
  pt_img   = (int *) img->fd_addr ;

  if (Compression == 5) StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_ENCODAGELZW)  ) ;
  if ((Compression == 5) && (MachineInfo.cpu >= 30L)) StdProgDisplay030( wprog, 1 ) ;

  for (i = 0; i < StripsPerImage; i++)
  {
    switch(BitsPerSample)
    {
      case 1 : num = (RowsPerStrip*lo_ligne) << 3 ;
               if (num_pts+num > nb_pts) num = nb_pts-num_pts ;
               nb_octet    = num >> 3 ;
               num_pts     = num_pts+num ;
               ltab_sbc[i] = nb_octet ;
               ltab_so[i]  = ftell(stream) ;
               if (Compression == 1)
               {
                 if (fwrite(adr, 1, nb_octet, stream) != nb_octet)
                 {
                   Xfree(ltab_sbc) ;
                   Xfree(ltab_so) ;
                   fclose(stream) ;
                   return(-2) ;
                 }
                 ltab_sbc[i] = nb_octet ;
               }
               else
               if (Compression == 5)
               {
                 int err ;

                 code_size = 9 ;
                 err = lzw_init(8, NULL, 0) ;
                 if (!err) err = lzw_compress((unsigned char *)adr, nb_octet, stream, &nb_out) ;
                 switch(err)
                 {
                   case -3 : lzw_end(&nb_out) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-3) ;
                   case -2 : lzw_end(&nb_out) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-2) ;
                   case -1 : lzw_end(&nb_out) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-1) ;
                 }
                 ltab_sbc[i] = nb_out ;
               }
               adr = adr+nb_octet ;
               break ;
      case 4 : num = (RowsPerStrip*lo_ligne) << 1 ;
               if (num_pts+num > nb_pts) num = nb_pts-num_pts ;
               nb_octet = num >> 1 ;
               num_pts  = num_pts+num ;
               raster2ind(pt_img, buffer, num, 4) ;
               ind4plans(buffer, num) ;
               ltab_so[i] = ftell(stream) ;
               if (Compression == 1)
               {
                 if (fwrite(buffer, 1, nb_octet, stream) != nb_octet)
                 {
                   Xfree(buffer) ;
                   Xfree(ltab_sbc) ;
                   Xfree(ltab_so) ;
                   fclose(stream) ;
                   return(-2) ;
                 }
                 ltab_sbc[i] = nb_octet ;
               }
               else
               if (Compression == 5)
               {
                 int err ;

                 code_size = 9 ;
                 err = lzw_init(8, NULL, 0) ;
                 if (!err) err = lzw_compress(buffer, nb_octet, stream, &nb_out) ;
                 switch(err)
                 {
                   case -3 : lzw_end(&nb_out) ;
                             Xfree(buffer) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-3) ;
                   case -2 : lzw_end(&nb_out) ;
                             Xfree(buffer) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-2) ;
                   case -1 : lzw_end(&nb_out) ;
                             Xfree(buffer) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-1) ;
                 }
                 ltab_sbc[i] = nb_out ;
               }
               pt_img = pt_img+nb_octet/2 ;
               break ;
      case 8 : num = RowsPerStrip*ImageWidth ;
               if (num_pts+num > nb_pts) num = nb_pts-num_pts ;
               nb_octet    = num*SamplesPerPixel ;
               num_pts     = num_pts+num ;
               ltab_sbc[i] = nb_octet ;
               ltab_so[i]  = ftell(stream) ;
               if (img->fd_nplanes <= 8)
               {
                 raster2ind(pt_img, buffer, num, 8) ;
                 if (Predictor == 2) cpi_predictor(buffer, nb_octet) ;
               }
               else
               {
                 if ( img->fd_nplanes == 16 )
                   tc16to24( pt_img, buffer, num ) ;
                 else
                 if ( img->fd_nplanes == 24 )
                   memcpy( buffer, pt_img, nb_octet ) ;
                 else
                 if ( img->fd_nplanes == 32 )
                   tc32to24( (long*)pt_img, buffer, num ) ;

                 if (Predictor == 2) cp_predictor(buffer, nb_octet) ;
               }
               if (Compression == 5)
               {
                 int err ;

                 code_size = 9 ;
                 err = lzw_init(8, NULL, 0) ;
                 if (!err) err = lzw_compress(buffer, nb_octet, stream, &nb_out) ;
                 switch(err)
                 {
                   case -3 : lzw_end(&nb_out) ;
                             Xfree(buffer) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-3) ;
                   case -2 : lzw_end(&nb_out) ;
                             Xfree(buffer) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-2) ;
                   case -1 : lzw_end(&nb_out) ;
                             Xfree(buffer) ;
                             Xfree(ltab_sbc) ;
                             Xfree(ltab_so) ;
                             fclose(stream) ;
                             return(-1) ;
                 }
                 ltab_sbc[i] = nb_out ;
               }
               else
               if (fwrite(buffer, 1, nb_octet, stream) != nb_octet)
               {
                 Xfree(buffer) ;
                 Xfree(ltab_sbc) ;
                 Xfree(ltab_so) ;
                 fclose(stream) ;
                 return(-2) ;
               }

               if (img->fd_nplanes <= 8)       pt_img = pt_img+nb_octet/2 ;
               else if (img->fd_nplanes == 16) pt_img = pt_img+num ;
               else if (img->fd_nplanes == 24) pt_img = pt_img+ (3*num)/2 ;
               else if (img->fd_nplanes == 32) pt_img = pt_img+num*2 ;
                
               break ;
    }
    if ( wprog )
    {
      pc = (int) (100L*(i+1)/(long)StripsPerImage) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
  }

  fseek(stream, StripOffsets, SEEK_SET) ;
  if (info->byteorder == INTEL)
  {
    for (i = 0; i < StripsPerImage; i++)
      ltab_so[i] = long_reverse(ltab_so[i]) ;
  }
  fwrite(ltab_so, 4, StripsPerImage, stream) ;
  fseek(stream, StripByteCounts, SEEK_SET) ;
  if (info->byteorder == INTEL)
  {
    for (i = 0; i < StripsPerImage; i++)
      ltab_sbc[i] = long_reverse(ltab_sbc[i]) ;
  }
  fwrite(ltab_sbc, 4, StripsPerImage, stream) ;

  if (BitsPerSample != 1) Xfree(buffer) ;
  Xfree(ltab_sbc) ;
  Xfree(ltab_so) ;
  if (fclose(stream)) return(-2) ;

  return(0) ;
}

void tiff_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "TIF\0TIFF\0\0" ;

  caps->iid = IID_TIFF ;
  strcpy( caps->short_name, "TIFF" ) ;
  strcpy( caps->file_extension, "TIF" ) ;
  strcpy( caps->name, "Tagged Image File Format 5.0" ) ;
  caps->version = 0x0400 ;

  caps->inport1         = 1 ;
  caps->inport2         = 0 ;
  caps->inport4         = 1 ;
  caps->inport8         = 1 ;
  caps->inport16        = 0 ;
  caps->inport24        = 1 ;
  caps->inport32        = 0 ;
  caps->inport_nocmp    = 1 ;
  caps->inport_rle      = 0 ;
  caps->inport_lzw      = 1 ;
  caps->inport_packbits = 1 ;
  caps->inport_jpeg     = 0 ;
  caps->inport_rfu      = 0 ;

  caps->export1         = 1 ;
  caps->export2         = 0 ;
  caps->export4         = 1 ;
  caps->export8         = 1 ;
  caps->export16        = 0 ;
  caps->export24        = 1 ;
  caps->export32        = 0 ;
  caps->export_nocmp    = 1 ;
  caps->export_rle      = 0 ;
  caps->export_lzw      = 1 ;
  caps->export_packbits = 0 ;
  caps->export_jpeg     = 0 ;
  caps->export_rfu      = 0 ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
