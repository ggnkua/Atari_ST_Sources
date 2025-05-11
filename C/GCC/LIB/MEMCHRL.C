/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memchrl.c,v 1.1 88/01/29 17:33:29 m68k Exp $
 *
 * $Log:	memchrl.c,v $
 * Revision 1.1  88/01/29  17:33:29  m68k
 * Initial revision
 * 
 */
#define	NULL	0

char	*
memchrl(s, c, n)
	char	*s;
	int	c;
	long	n;
{
	while (--n >= 0)
		if (*s++ == c)
			return s - 1;
	return (char *) NULL;
}
