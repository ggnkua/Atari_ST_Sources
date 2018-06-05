/*
 * Atari TOS Definitions File
 * from The Atari Compendium Companion Disk
 * Copyright (c)1994 Software Development Systems
 * All Rights Reserved
 *
 * Last	Update: 9/24/94 (SDS)
 *
 * NOTE: This file should not be included directly, rather, you should include
 * the version of TOS.H specific to your compiler which will, in turn, include
 * this file.
 */
 
#ifndef	_tosdefs_h_
#define	_tosdefs_h_

#include <PORTAB.H>

#ifndef P_
#ifdef __STDC__
#define P_(x) x
#else
#define P_(x) ()
#endif
#endif

#ifndef REGARGS
#ifdef LATTICE
#define REGARGS __regargs
#else
#define REGARGS /* */
#endif
#endif

#ifndef STDARGS
#ifdef LATTICE
#define STDARGS __stdargs
#else
#define STDARGS cdecl
#endif
#endif

#ifndef SAVEDS
#ifdef LATTICE
#define SAVEDS __saveds
#else
#define SAVEDS /* */
#endif
#endif

/****************************************** GEMDOS Error	Definitions ****/

#define	E_OK		0		/* no error */
#define	EINVFN		-32		/* invalid function */
#define	EFILNF		-33		/* file not found */
#define	EPTHNF		-34		/* path not found */
#define	ENHNDL		-35		/* no more handles */
#define	EACCDN		-36		/* access denied */
#define	EIHNDL		-37		/* invalid handle */
#define	ENSMEM		-39		/* insufficient memory */
#define	EIMBA		-40		/* invalid memory block address */
#define	EDRIVE		-46		/* invalid drive specification */
#define	EXDEV		-48		/* cross device rename */
#define	ENMFIL		-49		/* no more files (from fsnext) */
#define	ELOCKED	-58		/* record is locked already	*/
#define	ENSLOCK	-59		/* invalid lock removal request */
#define	ERANGE		-64		/* range error */
#define	EINTRN		-65		/* internal error */
#define	EPLFMT		-66		/* invalid program load format */
#define	ENOEXEC	 EPLFMT
#define	EGSBF		-67		/* memory block growth failure */

#define	ENAMETOOLONG 	ERANGE		/* a filename	component is too long */
#define	ELOOP 		-80		/* too	many symbolic	links */

#define	EMOUNT		-200

/****************************************************** MiNT Signals ****/

#define	SIGNULL	0		/* not	really	a signal */
#define	SIGHUP		1		/* hangup signal */
#define	SIGINT		2		/* sent by ^C	*/
#define	SIGQUIT	3		/* quit signal */
#define	SIGILL		4		/* illegal instruction */
#define	SIGTRAP	5		/* trace trap	*/
#define	SIGABRT	6		/* abort signal */
#define	SIGPRIV	7		/* privilege violation */
#define	SIGFPE		8		/* divide by zero */
#define	SIGKILL	9		/* cannot be ignored	*/
#define	SIGBUS		10		/* bus	error */
#define	SIGSEGV	11		/* illegal memory reference	*/
#define	SIGSYS		12		/* bad	argument to a	system	call */
#define	SIGPIPE	13		/* broken pipe */
#define	SIGALRM	14		/* alarm clock */
#define	SIGTERM	15		/* software termination signal */

#define	SIGURG		16		/* urgent condition on I/O channel	*/
#define	SIGSTOP	17		/* stop signal not from terminal */
#define	SIGTSTP	18		/* stop signal from terminal */
#define	SIGCONT	19		/* continue stopped process	*/
#define	SIGCHLD	20		/* child stopped or exited */
#define	SIGTTIN	21		/* read by background process */
#define	SIGTTOU	22		/* write by background process */
#define	SIGIO		23		/* I/O	possible on a	descriptor */
#define	SIGXCPU	24		/* CPU	time exhausted */
#define	SIGXFSZ	25		/* file size limited	exceeded */
#define	SIGVTALRM	26		/* virtual timer alarm */
#define	SIGPROF	27		/* profiling timer expired */
#define	SIGWINCH	28		/* window size changed */
#define	SIGUSR1	29		/* user signal 1 */
#define	SIGUSR2	30		/* user signal 2 */

/************************************************** Process Basepage ****/

typedef	struct	_base
{
	void *	p_lowtpa;		/* pointer to	bottom	of TPA	*/
	void *	p_hitpa;	  	/* pointer to	top of	TPA + 1 */
	void *	p_tbase;	  	/* base of text segment */
	LONG	p_tlen;	  	/* length of text segment */
	void *	p_dbase;	  	/* base of data segment */
	LONG	p_dlen;	  	/* length of data segment */
	void *	p_bbase;	  	/* base of BSS segment */
	LONG	p_blen;	  	/* length of BSS segment */
	void *	p_dta;			/* pointer to	current DTA */
	struct	_base	*p_parent;	/* pointer to	parent's basepage */
	void *	p_reserved;
	char *	p_env;	  		/* pointer to	environment strings */
	LONG	p_undef[20];
	char	p_cmdlin[128];  	/* command line image */
} BASEPAGE;

#ifdef LATTICE
extern BASEPAGE *_pbase;
#endif
#ifdef __PUREC__
extern BASEPAGE *_BasPag
#endif

/******************************************** Executable	File Header ****/

typedef	struct	tos_header
{
	WORD		PRG_magic;
	LONG		PRG_tsize;
	LONG		PRG_dsize;
	LONG		PRG_bsize;
	LONG		PRG_ssize;
	LONG		PRG_res1;
#define	PF_FASTLOAD  	0x01
#define	PF_TTRAMLOAD	0x02
#define	PF_TTRAMMEM  	0x04
#define	PF_PRIVATE   	0x00
#define	PF_GLOBAL    	0x10
#define	PF_SUPERVISOR	0x20
#define	PF_READABLE  	0x30
	LONG		prgflags;
	WORD		absflag;
} TOS_HEADER;

/****************************************** GEMDOS Standard Handles ****/
#define	GSH_CONIN		0
#define	GSH_CONOUT		1
#define	GSH_AUX		2
#define	GSH_PRN		3
#define	GSH_BIOSCON		-1
#define	GSH_BIOSAUX		-2
#define	GSH_BIOSPRN		-3
#define	GSH_BIOSMIDIIN	-4
#define	GSH_BIOSMIDIOUT	-5

/*********************************************** Function Constants ****/

/* For C...() */
#define	MINT_EOF		0xFF1A
#define	DEV_READY		-1
#define	DEV_BUSY		0

/* For Dgetpath() and	Dfree() */
#define	DEFAULT_DRIVE		0

typedef	struct
{
	ULONG	b_free;
	ULONG	b_total;
	ULONG	b_secsize;
	ULONG	b_clsize;
} DISKINFO;

/* For Dlock()	*/
#define	DRV_LOCK		1
#define	DRV_UNLOCK		0

/* For Dopendir() */
#define	MODE_NORMAL		0
#define	MODE_COMPAT		1

/* For Fattrib() and Fcreate() */
/*** Files (as	bits) ***/
#define	FA_READONLY		0x01
#define	FA_HIDDEN		0x02
#define	FA_SYSTEM		0x04
#define	FA_VOLUME		0x08
#define	FA_DIR			0x10
#define	FA_ARCHIVE		0x20

/**** Processes (as values) ***/
#define	FA_RUN			0x00
#define	FA_READY		0x01
#define	FA_TSR			0x02
#define	FA_WAITING		0x20
#define	FA_IOWAIT		0x21
#define	FA_EXITED		0x22
#define	FA_STOPPED		0x24

/**** Pipes (as bits)	***/
#define	FA_UNIDIRECTIONAL	0x01
#define	FA_NOKILL		0x02
#define	FA_TTY			0x04

/* For Fdatime() and other time needs */
typedef	struct
{
	unsigned hour:5;
	unsigned minute:6;
	unsigned second:5;
	unsigned year:7;
	unsigned month:4;
	unsigned day:5;
} GEMDOS_TIME;

/* For Fgetchar() and	Fputchar() */
#define	TTY_COOKED		0x01
#define	TTY_ECHO		0x02

/* For Fgetdta() and Fsetdta() */
typedef	struct
{
	char 	d_reserved[21];
	UCHAR	d_attrib;
	UWORD	d_time;
	UWORD	d_date;
	ULONG	d_length;
	char	d_fname[14];
} DTA;

/* For Flock()	*/
#define	FLK_LOCK		0
#define	FLK_UNLOCK		1

typedef	struct
{
	WORD	l_type;
	WORD	l_whence;
	LONG	l_start;
	LONG	l_len;
	LONG	l_pid;
} FLOCK;
	
/* For Fopen()	*/
#define	S_READ			0x00
#define	S_WRITE		0x01
#define	S_READWRITE		0x02
#define	S_COMPAT		0x00
#define	S_DENYREADWRITE	0x10
#define	S_DENYWRITE		0x20
#define	S_DENYREAD		0x30
#define	S_DENYNONE		0x40
#define	S_NOINHERIT		0x80

/* For Fseek()	*/
#ifndef	SEEK_SET
#define	SEEK_SET		0
#define	SEEK_CUR		1
#define	SEEK_END		2
#endif

/* For Mxalloc() */
#define	MX_STRAM		0x0000
#define	MX_TTRAM		0x0001
#define	MX_PREFSTRAM		0x0002
#define	MX_PREFTTRAM		0x0003
#define	MX_HEADER		0x0008
#define	MX_PRIVATE		0x0018
#define	MX_GLOBAL		0x0028
#define	MX_SUPERVISOR		0x0038
#define	MX_READABLE		0x0048

/* For Pdomain() */
#define	DOMAIN_TOS		0
#define	DOMAIN_MINT		1

/* For Pexec()	*/
#define	PE_LOADGO		0
#define	PE_LOAD		3
#define	PE_GO			4
#define	PE_BASEPAGE		5
#define	PE_GOTHENFREE		6
#define	PE_CLOADGO		100
#define	PE_CGO			104
#define	PE_NOSHARE		106
#define	PE_REPLACE		200

/* For Pmsg() */
typedef	struct
{
	LONG	userLONG1;
	LONG 	userLONG2;
	WORD	pid;
} MSG;

#define	MSG_READ		0
#define	MSG_WRITE		1
#define	MSG_READWRITE		2
#define	MSG_NOWAIT		0x8000

/* For Prusage() */
#define	PRU_KERNELTIME	0
#define	PRU_PROCESSTIME	1
#define	PRU_CHILDKERNELTIME	2
#define	PRU_CHILDPROCESSTIME	3
#define	PRU_MEMORY		4

/* For Psemaphore() */
#define	SEM_CREATE		0
#define	SEM_DESTROY		1
#define	SEM_LOCK		2
#define	SEM_UNLOCK		3

/* For Psetlimit() */
#define	LIM_MAXTIME		1
#define	LIM_MAXMEM		2
#define	LIM_MAXMALLOC		3

/* For Psigaction() and Psignal() */

#define	SIG_DFL		((void	(*STDARGS)P_(( LONG )))0L)
#define	SIG_IGN		((void	(*STDARGS)P_(( LONG )))1L)

#define	SA_NOCLDSTOP		1

typedef	struct
{
	void  	(*sa_handler)P_(( ULONG ));
	WORD	sa_mask;
	WORD	sa_flags;
} SIGACTION;

/* For Pterm()	*/
#define	TERM_OK		0
#define	TERM_ERROR		1
#define	TERM_BADPARAMS	2
#define	TERM_CRASH		-1
#define	TERM_CTRLC		-32

/* For Pwait3() */
#define	PW_NOBLOCK		0x01
#define	PW_STOPPED		0x02

/* For Pwaitpid() */
#define	PWP_ALLCHILDREN	-1
#define	PWP_SAMEGROUP		0

/* For Super()	*/
#define	SUP_SET		((char	*)0)
#define	SUP_INQUIRE		((char	*)1)

#define	SUP_USER		((char	*)0L) 	/* Return values */
#define	SUP_SUPER		((char	*)1L)

/* For Sysconf() */
#define	SYS_MAXINQ		-1
#define	SYS_MAXREGIONS	0
#define	SYS_MAXCOMMAND	1
#define	SYS_MAXFILES		2
#define	SYS_MAXIDS		3
#define	SYS_MAXPROCS		4

#ifndef	UNLIMITED
#define	UNLIMITED		0x7FFFFFFF
#endif

typedef	struct	context
{
	LONG	regs[15];
	LONG	usp;
	WORD	sr;
	LONG	pc;
	LONG	ssp;
	LONG	tvec;
	char	fstate[216];
	LONG	fregs[3*8];
	LONG	fctrl[3];
} CONTEXT;

/********************************** MiNT File Systems/Device Drivers */

#define NAME_MAX	32
#define PATH_MAX	128

struct filesys;			/* Forward Declarations */
struct devdrv;

typedef struct f_cookie
{
	struct filesys *fs;
	UWORD	dev;
	UWORD	aux;
	LONG	index;
} fcookie;

typedef struct dirstruct
{
	fcookie	fc;
	UWORD		index;
	UWORD		flags;
#define TOS_SEARCH	0x01
	char		fsstuff[60];
} DIR;

typedef struct xattr
{
	UWORD		mode;
	LONG		index;
	UWORD		dev;
	UWORD		reserved1;
	UWORD		nlink;
	UWORD		uid;
	UWORD		gid;
	LONG		size;
	LONG		blksize, nblocks;
	WORD		mtime, mdate;
	WORD		atime, adate;
	WORD		ctime, cdate;
	WORD		attr;
	WORD		reserved2;
	LONG		reserved3[2];
} XATTR;

#define S_IFMT		0170000
#define S_IFCHR	0020000
#define	S_IFDIR	0040000
#define S_IFREG	0100000
#define S_IFIFO	0120000
#define S_IMEM		0140000
#define S_IFLNK	0160000

#define S_ISUID	04000
#define S_ISGID	02000
#define S_ISVTX	01000

#define S_IRUSR	0400
#define S_IWUSR	0200
#define S_IXUSR	0100
#define S_IRGRP	0040
#define S_IWGRP	0020
#define S_IXGRP	0010
#define S_IROTH	0004
#define S_IWOTH	0002
#define S_IXOTH	0001

#define DEFAULT_DIRMODE	0777
#define DEFAULT_MODE		0666

typedef struct fileptr
{
	WORD		links;
	UWORD		flags;
	LONG		pos;
	LONG		devinfo;
	fcookie	fc;
	struct devdrv	*dev;
	struct fileptr *next;
} FILEPTR;

struct flock
{
	WORD	l_type;
	WORD	l_whence;
	LONG	l_start;
	LONG	l_len;
	WORD	l_pid;
};

#define F_RDLCK	O_RDONLY
#define F_WRLCK	O_WRONLY
#define F_UNLCK	3

typedef struct ilock
{
	struct flock	l;
	struct ilock	*next;
	LONG	reserved;
} LOCK;

typedef struct devdrv
{
	LONG (*open)P_((FILEPTR *f));
	LONG (*write)P_((FILEPTR *f, char *buf, LONG bytes ));
	LONG (*lseek)P_((FILEPTR *f, LONG where, WORD whence ));
	LONG (*ioctl)P_((FILEPTR *f, WORD mode, void *buf ));
	LONG (*datime)P_((FILEPTR *f, WORD *timeptr, WORD rwflag ));
	LONG (*close)P_((FILEPTR *f, WORD pid ));
	LONG (*select)P_((FILEPTR *f, LONG proc, WORD mode ));
	void (*unselect)P_((FILEPTR *f, LONG proc, WORD mode ));
	LONG reserved[3];
} DEVDRV;

typedef struct filesys {
	struct	filesys *next;
	long fsflags;
#define FS_KNOPARSE		0x01	/* kernel shouldn't do parsing */
#define FS_CASESENSITIVE	0x02	/* file names are case sensitive */
#define FS_NOXBIT		0x04	/* if a file can be read, it can be executed */
#define	FS_LONGPATH		0x08	/* file system understands "size" argument to
					   "getname" */

	LONG (*root)P_((WORD drv, fcookie *fc));
	LONG (*lookup)P_((fcookie *dir, char *name, fcookie *fc));
	LONG (*creat)P_((fcookie *dir, char *name, UWORD mode,
				WORD attrib, fcookie *fc));
	DEVDRV *(*getdev)P_((fcookie *fc, long *devspecial));
	LONG (*getxattr)P_((fcookie *fc, XATTR *xattr));
	LONG (*chattr)P_((fcookie *fc, WORD attr));
	LONG (*chown)P_((fcookie *fc, WORD uid, WORD gid));
	LONG (*chmode)P_((fcookie *fc, UWORD mode));
	LONG (*mkdir)P_((fcookie *dir, char *name, UWORD mode));
	LONG (*rmdir)P_((fcookie *dir, char *name));
	LONG (*remove)P_((fcookie *dir, char *name));
	LONG (*getname)P_((fcookie *relto, fcookie *dir, char *pathname,
				WORD size));
	LONG (*rename)P_((fcookie *olddir, char *oldname,
			    fcookie *newdir, char *newname));
	LONG (*opendir)P_((DIR *dirh, WORD tosflag));
	LONG (*readdir)P_((DIR *dirh, char *nm, WORD nmlen, fcookie *fc));
	LONG (*rewinddir)P_((DIR *dirh));
	LONG (*closedir)P_((DIR *dirh));
	LONG (*pathconf)P_((fcookie *dir, WORD which));
	LONG (*dfree)P_((fcookie *dir, LONG *buf));
	LONG (*writelabel)P_((fcookie *dir, char *name));
	LONG (*readlabel)P_((fcookie *dir, char *name, WORD namelen));
	LONG (*symlink)P_((fcookie *dir, char *name, char *to));
	LONG (*readlink)P_((fcookie *dir, char *buf, WORD len));
	LONG (*hardlink)P_((fcookie *fromdir, char *fromname,
	     		fcookie *todir, char *toname));
	LONG (*fscntl)P_((fcookie *dir, char *name, WORD cmd, LONG arg));
	LONG (*dskchng)P_((WORD drv));
	LONG (*release)P_((fcookie *fc));
	LONG (*dupcookie)P_((fcookie *dest, fcookie *src));
} FILESYS;

/*
 * this is the structure passed to loaded file systems to tell them
 * about the kernel
 */

typedef LONG (*_LongFunc)();

struct kerinfo {
	WORD	maj_version;	/* kernel version number */
	WORD	min_version;	/* minor kernel version number */
	UWORD	default_mode;	/* default file access mode */
	WORD	reserved1;	/* room for expansion */

/* OS functions */
	_LongFunc *bios_tab; /* pointer to the BIOS entry points */
	_LongFunc *dos_tab;	/* pointer to the GEMDOS entry points */

/* media change vector */
	void	(*drvchng)P_((WORD));

/* Debugging stuff */
	void	(*trace)P_((char *, ...));
	void	(*debug)P_((char *, ...));
	void	(*alert)P_((char *, ...));
	void	(*fatal)P_((char *, ...));

/* memory allocation functions */
	void *	(*kmalloc)P_((LONG));
	void	(*kfree)P_((void *));
	void *	(*umalloc)P_((LONG));
	void	(*ufree)P_((void *));

/* utility functions for string manipulation */
	WORD	(*strnicmp)P_((char *, char *, WORD));
	WORD	(*stricmp)P_((char *, char *));
	char *	(*strlwr)P_((char *));
	char *	(*strupr)P_((char *));
	WORD	(*sprintf)P_((char *, char *, ...));

/* utility functions for manipulating time */
	void	(*millis_time)P_((ULONG, WORD *));
	LONG	(*unixtim)P_((UWORD, UWORD));
	LONG	(*dostim)P_((LONG));

/* utility functions for dealing with pauses */
	void	(*nap)P_((UWORD));
	void	(*sleep)P_((WORD que, LONG cond));
	void	(*wake)P_((WORD que, LONG cond));
	void	(*wakeselect)P_((LONG param));

/* file system utility functions */
	WORD	(*denyshare)P_((FILEPTR *, FILEPTR *));
	LOCK *	(*denylock)P_((LOCK *, LOCK *));

/* timeout functions: available only in MiNT 1.06 and later */
	LONG	(*addtimeout)P_((LONG delta, void (*func)P_((void))));
	void	(*canceltimeout)P_((LONG));

/* reserved for future use */
	LONG	res2[7];
};

/* flags for open() modes */
#define O_RWMODE  	0x03	/* isolates file read/write mode */

#define O_RDONLY	0x00
#define O_WRONLY	0x01
#define O_RDWR		0x02
#define O_EXEC		0x03	/* execute file; used by kernel only */

#define O_APPEND	0x08	/* all writes go to end of file */

#define O_SHMODE	0x70	/* isolates file sharing mode */

#define O_COMPAT	0x00	/* compatibility mode */
#define O_DENYRW	0x10	/* deny both read and write access */
#define O_DENYW	0x20	/* deny write access to others */
#define O_DENYR	0x30	/* deny read access to others */
#define O_DENYNONE 	0x40	/* don't deny any access to others */

#define O_NOINHERIT	0x80	/* children don't get this file descriptor */

#define O_NDELAY	0x100	/* don't block for i/o on this file */
#define O_CREAT  	0x200	/* create file if it doesn't exist */
#define O_TRUNC  	0x400	/* truncate file to 0 bytes if it does exist */
#define O_EXCL		0x800	/* fail open if file exists */

#define O_USER		0x0fff	/* isolates user-settable flag bits */

#define O_GLOBAL	0x1000	/* for Fopen: opens a global file handle */

/* kernel mode bits -- the user can't set these! */
#define O_TTY		0x2000	/* FILEPTR refers to a terminal */
#define O_HEAD		0x4000	/* FILEPTR is the master side of a fifo */
#define O_LOCK		0x8000	/* FILEPTR has had locking Fcntl's performed */


/* macros to be applied to FILEPTRS to determine their type */
#define is_terminal(f) (f->flags & O_TTY)

/* The requests for Dpathconf() */
#define DP_IOPEN	0	/* internal limit on # of open files */
#define DP_MAXLINKS	1	/* max number of hard links to a file */
#define DP_PATHMAX	2	/* max path name length */
#define DP_NAMEMAX	3	/* max length of an individual file name */
#define DP_ATOMIC	4	/* # of bytes that can be written atomically */
#define DP_TRUNC	5	/* file name truncation behavior */
#define DP_CASE  	6	/* file name case conversion behavior */
#define DP_MAXREQ	6	/* highest legal request */

#define	DP_NOTRUNC	0	/* LONG filenames give an error */
#define	DP_AUTOTRUNC	1	/* LONG filenames truncated */
#define	DP_DOSTRUNC	2	/* DOS truncation rules in effect */

#define	DP_CASESENS	0	/* case sensitive */
#define	DP_CASECONV	1	/* case always converted */
#define	DP_CASEINSENS	2	/* case insensitive, preserved */

/* various character constants and defines for TTY's */
#define MiNTEOF	 0x0000ff1a	/* 1a == ^Z */

/* defines for tty_read */
#define RAW		0
#define COOKED		0x1
#define NOECHO		0
#define ECHO		0x2
#define ESCSEQ		0x04	 /* cursor keys, etc. get escape sequences */

/* constants for various Fcntl commands */
/* constants for Fcntl calls */
#define F_DUPFD		0		/* handled by kernel */
#define F_GETFD		1		/* handled by kernel */
#define F_SETFD		2		/* handled by kernel */
#define F_GETFL		3		/* handled by kernel */
#define F_SETFL		4		/* handled by kernel */
#define F_GETLK		5
#define F_SETLK		6
#define F_SETLKW		7

#define FD_CLOEXEC	1	/* close on exec flag */

#define FSTAT		(('F'<< 8) | 0)	/* handled by kernel */
#define FIONREAD	(('F'<< 8) | 1)
#define FIONWRITE	(('F'<< 8) | 2)
#define TIOCGETP	(('T'<< 8) | 0)
#define TIOCSETP	(('T'<< 8) | 1)
#define TIOCSETN	TIOCSETP
#define TIOCGETC	(('T'<< 8) | 2)
#define TIOCSETC	(('T'<< 8) | 3)
#define TIOCGLTC	(('T'<< 8) | 4)
#define TIOCSLTC	(('T'<< 8) | 5)
#define TIOCGPGRP	(('T'<< 8) | 6)
#define TIOCSPGRP	(('T'<< 8) | 7)
#define TIOCFLUSH	(('T'<< 8) | 8)
#define TIOCSTOP	(('T'<< 8) | 9)
#define TIOCSTART	(('T'<< 8) | 10)
#define TIOCGWINSZ	(('T'<< 8) | 11)
#define TIOCSWINSZ	(('T'<< 8) | 12)
#define TIOCGXKEY	(('T'<< 8) | 13)
#define TIOCSXKEY	(('T'<< 8) | 14)
#define TIOCIBAUD	(('T'<< 8) | 18)
#define TIOCOBAUD	(('T'<< 8) | 19)
#define TIOCCBRK	(('T'<< 8) | 20)
#define TIOCSBRK	(('T'<< 8) | 21)
#define TIOCGFLAGS	(('T'<< 8) | 22)
#define TIOCSFLAGS	(('T'<< 8) | 23)

#define TCURSOFF	(('c'<< 8) | 0)
#define TCURSON	(('c'<< 8) | 1)
#define TCURSBLINK	(('c'<< 8) | 2)
#define TCURSSTEADY	(('c'<< 8) | 3)
#define TCURSSRATE	(('c'<< 8) | 4)
#define TCURSGRATE	(('c'<< 8) | 5)

#define PPROCADDR	(('P'<< 8) | 1)
#define PBASEADDR	(('P'<< 8) | 2)
#define PCTXTSIZE	(('P'<< 8) | 3)
#define PSETFLAGS	(('P'<< 8) | 4)
#define PGETFLAGS	(('P'<< 8) | 5)
#define PTRACESFLAGS	(('P'<< 8) | 6)
#define PTRACEGFLAGS	(('P'<< 8) | 7)

#define	P_ENABLE	(1 << 0)	/* enable tracing */

#define PTRACEGO	(('P'<< 8) | 8)
#define PTRACEFLOW	(('P'<< 8) | 9)
#define PTRACESTEP	(('P'<< 8) | 10)
#define PTRACE11	(('P'<< 8) | 11)	/* unused, reserved */
#define PLOADINFO	(('P'<< 8) | 12)

#define SHMGETBLK	(('M'<< 8) | 0)
#define SHMSETBLK	(('M'<< 8) | 1)

/* terminal control constants (tty.sg_flags) */
#define T_CRMOD  	0x0001
#define T_CBREAK	0x0002
#define T_ECHO		0x0004
#define T_RAW		0x0010
#define T_TOS		0x0080
#define T_TOSTOP	0x0100
#define T_XKEY		0x0200		/* Fread returns escape sequences for
					   cursor keys, etc. */

/* the following are terminal status flags (tty.state) */
/* (the low byte of tty.state indicates a part of an escape sequence still
 * hasn't been read by Fread, and is an index into that escape sequence)
 */
#define TS_ESC		0x00ff
#define TS_HOLD  	0x1000		/* hold (e.g. ^S/^Q) */
#define TS_COOKED	0x8000		/* interpret control chars */

/* structures for terminals */
struct tchars {
	char t_intrc;
	char t_quitc;
	char t_startc;
	char t_stopc;
	char t_eofc;
	char t_brkc;
};

struct ltchars {
	char t_suspc;
	char t_dsuspc;
	char t_rprntc;
	char t_flushc;
	char t_werasc;
	char t_lnextc;
};

struct sgttyb {
	char sg_ispeed;
	char sg_ospeed;
	char sg_erase;
	char sg_kill;
	UWORD sg_flags;
};

struct winsize {
	WORD	ws_row;
	WORD	ws_col;
	WORD	ws_xpixel;
	WORD	ws_ypixel;
};

struct xkey {
	WORD	xk_num;
	char	xk_def[8];
};

struct tty {
	WORD		pgrp;		/* process group of terminal */
	WORD		state;		/* terminal status, e.g. stopped */
	WORD		use_cnt;	/* number of times terminal is open */
	WORD		res1;		/* reserved for future expansion */
	struct sgttyb 	sg;
	struct tchars 	tc;
	struct ltchars 	ltc;
	struct winsize	wsiz;
	LONG		rsel;		/* selecting process for read */
	LONG		wsel;		/* selecting process for write */
	char		*xkey;		/* extended keyboard table */
	LONG		rsrvd[3];	/* reserved for future expansion */
};

/* defines and declarations for Dcntl operations */

#define DEV_INSTALL	0xde02
#define DEV_NEWBIOS	0xde01
#define DEV_NEWTTY	0xde00

struct dev_descr {
	DEVDRV	*driver;
	WORD	dinfo;
	WORD	flags;
	struct tty *tty;
	LONG	reserved[4];
};

#define FS_INSTALL    0xf001  /* let the kernel know about the file system */
#define FS_MOUNT      0xf002  /* make a new directory for a file system */
#define FS_UNMOUNT    0xf003  /* remove a directory for a file system */
#define FS_UNINSTALL  0xf004  /* remove a file system from the list */

struct fs_descr
{
	FILESYS *file_system;
	WORD dev_no;    /* this is filled in by MiNT if arg == FS_MOUNT*/
	LONG flags;
	LONG reserved[4];
};

/**************************************************************	BIOS */

/******* BIOS errors */

#define	ERROR		-1		/* generic error */
#define	EDRVNR		-2		/* drive not ready */
#define	EUNCMD		-3		/* unknown command */
#define	E_CRC		-4		/* crc	error */
#define	EBADRQ		-5		/* bad	request */
#define	E_SEEK		-6		/* seek error	*/
#define	EMEDIA		-7		/* unknown media */
#define	ESECNF		-8		/* sector not	found */
#define	EPAPER		-9		/* out	of paper */
#define	EWRITF		-10		/* write fault */
#define	EREADF		-11		/* read fault	*/

#define	EWRPRO		-13		/* device write protected */
#define	E_CHNG		-14		/* media change detected */
#define	EUNDEV		-15		/* unknown device */
#define	EBADSF		-16		/* bad	sectors on format */
#define	EOTHER		-17		/* insert other disk	request */

/* Various Structures	and Definitions */

typedef	struct
{
#define	GEM_MAGIC	0x87654321
	ULONG	gem_magic;
	void *	gem_end;
	void 	(*gem_entry)();
} MUPB;

typedef	struct	_osheader
{
	UWORD		os_entry;
	UWORD		os_version;
	void 		(*reseth)P_(( void ));
	struct		_osheader *os_beg;
	void * 		os_end;
	ULONG		os_rsv1;
	MUPB *		os_magic;
	ULONG		os_date;
	UWORD		os_conf;
	GEMDOS_TIME	os_dosdate;
	char **	p_root;
	char **	p_kbshift;
	char **	p_run;
	LONG		p_rsv2;
} OSHEADER;

#define	VIDEO_MODE(x)		((x) &	0x01)
#define	COUNTRY_CODE(x)	((x) >> 1)

#define	USA			0
#define	GERMANY		1
#define	FRANCE			2
#define	UK			3
#define	SPAIN			4
#define	ITALY			5
#define	SWEDEN			6
#define	FSWITZERLAND		7
#define	GSWITZERLAND		8
#define	TURKEY			9
#define	FINLAND		10
#define	NORWAY			11
#define	DENMARK		12
#define	SAUDIARABIA		13
#define	HOLLAND		14
#define	CZECHOSLOVAKIA	15
#define	HUNGARY		16
#define	ALL_COUNTRIES		127

/*******************************************************	Cookie	Jar */

typedef	struct
{
#define	LAST_COOKIE		0L
	LONG	cookie;
	LONG	value;
} COOKIE;

#ifdef LATTICE
int getcookie(LONG,LONG *);
int putcookie(LONG,LONG);
#endif

#define	CPU_COOKIE		'_CPU'
#define	VIDEO_COOKIE		'_VDO'
#define	FPU_COOKIE		'_FPU'
#define	FLOPPY_COOKIE		'_FDC'
#define	SOUND_COOKIE		'_SND'
#define	MACHINE_COOKIE	'_MCH'
#define	SWITCH_COOKIE		'_SWI'
#define	FASTRAM_COOKIE	'_FRB'
#define	FLOCK_COOKIE		'_FLK'
#define	NETWORK_COOKIE	'_NET'
#define	DATETIME_COOKIE	'_IDT'
#define	KEYBOARD_COOKIE	'_AKP'
#define	GDOS_COOKIE		'FSMC'
#define	MINT_COOKIE		'MiNT'

#define	CPU_68000		0x00
#define	CPU_68010		0x0A
#define	CPU_68020		0x14
#define	CPU_68030		0x1E
#define	CPU_68040		0x28

#define	VIDEO_ST		0x00000000
#define	VIDEO_STE		0x00010000
#define	VIDEO_TT		0x00020000
#define	VIDEO_FALCON		0x00030000

#define	FPU_TYPE(x)		((x) >> 16)
#define	FPU_SOFTWARE(x)	((x) &	0xFFFF)
#define	FPU_NONE		0
#define	FPU_SFP		1
#define	FPU_6888X		2
#define	FPU_6888XwSFP	3
#define	FPU_68881		4
#define	FPU_68881wSFP		5
#define	FPU_68882		6
#define	FPU_68882wSFP		7
#define	FPU_68040		8
#define	FPU_68040wSFP		9

#define	FLOPPY_ORIGIN(x)	((x) &	0xFFF)
#define	FLOPPY_TYPE(x)	((x) >> 24)

#define	FLOPPY_ATARI		'ATC'
#define	FLOPPY_DSDD		0
#define	FLOPPY_DSHD		1
#define	FLOPPY_DSED		2

#define	SOUND_PSG		0x01
#define	SOUND_DMASTEREO	0x02
#define	SOUND_DMARECORD	0x04
#define	SOUND_XBIOS		0x04
#define	SOUND_CODEC		0x08
#define	SOUND_DSP		0x10

#define	MACHINE_ST		0x00000000
#define	MACHINE_STE		0x00010000
#define	MACHINE_STBOOK	0x00010008
#define	MACHINE_MEGASTE	0x0001000F
#define	MACHINE_TT		0x00020000
#define	MACHINE_FALCON	0x00030000

struct netinfo
{
	LONG	publisher;
	LONG	version;
};

#define	DATE_SEPARATOR(x)	((x) &	0xFF)
#define	DATE_FORMAT(x)	(((x) >> 8) &	0x0F)
#define	TIME_FORMAT(x)	(((x) >> 12) & 0x0F)

#define	DATE_MMDDYY		0
#define	DATE_DDMMYY		1
#define	DATE_YYMMDD		2
#define	DATE_YYDDMM		3

#define	TIME_12HOUR		0
#define	TIME_24HOUR		1

typedef	struct	_gdos_info
{
	LONG	gdos_type;
	UWORD	version;
	WORD	quality;
} GDOS_INFO;

/* BIOS	Devices */
#define	DEV_PRINTER		0
#define	DEV_PRN		0
#define	DEV_MODEM		1
#define	DEV_AUX		1
#define	DEV_CON		2
#define	DEV_CONSOLE		2
#define	DEV_MIDI		3
#define	DEV_IKBD		4
#define	DEV_RAW		5

#define	DEV_TTMODEM1		6
#define	DEV_TTMODEM2		7
#define	DEV_TTSERIAL1		8
#define	DEV_TTSERIAL2		9

#define	DEV_FALCONMODEM	7
#define	DEV_FALCONLAN		8

/* For Bconin() */
#define	ASCII_CODE(x)		((x) &	0xFF)
#define	SCAN_CODE(x)		(((x) >> 16) & 0xFF)
#define	SHIFT_STATE(x)	((x) >> 24)

/* For Getmpb() */
typedef	struct
{
	WORD	recsize;
	WORD 	clsiz;
	WORD	clsizb;
	WORD	rdlen;
	WORD	fsiz;
	WORD	fatrec;
	WORD	datrec;
	WORD	numcl;
	WORD	bflags;
} BPB;

typedef	struct	_md
{
	struct	_md *	m_link;
	void *		m_start;
	LONG	      	m_length;
	BASEPAGE *	m_own;
} MD;

typedef	struct
{
	MD	*mf_mf1;
	MD	*mf_ma1;
	MD	*mp_rover;
} MPB;

/* For Kbshift() */
#define	K_RSHIFT		0x01
#define	K_LSHIFT		0x02
#define	K_CTRL			0x04
#define	K_ALT			0x08
#define	K_CAPSLOCK		0x10
#define	K_CLRHOME		0x20
#define	K_INSERT		0x40

/* For Mediach() */
#define	MED_NOCHANGE		0
#define	MED_UNKNOWN		1
#define	MED_CHANGE		2

/* For Rwabs()	*/
#define	RW_READ		0x00
#define	RW_WRITE		0x01
#define	RW_USEMEDIACH		0x00
#define	RW_IGNOREMEDIACH	0x02
#define	RW_RETRIES		0x00
#define	RW_NORETRIES		0x04
#define	RW_TRANSLATE		0x00
#define	RW_NOTRANSLATE	0x08

/* For Setexc() */
#define	VEC_INQUIRE			((void	(*)())-1L)

#define	VEC_BUSERROR			0x02
#define	VEC_ADDRESSERROR	   	0x03
#define	VEC_ILLEGALINSTRUCTION	0x04
#define	VEC_DIVIDEBYZERO	   	0x05
#define	VEC_CHKINSTRUCTION		0x06
#define	VEC_TRAPXINSTRUCTION		0x07
#define	VEC_PRIVILEGEVIOLATION	0x08
#define	VEC_TRACEEXCEPTION		0x09
#define	VEC_LINEA		   	0x0A
#define	VEC_LINEF		   	0x0B
#define	VEC_PROTOCOLVIOLATION   	0x0D
#define	VEC_FORMATERROR	   	0x0E
#define	VEC_UNINTIALIZEDINTERRUPT	0x0F
#define	VEC_SPURIOUSINTERRUPT   	0x18

#define	VEC_AV1		   	0x19
#define	VEC_AV2		   	0x1A
#define	VEC_AV3		   	0x1B
#define	VEC_AV4		   	0x1C
#define	VEC_AV5		   	0x1D
#define	VEC_AV6		   	0x1E
#define	VEC_AV7		   	0x1F

#define	VEC_TRAP0		    	0x20
#define	VEC_TRAP1		    	0x21
#define	VEC_GEMDOS		    	0x21
#define	VEC_TRAP2		    	0x22
#define	VEC_GEM		    	0x22
#define	VEC_TRAP3		    	0x23
#define	VEC_TRAP4		    	0x24
#define	VEC_TRAP5		    	0x25
#define	VEC_TRAP6		    	0x26
#define	VEC_TRAP7		    	0x27
#define	VEC_TRAP8		    	0x28
#define	VEC_TRAP9		    	0x29
#define	VEC_TRAP10		    	0x2A
#define	VEC_TRAP11		    	0x2B
#define	VEC_TRAP12		    	0x2C
#define	VEC_TRAP13		    	0x2D
#define	VEC_BIOS		    	0x2D
#define	VEC_TRAP14		    	0x2E
#define	VEC_XBIOS		    	0x2E
#define	VEC_TRAP15		    	0x2F

#define	VEC_FPBSUC		    	0x30
#define	VEC_FPINEXACTRESULT		0x31
#define	VEC_FPDIVIDEBYZERO		0x32
#define	VEC_FPUNDERFLOW		0x33
#define	VEC_FPOPERANDERROR		0x34
#define	VEC_FPOVERFLOW		0x35
#define	VEC_FPSIGNALINGNAN		0x36

#define	VEC_MMUCONFIGERROR		0x37
#define	VEC_MMUILLEGALOP		0x38
#define	VEC_MMUACCESSVIOLATION	0x39

#define	VEC_STMFP0			0x40
#define	VEC_STMFP1			0x41
#define	VEC_STMFP2			0x42
#define	VEC_STMFP3			0x43
#define	VEC_STMFPTIMERD		0x44
#define	VEC_STMFPTIMERC		0x45
#define	VEC_STMFP4			0x46
#define	VEC_STMFP5			0x47
#define	VEC_STMFPTIMERB		0x48
#define	VEC_STMFPTRANSMITERROR	0x49
#define	VEC_STMFPTRANSMITBUFFER	0x4A
#define	VEC_STMFPRECIEVEERROR	0x4B
#define	VEC_STMFPRECIEVEBUFFER	0x4C
#define	VEC_STMFPTIMERA		0x4D
#define	VEC_STMFP6			0x4E
#define	VEC_STMFP7			0x4F

#define	VEC_TTMFP0			0x50
#define	VEC_TTMFP1			0x51
#define	VEC_TTMFP2			0x52
#define	VEC_TTMFP3			0x53
#define	VEC_TTMFPTIMERD		0x54
#define	VEC_TTMFPTIMERC		0x55
#define	VEC_TTMFP4			0x56
#define	VEC_TTMFP5			0x57
#define	VEC_TTMFPTIMERB		0x58
#define	VEC_TTMFPTRANSMITERROR	0x59
#define	VEC_TTMFPTRANSMITBUFFER	0x5A
#define	VEC_TTMFPRECIEVEERROR	0x5B
#define	VEC_TTMFPRECIEVEBUFFER	0x5C
#define	VEC_TTMFPTIMERA		0x5D
#define	VEC_TTMFP6			0x5E
#define	VEC_TTMFP7			0x5F

#define	VEC_SCCBTRANSMITBUFFER	0x60
#define	VEC_SCCBEXTERNALSTATUS	0x62
#define	VEC_SCCBRECEIVECHAR		0x64
#define	VEC_SCCBRECEIVECONDITION	0x66
#define	VEC_SCCATRANSMITBUFFER	0x68
#define	VEC_SCCAEXTERNALSTATUS	0x6A
#define	VEC_SCCARECEIVECHAR		0x6C
#define	VEC_SCCARECEIVECONDITION	0x6E

#define	VEC_TIMER			0x100
#define	VEC_CRITICALERROR		0x101
#define	VEC_TERMINATE			0x102

/*************** XBIOS ***************/
/* For Bconmap() / Iorec() */
#define	BMAP_CHECK		0
#define	BMAP_INQUIRE		-1
#define	BMAP_MAPTAB		-2

struct _iorec;	/* Forward Reference	*/

typedef	struct
{
	LONG	(*Bconstat)P_(( WORD ));
	LONG	(*Bconin)P_(( WORD ));
	LONG	(*Bcostat)P_(( WORD ));
	LONG	(*Bconout)P_(( WORD, WORD ));
	ULONG	(*Rsconf)P_(( WORD, WORD, WORD, WORD, WORD, WORD ));
	struct	_iorec	*iorec;
} MAPTAB;

typedef	struct
{
	MAPTAB	*maptab;
	WORD	maptabsize;
} BCONMAP;

/* For Blitmode() */
#define	BLIT_SOFT		0x00
#define	BLIT_HARD		0x01
#define	BLIT_INQUIRE		-1

/* For Buffoper() */
#define	PLAY_ENABLE		0x1
#define	PLAY_REPEAT		0x2
#define	RECORD_ENABLE		0x4
#define	RECORD_REPEAT		0x8

/* For Buffptr() */
typedef	struct
{
	void * 	playptr;
	void *	recordptr;
	void *	reserved1;
	void *	reserved2;
} SBUFPTR;

/* For Cursconf() */
#define	CURS_HIDE		0
#define	CURS_SHOW		1
#define	CURS_BLINK		2
#define	CURS_NOBLINK		3
#define	CURS_SETRATE		4
#define	CURS_GETRATE		5

/* For Dbmsg()	*/
#define	DB_NULLSTRING		0xF000
#define	DB_COMMAND		0xF100

/* For Devconnect() */
#define	ADC			3
#define	EXTINP			2
#define	DSPXMIT		1
#define	DMAPLAY		0

#define	DAC			0x8
#define	EXTOUT			0x4
#define	DSPRECV		0x2
#define	DMAREC			0x1

#define	CLK_25M		0
#define	CLK_EXT		1
#define	CLK_32M		2
 
#define	NO_SHAKE		1
#define	HANDSHAKE		0

#define	CLK_COMPAT		0
#define	CLK50K			1
#define	CLK33K			2
#define	CLK25K			3
#define	CLK20K			4
#define	CLK16K			5
#define	CLK12K			7
#define	CLK10K			9
#define	CLK8K			11

#define	ACT_CLK50K		49170
#define	ACT_CLK33K		33880
#define	ACT_CLK25K		24585
#define	ACT_CLK20K		20770
#define	ACT_CLK16K		16490
#define	ACT_CLK12K		12292
#define	ACT_CLK10K		9834
#define	ACT_CLK8K		8195

/* For Dosound() */
#define	DS_INQUIRE		-1

/* For Dsp_Hf0() & Dsp_Hf1()	*/
#define	HF_CLEAR		0
#define	HF_SET			1
#define	HF_INQUIRE		-1

#define	ICR_RXDF		0x01
#define	ICR_TXDE		0x02
#define	ICR_TRDY		0x04
#define	ICR_HF2		0x08
#define	ICR_HF3		0x10
#define	ICR_DMA		0x40
#define	ICR_HREQ		0x80

/* For Dsp_MultBlocks() */
typedef	struct
{
#define	BLOCK_LONG		0
#define	BLOCK_WORD		1
#define	BLOCK_UBYTE		2
	WORD	blocktype;
	LONG	blocksize;
	void *	block;
} DSPBLOCK;

/* For Dsp_RemoveInterrupts() */
#define	RTS_OFF		0x01
#define	RTR_OFF		0x02

/* Returned from transmitter	interrupt. */
#define	DSPSEND_NOTHING	0x00000000
#define	DSPSEND_ZERO		0xFF000000

/* For Dsptristate() */
#define	DSP_ENABLE		1
#define	DSP_TRISTATE		0

/* For Eget/setShift() */
#define	ES_SMEAR		0x8000
#define	ES_GRAY		0x1000

#define	ES_MODE		0x0700
#define	TT_LOW			0x0700
#define	TT_HIGH		0x0600
#define	TT_MED			0x0300
#define	ST_HIGH		0x0200
#define	ST_MED			0x0100
#define	ST_LOW			0x0000

#define	ES_BANK		0x000F
#define	BANK_0			0x0000
#define	BANK_1			0x0001
#define	BANK_2			0x0002
#define	BANK_3			0x0003
#define	BANK_4			0x0004
#define	BANK_5			0x0005
#define	BANK_6			0x0006
#define	BANK_7			0x0007
#define	BANK_8			0x0008
#define	BANK_9			0x0009
#define	BANK_10		0x000A
#define	BANK_11		0x000B
#define	BANK_12		0x000C
#define	BANK_13		0x000D
#define	BANK_14		0x000E
#define	BANK_15		0x000F

#define	IsSmearMode(x)	((x) &	ES_SMEAR)
#define	IsGrayMode(x)		((x) &	ES_GRAY)
#define	ScreenMode(x)		((x) &	ES_MODE)
#define	ColorBank(x)		((x) &	ES_BANK)

/* For EsetGray() */
#define	ESG_INQUIRE		-1
#define	ESG_COLOR		0
#define	ESG_GRAY		1

/* For EsetSmear() */
#define	ESM_NORMAL		0
#define	ESM_SMEAR		1
#define	ESM_INQUIRE		-1

/* For Flopfmt() */
#define	FLOP_DRIVEA		0
#define	FLOP_DRIVEB		1
#define	FLOP_SIDE0		0
#define	FLOP_SIDE1		1
#define	FLOP_NOSKEW		1
#define	FLOP_SKEW		-1
#define	FLOP_MAGIC		0x87654321
#define	FLOP_VIRGIN		0xE5E5

/* For Floprate() */
#define	FRATE_INQUIRE		-1
#define	FRATE_SEEK6		0
#define	FRATE_SEEK12		1
#define	FRATE_SEEK2		2
#define	FRATE_SEEK3		3

/* For Gettime() */
typedef	struct
{
	unsigned year:7;
	unsigned month:4;
	unsigned day:5;
	unsigned hour:5;
	unsigned minute:6;
	unsigned seconds:5;
} BIOS_TIME;

/* For Giaccess() */
#define	PSG_APITCHLOW		0
#define	PSG_APITCHHIGH	1
#define	PSG_BPITCHLOW		2
#define	PSG_BPITCHHIGH	3
#define	PSG_CPITCHLOW		4
#define	PSG_CPITCHHIGH	5
#define	PSG_WHITENOISEPITCH	6
#define	PSG_MODE		7
#define	PSG_AVOLUME		8
#define	PSG_BVOLUME		9
#define	PSG_CVOLUME		10
#define	PSG_FREQLOW		11
#define	PSG_FREQHIGH		12
#define	PSG_ENVELOPE		13
#define	PSG_PORTA		14
#define	PSG_PORTB		15

#define	PSG_SET		0x80

#define	PSG_ENABLEA		0x01
#define	PSG_ENABLEB		0x02
#define	PSG_ENABLEC		0x04
#define	PSG_NOISEA		0x08
#define	PSG_NOISEB		0x10
#define	PSG_NOISEC		0x20
#define	PSG_PORTAINPUT	0x00
#define	PSG_PORTAOUTPUT	0x40
#define	PSG_PORTBINPUT	0x00
#define	PSG_PORTBOUTPUT	0x80

/* For Gpio() */
#define	GPIO_INQUIRE		0
#define	GPIO_READ		1
#define	GPIO_WRITE		2

#define	GPIO_PIN1OUTPUT	0x00
#define	GPIO_PIN1INPUT	0x01
#define	GPIO_PIN2OUTPUT	0x00
#define	GPIO_PIN2INPUT	0x02
#define	GPIO_PIN3OUTPUT	0x00
#define	GPIO_PIN3INPUT	0x04

/* For Initmous() */
#define	IM_DISABLE		1
#define	IM_RELATIVE		2
#define	IM_ABSOLUTE		3
#define	IM_KEYCODE		4

struct param
{
	char	topmode;
	char	buttons;
	char	xparam;
	char	yparam;
};

/* For Iorec()	*/

#define	IO_SERIAL		0
#define	IO_KEYBOARD		1
#define	IO_MIDI		2

typedef	struct	_iorec
{
	char	*ibuf;
	WORD	ibufsize;
	WORD	ibufhd;
	WORD	ibuftl;
	WORD	ibuflow;
	WORD	ibuthi;
} IOREC;

/* For Kbdvbase() */
typedef	struct
{
	void	REGARGS (*midivec)P_(( char ));
	void (*vkbderr)P_(( void ));
	void (*vmiderr)P_(( void ));
	void REGARGS (*statvec)P_(( char * ));
	void REGARGS (*mousevec)P_(( char * ));
	void REGARGS (*clockvec)P_(( char * ));
	void REGARGS (*joyvec)P_(( char * ));
	void (*midisys)P_(( void ));
	void (*ikbdsys)P_(( void ));
	char ikbdstate;
} KBDVECS;

/* For Kbrate() */
#define	KB_INQUIRE		-1

/* For Keytbl() */
typedef	struct
{
	char	*unshift;
	char 	*shift;
	char 	*caps;
} KEYTAB;

#define	KT_NOCHANGE		((void *)-1)

/* For Locksnd() / Unlocksnd() */
#define	SNDNOTLOCKED		-128
#define	SNDLOCKED		-129

/* For Metainfo() */
typedef	struct
{
	ULONG	drivemap;
	char 	*version;
	LONG	reserved[2];
} METAINFO;

/* For Mfpint() */
#define	MFP_PARALLEL			0
#define	MFP_DCD     			1
#define	MFP_CTS     			2
#define	MFP_BITBLT  			3
#define	MFP_TIMERD  			4
#define	MFP_BAUDRATE			4
#define	MFP_TIMERC			5
#define	MFP_200HZ			5
#define	MFP_IKBD			6
#define	MFP_DISK			7
#define	MFP_TIMERB			8
#define	MFP_HBLANK			8
#define	MFP_TRANSMITERROR		9
#define	MFP_TRANSMITBUFFEREMPTY	10
#define	MFP_RECEIVEERROR		11
#define	MFP_RECEIVEBUFFERFULL	12
#define	MFP_TIMERA			13
#define	MFP_DMASOUND			13
#define	MFP_RINGINDICATOR		14
#define	MFP_MONODETECT		15

/* For NVMaccess() */
#define	NVM_READ		0
#define	NVM_WRITE		1
#define	NVM_RESET		2

/* For Off/Ongibit() */
#define	GI_FLOPPYSIDE		0x01
#define	GI_FLOPPYA		0x02
#define	GI_FLOPPYB		0x04
#define	GI_RTS			0x08
#define	GI_DTR			0x10
#define	GI_STROBE		0x20
#define	GI_GPO			0x40
#define	GI_RESERVED		0x80

/* For Protobt() */
#define	SERIAL_NOCHANGE	-1
#define	SERIAL_RANDOM		0x01000000

#define	DISK_NOCHANGE	-1
#define	DISK_SSSD		0
#define	DISK_DSSD		1
#define	DISK_SSDD		2
#define	DISK_DSDD		3
#define	DISK_DSHD		4
#define	DISK_DSED		5

#define	EXECUTE_NOCHANGE	-1
#define	EXECUTE_NO		0
#define	EXECUTE_YES		1

/* For Prtblk() */
typedef	struct
{
	void * 	blkptr;
	UWORD 	offset;
	UWORD 	width;
	UWORD 	height;
	UWORD 	left;
	UWORD 	right;
	UWORD 	srcres;
	UWORD 	destres;
	UWORD 	*colpal;
	UWORD 	type;
	UWORD 	port;
	char	*masks;
} PRTBLK;

/* For Rsconf() */
#define	BAUD_19200		0		/* Baud Rate Settings */
#define	BAUD_9600		1
#define	BAUD_4800		2
#define	BAUD_3600		3
#define	BAUD_2400		4
#define	BAUD_2000		5
#define	BAUD_1800		6
#define	BAUD_1200		7
#define	BAUD_600		8
#define	BAUD_300		9
#define	BAUD_200		10
#define	BAUD_150		11
#define	BAUD_134		12
#define	BAUD_110		13
#define	BAUD_75		14
#define	BAUD_50		15
	
#define	RS_LASTBAUD		-2		/* Inquiry Flags */
#define	RS_INQUIRE		-1

#define	FLOW_NONE		0		/* Flow Control */
#define	FLOW_SOFT		1
#define	FLOW_HARD		2
#define	FLOW_BOTH		3

#define	RS_ODDPARITY		0x02		/* Parity Control */
#define	RS_EVENPARITY		0x00
#define	RS_PARITYENABLE	0x04
#define	RS_PARITYDISABLE	0x00

#define	RS_8BITS		0x00		/* Character Size */
#define	RS_7BITS		0x20
#define	RS_6BITS		0x40
#define	RS_5BITS		0x60

#define	RS_CLK16		0x80		/* Clock Divisor */

#define	RS_RECVENABLE		0x01		/* Flags */
#define	RS_RECVDISABLE	0x00
#define	RS_SYNCSTRIP		0x02
#define	RS_MATCHBUSY		0x04
#define	RS_BRKDETECT		0x08
#define	RS_FRAMEERR		0x10
#define	RS_PARITYERR		0x20
#define	RS_OVERRUNERR		0x40
#define	RS_BUFFULL		0x80

/* For Setbuffer() */	
#define	PLAY			0
#define	RECORD			1

/* For Setcolor() */
#define	COL_INQUIRE		-1
	
/* For Setinterrupt()	*/
#define	INT_TIMERA		0
#define	INT_I7			1

#define	INT_DISABLE		0
#define	INT_PLAY		1
#define	INT_RECORD		2
#define	INT_BOTH		3
 
/* For Setmode() */
#define	MODE_STEREO8		0
#define	MODE_STEREO16		1
#define	MODE_MONO8		2

/* For Setprt() */
#define	PRT_INQUIRE		-1

#define	PRT_DOTMATRIX		0x00
#define	PRT_DAISY		0x01
#define	PRT_MONO		0x00
#define	PRT_COLOR		0x02
#define	PRT_ATARI		0x00
#define	PRT_EPSON		0x04
#define	PRT_DRAFT		0x00
#define	PRT_FINAL		0x08
#define	PRT_PARALLEL		0x00
#define	PRT_SERIAL		0x10
#define	PRT_CONTINUOUS	0x00
#define	PRT_SINGLESHEET	0x20

/* For Setscreen() */
#define	SCR_NOCHANGE		-1L

/* For Sndstatus() */
#define	SND_RESET		1

#define	SND_CLIPLEFT		0x08
#define	SND_CLIPRIGHT		0x10

#define	SND_ERROR		0x0F
#define	SND_OK			0
#define	SND_BADCONTROL	1
#define	SND_BADSYNC		2
#define	SND_BADCLOCK		3

#define	INQUIRE		-1

/* For Soundcmd() */
#define	LTATTEN		0
#define	RTATTEN		1
#define	LTGAIN			2
#define	RTGAIN			3
#define	ADDERIN		4
#define	ADCINPUT		5
#define	SETPRESCALE		6

#define	ADDR_ADC		0x01
#define	ADDR_MATRIX		0x02

#define	LEFT_MIC		0x00
#define	LEFT_PSG		0x01
#define	RIGHT_MIC		0x00
#define	RIGHT_PSG		0x01

#define	CCLK_50K		3
#define	CCLK_25K		2
#define	CCLK_12K		1
#define	CCLK_6K		0

/* For VgetMonitor() */
#define	MON_MONO		0
#define	MON_COLOR		1
#define	MON_VGA		2
#define	MON_TV			3

typedef	struct
{
	UCHAR reserved;
	UCHAR red;
	UCHAR blue;
	UCHAR green;
} RGB;

/* For VsetMask() */
#define	OVERLAY_ON		1
#define	OVERLAY_OFF		0

/* For VsetMode() */
#define	BPS1			0x00
#define	BPS2			0x01
#define	BPS4			0x02
#define	BPS8			0x03
#define	BPS16			0x04
#define	BPS32			0x05

#define	COL80			0x08
#define	COL40			0x00

#define	VGA			0x10
#define	TV			0x00

#define	PAL			0x20
#define	NTSC			0x00

#define	OVERSCAN		0x40
#define	STMODES		0x80
#define	VERTFLAG		0x100

#define	VM_INQUIRE		-1

/* For VsetScreen() */
#define	SCR_MODECODE		3

/* For VsetSync() */
#define	VCLK_EXTERNAL		0x01
#define	VCLK_EXTVSYNC		0x02
#define	VCLK_EXTHSYNC		0x04

/* For Xbtimer() */
#define	XB_TIMERA		0
#define	XB_TIMERB		1
#define	XB_TIMERC		2
#define	XB_TIMERD		3

/************************************************************ AES ****/

/* For appl_getinfo()	*/
#define	AES_LARGEFONT		0
#define	AES_SMALLFONT		1
#define	AES_SYSTEM		2
#define	AES_LANGUAGE		3
#define	AES_ENVIRON1		4
#define	AES_ENVIRON2		5
#define	AES_ENVIRON3		6
#define	AES_OSEXTENSIONS	7
#define	AES_MOUSE		8
#define	AES_MENU		9
#define	AES_SHELWRITE		10
#define	AES_WINDOW		11
#define	AES_MESSAGE		12
#define	AES_OBJECT		13
#define	AES_FORM		14

#define	SYSTEM_FONT		0
#define	OUTLINE_FONT		1

#define	AESLANG_ENGLISH	0
#define	AESLANG_GERMAN	1
#define	AESLANG_FRENCH	2
#define	AESLANG_SPANISH	4
#define	AESLANG_ITALIAN	5
#define	AESLANG_SWEDISH	6

#define	HAS_WFTOP		0x01
#define	HAS_WFNEWDESK		0x02
#define	HAS_WFCOLOR		0x04
#define	HAS_WFDCOLOR		0x08
#define	HAS_WFOWNER		0x10
#define	HAS_WFBEVENT		0x20
#define	HAS_WFBOTTOM		0x40
#define	HAS_WFICONIFY		0x80
#define	HAS_WFUNICONIFY	0x100

#define	HAS_ICONIFIER		0x01
#define	HAS_BOTTOMER		0x02
#define	HAS_SHIFTCLICK	0x04
#define	HAS_HOTCLOSEBOX	0x08

#define	HAS_WMNEWTOP		0x01
#define	HAS_WMUNTOPPED	0x02
#define	HAS_WMONTOP		0x04
#define	HAS_APTERM		0x08
#define	HAS_RESCHANGE		0x10
#define	HAS_CHEXIT		0x20
#define	HAS_WMBOTTOM		0x40
#define	HAS_WMICONIFY		0x80
#define	HAS_WMUNICONIFY	0x100
#define	HAS_WMALLICONIFY 	0x200

/* For appl_init() */
#ifdef LATTICE
#define	_AESversion		_AESglobal[0]
#define	_AESnumapps		_AESglobal[1]
#define	_AESapid		_AESglobal[2]
#define	_AESappglobal		((((LONG)_AESglobal[3])<<16)|(LONG)_AESglobal[4])
#define	_AESrscfile		((((LONG)_AESglobal[5])<<16)|(LONG)_AESglobal[6])
#define	_AESmaxchar		_AESglobal[13]
#define	_AESminchar		_AESglobal[14]
#endif
#ifdef __PUREC__

typedef struct
{
    int    contrl[15];
    int    global[15];
    int    intin[132];
    int    intout[140];
    void   *addrin[16];
    void   *addrout[16];
} GEMPARBLK;

extern  GEMPARBLK _GemParBlk;

#define _AESversion		_GemParBlk.global[0]
#define _AESnumapps		_GemParBlk.global[1]
#define _AESapid		_GemParBlk.global[2]
#define _AESappglobal		((((LONG)_GemParBlk.global[3])<<16)|(LONG)_GemParBlk.global[4])
#define _AESrscfile		((((LONG)_GemParBlk.global[5])<<16)|(LONG)_GemParBlk.global[6])
#define _AESmaxchar		_GemParBlk.global[13]
#define _AESminchar		_GemParBlk.global[14]

extern  int       _app;

typedef struct
{
    int    *contrl;
    int    *global;
    int    *intin;
    int    *intout;
    int    *addrin;
    int    *addrout;
} AESPB;

typedef struct /* Special type for EventMulti */
{
        /* input parameters */
        int     ev_mflags, ev_mbclicks, ev_bmask, ev_mbstate, ev_mm1flags,
                ev_mm1x, ev_mm1y, ev_mm1width, ev_mm1height, ev_mm2flags,
                ev_mm2x, ev_mm2y, ev_mm2width, ev_mm2height, ev_mtlocount,
                ev_mthicount;
        /* output parameters */
        int     ev_mwich, ev_mmox, ev_mmoy, ev_mmobutton, ev_mmokstate,
                ev_mkreturn, ev_mbreturn;
        /* message buffer */
        int     ev_mmgpbuf[8];
} EVENT;

#endif

/* For appl_read() */
#define	APR_NOWAIT		-1

/* For appl_search() */
#define	APP_FIRST		0
#define	APP_NEXT		1

#define	APP_SYSTEM		0
#define	APP_APPLICATION	1
#define	APP_ACCESSORY		2

/* For appl_tplay() */
typedef	struct
{
	LONG 	ap_event;
	LONG 	ap_value;
} EVNTREC;

#define	APPEVNT_TIMER		0
#define	APPEVNT_BUTTON	1
#define	APPEVNT_MOUSE		2
#define	APPEVNT_KEYBOARD	3

/* For evnt_...() */
#define	LEFT_BUTTON		0x01
#define	RIGHT_BUTTON		0x02
#define	MIDDLE_BUTTON		0x04

#define	EDC_INQUIRE		0
#define	EDC_SET		1

#define	MU_KEYBD		0x0001
#define	MU_BUTTON		0x0002
#define	MU_M1			0x0004
#define	MU_M2			0x0008
#define	MU_MESAG		0x0010
#define	MU_TIMER		0x0020

#define	MN_SELECTED		10

#define	WM_REDRAW		20
#define	WM_TOPPED		21
#define	WM_CLOSED		22
#define	WM_FULLED		23
#define	WM_ARROWED		24
#define	WM_HSLID		25
#define	WM_VSLID		26
#define	WM_SIZED		27
#define	WM_MOVED		28
#define	WM_UNTOPPED		30
#define	WM_ONTOP		31
#define	WM_BOTTOM		33
#define	WM_ICONIFY		34
#define	WM_UNICONIFY		35
#define	WM_ALLICONIFY		36
#define	WM_TOOLBAR		37
#define	AC_OPEN		40
#define	AC_CLOSE		41
#define	AP_TERM		50
#define	AP_TFAIL		51
#define	AP_RESCHG		57
#define	SHUT_COMPLETED 	60
#define	RESCH_FAILED		61
#define	AP_DRAGDROP		63
#define	SH_WDRAW		72
/* For SH_WDRAW */
#define	ALL_DRIVES		-1

#define	CH_EXIT		90

#define	CT_UPDATE		50
#define	CT_MOVE		51
#define	CT_NEWTOP		52
#define	CT_KEY			53

#define	WA_UPPAGE		0
#define	WA_DNPAGE		1
#define	WA_UPLINE		2
#define	WA_DNLINE		3
#define	WA_LFPAGE		4
#define	WA_RTPAGE		5
#define	WA_LFLINE		6
#define	WA_RTLINE		7

#define	MO_ENTER		0
#define	MO_LEAVE		1	

typedef	struct	moblk
{
	WORD 	m_out;
	WORD 	m_x;
	WORD 	m_y;
	WORD 	m_w;
	WORD 	m_h;
} MOBLK;


/* For form_dial() */
#define	FMD_START		0
#define	FMD_GROW		1
#define	FMD_SHRINK		2
#define	FMD_FINISH		3

/* For form_error() */
#define	FERR_FILENOTFOUND	2
#define	FERR_PATHNOTFOUND	3
#define	FERR_NOHANDLES   	4
#define	FERR_ACCESSDENIED	5
#define	FERR_LOWMEM	   	8
#define	FERR_BADENVIRON  	10
#define	FERR_BADFORMAT   	11
#define	FERR_BADDRIVE		15
#define	FERR_DELETEDIR   	16
#define	FERR_NOFILE	   	18

/* For fsel_input() */
#define	FSEL_OK		1
#define	FSEL_CANCEL		0

/* For graf_mouse() */
#define	ARROW			0
#define	TEXT_CRSR		1
#define	BUSY_BEE		2
#define	POINT_HAND		3
#define	FLAT_HAND		4
#define	THIN_CROSS		5
#define	THICK_CROSS		6
#define	OUTLN_CROSS		7
#define	USER_DEF		255
#define	M_OFF			256
#define	M_ON			257
#define	M_SAVE			258
#define	M_LAST			259
#define	M_RESTORE		260
#define	M_FORCE		0x8000

#define	VERTICAL		0
#define	HORIZONTAL		1

typedef	struct
{
	WORD	x, y;
	WORD	buttons;
	WORD	keys;
} MoInfo;

typedef	struct
{
	WORD x, y;
} POINT;

/* For menu_attach() / menu_popup()	*/

struct object;	/* Forward definition */

typedef	struct	_menu
{
	struct	object	*mn_tree;
	WORD	mn_menu;
	WORD	mn_item;
	WORD	mn_scroll;
	WORD	mn_keystate;
} MENU;

#define	SCROLL_YES		1
#define	SCROLL_NO		0
#define	SCROLL_LISTBOX	-1

#define	ME_INQUIRE		0
#define	ME_ATTACH		1
#define	ME_REMOVE		2

/* For menu_bar() */
#define	MENU_REMOVE		0
#define	MENU_INSTALL		1
#define	MENU_INQUIRE		-1

/* For menu_ienable()/icheck() */
#define	ENABLE			1
#define	DISABLE		0	
#define	CHECK			1
#define	UNCHECK		0
#define	HIGHLIGHT		0
#define	UNHIGHLIGHT		1

/* For menu_istart() */
#define	MIS_SETALIGN		1
#define	MIS_GETALIGN		0

/* For menu_register() */
#define	REG_NEWNAME		-1

/* For menu_settings() */
typedef	struct	_mn_set
{
	LONG	display;
	LONG	drag;
	LONG	delay;
	LONG	speed;
	WORD	height;
} MN_SET;

#define	MN_INQUIRE		0
#define	MN_CHANGE		1

/* OBJECT Definitions	*/
#define	ROOT			0
#define	NIL			-1

#define	MAX_DEPTH		8	/* max	depth of search or draw */

#define	IP_HOLLOW		0	/* inside patterns */
#define	IP_1PATT		1
#define	IP_2PATT		2
#define	IP_3PATT		3
#define	IP_4PATT		4
#define	IP_5PATT		5
#define	IP_6PATT		6
#define	IP_SOLID		7

#define	GDOS_PROP		0	/* font types	*/
#define	GDOS_MONO		1
#define	GDOS_BITM		2
#define	IBM			3
#define	SMALL			5

#define	G_BOX			20	/* Graphic types of obs	*/
#define	G_TEXT			21
#define	G_BOXTEXT		22
#define	G_IMAGE		23
#define	G_PROGDEF		24
#define	G_USERDEF		G_PROGDEF
#define	G_IBOX			25
#define	G_BUTTON		26
#define	G_BOXCHAR		27
#define	G_STRING		28
#define	G_FTEXT		29
#define	G_FBOXTEXT		30
#define	G_ICON			31
#define	G_TITLE		32
#define	G_CICON		33

#define	NONE			0x0000	/* Object flags */
#define	SELECTABLE		0x0001
#define	DEFAULT		0x0002
#define	EXIT			0x0004
#define	EDITABLE		0x0008
#define	RBUTTON		0x0010
#define	LASTOB			0x0020
#define	TOUCHEXIT		0x0040
#define	HIDETREE		0x0080
#define	INDIRECT		0x0100
#define	FL3DIND		0x0200
#define	FL3DBAK		0x0400
#define	FL3DACT		0x0600
#define	SUBMNU			0x0800

#define	NORMAL			0x0000	/* Object states */
#define	SELECTED		0x0001
#define	CROSSED		0x0002
#define	CHECKED		0x0004
#define	DISABLED		0x0008
#define	OUTLINED		0x0010
#define	SHADOWED		0x0020
#define	SPECIAL		0x0040	/* user defined object state */

#define	WHITE			0		/* Object colors */
#define	BLACK			1
#define	RED			2
#define	GREEN			3
#define	BLUE			4
#define	CYAN			5
#define	YELLOW			6
#define	MAGENTA		7
#define	LWHITE			8
#define	LBLACK			9
#define	LRED			10
#define	LGREEN			11
#define	LBLUE			12
#define	LCYAN			13
#define	LYELLOW		14
#define	LMAGENTA		15

#define	TE_LEFT		0		/* editable text justification */
#define	TE_RIGHT		1
#define	TE_CNTR		2

typedef	struct	object
{
	WORD 	ob_next;
	WORD 	ob_head;
	WORD 	ob_tail;
	UWORD 	ob_type;
	UWORD 	ob_flags;
	UWORD 	ob_state;
	void * 	ob_spec;
	WORD 	ob_x;
	WORD 	ob_y;
	WORD 	ob_width;
	WORD 	ob_height;
} OBJECT;

typedef	struct	text_edinfo
{
	char *te_ptext;
	char *te_ptmplt;
	char *te_pvalid;
	WORD 	te_font;
	WORD 	te_fontid;
	WORD 	te_just;
	WORD 	te_color;
	WORD 	te_fontsize;
	WORD 	te_thickness;
	WORD 	te_txtlen;
	WORD 	te_tmplen;
} TEDINFO;

typedef	struct	icon_block
{
	WORD *ib_pmask;
	WORD *ib_pdata;
	char *ib_ptext;
	WORD ib_char;
	WORD ib_xchar;
	WORD ib_ychar;
	WORD ib_xicon;
	WORD ib_yicon;
	WORD ib_wicon;
	WORD ib_hicon;
	WORD ib_xtext;
	WORD ib_ytext;
	WORD ib_wtext;
	WORD ib_htext;
} ICONBLK;

typedef	struct	cicon_data
{
	WORD	num_planes;
	WORD	*col_data;
	WORD	*col_mask;
	WORD	*sel_data;
	WORD	*sel_mask;
	struct	cicon_data *next_res;
} CICON;

typedef	struct	cicon_blk
{
	ICONBLK	monoblk;
	CICON		*mainlist;
} CICONBLK;

typedef	struct	bit_block
{
	WORD *bi_pdata;
	WORD bi_wb;
	WORD bi_hl;
	WORD bi_x;
	WORD bi_y;
	WORD bi_color;
} BITBLK;

typedef	struct	parm_blk
{
	OBJECT	*pb_tree;
	WORD pb_obj;
	WORD pb_prevstate;
	WORD pb_currstate;
	WORD pb_x;
	WORD pb_y;
	WORD pb_w;
	WORD pb_h;
	WORD pb_xc;
	WORD pb_yc;
	WORD pb_wc;
	WORD pb_hc;
	LONG pb_parm;
} PARMBLK;

typedef	struct	appl_blk
{
	int (*STDARGS ab_code)P_((PARMBLK *));
	LONG ab_parm;
} APPLBLK;

typedef	struct	grect
{
	WORD g_x;
	WORD g_y;
	WORD g_w;
	WORD g_h;
} GRECT;

/* For objc_change() */
#define	NO_DRAW		0
#define	REDRAW			1

/* For objc_edit() */
#define	ED_START		0
#define	ED_INIT		1
#define	ED_CHAR		2
#define	ED_END			3

/* For objc_order() */
#define	OO_LAST		-1
#define	OO_FIRST		0

/* For objc_sysvar() */
#define	SV_INQUIRE		0
#define	SV_SET			1

#define	LK3DIND		1
#define	LK3DACT		2
#define	INDBUTCOL		3
#define	ACTBUTCOL		4
#define	BACKGRCOL		5
#define	AD3DVAL		6
#define	AD3DVALUE		6

/* For rsrc_gaddr() */
#define	R_TREE			0
#define	R_OBJECT		1
#define	R_TEDINFO		2
#define	R_ICONBLK		3
#define	R_BITBLK		4
#define	R_STRING		5	/* gets pointer to free strings */
#define	R_IMAGEDATA		6	/* gets pointer to free images */
#define	R_OBSPEC		7
#define	R_TEPTEXT		8	/* sub	ptrs in TEDINFO */
#define	R_TEPTMPLT		9
#define	R_TEPVALID		10
#define	R_IBPMASK		11	/* sub	ptrs in ICONBLK */
#define	R_IBPDATA		12
#define	R_IBPTEXT		13
#define	R_BIPDATA		14	/* sub	ptrs in BITBLK */
#define	R_FRSTR		15	/* gets addr of ptr to free	strings */
#define	R_FRIMG		16	/* gets addr of ptr to free	images	*/

typedef	struct
{
	WORD rsh_vrsn;		/* RCS	version no. */
	UWORD rsh_object;		/* offset to object[] */
	UWORD rsh_tedinfo;		/* offset to tedinfo[] */
	UWORD rsh_iconblk;		/* offset to iconblk[] */
	UWORD rsh_bitblk;		/* offset to bitblk[] */
	UWORD rsh_frstr;		/* offset to free string index */
	UWORD rsh_string;		/* offset to first string */
	UWORD rsh_imdata;		/* offset to image data */
	UWORD rsh_frimg;		/* offset to free image index */
	UWORD rsh_trindex;		/* offset to object tree index */
	WORD rsh_nobs;		/* number of objects	*/
	WORD rsh_ntree;		/* number of trees */
	WORD rsh_nted;		/* number of tedinfos */
	WORD rsh_nib;			/* number of icon blocks */
	WORD rsh_nbb;			/* number of blt blocks */
	WORD rsh_nstring;		/* number of free strings */
	WORD rsh_nimages;		/* number of free images */
	UWORD rsh_rssize;		/* total bytes in resource */
} RSHDR;

/* For shel_get() */
#define	SHELL_BUFSIZ		-1

/* For shel_write() */
#define	SWM_LAUNCH		0
#define	SWM_LAUNCHNOW		1
#define	SWM_LAUNCHACC		3
#define	SWM_SHUTDOWN		4
#define	SWM_REZCHANGE		5
#define	SWM_BROADCAST		7
#define	SWM_ENVIRON		8
#define	SWM_NEWMSG		9
#define	SWM_AESMSG		10

#define	SW_PSETLIMIT		0x100
#define	SW_PRENICE		0x200
#define	SW_DEFDIR		0x400
#define	SW_ENVIRON		0x800

typedef	struct	_shelw
{
	char	*newcmd;
	LONG	psetlimit;
	LONG	prenice;
	char	*defdir;
	char	*env;
} SHELW;

#define	CL_NORMAL    		0
#define	CL_ARGV      		1

#define	SD_ABORT     		0
#define	SD_PARTIAL   		1
#define	SD_COMPLETE  		2

#define	ENVIRON_SIZE		0
#define	ENVIRON_CHANGE	1
#define	ENVIRON_COPY		2

#define	NM_APTERM		0x01

/* For wind_create() */
#define	NAME			0x0001
#define	CLOSE			0x0002
#define	CLOSER			CLOSE
#define	FULL			0x0004
#define	FULLER			FULL
#define	MOVE			0x0008
#define	MOVER			MOVE
#define	INFO			0x0010
#define	SIZE			0x0020
#define	SIZER			SIZE
#define	UPARROW		0x0040
#define	DNARROW		0x0080
#define	VSLIDE			0x0100
#define	LFARROW		0x0200
#define	RTARROW		0x0400
#define	HSLIDE			0x0800
#define	SMALLER		0x4000

/* For wind_get/set()	*/
#define	DESK			0

#define	WF_KIND		1
#define	WF_NAME 		2
#define	WF_INFO 		3
#define	WF_WXYWH		4
#define	WF_WORKXYWH		WF_WXYWH
#define	WF_CXYWH		5
#define	WF_CURRXYWH		WF_CXYWH
#define	WF_PXYWH		6
#define	WF_PREVXYWH		WF_PXYWH
#define	WF_FXYWH		7
#define	WF_FULLXYWH		WF_FXYWH
#define	WF_HSLIDE		8
#define	WF_VSLIDE		9
#define	WF_TOP			10
#define	WF_FIRSTXYWH		11
#define	WF_NEXTXYWH		12
#define	WF_IGNORE		13
#define	WF_NEWDESK		14
#define	WF_HSLSIZE		15
#define	WF_HSLSIZ		WF_HSLSIZE
#define	WF_VSLSIZE		16
#define	WF_VSLSIZ		WF_VSLSIZE
#define	WF_SCREEN		17
#define	WF_COLOR		18
#define	WF_DCOLOR		19
#define	WF_OWNER		20
#define	WF_BEVENT		24
#define	WF_BOTTOM		25
#define	WF_ICONIFY		26
#define	WF_UNICONIFY		27
#define	WF_TOOLBAR		30
#define	WF_FTOOLBAR		31
#define	WF_NTOOLBAR		32

#define	W_BOX			0
#define	W_TITLE		1
#define	W_CLOSER		2
#define	W_NAME			3
#define	W_FULLER		4
#define	W_INFO			5
#define	W_DATA			6
#define	W_WORK			7
#define	W_SIZER		8
#define	W_VBAR			9
#define	W_UPARROW		10
#define	W_DNARROW		11
#define	W_VSLIDE		12
#define	W_VELEV		13
#define	W_HBAR			14
#define	W_LFARROW		15
#define	W_RTARROW		16
#define	W_HSLIDE		17
#define	W_HELEV		18
#define	W_SMALLER		19

#define	B_UNTOPPABLE		0x01

/* For wind_update() */
#define	END_UPDATE		0
#define	BEG_UPDATE		1
#define	END_MCTRL		2
#define	BEG_MCTRL		3

#define	NO_BLOCK		0x100

/* For wind_calc() */
#define	WC_BORDER		0
#define	WC_WORK		1

#define	ADDR(a)		((LONG)(a)>>16),((LONG)(a))

/* Useful AES functions */
#ifndef	min
#ifdef LATTICE
int min(WORD,WORD);
int __builtin_min(WORD,WORD);
#define	min(a,b)	__builtin_min(a,b)
#else
#define	min(a,b)	(((a) < (b)) ? (a) :	(b))
#endif
#endif

#ifndef	max
#ifdef LATTICE
int max(WORD,WORD);
int __builtin_max(WORD,WORD);
#define	max(a,b)	__builtin_max(a,b)
#else
#define	max(a,b)	(((a) > (b)) ? (a) :	(b))
#endif
#endif

#ifdef LATTICE
UWORD umul_div( UWORD, UWORD, UWORD);
#pragma	inline	d0=umul_div(d0,d1,d2)	{"c0c180c2";}
#else
#define umul_div(a,b,c)	(((UWORD)a*(UWORD)b)/(UWORD)c)
#endif

/* macros to pass parameters	*/
#ifndef	PTRS
#define	PTRS(r) r->g_x, r->g_y, r->g_w, r->g_h
#endif

#ifndef	ELTS
#define	ELTS(r) r.g_x, r.g_y, r.g_w, r.g_h
#endif

/************************************************* Drag & Drop ********/

#define	DD_OK			0
#define	DD_NAK			1
#define	DD_EXT			2
#define	DD_LEN			3
#define	DD_TRASH		4
#define	DD_PRINTER		5
#define	DD_CLIPBOARD		6

/* timeout in milliseconds */
#define	DD_TIMEOUT		4000

#define	DD_NUMEXTS		8
#define	DD_EXTSIZE		32L

/********************************************************* OBDEFS *****/

#ifndef	NIL
#define	NIL			 -1
#endif

#define	MsgId(msg)		((msg)[0])			/* MN_SELECTED, WM_REDRAW, etc. */
#define	MsgSender(msg)	((msg)[1])			/* apid of message sender	*/
#define	MsgExtra(msg)		((msg)[2])			/* extra bytes in the pipe	*/
	
#define	MenTitle(msg)		((msg)[3])			/* for	MN_SELECTED		*/
#define	MenItem(msg)		((msg)[4])			/* for	MN_SELECTED		*/

#define	WinId(msg)		((msg)[3])			/* for	all WM_ messages	*/
#define	WinRect(msg)		(*(GRECT *)(&(msg)[4]))	/* WM_REDRAW,	WM_SIZED, WM_MOVED*/

#define	WinAction(msg)	((msg)[4])			/* for	WM_ARROWED, contains	*/
								/* WA_	number			*/
#define	WinSlider(msg)	((msg)[4])			/* WM_HSLID, WM_VSLID  	*/

#define	AccOpenId(msg)	((msg)[4])			/* AC_OPEN			*/
#define	AccCloseId(msg)	((msg)[3])			/* AC_CLOSE			*/
#define	CtlKey(msg)		((msg)[3])			/* XControl CT_KEY		*/

typedef	struct	sColorword
{
	unsigned cborder : 4;
	unsigned ctext   : 4;
	unsigned replace : 1;
	unsigned pattern : 3;
	unsigned cfill   : 4;
} Colorword;

typedef	struct	sObInfo
{
	UCHAR	   	letter;
	CHAR		border;
	Colorword	c;
} ObInfo;

typedef	struct	sWObInfo
{
	UCHAR	letter;
	CHAR	border;
	WORD	c;
} WObInfo;

typedef	struct	sIconInfo
{
	unsigned fcolor : 4;
	unsigned bcolor : 4;
	unsigned letter : 8;
} IconInfo;

#define	ObNIL			-1	/* not	an object */
#define	ObROOT			0	/* root object of tree */
#define	ObMAXLEN		81	/* max	string	length	for text fields */
#define	ObMAXDEPTH		8	/* max	depth of find	or draw */

/* Object types */
enum ObTypes
{
	ObBOX = 20,
	ObTEXT,
	ObBOXTEXT,
	ObIMAGE,
	ObUSERDEF,
	ObIBOX,
	ObBUTTON,
	ObBOXCHAR,
	ObSTRING,
	ObFTEXT,
	ObFBOXTEXT,
	ObICON,
	ObTITLE
};

/* Object flags */
#define	ObNONE			0x000U
#define	ObSELECTABLE		0x001U
#define	ObDEFAULT		0x002U
#define	ObEXIT			0x004U
#define	ObEDITABLE		0x008U
#define	ObRADIO 		0x010U
#define	ObLASTOB		0x020U
#define	ObTOUCHEXIT		0x040U
#define	ObHIDETREE		0x080U
#define	ObINDIRECT		0x100U
#define	ObFL3DIND		0x200U
#define	ObFL3DBAK		0x400U
#define	ObFL3DACT		0x600U
#define	ObFL3DMASK		0x600U
#define	ObFL3DNONE		0x000U
#define	ObSUBMENU		0x800U

#define	ObNORMAL		0x00U
#define	ObSELECTED		0x01U
#define	ObCROSSED		0x02U
#define	ObCHECKED		0x04U
#define	ObDISABLED		0x08U
#define	ObOUTLINED		0x10U
#define	ObSHADOWED		0x20U

enum ObColors
{
	ObWHITE = 0,
	ObBLACK,
	ObRED,
	ObGREEN,
	ObBLUE,
	ObCYAN,
	ObYELLOW,
	ObMAGENTA,
	ObLGRAY,
	ObGRAY,
	ObLRED,
	ObLGREEN,
	ObLBLUE,
	ObLCYAN,
	ObLYELLOW,
	ObLMAGENTA
};

/* TEDINFO fonts */
#define	TeGDOSPROP		0
#define	TeGDOSMONO		1
#define	TeGDOSBITM		2
#define	TeSYSTEMFONT		3
#define	TeSMALLFONT		5

/* TEDINFO justifications */
typedef	WORD TeJust;

enum TeJusts
{
	TeLEFT	= 0,
	TeRIGHT,
	TeCENTER
};

#define	ModeReplace		1
#define	ModeTransparent 	0

/* Object structure access macros
 * ----------------------------------------------------------------------
 * NOTE: These	macros	require an in-scope OBJECT *tree declaration.
 */
#define	ActiveTree( x	)	( tree	= x )

#define	ObNext(obj)		( tree[(obj)].ob_next )
#define	ObHead(obj)		( tree[(obj)].ob_head )
#define	ObTail(obj)		( tree[(obj)].ob_tail )
#define	ObType(obj)		( tree[(obj)].ob_type )
#define	ObFlags(obj)		( tree[(obj)].ob_flags )
#define	ObState(obj)		( tree[(obj)].ob_state )
#define	ObSpec(obj)		( tree[(obj)].ob_spec )

/* ObSpecs for	ObBOX,	ObIBOX, ObBOXCHAR */
#define	ObChar(obj)		( (*(ObInfo *)&ObSpec(obj)).letter	)
#define	ObBorder(obj)		( (*(ObInfo *)&ObSpec(obj)).border	)
#define	ObCBorder(obj)	( (*(ObInfo *)&ObSpec(obj)).c.cborder )
#define	ObCText(obj)		( (*(ObInfo *)&ObSpec(obj)).c.ctext )
#define	ObReplace(obj)	( (*(ObInfo *)&ObSpec(obj)).c.replace )
#define	ObPattern(obj)	( (*(ObInfo *)&ObSpec(obj)).c.pattern )
#define	ObCFill(obj)		( (*(ObInfo *)&ObSpec(obj)).c.cfill )
#define	ObColor(obj)		(  (*(WObInfo	*)&ObSpec(obj)).c )

/* TEDINFO access macros, for ObTEXT, ObBOXTEXT, ObFTEXT, ObFBOXTEXT */
#define	PTedinfo(obj)		( (TEDINFO *)ObSpec(obj) )
#define	TedText(obj)		( PTedinfo(obj)->te_ptext )
#define	TedTemplate(obj)	( PTedinfo(obj)->te_ptmplt )
#define	TedValid(obj)		( PTedinfo(obj)->te_pvalid )
#define	TedFont(obj)		( PTedinfo(obj)->te_font )
#define	TedJust(obj)		( PTedinfo(obj)->te_just )
#define	TedCBorder(obj) 	( (*(Colorword *)&PTedinfo(obj)->te_color).cborder )
#define	TedCText(obj)		( (*(Colorword *)&PTedinfo(obj)->te_color).ctext	)
#define	TedReplace(obj) 	( (*(Colorword *)&PTedinfo(obj)->te_color).replace )
#define	TedPattern(obj) 	( (*(Colorword *)&PTedinfo(obj)->te_color).pattern )
#define	TedCFill(obj)		( (*(Colorword *)&PTedinfo(obj)->te_color).cfill	)
#define	TedBorder(obj)	( PTedinfo(obj)->te_thickness )
#define	TedLen(obj)		( PTedinfo(obj)->te_txtlen )
#define	TedTempLen(obj) 	( PTedinfo(obj)->te_tmplen )

/* ICONBLK access for	ObICON	*/
#define	PIconblock(obj) 	( (ICONBLK *)ObSpec(obj) )
#define	IconMask(obj)		( PIconblock(obj)->ib_pmask	)
#define	IconData(obj)		( PIconblock(obj)->ib_pdata	)
#define	IconText(obj)		( PIconblock(obj)->ib_ptext	)
#define	IconFColor(obj) 	( (*(IconInfo	*)&PIconblock(obj)->ib_char).fcolor )
#define	IconBColor(obj) 	( (*(IconInfo	*)&PIconblock(obj)->ib_char).bcolor )
#define	IconChar(obj)		( (*(IconInfo	*)&PIconblock(obj)->ib_char).letter )
#define	IconXYChar(obj) 	( *(POINT *)&PIconblock(obj)->ib_xchar )
#define	IconRect(obj)		( *(GRECT *)&PIconblock(obj)->ib_xicon )
#define	IconTRect(obj)	( *(GRECT *)&PIconblock(obj)->ib_xtext )

/* BITBLK access for ObIMAGE	*/
#define	PBitblock(obj)	( (BITBLK *)ObSpec(obj) )
#define	ImageData(obj)	( PBitblock(obj)->bi_pdata )
#define	ImageWb(obj)		( PBitblock(obj)->bi_wb )
#define	ImageH(obj)		( PBitblock(obj)->bi_hl )
#define	ImageXY(obj)		( *(POINT *)&PBitblock(obj)->bi_x )
#define	ImageColor(obj) 	( PBitblock(obj)->bi_color )

/* String access for ObBUTTON, ObSTRING, ObTITLE */
#define	ObString(obj)		( (char *)ObSpec(obj) )

/* Object extents */
#define	ObX(obj)		( tree[(obj)].ob_x )
#define	ObY(obj)		( tree[(obj)].ob_y )
#define	ObXY(obj)		( *(POINT *)&tree[(obj)].ob_x )
#define	ObW(obj)		( tree[(obj)].ob_width )
#define	ObH(obj)		( tree[(obj)].ob_height )
#define	ObRect(obj)		( *(GRECT *)&tree[(obj)].ob_x )

/*
 * Object manipulation macros
 * ----------------------------------------------------------------------
 */

/*
 * rsrc_gaddr macros,	take an object index	and the address of a	pointer
 */
#define	GetTree(n,ptree)   	( rsrc_gaddr(R_TREE,(n),(void *)(ptree)) )
#define	GetString(n,pchar)	( rsrc_gaddr(R_STRING,(n),(void *)(pchar))	)
#define	GetAlert(n,pchar)	GetString(n,pchar)
#define	GetButton(n,pchar)	GetString(n,pchar)
#define	GetImage(n,pUWORD)	( rsrc_gaddr(R_FRIMG,n,pUWORD) )

/*
 * Object flags & states macros
 */
#define	IsSelectable(obj)	( ObFlags(obj) & ObSELECTABLE )
#define	IsDefault(obj)     	( ObFlags(obj) & ObDEFAULT )
#define	IsExit(obj)	     	( ObFlags(obj) & ObEXIT )
#define	IsEditable(obj)    	( ObFlags(obj) & ObEDITABLE	)
#define	IsRadio(obj)		( ObFlags(obj) & ObRADIO )
#define	IsRButton(obj)     	IsRadio(obj)
#define	IsLast(obj)	     	( ObFlags(obj) & ObLASTOB )
#define	IsLastob(obj)		IsLast(obj)
#define	IsTouchexit(obj)   	( ObFlags(obj) & ObTOUCHEXIT )
#define	IsHidden(obj)		( ObFlags(obj) & ObHIDETREE	)
#define	IsVisible(obj)     	( !IsHidden(obj) )
#define	IsIndirect(obj)    	( ObFlags(obj) & ObINDIRECT	)

#define	IsSelected(obj)    	( ObState(obj) & ObSELECTED	)
#define	IsCrossed(obj)     	( ObState(obj) & ObCROSSED )
#define	IsChecked(obj)     	( ObState(obj) & ObCHECKED )
#define	IsDisabled(obj)    	( ObState(obj) & ObDISABLED	)
#define	IsEnabled(obj)     	( !IsDisabled(obj) )
#define	IsOutlined(obj)    	( ObState(obj) & ObOUTLINED	)
#define	IsShadowed(obj)    	( ObState(obj) & ObSHADOWED	)
#define	IsTed(obj)	     	( (ObType(obj) == ObTEXT)	|| \
			     	  (ObType(obj) == ObBOXTEXT)|| \
			     	  (ObType(obj) == ObFTEXT)	|| \
			     	  (ObType(obj) == ObFBOXTEXT) )

#define	IsIndicator(obj)   	( ( ObFlags(obj) & ObFL3DMASK ) ==	ObFL3DIND )
#define	IsActivator(obj)   	( ( ObFlags(obj) & ObFL3DMASK ) ==	ObFL3DACT )
#define	IsBackground(obj)	( ( ObFlags(obj) & ObFL3DMASK ) ==	ObFL3DBAK )

/*
 * Object flags & states manipulation macros.
 *
 * NOTE: These	do not	affect	the visual appearance of the object;
 *	 state	changes will be reflected the next	time it is drawn.
 */
 
#define	MakeSelectable(obj)	( ObFlags(obj) |= ObSELECTABLE )
#define	MakeDefault(obj)   	( ObFlags(obj) |= ObDEFAULT	)
#define	MakeExit(obj)		( ObFlags(obj) |= ObEXIT )
#define	MakeEditable(obj)	( ObFlags(obj) |= ObEDITABLE )
#define	MakeRadio(obj)     	( ObFlags(obj) |= ObRADIO )
#define	MakeRButton(obj)   	MakeRadio(obj)
#define	MakeLast(obj)		( ObFlags(obj) |= ObLASTOB )
#define	MakeLastob(obj)    	MakeLast(obj)
#define	MakeTouchexit(obj)	( ObFlags(obj) |= ObTOUCHEXIT )
#define	HideObj(obj)		( ObFlags(obj) |= ObHIDETREE )
#define	MakeHidden(obj)    	HideObj(obj)
#define	MakeHidetree(obj)	HideObj(obj)
#define	MakeIndirect(obj)	( ObFlags(obj) |= ObINDIRECT )

#define	NoSelect(obj)		( ObFlags(obj) &= ~ObSELECTABLE )
#define	NoDefault(obj)     	( ObFlags(obj) &= ~ObDEFAULT )
#define	NoExit(obj)	     	( ObFlags(obj) &= ~ObEXIT )
#define	NoEdit(obj)	     	( ObFlags(obj) &= ~ObEDITABLE )
#define	NoRadio(obj)		( ObFlags(obj) &= ~ObRADIO )
#define	NoRButton(obj)     	NoRadio(obj)
#define	NoLast(obj)	     	( ObFlags(obj) &= ~ObLASTOB	)
#define	NoLastob(obj)		NoLast(obj)
#define	NoTouchexit(obj)   	( ObFlags(obj) &= ~ObTOUCHEXIT )
#define	ShowObj(obj)		( ObFlags(obj) &= ~ObHIDETREE )
#define	NoHidetree(obj)    	ShowObj(obj)
#define	NoIndirect(obj)    	( ObFlags(obj) &= ~ObINDIRECT )

#define	MakeActivator(obj)	( ObFlags(obj) |= ObFL3DACT	)
#define	MakeIndicator(obj)	( ObFlags(obj) |= ObFL3DIND	)
#define	MakeBackground(obj)	( ObFlags(obj) |= ObFL3DBAK	)
#define	NoActivator(obj)   	( ObFlags(obj) &= ~ObFL3DACT )
#define	NoIndicator(obj)   	( ObFlags(obj) &= ~ObFL3DIND )
#define	NoBackground(obj)	( ObFlags(obj) &= ~ObFL3DBAK )

#define	Select(obj)	     	( ObState(obj) |= ObSELECTED )
#define	Cross(obj)	     	( ObState(obj) |= ObCROSSED	)
#define	Check(obj)	     	( ObState(obj) |= ObCHECKED	)
#define	Disable(obj)		( ObState(obj) |= ObDISABLED )
#define	Outline(obj)		( ObState(obj) |= ObOUTLINED )
#define	Shadow(obj)	     	( ObState(obj) |= ObSHADOWED )

#define	Deselect(obj)		( ObState(obj) &= ~ObSELECTED )
#define	UnCross(obj)		( ObState(obj) &= ~ObCROSSED )
#define	UnCheck(obj)		( ObState(obj) &= ~ObCHECKED )
#define	Enable(obj)	     	( ObState(obj) &= ~ObDISABLED )
#define	NoOutline(obj)     	( ObState(obj) &= ~ObOUTLINED )
#define	NoShadow(obj)		( ObState(obj) &= ~ObSHADOWED )

#ifndef	DIAL
#define	DIAL(r) r.g_x	+ r.g_w/2, r.g_y + r.g_h/2,	0, 0, r.g_x, r.g_y, r.g_w, r.g_h
#endif

#ifndef	PELTS
#define	PELTS(r) &r.g_x, &r.g_y, &r.g_w, &r.g_h
#endif

/**************************************************************	VDI ***/

#ifdef __PUREC__

typedef struct
{
    int    contrl[15];
    int    intin[132];
    int    intout[140];
    int    ptsin[145];
    int    ptsout[145];
} VDIPARBLK;

typedef struct
{
    int    *contrl;
    int    *intin;
    int    *ptsin;
    int    *intout;
    int    *ptsout;
} VDIPB;

extern  VDIPARBLK _VDIParBlk;

#endif

/* For v_bez()	*/
#define	BEZ_POLYLINE		0x00
#define	BEZ_BEZIER		0x01
#define	BEZ_NODRAW		0x02

/* For v_bit_image() */
#define	SCALING_FRACTIONAL	0
#define	SCALING_INTEGER	1

#define	IMAGE_LEFT		0
#define	IMAGE_TOP		0
#define	IMAGE_CENTER		1
#define	IMAGE_RIGHT		2
#define	IMAGE_BOTTOM		2

/* For v_contourfill() */
#define	OTHER_COLOR		-1

/* For v_justified() */
#define	NOJUSTIFY		0
#define	JUSTIFY		1

/* For v_opnwk() */
#define	DEFAULT_PLOTTER	11
#define	DEFAULT_PRINTER	21
#define	METAFILE_DRIVER	31
#define	MEMORY_DRIVER		61

/* For v_show_c() */
#define	RESET_MOUSE		0
#define	NEST_MOUSE		1

/* For v_updwk() */
#define	SLM_OK			0x00
#define	SLM_ONERY		0x02
#define	SLM_NOTONER		0x03
#define	SLM_NOPAPER		0x05

/* For vq_color() */
#define	COLOR_REQUESTED	0
#define	COLOR_ACTUAL		1

/* For vq_extnd() */
#define	VQ_BASE		0
#define	VQ_EXTENDED		1

/* For vq_vgdos() */
#define	GDOS_NONE		0xfffffffe	/* no GDOS */
#define	GDOS_FSM		0x5f46534d	/* _FSM */
#define	GDOS_FNT		0x5f464e54	/* _FNT */
#define	GDOS_SPD		0x5f535044	/* _SPD (not actually a vq_gdos() return */

/* For vqin_mode() */
#define	LOCATOR		0
#define	VALUATOR		1
#define	CHOICE			2
#define	STRING			3

#define	REQUEST_MODE		1
#define	SAMPLE_MODE		2

/* For vqt_cachesize() */
#define	CACHE_CHAR		0
#define	CACHE_MISC		1

/* For vqt_devinfo() */
#define	DEV_MISSING		0
#define	DEV_INSTALLED		1

/* For vqt_name() */
#define	OUTLINE_FONT		1
#define	BITMAP_FONT		0

/* For vr_trnfm() */
#define	VDI_DEVICE		0
#define	VDI_STANDARD		1

/* For vro_cpyfm() */
#define	ALL_WHITE		0		/* bit	blt rules */
#define	S_AND_D		1
#define	S_AND_NOTD		2
#define	S_ONLY			3
#define	NOTS_AND_D		4
#define	D_ONLY			5
#define	S_XOR_D		6
#define	S_OR_D			7
#define	NOT_SORD		8
#define	NOT_SXORD		9
#define	NOT_D			10
#define	S_OR_NOTD		11
#define	NOT_S			12
#define	NOTS_OR_D		13
#define	NOT_SANDD		14
#define	ALL_BLACK		15

typedef	struct	fdbstr
{
	void *	fd_addr;
	WORD 	fd_w;
	WORD 	fd_h;
	WORD 	fd_wdwidth;
	WORD 	fd_stand;
	WORD 	fd_nplanes;
	WORD 	fd_r1;
	WORD 	fd_r2;
	WORD 	fd_r3;
} MFDB,	FDB;

/* For vs_clip() */
#define	CLIP_ON		1
#define	CLIP_OFF		0

/* For vsf_interior()	*/
#define	FIS_HOLLOW		0
#define	FIS_SOLID		1
#define	FIS_PATTERN		2
#define	FIS_HATCH		3
#define	FIS_USER		4

/* For vsf_style() */
#define	DOTS			3		/* fill patterns */
#define	GRID			6
#define	BRICKS			9
#define	WEAVE			16

/* For vsl_type() */
#define	SOLID			1		/* polyline line styles */
#define	LDASHED		2
#define	LONGDASH		LDASHED
#define	DOTTED			3
#define	DOT			DOTTED
#define	DASHDOT		4
#define	DASHED			5
#define	DASH			DASHED
#define	DASHDOTDOT		6
#define	DASH2DOT		DASHDOTDOT
#define	USERLINE		7

/* For vsl_ends() */
#define	SQUARE			0
#define	ARROWED		1
#define	ROUND			2

/* For vsm_type() */
#define	MRKR_DOT		1		/* Markers */
#define	MRKR_PLUS		2
#define	MRKR_ASTERISK		3
#define	MRKR_BOX		4
#define	MRKR_CROSS		5
#define	MRKR_DIAMOND		6

/* For vst_attributes() */
#define	THICKENED		0x0001	/* text effects */
#define	LIGHT			0x0002
#define	SKEWED			0x0004
#define	UNDERLINED		0x0008
#define	OUTLINE		0x0010
#define	SHADOW			0x0020

/* For vswr_mode() */
#define	MD_REPLACE		1
#define	MD_TRANS		2
#define	MD_XOR			3
#define	MD_ERASE		4

/* For vsc_form() */
#ifndef	_MFORM_T
#define	_MFORM_T
typedef	struct	mfstr
{
	WORD mf_xhot;
	WORD mf_yhot;
	WORD mf_nplanes;
	WORD mf_fg;
	WORD mf_bg;
	WORD mf_mask[16];
	WORD mf_data[16];
} MFORM;
#endif

/* For vsf_perimeter() */
#define	PERIMETER_ON		1
#define	PERIMETER_OFF		0

/* For vst_alignment() */
typedef	enum _halign { LEFT_HALIGN,	CENTER_HALIGN, RIGHT_HALIGN	} HALIGN;
typedef	enum _valign { BASE_VALIGN,	HALF_VALIGN, ASCENT_VALIGN,	BOTTOM_VALIGN, DESCENT_VALIGN, TOP_VALIGN	} VALIGN;

/* For vst_charmap() */
#define	MAP_ATARI		1
#define	MAP_BITSTREAM		0

/* For vst_error() */
#define	APP_ERROR		0
#define	SCREEN_ERROR		1
typedef	enum _gerror { NO_ERROR, CHAR_NOT_FOUND, FILE_READERR =	8,	
			 FILE_OPENERR, BAD_FORMAT, CACHE_FULL,
			 MISC_ERROR =	-1 } GDOS_ERROR;

/* For vst_kern() */
#define	PAIR_OFF	 	0
#define	PAIR_ON	 	1

#define	TRACKING_NONE		0
#define	TRACKING_NORMAL	1
#define	TRACKING_TIGHT 	2	
#define	TRACKING_VERYTIGHT	3

/* For vst_scratch() */
#define	SCRATCH_BOTH		0
#define	SCRATCH_BITMAP	1
#define	SCRATCH_NONE		2

/***************************************************** VDIWORK *****/

typedef	struct	vdiwk {
	WORD	handle, dev_id;  		/* Handle, & device ID opened */
	WORD	phys_handle			/* Added since last printing... */
	WORD	wchar,	hchar,	wbox, hbox;	/* Returned by graf_handle() */

	WORD	xres, yres;	      		/* Stuff returned by	v_opnvwk() */
	WORD	noscale;
	WORD	wpixel, hpixel;
	WORD	cheights;
	WORD	linetypes, linewidths;
	WORD	markertypes, markersizes;
	WORD	faces,	patterns, hatches, colors;
	WORD	ngdps;
	WORD	cangdps[10];
	WORD	gdpattr[10];
	WORD	cancolor, cantextrot;
	WORD	canfillarea, cancellarray;
	WORD	palette;
	WORD	locators, valuators;
	WORD	choicedevs, stringdevs;
	WORD	wstype;
	WORD	minwchar, minhchar;
	WORD	maxwchar, maxhchar;
	WORD	minwline;
	WORD	zero5;
	WORD	maxwline;
	WORD	zero7;
	WORD	minwmark, minhmark;
	WORD	maxwmark, maxhmark;

	WORD	screentype;		     	/* Stuff returned by	vq_extnd() */
	WORD	bgcolors, textfx;
	WORD	canscale;
	WORD	planes, lut;
	WORD	rops;
	WORD	cancontourfill, textrot;
	WORD	writemodes;
	WORD	inputmodes;
	WORD	textalign, inking, rubberbanding;
	WORD	maxvertices, maxintin;
	WORD	mousebuttons;
	WORD	widestyles, widemodes;
	WORD	reserved[40];
} VDI_Workstation;

/* Array indices for cangdp[] and gdpattr[] members of structure */

enum WsGDPs { gdpBAR,	gdpARC, gdpPIE,
	      gdpCIRCLE, gdpELLIPSE, gdpELLARC,
	      gdpELLPIE, gdpRRECT, gdpFRRECT, gdpTEXT };


/* values for gdpattr[] member */

enum WsAttributes {attrPLINE, attrPMARKER,	attrTEXT,
		    attrFILL,	attrNONE };

/* Type	flags for wstype member */

enum WsTypes {	wsOUTPUT, wsINPUT, wsINOUT,
		rsRESVD, wsMETAFILE };


/* Flag	values	for textrot member */

enum WsTextRot	{ TrNONE, Tr90, TrANY };


/**************************************************** XCONTROL ********/

typedef	struct
{
	WORD x;
	WORD y;
	WORD buttons;
	WORD kstate;
} MRETS;

typedef	struct
{
	WORD handle;
	WORD booting;
	WORD version;
	WORD SkipRshFix;

	char *reserve1;
	char *reserve2;

	void (* STDARGS rsh_fix)P_((WORD,WORD,WORD,WORD,OBJECT *,TEDINFO *,
	  char	*,ICONBLK *,BITBLK *,LONG *,LONG *,LONG *,void *));
	void (* STDARGS rsh_obfix)P_((OBJECT *,WORD));
	WORD (* STDARGS Popup)P_((char *[],WORD,WORD,WORD,GRECT *, GRECT *));
	void (* STDARGS Sl_size)P_((OBJECT *,WORD,WORD,WORD,WORD,WORD,WORD));
	void (* STDARGS Sl_x)P_((OBJECT *,WORD,WORD,WORD,WORD,WORD,void (* SAVEDS)(void)));
	void (* STDARGS Sl_y)P_((OBJECT *,WORD,WORD,WORD,WORD,WORD,void (* SAVEDS)(void)));
	void (* STDARGS Sl_arrow)P_((OBJECT *,WORD,WORD,WORD,WORD,WORD,WORD,WORD *,WORD,void (* SAVEDS)(void)));
	void (* STDARGS Sl_dragx)P_((OBJECT *,WORD,WORD,WORD,WORD,WORD *,void (* SAVEDS)(void)));
	void (* STDARGS Sl_dragy)P_((OBJECT *,WORD,WORD,WORD,WORD,WORD *,void (* SAVEDS)(void)));
	WORD (* STDARGS Xform_do)P_((OBJECT *,WORD,WORD *));
	GRECT *(* STDARGS GetFirstRect)P_((GRECT *));
	GRECT *(* STDARGS GetNextRext)P_((void));
	void (* STDARGS Set_Evnt_Mask)P_((WORD,MOBLK *,MOBLK *,LONG));
#define	SAVE_DEFAULTS		0
#define	MEM_ERR		1
#define	FILE_ERR		2
#define	FILE_NOT_FOUND	3
	WORD (* STDARGS XGen_Alert)P_((WORD));
	WORD (* STDARGS CPX_Save)P_((void *,LONG));
	void *(* STDARGS Get_Buffer)P_((void));
	WORD (* STDARGS getcookie)P_((LONG cookie,LONG *p_value));
	WORD Country_Code;
#define	MFSAVE			1
#define	MFRESTORE		0
	void (* STDARGS MFsave)P_((WORD saveit,MFORM *mf));
} XCPB;

typedef	struct
{
	WORD (* SAVEDS STDARGS cpx_call)P_((GRECT *));
	void (* SAVEDS STDARGS cpx_draw)P_((GRECT *));
	void (* SAVEDS STDARGS cpx_wmove)P_((GRECT *));
	void (* SAVEDS STDARGS cpx_timer)P_((WORD *));
	void (* SAVEDS STDARGS cpx_key)P_((WORD,WORD,WORD *));
	void (* SAVEDS STDARGS cpx_button)P_((MRETS *,WORD,WORD *));
	void (* SAVEDS STDARGS cpx_m1)P_((MRETS *,WORD *));
	void (* SAVEDS STDARGS cpx_m2)P_((MRETS *mrets,WORD *));
	WORD (* SAVEDS STDARGS cpx_hook)P_((WORD,WORD *,MRETS *,WORD *,WORD *));
	void (* SAVEDS STDARGS cpx_close)P_((WORD));
} CPXINFO;

/*
 * CPX header
 */
typedef	struct	_cpxhead
{
#define	CPXMAGIC		100	/* magic number */
	UWORD	magic;		   
#define	CPX_RESIDENT		4 	/* RAM	resident flag	*/
#define	CPX_BOOTINIT		2 	/* boot initialization flag	*/
#define	CPX_SETONLY		1 	/* set	only CPX flag	*/
	WORD 	flags;
	LONG 	cpx_id;	     	/* CPX	ID value */
	UWORD cpx_version;		/* CPX	version number */
	char 	i_text[14];		/* icon text */
	UWORD 	sm_icon[48];		/* icon bitmap - 32x24 pixels */
	UWORD 	i_color;	     	/* icon colour */

	char 	title[18];		/* title for CPX entry */
	UWORD 	t_color;	     	/* tedinfo field for	colour	*/
	char 	buffer[64];		/* buffer for	RAM storage */

	char 	reserved[306];     	/* reserved for expansion */
} CPXHEAD;

/*************************************************************************/
/* IKBD	USA Key Codes	(may be different with foreign keyboards)		  */
/* From	a collection assembled by Tyson Gill.		 		  */
/*************************************************************************/

/* named keys with combinations */
#define	KEY_BACKSPACE		0x0E08		/* Backspace */
#define	KEY_CLR 		0x4737		/* Clr	(also SHIFT_HOME) */
#define	KEY_DELETE 		0x537F		/* Delete  */
#define	SHIFT_DELETE		0x532E
#define	KEY_ENTER		0x720D		/* Enter */
#define	KEY_ESCAPE 		0x011B		/* Esc	*/
#define	KEY_HOME 		0x4700		/* Home */
#define	SHIFT_HOME 		0x4737		/* also KEY_CLR */
#define	CNTRL_HOME 		0x7700
#define	KEY_INSERT		0x5200		/* Insert */
#define	SHIFT_INSERT 		0x5230
#define	KEY_RETURN 		0x1C0D		/* Return */
#define	CNTRL_RETURN 		0x1C0A
#define	KEY_TAB 		0x0F09		/* Tab	*/
#define	KEY_UNDO	 	0x6100		/* Undo */
#define	KEY_HELP 		0x6200		/* Help */

/* cursor keys	*/
#define	KEY_LARROW 		0x4B00
#define	KEY_RARROW 		0x4D00
#define	KEY_UARROW 		0x4800
#define	KEY_DARROW 		0x5000
#define	SHIFT_LARROW 		0x4B34
#define	CNTRL_LARROW 		0x7300
#define	SHIFT_RARROW 		0x4D36
#define	CNTRL_RARROW 		0x7400
#define	SHIFT_UARROW 		0x4838
#define	SHIFT_DARROW 		0x5032
/* Note	that there are no defined Control-Up or Control-Down codes */

/* non-alpha keys with combinations	*/
#define	KEY_ACCENT 		0x2960		/* ` (below tilde) */
#define	KEY_AMPERSAND		0x0826		/* & */
#define	KEY_APOSTROPHE 	0x2827		/* ' (below quotation mark)	*/
#define	KEY_ASTERISK 		0x092A		/* * */
#define	KEY_AT			0x0340		/* @ */
#define	KEY_CARET 		0x075E		/* ^ */
#define	KEY_COLON 		0x273A		/* : */
#define	KEY_COMMA 		0x332C		/* , */
#define	KEY_DOLLAR 		0x0524		/* $ */
#define	KEY_EQUALS 		0x0D3D		/* = */
#define	ALT_EQUALS 		0x8300
#define	KEY_EXCLAMATION 	0x0221		/* ! */
#define	KEY_MINUS 		0x0C2D		/* - */
#define	ALT_MINUS 		0x8200
#define	CNTRL_MINUS	 	0x0C1F
#define	KEY_PERCENT		0x0625		/* % */
#define	KEY_PERIOD 		0x342E		/* . */
#define	KEY_PLUS 		0x0D2B		/* + */
#define	KEY_POUNDS 		0x0423		/* # */
#define	KEY_QUESTION 		0x353F		/* ? */
#define	KEY_QUOTATION		0x2822		/* " */
#define	KEY_SEMICOLON		0x273B		/* ; */
#define	KEY_SPACE 		0x3920		/*   */
#define	KEY_TILDE 		0x297E		/* ~ */
#define	KEY_ULINE 		0x0C5F		/* _ */
#define	KEY_VLINE 		0x2B7C		/* | */

/* Brackets with combinations */
#define	KEY_L_ANGLE 		0x333C		/* < */
#define	KEY_R_ANGLE 		0x343E		/* > */
#define	KEY_L_BRACKET		0x1A7B		/* { */
#define	KEY_R_BRACKET		0x1B7D		/* } */
#define	KEY_L_PAREN 		0x0A28		/* ( */
#define	KEY_R_PAREN 		0x0B29		/* ) */
#define	KEY_SLASH 		0x352F		/* / */
#define	KEY_BACKSLASH		0x2B5C		/* \ */
#define	CNTRL_BACKSLASH 	0x2B1C
#define	KEY_L_SQUARE 		0x1A5B		/* [ */
#define	CNTRL_L_SQUARE 	0x1A1B
#define	KEY_R_SQUARE 		0x1B5D		/* ] */
#define	CNTRL_R_SQUARE 	0x1B1D

/* Number keys	*/
#define	KEY_0 			0x0B30
#define	KEY_1 			0x0231
#define	KEY_2 			0x0332
#define	KEY_3 			0x0433
#define	KEY_4 			0x0534
#define	KEY_5 			0x0635
#define	KEY_6 			0x0736
#define	KEY_7 			0x0837
#define	KEY_8 			0x0938
#define	KEY_9 			0x0A39

/* Numeric keypad */
#define	KEYPAD_MINUS 		0x4A2B
#define	KEYPAD_PLUS 		0x4E2B

/* Upper case letters	*/
#define	KEY_A 			0x1E41
#define	KEY_B 			0x3042
#define	KEY_C 			0x2E43
#define	KEY_D 			0x2044
#define	KEY_E 			0x1245
#define	KEY_F 			0x2146
#define	KEY_G 			0x2247
#define	KEY_H 			0x2348
#define	KEY_I 			0x1749
#define	KEY_J 			0x244A
#define	KEY_K 			0x254B
#define	KEY_L 			0x264C
#define	KEY_M 			0x324D
#define	KEY_N 			0x314E
#define	KEY_O 			0x184F
#define	KEY_P 			0x1950
#define	KEY_Q 			0x1051
#define	KEY_R 			0x1352
#define	KEY_S 			0x1F53
#define	KEY_T 			0x1454
#define	KEY_U 			0x1655
#define	KEY_V 			0x2F56
#define	KEY_W 			0x1157
#define	KEY_X 			0x2D58
#define	KEY_Y 			0x1559
#define	KEY_Z 			0x2C5A

/* Lower case letters	*/
#define	KEY_a 			0x1E61
#define	KEY_b 			0x3062
#define	KEY_c 			0x2E63
#define	KEY_d 			0x2064
#define	KEY_e 			0x1265
#define	KEY_f 			0x2166
#define	KEY_g 			0x2267
#define	KEY_h 			0x2368
#define	KEY_i 			0x1769
#define	KEY_j 			0x246A
#define	KEY_k 			0x256B
#define	KEY_l 			0x266C
#define	KEY_m 			0x326D
#define	KEY_n 			0x316E
#define	KEY_o 			0x186F
#define	KEY_p 			0x1970
#define	KEY_q 			0x1071
#define	KEY_r 			0x1372
#define	KEY_s 			0x1F73
#define	KEY_t 			0x1474
#define	KEY_u 			0x1675
#define	KEY_v 			0x2F76
#define	KEY_w 			0x1177
#define	KEY_x 			0x2D78
#define	KEY_y 			0x1579
#define	KEY_z 			0x2C7A

/* Control combinations */
#define	CNTRL_2 		0x0300
#define	CNTRL_6 		0x071E
#define	CNTRL_A 		0x1E01
#define	CNTRL_B 		0x3002
#define	CNTRL_C 		0x2E03
#define	CNTRL_D 		0x2004
#define	CNTRL_E 		0x1205
#define	CNTRL_F 		0x2106
#define	CNTRL_G 		0x2207
#define	CNTRL_H 		0x2308
#define	CNTRL_I 		0x1709
#define	CNTRL_J 		0x240A
#define	CNTRL_K 		0x250B
#define	CNTRL_L 		0x260C
#define	CNTRL_M 		0x320D
#define	CNTRL_N 		0x310E
#define	CNTRL_O 		0x180F
#define	CNTRL_P 		0x1910
#define	CNTRL_Q 		0x1011
#define	CNTRL_R 		0x1312
#define	CNTRL_S 		0x1F13
#define	CNTRL_T 		0x1414
#define	CNTRL_U 		0x1615
#define	CNTRL_V 		0x2F16
#define	CNTRL_W 		0x1117
#define	CNTRL_X 		0x2D18
#define	CNTRL_Y 		0x1519
#define	CNTRL_Z 		0x2C1A

/* Alternate combinations */
#define	ALT_0 			0x8100
#define	ALT_1 			0x7800
#define	ALT_2 			0x7900
#define	ALT_3 			0x7A00
#define	ALT_4 			0x7B00
#define	ALT_5 			0x7C00
#define	ALT_6 			0x7D00
#define	ALT_7 			0x7E00
#define	ALT_8 			0x7F00
#define	ALT_9 			0x8000
#define	ALT_A 			0x1E00
#define	ALT_B 			0x3000
#define	ALT_C 			0x2E00
#define	ALT_D 			0x2000
#define	ALT_E 			0x1200
#define	ALT_F 			0x2100
#define	ALT_G 			0x2200
#define	ALT_H 			0x2300
#define	ALT_I 			0x1700
#define	ALT_J 			0x2400
#define	ALT_K 			0x2500
#define	ALT_L 			0x2600
#define	ALT_M 			0x3200
#define	ALT_N 			0x3100
#define	ALT_O 			0x1800
#define	ALT_P 			0x1900
#define	ALT_Q 			0x1000
#define	ALT_R 			0x1300
#define	ALT_S 			0x1F00
#define	ALT_T 			0x1400
#define	ALT_U 			0x1600
#define	ALT_V 			0x2F00
#define	ALT_W 			0x1100
#define	ALT_X 			0x2D00
#define	ALT_Y 			0x1500
#define	ALT_Z 			0x2C00

/* Function keys */
#define	FKEY_1			0x3B00
#define	FKEY_2			0x3C00
#define	FKEY_3			0x3D00
#define	FKEY_4			0x3E00
#define	FKEY_5			0x3F00
#define	FKEY_6			0x4000
#define	FKEY_7			0x4100
#define	FKEY_8			0x4200
#define	FKEY_9			0x4300
#define	FKEY_10		0x4400
#define	SHIFT_F1 		0x5400
#define	SHIFT_F2 		0x5500
#define	SHIFT_F3 		0x5600
#define	SHIFT_F4 		0x5700
#define	SHIFT_F5 		0x5800
#define	SHIFT_F6 		0x5900
#define	SHIFT_F7 		0x5A00
#define	SHIFT_F8 		0x5B00
#define	SHIFT_F9 		0x5C00
#define	SHIFT_F10		0x5D00

/********************************************** System Variables *****/

/* Processor state and post mortem dump area */

#define	PROC_LIVES_MAGIC 	0x12345678L	/* proc_lives	if dump is valid */
#define	_proc_lives		((ULONG *) 0x380L)
struct __post_mortem_dump
{
	ULONG	d0, d1, d2, d3, d4, d5, d6,	d7;
	void *	a0, a1, a2, a3, a4, a5, a6,	a7; 	/* a7 == ssp */
	void *	c;			    	/* first byte	is exception #   */
	void *	usp;			    
	UWORD	stk[16];			/* sixteen words of super stack */
};

#define	proc_post_mortem_dump_p	((struct __post_mortem_dump	*) 0x384L)
#define	proc_dregs	 		(&proc_post_mortem_dump_p->d0)
#define	proc_aregs	 		(&proc_post_mortem_dump_p->a0)
#define	proc_pc	 		(proc_post_mortem_dump_p->pc)
#define	proc_usp	 		(proc_post_mortem_dump_p->usp)
#define	proc_utk	 		(proc_post_mortem_dump_p->stk)

/* timer, crit	error and process termination handoff vectors */
#define	_etv_timer	 		(((void (**)()) 0x400L))
#define	_etv_critic	 		(((void (**)()) 0x404L))
#define	_etv_term	 		(((void (**)()) 0x408L))

/* memory controller */
#define	MEMVALID_MAGIC	0x752019F3L		/* once memory is sized */
#define	_memvalid		(((ULONG *) 0x420L))
#define	_memcntlr		(((UCHAR *) 0x424L))	/* 0 =	128K, 4 = 512K 0 = 256k(2banks) 5 = 1M */

/* reset vector, jump	through resvector if	resvalid on reset */
#define	RESVALID_MAGIC	0x31415926L
#define	_resvalid		((ULONG *) 0x426L)
#define	_resvector		((void	(**)()) 0x42aL)

/* mem */
#define	_phystop		(((ULONG *) 0x42eL))	/* physical top of ram */
#define	_membot		(((ULONG *) 0x432L))	/* bottom of avail	  */
#define	_memtop		(((ULONG *) 0x436L))	/* top	   of avail	  */
#define	MEMVAL2_MAGIC		0x237698AAL 		/* after suc.	coldstart && memvalid */
#define	_memval2		(((ULONG *) 0x43aL))	

/* floppy */
#define	_flock			(((WORD *) 0x43eL)) 	/* lock	usage of DMA	 chip 	*/
#define	_seekrate		(((WORD *) 0x440L)) 	/* 0=6ms 1=12ms 2=2ms	3=3ms 	*/
#define	_timr_ms		(((WORD *) 0x442L)) 	/* timer calib	== 20ms      	*/
#define	_fverify		(((WORD *) 0x444L)) 	/* write verify flag	  		*/
#define	_bootdev		(((WORD *) 0x446L))

/* video */
#define	_palmode		(((WORD *) 0x448L)) 	/* PAL	video mode flag	  	*/
#define	_defshiftmd		(((UCHAR *) 0x44aL))	/* default video rez	  	  	*/
#define	_sshiftmd		(((WORD *) 0x44cL))	/* shadow of hdwr. shiftmd reg	*/
 						     	/* 0=Lo 1=med	2=Hi rez	  	*/
#define	_v_bas_ad		(((void *) 0x44eL)) 	/* screen mem	base		  	*/
#define	_vblsem		((WORD	*) 0x452L)) 	/* vbl	semaphore		  	*/
#define	_nvbls			(((WORD *) 0x454L))	/* # of vbl entries def. ==	8 	*/
#define	_vblqueue		(((void (***)()) 0x456L)) 	/* vbl	queue pointer	     	*/
#define	_colorptr		(((WORD **) 0x45aL))	/* pal. on next vblank if!NULL	*/
#define	_vbclock		(((ULONG *) 0x462L))	/* vbi	counter      			*/
#define	_frclock    		(((ULONG	*) 0x466L))	/* #vbi not vblsem'ed  	*/

#define	_hz_200		((ULONG *) 0x4baL)

#define	_conterm		(*((UCHAR *) 0x484L))
#define	_savptr		((LONG	*) 0x4A2L)
#define	_nflops		((WORD	*) 0x4A6L)
#define	_sysbase		((OSHEADER **) 0x4F2L)
#define	GetROMSysbase()	((*_sysbase)->os_beg)
#define	_shell_p		((LONG	*) 0x4F6L)

typedef	struct	{
	WORD	puns;
	char	v_p_un[16];
	LONG	pstart[16];
	WORD	bpbs[1];   	/* really 16 BPB's (bios parameter	block)	*/
} HDINFO;

#define	_pun_ptr		((HDINFO *) 0x516L)
#define	_p_cookies		((LONG	**) 0x5A0L)

#endif
