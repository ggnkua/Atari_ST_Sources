/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: spawnl.c,v 1.1 88/01/29 17:29:54 m68k Exp $
 *
 * $Log:	spawnl.c,v $
 * Revision 1.1  88/01/29  17:29:54  m68k
 * Initial revision
 * 
 */
/*VARARGS2*/
int
spawnl(path, args)
	char	*path;
	char	*args;
{
	return spawnve(path, &args, (char *) 0);
}
