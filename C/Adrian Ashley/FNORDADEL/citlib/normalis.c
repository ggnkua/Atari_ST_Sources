/*
 * normalis.c -- string normalisation and stuff
 *
 * 90Aug27 AA	Split off from libmisc.c
 */

#include <ctype.h>

void
normalise(s)
char *s;
{
    char *pc, *base;

    for (base=pc=s; isspace(*s); ++s)		/* eat leading spaces	*/
	;

    while (*s)					/* copy the string over	*/
	if (*s == ' ' && s[1] == ' ')		/* killing runs of ` 's	*/
	    s++;
	else
	    *pc++ = *s++;
    *pc = 0;

    while (pc > base && isspace(pc[-1]))
	*--pc = 0;
}

/* copystring(): copy a string of length size and make it null-terminated. */
void
copystring(s1,s2,size)
char *s1, *s2;
{
    (void)strncpy(s1, s2, size);
    s1[size-1] = 0;
}
