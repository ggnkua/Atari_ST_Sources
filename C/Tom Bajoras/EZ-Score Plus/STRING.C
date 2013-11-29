overlay "megamax"

#include <string.h>
#include <stdio.h>

char *strcat(s1,s2)
register char *s1, *s2;
{
    char *result = s1;

    for ( ; *s1++; ) ;
    --s1;
    while ((*s1++ = *s2++));
    return result;
}

char *strncat(s1, s2, n)
register char *s1, *s2;
register int n;
{
    char *result = s1;

    for ( ; *s1++; ) ;
    --s1;
    while (n-- && (*s1++ = *s2++)) ;
    *s1 = 0;
    return result;
}

int strcmp(s1, s2)
register char *s1, *s2;
{
    for ( ; *s1 && *s1 == *s2; ) {
	++s1; ++s2;
    }
    return *s1 - *s2;
}

/*
 * Predecrement because on the last character, no test is needed.
 */
int strncmp(s1, s2, n)
register char *s1, *s2;
register int n;
{
    while (--n && *s1 && *s1 == *s2) {
	++s1; ++s2;
    }
    return *s1 - *s2;
}

char *strcpy(s1, s2)
char *s1, *s2;
{
	asm {
			move.l	s1(A6), A0
			move.l	A0, D0
			move.l	s2(A6), A1
	loop:
			move.b	(A1)+, (A0)+
			bne		loop
	}
}

char *strncpy(s1, s2, n)
register char *s1, *s2;
register int n;
{
    char *result = s1;

    while (n-- && (*s1++ = *s2++));
    return result;
}

int strlen(s)
register char *s;
{
    register char *temp;

    for (temp = s; *s; s++) ;
    return s - temp;
}

char *index(s, c)
register char *s;
register int c;
{
    register char temp;

    for ( ; (temp = *s) && temp != c; s++) ;
    return temp ? s : NULL;
}

char *rindex(s, c)
register char *s;
register int c;
{
    register char *p = 0;
    register char temp;

    for ( ; temp = *s; s++)
	if (temp == c)
	    p = s;
    return p;
}
