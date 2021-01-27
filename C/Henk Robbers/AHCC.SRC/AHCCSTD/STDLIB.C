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

#include <prelude.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <signal.h>
#include <tos.h>
#include <setjmp.h>
#include <basepage.h>
#include <ext.h>

/*   HR: the errno variable is defined in the startup code ahcstart.s */
#include <errno.h>
#include <ctype.h>
#include <limits.h>

#define environ __EnvStrPtr
extern char **__EnvStrPtr;		/* in ahcstart.c */

/*	Abort function */

void abort(void)
{
	static char m[] = "Abnormal program termination\r\n";
	Fwrite(-1, sizeof(m)-1, m);
	exit(3);
}

/* abs functions, fabs: see mc881lib.lib */

short abs(short  v) { if (v < 0) v = -v; return v; }
long labs(long v) { if (v < 0) v = -v; return v; }

/*	_Assert function	*/

void _Assert(void *mesg)
{
	fputs(mesg, stderr);
	fputs(" -- assertion failed\n", stderr);
	abort();
}

/* Atexit function */

typedef void VpV(void);

static VpV *extab[32] = {nil};
extern VpV *_AtExitVec;				/* ex startup code */
static short extp = 0;

VpV _Atexit
{
	while (--extp)
		extab[extp]();
}

short atexit(VpV *func)
{
	if (extp >= 32) return -1;
	extab[extp++] = func;
	_AtExitVec = _Atexit;
	return 0;
}

/* HR ptr to const char *endptr */
/* C has pretty good typing, if only people used it properly. */
/* You can safely assign a var ptr to a const ptr, not the otherway around. */

static
unsigned long strtoint(const char *nptr, const char **endptr, short base, bool S, bool *sign)
{
	short negative = 0;
	ulong i;
	const char *s, *save, *end;
	uchar c;

	if (base < 0 or base eq 1 or base > 36)
	{
		errno = EINVAL;
		return 0;
	}

	save = s = nptr;

	while (isspace(*s)) ++s;	/* Skip white space.  */

	if (*s)
	{
		if (S)
			if (*s eq '-')			/* Check for a sign.  */
				negative = 1, ++s;
			elif (*s eq '+')
				negative = 0, ++s;

		/* Recognize number prefix and if BASE is zero, figure it out ourselves.  */
		if (*s eq '0')
		{
			if  ((base eq 0 or base eq 16) and toupper(s[1]) eq 'X')
				s += 2, base = 16;
			elif (base eq 0)
				base = 8;
		}
		elif (base eq 0)
			base = 10;

		/* Save the pointer so we can check later if anything happened.  */
		save = s;

		end = nil;
		i = 0;

		for (c = *s; c != 0; c = *++s)
		{
			if (s eq end)
				break;
			if (c >= '0' && c <= '9')
				c -= '0';
			elif (isalpha(c))
				c = toupper(c) - 'A' + 10;
			else
				break;

			if (c >= base)
				break;

			i *= (ulong) base;
			i += c;
		}

		/* Check if anything actually happened.  */
		if (s ne save)
		{
			/* Store in ENDPTR the address of one character
			   past the last character we converted.  */

			if (endptr)
				*endptr = s;

			/* Return the result of the appropriate sign.  */
			if (negative && S)
				*sign = true;
			return i;
		}
	}

	/* We must handle a special case here: the base is 0 or 16 and the
	   first two characters are '0' and 'x', but the rest are no
	   hexadecimal digits.  This is no error case.  We return 0 and
	   ENDPTR points to the `x`.  */

	if (endptr)
	{
		if (    save - nptr >= 2
		    and toupper(save[-1]) eq 'X'
		    and save[-2] eq '0'
		   )
			*endptr = &save[-1];
		else
			/*  There was no number to convert.  */
			*endptr = nptr;
	}

	return 0;
}

long strtol(const char *nptr, const char **endptr, short base)
{
	bool sign = 0;
	unsigned long l =  strtoint(nptr, endptr, base, true, &sign);
	return sign ? -l : l;
}

unsigned long strtoul(const char *nptr, const char **endptr, short base)
{
	return strtoint(nptr, endptr, base, false, 0L);
}

/* Convert a string to a long.  */
long atol (const char *s)
{
	return strtol(s, nil, 10);
}

/* Convert a string to an short.  */
short atoi (const char *s)
{
	return strtol(s, nil, 10);
}

/* HR: works only if you run on a mc68881/2 coprocessor. */
/*     Much, much later I might try to compile the unabashed mintlib */
/*     This code is taken from HCC's tokenizer */

static
const char *in;		/* make input string static for mygetchar, muungetchar */

#ifndef __NO_FLOAT__
static
double fval;
#endif

static
short ishexa(char c)
{
	if (c>='a' && c<='f')
		return (c-'a'+10);
	if (c>='A' && c<='F')
		return (c-'A'+10);
	return 0;
}


static
long getnum(char c)
{
	long val = 0;
	short base, i;

	if (c eq '0')
		base = 8;
	else
		base = 10, val = c - '0';

more:
	c = *in++;
	if (c eq 0)
		return val;

	if (tolower(c) eq 'x' && val eq 0)
	{
		base = 16;
		goto more;
	}
	if (c >= '0' && c <= '9')
	{
		val = base*val + (c - '0');
		goto more;
	}
	if (base eq 16 && (i = ishexa(c)) ne 0)
	{
		val = 16*val + i;
		goto more;
	}
	--in;
	return val;
}

#ifndef __NO_FLOAT__
double getdbl(char c)
{
	double val = 0;

	while(c >= '0' and c <= '9')
	{
		int i = c - '0';
		val = val*10 + i;
		c = *in++;
	}

	--in;
	return val;
}

static
double getfrac(char c)
{
	double val;
	double dig = 0.1;

	val = dig * (c - '0');
more:
	c = *in++;
	if (c >= '0' && c <= '9')
	{
		dig = .1 * dig;
		val += dig * (c - '0');
		goto more;
	}
	--in;
	return val;
}

static
double makeflt(double intpart, double frac, short exp)
{
	double val;
	double moda, mod10;

	val = intpart + frac;
	if (exp > 0)
		moda = 1e1, mod10 = 1e10;
	else if (exp < 0)
		moda = 1e-1, mod10 = 1e-10, exp = -exp;

	while (exp >= 10)
		val *= mod10, exp -= 10;

	while (exp--)
		val *= moda;		/* slow and dirty */

	return val;
}

static
bool lookexp(double intpart, double frac)
{
	char c;
	short minus = 0;
	short exp;

	c = *in++;

	if (tolower(c) != 'e')
		return --in, false;

	c = *in++;

	if (c eq '-')
		minus = 1, c = *in++;
	else if (c eq '+')
		c = *in++;

	if (c >= '0' && c <= '9')
		exp = getnum(c);
	else
		exp = 0, --in;

	if (minus)
		exp = -exp;

	fval = makeflt(intpart, frac, exp);
	return true;
}

static
void gotfrac(double intpart, double frac)
{
	if (!lookexp(intpart, frac))
		fval = makeflt(intpart, frac, 0);
}

static
bool lookfrac(double intpart)
{
	char c;
	double frac;

	c = *in++;
	if (c != '.')
		return --in, false;
	c = *in++;
	if (c >= '0' && c <= '9')
		frac = getfrac(c);
	else
		--in, frac = 0.0;
	gotfrac(intpart, frac);
	return true;
}

double strtod(const char *s, const char **endptr)
{
	bool minus = false;
	char c;
	double v = 0;
	in = s;
	fval = 0.0;

	c = *in++;

#if COLDFIRE
	__FPCR__ = 0x80;
#else
	__FPCR__ = 0;
#endif

	while(c eq ' ' or c eq '\t')		/* 12'16 HR v5.5 */
		c = *in++;

	if   (c eq '-')
		minus = true, c = *in++;
	elif (c eq '+')
		c = *in++;

	if (c >= '0' and c <= '9')
		v = getdbl(c);

	if (c eq '.')
	{
		c = *in++;
		if (c >= '0' && c <= '9')
			gotfrac(0.0, getfrac(c));
		goto af;
	}

	if (lookfrac(v) or lookexp(v, 0.0))
		;
	else
		fval = v;
af:
	if (endptr) *endptr = in;
	return minus ? -fval : fval;
}

/* Convert a string to a double.  */
double atof (const char *s)
{
  return strtod (s, nil);
}
#endif

/* from Dale Schumacher's dLibs library */

/*
 * This routine is safe in the sense that it does not make
 * assumptions about sizeof(void *). Gcc assumes same as char *
 * when not -ansi, the "other" compiler just barfs.
 *
 */

void * bsearch(const void *key,		/* key:  item to search for */
               const void *base,	/* base: base address */
               size_t num,			/* num:  number of elements */
               size_t size,			/* size: element size in bytes */
               StdCompare *cmp)		/* cmp:  comparison function */
{
	size_t a, b, c;
	short dir;

	if (   key  eq nil
	    or base eq nil
	    or size eq 0
	    or num  eq 0
	    or cmp  eq nil
	   )
		return nil;

	a = 0;
	b = num - 1;
	while(a <= b)
	{
		c = (a + b) / 2;
		dir = cmp(key, ((char *)base + (c * size)));
		if (dir != 0 )
		{
			if (dir < 0)
			{
			    if (c eq 0)
					return(nil);

				b = c - 1;
			}
			else /* (dir > 0) */
				a = c + 1;
		}
		else
			return (((char *)base) + (c * size));
	}

	return nil;
}

div_t div(short numer, short denom)
{
	div_t result;

	result.quot = numer / denom;
	result.rem  = numer % denom;

	return result;
}

ldiv_t ldiv(long numer, long denom)
{
	ldiv_t result;

	result.quot = numer / denom;
	result.rem  = numer % denom;

	return result;
}

/* functions for manipulating the environment */

extern char	*_envp;

#define	ENVSIZ	(1<<12)			/* 4K environment string */

static int envset = FALSE;		/* local env created? */

static
char *findenv(const char *var)
/*
 *	INTERNAL FUNCTION.  This functions attempts to locate <var> in
 *	the environment.  If <var> is not found, NULL is returned.  If
 *	the environment is NULL, NULL is returned.  If <var> is found,
 *	a pointer to the beginning of <var> in the environment is returned.
 *	BOTH MS-DOS AND TOS ENVIRONMENT FORMATS ARE ACCOMODATED.
 */
{
	char *p = _envp;
	int len;

	if (!p)
		return nil;

	len = strlen(var);

	while (*p)
	{
		if (p[len] eq '=' and !strncmp(p, var, len))
			return p;

		while (*p++)		/* move to next arg */
			;
	}

	return nil;
}

char *getenv(const char *var)
{
	char *p, *q;
	int len;

	len = strlen(var);
	p = findenv(var);

	if (p)
	{
		p += len + 1;

		if (*p eq '\0')		/* TOS env format or empty value */
		{
			q = p + 1;

			if (*q eq '\0')		/* empty value + end of env */
				return p;

			while (*q and *q ne '=')
				++q;

			if (*q)			/* empty value */
				return p;
			else			/* TOS env format */
				return p + 1;
		}
	}
	return(p);
}

short putenv(const char *entry)
/*
 *	Add <entry> to the environment.  <entry> can be any of the following
 *	forms:
 *		<VARIABLE>		remove <VARIABLE>
 *		<VARIABLE>=		set <VARIABLE> to a null value
 *		<VARIABLE>=<value>	set <VARIABLE> to <value>
 */
{
	char e[256];
	char *t;
	char *p, *q, c;
	short len;

	strncpy(e, entry, sizeof(e));
	e[sizeof(e)-1] = 0;

	if (!envset)				/* no local env */
	{
		if ((p = malloc(ENVSIZ)) == NULL)
			return(FALSE);

		q = _envp;
		_envp = p;
		envset = TRUE;

		if (q)
			while (*q)
				while ((*p++ = *q++) != 0);
		else
			*p++ = '\0';

		*p++ = '\0';
		*p = 0xFF;
	}

	for (t=e; (c = *t) != 0 && c != '='; ++t);

	*t = '\0';

	if ((p = getenv(e)) != 0)		/* remove old var */
	{
		q = p;

		while(*q++);			/* find end of old val */

		p -= (len = strlen(e));

		while(strncmp(--p, e, len));	/* find start of old var */
		while(*q)			/* copy environment tail */
			while((*p++ = *q++) != 0);


		*p++ = '\0';			/* tie off environment */
		*p = 0xFF;
	}
	if (c == '=')				/* install new var */
	{
		p = _envp;

		while (*p)				/* find end of env */
			while (*p++);

		*t = c;
		q = e;

		while((*p++ = *q++) != 0);		/* copy new entry */

		*p++ = '\0';			/* tie off environment */
		*p = 0xFF;
	}

	_base->p_env = _envp;		/* update basepage pointer */

	return TRUE;
}

/* from dLibs, by Dale Schumacher */
/* Modified by Guido Flohr <guido@freemint.de>:
 * - Characters > 128 are control characters.
 * - iscntrl(EOF) should return false, argh, stupid but that's the
 *   the opinion of the majority.
 */

/* Modified for AHCC by Henk Robbers <h.robbers@chello.nl> */

static short _ctype[UCHAR_MAX + 1] =
{
	_CTc, _CTc, _CTc, _CTc,				/* 0x00..0x03 */
	_CTc, _CTc, _CTc, _CTc,				/* 0x04..0x07 */
	_CTc, _CTc|_CTs|_CTb, _CTc|_CTs, _CTc|_CTs,	/* 0x08..0x0B */
	_CTc|_CTs, _CTc|_CTs, _CTc, _CTc,		/* 0x0C..0x0F */

	_CTc, _CTc, _CTc, _CTc,				/* 0x10..0x13 */
	_CTc, _CTc, _CTc, _CTc,				/* 0x14..0x17 */
	_CTc, _CTc, _CTc, _CTc,				/* 0x18..0x1B */
	_CTc, _CTc, _CTc, _CTc,				/* 0x1C..0x1F */

	_CTs|_CTb|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x20..0x23 */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,				/* 0x24..0x27 */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,				/* 0x28..0x2B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP, _CTp|_CTg|_CTP,				/* 0x2C..0x2F */

	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,	/* 0x30..0x33 */
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,	/* 0x34..0x37 */
	_CTd|_CTx|_CTg|_CTP, _CTd|_CTx|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x38..0x3B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x3C..0x3F */

	_CTp|_CTg|_CTP, _CTu|_CTx|_CTg|_CTP,
	_CTu|_CTx|_CTg|_CTP, _CTu|_CTx|_CTg|_CTP,	/* 0x40..0x43 */
	_CTu|_CTx|_CTg|_CTP, _CTu|_CTx|_CTg|_CTP,
	_CTu|_CTx|_CTg|_CTP, _CTu|_CTg|_CTP,		/* 0x44..0x47 */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x48..0x4B */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x4C..0x4F */

	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x50..0x53 */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,			/* 0x54..0x57 */
	_CTu|_CTg|_CTP, _CTu|_CTg|_CTP,
	_CTu|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x58..0x5B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x5C..0x5F */

	_CTp|_CTg|_CTP, _CTl|_CTx|_CTg|_CTP,
	_CTl|_CTx|_CTg|_CTP, _CTl|_CTx|_CTg|_CTP,	/* 0x60..0x63 */
	_CTl|_CTx|_CTg|_CTP, _CTl|_CTx|_CTg|_CTP,
	_CTl|_CTx|_CTg|_CTP, _CTl|_CTg|_CTP,		/* 0x64..0x67 */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x68..0x6B */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x6C..0x6F */

	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x70..0x73 */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,			/* 0x74..0x77 */
	_CTl|_CTg|_CTP, _CTl|_CTg|_CTP,
	_CTl|_CTg|_CTP, _CTp|_CTg|_CTP,			/* 0x78..0x7B */
	_CTp|_CTg|_CTP, _CTp|_CTg|_CTP,
	_CTp|_CTg|_CTP, _CTc,				/* 0x7C..0x7F */

	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x87 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x8F */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x97 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0x9F */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xA7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xAF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xB7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xBF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xC7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xCF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xD7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xDF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xE7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xEF */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, /* 0x80..0xF7 */
	_CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc, _CTc  /* 0x80..0xFF */
};

short iscntrl(short c)
{
  return    c eq -1
          ? 0
          : (uchar) (c) eq 255
            ? 1
            : (short) (_ctype[(uchar)c] & _CTc);
}

short tolower(short c)
{
	uchar x = c;
	if (x >= 'A' && x <= 'Z') x |= 0x20;
	return x;
}

short toupper(short c)
{
	uchar x = c;
	if (x >= 'a' && x <= 'z') x &= ~0x20;
	return x;
}

short isalnum(short c) { return _ctype[(uchar)c] & (_CTu|_CTl|_CTd); }
short isalpha(short c) { return _ctype[(uchar)c] & (_CTu|_CTl); }
short isascii(short c) { return !((c) & ~0x7F); }
#ifndef toascii
short toascii(short c) { return  ((c) &  0x7F);}
#endif
short isdigit(short c) { return _ctype[(uchar)c] & _CTd; }
short isgraph(short c) { return _ctype[(uchar)c] & _CTg; }
short islower(short c) { return _ctype[(uchar)c] & _CTl; }
short isprint(short c) { return _ctype[(uchar)c] & _CTP; }
short ispunct(short c) { return _ctype[(uchar)c] & _CTp; }
short isspace(short c) { return _ctype[(uchar)c] & _CTs; }
short isupper(short c) { return _ctype[(uchar)c] & _CTu; }
short isxdigit(short c){ return _ctype[(uchar)c] & _CTx; }
short isblank (short c){ return _ctype[(uchar)c] & _CTb; }
short is_alpha(short c){ return c == '_' || (_ctype[(uchar)c] & (_CTu|_CTl)) != 0; }
short is_alnum(short c){ return c == '_' || (_ctype[(uchar)c] & (_CTu|_CTl|_CTd)) != 0; }

/*
 *  qsort functions
 */

char	*_qbuf = NULL;		/* pointer to storage for qsort() */

#define	PIVOT			((i+j)>>1)
#define moveitem(dst,src,size)	if (dst != src) memcpy(dst, src, size)

typedef long qsize;

static
void _wqsort(short *base, qsize lo, qsize hi, StdCompare *cmp)
{
	short k;
	qsize i, j, t;
	short *p = &k;

	while(hi > lo)
	{
		i = lo;
		j = hi;
		t = PIVOT;
		*p = base[t];
		base[t] = base[i];
		base[i] = *p;

		while(i < j)
		{
			while(cmp(base+j, p) > 0)
				--j;
			base[i] = base[j];
			while(i < j && cmp(base+i, p) <= 0)
				++i;
			base[j] = base[i];
		}
		base[i] = *p;
		if (i - lo < hi - i)
		{
			_wqsort(base, lo, i - 1, cmp);
			lo = i + 1;
		}
		else
		{
			_wqsort(base, i + 1, hi, cmp);
			hi = i - 1;
		}
	}
}

static
void _lqsort(long *base, qsize lo, qsize hi, StdCompare *cmp)
{
	long k;
	qsize i, j, t;
	long *p = &k;

	while(hi > lo)
	{
		i = lo;
		j = hi;
		t = PIVOT;
		*p = base[t];
		base[t] = base[i];
		base[i] = *p;

		while(i < j)
		{
			while (cmp(base+j, p) > 0)
				--j;
			base[i] = base[j];
			while (i < j && cmp(base+i, p) <= 0)
				++i;
			base[j] = base[i];
		}

		base[i] = *p;

		if (i - lo < hi - i)
		{
			_lqsort(base, lo, i - 1, cmp);
			lo = i + 1;
		}
		else
		{
			_lqsort(base, i + 1, hi, cmp);
			hi = i - 1;
		}
	}
}

static
void _nqsort(char *base, qsize lo, qsize hi, qsize size, StdCompare *cmp)
{
	qsize i, j;
	char *p = _qbuf;

	while (hi > lo)
	{
		i = lo;
		j = hi;
		p = (base+size*PIVOT);
		moveitem(_qbuf, p, size);
		moveitem(p, base+size*i, size);
		moveitem(base+size*i, _qbuf, size);
		p = _qbuf;

		while (i < j)
		{
			while (cmp((base+size*j), p) > 0)
				--j;
			moveitem((base+size*i), (base+size*j), size);
			while(i < j && cmp((base+size*i), p) <= 0)
				++i;
			moveitem(base+size*j, base+size*i, size);
		}

		moveitem(base+size*i, p, size);

		if ((i - lo) < (hi - i))
		{
			_nqsort(base, lo, i - 1, size, cmp);
			lo = i + 1;
		}
		else
		{
			_nqsort(base, i + 1, hi, size, cmp);
			hi = i - 1;
		}
	}
}

void qsort(void *base, size_t num, size_t size, StdCompare *cmp)
{
	char _qtemp[512];

	if (_qbuf == nil)
	{
		if (size > sizeof _qtemp)	/* records too large! */
			return;
		_qbuf = _qtemp;
	}

	if (size == 2)
		_wqsort(base, 0, num-1, cmp);
	else if (size == 4)
		_lqsort(base, 0, num-1, cmp);
	else
		_nqsort(base, 0, num-1, size, cmp);

	if (_qbuf == _qtemp)
		_qbuf = NULL;
}

/*
 *	Heap sorting functions
 */

static
void _wsift(short *base, qsize i, qsize n, StdCompare *cmp)
{
	qsize j, t;

	while ((j = ((i << 1) + 1)) < n)
	{
		if( (j < (n - 1)) && ((*cmp)((base+j), (base+j+1)) < 0))
			++j;
		if (cmp(base+i, base+j) < 0)
		{
			t = base[i];
			base[i] = base[j];
			base[j] = t;
			i = j;
		}
		else
			break;
	}
}

static
void _whsort(short *base, qsize num, StdCompare *cmp)
{
	qsize i, j;

	for (i = ((num >> 1) - 1); (i > 0); --i)
		_wsift(base, i, num, cmp);
	i = num;
	while (i > 1)
	{
		_wsift(base, 0, i--, cmp);
		j = *base;
		*base = *(base + i);
		*(base + i) = j;
	}
}

static
void _lsift(long *base, qsize i, qsize n, StdCompare *cmp)
{
	qsize j;
	long t;

	while ((j = ((i << 1) + 1)) < n)
	{
		if ((j < (n - 1)) && ((*cmp)((base+j), (base+j+1)) < 0))
			++j;
		if ((*cmp)((base+i), (base+j)) < 0)
		{
			t = base[i];
			base[i] = base[j];
			base[j] = t;
			i = j;
		}
		else
			break;
	}
}

static
void _lhsort(long *base, qsize num, StdCompare *cmp)
{
	qsize i;
	long j;

	for (i = ((num >> 1) - 1); (i > 0); --i)
		_lsift(base, i, num, cmp);
	i = num;
	while (i > 1)
	{
		_lsift(base, 0, i--, cmp);
		j = *base;
		*base = *(base + i);
		*(base + i) = j;
	}
}

static
void _nswap(char *pa, char *pb, qsize n)
{
	char c;

	while(n--)
	{
		c = *pa;
		*pa++ = *pb;
		*pb++ = c;
	}
}

static
void _nsift(char *base, qsize i, qsize n, qsize size, StdCompare *cmp)
{
	qsize j;
	char *p;

	while((j = ((i << 1) + 1)) < n)
	{
		p = (base+size*j);
		if ((j < (n - 1)) && ((*cmp)(p, p+size) < 0))
		{
			++j;
			p += size;
		}
		if ((*cmp)((base+size*i), p) < 0)
		{
			_nswap((base+size*i), p, size);
			i = j;
		}
		else
			break;
	}
}

static
void _nhsort(char *base, qsize num, qsize size, StdCompare *cmp)
{
	qsize i;

	for(i = ((num >> 1) - 1); (i > 0); --i)
		_nsift(base, i, num, size, cmp);
	i = num;
	while(i > 1)
	{
		_nsift(base, 0, i--, size, cmp);
		_nswap(base, (base+size*i), size);
	}
}

void hsort(void *base, size_t num, size_t size, StdCompare *cmp)
{
	if (size == 2)
		_whsort(base, num, cmp);
	else if (size == 4)
		_lhsort(base, num, cmp);
	else
		_nhsort(base, num, size, cmp);
}

/*  rand(3)
 *
 *  Author: Terrence W. Holm          Nov. 1988
 *
 *
 *  A prime modulus multiplicative linear congruential
 *  generator (PMMLCG), or "Lehmer generator".
 *  Implementation directly derived from the article:
 *
 *	S. K. Park and K. W. Miller
 *	Random Number Generators: Good Ones are Hard to Find
 *	CACM vol 31, #10. Oct. 1988. pp 1192-1201.
 *
 *
 *  Using the following multiplier and modulus, we obtain a
 *  generator which:
 *
 *	1)  Has a full period: 1 to 2^31 - 2.
 *	2)  Is testably "random" (see the article).
 *	3)  Has a known implementation by E. L. Schrage.
 */

#define  A	      16807L	/*  A "good" multiplier	  */
#define  M   2147483647L	/*  Modulus: 2^31 - 1	  */
#define  Q       127773L	/*  M / A		  */
#define  R         2836L	/*  M % A		  */

static long _lseed = 1L;

void srand(unsigned short seed) { _lseed = seed; }

short rand(void)
{
	_lseed = A * (_lseed % Q) - R * (_lseed / Q);

	if (_lseed < 0)
		_lseed += M;

	return _lseed & 0x7fffL;	/* how "good" is it now ? */
}

/*
system()  from dlibs
*/

char __numstr[] = "0123456789ABCDEF";

char *ultoa(unsigned long n, char *buffer, short radix)
{
	char *p = buffer;

	do
		*p++ = __numstr[n % radix];	/* grab each digit */
	while((n /= radix) > 0);

	*p = '\0';

	return strrev(buffer);			/* reverse and return it */
}

char *ltoa(long n, char *buffer, short radix)
{
	char *p = buffer;

	if (n < 0)
	{
		*p++ = '-';
		n = -n;
	}

	ultoa(n, p, radix);

	return buffer;
}

char *itoa(short n, char *buffer, short radix)
{
	return ltoa(n, buffer, radix);
}

char *ctlcnv(char *string)
{
	char *p, *q, c;
	short i, n;

	p = q = string;
	while (*q)
	{
		if (*q == '\\')
		{
			switch (*++q)
			{
				case 'n':			/* newline or linefeed */
					*p++ = '\n';
					break;
				case 'r':			/* carriage return */
					*p++ = '\r';
					break;
				case 'b':			/* backspace */
					*p++ = '\b';
					break;
				case 't':			/* horizontal tab */
					*p++ = '\t';
					break;
				case 'v':			/* vertical tab */
					*p++ = '\013';
					break;
				case 'f':			/* form feed */
					*p++ = '\f';
					break;
				case 'a':			/* alarm (bell) */
					*p++ = '\007';
					break;
				case '0':			/* octal constant */
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
					c = (*q - '0');
					i = 0;
					n = 3;
					do
					{
						i = (i<<3) + c;
						c = (*++q - '0');
					} while(   (--n)
						    && (c >= 0)
						    && (c < 8)
						   );
					*p++ = i;
					--q;
					break;
				case 'x':			/* hexadecimal constant */
					i = 0;
					n = 2;
					while((n--)
					   && ((c = strpos(__numstr,
					   		toupper(*++q))) >= 0))
						i = (i << 4) + c;
					*p++ = i;
					--q;
					break;
				case '\n':			/* "folded" line */
					break;
				default:
					*p++ = *q;
			}
		}
		else
			*p++ = *q;

		++q;
	}

	*p = '\0';

	return string;
}


void *lfind(void *key, void *base, size_t *num, size_t size, StdCompare *cmp)
{
	short n = *num;

	while (n--)
	{
		if ((*cmp)(base, key) == 0)
			return(base);
		(long)base += size;
	}
	return nil;
}

void *lsearch(void *key, void *base, size_t *num, size_t size, StdCompare *cmp)
{
	void *p;

	if ((p = lfind(key, base, num, size, cmp)) == nil)
	{
		p = memcpy(((char *)base + (size * (*num))), key, size);
		++(*num);
	}
	return p;
}

/*
From: gwyn@brl-tgr.ARPA (Doug Gwyn <gwyn>)
Newsgroups: net.sources
Subject: getopt library routine
Date: 30 Mar 85 04:45:33 GMT
*/
/*
	getopt -- public domain version of standard System V routine

	Strictly enforces the System V Command Syntax Standard;
	provided by D A Gwyn of BRL for generic ANSI C implementations

	Modified for dLibs on the Atari ST by Dale Schumacher, 07Oct88.
	#define STRICT to prevent acceptance of clustered options with
	arguments and ommision of whitespace between option and arg.

	To ANSI 89 by Henk Robbers may 2008.
*/

short	opterr = 1;			/* error => print message */
short	optind = 1;			/* next argv[] index */
char	*optarg = NULL;		/* option parameter if any */

static
short Err(					/* returns '?' */
	char	*name,			/* program name argv[0] */
	char	*mess,			/* specific message */
	short	c				/* defective option letter */
   )
{
	char nbuf[16];

	if ( opterr )
	{
		_splitpath(name, NULL, NULL, nbuf, NULL);
		name = nbuf;
		fprintf( stderr, "%s: %s -- %c\n", name, mess, c );
	}

	return '?';			/* erroneous-option marker */
}

short getopt(				/* returns letter, '?', EOF */
	short		argc,		/* argument count from main */
	char		*argv[],	/* argument vector from main */
	char		*optstring	/* allowed args, e.g. "ab:c" */
   )
{
	static short	sp = 1;	/* position within argument */
	short	osp;			/* saved `sp' for param test */
#ifndef STRICT
	short	oind;			/* saved `optind' for param test */
#endif
	short	c;				/* option letter */
	char	*cp;			/* -> option in `optstring' */

	optarg = NULL;

	if ( sp == 1 )						/* fresh argument */
		if (   optind >= argc			/* no more arguments */
		    || argv[optind][0] != '-'	/* no more options */
		    || argv[optind][1] == '\0'	/* not option; stdin */
		   )
			return EOF;
		else if ( strcmp( argv[optind], "--" ) == 0 )
		{
			++optind;					/* skip over "--" */
			return EOF;					/* "--" marks end of options */
		}

	c = argv[optind][sp];				/* option letter */

	osp = sp++;					/* get ready for next letter */

#ifndef STRICT
	oind = optind;				/* save optind for param test */
#endif
	if ( argv[optind][sp] == '\0' )	/* end of argument */
	{
		++optind;				/* get ready for next try */
		sp = 1;					/* beginning of next argument */
	}

	if (    c == ':'
	    ||  c == '?'			/* optstring syntax conflict */
	    || (cp = strchr( optstring, c )) == NULL	/* not found */
	   )
		return Err( argv[0], "illegal option", c );

	if ( cp[1] == ':' )			/* option takes parameter */
	{
#ifdef STRICT
		if ( osp != 1 )
			return Err( argv[0], "option must not be clustered", c );

		if ( sp != 1 )			/* reset by end of argument */
			return Err( argv[0], "option must be followed by white space", c );
#else
		if ( oind == optind )	/* argument w/o whitespace */
		{
			optarg = &argv[optind][sp];
			sp = 1;				/* beginning of next argument */
		}
		else
#endif
		if ( optind >= argc )
			return Err( argv[0], "option requires an argument", c );
		else					/* argument w/ whitespace */
			optarg = argv[optind];

		++optind;				/* skip over parameter */
	}

	return c;
}

static void parse_args(char *cmdln, char *argv[])
{
	static char delim[] = " \t\r\n";
	char *p = strtok(cmdln, delim);

	while (p)
	{
		*argv++ = p;
		p = strtok(NULL, delim);
	}
}

typedef struct
{
	char		xarg_magic[4];    /* verification value "xArg" */
	int		xargc;            /* argc */
	char		**xargv;          /* argv */
	char		*xiovector;       /* i/o handle status */
	BASEPAGE	*xparent;         /* pointer to parent's basepage */
} XARG;

static char     xmagic[] = "xArg";
static char     hex[] = "0123456789ABCDEF";

#define	MAXFORK	8		/* maximum number of concurrent fork's */

typedef struct
{
	int		fk_pid;
	char		fk_rv;
	char		fk_xstatus;
} FORK;

static	FORK	forktbl[MAXFORK];

#define	XS_NORMAL	0x00		/* process terminated normally */
#define	XS_RUNNING	0x7F		/* process still running */

static	FORK	*forkp = forktbl;	/* fork() context pointer */
static	int	forkcnt = 0;		/* # of fork's currently active */
static	char	fork_ext[] = ".ttp\0.tos\0.prg\0.app\0";

/*
 * Build TOS-style command line image from argv[] list.
 */
int makcmdln(char * cmdln, char ** argv)
{
	char *p, *q, *e;
	int argc = 1;

	p = cmdln + 1;
	e = cmdln + 127;
	while(q = *++argv)		/* start at argv[1] */
	{
		++argc;
		while(*q && p < e)
			*p++ = *q++;
		if (p < e)
			*p++ = ' ';
	}
	*p = '\0';
	cmdln[0] = p - (cmdln + 1);     /* store the string length */
	return(argc);                   /* return number of arguments */
}

FORK *_fork(void)
/*
 * create FORK struct for new process and return calculated pid
 */
{
	register long n;
	register int pid;
	register FORK *fp;

	if((forkcnt >= MAXFORK)		/* too many forks already active? */
	|| ((n = (long)Malloc(-1L)) <= 0))	/* malloc error? */
		return(NULL);
	n = (long)Malloc(n);			/* get address of next free block */
	Mfree(n);
	fp = forkp++;
	++forkcnt;
	n += 0x3EL;			/* adjust it */
	pid = (0x7FFF & (n>>8));	/* calculate pid from it */
	fp->fk_pid = pid;		/* initialize process entry */
	fp->fk_xstatus = XS_RUNNING;
	fp->fk_rv = 0;
	return(fp);
}

int _exec(
	char *pathname,
	char *cmdln,
	int argc,
	char **argv,
	char *envp)
{
	register FORK *fp;
	XARG xarg;
	register XARG *xp = &xarg;
	register char *p;
	register int n;
	register long rv;
	char xenv[16];

	if((fp = _fork()) == NULL)
		return(ERROR);
	/*
	 * initialize XARG struct
	 */
	strncpy(xp->xarg_magic, xmagic, 4);
	xp->xargc = argc;
	xp->xargv = argv;
	xp->xiovector = NULL;
	xp->xparent = _base;
	/*
	 * create environment variable "xArg=XXXXXXXX"
	 */
	strcpy(xenv, xmagic);
	p = strrchr(xenv, '\0');        /* move to terminating '\0' */
	*p++ = '=';
	rv = ((long) xp);

	for(n=8; n--; rv >>= 4)         /* convert long to ascii-hex */
		p[n] = hex[rv & 0xF];

	p[8] = '\0';
	/*
	 * install environment variable and execute program
	 */
	putenv(xenv);
	rv = Pexec(0, pathname, cmdln, envp);
	putenv(xmagic);                 /* remove "xArg" from environment */
	if(rv < 0L)			/* GEMDOS error */
	{
		errno = ((int) rv);
		fp->fk_rv = fp->fk_xstatus = ((char) rv);
	}
	else				/* normal exit */
	{
		fp->fk_xstatus = XS_NORMAL;
		fp->fk_rv = ((char) rv);
	}
	return(fp->fk_pid);
}

forkve(char *pathname, char **argv, char *envp)
{
	int argc;
	char cmdln[130];

	argc = makcmdln(cmdln, argv);
	return(_exec(pathname, cmdln, argc, argv, envp));
}


void forkl(char *pathname, char *arg0)
{
	forkve(pathname, &arg0, NULL);
}

int forkle(char *pathname, char *arg0)
{
	register char **argv = &arg0, *envp;
	register int argc;
	char cmdln[130];

	argc = makcmdln(cmdln, argv);
	envp = argv[argc+1];
	return(_exec(pathname, cmdln, argc, argv, envp));
}

#if 0
int forklp(pathname, arg0)
	char *pathname, *arg0;
	{
	char *pfindfile();

	if(pathname = pfindfile(NULL, pathname, fork_ext))
		return(forkve(pathname, &arg0, NULL));
	return(errno = EFILNF);
	}

int forklpe(pathname, arg0)
	char *pathname, *arg0;
	{
	register char **argv = &arg0, *envp;
	register int argc;
	char cmdln[130];
	char *pfindfile();

	if(pathname = pfindfile(NULL, pathname, fork_ext))
		{
		argc = makcmdln(cmdln, argv);
		envp = argv[argc+1];
		return(_exec(pathname, cmdln, argc, argv, envp));
		}
	return(errno = EFILNF);
	}
#endif

forkvpe(char *pathname, char **argv, char *envp)
{
	if(pathname = pfindfile(NULL, pathname, fork_ext))
		return(forkve(pathname, argv, envp));
	return(errno = -33);
}

int wait(char *rvp)
{
	register FORK *fp;
	register int pid;

	fp = forktbl;
	if(fp == forkp)			/* no child processes */
		return(errno = ERROR);
	for(;;)
	{
		for(fp = forktbl; fp < forkp; ++fp)
		{
			if(fp->fk_xstatus != XS_RUNNING)
			{
				pid = fp->fk_pid;
				if(rvp)
				{
					rvp[0] = fp->fk_rv;
					rvp[1] = fp->fk_xstatus;
				}
				--forkp;
				--forkcnt;
				while(fp++ < forkp)
					fp[-1] = fp[0];
				return(pid);
			}
		}
		sleep(1);
	}
}

typedef int Shell(const char *);

int system(const char *command)
{
	char *p;
	Shell *shell;
	char rv[2];
	char cmdln[1024];
	char *args[64];

	if(!command)
		return(ERROR);

	/* get _shell_p value */
	p = (char *) Super(0L);
	shell = (Shell *) 0x4F6L;
	Super(p);

	/* validate _shell_p */
	if(   shell									/* Shell available. */
	   && (long) shell < (long) _base			/* Reasonable shell pointer. */
	   && strncmp((char *)shell, "PATH", 4)		/* Not corrupted */
	  )
		return shell(command);					/* execute the command */

	strcpy(cmdln, command);						/* copy the command line for parsing */

	if ((p = getenv("SHELL")) && *p)			/* SHELL= variable? */
	{
		args[0] = p;
		parse_args(cmdln, (args + 1));
	}
	else	/* attempt to find first token as a program on the path */
	{
		parse_args(cmdln, args);
		p = args[0];
	}

	forkvpe(p, args, NULL);
	wait(rv);
	return rv[1] == 0 ? rv[0] : rv[1];
}
