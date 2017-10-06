/************************************************************************
 *									*
 *				N O T I C E				*
 *									*
 *			Copyright Abandoned, 1987, Fred Fish		*
 *									*
 *	This previously copyrighted work has been placed into the	*
 *	public domain by the author (Fred Fish) and may be freely used	*
 *	for any purpose, private or commercial.  I would appreciate	*
 *	it, as a courtesy, if this notice is left in all copies and	*
 *	derivative works.  Thank you, and enjoy...			*
 *									*
 *	The author makes no warranty of any kind with respect to this	*
 *	product and explicitly disclaims any implied warranties of	*
 *	merchantability or fitness for any particular purpose.		*
 *									*
 ************************************************************************
 */


/*
 *  FUNCTION
 *
 *	asinh   double precision hyperbolic arc sine
 *
 *  KEY WORDS
 *
 *	asinh
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Returns double precision hyperbolic arc sine of double precision
 *	floating point number.
 *
 *  USAGE
 *
 *	double asinh (x)
 *	double x;
 *
 *  RESTRICTIONS
 *
 *	The domain of the ASINH function is the entire real axis
 *	however the evaluation of x squared may cause overflow
 *	for large magnitudes.
 *
 *	For precision information refer to documentation of the
 *	floating point library routines called.
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *
 *  INTERNALS
 *
 *	Computes asinh(x) from:
 *
 *		1.	Let xmax = sqrt(MAXDOUBLE - 1)
 *
 *		2.	If x < -xmax or xmax < x then
 *			let x = xmax and flag overflow.
 *
 *		3.	asinh(x) = log [x+sqrt(x**2 + 1)]
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"

static char funcname[] = "asinh";


double asinh (x)
double x;
{
    auto struct exception xcpt;
    extern double log ();
    extern double sqrt ();

    DBUG_ENTER (funcname);
    DBUG_3 ("asinhin", "arg %le", x);
    if (x < -SQRT_MAXDOUBLE || x > SQRT_MAXDOUBLE) {
	xcpt.type = OVERFLOW;
	xcpt.name = funcname;
	xcpt.arg1 = x;
	if (!matherr (&xcpt)) {
	    fprintf (stderr, "%s: OVERFLOW error\n", funcname);
	    errno = ERANGE;
	    xcpt.retval = log (2 * SQRT_MAXDOUBLE);
	}
    } else {
	xcpt.retval = log (x + sqrt(x*x + 1.0));
    }
    DBUG_3 ("asinhout", "result %le", xcpt.retval);
    DBUG_RETURN (xcpt.retval);
}
