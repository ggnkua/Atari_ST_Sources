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
 *	cacos   complex double precision arc cosine
 *
 *  KEY WORDS
 *
 *	cacos
 *	complex functions
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex arc cosine of
 *	a double precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX cacos (z)
 *	COMPLEX z;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe,Az 85281
 *	(602) 966-8871
 *
 *  INTERNALS
 *
 *	Computes complex arc cosine of z = x + jy from:
 *
 *	    cacos(z) = -j * clog(z + j * csqrt(1-z*z))
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX cacos (z)
COMPLEX z;
{
    COMPLEX temp;
    double swaptemp;
    extern COMPLEX cmult (), csqrt (), clog ();

    temp = cmult(z, z);
    temp.real = 1.0 - temp.real;
    temp.imag = -temp.imag;
    temp = csqrt (temp);
    swaptemp = temp.real;
    temp.real = -temp.imag;
    temp.imag = swaptemp;
    temp.real += z.real;
    temp.imag += z.imag;
    temp = clog (temp);
    z.real = temp.imag;
    z.imag = -temp.real;
    return (z);
}
