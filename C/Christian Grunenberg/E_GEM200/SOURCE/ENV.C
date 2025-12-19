
#ifdef __MINT_LIB__
#include <basepage.h>
#define _BasPag	_base
#endif

#include "e_gem.h"

static char	*envbeg = 0l;

static void copyenv(char *,char *);
static char *getvar(const char *);

char *getenv(const char *var)
{
	reg char *s = _BasPag->p_env;
	reg const char *v;
	
	if (s)
		while (*s)
		{
			for (v=var; (*s) && (*s++ == *v++); )
				if ((*s == '=') && (*v == '\0'))
					return(++s);
			while (*s++);
		}
	return(NULL);
}

int	putenv(const char *entry)
{
	reg char *d,*s,*e;
	reg long envlen = 0;
	reg unsigned l,new;
	
	s = _BasPag->p_env;
	if ((s != NULL) && (*s))
	{
		while (*s)
		{
			while (*s++);
		}
		envlen = s - _BasPag->p_env;
	}
	
	if (envbeg == NULL)
	{
		s = _BasPag->p_env;
		if ((envbeg = malloc (envlen + 2) ) == NULL)
			return(FALSE);
		if ((s != NULL) && (*s))
			copyenv (s, envbeg);
		else
			envbeg[0] = envbeg[1] = '\0';
		_BasPag->p_env = envbeg;
	}
	
	if ((d = s = getvar(entry)) != NULL)
	{
		while (*s++);
		envlen -= s - d;
		
		if (*s)
			copyenv (s, d);
		else
			d[0] = d[1] = '\0';
	}
	
	for (e = (char *) entry, new = l = 0; *e++; l++)
		if (*e == '=')
			new = l;
	
	if (new)
		envlen += l + 1;
		
	if ((d = malloc (envlen + 2)) == NULL)
		return (FALSE);
	
	copyenv(envbeg, d);
	free(envbeg);
	envbeg = d;
	
	if (new)
	{
		while (*d)
			while (*d++);
		e = (char *) entry;
		while ((*d++ = *e++) != 0);
		*d = 0;
	}
	
	_BasPag->p_env = envbeg;
	return (TRUE);
}

static char *getvar(const char *var)
{
	reg char *r,*s = envbeg;
	reg const char *v;
	
	while (*s)
	{
		for ( r = s, v = var; (*s) && (*s++ == *v++); )
			if ((*s == '=') && ((*v == '=') || (*v == '\0')))
				return (r);
		while (*s++);
	}
	return (NULL);
}

static void copyenv(char *s, char *d)
{
	do
	{
		while ((*d++ = *s++) != '\0');
	} while (*s);
	*d = '\0';
}
