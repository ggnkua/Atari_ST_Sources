/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: bzerol.c,v 1.1 88/01/29 17:33:09 m68k Exp $
 *
 * $Log:	bzerol.c,v $
 * Revision 1.1  88/01/29  17:33:09  m68k
 * Initial revision
 * 
 */
void
bzerol(s, n)
	char	*s;
	long	n;
{
	while (--n >= 0)
		*s++ = 0;
}
