/*
 * jpeg_com.c
 *
 */

#include "jinclude.h"

#include "jcompres.h"
#include "jrdvideo.h"
#include "jrd_mrgb.h"
#include "jrd_mntc.h"

#include "jpeg_com.h"


/*-------------------------------------------- window_to_jpeg -----*/
GLOBAL int window_to_jpeg ( char *file_name,
							char *start,
							int x, int y, int w, int h, int bpl )
{
	struct compress_info_struct cinfo ;
	struct compress_methods_struct c_methods ;
	struct external_methods_struct e_methods ;
	int result ;
  
	init_compress_info ( &cinfo, &c_methods, &e_methods, FMT_VIDEO ) ;

	set_compression_window ( start, x, y, w, h, bpl, 32 ) ;

	result = open_cjpeg_files ( &cinfo, file_name, NULL, 1 ) ;
	if ( result == 0 )
		result = compress_jpeg_file ( &cinfo ) ;
	if ( cinfo.output_file != NULL )
		fclose ( cinfo.output_file ) ;
	return result ;
}

/*-------------------------------------------- ntc_to_jpeg -----*/
GLOBAL int ntc_to_jpeg ( char *file_name, NTCpixel *start, int w, int h )
{
	struct compress_info_struct cinfo ;
	struct compress_methods_struct c_methods ;
	struct external_methods_struct e_methods ;
	int result ;
  
	init_compress_info ( &cinfo, &c_methods, &e_methods, FMT_NTC ) ;

	set_ntc_compression_size ( start, w, h ) ;

	result = open_cjpeg_files ( &cinfo, file_name, NULL, 1 ) ;
	if ( result == 0 )
		result = compress_jpeg_file ( &cinfo ) ;
	if ( cinfo.output_file != NULL )
		fclose ( cinfo.output_file ) ;
	return result ;
}


/*-------------------------------------------- rgb_to_jpeg -----*/
GLOBAL int rgb_to_jpeg ( char *file_name, char *start, int w, int h )
{
	struct compress_info_struct cinfo ;
	struct compress_methods_struct c_methods ;
	struct external_methods_struct e_methods ;
	int result ;
  
	init_compress_info ( &cinfo, &c_methods, &e_methods, FMT_RGB ) ;

	set_compression_size ( start, w, h ) ;

	result = open_cjpeg_files ( &cinfo, file_name, NULL, 1 ) ;
	if ( result == 0 )
		result = compress_jpeg_file ( &cinfo ) ;
	if ( cinfo.output_file != NULL )
		fclose ( cinfo.output_file ) ;
	return result ;
}
