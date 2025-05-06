/* C library - printf/scanf guts */

#define FILE	char
#define EOF	-1
#define EOS	0
#define NULL	0L

/* printf's (see below for the guts) */

char *_dopf();

fprintf(fp, fmt, args) FILE *fp; char *fmt; int args; {
	extern char _pfb[256];
	_dopf(_pfb, fmt, &args);
	return fputs(_pfb, fp);
}

printf(fmt, args) char *fmt; int args; {
	extern char _pfb[256];
	extern FILE *stdout;
	_dopf(_pfb, fmt, &args);
	return fputs(_pfb, stdout);
}

/* scanf routines */

fscanf(f, fmt, args) FILE *f; char *fmt; int *args; {
	extern char *_sfcp;
	extern FILE *_sffp;
	_sffp = f;
	_sfcp = NULL;
	return _dosf(fmt, &args);
}

scanf(fmt, args) char *fmt; int *args; {
	extern char *_sfcp;
	extern FILE *_sffp, *stdin;
	_sffp = stdin;
	_sfcp = NULL;
	return _dosf(fmt, &args);
}

sscanf(s, fmt, args) char *s; char *fmt; int *args; {
	extern char *_sfcp;
	extern FILE *_sffp;
	_sffp = NULL;
	_sfcp = s;
	return _dosf(fmt, &args);
}
		
/* the guts of the scanf's */

_dosf(fmt, args) char *fmt; int **args; {
	int assigned, wid, lng, skip, *ip, f, c, m, base;
	extern char _pfb[1];
	long n, *lp, atof();
	char *cp;
	assigned = 0;
	c = _sfget();
	while ((f = *fmt++) && c != EOF) {
		if (f <= ' ') { /* skip spaces */
			while (c <= ' ' && c != EOF)
				c = _sfget();
		}
		else if (f != '%') { /* match character */
			if (c != f) 
				return assigned;
			c = _sfget();
		}
		else	{
			wid = lng = skip = 0;
			if ((f = *fmt++) == '*') { /* skip assignment */
				skip++;
				f = *fmt++;
			}
			while (f >= '0' && f <= '9') { /* width of value */
				wid = wid * 10 + f - '0';
				f = *fmt++;
			}
			if (f == 'l') { /* long */
				lng++;
				f = *fmt++;
			}
			else if (f == 'h') { /* short */
				f = *fmt++;
			}
			switch (f) { /* conversion spec */
			case '%':
				if (c != '%') return assigned;
				c = _sfget();
				break;
			case 'c':
				if (wid == 0) {
					cp = *args++;
					if (!skip) {
						*cp = c;
						assigned++;
					}
					c = _sfget();
					break;
				}
			case 's':
				cp = *args++;
				while (c <= ' ' && c != EOF)
					c = _sfget();
				while (c > ' ' && c != EOF) {
					if (!skip) *cp++ = c;
					c = _sfget();
					if (--wid == 0) break;
				}
				*cp = 0;
				if (!skip) assigned++;
				break;
			case 'D': case 'X': case 'O':
				lng = 1;
				f = f - 'A' + 'a';
			case 'd': case 'x': case 'o':
				base = (f == 'x' ? 16 : f == 'o' ? 8 : 10);
				n = 0L;
				while (c != EOF && c <= ' ')
					c = _sfget();
				if ((m = _sfnum(c, base)) < 0)
					return assigned;
				do	{
					n = n * base + m;
					c = _sfget();
					m = _sfnum(c, base);
					if (--wid == 0) break;
				} while (m >= 0);
				if (m >= 0) c = _sfget();
				if (!skip) {
					if (lng) {
						lp = *args++;
						*lp = n;
					}
					else	{
						ip = *args++;
						*ip = n;
					}
					assigned++;
				}
				break;
			case 'e': case 'f': case 'E': case 'F':
				while (c <= ' ' && c != EOF)
					c = _sfget();
				if (!_sfflt(c))
					return assigned;
				for (cp = _pfb; _sfflt(c); ) {
					*cp++ = c;
					c = _sfget();
				}
				*cp = 0;
				if (!skip) {
					lp = *args++;
					*lp = atof(_pfb);
					assigned++;
				}
				break;
			default:
				return assigned;
			}
		}
	}
	return f == 0 ? assigned : EOF;
}


_sfnum(c, base) {
	if (c >= '0' && c <= '9')
		return c - '0';
	else if (base == 16 && c >= 'a' && c <= 'f')
		return c - 'a' + 10;
	else if (base == 16 && c >= 'A' && c <= 'F')
		return c - 'A' + 10;
	else 	return -1;
}

_sfflt(c) { /* pretty lame parser for float numbers, but so it goes */
	if (c >= '0' && c <= '9') return 1;
	if (c == '+' || c == '-' || c == '.') return 1;
	if (c == 'e' || c == 'E') return 1;
	return 0;
}

_sfget() {
	extern char *_sfcp;
	extern FILE *_sffp;
	if (_sffp) return getc(_sffp);
	if (_sfcp && *_sfcp) return *_sfcp++;
	return EOF;
}

char *_sfcp;	/* char pointer for scanf input string */
FILE *_sffp;	/* FILE pointer for scanf input stream */

/* guts of the printf stuff */

#define	MINUSFLG	1
#define	PLUSFLG		2
#define	BLANKFLG	4
#define	POUNDFLG	8
#define	ZEROFLG		16
#define	LONGFLG		32
#define	SIGNFLG		64
#define	LOWERFLG	128

#define	MAXINT	32767

char	_pfb[256];	/* in case someone needs a buffer */

sprintf(buf, fmt, args)	char *buf, *fmt; int args; {
	return _dopf(buf, fmt, &args) - buf;
}

char *_numcnv(), *_fltcnv();

char *
_dopf(buf, fmt, i_p) char *buf, *fmt; int *i_p; {
	char	c, **s_p, *s;
	long	strtol();
	int	i, lng, precision, minfldw, flags;

	for (c = *fmt; ; c = *++fmt) {
		/* scan to next conversion specification */
		while (c != '%') {
			*buf++ = c;
			if (c == EOS) {
				return buf - 1;
			}
			c = *++fmt;
		}
		c = *++fmt;
		/* scan flags */
		for (flags = 0; ; c = *++fmt) {
			if (c == '-') flags |= MINUSFLG;
			else if (c == '+') flags |= PLUSFLG;
			else if (c == ' ') flags |= BLANKFLG;
			else if (c == '#') flags |= POUNDFLG;
			else break;
		}
		/* scan minimum field width */
		if (c == '*') {
			minfldw = *i_p++;
			c = *++fmt;
		}
		else	{
			if (c == '0') flags |= ZEROFLG;
			minfldw = (int)strtol(fmt, &fmt, 10);
			c = *fmt;
		}
		/* scan precision */
		precision = -1;
		if (c == '.') {
			c = *++fmt;
			if (c == '*') {
				precision = *i_p++;
				c = *++fmt;
			}
			else	{
				precision = (int)strtol(fmt, &fmt, 10);
				c = *fmt;
			}
		}
		if (c == 'l') {
			flags |= LONGFLG;
			c = *++fmt;
		}
		switch (c) {
		case 'd':
			buf = _numcnv(buf, 10, flags | SIGNFLG, &i_p,
				precision, minfldw);
			break;
		case 'o':
			buf = _numcnv(buf, 8, flags, &i_p, precision, minfldw);
			break;
		case 'u':
			buf = _numcnv(buf, 10, flags, &i_p, precision, minfldw);
			break;
		case 'x':
			flags |= LOWERFLG;
		case 'X':
			buf = _numcnv(buf, 16, flags, &i_p, precision, minfldw);
			break;
		case 'f':
			buf = _fltcnv(buf, 'f', flags, &i_p, 
					precision, minfldw);
			break;
		case 'e':
			flags |= LOWERFLG;
		case 'E':
			buf = _fltcnv(buf, 'E', flags, &i_p, 
					precision, minfldw);
			break;
		case 'g':
			flags |= LOWERFLG;
		case 'G':
			buf = _fltcnv(buf, 'G', flags, &i_p, precision, minfldw);
			break;
		case 'c':
			*buf++ = *i_p++;
			break;
		case 's':
			if (precision < 0) precision = MAXINT;
			s_p = (char **)i_p;
			s = *s_p++;
			i_p = (int *)s_p;
			for (lng = 0; s[lng] != EOS && lng < precision; ++lng);
			i = minfldw - lng;
			if ((flags & MINUSFLG) == 0) { /* right justify */
				while (i-- > 0) *buf++ = ' ';
			}
			while (lng--) *buf++ = *s++;
			while (i-- > 0) *buf++ = ' ';
			break;
		case '%':
		default:
			*buf++ = c;
			break;
		}
	}
}

/* 
 * convert float to ascii for my 32 bit floating point format
 *	bit	function
 *	31	sign
 *	24-30	exponent (excess 64)
 *	0-23	fraction
 */

#define EXCESS	64
#define DIGITS	24
#define MAXFRAC	0xFFFFFF
#define MAXEXP	0x7F
#define MAXBITS	32

#define sign(x) ((x >> 31) & 1)
#define exp(x) (((x >> 24) & MAXEXP) - EXCESS)
#define frac(x) (x & MAXFRAC)
#define negate(x) (x ^ 0x80000000L)

char *
_fltcnv(buf, style, flags, f_p, precision, minfldw) 
	char 	*buf;
	int	style;
	int	flags;
	long	**f_p;
	int 	precision;
	int	minfldw;
{
	long	x;
	int 	e, ee, len;
	char 	ibuf[15], fbuf[15], ebuf[6], sbuf[2], *p, *r;
	unsigned long f, t, b, d;

	x = **f_p;
	*f_p += 1;
	*ibuf = *fbuf = *sbuf = *ebuf = 0;
	if (precision < 0)
		precision = 6;
	else if (precision > 13)
		precision = 13;
	if (x == 0L) {
		strcpy(ibuf, "0");
		if (precision > 0)
			strcpy(fbuf, ".0");
	}
	else	{
		if (sign(x))
			strcpy(sbuf, "-");
		else if (flags & PLUSFLG)
			strcpy(sbuf, "+");
		else if (flags & BLANKFLG)
			strcpy(sbuf, " ");
		e = exp(x);
		f = frac(x);
		if (style == 'E' || e >= MAXBITS || e <= -DIGITS) {
			ee = 0;
			while (e > 2) {
				d = f % 10L;
				f = f / 10L;
				while (f && (f & 0x800000L) == 0) {
					f <<= 1;
					e--;
				}
				f += d;
				ee++;
			}
			while (e < 0) {
				f = f * 10L;
				d = 0L;
				while (f & 0xFF000000L) {
					d |= (f & 1L);
					f >>= 1;
					e++;
				}
				f += d;
				ee--;
			}
			ebuf[0] = flags & LOWERFLG ? 'e' : 'E';
			if (ee < 0) {
				ebuf[1] = '-';
				ee = -ee;
			}
			else	ebuf[1] = '+';
			ebuf[2] = (ee / 10) + '0';
			ebuf[3] = (ee % 10) + '0';
			ebuf[4] = 0;
		}
		/* now get the integer part */
		if (e > 0) {
			if (e > DIGITS)
				t = f << (e - DIGITS);
			else	t = f >> (DIGITS - e);
			_ltoc(t, ibuf);
			f = (f << e) & MAXFRAC;
			e = 0;
		}
		else	{
			strcpy(ibuf, "0");
			if (e < 0)
				f = f >> -e;
		}
		/* now get the fraction part */
		if (precision > 0) {
			if (f) {
				b = 0x800000;
				d =  500000000;
				t = 1000000000;
				while (b) {
					if (f & b)
						t += d;
					b >>= 1;
					d >>= 1;
				}
				_ltoc(t, fbuf);
				fbuf[0] = '.';
			}
			else 	strcpy(fbuf, ".0");
		}
	}
	/* adjust the fraction part, trailing 0's, etc */
	if (*fbuf) {
		for (e = strlen(fbuf); e < 15; e++)
			fbuf[e] = '0';
		fbuf[precision+1] = 0;
		if (!((flags & POUNDFLG) && style == 'G')) {
			/* drop trailing 0's */
			for (e = precision; e > 0 && fbuf[e] == '0'; e--)
				fbuf[e] = 0;
			if (e == 0) 
				*fbuf = 0;
		}
	}
	/* okay, now fill out buf with the number */
	r = buf;
	len = strlen(ibuf) + strlen(fbuf) + strlen(ebuf) + strlen(sbuf);
	if (flags & MINUSFLG) {
		while (len < minfldw) {
			*buf++ = ' ';
			len++;
		}
	}
	if (*sbuf) 
		*buf++ = *sbuf;
	for (p = ibuf; *buf = *p++; )
		buf++;
	if (*fbuf) {
		for (p = fbuf; *buf = *p++; )
			buf++;
	}
	else if (flags & BLANKFLG)
		*buf++ = '.';
	if (*ebuf) {
		for (p = ebuf; *buf = *p++; )
			buf++;
	}
	if ((flags & MINUSFLG) == 0) {
		while (len < minfldw) {
			*buf++ = ' ';
			len++;
		}
	}
	*buf = 0;
	return buf;
}

_ltoc(x, p) long x; char *p; {
	char *r;
	int i, j, t;
	r = p;
	if (x == 0) {
		*p++ = '0';
		*p = 0;
	}
	else	{
		if (x < 0) {
			*p++ = '-';
			x = -x;
		}
		for (i = 0; x > 0; x = x / 10L)
			p[i++] = (x % 10L) + '0';
		p[i--] = 0;
		for (j = 0; j < i; ) {
			t = p[i];
			p[i--] = p[j];
			p[j++] = t;
		}
	}
}

char *
_numcnv(buf, base, flags, ip_p, precision, minfldw)
	char	*buf;
	unsigned int	base;
	int	**ip_p;
{
	char	numbuf[20], prefix[5], *s, *p, *strncpy();
	int	n, pad, lng, d;
	long	value, *l_p;
	unsigned long	uvalue;

	s = numbuf;
	p = prefix;
	if (flags & LONGFLG) {
		l_p = (long *)*ip_p;
		value = *l_p++;
		*ip_p = (int *)l_p;
	}
	else	{
		value = (long)**ip_p;
		*ip_p += 1;
	}
	if (flags & SIGNFLG) {
		if (value < 0) {
			*p++ = '-';
			value = -value;
		}
		else	{
			if (flags & PLUSFLG) *p++ = '+';
			else if (flags & BLANKFLG) *p++ = ' ';
		}
	}
	uvalue = (unsigned long) value;
	while (uvalue) {
		d = uvalue % base;
		*s++ = (d < 10) ? d + '0' 
				: d - 10 + ((flags & LOWERFLG) ? 'a' : 'A');
		uvalue /= base;
	}
	lng = (int)(s - numbuf);
	n = (int)(p - prefix);
	pad = minfldw - n;
	if (flags & ZEROFLG) precision = minfldw - n;
	if (precision < 0) precision = 1;
	if (flags & POUNDFLG) {
		if (base == 8 && lng >= precision) precision = lng + 1;
		else if (base == 16) {
			*p++ = '0';
			*p++ = flags & LOWERFLG ? 'x' : 'X';
			n += 2;
			precision -= 2;
		}
	}
	pad -= lng > precision ? lng : precision;
	if (pad < 0) pad = 0;
	if ((flags & MINUSFLG) == 0) {
		while (pad--) *buf++ = ' ';
		pad = 0;
	}
	strncpy(buf, prefix, n);
	buf += n;
	while (precision-- > lng) *buf++ = '0';
	while (lng--) *buf++ = *--s;
	while (pad--) *buf++ = ' ';
	return	buf;
}
