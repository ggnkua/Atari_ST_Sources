/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: getwd.c,v 1.1 88/01/29 17:29:47 m68k Exp $
 *
 * $Log:	getwd.c,v $
 * Revision 1.1  88/01/29  17:29:47  m68k
 * Initial revision
 *
 * jrd 1.2
 *   initial ver was all fucked.  re-wrote.
 * 
 */
#include	<osbind.h>
#include	<string.h>
#include	<param.h>

char	*
getwd(buf)
	char	*buf;
{
	extern	char	*sys_error();

	int		rval;
	int		drv;

	drv = Dgetdrv();
	if ((rval = Dgetpath(buf + 2, drv + 1)) < 0)
		{
		(void) strncpy(buf, sys_error(rval), MAXPATHLEN);
		return (char *) 0;
		}
	*buf = drv + 'A';
	buf[1] = ':';

	return buf;
}
