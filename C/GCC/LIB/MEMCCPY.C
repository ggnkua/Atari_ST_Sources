/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memccpy.c,v 1.1 88/01/29 17:33:20 m68k Exp $
 *
 * $Log:	memccpy.c,v $
 * Revision 1.1  88/01/29  17:33:20  m68k
 * Initial revision
 * 
 */
#define	NULL	0

char	*
memccpy(s1, s2, c, n)
	char	*s1;
	char	*s2;
	int	c;
	int	n;
{
	while (--n >= 0)
		if ((*s2++ = *s1++) == c)
			break;
	return n < 0 ? (char *) NULL : s1;
}
