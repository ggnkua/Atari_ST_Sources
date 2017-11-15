/* Copyright (c) 1988,1989,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */
#include "top.h"

FILE	*ifp, *ofp;		/* input/output file pointers */

#ifndef	MINIX
long	_STKSIZ = 32768L;	/* need mucho stack for recursion */
#endif

/*
 * Options 
 */
bool	debug   = FALSE;
bool	do_brev = TRUE;		/* branch reversals enabled */
bool	do_peep = TRUE;		/* peephole optimizations enabled */
bool	do_regs = TRUE;		/* do "registerizing" */
bool	do_lrot = TRUE;		/* do loop rotations */
bool	gflag = FALSE;		/* don't do stuff that confuses the debugger */
bool	verbose = FALSE;

/*
 * Optimization statistics (use -v to print)
 */
int	s_bdel = 0;		/* branches deleted */
int	s_badd = 0;		/* branches added */
int	s_brev = 0;		/* branch reversals */
int	s_lrot = 0;		/* loop rotations */
int	s_peep1 = 0;		/* 1 instruction peephole changes */
int	s_peep2 = 0;		/* 2 instruction peephole changes */
int	s_peep3 = 0;		/* 3 instruction peephole changes */
int	s_idel = 0;		/* instructions deleted */
int	s_reg = 0;		/* variables "registerized" */

#define	TMPFILE	"top_tmp.$$$"	/* temporary file name */
int	use_temp = FALSE;	/* using temporary file */

char	*Version =
"top Version 2.00  Copyright (c) 1988-1991 by Sozobon, Limited.";

usage()
{
	fprintf(stderr, "usage: top [-gdvblpr] infile [outfile]\n");
	exit(1);
}

main(argc, argv)
int	argc;
char	*argv[];
{
	FILE	*fopen();
	register char	*s;

	while (argc > 1 && argv[1][0] == '-') {
		for (s = &argv[1][1]; *s ;s++) {
			switch (*s) {
			case 'd': case 'D':
				debug = TRUE;
				break;
			case 'b': case 'B':
				do_brev = FALSE;
				break;
			case 'p': case 'P':
				do_peep = FALSE;
				break;
			case 'r': case 'R':
				do_regs = FALSE;
				break;
			case 'l': case 'L':
				do_lrot = FALSE;
				break;
			case 'v': case 'V':
				fprintf(stderr, "%s\n", Version);
				verbose = TRUE;
				break;
			case 'g': case 'G':
				gflag = TRUE;
				break;
			case 'O': case 'z': case 'Z':
				/*
				 * When options are received from 'cc' they
				 * look like "-Oxxx", so just ignore the 'O'.
				 */
				break;
			default:
				usage();
				break;
			}
		}
		argv++;
		argc--;
	}

	if (argc > 3)
		usage();

	if (argc > 1) {
		if (strcmp(argv[1], "-") == 0)
			ifp = stdin;
		else if ((ifp = fopen(argv[1], "r")) == NULL) {
			fprintf(stderr, "top: can't open input file '%s'\n",
				argv[1]);
			exit(1);
		}
		if (argc > 2) {
			if (strcmp(argv[2], "-") == 0)
				ofp = stdout;
			else if ((ofp = fopen(argv[2], "w")) == NULL) {
				fprintf(stderr, "top: can't open output file '%s'\n",
					argv[2]);
				exit(1);
			}
		} else {
			if ((ofp = fopen(TMPFILE, "w")) == NULL) {
				fprintf(stderr, "top: can't create temp file\n");
				exit(1);
			}
			use_temp = TRUE;
		}
	} else
		usage();

	dofile();

	if (verbose) {
		if (do_peep) {
			fprintf(stderr, "Peephole changes (1): %4d\n", s_peep1);
			fprintf(stderr, "Peephole changes (2): %4d\n", s_peep2);
			fprintf(stderr, "Peephole changes (3): %4d\n", s_peep3);
			fprintf(stderr, "Instructions deleted: %4d\n", s_idel);
		}
		if (do_regs)
			fprintf(stderr, "Variables registered: %4d\n", s_reg);
		if (do_lrot)
			fprintf(stderr, "Loop rotations      : %4d\n", s_lrot);
		if (do_brev)
			fprintf(stderr, "Branch reversals    : %4d\n", s_brev);
		fprintf(stderr, "Branches removed    : %4d\n", s_bdel - s_badd);
	}

	/*
	 * If we're overwriting the original file, remove the old
	 * version, and rename the temp file to the old name.
	 */
	if (use_temp) {
		remove(argv[1]);
		rename(TMPFILE, argv[1]);
	}

	exit(0);
}

dofile()
{
	if (!readline())
		return;

	while (dofunc())
		;
}
