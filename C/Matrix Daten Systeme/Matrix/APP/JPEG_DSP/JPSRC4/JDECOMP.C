/*
 * jdmain.c
 *
 * Copyright (C) 1991, Thomas G. Lane.
 * This file is part of the Independent JPEG Group's software.
 * For conditions of distribution and use, see the accompanying README file.
 *
 */

#include "jinclude.h"
#ifdef __STDC__
#include <stdlib.h>		/* to declare exit() */
#endif

/*
 * This routine gets control after the input file header has been read.
 * It must determine what output file format is to be written,
 * and make any other decompression parameter changes that are desirable.
 */


#include "jdecomp.h"

#ifdef DONT_USE_B_MODE		/* define mode parameters for fopen() */
#define READ_BINARY	"r"
#define WRITE_BINARY	"w"
#else
#define READ_BINARY	"rb"
#define WRITE_BINARY	"wb"
#endif


/*------------------------------------------- open_djpeg_files ----------*/
int open_djpeg_files ( decompress_info_ptr cinfo,
						   char *ifi, char *ofi, int argc )
{
	cinfo->input_file = NULL ;
	cinfo->output_file = NULL ;

  /* Select the input and output files */

#ifdef TWO_FILE_COMMANDLINE
  switch ( argc )
  {
 case 2 :	if ( cinfo->dest_format >= FMT_VIDEO )
				return 3 ;
			if ((cinfo->input_file = fopen(ifi, READ_BINARY)) == NULL)
				return 4 ;
 			if ((cinfo->output_file = fopen(ofi, WRITE_BINARY)) == NULL)
				return 5 ;
		    break ;
 case 1 :	if ( cinfo->dest_format < FMT_VIDEO )
 				return 6 ;
			cinfo->output_file = NULL ;
			if ((cinfo->input_file = fopen(ifi, READ_BINARY)) == NULL)
				return 4 ;
			break ;
 default :	return 6 ;
	}

#else /* not TWO_FILE_COMMANDLINE -- use Unix style */
???
#endif /* TWO_FILE_COMMANDLINE */

	return 0 ;
}

METHODDEF void
d_ui_method_selection (decompress_info_ptr cinfo)
{
  /* if grayscale or CMYK input, force similar output; */
  /* else leave the output colorspace as set by options. */
  if (cinfo->jpeg_color_space == CS_GRAYSCALE)
    cinfo->out_color_space = CS_GRAYSCALE;
  else if (cinfo->jpeg_color_space == CS_CMYK)
    cinfo->out_color_space = CS_CMYK;

  /* select output file format */
  /* Note: jselwxxx routine may make additional parameter changes,
   * such as forcing color quantization if it's a colormapped format.
   */
  switch ( cinfo->dest_format )
  {
#ifdef GIF_SUPPORTED
  case FMT_GIF:
    jselwgif(cinfo);
    break;
#endif
#ifdef PPM_SUPPORTED
  case FMT_PPM:
    jselwppm(cinfo);
    break;
#endif
 case FMT_VIDEO :
	jselwvideo(cinfo);
	break;

 case FMT_VIDEO_NTC :
	jselw_ntc(cinfo);
	break;


  default:
    ERREXIT(cinfo->emethods, "Unsupported output file format");
    break;
  }
}


/*
 * Reload the input buffer after it's been emptied, and return the next byte.
 * See the JGETC macro for calling conditions.
 *
 * This routine would need to be replaced if reading JPEG data from something
 * other than a stdio stream.
 */

METHODDEF int
read_jpeg_data (decompress_info_ptr cinfo)
{
  cinfo->bytes_in_buffer = (int)fread(cinfo->input_buffer + MIN_UNGET,
				 1, JPEG_BUF_SIZE,
				 cinfo->input_file);
  
  cinfo->next_input_byte = cinfo->input_buffer + MIN_UNGET;
  
  if (cinfo->bytes_in_buffer <= 0)
    ERREXIT(cinfo->emethods, "Unexpected EOF in JPEG file");

  return JGETC(cinfo);
}


/*-------------------------- init_decompress_info ----------*/
void init_decompress_info ( decompress_info_ptr cinfo,
							struct Decompress_methods_struct *dc_methods,
						    struct External_methods_struct *e_methods,
						    IMAGE_FORMATS format )
{
  cinfo->dest_format = format;

  /* Initialize the system-dependent method pointers. */
  cinfo->methods = dc_methods;
  cinfo->emethods = e_methods;
  jselerror(e_methods);	/* error/trace message routines */
# if 0
  jselvirtmem(e_methods);	/* memory allocation routines */
# else
  jselmemmgr(e_methods);	/* memory allocation routines */
# endif
  dc_methods->d_ui_method_selection = d_ui_method_selection;
  dc_methods->read_jpeg_data = read_jpeg_data;

  /* Allocate memory for input buffer. */
  cinfo->input_buffer = (char *) (*cinfo->emethods->alloc_small)
					((size_t) (JPEG_BUF_SIZE + MIN_UNGET));
  cinfo->bytes_in_buffer = 0;	/* initialize buffer to empty */

  /* Set up default input and output file references. */
  /* (These may be overridden below.) */
  cinfo->input_file = stdin;
  cinfo->output_file = stdout;

  /* Set up default parameters. */
  e_methods->trace_level = 0;
  cinfo->output_gamma = 1.0;
  cinfo->quantize_colors = FALSE;
  cinfo->two_pass_quantize = FALSE;
  cinfo->use_dithering = FALSE;
  cinfo->desired_number_of_colors = 256;
  cinfo->do_block_smoothing = FALSE;
  cinfo->do_pixel_smoothing = FALSE;
  cinfo->out_color_space = CS_RGB;
  cinfo->jpeg_color_space = CS_UNKNOWN;
}


/*-------------------------- decompress_jpeg_file ----------*/
int decompress_jpeg_file ( decompress_info_ptr cinfo )
{
  /* Set up to read a JFIF or baseline-JPEG file. */
  /* A smarter UI would inspect the first few bytes of the input file */
  /* to determine its type. */
#ifdef JFIF_SUPPORTED
  jselrjfif ( cinfo ) ;
#else
  You shoulda defined JFIF_SUPPORTED.   /* deliberate syntax error */
#endif

  /* Do it to it! */
  jpeg_decompress ( cinfo ) ;

  /* Release memory. */
  (*cinfo->emethods->free_small) ((void *) cinfo->input_buffer);
#ifdef MEM_STATS
  if (e_methods.trace_level > 0)
    j_mem_stats();
#endif

	return 0 ;
}

