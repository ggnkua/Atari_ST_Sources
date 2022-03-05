/***************************************************************
*								*
*  PDMAKE, Atari ST version					*
*								*
*  Adapted from mod.sources Vol 7 Issue 71, 1986-12-03.		*
*								*
*  This port makes extensive use of the original net.sources	*
*  port by Jwahar Bammi.					*
*								*
*      Ton van Overbeek						*
*      Email: TPC862@ESTEC.BITNET				*
*             TPC862%ESTEC.BITNET@WISCVM.WISC.EDU    (ARPA)	*
*             ...!mcvax!tpc862%estec.bitnet   (UUCP Europe)	*
*             ...!ucbvax!tpc862%estec.bitnet  (UUCP U.S.A.)	*
*             71450,3537  (CompuServe)				*
*								*
\***************************************************************/

/*
 *    make [-f makefile] [-ins] [target(s) ...]
 *
 *    (Better than EON mk but not quite as good as UNIX make)
 *
 *    -f makefile name
 *    -i ignore exit status
 *    -n Pretend to make
 *    -p Print all macros & targets
 *    -q Question up-to-dateness of target.  Return exit status 1 if not
 *    -r Don't not use inbuilt rules
 *    -s Make silently
 *    -t Touch files instead of making them
 *    -m Change memory requirements (EON only)
 *
 *    -e Don't read the environment to set marcros (tony)
 *    -c dir  chdir to 'dir' before running...
 */

long	_BLKSIZ = 4096;		/* don't grab too much memory */

#include <stdio.h>
#include "h.h"

#include "astat.h"

long	_STKSIZ = 16 * 1024L;

char	*myname;
char	*makefile = "";		/*  The make file  */

FILE *ifd;			/*  Input file desciptor  */
bool	domake = TRUE;		/*  Go through the motions option  */
bool	ignore = FALSE;		/*  Ignore exit status option  */
bool	silent = FALSE;		/*  Silent option  */
bool	print = FALSE;		/*  Print debuging information  */
bool	rules = TRUE;		/*  Use inbuilt rules  */
bool	dotouch = FALSE;	/*  Touch files instead of making  */
bool	quest = FALSE;		/*  Question up-to-dateness of file  */
bool	doenv = FALSE;		/*  macros in the env. take precendence */
char	*dir = NULL;		/*  'cd' here before starting */


main(argc, argv)
int	argc;
char	*argv[];
{
	register char	*p;	/*  For argument processing  */
	int	estat = 0;	/*  For question  */
	register struct name *np;

	myname = "make";			/*  TOS doesn't pass argv[0]  */
	argc--;  
	argv++;

	while ((argc > 0) && (**argv == '-')) {
		argc--;				/*  One less to process  */
		p = *argv++;			/*  Now processing this one  */

		while (*++p != '\0') {
			switch (*p) {
			case 'f':		/*  Alternate file name  */
			case 'F':
				if (*++p == '\0') {
					if (argc-- <= 0)
						usage();
					p = *argv++;
				}
				makefile = p;
				goto end_of_args;
			case 'c':
			case 'C':
				if (*++p == '\0') {
					if (argc-- <= 0)
						usage();
					p = *argv++;
				}
				dir = p;
				goto end_of_args;
				break;
			case 'n':		/*  Pretend mode  */
			case 'N':
				domake = FALSE;
				break;
			case 'i':		/*  Ignore fault mode  */
			case 'I':
				ignore = TRUE;
				break;
			case 's':		/*  Silent about commands  */
			case 'S':
				silent = TRUE;
				break;
			case 'p':
			case 'P':
				print = TRUE;
				break;
			case 'r':
			case 'R':
				rules = FALSE;
				break;
			case 't':
			case 'T':
				dotouch = TRUE;
				break;
			case 'q':
			case 'Q':
				quest = TRUE;
				break;
			case 'e':
			case 'E':
				doenv = TRUE;
				break;
			default:    /*  Wrong option  */
				usage();
			}
		}
end_of_args:
		;
	}

	if (dir != NULL) {
		if (chdir(dir) != 0)
			fatal("Can't chdir to %s", dir);
	}

	if (strcmp(makefile, "-") == 0)	/*  Can use stdin as makefile  */
		ifd = stdin;
	else if (*makefile == '\0')	/*  If no file, then use default */
		ifd = fopen(DEFN1, "r");
	else if ((ifd = fopen(makefile, "r")) == (FILE * )0)
		fatal("Can't open %s", makefile);

	makerules();

	setmacro("$", "$");

	while (argc && (p = strchr(*argv, '='))) {
		char	c;

		c = *p;
		*p = '\0';
		setmacro(*argv, p + 1);
		*p = c;

		argv++;
		argc--;
	}

	/*
	 * By default macro values are read from the environment before
	 * the makefile is scanned. That way, the makefile overrides any
	 * values set in the environment.
	 */
	if (!doenv)
		readenv();

	if (ifd != NULL) {
		input(ifd);	/*  Input all the gunga  */
		fclose(ifd);	/*  Finished with makefile  */
	}

	/*
	 * If the environment takes precedence, read it last.
	 */
	if (doenv)
		readenv();

	lineno = 0;	/*  Any calls to error now print no line number */

	if (print)
		prt();		/*  Print out structures  */

	np = newname(".SILENT");
	if (np->n_flag & N_TARG)
		silent = TRUE;

	np = newname(".IGNORE");
	if (np->n_flag & N_TARG)
		ignore = TRUE;

	precious();

	if (!firstname && ifd != NULL)
		fatal("No targets defined");

	circh();		/*  Check circles in target definitions  */

	if (!argc) {
		if (firstname)
			estat = make(firstname, 0);
		else
			fatal("No target or makefile");
	} else 
		while (argc--) {
			if (!print && !silent && strcmp(*argv, "love") == 0)
				printf("Not war!\n");
			estat |= make(newname(*argv++), 0);
		}

	if (quest)
		exit(estat);
	else
		exit(0);
}


usage()
{
	fprintf(stderr,
	    "Usage: %s [-f makefile] [-inpqrst] [macro=val ...] [target(s) ...]\n",
	    myname);
	exit(1);
}


void
fatal(msg, a1, a2, a3, a4, a5, a6)
char	*msg;
{
	fprintf(stderr, "%s: ", myname);
	fprintf(stderr, msg, a1, a2, a3, a4, a5, a6);
	fputc('\n', stderr);
	exit(1);
}
