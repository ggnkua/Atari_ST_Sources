/* 
 * putw - write an word on a stream
 */
/* $Header: putw.c,v 1.1 89/12/18 14:40:15 eck Exp $ */

#include	<stdio.h>

_PROTOTYPE(int putw, (int w, FILE *stream ));

int
putw(w, stream)
int w;
register FILE *stream;
{
	register int cnt = sizeof(int);
	register char *p = (char *) &w;

	while (cnt--) {
		putc(*p++, stream);
	}
	if (ferror(stream)) return EOF;
	return w;
}
