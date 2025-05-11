/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: strlen.c,v 1.1 88/01/29 17:34:06 m68k Exp $
 *
 * $Log:	strlen.c,v $
 * Revision 1.1  88/01/29  17:34:06  m68k
 * Initial revision
 * 
 */
int
strlen(s)
	char	*s;
{
	int	n = 0;

	while (*s++)
		n++;
	return n;
}
