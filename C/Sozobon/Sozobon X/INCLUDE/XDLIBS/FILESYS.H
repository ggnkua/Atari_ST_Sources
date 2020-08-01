/* 
 * @(#) filesys.h for SozobonX XdLibs
 * 
 * based on file.h/filesys.h from MiNT distrib
 * see following note
 */

/*
 * NOTE: This file only works if sizeof(int) == 2!
 * UNLESS: you have an ANSI compiler and use prototypes
 *
 * Copyright 1991,1992 Eric R. Smith. This file may be re-distributed
 * as long as this notice remains intact.
 */

#ifndef _filesys_h
#define _filesys_h

#ifndef P_
# ifdef __STDC__
#  define P_(x) x
# else
#  define P_(x) ()
# endif
#endif

#ifdef _SHORTINT
#define _wORD int
#endif

#ifndef _wORD
#ifdef __MSHORT__		/* 16 bit integers? */
#define _wORD int
#else
#define _wORD short
#endif
#endif

#define TOS_NAMELEN 13

struct filesys;		/* forward declaration */
struct devdrv;		/* ditto */
struct timeout;		/* and ditto */

typedef struct f_cookie {
	struct filesys *fs;	/* filesystem that knows about this cookie */
	unsigned short	dev;		/* device info (e.g. Rwabs device number) */
	unsigned short	aux;		/* extra data that the file system may want */
	long	index;		/* this+dev uniquely identifies a file */
} fcookie;


typedef struct dtabuf {
	short	index;		/* index into arrays in the PROC struct */
	long	magic;
#define SVALID	0x1234fedcL	/* magic for a valid search */
#define EVALID	0x5678ba90L	/* magic for an exhausted search */

	char	dta_pat[TOS_NAMELEN+1];	/* pointer to pattern, if necessary */
	char	dta_sattrib;	/* attributes being searched for */
/* this stuff is returned to the user */
	char	dta_attrib;
	short	dta_time;
	short	dta_date;
	long	dta_size;
	char	dta_name[TOS_NAMELEN+1];
} DTABUF;

/* structure for opendir/readdir/closedir */
typedef struct dirstruct {
	fcookie fc;		/* cookie for this directory */
	unsigned short	index;		/* index of the current entry */
	unsigned short	flags;		/* flags (e.g. tos or not) */
#define TOS_SEARCH	0x01
	char	fsstuff[60];	/* anything else the file system wants */
							/* NOTE: this must be at least 45 bytes */
	struct dirstruct *next;	/* linked together so we can close them
							   on process termination */
} DIR;

#ifndef _file_h
/* structure for getxattr */
typedef struct xattr {
	unsigned short	mode;
/* file types */
#define S_IFMT	0170000		/* mask to select file type */
#define S_IFCHR	0020000		/* BIOS special file */
#define S_IFDIR	0040000		/* directory file */
#define S_IFREG 0100000		/* regular file */
#define S_IFIFO 0120000		/* FIFO */
#define S_IMEM	0140000		/* memory region or process */
#define S_IFLNK	0160000		/* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID	04000
#define S_ISGID 02000
#define S_ISVTX	01000

/* file access modes for user, group, and other*/
#define S_IRUSR	0400
#define S_IWUSR 0200
#define S_IXUSR 0100
#define S_IRGRP 0040
#define S_IWGRP	0020
#define S_IXGRP	0010
#define S_IROTH	0004
#define S_IWOTH	0002
#define S_IXOTH	0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE	(0666)
	long	index;
	unsigned short	dev;
	unsigned short	reserved1;
	unsigned short	nlink;
	unsigned short	uid;
	unsigned short	gid;
	long	size;
	long	blksize, nblocks;
	unsigned short	mtime, mdate;
	unsigned short	atime, adate;
	unsigned short	ctime, cdate;
	unsigned short	attr;
	short	reserved2;
	long	reserved3[2];
} XATTR;
#endif

typedef struct fileptr {
	short	links;	    /* number of copies of this descriptor */
	unsigned short	flags;	    /* file open mode and other file flags */
	long	pos;	    /* position in file */
	long	devinfo;    /* device driver specific info */
	fcookie	fc;	    /* file system cookie for this file */
	struct devdrv *dev; /* device driver that knows how to deal with this */
	struct fileptr *next; /* link to next fileptr for this file */
} FILEPTR;

#ifndef _file_h
/* lock structure */
struct flock {
	short l_type;			/* type of lock */
#define F_RDLCK		O_RDONLY
#define F_WRLCK		O_WRONLY
#define F_UNLCK		3
	short l_whence;			/* SEEK_SET, SEEK_CUR, SEEK_END */
	long l_start;			/* start of locked region */
	long l_len;			/* length of locked region */
	short l_pid;			/* pid of locking process
						(F_GETLK only) */
};
#endif

/* LOCK structure used by the kernel internally */

typedef struct ilock {
	struct flock l;
	struct ilock *next;
	long  reserved[4];
} LOCK;

typedef struct devdrv {
	long (*open)	P_((FILEPTR *f));
	long (*write)	P_((FILEPTR *f, char *buf, long bytes));
	long (*read)	P_((FILEPTR *f, char *buf, long bytes));
	long (*lseek)	P_((FILEPTR *f, long where, _wORD whence));
	long (*ioctl)	P_((FILEPTR *f, _wORD mode, void *buf));
	long (*datime)	P_((FILEPTR *f, _wORD *timeptr, _wORD rwflag));
	long (*close)	P_((FILEPTR *f, _wORD pid));
	long (*select)	P_((FILEPTR *f, long proc, _wORD mode));
	void (*unselect) P_((FILEPTR *f, long proc, _wORD mode));
/* extensions, check dev_descr.drvsize (size of DEVDRV struct) before calling:
 * fast RAW tty byte io  */
	long (*writeb)	P_((FILEPTR *f, const char *buf, long bytes));
	long (*readb)	P_((FILEPTR *f, char *buf, long bytes));
/* what about: scatter/gather io for DMA devices...
 *	long ARGS_ON_STACK (*writev)	P_((FILEPTR *f, const struct iovec *iov, long cnt));
 *	long ARGS_ON_STACK (*readv)	P_((FILEPTR *f, const struct iovec *iov, long cnt));
 */
} DEVDRV;

typedef struct filesys {
	struct	filesys	*next;	/* link to next file system on chain */
	long	fsflags;
#define FS_KNOPARSE	0x01	/* kernel shouldn't do parsing */
#define FS_CASESENSITIVE	0x02	/* file names are case sensitive */
#define FS_NOXBIT	0x04	/* if a file can be read, it can be executed */
#define	FS_LONGPATH	0x08	/* file system understands "size" argument to
							   "getname" */

	long	(*root) P_((_wORD drv, fcookie *fc));
	long	(*lookup) P_((fcookie *dir, char *name, fcookie *fc));
	long	(*creat) P_((fcookie *dir, char *name, unsigned _wORD mode,
				_wORD attrib, fcookie *fc));
	DEVDRV *(*getdev) P_((fcookie *fc, long *devspecial));
	long	(*getxattr) P_((fcookie *fc, XATTR *xattr));
	long	(*chattr) P_((fcookie *fc, _wORD attr));
	long	(*chown) P_((fcookie *fc, _wORD uid, _wORD gid));
	long	(*chmode) P_((fcookie *fc, unsigned _wORD mode));
	long	(*mkdir) P_((fcookie *dir, char *name, unsigned _wORD mode));
	long	(*rmdir) P_((fcookie *dir, char *name));
	long	(*remove) P_((fcookie *dir, char *name));
	long	(*getname) P_((fcookie *relto, fcookie *dir, char *pathname));
	long	(*rename) P_((fcookie *olddir, char *oldname,
			    fcookie *newdir, char *newname));
	long	(*opendir) P_((DIR *dirh, _wORD tosflag));
	long	(*readdir) P_((DIR *dirh, char *nm, _wORD nmlen, fcookie *fc));
	long	(*rewinddir) P_((DIR *dirh));
	long	(*closedir) P_((DIR *dirh));
	long	(*pathconf) P_((fcookie *dir, _wORD which));
	long	(*dfree) P_((fcookie *dir, long *buf));
	long	(*writelabel) P_((fcookie *dir, char *name));
	long	(*readlabel) P_((fcookie *dir, char *name, _wORD namelen));
	long	(*symlink) P_((fcookie *dir, char *name, char *to));
	long	(*readlink) P_((fcookie *dir, char *buf, _wORD len));
	long	(*hardlink) P_((fcookie *fromdir, char *fromname,
				fcookie *todir, char *toname));
	long	(*fscntl) P_((fcookie *dir, char *name, _wORD cmd, long arg));
	long	(*dskchng) P_((_wORD drv));
	long	(*release) P_((fcookie *));
	long	(*dupcookie) P_((fcookie *new, fcookie *old));
} FILESYS;

/*
 * this is the structure passed to loaded file systems to tell them
 * about the kernel
 */
/* structure for timeouts, the `void*'s are really `struct proc *'s */
typedef struct timeout {
	struct timeout	*next;
	void	*proc;
	long	when;
	void	(*func) (void * any); /* function to call at timeout */
	short	flags;
} TIMEOUT;

typedef long (*_LongFunc)();

struct kerinfo {
	short	maj_version;	/* kernel version number */
	short	min_version;	/* minor kernel version number */
	unsigned short default_mode;	/* default file access mode */
	short	reserved1;	/* room for expansion */

/* OS functions */
	_LongFunc *bios_tab; 	/* pointer to the BIOS entry points */
	_LongFunc *dos_tab;	/* pointer to the GEMDOS entry points */

/* media change vector */
	void	(*drvchng) P_((short));

/* Debugging stuff */
	void	(*trace) P_((char *, ...));
	void	(*debug) P_((char *, ...));
	void	(*alert) P_((char *, ...));
	void	(*fatal) P_((char *, ...));

/* memory allocation functions */
	void *	(*kmalloc) P_((long));
	void	(*kfree) P_((void *));
	void *	(*umalloc) P_((long));
	void	(*ufree) P_((void *));

/* utility functions for string manipulation */
	short	(*strnicmp) P_((char *, char *, _wORD));
	short	(*stricmp) P_((char *, char *));
	char *	(*strlwr) P_((char *));
	char *	(*strupr) P_((char *));
	short	(*sprintf) P_((char *, char *, ...));

/* utility functions for manipulating time */
	void	(*millis_time) P_((unsigned long, _wORD *));
	long	(*unixtim) P_((unsigned _wORD, unsigned _wORD));
	long	(*dostim) P_((long));

/* utility functions for dealing with pauses */
	void	(*nap) P_((unsigned short));
	void	(*sleep) P_((_wORD que, long cond));
	void	(*wake) P_((_wORD que, long cond));
	void	(*wakeselect) P_((long param));

/* file system utility functions */
	short	(*denyshare) P_((FILEPTR *, FILEPTR *));
	LOCK *	(*denylock) P_((LOCK *, LOCK *));

/* functions for adding/cancelling timeouts */
	TIMEOUT * (*addtimeout) P_((long, void (*)()));
	void	(*canceltimeout) P_((TIMEOUT *));
	TIMEOUT * (*addroottimeout) P_((long, void (*)(), short));
	void	(*cancelroottimeout) P_((TIMEOUT *));

/* miscellaneous other things */
	long	(*ikill) P_((short, short));
	void	(*iwake) P_((short, long, short));

/* reserved for future use */
	long	res2[3];
};

#ifndef _file_h
/* flags for open() modes */
#define O_RWMODE  	0x03	/* isolates file read/write mode */
#	define O_RDONLY	0x00
#	define O_WRONLY	0x01
#	define O_RDWR	0x02
#	define O_EXEC	0x03	/* execute file; used by kernel only */

#define O_APPEND	0x08	/* all writes go to end of file */

#define O_SHMODE	0x70	/* isolates file sharing mode */
#	define O_COMPAT	0x00	/* compatibility mode */
#	define O_DENYRW	0x10	/* deny both read and write access */
#	define O_DENYW	0x20	/* deny write access to others */
#	define O_DENYR	0x30	/* deny read access to others */
#	define O_DENYNONE 0x40	/* don't deny any access to others */

#define O_NOINHERIT	0x80	/* children don't get this file descriptor */

#define O_NDELAY	0x100	/* don't block for i/o on this file */
#define O_CREAT		0x200	/* create file if it doesn't exist */
#define O_TRUNC		0x400	/* truncate file to 0 bytes if it does exist */
#define O_EXCL		0x800	/* fail open if file exists */

#define O_USER		0x0fff	/* isolates user-settable flag bits */

#define O_GLOBAL	0x1000	/* for Fopen: opens a global file handle */

/* kernel mode bits -- the user can't set these! */
#define O_TTY		0x2000	/* FILEPTR refers to a terminal */
#define O_HEAD		0x4000	/* FILEPTR is the master side of a fifo */
#define O_LOCK		0x8000	/* FILEPTR has had locking Fcntl's performed */


/* GEMDOS file attributes */
#endif
/* macros to be applied to FILEPTRS to determine their type */
#define is_terminal(f) (f->flags & O_TTY)

#ifndef _file_h
/* lseek() origins */
#define	SEEK_SET	0		/* from beginning of file */
#define	SEEK_CUR	1		/* from current location */
#define	SEEK_END	2		/* from end of file */

/* The requests for Dpathconf() */
#define DP_IOPEN	0	/* internal limit on # of open files */
#define DP_MAXLINKS	1	/* max number of hard links to a file */
#define DP_PATHMAX	2	/* max path name length */
#define DP_NAMEMAX	3	/* max length of an individual file name */
#define DP_ATOMIC	4	/* # of bytes that can be written atomically */
#define DP_TRUNC	5	/* file name truncation behavior */
#	define	DP_NOTRUNC	0	/* long filenames give an error */
#	define	DP_AUTOTRUNC	1	/* long filenames truncated */
#	define	DP_DOSTRUNC	2	/* DOS truncation rules in effect */
#define DP_CASE		6	/* file name case conversion behavior */
#	define	DP_CASESENS	0	/* case sensitive */
#	define	DP_CASECONV	1	/* case always converted */
#	define	DP_CASEINSENS	2	/* case insensitive, preserved */

#define DP_MAXREQ	6	/* highest legal request */

/* Dpathconf and Sysconf return this when a value is not limited
   (or is limited only by available memory) */

#define UNLIMITED	0x7fffffffL

#endif

/* various character constants and defines for TTY's */
#define MiNTEOF 0x0000ff1a	/* 1a == ^Z */

/* defines for tty_read */
#define RAW	0
#define COOKED	0x1
#define NOECHO	0
#define ECHO	0x2
#define ESCSEQ	0x04		/* cursor keys, etc. get escape sequences */

#ifndef _file_h
/* constants for various Fcntl commands */
/* constants for Fcntl calls */
#define F_DUPFD		0		/* handled by kernel */
#define F_GETFD		1		/* handled by kernel */
#define F_SETFD		2		/* handled by kernel */
#	define FD_CLOEXEC	1	/* close on exec flag */

#define F_GETFL		3		/* handled by kernel */
#define F_SETFL		4		/* handled by kernel */
#define F_GETLK		5
#define F_SETLK		6
#define F_SETLKW	7

#define FSTAT		(('F'<< 8) | 0)	/* handled by kernel */
#define FIONREAD	(('F'<< 8) | 1)
#define FIONWRITE	(('F'<< 8) | 2)
#define TIOCGETP	(('T'<< 8) | 0)
#define TIOCSETP	(('T'<< 8) | 1)
#define TIOCSETN TIOCSETP
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
#define TIOCOBAUD	(('T'<< 8) | 19)	/* ??	*/
#define TIOCCBRK	(('T'<< 8) | 20)
#define TIOCSBRK	(('T'<< 8) | 21)

#define TIOCGFLAGS (('T'<< 8) | 22)
#define TIOCSFLAGS (('T'<< 8) | 23)


#define TIOCOUTQ	(('T'<< 8) | 24)
//#define TIOCSETP	(('T'<< 8) | 25)
#define TIOCHPCL	(('T'<< 8) | 26)
#define TIOCCAR		(('T'<< 8) | 27)
#define TIOCNCAR	(('T'<< 8) | 28)
#define TIOCWONLINE	(('T'<< 8) | 29)
#define TIOCSFLAGSB	(('T'<< 8) | 30)
#define TIOCGSTATE	(('T'<< 8) | 31)
#define TIOCSSTATEB	(('T'<< 8) | 32)
#define TIOCGVMIN	(('T'<< 8) | 33)
#define TIOCSVMIN	(('T'<< 8) | 34)

/* cursor control Fcntls:
 * NOTE THAT THESE MUST BE TOGETHER
 */
#define TCURSOFF	(('c'<< 8) | 0)
#define TCURSON		(('c'<< 8) | 1)
#define TCURSBLINK	(('c'<< 8) | 2)
#define TCURSSTEADY	(('c'<< 8) | 3)
#define TCURSSRATE	(('c'<< 8) | 4)
#define TCURSGRATE	(('c'<< 8) | 5)

/* process stuff */
#define PPROCADDR	(('P'<< 8) | 1)
#define PBASEADDR	(('P'<< 8) | 2)
#define PCTXTSIZE	(('P'<< 8) | 3)
#define PSETFLAGS	(('P'<< 8) | 4)
#define PGETFLAGS	(('P'<< 8) | 5)
#define PTRACESFLAGS	(('P'<< 8) | 6)
#define PTRACEGFLAGS	(('P'<< 8) | 7)
#	define	P_ENABLE	(1 << 0)	/* enable tracing */
#ifdef NOTYETDEFINED
#	define	P_DOS		(1 << 1)	/* trace DOS calls - unimplemented */
#	define	P_BIOS		(1 << 2)	/* trace BIOS calls - unimplemented */
#	define	P_XBIOS		(1 << 3)	/* trace XBIOS calls - unimplemented */
#endif

#define PTRACEGO	(('P'<< 8) | 8)	/* these 4 must be together */
#define PTRACEFLOW	(('P'<< 8) | 9)
#define PTRACESTEP	(('P'<< 8) | 10)
#define PTRACE11	(('P'<< 8) | 11)
#define PLOADINFO	(('P'<< 8) | 12)
#define	PFSTAT		(('P'<< 8) | 13)

#define PPROCADDR	(('P'<< 8) | 1)
#define PBASEADDR	(('P'<< 8) | 2)
#define PCTXTSIZE	(('P'<< 8) | 3)
#define PSETFLAGS	(('P'<< 8) | 4)
#define PGETFLAGS	(('P'<< 8) | 5)

#define SHMGETBLK	(('M'<< 8) | 0)
#define SHMSETBLK	(('M'<< 8) | 1)

/* terminal control constants (tty.sg_flags) */
#define T_CRMOD		0x0001
#define T_CBREAK	0x0002
#define T_ECHO		0x0004
 #define T_XTABS	0x0008  /* unimplemented*/
#define T_RAW		0x0010
 #define T_LCASE	0x0020  /* unimplemented */

#define T_NOFLSH	0x0040		/* don't flush buffer when signals
					   are received */
#define T_TOS		0x0080
#define T_TOSTOP	0x0100
#define T_XKEY		0x0200		/* Fread returns escape sequences for
					   cursor keys, etc. */
#define T_ECHOCTL	0x0400		/* echo ctl chars as ^x */
/* 0x0800 still available */

#define T_TANDEM	0x1000
#define T_RTSCTS	0x2000
#define T_EVENP		0x4000		/* EVENP and ODDP are mutually exclusive */
#define T_ODDP		0x8000

#define TF_FLAGS	0xF000

/* some flags for TIOC[GS]FLAGS */
#define TF_CAR		0x800		/* nonlocal mode, require carrier */
#define TF_NLOCAL	TF_CAR

#define TF_BRKINT	0x80		/* allow breaks interrupt (like ^C) */

#define TF_STOPBITS	0x0003
#define TF_1STOP	0x0001
#define TF_15STOP	0x0002
#define	TF_2STOP	0x0003

#define TF_CHARBITS	0x000C
#define TF_8BIT		0
#define TF_7BIT		0x4
#define TF_6BIT		0x8
#define TF_5BIT		0xC

/* the following are terminal status flags (tty.state) */
/* (the low byte of tty.state indicates a part of an escape sequence still
 * hasn't been read by Fread, and is an index into that escape sequence)
 */
#define TS_ESC		0x00ff
#define TS_BLIND	0x800		/* tty is `blind' i.e. has no carrier
					   (cleared in local mode) */
#define TS_HOLD		0x1000		/* hold (e.g. ^S/^Q) */
#define TS_HPCL		0x4000		/* hang up on close */
#define TS_COOKED	0x8000		/* interpret control chars */


/* the following are terminal status flags (tty.state) */
/* (the low byte of tty.state indicates a part of an escape sequence still
 * hasn't been read by Fread, and is an index into that escape sequence)
 */
#define TS_ESC		0x00ff
#define TS_HOLD		0x1000		/* hold (e.g. ^S/^Q) */
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
	unsigned short sg_flags;
};

struct winsize {
	short	ws_row;
	short	ws_col;
	short	ws_xpixel;
	short	ws_ypixel;
};

struct xkey {
	short	xk_num;
	char	xk_def[8];
};
#endif

struct tty {
	short		pgrp;		/* process group of terminal */
	short		state;		/* terminal status, e.g. stopped */
	short		use_cnt;	/* number of times terminal is open */
	short		res1;		/* reserved for future expansion */
	struct sgttyb 	sg;
	struct tchars 	tc;
	struct ltchars 	ltc;
	struct winsize	wsiz;
	long		rsel;		/* selecting process for read */
	long		wsel;		/* selecting process for write */
	char		*xkey;		/* extended keyboard table */
	long		rsrvd[3];	/* reserved for future expansion */
};

/* defines and declarations for Dcntl operations */
#ifndef _file_h
#define DEV_INSTALL	0xde02
#define DEV_NEWBIOS	0xde01
#define DEV_NEWTTY	0xde00
#endif
struct dev_descr {
	DEVDRV	*driver;
	short	dinfo;
	short	flags;
	struct tty *tty;
	long	reserved[4];
};

#define FS_INSTALL    0xf001  /* let the kernel know about the file system */
#define FS_MOUNT      0xf002  /* make a new directory for a file system */
#define FS_UNMOUNT    0xf003  /* remove a directory for a file system */
#define FS_UNINSTALL  0xf004  /* remove a file system from the list */


struct fs_descr
{
	FILESYS *file_system;
	short dev_no;    /* this is filled in by MiNT if arg == FS_MOUNT*/
	long flags;
	long reserved[4];
};


/* number of BIOS drives */
#define NUM_DRIVES 32

#define BIOSDRV (NUM_DRIVES)
#define PIPEDRV (NUM_DRIVES+1)
#define PROCDRV (NUM_DRIVES+2)
#define SHMDRV	(NUM_DRIVES+3)

#define UNI_NUM_DRVS (NUM_DRIVES+4)
#define UNIDRV	('U'-'A')

#define PSEUDODRVS ((1L<<UNIDRV))

/* various fields for the "rdev" device numbers */
#define BIOS_DRIVE_RDEV 	0x0000
#define BIOS_RDEV	0x0100
#define FAKE_RDEV	0x0200
#define PIPE_RDEV	0x7e00
#define UNK_RDEV	0x7f00
#define PROC_RDEV_BASE	0xa000

#ifndef GENMAGIC
/* external variables */

extern FILESYS *drives[NUM_DRIVES];
extern struct tty default_tty;
#define follow_links ((char *)-1L)

#endif

/* internal bios file structure */

#define	BNAME_MAX	13

struct bios_file {
	char 	name[BNAME_MAX+1];	/* device name */
	DEVDRV *device;			/* device driver for device */
	short	private;		/* extra info for device driver */
	unsigned short	flags;		/* flags for device open */
	struct tty *tty;		/* tty structure (if appropriate) */
	struct bios_file *next;
	short	lockpid;		/* owner of the lock */
	XATTR	xattr;			/* guess what... */
	long	drvsize;		/* size of DEVDRV struct */
};



/* defines for TOS attribute bytes */
#ifndef FA_RDONLY
#define	       FA_RDONLY	       0x01
#define	       FA_HIDDEN	       0x02
#define	       FA_SYSTEM	       0x04
#define	       FA_LABEL		       0x08
#define	       FA_DIR		       0x10
#define	       FA_CHANGED	       0x20
#endif

#endif /* _filesys_h */
