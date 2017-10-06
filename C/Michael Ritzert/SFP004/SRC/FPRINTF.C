/* from Dale Schumacher's dLibs */

#define __SRC__	/* keep compiler happy about protos */
#include <stdio.h>
#include <stdarg.h>

#ifdef __STDC__
extern	int	fputc(int, FILE *);
#else
extern	int	fputc();
#endif


fprintf(fp, fmt, arg)
	FILE *fp;
	const char *fmt;
	int arg;
	{
	return(_doprnt(fp, fmt, &arg));
	}

vfprintf(fp, fmt, args)
	FILE *fp;
	const char *fmt;
	va_list args;
	{
	return(_doprnt(fp, fmt, args));
	}

printf(fmt, arg)
	const char *fmt;
	int arg;
	{
	return(_doprnt(stdout, fmt, &arg));
	}

vprintf(fmt, args)
	const char *fmt;
	va_list args;
	{
	return(_doprnt(stdout, fmt, args));
	}

/* This is used by the `assert' macro.  */
void __eprintf (string, expression, line, filename)
char *string;
char *expression;
long line;
char *filename; /* note if STDC then filename is already in string */
{
    (void)_doprnt(stderr, string, &expression);
}
