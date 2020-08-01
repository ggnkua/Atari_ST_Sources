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
 *	casin   complex double precision arc sine
 *
 *  KEY WORDS
 *
 *	casin
 *	machine independent routines
 *	complex functions
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex arc sine of
 *	a double precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX casin (z)
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
 *	Computes complex arc sine of z = x + j y from:
 *
 *	    casin(z) = -j * clog(csqrt(1-z*z) + j*z)
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX casin (z)
COMPLEX z;
{
    COMPLEX temp;
    extern COMPLEX csqrt (), clog (), cmult ();

    temp = cmult (z, z);
    temp.real = 1.0 - temp.real;
    temp.imag = -temp.imag;
    temp = csqrt (temp);
    temp.real -= z.imag;
    temp.imag += z.real;
    temp = clog (temp);
    z.real = temp.imag;
    z.imag = -temp.real;

    return (z);
}
