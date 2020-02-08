/*
 * jcompres.c
 *
*/

#include "jinclude.h"
#ifdef __STDC__
#include <stdlib.h>		/* to declare exit() */
#endif

#ifdef DONT_USE_B_MODE		/* define mode parameters for fopen() */
#define READ_BINARY	"r"
#define WRITE_BINARY	"w"
#else
#define READ_BINARY	"rb"
#define WRITE_BINARY	"wb"
#endif


# include "jrdvideo.h"

# include "jcompres.h"

/*
 * This routine determines what format the input file is,
 * and selects the appropriate input-reading module.
 *
 * To determine which family of input formats the file belongs to,
 * we look only at the first byte of the file, since C does not
 * guarantee that more than one character can be pushed back with ungetc.
 * This is sufficient for the currently envisioned set of input formats.
 *
 * If you need to look at more than one character to select an input module,
 * you can either
 *     1) assume you can fseek() the input file (may fail for piped input);
 *     2) assume you can push back more than one character (works in
 *        some C implementations, but unportable);
 * or  3) don't put back the data, and modify the various input_init
 *        methods to assume they start reading after the start of file.
 */


LOCAL void
set_source_format (compress_info_ptr cinfo, int mc)
{
  switch (mc) {
#ifdef GIF_SUPPORTED
  case 'G':
	cinfo->source_format = FMT_GIF ;
    break;
#endif
#ifdef PPM_SUPPORTED
  case 'P':
	cinfo->source_format = FMT_PPM ;
    break;
#endif
  default:
    ERREXIT(cinfo->emethods, "Unsupported input file format");
    break;
  }
}

LOCAL void
select_file_type (compress_info_ptr cinfo)
{
  switch (cinfo->source_format) {
#ifdef GIF_SUPPORTED
  case FMT_GIF:
    jselrgif(cinfo);
    break;
#endif
#ifdef PPM_SUPPORTED
  case FMT_PPM:
    jselrppm(cinfo);
    break;
#endif
  case FMT_VIDEO :
    jselrvideo(cinfo);
    break;
  case FMT_RGB :
    jselrmemrgb(cinfo);
    break;
  case FMT_NTC :
    jselrmemntc(cinfo);
    break;
  default:
    ERREXIT(cinfo->emethods, "Unsupported source format");
    break;
  }
}



/*
 * This routine gets control after the input file header has been read.
 * It must determine what output JPEG file format is to be written,
 * and make any other compression parameter changes that are desirable.
 */

METHODDEF void
c_ui_method_selection (compress_info_ptr cinfo)
{
  /* If the input is gray scale, generate a monochrome JPEG file. */
  if (cinfo->in_color_space == CS_GRAYSCALE)
    j_monochrome_default(cinfo);
  /* For now, always select JFIF output format. */
#ifdef JFIF_SUPPORTED
  jselwjfif(cinfo);
#else
  You shoulda defined JFIF_SUPPORTED.   /* deliberate syntax error */
#endif
}



/*------------------------------------------- open_cjpeg_files ----------*/
int open_cjpeg_files ( compress_info_ptr cinfo,
					   char *fil0, char *fil1, int argc )
{
  cinfo->input_file  = NULL ;
  cinfo->output_file = NULL ;
#ifdef TWO_FILE_COMMANDLINE
  switch ( argc )
  {
 case 2 :	if ( cinfo->source_format >= FMT_VIDEO  )
				return 3 ;
			if ((cinfo->input_file = fopen(fil0, READ_BINARY)) == NULL)
				return 4 ;
 			if ((cinfo->output_file = fopen(fil1, WRITE_BINARY)) == NULL)
				return 5 ;
		    break ;
 case 1 :	if (  cinfo->source_format < FMT_VIDEO  )
 				return 6 ;
			cinfo->input_file = NULL ;
			if ((cinfo->output_file = fopen(fil0, WRITE_BINARY)) == NULL)
				return 5 ;
		    break ;
 default :	return 6 ;
	}

#else /* not TWO_FILE_COMMANDLINE -- use Unix style */

  if (optind < argc-1) {
    fprintf(stderr, "%s: only one input file\n", argv[0]);
    usage(argv[0]);
  }
  if (optind < argc) {
    if ((cinfo.input_file = fopen(argv[optind], READ_BINARY)) == NULL) {
      fprintf(stderr, "%s: can't open %s\n", argv[0], argv[optind]);
      exit(2);
    }
  }

#endif /* TWO_FILE_COMMANDLINE */

  return 0 ;
}

/*----------------------------------- init_compress_info -----------*/
void init_compress_info ( compress_info_ptr cinfo,
						  struct Compress_methods_struct *c_methods,
						  struct External_methods_struct *e_methods,
						  IMAGE_FORMATS format )
{
  /* Initialize the system-dependent method pointers. */

  cinfo->source_format = format ;
  cinfo->methods  = c_methods;
  cinfo->emethods = e_methods;
  jselerror(e_methods);	/* error/trace message routines */
# if 0
  jselvirtmem(e_methods);	/* memory allocation routines */
# else
  jselmemmgr(e_methods);	/* memory allocation routines */
# endif
  c_methods->c_ui_method_selection = c_ui_method_selection;

  /* Set up default input and output file references. */
  /* (These may be overridden below.) */
  cinfo->input_file = stdin;
  cinfo->output_file = stdout;

  /* Set up default parameters. */
  e_methods->trace_level = 0;
  j_c_defaults(cinfo, 75, TRUE); /* default quality level */
}


/*--------------------------------------- compress_jpeg_file -------*/
int compress_jpeg_file ( compress_info_ptr cinfo )
{
	int mc ;

  /* Figure out the input file format, and set up to read it. */
	if ( cinfo->source_format < FMT_VIDEO )
	{
	  	if ((mc = getc(cinfo->input_file)) == EOF)
		    ERREXIT(cinfo->emethods, "Empty input file");
		if (ungetc(mc, cinfo->input_file) == EOF)
	    	ERREXIT(cinfo->emethods, "ungetc failed");
	    set_source_format ( cinfo, mc ) ;
	}

	select_file_type ( cinfo ) ;

  /* Do it to it! */
  jpeg_compress(cinfo);

#ifdef MEM_STATS
  if (cinfo->e_methods->trace_level > 0)
    j_mem_stats();
#endif
  return 0 ;
}


