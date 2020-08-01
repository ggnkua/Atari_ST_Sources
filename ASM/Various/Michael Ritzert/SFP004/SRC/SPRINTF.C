#define __SRC__
#include <stdarg.h>
#include <stdio.h>
#include <limits.h>

#if 0
static int sputc(c, s)
	int c;
	char **s;
	{
	return(*(*s)++ = c);
	}
#endif

sprintf(buf, fmt, arg)
	char *buf;
	const char *fmt;
	int arg;
	{
	register int n;
	FILE sf =
	{0L, (unsigned char *)buf, (unsigned char *)buf,
	     _IOWRT|_IOBIN|_IOSTRING|_IOFBF, 0, LONG_MAX,'\0'};

	n = _doprnt(&sf, fmt, &arg);
	*(sf._ptr) = '\0';		/* always tie of the string */
	return(n);
	}

vsprintf(buf, fmt, args)
	char *buf;
	const char *fmt;
	va_list args;
	{
	register int n;
	FILE sf =
	{0L, (unsigned char *)buf, (unsigned char *)buf,
	     _IOWRT|_IOBIN|_IOSTRING|_IOFBF, 0, LONG_MAX,'\0'};

	n = _doprnt(&sf, fmt, args);
	*(sf._ptr) = '\0';		/* always tie of the string */
	return(n);
	}
