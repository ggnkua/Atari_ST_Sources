/*
 * jcmain.c
 *
 * Copyright (C) 1991, Thomas G. Lane.
 * This file is part of the Independent JPEG Group's software.
 * For conditions of distribution and use, see the accompanying README file.
 *
 * This file contains a trivial test user interface for the JPEG compressor.
 * It should work on any system with Unix- or MS-DOS-style command lines.
 *
 * Two different command line styles are permitted, depending on the
 * compile-time switch TWO_FILE_COMMANDLINE:
 *	cjpeg [options]  inputfile outputfile
 *	cjpeg [options]  [inputfile]
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

#include "jcompres.h"

#ifdef HAVE_GETOPT
extern int getopt PP((int argc, char **argv, char *optstring));
extern char * optarg;
extern int optind;
#else
#include "egetopt.c"
#define getopt(argc,argv,opt)	egetopt(argc,argv,opt)
#endif

LOCAL void
usage (char * progname)
/* complain about bad command line */
{
  fprintf(stderr, "usage: %s ", progname);
  fprintf(stderr, "[-I] [-Q quality 0..100] [-a] [-o] [-d] [-v]");
#ifdef TWO_FILE_COMMANDLINE
  fprintf(stderr, " [inputfile] outputfile\n");
#else
  fprintf(stderr, " [inputfile]\n");
#endif
  exit(2);
}
/*------------------------------------------------- main -----------*/
GLOBAL int
main (int argc, char **argv)
{
  struct compress_info_struct cinfo;
  struct compress_methods_struct c_methods;
  struct external_methods_struct e_methods;
  int c, result ;
  
  /* On Mac, fetch a command line. */
#ifdef THINK_C
  argc = ccommand(&argv);
#endif

  init_compress_info ( &cinfo, &c_methods, &e_methods, FMT_UNDEF ) ;
  /* Scan parameters */
 
  while ((c = getopt(argc, argv, "IQ:vaod")) != EOF)
    switch (c) {
    case 'I':			/* Create noninterleaved file. */
#ifdef MULTISCAN_FILES_SUPPORTED
      cinfo.interleave = FALSE;
#else
      fprintf(stderr, "%s: sorry, multiple-scan support was not compiled\n",
	      argv[0]);
      exit(2);
#endif
      break;
    case 'Q':			/* Quality factor. */
      { int val;
	if (optarg == NULL)
	  usage(argv[0]);
	if (sscanf(optarg, "%d", &val) != 1)
	  usage(argv[0]);
	/* Note: for now, we leave force_baseline FALSE.
	 * In a production user interface, probably should make it TRUE
	 * unless overridden by a separate switch.
	 */
	j_set_quality(&cinfo, val, FALSE);
      }
      break;
    case 'v':
    	cinfo.source_format = FMT_VIDEO ;
      break ;
    case 'a':			/* Use arithmetic coding. */
#ifdef ARITH_CODING_SUPPORTED
      cinfo.arith_code = TRUE;
#else
      fprintf(stderr, "%s: sorry, arithmetic coding not supported\n",
	      argv[0]);
      exit(2);
#endif
      break;
    case 'o':			/* Enable entropy parm optimization. */
#ifdef ENTROPY_OPT_SUPPORTED
      cinfo.optimize_coding = TRUE;
#else
      fprintf(stderr, "%s: sorry, entropy optimization was not compiled\n",
	      argv[0]);
      exit(2);
#endif
      break;
    case 'd':			/* Debugging. */
      e_methods.trace_level++;
      break;
    case '?':
    default:
      usage(argv[0]);
      break;
    }

  /* Select the input and output files */

	result = open_cjpeg_files ( &cinfo, argv[optind], argv[optind+1],
								argc - optind ) ;
	if ( result == 0 )
		result = compress_jpeg_file ( &cinfo ) ;

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
