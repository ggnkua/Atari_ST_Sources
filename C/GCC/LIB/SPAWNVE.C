/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: spawnve.c,v 1.1 88/01/29 17:30:04 m68k Exp $
 *
 * $Log:	spawnve.c,v $
 * Revision 1.1  88/01/29  17:30:04  m68k
 * Initial revision
 * 
 */
#include	<param.h>
#include	<osbind.h>

static	char	cmd[NCARGS+1];
static	char	env[1024];		/* this should be enough */

int
spawnve(path, argv, envp)
	char	*path;
	char	**argv;
	char	**envp;
{
	extern	int	errno;

	int		len = NCARGS;
	char		*p;
	char		*s;

	bzero(s = cmd, sizeof(cmd));
	if (argv && *argv)
		while (*++argv) {
			for (p = *argv ; --len >= 0 && *p ; )
				*s++ = *p++;
			if (len >= 0)
				*s++ = ' ';
			else
				break;
		}
	if (envp && *envp) {
		len = sizeof(env) - 2;
		s = env;
		while (*++argv) {
			for (p = *envp ; --len >= 0 && *p ; )
				*s++ = *p++;
			if (len >= 0)
				*s++ = '\0';
			else
				break;
		}
		*s++ = '\0';
		*s = '\0';
	}

	if ((len = Pexec(PE_LOADGO, path, cmd, envp ? env : (char *) 0))
		< 0)
	{
		errno = -len;
		len = -1;
	}
	return len;
}
