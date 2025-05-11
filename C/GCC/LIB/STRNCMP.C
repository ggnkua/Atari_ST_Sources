/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: strncmp.c,v 1.1 88/01/29 17:34:12 m68k Exp $
 *
 * $Log:	strncmp.c,v $
 * Revision 1.1  88/01/29  17:34:12  m68k
 * Initial revision
 * 
 */
int
strncmp(s1, s2, n)
	char	*s1;
	char	*s2;
	int	n;
{
	while (--n >= 0 && (*s1 == *s2++))
		if (!*s1++)
			return 0;
	return n < 0 ? 0 : *s1 - *--s2;
}
