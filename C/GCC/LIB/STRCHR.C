/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: strchr.c,v 1.1 88/01/29 17:33:54 m68k Exp $
 *
 * $Log:	strchr.c,v $
 * Revision 1.1  88/01/29  17:33:54  m68k
 * Initial revision
 * 
 */
char	*
strchr(s, c)
	char	*s;
	char	c;
{
	do
		if (*s == c)
			return s;
	while (*s++);
	return (char *) 0;
}
