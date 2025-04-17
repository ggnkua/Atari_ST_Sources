/*
 *                      RCS create/change operation
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




/* $Log: rcs.c,v $
 * Revision 5.11  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.10  91/01/30  12:02:40  apratt
 * Changed RCS5AKP1 to RCS5AP1
 * 
 * Revision 5.9  91/01/29  17:45:30  apratt
 * Added RCS5AKP1 to usage message
 * 
 * Revision 5.8  91/01/11  12:46:10  apratt
 * First version that compiles.
 * 
 * Revision 5.7  90/12/18  17:19:21  eggert
 * checked in with -k by apratt at 91.01.10.13.15.02.
 * 
 * Revision 5.7  1990/12/18  17:19:21  eggert
 * Fix bug with multiple -n and -N options.
 *
 * Revision 5.6  1990/12/04  05:18:40  eggert
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.5  1990/11/11  00:06:35  eggert
 * Fix `rcs -e' core dump.
 *
 * Revision 5.4  1990/11/01  05:03:33  eggert
 * Add -I and new -t behavior.  Permit arbitrary data in logs.
 *
 * Revision 5.3  1990/10/04  06:30:16  eggert
 * Accumulate exit status across files.
 *
 * Revision 5.2  1990/09/04  08:02:17  eggert
 * Standardize yes-or-no procedure.
 *
 * Revision 5.1  1990/08/29  07:13:51  eggert
 * Remove unused setuid support.  Clean old log messages too.
 *
 * Revision 5.0  1990/08/22  08:12:42  eggert
 * Don't lose names when applying -a option to multiple files.
 * Remove compile-time limits; use malloc instead.  Add setuid support.
 * Permit dates past 1999/12/31.  Make lock and temp files faster and safer.
 * Ansify and Posixate.  Add -V.  Fix umask bug.  Make linting easier.  Tune.
 * Yield proper exit status.  Check diff's output.
 *
 * Revision 4.11  89/05/01  15:12:06  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.10  88/11/08  16:01:54  narten
 * didn't install previous patch correctly
 * 
 * Revision 4.9  88/11/08  13:56:01  narten
 * removed include <sysexits.h> (not needed)
 * minor fix for -A option
 * 
 * Revision 4.8  88/08/09  19:12:27  eggert
 * Don't access freed storage.
 * Use execv(), not system(); yield proper exit status; remove lint.
 * 
 * Revision 4.7  87/12/18  11:37:17  narten
 * lint cleanups (Guy Harris)
 * 
 * Revision 4.6  87/10/18  10:28:48  narten
 * Updating verison numbers. Changes relative to 1.1 are actually 
 * relative to 4.3
 * 
 * Revision 1.4  87/09/24  13:58:52  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.3  87/03/27  14:21:55  jenkins
 * Port to suns
 * 
 * Revision 1.2  85/12/17  13:59:09  albitz
 * Changed setstate to rcs_setstate because of conflict with random.o.
 * 
 * Revision 4.3  83/12/15  12:27:33  wft
 * rcs -u now breaks most recent lock if it can't find a lock by the caller.
 * 
 * Revision 4.2  83/12/05  10:18:20  wft
 * Added conditional compilation for sending mail.
 * Alternatives: V4_2BSD, V6, USG, and other.
 * 
 * Revision 4.1  83/05/10  16:43:02  wft
 * Simplified breaklock(); added calls to findlock() and getcaller().
 * Added option -b (default branch). Updated -s and -w for -b.
 * Removed calls to stat(); now done by pairfilenames().
 * Replaced most catchints() calls with restoreints().
 * Removed check for exit status of delivermail().
 * Directed all interactive output to stderr.
 * 
 * Revision 3.9.1.1  83/12/02  22:08:51  wft
 * Added conditional compilation for 4.2 sendmail and 4.1 delivermail.
 * 
 * Revision 3.9  83/02/15  15:38:39  wft
 * Added call to fastcopy() to copy remainder of RCS file.
 *
 * Revision 3.8  83/01/18  17:37:51  wft
 * Changed sendmail(): now uses delivermail, and asks whether to break the lock.
 *
 * Revision 3.7  83/01/15  18:04:25  wft
 * Removed putree(); replaced with puttree() in rcssyn.c.
 * Combined putdellog() and scanlogtext(); deleted putdellog().
 * Cleaned up diagnostics and error messages. Fixed problem with
 * mutilated files in case of deletions in 2 files in a single command.
 * Changed marking of selector from 'D' to DELETE.
 *
 * Revision 3.6  83/01/14  15:37:31  wft
 * Added ignoring of interrupts while new RCS file is renamed;
 * Avoids deletion of RCS files by interrupts.
 *
 * Revision 3.5  82/12/10  21:11:39  wft
 * Removed unused variables, fixed checking of return code from diff,
 * introduced variant COMPAT2 for skipping Suffix on -A files.
 *
 * Revision 3.4  82/12/04  13:18:20  wft
 * Replaced getdelta() with gettree(), changed breaklock to update
 * field lockedby, added some diagnostics.
 *
 * Revision 3.3  82/12/03  17:08:04  wft
 * Replaced getlogin() with getpwuid(), flcose() with ffclose(),
 * /usr/ucb/Mail with macro MAIL. Removed handling of Suffix (-x).
 * fixed -u for missing revno. Disambiguated structure members.
 *
 * Revision 3.2  82/10/18  21:05:07  wft
 * rcs -i now generates a file mode given by the umask minus write permission;
 * otherwise, rcs keeps the mode, but removes write permission.
 * I added a check for write error, fixed call to getlogin(), replaced
 * curdir() with getfullRCSname(), cleaned up handling -U/L, and changed
 * conflicting, long identifiers.
 *
 * Revision 3.1  82/10/13  16:11:07  wft
 * fixed type of variables receiving from getc() (char -> int).
 */


#include "rcsbase.h"

struct  Lockrev {
	const char *revno;
        struct  Lockrev   * nextrev;
};

struct  Symrev {
	const char *revno;
	const char *ssymbol;
        int     override;
        struct  Symrev  * nextsym;
};

struct  Status {
	const char *revno;
	const char *status;
        struct  Status  * nextstatus;
};

enum changeaccess {append, erase};
struct chaccess {
	const char *login;
	enum changeaccess command;
	struct chaccess *nextchaccess;
};

struct delrevpair {
	const char *strt;
	const char *end;
        int     code;
};

static int buildeltatext P((const struct hshentries*));
static int removerevs P((void));
static int sendmail P((const char*,const char*));
static struct Lockrev *rmnewlocklst P((const struct Lockrev*));
static void breaklock P((const struct hshentry*));
static void buildtree P((void));
static void cleanup P((void));
static void getaccessor P((char*,enum changeaccess));
static void getassoclst P((int,char*));
static void getchaccess P((const char*,enum changeaccess));
static void getdelrev P((char*));
static void getstates P((char*));
static void rcs_setstate P((const char*,const char*));
static void scanlogtext P((struct hshentry*,int));
static void setlock P((const char*));
static void updateaccess P((void));
static void updateassoc P((void));
static void updatelocks P((void));

static struct buf numrev;
static const char *headstate;
static int chgheadstate, exitstatus, lockhead, unlockcaller;
static struct Lockrev *newlocklst, *rmvlocklst;
static struct Status *statelst, *laststate;
static struct Symrev *assoclst, *lastassoc;
static struct chaccess *chaccess, **nextchaccess;
static struct delrevpair delrev;
static struct hshentry *cuthead, *cuttail, *delstrt;
static struct hshentries *gendeltas;

mainProg(rcsId, "rcs", "$Id: rcs.c,v 5.11 1991/01/30 14:21:32 apratt Exp $")
{
	static const char cmdusage[] =
		"\nRCS5AP1 as modified for TOS by Allan Pratt, atari!apratt\nrcs usage: rcs -alogins -Aoldfile -{blu}[rev] -cstring -e[logins] -i -{LU} -{nN}name[:rev] -orange -sstate[:rev] -t[textfile] -Vn file ...";

	const char *branchsym, *commsyml, *textfile;
	int branchflag, expmode, initflag;
	int r, strictlock, strict_selected, textflag;
	mode_t defaultRCSmode;	/* default mode for new RCS files */
	struct buf branchnum;
        struct  Lockrev *curlock,  * rmvlock, *lockpt;
        struct  Status  * curstate;

	initid();
	catchints();

	nextchaccess = &chaccess;
	branchsym = commsyml = textfile = nil;
	branchflag = strictlock = false;
	bufautobegin(&branchnum);
	curlock = rmvlock = nil;
	defaultRCSmode = 0;
	expmode = -1;
        initflag= textflag = false;
        strict_selected = 0;

        /*  preprocessing command options    */
        while (--argc,++argv, argc>=1 && ((*argv)[0] == '-')) {
                switch ((*argv)[1]) {

		case 'i':   /*  initial version  */
                        initflag = true;
                        break;

                case 'b':  /* change default branch */
			if (branchflag) redefined('b');
                        branchflag= true;
                        branchsym = (*argv)+2;
                        break;

                case 'c':   /*  change comment symbol   */
			if (commsyml) redefined('c');
                        commsyml = (*argv)+2;
                        break;

                case 'a':  /*  add new accessor   */
			getaccessor(*argv+1, append);
                        break;

                case 'A':  /*  append access list according to accessfile  */
			*argv += 2;
			if (!**argv) {
			    error("missing file name after -A");
                            break;
                        }
			if (0 < pairfilenames(1,argv,rcsreadopen,true,false)) {
			    while (AccessList) {
				getchaccess(strsave(AccessList->login), append);
				AccessList = AccessList->nextaccess;
			    }
			    ffclose(finptr);
                        }
                        break;

                case 'e':    /*  remove accessors   */
			getaccessor(*argv+1, erase);
                        break;

                case 'l':    /*   lock a revision if it is unlocked   */
                        if ( (*argv)[2] == '\0'){ /* lock head or def. branch */
                            lockhead = true;
                            break;
                        }
			lockpt = talloc(struct Lockrev);
                        lockpt->revno = (*argv)+2;
                        lockpt->nextrev = nil;
                        if ( curlock )
                            curlock->nextrev = lockpt;
                        else
                            newlocklst = lockpt;
                        curlock = lockpt;
                        break;

                case 'u':   /*  release lock of a locked revision   */
                        if ( (*argv)[2] == '\0'){ /*  unlock head  */
                            unlockcaller=true;
                            break;
                        }
			lockpt = talloc(struct Lockrev);
                        lockpt->revno = (*argv)+2;
                        lockpt->nextrev = nil;
                        if (rmvlock)
                            rmvlock->nextrev = lockpt;
                        else
                            rmvlocklst = lockpt;
                        rmvlock = lockpt;

                        curlock = rmnewlocklst(lockpt);
                        break;

                case 'L':   /*  set strict locking */
                        if (strict_selected++) {  /* Already selected L or U? */
			   if (!strictlock)	  /* Already selected -U? */
			       warn("-L overrides -U.");
                        }
                        strictlock = true;
                        break;

                case 'U':   /*  release strict locking */
                        if (strict_selected++) {  /* Already selected L or U? */
			   if (strictlock)	  /* Already selected -L? */
			       warn("-L overrides -U.");
                        }
			else
			    strictlock = false;
                        break;

                case 'n':    /*  add new association: error, if name exists */
                        if ( (*argv)[2] == '\0') {
			    error("missing symbolic name after -n");
                            break;
                        }
                        getassoclst(false, (*argv)+1);
                        break;

                case 'N':   /*  add or change association   */
                        if ( (*argv)[2] == '\0') {
			    error("missing symbolic name after -N");
                            break;
                        }
                        getassoclst(true, (*argv)+1);
                        break;

		case 'o':   /*  delete revisions  */
			if (delrev.strt) redefined('o');
                        if ( (*argv)[2] == '\0' ) {
			    error("missing revision range after -o");
                            break;
                        }
                        getdelrev( (*argv)+1 );
                        break;

                case 's':   /*  change state attribute of a revision  */
                        if ( (*argv)[2] == '\0') {
			    error("state missing after -s");
                            break;
                        }
                        getstates( (*argv)+1);
                        break;

                case 't':   /*  change descriptive text   */
                        textflag=true;
                        if ((*argv)[2]!='\0'){
				if (textfile) redefined('t');
                                textfile = (*argv)+2;
                        }
                        break;

		case 'I':
			interactiveflag = true;
			break;

                case 'q':
                        quietflag = true;
                        break;

		case 'V':
			setRCSversion(*argv);
			break;

		case 'k':    /*  set keyword expand mode  */
			if (0 <= expmode) redefined('k');
			if (0 <= (expmode = str2expmode(*argv+2)))
			    break;
			/* fall into */
                default:
			faterror("unknown option: %s%s", *argv, cmdusage);
                };
        }  /* end processing of options */

	if (argc<1) faterror("no input file%s", cmdusage);
        if (nerror) {
	    diagnose("%s aborted\n",cmdid);
	    exitmain(EXIT_FAILURE);
        }
	if (initflag) {
	    defaultRCSmode = umask((mode_t)0);
	    VOID umask(defaultRCSmode);
	    defaultRCSmode = ~defaultRCSmode & 0444;
	}

        /* now handle all filenames */
        do {
	foutptr = NULL;
        finptr=frewrite=NULL;
	ffree();

        if ( initflag ) {
	    switch (pairfilenames(argc, argv, rcswriteopen, false, false)) {
                case -1: break;        /*  not exist; ok */
                case  0: continue;     /*  error         */
                case  1: error("file %s exists already", RCSfilename);
                         continue;
            }
	}
        else  {
	    switch (pairfilenames(argc, argv, rcswriteopen, true, false)) {
                case -1: continue;    /*  not exist      */
                case  0: continue;    /*  errors         */
                case  1: break;       /*  file exists; ok*/
            }
	}


        /* now RCSfilename contains the name of the RCS file, and
         * workfilename contains the name of the working file.
         * if !initflag, finptr contains the file descriptor for the
         * RCS file. The admin node is initialized.
         */

	diagnose("RCS file: %s\n", RCSfilename);

	if (initflag && !getworkstat())		   continue; /* give up */
	if (!initflag && !checkaccesslist())	   continue; /* give up */

        gettree(); /* read in delta tree */

        /*  update admin. node    */
        if (strict_selected) StrictLocks = strictlock;
	if (commsyml) {
		Comment.string = commsyml;
		Comment.size = strlen(commsyml);
	}
	if (0 <= expmode) Expand = expmode;

        /* update default branch */
	if (branchflag && expandsym(branchsym, &branchnum)) {
	    if (countnumflds(branchnum.string)) {
		Dbranch = branchnum.string;
            } else
                Dbranch = nil;
        }

	updateaccess();		/*  update access list        */

        updateassoc();          /*  update association list   */

        updatelocks();          /*  update locks              */

        /*  update state attribution  */
        if (chgheadstate) {
            /* change state of default branch or head */
            if (Dbranch==nil) {
                if (Head==nil)
		     warn("can't change states in an empty tree");
                else Head->state = headstate;
            } else {
		rcs_setstate(Dbranch,headstate); /* Can't set directly */
            }
        }
        curstate = statelst;
        while( curstate ) {
            rcs_setstate(curstate->revno,curstate->status);
            curstate = curstate->nextstatus;
        }

        cuthead = cuttail = nil;
	if (delrev.strt && removerevs()) {
            /*  rebuild delta tree if some deltas are deleted   */
            if ( cuttail )
		VOID genrevs(cuttail->num, (char *)nil,(char *)nil,
			     (char *)nil, &gendeltas);
            buildtree();
        }


        putadmin(frewrite);
        if ( Head )
           puttree(Head, frewrite);
	putdesc(textflag,textfile);
	foutptr = NULL;

        if ( Head) {
	    if (!delrev.strt) {
                /* no revision deleted */
                fastcopy(finptr,frewrite);
            } else {
		if (!cuttail || buildeltatext(gendeltas))
                    scanlogtext((struct hshentry *)nil,nil);
                    /* copy rest of delta text nodes that are not deleted      */
            }
        }
	if (finptr) {ffclose(finptr); finptr=NULL;} /* Help the file system. */
        ffclose(frewrite);   frewrite = NULL;
        if ( ! nerror ) {  /*  move temporary file to RCS file if no error */
	    /* update mode */
	    seteid();
	    r = chmod(newRCSfilename,
			 (
			       !initflag ? RCSstat.st_mode
			     : haveworkstat==0 ? workstat.st_mode
			     : defaultRCSmode
			 ) & ~(S_IWUSR|S_IWGRP|S_IWOTH)
	    );
	    if (r == 0) {
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
	    diagnose("done\n");
        } else {
	    diagnose("%s aborted; %s unchanged.\n",cmdid,RCSfilename);
        }
	} while (cleanup(),
                 ++argv, --argc >=1);

	tempunlink();
	exitmain(exitstatus);
}       /* end of main (rcs) */

	static void
cleanup()
{
	if (nerror) exitstatus = EXIT_FAILURE;
	if (finptr) ffclose(finptr);
	if (frewrite) ffclose(frewrite);
	dirtempunlink();
}

	exiting void
exiterr()
{
	dirtempunlink();
	tempunlink();
	_exit(EXIT_FAILURE);
}


	static void
getassoclst(flag, sp)
int     flag;
char    * sp;
/*  Function:   associate a symbolic name to a revision or branch,      */
/*              and store in assoclst                                   */

{
        struct   Symrev  * pt;
	const char *temp;
        int                c;

        while( (c=(*++sp)) == ' ' || c == '\t' || c =='\n')  ;
        temp = sp;
	sp = checkid(sp, ':');  /*  check for invalid symbolic name  */
	c = *sp;   *sp = '\0';
        while( c == ' ' || c == '\t' || c == '\n')  c = *++sp;

        if ( c != ':' && c != '\0') {
	    error("invalid string %s after option -n or -N",sp);
            return;
        }

	pt = talloc(struct Symrev);
        pt->ssymbol = temp;
        pt->override = flag;
	if (c == '\0')  /*  delete symbol  */
            pt->revno = nil;
        else {
            while( (c = *++sp) == ' ' || c == '\n' || c == '\t')  ;
	    if ( c == '\0' )
                pt->revno = nil;
	    else
                pt->revno = sp;
        }
        pt->nextsym = nil;
        if (lastassoc)
            lastassoc->nextsym = pt;
        else
            assoclst = pt;
        lastassoc = pt;
        return;
}


	static void
getchaccess(login, command)
	const char *login;
	enum changeaccess command;
{
	register struct chaccess *pt;

	*nextchaccess = pt = talloc(struct chaccess);
	pt->login = login;
	pt->command = command;
	pt->nextchaccess = nil;
	nextchaccess = &pt->nextchaccess;
}



	static void
getaccessor(opt, command)
	char *opt;
	enum changeaccess command;
/*   Function:  get the accessor list of options -e and -a,     */
/*		and store in chaccess				*/


{
        register c;
	register char *sp;

	sp = opt;
        while( ( c = *++sp) == ' ' || c == '\n' || c == '\t' || c == ',') ;
        if ( c == '\0') {
	    if (command == erase  &&  sp-opt == 1) {
		getchaccess((const char*)nil, command);
		return;
	    }
	    error("missing login name after option -a or -e");
	    return;
        }

        while( c != '\0') {
		getchaccess(sp, command);
		sp = checkid(sp,',');
		c = *sp;   *sp = '\0';
                while( c == ' ' || c == '\n' || c == '\t'|| c == ',')c =(*++sp);
        }
}



	static void
getstates(sp)
char    *sp;
/*   Function:  get one state attribute and the corresponding   */
/*              revision and store in statelst                  */

{
	const char *temp;
        struct  Status  *pt;
        register        c;

        while( (c=(*++sp)) ==' ' || c == '\t' || c == '\n')  ;
        temp = sp;
	sp = checkid(sp,':');  /* check for invalid state attribute */
	c = *sp;   *sp = '\0';
        while( c == ' ' || c == '\t' || c == '\n' )  c = *++sp;

        if ( c == '\0' ) {  /*  change state of def. branch or Head  */
            chgheadstate = true;
            headstate  = temp;
            return;
        }
        else if ( c != ':' ) {
	    error("missing ':' after state in option -s");
            return;
        }

        while( (c = *++sp) == ' ' || c == '\t' || c == '\n')  ;
	pt = talloc(struct Status);
        pt->status     = temp;
        pt->revno      = sp;
        pt->nextstatus = nil;
        if (laststate)
            laststate->nextstatus = pt;
        else
            statelst = pt;
        laststate = pt;
}



	static void
getdelrev(sp)
char    *sp;
/*   Function:  get revision range or branch to be deleted,     */
/*              and place in delrev                             */
{
        int    c;
        struct  delrevpair      *pt;

	pt = &delrev;
        while((c = (*++sp)) == ' ' || c == '\n' || c == '\t') ;

        if ( c == '<' || c == '-' ) {  /*  -o  -rev  or <rev  */
            while( (c = (*++sp)) == ' ' || c == '\n' || c == '\t')  ;
            pt->strt = sp;    pt->code = 1;
            while( c != ' ' && c != '\n' && c != '\t' && c != '\0') c =(*++sp);
            *sp = '\0';
	    pt->end = nil;
            return;
        }
        else {
            pt->strt = sp;
            while( c != ' ' && c != '\n' && c != '\t' && c != '\0'
                   && c != '-' && c != '<' )  c = *++sp;
            *sp = '\0';
            while( c == ' ' || c == '\n' || c == '\t' )  c = *++sp;
            if ( c == '\0' )  {  /*   -o rev or branch   */
                pt->end = nil;   pt->code = 0;
                return;
            }
            if ( c != '-' && c != '<') {
		faterror("invalid range %s %s after -o", pt->strt, sp);
            }
            while( (c = *++sp) == ' ' || c == '\n' || c == '\t')  ;
            if ( c == '\0') {  /*  -o   rev-   or   rev<   */
                pt->end = nil;   pt->code = 2;
                return;
            }
        }
        /*   -o   rev1-rev2    or   rev1<rev2   */
	pt->end = sp;  pt->code = 3;
        while( c!= ' ' && c != '\n' && c != '\t' && c != '\0') c = *++sp;
        *sp = '\0';
}




	static void
scanlogtext(delta,edit)
	struct hshentry *delta;
	int edit;
/* Function: Scans delta text nodes up to and including the one given
 * by delta, or up to last one present, if delta==nil.
 * For the one given by delta (if delta!=nil), the log message is saved into
 * curlogmsg and the text is edited if 'edit' is set, copied otherwise.
 * Assumes the initial lexeme must be read in first.
 * Does not advance nexttok after it is finished, except if delta==nil.
 */
{
	const struct hshentry *nextdelta;
	struct cbuf cb;

	for (;;) {
		foutptr = NULL;
                nextlex();
                if (!(nextdelta=getnum())) {
                    if(delta)
			faterror("can't find delta for revision %s", delta->num);
		    if (nexttok != EOFILE)
			fatserror("expecting EOF");
		    return; /* no more delta text nodes */
                }
		if (nextdelta->selector) {
			foutptr = frewrite;
			aprintf(frewrite,DELNUMFORM,nextdelta->num,Klog);
                }
		getkeystring(Klog);
		if (delta==nextdelta) {
			cb = savestring(&curlogbuf);
			delta->log = curlogmsg =
				cleanlogmsg(curlogbuf.string, cb.size);
                } else {readstring();
                }
                nextlex();
		while (nexttok==ID && strcmp(NextString,Ktext)!=0)
			ignorephrase();
		getkeystring(Ktext);

		if (delta==nextdelta)
			break;
		readstring(); /* skip over it */

	}
	/* got the one we're looking for */
	if (edit)
		editstring((struct hshentry *)nil);
	else
		copystring();
}



	static struct Lockrev *
rmnewlocklst(which)
	const struct Lockrev *which;
/*   Function:  remove lock to revision which->revno from newlocklst   */

{
        struct  Lockrev   * pt, *pre;

        while( newlocklst && (! strcmp(newlocklst->revno, which->revno))){
	    struct Lockrev *pn = newlocklst->nextrev;
	    tfree(newlocklst);
	    newlocklst = pn;
        }

        pt = pre = newlocklst;
        while( pt ) {
            if ( ! strcmp(pt->revno, which->revno) ) {
                pre->nextrev = pt->nextrev;
		tfree(pt);
		pt = pre->nextrev;
            }
            else {
                pre = pt;
                pt = pt->nextrev;
            }
        }
        return pre;
}



	static void
updateaccess()
{
	register struct chaccess *ch;
	register struct access **p, *t;

	for (ch = chaccess;  ch;  ch = ch->nextchaccess) {
		switch (ch->command) {
		case erase:
			if (!ch->login)
			    AccessList = nil;
			else
			    for (p = &AccessList;  (t = *p);  )
				if (strcmp(ch->login, t->login) == 0)
					*p = t->nextaccess;
				else
					p = &t->nextaccess;
			break;
		case append:
			for (p = &AccessList;  ;  p = &t->nextaccess)
				if (!(t = *p)) {
					*p = t = ftalloc(struct access);
					t->login = ch->login;
					t->nextaccess = nil;
					break;
				} else if (strcmp(ch->login, t->login) == 0)
					break;
			break;
		}
	}
}


	static int
sendmail(Delta, who)
	const char *Delta, *who;
/*   Function:  mail to who, informing him that his lock on delta was
 *   broken by caller. Ask first whether to go ahead. Return false on
 *   error or if user decides not to break the lock.
 */
{
#if !DONT_SEND_MAIL
	const char *messagefile;
	int old1, old2, c;
        FILE    * mailmess;
#endif

	aprintf(stderr, "Revision %s is already locked by %s.\n", Delta, who);
	if (!yesorno(false, "Do you want to break the lock? [ny](n): "))
		return false;

        /* go ahead with breaking  */

#if !DONT_SEND_MAIL
	messagefile = maketemp(0);
	errno = 0;
        if ( (mailmess = fopen(messagefile, "w")) == NULL) {
	    efaterror(messagefile);
        }

	aprintf(mailmess, "Subject: Broken lock on %s\n\nYour lock on revision %s of file %s\nhas been broken by %s for the following reason:\n",
		bindex(RCSfilename,SLASH), Delta, getfullRCSname(), getcaller()
	);
	aputs("State the reason for breaking the lock:\n(terminate with single '.' or end of file)\n>> ", stderr);

        old1 = '\n';    old2 = ' ';
        for (; ;) {
	    c = getcstdin();
            if ( c == EOF ) {
		aprintf(mailmess, "%c\n", old1);
                break;
            }
            else if ( c == '\n' && old1 == '.' && old2 == '\n')
                break;
            else {
		afputc(old1, mailmess);
                old2 = old1;   old1 = c;
		if (c=='\n') aputs(">> ", stderr);
            }
        }
        ffclose(mailmess);

	/* ignore the exit status, even if delivermail unsuccessful */
	VOID run(messagefile, (char*)nil, SENDMAIL, who, (char*)nil);

#else
	/* this is the DONT_SEND_MAIL case */
	aprintf(stderr,"Please tell %s that you broke the lock and why.",who);
#endif
	return(true);
}



	static void
breaklock(delta)
	const struct hshentry *delta;
/* function: Finds the lock held by caller on delta,
 * and removes it.
 * Sends mail if a lock different from the caller's is broken.
 * Prints an error message if there is no such lock or error.
 */
{
        register struct lock * next, * trail;
	const char *num;
        struct lock dummy;

	num=delta->num;
        dummy.nextlock=next=Locks;
        trail = &dummy;
        while (next!=nil) {
		if (strcmp(num, next->delta->num) == 0) {
			if (
				strcmp(getcaller(),next->login) != 0
			    &&	!sendmail(num, next->login)
			) {
			    error("%s still locked by %s", num, next->login);
			    return;
			}
			break; /* exact match */
                }
                trail=next;
                next=next->nextlock;
        }
        if (next!=nil) {
                /*found one */
		diagnose("%s unlocked\n",next->delta->num);
                trail->nextlock=next->nextlock;
                next->delta->lockedby=nil;
                Locks=dummy.nextlock;
        } else  {
		error("no lock set on revision %s", num);
        }
}



	static struct hshentry *
searchcutpt(object, length, store)
	const char *object;
	unsigned length;
	struct hshentries *store;
/*   Function:  Search store and return entry with number being object. */
/*              cuttail = nil, if the entry is Head; otherwise, cuttail */
/*              is the entry point to the one with number being object  */

{
	cuthead = nil;
	while (compartial(store->first->num, object, length)) {
		cuthead = store->first;
		store = store->rest;
	}
	return store->first;
}



	static int
branchpoint(strt, tail)
struct  hshentry        *strt,  *tail;
/*   Function: check whether the deltas between strt and tail	*/
/*		are locked or branch point, return 1 if any is  */
/*		locked or branch point; otherwise, return 0 and */
/*		mark deleted					*/

{
        struct  hshentry    *pt;
	const struct lock *lockpt;
        int     flag;


        pt = strt;
        flag = false;
        while( pt != tail) {
            if ( pt->branches ){ /*  a branch point  */
                flag = true;
		error("can't remove branch point %s", pt->num);
            }
	    lockpt = Locks;
	    while(lockpt && lockpt->delta != pt)
		lockpt = lockpt->nextlock;
	    if ( lockpt ) {
		flag = true;
		error("can't remove locked revision %s",pt->num);
	    }
            pt = pt->next;
        }

        if ( ! flag ) {
            pt = strt;
            while( pt != tail ) {
		pt->selector = false;
		diagnose("deleting revision %s\n",pt->num);
                pt = pt->next;
            }
        }
        return flag;
}



	static int
removerevs()
/*   Function:  get the revision range to be removed, and place the     */
/*              first revision removed in delstrt, the revision before  */
/*              delstrt in cuthead( nil, if delstrt is head), and the   */
/*              revision after the last removed revision in cuttail(nil */
/*              if the last is a leaf                                   */

{
	struct  hshentry *target, *target2, *temp;
	unsigned length;
	int flag;

        flag = false;
	if (!expandsym(delrev.strt, &numrev)) return 0;
	target = genrevs(numrev.string, (char*)nil, (char*)nil, (char*)nil, &gendeltas);
        if ( ! target ) return 0;
	if (cmpnum(target->num, numrev.string)) flag = true;
	length = countnumflds(numrev.string);

	if (delrev.code == 0) {  /*  -o  rev    or    -o  branch   */
	    if (length & 1)
		temp=searchcutpt(target->num,length+1,gendeltas);
	    else if (flag) {
		error("Revision %s doesn't exist.", numrev.string);
		return 0;
	    }
	    else
		temp = searchcutpt(numrev.string, length, gendeltas);
	    cuttail = target->next;
            if ( branchpoint(temp, cuttail) ) {
                cuttail = nil;
                return 0;
            }
            delstrt = temp;     /* first revision to be removed   */
            return 1;
        }

	if (length & 1) {   /*  invalid branch after -o   */
	    error("invalid branch range %s after -o", numrev.string);
            return 0;
        }

	if (delrev.code == 1) {  /*  -o  -rev   */
            if ( length > 2 ) {
                temp = searchcutpt( target->num, length-1, gendeltas);
                cuttail = target->next;
            }
            else {
                temp = searchcutpt(target->num, length, gendeltas);
                cuttail = target;
                while( cuttail && ! cmpnumfld(target->num,cuttail->num,1) )
                    cuttail = cuttail->next;
            }
            if ( branchpoint(temp, cuttail) ){
                cuttail = nil;
                return 0;
            }
            delstrt = temp;
            return 1;
        }

	if (delrev.code == 2) {   /*  -o  rev-   */
            if ( length == 2 ) {
                temp = searchcutpt(target->num, 1,gendeltas);
                if ( flag)
                    cuttail = target;
                else
                    cuttail = target->next;
            }
            else  {
                if ( flag){
                    cuthead = target;
                    if ( !(temp = target->next) ) return 0;
                }
                else
                    temp = searchcutpt(target->num, length, gendeltas);
		getbranchno(temp->num, &numrev);  /* get branch number */
		target = genrevs(numrev.string, (char*)nil, (char*)nil, (char*)nil, &gendeltas);
            }
            if ( branchpoint( temp, cuttail ) ) {
                cuttail = nil;
                return 0;
            }
            delstrt = temp;
            return 1;
        }

        /*   -o   rev1-rev2   */
	if (!expandsym(delrev.end, &numrev)) return 0;
	if (
		length != countnumflds(numrev.string)
	    ||	length>2 && compartial(numrev.string, target->num, length-1)
	) {
	    error("invalid revision range %s-%s", target->num, numrev.string);
            return 0;
        }

	target2 = genrevs(numrev.string,(char*)nil,(char*)nil,(char*)nil,&gendeltas);
        if ( ! target2 ) return 0;

        if ( length > 2) {  /* delete revisions on branches  */
            if ( cmpnum(target->num, target2->num) > 0) {
		if (cmpnum(target2->num, numrev.string))
                    flag = true;
                else
                    flag = false;
                temp = target;
                target = target2;
                target2 = temp;
            }
            if ( flag ) {
                if ( ! cmpnum(target->num, target2->num) ) {
		    error("Revisions %s-%s don't exist.", delrev.strt,delrev.end);
                    return 0;
                }
                cuthead = target;
                temp = target->next;
            }
            else
                temp = searchcutpt(target->num, length, gendeltas);
            cuttail = target2->next;
        }
        else { /*  delete revisions on trunk  */
            if ( cmpnum( target->num, target2->num) < 0 ) {
                temp = target;
                target = target2;
                target2 = temp;
            }
            else
		if (cmpnum(target2->num, numrev.string))
                    flag = true;
                else
                    flag = false;
            if ( flag ) {
                if ( ! cmpnum(target->num, target2->num) ) {
		    error("Revisions %s-%s don't exist.", delrev.strt, delrev.end);
                    return 0;
                }
                cuttail = target2;
            }
            else
                cuttail = target2->next;
            temp = searchcutpt(target->num, length, gendeltas);
        }
        if ( branchpoint(temp, cuttail) )  {
            cuttail = nil;
            return 0;
        }
        delstrt = temp;
        return 1;
}



	static void
updateassoc()
/*   Function: add or delete(if revno is nil) association	*/
/*		which is stored in assoclst			*/

{
	const struct Symrev *curassoc;
	struct  assoc   * pre,  * pt;

        /*  add new associations   */
        curassoc = assoclst;
        while( curassoc ) {
            if ( curassoc->revno == nil ) {  /* delete symbol  */
		pre = pt = Symbols;
                while( pt && strcmp(pt->symbol,curassoc->ssymbol) ) {
		    pre = pt;
		    pt = pt->nextassoc;
		}
		if ( pt )
		    if ( pre == pt )
			Symbols = pt->nextassoc;
		    else
			pre->nextassoc = pt->nextassoc;
		else
		    warn("can't delete nonexisting symbol %s",curassoc->ssymbol);
	    }
	    else if (expandsym(curassoc->revno, &numrev)) {
	    /*   add symbol  */
		VOID addsymbol(fstrsave(numrev.string), curassoc->ssymbol, curassoc->override);
            }
            curassoc = curassoc->nextsym;
        }

}



	static void
updatelocks()
/* Function: remove lock for caller or first lock if unlockcaller is set;
 *           remove locks which are stored in rmvlocklst,
 *           add new locks which are stored in newlocklst,
 *           add lock for Dbranch or Head if lockhead is set.
 */
{
	const struct Lockrev *lockpt;
	struct hshentry *target;

	if (unlockcaller) { /*  find lock for caller  */
            if ( Head ) {
		if (Locks) {
		    switch (findlock(true, &target)) {
		      case 0:
			breaklock(Locks->delta); /* remove most recent lock */
			break;
		      case 1:
			diagnose("%s unlocked\n",target->num);
			break;
		    }
		} else {
		    warn("No locks are set.");
		}
            } else {
		warn("can't unlock an empty tree");
            }
        }

        /*  remove locks which are stored in rmvlocklst   */
        lockpt = rmvlocklst;
        while( lockpt ) {
	    if (expandsym(lockpt->revno, &numrev)) {
		target = genrevs(numrev.string, (char *)nil, (char *)nil, (char *)nil, &gendeltas);
                if ( target )
		   if (!(countnumflds(numrev.string)&1) && cmpnum(target->num,numrev.string))
			error("can't unlock nonexisting revision %s",lockpt->revno);
                   else
			breaklock(target);
                        /* breaklock does its own diagnose */
            }
            lockpt = lockpt->nextrev;
        }

        /*  add new locks which stored in newlocklst  */
        lockpt = newlocklst;
        while( lockpt ) {
	    setlock(lockpt->revno);
            lockpt = lockpt->nextrev;
        }

	if (lockhead) {  /*  lock default branch or head  */
            if (Dbranch) {
		setlock(Dbranch);
	    } else if (Head) {
		if (0 <= addlock(Head))
		    diagnose("%s locked\n",Head->num);
            } else {
		warn("can't lock an empty tree");
            }
        }

}



	static void
setlock(rev)
	const char *rev;
/* Function: Given a revision or branch number, finds the corresponding
 * delta and locks it for caller.
 */
{
        struct  hshentry *target;

	if (expandsym(rev, &numrev)) {
	    target = genrevs(numrev.string, (char*)nil, (char*)nil,
			     (char*)nil, &gendeltas);
            if ( target )
	       if (!(countnumflds(numrev.string)&1) && cmpnum(target->num,numrev.string))
		    error("can't lock nonexisting revision %s", numrev.string);
               else
		    if (0 <= addlock(target))
			diagnose("%s locked\n", target->num);
        }
}



	static void
rcs_setstate(rev,status)
	const char *rev, *status;
/* Function: Given a revision or branch number, finds the corresponding delta
 * and sets its state to status.
 */
{
        struct  hshentry *target;

	if (expandsym(rev, &numrev)) {
	    target = genrevs(numrev.string, (char*)nil, (char*)nil,
			     (char*)nil, &gendeltas);
            if ( target )
	       if (!(countnumflds(numrev.string)&1) && cmpnum(target->num,numrev.string))
		    error("can't set state of nonexisting revision %s to %s",
			  numrev.string, status);
               else
                    target->state = status;
        }
}





	static int
buildeltatext(deltas)
	const struct hshentries *deltas;
/*   Function:  put the delta text on frewrite and make necessary   */
/*              change to delta text                                */
{
	int exit_stats;
	register FILE *fcut;	/* temporary file to rebuild delta tree */
	const char *cutfilename, *diffilename;

	cutfilename = nil;
	cuttail->selector = false;
	inittmpeditfiles();
	scanlogtext(deltas->first, false);
        if ( cuthead )  {
	    cutfilename = maketemp(3);
	    errno = 0;
            if ( (fcut = fopen(cutfilename, "w")) == NULL) {
		efaterror(cutfilename);
            }

	    while (deltas->first != cuthead) {
		deltas = deltas->rest;
		scanlogtext(deltas->first, true);
            }

	    finishedit((struct hshentry *)nil);
	    arewind(fcopy);
	    fastcopy(fcopy, fcut);
            swapeditfiles(false);
            ffclose(fcut);
        }

	while (deltas->first != cuttail)
	    scanlogtext((deltas = deltas->rest)->first, true);
        finishedit((struct hshentry *)nil);    ffclose(fcopy);

        if ( cuthead ) {
	    diffilename = maketemp(0);
            exit_stats = run((char*)nil,diffilename,
			DIFF DIFF_FLAGS, cutfilename, resultfile, (char*)nil);
	    if (!WIFEXITED(exit_stats) || 1<WEXITSTATUS(exit_stats))
                faterror ("diff failed");
	    return putdtext(cuttail->num,curlogmsg,diffilename,frewrite,true);
	} else
	    return putdtext(cuttail->num,curlogmsg,resultfile,frewrite,false);
}



	static void
buildtree()
/*   Function:  actually removes revisions whose selector field  */
/*		is false, and rebuilds the linkage of deltas.	 */
/*              asks for reconfirmation if deleting last revision*/
{
	struct	hshentry   * Delta;
        struct  branchhead      *pt, *pre;

        if ( cuthead )
           if ( cuthead->next == delstrt )
                cuthead->next = cuttail;
           else {
                pre = pt = cuthead->branches;
                while( pt && pt->hsh != delstrt )  {
                    pre = pt;
                    pt = pt->nextbranch;
                }
                if ( cuttail )
                    pt->hsh = cuttail;
                else if ( pt == pre )
                    cuthead->branches = pt->nextbranch;
                else
                    pre->nextbranch = pt->nextbranch;
            }
	else {
            if ( cuttail == nil && !quietflag) {
		if (!yesorno(false, "Do you really want to delete all revisions? [ny](n): ")) {
		    error("No revision deleted");
		    Delta = delstrt;
		    while( Delta) {
			Delta->selector = true;
			Delta = Delta->next;
		    }
		    return;
		}
	    }
            Head = cuttail;
	}
        return;
}

#if lint
/* This lets us lint everything all at once. */

const char cmdid[] = "";

#define go(p,e) {int p P((int,char**)); void e P((void)); if(*argv)return p(argc,argv);if(*argv[1])e();return 0;}

	int
main(argc, argv)
	int argc;
	char **argv;
{
	switch (argc) {
		case 0:	go(ciId,	ciExit);
		case 1:	go(coId,	coExit);
		case 2:	go(identId,	identExit);
		case 3:	go(rcsdiffId,	rdiffExit);
		case 4:	go(rcsmergeId,	rmergeExit);
		case 5:	go(rlogId,	rlogExit);
		case 6:	go(rcsId,	exiterr);
		default: return 0;
	}
}
#endif
