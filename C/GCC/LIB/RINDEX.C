/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: rindex.c,v 1.1 88/01/29 17:33:49 m68k Exp $
 *
 * $Log:	rindex.c,v $
 * Revision 1.1  88/01/29  17:33:49  m68k
 * Initial revision
 * 
 */
char	*
rindex(s, c)
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
