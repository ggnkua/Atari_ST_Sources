/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A public domain implementation of BSD directory routines for MS-DOS/atari.
 *  Written by Michael Rendell ({uunet,utai}michael@garfield), August 1897
 *
 * $Header: seekdir.c,v 1.2 88/01/29 18:04:04 m68k Exp $
 *
 * jrd 1.2
 *
 * $Log:	seekdir.c,v $
 * Revision 1.1  88/01/29  18:04:04  m68k
 * Initial revision
 * 
 */

#ifdef gem
# include <types.h>
# include <dir.h>
#else /* !gem */
# include <sys/types.h>
# include <sys/dir.h>
#endif	/* gem */

void
seekdir(dirp, off)
	DIR	*dirp;
	long	off;
{
	long			i = off;
	struct _dircontents	*dp;

	if (off < 0)
		return;
	for (dp = dirp->dd_contents ; --i >= 0 && dp ; dp = dp->_d_next)
		;
	dirp->dd_loc = off - (i + 1);
	dirp->dd_cp = dp;
}
