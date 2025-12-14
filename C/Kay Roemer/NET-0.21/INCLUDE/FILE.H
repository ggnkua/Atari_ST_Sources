/*
 *	This file defines various structures and constants used by
 *	MiNT kernel, device drivers and filesystems.
 *	It does only work with ANSI compilers and prototypes.
 *
 *	file.h is derived from filesys.h, which is
 *
 * 	Copyright 1991,1992 Eric R. Smith. This file may be re-distributed
 * 	as long as this notice remains intact.
 */

#ifndef _FILE_H
#define _FILE_H

#define NAME_MAX 32
#define PATH_MAX 128

struct filesys;		/* forward declaration */
struct devdrv;		/* ditto */

/* structure for timeouts, the `void*'s are really `struct proc *'s */
typedef struct timeout {
	struct timeout	*next;
	void	*proc;
	long	when;
	void	(*func) (void *); /* function to call at timeout */
} TIMEOUT;

typedef struct f_cookie {
	struct filesys *fs;	/* filesystem that knows about this cookie */
	unsigned short	dev;	/* device info (e.g. Rwabs device number) */
	unsigned short	aux;	/* extra data that the file system may want */
	long	index;		/* this+dev uniquely identifies a file */
} fcookie;

/* structure for opendir/readdir/closedir */
typedef struct dirstruct {
	fcookie fc;		/* cookie for this directory */
	unsigned short	index;	/* index of the current entry */
	unsigned short	flags;	/* flags (e.g. tos or not) */
#define TOS_SEARCH	0x01
	char	fsstuff[60];	/* anything else the file system wants */
				/* NOTE: this must be at least 45 bytes */
} DIR;

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
	short	mtime, mdate;
	short	atime, adate;
	short	ctime, cdate;
	short	attr;
	short	reserved2;
	long	reserved3[2];
} XATTR;

typedef struct fileptr {
	short	links;	    /* number of copies of this descriptor */
	unsigned short	flags;	    /* file open mode and other file flags */
	long	pos;	    /* position in file */
	long	devinfo;    /* device driver specific info */
	fcookie	fc;	    /* file system cookie for this file */
	struct devdrv *dev; /* device driver that knows how to deal with this */
	struct fileptr *next; /* link to next fileptr for this file */
} FILEPTR;

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

/* LOCK structure used by the kernel internally */
typedef struct ilock {
	struct flock l;
	struct ilock *next;
	long  reserved[4];
} LOCK;

typedef struct devdrv {
	long (*open)	(FILEPTR *f);
	long (*write)	(FILEPTR *f, char *buf, long bytes);
	long (*read)	(FILEPTR *f, char *buf, long bytes);
	long (*lseek)	(FILEPTR *f, long where, short whence);
	long (*ioctl)	(FILEPTR *f, short mode, void *buf);
	long (*datime)	(FILEPTR *f, short *timeptr, short rwflag);
	long (*close)	(FILEPTR *f, short pid);
	long (*select)	(FILEPTR *f, long proc, short mode);
	void (*unselect) (FILEPTR *f, long proc, short mode);
	long	reserved[3];	/* reserved for future use */
} DEVDRV;

typedef struct filesys {
	struct	filesys	*next;	/* link to next file system on chain */
	long	fsflags;
#define FS_KNOPARSE	0x01	/* kernel shouldn't do parsing */
#define FS_CASESENSITIVE	0x02	/* file names are case sensitive */
#define FS_NOXBIT	0x04	/* if a file can be read, it can be executed */
#define	FS_LONGPATH	0x08	/* file system understands "size" argument to
				   "getname" */

	long	(*root) (short drv, fcookie *fc);
	long	(*lookup) (fcookie *dir, char *name, fcookie *fc);
	long	(*creat) (fcookie *dir, char *name, unsigned short mode,
				short attrib, fcookie *fc);
	DEVDRV *(*getdev) (fcookie *fc, long *devspecial);
	long	(*getxattr) (fcookie *fc, XATTR *xattr);
	long	(*chattr) (fcookie *fc, short attr);
	long	(*chown) (fcookie *fc, short uid, short gid);
	long	(*chmode) (fcookie *fc, unsigned short mode);
	long	(*mkdir) (fcookie *dir, char *name, unsigned short mode);
	long	(*rmdir) (fcookie *dir, char *name);
	long	(*remove) (fcookie *dir, char *name);
	long	(*getname) (fcookie *relto, fcookie *dir, char *pathname,
				short size);
	long	(*rename) (fcookie *olddir, char *oldname,
			    fcookie *newdir, char *newname);
	long	(*opendir) (DIR *dirh, short tosflag);
	long	(*readdir) (DIR *dirh, char *nm, short nmlen, fcookie *fc);
	long	(*rewinddir) (DIR *dirh);
	long	(*closedir) (DIR *dirh);
	long	(*pathconf) (fcookie *dir, short which);
	long	(*dfree) (fcookie *dir, long *buf);
	long	(*writelabel) (fcookie *dir, char *name);
	long	(*readlabel) (fcookie *dir, char *name, short namelen);
	long	(*symlink) (fcookie *dir, char *name, char *to);
	long	(*readlink) (fcookie *dir, char *buf, short len);
	long	(*hardlink) (fcookie *fromdir, char *fromname,
				fcookie *todir, char *toname);
	long	(*fscntl) (fcookie *dir, char *name, short cmd, long arg);
	long	(*dskchng) (short drv);
	long	(*release) (fcookie *fc);
	long	(*dupcookie) (fcookie *dest, fcookie *src);

} FILESYS;

/*
 * this is the structure passed to loaded file systems to tell them
 * about the kernel
 */

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
	void	(*drvchng) (short);

/* Debugging stuff */
	void	(*trace) (char *, ...);
	void	(*debug) (char *, ...);
	void	(*alert) (char *, ...);
	void	(*fatal) (char *, ...);

/* memory allocation functions */
	void *	(*kmalloc) (long);
	void	(*kfree) (void *);
	void *	(*umalloc) (long);
	void	(*ufree) (void *);

/* utility functions for string manipulation */
	short	(*strnicmp) (char *, char *, short);
	short	(*stricmp) (char *, char *);
	char *	(*strlwr) (char *);
	char *	(*strupr) (char *);
	short	(*sprintf) (char *, char *, ...);

/* utility functions for manipulating time */
	void	(*millis_time) (unsigned long, short *);
	long	(*unixtim) (unsigned short, unsigned short);
	long	(*dostim) (long);

/* utility functions for dealing with pauses */
	void	(*nap) (unsigned short);
	void	(*sleep) (short que, long cond);
	void	(*wake) (short que, long cond);
	void	(*wakeselect) (long param);

/* file system utility functions */
	short	(*denyshare) (FILEPTR *, FILEPTR *);
	LOCK *	(*denylock) (LOCK *, LOCK *);

/* functions for adding/cancelling timeouts */
	TIMEOUT * (*addtimeout) (long, void (*)());
	void	(*canceltimeout) (TIMEOUT *);

/* reserved for future use */
	long	res2[7];
};

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

/* macros to be applied to FILEPTRS to determine their type */
#define is_terminal(f) (f->flags & O_TTY)

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

/* various character constants and defines for TTY's */
#define MiNTEOF 0x0000ff1a	/* 1a == ^Z */

/* defines for tty_read */
#define RAW	0
#define COOKED	0x1
#define NOECHO	0
#define ECHO	0x2
#define ESCSEQ	0x04		/* cursor keys, etc. get escape sequences */

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
#define TCURSON		(('c'<< 8) | 1)
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
#	define	P_ENABLE	(1 << 0)	/* enable tracing */

#define PTRACEGO	(('P'<< 8) | 8)
#define PTRACEFLOW	(('P'<< 8) | 9)
#define PTRACESTEP	(('P'<< 8) | 10)
#define PTRACE11	(('P'<< 8) | 11)	/* unused, reserved */

#define SHMGETBLK	(('M'<< 8) | 0)
#define SHMSETBLK	(('M'<< 8) | 1)

/* terminal control constants (tty.sg_flags) */
#define T_CRMOD		0x0001
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

#define DEV_INSTALL	0xde02
#define DEV_NEWBIOS	0xde01
#define DEV_NEWTTY	0xde00

struct dev_descr {
	DEVDRV	*driver;
	short	dinfo;
	short	flags;
	struct tty *tty;
	long	reserved[4];
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

#endif /* _FILE_H */
