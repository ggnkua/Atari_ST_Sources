/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memset.c,v 1.1 88/01/29 17:33:43 m68k Exp $
 *
 * $Log:	memset.c,v $
 * Revision 1.1  88/01/29  17:33:43  m68k
 * Initial revision
 * 
 */
char	*
memset(s, c, n)
	char	*s;
	int	c;
	int	n;
{
	char	*save = s;

	while (--n >= 0)
		*s++ = c;
	return save;
}
