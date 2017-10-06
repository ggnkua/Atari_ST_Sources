#include <stdio.h>
#include <basepage.h>

extern char	*_envp;

#define	ENVSIZ	(1<<12)			/* 4K environment string */

static	int	envset = FALSE;		/* local env created? */

int putenv(entry)
	char *entry;
/*
 *	Add <entry> to the environment.  <entry> can be any of the following
 *	forms:
 *		<VARIABLE>		remove <VARIABLE>
 *		<VARIABLE>=		set <VARIABLE> to a null value
 *		<VARIABLE>=<value>	set <VARIABLE> to <value>
 */
	{
	register char *p, *q, *t, c;
	register int len;
	char *malloc(), *getenv();

	if(!envset)			/* no local env */
		{
		if((p = malloc(ENVSIZ)) == NULL)
			return(FALSE);
		q = _envp;
		_envp = p;
		envset = TRUE;
		if(q)
			{
			while(*q)
				while(*p++ = *q++)
					;
			}
		else
			*p++ = '\0';
		*p++ = '\0';
		*p = 0xFF;
		}
	for(t=entry; (c = *t) && (c != '='); ++t)
		;
	*t = '\0';
	if(p = getenv(entry))		/* remove old var */
		{
		q = p;
		while(*q++)			/* find end of old val */
			;
		p -= (len = strlen(entry));
		while(strncmp(--p, entry, len))	/* find start of old var */
			;
		while(*q)			/* copy environment tail */
			while(*p++ = *q++)
				;
		*p++ = '\0';			/* tie off environment */
		*p = 0xFF;
		}
	if(c == '=')					/* install new var */
		{
		p = _envp;
		while(*p)		/* find end of env */
			while(*p++)
				;
		*t = c;
		q = entry;
		while(*p++ = *q++)		/* copy new entry */
			;
		*p++ = '\0';			/* tie off environment */
		*p = 0xFF;
		}
	_base->p_env = _envp;		/* update basepage pointer */
	return(TRUE);
	}
