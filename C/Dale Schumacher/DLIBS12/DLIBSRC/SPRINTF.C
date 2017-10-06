#include <stdarg.h>

static unsigned int sputc(c, s)
	char c, **s;
	{
	return(*(*s)++ = c);
	}

sprintf(buf, fmt, arg)
	char *buf;
	char *fmt;
	int arg;
	{
	register int n;
	register char *p = buf;

	n = _printf(&buf, sputc, fmt, &arg);
	p[n] = '\0';		/* always tie of the string */
	return(n);
	}

vsprintf(buf, fmt, args)
	char *buf;
	char *fmt;
	va_list args;
	{
	register int n;
	register char *p = buf;

	n = _printf(&buf, sputc, fmt, args);
	p[n] = '\0';		/* always tie of the string */
	return(n);
	}
