/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: ffsl.c,v 1.1 88/01/29 17:33:15 m68k Exp $
 *
 * $Log:	ffsl.c,v $
 * Revision 1.1  88/01/29  17:33:15  m68k
 * Initial revision
 * 
 */
int
ffsl(n)
	long	n;
{
	int	i = 0;

	if (n)
		for (; !(n & 1) ; i++)
			n >>= 1;
	return i;
}
