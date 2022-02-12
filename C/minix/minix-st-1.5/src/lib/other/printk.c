#include <lib.h>
#include <stdarg.h>

/* three compile time options:
 *	NO_LONGD	%d and %ld/%D are equal
 *	NO_FLOAT	abort on %e, %f and %g
 */

#define	NO_FLOAT

#ifdef NO_FLOAT
#define	MAXDIG		11	/* 32 bits in radix 8 */
#else
#define	MAXDIG		128	/* this must be enough */
#endif

_PROTOTYPE( void putc, (int ch));	/* user-supplied, should be putk */

PRIVATE _PROTOTYPE( char *_itoa, (char *p, unsigned num, int radix));
#ifndef NO_LONGD
PRIVATE _PROTOTYPE( char *ltoa, (char *p, unsigned long num, int radix));
#endif

PRIVATE char *_itoa(p, num, radix)
register char *p;
register unsigned num;
register radix;
{
  register i;
  register char *q;

  q = p + MAXDIG;
  do {
        i = (int) (num % radix);
        i += '0';
        if (i > '9') i += 'A' - '0' - 10;
        *--q = i;
  } while (num = num / radix);
  i = p + MAXDIG - q;
  do
        *p++ = *q++;
  while (--i);
  return(p);
}

#ifndef NO_LONGD
PRIVATE char *ltoa(p, num, radix)
register char *p;
register unsigned long num;
register radix;
{
  register i;
  register char *q;

  q = p + MAXDIG;
  do {
	i = (int) (num % radix);
	i += '0';
	if (i > '9') i += 'A' - '0' - 10;
	*--q = i;
  } while (num = num / radix);
  i = p + MAXDIG - q;
  do
	*p++ = *q++;
  while (--i);
  return(p);
}

#endif

#ifndef NO_FLOAT
extern char *_ecvt();
extern char *_fcvt();
extern char *_gcvt();
#endif

#define	GETARG(typ)	va_arg(args, typ)

void printk(fmt, arg1)
register char *fmt;
int arg1;
{
  char buf[MAXDIG + 1];		/* +1 for sign */
  register int *args = &arg1;
  register char *p;
  register char *s;
  register c;
  register i;
  register short width;
  register short ndigit;
  register ndfnd;
  register ljust;
  register zfill;
#ifndef NO_LONGD
  register lflag;
  register long l;
#endif

  for (;;) {
	c = *fmt++;
	if (c == 0) return;
	if (c != '%') {
		putc(c);
		continue;
	}
	p = buf;
	s = buf;
	ljust = 0;
	if (*fmt == '-') {
		fmt++;
		ljust++;
	}
	zfill = ' ';
	if (*fmt == '0') {
		fmt++;
		zfill = '0';
	}
	for (width = 0;;) {
		c = *fmt++;
		if (c >= '0' && c <= '9')
			c -= '0';
		else if (c == '*')
			c = GETARG(int);
		else
			break;
		width *= 10;
		width += c;
	}
	ndfnd = 0;
	ndigit = 0;
	if (c == '.') {
		for (;;) {
			c = *fmt++;
			if (c >= '0' && c <= '9')
				c -= '0';
			else if (c == '*')
				c = GETARG(int);
			else
				break;
			ndigit *= 10;
			ndigit += c;
			ndfnd++;
		}
	}
#ifndef NO_LONGD
	lflag = 0;
#endif
	if (c == 'l' || c == 'L') {
#ifndef NO_LONGD
		lflag++;
#endif
		if (*fmt) c = *fmt++;
	}
	switch (c) {
	    case 'X':
#ifndef NO_LONGD
		lflag++;
#endif
	    case 'x':
		c = 16;
		goto oxu;
	    case 'U':
#ifndef NO_LONGD
		lflag++;
#endif
	    case 'u':
		c = 10;
		goto oxu;
	    case 'O':
#ifndef NO_LONGD
		lflag++;
#endif
	    case 'o':
		c = 8;
  oxu:
#ifndef NO_LONGD
		if (lflag) {
			p = ltoa(p, (unsigned long)GETARG(long), c);
			break;
		}
#endif
		p = _itoa(p, (unsigned int)GETARG(int), c);
		break;
	    case 'D':
#ifndef NO_LONGD
		lflag++;
#endif
	    case 'd':
#ifndef NO_LONGD
		if (lflag) {
			if ((l = GETARG(long)) < 0) {
				*p++ = '-';
				l = -l;
			}
			p = ltoa(p, (unsigned long)l, 10);
			break;
		}
#endif
		if ((i = GETARG(int)) < 0) {
			*p++ = '-';
			i = -i;
		}
		p = _itoa(p, (unsigned int)i, 10);
		break;
#ifdef NO_FLOAT
	    case 'e':
	    case 'f':
	    case 'g':
		zfill = ' ';
		*p++ = '?';
		break;
#else
	    case 'e':
		if (ndfnd == 0) ndigit = 6;
		ndigit++;
		p = _ecvt(p, GETARG(double), ndigit);
		break;
	    case 'f':
		if (ndfnd == 0) ndigit = 6;
		p = _fcvt(p, GETARG(double), ndigit);
		break;
	    case 'g':
		if (ndfnd == 0) ndigit = 6;
		p = _gcvt(p, GETARG(double), ndigit);
		break;
#endif
	    case 'c':
		zfill = ' ';
		*p++ = GETARG(int);
		break;
	    case 's':
		zfill = ' ';
		if ((s = GETARG(char *)) == 0) s = "(null)";
		if (ndigit == 0) ndigit = 32767;
		for (p = s; *p && --ndigit >= 0; p++);
		break;
	    default:	*p++ = c;	  		break;
	}
	i = p - s;
	if ((width -= i) < 0) width = 0;
	if (ljust == 0) width = -width;
	if (width < 0) {
		if (*s == '-' && zfill == '0') {
			putc(*s++);
			i--;
		}
		do
			putc(zfill);
		while (++width != 0);
	}
	while (--i >= 0) putc(*s++);
	while (width) {
		putc(zfill);
		width--;
	}
  }
}
