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
 *	csqrt   complex double precision square root
 *
 *  KEY WORDS
 *
 *	csqrt
 *	machine independent routines
 *	complex functions
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex square root of
 *	a double precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX csqrt (z)
 *	COMPLEX z;
 *
 *  REFERENCES
 *
 *	Fortran 77 user's guide, Digital Equipment Corp. pp B-12
 *
 *  RESTRICTIONS
 *
 *	The relative error in the double precision square root
 *	computation is 10**(-30.1) after three applications
 *	of Heron's iteration for the square root.
 *
 *	However, this assumes exact arithmetic in the iterations
 *	and initial approximation.  Additional errors may occur
 *	due to truncation, rounding, or machine precision limits.
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 *  INTERNALS
 *
 *	Computes complex square root of z = x + j y from:
 *
 *		1.	If z = 0 + j 0 then return z.
 *
 *		2.	root = sqrt((dabs(x) + cabs(z)) / 2)
 *
 *		3.	q = y / (2 * root)
 *
 *		4.	If x >= 0 then
 *			csqrt(z) = (root,q)
 *
 *		5.	If x < 0 and y >= 0 then
 *			csqrt(z) = (q,root)
 *
 *		6.	If x < 0 and y < 0 then
 *			csqrt(z) = (-q,root)
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX csqrt (z)
COMPLEX z;
{
    double root, q;
    extern double dabs(), sqrt(), cabs ();

    ENTER ("csqrt");
    DEBUG4 ("csqrtin", "arg %le %le", z.real, z.imag);
    if (z.real != 0.0 || z.imag != 0.0) {
        root = sqrt (0.5 * (dabs (z.real) + cabs (z)));
        q = z.imag / (2.0 * root);
        if (z.real >= 0.0) {
            z.real = root;
	    z.imag = q;
        } else if (z.imag < 0.0) {
	    z.real = -q;
	    z.imag = -root;
        } else {
	    z.real = q;
	    z.imag = root;
        }
    }
    DEBUG4 ("csqrtout", "result %le %le", z.real, z.imag);
    LEAVE ();
    return (z);
}
