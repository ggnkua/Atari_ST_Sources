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
 *	clog   complex double precision natural logarithm
 *
 *  KEY WORDS
 *
 *	clog
 *	complex functions
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex natural logarithm of
 *	a double precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX clog (z)
 *	COMPLEX z;
 *
 *  REFERENCES
 *
 *	Fortran 77 user's guide, Digital Equipment Corp. pp B-13
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 *  INTERNALS
 *
 *	Computes complex natural logarithm of z = x + j y from:
 *
 *		1.	r_clog = log(cabs(z))
 *
 *		2.	i_clog = atan2(x,y)
 *
 *		3.	clog(z) = r_clog + j i_clog
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX clog (z)
COMPLEX z;
{
    double temp;
    extern double cabs (), atan2(), log ();

    temp = log (cabs (z));
    z.imag = atan2 (z.real, z.imag);
    z.real = temp;
    return (z);
}
