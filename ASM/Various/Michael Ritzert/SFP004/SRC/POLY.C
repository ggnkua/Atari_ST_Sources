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
 *	poly   double precision polynomial evaluation
 *
 *  KEY WORDS
 *
 *	poly
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Evaluates a polynomial and returns double precision
 *	result.  Is passed a the order of the polynomial,
 *	a pointer to an array of double precision polynomial
 *	coefficients (in ascending order), and the independent
 *	variable.
 *
 *  USAGE
 *
 *	double poly (order, coeffs, x)
 *	int order;
 *	double *coeffs;
 *	double x;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *
 *  INTERNALS
 *
 *	Evalates the polynomial using recursion and the form:
 *
 *		P(x) = P0 + x(P1 + x(P2 +...x(Pn)))
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


double poly (order, coeffs, x)
register int order;
double *coeffs;
double x;
{
    auto double curr_coeff;
    auto double rtn_value;

    DBUG_ENTER ("poly");
    DBUG_5 ("polyin", "args %d %#x %le", order, coeffs, x);
#if 0
    if (order <= 0) {
	rtn_value = *coeffs;
    } else {
	curr_coeff = *coeffs;	/* Bug in Unisoft's compiler.  Does not */
	coeffs++;		/* generate good code for *coeffs++ */
	rtn_value = curr_coeff + x * poly (--order, coeffs, x);
    }
#else /* ++jrb -- removed tail recursion */
    coeffs += order;
    rtn_value = *coeffs--;
    while(order-- > 0)
	rtn_value = *coeffs-- + (x * rtn_value);

#endif
    DBUG_3 ("polyout", "result %le", rtn_value);
    DBUG_RETURN (rtn_value);
}
