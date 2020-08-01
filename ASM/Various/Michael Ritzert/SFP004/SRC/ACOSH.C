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
 *	acosh   double precision hyperbolic arc cosine
 *
 *  KEY WORDS
 *
 *	acosh
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Returns double precision hyperbolic arc cosine of double precision
 *	floating point number.
 *
 *  USAGE
 *
 *	double acosh (x)
 *	double x;
 *
 *  RESTRICTIONS
 *
 *	The range of the ACOSH function is all real numbers greater
 *	than or equal to 1.0 however large arguments may cause
 *	overflow in the x squared portion of the function evaluation.
 *
 *	For precision information refer to documentation of the
 *	floating point library primatives called.
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *
 *  INTERNALS
 *
 *	Computes acosh(x) from:
 *
 *		1.	If x < 1.0 then report illegal
 *			argument and return zero.
 *
 *		2.	If x > sqrt(MAXDOUBLE) then
 *			set x = sqrt(MAXDOUBLE and
 *			continue after reporting overflow.
 *
 *		3.	acosh(x) = log [x+sqrt(x**2 - 1)]
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"

static char funcname[] = "acosh";


double acosh (x)
double x;
{
    auto struct exception xcpt;
    extern double log ();
    extern double sqrt ();

    DBUG_ENTER (funcname);
    DBUG_3 ("acoshin", "arg %le", x);
    if (x < 1.0) {
	xcpt.type = DOMAIN;
	xcpt.name = funcname;
	xcpt.arg1 = x;
	if (!matherr (&xcpt)) {
	    fprintf (stderr, "%s: DOMAIN error\n", funcname);
	    errno = ERANGE;
	    xcpt.retval = 0.0;
	}
    } else if (x > SQRT_MAXDOUBLE) {
	xcpt.type = OVERFLOW;
	xcpt.name = funcname;
	xcpt.arg1 = x;
	if (!matherr (&xcpt)) {
	    fprintf (stderr, "%s: OVERFLOW error\n", funcname);
	    errno = ERANGE;
	    x = SQRT_MAXDOUBLE;
	    xcpt.retval = log (2* SQRT_MAXDOUBLE);
	}
    } else {
	xcpt.retval = log (x + sqrt (x*x - 1.0));
    }
    DBUG_3 ("acoshout", "result %le", xcpt.retval);
    DBUG_RETURN (xcpt.retval);
}
