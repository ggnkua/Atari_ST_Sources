#include <stdarg.h>
#include <stdio.h>
#include <limits.h>
#include "lib.h"

static int sputc __PROTO((int ch, FILE *fp));

static int
sputc (ch, fp)
     int ch;
     FILE *fp;
{
  char **bufp = (char **) fp;
  *(*bufp)++ = ch;
  return ((int)ch) & 0xff;
}

#ifdef __STDC__
int sprintf(char *buf, const char *fmt, ...)
#else
int sprintf(buf, fmt)
	char *buf;
	const char *fmt;
#endif
	{
	register int n;
	va_list argp;

	va_start(argp, fmt);
	n = _doprnt(sputc, (FILE *) &buf, fmt, argp);
	*buf = '\0';		/* always tie of the string */
	return(n);
	}

int vsprintf(buf, fmt, args)
	char *buf;
	const char *fmt;
	va_list args;
	{
	register int n;
	n = _doprnt(sputc, (FILE *) &buf, fmt, args);
	*buf = '\0';		/* always tie of the string */
	return(n);
	}
