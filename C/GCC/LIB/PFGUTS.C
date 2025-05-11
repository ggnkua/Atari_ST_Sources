
/* this is based on the DOPRNT distributed by MUN, but extensively
   hacked by jrd.  It's no longer doprnt, rather it's something general,
   purpose, suitable for underlying various printf variants etc */

#include	<varargs.h>
#include	<ctype.h>

#define	SZ_NORM		0
#define	SZ_SHORT	1
#define	SZ_LONG		2

/* the formatter for flona */
char * _flofmt(buf, flags, value, precision, field_width)
char * buf;
int flags;
double value;
int precision, field_width;
{
  char * orig_buf = buf;
  long int_part;
  int place_number;
  double place;
  char digit[32];
  int idx, ndigits;
  int ten = 10;
  int zero = 0;

/* sanity check field qualifiers */
  if (field_width < 30) 
	field_width = 30;
  if (precision > field_width)
	precision = field_width;
  if (precision > 30)
	precision = 30;

  if (value < zero)
	{
	*buf++ = '-';
	value = -value;
	}
  int_part = (long )value;
  value = value - (double )int_part;
  for (idx = 0 ; (idx == 0) || (int_part > 0) ; idx++)
	{
	digit[idx] = int_part % ten;
/* kludge til we get doubles accurate... */
	if ((digit[idx] > 9) || (digit[idx] < 0))
		digit[idx] = 0;
	int_part = int_part / ten;
	}
  for ( ; idx > 0 ; )
	*buf++ = digit[--idx] + 48;

/* now do the decimal places */
  for (idx = 0 ; idx < 30 ; idx++)
	digit[idx] = 0;
  for (idx = 0, ndigits = 0 ; idx < 10 ; idx++)
	{
	value = value * ten;
	int_part = value;
	value = value - int_part;
	digit[idx] = int_part;
/* kludge til we get doubles accurate... */
	if ((digit[idx] > 9) || (digit[idx] < 0))
		digit[idx] = 0;
	if (int_part > 0) ndigits = idx + 1;
	}
  if (precision > -1)			/* he say how many places? */ 
	ndigits = precision;		/* yes, use his */
  if (ndigits > 0)			/* were there any? */
	{
	*buf++ = '.';
	for (idx = 0 ; idx < ndigits ; idx++)
		{
		*buf++ = digit[idx] + 48;
		}
	}
  *buf = '\0';
  return(orig_buf);  
}


/* and here's the main loop */
void _printf_guts(template, args, fun, funargs)
char	*template;
va_list	args;
void	(* fun)();	/* foo(char, args) */
long	**funargs;
{
  register char		c;
  register char		*s;
  register char		*p;
  register unsigned long	lnum;
  double		dnum;
  register int		tmp;
  register int		field;
  register int		precision;
  int			hash;
  int			pad;
  int			adjust;
  int			signfmt;
  int			size;
  int			upper;
  int			neg;
  char			numbuf[36];

  if (!template)
	return;

  while (c = *template++) 
	{
	if (c == '%') 
		{
		c = *template++;
		if (c == '#')
			hash = 1, c = *template++;
		    else
			hash = 0;

		signfmt = 0;
		adjust = 0;
		while (1) 
			{
			if (c == '-')
				adjust = 1, c = *template++;
			else if (c == '+')
				signfmt = 1, c = *template++;
			else if (c == ' ') 
				{
				if (!signfmt)	/* + take presidence */
					signfmt = -1;
				c = *template++;
				}
			    else
				break;
			}

		pad = ' ';
		field = 0;
		if (c == '0')
			pad = '0', c = *template++;
		if (isdigit(c)) 
			{
			while (isdigit(c)) 
				{
				field = field * 10 + c - '0';
				c = *template++;
				}
			}
		    else
		if (c == '*') 
			{
			field = va_arg(args, int), c = *template++;
			if (field < 0) 
				{
				field = -field;
				adjust = 1;
				}
			}

		precision = 32000;
		if (c == '.') 
			{
			c = *template++;
			if (c == '*') 
				{
				precision = va_arg(args, int);
				c = *template++;
				}
			    else 
				{
				precision = 0;
				while (isdigit(c)) 
					{
					precision = precision * 10
						+ c - '0';
					c = *template++;
					}
				}
			}

		size = SZ_NORM;
		if (c == 'l')
			size = SZ_LONG, c = *template++;
		else if (c == 'h')
			size = SZ_SHORT, c = *template++;
		/* This is dodgy - does X mean long hex or
		 * use uppercase hex digits?  Does both right
		 * now so becareful...
		 */
		if (isupper(c))
			upper = 1, size = SZ_LONG, c = tolower(c);
		    else
			upper = 0;

		if (c == 'd' || c == 'o' || c == 'x' || c == 'u')
			switch (size) 
				{
			case SZ_NORM:
			case SZ_SHORT:
				/* What kinda of machine we on?
				 * hopfully the C compiler will
				 * optimize this out...
				 *
				 * For shorts, we want sign extend
				 * for %d but not for %[oxu] -
				 * on 16 bit machines it don't
				 * matter.
				 * Assmumes C compiler has converted
				 * shorts to ints before pushing them.
				 */
				if (sizeof(int) < sizeof(long))
					lnum = (c == 'd') ? (long)
						va_arg(args, int) :
						va_arg(args, unsigned);
				    else
					lnum = va_arg(args, unsigned);
				break;

			case SZ_LONG:
				lnum = va_arg(args, unsigned long);
				}

		else if (c == 'e' || c == 'g' || c == 'f')
			{
			dnum = va_arg(args, double);
			}

		switch (c) 
			{
		case 'd':
			if (0 > (long) lnum)
				lnum = - (long) lnum, neg = 1;
			else
				neg = 0;
			s = &numbuf[sizeof(numbuf)];
			*--s = '\0';
			do 	{
				*--s = lnum % 10 + '0';
				lnum /= 10;
				} while (lnum);

			if (neg)
				*--s = '-';
			else if (signfmt > 0)
				*--s = '+';
			else if (signfmt < 0)
				*--s = ' ';
			goto put_string;

		case 'o':
			s = &numbuf[sizeof(numbuf)];
			*--s = '\0';
			do 	{
				*--s = (lnum & 0x7) + '0';
				lnum >>= 3;
				} while (lnum);

			if (hash && s[1])
				*--s = '0';
			goto put_string;

		case 'x':
			s = &numbuf[sizeof(numbuf)];
			*--s = '\0';
			p = upper ? "0123456789ABCDEF" :
				"0123456789abcdef";
			do 	{
				*--s = p[lnum & 0x0F];
				lnum >>= 4;
				} while (lnum);

			if (hash && s[1])
				*--s = upper ? 'X' : 'x', *--s = '0';
			goto put_string;

		case 'u':
			s = &numbuf[sizeof(numbuf)];
			*--s = '\0';
			do 	{
				*--s = lnum % 10 + '0';
				lnum /= 10;
				} while (lnum);
			goto put_string;

		case 'c':
			(* fun)(va_arg(args, int), funargs);
			break;

		case '%':
			(* fun)('%', funargs);
			break;

		case 'e': case 'g': case 'f':
			{
			{
			char dbuf[64];

			if (precision == 32000)
				precision = -1;
			s = _flofmt(&dbuf, 0, dnum, precision, field);
			if (precision < strlen(s))
				precision = strlen(s);
					/* don't confuse string copier. */
			};
			goto put_string;
			};

		case 's':
			s = va_arg(args, char *);
			/* fall through */

put_string:
			/* we have a string, now format & print it */
			tmp = strlen(s);
			if (tmp < precision)
				precision = tmp;
			if (field > precision) 
				{
				tmp = field - precision;
				if (adjust)
					adjust = tmp, pad = ' ';
				else
					adjust = -tmp;
				}
			    else
			if (field == precision)
				adjust = 0;
			while (adjust < 0) 
				{
				if ((*s == '-') && (pad == '0')) 
					{
					(* fun)(*s++, funargs);
					precision--;
					}
				(* fun)(pad, funargs);
				adjust++;
				}
			while (--precision >= 0)
				(* fun)(*s++, funargs);
			while (adjust) 
				{
				(* fun)(pad, funargs);
				adjust--;
				}
			}
		} 
	    else
		(* fun)(c, funargs);
	}
}
