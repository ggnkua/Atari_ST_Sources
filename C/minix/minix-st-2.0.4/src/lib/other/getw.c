/*
 * getw - read a word from a stream
 */
/* $Header: getw.c,v 1.1 89/12/18 14:39:51 eck Exp $ */

#include	<stdio.h>

_PROTOTYPE(int getw, (FILE *stream ));

int getw(stream)
register FILE *stream;
{
	register int cnt = sizeof(int);
	int w;
	register char *p = (char *) &w;

	while (cnt--) {
		*p++ = getc(stream);
	}
	if (feof(stream) || ferror(stream)) return EOF;
	return w;
}
