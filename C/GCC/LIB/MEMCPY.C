/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: memcpy.c,v 1.1 88/01/29 17:33:37 m68k Exp $
 *
 * $Log:	memcpy.c,v $
 * Revision 1.1  88/01/29  17:33:37  m68k
 * Initial revision
 * 
 */
char	*
memcpy(s1, s2, n)
	char	*s1;
	char	*s2;
	int	n;
{
	char	*save = s1;

	while (--n >= 0)
		*s1++ = *s2++;
	return save;
}
