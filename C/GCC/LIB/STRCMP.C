/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: strcmp.c,v 1.1 88/01/29 17:33:57 m68k Exp $
 *
 * $Log:	strcmp.c,v $
 * Revision 1.1  88/01/29  17:33:57  m68k
 * Initial revision
 * 
 */
int
strcmp(s1, s2)
	char	*s1;
	char	*s2;
{
	if (!s1 && s2) return(-1);
	if (!s2 && s1) return(1);
	if (!s1 && !s2) return(0);
	while (*s1 == *s2++)
		if (!*s1++)
			return 0;
	return *s1 - *--s2;
}
