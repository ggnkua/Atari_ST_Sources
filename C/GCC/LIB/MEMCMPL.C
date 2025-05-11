/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memcmpl.c,v 1.1 88/01/29 17:33:34 m68k Exp $
 *
 * $Log:	memcmpl.c,v $
 * Revision 1.1  88/01/29  17:33:34  m68k
 * Initial revision
 * 
 */
int
memcmpl(s1, s2, n)
	char	*s1;
	char	*s2;
	long	n;
{
	char	c;

	while (--n >= 0)
		if (c = *s1++ - *s2++)
			return c;
	return 0;
}
