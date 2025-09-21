/*

	Copyright (C) 1988 Free Software Foundation

GNU tar is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the GNU tar General Public License for full details.

Everyone is granted permission to copy, modify and redistribute GNU tar,
but only under the conditions described in the GNU tar General Public
License.  A copy of this license is supposed to have been given to you
along with GNU tar so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

In other words, go ahead and share GNU tar, but don't try to stop
anyone else from sharing it farther.  Help stamp out software hoarding!
*/

/*
 * @(#)port.c 1.15	87/11/05	by John Gilmore, 1986
 *
 * These are routines not available in all environments.
 *
 * I know this introduces an extra level of subroutine calls and is
 * slightly slower.  Frankly, my dear, I don't give a damn.  Let the
 * Missed-Em Vee losers suffer a little.  This software is proud to
 * have been written on a BSD system.
 */
#include <stdio.h>
#ifdef atarist
#include <types.h>
#include <time.h>
#include <stat.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif
#include <signal.h>
#include <errno.h>

#ifdef MSDOS
#include <fcntl.h>
#else
#include <sys/file.h>
#endif

#include "tar.h"
#include "port.h"

extern size_t strlen();

extern long baserec;
/*
 * Some people (e.g. V7) don't have a #define for these.
 */
#ifndef	O_BINARY
#define	O_BINARY	0
#endif
#ifndef	O_RDONLY
#define	O_RDONLY	0
#endif
#ifndef NULL
#define NULL 0
#endif

/* JF: modified so all configuration information can appear here, instead of
   being scattered through the file.  Add all the machine-dependent #ifdefs
   here */
#undef WANT_DUMB_GETDATE/* WANT_DUMB_GETDATE --> getdate() */
#undef WANT_LSTAT	/* WANT_LSTAT --> lstat() */
#undef WANT_VALLOC	/* WANT_VALLOC --> valloc() */
#undef WANT_MKDIR	/* WANT_MKDIR --> mkdir() */
#undef WANT_STRING	/* WANT_STRING --> index() bcopy() bzero() bcmp() */
#undef WANT_BZERO	/* WANT_BZERO --> bzero() bcmp() execlp() */
			/* EMUL_OPEN3 --> open3() */
#undef WANT_MKNOD	/* WANT_MKNOD --> mknod() link() chown() geteuid() */
#undef WANT_UTILS	/* WANT_UTILS --> panic() ck_*() *_buffer()
			   merge_sort() quote_copy_string() un_quote_string() */
#undef WANT_CK_PIPE	/* WANT_CK_PIPE --> ck_pipe() getwd() */
#undef WANT_GETOPT	/* WANT_GETOPT --> getopt() optind optarg */
#undef WANT_STRSTR	/* WANT_STRSTR --> strstr() */

/* Define only ONE of these four . . . */
#undef DOPRNT_MSG	/* Define this one if you have _doprnt() and
			   no varargs support */
#undef VARARGS_MSG	/* Define this one if you have varargs.h and
			   vfprintf() */
#undef STDC_MSG		/* Define this one if you are using ANSI C and
			   and have vfprintf() */
#undef LOSING_MSG	/* Define this one if you don't have any of the
			   above */
#ifdef USG
#define WANT_STRING
#define WANT_VALLOC
#endif

#ifdef MINIX
#define WANT_BZERO
#endif

/* MSDOS stuff changed around for atarist by ERS */
#ifdef MSDOS
# define WANT_LSTAT
# define WANT_MKNOD
# define WANT_UTILS
# define WANT_GETOPT
# define WANT_VALLOC
# ifdef atarist
#  define WANT_DUMB_GETDATE
#  define VARARGS_MSG
# else
#  define WANT_STRING
# endif
#else
# define VARARGS_MSG
# define WANT_UTILS
# define WANT_CK_PIPE
# define WANT_STRSTR
# define WANT_GETOPT
#endif

/* End of system-dependent #ifdefs */

#ifdef WANT_DUMB_GETDATE
/* JF a getdate() routine takes a date/time/etc and turns it into a time_t */
/* This one is a quick hack I wrote in about five minutes to see if the N
   option works.  Someone should replace it with one that works */

/* This getdate takes an arg of the form mm/dd/yyyy hh:mm:ss and turns it
   into a time_t .  Its not well tested or anything. . .  */
/* In general, you should use the getdate() supplied in getdate.y */

/*#define OFF_FROM_GMT 18000		/* Change for your time zone! */
#define OFF_FROM_GMT 0

time_t
getdate(str)
char *str;
{
	int month,day,year,hour,minute,second;
#ifdef atarist
	struct tm t;
	int	n;
#else
	time_t ret;
	int	n;

#define SECS_PER_YEAR (365L*SECS_PER_DAY)
#define SECS_PER_LEAP_YEAR (366L*SECS_PER_DAY)

#define SECS_PER_DAY (24L*60*60)
	static int days_per_month[2][12] = {
		31,28,31,30,31,30,31,31,30,31,30,31,
		31,29,31,30,31,30,31,31,30,31,30,31
	};

	static int days_per_year[2]={365,366};
#endif
	month=day=year=hour=minute=second=0;
	n=sscanf(str,"%d/%d/%d %d:%d:%d",&month,&day,&year,&hour,&minute,&second);
	if(n<3)
		return 0;
	if(year<100)
		year+=1900;
	if(year<1970)
		return 0;
#ifdef atarist
	t.tm_sec = second;
	t.tm_min = minute;
	t.tm_hour = hour;
	t.tm_mday = day;
	t.tm_mon = month - 1;
	t.tm_year = year - 1900;
	return mktime(&t);
#else
	ret=0;

	ret+=OFF_FROM_GMT;

	for(n=1970;n<year;n++)
		if(n%4==0 && n%400!=0)
			ret+=SECS_PER_LEAP_YEAR;
		else
			ret+=SECS_PER_YEAR;

	month--;
	for(n=0;n<month;n++) {
		if(year%4==0 && year%400!=0)
			ret+=SECS_PER_DAY*days_per_month[1][n];
		else
			ret+=SECS_PER_DAY*days_per_month[0][n];
	}
	ret+=SECS_PER_DAY*(day-1);
	ret+=second+minute*60+hour*60*60;
	return ret;
#endif /* atarist */
}
#endif

/*
 * lstat() is a stat() which does not follow symbolic links.
 * If there are no symbolic links, just use stat().
 */
#ifdef WANT_LSTAT
int
lstat (path, buf)
	char *path;
	struct stat *buf;
{
	extern int stat ();
	return (stat (path, buf));
}
#endif

#ifdef WANT_VALLOC
/*
 * valloc() does a malloc() on a page boundary.  On some systems,
 * this can make large block I/O more efficient.
 */
char *
valloc (size)
	unsigned size;
{
	extern char *malloc ();
	return (malloc (size));
}
#endif
/*
 *				NMKDIR.C
 *
 * Written by Robert Rother, Mariah Corporation, August 1985. 
 *
 * I wrote this out of shear disgust with myself because I couldn't
 * figure out how to do this in /bin/sh.
 *
 * If you want it, it's yours.  All I ask in return is that if you
 * figure out how to do this in a Bourne Shell script you send me
 * a copy.
 *					sdcsvax!rmr or rmr@uscd
*
* Severely hacked over by John Gilmore to make a 4.2BSD compatible
* subroutine.	11Mar86; hoptoad!gnu
*
* Modified by rmtodd@uokmax 6-28-87 -- when making an already existing dir,
* subroutine didn't return EEXIST.  It does now.
*/

/*
 * Make a directory.  Compatible with the mkdir() system call on 4.2BSD.
 */
#ifdef WANT_MKDIR
int
mkdir(dpath, dmode)
	char *dpath;
	int dmode;
{
	int cpid, status;
	struct stat statbuf;
	extern int errno;

	if (stat(dpath,&statbuf) == 0) {
		errno = EEXIST;		/* Stat worked, so it already exists */
		return -1;
	}

	/* If stat fails for a reason other than non-existence, return error */
	if (errno != ENOENT) return -1; 

	switch (cpid = fork()) {

	case -1:			/* Error in fork() */
		return(-1);		/* Errno is set already */

	case 0:				/* Child process */
		/*
		 * Cheap hack to set mode of new directory.  Since this
		 * child process is going away anyway, we zap its umask.
		 * FIXME, this won't suffice to set SUID, SGID, etc. on this
		 * directory.  Does anybody care?
		 */
		status = umask(0);	/* Get current umask */
		status = umask(status | (0777 & ~dmode)); /* Set for mkdir */
		execl("/bin/mkdir", "mkdir", dpath, (char *)0);
		_exit(-1);		/* Can't exec /bin/mkdir */
	
	default:			/* Parent process */
		while (cpid != wait(&status)) ;	/* Wait for kid to finish */
	}

	if (TERM_SIGNAL(status) != 0 || TERM_VALUE(status) != 0) {
		errno = EIO;		/* We don't know why, but */
		return -1;		/* /bin/mkdir failed */
	}

	return 0;
}
#endif

#ifdef WANT_STRING
/*
 * Translate V7 style into Sys V style.
 */
#include <string.h>
#include <memory.h>

char *
index (s, c)
	char *s;
	int c;
{
	return (strchr (s, c));
}

char *
rindex(s,c)
char *s;
int c;
{
	return strrchr(s,c);
}

void
bcopy (s1, s2, n)
	char *s1, *s2;
	int n;
{
	(void) memcpy (s2, s1, n);
}

void
bzero (s1, n)
	char *s1;
	int n;
{
	(void) memset(s1, 0, n);
}

int
bcmp(s1, s2, n)
	char	*s1, *s2;
	int	n;
{
	return memcmp(s1, s2, n);
}
#endif

#ifdef WANT_BZERO
/* Minix has bcopy but not bzero, and no memset.  Thanks, Andy. */
void
bzero (s1, n)
	register char *s1;
	register int n;
{
	while (n--) *s1++ = '\0';
}

/* It also has no bcmp() */
int
bcmp (s1, s2, n) 
	register char *s1,*s2;
	register int n;
{
	for ( ; n-- ; ++s1, ++s2) {
		if (*s1 != *s2) return *s1 - *s2;
	}
	return 0;
}

/*
 * Groan, Minix doesn't have execlp either!
 *
 * execlp(file,arg0,arg1...argn,(char *)NULL)
 * exec a program, automatically searching for the program through
 * all the directories on the PATH.
 *
 * This version is naive about variable argument lists, it assumes
 * a straightforward C calling sequence.  If your system has odd stacks
 * *and* doesn't have execlp, YOU get to fix it.
 */
int
execlp(filename, arg0)
	char *filename, *arg0;
{
	register char *p, *path;    
	register char *fnbuffer;
	char **argstart = &arg0;
	struct stat statbuf;
	extern char **environ;
	extern int errno;
	extern char *malloc(), *getenv(), *index();

	if ((p = getenv("PATH")) == NULL) {
		/* couldn't find path variable -- try to exec given filename */
		return execve(filename, argstart, environ);
	}

	/*
	 * make a place to build the filename.  We malloc larger than we
	 * need, but we know it will fit in this.
	 */
	fnbuffer = malloc( strlen(p) + 1 + strlen(filename) );
	if (fnbuffer == NULL) {
		errno = ENOMEM;
		return -1;
	}

	/*
	 * try each component of the path to see if the file's there
	 * and executable.
	 */
	for (path = p ; path ; path = p) {
		/* construct full path name to try */
		if ((p = index(path,':')) == NULL) {
			strcpy(fnbuffer, path);
		} else {
			strncpy(fnbuffer, path, p-path);
			fnbuffer[p-path] = '\0';
			p++;		/* Skip : for next time */
		}
		if (strlen(fnbuffer) != 0)
			strcat(fnbuffer,"/");
		strcat(fnbuffer,filename);

		/* check to see if file is there and is a normal file */
		if (stat(fnbuffer, &statbuf) < 0) {
			if (errno == ENOENT)
				continue; /* file not there,keep on looking */
			else
				goto fail; /* failed for some reason, return */
		}
		if ( (statbuf.st_mode & S_IFMT) != S_IFREG) continue;

		if (execve(fnbuffer, argstart, environ) < 0
		    && errno != ENOENT
		    && errno != ENOEXEC) {
			/* failed, for some other reason besides "file
			 * not found" or "not a.out format"
			 */
			goto fail;
		}

		/*
		 * If we got error ENOEXEC, the file is executable but is
		 * not an object file.  Try to execute it as a shell script,
		 * returning error if we can't execute /bin/sh.
		 *
		 * FIXME, this code is broken in several ways.  Shell
		 * scripts should not in general be executed by the user's
		 * SHELL variable program.  On more mature systems, the
		 * script can specify with #!/bin/whatever.  Also, this
		 * code clobbers argstart[-1] if the exec of the shell
		 * fails.
		 */
		if (errno == ENOEXEC) {
			char *shell;

			/* Try to execute command "sh arg0 arg1 ..." */
			if ((shell = getenv("SHELL")) == NULL)
				shell = "/bin/sh";
			argstart[-1] = shell;
			argstart[0] = fnbuffer;
			execve(shell, &argstart[-1], environ);
			goto fail;	/* Exec didn't work */
		}

		/* 
		 * If we succeeded, the execve() doesn't return, so we
		 * can only be here is if the file hasn't been found yet.
		 * Try the next place on the path.
		 */
	}

	/* all attempts failed to locate the file.  Give up. */
	errno = ENOENT;

fail:
	free(fnbuffer);
	return -1;
}
#endif


#ifdef EMUL_OPEN3
#include "open3.h"
/*
 * open3 -- routine to emulate the 3-argument open system
 * call that is present in most modern Unix systems.
 * This version attempts to support all the flag bits except for O_NDELAY
 * and O_APPEND, which are silently ignored.  The emulation is not as efficient
 * as the real thing (at worst, 4 system calls instead of one), but there's
 * not much I can do about that.
 *
 * Written 6/10/87 by rmtodd@uokmax
 *
 * open3(path, flag, mode)
 * Attempts to open the file specified by
 * the given pathname.  The following flag bits (#defined in tar.h)
 * specify options to the routine:
 *	O_RDONLY	file open for read only
 *	O_WRONLY	file open for write only
 *	O_RDWR		file open for both read & write
 * (Needless to say, you should only specify one of the above).
 * 	O_CREAT		file is created with specified mode if it needs to be.
 *	O_TRUNC		if file exists, it is truncated to 0 bytes
 *	O_EXCL		used with O_CREAT--routine returns error if file exists
 * Function returns file descriptor if successful, -1 and errno if not.
 */

/*
 * array to give arguments to access for various modes
 * FIXME, this table depends on the specific integer values of O_XXX,
 * and also contains integers (args to 'access') that should be #define's.
 */
static int modes[] =
	{
		04, /* O_RDONLY */
		02, /* O_WRONLY */
		06, /* O_RDWR */
		06, /* invalid but we'd better cope -- O_WRONLY+O_RDWR */
	};

/* Shut off the automatic emulation of open(), we'll need it. */
#undef open

int
open3(path, flags, mode)
char *path;
int flags, mode;
{
	extern int errno;
	int exists = 1;
	int call_creat = 0;
	int fd;
	/*
	 * We actually do the work by calling the open() or creat() system
	 * call, depending on the flags.  Call_creat is true if we will use 
	 * creat(), false if we will use open().
	 */

	/*
	 * See if the file exists and is accessible in the requested mode. 
	 *
	 * Strictly speaking we shouldn't be using access, since access checks
	 * against real uid, and the open call should check against euid.
	 * Most cases real uid == euid, so it won't matter.   FIXME.
	 * FIXME, the construction "flags & 3" and the modes table depends
	 * on the specific integer values of the O_XXX #define's.  Foo!
	 */
	if (access(path,modes[flags & 3]) < 0) {
		if (errno == ENOENT) {
			/* the file does not exist */
			exists = 0;
		} else {
			/* probably permission violation */
			if (flags & O_EXCL) {
				/* Oops, the file exists, we didn't want it. */
				/* No matter what the error, claim EEXIST. */
				errno = EEXIST;
			}
			return -1;
		}
	}

	/* if we have the O_CREAT bit set, check for O_EXCL */
	if (flags & O_CREAT) {
		if ((flags & O_EXCL) && exists) {
			/* Oops, the file exists and we didn't want it to. */
			errno = EEXIST;
			return -1;
		}
		/*
		 * If the file doesn't exist, be sure to call creat() so that
		 * it will be created with the proper mode.
		 */
		if (!exists) call_creat = 1;
	} else {
		/* If O_CREAT isn't set and the file doesn't exist, error. */
		if (!exists) {
			errno = ENOENT;
			return -1;
		}
	}

	/*
	 * If the O_TRUNC flag is set and the file exists, we want to call
	 * creat() anyway, since creat() guarantees that the file will be
	 * truncated and open()-for-writing doesn't.
	 * (If the file doesn't exist, we're calling creat() anyway and the
	 * file will be created with zero length.)
	 */
	if ((flags & O_TRUNC) && exists) call_creat = 1;
	/* actually do the call */
	if (call_creat) {
		/*
		 * call creat.  May have to close and reopen the file if we
		 * want O_RDONLY or O_RDWR access -- creat() only gives
		 * O_WRONLY.
		 */
		fd = creat(path,mode);
		if (fd < 0 || (flags & O_WRONLY)) return fd;
		if (close(fd) < 0) return -1;
		/* Fall out to reopen the file we've created */
	}

	/*
	 * calling old open, we strip most of the new flags just in case.
	 */
	return open(path, flags & (O_RDONLY|O_WRONLY|O_RDWR|O_BINARY));
}
#endif

#ifdef	WANT_MKNOD
/* Fake mknod by complaining */
int
mknod(path, mode, dev)
	char		*path;
	unsigned short	mode;
	dev_t		dev;
{
	extern int	errno;
	int		fd;
	
	errno = ENXIO;		/* No such device or address */
	return -1;		/* Just give an error */
}

/* Fake links by copying */
int
link(path1, path2)
	char		*path1;
	char		*path2;
{
	char	buf[256];
	int	ifd, ofd;
	int	nrbytes;
	int	nwbytes;

	fprintf(stderr, "%s: %s: cannot link to %s, copying instead\n",
		tar, path1, path2);
	if ((ifd = open(path1, O_RDONLY|O_BINARY)) < 0)
		return -1;
	if ((ofd = creat(path2, 0666)) < 0)
		return -1;
	setmode(ofd, O_BINARY);
	while ((nrbytes = read(ifd, buf, sizeof(buf))) > 0) {
		if ((nwbytes = write(ofd, buf, nrbytes)) != nrbytes) {
			nrbytes = -1;
			break;
		}
	}
	/* Note use of "|" rather than "||" below: we want to close
	 * the files even if an error occurs.
	 */
	if ((nrbytes < 0) | (0 != close(ifd)) | (0 != close(ofd))) {
		unlink(path2);
		return -1;
	}
	return 0;
}

#ifndef atarist
/* everyone owns everything on MS-DOS (or is it no one owns anything?) */
int
chown(path, uid, gid)
	char	*path;
	int	uid;
	int	gid;
{
	return 0;
}

int
geteuid()
{
	return 0;
}
#endif
#endif	/* WANT_MKNOD */

#ifdef WANT_UTILS
/* Stash argv[0] here so panic will know what the program is called */
char *myname = 0;

void
panic(s)
char *s;
{
	if(myname)
		fprintf(stderr,"%s:",myname);
	fprintf(stderr,s);
	putc('\n',stderr);
	exit(12);
}

char *
ck_realloc(ptr,size)
char *ptr;
size_t size;
{
	char *ret;
	char *realloc();

	ret=realloc(ptr,size);
	if(ret==0)
		panic("Couldn't re-allocate memory");
	return ret;
}


/* Implement a variable sized buffer of 'stuff'.  We don't know what it is,
   nor do we care, as long as it doesn't mind being aligned on a char boundry.
 */

struct buffer {
	int	allocated;
	int	length;
	char	*b;
};

#define MIN_ALLOCATE 50

char *
init_buffer()
{
	struct buffer *b;
	char *ck_malloc();

	b=(struct buffer *)ck_malloc(sizeof(struct buffer));
	b->allocated=MIN_ALLOCATE;
	b->b=(char *)ck_malloc(MIN_ALLOCATE);
	b->length=0;
	return (char *)b;
}

void
flush_buffer(bb)
char *bb;
{
	struct buffer *b;

	b=(struct buffer *)bb;
	free(b->b);
	b->b=0;
	b->allocated=0;
	b->length=0;
	free((void *)b);
}

void
add_buffer(bb,p,n)
char *bb;
char *p;
int n;
{
	struct buffer *b;

	b=(struct buffer *)bb;
	if(b->length+n>b->allocated) {
		b->allocated*=2;
		b->b=(char *)ck_realloc(b->b,b->allocated);
	}
	bcopy(p,b->b+b->length,n);
	b->length+=n;
}

char *
get_buffer(bb)
char *bb;
{
	struct buffer *b;

	b=(struct buffer *)bb;
	return b->b;
}

char *
merge_sort(list,n,off,cmp)
char *list;
int (*cmp)();
unsigned n;
int off;
{
	char *ret;

	char *alist,*blist;
	unsigned alength,blength;

	char *tptr;
	int tmp;
	char **prev;
#define NEXTOF(ptr)	(* ((char **)(((char *)(ptr))+off) ) )
	if(n==1)
		return list;
	if(n==2) {
		if((*cmp)(list,NEXTOF(list))>0) {
			ret=NEXTOF(list);
			NEXTOF(ret)=list;
			NEXTOF(list)=0;
			return ret;
		}
		return list;
	}
	alist=list;
	alength=(n+1)/2;
	blength=n/2;
	for(tptr=list,tmp=(n-1)/2;tmp;tptr=NEXTOF(tptr),tmp--)
		;
	blist=NEXTOF(tptr);
	NEXTOF(tptr)=0;

	alist=merge_sort(alist,alength,off,cmp);
	blist=merge_sort(blist,blength,off,cmp);
	prev = &ret;
	for(;alist && blist;) {
		if((*cmp)(alist,blist)<0) {
			tptr=NEXTOF(alist);
			*prev = alist;
			prev = &(NEXTOF(alist));
			alist=tptr;
		} else {
			tptr=NEXTOF(blist);
			*prev = blist;
			prev = &(NEXTOF(blist));
			blist=tptr;
		}
	}
	if(alist)
		*prev = alist;
	else
		*prev = blist;

	return ret;
}

char *
ck_malloc(size)
size_t size;
{
	char *ret;
	char *malloc();

	ret=malloc(size);
	if(ret==0)
		panic("Couldn't allocate memory");
	return ret;
}

void
ck_close(fd)
int fd;
{
	if(close(fd)<0) {
		msg_perror("can't close a file");
		exit(EX_SYSTEM);
	}
}

#include <ctype.h>
#ifdef sparc
#include "alloca.h"
#endif

/* Quote_copy_string is like quote_string, but instead of modifying the
   string in place, it malloc-s a copy  of the string, and returns that.
   If the string does not have to be quoted, it returns the NULL string.
   The allocated copy can, of course, be freed with free() after the
   caller is done with it.
 */
char *
quote_copy_string(string)
char *string;
{
	char	*ret;
	char	*from_here;
	char	*to_there = 0;
	char	*copy_buf = 0;
	int	c;
	int	copying = 0;
	void	*alloca();

	ret=string;

	from_here=string;
	while(*from_here) {
		c= *from_here++;
		if(c=='\\') {
			if(!copying) {
				int n;

				n=(from_here-string)-1;
				copying++;
				copy_buf=(char *)malloc(n+1+strlen(from_here)*4);
				bcopy(string,copy_buf,n);
				to_there=copy_buf+n;
			}
			*to_there++='\\';
			*to_there++='\\';
		} else if(isprint(c)) {
			if(copying)
				*to_there++= c;
		} else {
			if(!copying) {
				int	n;

				n=(from_here-string)-1;
				copying++;
				copy_buf=(char *)malloc(n+1+strlen(from_here)*4);
				bcopy(string,copy_buf,n);
				to_there=copy_buf+n;
			}
			*to_there++='\\';
			if(c=='\n') *to_there++='n';
			else if(c=='\t') *to_there++='t';
			else if(c=='\f') *to_there++='f';
			else if(c=='\b') *to_there++='b';
			else if(c=='\r') *to_there++='r';
			else if(c=='\177') *to_there++='?';
			else {
				to_there[0]=(c>>6)+'0';
				to_there[1]=((c>>3)&07)+'0';
				to_there[2]=(c&07)+'0';
				to_there+=3;
			}
		}
	}
	if(copying) {
		*to_there='\0';
		return copy_buf;
	}
	return (char *)0;
}


/* Un_quote_string takes a quoted c-string (like those produced by
   quote_string or quote_copy_string and turns it back into the
   un-quoted original.  This is done in place.

   HACK FOR ATARI ST: change '\' into '/', so people can use GEMDOS
   style path names; this loses if un_quote_string gets called by
   anyone but "name_next"!!!!!!!
 */

/* There is no un-quote-copy-string.  Write it yourself */

char *un_quote_string(string)
char *string;
{
	char *ret;
	char *from_here;
	char *to_there;
	int	tmp;

	ret=string;
	to_there=string;
	from_here=string;
	while(*from_here) {
		if(*from_here!='\\') {
			if(from_here!=to_there)
				*to_there++= *from_here++;
			else
				from_here++,to_there++;
			continue;
		}
#ifdef atarist
		*to_there++ = '/';
		from_here++;
#else
		switch(*++from_here) {
		case '\\':
			*to_there++= *from_here++;
			break;
		case 'n':
			*to_there++= '\n';
			from_here++;
			break;
		case 't':
			*to_there++= '\t';
			from_here++;
			break;
		case 'f':
			*to_there++= '\f';
			from_here++;
			break;
		case 'b':
			*to_there++= '\b';
			from_here++;
			break;
		case 'r':
			*to_there++= '\r';
			from_here++;
			break;
		case '?':
			*to_there++= 0177;
			from_here++;
			break;
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
			tmp= *from_here - '0';
			from_here++;
			if(*from_here<'0' || *from_here>'7') {
				*to_there++= tmp;
				break;
			}
			tmp= tmp*8 + *from_here-'0';
			from_here++;
			if(*from_here<'0' || *from_here>'7') {
				*to_there++= tmp;
				break;
			}
			tmp=tmp*8 + *from_here-'0';
			from_here++;
			*to_there=tmp;
			break;
		default:
			ret=0;
			*to_there++='\\';
			*to_there++= *from_here++;
			break;
		}
#endif
	}
	*to_there++='\0';
	return ret;
}
#endif

#ifdef WANT_CK_PIPE
void ck_pipe(pipes)
int *pipes;
{
	if(pipe(pipes)<0) {
		msg_perror("can't open a pipe");
		exit(EX_SYSTEM);
	}
}

char *
getwd(path)
char *path;
{
	FILE *fp;
	FILE *popen();

	fp=popen("pwd","r");
	if(!fp)
		return 0;
	if(!fgets(path,100,fp))
		return 0;
	if(!pclose(fp))
		return 0;
	return path;
}
#endif /* WANT_CK_PIPE */


#ifdef WANT_GETOPT
/* Getopt for GNU.
   Copyright (C) 1987 Free Software Foundation, Inc.

		       NO WARRANTY

  BECAUSE THIS PROGRAM IS LICENSED FREE OF CHARGE, WE PROVIDE ABSOLUTELY
NO WARRANTY, TO THE EXTENT PERMITTED BY APPLICABLE STATE LAW.  EXCEPT
WHEN OTHERWISE STATED IN WRITING, FREE SOFTWARE FOUNDATION, INC,
RICHARD M. STALLMAN AND/OR OTHER PARTIES PROVIDE THIS PROGRAM "AS IS"
WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY
AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE
DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

 IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW WILL RICHARD M.
STALLMAN, THE FREE SOFTWARE FOUNDATION, INC., AND/OR ANY OTHER PARTY
WHO MAY MODIFY AND REDISTRIBUTE THIS PROGRAM AS PERMITTED BELOW, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY LOST PROFITS, LOST MONIES, OR
OTHER SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR
DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY THIRD PARTIES OR
A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS) THIS
PROGRAM, EVEN IF YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES, OR FOR ANY CLAIM BY ANY OTHER PARTY.

		GENERAL PUBLIC LICENSE TO COPY

  1. You may copy and distribute verbatim copies of this source file
as you receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy a valid copyright notice "Copyright
 (C) 1987 Free Software Foundation, Inc."; and include following the
copyright notice a verbatim copy of the above disclaimer of warranty
and of this License.  You may charge a distribution fee for the
physical act of transferring a copy.

  2. You may modify your copy or copies of this source file or
any portion of it, and copy and distribute such modifications under
the terms of Paragraph 1 above, provided that you also do the following:

    a) cause the modified files to carry prominent notices stating
    that you changed the files and the date of any change; and

    b) cause the whole of any work that you distribute or publish,
    that in whole or in part contains or is a derivative of this
    program or any part thereof, to be licensed at no charge to all
    third parties on terms identical to those contained in this
    License Agreement (except that you may choose to grant more
    extensive warranty protection to third parties, at your option).

    c) You may charge a distribution fee for the physical act of
    transferring a copy, and you may at your option offer warranty
    protection in exchange for a fee.

  3. You may copy and distribute this program or any portion of it in
compiled, executable or object code form under the terms of Paragraphs
1 and 2 above provided that you do the following:

    a) cause each such copy to be accompanied by the
    corresponding machine-readable source code, which must
    be distributed under the terms of Paragraphs 1 and 2 above; or,

    b) cause each such copy to be accompanied by a
    written offer, with no time limit, to give any third party
    free (except for a nominal shipping charge) a machine readable
    copy of the corresponding source code, to be distributed
    under the terms of Paragraphs 1 and 2 above; or,

    c) in the case of a recipient of this program in compiled, executable
    or object code form (without the corresponding source code) you
    shall cause copies you distribute to be accompanied by a copy
    of the written offer of source code which you received along
    with the copy you received.

  4. You may not copy, sublicense, distribute or transfer this program
except as expressly provided under this License Agreement.  Any attempt
otherwise to copy, sublicense, distribute or transfer this program is void and
your rights to use the program under this License agreement shall be
automatically terminated.  However, parties who have received computer
software programs from you with this License Agreement will not have
their licenses terminated so long as such parties remain in full compliance.

  5. If you wish to incorporate parts of this program into other free
programs whose distribution conditions are different, write to the Free
Software Foundation at 675 Mass Ave, Cambridge, MA 02139.  We have not yet
worked out a simple rule that can be stated here, but we will often permit
this.  We will be guided by the two goals of preserving the free status of
all derivatives of our free software and of promoting the sharing and reuse of
software.


In other words, you are welcome to use, share and improve this program.
You are forbidden to forbid anyone else to use, share and improve
what you give them.   Help stamp out software-hoarding!  */

/* This version of `getopt' appears to the caller like standard Unix `getopt'
   but it behaves differently for the user, since it allows the user
   to intersperse the options with the other arguments.

   As `getopt' works, it permutes the elements of `argv' so that,
   when it is done, all the options precede everything else.  Thus
   all application programs are extended to handle flexible argument order.

   Setting the environment variable _POSIX_OPTION_ORDER disables permutation.
   Then the behavior is completely standard.

   GNU application programs can use a third alternative mode in which
   they can distinguish the relative order of options and other arguments.  */

#include <stdio.h>

/* For communication from `getopt' to the caller.
   When `getopt' finds an option that takes an argument,
   the argument value is returned here.
   Also, when `ordering' is RETURN_IN_ORDER,
   each non-option ARGV-element is returned here.  */

char *optarg = 0;

/* Index in ARGV of the next element to be scanned.
   This is used for communication to and from the caller
   and for communication between successive calls to `getopt'.

   On entry to `getopt', zero means this is the first call; initialize.

   When `getopt' returns EOF, this is the index of the first of the
   non-option elements that the caller should itself scan.

   Otherwise, `optind' communicates from one call to the next
   how much of ARGV has been scanned so far.  */

int optind = 0;

/* The next char to be scanned in the option-element
   in which the last option character we returned was found.
   This allows us to pick up the scan where we left off.

   If this is zero, or a null string, it means resume the scan
   by advancing to the next ARGV-element.  */

static char *nextchar;

/* Callers store zero here to inhibit the error message
   for unrecognized options.  */

int opterr = 1;

/* Describe how to deal with options that follow non-option ARGV-elements.

   UNSPECIFIED means the caller did not specify anything;
   the default is then REQUIRE_ORDER if the environment variable
   _OPTIONS_FIRST is defined, PERMUTE otherwise.

   REQUIRE_ORDER means don't recognize them as options.
   Stop option processing when the first non-option is seen.
   This is what Unix does.

   PERMUTE is the default.  We permute the contents of `argv' as we scan,
   so that eventually all the options are at the end.  This allows options
   to be given in any order, even with programs that were not written to
   expect this.

   RETURN_IN_ORDER is an option available to programs that were written
   to expect options and other ARGV-elements in any order and that care about
   the ordering of the two.  We describe each non-option ARGV-element
   as if it were the argument of an option with character code zero.
   Using `-' as the first character of the list of option characters
   requests this mode of operation.

   The special argument `--' forces an end of option-scanning regardless
   of the value of `ordering'.  In the case of RETURN_IN_ORDER, only
   `--' can cause `getopt' to return EOF with `optind' != ARGC.  */

static enum { REQUIRE_ORDER, PERMUTE, RETURN_IN_ORDER } ordering;

/* Handle permutation of arguments.  */

/* Describe the part of ARGV that contains non-options that have
   been skipped.  `first_nonopt' is the index in ARGV of the first of them;
   `last_nonopt' is the index after the last of them.  */

static int first_nonopt;
static int last_nonopt;

/* Exchange two adjacent subsequences of ARGV.
   One subsequence is elements [first_nonopt,last_nonopt)
    which contains all the non-options that have been skipped so far.
   The other is elements [last_nonopt,optind), which contains all
    the options processed since those non-options were skipped.

   `first_nonopt' and `last_nonopt' are relocated so that they describe
    the new indices of the non-options in ARGV after they are moved.  */

static void
exchange (argv)
     char **argv;
{
  int nonopts_size
    = (last_nonopt - first_nonopt) * sizeof (char *);
  char **temp = (char **) alloca (nonopts_size);

  /* Interchange the two blocks of data in argv.  */

  bcopy (&argv[first_nonopt], temp, nonopts_size);
  bcopy (&argv[last_nonopt], &argv[first_nonopt],
	 (optind - last_nonopt) * sizeof (char *));
  bcopy (temp, &argv[first_nonopt + optind - last_nonopt],
	 nonopts_size);

  /* Update records for the slots the non-options now occupy.  */

  first_nonopt += (optind - last_nonopt);
  last_nonopt = optind;
}

/* Scan elements of ARGV (whose length is ARGC) for option characters
   given in OPTSTRING.

   If an element of ARGV starts with '-', and is not exactly "-" or "--",
   then it is an option element.  The characters of this element
   (aside from the initial '-') are option characters.  If `getopt'
   is called repeatedly, it returns successively each of theoption characters
   from each of the option elements.

   If `getopt' finds another option character, it returns that character,
   updating `optind' and `nextchar' so that the next call to `getopt' can
   resume the scan with the following option character or ARGV-element.

   If there are no more option characters, `getopt' returns `EOF'.
   Then `optind' is the index in ARGV of the first ARGV-element
   that is not an option.  (The ARGV-elements have been permuted
   so that those that are not options now come last.)

   OPTSTRING is a string containing the legitimate option characters.
   A colon in OPTSTRING means that the previous character is an option
   that wants an argument.  The argument is taken from the rest of the
   current ARGV-element, or from the following ARGV-element,
   and returned in `optarg'.

   If an option character is seen that is not listed in OPTSTRING,
   return '?' after printing an error message.  If you set `opterr' to
   zero, the error message is suppressed but we still return '?'.

   If a char in OPTSTRING is followed by a colon, that means it wants an arg,
   so the following text in the same ARGV-element, or the text of the following
   ARGV-element, is returned in `optarg.  Two colons mean an option that
   wants an optional arg; if there is text in the current ARGV-element,
   it is returned in `optarg'.

   If OPTSTRING starts with `-', it requests a different method of handling the
   non-option ARGV-elements.  See the comments about RETURN_IN_ORDER, above.  */

int
getopt (argc, argv, optstring)
     int argc;
     char **argv;
     char *optstring;
{
  /* Initialize the internal data when the first call is made.
     Start processing options with ARGV-element 1 (since ARGV-element 0
     is the program name); the sequence of previously skipped
     non-option ARGV-elements is empty.  */

  if (optind == 0)
    {
      first_nonopt = last_nonopt = optind = 1;

      nextchar = 0;

      /* Determine how to handle the ordering of options and nonoptions.  */

      if (optstring[0] == '-')
	ordering = RETURN_IN_ORDER;
      else if (getenv ("_POSIX_OPTION_ORDER") != 0)
	ordering = REQUIRE_ORDER;
      else
	ordering = PERMUTE;
    }

  if (nextchar == 0 || *nextchar == 0)
    {
      if (ordering == PERMUTE)
	{
	  /* If we have just processed some options following some non-options,
	     exchange them so that the options come first.  */

	  if (first_nonopt != last_nonopt && last_nonopt != optind)
	    exchange (argv);
	  else if (last_nonopt != optind)
	    first_nonopt = optind;

	  /* Now skip any additional non-options
	     and extend the range of non-options previously skipped.  */

	  while (optind < argc
		 && (argv[optind][0] != '-'
		     || argv[optind][1] == 0))
	    optind++;
	  last_nonopt = optind;
	}

      /* Special ARGV-element `--' means premature end of options.
	 Skip it like a null option,
	 then exchange with previous non-options as if it were an option,
	 then skip everything else like a non-option.  */

      if (optind != argc && !strcmp (argv[optind], "--"))
	{
	  optind++;

	  if (first_nonopt != last_nonopt && last_nonopt != optind)
	    exchange (argv);
	  else if (first_nonopt == last_nonopt)
	    first_nonopt = optind;
	  last_nonopt = argc;

	  optind = argc;
	}

      /* If we have done all the ARGV-elements, stop the scan
	 and back over any non-options that we skipped and permuted.  */

      if (optind == argc)
	{
	  /* Set the next-arg-index to point at the non-options
	     that we previously skipped, so the caller will digest them.  */
	  if (first_nonopt != last_nonopt)
	    optind = first_nonopt;
	  return EOF;
	}
	 
      /* If we have come to a non-option and did not permute it,
	 either stop the scan or describe it to the caller and pass it by.  */

      if (argv[optind][0] != '-' || argv[optind][1] == 0)
	{
	  if (ordering == REQUIRE_ORDER)
	    return EOF;
	  optarg = argv[optind++];
	  return 0;
	}

      /* We have found another option-ARGV-element.
	 Start decoding its characters.  */

      nextchar = argv[optind] + 1;
    }

  /* Look at and handle the next option-character.  */

  {
    char c = *nextchar++;
    char *temp = (char *) index (optstring, c);

    /* Increment `optind' when we start to process its last character.  */
    if (*nextchar == 0)
      optind++;

    if (temp == 0)
      {
	if (opterr != 0)
	  {
	    if (c < 040 || c >= 0177)
	      fprintf (stderr, "%s: unrecognized option, character code 0%o\n",
		       argv[0], c);
	    else
	      fprintf (stderr, "%s: unrecognized option `-%c'\n",
		       argv[0], c);
	  }
	return '?';
      }
    if (temp[1] == ':')
      {
	if (temp[2] == ':')
	  {
	    /* This is an option that accepts an argument optionally.  */
	    if (*nextchar != 0)
	      {
	        optarg = nextchar;
		optind++;
	      }
	    else
	      optarg = 0;
	    nextchar = 0;
	  }
	else
	  {
	    /* This is an option that requires an argument.  */
	    if (*nextchar != 0)
	      {
		optarg = nextchar;
		/* If we end this ARGV-element by taking the rest as an arg,
		   we must advance to the next element now.  */
		optind++;
	      }
	    else if (optind == argc)
	      {
		if (opterr != 0)
		  fprintf (stderr, "%s: no argument for `-%c' option\n",
			   argv[0], c);
		optarg = 0;
	      }
	    else
	      /* We already incremented `optind' once;
		 increment it again when taking next ARGV-elt as argument.  */
	      optarg = argv[optind++];
	    nextchar = 0;
	  }
      }
    return c;
  }
}

#ifdef TEST

/* Compile with -DTEST to make an executable for use in testing
   the above definition of `getopt'.  */

int
main (argc, argv)
     int argc;
     char **argv;
{
  char c;
  int digit_optind = 0;

  while (1)
    {
      int this_option_optind = optind;
      if ((c = getopt (argc, argv, "abc:d:0123456789")) == EOF)
	break;

      switch (c)
	{
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	  if (digit_optind != 0 && digit_optind != this_option_optind)
	    printf ("digits occur in two different argv-elements.\n");
	  digit_optind = this_option_optind;
	  printf ("option %c\n", c);
	  break;

	case 'a':
	  printf ("option a\n");
	  break;

	case 'b':
	  printf ("option b\n");
	  break;

	case 'c':
	  printf ("option c with value `%s'\n", optarg);
	  break;

	case '?':
	  break;

	default:
	  printf ("?? getopt returned character code 0%o ??\n", c);
	}
    }

  if (optind < argc)
    {
      printf ("non-option ARGV-elements: ");
      while (optind < argc)
	printf ("%s ", argv[optind++]);
      printf ("\n");
    }

  return 0;
}

#endif /* TEST */

#endif /* WANT_GETOPT */

#ifdef WANT_STRSTR

/*
 * strstr - find first occurrence of wanted in s
 */

char *				/* found string, or NULL if none */
strstr(s, wanted)
char *s;
char *wanted;
{
	register char *scan;
	register size_t len;
	register char firstc;
	extern int strcmp();

	/*
	 * The odd placement of the two tests is so "" is findable.
	 * Also, we inline the first char for speed.
	 * The ++ on scan has been moved down for optimization.
	 */
	firstc = *wanted;
	len = strlen(wanted);
	for (scan = s; *scan != firstc || strncmp(scan, wanted, len) != 0; )
		if (*scan++ == '\0')
			return (char *)0;
	return scan;
}
#endif

#ifdef STDC_MSG
#include <stdarg.h>


void
msg(char *str,...)
{
	va_list args;

	va_start(args,str);
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	vfprintf(stderr,str,args);
	va_end(args);
	putc('\n',stderr);
}

void
msg_perror(char *str,...)
{
	va_list args;
	int save_e;
	extern int errno;

	save_e=errno;
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	va_start(args,str);
	vfprintf(stderr,str,args);
	va_end(args);
	fprintf(stderr,": ");
	errno=save_e;
	perror((char *)0);
}
#endif

#ifdef VARARGS_MSG
#include <varargs.h>
void msg(str,va_alist)
char *str;
va_dcl
{
	va_list args;

	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	va_start(args);
	vfprintf(stderr,str,args);
	va_end(args);
	putc('\n',stderr);
}

void msg_perror(str,va_alist)
char *str;
va_dcl
{
	va_list args;
	int save_e;
	extern int errno;

	save_e=errno;
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	va_start(args);
	vfprintf(stderr,str,args);
	va_end(args);
	fprintf(stderr,": ");
	errno=save_e;
	perror(0);
}
#endif

#ifdef DOPRNT_MSG
void msg(str,args)
char *str;
{
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	_doprnt(str, &args, stderr);
	putc('\n',stderr);
}

void msg_perror(str,args)
char *str;
{
	int save_e;
	extern int errno;

	save_e=errno;
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	_doprnt(str, &args, stderr);
	fprintf(stderr,": ");
	errno=save_e;
	perror(0);
}

#endif
#ifdef LOSING_MSG
void msg(str,a1,a2,a3,a4,a5,a6)
char *str;
{
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	fprintf(stderr,str,a1,a2,a3,a4,a5,a6);
	putc('\n',stderr);
}

void msg_perror(str,a1,a2,a3,a4,a5,a6)
char *str;
{
	int save_e;
	extern int errno;

	save_e=errno;
	fprintf(stderr,"%s: ",tar);
	if(f_sayblock)
		fprintf(stderr,"rec %d: ",baserec + (ar_record - ar_block));
	fprintf(stderr,str,a1,a2,a3,a4,a5,a6);
	fprintf(stderr,": ");
	errno=save_e;
	perror(0);
}

#endif
