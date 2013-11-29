#include <stdio.h>

char *gets(s)
register char *s;
{
    register char *result = s, c;

    while ((c = getc(stdin)) != EOF)
	if (c == '\n') break;
	else
	    *s++ = c;
    *s = 0;
    return (c == EOF ? NULL : result);
}

char *fgets(s, n, iop)
register char *s;
int n;
FILE *iop;
{
    int c;
    register char *cs;

    cs = s;
    while (--n > 0 && (c = getc(iop)) != EOF)
	if ((*cs++ = c) == '\n')
	    break;
    *cs = '\0';
    return ((c == EOF && cs == s) ? NULL : s);
}
