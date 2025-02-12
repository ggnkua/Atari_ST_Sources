/*
 * Copyright (c) 1987, 1989 University of Maryland
 * Department of Computer Science.  All rights reserved.
 * Permission to copy for any purpose is hereby granted
 * so long as this copyright notice remains intact.
 */

/*
 * getopt - get option letter from argv
 * (From Henry Spencer @ U of Toronto Zoology, slightly edited)
 */

/* 
 * modiifed by Tony Robinson on 27 March 1993 to remove the call to
 * index() and declare strcmp(); and strlen().
 * 08 Aug 94: these mods deleted and shorten.h included instead.
*/

/*
 * modified by Jon Fiscus on 18 August 1993: renamed to hs_getopt
 * to avoid conflicts with system provided calls.
*/

#include <stdio.h>
#include <string.h>
#include "shorten.h"

char	*hs_optarg;	/* Global argument pointer. */
int	 hs_optind;	/* Global argv index. */

static char *scan;	/* Private scan pointer. */

void hs_resetopt() {
        scan = (char *)0;
        hs_optind = 0;
} 

int
hs_getopt(argc, argv, optstring)
	register int argc;
	register char **argv;
	char *optstring;
{
	register int c;
	register char *place;

	hs_optarg = NULL;
	if (scan == NULL || *scan == 0) {
		if (hs_optind == 0)
			hs_optind++;
		if (hs_optind >= argc || argv[hs_optind][0] != '-' ||
		    argv[hs_optind][1] == 0)
			return (EOF);
		if (strcmp(argv[hs_optind], "--") == 0) {
			hs_optind++;
			return (EOF);
		}
		scan = argv[hs_optind] + 1;
		hs_optind++;
	}
	c = *scan++;

	/* BEGIN AJR MOD
	   this used to read:
	   place = index(optstring, c);
	   this code modified from code by Steve Lowe (steve@dragonsys.com)
	*/
	{ char *str = optstring;
	  if(str == NULL) place = NULL;
	  while((*str != '\0') && (*str != c)) str++;
	  if(*str == c) place = str;
	  else place = NULL;
	}
	/* END AJR MOD */

	if (place == NULL || c == ':') {
	  fprintf(stderr, "%s: unknown option -%c\n", argv[0], c);
	  return ('?');
	}
	place++;
	if (*place == ':') {
		if (*scan != '\0') {
			hs_optarg = scan;
			scan = NULL;
		} else {
			if (hs_optind >= argc) {
				fprintf(stderr,
					"%s: missing argument after -%c\n",
					argv[0], c);
				return ('?');
			}
			hs_optarg = argv[hs_optind];
			hs_optind++;
		}
	}
	return (c);
}
