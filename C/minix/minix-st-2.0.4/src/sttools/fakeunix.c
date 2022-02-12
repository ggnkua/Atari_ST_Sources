#ifdef __GNUC__
#include <unixlib.h>
#include <osbind.h>

#else

extern long	gemdos();

#define	creat(a,b)	(int)gemdos(0x3c,a,0)
#define	open(a,b)	(int)gemdos(0x3d,a,b)
#define	close(a)	(int)gemdos(0x3e,a)
#define	read(a,b,c)	(int)gemdos(0x3f,a,(long)((unsigned)c),b)
#define	write(a,b,c)	(int)gemdos(0x40,a,(long)((unsigned)c),b)
#define	lseek(a,b,c)	     gemdos(0x42,b,a,c)
#define	free(a)		(int)gemdos(0x49,a)
#define	exit(a)		     gemdos(0x4c,a)
#define	malloc		myalloc

char *myalloc(siz)
unsigned siz;
{
	long n;

	n = gemdos(0x48,(long)siz);
	if (n < 0)
		return((char *)0);
	return((char *)n);
}

abort()
{
	printf("Abort\n");
	exit(-1);
}

_outc(c)
{
	if (c == '\n')
		_outc('\r');
	gemdos(0x02,c);
}

printf(f, a) char *f; {
	_doprnt(f, &a, _outc);
}

/*--------------------------------------------------------------------*/

#define	NO_FLOAT

/* @(#)doprnt.c	1.1 */
/*
 * C version of doprnt.s for ACK
 * three compile time options:
 *	STACKUP		fetch arguments using *p-- instead of *p++
 *	NO_LONGD	%d and %ld/%D are equal
 *	NO_FLOAT	abort on %e, %f and %g
 */

static char *
itoa(p, num, radix)
register char *p;
register unsigned num;
register radix;
{
	register	i;
	register char	*q;

	q = p + 32;
	do {
		i = (int)(num % radix);
#ifdef TOS
		if (i < 0) i += radix;	/* Bug in Alcyon 4.14 C */
#endif
		i += '0';
		if (i > '9')
			i += 'A' - '0' - 10;
		*--q = i;
	} while (num = num / radix);
	i = (int)(p + 32 - q);
	do
		*p++ = *q++;
	while (--i);
	return(p);
}

#ifndef NO_LONGD
static char *
ltoa(p, num, radix)
register char *p;
register unsigned long num;
register radix;
{
	register	i;
	register char	*q;

	q = p + 32;
	do {
		i = (int)(num % radix);
		i += '0';
		if (i > '9')
			i += 'A' - '0' - 10;
		*--q = i;
	} while (num = num / radix);
	i = (int)(p + 32 - q);
	do
		*p++ = *q++;
	while (--i);
	return(p);
}
#endif

#ifndef NO_FLOAT
extern char	*_ecvt();
extern char	*_fcvt();
extern char	*_gcvt();
#endif

#ifdef STACKUP
#define	GETARG(typ)	*((typ *)args)--
#else
#define	GETARG(typ)	*((typ *)args)++
#endif STACKUP

_doprnt(fmt, args, outc)
register char *fmt;
register int *args;
int (*outc)();
{
	char		buf[128];
	register char	*p;
	register char	*s;
	register	c;
	register	i;
	register short	width;
	register short	ndigit;
	register	ndfnd;
	register	ljust;
	register	zfill;
#ifndef NO_LONGD
	register	lflag;
	register long	l;
#endif

	for (;;) {
		p = buf;
		s = buf;
		while ((c = *fmt++) && c != '%')
			(*outc)(c);
		if (c == 0)
			return;
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
			if (*fmt)
				c = *fmt++;
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
				p = ltoa(p, GETARG(long), c);
				break;
			}
#endif
			p = itoa(p, GETARG(int), c);
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
				p = ltoa(p, l, 10);
				break;
			}
#endif
			if ((i = GETARG(int)) < 0) {
				*p++ = '-';
				i = -i;
			}
			p = itoa(p, i, 10);
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
			if (ndfnd == 0)
				ndigit = 6;
			ndigit++;
			p = _ecvt(p, GETARG(double), ndigit);
			break;
		case 'f':
			if (ndfnd == 0)
				ndigit = 6;
			p = _fcvt(p, GETARG(double), ndigit);
			break;
		case 'g':
			if (ndfnd == 0)
				ndigit = 6;
			p = _gcvt(p, GETARG(double), ndigit);
			break;
#endif
		case 'c':
			zfill = ' ';
			if (c = GETARG(int))
				*p++ = c;
			break;
		case 's':
			zfill = ' ';
			if ((s = GETARG(char *)) == 0)
				s = "(null)";
			if (ndigit == 0)
				ndigit = 32767;
			for (p = s; *p && --ndigit >= 0; p++)
				;
			break;
		default:
			*p++ = c;
			break;
		}
		i = (int)(p - s);
		if ((width -= i) < 0)
			width = 0;
		if (ljust == 0)
			width = -width;
		if (width < 0) {
			if (*s=='-' && zfill=='0') {
				(*outc)(*s++);
				i--;
			}
			do
				(*outc)(zfill);
			while (++width != 0);
		}
		while (--i>=0)
			(*outc)(*s++);
		while (width) {
			(*outc)(zfill);
			width--;
		}
	}
}
#endif /* __GNUC__ */
