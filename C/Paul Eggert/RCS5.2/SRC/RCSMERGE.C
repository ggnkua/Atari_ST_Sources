/*
 *                       rcsmerge operation
 */
/*****************************************************************************
 *                       join 2 revisions with respect to a third
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



/* $Log: rcsmerge.c,v $
 * Revision 5.4  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.3  90/11/01  05:03:50  eggert
 * checked in with -k by apratt at 91.01.10.13.15.26.
 * 
 * Revision 5.3  1990/11/01  05:03:50  eggert
 * Remove unneeded setid check.
 *
 * Revision 5.2  1990/09/04  08:02:28  eggert
 * Check for I/O error when reading working file.
 *
 * Revision 5.1  1990/08/29  07:14:04  eggert
 * Add -q.  Pass -L options to merge.
 *
 * Revision 5.0  1990/08/22  08:13:41  eggert
 * Propagate merge's exit status.
 * Remove compile-time limits; use malloc instead.
 * Make lock and temp files faster and safer.  Ansify and Posixate.  Add -V.
 * Don't use access().  Tune.
 *
 * Revision 4.5  89/05/01  15:13:16  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.4  88/08/09  19:13:13  eggert
 * Beware merging into a readonly file.
 * Beware merging a revision to itself (no change).
 * Use execv(), not system(); yield exit status like diff(1)'s.
 * 
 * Revision 4.3  87/10/18  10:38:02  narten
 * Updating version numbers. Changes relative to version 1.1 
 * actually relative to 4.1
 * 
 * Revision 1.3  87/09/24  14:00:31  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:22:36  jenkins
 * Port to suns
 * 
 * Revision 4.1  83/03/28  11:14:57  wft
 * Added handling of default branch.
 * 
 * Revision 3.3  82/12/24  15:29:00  wft
 * Added call to catchsig().
 *
 * Revision 3.2  82/12/10  21:32:02  wft
 * Replaced getdelta() with gettree(); improved error messages.
 *
 * Revision 3.1  82/11/28  19:27:44  wft
 * Initial revision.
 *
 */
#include "rcsbase.h"

static exiting void nowork P((void));

static const char co[] = CO;

mainProg(rcsmergeId, "rcsmerge", "$Id: rcsmerge.c,v 5.4 1991/01/30 14:21:32 apratt Exp $")
{
	static const char cmdusage[] =
		"\nrcsmerge usage: rcsmerge -rrev1 [-rrev2] [-p] [-Vn] file";
	static const char quietarg[] = "-q";

	const char *rev1, *rev2; /*revision numbers*/
	const char *temp1file, *temp2file;
	const char *expandarg, *versionarg;
	const char *mergearg[13], **a;
        int tostdout;
	int status, workfd;
	struct buf commarg;
	struct buf numericrev; /* holds expanded revision number */
	struct hshentries *gendeltas; /* deltas to be generated */
        struct hshentry * target;

	initid();
        catchints();

	bufautobegin(&commarg);
	bufautobegin(&numericrev);
	rev1 = rev2 = nil;
	status = 0; /* Keep lint happy.  */
	tostdout = false;
	expandarg = versionarg = quietarg; /* i.e. a no-op */

        while (--argc,++argv, argc>=1 && ((*argv)[0] == '-')) {
                switch ((*argv)[1]) {
                case 'p':
                        tostdout=true;
			goto revno;
		case 'q':
			quietflag = true;
                        /* falls into -r */
                case 'r':
		revno:
                        if ((*argv)[2]!='\0') {
			    if (!rev1)
				    rev1 = *argv + 2;
			    else if (!rev2)
				    rev2 = *argv + 2;
			    else
                                    faterror("too many revision numbers");
                        } /* do nothing for empty -r or -p */
                        break;
		case 'V':
			versionarg = *argv;
			setRCSversion(versionarg);
			break;

		case 'k':
			expandarg = *argv;
			if (0 <= str2expmode(expandarg+2))
			    break;
			/* fall into */
                default:
			faterror("unknown option: %s%s", *argv, cmdusage);
                };
        } /* end of option processing */

	if (argc<1) faterror("no input file%s", cmdusage);
	if (!rev1) faterror("no base revision number given");

        /* now handle all filenames */

	if (pairfilenames(argc, argv, rcsreadopen, true, false) == 1) {

                if (argc>2 || (argc==2&&argv[1]!=nil))
                        warn("too many arguments");
		diagnose("RCS file: %s\n", RCSfilename);
		if ((workfd = open(workfilename, tostdout?O_RDONLY:O_RDWR)) < 0)
			nowork();

                gettree();  /* reads in the delta tree */

                if (Head==nil) faterror("no revisions present");


		if (!expandsym(rev1,&numericrev)) goto end;
		if (!(target=genrevs(numericrev.string, (char *)nil, (char *)nil, (char *)nil,&gendeltas))) goto end;
                rev1=target->num;
		if (!rev2)
			rev2  =  Dbranch ? Dbranch : Head->num;
		if (!expandsym(rev2,&numericrev)) goto end;
		if (!(target=genrevs(numericrev.string, (char *)nil, (char *)nil, (char *)nil,&gendeltas))) goto end;
                rev2=target->num;

		if (strcmp(rev1,rev2) == 0) {
			error("merging revision %s to itself (no change)",
				rev1
			);
			if (tostdout) {
				FILE *w;
				errno = 0;
				if (!(w = fdopen(workfd,"r")))
					nowork();
				fastcopy(w,stdout);
				ffclose(w);
			}
			goto end;
		}
		if (close(workfd) < 0)
			nowork();

		temp1file = maketemp(0);
		temp2file = maketemp(1);

		diagnose("retrieving revision %s\n", rev1);
		bufscpy(&commarg, "-p");
		bufscat(&commarg, rev1);
		if (run((char*)nil,temp1file, co,quietarg,commarg.string,expandarg,versionarg,RCSfilename,(char*)nil)){
                        faterror("co failed");
                }
		diagnose("retrieving revision %s\n",rev2);
		bufscpy(&commarg, "-p");
		bufscat(&commarg, rev2);
		if (run((char*)nil,temp2file, co,quietarg,commarg.string,expandarg,versionarg,RCSfilename,(char*)nil)){
                        faterror("co failed");
                }
		diagnose("Merging differences between %s and %s into %s%s\n",
                         rev1, rev2, workfilename,
                         tostdout?"; result to stdout":"");

		a = mergearg;
		*a++ = nil;
		*a++ = nil;
		*a++ = MERGE;
		if (tostdout)
		    *a++ = "-p";
		if (quietflag)
		    *a++ = quietarg;
		*a++ = "-L";  *a++ = workfilename;
		*a++ = "-L";  *a++ = rev2;
		*a++ = workfilename;
		*a++ = temp1file;
		*a++ = temp2file;
		*a = nil;

		status = runv(mergearg);
		if (!WIFEXITED(status)  ||  1 < WEXITSTATUS(status)) {
                        faterror("merge failed");
                }
        }

end:
	tempunlink();
	exitmain(nerror ? EXIT_TROUBLE : WEXITSTATUS(status));
}

#if lint
#	define exiterr rmergeExit
#endif
	exiting void
exiterr()
{
	tempunlink();
	_exit(EXIT_TROUBLE);
}


	static exiting void
nowork()
{
	efaterror(workfilename);
}
