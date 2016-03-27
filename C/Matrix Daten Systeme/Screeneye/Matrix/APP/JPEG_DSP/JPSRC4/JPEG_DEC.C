#include "jinclude.h"

#include "jdecomp.h"
#include "jwrvideo.h"
#include "jwr_ntc.h"

#include "jpeg_dec.h"


/*-------------------------------------------- jpeg_to_window -----*/
GLOBAL int jpeg_to_window ( char *file_name,
							char *start,
							int x, int y, int w, int h, int bpl )
{
  struct Decompress_info_struct cinfo;
  struct Decompress_methods_struct dc_methods;
  struct External_methods_struct e_methods;
  int result ;

  init_decompress_info ( &cinfo, &dc_methods, &e_methods, FMT_VIDEO ) ;

  set_decompress_window ( start, x, y, w, h, bpl ) ;

  result = open_djpeg_files ( &cinfo, file_name, NULL, 1 ) ;
  if ( result == 0 )
	result = decompress_jpeg_file ( &cinfo ) ;
  if ( cinfo.input_file != NULL )
	fclose ( cinfo.input_file ) ;
  return result ;
}

/*-------------------------------------------- jpeg_to_ntc_window -----*/
GLOBAL int jpeg_to_ntc_window ( char *file_name,
								unsigned short *start,
								int x, int y, int w, int h, int bpl )
{
  struct Decompress_info_struct cinfo;
  struct Decompress_methods_struct dc_methods;
  struct External_methods_struct e_methods;
  int result ;

  init_decompress_info ( &cinfo, &dc_methods, &e_methods, FMT_VIDEO_NTC ) ;

  set_ntc_decompress_window ( start, x, y, w, h, bpl ) ;

  result = open_djpeg_files ( &cinfo, file_name, NULL, 1 ) ;
  if ( result == 0 )
	  result = decompress_jpeg_file ( &cinfo ) ;
  if ( cinfo.input_file != NULL )
	fclose ( cinfo.input_file ) ;
  return result ;
}
