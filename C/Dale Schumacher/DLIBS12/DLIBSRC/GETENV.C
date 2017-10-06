#include <stdio.h>

extern char	*_envp;

static char *findenv(var)
	register char *var;
/*
 *	INTERNAL FUNCTION.  This functions attempts to locate <var> in
 *	the environment.  If <var> is not found, NULL is returned.  If
 *	the environment is NULL, NULL is returned.  If <var> is found,
 *	a pointer to the beginning of <var> in the environment is returned.
 *	BOTH MS-DOS AND TOS ENVIRONMENT FORMATS ARE ACCOMODATED.
 */
	{
	register char *p;
	register int len;

	if((p = _envp) == NULL)
		return(NULL);
	len = strlen(var);
	while(*p)
		{
		if((p[len] == '=') && !strncmp(p, var, len))
			return(p);
		while(*p++)		/* move to next arg */
			;
		}
	return(NULL);
	}

char *getenv(var)
	register char *var;
	{
	register char *p, *q;
	register int len;

	len = strlen(var);
	if(p = findenv(var))
		{
		p += (len + 1);
		if(*p == '\0')		/* TOS env format or empty value */
			{
			q = p+1;
			if(*q == '\0')		/* empty value + end of env */
				return(p);
			while(*q && (*q != '='))
				++q;
			if(*q)			/* empty value */
				return(p);
			else			/* TOS env format */
				return(p+1);
			}
		}
	return(p);
	}
