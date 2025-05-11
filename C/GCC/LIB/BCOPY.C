/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: bcopy.c,v 1.1 88/01/29 17:33:01 m68k Exp $
 *
 * $Log:	bcopy.c,v $
 * Revision 1.1  88/01/29  17:33:01  m68k
 * Initial revision
 * 
 */
void
bcopy(s1, s2, n)
	char	*s1;
	char	*s2;
	int	n;
{
	while (--n >= 0)
		*s2++ = *s1++;
}
