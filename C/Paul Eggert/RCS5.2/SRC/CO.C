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
 *                     RCS checkout operation
 */
/*****************************************************************************
 *                       check out revisions from RCS files
 *****************************************************************************
 */


/* $Log: co.c,v $
 * Revision 5.10  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.9  91/01/30  12:02:34  apratt
 * Changed RCS5AKP1 to RCS5AP1
 * 
 * Revision 5.8  91/01/29  17:45:24  apratt
 * Added RCS5AKP1 to usage message
 * 
 * Revision 5.7  91/01/11  12:45:34  apratt
 * First version that compiles.
 * 
 * Revision 5.6  90/12/04  05:18:38  eggert
 * checked in with -k by apratt at 91.01.10.13.14.50.
 * 
 * Revision 5.6  1990/12/04  05:18:38  eggert
 * Don't checkaccesslist() unless necessary.
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.5  1990/11/01  05:03:26  eggert
 * Fix -j.  Add -I.
 *
 * Revision 5.4  1990/10/04  06:30:11  eggert
 * Accumulate exit status across files.
 *
 * Revision 5.3  1990/09/11  02:41:09  eggert
 * co -kv yields a readonly working file.
 *
 * Revision 5.2  1990/09/04  08:02:13  eggert
 * Standardize yes-or-no procedure.
 *
 * Revision 5.0  1990/08/22  08:10:02  eggert
 * Permit multiple locks by same user.  Add setuid support.
 * Remove compile-time limits; use malloc instead.
 * Permit dates past 1999/12/31.  Switch to GMT.
 * Make lock and temp files faster and safer.
 * Ansify and Posixate.  Add -k, -V.  Remove snooping.  Tune.
 *
 * Revision 4.7  89/05/01  15:11:41  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.6  88/08/09  19:12:15  eggert
 * Fix "co -d" core dump; rawdate wasn't always initialized.
 * Use execv(), not system(); fix putchar('\0') and diagnose() botches; remove lint
 * 
 * Revision 4.5  87/12/18  11:35:40  narten
 * lint cleanups (from Guy Harris)
 * 
 * Revision 4.4  87/10/18  10:20:53  narten
 * Updating version numbers changes relative to 1.1, are actually
 * relative to 4.2
 * 
 * Revision 1.3  87/09/24  13:58:30  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:21:38  jenkins
 * Port to suns
 * 
 * Revision 4.2  83/12/05  13:39:48  wft
 * made rewriteflag external.
 * 
 * Revision 4.1  83/05/10  16:52:55  wft
 * Added option -u and -f.
 * Added handling of default branch.
 * Replaced getpwuid() with getcaller().
 * Removed calls to stat(); now done by pairfilenames().
 * Changed and renamed rmoldfile() to rmworkfile().
 * Replaced catchints() calls with restoreints(), unlink()--link() with rename();
 * 
 * Revision 3.7  83/02/15  15:27:07  wft
 * Added call to fastcopy() to copy remainder of RCS file.
 *
 * Revision 3.6  83/01/15  14:37:50  wft
 * Added ignoring of interrupts while RCS file is renamed; this avoids
 * deletion of RCS files during the unlink/link window.
 *
 * Revision 3.5  82/12/08  21:40:11  wft
 * changed processing of -d to use DATEFORM; removed actual from
 * call to preparejoin; re-fixed printing of done at the end.
 *
 * Revision 3.4  82/12/04  18:40:00  wft
 * Replaced getdelta() with gettree(), SNOOPDIR with SNOOPFILE.
 * Fixed printing of "done".
 *
 * Revision 3.3  82/11/28  22:23:11  wft
 * Replaced getlogin() with getpwuid(), flcose() with ffclose(),
 * %02d with %.2d, mode generation for working file with WORKMODE.
 * Fixed nil printing. Fixed -j combined with -l and -p, and exit
 * for non-existing revisions in preparejoin().
 *
 * Revision 3.2  82/10/18  20:47:21  wft
 * Mode of working file is now maintained even for co -l, but write permission
 * is removed.
 * The working file inherits its mode from the RCS file, plus write permission
 * for the owner. The write permission is not given if locking is strict and
 * co does not lock.
 * An existing working file without write permission is deleted automatically.
 * Otherwise, co asks (empty answer: abort co).
 * Call to getfullRCSname() added, check for write error added, call
 * for getlogin() fixed.
 *
 * Revision 3.1  82/10/13  16:01:30  wft
 * fixed type of variables receiving from getc() (char -> int).
 * removed unused variables.
 */




#include "rcsbase.h"

static const char *getancestor P((const char*,const char*));
static int buildjoin P((const char*));
static int creatempty P((void));
static int fixworkmode P((const char*));
static int preparejoin P((void));
static int rmlock P((const struct hshentry*));
static int rmworkfile P((void));
static void cleanup P((void));

static const char quietarg[] = "-q";

static const char *join, *versionarg;
static const char *joinlist[joinlength];/* revisions to be joined	*/
static int exitstatus;
static int forceflag, tostdout;
static int lastjoin;			/* index of last element in joinlist  */
static int lockflag; /* -1 -> unlock, 0 -> do nothing, 1 -> lock */
static struct hshentries *gendeltas;	/* deltas to be generated	*/
static struct hshentry *targetdelta;	/* final delta to be generated	*/

mainProg(coId, "co", "$Id: co.c,v 5.10 1991/01/30 14:21:32 apratt Exp $")
{
	static const char cmdusage[] =
		"\nRCS5AP1 as modified for TOS by Allan Pratt, atari!apratt\nco usage: co -{flpqru}[rev] -ddate -jjoinlist -sstate -w[login] -Vn file ...";

	const char *author, *date, *rev, *state;
	const char *neworkfilename;
	int changelock;  /* 1 if a lock has been changed, -1 if error */
	int expmode, r;
	struct buf numericrev;	/* expanded revision number	*/
	char finaldate[datesize];

	initid();
	catchints();
	author = date = rev = state = nil;
	bufautobegin(&numericrev);
	expmode = -1;
	versionarg = nil;

        while (--argc,++argv, argc>=1 && ((*argv)[0] == '-')) {
                switch ((*argv)[1]) {

                case 'r':
                revno:  if ((*argv)[2]!='\0') {
				if (rev) warn("redefinition of revision number");
                                rev = (*argv)+2;
                        }
                        break;

		case 'f':
			forceflag=true;
			goto revno;

                case 'l':
			if (lockflag < 0) {
                                warn("-l overrides -u.");
                        }
			lockflag = 1;
                        goto revno;

                case 'u':
			if (0 < lockflag) {
                                warn("-l overrides -u.");
                        }
			lockflag = -1;
                        goto revno;

                case 'p':
                        tostdout=true;
                        goto revno;

		case 'I':
			interactiveflag = true;
			goto revno;

                case 'q':
                        quietflag=true;
                        goto revno;

                case 'd':
			if (date)
				redefined('d');
			str2date(*argv+2, finaldate);
                        date=finaldate;
                        break;

                case 'j':
                        if ((*argv)[2]!='\0'){
				if (join) redefined('j');
                                join = (*argv)+2;
                        }
                        break;

                case 's':
                        if ((*argv)[2]!='\0'){
				if (state) redefined('s');
                                state = (*argv)+2;
                        }
                        break;

                case 'w':
			if (author) redefined('w');
                        if ((*argv)[2]!='\0')
                                author = (*argv)+2;
			else
				author = getcaller();
                        break;

		case 'V':
			if (versionarg) redefined('V');
			versionarg = *argv;
			setRCSversion(versionarg);
			break;

		case 'k':    /*  set keyword expand mode  */
			if (0 <= expmode) redefined('k');
			if (0 <= (expmode = str2expmode(*argv+2)))
			    break;
			/* fall into */
                default:
			faterror("unknown option: %s%s", *argv, cmdusage);

                };
        } /* end of option processing */

	if (argc<1) faterror("no input file%s", cmdusage);

        /* now handle all filenames */
        do {
        finptr=frewrite=NULL;
	fcopy = foutptr = NULL;
	ffree();

	if (!pairfilenames(argc, argv, lockflag?rcswriteopen:rcsreadopen, true, tostdout))
		continue;

        /* now RCSfilename contains the name of the RCS file, and finptr
         * the file descriptor. If tostdout is false, workfilename contains
         * the name of the working file, otherwise undefined (not nil!).
	 * Also, RCSstat has been set.
         */
	diagnose("%s  -->  %s\n", RCSfilename,tostdout?"stdout":workfilename);

	if (!tostdout) {
		if (!getworkstat()) continue; /* give up */
		if (!initeditfiles(workfilename)) {
			if (errno == EACCES)
				error("%s: parent directory isn't writable",
					workfilename
				);
			else
				eerror(resultfile);
			continue;
		}
	}
	if (0 <= expmode)
		Expand = expmode;
	if (0 < lockflag  &&  Expand == VAL_EXPAND) {
		error("cannot combine -kv and -l");
		continue;
	}

        gettree();  /* reads in the delta tree */

        if (Head==nil) {
                /* no revisions; create empty file */
		diagnose("no revisions present; generating empty revision 0.0\n");
                if (!tostdout)
                        if (!creatempty()) continue;
                /* Can't reserve a delta, so don't call addlock */
        } else {
                if (rev!=nil) {
                        /* expand symbolic revision number */
			if (!expandsym(rev, &numericrev))
                                continue;
		} else
			switch (lockflag<0 ? findlock(false,&targetdelta) : 0) {
			    default:
				continue;
			    case 0:
				bufscpy(&numericrev, Dbranch?Dbranch:"");
				break;
			    case 1:
				bufscpy(&numericrev, targetdelta->num);
				break;
			}
                /* get numbers of deltas to be generated */
		if (!(targetdelta=genrevs(numericrev.string,date,author,state,&gendeltas)))
                        continue;
                /* check reservations */
		changelock = 0;
		if (lockflag) {
		    changelock =
		       lockflag<0 ? rmlock(targetdelta) : addlock(targetdelta);
		    if (changelock) {
			if (changelock<0 || !checkaccesslist())
			    continue;
		    } else {
			ffclose(frewrite);  frewrite=NULL;
			seteid();
			ignoreints();
			r = unlink(newRCSfilename);
			keepdirtemp(newRCSfilename);
			restoreints();
			setrid();
			if (r != 0) {
			    eerror(RCSfilename);
			    continue;
			}
		    }
		}

                if (join && !preparejoin()) continue;

		diagnose("revision %s%s\n",targetdelta->num,
			 0<lockflag ? " (locked)" :
			 lockflag<0 ? " (unlocked)" : "");

                /* remove old working file if necessary */
                if (!tostdout)
                        if (!rmworkfile()) continue;

                /* prepare for rewriting the RCS file */
		if (changelock) {
                        putadmin(frewrite);
                        puttree(Head,frewrite);
			aprintf(frewrite, "\n\n%s%c",Kdesc,nextc);
			foutptr = frewrite;
		}

                /* skip description */
                getdesc(false); /* don't echo*/

		locker_expansion = 0 < lockflag;
                if (!(neworkfilename=buildrevision(gendeltas,targetdelta,
						   tostdout,Expand!=OLD_EXPAND)))
                                continue;

		if (changelock && !nerror) {
                        /* rewrite the rest of the RCSfile */
                        fastcopy(finptr,frewrite);
			ffclose(finptr); finptr=NULL; /*Help the file system.*/
                        ffclose(frewrite); frewrite=NULL;
			seteid();
			if ((r = chmod(newRCSfilename, RCSstat.st_mode & ~(S_IWUSR|S_IWGRP|S_IWOTH))) == 0) {
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
                }

                if (join) {
			if (!buildjoin(neworkfilename)) continue;
                }
                if (!tostdout) {
			if (!fixworkmode(neworkfilename))
				continue;
			ignoreints();
			r = re_name(neworkfilename,workfilename);
			keepdirtemp(neworkfilename);
			restoreints();
			if (r != 0) {
				eerror(workfilename);
				error("see %s", neworkfilename);
                                continue;
                        }
		}
        }
	if (!tostdout) diagnose("done\n");
        } while (cleanup(),
                 ++argv, --argc >=1);

	tempunlink();
	exitmain(exitstatus);

}       /* end of main (co) */

	static void
cleanup()
{
	if (nerror) exitstatus = EXIT_FAILURE;
	if (finptr) ffclose(finptr);
	if (frewrite) ffclose(frewrite);
	dirtempunlink();
}

#if lint
#	define exiterr coExit
#endif
	exiting void
exiterr()
{
	dirtempunlink();
	tempunlink();
	_exit(EXIT_FAILURE);
}


/*****************************************************************
 * The following routines are auxiliary routines
 *****************************************************************/

	static int
rmworkfile()
/* Function: prepares to remove workfilename, if it exists, and if
 * it is read-only.
 * Otherwise (file writable):
 *   if !quietmode asks the user whether to really delete it (default: fail);
 *   otherwise failure.
 * Returns 0 on failure to get permission, -1 if there's nothing to remove,
 * 1 if there is a file to remove.
 */
{
	if (haveworkstat)	  /* File doesn't exist; set by pairfilenames*/
	    return -1;

	if (workstat.st_mode&(S_IWUSR|S_IWGRP|S_IWOTH) && !forceflag) {
	    /* File is writable */
	    if (!yesorno(false, "writable %s exists; remove it? [ny](n): ",
			workfilename
	    )) {
		error(!quietflag && ttystdin()
			? "checkout aborted"
			: "writable %s exists; checkout aborted", workfilename);
		return 0;
            }
        }
	/* Actual unlink is done later by caller. */
	return 1;
}

	static int
fixworkmode(f)
	const char *f;
{
	if (
		chmod(f, WORKMODE(RCSstat.st_mode,
		    !(Expand==VAL_EXPAND  ||  lockflag<=0 && StrictLocks)
		)) < 0
	) {
		eerror(workfilename);
		return false;
	}
	return true;
}


	static int
creatempty()
/* Function: creates an empty working file.
 * First, removes an existing working file with rmworkfile().
 */
{
        int  fdesc;              /* file descriptor */
	int s;

	if (!(s = rmworkfile()))
		return false;
	if (0 < s  &&  unlink(workfilename) != 0) {
		eerror(workfilename);
		return false;
	}
        fdesc=creat(workfilename,0);
	if (fdesc < 0)
		efaterror(workfilename);
	VOID close(fdesc); /* empty file */
	return fixworkmode(workfilename);
}


	static int
rmlock(delta)
	const struct hshentry *delta;
/* Function: removes the lock held by caller on delta.
 * Returns -1 if someone else holds the lock,
 * 0 if there is no lock on delta,
 * and 1 if a lock was found and removed.
 */
{       register struct lock * next, * trail;
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
                    error("revision %s locked by %s; use co -r or rcs -u",num,next->login);
                    return -1;
                }
                trail=next;
                next=next->nextlock;
        }
        if (next!=nil) {
                /*found one; delete it */
                trail->nextlock=next->nextlock;
                Locks=dummy.nextlock;
                next->delta->lockedby=nil; /* reset locked-by */
                return 1; /*success*/
        } else  return 0; /*no lock on delta*/
}




/*****************************************************************
 * The rest of the routines are for handling joins
 *****************************************************************/


	static const char *
addjoin(joinrev)
	char *joinrev;
/* Add joinrev's number to joinlist, yielding address of char past joinrev,
 * or nil if no such revision exists.
 */
{
	register char *j;
	register const struct hshentry *d;
	char terminator;
	struct buf numrev;
	struct hshentries *joindeltas;

	j = joinrev;
	for (;;) {
	    switch (*j++) {
		default:
		    continue;
		case 0:
		case ' ': case '\t': case '\n':
		case ':': case ',': case ';':
		    break;
	    }
	    break;
	}
	terminator = *--j;
	*j = 0;
	bufautobegin(&numrev);
	d = 0;
	if (expandsym(joinrev, &numrev))
	    d = genrevs(numrev.string,(char*)nil,(char*)nil,(char*)nil,&joindeltas);
	bufautoend(&numrev);
	*j = terminator;
	if (d) {
		joinlist[++lastjoin] = d->num;
		return j;
	}
	return nil;
}

	static int
preparejoin()
/* Function: Parses a join list pointed to by join and places pointers to the
 * revision numbers into joinlist.
 */
{
	register const char *j;

        j=join;
        lastjoin= -1;
        for (;;) {
                while ((*j==' ')||(*j=='\t')||(*j==',')) j++;
                if (*j=='\0') break;
                if (lastjoin>=joinlength-2) {
                        error("too many joins");
                        return(false);
                }
		if (!(j = addjoin(j))) return false;
                while ((*j==' ') || (*j=='\t')) j++;
                if (*j == ':') {
                        j++;
                        while((*j==' ') || (*j=='\t')) j++;
                        if (*j!='\0') {
				if (!(j = addjoin(j))) return false;
                        } else {
                                error("join pair incomplete");
                                return false;
                        }
                } else {
                        if (lastjoin==0) { /* first pair */
                                /* common ancestor missing */
                                joinlist[1]=joinlist[0];
                                lastjoin=1;
                                /*derive common ancestor*/
				if (!(joinlist[0] = getancestor(targetdelta->num,joinlist[1])))
                                       return false;
                        } else {
                                error("join pair incomplete");
                                return false;
                        }
                }
        }
        if (lastjoin<1) {
                error("empty join");
                return false;
        } else  return true;
}



	static const char *
getancestor(r1, r2)
	const char *r1, *r2;
/* Yield the common ancestor of r1 and r2 if successful, nil otherwise.
 * Work reliably only if r1 and r2 are not branch numbers.
 */
{
	static struct buf t1, t2;

	unsigned l1, l2, l3;
	const char *r;

	l1 = countnumflds(r1);
	l2 = countnumflds(r2);
	if ((2<l1 || 2<l2)  &&  cmpnum(r1,r2)!=0) {
	    /* not on main trunk or identical */
	    l3 = 0;
	    while (cmpnumfld(r1, r2, l3+1)==0 && cmpnumfld(r1, r2, l3+2)==0)
		l3 += 2;
	    /* This will terminate since r1 and r2 are not the same; see above. */
	    if (l3==0) {
		/* no common prefix; common ancestor on main trunk */
		VOID partialno(&t1, r1, l1>2 ? (unsigned)2 : l1);
		VOID partialno(&t2, r2, l2>2 ? (unsigned)2 : l2);
		r = cmpnum(t1.string,t2.string)<0 ? t1.string : t2.string;
		if (cmpnum(r,r1)!=0 && cmpnum(r,r2)!=0)
			return r;
	    } else if (cmpnumfld(r1, r2, l3+1)!=0)
			return partialno(&t1,r1,l3);
	}
	error("common ancestor of %s and %s undefined", r1, r2);
	return nil;
}



	static int
buildjoin(initialfile)
	const char *initialfile;
/* Function: merge pairs of elements in joinlist into initialfile
 * If tostdout is set, copy result to stdout.
 * All unlinking of initialfile, rev2, and rev3 should be done by *tempunlink().
 */
{
	struct buf commarg;
	struct buf subs;
	const char *rev2, *rev3;
        int i;
	int status;
	const char *cov[8], *mergev[12];
	const char **p;

	bufautobegin(&commarg);
	bufautobegin(&subs);
	rev2 = maketemp(0);
	rev3 = maketemp(3); /* buildrevision() may use 1 and 2 */

	cov[0] = nil;
	/* cov[1] setup below */
	cov[2] = CO;
	/* cov[3] setup below */
	p = &cov[4];
	if (versionarg) *p++ = versionarg;
	*p++ = quietarg;
	*p++ = RCSfilename;
	*p = nil;

	mergev[0] = nil;
	mergev[1] = nil;
	mergev[2] = MERGE;
	mergev[3] = mergev[5] = "-L";
	/* rest of mergev setup below */

        i=0;
        while (i<lastjoin) {
                /*prepare marker for merge*/
                if (i==0)
			bufscpy(&subs, targetdelta->num);
		else {
			bufscat(&subs, ",");
			bufscat(&subs, joinlist[i-2]);
			bufscat(&subs, ":");
			bufscat(&subs, joinlist[i-1]);
		}
		diagnose("revision %s\n",joinlist[i]);
		bufscpy(&commarg, "-p");
		bufscat(&commarg, joinlist[i]);
		cov[1] = rev2;
		cov[3] = commarg.string;
		if (runv(cov))
			goto badmerge;
		diagnose("revision %s\n",joinlist[i+1]);
		bufscpy(&commarg, "-p");
		bufscat(&commarg, joinlist[i+1]);
		cov[1] = rev3;
		cov[3] = commarg.string;
		if (runv(cov))
			goto badmerge;
		diagnose("merging...\n");
		mergev[4] = subs.string;
		mergev[6] = joinlist[i+1];
		p = &mergev[7];
		if (quietflag) *p++ = quietarg;
		if (lastjoin<=i+2 && tostdout) *p++ = "-p";
		*p++ = initialfile;
		*p++ = rev2;
		*p++ = rev3;
		*p = nil;
		status = runv(mergev);
		if (!WIFEXITED(status) || 1<WEXITSTATUS(status))
			goto badmerge;
                i=i+2;
        }
	bufautoend(&commarg);
	bufautoend(&subs);
        return true;

    badmerge:
	nerror++;
	bufautoend(&commarg);
	bufautoend(&subs);
	return false;
}
