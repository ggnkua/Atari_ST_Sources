/*
 *  A replacement sqrt() function for PML math library by Fred Fish.
 *  This alternative function by Michal Jaegermann, 24 October 1990.
 *
 *  This code is released into a public domain.
 */
/*
 *  FUNCTION
 *
 *	sqrt   double precision square root
 *
 *  KEY WORDS
 *
 *	sqrt
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Returns double precision square root of double precision
 *	floating point argument.
 *
 *  USAGE
 *
 *	double sqrt (x)
 *	double x;
 *
 *  REFERENCES
 *
 *	Computer Approximations, J.F. Hart et al, John Wiley & Sons,
 *	1968, pp. 89-96.
 *
 *  RESTRICTIONS
 *
 *	You shouldn't really count on more than 13-14 significant
 *      digits, though in some cases you may get more.  Still better
 *      than predecessor.
 *	
 *  PROGRAMMER
 *
 *	Michal Jaegermann - modified from Fred Fish sources.
 *
 *  INTERNALS
 *
 *	Computes square root by:
 *
 *	  (1)	Range reduction of argument to [0.5,1.0]
 *		by application of identity:
 *
 *		sqrt(x)  =  2**(k/2) * sqrt(x * 2**(-k))
 *
 *		k is the exponent when x is written as
 *		a mantissa times a power of 2 (m * 2**k).
 *		It is assumed that the mantissa is
 *		already normalized (0.5 =< m < 1.0).
 *
 *	  (2)	An approximation to sqrt(m) is obtained
 *		from a polynomial approximation:
 *
 *		u = sqrt(m) = P0 + P1*m + P2*m^2 + P3*m^3 + P4*m^4
 *
 *		P0  0.22906994529e+00
 *		P1  0.13006690496e+01
 *		P2 -0.90932104982e+00
 *		P3  0.50104207633e+00
 *		P4 -0.12146838249e+00
 *
 *		(coefficients from Hart - op.cit. table SQRT 0132)
 *
 *	  (3)	Two applications of Heron's iteration are
 *		performed using:
 *
 *		y[n+1] = 0.5 * (y[n] + (m/y[n]))
 *
 *		where y[0] = u = approx sqrt(m)
 *
 *	  (4)	If the value of k was odd then y is 
 *		multiplied by the square root of two.
 *
 *	  (5)	Finally, y is rescaled by (k >> 1) which
 *		is equivalent to multiplication by 2**int(k/2)
 *              for positive k and behaves correctly for 
 *              negative values of k, whereas division by 2 does not.
 *              This step is combined with division by 2 from
 *              the second Heron iteration.
 *
 *		The result of steps 4 and 5 is that the value
 *		of y between 0.5 and 1.0 has been rescaled by
 *		2**(k/2) which removes the original rescaling
 *		done prior to finding the mantissa square root.
 *
 */
 
#include <stdio.h>
#include <pmluser.h>
#include "pml.h"

#define P0  0.22906994529e+00		/* Hart SQRT 0132 */
#define P1  0.13006690496e+01
#define P2 -0.90932104982e+00
#define P3  0.50104207633e+00
#define P4 -0.12146838249e+00

static char funcname[] = "sqrt";


double sqrt (x)
double x;
{
#ifdef __MSHORT__
    auto short k;
#else
    auto int k;
#endif
    auto double m;
    auto double u;
    auto struct exception xcpt;
    extern double frexp ();
    extern double ldexp ();
 
    DBUG_ENTER ("sqrt");
    DBUG_3 ("sqrtin", "arg %le", x);
    if (x == 0.0) {
	xcpt.retval = 0.0;
    } else if (x < 0.0) {
	xcpt.type = DOMAIN;
	xcpt.name = funcname;
	xcpt.arg1 = x;
	if (!matherr (&xcpt)) {
	    fprintf (stderr, "%s: DOMAIN error\n", funcname);
	    errno = EDOM;
	    xcpt.retval = 0.0;
	}
    } else {
	m = frexp (x, &k);
	u = (((P4 * m + P3) * m + P2) * m + P1) * m + P0;
	u = ldexp((u + (m / u)), -1);	/* Heron's iteration */
	u += m / u;			/* and a part of the second one */
	if (k & 1) {
	    u *= SQRT2;
	}
	/* 
	 * here we rely on the fact that -3/2 and (-3 >> 1)
	 * do give different results
	 */
	xcpt.retval = ldexp (u, (k >> 1) - 1);
    }
    DBUG_3 ("sqrtout", "result %le", xcpt.retval);
    DBUG_RETURN (xcpt.retval);
}
