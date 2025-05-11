/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memcmp.c,v 1.1 88/01/29 17:33:31 m68k Exp $
 *
 * $Log:	memcmp.c,v $
 * Revision 1.1  88/01/29  17:33:31  m68k
 * Initial revision
 * 
 */
int
memcmp(s1, s2, n)
	char	*s1;
	char	*s2;
	int	n;
{
	char	c;

	while (--n >= 0)
		if (c = *s1++ - *s2++)
			return c;
	return 0;
}
