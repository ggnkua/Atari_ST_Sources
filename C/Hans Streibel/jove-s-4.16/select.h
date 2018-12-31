/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef USE_SELECT_H
# include <sys/select.h>
#endif

#ifndef FD_SET		/* usually set in sys/types.h (AIX: sys/select.h) */

  typedef long fd_set;

# ifndef FD_SETSIZE
#  define FD_SETSIZE      32
# endif

# define FD_SET(fd, fdset)	(*(fdset) |= (1L << (fd)))
# define FD_CLR(fd, fdset)	(*(fdset) &= ~(1L << (fd))
# define FD_ISSET(fd, fdset)	(*(fdset) & (1L << (fd)))
# define FD_ZERO(fdset)		(*(fdset) = 0)

#endif /* FD_SET */

#ifndef FULL_UNISTD

# ifdef USE_PROTOTYPES
struct timeval;	/* forward declaration preventing prototype scoping */
# endif

extern int	UNMACRO(select) proto((int /*width*/,
	fd_set * /*readfds*/, fd_set * /*writefds*/, fd_set * /*exceptfds*/,
	struct timeval * /*timeout*/));

#endif

#ifdef USE_SELECT
extern fd_set	global_fd;
extern int	global_maxfd;
#endif
