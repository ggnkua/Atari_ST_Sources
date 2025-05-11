/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: close.c,v 1.2 88/01/29 17:30:58 m68k Exp $
 *
 * $Log:	close.c,v $
 * Revision 1.1  88/01/29  17:30:58  m68k
 * Initial revision
 * 
 * 1.2	jrd
 *
 */
#include	<osbind.h>
#include	<file.h>

#ifdef DEBUG
extern int stderr;
#endif

int close(fd)
	int	fd;
{
	extern	int	errno;
	int		rval;

	if ((rval = Fclose(fd)) < 0) {
		errno = rval;
		rval = -1;
	if ((fd >= 0) && (fd < N_HANDLES))
		__handle_stat[fd] = FH_UNKNOWN;
	}
#ifdef DEBUG
	fprintf(stderr, "close(%d)->%d\n", fd, rval);
#endif
	return rval;
}
