/*********************************/
/* Gestion du format DEGAS ELITE */
/*********************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\packbits.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\logging.h"


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


int degas_load(INFO_IMAGE* inf)
{
  DEGAS_HEADER header ;
  FILE*        stream ;
  MFDB*        out = &inf->mfdb ;

  perf_start( PERF_DISK, &inf->perf_info ) ;
  stream = fopen( inf->filename, "rb" ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  fread( &header, sizeof(DEGAS_HEADER), 1, stream ) ;
  out->fd_stand = 0 ;
  switch( header.resolution & 0x7FFF )
  {
    case 0  : out->fd_w       = 320 ; 
              out->fd_h       = 200 ;
              out->fd_nplanes = 4 ;
              break ;
    case 1  : out->fd_w       = 640 ; 
              out->fd_h       = 200 ;
              out->fd_nplanes = 2 ;
              break ;
    case 2  : out->fd_w       = 640 ; 
              out->fd_h       = 400 ;
              out->fd_nplanes = 1 ;
              break ;
    default : fclose( stream ) ;
              return EIMG_DATAINCONSISTENT ;
  }

  out->fd_wdwidth = out->fd_w>>4 ;
  out->fd_addr    = Xalloc( 32000 ) ;
  if ( out->fd_addr == NULL )
  {
    fclose( stream ) ;
    return EIMG_NOMEMORY ;
  }

  fseek(stream, 2+2*16, SEEK_SET) ;
  if ( header.resolution >= 0 )
  {
    fread( out->fd_addr, 32000, 1, stream ) ;
    perf_stop( PERF_DISK, &inf->perf_info ) ;
  }
  else
  {
    PACKBITS_STR pb_str ;
    size_t       taille ;

    taille            = file_size(inf->filename)-sizeof(DEGAS_HEADER) ;
    pb_str.pbadr_in   = Xalloc( taille ) ;
    pb_str.pbadr_out  = out->fd_addr ;
    pb_str.pbnb_pixel = out->fd_w ;
    pb_str.pbnb_ligne = out->fd_h ;
    pb_str.pbnb_plan  = out->fd_nplanes ;
    if ( pb_str.pbadr_in == NULL )
    {
      fclose( stream ) ;
      Xfree( out->fd_addr ) ;
      return EIMG_NOMEMORY ;
    }
    fread( pb_str.pbadr_in, taille, 1, stream ) ;
    perf_stop( PERF_DISK, &inf->perf_info ) ;
    perf_start( PERF_COMPRESS, &inf->perf_info ) ;
    packbits_dcmps( &pb_str ) ;
    perf_stop( PERF_COMPRESS, &inf->perf_info ) ;
    Xfree( pb_str.pbadr_in ) ;
  }
  fclose( stream ) ;

  return EIMG_SUCCESS ;
}

int degas_identify(char* nom, INFO_IMAGE* inf)
{
  DEGAS_HEADER degas_inf ;
  FILE*        stream ;
  size_t       filesize ;
  long         tcol ;
  int          i, *pt ;

  stream = fopen(nom, "rb") ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  fread( &degas_inf, sizeof(DEGAS_HEADER), 1, stream ) ;
  fclose( stream ) ;

  inf->compress = (degas_inf.resolution < 0) ;
  filesize      = file_size( nom ) ;
  if ( !inf->compress && (filesize != (32000UL+sizeof(DEGAS_HEADER))) )
  {
    /* Overscan picture, we don't handle */
    LoggingDo(LL_INFO, "Degas non compressed, expected file size=%lu, file size=%lu", filesize, 32000UL+sizeof(DEGAS_HEADER)) ;
    return EIMG_UNKOWNFORMAT ;
  }

  switch( degas_inf.resolution & 0x7FFF )
  {
    case 0 : inf->width   = 320 ;
             inf->height  = 200 ;
             inf->nplanes = 4 ;
             inf->nb_cpal = 16 ;
             break ;
    case 1 : inf->width   = 640 ;
             inf->height  = 200 ;
             inf->nplanes = 2 ;
             inf->nb_cpal = 4 ;
             break ;
    case 2 : inf->width   = 640 ;
             inf->height  = 400 ;
             inf->nplanes = 1 ;
             inf->nb_cpal = 2 ;
             break ;
    default: return EIMG_UNKOWNFORMAT ;
  }
  inf->lpix = 72 ; /* On ne sait pas */
  inf->hpix = 72 ;

  tcol = nb_colors ;
  if (inf->nb_cpal > tcol) tcol = inf->nb_cpal ;
  inf->palette = Xcalloc( tcol, 6 ) ;
  if ( inf->palette == NULL ) return EIMG_NOMEMORY ;

  pt  = (int*) inf->palette ;
  if ( inf->nb_cpal == 2 )
  {
    if ( degas_inf.palette[0] & 0x0001 )
    {
      pt[0] = pt[1] = pt[2] = 1000 ;
      pt[3] = pt[4] = pt[5] = 0 ;
    }
    else
    {
      pt[0] = pt[1] = pt[2] = 0 ;
      pt[3] = pt[4] = pt[5] = 1000 ;
    }
  }
  else
  {
    for ( i = 0; i < inf->nb_cpal; i++ )
    {
      *pt++ = rgb3b2rgbm( degas_inf.palette[i] >> 8 ) ; /* Red   */
      *pt++ = rgb3b2rgbm( degas_inf.palette[i] >> 4 ) ; /* Green */
      *pt++ = rgb3b2rgbm( degas_inf.palette[i] ) ;      /* Blue  */
    }
  }

  return EIMG_SUCCESS ;
}

#pragma warn -par
int degas_sauve(char* name, MFDB* img, INFO_IMAGE* inf, GEM_WINDOW* wprog)
{
  DEGAS_HEADER header ;
  FILE*        stream ;
  int          i ;
  int*         pt ;

  if ( (img->fd_w == 320) && (img->fd_h == 200) && (img->fd_nplanes == 4) ) header.resolution = 0 ;
  else if ( (img->fd_w == 640) && (img->fd_h == 200) && (img->fd_nplanes == 2) ) header.resolution = 1 ;
  else if ( (img->fd_w == 640) && (img->fd_h == 400) && (img->fd_nplanes == 1) ) header.resolution = 2 ;
  else return EIMG_DATAINCONSISTENT ;

  memzero( &header.palette, 16*2 ) ;
  if ( inf->palette )
  {
    pt = (int*) inf->palette ;
    for ( i = 0; i < inf->nb_cpal; i++ )
    {
      header.palette[i]  = rgbm2rgb3b( *pt++ ) << 8 ;
      header.palette[i] += rgbm2rgb3b( *pt++ ) << 4 ;
      header.palette[i] += rgbm2rgb3b( *pt++ ) ;
    }
  }

  stream = CreateFileR( name ) ;
  if ( stream == NULL ) return EIMG_FILENOEXIST ;

  fwrite( &header, sizeof(DEGAS_HEADER), 1, stream ) ;
  fwrite( img->fd_addr, 32000, 1, stream ) ;

  if ( fclose( stream ) ) return EIMG_DATAINCONSISTENT ;

  inf->compress = 0 ;

  return EIMG_SUCCESS ;
}
#pragma warn +par

void degas_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "PI1\0PI2\0PI3\0PC1\0PC2\0PC3\0\0" ;

  caps->iid = IID_DEGAS ;
  strcpy( caps->short_name, "Degas" ) ;
  strcpy( caps->file_extension, "PI1" ) ;
  strcpy( caps->name, "Degas Elite" ) ;
  caps->version = 0x0407 ;

  caps->import = IEF_P1 | IEF_P2 | IEF_P4 | IEF_NOCOMP | IEF_PBIT ;
  caps->export = IEF_P1 | IEF_P2 | IEF_P4 | IEF_NOCOMP ;

  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
