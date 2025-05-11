/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: spawnle.c,v 1.1 88/01/29 17:29:57 m68k Exp $
 *
 * $Log:	spawnle.c,v $
 * Revision 1.1  88/01/29  17:29:57  m68k
 * Initial revision
 * 
 */
/*VARARGS3*/
int
spawnle(path, args)
	char	*path;
	char	*args;
{
	char	**envp;

	for (envp = &args ; *envp ; envp++)
		;
	return spawnve(path, &args, envp);
}
