/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: spawnv.c,v 1.1 88/01/29 17:30:01 m68k Exp $
 *
 * $Log:	spawnv.c,v $
 * Revision 1.1  88/01/29  17:30:01  m68k
 * Initial revision
 * 
 */
int
spawnv(path, argv)
	char	*path;
	char	**argv;
{
	return spawnve(path, argv, (char *) 0);
}
