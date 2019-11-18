/*******************************************************************************/
/* PNG Format Handling (CPU) using pnglib as shared lib                        */
/* Some usefull resources:                                                     */
/* https://github.com/LuaDist/libpng/blob/master/example.c                     */
/* http://zarb.org/~gc/html/libpng.html                                        */
/* https://gist.github.com/niw/5963798                                         */
/* http://corona.sourceforge.net/corona-1.0.2-doxygen/OpenPNG_8cpp-source.html */
/*******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include         "..\tools\xgem.h"
#include       "..\tools\xalloc.h"
#include      "..\tools\logging.h"
#include     "..\tools\rasterop.h"
#include     "..\tools\image_io.h"
#include     "..\tools\chkstack.h"

#include     "..\tools\png\slb\png.h"

static char        libpngOpen = 0 ;
static FILE*       png_stream ;
static png_structp png_str ;
static png_infop   png_inf ;
static jmp_buf     png_jmp_buf ; /* We have our own jmp_buf stuff */
static png_bytep   png_row32 = NULL ; /* If MFDB we load to is not 32bit pixels, we have to allocate one line of 32bit pixels    */
                                      /* We need it global as PureC would optimize it inspite of being used in a setjmp routine  */

static int open_slb_pnglib(void)
{
  long ret ;
  int  err = EIMG_SUCCESS ;

  if ( libpngOpen == 2 ) return EIMG_NOPNGSLB ;

  LoggingDo(LL_INFO, "Opening shared pnglib...") ;
  ret = slb_pnglib_open( NULL ) ;
  if ( ret >= 0 ) libpngOpen = 1 ;
  else
  {
    err       = EIMG_NOPNGSLB ;
    libpngOpen = 2 ;
    LoggingDo(LL_WARNING, "PNG Shared library not found, err=%ld", ret) ;
  }

  return err ;
}

static void png2inf(png_structp png_str, png_infop png_inf, INFO_IMAGE* inf)
{
  inf->c.f.png.bit_depth  = png_get_bit_depth( png_str, png_inf ) ;
  inf->width              = (short) png_get_image_width( png_str, png_inf ) ;
  inf->height             = (short) png_get_image_height( png_str, png_inf ) ;
  inf->compress           = png_get_compression_type( png_str, png_inf ) ;
  inf->c.f.png.channels   = png_get_channels( png_str, png_inf ) ;
  inf->nplanes            = inf->c.f.png.bit_depth * inf->c.f.png.channels ;
  inf->c.f.png.num_passes = (short) png_set_interlace_handling( png_str ) ;
  inf->c.f.png.type       = png_get_color_type( png_str, png_inf ) ;
  inf->palette    = NULL ;
  inf->nb_cpal    = 0 ;
  inf->lpix       = 0x150 ;
  inf->hpix       = 0x150 ;
  LoggingDo(LL_DEBUG, "PNG type=%d", inf->c.f.png.type) ;
  LoggingDo(LL_DEBUG, "PNG compression=%d", inf->compress) ;
  LoggingDo(LL_DEBUG, "PNG width=%d", inf->width) ;
  LoggingDo(LL_DEBUG, "PNG height=%d", inf->height) ;
  LoggingDo(LL_DEBUG, "PNG planes=%d", inf->c.f.png.bit_depth) ;
  LoggingDo(LL_DEBUG, "PNG channels=%d", inf->c.f.png.channels) ;
  LoggingDo(LL_DEBUG, "PNG npasses=%d", inf->c.f.png.num_passes) ;
  LoggingDo(LL_DEBUG, "INF nplans=%d", inf->nplanes) ;
}

/* Let LIBPNG call our memory allocation routines */
#pragma warn -par
static png_voidp PNGCBAPI ipng_malloc(png_structp png_ptr, png_alloc_size_t size)
{
  return (png_voidp) Xalloc( size ) ;
}

void PNGCBAPI ipng_free(png_structp png_ptr, png_voidp ptr)
{
  Xfree( ptr ) ;
}

static void PNGCBAPI png_error_handler(png_structp png_ptr, png_const_charp msg)
{
  LoggingDo(LL_ERROR, "pnglib: %s", msg) ;
  longjmp( png_jmp_buf, 1 ) ;
}
#pragma warn +par

int cpu_png_identify(char* name, INFO_IMAGE* inf)
{
#define NB_BYTES_HEADER 8
  unsigned char header[NB_BYTES_HEADER] ;
  int           err = EIMG_SUCCESS ;

  if ( libpngOpen != 1 ) err = open_slb_pnglib() ;
  if ( err != EIMG_SUCCESS )
  {
    if ( png_stream ) fclose( png_stream ) ; png_stream = NULL ;
    return err ;
  }

  if ( png_stream ) fclose( png_stream ) ;
  png_stream = fopen( name, "rb" ) ;
  if ( png_stream == NULL ) return EIMG_FILENOEXIST ;

  fread( header, 1, NB_BYTES_HEADER, png_stream ) ;
  if ( png_sig_cmp( header, 0, NB_BYTES_HEADER ) )
  {
    LoggingDo(LL_ERROR, "Failed to identify PNG format") ;
    fclose( png_stream ) ; png_stream = NULL ;
    return EIMG_DATAINCONSISTENT ;
  }

  png_str = png_create_read_struct_2( PNG_LIBPNG_VER_STRING, NULL, png_error_handler, (png_error_ptr)NULL, NULL, ipng_malloc, ipng_free ) ;
  if ( !png_str )
  {
    fclose( png_stream ) ; png_stream = NULL ;
    LoggingDo(LL_ERROR, "Failed to create PNG read struct") ;
    return EIMG_NOMEMORY ;
  }

  png_inf = png_create_info_struct( png_str );
  if ( !png_inf )
  {
    fclose( png_stream ) ; png_stream = NULL ;
    png_destroy_read_struct( &png_str, NULL, NULL ) ;
    LoggingDo(LL_ERROR, "Failed to create PNG info struct") ;
    return EIMG_NOMEMORY ;
  }

  if ( setjmp( png_jmp_buf ) )
  {
    fclose( png_stream ) ; png_stream = NULL ;
    png_destroy_read_struct( &png_str, &png_inf, NULL ) ;
    LoggingDo(LL_ERROR, "Error identifying the file") ;
    return EIMG_DATAINCONSISTENT ;
  }

  png_init_io( png_str, png_stream ) ;
  png_set_sig_bytes( png_str, NB_BYTES_HEADER );
  png_read_info( png_str, png_inf ) ;

  png2inf( png_str, png_inf, inf ) ;
  if ( (inf->width <= 0) || (inf->height <= 0) || (inf->nplanes <= 0) )
  {
    fclose( png_stream ) ; png_stream = NULL ;
    LoggingDo(LL_ERROR, "Inconsistent PNG data") ;
    err = EIMG_DATAINCONSISTENT ;
  }
  else
  {
    if ( inf->c.f.png.bit_depth == 16 ) png_set_strip_16( png_str ) ;
    if ( inf->c.f.png.type == PNG_COLOR_TYPE_PALETTE ) png_set_palette_to_rgb( png_str ) ;

    /* PNG_COLOR_TYPE_GRAY_ALPHA is always 8 or 16bit depth. */
    if ( (inf->c.f.png.type == PNG_COLOR_TYPE_GRAY) && (inf->c.f.png.bit_depth < 8) ) png_set_expand_gray_1_2_4_to_8( png_str ) ;
    if ( png_get_valid( png_str, png_inf, PNG_INFO_tRNS ) ) png_set_tRNS_to_alpha( png_str ) ;

    /* These color_type don't have an alpha channel then fill it with 0xff. */
    if ( (inf->c.f.png.type == PNG_COLOR_TYPE_RGB) || (inf->c.f.png.type == PNG_COLOR_TYPE_GRAY) || (inf->c.f.png.type == PNG_COLOR_TYPE_PALETTE) )
      png_set_filler( png_str, 0xFF, PNG_FILLER_AFTER ) ;

    if ( (inf->c.f.png.type == PNG_COLOR_TYPE_GRAY) || (inf->c.f.png.type == PNG_COLOR_TYPE_GRAY_ALPHA) )
      png_set_gray_to_rgb( png_str ) ;

    png_read_update_info( png_str, png_inf ) ;
    png2inf( png_str, png_inf, inf ) ;
  }

  return err ;
}

int cpu_png_load(INFO_IMAGE* inf)
{
  png_bytep   row ;
  MFDB*       out = &inf->mfdb ;
  GEM_WINDOW* wprog = (GEM_WINDOW*) inf->prog ;
  size_t      len_line ;
  long        all_y ;
  int         number_passes ;
  int         pass, y, yc, w16 ;
  int         ret = EIMG_SUCCESS ;

  out->fd_w       = (int) png_get_image_width( png_str, png_inf ) ;
  out->fd_h       = (int) png_get_image_height( png_str, png_inf ) ;
  out->fd_stand   = 0 ;
  out->fd_wdwidth = out->fd_w / 16 ;
  if ( out->fd_w % 16 ) out->fd_wdwidth++ ;

  if ( setjmp( png_jmp_buf ) )
  {
    if ( out->fd_addr ) Xfree( out->fd_addr ) ; out->fd_addr = NULL ;
    if ( png_row32 ) Xfree( png_row32 ) ;
    if ( png_stream ) fclose( png_stream ) ; png_stream = NULL ;
    png_destroy_read_struct( &png_str, &png_inf, NULL ) ;
    LoggingDo(LL_ERROR, "Error reading the file") ;
    return EIMG_DATAINCONSISTENT ;
  }

  png_row32 = NULL ; /* Not before as PureC would optimize it and would consider it NULL in setmp routine */
  if ( Force16BitsLoad )
  {
    LoggingDo(LL_INFO, "PNG image will be loaded to 16bit MFDB") ;
    out->fd_nplanes = 16 ;
    png_row32       = img_alloc( out->fd_w, 1, 32 ) ;
    if ( png_row32 == NULL )
    {
      png_destroy_read_struct( &png_str, &png_inf, NULL ) ;
      if ( png_stream ) fclose( png_stream ) ; png_stream = NULL ;
      return EIMG_NOMEMORY ;
    }
    /* Make sure last 16 pixels are white */
    if ( out->fd_w > 16 ) memset( png_row32 + sizeof(long)*(out->fd_w-16), 0xFF, sizeof(long)*16 ) ;
    w16 = ALIGN16( out->fd_w ) ;
  }
  else
    out->fd_nplanes = png_get_bit_depth( png_str, png_inf ) * png_get_channels( png_str, png_inf ) ;
  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL )
  {
    if ( png_row32 ) Xfree( png_row32 ) ; png_row32 = NULL ;
    png_destroy_read_struct( &png_str, &png_inf, NULL ) ;
    if ( png_stream ) fclose( png_stream ) ; png_stream = NULL ;
    return EIMG_NOMEMORY ;
  }

  len_line       = img_size( out->fd_w, 1, out->fd_nplanes ) ;
  number_passes  = (int) png_set_interlace_handling( png_str ) ;
  all_y          = (long)number_passes * (long)out->fd_h ;
  yc             = 0 ;
  for ( pass = 0; pass < number_passes; pass++ )
  {
    row = out->fd_addr ;
    for ( y = 0; y < out->fd_h; y++, yc++ )
    {
      if ( png_row32 )
      {
        png_read_row( png_str, png_row32, NULL ) ;
        tc32to16( png_row32, (short*)row, w16 ) ;
      }
      else png_read_row( png_str, row, NULL ) ;
      
      if ( STOP_CODE( GWProgRange( wprog, yc, all_y, NULL ) ) )
      {
        ret = EIMG_USERCANCELLED ;
        y   = out->fd_h ; pass = number_passes ;
      }
      row += len_line ;
    }
  }

  png_read_end( png_str, png_inf ) ;
  if ( png_row32 ) Xfree( png_row32 ) ; png_row32 = NULL ;
  png_destroy_read_struct( &png_str, &png_inf, NULL ) ;
  if ( png_stream ) fclose( png_stream ) ; png_stream = NULL ;

  return ret ;
}

#pragma warn -par
int cpu_png_sauve(char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  FILE*       stream ;
  png_structp rpng_str ;
  png_infop   rpng_inf ;
  int         err = EIMG_SUCCESS ;

  if ( libpngOpen != 1 ) err = open_slb_pnglib() ;
  if ( err != EIMG_SUCCESS ) return err ;

  rpng_str = png_create_write_struct( PNG_LIBPNG_VER_STRING, NULL, (png_error_ptr)NULL, (png_error_ptr)NULL ) ;
  if ( !rpng_str )
  {
    LoggingDo(LL_ERROR, "Failed to create PNG write struct") ;
    return EIMG_NOMEMORY ;
  }

  rpng_inf = png_create_info_struct( rpng_str ) ;
  if ( !rpng_inf )
  {
    LoggingDo(LL_ERROR, "Failed to create PNG info struct") ;
    png_destroy_write_struct( &rpng_str, (png_infopp) NULL ) ;
    return EIMG_NOMEMORY ;
  }

  stream = fopen( name, "wb" ) ;
  if ( stream == NULL )
  {
    LoggingDo(LL_ERROR, "Failed to create file %s", name) ;
    png_destroy_write_struct( &rpng_str, &rpng_inf ) ;
    return EIMG_FILENOEXIST ;
  }

  if ( setjmp( png_jmpbuf( rpng_str ) ) )
  {
    /* If we get here, we had a problem writing the file */
    fclose( stream ) ;
    png_destroy_write_struct( &rpng_str, &rpng_inf ) ;
    return EIMG_DATAINCONSISTENT ;
  }
/*
  png_set_IHDR( rpng_str, rpng_inf, img->fd_w, img->fd_h, ciBitDepth,
            PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE,
            PNG_FILTER_TYPE_BASE);
            */
  png_init_io( rpng_str, stream ) ;
  png_write_info( rpng_str, rpng_inf ) ;

  fclose( stream ) ;
  png_destroy_write_struct( &rpng_str, &rpng_inf ) ;
  return err ;
}
#pragma warn +par

void cpu_png_terminate(void)
{
  if ( libpngOpen == 1 ) /* pnglib was successfully open */
  {
    if ( png_stream ) fclose( png_stream ) ; png_stream = NULL ;
    png_destroy_read_struct( &png_str, &png_inf, NULL ) ;
    LoggingDo(LL_INFO, "Closing PNG shared library") ;
    slb_pnglib_close() ;
    libpngOpen = 0 ;
  }
}
