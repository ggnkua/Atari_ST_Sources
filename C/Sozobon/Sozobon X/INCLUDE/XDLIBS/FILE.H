/* @(#)file.h, XdLibs MiNT support

	XdLibs - MiNT support
	file.h
	MiNT: sort of fcntl.h & ioctl.h 
	constants and structures
	used in MiNT Functions Dcntl() and Fcntl(), Fopen() etc

	see filesys.h for filesystems and device drivers
*/

#ifndef _file_h
#define _file_h


/* structure for getxattr */

typedef struct xattr {
	unsigned short	mode;
/* file types */
#define S_IFMT	0170000		/* mask to select file type */
#define S_IFCHR	0020000		/* BIOS special file */
#define S_IFDIR	0040000		/* directory file */
#define S_IFREG 0100000		/* regular file */
#define S_IFIFO	0120000		/* FIFO */
#define S_IFMEM	0140000		/* memory region or process */
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
	unsigned short	rdev;		/* "real" device */
	unsigned short	nlink;
	unsigned short	uid;
	unsigned short	gid;
	long	size;
	long	blksize;
	long	nblocks;
	unsigned short	mtime, mdate;
	unsigned short	atime, adate;
	unsigned short	ctime, cdate;
	unsigned short	attr;
/* defines for TOS attribute bytes */
#ifndef FA_RDONLY
#define	       FA_RDONLY	       0x01
#define	       FA_HIDDEN	       0x02
#define	       FA_SYSTEM	       0x04
#define	       FA_LABEL		       0x08
#define	       FA_DIR		       0x10
#define	       FA_CHANGED	       0x20
#endif
	short	reserved2;
	long	reserved3[2];
} XATTR;


struct flock {
	short l_type;			/* type of lock */
#define F_RDLCK		0
#define F_WRLCK		1
#define F_UNLCK		3
	short l_whence;			/* SEEK_SET, SEEK_CUR, SEEK_END */
	long l_start;			/* start of locked region */
	long l_len;			/* length of locked region */
	short l_pid;			/* pid of locking process
						(F_GETLK only) */
};


/* flags for Fopen() modes, with MiNT > 0.9 
	Fopen() replaces Fcreate() */

#define O_USER		0x0fff	/* isolates user-settable flag bits */
#define O_RWMODE  	0x03	/* isolates file read/write mode */
#ifndef _FCNTL_H
#	define O_RDONLY	0x00
#	define O_WRONLY	0x01
#	define O_RDWR	0x02
#endif

#define O_EXEC		0x03	/* execute file; used by kernel only */
	/* 0x04 is for future expansion */
#ifndef _FCNTL_H
#define O_APPEND	0x08	/* all writes go to end of file */

#define O_SHMODE	0x70	/* isolates file sharing mode */
#	define O_COMPAT	0x00	/* compatibility mode */
#	define O_DENYRW	0x10	/* deny both read and write access */
#	define O_DENYW	0x20	/* deny write access to others */
#	define O_DENYR	0x30	/* deny read access to others */
#	define O_DENYNONE 0x40	/* don't deny any access to others */

#define O_NOINHERIT	0x80	/* private file (not passed to child) */

#define O_NDELAY	0x100	/* don't block for i/o on this file */
#define O_CREAT		0x200	/* create file if it doesn't exist */
#define O_TRUNC		0x400	/* truncate file to 0 bytes if it does exist */
#define O_EXCL		0x800	/* fail open if file exists */

#define O_GLOBAL	0x1000	/* for opening a global file */

#endif

/* kernel mode bits -- the user can't set these! */
#define O_TTY		0x2000
#define O_HEAD		0x4000
#define O_LOCK		0x8000

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
#define DP_CASE		6
#	define	DP_CASESENS	0	/* case sensitive */
#	define	DP_CASECONV	1	/* case always converted */
#	define	DP_CASEINSENS	2	/* case insensitive, preserved */
#define DP_MODEATTR		7
#	define	DP_ATTRBITS	0x000000ffL	/* mask for valid TOS attribs */
#	define	DP_MODEBITS	0x000fff00L	/* mask for valid Unix file modes */
#	define	DP_FILETYPS	0xfff00000L	/* mask for valid file types */
#	define	DP_FT_DIR	0x00100000L	/* directories (always if . is there) */
#	define	DP_FT_CHR	0x00200000L	/* character special files */
#	define	DP_FT_BLK	0x00400000L	/* block special files, currently unused */
#	define	DP_FT_REG	0x00800000L	/* regular files */
#	define	DP_FT_LNK	0x01000000L	/* symbolic links */
#	define	DP_FT_SOCK	0x02000000L	/* sockets, currently unused */
#	define	DP_FT_FIFO	0x04000000L	/* pipes */
#	define	DP_FT_MEM	0x08000000L	/* shared memory or proc files */
#define DP_XATTRFIELDS	8
#	define	DP_INDEX	0x0001
#	define	DP_DEV		0x0002
#	define	DP_RDEV		0x0004
#	define	DP_NLINK	0x0008
#	define	DP_UID		0x0010
#	define	DP_GID		0x0020
#	define	DP_BLKSIZE	0x0040
#	define	DP_SIZE		0x0080
#	define	DP_NBLOCKS	0x0100
#	define	DP_ATIME	0x0200
#	define	DP_CTIME	0x0400
#	define	DP_MTIME	0x0800
#define DP_MAXREQ	8	/* highest legal request */

/* Dpathconf and Sysconf return this when a value is not limited
   (or is limited only by available memory) */

#define UNLIMITED	0x7fffffffL


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

/* more constants for various Fcntl's */
	/* basic file operations	*/
#define FSTAT		(('F'<< 8) | 0)		/* handled by kernel */
#define FIONREAD	(('F'<< 8) | 1)
#define FIONWRITE	(('F'<< 8) | 2)
#define FUTIME		(('F'<< 8) | 3)	/* for use by Dcntl() too	*/
#define FTRUNCATE	(('F'<< 8) | 4)	/* for use by Dcntl() too	*/
#define FIOEXCEPT	(('F'<< 8) | 5)
	/* basic tty related calls	*/
#define TIOCGETP	(('T'<< 8) | 0)
#define TIOCSETN	(('T'<< 8) | 1)
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
#define TIOCGFLAGS	(('T'<< 8) | 22)	/* see TF_ constants/flags	*/
#define TIOCSFLAGS	(('T'<< 8) | 23)	/* see TF_ constants/flags	*/
#define TIOCOUTQ	(('T'<< 8) | 24)
#define TIOCSETP	(('T'<< 8) | 25)
#define TIOCHPCL	(('T'<< 8) | 26)
#define TIOCCAR		(('T'<< 8) | 27)
#define TIOCNCAR	(('T'<< 8) | 28)
#define TIOCWONLINE	(('T'<< 8) | 29)
#define TIOCSFLAGSB	(('T'<< 8) | 30)
#define TIOCGSTATE	(('T'<< 8) | 31)
#define TIOCSSTATEB	(('T'<< 8) | 32)
#define TIOCGVMIN	(('T'<< 8) | 33)
#define TIOCSVMIN	(('T'<< 8) | 34)
/* extended tty Fcntls	*/
	/* sorry - missing	*/

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

#define SHMGETBLK	(('M'<< 8) | 0)
#define SHMSETBLK	(('M'<< 8) | 1)


struct ploadinfo {
	/* passed */
	short fnamelen;
	/* returned */
	char *cmdlin, *fname;
};


/* terminal control constants (tty.sg_flags) */
#define T_CRMOD		0x0001
#define T_CBREAK	0x0002
#define T_ECHO		0x0004
/* #define T_XTABS	0x0008  unimplemented*/
#define T_RAW		0x0010
/* #define T_LCASE	0x0020  unimplemented */

#define T_NOFLSH	0x0040		/* don't flush buffer when signals
								   are received */
#define T_TOS		0x0080
#define T_TOSTOP	0x0100
#define T_XKEY		0x0200		/* Fread returns escape sequences for
								   cursor keys, etc. */
#define T_ECHOCTL	0x0400		/* echo ctl chars as ^x */
/* 0x0800 still available */

/* some TF_ flags : flags for TIOC[GS]FLAGS */
#define TF_CAR		0x800		/* nonlocal mode, require carrier */
#define TF_NLOCAL	TF_CAR
#define TF_BRKINT	0x80		/* allow breaks interrupt (like ^C) */

#define TF_STOPBITS 0x0003
#define TF_1STOP   0x0001 /* 1 Stoppbit */
#define TF_15STOP  0x0002 /* 1.5 Stoppbit */
#define	TF_2STOP   0x0003 /* 2 Stoppbit */
#define TF_CHARBITS 0x000C
#define TF_8BIT	0x0 /* 8 Bit */
#define TF_7BIT	0x4
#define TF_6BIT	0x8
#define TF_5BIT	0xC /* 5 Bit */
#define TF_FLAGS 0xF000
#define T_TANDEM 0x1000 /* Xon/Xoff */
#define T_RTSCTS 0x2000 /* RTS/CTS  */
#define T_EVENP  0x4000 /* even  */
#define T_ODDP   0x8000 /* odd  */

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



/* Dcntl constants and types */
/* for FUTIME and FTRUNCATE see Fcntl() defines */

#define DEV_NEWTTY	0xde00
#define DEV_NEWBIOS	0xde01
#define DEV_INSTALL	0xde02

#define FS_INSTALL    0xf001  /* let the kernel know about the file system */
#define FS_MOUNT      0xf002  /* make a new directory for a file system */
#define FS_UNMOUNT    0xf003  /* remove a directory for a file system */
#define FS_UNINSTALL  0xf004  /* remove a file system from the list */

struct _mutimbuf {
	unsigned short actime, acdate;	/* GEMDOS format */
	unsigned short modtime, moddate;
};


/* various fields for the "rdev" device numbers */
#define BIOS_DRIVE_RDEV 	0x0000
#define BIOS_RDEV	0x0100
#define FAKE_RDEV	0x0200
#define PIPE_RDEV	0x7e00
#define UNK_RDEV	0x7f00
#define PROC_RDEV_BASE	0xa000


#endif /* _file_h */
