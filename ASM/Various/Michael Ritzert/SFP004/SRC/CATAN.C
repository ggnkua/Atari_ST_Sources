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
 *	catan   complex double precision arc tangent
 *
 *  KEY WORDS
 *
 *	catan
 *	machine independent routines
 *	complex functions
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex arc tangent of
 *	a double precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX catan (z)
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
 *	Computes complex arc tangent of z = x + j y from:
 *
 *	    catan(z) = -j/2 * clog( (j+z) / (j-z) )
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX catan (z)
COMPLEX z;
{
    COMPLEX temp;
    double swaptemp;
    extern COMPLEX cdiv (), clog ();

    temp.real = -z.real;
    temp.imag = 1.0 - z.imag;
    z.imag += 1.0;
    z = cdiv (z, temp);
    z = clog (z);
    swaptemp = z.real;
    z.real = -0.5 * z.imag;
    z.imag =  0.5 * swaptemp;
    return (z);
}
