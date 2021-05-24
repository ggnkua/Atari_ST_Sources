/***********************************************/
/* Gestion du Graphic Interchange Format (GIF) */
/***********************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include      "defs.h" /* A pretty bad dependency with VISION ...*/
#include       "lzw.h"
#include    "msgtxt.h"
#include   "logging.h"
#include  "rasterop.h"

#define ID_DESCRIPTOR      ','
#define GIF_TERMINATOR     ';'
#define GIF_EXTENDER      0x21
#define GIF_CONTROL_LABEL 0xF9

#define DCPRS_SIZE    (64L*1024L)

extern HMSG hMsg ; /* For accessing messages */

typedef struct
{
  char          signature[6] ;
  unsigned int  width ;
  unsigned int  height ;
  unsigned char color_inf ;
  unsigned char background ;
  unsigned char map ;
}
GIF_HEADER ;

typedef struct
{
  unsigned int  deltax ;
  unsigned int  deltay ;
  unsigned int  width ;
  unsigned int  height ;
  unsigned char color_inf ;
}
GIF_DESCRIPTOR ;

/* Hold data we need to perform gif_load after being filled by gif_identify */
typedef struct _GIF_SPECIFIC
{
  GIF_HEADER     header ;
  GIF_DESCRIPTOR descriptor ;
}
GIF_SPECIFIC, *PGIF_SPECIFIC ;


static int is_interleaved(GIF_SPECIFIC* specific)
{
  if ( specific && (specific->descriptor.color_inf & 0x40) ) return 1 ;

  return 0 ;
}

int de_entrelace(INFO_IMAGE* inf)
{
  MFDB*         out = &inf->mfdb ;
  MFDB          new ;
  long          lo_line ;
  int           err = EIMG_SUCCESS ;
  int           l;
  unsigned char *new_natural_format, *src, *dst ;
  unsigned char *pt_e, *pt_de ;

  CopyMFDB( &new, out ) ;
  if ( inf->natural_format )
  {
    new_natural_format = (unsigned char *) Xalloc( (long)out->fd_w*(long)out->fd_h ) ;
    err = ( new_natural_format == NULL ) ;
    if ( err ) Xfree( inf->natural_format ) ;
    lo_line = inf->natural_width ;
    src     = inf->natural_format ;
    dst     = new_natural_format ;
  }
  else
  {
    new.fd_addr = img_alloc( new.fd_w, new.fd_h, new.fd_nplanes ) ;
    err = ( new.fd_addr == NULL ) ;
    if ( err ) Xfree( out->fd_addr ) ;
    lo_line = img_size( out->fd_w, 1, out->fd_nplanes ) ;
    src = out->fd_addr ;
    dst = new.fd_addr ;
  }

  if ( err ) return EIMG_NOMEMORY ;

  /* Passe 1 */
  pt_e  = src ;
  pt_de = dst ;
  for ( l = 0; l < out->fd_h; l += 8 )
  {
    memcpy( pt_de, pt_e, lo_line ) ;
    pt_e  += lo_line ;
    pt_de += 8*lo_line ;
  }

  /* Passe 2 */
  pt_de  = dst ;
  pt_de += 4*lo_line ;
  for ( l = 4; l < out->fd_h; l += 8 )
  {
    memcpy( pt_de, pt_e, lo_line ) ;
    pt_e  += lo_line ;
    pt_de += 8*lo_line ;
  }

  /* Passe 3 */
  pt_de  = dst ;
  pt_de += 2*lo_line ;
  for ( l = 2; l < out->fd_h; l += 4 )
  {
    memcpy( pt_de, pt_e, lo_line ) ;
    pt_e  += lo_line ;
    pt_de += 4*lo_line ;
  }

  /* Passe 4 */
  pt_de  = dst ;
  pt_de += lo_line ;
  for ( l = 1; l < out->fd_h; l += 2 )
  {
    memcpy( pt_de, pt_e, lo_line ) ;
    pt_e  += lo_line ;
    pt_de += 2*lo_line ;
  }

  if ( !inf->natural_format )
  {
    Xfree( out->fd_addr ) ;
    CopyMFDB( out, &new ) ;
  }
  else
  {
    CopyMFDB( out, &new ) ;
    Xfree( inf->natural_format ) ;
    inf->natural_format = new_natural_format ;
  }

  return err ;
}

static int gif_decompress(unsigned char* buffer, long taille, INFO_IMAGE* inf)
{
  GEM_WINDOW*   wprog = (GEM_WINDOW*) inf->prog ;
  MFDB*         out = &inf->mfdb ;
  size_t        nb_pts, nb_tpts ;
  long          total ;
  unsigned int  byte_count ;
  int           cpt = 0 ;
  int           code, ret = EIMG_SUCCESS ;
  char          old_ignore_a16 = ignore_a16 ;
  unsigned char *pt ;
  unsigned char *data, *last_data ;
  unsigned char *pt_natural ;

  pt_natural = inf->natural_format ;
  data = (unsigned char*) Xalloc( DCPRS_SIZE+2048 ) ; /* 2KB more to limit potential overflow consequences */
  if ( data == NULL ) return EIMG_NOMEMORY ;
  /* Buffer pointe un bloc de donn‚es raster ie : */
  /* Buffer ---> Code_size                        */
  /*             Byte count                       */
  /*             Byte Bloc (Byte Count octets)    */
  if ( lzw_init( out->fd_nplanes, 2+buffer, 1 ) != 0 )
  {
    Xfree(data) ;
    return EIMG_NOMEMORY ;
  }

  pt      = buffer ;
  nb_tpts = 0 ;
  ignore_a16 = 1 ; /* Pas d'optimisation sur 16 pixels */
  i2r_init(out, out->fd_w, 1) ;
  i2r_data    = data ;
  StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_DECODAGELZW)  ) ;
  StdProgWText( wprog, 2, inf->filename ) ;
  total = (long)out->fd_w*(long)out->fd_h ;
  last_data = pt + taille - 1 ;
  while ( (pt <= last_data) && (*pt != GIF_TERMINATOR) && (nb_tpts < total) )
  {
    if ( (*pt > 1) && (*pt < 13) ) /* Code Size */
    {
      code_size  = *pt++ ;
      code_size++ ; /* D‚but du codage n plans +2 codes sp‚ciaux */ 
      byte_count = *pt++ ;
      do
      {
        perf_start( PERF_COMPRESS, &inf->perf_info ) ;
        nb_pts = lzw_decompress( pt, byte_count, data, DCPRS_SIZE ) ;
        perf_stop( PERF_COMPRESS, &inf->perf_info ) ;
        if ( nb_pts > DCPRS_SIZE )
        {
          LoggingDo(LL_WARNING, "LZW overflow: buffer is %ld bytes, %ld inflated %s", DCPRS_SIZE, nb_pts, (nb_pts < DCPRS_SIZE+2048) ? "(still safe)":"") ;
          nb_pts = 0 ;
        }

        if ( nb_pts == 0 )
        {
          *pt = GIF_TERMINATOR ;
          ret = EIMG_DECOMPRESERR ;
          break ;
        }

        /* Convertir tableau d'indices au format MFDB */
        nb_tpts   += nb_pts ;
        pt         = pt + byte_count ;
        byte_count = *pt++ ;

        if ( nb_tpts <= total ) i2r_nb = nb_pts ;
        else                    i2r_nb = nb_pts-(int)(nb_tpts-total) ;
        if (inf->img_analyse && (out->fd_nplanes > 1)) pal_ajust() ;

        if ( !inf->natural_format )
        {
          perf_start( PERF_IND2RASTER, &inf->perf_info ) ;
          ind2raster() ;
          perf_stop( PERF_IND2RASTER, &inf->perf_info ) ;
        }
        else
        {
          memcpy( pt_natural, data, i2r_nb ) ;
          pt_natural += i2r_nb ;
        }

        code = GWProgRange( wprog, nb_tpts, total, NULL ) ;
        if ( PROG_CANCEL_CODE( code ) )
        {
          *pt = GIF_TERMINATOR ;
          ret = -8 ;
          break ;
        }
        cpt++ ;
      }
      while ( (pt <= last_data) && (byte_count != 0) && (nb_tpts < total) ) ;
    }
    else
    {
      switch( *pt )
      {
        case ID_DESCRIPTOR : /* Seule la premiere image est chargee */
                             *pt = GIF_TERMINATOR ;
                             inf->multiple_images = 1 ;
                             break ;

        case GIF_EXTENDER  : pt++ ;
                             if ( *pt == GIF_CONTROL_LABEL )
                             { /* Gestion transparence et autres */
                               pt++ ;
                               do
                               {
                                 byte_count = *pt++ ;
                                 pt        += byte_count ;
                               }
                               while ( ( pt <= last_data ) && ( *pt != 0 ) ) ;
                             }
                             else
                             {
                               pt++ ;
                               do
                               {
                                 byte_count = *pt++ ;
                                 pt        += byte_count ;
                               }
                               while ( ( pt <= last_data ) && ( *pt != 0 ) ) ;
                             }
                             pt++ ;
                             break ;

        default :            byte_count = *pt ;
                             pt        += byte_count ;
                             pt++ ;
                             break ;
      }
    }
  }

  ignore_a16 = old_ignore_a16 ;
  (void)lzw_end() ;
  Xfree(data) ;

  if ( is_interleaved( inf->specific ) ) ret = de_entrelace( inf ) ;
  StdProgWText( wprog, 2, "" ) ; /* Avoid display artifact if progress window is not destroyed (e.g. recycled for next load, only GIF uses index#2 */

  return ret ;
}

int pos_on_image_descriptor(INFO_IMAGE* inf, unsigned char* buf)
{
  GIF_SPECIFIC*   specific = inf->specific ;
  GIF_DESCRIPTOR* descriptor = &specific->descriptor ;
  unsigned char   block_id ;
  unsigned char   err = 0, trouve = 0 ;
  int             block_size ;

  /* Le header vient d'etre lu */
  do
  {
    block_id = ImgFGetc( inf ) ;
    switch ( block_id )
    {
      case GIF_EXTENDER  : ImgFGetc( inf ) ;
                           block_size = ImgFGetc( inf ) ;
                           while ( !err && block_size )
                           {
                             err = (ImgFSeek( inf, block_size, SEEK_CUR ) < 0) ;
                             block_size = ImgFGetc( inf ) ;
                           }
                           break ;

      case ID_DESCRIPTOR : trouve = 1 ;
                           break ;

      default            : block_size = ImgFGetc( inf ) ;
                           if ( block_size == EOF ) err = 1 ;
                           else                     err = (ImgFSeek( inf, block_size, SEEK_CUR ) < 0) ;
                           break ;
    }
  }
  while ( !trouve && !err ) ;

  if ( trouve )
  {
    ImgFRead( inf, descriptor, 9 ) ;
    descriptor->deltax = int_reverse( descriptor->deltax ) ;
    descriptor->deltay = int_reverse( descriptor->deltay ) ;
    descriptor->width  = int_reverse( descriptor->width ) ;
    descriptor->height = int_reverse( descriptor->height ) ;
    if ( descriptor->color_inf & 0x80 ) /* Palette locale */
    {
      size_t nb_col ;

      nb_col = 1 << ( 1 + (descriptor->color_inf & 0x07) ) ;
      if ( buf ) ImgFRead( inf, buf, 3*nb_col ) ;
      else       ImgFSeek( inf, 3*nb_col, SEEK_CUR ) ;
    }
  }
  else err = 1 ;

  return err ;
}

int check_planes(int nplanes)
{
  if ( (nplanes != 1) && (nplanes != 4) && (nplanes != 8) ) return 1 ;

  return 0 ;
}

int gif_load(INFO_IMAGE* inf)
{
  GIF_SPECIFIC*  specific = (GIF_SPECIFIC*) inf->specific ;
  MFDB*          out = &inf->mfdb ;
  int            ret ;

  if ( !inf->xfile.valid )
  {
    LoggingDo(LL_ERROR, "gif_load: file descriptor is invalid") ;
    return EIMG_FILENOEXIST ;
  }
  if ( inf->specific == NULL )
  {
    LoggingDo(LL_ERROR, "gif_load: no GIF specific data") ;
    return EIMG_DATAINCONSISTENT ;
  }

  out->fd_w       = specific->descriptor.width ;
  out->fd_h       = specific->descriptor.height ;
  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
  out->fd_stand   = 0 ;
  out->fd_nplanes = 1 + ( specific->header.color_inf & 0x07 ) ;

  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr )
  {
    unsigned char* data = (unsigned char*) Xalloc( inf->file_size ) ;

    if ( data )
    {
      perf_start( PERF_DISK, &inf->perf_info ) ;
      ImgFRead( inf, data, inf->file_size ) ;
      ImgFClose( inf ) ;
      perf_stop( PERF_DISK, &inf->perf_info ) ;
      img_raz( out ) ;
      if ( may_use_natural_format( inf->final_nb_planes, out->fd_nplanes ) )
      {
        inf->natural_format = Xalloc( (long)out->fd_w*(long)out->fd_h ) ;
        inf->natural_width  = (int) specific->descriptor.width ;
      }
      ret = gif_decompress( data, inf->file_size, inf ) ;
      out->fd_w = align16( out->fd_w ) ;
      Xfree( data ) ;
    }
    else ret = EIMG_NOMEMORY ;
  }
  else ret = EIMG_NOMEMORY ;

  img_post_loading( ret, inf ) ;

  return ret ;
}

int gif_identify(char* name, INFO_IMAGE* inf)
{
  GIF_SPECIFIC* specific ;
  unsigned char buf[768] ;
  int           ret ;

  ret = ImgFOpen( inf, name, &inf->file_size ) ;
  if ( ret != EIMG_SUCCESS ) return ret ;

  inf->specific = Xcalloc( 1, sizeof(GIF_SPECIFIC) ) ;
  specific = (GIF_SPECIFIC*) inf->specific ;
  if ( specific == NULL )
  {
    free_info( inf ) ;
    return EIMG_NOMEMORY ;
  }

  ImgFRead( inf, &specific->header, 13 ) ; 
  if ( memcmp( &specific->header.signature, "GIF", 3 ) != 0 )
  {
    free_info( inf ) ;
    LoggingDo(LL_INFO, "gif_identify: GIF signature not valid") ;
    return EIMG_DATAINCONSISTENT ;
  }

  if ( check_planes( 1 + (specific->header.color_inf & 0x07) ) )
  {
    free_info( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }

  specific->header.width  = int_reverse( specific->header.width ) ;
  specific->header.height = int_reverse( specific->header.height ) ;

  inf->compress = 1 ;
  inf->lpix     = 0x152 ;
  inf->hpix     = 0x152 ;
  inf->palette  = NULL ;
  inf->nb_cpal  = 0 ;
  if ( specific->header.color_inf & 0x80 )
  {
    inf->nb_cpal = 1 << (1+(specific->header.color_inf & 0x07)) ;
    ImgFRead( inf, buf, 3*inf->nb_cpal ) ;
  }

  if ( pos_on_image_descriptor( inf, buf ) != 0 )
  {
    free_info( inf ) ;
    return EIMG_DATAINCONSISTENT ;
  }

  inf->width   = specific->descriptor.width ;
  inf->height  = specific->descriptor.height ;
  inf->nplanes = 1 + (specific->descriptor.color_inf & 0x07)  ;
  if ( check_planes( inf->nplanes ) != 0 )
  {
    free_info( inf ) ;
    return EIMG_DATAINCONSISTENT ;
  }

  if ( specific->descriptor.color_inf & 0x80 )
    inf->nb_cpal = 1 << inf->nplanes ; /* buf has been filled by pos_on_image_descriptor */

  if ( inf->nb_cpal )
  {
    unsigned char* pt_buf = buf ;
    long           tcol ;
    int*           pt ;
    int            i ;

    tcol = nb_colors ;
    if ( inf->nb_cpal > tcol ) tcol = inf->nb_cpal ;
    inf->palette = Xalloc( 6*tcol ) ;
    if ( inf->palette == NULL )
    {
      free_info( inf ) ;
      return EIMG_NOMEMORY ;
    }

    pt  = (int*) inf->palette ;
    for (i = 0; i < inf->nb_cpal; i++)
    {
      *pt++ = RGB8BToRGBPM[ *pt_buf++ ] ;
      *pt++ = RGB8BToRGBPM[ *pt_buf++ ] ;
      *pt++ = RGB8BToRGBPM[ *pt_buf++ ] ;
    }
  }

  LoggingDo(LL_DEBUG, "gif_identify: %dx%dx%d, %ld colors for palette",  inf->width, inf->height, inf->nplanes, inf->nb_cpal) ;

  return EIMG_SUCCESS ;
}

int gif_compress(MFDB *img, FILE *stream, GEM_WINDOW* wprog)
{
  long          dummy, tmligne ;
  int           *pt_raster ;
  int           i, ret = EIMG_SUCCESS ;
  unsigned char *buffer ;
  unsigned char ucar ;

  buffer = (unsigned char *) Xalloc(img->fd_w) ;
  if (buffer == NULL) return EIMG_NOMEMORY ;
  StdProgWText( wprog, 1, MsgTxtGetMsg(hMsg, MSG_ENCODAGELZW)  ) ;
  ucar = (unsigned char) img->fd_nplanes ;
  if (ucar == 1) ucar = 2 ;
  fwrite(&ucar, 1, 1, stream) ;
  tmligne   = img->fd_wdwidth*img->fd_nplanes ;
  code_size = 1+img->fd_nplanes ;
  if (code_size == 2) code_size = 3 ;
  if (lzw_init(code_size-1, NULL, 1) != 0)
  {
    Xfree(buffer) ;
    return EIMG_NOMEMORY ;
  }
  pt_raster = (int *) img->fd_addr ;
  for (i = 0; (ret == EIMG_SUCCESS) && (i < img->fd_h); i++)
  {
    (void)GWProgRange( wprog, 1+i, img->fd_h, NULL ) ;

    raster2ind(pt_raster, buffer, img->fd_w, img->fd_nplanes) ;
    switch( lzw_compress(buffer, img->fd_w, stream, &dummy) )
    {
      case -3 : ret = EIMG_NOMEMORY ;
                break ;
      case -2 : ret = EIMG_DATAINCONSISTENT ;
                break ;
      case -1 : ret = EIMG_FILENOEXIST ;
                break ;
    }
    pt_raster += tmligne ;
  }
  
  (void)lzw_end() ;
  Xfree(buffer) ;
  ucar = 0 ;
  fwrite(&ucar, 1, 1, stream) ;

  return ret ;
}

int gif_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog)
{
  GIF_DESCRIPTOR descriptor ;
  GIF_HEADER     header ;
  FILE           *stream ;
  int            pal[256*6] ;
  int            *pt ;
  int            i, ind ;
  int            ret ;
  int            nbits ;
  unsigned char  rvb[3] ;

  if (img->fd_nplanes > 8) return EIMG_OPTIONNOTSUPPORTED ;

  stream = CreateFileR( name ) ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  memcpy(header.signature, "GIF87a", 6) ;
  header.width      = int_reverse( img->fd_w ) ;
  header.height     = int_reverse( img->fd_h ) ;
  nbits             = (unsigned char)img->fd_nplanes-1 ;
  header.color_inf  = 128 + nbits ;
  header.background = 0 ;
  header.map        = 0 ;
  fwrite(&header, 13, 1, stream) ;
  if (info->palette != NULL)
  {
    pt  = (int *) info->palette ;
    ind = 0 ;
    for (i = 0; i < info->nb_cpal; i++)
    {
      rvb[0] = RGBPMToRGB8B[ pt[ind++] ] ;
      rvb[1] = RGBPMToRGB8B[ pt[ind++] ] ;
      rvb[2] = RGBPMToRGB8B[ pt[ind++] ] ;
      fwrite(rvb, 3, 1, stream) ;
    }
  }
  else
  {
    get_tospalette(pal) ;
    info->nb_cpal = 1 << img->fd_nplanes ;
    pt  = pal ;
    ind = 0 ;
    for (i = 0; i < info->nb_cpal; i++)
    {
      rvb[0] = RGBPMToRGB8B[ pt[ind++] ] ;
      rvb[1] = RGBPMToRGB8B[ pt[ind++] ] ;
      rvb[2] = RGBPMToRGB8B[ pt[ind++] ] ;
      fwrite(rvb, 3, 1, stream) ;
    }
  }
  *rvb = ID_DESCRIPTOR ;
  fwrite(rvb, 1, 1, stream) ;
  descriptor.deltax    = 0 ;
  descriptor.deltay    = 0 ;
  descriptor.width     = header.width ;
  descriptor.height    = header.height ;
  descriptor.color_inf = (unsigned char) (img->fd_nplanes-1) ;
  fwrite(&descriptor, 9, 1, stream) ;

  ret    = gif_compress( img, stream, wprog ) ;
  rvb[0] = GIF_TERMINATOR ;
  fwrite( rvb, 1, 1, stream ) ;
  fclose(stream) ;

  return ret ;
}

void gif_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "GIF\0\0" ;

  caps->iid = IID_GIF ;
  strcpy( caps->short_name, "GIF" ) ;
  strcpy( caps->file_extension, "GIF" ) ;
  strcpy( caps->name, "Graphic Interchange Format 89a" ) ;
  caps->version = 0x0408 ;

  caps->import = IEF_P1 | IEF_P4 | IEF_P8 | IEF_LZW ;
  caps->export = IEF_P1 | IEF_P4 | IEF_P8 | IEF_LZW ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
