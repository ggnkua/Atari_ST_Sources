/*
 *     double strtod (str, endptr);
 *     const char *str;
 *     char **endptr;
 *		if !NULL, on return, points to char in str where conv. stopped
 *
 *     double atof (str)
 *     const char *str;
 *
 * recognizes:
 [spaces] [sign] digits [ [.] [ [digits] [ [e|E|d|D] [space|sign] [int][F|L]]]]
 *
 * returns:
 *	the number
 *		on overflow: HUGE_VAL and errno = ERANGE
 *		on underflow: -HUGE_VAL and errno = ERANGE
 *
 * bugs:
 *   naive over/underflow detection
 *
 *	++jrb bammi@dsrgsun.ces.cwru.edu
 *
 * 07/29/89:
 *	ok, before you beat me over the head, here is a hopefully
 *	much improved one, with proper regard for rounding/precision etc
 *	(had to read up on everything i did'nt want to know in K. V2)
 *	the old naive coding is at the end bracketed by ifdef __OLD__.
 *	modeled after peter housels posting on comp.os.minix.
 *	thanks peter!
 *
 *	mjr: 68881 version added
 *
 *	schwab: 68881 version replaced with new implementation that
 *		uses fmovep for maximum precision, no bits lost anymore!
 */

#if !defined (__M68881__) && !defined (sfp004)

#if !defined(__GNUC__) || defined(__SOZOBON__)
#define __OLD__
#endif /* !__GNUC__ || __SOZOBON */

#if !(defined(unix) || defined(minix))
#include <stddef.h>
#include <stdlib.h>
#include <float.h>
#endif
#include <errno.h>
#include <assert.h>
#include <math.h>

#ifdef minix
#include "lib.h"
#endif
#if 0
#ifndef _COMPILER_H
#include <compiler.h>
#endif
#endif
extern int errno;
#if (defined(unix) || defined(minix))
#define NULL 	((void *)0)
#endif

#define Ise(c)		((c == 'e') || (c == 'E') || (c == 'd') || (c == 'D'))
#define Isdigit(c)	((c <= '9') && (c >= '0'))
#define Isspace(c)	((c == ' ') || (c == '\t'))
#define Issign(c)	((c == '-') || (c == '+'))
#define IsValidTrail(c) ((c == 'F') || (c == 'L'))
#define Val(c)		((c - '0'))

#define MAXDOUBLE	DBL_MAX
#define MINDOUBLE	DBL_MIN

#define MAXF  1.797693134862316
#define MINF  2.225073858507201
#define MAXE  308
#define MINE  (-308)

/* another alias for ieee double */
struct ldouble {
    unsigned long hi, lo;
};

static int __ten_mul __PROTO((double *acc, int digit));
static double __adjust __PROTO((double *acc, int dexp, int sign));

#ifdef __OLD__
static double __ten_pow __PROTO((double r, int e));
#endif

#if defined(__GNUC__) && !defined(__OLD__)
/*
 * mul 64 bit accumulator by 10 and add digit
 * algorithm:
 *	10x = 2( 4x + x ) == ( x<<2 + x) << 1
 *	result = 10x + digit
 */
static int __ten_mul(acc, digit)
double *acc;
int digit;
{
    register unsigned long d0, d1, d2, d3;
    register          short i;
    
    d2 = d0 = ((struct ldouble *)acc)->hi;
    d3 = d1 = ((struct ldouble *)acc)->lo;

    /* check possibility of overflow */
/*    if( (d0 & 0x0FFF0000L) >= 0x0ccc0000L ) */
/*    if( (d0 & 0x70000000L) != 0 ) */
    if( (d0 & 0xF0000000L) != 0 )
	/* report overflow somehow */
	return 1;
    
    /* 10acc == 2(4acc + acc) */
    for(i = 0; i < 2; i++)
    {  /* 4acc == ((acc) << 2) */
	asm volatile("	lsll	#1,%1;
 			roxll	#1,%0"	/* shift L 64 bit acc 1bit */
	    : "=d" (d0), "=d" (d1)
	    : "0"  (d0), "1"  (d1) );
    }

    /* 4acc + acc */
    asm volatile(" addl    %2,%0" : "=d" (d1) : "0" (d1), "d" (d3));
    asm volatile(" addxl   %2,%0" : "=d" (d0) : "0" (d0), "d" (d2));

    /* (4acc + acc) << 1 */
    asm volatile("  lsll    #1,%1;
 		    roxll   #1,%0"	/* shift L 64 bit acc 1bit */
	    : "=d" (d0), "=d" (d1)
	    : "0"  (d0), "1"  (d1) );

    /* add in digit */
    d2 = 0;
    d3 = digit;
    asm volatile(" addl    %2,%0" : "=d" (d1) : "0" (d1), "d" (d3));
    asm volatile(" addxl   %2,%0" : "=d" (d0) : "0" (d0), "d" (d2));


    /* stuff result back into acc */
    ((struct ldouble *)acc)->hi = d0;
    ((struct ldouble *)acc)->lo = d1;

    return 0;	/* no overflow */
}

#if 0 /* not needed */
#include "flonum.h"
#endif

static double __adjust(acc, dexp, sign)
double *acc;	/* the 64 bit accumulator */
int     dexp;	/* decimal exponent       */
int	sign;	/* sign flag		  */
{
    register unsigned long  d0, d1, d2, d3;
    register          short i;
    register 	      short bexp = 0; /* binary exponent */
    unsigned short tmp[4];
    double r;

#ifdef __STDC__
    double __normdf( double d, int exp, int sign, int rbits );
    double ldexp(double d, int exp);
#else
    extern double __normdf();
    extern double ldexp();
#endif    
    d0 = ((struct ldouble *)acc)->hi;
    d1 = ((struct ldouble *)acc)->lo;
    while(dexp != 0)
    {	/* something to do */
	if(dexp > 0)
	{ /* need to scale up by mul */
	    while(d0 > 429496729 ) /* 2**31 / 5 */
	    {	/* possibility of overflow, div/2 */
		asm volatile(" lsrl	#1,%1;
 			       roxrl	#1,%0"
		    : "=d" (d1), "=d" (d0)
		    : "0"  (d1), "1"  (d0));
		bexp++;
	    }
	    /* acc * 10 == 2(4acc + acc) */
	    d2 = d0;
	    d3 = d1;
	    for(i = 0; i < 2; i++)
	    {  /* 4acc == ((acc) << 2) */
		asm volatile("	lsll	#1,%1;
 				roxll	#1,%0"	/* shift L 64 bit acc 1bit */
			     : "=d" (d0), "=d" (d1)
			     : "0"  (d0), "1"  (d1) );
	    }

	    /* 4acc + acc */
	    asm volatile(" addl    %2,%0" : "=d" (d1) : "0" (d1), "d" (d3));
	    asm volatile(" addxl   %2,%0" : "=d" (d0) : "0" (d0), "d" (d2));

	    /* (4acc + acc) << 1 */
	    bexp++;	/* increment exponent to effectively acc * 10 */
	    dexp--;
	}
	else /* (dexp < 0) */
	{ /* scale down by 10 */
	    while((d0 & 0xC0000000L) == 0)
	    {	/* preserve prec by ensuring upper bits are set before div */
		asm volatile(" lsll  #1,%1;
 			       roxll #1,%0" /* shift L to move bits up */
		    : "=d" (d0), "=d" (d1)
		    : "0"  (d0), "1"  (d1) );
		bexp--;	/* compensate for the shift */
	    }
	    /* acc/10 = acc/5/2 */
	    *((unsigned long *)&tmp[0]) = d0;
	    *((unsigned long *)&tmp[2]) = d1;
	    d2 = (unsigned long)tmp[0];
	    asm volatile(" divu #5,%0" : "=d" (d2) : "0" (d2));
	    tmp[0] = (unsigned short)d2;	/* the quotient only */
	    for(i = 1; i < 4; i++)
	    {
		d2 = (d2 & 0xFFFF0000L) | (unsigned long)tmp[i]; /* REM|next */
		asm volatile(" divu #5,%0" : "=d" (d2) : "0" (d2));
		tmp[i] = (unsigned short)d2;
	    }
	    d0 = *((unsigned long *)&tmp[0]);
	    d1 = *((unsigned long *)&tmp[2]);
	    /* acc/2 */
	    bexp--;	/* div/2 taken care of by decrementing binary exp */
	    dexp++;
	}
    }
    
    /* stuff the result back into acc */
    ((struct ldouble *)acc)->hi = d0;
    ((struct ldouble *)acc)->lo = d1;

    /* normalize it */
    r = __normdf( *acc, ((0x03ff - 1) + 53), (sign)? -1 : 0, 0 );
    /* now shove in the binary exponent */
    return ldexp(r, bexp);
}

/* flags */
#define SIGN	0x01
#define ESIGN	0x02
#define DECP	0x04
#define CONVF	0x08

double strtod (s, endptr)
const register char *s;
char **endptr;
{
    double         accum = 0.0;
    register short flags = 0;
    register short texp  = 0;
    register short e     = 0;
    double	   zero = 0.0;
    const char 	   *tmp;
 
    assert ((s != NULL));

    if(endptr != NULL) *endptr = (char *)s;
    while(Isspace(*s)) s++;
    if(*s == '\0')
    {	/* just leading spaces */
	return zero;
    }

    if(Issign(*s))
    {
	if(*s == '-') flags = SIGN;
	if(*++s == '\0')
	{   /* "+|-" : should be an error ? */
	    return zero;
	}
    }

    do {
	if (Isdigit(*s))
	{
	    flags |= CONVF;
	    if( __ten_mul(&accum, Val(*s)) ) texp++;
	    if(flags & DECP) texp--;
	}
	else if(*s == '.')
	{
	    if (flags & DECP)  /* second decimal point */
		break;
	    flags |= DECP;
	}
	else
	    break;
	s++;
    } while (1);

    if(Ise(*s))
    {
	if(*++s != '\0') /* skip e|E|d|D */
	{  /* ! ([s]xxx[.[yyy]]e)  */
 	    tmp = s;
	    while(Isspace(*s)) s++; /* Ansi allows spaces after e */
	    if(*s != '\0')
	    { /*  ! ([s]xxx[.[yyy]]e[space])  */

		if(Issign(*s))
		    if(*s++ == '-') flags |= ESIGN;

		if(*s != '\0')
		{ /*  ! ([s]xxx[.[yyy]]e[s])  -- error?? */

		    for(; Isdigit(*s); s++)
			e = (((e << 2) + e) << 1) + Val(*s);

		    if(IsValidTrail(*s)) s++;
		
		    /* dont care what comes after this */
		    if(flags & ESIGN)
			texp -= e;
		    else
			texp += e;
		}
	    }
	    if(s == tmp) s++;	/* back up pointer for a trailing e|E|d|D */
	}
    }

    if((endptr != NULL) && (flags & CONVF))
	*endptr = (char *) s;
    if(accum == zero) return zero;

    return __adjust(&accum, (int)texp, (int)(flags & SIGN));
}
#endif /* __GNUC__ && !__OLD__ */

double atof(s)
const char *s;
{
#ifdef __OLD__
    extern double strtod();
#endif
    return strtod(s, (char **)NULL);
}


/* old naive coding */
#ifdef __OLD__
extern double HUGE_VAL;

static double __ten_pow(r, e)
double r;
register int e;
{
    if(e < 0)
	for(; e < 0; e++) r /= 10.0;
    else
	for(; e > 0; --e) r *= 10.0;
    return r;
}

#define RET(X) 	{goto ret;}

double strtod (s, endptr)
const register char *s;
char **endptr;
{
    double f = 0.1, r = 0.0, accum = 0.0;
    register int  e = 0, esign = 0, sign = 0;
    register int texp = 0, countexp;
    
    assert ((s != NULL));
    
    while(Isspace(*s)) s++;
    if(*s == '\0') RET(r);	/* just spaces */
    
    if(Issign(*s))
    {
	if(*s == '-') sign = 1;
	s++;
	if(*s == '\0') RET(r); /* "+|-" : should be an error ? */
    }
    countexp = 0;
    while(Isdigit(*s))
    {
	if(!countexp && (*s != '0')) countexp = 1;
	accum = (accum * 10.0) + Val(*s);
	/* should check for overflow here somehow */
	s++; 
	if(countexp) texp++;
    }
    r = (sign ? (-accum) : accum);
    if(*s == '\0') RET(r);  /* [s]xxx */
    
    countexp = (texp == 0);
    if(*s == '.')
    {
	s++;
	if(*s == '\0') RET(r); /* [s]xxx. */
	if(!Ise(*s))
	{
	    while(Isdigit(*s))
	    {
		if(countexp && (*s == '0')) --texp;
		if(countexp && (*s != '0')) countexp = 0;
		accum = accum + (Val(*s) * f);
		f = f / 10.0;
		/* overflow (w + f) ? */
		s++;
	    }
	    r = (sign ? (-accum) : accum);
	    if(*s == '\0') RET(r); /* [s]xxx.yyy  */
	}
    }
    if(!Ise(*s)) RET(r);	/* [s]xxx[.[yyy]]  */
    
    s++; /* skip e */
    if(*s == '\0') RET(r); /* [s]xxx[.[yyy]]e  */
    
    while(Isspace(*s)) s++;
    if(*s == '\0') RET(r); /* [s]xxx[.[yyy]]e[space]  */
    
    if(Issign(*s))
    {
	if(*s == '-') esign = 1;
	s++;
	if(*s == '\0') RET(r); /* [s]xxx[.[yyy]]e[s]  */
    }
    
    while(Isdigit(*s))
    {
	e = (e * 10) + Val(*s);
	s++;
    }
    /* dont care what comes after this */
    if(esign) e = (-e);
    texp += e;
    
    /* overflow ? */ /* FIXME */
    if( texp > MAXE)
    {
	if( ! ((texp == (MAXE+1)) && (accum <= MAXF)))
	{
	    errno = ERANGE;
	    r = ((sign) ? -HUGE_VAL : HUGE_VAL);
	    RET(r);
	}
    }
    
    /* underflow -- in reality occurs before this */ /* FIXME */
    if(texp < MINE)
    {
	errno = ERANGE;
	r = ((sign) ? -HUGE_VAL : HUGE_VAL);
	RET(r);
    }
    r = __ten_pow(r, e);
    /* fall through */
    
    /* all returns end up here, with return value in r */
  ret:
    if(endptr != NULL)
	*endptr = s;
    return r;
}
#endif /* __OLD__ */

#else /* __M68881__ || sfp004 */

#include <string.h>
#include <ctype.h>
#include <math.h>
#include <float.h>
#include <errno.h>
#include "flonum.h"

#ifdef sfp004
/* Note: not tested -- schwab */

/* static */ double Float __PROTO ((char *));

asm ("
comm = -6;
resp = -16;
.text
.even
_Float:
	lea	0xfffffa50:w,a0			| fpu address
	movel	sp@(4),a1
	movew	#0x4c00,a0@(comm)		| fmovep -> fp0
1:	cmpw	#0x8900,a0@(resp)
	beq	1b
	movel	a1@+,a0@			| load data
	movel	a1@+,a0@
	movel	a1@+,a0@

	movew	#0x7400,a0@(comm)		| fmoved fp0 -> d0/d1
1:	cmpw	#0x8900,a0@(resp)
	beq	1b
	movel	a0@,d0
	movel	a0@,d1
	rts	");
#endif

/* Format of packed decimal (from left to right):

    1 Bit: sign of mantissa
    1 Bit: sign of exponent
    2 Bits zero
   12 Bits: three digits exponent
    4 Bits unused, fourth (higher order) digit of exponent
    8 Bits zero
   68 Bits: 17 digits of mantissa, decimal point after first digit
  --------
   96 Bits == 12 Bytes

   All digits in BCD format.  */

double
strtod (const char *str, const char **endptr)
{
  char packed_buf[12];
  char *p;
  int exponent, i, digits_seen;
  union double_di di;

  if (endptr)
    *endptr = str;
  while (isspace (*str))
    str++;
  p = packed_buf;
  for (i = 0; i < sizeof (packed_buf); i++)
    *p++ = 0;
  if (*str == '-')
    {
      packed_buf[0] = 0x80;
      str++;
    }
  else if (*str == '+')
    str++;
  else if (*str == '\0')
    return 0.0;
  i = 0;
  exponent = -1;
  digits_seen = 0;
  p = packed_buf + 3;
  /* Ignore leading 0's. */
  while (*str == '0')
    {
      digits_seen++;
      str++;
    }
  while (isdigit (*str))
    {
      digits_seen++;
      if (i < 17)
	{
	  if (i & 1)
	    *p = (*str - '0') << 4;
	  else
	    *p++ |= *str - '0';
	  i++;
	}
      exponent++;
      str++;
    }
  if (*str == '.')
    {
      str++;
      if (i == 0)
	{
	  /* Skip leading 0's.  */
	  while (*str == '0')
	    {
	      digits_seen++;
	      exponent--;
	      str++;
	    }
	}
      while (isdigit (*str))
	{
	  digits_seen++;
	  if (i < 17)
	    {
	      if (i++ & 1)
		*p = (*str - '0') << 4;
	      else
		*p++ |= *str - '0';
	    }
	  str++;
	}
    }
  /* Check that there were any digits.  */
  if (!digits_seen)
    return 0.0;

  if (*str == 'e' || *str == 'E' || *str == 'd' || *str == 'D')
    {
      const char *eptr = str;
      int exp_given, exp_neg;

      str++;
      while (isspace (*str))
	str++;
      exp_neg = 0;
      if (*str == '-')
	{
	  exp_neg = 1;
	  str++;
	}
      else if (*str == '+')
	str++;
      if (!isdigit (*str))
	{
	  str = eptr;
	  goto convert;
	}
      while (*str == '0')
	str++;
      exp_given = 0;
      while (isdigit (*str) && exp_given < 900)
	{
	  exp_given = exp_given * 10 + *str - '0';
	  str++;
	}
      while (isdigit (*str))
	str++;
      if (exp_given >= 900)
	{
	  /* Must be overflow/underflow.  */
	  if (endptr)
	    *endptr = str;
	  if (exp_neg)
	    return 0.0;
	  goto overflow;
	}
      if (exp_neg)
	exponent -= exp_given;
      else
	exponent += exp_given;
    }
 convert:
  if (endptr)
    *endptr = str;
  if (exponent < 0)
    {
      packed_buf[0] |= 0x40;
      exponent = -exponent;
    }
  packed_buf[1] = exponent % 10;
  packed_buf[1] |= ((exponent /= 10) % 10) << 4;
  packed_buf[0] |= exponent / 10 % 10;
#ifdef sfp004
  di.d = Float (packed_buf);
#else
  __asm ("fmovep %1,%0" : "=f" (di.d) : "m" (packed_buf[0]));
#endif
  /* Check for overflow.  */
  if ((di.i[0] & 0x7fffffff) >= 0x7ff00000)
    {
    overflow:
      errno = ERANGE;
      if (packed_buf[0] & 0x80)
	return -DBL_MAX;
      else
	return DBL_MAX;
    }
  return di.d;
}

double
atof (const char *str)
{
  return strtod (str, NULL);
}

#endif /* __M68881__ || sfp004 */

#ifdef TEST
#if 0
#ifdef __MSHORT__
#error "please run this test in 32 bit int mode"
#endif
#endif

#define NTEST 10000L

#ifdef __MSHORT__
# define	RAND_MAX	(0x7FFF)	/* maximum value from rand() */
#else
# define	RAND_MAX	(0x7FFFFFFFL)	/* maximum value from rand() */
#endif

main()
{
    
    double expected, result, e, max_abs_err;
    char buf[128];
    register long i, errs;
    register long s;
#ifdef __STDC__
    double atof(const char *);
    int rand(void);
#else
    extern double atof();
    extern int rand();
#endif

#if 0
    expected = atof("3.14159265358979e23");
    expected = atof("3.141");
    expected = atof(".31415"); 
    printf("%f\n\n", expected);
    expected = atof("3.1415"); 
    printf("%f\n\n", expected);
    expected = atof("31.415"); 
    printf("%f\n\n", expected);
    expected = atof("314.15"); 
    printf("%f\n\n", expected);

    expected = atof(".31415"); 
    printf("%f\n\n", expected);
    expected = atof(".031415"); 
    printf("%f\n\n", expected);
    expected = atof(".0031415"); 
    printf("%f\n\n", expected);
    expected = atof(".00031415"); 
    printf("%f\n\n", expected);
    expected = atof(".000031415"); 
    printf("%f\n\n", expected);

    expected = atof("-3.1415e-9"); 
    printf("%20.15e\n\n", expected);

    expected = atof("+3.1415e+009"); 
    printf("%20.15e\n\n", expected);
#endif

    expected = atof("+3.123456789123456789"); 
    printf("%30.25e\n\n", expected);

    expected = atof(".000003123456789123456789"); 
    printf("%30.25e\n\n", expected);

    expected = atof("3.1234567891234567890000000000"); 
    printf("%30.25e\n\n", expected);

    expected = atof("9.22337999999999999999999999999999999999999999"); 
    printf("%47.45e\n\n", expected);

    expected = atof("1.0000000000000000000"); 
    printf("%25.19e\n\n", expected);

    expected = atof("1.00000000000000000000"); 
    printf("%26.20e\n\n", expected);

    expected = atof("1.000000000000000000000"); 
    printf("%27.21e\n\n", expected);

    expected = atof("1.000000000000000000000000"); 
    printf("%30.24e\n\n", expected);

 
#if 0
    expected = atof("1.7e+308");
    if(errno != 0)
    {
	printf("%d\n", errno);
    }
    else    printf("1.7e308 OK %g\n", expected);
    expected = atof("1.797693e308");	/* anything gt looses */
    if(errno != 0)
    {
	printf("%d\n", errno);
    }
    else    printf("Max OK %g\n", expected);
    expected = atof("2.225073858507201E-307");
    if(errno != 0)
    {
	printf("%d\n", errno, expected);
    }
    else    printf("Min OK %g\n", expected);
#endif
    
    max_abs_err = 0.0;
    for(errs = 0, i = 0; i < NTEST; i++)
    {
	expected = (double)(s = rand()) / (double)rand();
	if(s > (RAND_MAX >> 1)) expected = -expected;
	sprintf(buf, "%.14e", expected);
	result = atof(buf);
	e = (expected == 0.0) ? result : (result - expected)/expected;
	if(e < 0) e = (-e);
	if(e > 1.0e-6) 
	{
	    errs++; printf("%.14e %s %.14e (%.14e)\n", expected, buf, result, e);
	}
	if (e > max_abs_err) max_abs_err = e;
    }
    printf("%ld Error(s), Max abs err %.14e\n", errs, max_abs_err);
}
#endif /* TEST */
