/*
 * jdmain.c
 *
 * Copyright (C) 1991, Thomas G. Lane.
 * This file is part of the Independent JPEG Group's software.
 * For conditions of distribution and use, see the accompanying README file.
 *
 * This file contains a trivial test user interface for the JPEG decompressor.
 * It should work on any system with Unix- or MS-DOS-style command lines.
 *
 * Two different command line styles are permitted, depending on the
 * compile-time switch TWO_FILE_COMMANDLINE:
 *	djpeg [options]  inputfile outputfile
 *	djpeg [options]  [inputfile]
 * In the second style, output is always to standard output, which you'd
 * normally redirect to a file or pipe to some other program.  Input is
 * either from a named file or from standard input (typically redirected).
 * The second style is convenient on Unix but is unhelpful on systems that
 * don't support pipes.  Also, you MUST use the first style if your system
 * doesn't do binary I/O to stdin/stdout.
 */

#include "jinclude.h"
#ifdef __STDC__
#include <stdlib.h>		/* to declare exit() */
#endif

#ifdef THINK_C
#include <console.h>		/* command-line reader for Macintosh */
#endif

/*
 * If your system has getopt(3), you can use your library version by
 * defining HAVE_GETOPT.  By default, we use the PD 'egetopt'.
 */

#ifdef HAVE_GETOPT
extern int getopt PP((int argc, char **argv, char *optstring));
extern char * optarg;
extern int optind;
#else
#include "egetopt.c"
#define getopt(argc,argv,opt)	egetopt(argc,argv,opt)
#endif

#include "jdecomp.h"


LOCAL void
usage (char * progname)
/* complain about bad command line */
{
  fprintf(stderr, "usage: %s ", progname);
  fprintf(stderr, "[-b] [-q colors] [-2] [-d] [-v] [-g] [-G]");
#ifdef TWO_FILE_COMMANDLINE
  fprintf(stderr, " inputfile [ outputfile ]\n");
#else
  fprintf(stderr, " [inputfile]\n");
#endif
  exit(2);
}


/*
 * The main program.
 */

GLOBAL int
main (int argc, char **argv)
{
  struct decompress_info_struct cinfo;
  struct decompress_methods_struct dc_methods;
  struct external_methods_struct e_methods;
  int c, result ;

#ifdef PPM_SUPPORTED
  init_decompress_info ( &cinfo, &dc_methods, &e_methods, FMT_PPM ) ;
#else
  init_decompress_info ( &cinfo, &dc_methods, &e_methods, FMT_GIF ) ;
#endif

  /* On Mac, fetch a command line. */
#ifdef THINK_C
  argc = ccommand(&argv);
#endif

  /* setting any other value in jpeg_color_space overrides heuristics */
  /* in jrdjfif.c ... */
  /* You may wanta change the default output format; here's the place: */

  /* Scan parameters */
  while ((c = getopt(argc, argv, "bq:2DdgvG")) != EOF)
  {
    switch (c)
    {
    case 'b':			/* Enable cross-block smoothing. */
      cinfo.do_block_smoothing = TRUE;
      break;

    case 'q':			/* Do color quantization. */
      { int val;
	if (optarg == NULL)
	  usage(argv[0]);
	if (sscanf(optarg, "%d", &val) != 1)
	  usage(argv[0]);
	cinfo.desired_number_of_colors = val;
      }
      cinfo.quantize_colors = TRUE;
      break;
    case '2':			/* Use two-pass quantization. */
      cinfo.two_pass_quantize = TRUE;
      break;
    case 'D':			/* Use dithering in color quantization. */
      cinfo.use_dithering = TRUE;
      break;
    case 'd':			/* Debugging. */
      e_methods.trace_level++;
      break;
    case 'g':			/* Force grayscale output. */
      cinfo.out_color_space = CS_GRAYSCALE;
      break;

    case 'v' :	cinfo.dest_format = FMT_VIDEO ;
    			break ;
    case 'G':			/* GIF output format. */
      cinfo.dest_format = FMT_GIF;
      break;
    case '?':
    default:
      usage(argv[0]);
      break;
    }
  }


  result = open_djpeg_files ( &cinfo, argv[optind], argv[optind+1], argc - optind ) ;
  if ( result == 0 )
	  result = decompress_jpeg_file ( &cinfo ) ;

  switch ( result )
  {
 case 0 :	return 0 ;
 case 3 :	fprintf(stderr, "%s: only one input file for direct video output\n", argv[0]);
			break ;
 case 4 :	fprintf(stderr, "%s: can't open %s\n", argv[0], argv[optind]) ;
			break ;
 case 5 :	fprintf(stderr, "%s: can't create %s\n", argv[0], argv[optind+1]) ;
			break ;
 case 6 :	fprintf(stderr, "%s: must name one input and one output file\n", argv[0]);
			break ;
 case 7 :   fprintf(stderr, "%s: only one input file\n", argv[0]);
			break ;
  }

  usage(argv[0]);
  
  return result ;
}
