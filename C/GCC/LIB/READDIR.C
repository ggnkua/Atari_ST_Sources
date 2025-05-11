/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A public domain implementation of BSD directory routines for MS-DOS/atari.
 *  Written by Michael Rendell ({uunet,utai}michael@garfield), August 1897
 *
 * $Header: readdir.c,v 1.2 88/01/29 18:04:01 m68k Exp $
 *
 * jrd 1.2
 *
 * $Log:	readdir.c,v $
 * Revision 1.1  88/01/29  18:04:01  m68k
 * Initial revision
 * 
 */

#include <types.h>
#include <dir.h>
#include <string.h>

#ifndef	NULL
# define	NULL	0
#endif	/* NULL */

struct direct	*
readdir(dirp)
	DIR	*dirp;
{
	static	struct direct	dp;
	
	if (dirp->dd_cp == (struct _dircontents *) NULL)
		return (struct direct *) NULL;
	dp.d_namlen = dp.d_reclen =
		strlen(strcpy(dp.d_name, dirp->dd_cp->_d_entry));
	dp.d_ino = 0;
	dirp->dd_cp = dirp->dd_cp->_d_next;
	dirp->dd_loc++;

	return &dp;
}
