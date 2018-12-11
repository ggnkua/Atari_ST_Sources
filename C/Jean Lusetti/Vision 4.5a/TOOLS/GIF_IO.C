/***********************************************/
/* Gestion du Graphic Interchange Format (GIF) */
/***********************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include               "defs.h"
#include       "..\tools\lzw.h"
#include  "..\tools\rasterop.h"
#include  "..\tools\msgtxt.h"

#define ID_DESCRIPTOR      ','
#define GIF_TERMINATOR     ';'
#define GIF_EXTENDER      0x21
#define GIF_CONTROL_LABEL 0xF9

#define DCPRS_SIZE    64000L

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

unsigned char Interleaved ;


int de_entrelace(MFDB *out)
{
  MFDB          new ;
  long          lo_line ;
  int           err = EIMG_SUCCESS ;
  int           l;
  unsigned char *new_natural_format, *src, *dst ;
  unsigned char *pt_e, *pt_de ;

  memcpy( &new, out, sizeof(MFDB) ) ;
  if ( NaturalFormat )
  {
    new_natural_format = (unsigned char *) Xalloc( (long)out->fd_w*(long)out->fd_h ) ;
    err = ( new_natural_format == NULL ) ;
    if ( err ) Xfree( NaturalFormat ) ;
    lo_line = NaturalWidth ;
    src     = NaturalFormat ;
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

  if ( !NaturalFormat )
  {
    Xfree( out->fd_addr ) ;
    memcpy( out, &new, sizeof(MFDB) ) ;
  }
  else
  {
    memcpy( out, &new, sizeof(MFDB) ) ;
    Xfree( NaturalFormat ) ;
    NaturalFormat = new_natural_format ;
  }

  return err ;
}

int gif_decompress(unsigned char *buffer, long taille, MFDB *out, char *name, GEM_WINDOW *wprog)
{
  int           pc ;
  size_t        nb_pts, nb_tpts ;
  long          dummy ;
  long          total ;
  unsigned int  byte_count ;
  int           cpt = 0 ;
  int           code, ret = EIMG_SUCCESS ;
  int           old_ignore_a16 = ignore_a16 ;
  unsigned char *pt ;
  unsigned char *data, *last_data ;
  unsigned char *pt_natural ;

  pt_natural = NaturalFormat ;
  data = (unsigned char *) Xalloc(DCPRS_SIZE) ;
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
  StdProgWText( wprog, 2, name ) ;
  total = (long)out->fd_w*(long)out->fd_h ;
  last_data = pt + taille - 1 ;
  while ( ( pt <= last_data ) && ( *pt != GIF_TERMINATOR ) && ( nb_tpts < total ) )
  {
    if ( ( *pt > 1 ) && ( *pt < 13 ) ) /* Code Size */
    {
      code_size  = *pt++ ;
      code_size++ ; /* D‚but du codage n plans +2 codes sp‚ciaux */ 
      byte_count = *pt++ ;
      do
      {
        perf_start( PERF_COMPRESS, &PerfInfo ) ;
        nb_pts = lzw_decompress( pt, data, byte_count ) ;
        perf_stop( PERF_COMPRESS, &PerfInfo ) ;

        if ( nb_pts == 0 )
        {
          *pt = GIF_TERMINATOR ;
          ret = -4 ;
          break ;
        }

        /* Convertir tableau d'indices au format MFDB */
        nb_tpts   += nb_pts ;
        pt         = pt + byte_count ;
        byte_count = *pt++ ;

        if ( nb_tpts <= total ) i2r_nb = nb_pts ;
        else                    i2r_nb = nb_pts-(int)(nb_tpts-total) ;
        if (img_analyse && (out->fd_nplanes > 1)) pal_ajust() ;

        if ( !NaturalFormat )
        {
          perf_start( PERF_IND2RASTER, &PerfInfo ) ;
          ind2raster() ;
          perf_stop( PERF_IND2RASTER, &PerfInfo ) ;
        }
        else
        {
          memcpy( pt_natural, data, i2r_nb ) ;
          pt_natural += i2r_nb ;
        }

        if ( MAY_UPDATE( wprog, cpt ) )
        {
          pc = (int) ((100L*nb_tpts)/total) ;
          code = wprog->ProgPc( wprog, pc, NULL ) ;
          if ( STOP_CODE( code ) )
          {
            *pt = GIF_TERMINATOR ;
            ret = -8 ;
            break ;
          }
        }
        cpt++ ;
      }
      while ( ( pt <= last_data ) && ( byte_count != 0 ) && ( nb_tpts < total ) ) ;
    }
    else
    {
      switch( *pt )
      {
        case ID_DESCRIPTOR : /* Seule la premiere image est chargee */
                             *pt = GIF_TERMINATOR ;
                             MultipleImages = 1 ;
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
  lzw_end(&dummy) ;
  Xfree(data) ;

  if ( Interleaved ) ret = de_entrelace( out ) ;

  return ret ;
}

int pos_on_image_descriptor(FILE *stream, GIF_DESCRIPTOR *descriptor, unsigned char *buf )
{
  union
  {
    struct
    {
      unsigned char lsb ;
      unsigned char msb ;
    }
    i ;
    unsigned int int_nb ;
  }
  mot_int ;
  unsigned char block_id ;
  unsigned char err = 0, trouve = 0 ;
  int           block_size ;

  /* Le header vient d'etre lu */
  do
  {
    block_id = fgetc( stream ) ;
    switch ( block_id )
    {
      case GIF_EXTENDER  : fgetc( stream ) ;
                           block_size = fgetc( stream ) ;
                           while ( !err && block_size )
                           {
                             err = fseek( stream, block_size, SEEK_CUR ) ;
                             block_size = fgetc( stream ) ;
                           }
                           break ;

      case ID_DESCRIPTOR : trouve = 1 ;
                           break ;

      default            : block_size = fgetc( stream ) ;
                           err = fseek( stream, block_size, SEEK_CUR ) ;
                           break ;
    }
  }
  while ( !trouve && !err ) ;

  if ( trouve )
  {
    fread( descriptor, 9, 1, stream ) ;
    memcpy( &mot_int, &descriptor->deltax, 2 ) ;
    descriptor->deltax = mot_int.i.lsb+256*mot_int.i.msb ;
    memcpy( &mot_int, &descriptor->deltay, 2 ) ;
    descriptor->deltay = mot_int.i.lsb+256*mot_int.i.msb ;
    memcpy( &mot_int, &descriptor->width, 2 ) ;
    descriptor->width = mot_int.i.lsb+256*mot_int.i.msb ;
    memcpy( &mot_int, &descriptor->height, 2 ) ;
    descriptor->height = mot_int.i.lsb+256*mot_int.i.msb ;
    if ( descriptor->color_inf & 0x80 ) /* Palette locale */
    {
      size_t nb_col ;

      nb_col = 1 << ( 1 + (descriptor->color_inf & 0x07) ) ;
      if ( buf ) fread( buf, 3, nb_col, stream ) ;
      else       fseek( stream, 3*nb_col, SEEK_CUR ) ;
    }
  }
  else err = 1 ;

  return err ;
}

int gif_load(char *name, MFDB *out, GEM_WINDOW *wprog)
{
  union
  {
    struct
    {
      unsigned char lsb ;
      unsigned char msb ;
    }
    i ;
    unsigned int int_nb ;
  }
  mot_int ;
  GIF_DESCRIPTOR descriptor ;
  GIF_HEADER     entete ;
  FILE           *stream ;
  long           taille ;
  int            ret ;
  unsigned char  *data ;
  
  perf_start( PERF_DISK, &PerfInfo ) ;
  taille = file_size( name ) ;
  if ( taille < 0 ) return EIMG_FILENOEXIST ;
  stream = fopen(name, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;
  
  fread(&entete, 13, 1, stream) ;
  
  if (memcmp(&entete.signature, "GIF", 3) != 0)
  {
    fclose(stream) ;
    return EIMG_DATAINCONSISTENT ;
  }

  memcpy(&mot_int, &entete.width, 2) ;
  entete.width = mot_int.i.lsb+256*mot_int.i.msb ;
  memcpy(&mot_int, &entete.height, 2) ;
  entete.height = mot_int.i.lsb+256*mot_int.i.msb ;

  if ( entete.color_inf & 0x80 )
  {
    int nb_oct ;

    nb_oct = 3*(1 << (1 + (entete.color_inf & 0x07) ) ) ;
    fseek(stream, nb_oct, SEEK_CUR) ;
  }

  if ( pos_on_image_descriptor( stream, &descriptor, NULL ) != 0 )
  {
    fclose( stream ) ;
    return EIMG_DATAINCONSISTENT ;
  }

  out->fd_w = descriptor.width ;
  out->fd_h = descriptor.height ;
  out->fd_wdwidth = out->fd_w/16 ;
  if (out->fd_w % 16) out->fd_wdwidth++ ;
  out->fd_stand = 0 ;
  out->fd_nplanes = 1 + ( entete.color_inf & 0x07 ) ;

  out->fd_addr = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL)
  {
    fclose(stream) ;
    return EIMG_NOMEMORY ;
  }

  data   = (unsigned char *) Xalloc(taille) ;
  if (data == NULL)
  {
    Xfree(out->fd_addr) ;
    fclose(stream) ;
    return EIMG_NOMEMORY ;
  }
  fread(data, 1, taille, stream) ;
  fclose(stream) ;
  perf_stop( PERF_DISK, &PerfInfo ) ;

  /* Remise … z‚ro de l'image */
  img_raz(out) ;

  if ( may_use_natural_format( FinalNbPlanes, out->fd_nplanes ) )
  {
    NaturalFormat = Xalloc( (long)out->fd_w*(long)out->fd_h ) ;
    NaturalWidth  = (int) descriptor.width ;
  }

  ret = gif_decompress( data, taille, out, name, wprog ) ;

  Xfree(data) ;
  if (out->fd_w % 16) out->fd_w = (out->fd_w & 0xFFF0)+16 ;

  return ret ;
}

int gif_identify(char *name, INFO_IMAGE *inf)
{
  union
  {
    struct
    {
      unsigned char lsb ;
      unsigned char msb ;
    }
    i ;
    unsigned int int_nb ;
  }
  mot_int ;
  GIF_DESCRIPTOR descriptor ;
  GIF_HEADER     entete ;
  FILE           *stream ;
  unsigned char  buf[768] ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;
  
  fread(&entete, 13, 1, stream) ;
  
  if (memcmp(&entete.signature, "GIF", 3) != 0)
  {
    fclose(stream) ;
    return EIMG_DATAINCONSISTENT ;
  }

  memcpy(&mot_int, &entete.width, 2) ;
  entete.width = mot_int.i.lsb+256*mot_int.i.msb ;
  memcpy(&mot_int, &entete.height, 2) ;
  entete.height = mot_int.i.lsb+256*mot_int.i.msb ;

  memcpy(&inf->version, &entete.signature[3], 3) ;
  inf->compress = 1 ;               /* Sans signification ici */
  inf->lpix     = 0x152 ;
  inf->hpix     = 0x152 ;
  inf->palette  = NULL ;
  inf->nb_cpal  = 0 ;
  if ( entete.color_inf & 0x80 )
  {
    size_t nb_oct ;

    inf->nb_cpal = 1 << (1+(entete.color_inf & 0x07)) ;
    nb_oct       = 3*inf->nb_cpal ;
    fread(buf, nb_oct, 1, stream) ;
  }

  if ( pos_on_image_descriptor( stream, &descriptor, buf ) != 0 )
  {
    fclose(stream) ;
    return EIMG_DATAINCONSISTENT ;
  }

  Interleaved = ( descriptor.color_inf & 0x40 ) ;

  inf->largeur = descriptor.width ;
  inf->hauteur = descriptor.height ;
  if ( descriptor.color_inf & 0x80 )
    inf->nb_cpal = 1 << ( 1 + (descriptor.color_inf & 0x07) ) ;
  inf->nplans  = 1 + ( entete.color_inf & 0x07 ) ;

  if ( inf->nb_cpal != 0 )
  {
    long tcol ;
    int  *pt ;
    int  i, ind ;

    tcol = nb_colors ;
    if (inf->nb_cpal > tcol) tcol = inf->nb_cpal ;
    inf->palette = Xalloc(6*tcol) ;
    if (inf->palette == NULL)
    {
      fclose(stream) ;
      return EIMG_NOMEMORY ;
    }

    pt  = (int *) inf->palette ;
    ind = 0 ;
    for (i = 0; i < inf->nb_cpal; i++)
    {
      pt[ind] = RGB8BToRGBPM[ buf[ind] ] ;
      ind++ ;
      pt[ind] = RGB8BToRGBPM[ buf[ind] ] ;
      ind++ ;
      pt[ind] = RGB8BToRGBPM[ buf[ind] ] ;
      ind++ ;
    }
  }

  fclose(stream) ;
  return EIMG_SUCCESS ;
}

int gif_compress(MFDB *img, FILE *stream, GEM_WINDOW *wprog)
{
  long          dummy ;
  long          tmligne ;
  int           *pt_raster ;
  int           i ;
  int           pc ;
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
  for (i = 0; i < img->fd_h; i++)
  {
    if ( MAY_UPDATE( wprog, i ) )
    {
      pc = (int) (100L*(long)(i+1)/(long)img->fd_h) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }

    raster2ind(pt_raster, buffer, img->fd_w, img->fd_nplanes) ;
    switch(lzw_compress(buffer, img->fd_w, stream, &dummy))
    {
      case -3 : lzw_end(&dummy) ;
                Xfree(buffer) ;
                return EIMG_NOMEMORY ;
      case -2 : lzw_end(&dummy) ;
                Xfree(buffer) ;
                return EIMG_DATAINCONSISTENT ;
      case -1 : lzw_end(&dummy) ;
                Xfree(buffer) ;
                return EIMG_FILENOEXIST ;
    }
    pt_raster += tmligne ;
  }
  
  lzw_end(&dummy) ;
  Xfree(buffer) ;
  ucar = 0 ;
  fwrite(&ucar, 1, 1, stream) ;

  return EIMG_SUCCESS ;
}

int gif_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  union
  {
    struct
    {
      unsigned char lsb ;
      unsigned char msb ;
    }
    i ;
    unsigned int int_nb ;
  }
  mot_int ;
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

  stream = fopen(name, "wb") ;
  if (stream == NULL) return EIMG_FILENOEXIST ;

  memcpy(header.signature, "GIF87a", 6) ;
  memcpy(&mot_int, &img->fd_w, 2) ;
  header.width = mot_int.i.lsb+256*mot_int.i.msb ;
  memcpy(&mot_int, &img->fd_h, 2) ;
  header.height = mot_int.i.lsb+256*mot_int.i.msb ;
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

  ret = gif_compress( img, stream, wprog ) ;
  if (ret != 0)
  {
    fclose(stream) ;
    return ret ;
  }

  rvb[0] = GIF_TERMINATOR ;
  fwrite( rvb, 1, 1, stream ) ;
  if ( fclose(stream) ) return( -1 ) ;

  return EIMG_SUCCESS ;
}

void gif_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "GIF\0\0" ;

  caps->iid = IID_GIF ;
  strcpy( caps->short_name, "GIF" ) ;
  strcpy( caps->file_extension, "GIF" ) ;
  strcpy( caps->name, "Graphic Interchange Format 89a" ) ;
  caps->version = 0x0401 ;

  caps->import = IEF_P1 | IEF_P4 | IEF_P8 |IEF_LZW ;
  caps->export = IEF_P1 | IEF_P4 | IEF_P8 |IEF_LZW ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}