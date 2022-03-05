#include <stdio.h>
#include <stdarg.h>

extern	int	fputc();

fprintf(fp, fmt, arg)
	FILE *fp;
	char *fmt;
	int arg;
	{
	return(_printf(fp, fputc, fmt, &arg));
	}

vfprintf(fp, fmt, args)
	FILE *fp;
	char *fmt;
	va_list args;
	{
	return(_printf(fp, fputc, fmt, args));
	}

printf(fmt, arg)
	char *fmt;
	int arg;
	{
	return(_printf(stdout, fputc, fmt, &arg));
	}

vprintf(fmt, args)
	char *fmt;
	va_list args;
	{
	return(_printf(stdout, fputc, fmt, args));
	}
