#include <stdio.h>
#include <ctype.h>

/*
 * %efg were loosing big time
 *	fixed  ++jrb
 * all floating conversion now done by atof. much is gained by this.
 *	++jrb
 */

#ifndef __NO_FLOAT__
#define FLOATS 1
#endif

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

extern        char    _numstr[];

#define	skip()	while(isspace(c)) { if ((c=(*get)(ip))<1) goto done; }
#define TEN_MUL(X)	((((X) << 2) + (X)) << 1)

#if FLOATS
/* fp scan actions */
#define F_NADA	0	/* just change state */
#define F_SIGN	1	/* set sign */
#define F_ESIGN	2	/* set exponent's sign */
#define F_INT	3	/* adjust integer part */
#define F_FRAC	4	/* adjust fraction part */
#define F_EXP	5	/* adjust exponent part */
#define F_QUIT	6

#define NSTATE	8
#define FS_INIT		0	/* initial state */
#define FS_SIGNED	1	/* saw sign */
#define FS_DIGS		2	/* saw digits, no . */
#define FS_DOT		3	/* saw ., no digits */
#define FS_DD		4	/* saw digits and . */
#define FS_E		5	/* saw 'e' */
#define FS_ESIGN	6	/* saw exp's sign */
#define FS_EDIGS	7	/* saw exp's digits */

#define FC_DIG		0
#define FC_DOT		1
#define FC_E		2
#define FC_SIGN		3

/* given transition,state do what action? */
int fp_do[][NSTATE] = {
{F_INT,F_INT,F_INT,
     F_FRAC,F_FRAC,
     F_EXP,F_EXP,F_EXP},	/* see digit */
{F_NADA,F_NADA,F_NADA,
     F_QUIT,F_QUIT,F_QUIT,F_QUIT,F_QUIT},	/* see '.' */
{F_QUIT,F_QUIT,
     F_NADA,F_QUIT,F_NADA,
     F_QUIT,F_QUIT,F_QUIT},	/* see e/E */
{F_SIGN,F_QUIT,F_QUIT,F_QUIT,F_QUIT,
     F_ESIGN,F_QUIT,F_QUIT},	/* see sign */
};
/* given transition,state what is new state? */
int fp_ns[][NSTATE] = {
{FS_DIGS,FS_DIGS,FS_DIGS,
     FS_DD,FS_DD,
     FS_EDIGS,FS_EDIGS,FS_EDIGS},	/* see digit */
{FS_DOT,FS_DOT,FS_DD,
 },	/* see '.' */
{0,0,
     FS_E,0,FS_E,
 },	/* see e/E */
{FS_SIGNED,0,0,0,0,
     FS_ESIGN,0,0},	/* see sign */
};
/* which states are valid terminators? */
int fp_sval[NSTATE] = {
    0,0,1,0,1,0,0,1
};
#endif

_scanf(ip, get, unget, fmt, args)
register unsigned char *ip;
int (*get)();
int (*unget)();
register unsigned char *fmt;
char **args;

{
    register long n;
    register int c, width, lval, sval, cnt = 0;
    int store, neg, base, wide1, endnull, rngflag, c2;
    register unsigned char *p;
    unsigned char delim[128], digits[17], *q;
    char *strchr(), *strcpy();
#if FLOATS
    double fx;
    char fbuf[128], *fbp;
    int fstate, trans;
    extern double atof();
#endif

    if (!*fmt)
	return(0);

    c = (*get)(ip);
    while(c > 0)
    {
	store = FALSE;
	if (*fmt == '%')
	{
	    n	= 0;
	    width	= -1;
	    wide1	= 1;
	    base	= 10;
	    lval	= FALSE;
	    sval	= FALSE;
	    store	= TRUE;
	    endnull	= TRUE;
	    neg	= -1;

	    strcpy(delim,  "\011\012\013\014\015 ");
	    strcpy(digits, _numstr); /* "01234567890ABCDEF" */

	    if (fmt[1] == '*')
	    {
		endnull = store = FALSE;
		++fmt;
	    }

	    while (isdigit(*++fmt))		/* width digit(s) */
	    {
		if (width == -1)
		    width = 0;
		wide1 = width = TEN_MUL(width) + (*fmt - '0');
	    }
	    --fmt;
	  fmtnxt:
	    ++fmt;
	    switch(tolower(*fmt))	/* tolower() is a MACRO! */
	    {
	      case '*':
		endnull = store = FALSE;
		goto fmtnxt;

	      case 'l':	/* long data */
		lval = TRUE;
	      case 'h':	/* short data (for compatibility) */
		sval = TRUE;
		goto fmtnxt;

	      case 'i':	/* any-base numeric */
		base = 0;
		goto numfmt;

	      case 'b':	/* unsigned binary */
		base = 2;
		goto numfmt;

	      case 'o':	/* unsigned octal */
		base = 8;
		goto numfmt;

	      case 'x':	/* unsigned hexadecimal */
		base = 16;
		goto numfmt;

	      case 'd':	/* SIGNED decimal */
		neg = FALSE;
		/* FALL-THRU */

	      case 'u':	/* unsigned decimal */
	      numfmt:					skip();

		if (isupper(*fmt))
		    lval = TRUE;

		if (!base)
		{
		    base = 10;
		    neg = FALSE;
		    if (c == '%')
		    {
			base = 2;
			goto skip1;
		    }
		    else if (c == '0')
		    {
			c = (*get)(ip);
			if (c < 1)
			    goto savnum;
			if ((c != 'x')
			    && (c != 'X'))
			{
			    base = 8;
			    digits[8]= '\0';
			    goto zeroin;
			}
			base = 16;
			goto skip1;
		    }
		}

		if ((neg == FALSE) && (base == 10)
		    && ((neg = (c == '-')) || (c == '+')))
		{
		  skip1:
		    c = (*get)(ip);
		    if (c < 1)
			goto done;
		}

		digits[base] = '\0';
		p = ((unsigned char *)
		     strchr(digits,toupper(c)));

		if ((!c || !p) && width)
		    goto done;

		while (p && width-- && c)
		{
		    n = (n * base) + (p - digits);
		    c = (*get)(ip);
		  zeroin:
		    p = ((unsigned char *)
			 strchr(digits,toupper(c)));
		}
	      savnum:
		if (store)
		{
		    p = ((unsigned char *) *args);
		    if (neg == TRUE)
			n = -n;
		    if (lval)
			*((long*) p) = n;
		    else if (sval)
			*((short *) p) = n;
		    else
			*((int *) p) = n;
		    ++cnt;
		}
		break;

#if FLOATS
	      case 'e':	/* float */
	      case 'f':
	      case 'g':
		skip();

		if (isupper(*fmt))
		    lval = TRUE;

		fstate = FS_INIT;
		fbp = fbuf;
		while (c && width--) {
		    if (c >= '0' && c <= '9')
			trans = FC_DIG;
		    else if (c == '.')
			trans = FC_DOT;
		    else if (c == '+' || c == '-')
			trans = FC_SIGN;
		    else if (tolower(c) == 'e')
			trans = FC_E;
		    else
			goto fdone;

		    *fbp++ = c;

		    if (fp_do[trans][fstate] == F_QUIT)
			goto fdone;
		    fstate = fp_ns[trans][fstate];
		    c = (*get)(ip);
		}

	      fdone:
		*fbp = '\0';
		if (!fp_sval[fstate])
		    goto done;
		if (store) {
		    fx = (*fbuf == '\0') ? 0.0 : atof(fbuf);
		    p = (unsigned char *) *args;
		    if (lval)
			*((double *) p) = fx;
		    else
			*((float *) p) = (float)fx;
		    ++cnt;
		}
		break;
#endif

	      case 'n':
		if (store) {
		  p = (unsigned char *) *args;
		  *((int *) p) = cnt;
		}
		break;

	      case 'c':	/* character data */
		width = wide1;
		endnull	= FALSE;
		delim[0] = '\0';
		goto strproc;

	      case '[':	/* string w/ delimiter set */

		/* get delimiters */
		p = delim;

		if (*++fmt == '^')
		    fmt++;
		else
		    lval = TRUE;

		rngflag = 2;
		if ((*fmt == ']') || (*fmt == '-'))
		{
		    *p++ = *fmt++;
		    rngflag = FALSE;
		}

		while (*fmt != ']')
		{
		    if (*fmt == '\0')
			goto done;
		    switch (rngflag)
		    {
		      case TRUE:
			c2 = *(p-2);
			if (c2 <= *fmt)
			{
			    p -= 2;
			    while (c2 < *fmt)
				*p++ = c2++;
			    rngflag = 2;
			    break;
			}
			/* fall thru intentional */

		      case FALSE:
			rngflag = (*fmt == '-');
			break;

		      case 2:
			rngflag = FALSE;
		    }

		    *p++ = *fmt++;
		}

		*p = '\0';
		goto strproc;

	      case 's':	/* string data */
		skip();
	      strproc:
		/* process string */
		p = ((unsigned char *) *args);

		/* if the 1st char fails, match fails */
		if (width)
		{
		    q = ((unsigned char *)
			 strchr(delim, c));
		    if((c < 1)
		       || (lval ? !q : (int) q))
		    {
			if (endnull)
			    *p = '\0';
			goto done;
		    }
		}

		for (;;) /* FOREVER */
		{
		    if (store)
			*p++ = c;
		    if (((c = (*get)(ip)) < 1) ||
			(--width == 0))
			break;

		    q = ((unsigned char *)
			 strchr(delim, c));
		    if (lval ? !q : (int) q)
			break;
		}

		if (store)
		{
		    if (endnull)
			*p = '\0';
		    ++cnt;
		}
		break;

	      case '\0':	/* early EOS */
		--fmt;
		/* FALL THRU */

	      default:
		goto cmatch;
	    }
	}
	else if (isspace(*fmt))		/* skip whitespace */
	{
	    skip();
	}
	else
	{			/* normal match char */
	  cmatch:
	    if (c != *fmt)
		break;
	    c = (*get)(ip);
	}

	if (store)
	    args++;

	if (!*++fmt)
	    break;
    }

  done:						/* end of scan */
    if ((c < 0) && (cnt == 0))
	return(EOF);

    (*unget)(c, ip);
    return(cnt);
}
