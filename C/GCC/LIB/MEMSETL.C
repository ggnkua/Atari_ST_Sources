/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memsetl.c,v 1.1 88/01/29 17:33:46 m68k Exp $
 *
 * $Log:	memsetl.c,v $
 * Revision 1.1  88/01/29  17:33:46  m68k
 * Initial revision
 * 
 */
char	*
memsetl(s, c, n)
	char	*s;
	int	c;
	long	n;
{
	char	*save = s;

	while (--n >= 0)
		*s++ = c;
	return save;
}
