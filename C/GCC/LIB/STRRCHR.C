/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: strrchr.c,v 1.1 88/01/29 17:34:17 m68k Exp $
 *
 * $Log:	strrchr.c,v $
 * Revision 1.1  88/01/29  17:34:17  m68k
 * Initial revision
 * 
 */
char	*
strrchr(s, c)
	char	*s;
	char	c;
{
	int	n = 0;

	while (*s++)
		n++;
	while (--n >= 0)
		if (*--s == c)
			return s;
	return (char *) 0;
}
