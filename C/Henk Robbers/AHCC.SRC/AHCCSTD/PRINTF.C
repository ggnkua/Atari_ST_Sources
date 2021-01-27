/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/

/* printf.c */
/* from Dale Schumacher's dLibs library */
/* Adapted to ANSI and AHCC by H. Robbers */
/* HR: feb 2009: implemented long long
 *               while actually not using type long long itself.
 */

#include <prelude.h>
#include <limits.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>
#include <tos.h>

#define DMODE 0

#ifndef __NO_FLOAT__
#include <math.h>
#define DB8 (sizeof(double) == 8)
#endif

#if __LONGLONG__
#include "ll.h"
#endif

static
bool fixdot = false;		/* set to true by %g */

typedef struct
{
	short
		width,
		preci,
		minus,
		exp,
		ll;
	uchar
		pad,
		upp,
		sign;
	bool
		ljustf,
		dpoint;
#if __LONGLONG__
	__ll val;
#else
	union
	{
		long lo;
	}
	val;
#endif
	char oflo, buf[63];
} AT;

extern char __numstr[];

#if __LONGLONG__
static
char *__ulltoa(__ll n, char *buffer, short radix)
{
	char *p = buffer;

	do
	{
		short rem;
		n = _ullsdiv(n, radix, &rem);
		*p++ = __numstr[rem];		/* grab each digit */
	}
	while(n.hi or n.lo);

	*p = '\0';

	return strrev(buffer);			/* reverse and return it */
}

static
char *__lltoa(__ll n, char *buffer, short radix)
{
	char *p = buffer;

	if (n.hi < 0)
	{
		*p++ = '-';
		n = _llneg(n);
	}

	__ulltoa(n, p, radix);

	return buffer;
}
#endif

static
char * p_round(char *rs, char *rp, AT *at)
{
	char *p = rp + at->preci,
	     *e = p,
	      c = *p;

	*p = 0;
	at->oflo = '0';

	if (c >= '5')
	{
		p--;

		while (p >= rs)
		{
			if (p eq rp - 1)
				p--;
			*p += 1;

			if (*p <= '9')
				if (!fixdot) return p;
				else
					goto done;
			*p = '0';
			p--;
		}

		at->oflo = '1';
	}
	if (!fixdot) return p;
done:
	p = e;
	while (*--p eq '0') *p = 0;
	if (*p eq '.') return *p = 0, p;
	return p + 1;
}

#ifndef __NO_FLOAT__

char *NaN[] =
{
	"-Inf",
	"",
	"+Inf",
	"NaN"
};

/* NaN: Exponent is MAX and any bit in mantissa ( **) MOTOROLA MC68881/MC68882 user's manual 3-5) */
/* NB! the size 8 numbers dont have the 'integer bit' in the mantissa */
global
short is_NaNorInf(double x) /* yields  -1 is -Inf, 0 is not (NaN or Inf), +1 = +Inf, 2 is NaN */
{
	ushort *e = (ushort *)&x;
#if DB8
	if ((*e&0x7ff0) eq 0x7ff0)
	{
		if (    (e[0]&0x000f) ne 0 or     e[1] ne 0 or  e[2] ne 0 or  e[3] ne 0)
			return 2;
		if (    (e[0]&0x000f) eq 0 and    e[1] eq 0 and e[2] eq 0 and e[3] eq 0)
			if ((*e&0x8000) ne 0)
				return -1;	/* -Inf */
			else
				return 1;	/* +Inf */
	}
#else
	if ((*e&0x7fff) eq 0x7fff)
	{
		if ( (e[2]/* *) */ &0x7fff) ne 0 or  e[3] ne 0 or  e[4] ne 0 or  e[5] ne 0)
			return 2;		/* NaN */
		if ( (e[2]/* *) */ &0x7fff) eq 0 and e[3] eq 0 and e[4] eq 0 and e[5] eq 0)
			if ((*e&0x8000) ne 0)
				return -1;	/* -Inf */
			else
				return 1;	/* +Inf */
	}
#endif

	return 0;
}

/* *) The **) manual does not mention the 'integer bit' for extended precision NaN */

static
void e_print(double x, AT *at, char *tmp)
{
	short nsig;
	char *p = tmp, *rp;

	if (at->preci < 0)
		nsig = at->preci = 7;
	else
		nsig = at->preci + 1;

	if (at->minus)
		*p++ = '-';

	*p++ = at->buf[0];
	*p++ = '.';
	rp = p;

	if (nsig > 1)
		strcpy(p, &at->buf[1]);

	p += strlen(p);
	p = p_round(tmp, rp, at);

	*p++ = at->upp ? 'E' : 'e';
	at->exp--;

	if (at->exp < 0)
		*p++ = '-', at->exp = -at->exp;

	itoa(at->exp, p, 10);
}

static
void f_print(double x, AT *at, char *tmp)
{
	short nsig, nz, i;
	char *p = tmp, *rp = nil;

	if (at->preci < 0)
		nsig = at->preci = 6;
	else
		nsig = at->preci;

	if (at->minus)
		*p++ = '-';

	if (at->exp < 1)
		*p++ = '0';
	else
	{
		strncpy(p, at->buf, at->exp);
		p += at->exp;
	}

	if (at->preci != 0 or nsig)
	{
		*p++ = '.';
		rp = p;
	}

	if (nsig == 0)
		*p = 0;
	elif (at->exp < 0)
	{
		nz = -at->exp;

		if (nz > nsig)
			nz = nsig;

		for (i=0; i<nz; i++)
			*p++ = '0';

		nsig -= nz;

		if (nsig > 0)
		{
			strncpy(p, at->buf, nsig);
			p += nsig;
		}

		*p = 0;
	}
	else
		strcpy(p, &at->buf[at->exp]);

	if (rp)
		p_round(tmp, rp, at);
}

static
void g_print(double x, AT *at, char *tmp)
{

	if (at->preci < 0)
		at->preci = 6;
	if (at->preci < 1)
		at->preci = 1;

	if (at->exp < -3 or at->exp > at->preci)
	{
		at->preci -= 1;
		fixdot = false;			/* 01'17 HR v5.5 */
		e_print(x, at, tmp);
	}
	else
	{
		fixdot = true;			/* 01'17 HR v5.5: remove all zero fractional digits and dot */
		f_print(x, at, tmp);
		fixdot = false;			/* 01'17 HR v5.5 */
	}
}

/* short mynan; */
static
void fp_print(double x, char fmtc, char *tmp, AT *at)
{
	short nan;
	at->upp = 0;

	nan = is_NaNorInf(x);
/*	mynan = nan; */
	if (nan)		/* Nan or Inf */
		strcpy(tmp, NaN[nan+1]);
	else
	{
		strcpy(at->buf, ecvt(x, 21, &at->exp, &at->minus));

		switch (fmtc)
		{
		case 'E':
			at->upp = 1;
		case 'e':
			e_print(x, at, tmp);
			break;
		case 'F':
		case 'f':
			f_print(x, at, tmp);
			break;
		case 'G':
			at->upp = 1;
		case 'g':
			g_print(x, at, tmp);
			break;
		}
	}
}
#endif

static
size_t __prtfld(void *op, OutFunc *put, char *buf, AT *at)
/*
 *	Output the given field in the manner specified by the arguments.
 *	Return the number of characters output.
 */
{
	short cnt = 0, len;
	uchar ch;

	len = strlen((char *)buf);

	if (*buf eq '-')
		at->sign = *buf++;
	elif (at->sign)
		len++;

	if (at->preci != -1 and len > at->preci)	/* limit max data width */
		len = at->preci;

	if (at->width < len)			/* flexible field width or width overflow */
		at->width = len;

/* at this point:
 *	width = total field width
 *	len   = actual data width (including possible sign character)
 */
	cnt = at->width;
	at->width -= len;

	while (at->width or len)
	{
		if (!at->ljustf and at->width)		/* left padding */
		{
			if (len and at->sign and at->pad eq '0')
				goto showsign;
			ch = at->pad;
			--at->width;
		}
		elif (len)
		{
			if (at->sign)
			{
showsign:		ch = at->sign;			/* sign */
				at->sign = '\0';
			}
			else
				ch = *buf++;		/* main field */
			--len;
		othw
			ch = at->pad;				/* right padding */
			--at->width;
		}

		put(ch, op);
	}

	return cnt;
}

#if DMODE
short _prt_lmode = 0;

short printf_dmode(short new)
{
	if (new < 0)
		return _prt_lmode;
	_prt_lmode = new ne 0;
	return _prt_lmode;
}
#endif

size_t _printf(void *op, OutFunc *put, const char *fmt, va_list args)
{
	short i;
	size_t cnt = 0;
	char tmp[512];

#ifndef __NO_FLOAT__
	double fx;
#endif

	while (*fmt)
	{
		if (*fmt eq '%')
		{
			AT at = {0};
									/* defaults with non zero value: */
			at.pad = ' ';			/* justification padding char */
			at.width = -1;			/* min field width */
			at.preci = -1;			/* max data width */
			at.oflo  = '0';			/* rounding overflow */

			do						/* firstly, get attributes */
			{
				char c;
				i = 0;
				while (isdigit(*++fmt))
				{
					i = (i * 10) + (*fmt - '0');

					if (at.dpoint)
						at.preci = i;
					elif (!i and at.pad eq ' ')
						at.pad = '0';
					else
						at.width = i;
				}

				c = *fmt;
				if (c eq '-')				/* left justification */
					at.ljustf = true;
				elif (c eq ' ' or c eq  '+')	/* leading sign flag */
					at.sign = *fmt;
				elif (c eq '*')				/* parameter width value */
				{
					i = va_arg(args, short);
					if (at.dpoint)
						at.preci = i;
					else
						at.width = i;
				}
				elif (c eq '.')				/* secondary width field */
					at.dpoint = true;
				elif (c eq 'l')				/* long data */
					at.ll++;				/* 2 l's = long long */
				else
					break;
			}
			od

			switch (*fmt)					/* one of the data types */
			{
				case '\0':					/* early EOS */
					--fmt;
					cnt += put(*fmt, op);
				break;
				case 'd':					/* Signed decimal */
				case 'i':
#if __LONGLONG__
					if (at.ll > 1)
					{
						at.val = va_arg(args, __ll);
						__lltoa(at.val, tmp, 10);
					}
					else
#endif
					{
						at.val.lo =   (   at.ll
#if DMODE
						               or _prt_lmode
#endif
						              )
						            ? va_arg(args, long)
						            : va_arg(args, short);
						ltoa(at.val.lo, tmp, 10);
					}
					cnt += __prtfld(op, put, tmp, &at);
				break;
				case 'b':					/* Unsigned binary */
#if __LONGLONG__
					if (at.ll > 1)
					{
						at.val = va_arg(args, __ll);
						__ulltoa(at.val, tmp, 2);
					}
					else
#endif
					{
						at.val.lo =   (   at.ll
#if DMODE
						               or _prt_lmode
#endif
						              )
						            ? va_arg(args, ulong)
						            : va_arg(args, ushort);
						ultoa(at.val.lo, tmp, 2);
					}
					cnt += __prtfld(op, put, tmp, &at);
				break;
				case 'o':					/* Unsigned octal */
#if __LONGLONG__
					if (at.ll > 1)
					{
						at.val = va_arg(args, __ll);
						__ulltoa(at.val, tmp, 8);
					}
					else
#endif
					{
						at.val.lo =   (   at.ll
#if DMODE
						               or _prt_lmode
#endif
						              )
						            ? va_arg(args, ulong)
						            : va_arg(args, ushort);
						ultoa(at.val.lo, tmp, 8);
					}
					cnt += __prtfld(op, put, tmp, &at);
				break;
				case 'p':					/* Pointer (always ulong) */
					at.ll = 1;
					at.pad = '0';
					at.width = 8;
					at.preci = 8;
					at.val.lo = va_arg(args, ulong);
					ultoa(at.val.lo, tmp, 16);
					cnt += __prtfld(op, put, tmp, &at);
				break;
				case 'x':					/* Unsigned hexadecimal */
				case 'X':
#if __LONGLONG__
					if (at.ll > 1)
					{
						at.val = va_arg(args, __ll);
						__ulltoa(at.val, tmp, 16);
					}
					else
#endif
					{
						at.val.lo =   (   at.ll
#if DMODE
						               or _prt_lmode
#endif
						              )
						            ? va_arg(args, ulong)
						            : va_arg(args, ushort);
						ultoa(at.val.lo, tmp, 16);
					}
					if (*fmt eq 'x')
						strlwr(tmp);
					cnt += __prtfld(op, put, tmp, &at);
				break;
				case 'u':					/* Unsigned decimal */
#if __LONGLONG__
					if (at.ll > 1)
					{
						at.val = va_arg(args, __ll);
						__ulltoa(at.val, tmp, 10);
					}
					else
#endif
					{
						at.val.lo =   (   at.ll
#if DMODE
						               or _prt_lmode
#endif
						              )
						            ? va_arg(args, ulong)
						            : va_arg(args, ushort);
						ultoa(at.val.lo, tmp, 10);
					}
					cnt += __prtfld(op, put, tmp, &at);
					break;
#ifndef __NO_FLOAT__
				case 'g':
				case 'G':
				case 'f':
				case 'e':
				case 'E':
				{
					fx = va_arg(args, double);
					fp_print(fx, *fmt, tmp, &at);
					at.preci = -1;
					cnt += __prtfld(op, put, tmp, &at);
				}
				break;
#endif
				case 'c':					/* Character */
					tmp[0] = va_arg(args, char);
					tmp[1] = '\0';
					at.sign = '\0';
					at.pad  = ' ';
					cnt += __prtfld(op, put, tmp, &at);
				break;
				case 's':					/* String */
				{
					char *ptmp = va_arg(args, char *);
					at.sign = '\0';
					at.pad  = ' ';
					cnt += __prtfld(op, put, ptmp, &at);
				}
				break;
				default:					/* unknown character */
					cnt += put(*fmt, op);
			}
		}
		else		/* no % */
			cnt += put(*fmt, op);			/* normal char out */

		fmt += 1;
	}

	return cnt;
}

static
OutFunc __sputc
{
	char **s = op;
	*(*s)++ = c;
	return 1;
}

static
OutFunc __fputc
{
	fputc(c, op);
	return 1;
}

static
OutFunc __putch
{
	Cconout(c);
	return 1;
}

short sprintf(char *buf, const char *fmt, ...)
{
	short n;
	char *p = buf;
	va_list args;
	va_start(args, fmt);

	n = _printf(&buf, __sputc, fmt, args);

	p[n] = '\0';		/* always tie of the string */

	return n;
}

short vsprintf(char *buf, const char *fmt, va_list args)
{
	short n;
	char *p = buf;

	n = _printf(&buf, __sputc, fmt, args);

	p[n] = '\0';		/* always tie of the string */

	return n;
}

short fprintf(FILE *fp, const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);

	return _printf(fp, __fputc, fmt, args);
}

short vfprintf(FILE *fp, const char *fmt, va_list args)
{
	return _printf(fp, __fputc, fmt, args);
}

short printf(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);

	return _printf(stdout, __fputc, fmt, args);
}

short vprintf(const char *fmt, va_list args)
{
	return _printf(stdout, __fputc, fmt, args);
}


short cprintf(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);

	return _printf(NIL, __putch, fmt, args);
}

