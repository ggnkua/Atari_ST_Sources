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
 *	ctanh   complex double precision hyperbolic tangent
 *
 *  KEY WORDS
 *
 *	ctanh
 *	complex functions
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex hyperbolic tangent of
 *	a double precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX ctanh (z)
 *	COMPLEX z;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 *  INTERNALS
 *
 *	Computes complex hyperbolic tangent of Z = x + j y from:
 *
 *	    ctanh(z) = (1 - cexp(-2z)) / (1 + cexp(-2z))
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX ctanh (z)
COMPLEX z;
{
    COMPLEX result;
    extern COMPLEX cexp (), cdiv ();

    ENTER ("ctanh");
    DEBUG4 ("ctanhin", "arg %le %le", z.real, z.imag);
    result.real = -2.0 * z.real;
    result.imag = -2.0 * z.imag;
    result = cexp (result);
    z.real = 1.0 - result.real;
    z.imag = -result.imag;
    result.real += 1.0;
    result = cdiv (z, result);
    DEBUG4 ("ctanhout", "result %le %le", result.real, result.imag);
    LEAVE ();
    return (result);
}
