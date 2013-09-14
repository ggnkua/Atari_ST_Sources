/* string.c */

/*
 *	string -- handy string functions
 *
 *----
 * <sometime> JWTittsler	Original stuff.
 * 13-Mar-1986 lmd		Some more functions.
 */


/*
 * Cat string2 onto string1
 *
 */
char *strcat(s1, s2)
register char *s1;
register char *s2;
{
	char *sptr;

	sptr = s1;
	while (*s1++)		/* find the end of s1 */
	    ;
	--s1;			/* back up so we point to the null */
	while (*s1++ = *s2++)	/* tack on s2 */
	    ;
	return sptr;
}


/*
 * Copy string2 to string1
 *
 */
char *strcpy(s1, s2)
register char *s1;
register char *s2;
{
    char *sptr;

    sptr = s1;
    while (*s1++ = *s2++)
	;
    return sptr;
}


/*
 * Replace occurances of `c1' in the string `s'
 * with `c2'.
 *
 */
char *strrep(s, c1, c2)
register char *s;
register char c1;
register char c2;
{
    char *sptr;

    sptr = s;
    while (*s)
	if(*s == c1)
	    *s++ = c2;
	    else ++s;;

    return sptr;
}


/*
 * Return uppercase of `c'
 *
 */
char toupper(c)
char c;
{
    if(c >= 'a' && c <= 'z')
	c -= 0x20;
    return c;
}


/*
 * Return `1' if `c' is an ascii space, tab, or newline.
 *
 */
isspace(c)
char c;
{
    if(c == 0x20 ||
       c == '\t' ||
       c == '\n') return 1;

    return 0;
}


/*
 * Return `0' if the strings match, `1' if they don't;
 * uppercase letters match their lowercase counterparts.
 *
 */
strcmp(st1, st2)
char *st1, *st2;
{
    register char *s1, *s2;

    s1 = st1;
    s2 = st2;
    while(*s1 && toupper(*s1) == toupper(*s2))
	++s1, ++s2;
    return (*s1 != *s2);
}
