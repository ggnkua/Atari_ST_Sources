/*
 * $Header: arc.c,v 1.13 88/11/01 02:22:23 hyc Exp $
 */

/*  ARC - Archive utility
  
    Version 5.21, created on 04/22/87 at 15:05:21
  
(C) COPYRIGHT 1985-87 by System Enhancement Associates; ALL RIGHTS RESERVED
  
    By:	 Thom Henderson
  
    Description:
	 This program is a general archive utility, and is used to maintain
	 an archive of files.  An "archive" is a single file that combines
	 many files, reducing storage space and allowing multiple files to
	 be handled as one.
  
    Instructions:
	 Run this program with no arguments for complete instructions.
  
    Programming notes:
	 ARC Version 2 differs from version 1 in that archive entries
	 are automatically compressed when they are added to the archive,
	 making a separate compression step unecessary.	 The nature of the
	 compression is indicated by the header version number placed in
	 each archive entry, as follows:
  
	 1 = Old style, no compression
	 2 = New style, no compression
	 3 = Compression of repeated characters only
	 4 = Compression of repeated characters plus Huffman SQueezing
	 5 = Lempel-Zev packing of repeated strings (old style)
	 6 = Lempel-Zev packing of repeated strings (new style)
	 7 = Lempel-Zev Williams packing with improved hash function
	 8 = Dynamic Lempel-Zev packing with adaptive reset
	 9 = Dynamic Lempel-Zev packing, larger hash table
  
	 Type 5, Lempel-Zev packing, was added as of version 4.0
  
	 Type 6 is Lempel-Zev packing where runs of repeated characters
	 have been collapsed, and was added as of version 4.1
  
	 Type 7 is a variation of Lempel-Zev using a different hash
	 function which yields speed improvements of 20-25%, and was
	 added as of version 4.6
  
	 Type 8 is a different implementation of Lempel-Zev, using a
	 variable code size and an adaptive block reset, and was added
	 as of version 5.0
  
	 Type 9 is a slight modification of type 8, first used by Phil
	 Katz in his PKARC utilites. The primary difference is the use
	 of a hash table twice as large as for type 8, and that this
	 algorithm called Squashing, doesn't perform run-length encoding
	 on the input data.
  
	 Verion 4.3 introduced a temporary file for holding the result
	 of the first crunch pass, thus speeding up crunching.
  
	 Version 4.4 introduced the ARCTEMP environment string, so that
	 the temporary crunch file may be placed on a ramdisk.	Also
	 added was the distinction bewteen Adding a file in all cases,
	 and Updating a file only if the disk file is newer than the
	 corresponding archive entry.
  
	 The compression method to use is determined when the file is
	 added, based on whichever method yields the smallest result.
  
    Language:
	 Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

#if	UNIX
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifndef __STDC__
int		strlen();
#endif
void		addarc(), delarc(), extarc(), lstarc(), tstarc(), cvtarc(), runarc();
void		abort();
static	void	expandlst();
#if	MTS
void		etoa();
#endif
#if	GEMDOS
long		_stksize = 65536L;
#endif
#ifndef __STDC__
char		*strcpy(), *strcat();
#endif
char		*makefnam();	/* filename fixup routine */

static char   **lst;		/* files list */
static int	lnum;		/* length of files list */

main(num, arg)			/* system entry point */
	int		num;	/* number of arguments */
	char	       *arg[];	/* pointers to arguments */
{
	char		opt = 0;/* selected action */
	char	       *a;	/* option pointer */
	void		upper();/* case conversion routine */
#ifndef __STDC__
	char	       *index();/* string index utility */
#endif
	char	       *envfind();	/* environment searcher */
	int		n;	/* index */
	char	       *arctemp2;
#ifndef __STDC__
	char		*calloc(), *mktemp();
#endif
#if	GEMDOS
	void		exitpause();
	int		append;
#endif
#if	MTS
	fortran void	guinfo();
	char		gotinf[4];
#endif
#if	UNIX
	struct	stat	sbuf;
#endif

	if (num < 3) {
		printf("ARC - Archive utility, Version 5.21, created on 04/22/87 at 15:05:21\n");
/*		printf("(C) COPYRIGHT 1985,86,87 by System Enhancement Associates;");
		printf(" ALL RIGHTS RESERVED\n\n");
		printf("Please refer all inquiries to:\n\n");
		printf("       System Enhancement Associates\n");
		printf("       21 New Street, Wayne NJ 07470\n\n");
		printf("You may copy and distribute this program freely,");
		printf(" provided that:\n");
		printf("    1)	 No fee is charged for such copying and");
		printf(" distribution, and\n");
		printf("    2)	 It is distributed ONLY in its original,");
		printf(" unmodified state.\n\n");
		printf("If you like this program, and find it of use, then your");
		printf(" contribution will\n");
		printf("be appreciated.	 You may not use this product in a");
		printf(" commercial environment\n");
		printf("or a governmental organization without paying a license");
		printf(" fee of $35.  Site\n");
		printf("licenses and commercial distribution licenses are");
		printf(" available.  A program\n");
		printf("disk and printed documentation are available for $50.\n");
		printf("\nIf you fail to abide by the terms of this license, ");
		printf(" then your conscience\n");
		printf("will haunt you for the rest of your life.\n\n"); */
#if	MSDOS
		printf("Usage: ARC {amufdxerplvtc}[bswnoq][g<password>]");
#endif
#if	GEMDOS
		printf("Usage: ARC {amufdxerplvtc}[bhswnoq][g<password>]");
#endif
#if	UNIX
		printf("Usage: arc {amufdxerplvtc}[biswnoq][g<password>]");
#endif
#if	MTS
		printf("Parameters: {amufdxeplvtc}[biswnoq][g<password>]");
#endif
		printf(" <archive> [<filename> . . .]\n");
		printf("Where:	 a   = add files to archive\n");
		printf("	 m   = move files to archive\n");
		printf("	 u   = update files in archive\n");
		printf("	 f   = freshen files in archive\n");
		printf("	 d   = delete files from archive\n");
		printf("	 x,e = extract files from archive\n");
#if	!MTS
		printf("	 r   = run files from archive\n");
#endif
		printf("	 p   = copy files from archive to");
		printf(" standard output\n");
		printf("	 l   = list files in archive\n");
		printf("	 v   = verbose listing of files in archive\n");
		printf("	 t   = test archive integrity\n");
		printf("	 c   = convert entry to new packing method\n");
		printf("	 b   = retain backup copy of archive\n");
#if	GEMDOS
		printf("	 h   = hold screen after finishing\n");
#endif
#if	MTS
		printf("	 i   = suppress ASCII/EBCDIC translation\n");
#endif
#if	UNIX
		printf("	 i   = suppress image mode (translate EOL)\n");
#endif
		printf("	 s   = suppress compression (store only)\n");
		printf("	 w   = suppress warning messages\n");
		printf("	 n   = suppress notes and comments\n");
		printf("	 o   = overwrite existing files when");
		printf(" extracting\n");
		printf("	 q   = squash instead of crunching\n");
		printf("	 g   = Encrypt/decrypt archive entry\n");
		printf("\nAdapted from MSDOS by Howard Chu\n");
		/*
		 * printf("\nPlease refer to the program documentation for");
		 * printf(" complete instructions.\n"); 
		 */
#if	GEMDOS
		exitpause();
#endif
		return 1;
	}
	/* see where temp files go */
#if	!MTS
	arctemp = calloc(1, STRLEN);
	if (!(arctemp2 = envfind("ARCTEMP")))
		arctemp2 = envfind("TMPDIR");
	if (arctemp2) {
		strcpy(arctemp, arctemp2);
		n = strlen(arctemp);
		if (arctemp[n - 1] != CUTOFF)
			arctemp[n] = CUTOFF;
	}
#if	UNIX
	else	strcpy(arctemp, "/tmp/");
#endif
#if	!MSDOS
	{
		static char tempname[] = "AXXXXXX";
		strcat(arctemp, mktemp(tempname));
	}
#else
	strcat(arctemp, "$ARCTEMP");
	arctemp2 = NULL;
#endif
#else
	guinfo("SHFSEP	", gotinf);
	sepchr[0] = gotinf[0];
	guinfo("SCRFCHAR", gotinf);
	tmpchr[0] = gotinf[0];
	arctemp = "-$$$";
	arctemp[0] = tmpchr[0];
#endif

#if	!UNIX
	/* avoid any case problems with arguments */

	for (n = 1; n < num; n++)	/* for each argument */
		upper(arg[n]);	/* convert it to uppercase */
#else
	/* avoid case problems with command options */
	upper(arg[1]);		/* convert to uppercase */
#endif

	/* create archive names, supplying defaults */
#if	UNIX
	if (!stat(arg[2],&sbuf)) {
		if ((sbuf.st_mode & S_IFMT) == S_IFDIR)
			makefnam(arg[2],".arc",arcname);
		else
			strcpy(arcname,arg[2]);
	} else
		makefnam(arg[2],".arc",arcname);
#else
	makefnam(arg[2], ".ARC", arcname);
#endif
	/* makefnam(".$$$",arcname,newname); */
	sprintf(newname, "%s.arc", arctemp);
	makefnam(".BAK", arcname, bakname);

	/* now scan the command and see what we are to do */

	for (a = arg[1]; *a; a++) {	/* scan the option flags */
#if	!MTS
		if (index("AMUFDXEPLVTCR", *a)) {	/* if a known command */
#else
		if (index("AMUFDXEPLVTC", *a)) {
#endif
			if (opt)/* do we have one yet? */
				abort("Cannot mix %c and %c", opt, *a);
			opt = *a;	/* else remember it */
		} else if (*a == 'B')	/* retain backup copy */
			keepbak = 1;

		else if (*a == 'W')	/* suppress warnings */
			warn = 0;
#if	!DOS
		else if (*a == 'I')	/* image mode, no ASCII/EBCDIC x-late */
			image = !image;
#endif
#if	GEMDOS
		else if (*a == 'H')	/* pause before exit */
			hold = 1;
#endif

		else if (*a == 'N')	/* suppress notes and comments */
			note = 0;

		else if (*a == 'O')	/* overwrite file on extract */
			overlay = 1;

		else if (*a == 'G') {	/* garble */
			password = a + 1;
			while (*a)
				a++;
			a--;
#if	MTS
			etoa(password, strlen(password));
#endif
		} else if (*a == 'S')	/* storage kludge */
			nocomp = 1;

		else if (*a == 'K')	/* special kludge */
			kludge = 1;

		else if (*a == 'Q')	/* use squashing */
			dosquash = 1;

		else if (*a == '-' || *a == '/')	/* UNIX and PC-DOS
							 * option markers */
			;

		else
			abort("%c is an unknown command", *a);
	}

	if (!opt)
		abort("I have nothing to do!");

	/* get the files list set up */

	lnum = num - 3;		/* initial length of list */
	lst = (char **) calloc((lnum==0) ? 1:lnum,
				 sizeof(char *));	/* initial list */
	for (n = 3; n < num; n++)
		lst[n - 3] = arg[n];

	for (n = 0; n < lnum;) {/* expand indirect references */
		if (*lst[n] == '@')
			expandlst(n);
#if	GEMDOS		/* redirect stdout from the desktop...*/
		else if (*lst[n] == '>') {
			arctemp2 = (++lst[n]);
			lst[n] = lst[lnum-1];	/* delete this entry */
			lnum--;
			if (arctemp2[0] == '>') {
				append = 1;
				arctemp2++;
			}
			else	append = 0;
		}
#endif
		else
			n++;
	}
#if	GEMDOS
	if (arctemp2)
		freopen(arctemp2,append ? "a" : "w",stdout);
#endif

	/* act on whatever action command was given */

	switch (opt) {		/* action depends on command */
	case 'A':		/* Add */
	case 'M':		/* Move */
	case 'U':		/* Update */
	case 'F':		/* Freshen */
		addarc(lnum, lst, (opt == 'M'), (opt == 'U'), (opt == 'F'));
		break;

	case 'D':		/* Delete */
		delarc(lnum, lst);
		break;

	case 'E':		/* Extract */
	case 'X':		/* eXtract */
	case 'P':		/* Print */
		extarc(lnum, lst, (opt == 'P'));
		break;

	case 'V':		/* Verbose list */
		bose = 1;
	case 'L':		/* List */
		lstarc(lnum, lst);
		break;

	case 'T':		/* Test */
		tstarc();
		break;

	case 'C':		/* Convert */
		cvtarc(lnum, lst);
		break;
#if	!MTS
	case 'R':		/* Run */
		runarc(lnum, lst);
		break;
#endif
	default:
		abort("I don't know how to do %c yet!", opt);
	}
#if	GEMDOS
	if (hold)
		exitpause();
#endif
	return nerrs;
}
static	void
expandlst(n)			/* expand an indirect reference */
	int		n;	/* number of entry to expand */
{
	FILE	       *lf;	/* list file, opener */
#ifndef __STDC__
	FILE	       *fopen();
	char	       *malloc(), *realloc();	/* memory managers */
#endif
	char		buf[100];	/* input buffer */
	int		x;	/* index */
	char	       *p = lst[n] + 1; /* filename pointer */

	if (*p) {		/* use name if one was given */
		makefnam(p, ".CMD", buf);
		if (!(lf = fopen(buf, "r")))
			abort("Cannot read list of files in %s", buf);
	} else
		lf = stdin;	/* else use standard input */

	for (x = n + 1; x < lnum; x++)	/* drop reference from the list */
		lst[x - 1] = lst[x];
	lnum--;

	while (fscanf(lf, "%99s", buf) > 0) {	/* read in the list */
		if (!(lst =(char **)realloc(lst, (lnum + 1) * sizeof(char *))))
			abort("too many file references");

		lst[lnum] = malloc(strlen(buf) + 1);
		strcpy(lst[lnum], buf); /* save the name */
		lnum++;
	}

	if (lf != stdin)	/* avoid closing standard input */
		fclose(lf);
}
