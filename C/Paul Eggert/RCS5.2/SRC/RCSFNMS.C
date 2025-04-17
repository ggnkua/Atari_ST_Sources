/*
 *                     RCS file name handling
 */
/****************************************************************************
 *                     creation and deletion of /tmp temporaries
 *                     pairing of RCS file names and working file names.
 *                     Testprogram: define PAIRTEST
 ****************************************************************************
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




/* $Log: rcsfnms.c,v $
 * Revision 5.7  1991/01/30  14:13:06  apratt
 * Fixed a bug: bindex returns ptr to char PAST match if there's a match.
 *
 * Revision 5.7  1991/01/30  14:11:14  apratt
 * Fixed a bug: bindex returns ptr to char PAST match if there's a match.
 *
 * Revision 5.6  91/01/29  17:45:54  apratt
 * Added AKP_BUGFIXES around my bug fixes, changed headstr
 * 
 * Revision 5.5  91/01/16  15:45:00  apratt
 * This version works passably on the ST.
 * 
 * Revision 5.4  90/11/01  05:03:43  eggert
 * checked in with -k by apratt at 91.01.10.13.15.14.
 * 
 * Revision 5.4  1990/11/01  05:03:43  eggert
 * Permit arbitrary data in comment leaders.
 *
 * Revision 5.3  1990/09/14  22:56:16  hammer
 * added more filename extensions and their comment leaders
 *
 * Revision 5.2  1990/09/04  08:02:23  eggert
 * Fix typo when !RCSSEP.
 *
 * Revision 5.1  1990/08/29  07:13:59  eggert
 * Work around buggy compilers with defective argument promotion.
 *
 * Revision 5.0  1990/08/22  08:12:50  eggert
 * Ignore signals when manipulating the semaphore file.
 * Modernize list of file name extensions.
 * Permit paths of arbitrary length.  Beware file names beginning with "-".
 * Remove compile-time limits; use malloc instead.
 * Permit dates past 1999/12/31.  Make lock and temp files faster and safer.
 * Ansify and Posixate.
 * Don't use access().  Fix test for non-regular files.  Tune.
 *
 * Revision 4.8  89/05/01  15:09:41  narten
 * changed getwd to not stat empty directories.
 * 
 * Revision 4.7  88/08/09  19:12:53  eggert
 * Fix troff macro comment leader bug; add Prolog; allow cc -R; remove lint.
 * 
 * Revision 4.6  87/12/18  11:40:23  narten
 * additional file types added from 4.3 BSD version, and SPARC assembler
 * comment character added. Also, more lint cleanups. (Guy Harris)
 * 
 * Revision 4.5  87/10/18  10:34:16  narten
 * Updating version numbers. Changes relative to 1.1 actually relative
 * to verion 4.3
 * 
 * Revision 1.3  87/03/27  14:22:21  jenkins
 * Port to suns
 * 
 * Revision 1.2  85/06/26  07:34:28  svb
 * Comment leader '% ' for '*.tex' files added.
 * 
 * Revision 4.3  83/12/15  12:26:48  wft
 * Added check for KDELIM in file names to pairfilenames().
 * 
 * Revision 4.2  83/12/02  22:47:45  wft
 * Added csh, red, and sl file name suffixes.
 * 
 * Revision 4.1  83/05/11  16:23:39  wft
 * Added initialization of Dbranch to InitAdmin(). Canged pairfilenames():
 * 1. added copying of path from workfile to RCS file, if RCS file is omitted;
 * 2. added getting the file status of RCS and working files;
 * 3. added ignoring of directories.
 * 
 * Revision 3.7  83/05/11  15:01:58  wft
 * Added comtable[] which pairs file name suffixes with comment leaders;
 * updated InitAdmin() accordingly.
 * 
 * Revision 3.6  83/04/05  14:47:36  wft
 * fixed Suffix in InitAdmin().
 * 
 * Revision 3.5  83/01/17  18:01:04  wft
 * Added getwd() and rename(); these can be removed by defining
 * V4_2BSD, since they are not needed in 4.2 bsd.
 * Changed sys/param.h to sys/types.h.
 *
 * Revision 3.4  82/12/08  21:55:20  wft
 * removed unused variable.
 *
 * Revision 3.3  82/11/28  20:31:37  wft
 * Changed mktempfile() to store the generated file names.
 * Changed getfullRCSname() to store the file and pathname, and to
 * delete leading "../" and "./".
 *
 * Revision 3.2  82/11/12  14:29:40  wft
 * changed pairfilenames() to handle file.sfx,v; also deleted checkpathnosfx(),
 * checksuffix(), checkfullpath(). Semaphore name generation updated.
 * mktempfile() now checks for nil path; freefilename initialized properly.
 * Added Suffix .h to InitAdmin. Added testprogram PAIRTEST.
 * Moved rmsema, trysema, trydiraccess, getfullRCSname from rcsutil.c to here.
 *
 * Revision 3.1  82/10/18  14:51:28  wft
 * InitAdmin() now initializes StrictLocks=STRICT_LOCKING (def. in rcsbase.h).
 * renamed checkpath() to checkfullpath().
 */


#include "rcsbase.h"

libId(fnmsId, "$Id: rcsfnms.c,v 5.7 1991/01/30 14:13:06 apratt Exp $")

const char *RCSfilename;
char *workfilename;
struct stat RCSstat, workstat; /* file status for RCS file and working file */
int haveworkstat;

#if !USE_AKP_PAIRS
static const char rcsdir[] = RCSDIR;
#endif

#define TEMPNAMES 4 /* must be at least DIRTEMPNAMES (see rcsedit.c) */
static char tfnames[TEMPNAMES][L_tmpnam];	/* unlink these when done */
static volatile int tfmade[TEMPNAMES];		/* if these flags are set */


struct compair {
	const char *suffix, *comlead;
};

static const struct compair comtable[] = {
/* comtable pairs each filename suffix with a comment leader. The comment   */
/* leader is placed before each line generated by the $Log keyword. This    */
/* table is used to guess the proper comment leader from the working file's */
/* suffix during initial ci (see InitAdmin()). Comment leaders are needed   */
/* for languages without multiline comments; for others they are optional.  */
	"a",   "-- ",   /* Ada         */
        "c",   " * ",   /* C           */
	"C",   "// ",	/* C++ in all its infinite guises */
	"CC",  "// ",
	"c++", "// ",
	"cc",  "// ",
	"cxx", "// ",
	"cl",  ";;; ",  /* Common Lisp */
	"cmf", "C ",	/* CM FORTRAN  */
	"cs",  " * ",	/* C*          */
	"el",  "; ",    /* Emacs Lisp  */
	"f",   "c ",    /* Fortran     */
	"for", "c ",
        "h",   " * ",   /* C-header    */
        "l",   " * ",   /* lex      NOTE: conflict between lex and franzlisp */
	"lisp",";;; ",	/* Lucid Lisp  */
        "mac", "; ",    /* macro       vms or dec-20 or pdp-11 macro */
	"me",  ".\\\" ",/* me-macros   t/nroff*/
	"ml",  "; ",    /* mocklisp    */
	"mm",  ".\\\" ",/* mm-macros   t/nroff*/
	"ms",  ".\\\" ",/* ms-macros   t/nroff*/
	"p",   " * ",   /* Pascal      */
	"pl",  "% ",	/* Prolog      */
	"tex", "% ",	/* TeX	       */
        "y",   " * ",   /* yacc        */
	nil,   "# "     /* default for unknown suffix; must always be last */
};


	void
ffclose(fptr)
FILE * fptr;
/* Function: checks ferror(fptr) and aborts the program if there were
 * errors; otherwise closes fptr.
 */
{       if (ferror(fptr) || fclose(fptr)==EOF)
		IOerror();
}



	char *
maketemp(n)
	int n;
/* Create a unique filename using n and the process id and store it
 * into the nth slot in tfnames.
 * Because of storage in tfnames, tempunlink() can unlink the file later.
 * Returns a pointer to the filename created.
 */
{
	char *p = tfnames[n];

	if (!tfmade[n]) {
#if has_tmpnam
		if (!tmpnam(p))
#else
		VOID sprintf(p, "%sRCS%cXXXXXX", tmp(), 'A'+n);
		if (!mktemp(p))
#endif
			faterror("can't make temporary file name");
	}
	tfmade[n] = true;
	return p;
}

	void
tempunlink()
/* Clean up maketemp() files.  May be invoked by signal handler.
 */
{
	register int i;

	for (i = TEMPNAMES;  0 <= --i;  )
	    if (tfmade[i]) {
		VOID unlink(tfnames[i]);
		tfmade[i] = 0;
	    }
}


	const char *
bindex(sp,ch)
	register const char *sp;
	int ch;
/* Function: Finds the last occurrence of character c in string sp
 * and returns a pointer to the character just beyond it. If the
 * character doesn't occur in the string, sp is returned.
 */
{
	register const char c=ch, *r;
        r = sp;
        while (*sp) {
                if (*sp++ == c) r=sp;
        }
        return r;
}





	static void
InitAdmin()
/* function: initializes an admin node */
{
	register const char *Suffix;
        register int i;

	Head=nil; Dbranch=nil; AccessList=nil; Symbols=nil; Locks=nil;
        StrictLocks=STRICT_LOCKING;

        /* guess the comment leader from the suffix*/
        Suffix=bindex(workfilename, '.');

#if AKP_BUGFIXES
	/* Improved by AKP: only match '.' AFTER all SLASHes */
	if (Suffix < bindex(workfilename,SLASH)) Suffix = workfilename;
#endif

        if (Suffix==workfilename) Suffix= ""; /* empty suffix; will get default*/
	for (i=0; comtable[i].suffix && strcmp(Suffix,comtable[i].suffix); i++)
		;
	Comment.string = comtable[i].comlead;
	Comment.size = strlen(comtable[i].comlead);
        Lexinit(); /* Note: if finptr==NULL, reads nothing; only initializes*/
}


#if !RCSSEP
	static int
isRCSfilename(f, p)
	const char *f, *p;
/* Yield true iff F (with pure file name P) is an RCS file name.  */
{
	return
		p-f <= sizeof(rcsdir)-1  &&
		((p -= sizeof(rcsdir)-1) == f  ||  p[-1] == SLASH)  &&
		strncmp(p, rcsdir, sizeof(rcsdir)-1) == 0;
}
#endif

#if RCSSEP
#	define findpair(c,v,f,m) findpairfile(c,v,f)
#else
#	define findpair(c,v,f,m) findpairfile(c,v,f,m)
#endif

#if !USE_AKP_PAIRS
	static char *
#if RCSSEP
findpairfile(argc, argv, fname)
#else
findpairfile(argc, argv, fname, rcsmatch)
int rcsmatch; /* *ARGV must be an RCS file name iff this is set.  */
#endif
int argc; char * argv[], *fname;
/* Peek ahead in an ARGC-ARGV argument vector for a pathname ending in FNAME.
 * Yield it if found, and set the corresponding pointer in ARGV to nil.
 * Yield FNAME otherwise.
 */
{
	register char *arg;
#if !RCSSEP
	register char *b;
#endif
	if (
		0 < argc
#if RCSSEP
		&& strcmp(bindex(arg = *argv,SLASH), fname) == 0
#else
		&& strcmp(b = bindex(arg = *argv,SLASH), fname) == 0
		&& isRCSfilename(arg, b) == rcsmatch
#endif
	) {
		*argv = nil;
		return arg;
        }
        return fname;
}
#endif

	static int
handleworkstat(s)
	int s;
{
	if (s==0  &&  !S_ISREG(workstat.st_mode)) {
		error("%s isn't a regular file", workfilename);
		return false;
	}
#if AKP_BUGFIXES
	haveworkstat = (s == 0 ? 0 : errno);
#else
	haveworkstat = errno;
#endif
	return true;
}

int getworkstat()
/* Function: get status of workfilename. */
{
	errno = 0;
	return handleworkstat(stat(workfilename, &workstat));
}

	int
getfworkstat(f)
	int f;
/* Get status of file descriptor f. */
{
	errno = 0;
	return handleworkstat(fstat(f, &workstat));
}


#if defined(_POSIX_NO_TRUNC) & _POSIX_NO_TRUNC!=-1
#	define LONG_NAMES_MAY_BE_SILENTLY_TRUNCATED 0
#else
#	define LONG_NAMES_MAY_BE_SILENTLY_TRUNCATED 1
#endif

#if LONG_NAMES_MAY_BE_SILENTLY_TRUNCATED
#ifdef NAME_MAX
#	define filenametoolong(path) (NAME_MAX < strlen(bindex(path,SLASH)))
#else
	static int
filenametoolong(path)
	char *path;
/* Yield true if the last file name in PATH is too long. */
{
	static unsigned long dot_namemax;

	register size_t namelen;
	register char *lastslash;
	register unsigned long namemax;

	lastslash = strrchr(path, SLASH);
	namelen = strlen(lastslash ? lastslash+1 : path);
	if (namelen <= _POSIX_NAME_MAX) /* fast check for shorties */
		return false;
	if (lastslash) {
		*lastslash = 0;
		namemax = pathconf(path, _PC_NAME_MAX);
		*lastslash = SLASH;
	} else {
		/* Cache the results for the working directory, for speed. */
		if (!dot_namemax)
			dot_namemax = pathconf(".", _PC_NAME_MAX);
		namemax = dot_namemax;
	}
	/* If pathconf() yielded -1, namemax is now ULONG_MAX.  */
	return namemax<namelen;
}
#endif
#endif

	void
bufalloc(b, size)
	register struct buf *b;
	size_t size;
/* Ensure *B is a name buffer of at least SIZE bytes.
 * *B's old contents can be freed; *B's new contents are undefined.
 */
{
	if (b->size < size) {
		if (b->size)
			tfree(b->string);
		else
			b->size = sizeof(malloc_type);
		while (b->size < size)
			b->size <<= 1;
		b->string = tnalloc(char, b->size);
	}
}

	void
bufrealloc(b, size)
	register struct buf *b;
	size_t size;
/* like bufalloc, except *B's old contents, if any, are preserved */
{
	if (b->size < size) {
		if (!b->size)
			bufalloc(b, size);
		else {
			while ((b->size <<= 1)  <  size)
				;
			b->string = (char *)testrealloc((malloc_type)b->string, b->size);
		}
	}
}

	void
bufautoend(b)
	struct buf *b;
/* Free an auto buffer at block exit. */
{
	if (b->size)
		tfree(b->string);
}

	char *
bufenlarge(b, alim)
	register struct buf *b;
	const char **alim;
/* Make *B larger.  Set *ALIM to its new limit, and yield the relocated value
 * of its old limit.
 */
{
	size_t s = b->size;
	bufrealloc(b, s + 1);
	*alim = b->string + b->size;
	return b->string + s;
}

	void
bufscat(b, s)
	struct buf *b;
	const char *s;
/* Concatenate S to B's end. */
{
	size_t blen  =  b->string ? strlen(b->string) : 0;
	bufrealloc(b, blen+strlen(s)+1);
	VOID strcpy(b->string+blen, s);
}

	void
bufscpy(b, s)
	struct buf *b;
	const char *s;
/* Copy S into B. */
{
	bufalloc(b, strlen(s)+1);
	VOID strcpy(b->string, s);
}


	FILE *
rcsreadopen(RCSname)
	const char *RCSname;
/* Open RCSNAME for reading and yield its FILE* descriptor.
 * Pass this routine to pairfilenames() for read-only access to the file.  */
{
#if AKP_BUGFIXES
	int errno_hold;		/* AKP: this fixes a bug, I think */
#endif
	FILE *f;
	seteid();
#if AKP_BUGFIXES
	errno = 0;
#endif
	f = fopen(RCSname, "r");

#if AKP_BUGFIXES
	errno_hold = errno;
	setrid();
	errno = errno_hold;
#else
	setrid();
#endif
	return f;
}

#if !USE_AKP_PAIRS

	int
pairfilenames(argc, argv, rcsopen, mustread, tostdout)
	int argc;
	char **argv;
	FILE *(*rcsopen)P((const char*));
	int mustread, tostdout;
/* Function: Pairs the filenames pointed to by argv; argc indicates
 * how many there are.
 * Places a pointer to the RCS filename into RCSfilename,
 * and a pointer to the name of the working file into workfilename.
 * If both the workfilename and the RCS filename are given, and tostdout
 * is true, a warning is printed.
 *
 * If the RCS file exists, places its status into RCSstat.
 *
 * If the RCS file exists, it is RCSOPENed for reading, the file pointer
 * is placed into finptr, and the admin-node is read in; returns 1.
 * If the RCS file does not exist and mustread is set, an error is printed
 * and 0 returned.
 * If the RCS file does not exist and !mustread, the admin node
 * is initialized and -1 returned.
 *
 * 0 is returned on all errors, e.g. files that are not regular files.
 */
{
	static struct buf RCSbuf, tempbuf;

	register char *p, *arg, *tempfilename, *RCS1;
	const char *purefname, *pureRCSname;
	FILE *lock1;

	if (!(arg = *argv)) return 0; /* already paired filename */
	if (*arg == '-') {
		error("%s option is ignored after file names", arg);
		return 0;
	}

	/* Allocate buffer temporary to hold the default paired file name. */
	for (purefname = p = arg; *p; )
		switch (*p++) {
		    case SLASH:
			purefname = p;
			break;
		    /* Beware characters that cause havoc with ci -k. */
		    case KDELIM:
			error("RCS file name `%s' contains %c", arg, KDELIM);
			return 0;
		    case ' ': case '\n': case '\t':
			error("RCS file name `%s' contains white space", arg);
			return 0;
		}
	bufalloc(&tempbuf, p - purefname + 3);
	tempfilename = tempbuf.string;

        /* first check suffix to see whether it is an RCS file or not */
#if RCSSEP
	if (purefname<(p-=2) && p[0]==RCSSEP && p[1]==RCSSUF)
#else
	if (isRCSfilename(arg, purefname))
#endif
	{
                /* RCS file name given*/
		RCS1 = arg;
		pureRCSname = purefname;
                /* derive workfilename*/
		VOID strcpy(tempfilename, purefname);
		tempfilename[p - purefname] = 0;
                /* try to find workfile name among arguments */
		workfilename = findpair(argc-1,argv+1,tempfilename,false);
        } else {
                /* working file given; now try to find RCS file */
		workfilename = arg;
                /* derive RCS file name*/
		VOID sprintf(tempfilename,"%s%c%c", purefname, RCSSEP, RCSSUF);
                /* Try to find RCS file name among arguments*/
		RCS1 = findpair(argc-1,argv+1,tempfilename,true);
                pureRCSname=bindex(RCS1, SLASH);
        }
        /* now we have a (tentative) RCS filename in RCS1 and workfilename  */
        /* Second, try to find the right RCS file */
        if (pureRCSname!=RCS1) {
                /* a path for RCSfile is given; single RCS file to look for */
		errno = 0;
		RCSfilename = p = RCS1;
		finptr = (*rcsopen)(RCSfilename = p = RCS1);
        } else {
		/* no path for RCS file name. Prefix it with path of work */
		/* file if RCS file omitted.  Try RCSDIR subdirectory 1st.*/
		bufalloc(&RCSbuf, strlen(workfilename)+sizeof(rcsdir)+2);
		RCSfilename = p = RCSbuf.string;
		if (RCS1==tempfilename) {
			/* RCS file name not given; prepend work path */
			VOID strncpy(p, arg, purefname-arg);
			p += purefname-arg;
		}
		VOID strcpy(p, rcsdir);
		VOID strcpy(p+sizeof(rcsdir)-1, RCS1);

		/* Try D/RCS/file,v. */
		errno = 0;
		if (!(finptr = (*rcsopen)(RCSfilename))
		    &&  (errno==ENOTDIR || errno==ENOENT)
		    /*
		     * Many (broken) systems yield ENOENT, not ENOTDIR,
		     * when the problem is a missing RCS subdirectory.
		     */
		) {
			lock1 = frewrite;

			/* Try D/file,v. */
			VOID strcpy(p, RCS1);
			errno = 0;
			if (!(finptr=(*rcsopen)(RCSfilename)) && errno==ENOENT) {
			    /*
			     * Neither file exists; determine the default.
			     * Prefer D/RCS/file,v to D/file,v.
			     */
			    if (mustread || lock1) {
				/* Switch back to D/RCS/file,v. */
				VOID strcpy(p, rcsdir);
				VOID strcpy(p+sizeof(rcsdir)-1, RCS1);
			    }
			}
		}
		p = RCSbuf.string;
        }
	if (finptr) {
		if (fstat(fileno(finptr), &RCSstat) < 0)
			efaterror(p);
		if (!S_ISREG(RCSstat.st_mode)) {
			error("%s isn't a regular file -- ignored", p);
                        return 0;
                }
                Lexinit(); getadmin();
	} else {
		if (errno!=ENOENT || mustread || !frewrite) {
			if (errno == EEXIST)
				error("RCS file %s is in use", p);
			else
				eerror(p);
			return 0;
		}
                InitAdmin();
        };
#	if LONG_NAMES_MAY_BE_SILENTLY_TRUNCATED
	    if (filenametoolong(p)) {
		error("RCS file name %s is too long", p);
		return 0;
	    }
#	    ifndef NAME_MAX
		/*
		 * Check workfilename, even though it is shorter,
		 * because it may reside on a different filesystem.
		 */
		if (filenametoolong(workfilename)) {
		    error("working file name %s is too long", workfilename);
		    return 0;
		}
#	    endif
#	endif

        if (tostdout&&
            !(RCS1==tempfilename||workfilename==tempfilename))
                /*The last term determines whether a pair of        */
                /* file names was given in the argument list        */
                warn("Option -p is set; ignoring output file %s",workfilename);

	return finptr ? 1 : -1;
}

#else

/* USE_AKP_PAIRS */

#define HEADSTR "head"
#define HSLEN 4

/*
 * pairfilenames: does what the normal code does, but handles 8.3
 * filenames.
 */

	int
pairfilenames(argc, argv, rcsopen, mustread, tostdout)
	int argc;
	char **argv;
	FILE *(*rcsopen)P((const char*));
	int mustread, tostdout;
{
	static struct buf RCSbuf, tempbuf;
	char *temp;
	char *temp1;
	int checkedRCS = false;
	int checkedwork = false;
	int retcode = 0;
	FILE *fp;
	struct stat st;
	char tmpbuf[HSLEN+1];

	tmpbuf[HSLEN] = '\0';	/* null-terminate the buffer */

	if (**argv == '-') {
		error("%s: option is ignored after file names", *argv);
		return 0;
	}
	if (bindex(*argv,KDELIM) != *argv) {
		error("RCS file name `%s' contains %c",*argv,KDELIM);
		return 0;
	}
	if (index(*argv,' ') || index(*argv,'\t') || index(*argv,'\n')) {
		error("RCS file name `%s' contains white space",*argv);
		return 0;
	}

	/* try to open the file as given */
	if ((fp = fopen(*argv,"r")) != NULL) {
		/* exists; read the header */
		if (fread(tmpbuf,1,HSLEN,fp) == HSLEN && 
		    !strcmp(tmpbuf,HEADSTR)) {
			/* you gave the RCS file name and it exists */
			fclose(fp);
			checkedRCS = true;
			stat(*argv,&RCSstat);
			retcode = 1;
			RCSfilename = *argv;
			temp = bindex(*argv,SLASH);
			bufalloc(&tempbuf,strlen(temp)+1);
			workfilename = tempbuf.string;
			strcpy(workfilename,temp);

			/* remove ,v at the end of workfilename */
			if (((temp = bindex(workfilename,RCSSEP)) 
						    != workfilename) &&
			    ((!*temp) || 
			    ((*temp == RCSSUF) && (*(temp+1) == '\0'))))
				*(--temp) = '\0';
	        }
		else {
		    /* exists, but isn't an RCS file: must be work file */
		    /* RCSfilename is RCS/name.,v or name.,v if no RCS/ */
		    fclose(fp);
		    checkedwork = true;
justwf:
		    workfilename = *argv;
		    temp = bindex(*argv,SLASH);

		    /* magic number 9 below is > max added chars: RCS/.,v */
		    if ((stat(RCSDIR,&st) == 0) && (st.st_mode & S_IFDIR)) {
			bufalloc(&RCSbuf,strlen(temp)+9);
			RCSfilename = RCSbuf.string;
			sprintf(RCSfilename,"%s%s%s",RCSDIR,temp,
			    bindex(temp,'.') == temp ? ".,v" : ",v");
		    }
		    else {
			/* subdir RCS doesn't exist */
			bufalloc(&RCSbuf,strlen(temp)+4);
			RCSfilename = RCSbuf.string;
			sprintf(RCSfilename,"%s%s",temp,
			    bindex(temp,'.') == temp ? ".,v" : ",v");
		    }
		}
	}
	else {
	    /* file didn't exist */

	    /* remove ,v after file name */
	    if (((temp = bindex(*argv,RCSSEP)) != *argv) &&
		((!*temp) || 
		((*temp == RCSSUF) && (*(temp+1) == '\0'))))
		    *--temp = '\0';

	    /* if RCS/name.,v exists and is magic, or name.,v exists and */
	    /* is magic, that file is RCSfilename and you gave work.	 */
	    temp = bindex(temp,SLASH);
	    bufalloc(&tempbuf,strlen(temp)+9);
	    temp1 = tempbuf.string;
	    sprintf(temp1,"%s%s%s",RCSDIR,temp,
		bindex(temp,'.') == temp ? ".,v" : ",v");
	    if (stat(temp1,&st) == 0) {
		/* RCS/file.,v exists -- fine. */
		RCSfilename = temp1;
		RCSstat = st;
		workfilename = *argv;
	    }
	    else {
		/* doesn't exist in RCS subdir */
		sprintf(temp1,"%s%s",temp,
		    bindex(temp,'.') == temp ? ".,v" : ",v");
		if (stat(temp1,&st) == 0) {
		    /* ./file.,v exists -- fine. */
		    RCSfilename = temp1;
		    workfilename = *argv;
		}
		else {
		    /* file doesn't exist anywhere! */
		    /* same case as above */
		    goto justwf;
		}
	    }
	}

	/* at this point, RCSfilename and workfilename are set.	    */
	/* if !checkedwork, then verify workfile, ditto checkedRCS. */

	if (!checkedwork) {
	    if (((fp = fopen(workfilename,"r")) != NULL) &&
		(fread(tmpbuf,1,HSLEN,fp) == HSLEN) &&
		(!strcmp(tmpbuf,HEADSTR))) {
		    fclose(fp);
		    error("Computed work file name %s is actually an RCS file",
			workfilename);
		    return 0;
	    }
	    else {
		fclose(fp);
	    }
	}
	if (!checkedRCS) {
	    if ((fp = fopen(RCSfilename,"r")) != NULL) {
		if ((fread(tmpbuf,1,HSLEN,fp) == HSLEN) &&
		    (!strcmp(tmpbuf,HEADSTR))) {
			stat(RCSfilename,&RCSstat);
			fclose(fp);
			finptr = (*rcsopen)(RCSfilename);
			Lexinit();
			getadmin();
			return 1;
		}
		else {
		    fclose(fp);
		    error("Computed RCS file name %s is not an RCS file",
			RCSfilename);
		    return 0;
		}
	    }
	    else {
		/* RCS file doesn't exist */
		if (mustread) {
		    error("Can't find computed RCS file %s",RCSfilename);
		    return 0;
		}
		else {
		    finptr = (*rcsopen)(RCSfilename);
		    InitAdmin();
		    return -1;
		}
	    }
	}
	else {
	    /* RCS file was checked, so we know it exists */
	    finptr = (*rcsopen)(RCSfilename);
	    Lexinit();
	    getadmin();
	    return 1;
	}
}

/* end if USE_AKP_PAIRS */
#endif


	const char *
getfullRCSname()
/* Function: returns a pointer to the full path name of the RCS file.
 * Gets the working directory's name at most once.
 * Removes leading "../" and "./".
 */
{
	static const char *wd;
	static struct buf rcsbuf, wdbuf;
	static size_t pathlength;

	register const char *realname;
	register size_t parentdirlength;
	register unsigned dotdotcounter;
	register char *d;

	if (ROOTPATH(RCSfilename)) {
                return(RCSfilename);
        } else {
		if (!wd) { /* Get working directory for the first time. */
		    if (!(d = cgetenv("PWD"))) {
			bufalloc(&wdbuf, 1 +
#			    ifdef PATH_MAX
				PATH_MAX
#			    else
				_POSIX_PATH_MAX
#			    endif
			);
			errno = 0;
#			if !has_getcwd
			    d = getwd(wdbuf.string);
#			else
			    while (
				    !(d = getcwd(wdbuf.string,(int)wdbuf.size))
				&&  errno==ERANGE
			    )
				bufalloc(&wdbuf, wdbuf.size<<1);
#			endif
			if (!d)
			    efaterror("working directory");
		    }
		    pathlength = strlen(d);
		    while (pathlength && d[pathlength-1]==SLASH) {
			d[--pathlength] = 0;
                        /* Check needed because some getwd implementations */
                        /* generate "/" for the root.                      */
                    }
		    wd = d;
                }
                /*the following must be redone since RCSfilename may change*/
		/* Find how many `../'s to remove from RCSfilename.  */
                dotdotcounter =0;
                realname = RCSfilename;
                while( realname[0]=='.' &&
                      (realname[1]==SLASH||(realname[1]=='.'&&realname[2]==SLASH))){
                        if (realname[1]==SLASH) {
                            /* drop leading ./ */
                            realname += 2;
                        } else {
                            /* drop leading ../ and remember */
                            dotdotcounter++;
                            realname += 3;
                        }
                }
		/* Now remove dotdotcounter trailing directories from wd. */
		parentdirlength = pathlength;
		while (dotdotcounter && parentdirlength) {
                    /* move pointer backwards over trailing directory */
		    if (wd[--parentdirlength] == SLASH) {
                        dotdotcounter--;
                    }
                }
		if (dotdotcounter) {
                    error("can't generate full path name for RCS file");
                    return RCSfilename;
                } else {
                    /* build full path name */
		    bufalloc(&rcsbuf, parentdirlength+strlen(realname)+2);
		    VOID strncpy(rcsbuf.string, wd, parentdirlength);
		    rcsbuf.string[parentdirlength++] = SLASH;
		    VOID strcpy(rcsbuf.string+parentdirlength, realname);
		    return rcsbuf.string;
		}
        }
}

	const char *
tmp()
/* Yield the name of the tmp directory, with a trailing SLASH.  */
{
	static const char *s;
	if (!s)
		if (!(s = getenv("TMP")))
			s = TMPDIR;
		else {
			size_t l = strlen(s);
			int extra = l && s[l-1]!=SLASH;
			char *p = ftnalloc(char, l + extra + 1);
			VOID strcpy(p, s);
			if (extra) {
				p[l] = SLASH;
				p[l+1] = 0;
			}
			s = p;
		}
	return s;
}


#if bad_unlink
/*
 * bad_unlink means unlink(A) fails if A is read-only.
 * unlink has been #defined to un_link.
 */

#undef unlink
	int
un_link(file)
const char *file;
{
	int e;
	/* first, try unlink outright */
	if (!unlink(file)) return 0;

	/* try chmod a+rwx - fail if can't even do that */
	if (e = chmod(file,0777)) return e;
	return unlink(file);
}
/* re-define unlink to un_link for remainder of this file */
#define unlink un_link
#endif

#if !has_rename | bad_rename

	int
re_name(from, to)
	const char *from, *to;
/* Function: renames a file with the name given by from to the name given by to.
 * unlinks the to-file if it already exists. returns -1 on error, 0 otherwise.
 */
{       VOID unlink(to);      /* no need to check return code; will be caught by link*/
                         /* no harm done if file "to" does not exist            */
#if terrible_rename
	/* terrible_rename is worse than bad_rename: you have */
	/* to make "from" writable before you can rename it.  */
	{
		struct stat st;
		int e;
		if (stat(from,&st)) return -1;	/* error: can't stat 'from' */
		if (chmod(from,0777)) return -1; /* can't chmod 'from' */
#if has_rename
		e = rename(from,to);
#else
		e = (link(from,to) || unlink(from));
#endif
		/* if this fails, it'll look like the rename failed! */
		if (chmod(to,st.st_mode)) return -1;
		return e;
	}
#else
/* !terrible_rename */
#if has_rename
	return rename(from,to);
#else
        if (link(from,to)<0) return -1;
        return(unlink(from));
#endif
#endif
}

#endif


#if !has_getcwd & !has_getwd

#if !MAKEDEPEND
#include <sys/dir.h>
#endif


#define dot     "."
#define dotdot  ".."



char * getwd(name)
char * name;
/* Function: places full pathname of current working directory into name and
 * returns name on success, NULL on failure.
 * getwd is an adaptation of pwd. May not return to the current directory on
 * failure.
 */
{
        FILE    *file;
        struct  stat    d, dd;
        char buf[2];    /* to NUL-terminate dir.d_name */
        struct  direct  dir;

        int rdev, rino;
        int off;
        register i,j;

	off = 0;
	name[0] = SLASH;
        name[1] = '\0';
        buf[0] = '\0';
	if (stat(name, &d)<0) return NULL;
        rdev = d.st_dev;
        rino = d.st_ino;
        for (;;) {
                if (stat(dot, &d)<0) return NULL;
                if (d.st_ino==rino && d.st_dev==rdev) {
			if (name[off] == SLASH)
				name[off] = '\0';
			VOID chdir(name); /*change back to current directory*/
                        return name;
                }
                if ((file = fopen(dotdot,"r")) == NULL) return NULL;
                if (fstat(fileno(file), &dd)<0) goto fail;
		VOID chdir(dotdot);
                if(d.st_dev == dd.st_dev) {
                        if(d.st_ino == dd.st_ino) {
			    if (name[off] == SLASH)
				name[off] = 0;
			    VOID chdir(name); /*change back to current directory*/
			    ffclose(file);
                            return name;
                        }
                        do {
                            if (fread((char *)&dir, sizeof(dir), 1, file) !=1)
                                goto fail;
                        } while (dir.d_ino != d.st_ino);
                }
                else do {
                        if(fread((char *)&dir, sizeof(dir), 1, file) != 1) {
                            goto fail;
                        }
                        if (dir.d_ino == 0)
			    dd.st_ino = d.st_ino + 1;
                        else if (stat(dir.d_name, &dd) < 0)
			    goto fail;
                } while(dd.st_ino != d.st_ino || dd.st_dev != d.st_dev);
		ffclose(file);

                /* concatenate file name */
                i = -1;
                while (dir.d_name[++i] != 0);
                for(j=off+1; j>0; --j)
                        name[j+i+1] = name[j];
                off=i+off+1;
		name[i+1] = SLASH;
                for(--i; i>=0; --i)
                        name[i+1] = dir.d_name[i];
        } /* end for */

fail:   ffclose(file);
        return NULL;
}


#endif


#ifdef PAIRTEST
/* test program for pairfilenames() and getfullRCSname() */

#if AKP_BUGFIXES
/* AKP: this function was missing when PAIRTEST is 1 */
exiting void 
exiterr()
{
	dirtempunlink();
	tempunlink();
	_exit(EXIT_FAILURE);
}
#endif

const char cmdid[] = "pair";

main(argc, argv)
int argc; char *argv[];
{
        int result;
        int initflag,tostdout;
        quietflag=tostdout=initflag=false;

#if AKP_BUGFIXES
	/* AKP: this was missing so errors didn't get printed */
	frewrite = stdout;
#endif

        while(--argc, ++argv, argc>=1 && ((*argv)[0] == '-')) {
                switch ((*argv)[1]) {

                case 'p':       tostdout=true;
                                break;
                case 'i':       initflag=true;
                                break;
                case 'q':       quietflag=true;
                                break;
                default:        error("unknown option: %s", *argv);
                                break;
                }
        }

        do {
                RCSfilename=workfilename=nil;
		result = pairfilenames(argc,argv,rcsreadopen,!initflag,tostdout);
                if (result!=0) {
		    diagnose("RCS file: %s; working file: %s\nFull RCS file name: %s\n",
			     RCSfilename,workfilename,getfullRCSname()
		    );
                }
                switch (result) {
                        case 0: continue; /* already paired file */

                        case 1: if (initflag) {
                                    error("RCS file %s exists already",RCSfilename);
                                } else {
				    diagnose("RCS file %s exists\n",RCSfilename);
                                }
				ffclose(finptr);
                                break;

			case -1:diagnose("RCS file doesn't exist\n");
                                break;
                }

        } while (++argv, --argc>=1);

}
#endif
