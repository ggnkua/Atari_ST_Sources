#include <stdio.h>
#include <ctype.h>

extern int _digits();	 /* defined in printf.c */

static FILE *scanstream;
static char *scanstr;
static int file;
static int scanferr;

static int nextch()
{
    return file ? fgetc(scanstream) : *scanstr++;
}

static int skipwhite()
{
    int ch;

    do
	ch = nextch();
    while (ch == ' ' || ch == '\t' || ch == '\n');
    return ch;
}

static int val(ch, base)
int ch, base;
{
    int result = -1;

    if (ch >= '0' && ch <= '9') result = ch - '0';
    else if (ch >= 'a') result = ch - 'a'+10;
    else if (ch >= 'A') result = ch - 'A'+10;
    if (result > base)
	result = -1;
    if (result == -1)
	scanferr = 1;

    return result;
}

static long nconv(convchar, firstch, width)
int convchar, firstch;
int width;
{
    int base, ch = firstch, temp, neg = 0, atleast1 = 0;
    register long result = 0;

    switch (convchar) {
	case 'd': base = 10; break;
	case 'o': base = 8; break;
	case 'x': base = 16; break;
	case 'h': base = 10; break;
    }
    if (ch == '-')
	neg = 1, ch = nextch();
    while (width && (temp = val(ch, base)) != -1) {
	if (base == 10)
	    result = (result << 3) + (result << 1) + temp;
	else if (base == 8)
	    result = (result << 3) + temp;
	else
	    result = (result << 4) + temp;
	width--;
	atleast1 = 1;
	ch = nextch();
    }
    if (atleast1 && scanferr)	/* not an error if read at least one digit */
	scanferr = 0;
    if (file)
	ungetc(ch, scanstream);
    else
	scanstr--;
    return neg ? -result : result;
}

static double fconv(ch, width)
register int ch;
int width;
{
    int ten = 10;
    double dten = ten;
    short sgn;
    int dexp;
    register char *sp;	  /* string pointer */
    int pastdot = 0, paste = 0, exp = 0, expsgn = 0, leading = 1, atleast1 = 0;
    int digcnt = 19;   /* don't accumulate more than 19 digits */
    double retval = 0;

    if (ch == '-') {
	sgn = 1;
	ch = nextch();
    }
    else
	sgn = 0;
    dexp = 0;
    while (width) {
	if (ch == '-' && paste)
	    expsgn = 1;
	else if (isdigit(ch))
	    if (paste)
		exp = exp*10 + ch-'0';
	    else {
		if (ch != '0')
		    leading = 0;
		if (!digcnt)
		    dexp++;
		else {
		    if (pastdot)
			dexp--;
		    if (!leading) {
			retval = retval*dten + ch-'0';
			digcnt--;
		    }
		}
	    }
	else if (ch == '.' && !pastdot)
	    pastdot = 1;
	else if ((ch == 'E' || ch == 'e') && !paste)
	    paste = 1;
	else 
	    break;

	atleast1 = 1;
	ch = nextch();
	width--;
    }
    if (!atleast1)
	scanferr = 1;

    if (expsgn)
	dexp -= exp;
    else
	dexp += exp;

    while (dexp)
	if (dexp < 0) {
	    retval /= dten;
	    dexp++;
	}
	else {
	    retval *= dten;
	    dexp--;
	}

    if (sgn)
	retval *= -1;

    if (file)
	ungetc(ch, scanstream);
    else
	scanstr--;
    return retval;
}

/*VARARGS*/
static int _scanf(args)
char **args;
{
    int nitems = 0;	/* count of number of successfully converted items */
    register char *format, *sptr; 
    char *tp;
    int fch, sch, convchar;
    int supress, longitem, width;
    double real;
    long longint;

    scanferr = 0;
    format = *args++;
    while (*format) {
	fch = *format++;

	if (fch == ' ' || fch == '\t' || fch == '\n') {
	    sch = skipwhite();
	    if (sch != EOF)
		if (file)
		    ungetc(sch, scanstream);
		else
		    scanstr--;
	    continue;	
	}

	if (fch != '%') {
	    sch = skipwhite();
	    if (sch == EOF)
		return EOF;
	    if (sch != fch) {
		if (file)
		    ungetc(sch, scanstream);
		else
		    scanstr--;
		return nitems;
	    }
	}
	else {
	    longitem = supress = 0; width = 256;
	    if (*format == '*') {
		supress = 1;
		format++;
	    }
	    if (*format >= '0' && *format <= '9')
		{tp = format; width = _digits(&tp); format = tp;}
	    if (*format == 'l') {
		longitem = 1;
		format++; }
	    convchar = *format++;

	    if (convchar == 'c') {
		if ((sch = nextch()) == EOF)
		    return EOF;
		if (!supress)
		    **args++ = sch;
		nitems++;
	    } else
	    if (convchar == 'd' || convchar == 'o' || convchar == 'x' ||
		convchar == 'h') {
		if ((sch = skipwhite()) == EOF)
		    return EOF;
		longint = nconv(convchar, sch, width);
		if (scanferr)
		    return nitems;
		if (!supress)
		    if (longitem)
			*(long *)(*args++) = longint;
		    else if (convchar == 'h')
			*(short *)(*args++) = (short)longint;
		    else
			*(int *)(*args++) = (int)longint;
		nitems++;
	    } else
	    if (convchar == 'e' || convchar == 'f') {
		if ((sch = skipwhite()) == EOF)
		    return EOF;
		real = fconv(sch, width);
		if (scanferr)
		    return nitems;
		if (!supress)
		    if (longitem)
			*(double *)(*args++) = real;
		    else
			*(float *)(*args++) = (float)real;
		nitems++;
	    } else
	    if (convchar == 's') {
		if ((sch = skipwhite()) == EOF)
		    return EOF;
		if (!supress)
		    sptr = *args++;
		while (width && sch != ' ' && sch != '\t' && sch != '\n') {
		    if (!supress)
			*sptr++ = sch;
		    if ((sch = nextch()) == EOF)
			return EOF;
		    width--;
		}
		*sptr++ = 0;	/* must terminate with a null */
		if (file)
		    ungetc(sch, scanstream);
		else
		    scanstr--;
		nitems++;
	    }
	}
    }
    return nitems;
}

/*VARARGS*/
int scanf(args)
int args;
{
    scanstream = stdin;
    file = 1;
    return _scanf(&args);
}

/*VARARGS1*/
int fscanf(stream, args)
FILE *stream;
int args;
{
    scanstream = stream;
    file = 1;
    return _scanf(&args);
}

/*VARARGS1*/
int sscanf(s, args)
char *s;
int args;
{
    scanstr = s;
    file = 0;
    _scanf(&args);
}
