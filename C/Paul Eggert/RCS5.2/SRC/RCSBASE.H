
/*
 *                     RCS common definitions and data structures
 */
#define RCSBASE "$Id: rcsbase.h,v 5.7 1991/01/30 14:21:32 apratt Exp $"

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



/*****************************************************************************
 * INSTRUCTIONS:
 * =============
 * See the Makefile for how to define C preprocessor symbols.
 * If you need to change the comment leaders, update the table comtable[]
 * in rcsfnms.c. (This can wait until you know what a comment leader is.)
 *****************************************************************************
 */


/* $Log: rcsbase.h,v $
 * Revision 5.7  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.6  91/01/11  12:46:18  apratt
 * First version that compiles.
 * 
 * Revision 5.5  90/12/04  05:18:43  eggert
 * checked in with -k by apratt at 91.01.10.13.15.06.
 * 
 * Revision 5.5  1990/12/04  05:18:43  eggert
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.4  1990/11/01  05:03:35  eggert
 * Don't assume that builtins are functions; they may be macros.
 * Permit arbitrary data in logs.
 *
 * Revision 5.3  1990/09/26  23:36:58  eggert
 * Port wait() to non-Posix ANSI C hosts.
 *
 * Revision 5.2  1990/09/04  08:02:20  eggert
 * Don't redefine NAME_MAX, PATH_MAX.
 * Improve incomplete line handling.  Standardize yes-or-no procedure.
 *
 * Revision 5.1  1990/08/29  07:13:53  eggert
 * Add -kkvl.  Fix type typos exposed by porting.  Clean old log messages too.
 *
 * Revision 5.0  1990/08/22  08:12:44  eggert
 * Adjust ANSI C / Posix support.  Add -k, -V, setuid.  Don't call access().
 * Remove compile-time limits; use malloc instead.
 * Ansify and Posixate.  Add support for ISO 8859.
 * Remove snoop and v2 support.
 *
 * Revision 4.9  89/05/01  15:17:14  narten
 * botched previous USG fix 
 * 
 * Revision 4.8  89/05/01  14:53:05  narten
 * changed #include <strings.h> -> string.h for USG systems.
 * 
 * Revision 4.7  88/11/08  15:58:45  narten
 * removed defs for functions loaded from libraries
 * 
 * Revision 4.6  88/08/09  19:12:36  eggert
 * Shrink stdio code size; remove lint; permit -Dhshsize=nn.
 * 
 * Revision 4.5  87/12/18  17:06:41  narten
 * made removed BSD ifdef, now uses V4_2BSD
 * 
 * Revision 4.4  87/10/18  10:29:49  narten
 * Updating version numbers
 * Changes relative to 1.1 are actually relative to 4.2
 * 
 * Revision 1.3  87/09/24  14:02:25  narten
 * changes for lint
 * 
 * Revision 1.2  87/03/27  14:22:02  jenkins
 * Port to suns
 * 
 * Revision 4.2  83/12/20  16:04:20  wft
 * merged 3.6.1.1 and 4.1 (SMALLOG, logsize).
 * moved setting of STRICT_LOCKING to Makefile.
 * changed DOLLAR to UNKN (conflict with KDELIM).
 * 
 * Revision 4.1  83/05/04  09:12:41  wft
 * Added markers Id and RCSfile.
 * Added Dbranch for default branches.
 * 
 * Revision 3.6.1.1  83/12/02  21:56:22  wft
 * Increased logsize, added macro SMALLOG.
 * 
 * Revision 3.6  83/01/15  16:43:28  wft
 * 4.2 prerelease
 * 
 * Revision 3.6  83/01/15  16:43:28  wft
 * Replaced dbm.h with BYTESIZ, fixed definition of rindex().
 * Added variants of NCPFN and NCPPN for bsd 4.2, selected by defining V4_2BSD.
 * Added macro DELNUMFORM to have uniform format for printing delta text nodes.
 * Added macro DELETE to mark deleted deltas.
 *
 * Revision 3.5  82/12/10  12:16:56  wft
 * Added two forms of DATEFORM, one using %02d, the other %.2d.
 *
 * Revision 3.4  82/12/04  20:01:25  wft
 * added LOCKER, Locker, and USG (redefinition of rindex).
 *
 * Revision 3.3  82/12/03  12:22:04  wft
 * Added dbm.h, stdio.h, RCSBASE, RCSSEP, RCSSUF, WORKMODE, TMPFILE3,
 * PRINTDATE, PRINTTIME, map, and ctab; removed Suffix. Redefined keyvallength
 * using NCPPN. Changed putc() to abort on write error.
 *
 * Revision 3.2  82/10/18  15:03:52  wft
 * added macro STRICT_LOCKING, removed RCSUMASK.
 * renamed JOINFILE[1,2] to JOINFIL[1,2].
 *
 * Revision 3.1  82/10/11  19:41:17  wft
 * removed NBPW, NBPC, NCPW.
 * added typdef int void to aid compiling
 */

/* GCC */
#if __GNUC__ && !__STRICT_ANSI__
#	define exiting volatile
#else
#	define exiting
#endif


/* standard include files */

#include "conf.h"

#if !MAKEDEPEND

#include <errno.h>
#include <signal.h>
#include <time.h>


/* AKP: set ANSI_INCLUDE_FILES to 1 in conf.h if you have them. */

#if !ANSI_INCLUDE_FILES

/* ANSI C library */
/* These declarations are for the benefit of non-ANSI C hosts.  */

	/* <errno.h> */
#	ifndef errno
		extern int errno;
#	endif

	/* <limits.h> */
#	ifndef CHAR_BIT
#		define CHAR_BIT 8
#	endif
#	ifndef ULONG_MAX
#		define ULONG_MAX (-(unsigned long)1)
#	endif

	/* <signal.h> */
#	ifndef signal
		signal_type (*signal P((int,signal_type(*)P((int)))))P((int));
#	endif

	/* <stdio.h> */
	/* conf.h declares the troublesome printf family.  */
#	ifndef L_tmpnam
#		define L_tmpnam 25 /* sizeof("/usr/tmp/xxxxxxxxxxxxxxx") */
#	endif
#	ifndef SEEK_SET
#		define SEEK_SET 0
#	endif
#	ifndef fopen
		FILE *fopen P((const char*,const char*));
#	endif
#	ifndef fread
		fread_type fread P((void*,size_t,size_t,FILE*));
#	endif
#	ifndef fwrite
		fread_type fwrite P((const void*,size_t,size_t,FILE*));
#	endif
#	ifndef fclose
		int fclose P((FILE*));
#	endif
#	ifndef fflush
		int fflush P((FILE*));
#	endif
#	ifndef fputs
		int fputs P((const char*,FILE*));
#	endif
#	ifndef fseek
		int fseek P((FILE*,long,int));
#	endif
#	ifndef perror
		void perror P((const char*));
#	endif
#	ifndef clearerr
		void clearerr P((FILE*));
#	endif
#	ifndef feof
		int feof P((FILE*));
#	endif
#	ifndef ferror
		int ferror P((FILE*));
#	endif
#	if has_rename && !defined(rename)
		int rename P((const char*,const char*));
#	endif
#	if has_tmpnam && !defined(tmpnam)
		char *tmpnam P((char*));
#	endif

	/* <stdlib.h> */
#	ifndef EXIT_FAILURE
#		define EXIT_FAILURE 1
#	endif
#	ifndef EXIT_SUCCESS
#		define EXIT_SUCCESS 0
#	endif
#	ifndef getenv
		char *getenv P((const char*));
#	endif
#	ifndef exit
		exiting exit_type exit P((int));
#	endif
#	ifndef _exit
		exiting underscore_exit_type _exit P((int));
#	endif
#	ifndef free
		free_type free P((malloc_type));
#	endif
#	ifndef atoi
		int atoi P((const char*));
#	endif
#	ifndef malloc
		malloc_type malloc P((size_t));
#	endif
#	ifndef realloc
		malloc_type realloc P((malloc_type,size_t));
#	endif

	/* <string.h> */
#	ifndef strcat
		char *strcat P((char*,const char*));
#	endif
#	ifndef strcpy
		char *strcpy P((char*,const char*));
#	endif
#	ifndef strncpy
		char *strncpy P((char*,const char*,int));
#	endif
#	ifndef strrchr
		char *strrchr P((const char*,int));
#	endif
#	ifndef strcmp
		int strcmp P((const char*,const char*));
#	endif
#	ifndef strncmp
		int strncmp P((const char*,const char*,int));
#	endif
#	ifndef strlen
		strlen_type strlen P((const char*));
#	endif

	/* <time.h> */
#	ifndef time
		time_t time P((time_t*));
#	endif

/* end if !ANSI_INCLUDE_FILES */
#endif

/* Posix 1003.1-1988 */
/* These declarations are for the benefit of non-Posix hosts.  */

	/* <limits.h> */
#	if !defined(NAME_MAX) && !defined(_POSIX_NAME_MAX)
#		if has_sys_dir_h
#			include <sys/dir.h>
#		endif
#		ifndef NAME_MAX
#			ifndef MAXNAMLEN
#				define MAXNAMLEN 14
#			endif
#			define NAME_MAX MAXNAMLEN
#		endif
#	endif
#	if !defined(PATH_MAX) && !defined(_POSIX_PATH_MAX)
#		if has_sys_param_h
#			include <sys/param.h>
#		endif
#		ifndef PATH_MAX
#			ifndef MAXPATHLEN
#				define MAXPATHLEN 256
#			endif
#			define PATH_MAX (MAXPATHLEN-1)
#		endif
#	endif

#if !ANSI_INCLUDE_FILES
/* these are really "posix_include_files" but who's counting? */
	/* <sys/wait.h> */
#	if has_sys_wait_h
#		include <sys/wait.h>
#	endif
#	ifndef WEXITSTATUS
#		define WEXITSTATUS(stat_val) ((unsigned)(stat_val) >> 8)
#		undef WIFEXITED /* Avoid 4.3BSD incompatibility with Posix.  */
#	endif
#	ifndef WIFEXITED
#		define WIFEXITED(stat_val) (!((stat_val) & 255))
#	endif

	/* <fcntl.h> */
	/* conf.h declares fcntl() and open().  */
#	ifdef F_DUPD
#		undef dup2
#		define dup2(a,b) fcntl(a,F_DUPFD,b)
#	else
#		ifndef dup2
			int dup2 P((int,int));
#		endif
#	endif
#	ifdef O_CREAT
#		define open_can_creat 1
#		undef creat
#		define creat(path,mode) open(path,O_CREAT|O_TRUNC|O_WRONLY,mode)
#	else
#		define open_can_creat 0
#		define O_RDONLY 0
#		define O_WRONLY 1
#		define O_CREAT 01000
#		define O_TRUNC 02000
#		ifndef creat
			int creat P((const char*,mode_t));
#		endif
#	endif

	/* <stdio.h> */
#	ifndef fdopen
		FILE *fdopen P((int,const char*));
#	endif
/* end if !ANSI_INCLUDE_FILES */
#endif
	/* <sys/stat.h> */
	/* conf.h declares chmod() and umask().  */
#	ifndef S_IRUSR
#		define S_IRUSR 0400
#		define S_IWUSR 0200
#		define S_IRGRP 0040
#		define S_IWGRP 0020
#		define S_IROTH 0004
#		define S_IWOTH 0002
#	endif
#	ifndef S_ISREG
#		define S_ISREG(n) (((n) & S_IFMT) == S_IFREG)
#	endif
#if !ANSI_INCLUDE_FILES
#	ifndef fstat
		int fstat P((int,struct stat*));
#	endif
#	ifndef stat
		int stat P((const char*,struct stat*));
#	endif
/* end if !ANSI_INCLUDE_FILES */
#endif

	/* <unistd.h> */
#	ifndef STDIN_FILENO
#		define STDIN_FILENO 0
#		define STDOUT_FILENO 1
#		define STDERR_FILENO 2
#	endif
#if !ANSI_INCLUDE_FILES
#	ifndef getlogin
		char *getlogin P((void));
#	endif
#	ifndef _exit
		exiting void _exit P((int));
#	endif
#	ifndef close
		int close P((int));
#	endif
#	ifndef execv
		int execv P((const char*,const char*const*));
#	endif
#	ifndef execvp
		int execvp P((const char*,const char*const*));
#	endif
#	ifndef isatty
		int isatty P((int));
#	endif
#	ifndef read
		int read P((int,char*,unsigned));
#	endif
#	ifndef write
		int write P((int,const char*,unsigned));
#	endif
#	ifndef unlink
		int unlink P((const char*));
#	endif
#	if has_getcwd && !defined(getcwd)
		char *getcwd P((char*,size_t));
#	endif

/* end if !ANSI_INCLUDE_FILES */
#endif

#	if has_getuid
#		ifndef getgid
			gid_t getgid P((void));
#		endif
#		ifndef getuid
			uid_t getuid P((void));
#		endif
#	endif
#	if has_seteuid
#		ifndef setegid
			int setegid P((gid_t));
#		endif
#		ifndef seteuid
			int seteuid P((uid_t));
#		endif
#		ifndef getegid
			gid_t getegid P((void));
#		endif
#		ifndef geteuid
			uid_t geteuid P((void));
#		endif
#	endif

#if !DONT_USE_FORK
#	if has_vfork
#		ifndef vfork
			pid_t vfork P((void));
#		endif
#	else
#		define vfork fork
#		ifndef fork
			pid_t fork P((void));
#		endif
#	endif
#endif


/* traditional Unix library */
#define EXIT_TROUBLE 2 /* code returned by diff(1) if trouble is found */
#if !has_getcwd && !defined(getwd)
	char *getwd P((char*));
#endif
#if !has_tmpnam && !defined(mktemp)
	char *mktemp P((char*));
#endif
#if !has_sigaction & has_sigblock
#	ifndef sigblock
		int sigblock P((int));
#	endif
#	ifndef sigsetmask
		int sigsetmask P((int));
#	endif
#endif
#ifndef _filbuf
	int _filbuf P((FILE*));
#endif
#ifndef _flsbuf
	int _flsbuf P((int,FILE*));
#endif


#endif /* !MAKEDEPEND */


/*
 * Parameters
 */

/* backwards compatibility with old versions of RCS */
#define VERSION_MIN 3		/* old output RCS format supported */
#define VERSION_MAX 5		/* newest output RCS format supported */
#ifndef VERSION_DEFAULT		/* default RCS output format */
#	define VERSION_DEFAULT VERSION_MAX
#endif
#define VERSION(n) ((n) - VERSION_DEFAULT) /* internally, 0 is the default */

#ifndef STRICT_LOCKING
#define STRICT_LOCKING 0
#endif
			      /* 0 sets the default locking to non-strict;  */
                              /* used in experimental environments.         */
                              /* 1 sets the default locking to strict;      */
                              /* used in production environments.           */

#define yearlength	   16 /* (good through AD 9,999,999,999,999,999)    */
#define datesize (yearlength+16) /* size of output of DATEFORM		    */
#define joinlength         20 /* number of joined revisions permitted       */
#define RCSSUF            'v' /* suffix for RCS files                       */
#define KDELIM            '$' /* delimiter for keywords                     */
#define VDELIM            ':' /* separates keywords from values             */
#define DEFAULTSTATE    "Exp" /* default state of revisions                 */



#define true     1
#define false    0
#define nil      0




/* This version of putc prints a char, but aborts on write error            */
#if lint
#	define aputc(c,o) afputc(c,o)
#	define GETC(i,o,c) afputc(c=getc(i), o)
#else
#	define aputc(c,o) do { if (putc(c,o)==EOF) IOerror(); } while(0)
#	define GETC(i,o,c) do {c=getc(i); if (o) aputc(c,o); } while(0)
#endif
/* GETC writes a DEL-character (all ones) on end of file.		    */

#if AKP_MODES
#define WORKMODE(RCSmode, writable) ((RCSmode)&~(S_IWRITE) | ((writable)?S_IWRITE:0))
#else
#define WORKMODE(RCSmode, writable) ((RCSmode)&~(S_IWUSR|S_IWGRP|S_IWOTH) | ((writable)?S_IWUSR:0))
#endif

/* computes mode of working file: same as RCSmode, but write permission     */
/* determined by writable */


/* character classes and token codes */
enum tokens {
/* classes */	DELIM,	DIGIT,	IDCHAR,	NEWLN,	LETTER,	Letter,
		PERIOD,	SBEGIN,	SPACE,	UNKN,
/* tokens */	COLON,	EOFILE,	ID,	NUM,	SEMI,	STRING
};

#define SDELIM  '@'     /* the actual character is needed for string handling*/
/* SDELIM must be consistent with map[], so that ctab[SDELIM]==SBEGIN.
 * there should be no overlap among SDELIM, KDELIM, and VDELIM
 */

#define isdigit(c) ((unsigned)((c)-'0') <= 9) /* faster than ctab[c]==DIGIT */





/***************************************
 * Data structures for the symbol table
 ***************************************/

/* Buffer of arbitrary data */
struct buf {
	char *string;
	size_t size;
};
struct cbuf {
	const char *string;
	size_t size;
};

/* Hash table entry */
struct hshentry {
	const char	  * num;      /* pointer to revision number (ASCIZ) */
	const char	  * date;     /* pointer to date of checkin	    */
	const char	  * author;   /* login of person checking in        */
	const char	  * lockedby; /* who locks the revision             */
	const char	  * state;    /* state of revision (Exp by default) */
	struct cbuf	    log;      /* log message requested at checkin   */
        struct branchhead * branches; /* list of first revisions on branches*/
	struct cbuf	    ig;	      /* ignored phrases of revision	    */
        struct hshentry   * next;     /* next revision on same branch       */
	struct hshentry   * nexthsh;  /* next revision with same hash value */
	unsigned long	    insertlns;/* lines inserted (computed by rlog)  */
	unsigned long	    deletelns;/* lines deleted  (computed by rlog)  */
	char		    selector; /* true if selected, false if deleted */
};

/* list of hash entries */
struct hshentries {
	struct hshentries *rest;
	struct hshentry *first;
};

/* list element for branch lists */
struct branchhead {
        struct hshentry   * hsh;
        struct branchhead * nextbranch;
};

/* accesslist element */
struct access {
	const char	  * login;
        struct access     * nextaccess;
};

/* list element for locks  */
struct lock {
	const char	  * login;
        struct hshentry   * delta;
        struct lock       * nextlock;
};

/* list element for symbolic names */
struct assoc {
	const char	  * symbol;
	const char	  * num;
        struct assoc      * nextassoc;
};


#define mainArgs (argc,argv) int argc; char **argv;

#if lint
#	define libId(name,rcsid)
#	define mainProg(name,cmd,rcsid) int name mainArgs
#else
#	define libId(name,rcsid) const char name[] = rcsid;
#	define mainProg(name,cmd,rcsid) const char copyright[] = "Copyright 1982,1988,1989 by Walter F. Tichy\nPurdue CS\nCopyright 1990 by Paul Eggert", rcsbaseId[] = RCSBASE, cmdid[] = cmd; libId(name,rcsid) int main mainArgs
#endif

/*
 * Markers for keyword expansion (used in co and ident)
 *	Every byte must have class LETTER or Letter.
 */
#define AUTHOR          "Author"
#define DATE            "Date"
#define HEADER          "Header"
#define IDH             "Id"
#define LOCKER          "Locker"
#define LOG             "Log"
#define RCSFILE         "RCSfile"
#define REVISION        "Revision"
#define SOURCE          "Source"
#define STATE           "State"
#define keylength 8 /* max length of any of the above keywords */

enum markers { Nomatch, Author, Date, Header, Id,
	       Locker, Log, RCSfile, Revision, Source, State };
	/* This must be in the same order as rcskeys.c's Keyword[] array. */

#define DELNUMFORM      "\n\n%s\n%s\n"
/* used by putdtext and scanlogtext */

/* main program */
extern const char cmdid[];
exiting void exiterr P((void));

/* maketime */
void str2date P((const char*,char[datesize]));
void time2date P((time_t,char[datesize]));

/* partime */
int partime P((const char*,struct tm*,int*));

/* rcsedit */
#define ciklogsize 23 /* sizeof("checked in with -k by ") */
extern FILE *fcopy;
extern const char *resultfile;
extern const char ciklog[ciklogsize];
extern int locker_expansion;
extern struct buf dirtfname[];
#define newRCSfilename (dirtfname[0].string)
FILE *initeditfiles P((const char*));
FILE *rcswriteopen P((const char*));
const char *makedirtemp P((const char*,int));
int expandline P((FILE*,FILE*,const struct hshentry*,int,FILE*));
void arewind P((FILE*));
void copystring P((void));
void dirtempunlink P((void));
void editstring P((const struct hshentry*));
void finishedit P((const struct hshentry*));
void inittmpeditfiles P((void));
void keepdirtemp P((const char*));
void swapeditfiles P((int));
void xpandstring P((const struct hshentry*));

/* rcsfnms */
#define bufautobegin(b) ((void) ((b)->size = 0)) /* for auto on block entry */
extern char *workfilename;
extern const char *RCSfilename;
extern int haveworkstat;
extern struct stat RCSstat;
extern struct stat workstat;
FILE *rcsreadopen P((const char*));
char *bufenlarge P((struct buf*,const char**));
char *maketemp P((int));
const char *bindex P((const char*,int));
const char *getfullRCSname P((void));
const char *tmp();
int getfworkstat P((int));
int getworkstat P((void));
int pairfilenames P((int,char**,FILE*(*)P((const char*)),int,int));
void bufalloc P((struct buf*,size_t));
void bufautoend P((struct buf*));
void bufrealloc P((struct buf*,size_t));
void bufscat P((struct buf*,const char*));
void bufscpy P((struct buf*,const char*));
void ffclose P((FILE*));
void tempunlink P((void));
#if has_rename & !bad_rename
#	define re_name(x,y) rename(x,y)
#else
	int re_name P((const char*,const char*));
#endif

#if bad_unlink
int un_link P((const char *a));
#  define unlink(a) un_link(a)
#endif

/* rcsgen */
extern int interactiveflag;
extern struct cbuf curlogmsg;
extern struct buf curlogbuf;
const char *buildrevision P((const struct hshentries*,struct hshentry*,int,int));
int getcstdin P((void));
int ttystdin P((void));
int yesorno P((int,const char*,...));
struct cbuf cleanlogmsg P((char*,size_t));
void putdesc P((int,const char*));

/* rcskeys */
extern const char *const Keyword[];
enum markers trymatch P((const char*));

/* rcslex */
extern FILE *finptr;
extern FILE *foutptr;
extern FILE *frewrite;
extern const char *NextString;
extern enum tokens nexttok;
extern int hshenter;
extern int nerror;
extern int nextc;
extern int quietflag;
extern unsigned long rcsline;
const char *getid P((void));
exiting void efaterror P((const char*));
exiting void faterror P((const char*,...));
exiting void fatserror P((const char*,...));
exiting void IOerror P((void));
exiting void unterminatedString P((void));
char *checkid P((char*,int));
int getkeyopt P((const char*));
int getlex P((enum tokens));
struct cbuf getphrases P((const char*));
struct cbuf savestring P((struct buf*));
struct hshentry *getnum P((void));
void Lexinit P((void));
void afputc P((int,FILE*));
void aprintf P((FILE*,const char*,...));
void aputs P((const char*,FILE*));
void checksid P((char*));
void diagnose P((const char*,...));
void eflush P((void));
void error P((const char*,...));
void eerror P((const char*));
void fvfprintf P((FILE*,const char*,va_list));
void getkey P((const char*));
void getkeystring P((const char*));
void nextlex P((void));
void oflush P((void));
void printstring P((void));
void readstring P((void));
void redefined P((int));
void warn P((const char*,...));
void warnignore P((void));

/* rcsmap */
#define ctab (&map[1])
extern const enum tokens map[];

/* rcsrev */
char *partialno P((struct buf*,const char*,unsigned));
int cmpnum P((const char*,const char*));
int cmpnumfld P((const char*,const char*,unsigned));
int compartial P((const char*,const char*,unsigned));
int expandsym P((const char*,struct buf*));
struct hshentry *genrevs P((const char*,const char*,const char*,const char*,struct hshentries**));
unsigned countnumflds P((const char*));
void getbranchno P((const char*,struct buf*));

/* rcssyn */
/* These expand modes must agree with Expand_names[] in rcssyn.c.  */
#define KEYVAL_EXPAND 0 /* -kkv `$Keyword: value $' */
#define KEYVALLOCK_EXPAND 1 /* -kkvl `$Keyword: value locker $' */
#define KEY_EXPAND 2 /* -kk `$Keyword$' */
#define VAL_EXPAND 3 /* -kv `value' */
#define OLD_EXPAND 4 /* -ko use old string, omitting expansion */
struct diffcmd {
	unsigned long
		line1, /* number of first line */
		nlines, /* number of lines affected */
		adprev, /* previous 'a' line1+1 or 'd' line1 */
		dafter; /* sum of previous 'd' line1 and previous 'd' nlines */
};
extern const char      * Dbranch;
extern struct access   * AccessList;
extern struct assoc    * Symbols;
extern struct cbuf Comment;
extern struct lock     * Locks;
extern struct hshentry * Head;
extern int		 Expand;
extern int               StrictLocks;
extern int               TotalDeltas;
extern const char *const expand_names[];
extern const char Kdesc[];
extern const char Klog[];
extern const char Ktext[];
int getdiffcmd P((FILE*,int,FILE*,struct diffcmd*));
int putdftext P((const char*,struct cbuf,FILE*,FILE*,int));
int putdtext P((const char*,struct cbuf,const char*,FILE*,int));
int str2expmode P((const char*));
void getadmin P((void));
void getdesc P((int));
void gettree P((void));
void ignorephrase P((void));
void initdiffcmd P((struct diffcmd*));
void putadmin P((FILE*));
void puttree P((const struct hshentry*,FILE*));

/* rcsutil */
extern int RCSversion;
char *cgetenv P((const char*));
const char *getcaller P((void));
const char *fstrsave P((const char*));
const char *strsave P((const char*));
int addlock P((struct hshentry*));
int addsymbol P((const char*,const char*,int));
int checkaccesslist P((void));
int findlock P((int,struct hshentry**));
int run P((const char*,const char*,...));
int runv P((const char**));
malloc_type fremember P((malloc_type));
malloc_type ftestalloc P((size_t));
malloc_type testalloc P((size_t));
malloc_type testrealloc P((malloc_type,size_t));
#define ftalloc(T) ftnalloc(T,1)
#define talloc(T) tnalloc(T,1)
#if lint
	extern malloc_type lintalloc;
#	define ftnalloc(T,n) (lintalloc = ftestalloc(sizeof(T)*(n)), (T*)0)
#	define tnalloc(T,n) (lintalloc = testalloc(sizeof(T)*(n)), (T*)0)
#	define tfree(p)
#else
#	define ftnalloc(T,n) ((T*) ftestalloc(sizeof(T)*(n)))
#	define tnalloc(T,n) ((T*) testalloc(sizeof(T)*(n)))
#	define tfree(p) free((malloc_type)(p))
#endif
void awrite P((const char*,fread_type,FILE*));
void catchints P((void));
void fastcopy P((FILE*,FILE*));
void ffree P((void));
void ffree1 P((const char*));
void initid P((void));
void ignoreints P((void));
void printdate P((FILE*,const char*,const char*));
void restoreints P((void));
void setRCSversion P((const char*));
#define SETID (has_getuid & has_seteuid & DIFF_PATH_HARDWIRED)
#if has_getuid
	extern uid_t ruid;
#	define myself(u) ((u) == ruid)
#else
#	define myself(u) true
#endif
#if SETID
	void seteid P((void));
	void setrid P((void));
#else
#	define seteid()
#	define setrid()
#endif
