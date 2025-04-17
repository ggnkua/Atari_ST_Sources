/*
 *                       RLOG    operation
 */
/*****************************************************************************
 *                       print contents of RCS files
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




/* $Log: rlog.c,v $
 * Revision 5.8  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.7  91/01/30  12:02:48  apratt
 * Changed RCS5AKP1 to RCS5AP1
 * 
 * Revision 5.6  91/01/29  17:45:26  apratt
 * Added RCS5AKP1 to usage message
 * 
 * Revision 5.5  90/11/01  05:03:55  eggert
 * checked in with -k by apratt at 91.01.10.13.15.34.
 * 
 * Revision 5.5  1990/11/01  05:03:55  eggert
 * Permit arbitrary data in logs and comment leaders.
 *
 * Revision 5.4  1990/10/04  06:30:22  eggert
 * Accumulate exit status across files.
 *
 * Revision 5.3  1990/09/11  02:41:16  eggert
 * Plug memory leak.
 *
 * Revision 5.2  1990/09/04  08:02:33  eggert
 * Count RCS lines better.
 *
 * Revision 5.0  1990/08/22  08:13:48  eggert
 * Remove compile-time limits; use malloc instead.  Add setuid support.
 * Switch to GMT.
 * Report dates in long form, to warn about dates past 1999/12/31.
 * Change "added/del" message to make room for the longer dates.
 * Don't generate trailing white space.  Add -V.  Ansify and Posixate.
 *
 * Revision 4.7  89/05/01  15:13:48  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.6  88/08/09  19:13:28  eggert
 * Check for memory exhaustion; don't access freed storage.
 * Shrink stdio code size; remove lint.
 * 
 * Revision 4.5  87/12/18  11:46:38  narten
 * more lint cleanups (Guy Harris)
 * 
 * Revision 4.4  87/10/18  10:41:12  narten
 * Updating version numbers
 * Changes relative to 1.1 actually relative to 4.2
 * 
 * Revision 1.3  87/09/24  14:01:10  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:22:45  jenkins
 * Port to suns
 * 
 * Revision 4.2  83/12/05  09:18:09  wft
 * changed rewriteflag to external.
 * 
 * Revision 4.1  83/05/11  16:16:55  wft
 * Added -b, updated getnumericrev() accordingly.
 * Replaced getpwuid() with getcaller().
 * 
 * Revision 3.7  83/05/11  14:24:13  wft
 * Added options -L and -R;
 * Fixed selection bug with -l on multiple files.
 * Fixed error on dates of the form -d'>date' (rewrote getdatepair()).
 * 
 * Revision 3.6  82/12/24  15:57:53  wft
 * shortened output format.
 *
 * Revision 3.5  82/12/08  21:45:26  wft
 * removed call to checkaccesslist(); used DATEFORM to format all dates;
 * removed unused variables.
 *
 * Revision 3.4  82/12/04  13:26:25  wft
 * Replaced getdelta() with gettree(); removed updating of field lockedby.
 *
 * Revision 3.3  82/12/03  14:08:20  wft
 * Replaced getlogin with getpwuid(), %02d with %.2d, fancydate with PRINTDATE.
 * Fixed printing of nil, removed printing of Suffix,
 * added shortcut if no revisions are printed, disambiguated struct members.
 *
 * Revision 3.2  82/10/18  21:09:06  wft
 * call to curdir replaced with getfullRCSname(),
 * fixed call to getlogin(), cosmetic changes on output,
 * changed conflicting long identifiers.
 *
 * Revision 3.1  82/10/13  16:07:56  wft
 * fixed type of variables receiving from getc() (char -> int).
 */



#include "rcsbase.h"

struct  lockers {                     /* lockers in locker option; stored   */
     const char         * login;      /* lockerlist                         */
     struct     lockers * lockerlink;
     }  ;

struct  stateattri {                  /* states in state option; stored in  */
     const char         * status;     /* statelist                          */
     struct  stateattri * nextstate;
     }  ;

struct  authors {                     /* login names in author option;      */
     const char         * login;      /* stored in authorlist               */
     struct     authors * nextauthor;
     }  ;

struct Revpairs{                      /* revision or branch range in -r     */
     unsigned		  numfld;     /* option; stored in revlist	    */
     const char         * strtrev;
     const char         * endrev;
     struct  Revpairs   * rnext;
     } ;

struct Datepairs{                     /* date range in -d option; stored in */
     char               strtdate[datesize];   /* duelst and datelist      */
     char               enddate[datesize];
     struct  Datepairs  * dnext;
     };

static char extractdelta P((const struct hshentry*));
static int checkrevpair P((const char*,const char*));
static int readdeltalog P((void));
static void cleanup P((void));
static void extdate P((struct hshentry*));
static void exttree P((struct hshentry*));
static void getauthor P((char*));
static void getdatepair P((char*));
static void getlocker P((char*));
static void getnumericrev P((void));
static void getrevpairs P((char*));
static void getscript P((struct hshentry*));
static void getstate P((char*));
static void putabranch P((const struct hshentry*));
static void putadelta P((const struct hshentry*,const struct hshentry*,int));
static void putforest P((const struct branchhead*));
static void putree P((const struct hshentry*));
static void putrunk P((void));
static void recentdate P((const struct hshentry*,struct Datepairs*));
static void trunclocks P((void));

static const char *insDelFormat;
static int branchflag;	/*set on -b */
static int exitstatus;
static int lockflag;
static int revno;	/* number of revision chosen */
static struct Datepairs *datelist, *duelst;
static struct Revpairs *revlist, *Revlst;
static struct authors *authorlist;
static struct lockers *lockerlist;
static struct stateattri *statelist;


mainProg(rlogId, "rlog", "$Id: rlog.c,v 5.8 1991/01/30 14:21:32 apratt Exp $")
{
	static const char cmdusage[] =
		"\nRCS5AP1 as modified for TOS by Allan Pratt, atari!apratt\nrlog usage: rlog -{bhLRt} -ddates -l[lockers] -rrevs -sstates -w[logins] -Vn file ...";

	struct Datepairs *currdate;
	const char *accessListString, *accessFormat, *commentFormat;
	const char *headFormat, *symbolFormat;
	const struct access *curaccess;
	const struct assoc *curassoc;
	const struct lock *currlock;
	int descflag, selectflag;
	int onlylockflag;  /* print only files with locks */
	int selectop;  /* print only some revisions */
	int onlyRCSflag;  /* print only RCS file name */

	initid();

        descflag = selectflag = true;
	onlylockflag = selectop = onlyRCSflag = false;

        while (--argc,++argv, argc>=1 && ((*argv)[0] == '-')) {
                switch ((*argv)[1]) {

		case 'L':
			onlylockflag = true;
			break;

		case 'R':
			onlyRCSflag =true;
			break;

                case 'l':
                        selectop = true;
                        lockflag = true;
                        getlocker( (*argv)+2 );
                        break;

                case 'b':
                        selectop = true;
                        branchflag = true;
                        break;

                case 'r':
                        selectop = true;
                        getrevpairs( (*argv)+2 );
                        break;

                case 'd':
                        selectop = true;
                        getdatepair( (*argv)+2 );
                        break;

                case 's':
                        selectop = true;
                        getstate( (*argv)+2);
                        break;

                case 'w':
                        selectop = true;
                        getauthor( (*argv)+2);
                        break;

                case 'h':
                        if ( ! selectflag ) warn("-t overrides -h.");
                        else    descflag = false;
                        break;

                case 't':
                        selectflag = false;
                        if ( ! descflag ) warn("-t overrides -h.");
                        descflag = true;
                        break;

		case 'V':
			setRCSversion(*argv);
			break;

                default:
			faterror("unknown option: %s%s", *argv, cmdusage);

                };
        } /* end of option processing */

	if (argc<1) faterror("no input file%s", cmdusage);

	if (RCSversion < VERSION(5)) {
	    accessListString = "\naccess list:   ";
	    accessFormat = "  %s";
	    commentFormat = "\ncomment leader:  \"";
	    headFormat = "\nRCS file:        %s;   Working file:    %s\nhead:           %s%s\nbranch:         %s%s\nlocks:         ";
	    insDelFormat = "  lines added/del: %lu/%lu";
	    symbolFormat = "  %s: %s;";
	} else {
	    accessListString = "\naccess list:";
	    accessFormat = "\n\t%s";
	    commentFormat = "\ncomment leader: \"";
	    headFormat = "\nRCS file: %s\nWorking file: %s\nhead:%s%s\nbranch:%s%s\nlocks:%s";
	    insDelFormat = "  lines: +%lu -%lu";
	    symbolFormat = "\n\t%s: %s";
	}

        /* now handle all filenames */
        do {
	    finptr = NULL;
	    ffree();

	    if (!pairfilenames(argc, argv, rcsreadopen, true, false))
		continue;

            /* now RCSfilename contains the name of the RCS file, and finptr
             * the file descriptor. Workfilename contains the name of the
             * working file.
             */

	    /* Keep only those locks given by -l.  */
	    if (lockflag)
		trunclocks();

            /* do nothing if -L is given and there are no locks*/
	    if (onlylockflag && !Locks)
		continue;

	    if ( onlyRCSflag ) {
		aprintf(stdout, "%s\n", RCSfilename);
		continue;
	    }
            /*   print RCS filename , working filename and optional
                 administrative information                         */
            /* could use getfullRCSname() here, but that is very slow */
	    aprintf(stdout, headFormat, RCSfilename, workfilename,
		    Head ? " " : "",  Head ? Head->num : "",
		    Dbranch ? " " : "",  Dbranch ? Dbranch : "",
		    StrictLocks ? " strict" : ""
	    );
            currlock = Locks;
            while( currlock ) {
		aprintf(stdout, symbolFormat, currlock->login,
                                currlock->delta->num);
                currlock = currlock->nextlock;
            }
            if (StrictLocks && RCSversion<VERSION(5))
		aputs("  strict", stdout);

	    aputs(accessListString, stdout);      /*  print access list  */
            curaccess = AccessList;
            while(curaccess) {
		aprintf(stdout, accessFormat, curaccess->login);
                curaccess = curaccess->nextaccess;
            }

	    aputs("\nsymbolic names:", stdout);   /*  print symbolic names   */
	    for (curassoc=Symbols; curassoc; curassoc=curassoc->nextassoc)
		aprintf(stdout, symbolFormat, curassoc->symbol, curassoc->num);
	    aputs(commentFormat, stdout);
	    awrite(Comment.string, Comment.size, stdout);
	    aputs("\"\n", stdout);
	    if (VERSION(5)<=RCSversion  ||  Expand != KEYVAL_EXPAND)
		aprintf(stdout, "keyword substitution: %s\n",
			expand_names[Expand]
		);

            gettree();

	    aprintf(stdout, "total revisions: %d", TotalDeltas);

            if ( Head == nil || !selectflag || !descflag) {
		afputc('\n',stdout);
		if (descflag) aputs("description:\n", stdout);
                getdesc(descflag);
		goto rlogend;
            }


            getnumericrev();    /* get numeric revision or branch names */
            revno = 0;

            exttree(Head);

            /*  get most recently date of the dates pointed by duelst  */
            currdate = duelst;
            while( currdate) {
                recentdate(Head, currdate);
                currdate = currdate->dnext;
	    }

            extdate(Head);

            /*  reinitialize the date specification list   */
            currdate = duelst;
            while(currdate) {
                VOID sprintf(currdate->strtdate,DATEFORM,0,0,0,0,0,0);
                currdate = currdate->dnext;
            }

            if ( selectop || ( selectflag && descflag) )
		aprintf(stdout, ";\tselected revisions: %d", revno);
	    afputc('\n', stdout);
	    if (descflag) aputs("description:\n", stdout);
            getdesc(descflag);
            if (selectflag && descflag && revno) {
		while (readdeltalog())
		    ;
                putrunk();
                putree(Head);
		if (nexttok != EOFILE)
		    fatserror("expecting EOF");
            }
	rlogend:
	    aputs("=============================================================================\n",stdout);
	} while (cleanup(),
		 ++argv, --argc >= 1);
	exitmain(exitstatus);
}

	static void
cleanup()
{
	if (nerror) exitstatus = EXIT_FAILURE;
	if (finptr) ffclose(finptr);
}

#if lint
#	define exiterr rlogExit
#endif
	exiting void
exiterr()
{
	_exit(EXIT_FAILURE);
}



	static void
putrunk()
/*  function:  print revisions chosen, which are in trunk      */

{
	register const struct hshentry *ptr;

	for (ptr = Head;  ptr;  ptr = ptr->next)
		putadelta(ptr, ptr->next, true);
}



	static void
putree(root)
	const struct hshentry *root;
/*   function: print delta tree (not including trunk) in reverse
               order on each branch                                        */

{
        if ( root == nil ) return;

        putree(root->next);

        putforest(root->branches);
}




	static void
putforest(branchroot)
	const struct branchhead *branchroot;
/*   function:  print branches that has the same direct ancestor    */
{

        if ( branchroot == nil ) return;

        putforest(branchroot->nextbranch);

        putabranch(branchroot->hsh);
        putree(branchroot->hsh);
}




	static void
putabranch(root)
	const struct hshentry *root;
/*   function  :  print one branch     */

{

        if ( root == nil) return;

        putabranch(root->next);

        putadelta(root, root, false);
}





	static void
putadelta(node,editscript,trunk)
	register const struct hshentry *node, *editscript;
	int trunk;
/*  function: Print delta node if node->selector is set.        */
/*      editscript indicates where the editscript is stored     */
/*      trunk indicated whether this node is in trunk           */
{
	const struct branchhead *newbranch;
	struct buf branchnum;

	if (!node->selector)
            return;

	aprintf(stdout,
		"----------------------------\nrevision %s", node->num
	);
        if ( node->lockedby )
	   aprintf(stdout, "\tlocked by: %s;", node->lockedby);

	aputs("\ndate: ",stdout);
	printdate(stdout, node->date, " ");
	aprintf(stdout, ";  author: %s;  state: %s;",
		node->author, node->state
	);

        if ( editscript )
           if(trunk)
	      aprintf(stdout, insDelFormat,
                             editscript->deletelns, editscript->insertlns);
           else
	      aprintf(stdout, insDelFormat,
                             editscript->insertlns, editscript->deletelns);

        newbranch = node->branches;
        if ( newbranch ) {
	   bufautobegin(&branchnum);
	   aputs("\nbranches:", stdout);
           while( newbranch ) {
		getbranchno(newbranch->hsh->num, &branchnum);
		aprintf(stdout, "  %s;", branchnum.string);
                newbranch = newbranch->nextbranch;
           }
	   bufautoend(&branchnum);
        }

	afputc('\n', stdout);
	awrite(node->log.string, node->log.size, stdout);
}





	static int
readdeltalog()
/*  Function : get the log message and skip the text of a deltatext node.
 *             Return false if current block does not start with a number.
 *             Assumes the current lexeme is not yet in nexttok; does not
 *             advance nexttok.
 */
{
        register struct  hshentry  * Delta;
	struct buf logbuf;

        nextlex();
        if ( !(Delta = getnum() )) return(false);
	getkeystring(Klog);
	bufautobegin(&logbuf);
	Delta->log = savestring(&logbuf);
	/*
	 * Do the following instead of bufautoend(&logbuf),
	 * because the buffer must survive until we are done with the file.
	 */
	Delta->log.string = (char *)fremember(testrealloc(
		(malloc_type)logbuf.string,
		Delta->log.size
	));

        nextlex();
	while (nexttok==ID && strcmp(NextString,Ktext)!=0)
		ignorephrase();
	getkeystring(Ktext);
        Delta->insertlns = Delta->deletelns = 0;
        if ( Delta != Head)
                getscript(Delta);
        else
                readstring();
        return true;
}



	static void
getscript(Delta)
struct    hshentry   * Delta;
/*   function:  read edit script of Delta and count how many lines added  */
/*              and deleted in the script                                 */

{
        int ed;   /*  editor command  */
	register FILE * fin;
        register  int   c;
	register unsigned long i;
	struct diffcmd dc;

	fin = finptr;
	initdiffcmd(&dc);
	while (0  <=  (ed = getdiffcmd(fin,SDELIM,(FILE *)0,&dc)))
	    if (!ed)
                 Delta->deletelns += dc.nlines;
	    else {
                 /*  skip scripted lines  */
		 i = dc.nlines;
		 Delta->insertlns += i;
		 do {
		     while ((c=getc(fin)) != '\n')
			if (c==EOF  ||  c==SDELIM && (c=getc(fin))!=SDELIM) {
			    if (c==EOF || i!=1)
				fatserror("unexpected end to edit script");
			    nextc = c;
			    return;
			}
		     ++rcsline;
		 } while (--i);
            }
	nextc = getc(fin);
}







	static void
exttree(root)
struct hshentry  *root;
/*  function: select revisions , starting with root             */

{
	const struct branchhead *newbranch;

        if (root == nil) return;

	root->selector = extractdelta(root);
        exttree(root->next);

        newbranch = root->branches;
        while( newbranch ) {
            exttree(newbranch->hsh);
            newbranch = newbranch->nextbranch;
        }
}




	static void
getlocker(argv)
char    * argv;
/*   function : get the login names of lockers from command line   */
/*              and store in lockerlist.                           */

{
        register char c;
        struct   lockers   * newlocker;
        argv--;
        while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                 c == '\n' || c == ';')  ;
        if (  c == '\0') {
            lockerlist=nil;
            return;
        }

        while( c != '\0' ) {
	    newlocker = talloc(struct lockers);
            newlocker->lockerlink = lockerlist;
            newlocker->login = argv;
            lockerlist = newlocker;
            while ( ( c = (*++argv)) != ',' && c != '\0' && c != ' '
                       && c != '\t' && c != '\n' && c != ';') ;
            *argv = '\0';
            if ( c == '\0' ) return;
            while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                     c == '\n' || c == ';')  ;
        }
}



	static void
getauthor(argv)
char   *argv;
/*   function:  get the author's name from command line   */
/*              and store in authorlist                   */

{
        register    c;
        struct     authors  * newauthor;

        argv--;
        while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                 c == '\n' || c == ';')  ;
        if ( c == '\0' ) {
	    authorlist = talloc(struct authors);
	    authorlist->login = getcaller();
            authorlist->nextauthor  = nil;
            return;
        }

        while( c != '\0' ) {
	    newauthor = talloc(struct authors);
            newauthor->nextauthor = authorlist;
            newauthor->login = argv;
            authorlist = newauthor;
            while( ( c = *++argv) != ',' && c != '\0' && c != ' '
                     && c != '\t' && c != '\n' && c != ';') ;
            * argv = '\0';
            if ( c == '\0') return;
            while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                     c == '\n' || c == ';')  ;
        }
}




	static void
getstate(argv)
char   * argv;
/*   function :  get the states of revisions from command line  */
/*               and store in statelist                         */

{
        register  char  c;
        struct    stateattri    *newstate;

        argv--;
        while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                 c == '\n' || c == ';')  ;
        if ( c == '\0'){
	    warn("missing state attributes after -s options");
            return;
        }

        while( c != '\0' ) {
	    newstate = talloc(struct stateattri);
            newstate->nextstate = statelist;
            newstate->status = argv;
            statelist = newstate;
            while( (c = (*++argv)) != ',' && c != '\0' && c != ' '
                    && c != '\t' && c != '\n' && c != ';')  ;
            *argv = '\0';
            if ( c == '\0' ) return;
            while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                     c == '\n' || c == ';')  ;
        }
}



	static void
trunclocks()
/*  Function:  Truncate the list of locks to those that are held by the  */
/*             id's on lockerlist. Do not truncate if lockerlist empty.  */

{
	const struct lockers *plocker;
        struct lock     * plocked,  * nextlocked;

        if ( (lockerlist == nil) || (Locks == nil)) return;

        /* shorten Locks to those contained in lockerlist */
        plocked = Locks;
        Locks = nil;
        while( plocked != nil) {
            plocker = lockerlist;
            while((plocker != nil) && ( strcmp(plocker->login, plocked->login)!=0))
                plocker = plocker->lockerlink;
            nextlocked = plocked->nextlock;
            if ( plocker != nil) {
                plocked->nextlock = Locks;
                Locks = plocked;
            }
            plocked = nextlocked;
        }
}



	static void
recentdate(root, pd)
	const struct hshentry *root;
	struct Datepairs *pd;
/*  function:  Finds the delta that is closest to the cutoff date given by   */
/*             pd among the revisions selected by exttree.                   */
/*             Successively narrows down the interval given by pd,           */
/*             and sets the strtdate of pd to the date of the selected delta */
{
	const struct branchhead *newbranch;

	if ( root == nil) return;
	if (root->selector) {
             if ( cmpnum(root->date, pd->strtdate) >= 0 &&
                  cmpnum(root->date, pd->enddate) <= 0)
		VOID strcpy(pd->strtdate, root->date);
        }

        recentdate(root->next, pd);
        newbranch = root->branches;
        while( newbranch) {
           recentdate(newbranch->hsh, pd);
           newbranch = newbranch->nextbranch;
	}
}






	static void
extdate(root)
struct  hshentry        * root;
/*  function:  select revisions which are in the date range specified     */
/*             in duelst  and datelist, start at root                     */

{
	const struct branchhead *newbranch;
	const struct Datepairs *pdate;

        if ( root == nil) return;

        if ( datelist || duelst) {
            pdate = datelist;
            while( pdate ) {
                if ( (pdate->strtdate)[0] == '\0' || cmpnum(root->date,pdate->strtdate) >= 0){
                   if ((pdate->enddate)[0] == '\0' || cmpnum(pdate->enddate,root->date) >= 0)
                        break;
                }
                pdate = pdate->dnext;
            }
            if ( pdate == nil) {
                pdate = duelst;
		for (;;) {
		   if (!pdate) {
			root->selector = false;
			break;
		   }
                   if ( cmpnum(root->date, pdate->strtdate) == 0)
                      break;
                   pdate = pdate->dnext;
                }
            }
        }
	if (root->selector)
	    ++revno;

        extdate(root->next);

        newbranch = root->branches;
        while( newbranch ) {
           extdate(newbranch->hsh);
           newbranch = newbranch->nextbranch;
        }
}



	static char
extractdelta(pdelta)
	const struct hshentry *pdelta;
/*  function:  compare information of pdelta to the authorlist, lockerlist,*/
/*             statelist, revlist and yield true if pdelta is selected.    */

{
	const struct lock *plock;
	const struct stateattri *pstate;
	const struct authors *pauthor;
	const struct Revpairs *prevision;
	unsigned length;

	if ((pauthor = authorlist)) /* only certain authors wanted */
	    while (strcmp(pauthor->login, pdelta->author) != 0)
		if (!(pauthor = pauthor->nextauthor))
		    return false;
	if ((pstate = statelist)) /* only certain states wanted */
	    while (strcmp(pstate->status, pdelta->state) != 0)
		if (!(pstate = pstate->nextstate))
		    return false;
	if (lockflag) /* only locked revisions wanted */
	    for (plock = Locks;  ;  plock = plock->nextlock)
		if (!plock)
		    return false;
		else if (plock->delta == pdelta)
		    break;
	if ((prevision = Revlst)) /* only certain revs or branches wanted */
	    for (;;) {
                length = prevision->numfld;
		if (
		    countnumflds(pdelta->num) == length+(length&1) &&
		    0 <= compartial(pdelta->num, prevision->strtrev, length) &&
		    0 <= compartial(prevision->endrev, pdelta->num, length)
		)
		     break;
		if (!(prevision = prevision->rnext))
		    return false;
            }
	return true;
}



	static void
getdatepair(argv)
   char   * argv;
/*  function:  get time range from command line and store in datelist if    */
/*             a time range specified or in duelst if a time spot specified */

{
        register   char         c;
        struct     Datepairs    * nextdate;
	const char		* rawdate;
	int                     switchflag;

        argv--;
        while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                 c == '\n' || c == ';')  ;
        if ( c == '\0' ) {
	    warn("missing date/time after -d");
            return;
        }

        while( c != '\0' )  {
	    switchflag = false;
	    nextdate = talloc(struct Datepairs);
            if ( c == '<' ) {   /*   case: -d <date   */
                c = *++argv;
                (nextdate->strtdate)[0] = '\0';
	    } else if (c == '>') { /* case: -d'>date' */
		c = *++argv;
		(nextdate->enddate)[0] = '\0';
		switchflag = true;
	    } else {
                rawdate = argv;
		while( c != '<' && c != '>' && c != ';' && c != '\0')
		     c = *++argv;
                *argv = '\0';
		if ( c == '>' ) switchflag=true;
		str2date(rawdate,
			 switchflag ? nextdate->enddate : nextdate->strtdate);
		if ( c == ';' || c == '\0') {  /*  case: -d date  */
		    VOID strcpy(nextdate->enddate,nextdate->strtdate);
		    VOID sprintf(nextdate->strtdate,DATEFORM,0,0,0,0,0,0);
                    nextdate->dnext = duelst;
                    duelst = nextdate;
		    goto end;
		} else {
		    /*   case:   -d date<  or -d  date>; see switchflag */
		    while ( (c= *++argv) == ' ' || c=='\t' || c=='\n');
		    if ( c == ';' || c == '\0') {
			/* second date missing */
			if (switchflag)
			    *nextdate->strtdate= '\0';
			else
			    *nextdate->enddate= '\0';
			nextdate->dnext = datelist;
			datelist = nextdate;
			goto end;
		    }
                }
            }
            rawdate = argv;
	    while( c != '>' && c != '<' && c != ';' && c != '\0')
 		c = *++argv;
            *argv = '\0';
	    str2date(rawdate,
		     switchflag ? nextdate->strtdate : nextdate->enddate);
            nextdate->dnext = datelist;
	    datelist = nextdate;
     end:
	    if ( c == '\0')  return;
            while( (c = *++argv) == ';' || c == ' ' || c == '\t' || c =='\n');
        }
}



	static void
getnumericrev()
/*  function:  get the numeric name of revisions which stored in revlist  */
/*             and then stored the numeric names in Revlst                */
/*             if branchflag, also add default branch                     */

{
        struct  Revpairs        * ptr, *pt;
	unsigned n;
	struct buf s, e;
	const struct buf *rstart, *rend;

        Revlst = nil;
        ptr = revlist;
	bufautobegin(&s);
	bufautobegin(&e);
        while( ptr ) {
	    n = 0;
	    rstart = &s;
	    rend = &e;

	    switch (ptr->numfld) {

	      case 1: /* -r rev */
		if (expandsym(ptr->strtrev, &s)) {
		    rend = &s;
		    n = countnumflds(s.string);
                }
		break;

	      case 2: /* -r rev- */
		if (expandsym(ptr->strtrev, &s)) {
		    bufscpy(&e, s.string);
		    n = countnumflds(s.string);
		    (n<2 ? e.string : strrchr(e.string,'.'))[0]  =  0;
                }
		break;

	      case 3: /* -r -rev */
		if (expandsym(ptr->endrev, &e)) {
		    if ((n = countnumflds(e.string)) < 2)
			bufscpy(&s, ".1");
		    else {
			bufscpy(&s, e.string);
			VOID strcpy(strrchr(s.string,'.'), ".1");
		    }
                }
		break;

	      default: /* -r rev1-rev2 */
		if (
			expandsym(ptr->strtrev, &s)
		    &&	expandsym(ptr->endrev, &e)
		    &&	checkrevpair(s.string, e.string)
		) {
		    n = countnumflds(s.string);
		    /* Swap if out of order.  */
		    if (compartial(s.string,e.string,n) > 0) {
			rstart = &e;
			rend = &s;
		    }
		}
		break;
	    }

	    if (n) {
		pt = ftalloc(struct Revpairs);
		pt->numfld = n;
		pt->strtrev = fstrsave(rstart->string);
		pt->endrev = fstrsave(rend->string);
                pt->rnext = Revlst;
                Revlst = pt;
	    }
	    ptr = ptr->rnext;
        }
        /* Now take care of branchflag */
	if (branchflag && (Dbranch||Head)) {
	    pt = ftalloc(struct Revpairs);
	    pt->strtrev = pt->endrev =
		Dbranch ? Dbranch : fstrsave(partialno(&s,Head->num,1));
	    pt->rnext=Revlst; Revlst=pt;
	    pt->numfld = countnumflds(pt->strtrev);
        }
	bufautoend(&s);
	bufautoend(&e);
}



	static int
checkrevpair(num1,num2)
	const char *num1, *num2;
/*  function:  check whether num1, num2 are legal pair,i.e.
    only the last field are different and have same number of
    fields( if length <= 2, may be different if first field)   */

{
	unsigned length = countnumflds(num1);

	if (
			countnumflds(num2) != length
		||	2 < length  &&  compartial(num1, num2, length-1) != 0
	) {
	    error("invalid branch or revision pair %s : %s", num1, num2);
            return false;
        }

        return true;
}



	static void
getrevpairs(argv)
register     char    * argv;
/*  function:  get revision or branch range from command line, and   */
/*             store in revlist                                      */

{
        register    char    c;
        struct      Revpairs  * nextrevpair;
        int         flag;

        argv--;
        while( ( c = (*++argv)) == ',' || c == ' ' || c == '\t' ||
                 c == '\n' || c == ';')  ;
        if ( c == '\0' ) {
	    warn("missing revision or branch number after -r");
            return;
        }

        while( c != '\0') {
            while(  c  == ',' || c == ' ' || c == '\t' ||
                     c == '\n' || c == ';') c = *++argv;
            if (c == '\0')  return;
	    nextrevpair = talloc(struct Revpairs);
            nextrevpair->rnext = revlist;
            revlist = nextrevpair;
	    nextrevpair->numfld = 0;
            nextrevpair->strtrev = nil;
            nextrevpair->endrev  = nil;
            flag = false;
            if (  c == '<' || c == '-' ) {  /*  case: -r -rev  or -r <rev  */
                flag = true;
                while( (c =(*++argv)) == ' ' || c == '\t' || c =='\n') ;
            }
            else {
                nextrevpair->strtrev = argv;
                /*   get a revision or branch name  */
                while( c != ',' && c != ';' && c != ' ' && c != '\0' && c != '-'
                        && c != '\t' && c != '\n' && c != '<') c = *++argv;

                *argv = '\0';

                if ( c != '<' && c != '-') {    /*  case: rev  */
                    nextrevpair->numfld = 1;
                    continue;
                }

                if ( (c =(*++argv)) == ',' || c == '\0' || c == ' '
                      || c == '\t' || c == '\n' || c == ';') {/*  case: rev_  */
                    nextrevpair->numfld = 2;
                    continue;
                }
            }
            nextrevpair->endrev = argv;
            while( c != ',' && c != ' ' && c != '\0' && c != '\t' && c != '<'
                   && c != '\n' && c != '-' && c != ';')  c = *++argv;

            * argv = '\0';
            if ( c == '<'){
		error("separator expected near %s", nextrevpair->endrev);
                while( (c = *++argv) != ',' && c != ' ' && c != '\0' &&
                        c != '\t' && c != '\n' && c != ';' ) ;
                revlist = nextrevpair->rnext;
                continue;
            }
            else  {
                if (flag)   /*  case:  -rev   */
                    nextrevpair->numfld  = 3;

                else     /*   rev1-rev2  appears  */
                    nextrevpair->numfld = 4;
            }
        }
}
