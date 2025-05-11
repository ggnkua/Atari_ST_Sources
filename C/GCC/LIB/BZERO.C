/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: bzero.c,v 1.1 88/01/29 17:33:06 m68k Exp $
 *
 * $Log:	bzero.c,v $
 * Revision 1.1  88/01/29  17:33:06  m68k
 * Initial revision
 * 
 */
void
bzero(s, n)
	char	*s;
	int	n;
{
	while (--n >= 0)
		*s++ = 0;
}
