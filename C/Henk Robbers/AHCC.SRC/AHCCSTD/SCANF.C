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

/* scanf.c */
/* from Dale Schumacher's dLibs library */
/* Adapted to ANSI and AHCC by H. Robbers */
/* Couldnt get it working correctly without removing ALL use of goto.
   Wished K&R had have the courage to leave goto out of C!! */

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

#if __LONGLONG__
#include "ll.h"
#endif

short alert_msg(char *, ...);

extern	char __numstr[];

#ifndef __NO_FLOAT__
/* fp scan actions */
enum
{
	F_NADA,			/* just change state */
	F_SIGN,			/* set sign */
	F_ESIGN,		/* set exponent's sign */
	F_INT,			/* adjust integer part */
	F_FRAC,			/* adjust fraction part */
	F_EXP,			/* adjust exponent part */
	F_QUIT
};
enum
{
	FS_INIT,		/* initial state */
	FS_SIGNED,		/* saw sign */
	FS_DIGS,		/* saw digits, no . */
	FS_DOT,			/* saw ., no digits */
	FS_DD,			/* saw digits and . */
	FS_E,			/* saw 'e' */
	FS_ESIGN,		/* saw exp's sign */
	FS_EDIGS,		/* saw exp's digits */
	NSTATE
};
enum
{
	FC_DIG,
	FC_DOT,
	FC_E,
	FC_SIGN
};

/* given transition,state do what action? */
int fp_do[][NSTATE] =
{
	{F_INT,F_INT,F_INT,
	 F_FRAC,F_FRAC,
	 F_EXP,F_EXP,F_EXP},					/* see digit */
	{F_NADA,F_NADA,F_NADA,
	 F_QUIT,F_QUIT,F_QUIT,F_QUIT,F_QUIT},	/* see '.' */
	{F_QUIT,F_QUIT,
	 F_NADA,F_QUIT,F_NADA,
	 F_QUIT,F_QUIT,F_QUIT},					/* see e/E */
	{F_SIGN,F_QUIT,F_QUIT,F_QUIT,F_QUIT,
	 F_ESIGN,F_QUIT,F_QUIT},				/* see sign */
};

/* given transition,state what is new state? */
int fp_ns[][NSTATE] =
{
	{FS_DIGS,FS_DIGS,FS_DIGS,
	 FS_DD,FS_DD,
	 FS_EDIGS,FS_EDIGS,FS_EDIGS},	/* see digit */
	{FS_DOT,FS_DOT,FS_DD,},			/* see '.' */
	{0,0,FS_E,0,FS_E,},				/* see e/E */
	{FS_SIGNED,0,0,0,0,
	 FS_ESIGN,0,0},					/* see sign */
};

/* which states are valid terminators? */
int fp_sval[NSTATE] =
{
	0,0,1,0,1,0,0,1
};

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

#endif

typedef struct
{
	short width, wide1, base, neg, rngflag, ll;
	bool fupper, store, endnull;
	char delim[128], digits[26];
#ifndef __NO_FLOAT__
	short expo, eneg, fraclen, fstate, trans;
#endif
} AT;

static
short spaces(void *ip, InFunc *get, short *c)
{
	short read = 0;
	while (isspace(*c))
	{
		*c = get(ip);
		if (*c > 0)
			read += 1;
	}

	return read;
}
#define DMODE 0

#if DMODE
extern
short _prt_lmode;
#endif

short get_num(void *ip, InFunc *get, short *c, char *args, AT *at, short *cnt)
{
	short read = 0;
#if __LONGLONG__
	__ll n = {0,0};
#else
	union
	{
		long lo;
	} n = {0};
#endif
	char *p;

	read += spaces(ip, get, c);

	if (at->fupper and at->ll eq 0)
		at->ll = 1;

	if (!at->base)
	{
		at->base = 10;
		at->neg = false;
		if (*c eq '%')
		{
			at->base = 2;
			*c = get(ip);
			if (*c < 1)
				goto done;
			read += 1;
		}
		elif (*c eq '0')
		{
			*c = get(ip);
			if (*c < 1)
				goto savnum;

			read += 1;
			if (*c != 'x' and *c != 'X')
			{
				at->base = 8;
				at->digits[8]= '\0';
				goto zeroin;
			}

			at->base = 16;
			*c = get(ip);
			if (*c < 1)
				goto done;
			read += 1;
		}
	}

	if (    at->neg eq false
	    and at->base eq 10
	    and (   ((at->neg = (*c eq '-')) != 0)
	         or (*c eq '+')
	        )
	   )
	{
		if (*c < 1)
			goto done;
		*c = get(ip);
		if (*c < 1)
			goto done;
		read += 1;
	}

	at->digits[at->base] = '\0';

	p = strchr(at->digits,toupper(*c));

	if ((!*c or !p) and at->width)
		goto done;

	while (p and at->width-- and *c)
	{
#if __LONGLONG__
		if (at->ll >= 2)
			n = _ullsmul(n, at->base, p - at->digits);
		else
#endif
			n.lo = (n.lo * at->base) + (p - at->digits);
		*c = get(ip);
		read += 1;
zeroin:
		p = strchr(at->digits,toupper(*c));
	}

savnum:
	if (at->store)
	{
		if (at->neg eq true)
#if __LONGLONG__
			if (at->ll >= 2)
				n = _llneg(n);
			else
#endif
				n.lo = -n.lo;

#if __LONGLONG__
		if (at->ll >= 2)
			*((__ll *) args) = n;
		else
#endif
		if (at->ll
#if DMODE
		   or _prt_lmode
#endif
		  )
			*((long *) args) = n.lo;
		else
			*((int  *) args) = n.lo;
		*cnt += 1;
	}

done:
/*	alert_msg("get_num %d", read);	*/
	return read;
}

#ifndef __NO_FLOAT__
short fp_scan(void *ip, InFunc *get, short *c, char *args, AT *at, short *cnt)
{
	short read = 0;
	int state;
	double fn, frac, fx;

	spaces(ip, get, c);

	if (at->fupper and at->ll eq 0)
		at->ll = 1;

	at->fstate = FS_INIT;
	fn = 0; frac = 0; fx = 0;

	while (*c and at->width--)
	{
		if (*c >= '0' and *c <= '9')
			at->trans = FC_DIG;
		elif (*c eq '.')
			at->trans = FC_DOT;
		elif (*c eq '+' or *c eq '-')
			at->trans = FC_SIGN;
		elif (tolower(*c) eq 'e')
			at->trans = FC_E;
		else
			break;			/* while */

		state = fp_do[at->trans][at->fstate];
		if (state eq F_QUIT)
			break;			/* while */

		switch (state)
		{
		case F_SIGN:
			at->neg = (*c eq '-');
			break;
		case F_ESIGN:
			at->eneg = (*c eq '-');
			break;
		case F_INT:
			fn = 10*fn + (*c - '0');
			break;
		case F_FRAC:
			frac = 10*frac + (*c - '0');
			at->fraclen++;
			break;
		case F_EXP:
			at->expo = 10*at->expo + (*c - '0');
			break;
		}

		at->fstate = fp_ns[at->trans][at->fstate];
		*c = get(ip);
		read += 1;
	}

	if (fp_sval[at->fstate])
		if (at->store)
		{
			while (at->fraclen--) frac /= 10.0;
			fx = makeflt(fn, frac, at->eneg ? -at->expo : at->expo);
			if (at->neg) fx = -fx;

			if (at->ll)
				*((double *) args) = fx;
			else
				*((float  *) args) = fx;
			++*cnt;
		}

/*	alert_msg("fp_scan %d", read); */
	return read;
}
#endif

short _scanf(void *ip, InFunc *get, UnFunc *unget, const char *fmt, char **args)
{
	short c, read = 0, c2, cnt = 0;
	char *p, *q;

	if (!*fmt)
		return 0;

	c = get(ip);
	if (c < 1)
		goto done;

	while (*fmt)
	{
		if (*fmt eq '%')
		{
			AT at = {-1, 1, 10, 0, 2, 0, false, true, true,
			         "\t\n\013\f\r ", "0123456789ABCDEF"
			        };

			fmt += 1;

			if (*fmt eq '*')
			{
				at.endnull = false;
				at.store   = false;
				fmt += 1;
			}

			while (isdigit(*fmt))		/* width digit(s) */
			{
				if (at.width eq -1)
					at.width = 0;

				at.width = (at.width * 10) + (*fmt++ - '0');
				at.wide1 = at.width;
			}

			do
			{
				short f = tolower(*fmt);
				if (f eq '*')
					at.endnull = false,
					at.store   = false;
				elif (f eq 'l')
					at.ll += 1;
				elif (f eq 'h')
					at.ll = 0;
				else
					break;

				fmt += 1;
			}
			od

			at.fupper = isupper(*fmt);
			switch(tolower(*fmt))
			{
			case 'i':		/* any-base numeric */
				at.base = 0;
				read += get_num(ip, get, &c, *args, &at, &cnt);
			break;
			case 'b':		/* unsigned binary */
				at.base = 2;
				read += get_num(ip, get, &c, *args, &at, &cnt);
			break;
			case 'o':	/* unsigned octal */
				at.base = 8;
				read += get_num(ip, get, &c, *args, &at, &cnt);
			break;
			case 'x':	/* unsigned hexadecimal */
				at.base = 16;
				read += get_num(ip, get, &c, *args, &at, &cnt);
			break;
			case 'd':	/* SIGNED decimal */
				at.neg = false;
				read += get_num(ip, get, &c, *args, &at, &cnt);
			break;
			case 'u':	/* unsigned decimal */
				read += get_num(ip, get, &c, *args, &at, &cnt);
			break;
#ifndef __NO_FLOAT__
			case 'e':	/* float */
			case 'f':
			case 'g':
				read += fp_scan(ip, get, &c, *args, &at, &cnt);
				break;
#endif
			case 'c':	/* character data */
				at.width = at.wide1;
				at.endnull	= false;
				at.delim[0] = '\0';
				goto strproc;
			case '[':	/* string w/ delimiter set */
				/* get delimiters */
				p = at.delim;
				if (*++fmt eq '^')
					fmt++;
				else
					at.ll = 1;

				if ((*fmt eq ']') or (*fmt eq '-'))
				{
					*p++ = *fmt++;
					at.rngflag = 0;
				}
				while (*fmt != ']')
				{
					if (*fmt eq '\0')
						goto done;
					switch (at.rngflag)
				    {
				    case 1:
						c2 = *(p-2);
						if (c2 <= *fmt)
					    {
						    p -= 2;
						    while (c2 < *fmt)
						    	*p++ = c2++;
						    at.rngflag = 2;
						    break;
					    }
					    /* fall thru intentional */
				    case 0:
						at.rngflag = (*fmt eq '-') ? 1 : 0;
					break;
				    case 2:
						at.rngflag = 0;
				    }
					*p++ = *fmt++;
				}
				*p = '\0';
				goto strproc;
			case 's':	/* string data */
				read += spaces(ip, get, &c);
strproc:
				/* process string */
				p = *args;
				/* if the 1st char fails, match fails
				   HR: if a delimiter is the first, return empty string */
				if (at.width)
				{
					q = strchr(at.delim, c);
					if ((c < 1) or (at.ll ? !q : (int) q))
					{
						if (at.endnull)
							*p = '\0';
						goto strend;
					}
				}
				do
				{
					if (at.store)
						*p++ = c;

					c = get(ip);
					if (c <= 0)
						break;
					read += 1;
					if (--at.width eq 0)
						break;
					q = strchr(at.delim, c);
					if (at.ll ? !q : (int) q)
						break;
				}
				od
strend:
				if (at.store)
				{
					if (at.endnull)
						*p = '\0';
					++cnt;
				}
				break;
			case 'n':
				if (at.store)
				{
					p = *args;
					*(short *)p = read;
				}
				break;
			case '\0':	/* early EOS */
				--fmt;
				/* FALL THRU */
			default:
				goto cmatch;
			}

			if (at.store)
				args++;
		}
		elif (isspace(*fmt))		/* skip whitespace */
			read += spaces(ip, get, &c);
		else
		{			/* normal match char */
cmatch:
			if (c != *fmt)
				break;
			c = get(ip);
			if (c <= 0)
				break;
			 read += 1;
		}

		fmt += 1;

		if (!*fmt)
			break;
	}
done:						/* end of scan */
	if (c < 0 and cnt eq 0)
		return EOF;
	unget(c, ip);
	return cnt;
}

static
InFunc __fgetc
{
	return fgetc(ip);
}

static
UnFunc __fungetc
{
	return ungetc(c, ip);
}

static
InFunc __sgetc
{
	char **s = ip;
	char c = *(*s)++;
	return c == '\0' ? EOF : c;
}

static
UnFunc __sungetc
{
	char **s = ip;
	if (c == EOF)
		c = '\0';
	return *--(*s) = c;
}

short fscanf(FILE *fp, const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	return _scanf(fp, __fgetc, __fungetc, fmt, (char **)args);
}

short scanf(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	return _scanf(stdin, __fgetc, __fungetc, fmt, (char **)args);
}

short sscanf(const char *buf, const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	return _scanf(&buf, __sgetc, __sungetc, fmt, (char **)args);
}

short vscanf(const char *fmt, va_list args)
{
	return _scanf(stdin, __fgetc, __fungetc, fmt, (char **)args);
}

short vsscanf(char *buf, const char *fmt, va_list args)
{
	return _scanf(buf, __sgetc, __sungetc, fmt, (char **)args);
}

short vfscanf(FILE *fp, const char *fmt, va_list args)
{
	return _scanf(fp, __fgetc, __fungetc, fmt, (char **)args);
}
