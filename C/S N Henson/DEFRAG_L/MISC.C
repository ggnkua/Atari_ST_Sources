/*
 * misc.c - miscellaneous functions for the Linux file system degragmenter.
 * misc.c,v 1.7 1993/01/07 14:48:50 linux Exp
 *
 * Copyright (C) 1992, 1993 Stephen Tweedie (sct@dcs.ed.ac.uk)
 * 
 * This file may be redistributed under the terms of the GNU General
 * Public License.
 *
 */


#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define MISC_C
#include "defrag.h"

volatile void fatal_error (const char * fmt_string)
{
	fflush (stdout);
	fprintf (stderr, fmt_string, program_name, device_name);
	exit (1);
}

volatile void usage()
{
	fflush (stdout);
	fprintf (stderr, 
		 "Usage: %s [-V"
#ifndef NODEBUG
		 "d"
#endif
		 "rsv] [-p pool_size] /dev/name\n", 
		 program_name);
	fprintf (stderr, "  -V : print full version information\n");
#ifndef NODEBUG
	fprintf (stderr, "  -d : debugging mode\n");
#endif
	fprintf (stderr, "  -r : read_only (testing) mode (implies -s)\n");
	fprintf (stderr, "  -s : show summary information\n");
	fprintf (stderr, "  -v : verbose (-vv is even more so)\n");
	exit (1);
}
