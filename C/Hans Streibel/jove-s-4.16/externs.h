/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* UNIX Library/System Routine Emulations for Macintosh (mac.c) */

#ifdef MAC

extern int
	creat proto((const char *, int)),
	/* open may have an optional third argument, int mode */
	open proto((const char */*path*/, int /*flags*/, ...)),
	close proto((int)),
	unlink proto((const char *)),
	chdir proto((const char *));

extern SSIZE_T
	read proto((int /*fd*/, UnivPtr /*buf*/, size_t /*nbytes*/)),
	write proto((int /*fd*/, UnivConstPtr /*buf*/, size_t /*nbytes*/));

extern long	lseek proto((int /*fd*/, long /*offset*/, int /*whence*/));
extern time_t	time proto((time_t *));

extern void
	menus_off proto((void));	/* called by real_ask, findcom, waitchar */

#endif /* MAC */

/*==== Declarations of Library/System Routines ====*/

#ifndef REALSTDC
extern int	errno;	/* Redundant if declared in <errno.h> -- DHR */
#endif
extern char *strerror proto((int));	/* errno.h or string.h? */

/* General Utilities: <stdlib.h> */

extern int	abs proto((int));

extern void	abort proto((void));
extern void	exit proto((int));

extern int	atoi proto((const char */*nptr*/));

extern void	qsort proto((UnivPtr /*base*/, size_t /*nmemb*/,
	size_t /*size*/, int (*/*compar*/)(UnivConstPtr, UnivConstPtr)));

extern char	*getenv proto((const char *));
extern int	system proto((const char *));

extern void
	free proto((UnivPtr));

extern UnivPtr
	calloc proto((size_t, size_t)),
	malloc proto((size_t)),
	realloc proto((UnivPtr, size_t));

/* Date and Time <time.h> */

extern time_t	time proto((time_t */*tloc*/));
extern char	*ctime proto((const time_t *));

/* UNIX */

#ifdef MSC51
#define const	/* the const's in the following defs conflict with MSC 5.1 */
#endif

#ifdef POSIX_UNISTD
# include <unistd.h>
# if _POSIX_VERSION < 199009L	/* defined in <unistd.h>: can't test earlier */
   /* ssize_t is not defined in original POSIX.1
    * Surprise: NetBSD defines it, even though it claims to be old POSIX.1!
    * To dodge this problem, we define ssize_t as a macro, not a typedef.
    */
#  define ssize_t	int
# endif
# include <fcntl.h>
#else /* !POSIX_UNISTD */

extern int	chdir proto((const char */*path*/));

/* POSIX, System Vr4, MSDOS, and our Mac code specify getcwd.
 * System Vr4 (sometimes?) types the second argument "int"!!
 */
# ifdef USE_GETCWD
extern char	*getcwd proto((char *, size_t));
# endif /* USE_GETCWD */

extern int	access proto((const char */*path*/, int /*mode*/));
# ifndef W_OK
#  define W_OK	2
#  define X_OK	1
#  define F_OK	0
# endif

extern int	creat proto((const char */*path*/, int /*mode*/));
	/* open may have an optional third argument, int mode */
extern int	open proto((const char */*path*/, int /*flags*/, ...));


# ifdef MSC51
extern SSIZE_T	read proto((int /*fd*/, char * /*buf*/, size_t /*nbytes*/));
extern SSIZE_T	write proto((int /*fd*/, const char * /*buf*/, size_t /*nbytes*/));
# else
extern SSIZE_T	read proto((int /*fd*/, UnivPtr /*buf*/, size_t /*nbytes*/));
extern SSIZE_T	write proto((int /*fd*/, UnivConstPtr /*buf*/, size_t /*nbytes*/));
# endif

# if !defined(ZTCDOS) && !defined(__BORLANDC__)
/* Zortech incorrectly defines argv as const char **.
 * Borland incorrectly defines argv as char *[] and omits some consts
 * on execl and execlp parameters.
 * On the other hand, each supplies declarations for these functions.
 */
extern int	execl proto((const char */*path*/, const char */*arg*/, ...));
extern int	execlp proto((const char */*file*/, const char */*arg*/, ...));
extern int	execv proto((const char */*path*/, char *const /*argv*/[]));
extern int	execvp proto((const char */*file*/, char *const /*argv*/[]));
# endif

# ifdef MSC51
#  undef const
# endif

extern void	_exit proto((int));	/* exit(), without flush, etc. */

extern unsigned	alarm proto((unsigned /*seconds*/));

extern int	pipe proto((int *));
extern int	close proto((int));
extern int	dup proto((int));
extern int	dup2 proto((int /*old_fd*/, int /*new_fd*/));
extern long	lseek proto((int /*fd*/, long /*offset*/, int /*whence*/));
extern int	fchmod proto((int /*fd*/, int /*mode*/));
extern int	chown proto((const char *, int, int));

extern int	unlink proto((const char */*path*/));

#endif /* !POSIX_UNISTD */


#ifndef FULL_UNISTD

extern int	fsync proto((int));

/* BSD UNIX
 *
 * Note: in most systems, declaration of a non-existant function is
 * OK if the function is never actually called.  The parentheses around
 * the name prevent any macro expansion.  Of course, if the types in the
 * prototype are not declared, the compiler gets upset.
 */

# ifdef USE_BCOPY
extern void	UNMACRO(bcopy) proto((UnivConstPtr, UnivPtr, size_t));
extern void	UNMACRO(bzero) proto((UnivPtr, size_t));
# endif

#endif /* !FULL_UNISTD */

extern char	*mktemp proto((char *));

/* termcap */
#ifdef TERMCAP
# ifdef TERMINFO
extern char	*UNMACRO(tparm) proto((const char *, ...));
#  define	targ1(s, i)	tparm(s, i)
#  define	targ2(s, c, l)	tparm(s, c, l)
# else
extern char	*UNMACRO(tgoto) proto((const char *, int /*destcol*/, int /*destline*/));
#  define	targ1(s, i)	tgoto(s, 0, i)
#  define	targ2(s, c, l)	tgoto(s, c, l)
# endif
#endif
