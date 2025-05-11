/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: bcopyl.c,v 1.1 88/01/29 17:33:03 m68k Exp $
 *
 * $Log:	bcopyl.c,v $
 * Revision 1.1  88/01/29  17:33:03  m68k
 * Initial revision
 * 
 */
void
bcopyl(s1, s2, n)
	char	*s1;
	char	*s2;
	long	n;
{
	while (--n >= 0)
		*s2++ = *s1++;
}
