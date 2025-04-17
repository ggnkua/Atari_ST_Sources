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

/*
 *                     RCS checkin operation
 */
/*******************************************************************
 *                       check revisions into RCS files
 *******************************************************************
 */



/* $Log: ci.c,v $
 * Revision 5.16  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.15  91/01/30  12:02:28  apratt
 * Changed RCS5AKP1 to RCS5AP1
 * 
 * Revision 5.14  91/01/29  17:45:16  apratt
 * Added RCS5AKP1 to usage message
 * 
 * Revision 5.13  91/01/16  15:43:44  apratt
 * This version works passably on the ST.
 * 
 * Revision 5.12  1990/12/31  01:00:12  eggert
 * Don't use uninitialized storage when handling -{N,n}.
 *
 * Revision 5.11  1990/12/04  05:18:36  eggert
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.10  1990/11/05  20:30:10  eggert
 * Don't remove working file when aborting due to no changes.
 *
 * Revision 5.9  1990/11/01  05:03:23  eggert
 * Add -I and new -t behavior.  Permit arbitrary data in logs.
 *
 * Revision 5.8  1990/10/04  06:30:09  eggert
 * Accumulate exit status across files.
 *
 * Revision 5.7  1990/09/25  20:11:46  hammer
 * fixed another small typo
 *
 * Revision 5.6  1990/09/24  21:48:50  hammer
 * added cleanups from Paul Eggert.
 *
 * Revision 5.5  1990/09/21  06:16:38  hammer
 * made it handle multiple -{N,n}'s.  Also, made it treat re-directed stdin
 * the same as the terminal
 *
 * Revision 5.4  1990/09/20  02:38:51  eggert
 * ci -k now checks dates more thoroughly.
 *
 * Revision 5.3  1990/09/11  02:41:07  eggert
 * Fix revision bug with `ci -k file1 file2'.
 *
 * Revision 5.2  1990/09/04  08:02:10  eggert
 * Permit adjacent revisions with identical time stamps (possible on fast hosts).
 * Improve incomplete line handling.  Standardize yes-or-no procedure.
 *
 * Revision 5.1  1990/08/29  07:13:44  eggert
 * Expand locker value like co.  Clean old log messages too.
 *
 * Revision 5.0  1990/08/22  08:10:00  eggert
 * Don't require a final newline.
 * Make lock and temp files faster and safer.
 * Remove compile-time limits; use malloc instead.
 * Permit dates past 1999/12/31.  Switch to GMT.
 * Add setuid support.  Don't pass +args to diff.  Check diff's output.
 * Ansify and Posixate.  Add -k, -V.  Remove snooping.  Tune.
 * Check diff's output.
 *
 * Revision 4.9  89/05/01  15:10:54  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.8  88/11/08  13:38:23  narten
 * changes from root@seismo.CSS.GOV (Super User)
 * -d with no arguments uses the mod time of the file it is checking in
 * 
 * Revision 4.7  88/08/09  19:12:07  eggert
 * Make sure workfile is a regular file; use its mode if RCSfile doesn't have one.
 * Use execv(), not system(); allow cc -R; remove lint.
 * isatty(fileno(stdin)) -> ttystdin()
 * 
 * Revision 4.6  87/12/18  11:34:41  narten
 * lint cleanups (from Guy Harris)
 * 
 * Revision 4.5  87/10/18  10:18:48  narten
 * Updating version numbers. Changes relative to revision 1.1 are actually
 * relative to 4.3
 * 
 * Revision 1.3  87/09/24  13:57:19  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:21:33  jenkins
 * Port to suns
 * 
 * Revision 4.3  83/12/15  12:28:54  wft
 * ci -u and ci -l now set mode of working file properly.
 * 
 * Revision 4.2  83/12/05  13:40:54  wft
 * Merged with 3.9.1.1: added calls to clearerr(stdin).
 * made rewriteflag external.
 * 
 * Revision 4.1  83/05/10  17:03:06  wft
 * Added option -d and -w, and updated assingment of date, etc. to new delta.
 * Added handling of default branches.
 * Option -k generates std. log message; fixed undef. pointer in reading of log.
 * Replaced getlock() with findlock(), link--unlink with rename(),
 * getpwuid() with getcaller().
 * Moved all revision number generation to new routine addelta().
 * Removed calls to stat(); now done by pairfilenames().
 * Changed most calls to catchints() with restoreints().
 * Directed all interactive messages to stderr.
 * 
 * Revision 3.9.1.1  83/10/19  04:21:03  lepreau
 * Added clearerr(stdin) to getlogmsg() for re-reading stdin.
 * 
 * Revision 3.9  83/02/15  15:25:44  wft
 * 4.2 prerelease
 * 
 * Revision 3.9  83/02/15  15:25:44  wft
 * Added call to fastcopy() to copy remainder of RCS file.
 *
 * Revision 3.8  83/01/14  15:34:05  wft
 * Added ignoring of interrupts while new RCS file is renamed;
 * Avoids deletion of RCS files by interrupts.
 *
 * Revision 3.7  82/12/10  16:09:20  wft
 * Corrected checking of return code from diff.
 *
 * Revision 3.6  82/12/08  21:34:49  wft
 * Using DATEFORM to prepare date of checked-in revision;
 * Fixed return from addbranch().
 *
 * Revision 3.5  82/12/04  18:32:42  wft
 * Replaced getdelta() with gettree(), SNOOPDIR with SNOOPFILE. Updated
 * field lockedby in removelock(), moved getlogmsg() before calling diff.
 *
 * Revision 3.4  82/12/02  13:27:13  wft
 * added option -k.
 *
 * Revision 3.3  82/11/28  20:53:31  wft
 * Added mustcheckin() to check for redundant checkins.
 * Added xpandfile() to do keyword expansion for -u and -l;
 * -m appends linefeed to log message if necessary.
 * getlogmsg() suppresses prompt if stdin is not a terminal.
 * Replaced keeplock with lockflag, fclose() with ffclose(),
 * %02d with %.2d, getlogin() with getpwuid().
 *
 * Revision 3.2  82/10/18  20:57:23  wft
 * An RCS file inherits its mode during the first ci from the working file,
 * otherwise it stays the same, except that write permission is removed.
 * Fixed ci -l, added ci -u (both do an implicit co after the ci).
 * Fixed call to getlogin(), added call to getfullRCSname(), added check
 * for write error.
 * Changed conflicting identifiers.
 *
 * Revision 3.1  82/10/13  16:04:59  wft
 * fixed type of variables receiving from getc() (char -> int).
 * added include file dbm.h for getting BYTESIZ. This is used
 * to check the return code from diff portably.
 */

#include "rcsbase.h"

struct Symrev {
       const char *ssymbol;
       int override;
       struct Symrev * nextsym;
};

/* rcsfcmp */
int rcsfcmp P((const char*,const char*,const struct hshentry*));

/* rcskeep */
extern char prevdate[];
extern struct buf prevauthor, prevrev, prevstate;
int getoldkeys P((FILE*));

static const char *xpandfile P((const char*,const char*,const struct hshentry*));
static const char *getdate P((void));
static int addbranch P((struct hshentry*,struct buf*));
static int addelta P((void));
static int mustcheckin P((const char*,const struct hshentry*));
static struct cbuf getlogmsg P((void));
static struct hshentry *removelock P((struct hshentry*));
static void cleanup P((void));
static void incnum P((const char*,struct buf*));
static void addassoclst P((int, char *));

static const char diff[] = DIFF;

static FILE *workptr;			/* working file pointer		*/
static const char *olddeltanum;		/* number of old delta		*/
static struct buf newdelnum;		/* new revision number		*/
static struct cbuf msg;
static int exitstatus;
static int forceciflag;			/* forces check in		*/
static int keepflag, keepworkingfile, rcsinitflag;
static struct hshentries *gendeltas;	/* deltas to be generated	*/
static struct hshentry *targetdelta;	/* old delta to be generated	*/
static struct hshentry newdelta;	/* new delta to be inserted	*/
static struct Symrev *assoclst, *lastassoc;

mainProg(ciId, "ci", "$Id: ci.c,v 5.16 1991/01/30 14:21:32 apratt Exp $")
{
	static const char cmdusage[] =
		"\nRCS5AP1 as modified for TOS by Allan Pratt, atari!apratt\nci usage: ci -{fklqru}[rev] -mmsg -{nN}name -sstate -t[textfile] -Vn file ...";

	char altdate[datesize];
	const char *author, *krev, *rev, *state, *textfile;
	const char *diffilename, *expfilename;
	const char *workdiffname, *newworkfilename;
	int exit_stats;		 /* return code for command invocations     */
	int lockflag;
	int r;
	int usestatdate; /* Use mod time of file for -d.  */
	mode_t newRCSmode; /* mode for RCS file */
	mode_t newworkmode; /* mode for working file */
	struct Symrev *curassoc;
	
	initid();
	catchints();

	author = rev = state = textfile = nil;
	curassoc = assoclst = lastassoc = (struct Symrev *) nil;
	lockflag = false;
	altdate[0]= '\0'; /* empty alternate date for -d */
	usestatdate=false;

        while (--argc,++argv, argc>=1 && ((*argv)[0] == '-')) {
                switch ((*argv)[1]) {

                case 'r':
			keepworkingfile = lockflag = false;
                revno:  if ((*argv)[2]!='\0') {
				if (rev) warn("redefinition of revision number");
                                rev = (*argv)+2;
                        }
                        break;

                case 'l':
                        keepworkingfile=lockflag=true;
                        goto revno;

                case 'u':
                        keepworkingfile=true; lockflag=false;
                        goto revno;

		case 'I':
			interactiveflag = true;
			goto revno;

                case 'q':
                        quietflag=true;
                        goto revno;

                case 'f':
                        forceciflag=true;
                        goto revno;

                case 'k':
                        keepflag=true;
                        goto revno;

                case 'm':
			if (msg.size) redefined('m');
			msg = cleanlogmsg(*argv+2, strlen(*argv+2));
			if (!msg.size)
				warn("missing message for -m option");
                        break;

                case 'n':
			if ((*argv)[2] == '\0') {
                                error("missing symbolic name after -n");
				break;
            		}
           		checksid((*argv)+2);
            		addassoclst(false, (*argv)+2);
		        break;
		
		case 'N':
			if ((*argv)[2] == '\0') {
                                error("missing symbolic name after -N");
				break;
            		}
                	checksid((*argv)+2);
            		addassoclst(true, (*argv)+2);
		        break;

                case 's':
                        if ((*argv)[2]!='\0'){
				if (state) redefined('s');
				checksid((*argv)+2);
                                state = (*argv)+2;
			} else
				warn("missing state for -s option");
                        break;

                case 't':
                        if ((*argv)[2]!='\0'){
				if (textfile) redefined('t');
                                textfile = (*argv)+2;
                        }
                        break;

		case 'd':
			if (altdate[0] || usestatdate)
				redefined('d');
			altdate[0] = 0;
			usestatdate = false;
			if ((*argv)[2])
				str2date(*argv+2, altdate);
			else
				usestatdate = true;
                        break;

		case 'w':
                        if ((*argv)[2]!='\0'){
				if (author) redefined('w');
				checksid((*argv)+2);
				author = (*argv)+2;
			} else
				warn("missing author for -w option");
                        break;

		case 'V':
			setRCSversion(*argv);
			break;



                default:
			faterror("unknown option: %s%s", *argv, cmdusage);
                };
        }  /* end processing of options */

	if (argc<1) faterror("no input file%s", cmdusage);

        /* now handle all filenames */
        do {
        finptr=frewrite=NULL;
	fcopy = foutptr = NULL;
	workptr = NULL;
        targetdelta=nil;
        olddeltanum=nil;
	ffree();

	switch (pairfilenames(argc, argv, rcswriteopen, false, false)) {

        case -1:                /* New RCS file */
		rcsinitflag = true;
                break;

        case 0:                 /* Error */
                continue;

        case 1:                 /* Normal checkin with prev . RCS file */
		rcsinitflag = !Head;
        }

        /* now RCSfilename contains the name of the RCS file, and
         * workfilename contains the name of the working file.
	 * If the RCS file exists, finptr contains the file descriptor for the
         * RCS file. The admin node is initialized.
	 * RCSstat is set.
         */

	diagnose("%s  <--  %s\n", RCSfilename,workfilename);

	errno = 0;
	if (!(workptr = fopen(workfilename,"r"))) {
		eerror(workfilename);
		continue;
	}
	if (!getfworkstat(fileno(workptr))) continue;
	newRCSmode =
		  (rcsinitflag ? workstat.st_mode : RCSstat.st_mode)
		& ~(S_IWUSR|S_IWGRP|S_IWOTH);
	/* newRCSmode also adjusts mode of working file for -u and -l. */
	if (finptr && !checkaccesslist()) continue; /* give up */

	krev = rev;
        if (keepflag) {
                /* get keyword values from working file */
		if (!getoldkeys(workptr)) continue;
		if (!rev  &&  !*(krev = prevrev.string)) {
			error("can't find a revision number in %s",workfilename);
                        continue;
                }
		if (*prevdate=='\0' && *altdate=='\0' && usestatdate==false)
			warn("can't find a date in %s", workfilename);
		if (!*prevauthor.string && !author)
			warn("can't find an author in %s", workfilename);
		if (!*prevstate.string && !state)
			warn("can't find a state in %s", workfilename);
        } /* end processing keepflag */

        gettree(); /* reads in the delta tree.*/

        /* expand symbolic revision number */
	if (!expandsym(krev,&newdelnum)) continue;

        /* splice new delta into tree */
        if (!addelta()) continue;

	if (rcsinitflag) {
		diagnose("initial revision: %s\n", newdelnum.string);
	} else  diagnose("new revision: %s; previous revision: %s\n",
			 newdelnum.string, olddeltanum);

	newdelta.num = newdelnum.string;
        newdelta.branches=nil;
        newdelta.lockedby=nil; /*might be changed by addlock() */
	newdelta.selector = true;
	/* set author */
	if (author!=nil)
		newdelta.author=author;     /* set author given by -w         */
	else if (keepflag && *prevauthor.string)
		newdelta.author=prevauthor.string; /* preserve old author if possible*/
	else    newdelta.author=getcaller();/* otherwise use caller's id      */
	if (state!=nil)
		newdelta.state=state;       /* set state given by -s          */
	else if (keepflag && *prevstate.string)
		newdelta.state=prevstate.string;   /* preserve old state if possible */
	else    newdelta.state=DEFAULTSTATE;/* otherwise use default state    */
	if (usestatdate) {
	    time2date(workstat.st_mtime, altdate);
	}
	if (*altdate!='\0')
		newdelta.date=altdate;      /* set date given by -d           */
	else if (keepflag && *prevdate) /* preserve old date if possible  */
		newdelta.date = prevdate;
	else
		newdelta.date = getdate();  /* use current date               */
	/* now check validity of date -- needed because of -d and -k          */
	if (targetdelta!=nil &&
	    cmpnum(newdelta.date,targetdelta->date) < 0) {
		error("Date %s precedes %s in existing revision %s.",
		       newdelta.date,targetdelta->date, targetdelta->num);
		continue;
	}


	if (lockflag  &&  addlock(&newdelta) < 0) continue;
        curassoc = assoclst;
	while (curassoc) {
	        if (!addsymbol(newdelta.num, curassoc->ssymbol, curassoc->override))
		        break;
	        curassoc = curassoc->nextsym;
	}
	if (curassoc) continue;

    
        putadmin(frewrite);
        puttree(Head,frewrite);
	putdesc(false,textfile);


        /* build rest of file */
	if (rcsinitflag) {
                /* get logmessage */
                newdelta.log=getlogmsg();
		if (!putdftext(newdelnum.string,newdelta.log,workptr,frewrite,false)) continue;
        } else {
		diffilename = maketemp(0);
		workdiffname = workfilename;
		if (workdiffname[0] == '+') {
			/* Some diffs have options with leading '+'. */
			char *w = ftnalloc(char, strlen(workfilename)+3);
			workdiffname = w;
			*w++ = '.';
			*w++ = SLASH;
			VOID strcpy(w, workfilename);
		}
                if (&newdelta==Head) {
                        /* prepend new one */
			foutptr = NULL;
                        if (!(expfilename=
			      buildrevision(gendeltas,targetdelta,false,false))) continue;
                        if (!mustcheckin(expfilename,targetdelta)) continue;
                                /* don't check in files that aren't different, unless forced*/
                        newdelta.log=getlogmsg();
                        exit_stats = run((char*)nil,diffilename,
				diff DIFF_FLAGS, workdiffname, expfilename,
				(char*)nil);
			if (!WIFEXITED(exit_stats) || 1<WEXITSTATUS(exit_stats))
                            faterror ("diff failed");
			/* diff status is EXIT_TROUBLE on failure. */
			if (!putdftext(newdelnum.string,newdelta.log,workptr,frewrite,false)) continue;
			if (!putdtext(olddeltanum,targetdelta->log,diffilename,frewrite,true)) continue;
                } else {
                        /* insert new delta text */
			foutptr = frewrite;
                        if (!(expfilename=
			      buildrevision(gendeltas,targetdelta,false,false))) continue;
                        if (!mustcheckin(expfilename,targetdelta)) continue;
                                /* don't check in files that aren't different, unless forced*/
                        newdelta.log=getlogmsg();
                        exit_stats = run((char*)nil, diffilename,
				diff DIFF_FLAGS, expfilename, workdiffname,
				(char*)nil);
			if (!WIFEXITED(exit_stats) || 1<WEXITSTATUS(exit_stats))
                            faterror ("diff failed");
			if (!putdtext(newdelnum.string,newdelta.log,diffilename,frewrite,true)) continue;
                }

                /* rewrite rest of RCS file */
                fastcopy(finptr,frewrite);
		ffclose(finptr); finptr=NULL; /* Help the file system. */
        }
	ffclose(frewrite); frewrite=NULL;
	ffclose(workptr); workptr=NULL;
	seteid();
	if ((r = chmod(newRCSfilename,newRCSmode)) == 0) {
	    ignoreints();
	    r = re_name(newRCSfilename,RCSfilename);
	    keepdirtemp(newRCSfilename);
	    restoreints();
	}
	setrid();
	if (r != 0) {
		eerror(RCSfilename);
		error("saved in %s", newRCSfilename);
		dirtempunlink();
                break;
        }

        if (!keepworkingfile) {
		r = unlink(workfilename); /* Get rid of old file */
        } else {
		newworkmode = WORKMODE(newRCSmode,
			!(Expand == OLD_EXPAND  ||  !lockflag && StrictLocks)
		);
		/* Expand if !OLD_EXPAND, or if mode can't be fixed.  */
		if (
			Expand != OLD_EXPAND
		||	(	workstat.st_mode != newworkmode
			&&	(r = chmod(workfilename,newworkmode)) < 0
			)
		) {
		    /* Expand keywords in file.  */
		    locker_expansion = lockflag;
		    newworkfilename=
		    xpandfile(workfilename,workfilename /*for directory*/,&newdelta);
		    if (!newworkfilename) continue; /* expand failed */
		    if ((r = chmod(newworkfilename, newworkmode)) == 0) {
			ignoreints();
			r = re_name(newworkfilename,workfilename);
			keepdirtemp(newworkfilename);
			restoreints();
		    }
		}
        }
	if (r != 0) {
	    eerror(workfilename);
	    continue;
	}
	diagnose("done\n");

        } while (cleanup(),
                 ++argv, --argc >=1);

	tempunlink();
	exitmain(exitstatus);
}       /* end of main (ci) */

	static void
cleanup()
{
	if (nerror) exitstatus = EXIT_FAILURE;
	if (finptr) ffclose(finptr);
	if (frewrite) ffclose(frewrite);
	if (workptr) ffclose(workptr);
	dirtempunlink();
}

#if lint
#	define exiterr ciExit
#endif
	exiting void
exiterr()
{
	dirtempunlink();
	tempunlink();
	_exit(EXIT_FAILURE);
}

/*****************************************************************/
/* the rest are auxiliary routines                               */


	static int
addelta()
/* Function: Appends a delta to the delta tree, whose number is
 * given by newdelnum.  Updates Head, newdelnum, newdelnumlength,
 * olddeltanum and the links in newdelta.
 * Returns false on error, true on success.
 */
{
	register char *tp;
	register unsigned i;
	unsigned newdnumlength;  /* actual length of new rev. num. */

	newdnumlength = countnumflds(newdelnum.string);

	if (rcsinitflag) {
                /* this covers non-existing RCS file and a file initialized with rcs -i */
		if ((newdnumlength==0)&&(Dbranch!=nil)) {
			bufscpy(&newdelnum, Dbranch);
			newdnumlength = countnumflds(Dbranch);
		}
		if (newdnumlength==0) bufscpy(&newdelnum, "1.1");
		else if (newdnumlength==1) bufscat(&newdelnum, ".1");
		else if (newdnumlength>2) {
		    error("Branch point doesn't exist for %s.",newdelnum.string);
                    return false;
                } /* newdnumlength == 2 is OK;  */
                olddeltanum=nil;
                Head = &newdelta;
                newdelta.next=nil;
                return true;
        }
        if (newdnumlength==0) {
                /* derive new revision number from locks */
		switch (findlock(true, &targetdelta)) {

		  default:
		    /* found two or more old locks */
		    return false;

		  case 1:
                    /* found an old lock */
                    olddeltanum=targetdelta->num;
                    /* check whether locked revision exists */
		    if (!genrevs(olddeltanum,(char*)nil,(char*)nil,(char*)nil,&gendeltas)) return false;
                    if (targetdelta==Head) {
                        /* make new head */
                        newdelta.next=Head;
                        Head= &newdelta;
			incnum(olddeltanum, &newdelnum);
		    } else if (!targetdelta->next && countnumflds(olddeltanum)>2) {
                        /* new tip revision on side branch */
                        targetdelta->next= &newdelta;
                        newdelta.next = nil;
			incnum(olddeltanum, &newdelnum);
                    } else {
                        /* middle revision; start a new branch */
			bufscpy(&newdelnum, "");
			if (!addbranch(targetdelta,&newdelnum)) return false;
                    }
		    return true; /* successful use of existing lock */

		  case 0:
                    /* no existing lock; try Dbranch */
                    /* update newdelnum */
		    if (StrictLocks || !myself(RCSstat.st_uid)) {
			error("no lock set by %s",getcaller());
                        return false;
                    }
                    if (Dbranch) {
			bufscpy(&newdelnum, Dbranch);
                    } else {
			incnum(Head->num, &newdelnum);
                    }
		    newdnumlength = countnumflds(newdelnum.string);
                    /* now fall into next statement */
                }
        }
        if (newdnumlength<=2) {
                /* add new head per given number */
                olddeltanum=Head->num;
                if(newdnumlength==1) {
                    /* make a two-field number out of it*/
		    if (cmpnumfld(newdelnum.string,olddeltanum,1)==0)
			incnum(olddeltanum, &newdelnum);
		    else
			bufscat(&newdelnum, ".1");
                }
		if (cmpnum(newdelnum.string,olddeltanum) <= 0) {
                    error("deltanumber %s too low; must be higher than %s",
			  newdelnum.string, Head->num);
                    return false;
                }
		if (!(targetdelta=removelock(Head))) return false;
		if (!genrevs(olddeltanum,(char*)nil,(char*)nil,(char*)nil,&gendeltas)) return false;
                newdelta.next=Head;
                Head= &newdelta;
        } else {
                /* put new revision on side branch */
                /*first, get branch point */
		tp = newdelnum.string;
		for (i = newdnumlength - (newdnumlength&1 ^ 1);  (--i);  )
			while (*tp++ != '.')
				;
		*--tp = 0; /* Kill final dot to get old delta temporarily. */
		if (!(targetdelta=genrevs(newdelnum.string,(char*)nil,(char*)nil,(char*)nil,&gendeltas)))
                     return false;
		olddeltanum = targetdelta->num;
		if (cmpnum(olddeltanum, newdelnum.string) != 0) {
		    error("can't find branchpoint %s", newdelnum.string);
                    return false;
                }
		*tp = '.'; /* Restore final dot. */
		if (!addbranch(targetdelta,&newdelnum)) return false;
        }
        return true;
}



	static int
addbranch(branchpoint,num)
	struct hshentry *branchpoint;
	struct buf *num;
/* adds a new branch and branch delta at branchpoint.
 * If num is the null string, appends the new branch, incrementing
 * the highest branch number (initially 1), and setting the level number to 1.
 * the new delta and branchhead are in globals newdelta and newbranch, resp.
 * the new number is placed into num.
 * returns false on error.
 */
{
	struct branchhead *bhead, **btrail;
	struct buf branchnum;
	int result;
	unsigned field, numlength;
	static struct branchhead newbranch;  /* new branch to be inserted */

	numlength = countnumflds(num->string);

        if (branchpoint->branches==nil) {
                /* start first branch */
                branchpoint->branches = &newbranch;
                if (numlength==0) {
			bufscpy(num, branchpoint->num);
			bufscat(num, ".1.1");
		} else if (numlength&1)
			bufscat(num, ".1");
                newbranch.nextbranch=nil;

	} else if (numlength==0) {
                /* append new branch to the end */
                bhead=branchpoint->branches;
                while (bhead->nextbranch) bhead=bhead->nextbranch;
                bhead->nextbranch = &newbranch;
		bufautobegin(&branchnum);
		getbranchno(bhead->hsh->num, &branchnum);
		incnum(branchnum.string, num);
		bufautoend(&branchnum);
		bufscat(num, ".1");
                newbranch.nextbranch=nil;
        } else {
                /* place the branch properly */
		field = numlength - (numlength&1 ^ 1);
                /* field of branch number */
		btrail = &branchpoint->branches;
		while (0 < (result=cmpnumfld(num->string,(*btrail)->hsh->num,field))) {
			btrail = &(*btrail)->nextbranch;
			if (!*btrail) {
				result = -1;
				break;
			}
                }
		if (result < 0) {
                        /* insert/append new branchhead */
			newbranch.nextbranch = *btrail;
			*btrail = &newbranch;
			if (numlength&1) bufscat(num, ".1");
                } else {
                        /* branch exists; append to end */
			bufautobegin(&branchnum);
			getbranchno(num->string, &branchnum);
			targetdelta=genrevs(branchnum.string,(char*)nil,
					    (char*)nil,(char*)nil,&gendeltas);
			bufautoend(&branchnum);
			if (!targetdelta) return false;
                        olddeltanum=targetdelta->num;
			if (cmpnum(num->string,olddeltanum) <= 0) {
                                error("deltanumber %s too low; must be higher than %s",
				      num->string,olddeltanum);
                                return false;
                        }
			if (!removelock(targetdelta)) return false;
			if (numlength&1) incnum(olddeltanum,num);
                        targetdelta->next= &newdelta;
                        newdelta.next=nil;
                        return true; /* Don't do anything to newbranch */
                }
        }
        newbranch.hsh = &newdelta;
        newdelta.next=nil;
        return true;
}



	static void
incnum(onum,nnum)
	const char *onum;
	struct buf *nnum;
/* Increment the last field of revision number onum by one and
 * place the result into nnum.
 */
{
	register const char *sp;
	register char *tp;
	register unsigned i;

	sp = onum;
	bufalloc(nnum, strlen(sp)+2);
	tp = nnum->string;
	for (i=countnumflds(sp);  (--i);  ) {
		while (*sp != '.') *tp++ = *sp++;
		*tp++ = *sp++;  /* copy dot also */
	}
	VOID sprintf(tp, "%d", atoi(sp)+1);
}



	static struct hshentry *
removelock(delta)
struct hshentry * delta;
/* function: Finds the lock held by caller on delta,
 * removes it, and returns a pointer to the delta.
 * Prints an error message and returns nil if there is no such lock.
 * An exception is if !StrictLocks, and caller is the owner of
 * the RCS file. If caller does not have a lock in this case,
 * delta is returned.
 */
{
        register struct lock * next, * trail;
	const char *num;
        struct lock dummy;
        int whomatch, nummatch;

        num=delta->num;
        dummy.nextlock=next=Locks;
        trail = &dummy;
        while (next!=nil) {
		whomatch = strcmp(getcaller(), next->login);
                nummatch=strcmp(num,next->delta->num);
                if ((whomatch==0) && (nummatch==0)) break;
			/*found a lock on delta by caller*/
                if ((whomatch!=0)&&(nummatch==0)) {
                    error("revision %s locked by %s",num,next->login);
                    return nil;
                }
                trail=next;
                next=next->nextlock;
        }
        if (next!=nil) {
                /*found one; delete it */
                trail->nextlock=next->nextlock;
                Locks=dummy.nextlock;
                next->delta->lockedby=nil; /* reset locked-by */
                return next->delta;
        } else {
		if (StrictLocks || !myself(RCSstat.st_uid)) {
		    error("no lock set by %s for revision %s",getcaller(),num);
                    return nil;
                } else {
                        return delta;
                }
        }
}



	static const char *
getdate()
/* Return a pointer to the current date.  */
{
	static char buffer[datesize]; /* date buffer */
	time_t t;

	if (!buffer[0]) {
		t = time((time_t *)0);
		if (t == -1)
			faterror("time not available");
		time2date(t, buffer);
	}
        return buffer;
}


	static const char *
xpandfile (unexfname,dir,delta)
	const char *unexfname, *dir;
	const struct hshentry *delta;
/* Function: Reads file unexpfname and copies it to a
 * file in dir, performing keyword substitution with data from delta.
 * returns the name of the expanded file if successful, nil otherwise.
 */
{
	const char *targetfname;
        FILE * unexfile, *exfile;

	targetfname = makedirtemp(dir,0);
	errno = 0;
	if (!(unexfile = fopen(unexfname, "r"))) {
		eerror(unexfname);
		return nil;
	}
	errno = 0;
	if (!(exfile = fopen(targetfname, "w"))) {
		eerror(targetfname);
		error("can't expand file %s",unexfname);
		ffclose(unexfile);
                return nil;
        }
	if (Expand == OLD_EXPAND)
		fastcopy(unexfile,exfile);
	else
		while (0 < expandline(unexfile,exfile,delta,false,(FILE*)nil))
			;
        ffclose(unexfile);ffclose(exfile);
        return targetfname;
}


	static int
mustcheckin (unexfname,delta)
	const char *unexfname;
	const struct hshentry *delta;
/* Function: determines whether checkin should proceed.
 * Compares the workfilename with unexfname, disregarding keywords.
 * If the 2 files differ, returns true. If they do not differ, asks the user
 * whether to return true or false (i.e., whether to checkin the file anyway);
 * the default answer is false.
 * Shortcut: If forceciflag is set, mustcheckin() always returns true.
 */
{
	int result;

        if (forceciflag) return true;

        if (!rcsfcmp(workfilename,unexfname,delta)) return true;
        /* If files are different, must check them in. */

        /* files are the same */
	if (!(result = yesorno(false,
		"File %s is unchanged with respect to revision %s\ncheckin anyway? [ny](n): ",
		workfilename, delta->num
	))) {
	    error("%scheckin aborted", 
		    !quietflag && ttystdin()  ?  ""  :  "file is unchanged; "
	    );
        }
        return result;
}




/* --------------------- G E T L O G M S G --------------------------------*/


	static struct cbuf
getlogmsg()
/* Function: obtains a log message and returns a pointer to it.
 * If a log message is given via the -m option, a pointer to that
 * string is returned.
 * If this is the initial revision, a standard log message is returned.
 * Otherwise, reads a character string from the terminal.
 * Stops after reading EOF or a single '.' on a
 * line. getlogmsg prompts the first time it is called for the
 * log message; during all later calls it asks whether the previous
 * log message can be reused.
 * returns a pointer to the character string; the pointer is always non-nil.
 */
{
	static const char
		emptych[] = "*** empty log message ***",
		initialch[] = "Initial revision";
	static const struct cbuf
		emptylog = { emptych, sizeof(emptych)-sizeof(char) },
		initiallog = { initialch, sizeof(initialch)-sizeof(char) };
	static struct buf logbuf;
	static struct cbuf logmsg;

	int cin;
	register char *tp;
	register size_t i;
	register const char *p;
	const char *caller, *date;

	if (keepflag) {
		/* generate std. log message */
		caller = getcaller();
		p = date = getdate();
		while (*p++ != '.')
			;
		i = strlen(caller);
		bufalloc(&logbuf, sizeof(ciklog)+strlen(caller)+4+datesize);
		tp = logbuf.string;
		VOID sprintf(tp,
			"%s%s at %s%.*s/%.2s/%.2s %.2s:%.2s:%s",
			ciklog, caller,
			date[2]=='.' && VERSION(5)<=RCSversion  ?  "19"  :  "",
			p-date-1, date,
			p, p+3, p+6, p+9, p+12
		);
		logmsg.string = tp;
		logmsg.size = strlen(tp);
		return logmsg;
	}

	if (msg.size) return msg;

	if (!olddeltanum && (
		cmpnum(newdelnum.string,"1.1")==0 ||
		cmpnum(newdelnum.string,"1.0")==0
	))
		return initiallog;

	if (logmsg.size) {
                /*previous log available*/
	    if (yesorno(true, "reuse log message of previous file? [yn](y): "))
		return logmsg;
        }

        /* now read string from stdin */
	if (feof(stdin))
	    faterror("can't reread redirected stdin for log message; use -m");
	if (ttystdin())
		aputs("enter log message:\n(terminate with single '.' or end of file)\n>> ",stderr);

	i = 0;
	tp = logbuf.string;
	while ((cin = getcstdin()) != EOF) {
		if (cin=='\n') {
			if (i && tp[i-1]=='.' && (i==1 || tp[i-2]=='\n')) {
				/* Remove trailing '.'. */
				--i;
				break;
			}
			if (ttystdin()) aputs(">> ", stderr);
		}
		bufrealloc(&logbuf, i+1);
		tp = logbuf.string;
		tp[i++] = cin;
                /*SDELIM will be changed to double SDELIM by putdtext*/
        } /* end for */

        /* now check whether the log message is not empty */
	logmsg = cleanlogmsg(tp, i);
	if (logmsg.size)
		return logmsg;
	return emptylog;
}

/*  Make a linked list of Symbolic names  */

        static void
addassoclst(flag, sp)
int  flag;
char * sp;
{
        struct Symrev *pt;
	
	pt = talloc(struct Symrev);
	pt->ssymbol = sp;
	pt->override = flag;
	pt->nextsym = nil;
	if (lastassoc)
	        lastassoc->nextsym = pt;
	else
	        assoclst = pt;
	lastassoc = pt;
	return;
}
