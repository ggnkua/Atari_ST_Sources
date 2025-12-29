/*
 * NOTE: This file only works if sizeof(int) == 2!
 * UNLESS: you have an ANSI compiler and use prototypes
 *
 * Copyright 1991 Eric R. Smith. This file may be re-distributed freely
 * so long as this notice remains intact.
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

#define NAME_MAX 32
#define PATH_MAX 128

struct filesys;		/* forward declaration */
struct devdrv;		/* ditto */

typedef struct f_cookie {
	struct filesys *fs;	/* filesystem that knows about this cookie */
	unsigned short	dev;		/* device info (e.g. Rwabs device number) */
	unsigned short	aux;		/* extra data that the file system may want */
	long	index;		/* this+dev uniquely identifies a file */
} fcookie;

/* structure for opendir/readdir/closedir */
typedef struct dirstruct {
	fcookie fc;		/* cookie for this directory */
	unsigned short	index;		/* index of the current entry */
	unsigned short	flags;		/* flags (e.g. tos or not) */
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

typedef struct devdrv {
	long (*open)	P_((FILEPTR *f));
	long (*write)	P_((FILEPTR *f, char *buf, long bytes));
	long (*read)	P_((FILEPTR *f, char *buf, long bytes));
	long (*lseek)	P_((FILEPTR *f, long where, short whence));
	long (*ioctl)	P_((FILEPTR *f, short mode, void *buf));
	long (*datime)	P_((FILEPTR *f, short *timeptr, short rwflag));
	long (*close)	P_((FILEPTR *f));
	long (*select)	P_((FILEPTR *f, long proc, short mode));
	void (*unselect) P_((FILEPTR *f, long proc, short mode));
} DEVDRV;

typedef struct filesys {
	struct	filesys	*next;	/* link to next file system on chain */
	long	fsflags;
#define FS_KNOPARSE	0x01	/* kernel shouldn't do parsing */
#define FS_CASESENSITIVE	0x02	/* file names are case sensitive */
#define FS_NOXBIT	0x04	/* if a file can be read, it can be executed */

	long	(*root) P_((short drv, fcookie *fc));
	long	(*lookup) P_((fcookie *dir, char *name, fcookie *fc));
	long	(*creat) P_((fcookie *dir, char *name, unsigned short mode,
				short attrib, fcookie *fc));
	DEVDRV *(*getdev) P_((fcookie *fc, long *devspecial));
	long	(*getxattr) P_((fcookie *fc, XATTR *xattr));
	long	(*chattr) P_((fcookie *fc, short attr));
	long	(*chown) P_((fcookie *fc, short uid, short gid));
	long	(*chmode) P_((fcookie *fc, unsigned short mode));
	long	(*mkdir) P_((fcookie *dir, char *name, unsigned short mode));
	long	(*rmdir) P_((fcookie *dir, char *name));
	long	(*remove) P_((fcookie *dir, char *name));
	long	(*getname) P_((fcookie *relto, fcookie *dir, char *pathname));
	long	(*rename) P_((fcookie *olddir, char *oldname,
			    fcookie *newdir, char *newname));
	long	(*opendir) P_((DIR *dirh, short tosflag));
	long	(*readdir) P_((DIR *dirh, char *nm, short nmlen, fcookie *fc));
	long	(*rewinddir) P_((DIR *dirh));
	long	(*closedir) P_((DIR *dirh));
	long	(*pathconf) P_((fcookie *dir, short which));
	long	(*dfree) P_((fcookie *dir, long *buf));
	long	(*writelabel) P_((fcookie *dir, char *name));
	long	(*readlabel) P_((fcookie *dir, char *name, short namelen));
	long	(*symlink) P_((fcookie *dir, char *name, char *to));
	long	(*readlink) P_((fcookie *dir, char *buf, short len));
	long	(*hardlink) P_((fcookie *fromdir, char *fromname,
				fcookie *todir, char *toname));
	long	(*fscntl) P_((fcookie *dir, char *name, short cmd, long arg));
	long	(*dskchng) P_((short drv));
	long	zero;
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
	short	(*strnicmp) P_((char *, char *, short));
	short	(*stricmp) P_((char *, char *));
	char *	(*strlwr) P_((char *));
	char *	(*strupr) P_((char *));
	short	(*sprintf) P_((char *, char *, ...));

/* utility functions for manipulating time */
	void	(*millis_time) P_((unsigned long, short *));
	long	(*unixtim) P_((unsigned short, unsigned short));
	long	(*dostim) P_((long));

/* utility functions for dealing with pauses */
	void	(*nap) P_((unsigned short));
	void	(*sleep) P_((short que, long cond));
	void	(*wake) P_((short que, long cond));
	void	(*wakeselect) P_((long param));

/* file system utility functions */
	short	(*denyshare) P_((FILEPTR *, FILEPTR *));

/* reserved for future use */
	long	res2[10];
};

/* flags for open() modes */
#define O_RWMODE  	0x03	/* isolates file read/write mode */
#	define O_RDONLY	0x00
#	define O_WRONLY	0x01
#	define O_RDWR	0x02
#	define O_EXEC	0x03	/* execute file; used by kernel only */

#define O_SHMODE	0x70	/* isolates file sharing mode */
#	define O_COMPAT	0x00	/* compatibility mode */
#	define O_DENYRW	0x10	/* deny both read and write access */
#	define O_DENYW	0x20	/* deny write access to others */
#	define O_DENYR	0x30	/* deny read access to others */
#	define O_DENYNONE 0x40	/* don't deny any access to others */

#define O_NOINHERIT	0x80	/* this is currently ignored by MiNT */

#define O_NDELAY	0x100	/* don't block for i/o on this file */
#define O_CREAT		0x200	/* create file if it doesn't exist */
#define O_TRUNC		0x400	/* truncate file to 0 bytes if it does exist */
#define O_EXCL		0x800	/* fail open if file exists */

#define O_USER		0x0fff	/* isolates user-settable flag bits */

/* kernel mode bits -- the user can't set these! */
#define O_BIOS		0x2000
#define O_HEAD		0x4000
#define O_LOCK		0x8000

/* GEMDOS file attributes */

/* macros to be applied to FILEPTRS to determine their type */
#define is_bios(f) (f->flags & O_BIOS)

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

#define DP_MAXREQ	5	/* highest legal request */

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

#define PPROCADDR	(('P'<< 8) | 1)
#define PBASEADDR	(('P'<< 8) | 2)

/* terminal control constants */
#define T_CRMOD		0x0001
#define T_CBREAK	0x0002
#define T_ECHO		0x0004
#define T_RAW		0x0010
#define T_TOS		0x0080
#define T_TOSTOP	0x0100

/* the following are terminal status flags */
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
	long		rsrvd[4];	/* reserved for future expansion */
};

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

/* defines for TOS attribute bytes */
#ifndef FA_RDONLY
#define	       FA_RDONLY	       0x01
#define	       FA_HIDDEN	       0x02
#define	       FA_SYSTEM	       0x04
#define	       FA_LABEL		       0x08
#define	       FA_DIR		       0x10
#define	       FA_CHANGED	       0x20
#endif

#endif _filesys_h
