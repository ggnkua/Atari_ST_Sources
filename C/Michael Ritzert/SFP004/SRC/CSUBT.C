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
 *	csubt   double precision complex subtraction
 *
 *  KEY WORDS
 *
 *	csubt
 *	machine independent routines
 *	complex functions
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex result of subtraction of
 *	second double precision complex argument from first double
 *	precision complex argument.
 *
 *	Note that the complex subtraction function is so simple that
 *	it would not normally be called as a function but simply
 *	done "inline".  It is supplied mostly for completeness.
 *
 *  USAGE
 *
 *	COMPLEX csubt (z1, z2)
 *	COMPLEX z1;
 *	COMPLEX z2;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az
 *	(602) 966-8871
 *
 *  INTERNALS
 *
 *	Computes csubt (z1, z2) from:
 *
 *		1.	Let z1 = a + j b
 *			Let z2 = c + j d
 *
 *		2.	Then csubt(z1,z2) = (a - c) + j (b - d)
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX csubt (z1, z2)
COMPLEX z1;
COMPLEX z2;
{
    z1.real -= z2.real;
    z1.imag -= z2.imag;
    return (z1);
}
