#ifndef _UNISTD_H
#define _UNISTD_H

/* NOTE:
 * in prototypes used here, do *not* use things
 * like size_t, uid_t, etc., since these
 * may not be defined. Use the macros
 * from <compiler.h> instead.
 */
#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* see Posix standard -- 1003.1 sect 2.10 */

#ifndef NULL
#define NULL __NULL
#endif

#ifndef F_OK
/* file access stuff */
#define	F_OK			0
#define	X_OK			1
#define	W_OK			2
#define	R_OK			4
#endif

#ifndef SEEK_SET
/* lseek() origins */
#define	SEEK_SET	0		/* from beginning of file */
#define	SEEK_CUR	1		/* from current location */
#define	SEEK_END	2		/* from end of file */
#endif

#define _POSIX_JOB_CONTROL
#if 0
#define _POSIX_VERSION		0L		/* <- NON-CONFORMING */
#endif
#define _POSIX_CHOWN_RESTRICTED 0
#ifndef _TERMIOS_H
#define _POSIX_VDISABLE		0
#endif

#if 0					/* this depends on the file system */
#define _POSIX_NO_TRUNC		-1
#endif

/* 1003.1 section 8.2.1.2 */
#define STDIN_FILENO	0
#define STDOUT_FILENO	1
#define STDERR_FILENO	2

/* sysconf() values */
#define _SC_LAST	-1	/* max limit # for sysconf - NOT POSIX */
#define _SC_MEMR_MAX	0	/* memory regions per process - NOT POSIX */
#define _SC_ARG_MAX	1	/* max length of cmdln - NOT quite POSIX */
#define _SC_OPEN_MAX	2	/* max # of open files per process - POSIX */
#define _SC_NGROUPS_MAX	3	/* max # supp gids - POSIX */
#define _SC_CHILD_MAX	4	/* max # processes/user - NOT quite POSIX */

/* pathconf() values */
#define _PC_LAST	-1	/* max limit # for pathconf - POSIX (!?) */
#define _PC_IOPEN_MAX	0	/* internal limit on open files - NOT POSIX */
#define _PC_LINK_MAX	1	/* max # of links - POSIX */
#define _PC_PATH_MAX	2	/* max len of a full pathname - POSIX */
#define _PC_NAME_MAX	3	/* max len of individual name - POSIX */
#define _PC_PIPE_BUF	4	/* bytes written atomically to fifo - POSIX */
#define _PC_NO_TRUNC	5	/* filename truncation - POSIX */

#ifdef __MINT__
# ifndef _POSIX_SOURCE
/* flock() commands */
#  define F_ULOCK	0	/* unlock */
#  define F_LOCK	1	/* lock */
#  define F_TLOCK	2	/* test and lock (non-blocking) */
#  define F_TEST	3	/* test */
__EXTERN int		lockf	__PROTO((int, int, long));
# endif
#endif /* __MINT__ */

__EXTERN __EXITING _exit	__PROTO((int)) __NORETURN;
__EXTERN int	access	__PROTO((const char *, int));
__EXTERN unsigned alarm	__PROTO((unsigned));
__EXTERN int	chdir	__PROTO((const char *));
__EXTERN int	chown	__PROTO((const char *, int, int));
__EXTERN int	close	__PROTO((int));
__EXTERN int	dup	__PROTO((int));
__EXTERN int	dup2	__PROTO((int, int));
__EXTERN int	execl	__PROTO((const char *, ...));
__EXTERN int	execle	__PROTO((const char *, ...));
__EXTERN int	execlp	__PROTO((const char *, ...));
__EXTERN int	execv	__PROTO((const char *, char *const *));
__EXTERN int	execve	__PROTO((const char *, char *const *, char *const *));
__EXTERN int	execvp	__PROTO((const char *, char *const *));
__EXTERN int	fork	__PROTO((void));
__EXTERN char *	getcwd	__PROTO((char *, int));
__EXTERN _GID_T	getegid	__PROTO((void));
__EXTERN _UID_T	geteuid	__PROTO((void));
__EXTERN _GID_T	getgid	__PROTO((void));
__EXTERN int	getgroups __PROTO((int, _GID_T *));
__EXTERN char *	getlogin __PROTO((void));
__EXTERN int	getpid	__PROTO((void));
__EXTERN int	getppid	__PROTO((void));
__EXTERN _UID_T	getuid	__PROTO((void));
__EXTERN int	isatty	__PROTO((int));
__EXTERN int	link	__PROTO((const char *oldname, const char *newname));
__EXTERN long	lseek	__PROTO((int, long, int));
__EXTERN int	pause	__PROTO((void));
__EXTERN int	pipe	__PROTO((int *));
__EXTERN long	pathconf __PROTO((const char *, int));
__EXTERN int	rmdir	__PROTO((const char *));
__EXTERN int	read	__PROTO((int, void *, unsigned));
__EXTERN int	setgid	__PROTO((int));
__EXTERN int	setuid	__PROTO((int));
__EXTERN unsigned sleep	__PROTO((unsigned int));
__EXTERN long	sysconf	__PROTO((int));
__EXTERN char *	ttyname	__PROTO((int));
__EXTERN int	unlink	__PROTO((const char *));
__EXTERN int	write	__PROTO((int, const void *, unsigned));

#ifndef _POSIX_SOURCE
__EXTERN int	_bsd_getpgrp __PROTO((int));
__EXTERN int	_bsd_setpgrp __PROTO((int, int));
__EXTERN int    getdtablesize __PROTO ((void));
__EXTERN int	getloadavg __PROTO((double *, int));
__EXTERN char *	getwd	__PROTO((char *));
__EXTERN int	getopt	__PROTO((int, char * const *, const char *));
__EXTERN int	getpagesize __PROTO((void));
__EXTERN char *	getpass	__PROTO((const char *prompt));
__EXTERN char *	initstate __PROTO((unsigned int seed, char *arg_state, int n));

/* be careful with this and Gcc, where strings are really constants */
__EXTERN char *	mktemp	__PROTO((char *));

__EXTERN void	psignal	__PROTO((int, const char *));
__EXTERN long 	random	__PROTO((void));
__EXTERN long	_read	__PROTO((int, void *, unsigned long));
__EXTERN int	readlink __PROTO((char *filename, char *linkto, int siz));
__EXTERN void *	sbrk	__PROTO((__SIZE_TYPEDEF__));
__EXTERN void *	_sbrk	__PROTO((long));
__EXTERN int	setegid	__PROTO((int));
__EXTERN int	seteuid	__PROTO((int));
__EXTERN int	setregid __PROTO((int, int));
__EXTERN int	setreuid __PROTO((int, int));
__EXTERN char *	setstate __PROTO((char *arg_state));
__EXTERN void	sigpause __PROTO((long mask));
__EXTERN void	srandom	__PROTO((unsigned int seed));
__EXTERN int	stime	__PROTO((long *));
__EXTERN int	symlink __PROTO((const char *oldname, const char *newname));
__EXTERN long	tell	__PROTO((int));
__EXTERN void	usleep	__PROTO((unsigned long));
__EXTERN int	vfork	__PROTO((void));
__EXTERN long	_write	__PROTO((int, const void *, unsigned long));

#ifndef __MINT__
#define lread _read	/* backwards compatibility, likely to go away */
#define lwrite _write	/* backwards compatibility, likely to go away */
#endif /* __MINT__ */

#endif	/* _POSIX_SOURCE */

#ifdef __SOZOBON__
#define lsbrk _sbrk	/* backwards compatibility, don't use */
#endif

#if defined (_BSD_SOURCE) && !defined(_POSIX_SOURCE)
#define getpgrp _bsd_getpgrp
#define setpgrp _bsd_setpgrp
#else /* not _BSD_SOURCE */
__EXTERN _PID_T	getpgrp	__PROTO((void));
#ifndef _POSIX_SOURCE
__EXTERN int	setpgrp	__PROTO((void));
#endif /* _POSIX_SOURCE */
#endif /* not _BSD_SOURCE */
__EXTERN int	setpgid __PROTO((_PID_T, _PID_T));
__EXTERN int	setsid __PROTO((void));
__EXTERN _PID_T	tcgetpgrp	__PROTO((int fd));
__EXTERN int	tcsetpgrp	__PROTO((int fd, _PID_T pgrp));

#if defined(__cplusplus)
}
#endif

#endif /* _UNISTD_H */
