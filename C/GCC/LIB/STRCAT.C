/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: strcat.c,v 1.1 88/01/29 17:33:51 m68k Exp $
 *
 * $Log:	strcat.c,v $
 * Revision 1.1  88/01/29  17:33:51  m68k
 * Initial revision
 * 
 */
char	*
strcat(s1, s2)
	char	*s1;
	char	*s2;
{
	char	*saves1 = s1;

	while (*s1++)
		;
	s1--;
	while (*s1++ = *s2++)
		;
	return saves1;
}
