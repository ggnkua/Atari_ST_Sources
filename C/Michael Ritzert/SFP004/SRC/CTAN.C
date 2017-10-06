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
 *	ctan   complex double precision tangent
 *
 *  KEY WORDS
 *
 *	ctan
 *	complex functions
 *	machine independent functions
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Computes double precision complex tangent of a double
 *	precision complex argument.
 *
 *  USAGE
 *
 *	COMPLEX ctan (z)
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
 *	Computes complex tangent of z = x + j y from:
 *
 *		1.	Compute ccos(z)
 *
 *		2.	If ccos(z) = 0 + j0 then the
 *			result is MAX_POS_DBLF + j0
 *
 *		3.	Else ctan(z) = csin(z) / ccos(z)
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"


COMPLEX ctan (z)
COMPLEX z;
{
    COMPLEX ccosz;
    extern COMPLEX ccos (), csin (), cdiv ();

    ENTER ("ctan");
    DEBUG4 ("ctanin", "arg %le %le", z.real, z.imag);
    ccosz = ccos (z);
    if (ccosz.real == 0.0 && ccosz.imag == 0.0) {
/*****
	z.real = MAX_POS_DBLF;
******/
	z.real = 0.0;		/* TERRIBLY WRONG! */
	z.imag = 0.0;
    } else {
	z = csin (z);
	z = cdiv (z, ccosz);
    }
    DEBUG4 ("ctanout", "result %le %le", z.real, z.imag);
    LEAVE ();
    return (z);
}
