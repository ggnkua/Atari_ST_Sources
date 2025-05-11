/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A public domain implementation of BSD directory routines for MS-DOS/atari.
 *  Written by Michael Rendell ({uunet,utai}michael@garfield), August 1897
 *
 * $Header: telldir.c,v 1.2 88/01/29 18:04:07 m68k Exp $
 *
 * jrd 1.2
 *
 * $Log:	telldir.c,v $
 * Revision 1.1  88/01/29  18:04:07  m68k
 * Initial revision
 * 
 */

#include <types.h>
#include <dir.h>

long
telldir(dirp)
	DIR	*dirp;
{
	return dirp->dd_loc;
}
