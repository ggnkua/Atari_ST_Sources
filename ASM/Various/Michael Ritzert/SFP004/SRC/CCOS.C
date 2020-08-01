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
 *	ccos   complex double precision cosine
 *
 *  KEY WORDS
 *
 *	ccos
 *	complex functions
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex cosine of a double
 *	precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX ccos (z)
 *	COMPLEX z;
 *
 *  REFERENCES
 *
 *	Fortran 77 user's guide, Digital Equipment Corp. pp B-12
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 *  INTERNALS
 *
 *	Computes complex cosine of z = x + j y from:
 *
 *		1.	r_ccos = cos(x) * cosh(y)
 *
 *		2.	i_ccos = -sin(x) * sinh(y)
 *
 *		3.	ccos(z) = r_ccos + j i_ccos
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX ccos (z)
COMPLEX z;
{
    COMPLEX result;
    extern double sin(), cos(), sinh(), cosh();

    ENTER ("ccos");
    DEBUG4 ("ccosin", "arg %le %le", z.real, z.imag);
    result.real = cos(z.real) * cosh(z.imag);
    result.imag = -sin(z.real) * sinh(z.imag);
    DEBUG4 ("ccosout", "result %le %le", result.real, result.imag);
    LEAVE ();
    return (result);
}
