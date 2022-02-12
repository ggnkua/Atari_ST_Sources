#include <lib.h>
#include <limits.h>
#include <stdarg.h>
/* scanf - formatted input conversion	Author: Patrick van Kleef */
/* added floatingpoint conversion from dLibs: Volker Seebode */
#define	__SRC__
#include <stdio.h>
#include <ctype.h>

#ifndef FLOATS
#define FLOATS	1	/* default: include stuff for floating point */
#endif /* FLOATS */

#if (defined(dLibs) && defined(SOZOBON))
#define	_doscanf _scanf	/* for compatibility */
#endif /* dLibs */

#ifndef _PROTOTYPE
#if ((defined(__STDC__)) && (!defined(__NO_PROTO__)))
#define	_PROTOTYPE(fun,args)	fun args
#define	_CONST	const
#else
#define	_PROTOTYPE(fun,args)	fun()
#define	_CONST
#endif /* __STDC__ */
#define	PUBLIC
#define	PRIVATE	static
#endif /* _PROTOTYPE */

/* extern int _doscanf(); */
PUBLIC int _PROTOTYPE(_doscanf,	(int, char *, char *, va_list));
PUBLIC int _PROTOTYPE(scanf,	(_CONST char *, char *));
PUBLIC int _PROTOTYPE(fscanf,	(FILE *, _CONST char *, char *));
PUBLIC int _PROTOTYPE(sscanf,	(_CONST char *, _CONST char *, int));

int scanf(format, args)
_CONST char *format;
char *args;
{
  return(_doscanf(0, (char *) stdin, (char *) format, (char *)&args));
}


int fscanf(fp, format, args)
FILE *fp;
_CONST char *format;
char *args;
{
  return(_doscanf(0, (char *) fp, (char *) format, (char *)&args));
}


int sscanf(string, format, args)
_CONST char *string;		/* source of data */
_CONST char *format;		/* control string */
int args;			/* our args */
{
  return(_doscanf(1, (char *) string, (char *) format, (char *) &args));
}


union ptr_union {
  char *chr_p;
  unsigned int *uint_p;
  unsigned long *ulong_p;
#if FLOATS
  float *float_p;
  double *double_p;
#endif
};

PRIVATE int ic;			/* the current character */
PRIVATE char *rnc_arg;		/* the string or the filepointer */
PRIVATE rnc_code;		/* 1 = read from string, else from FILE */

#if FLOATS
/* fp scan actions */
#define F_NADA	0		/* just change state */
#define F_SIGN	1		/* set sign */
#define F_ESIGN	2		/* set exponent's sign */
#define F_INT	3		/* adjust integer part */
#define F_FRAC	4		/* adjust fraction part */
#define F_EXP	5		/* adjust exponent part */
#define F_QUIT	6

#define NSTATE		8
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
#endif /* FLOATS */

PRIVATE _PROTOTYPE( void rnc, (void));
PRIVATE _PROTOTYPE( int scnindex, (int ch, char *string));
PRIVATE _PROTOTYPE( void ugc, (void));
#if FLOATS
PRIVATE _PROTOTYPE( double fpscan, (int neg, int eneg, long ipart, \
					long fpart, long epart, int flen));
#endif /* FLOATS */

/* Get the next character */

PRIVATE void rnc()
{
  if (rnc_code) {
	if (!(ic = *rnc_arg++)) ic = EOF;
  } else
	ic = getc((FILE *) rnc_arg);
}


/* unget the current character
 */

PRIVATE void ugc()
{

  if (rnc_code)
	--rnc_arg;
  else
	ungetc(ic, (FILE *) rnc_arg);
}


PRIVATE int scnindex(ch, string)
int ch;
char *string;
{
  while (*string++ != (char) ch)
	if (!*string) return(0);
  return(1);
}


/* the routine that does the job
 */

int _doscanf(code, funcarg, format, argpfix)
int code;			/* function to get a character */
char *funcarg;			/* an argument for the function */
char *format;			/* the format control string */
va_list argpfix;		/* our argument list */
{
  int done = 0;			/* number of items done */
  int base;			/* conversion base */
  long val;			/* an integer value */
  int sign;			/* sign flag */
  int do_assign;		/* assignment suppression flag */
  unsigned width;		/* width of field */
  int widflag;			/* width was specified */
  int longflag;			/* true if long */
  int done_some;		/* true if we have seen some data */
  int reverse;			/* reverse the checking in [...] */
  char *endbracket;		/* position of the ] in format string */
#if FLOATS
  long frac, expo;
  int eneg, fraclen, fstate, trans;
  double fx;
#endif
  /* convert good form of argp to bad form for further (old) bad conversions */
  union ptr_union *argp = (union ptr_union *) argpfix;

  rnc_arg = funcarg;
  rnc_code = code;

  rnc();			/* read the next character */

  if (ic == EOF) {
	done = EOF;
	goto quit;
  }
  while (1) {
	while (isspace(*format)) ++format;	/* skip whitespace */
	if (!*format) goto all_done;	/* end of format */
	if (ic < 0) goto quit;	/* seen an error */
	if (*format != '%') {
		while (isspace(ic)) rnc();
		if (ic != *format) goto all_done;
		++format;
		rnc();
		continue;
	}
	++format;
	do_assign = 1;
	if (*format == '*') {
		++format;
		do_assign = 0;
	}
	if (isdigit(*format)) {
		widflag = 1;
		for (width = 0; isdigit(*format);)
			width = width * 10 + *format++ - '0';
	} else {
		widflag = 0;	/* no width spec */
		width = (unsigned) UINT_MAX;	/* very wide */
	}
	if (longflag = (tolower(*format) == 'l')) ++format;
	if (*format != 'c') while (isspace(ic))
			rnc();
	done_some = 0;		/* nothing yet */
	switch (*format) {
	    case 'o':
		base = 8;
		goto decimal;
	    case 'u':
	    case 'd':
		base = 10;
		goto decimal;
	    case 'x':
		base = 16;
		if (width >= 2 && ic == '0') {
			rnc();
			if (tolower(ic) == 'x') {
				width -= 2;
				done_some = 1;
				rnc();
			} else {
				ugc();
				ic = '0';
			}
		}
  decimal:
		val = 0L;	/* our result value */
		sign = 0;	/* assume positive */
		if (width && ic == '+')
			rnc();
		else if (width && ic == '-') {
			sign = 1;
			rnc();
		}
		while (width--) {
			if (isdigit(ic) && ic - '0' < base)
				ic -= '0';
			else if (base == 16 && tolower(ic) >= 'a' && tolower(ic) <= 'f')
				ic = 10 + tolower(ic) - 'a';
			else
				break;
			val = val * base + ic;
			rnc();
			done_some = 1;
		}
		if (do_assign) {
			if (sign) val = -val;
			if (longflag)
				*(argp++)->ulong_p = (unsigned long) val;
			else
				*(argp++)->uint_p = (unsigned) val;
		}
		if (done_some) {
			if (do_assign) ++done;
		} else
			goto all_done;
		break;
#if FLOATS
	    case 'e':	/* float */
	    case 'f':
	    case 'g':
		/* skip(); */

		fstate = FS_INIT;
		sign = 0;  eneg = FALSE;
		val = 0L;  frac = 0;  expo = 0;
		fraclen = 0;

		while (ic && width--) {
			if (ic >= '0' && ic <= '9')
				trans = FC_DIG;
			else if (ic == '.')
				trans = FC_DOT;
			else if (ic == '+' || ic == '-')
				trans = FC_SIGN;
			else if (tolower(ic) == 'e')
				trans = FC_E;
			else
				goto fdone;

			switch (fp_do[trans][fstate]) {
				case F_SIGN:
					sign = (ic == '-');
					break;
				case F_ESIGN:
					eneg = (ic == '-');
					break;
				case F_INT:
					val = 10*val + (ic - '0');
					break;
				case F_FRAC:
					frac = 10*frac + (ic - '0');
					fraclen++;
					break;
				case F_EXP:
					expo = 10*expo + (ic - '0');
					break;
				case F_QUIT:
					goto fdone;
			} /* switch */
			fstate = fp_ns[trans][fstate];
			rnc();
		} /* while */
fdone:
		if (!fp_sval[fstate])
			goto all_done;
		done_some = 1;
		if (do_assign) {
			fx = fpscan(sign, eneg,	val, frac, expo, fraclen);
			if (longflag)
				*(argp++)->double_p = fx;
			else
				*(argp++)->float_p = (float) fx;
			++done;
		}
		break;
#endif /* FLOATS */
	    case 'c':
		if (!widflag) width = 1;
		while (width-- && ic >= 0) {
			if (do_assign) *(argp)->chr_p++ = (char) ic;
			rnc();
			done_some = 1;
		}
		if (do_assign) argp++;	/* done with this one */
		if (done_some && do_assign) ++done;
		break;
	    case 's':
		while (width-- && !isspace(ic) && ic > 0) {
			if (do_assign) *(argp)->chr_p++ = (char) ic;
			rnc();
			done_some = 1;
		}
		if (do_assign)	/* terminate the string */
			*(argp++)->chr_p = '\0';
		if (done_some) {
			if (do_assign) ++done;
		} else
			goto all_done;
		break;
	    case '[':
		if (*(++format) == '^') {
			reverse = 1;
			format++;
		} else
			reverse = 0;

		endbracket = format;
		while (*endbracket != ']' && *endbracket != '\0')
			endbracket++;

		if (!*endbracket) goto quit;

		*endbracket = '\0';	/* change format string */

		while (width-- && !isspace(ic) && ic > 0 &&
		       (scnindex(ic, format) ^ reverse)) {
			if (do_assign) *(argp)->chr_p++ = (char) ic;
			rnc();
			done_some = 1;
		}
		format = endbracket;
		*format = ']';	/* put it back */
		if (do_assign)	/* terminate the string */
			*(argp++)->chr_p = '\0';
		if (done_some) {
			if (do_assign) ++done;
		} else
			goto all_done;
		break;
	}			/* end switch */
	++format;
  }
all_done:
  if (ic >= 0) ugc();		/* restore the character */
quit:
  return(done);
}

#if FLOATS
/*
 *	fpscan().
 *	Compile floating point number out of integer, fractional and exponent
 *	part.
 */

PRIVATE double fpscan(neg, eneg, ipart, fpart, epart, flen)
int neg, eneg, flen;
long ipart, fpart, epart;	/* ganzzahliger/gebrochener Anteil, Exponent */
{
	double val, fmul, fexp;

	val = (double) ipart;

	fmul = 1.0;
	while (flen--)
		fmul /= 10.0;
	val += fmul*(double)fpart;

	if (epart) {
		fmul = 1.0;
		if (eneg)
			fexp = 1e-10;
		else
			fexp = 1e10;
		while (epart >= 10) {
			fmul *= fexp;
			epart -= 10;
		}
		if (eneg)
			fexp = 1e-1;
		else
			fexp = 1e1;
		while (epart--)
			fmul *= fexp;
		val *= fmul;
	}
	if (neg)
		val = -val;
	return val;
}
#endif /* FLOATS */
