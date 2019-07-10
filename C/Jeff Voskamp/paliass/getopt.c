#include <stdio.h>
#include <string.h>
/*
 *----------------------------------------------------------------------------
 *
 *	This getopt is derived from one posted to the net as part of
 *	the smail 2.5 distribution.  I have had to patch it to allow
 *	for a few MWC 2.0 and/or Atari TOS peculiarities.  These patches
 *	are noted in comments marked `:rwa:'.  The orginal header follows.
 *
 *----------------------------------------------------------------------------
 */

/*
**	@(#)getopt.c	2.5 (smail) 9/15/87
*/

/*
 * Here's something you've all been waiting for:  the AT&T public domain
 * source for getopt(3).  It is the code which was given out at the 1985
 * UNIFORUM conference in Dallas.  I obtained it by electronic mail
 * directly from AT&T.  The people there assure me that it is indeed
 * in the public domain.
 * 
 * There is no manual page.  That is because the one they gave out at
 * UNIFORUM was slightly different from the current System V Release 2
 * manual page.  The difference apparently involved a note about the
 * famous rules 5 and 6, recommending using white space between an option
 * and its first argument, and not grouping options that have arguments.
 * Getopt itself is currently lenient about both of these things White
 * space is allowed, but not mandatory, and the last option in a group can
 * have an argument.  That particular version of the man page evidently
 * has no official existence, and my source at AT&T did not send a copy.
 * The current SVR2 man page reflects the actual behavor of this getopt.
 * However, I am not about to post a copy of anything licensed by AT&T.
 */

/*LINTLIBRARY*/
/* #define NULL	0 */
/* #define EOF	(-1) */

/*	MWC can't hack the original macro (too complex). I have made it
	simpler and defined a function, prterr(), to do the work. :rwa:	    */

#define ERR(s, c)	if ( opterr ) prterr( argv, s, c )

static void
prterr( argv, s, c )
	char * * argv;
	char * s;
	int c; {
	extern int strlen();
	char errbuf[3];

	errbuf[0] = c;
	errbuf[1] = '\r';		/* added \r to pander to TOS :rwa: */
	errbuf[2] = '\n';

	(void) write(2, argv[0], (unsigned)strlen(argv[0]));
	(void) write(2, s, (unsigned)strlen(s));
	(void) write(2, errbuf, 3);
}

#define strchr index			/* SysV-ism, use v7 routine :rwa: */

extern int strcmp();
extern char *strchr();

int	opterr = 1;
int	optind = 1;
int	optopt;
char	*optarg;

int
getopt(argc, argv, opts)
int	argc;
char	**argv, *opts;
{
	static int sp = 1;
	register int c;
	register char *cp;

	if(sp == 1)
		if(optind >= argc ||
		   argv[optind][0] != '-' || argv[optind][1] == '\0')
			return(EOF);
		else if(strcmp(argv[optind], "--") == NULL) {
			optind++;
			return(EOF);
		}
	optopt = c = argv[optind][sp];
	if(c == ':' || (cp=strchr(opts, c)) == NULL) {
		ERR(": unknown option, -", c);
		if(argv[optind][++sp] == '\0') {
			optind++;
			sp = 1;
		}
		return('?');
	}
	if(*++cp == ':') {
		if(argv[optind][sp+1] != '\0')
			optarg = &argv[optind++][sp+1];
		else if(++optind >= argc) {
			ERR(": argument missing for -", c);
			sp = 1;
			return('?');
		} else
			optarg = argv[optind++];
		sp = 1;
	} else {
		if(argv[optind][++sp] == '\0') {
			sp = 1;
			optind++;
		}
		optarg = NULL;
	}
	return(c);
}
