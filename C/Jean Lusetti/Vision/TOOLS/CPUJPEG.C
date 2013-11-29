/********************************/
/* Gestion du format JPEG (CPU) */
/********************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include         "..\tools\xgem.h"
#include     "..\tools\rasterop.h"
#include     "..\tools\image_io.h"
#include "..\tools\jpeg\jpeglib.h"

#include "defs.h"

FILE          *infile ;
struct        jpeg_decompress_struct cinfo ;
char          info_is_allocated ;
unsigned char GrayScale[256] ;


void release_info(void)
{
  jpeg_destroy_decompress( &cinfo );
  fclose( infile ) ;
  info_is_allocated = 0 ;
}

int cpu_jpeg_identify(char *nom, INFO_IMAGE *inf)
{
  int  ret ;

  if ( info_is_allocated ) release_info() ;

  infile = fopen( nom, "rb" ) ;
  if ( infile == NULL ) return( -1 ) ;

  /* Step 1: allocate and initialize JPEG decompression object */
  /* We set up the normal JPEG error routines */
/*  cinfo.err = jpeg_std_error( &jerr );*/

  /* Now we can initialize the JPEG decompression object. */
  jpeg_create_decompress( &cinfo ) ;

  /* Step 2: specify data source (eg, a file) */
  jpeg_stdio_src( &cinfo, infile ) ;

  /* Step 3: read file parameters with jpeg_read_header() */
  ret = ( jpeg_read_header( &cinfo, TRUE ) == JPEG_HEADER_OK ) ? 0:-2 ;
  cinfo.dct_method  = JDCT_IFAST ; /* Selection de la DCT rapide sur entiers */
  cinfo.dither_mode = JDITHER_NONE ;

  inf->byteorder = 0 ; /* Sans importance */
  inf->version   = 1 ;
  inf->compress  = 1 ;
  inf->predictor = 0 ;
  inf->palette   = NULL ;
  inf->nb_cpal   = 0 ;
  inf->nplans    = 24 ;
  inf->lpix      = 0x150 ;
  inf->hpix      = 0x150 ;
  inf->largeur   = cinfo.image_width ;
  inf->hauteur   = cinfo.image_height ;
  inf->quality   = 75 ;

  if ( cinfo.out_color_space == JCS_GRAYSCALE )
  {
    int i ;
    float coe = 1000.0/(254.0-16.0) ;
    int *pt_pal ;
    int v, b ;
    unsigned char *pt_vdi2tos ;

    inf->nplans    = 8 ;
    inf->nb_cpal   = 256 ;
    inf->palette = malloc( 6*inf->nb_cpal ) ;
    pt_pal = (int *) inf->palette ;
    if ( pt_pal == NULL )
      ret = -3 ;
    else
    {
      pt_vdi2tos = get_ptvdi2tos( 8 ) ;
      for ( b = 0; b < 16; b++ )
      {
        v = 3*pt_vdi2tos[b] ;
        memcpy( &pt_pal[v], &vdi_sys_colors[3*b], 6 ) ;
      }
      pt_pal += 16*3 ;
      for ( i = 16; i < 255; i++ )
      {
        v = (int) ( 0.5 + (float)((i-16))*coe ) ;
        *pt_pal++ = v ;
        *pt_pal++ = v ;
        *pt_pal++ = v ;
      }
    }

    if ( GrayScale[255] == 0 ) /* GreyScale non initialise */
    {
      coe = (254.0-16.0)/255.0 ;
      for ( i = 0; i < 256; i++ ) GrayScale[i] = (unsigned char) ( 16.5 + (float)i*coe ) ;
    }
  }

  if ( ret ) release_info() ;
  else       info_is_allocated = 1 ;

  return( ret ) ;
}

int cpu_jpeg_load(MFDB *out, GEM_WINDOW *wprog)
{
  JSAMPARRAY    buffer ;	 /* Output row buffer */
  long          lo_line ;
  int           row_stride ; /* physical row width in output buffer */
  int           code, pc ;
  int           ret = 0 ;
  unsigned long *ulrgb ;
  unsigned char *ucrgb ;
  unsigned char *indexes ;

  out->fd_w = cinfo.image_width ;
  out->fd_h = cinfo.image_height ;
  out->fd_wdwidth = out->fd_w / 16 ;
  if ( out->fd_w % 16 ) out->fd_wdwidth++ ;
  if ( cinfo.out_color_space == JCS_GRAYSCALE )
  {
    out->fd_nplanes  = 8 ;
  }
  else if ( out->fd_nplanes < 16 ) out->fd_nplanes  = ( Force16BitsLoad ? 16 : 24 ) ;
  out->fd_addr = img_alloc( out->fd_w, out->fd_h, out->fd_nplanes ) ;
  if ( out->fd_addr == NULL )
  {
    release_info() ;
    return( -3 ) ;
  }

  ulrgb   = (unsigned long *) out->fd_addr ;
  ucrgb   = (unsigned char *) out->fd_addr ;
  lo_line = img_size( out->fd_w, 1, out->fd_nplanes ) ;
  if ( out->fd_nplanes == 16 ) lo_line = lo_line >> 1 ;
  else if ( out->fd_nplanes == 32 ) lo_line = lo_line >> 2 ;
  (void) jpeg_start_decompress( &cinfo ) ;

  /* We may need to do some setup of our own at this point before reading
   * the data.  After jpeg_start_decompress() we have the correct scaled
   * output image dimensions available, as well as the output colormap
   * if we asked for color quantization.
   * In this example, we need to make an output work buffer of the right size.
   */ 
  /* JSAMPLEs per row in output buffer */
  row_stride = cinfo.output_width * cinfo.output_components ;
  /* Make a one-row-high sample array that will go away when done with image */
  buffer = (*cinfo.mem->alloc_sarray)
		( (j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1 ) ;

  /* Step 6: while (scan lines remain to be read) */
  /*           jpeg_read_scanlines(...); */

  /* Here we use the library's state variable cinfo.output_scanline as the
   * loop counter, so that we don't have to keep track ourselves.
   */

  i2r_init( out, cinfo.image_width, 0 ) ; 
  i2r_nb   = row_stride ;
  i2r_data = buffer[0] ;
  perf_start( PERF_COMPRESS, &PerfInfo ) ;
  while ( cinfo.output_scanline < cinfo.output_height )
  {
    /* jpeg_read_scanlines expects an array of pointers to scanlines.
     * Here the array is only one element long, but you could ask for
     * more than one scanline at a time if that's more convenient.
     */
    (void) jpeg_read_scanlines( &cinfo, buffer, 1 ) ;

    switch( out->fd_nplanes )
    {
      case  8 : indexes = i2r_data ;
                for ( pc = 0; pc < cinfo.image_width; pc++ ) indexes[pc] = GrayScale[indexes[pc]] ;
                ind2raster() ;
                break ;

      case 16 : tc24to16() ;
                break ;

      case 24 : memcpy( ucrgb, buffer[0], row_stride ) ;
                break ;

      case 32 : tc24to32( buffer[0], ulrgb, cinfo.image_width ) ;
                ulrgb += lo_line ;
                break ;
    }
    ucrgb += lo_line ;
    if ( MAY_UPDATE( wprog, cinfo.output_scanline ) )
    {
      pc = (int) ((100L*cinfo.output_scanline)/(long)cinfo.output_height) ;
      code = wprog->ProgPc( wprog, pc, NULL ) ;
      if ( STOP_CODE( code ) )
      {
        ret = -8 ;
        break ;
      }
    }
  }

  /* Step 7: Finish decompression */
  (void) jpeg_finish_decompress( &cinfo ) ;
  perf_stop( PERF_COMPRESS, &PerfInfo ) ;

  /* Step 8: Release JPEG decompression object */
  release_info() ;

  if ( ret == 0 ) RasterResetUnusedData( out ) ;

  return( ret ) ;
}

void make_grayscale(INFO_IMAGE *info, unsigned char *grayscale)
{
  float coe = 255.0/1000.0 ;
  int i ;
  int *pt_pal ;

  pt_pal = (int *) info->palette ;
  for ( i = 0; i < info->nb_cpal; i++ )
  {
    grayscale[i] = (unsigned char) ( 0.5 + ((float)(*pt_pal)) * coe ) ;
    pt_pal      += 3 ;
  }
}

int cpu_jpeg_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog)
{
  struct jpeg_compress_struct cinfo ;
/*  struct jpeg_error_mgr       jerr ;*/
  int                         pc ;
  FILE                        *outfile ;
  JSAMPROW                    row_pointer[1] ;
  int                         *pt_img16 ;
  unsigned char               *pt_img24 ;
  long                        *pt_img32 ;
  long                        add_line ;
  unsigned char               *buffer24 = NULL ;
  unsigned char               *indexes = NULL ;
  unsigned char               grayscale[256] ;

  if ( img->fd_nplanes < 8 ) return( -6 ) ;

  add_line = img_size( img->fd_w, 1, img->fd_nplanes ) ;
  switch( img->fd_nplanes )
  {
    case  8 : add_line >>= 1 ;
              indexes = img_alloc( img->fd_w, 1, 8 ) ;
              if ( indexes == NULL ) return( -3 ) ;
              break ;

    case 16 : add_line >>= 1 ;
              buffer24 = img_alloc( img->fd_w, 1, 24 ) ;
              if ( buffer24 == NULL ) return( -3 ) ;
              break ;

    case 24 : /* OK */
              break ;

    case 32 : add_line >>= 2 ;
              buffer24 = img_alloc( img->fd_w, 1, 24 ) ;
              if ( buffer24 == NULL ) return( -3 ) ;
              break ;
  }

  /* Step 1: allocate and initialize JPEG compression object */
/*  cinfo.err = jpeg_std_error( &jerr ) ;*/

  /* Now we can initialize the JPEG compression object. */
  jpeg_create_compress( &cinfo ) ;

  /* Step 2: specify data destination (eg, a file) */
  /* Note: steps 2 and 3 can be done in either order. */
  outfile = fopen( name, "wb" ) ;
  if ( outfile == NULL ) return( -1 ) ;

  jpeg_stdio_dest( &cinfo, outfile ) ;

  /* Step 3: set parameters for compression */

  /* First we supply a description of the input image.
   * Four fields of the cinfo struct must be filled in:
   */
  cinfo.image_width      = img->fd_w ;
  cinfo.image_height     = img->fd_h ;
  if ( ( img->fd_nplanes == 8 ) && info->palette )
  {
    /* Suppose qu'il s'agit d'une image en niveaux de gris */
    cinfo.input_components = 1 ;
    cinfo.in_color_space   = JCS_GRAYSCALE ;
    make_grayscale( info, grayscale ) ;
  }
  else
  {
    cinfo.input_components = 3;          /* # of color components per pixel */
    cinfo.in_color_space   = JCS_RGB;    /* colorspace of input image */
  }

  jpeg_set_defaults( &cinfo ) ;
  /* Now you can set any non-default parameters you wish to.
   * Here we just illustrate the use of quality (quantization table) scaling:
   */
  jpeg_set_quality( &cinfo, info->quality, TRUE /* limit to baseline-JPEG values */ ) ;
  cinfo.dct_method  = JDCT_IFAST ; /* Selection de la DCT rapide sur entiers */

  /* Step 4: Start compressor */

  /* TRUE ensures that we will write a complete interchange-JPEG file.
   * Pass TRUE unless you are very sure of what you're doing.
   */
  jpeg_start_compress( &cinfo, TRUE ) ;

  pt_img16 = (int *)  img->fd_addr ;
  pt_img24 = (unsigned char *) img->fd_addr ;
  pt_img32 = (long *) img->fd_addr ;

  while ( cinfo.next_scanline < cinfo.image_height )
  {
    switch( img->fd_nplanes )
    {
      case  8 : raster2ind( pt_img16, indexes, img->fd_wdwidth << 4, img->fd_nplanes ) ;
                for ( pc = 0; pc < img->fd_w; pc++ ) indexes[pc] = grayscale[indexes[pc]] ;
                row_pointer[0] = indexes ;
                pt_img16 += add_line ;
                break ;

      case 16 : tc16to24( pt_img16, buffer24, img->fd_w ) ;
                row_pointer[0] = buffer24 ;
                pt_img16 += add_line ;
                break ;

      case 24 : row_pointer[0] = pt_img24 ;
                pt_img24 += add_line ;
                break ;

      case 32 : tc32to24( pt_img32, buffer24, img->fd_w ) ;
                row_pointer[0] = buffer24 ;
                pt_img32 += add_line ;
                break ;
    }
    (void) jpeg_write_scanlines( &cinfo, row_pointer, 1 ) ;
    if ( MAY_UPDATE( wprog, cinfo.next_scanline ) )
    {
      pc = (int) ((100L*cinfo.next_scanline)/(long)cinfo.image_height) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
  }

  /* Step 6: Finish compression */
  jpeg_finish_compress( &cinfo ) ;
  fclose( outfile ) ;
  jpeg_destroy_compress( &cinfo ) ;

  if ( buffer24 ) free( buffer24 ) ;
  if ( indexes ) free( indexes ) ;

  return( 0 ) ;
}
