/* Gestion du Cookies Jar */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <cookies.h>

COOKIE *get_cookie(long id)
{
	COOKIE *p;
	p=fcookie();
	while (p)
	{
		if (p->ident==id)
			return p;
		p=ncookie(p);
	}
	return (COOKIE *)0;
}

COOKIE *fcookie(void)
{
	COOKIE *p;
	long stack;
	stack=Super(0L);
	p=*(COOKIE **)0x5a0;
	Super((void *)stack);
	if (!p)
		return (COOKIE *)0;
	return p;
}

COOKIE *ncookie(COOKIE *p)
{
	if (!p->ident)
		return 0;
	return ++p;
}

int add_cookie(COOKIE *cook)
{
	COOKIE *p;
	int i=0;
	p=fcookie();
	while (p)
	{
		if (p->ident==cook->ident)
			return -1;
		if (!p->ident)
		{
			if (i+1 < p->v.l)
			{
				*(p+1)=*p;
				*p=*cook;
				return 0;
			}
			else
				return -2;			/* pas de place -> probleme! */
		}
		i++;
		p=ncookie(p);
	}
	return -1;						/* pas de cookies jar ! */
}
