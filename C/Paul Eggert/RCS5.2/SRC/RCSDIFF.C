/*
 *                     RCS rcsdiff operation
 */
/*****************************************************************************
 *                       generate difference between RCS revisions
 *****************************************************************************
 */

/* Copyright (C) 1982, 1988, 1989 Walter Tichy
   Copyright 1990 by Paul Eggert
   Distributed under license by the Free Software Foundation, Inc.

This file is part of RCS.

RCS is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

RCS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RCS; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

Report problems and direct all questions to:

    rcs-bugs@cs.purdue.edu

*/




/* $Log: rcsdiff.c,v $
 * Revision 5.10  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.9  91/01/30  12:02:44  apratt
 * Changed RCS5AKP1 to RCS5AP1
 * 
 * Revision 5.8  91/01/29  17:45:50  apratt
 * Added RCS5AKP1 to usage message, and bugfix: close if can not getfworkstat
 * 
 * Revision 5.7  90/12/13  06:54:07  eggert
 * checked in with -k by apratt at 91.01.10.13.15.08.
 * 
 * Revision 5.7  1990/12/13  06:54:07  eggert
 * GNU diff 1.15 has -u.
 *
 * Revision 5.6  1990/11/01  05:03:39  eggert
 * Remove unneeded setid check.
 *
 * Revision 5.5  1990/10/04  06:30:19  eggert
 * Accumulate exit status across files.
 *
 * Revision 5.4  1990/09/27  01:31:43  eggert
 * Yield 1, not EXIT_FAILURE, when diffs are found.
 *
 * Revision 5.3  1990/09/11  02:41:11  eggert
 * Simplify -kkvl test.
 *
 * Revision 5.2  1990/09/04  17:07:19  eggert
 * Diff's argv was too small by 1.
 *
 * Revision 5.1  1990/08/29  07:13:55  eggert
 * Add -kkvl.
 *
 * Revision 5.0  1990/08/22  08:12:46  eggert
 * Add -k, -V.  Don't use access().  Add setuid support.
 * Remove compile-time limits; use malloc instead.
 * Don't pass arguments with leading '+' to diff; GNU DIFF treats them as options.
 * Add GNU diff's flags.  Make lock and temp files faster and safer.
 * Ansify and Posixate.
 *
 * Revision 4.6  89/05/01  15:12:27  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.5  88/08/09  19:12:41  eggert
 * Use execv(), not system(); yield exit status like diff(1)s; allow cc -R.
 * 
 * Revision 4.4  87/12/18  11:37:46  narten
 * changes Jay Lepreau made in the 4.3 BSD version, to add support for
 * "-i", "-w", and "-t" flags and to permit flags to be bundled together,
 * merged in.
 * 
 * Revision 4.3  87/10/18  10:31:42  narten
 * Updating version numbers. Changes relative to 1.1 actually
 * relative to 4.1
 * 
 * Revision 1.3  87/09/24  13:59:21  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:22:15  jenkins
 * Port to suns
 * 
 * Revision 4.1  83/05/03  22:13:19  wft
 * Added default branch, option -q, exit status like diff.
 * Added fterror() to replace faterror().
 * 
 * Revision 3.6  83/01/15  17:52:40  wft
 * Expanded mainprogram to handle multiple RCS files.
 *
 * Revision 3.5  83/01/06  09:33:45  wft
 * Fixed passing of -c (context) option to diff.
 *
 * Revision 3.4  82/12/24  15:28:38  wft
 * Added call to catchsig().
 *
 * Revision 3.3  82/12/10  16:08:17  wft
 * Corrected checking of return code from diff; improved error msgs.
 *
 * Revision 3.2  82/12/04  13:20:09  wft
 * replaced getdelta() with gettree(). Changed diagnostics.
 *
 * Revision 3.1  82/11/28  19:25:04  wft
 * Initial revision.
 *
 */
#include "rcsbase.h"

#if DIFF_L
static const char *setup_label P((struct buf*,const char*,const char[datesize]));
#endif
static void cleanup P((void));

static const char co[] = CO;

static int exitstatus;

mainProg(rcsdiffId, "rcsdiff", "$Id: rcsdiff.c,v 5.10 1991/01/30 14:21:32 apratt Exp $")
{
    static const char cmdusage[] =
	    "\nRCS5AP1 as modified for TOS by Allan Pratt, atari!apratt\nrcsdiff usage: rcsdiff [-q] [-rrev1 [-rrev2]] [-Vn] [diff options] file ...";
    static const char quietarg[] = "-q";

    int  revnums;                 /* counter for revision numbers given */
    const char *rev1, *rev2;	/* revision numbers from command line */
    const char *xrev1, *xrev2;	/* expanded revision numbers */
    const char *expandarg, *lexpandarg, *versionarg;
#if DIFF_L
    static struct buf labelbuf[2];
    int file_labels;
    const char **diff_label1, **diff_label2;
    char date2[datesize];
#endif
    const char **diffv, **diffp;	/* argv for subsidiary diff */
    const char **pp, *p, *diffvstr;
    struct buf commarg;
    struct buf numericrev;	/* expanded revision number */
    struct hshentries *gendeltas;	/* deltas to be generated */
    struct hshentry * target;
    int  exit_stats;
    char *argp, *dcp;
    register c;

    initid();
    catchints();

    bufautobegin(&commarg);
    bufautobegin(&numericrev);
    revnums = 0;
    rev1 = rev2 = xrev2 = nil;
#if DIFF_L
    file_labels = 0;
#endif
    expandarg = versionarg = quietarg; /* i.e. a no-op */

    /* Room for args + 2 i/o [+ 2 labels] + 1 file + 1 trailing null.  */
    diffp = diffv = tnalloc(const char*, argc + 4 + 2*DIFF_L);
    *diffp++ = nil;
    *diffp++ = nil;
    *diffp++ = DIFF;

    while (--argc,++argv, argc>=1 && ((*argv)[0] == '-')) {
	dcp = argp = *argv + 1;
	while (c = *argp++) switch (c) {
	    case 'r':
		    if (*argp!='\0') {
			if (revnums==0) {
				rev1= argp; revnums=1;
			} else if (revnums==1) {
				rev2= argp; revnums=2;
			} else {
				faterror("too many revision numbers");
			}
		    } /* do nothing for empty -r */
		    goto option_handled;
#if DIFF_L
	    case 'L':
		    if (++file_labels == 2)
			faterror("too many -L options");
		    /* fall into */
#endif
	    case 'C': case 'D': case 'F': case 'I':
		    *dcp++ = c;
		    if (*argp)
			do *dcp++ = *argp;
			while (*++argp);
		    else {
			if (!--argc)
			    faterror("-%c needs following argument%s",
				    c, cmdusage
			    );
			*diffp++ = *argv++;
		    }
		    break;
	    case 'B': case 'H': case 'T':
	    case '0': case '1': case '2': case '3': case '4':
	    case '5': case '6': case '7': case '8': case '9':
	    case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
	    case 'h': case 'i': case 'n': case 'p':
	    case 't': case 'u': case 'w':
		    *dcp++ = c;
		    break;
	    case 'q':
		    quietflag=true;
		    break;
	    case 'V':
		    versionarg = *argv;
		    setRCSversion(versionarg);
		    goto option_handled;
	    case 'k':
		    expandarg = *argv;
		    if (0 <= str2expmode(expandarg+2))
			goto option_handled;
		    /* fall into */
	    default:
		    faterror("unknown option: %s%s", *argv, cmdusage);
	    };
      option_handled:
	if (dcp != *argv+1) {
	    *dcp = 0;
	    *diffp++ = *argv;
	}
    } /* end of option processing */

    if (argc<1) faterror("no input file%s", cmdusage);

    for (pp = diffv+3, c = 0;  pp<diffp;  )
	    c += strlen(*pp++) + 1;
    diffvstr = argp = tnalloc(char, c + 1);
    for (pp = diffv+3;  pp<diffp;  ) {
	    p = *pp++;
	    *argp++ = ' ';
	    while ((*argp = *p++))
		    argp++;
    }
    *argp = 0;

#if DIFF_L
    diff_label1 = diff_label2 = nil;
    if (file_labels < 2) {
	    if (!file_labels)
		    diff_label1 = diffp++;
	    diff_label2 = diffp++;
    }
#endif
    diffp[2] = nil;

    /* now handle all filenames */
    do {
	    finptr=NULL;
	    ffree();

	    if (pairfilenames(argc, argv, rcsreadopen, true, false) != 1)
		    continue;
	    diagnose("===================================================================\nRCS file: %s\n",RCSfilename);
	    if (!rev2) {
		/* Make sure work file is readable, and get its status.  */
		if ((c = open(workfilename,O_RDONLY,0)) < 0) {
		    eerror(workfilename);
		    continue;
		}
		if (!getfworkstat(c))
#if AKP_BUGFIXES
			{ VOID close(c); continue; }
#else
			continue;
#endif
		VOID close(c);
	    }


	    gettree(); /* reads in the delta tree */

	    if (Head==nil) {
		    error("no revisions present");
		    continue;
	    }
	    if (revnums==0)
		    rev1  =  Dbranch ? Dbranch : Head->num;

	    if (!expandsym(rev1,&numericrev)) continue;
	    if (!(target=genrevs(numericrev.string,(char *)nil,(char *)nil,(char *)nil,&gendeltas))) continue;
	    xrev1=target->num;
#if DIFF_L
	    if (diff_label1)
		*diff_label1 = setup_label(&labelbuf[0], target->num, target->date);
#endif

	    lexpandarg = expandarg;
	    if (revnums==2) {
		    if (!expandsym(rev2, &numericrev)) continue;
		    if (!(target=genrevs(numericrev.string,(char *)nil,(char *)nil,(char *)nil,&gendeltas))) continue;
		    xrev2=target->num;
	    } else if (
			target->lockedby
		&&	lexpandarg == quietarg
		&&	Expand == KEYVAL_EXPAND
		&&	WORKMODE(RCSstat.st_mode,true) == workstat.st_mode
	    )
		    lexpandarg = "-kkvl";
#if DIFF_L
	    if (diff_label2)
		if (revnums == 2)
		    *diff_label2 = setup_label(&labelbuf[1], target->num, target->date);
		else {
		    time2date(workstat.st_mtime, date2);
		    *diff_label2 = setup_label(&labelbuf[1], workfilename, date2);
		}
#endif

	    diffp[0] = maketemp(0);
	    diagnose("retrieving revision %s\n", xrev1);
	    bufscpy(&commarg, "-p");
	    bufscat(&commarg, xrev1);
	    if (run((char*)nil,diffp[0], co,quietarg,commarg.string,lexpandarg,versionarg,RCSfilename,(char*)nil)){
		    error("co failed");
		    continue;
	    }
	    if (!rev2) {
		    diffp[1] = workfilename;
		    if (workfilename[0] == '+') {
			    /* Some diffs have options with leading '+'. */
			    diffp[1] = argp =
				    ftnalloc(char, strlen(workfilename)+3);
			    *argp++ = '.';
			    *argp++ = SLASH;
			    VOID strcpy(argp, workfilename);
		    }
	    } else {
		    diffp[1] = maketemp(1);
		    diagnose("retrieving revision %s\n",xrev2);
		    bufscpy(&commarg, "-p");
		    bufscat(&commarg, xrev2);
		    if (run((char*)nil,diffp[1], co,quietarg,commarg.string,expandarg,versionarg,RCSfilename,(char *)nil)){
			    error("co failed");
			    continue;
		    }
	    }
	    if (!rev2)
		    diagnose("diff%s -r%s %s\n", diffvstr, xrev1, workfilename);
	    else
		    diagnose("diff%s -r%s -r%s\n", diffvstr, xrev1, xrev2);

	    exit_stats = runv(diffv);

	    if (exit_stats)
		    if (WIFEXITED(exit_stats) && WEXITSTATUS(exit_stats)==1) {
			    if (!exitstatus)
				    exitstatus = 1;
		    } else
			    error("diff failed");
    } while (cleanup(),
	     ++argv, --argc >=1);


    tempunlink();
    exitmain(exitstatus);
}

    static void
cleanup()
{
    if (nerror) exitstatus = EXIT_TROUBLE;
    if (finptr) ffclose(finptr);
}

#if lint
#	define exiterr rdiffExit
#endif
    exiting void
exiterr()
{
    tempunlink();
    _exit(EXIT_TROUBLE);
}

#if DIFF_L
	static const char *
setup_label(b, name, date)
	struct buf *b;
	const char *name;
	const char date[datesize];
{
	const char *p;

	bufalloc(b,  2+strlen(name)+1+datesize);
	for (p = date;  *p++ != '.';  )
		;
	VOID sprintf(b->string, "-L%s\t%s%.*s/%.2s/%.2s %.2s:%.2s:%s",
		name,
		date[2]=='.' ? "19" : "",
		p-date-1, date, p, p+3, p+6, p+9, p+12
	);
	return b->string;
}
#endif
