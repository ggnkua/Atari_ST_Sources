overlay "find"

/******************************
*******************************
		file ani/c/lprintf.c
		I have a sneaking suspicion that the
		allignment tricks in _ildoprnt might not
		work on all processors, but its a great kludge
		for the 68000 - jim kent july 12 1985
**/



#include <stdio.h>

#define LSP_SZ 256


static ildoprnt();


idiot_sink(c)
char c;
{
putchar(c);
}

printf(frmt, args)
char		*frmt;
char		*args;
{
ildoprnt(idiot_sink, NULL, frmt, &args);
}

fsink(c, file)
register int c;
register FILE *file;
{
putc(c, file);
}


fprintf(file, frmt, args)
FILE *file;
char		*frmt;
char		*args;
{
ildoprnt(lfsink, file, frmt, &args);
}


/*
**	The actual formatting routine for printf, ioqprintf and sprintf
*/

extern char	*ltos ();

static
ildoprnt (sink, sarg, format, ap)
int		(*sink)();
FILE 	*sarg;
register char	*format;
char		*ap;
{
	register char	c, *bp;
	register int	n;
	char		*save_bp, nbuf[36];
	int		filchar, base;
	int		fldwth, prec;
	int		lftjust, longf;
	long int	l;

	if(!format)
		{
		lprintf("NULL format string in _ildoprnt\n");
		return;
		}
	while (c = *format++)
		if ( c != '%')
			(*sink) (c, sarg);
		else
		{
			bp = nbuf;
			fldwth = 0;
			lftjust = 0;
			longf = 0;
			prec = 0;
			filchar = ' ';

			if ((c = *format++) == '-')
			{
				++lftjust;
				c = *format++;
			}

			if (c == '0')
			{
				filchar = c;
				c = *format++;
			}

			if (c == '*')
			{
				fldwth = *((int *)ap);
				ap += sizeof(int);
				c = *format++;
			}
			else while ('0' <= c && c <= '9')
			{
				fldwth = fldwth * 10 + c - '0';
				c = *format++;
			}

			if (c == '.')
			{
				if ((c = *format++) == '*')
				{
					prec = *((int *)ap);
					ap += sizeof(int);
					c = *format++;
				}
				else while ('0' <= c && c <= '9')
				{
					prec = prec * 10 + c - '0';
					c = *format++;
				}
			}

			if (c == 'l')
			{
				++longf;
				c = *format++;
			}

			switch(c)
			{
			case 'd':
				base = -10;
				goto pnum;

			case 'u':
				base = 10;
				goto pnum;

			case 'x':
				base = 16;
				goto pnum;

			case 'o':
				base = 8;
pnum:
				if (longf)
				{
					l = *(long *)ap;
					ap += sizeof(long);
				}
				else
				{
					l = *((int *)ap);
					ap += sizeof(int);
					if (c != 'd')
						l &= 0x0000ffffL;
				}

				if (l < 0 && c == 'd' && filchar == '0')
				{
					(*sink) ('-', sarg);
					fldwth--;
					l = -l;
				}

				bp = ltos (bp, l, base);

				break;

			case 's':
				bp = *( (char **)ap);
				ap += sizeof(char *);
				if (!bp)
					bp = "(null)";
				break;

			case 'c':
				*bp++ = *((int *)ap);
				ap += sizeof(int);
				break;

			case '\0':
				--format;
				break;

			default:
				*bp++ = c;
				break;
			}

			if (c != 's')
			{
				*bp = '\0';
				n = bp - nbuf;
				bp = nbuf;
			}
			else
			{
				save_bp = bp;
				for (n = 0; *bp++; ++n)
					;
				if (prec && n > prec)
					n = prec;
				bp = save_bp;
			}

			if ((fldwth -= n) < 0)
				fldwth = 0;

			if (!lftjust)
				while (fldwth)
				{
					(*sink) (filchar, sarg);
					--fldwth;
				}

			while (n)
			{
				(*sink) (*bp++, sarg);
				--n;
			}

			if (lftjust)
				while (fldwth)
				{
					(*sink) (filchar, sarg);
					--fldwth;
				}
		}
}




/*
**	Convert long to string
*/

char	*ltos (bufp, num, base)
char		*bufp;
long		num;
register int	base;
{
	register char		*p, *q;
	register unsigned int	rem;
	unsigned long		unum;
	int			sign = {0};
	char			tbuf[34];

	q = tbuf;
	*q++ = '\0';

	if (num == 0L)
		*q++ = '0';
	else
	{
		if (num < 0L && base <= 0)
		{
			sign++;
			unum = -num;
		}
		else
			unum = num;

		if (base == 0)
			base = 10;
		else
		{
			if (base < 0)
				base = -base;
			if (base == 1)
				base = 10;
		}

		while (unum)
		{
			rem = unum % base;
			*q++ = rem + ((rem > 9) ? ('a' - 10) : '0');
			unum /= base;
		}

		if (sign)
			*q++ = '-';
	}

	p = bufp;
	while (*p++ = *--q)
		;

	return (--p);
}


