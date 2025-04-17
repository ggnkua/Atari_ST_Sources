/*
 *                     RCS utilities
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




/* $Log: rcsutil.c,v $
 * Revision 5.8  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.7  91/01/29  17:46:04  apratt
 * Added quotes around args with spaces in call to system
 * 
 * Revision 5.6  91/01/11  12:46:44  apratt
 * First version that compiles.
 * 
 * Revision 5.5  90/12/04  05:18:49  eggert
 * checked in with -k by apratt at 91.01.10.13.15.32.
 * 
 * Revision 5.5  1990/12/04  05:18:49  eggert
 * Don't output a blank line after a signal diagnostic.
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.4  1990/11/01  05:03:53  eggert
 * Remove unneeded setid check.  Add awrite(), fremember().
 *
 * Revision 5.3  1990/10/06  00:16:45  eggert
 * Don't fread F if feof(F).
 *
 * Revision 5.2  1990/09/04  08:02:31  eggert
 * Store fread()'s result in an fread_type object.
 *
 * Revision 5.1  1990/08/29  07:14:07  eggert
 * Declare getpwuid() more carefully.
 *
 * Revision 5.0  1990/08/22  08:13:46  eggert
 * Add setuid support.  Permit multiple locks per user.
 * Remove compile-time limits; use malloc instead.
 * Switch to GMT.  Permit dates past 1999/12/31.
 * Add -V.  Remove snooping.  Ansify and Posixate.
 * Tune.  Some USG hosts define NSIG but not sys_siglist.
 * Don't run /bin/sh if it's hopeless.
 * Don't leave garbage behind if the output is an empty pipe.
 * Clean up after SIGXCPU or SIGXFSZ.  Print name of signal that caused cleanup.
 *
 * Revision 4.6  89/05/01  15:13:40  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.5  88/11/08  16:01:02  narten
 * corrected use of varargs routines
 * 
 * Revision 4.4  88/08/09  19:13:24  eggert
 * Check for memory exhaustion.
 * Permit signal handlers to yield either 'void' or 'int'; fix oldSIGINT botch.
 * Use execv(), not system(); yield exit status like diff(1)'s.
 * 
 * Revision 4.3  87/10/18  10:40:22  narten
 * Updating version numbers. Changes relative to 1.1 actually
 * relative to 4.1
 * 
 * Revision 1.3  87/09/24  14:01:01  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:22:43  jenkins
 * Port to suns
 * 
 * Revision 4.1  83/05/10  15:53:13  wft
 * Added getcaller() and findlock().
 * Changed catchints() to check SIGINT for SIG_IGN before setting up the signal
 * (needed for background jobs in older shells). Added restoreints().
 * Removed printing of full RCS path from logcommand().
 * 
 * Revision 3.8  83/02/15  15:41:49  wft
 * Added routine fastcopy() to copy remainder of a file in blocks.
 *
 * Revision 3.7  82/12/24  15:25:19  wft
 * added catchints(), ignoreints() for catching and ingnoring interrupts;
 * fixed catchsig().
 *
 * Revision 3.6  82/12/08  21:52:05  wft
 * Using DATEFORM to format dates.
 *
 * Revision 3.5  82/12/04  18:20:49  wft
 * Replaced SNOOPDIR with SNOOPFILE; changed addlock() to update
 * lockedby-field.
 *
 * Revision 3.4  82/12/03  17:17:43  wft
 * Added check to addlock() ensuring only one lock per person.
 * Addlock also returns a pointer to the lock created. Deleted fancydate().
 *
 * Revision 3.3  82/11/27  12:24:37  wft
 * moved rmsema(), trysema(), trydiraccess(), getfullRCSname() to rcsfnms.c.
 * Introduced macro SNOOP so that snoop can be placed in directory other than
 * TARGETDIR. Changed %02d to %.2d for compatibility reasons.
 *
 * Revision 3.2  82/10/18  21:15:11  wft
 * added function getfullRCSname().
 *
 * Revision 3.1  82/10/13  16:17:37  wft
 * Cleanup message is now suppressed in quiet mode.
 */




#include "rcsbase.h"

#if !MAKEDEPEND && defined(declare_getpwuid)
#	include <pwd.h>
	declare_getpwuid
#endif

libId(utilId, "$Id: rcsutil.c,v 5.8 1991/01/30 14:21:32 apratt Exp $")

#if lint
	malloc_type lintalloc;
#endif

#if has_getuid
	uid_t ruid;
#endif
#if SETID
	static uid_t euid;
	static gid_t egid, rgid;
#endif

/*
 * list of blocks allocated with ftestalloc()
 * These blocks can be freed by ffree when we're done with the current file.
 * We could put the free block inside struct alloclist, rather than a pointer
 * to the free block, but that would be less portable.
 */
struct alloclist {
	malloc_type alloc;
	struct alloclist *nextalloc;
};
static struct alloclist *alloced;


	static malloc_type
okalloc(p)
	malloc_type p;
{
	if (!p)
		faterror("out of memory");
	return p;
}

	malloc_type
testalloc(size)
	size_t size;
/* Allocate a block, testing that the allocation succeeded.  */
{
	return okalloc(malloc(size));
}

	malloc_type
testrealloc(ptr, size)
	malloc_type ptr;
	size_t size;
/* Reallocate a block, testing that the allocation succeeded.  */
{
	return okalloc(realloc(ptr, size));
}

	malloc_type
fremember(ptr)
	malloc_type ptr;
/* Remember PTR in 'alloced' so that it can be freed later.  Yield PTR.  */
{
	register struct alloclist *q = talloc(struct alloclist);
	q->nextalloc = alloced;
	alloced = q;
	return q->alloc = ptr;
}

	malloc_type
ftestalloc(size)
	size_t size;
/* Allocate a block, putting it in 'alloced' so it can be freed later. */
{
	return fremember(testalloc(size));
}

	void
ffree()
/* Free all blocks allocated with ftestalloc().  */
{
	register struct alloclist *p, *q;
	for (p = alloced;  p;  p = q) {
		q = p->nextalloc;
		tfree(p->alloc);
		tfree(p);
	}
	alloced = nil;
}

	void
ffree1(f)
	register const char *f;
/* Free the block f, which was allocated by ftestalloc.  */
{
	register struct alloclist *p, **a = &alloced;

	while ((p = *a)->alloc  !=  f)
		a = &p->nextalloc;
	*a = p->nextalloc;
	tfree(p->alloc);
	tfree(p);
}

	const char *
strsave(s)
	const char *s;
/* Save s in permanently allocated storage. */
{
	return strcpy(tnalloc(char, strlen(s)+1), s);
}

	const char *
fstrsave(s)
	const char *s;
/* Save s in storage that will be deallocated when we're done with this file. */
{
	return strcpy(ftnalloc(char, strlen(s)+1), s);
}

	char *
cgetenv(name)
	const char *name;
/* Like getenv(), but yield a copy; getenv() can overwrite old results. */
{
	register char *p;

	return (p=getenv(name)) ? strsave(p) : p;
}


	const char *
getcaller()
/* Function: gets the caller's login.
 */
{
	static char *name;

	if (!name) {
		if (!(
		    /* Use getenv() if we're trustworthy; it's much faster.  */
#if SETID
			euid==ruid && egid==rgid &&
#endif
			(
				(name = cgetenv("LOGNAME"))
			||	(name = cgetenv("USER"))
			)

		    /* Follow a procedure recommended by Posix 1003.1-1988.  */
		    ||	(name = getlogin())
		)) {
#if has_getuid & defined(declare_getpwuid)
			const struct passwd *pw = getpwuid(ruid);
			if (!pw)
			    faterror("no password entry for userid %lu",
				     (unsigned long)ruid
			    );
			name = pw->pw_name;
#else
			faterror("Who are you?  Please set LOGNAME.");
#endif
		}
		checksid(name);
	}
	return name;
}



	int
findlock(delete, target)
	int delete;
	struct hshentry **target;
/* Finds the first lock held by caller and returns a pointer
 * to the locked delta; also removes the lock if delete is set.
 * Returns 0 for no locks, 1 for one, 2 for two or more.
 * If one lock, puts it into *target.
 */
{
	register struct lock *next, **trail, **found = nil;

	for (trail = &Locks;  (next = *trail);  trail = &next->nextlock)
		if (strcmp(getcaller(), next->login)  ==  0) {
			if (found) {
				error("multiple revisions locked by %s; please specify one", getcaller());
				return 2;
			}
			found = trail;
		}
	if (!found)
		return 0;
	next = *found;
	*target = next->delta;
	if (delete) {
		next->delta->lockedby = nil;
		*found = next->nextlock;
	}
	return 1;
}







	int
addlock(delta)
struct hshentry * delta;
/* Add a lock held by caller to delta and yield 1 if successful.
 * Print an error message and yield -1 if no lock is added because
 * the delta is locked by somebody other than caller.
 * Yield 0 if the caller already holds the lock.  */
{
        struct lock * next;

        next=Locks;
        while (next!=nil) {
                if (cmpnum(delta->num,next->delta->num)==0) {
			if (strcmp(getcaller(),next->login)==0)
				return 0;
                        else {
                                error("revision %s already locked by %s",
                                      delta->num, next->login);
				return -1;
                        }
                }
		next = next->nextlock;
	}
        /* set up new lockblock */
	next = ftalloc(struct lock);
	delta->lockedby=next->login=getcaller();
        next->delta= delta;
        next->nextlock=Locks;
        Locks=next;
	return 1;
}



	int
addsymbol(num, name, rebind)
	const char *num, *name;
	int rebind;
/* Function: adds a new symbolic name and associates it with revision num.
 * If name already exists and rebind is true, the name is associated
 * with the new num; otherwise, an error message is printed and
 * false returned. Returns true it successful.
 */
{       register struct assoc * next;
        next=Symbols;
        while (next!=nil) {
                if (strcmp(name,next->symbol)==0) {
                        if (rebind) {
				next->num = num;
                                return true;
                        } else {
                                error("symbolic name %s already bound to %s",
					name, next->num);
                                return false;
                        }
                } else  next = next->nextassoc;
        }
        /* not found; insert new pair. */
	next = ftalloc(struct assoc);
        next->symbol=name;
	next->num = num;
        next->nextassoc=Symbols;
        Symbols = next;
        return true;
}




int checkaccesslist()
/* function: Returns true if caller is the superuser, the owner of the
 * file, the access list is empty, or caller is on the access list.
 * Prints an error message and returns false otherwise.
 */
{
	register const struct access *next;

	if (!AccessList || strcmp(getcaller(),"root")==0)
                return true;

        next=AccessList;
        do {
		if (strcmp(getcaller(),next->login)==0)
                        return true;
                next=next->nextaccess;
        } while (next!=nil);

#if has_getuid
    {
        struct stat statbuf;
        VOID fstat(fileno(finptr),&statbuf);  /* get owner of file */
        if (myself(statbuf.st_uid)) return true;
    }
#endif

	error("user %s not on the access list", getcaller());
        return false;
}


/*
 *	 Signal handling
 *
 * ANSI C places too many restrictions on signal handlers.
 * We obey as many of them as we can.
 * Posix places fewer restrictions, and we are Posix-compatible here.
 */

#if DONT_USE_SIGNALS

void ignoreints() { ; }		/* stubs for signal-related functions */
void restoreints() { ; }
void catchints() { ; }

#else

static volatile sig_atomic_t heldsignal, holdlevel;

	static signal_type
catchsig(s)
	int s;
{
	const char *sname;
	char buf[BUFSIZ];

#if sig_zaps_handler
	/* If a signal arrives before we reset the signal handler, we lose. */
	VOID signal(s, SIG_IGN);
#endif
	if (holdlevel) {
		heldsignal = s;
		return;
	}
	ignoreints();
	setrid();
	if (!quietflag) {
	    sname = nil;
#if has_sys_siglist & defined(NSIG)
	    if ((unsigned)s < NSIG) {
#		ifndef sys_siglist
		    extern const char *sys_siglist[];
#		endif
		sname = sys_siglist[s];
	    }
#else
	    switch (s) {
#ifdef SIGHUP
		case SIGHUP:	sname = "Hangup";  break;
#endif
#ifdef SIGINT
		case SIGINT:	sname = "Interrupt";  break;
#endif
#ifdef SIGPIPE
		case SIGPIPE:	sname = "Broken pipe";  break;
#endif
#ifdef SIGQUIT
		case SIGQUIT:	sname = "Quit";  break;
#endif
#ifdef SIGTERM
		case SIGTERM:	sname = "Terminated";  break;
#endif
#ifdef SIGXCPU
		case SIGXCPU:	sname = "Cputime limit exceeded";  break;
#endif
#ifdef SIGXFSZ
		case SIGXFSZ:	sname = "Filesize limit exceeded";  break;
#endif
	    }
#endif
	    if (sname)
		VOID sprintf(buf, "\nRCS: %s.  Cleaning up.\n", sname);
	    else
		VOID sprintf(buf, "\nRCS: Signal %d.  Cleaning up.\n", s);
	    VOID write(STDERR_FILENO, buf, strlen(buf));
	}
	exiterr();
}

	void
ignoreints()
{
	++holdlevel;
}

	void
restoreints()
{
	if (!--holdlevel && heldsignal)
		VOID catchsig(heldsignal);
}

static const sig[] = {
#ifdef SIGHUP
	SIGHUP,
#endif
#ifdef SIGINT
	SIGINT,
#endif
#ifdef SIGPIPE
	SIGPIPE,
#endif
#ifdef SIGQUIT
	SIGQUIT,
#endif
#ifdef SIGTERM
	SIGTERM,
#endif
#ifdef SIGXCPU
	SIGXCPU,
#endif
#ifdef SIGXFSZ
	SIGXFSZ,
#endif
};
#define SIGS (sizeof(sig)/sizeof(*sig))


#if has_sigaction

	static void
  checksig(r)
	int r;
  {
	if (r < 0)
		efaterror("signal");
  }

	void
  catchints()
  {
	register int i;
	sigset_t blocked;
	struct sigaction act;

	checksig(sigemptyset(&blocked));
	for (i=SIGS; 0<=--i; )
	    checksig(sigaddset(&blocked, sig[i]));
	for (i=SIGS; 0<=--i; ) {
	    checksig(sigaction(sig[i], (struct sigaction*)nil, &act));
	    if (act.sa_handler != SIG_IGN) {
		    act.sa_handler = catchsig;
		    act.sa_mask = blocked;
		    checksig(sigaction(sig[i], &act, (struct sigaction*)nil));
	    }
	}
  }

#else
#if has_sigblock

  void catchints()
  {
	register int i;
	int mask;

	mask = 0;
	for (i=SIGS; 0<=--i; )
		mask |= sigmask(sig[i]);
	mask = sigblock(mask);
	for (i=SIGS; 0<=--i; )
		if (signal(sig[i], catchsig) == SIG_IGN)
			VOID signal(sig[i], SIG_IGN);
	VOID sigsetmask(mask);
  }

#else

  void catchints()
  {
	register i;
	for (i=SIGS; 0<=--i; )
		if (signal(sig[i], SIG_IGN) != SIG_IGN)
			VOID signal(sig[i], catchsig);
  }

#endif
#endif

/* end if DONT_USE_SIGNALS */
#endif 

	void
fastcopy(inf,outf)
FILE * inf, * outf;
/* Function: copies the remainder of file inf to outf.
 */
{       char buf[BUFSIZ];
	register fread_type rcount;

        /*now read the rest of the file in blocks*/
	while (!feof(inf)  &&  (rcount = fread(buf,sizeof(char),BUFSIZ,inf))) {
		awrite(buf, rcount, outf);
        }
}

	void
awrite(buf, chars, f)
	const char *buf;
	fread_type chars;
	FILE *f;
{
	if (fwrite(buf, sizeof(char), chars, f) != chars)
		IOerror();
}





/*
* Print RCS format date and time in user-readable format.
*/
	void
printdate(f, date, separator)
	register FILE *f;
	const char *date, *separator;
{
	register const char *p = date;

	while (*p++ != '.')
		;
	aprintf(f, "%s%.*s/%.2s/%.2s%s%.2s:%.2s:%s",
		date[2]=='.' && VERSION(5)<=RCSversion  ?  "19"  :  "",
		p-date-1, date,
		p, p+3, separator, p+6, p+9, p+12
	);
}




#if !DONT_USE_FORK
static int fdreopen(fd, file, flags, mode)
	int fd;
	const char *file;
	int flags;
	mode_t mode;
{
	int newfd;
	VOID close(fd);
	newfd =
#if !open_can_creat
		flags&O_CREAT ? creat(file,mode) :
#endif
		open(file,flags,mode);
	if (newfd < 0  ||  newfd == fd)
		return newfd;
	fd = dup2(newfd, fd);
	VOID close(newfd);
	return fd;
}

static void tryopen(fd,file,flags)
	int fd, flags;
	const char *file;
{
	if (file  &&  fdreopen(fd,file,flags,S_IRUSR|S_IWUSR) != fd) {
		VOID write(STDERR_FILENO, file, strlen(file));
		VOID write(STDERR_FILENO, ": can't open\n", 13);
		_exit(EXIT_TROUBLE);
	}
}

/*
* Run a command specified by the strings in 'inoutargs'.
* inoutargs[0], if nonnil, is the name of the input file.
* inoutargs[1], if nonnil, is the name of the output file.
* inoutargs[2..] form the command to be run.
*/
	int
runv(inoutargs)
	const char **inoutargs;
{
	int pid;
	int wstatus, w;
	register const char **p;
	oflush();
	eflush();

	if (!(pid = vfork())) {
		p = inoutargs;
		tryopen(STDIN_FILENO, *p++, O_RDONLY);
		tryopen(STDOUT_FILENO, *p++, O_CREAT|O_TRUNC|O_WRONLY);
		VOID EXECRCS(*p, p);
		if (errno == ENOEXEC) {
			*--p = "/bin/sh";
			VOID execv(*p, p);
		}
		VOID write(STDERR_FILENO, *p, strlen(*p));
		VOID write(STDERR_FILENO, ": not found\n", 12);
		_exit(EXIT_TROUBLE);
	}
	if (pid < 0)
		return pid;
	do {
		if ((w = wait(&wstatus)) < 0)
			return w;
	} while (w != pid);
	return wstatus;
}
#else
	int
runv(inoutargs)
	const char **inoutargs;
{
	char *rargs;
	int rargs_len;
	int rargs_size;
	const char *infile, *outfile;
	int r;

	oflush();
	eflush();

	infile = *inoutargs++;
	outfile = *inoutargs++;

	/* pre-set rargs_len to the length of the redirection part */
	rargs_len = 0;
	if (infile) rargs_len += strlen(infile) + 2;
	if (outfile) rargs_len += strlen(outfile) + 2;

	rargs_size = rargs_len + 32;

	rargs = testalloc(rargs_size);
	*rargs = '\0';

	/* strcat each arg to rargs, realloc'ing more room as necessary */
	/* If an arg contains a space, then wrap it in quotes. */
	while (*inoutargs) {
		if (rargs_len + strlen(*inoutargs) + 4 > rargs_size) {
			rargs_size += strlen(*inoutargs) + 128;
			rargs = testrealloc(rargs,rargs_size);
		}
		if (strchr(*inoutargs,' ') != NULL) {
			rargs_len += strlen(*inoutargs) + 3;
			strcat(rargs,"\"");
			strcat(rargs,*inoutargs++);
			strcat(rargs,"\" ");
		}
		else {
			rargs_len += strlen(*inoutargs) + 1;
			strcat(rargs,*inoutargs++);
			strcat(rargs," ");
		}
	}
	if (infile) {
		strcat(rargs," <");
		strcat(rargs,infile);
	}
	if (outfile) {
		strcat(rargs," >");
		strcat(rargs,outfile);
	}
	r = system(rargs);
	free(rargs);
	return r;
}
#endif

#define CARGSMAX 20
/*
* Run a command.
* The first two arguments are the input and output files (if nonnil);
* the rest specify the command and its arguments.
*/
	int
#if has_prototypes
run(const char *infile, const char *outfile, ...)
#else
	/*VARARGS2*/
run(infile, outfile, va_alist)
	const char *infile;
	const char *outfile;
	va_dcl
#endif
{
	va_list ap;
	const char *rgargs[CARGSMAX];
	register i = 0;
	rgargs[0] = infile;
	rgargs[1] = outfile;
	vararg_start(ap, outfile);
	for (i = 2;  (rgargs[i++] = va_arg(ap, const char*));  )
		if (CARGSMAX <= i)
			faterror("too many command arguments");
	va_end(ap);
	return runv(rgargs);
}


int RCSversion;

	void
setRCSversion(str)
	const char *str;
{
	static const char *oldversion;

	register const char *s = str + 2;
	int v = VERSION_DEFAULT;

	if (oldversion)
		redefined('V');
	oldversion = str;

	if (*s) {
		v = 0;
		while (isdigit(*s))
			v  =  10*v + *s++ - '0';
		if (*s)
			faterror("%s isn't a number", str);
		if (v < VERSION_MIN  ||  VERSION_MAX < v)
			faterror("%s out of range %d..%d", str, VERSION_MIN, VERSION_MAX);
	}

	RCSversion = VERSION(v);
}

	void
initid()
{
#if SETID
	egid = getegid();
	euid = geteuid();
	rgid = getgid();
#endif
#if has_getuid
	ruid = getuid();
#endif
#if SETID || !AKP_BUGFIXES
	/* AKP: originally, setrid was called even if !SETID */
	setrid();
#endif
}


#if SETID
	void
seteid()
/* Become effective user and group.  */
{
	if (euid!=ruid && seteuid(euid)<0  ||  egid!=rgid && setegid(egid)<0)
		efaterror("seteid");
}

	void
setrid()
/* Become real user and group.  */
{
	if (euid!=ruid && seteuid(ruid)<0  ||  egid!=rgid && setegid(rgid)<0)
		efaterror("setrid");
}
#endif

