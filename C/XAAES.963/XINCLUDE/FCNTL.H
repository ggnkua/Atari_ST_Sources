/*
 *	FCNTL.H
 */

#ifndef	_FCNTL_H
#define	_FCNTL_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

begin_decls

#define	O_RDONLY	0x00		/* read only */
#define	O_WRONLY	0x01		/* write only */
#define	O_RDWR		0x02		/* read/write */
#define O_ACCMODE	0x03		/* used to mask off file access mode */

/* file sharing modes (not POSIX) */
#define O_COMPAT	0x00		/* old TOS compatibility mode */
#define O_DENYRW	0x10		/* deny both reads and writes */
#define O_DENYW		0x20
#define O_DENYR		0x30
#define O_DENYNONE	0x40		/* don't deny anything */
#define O_SHMODE	0x70		/* mask for file sharing mode */

#define	O_NDELAY	0x100		/* Non-blocking I/O */
#ifdef __MINT__
# define O_SYNC		0x00		/* sync after writes (not implemented) */
#endif

/* the following flags are not passed to the OS  HR?? but they are */
#define	O_CREAT		0x200		/* create new file if needed */
#define	O_TRUNC		0x400		/* make file 0 length */
#define	O_EXCL		0x800		/* error if file exists */
#define	O_APPEND	0x1000		/* position at EOF */

#define _REALO_APPEND	0x08		/* this is what MiNT uses */
#ifndef __MINT__
# define O_PIPE		0x2000		/* serial pipe     */
#endif
#define O_NOCTTY	0x4000		/* do not open new controlling tty */

/*
 * defines for the access() function
 */
#define	F_OK			0
#define	X_OK			1
#define	W_OK			2
#define	R_OK			4

/*
 * defines for fcntl()
 */
#define	F_DUPFD		0	/* Duplicate fildes */
#define	F_GETFD		1	/* Get fildes flags */
#define	F_SETFD		2	/* Set fildes flags */
#define	F_GETFL		3	/* Get file flags */
#define	F_SETFL		4	/* Set file flags */

#ifdef __MINT__
#define F_GETLK		5	/* Get file lock */
#define F_SETLK		6	/* Set file lock */
#define F_SETLKW	7	/* Get lock, wait if busy */

struct flock {
	short l_type;
#define F_RDLCK		O_RDONLY
#define F_WRLCK		O_WRONLY
#define F_UNLCK		3
	short l_whence;
	long l_start;
	long l_len;
	short l_pid;
};
#endif /* __MINT__ */

/* Mask for close-on-exec bit in the flags retrieved/set by F_GETFD/F_SETFD */
#define FD_CLOEXEC 0x01

/* smallest valid gemdos handle */
/* note handle is only word (16 bit) negative, not long negative,
   and since Fopen etc are declared as returning long in osbind.h
   the sign-extension will not happen -- thanks ers
*/
#ifdef __MSHORT__
#define __SMALLEST_VALID_HANDLE (-3)
#else
#define __SMALLEST_VALID_HANDLE (0)
#endif

#if ! FIX_PC
int	creat	(const char *, unsigned short);
int	__creat	(const char *, unsigned short);
int	fcntl	(int f, int cmd, ...);
int	__fcntl	(int f, int cmd, ...);
int	open	(const char *, int, ...);
int	__open	(const char *, int, ...);
#endif

#ifdef __MINT__
# if defined (__USE_MISC) && !defined (F_LOCK)
/* NOTE: These declarations also appear in <unistd.h>; be sure to keep both
   files consistent.  Some systems have them there and some here, and some
   software depends on the macros being defined without including both.  */

/* `lockf' is a simpler interface to the locking facilities of `fcntl'.
   LEN is always relative to the current file position.
   The CMD argument is one of the following.  */

/* flock() commands */
#  define F_ULOCK	0	/* unlock */
#  define F_LOCK	1	/* lock */
#  define F_TLOCK	2	/* test and lock (non-blocking) */
#  define F_TEST	3	/* test */
int		lockf	(int, int, long);
# endif
#endif /* __MINT__ */

end_decls

#endif /* _FCNTL_H */
