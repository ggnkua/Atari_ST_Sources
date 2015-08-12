/*
 *  Match keyword
 *
 */
#include "as.h"

extern char tolowertab[];	/* convert uppercase ==> lowercase */


/*
 *  Check to see if the string is a keyword.
 *  Returns -1, or a value from the 'accept[]' table.
 *
 */
kmatch(p, base, check, tab, accept)
register char *p;
register int *base;
register int *check;
int *tab;
int *accept;
{
	register int state;
	register int j;

	for (state = 0; state >= 0;)
	{
		j = base[state] + tolowertab[*p];
		if (check[j] != state) /* reject, character doesn't match */
		{
			state = -1;	/* no match */
			break;
		}

		if (!*++p)
		{			/* must accept or reject at EOS */
			state = accept[j]; /* (-1 on no terminal match) */
			break;
		}
		state = tab[j];
	}

	return state;
}
