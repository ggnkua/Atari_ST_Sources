/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A public domain implementation of BSD directory routines for MS-DOS/atari.
 *  Written by Michael Rendell ({uunet,utai}michael@garfield), August 1897
 *
 * $Header: closedir.c,v 1.2 88/01/29 18:03:55 m68k Exp $
 *
 * $Log:	closedir.c,v $
 *
 * jrd 1.2
 *
 * Revision 1.1  88/01/29  18:03:55  m68k
 * Initial revision
 * 
 */
#include <types.h>
#include <dir.h>
#include <memory.h>

static	void	free_dircontents();

void
closedir(dirp)
	DIR	*dirp;
{
	free_dircontents(dirp->dd_contents);
	free((char *) dirp);
}


static	void
free_dircontents(dp)
	struct	_dircontents	*dp;
{
	struct _dircontents	*odp;

	while (dp) {
		if (dp->_d_entry)
			free(dp->_d_entry);
		dp = (odp = dp)->_d_next;
		free((char *) odp);
	}
}
