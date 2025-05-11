/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: ffs.c,v 1.1 88/01/29 17:33:12 m68k Exp $
 *
 * $Log:	ffs.c,v $
 * Revision 1.1  88/01/29  17:33:12  m68k
 * Initial revision
 * 
 */
int
ffs(n)
	int	n;
{
	int	i = 0;

	if (n)
		for (; !(n & 1) ; i++)
			n >>= 1;
	return i;
}
