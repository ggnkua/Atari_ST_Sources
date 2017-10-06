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
 *	atan2   double precision arc tangent of two arguments
 *
 *  KEY WORDS
 *
 *	atan2
 *	machine independent routines
 *	trigonometric functions
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Returns double precision arc tangent of two
 *	double precision floating point arguments ( atan(Y/X) ).
 *
 *  USAGE
 *
 *	double atan2(x,y)
 *	double x;
 *	double y;
 *
 *  REFERENCES
 *
 *	Fortran 77 user's guide, Digital Equipment Corp. pp B-4.
 *
 *  RESTRICTIONS
 *
 *	Note that the argument usage is exactly the reverse of the
 *	common FORTRAN usage where atan2(x,y) computes atan(x/y).
 *	The usage here is less confusing than remembering that x is
 *	really y and y is really x.
 *
 *	For precision information refer to documentation of the
 *	other floating point library routines called.
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *
 *  INTERNALS
 *
 *	Computes atan(y/x) from:
 *
 *		1.	If x = 0 then
 *			atan(x,y) = PI/2 * (sign(y))
 *
 *		2.	If x > 0 then
 *			atan(x,y) = atan(y/x)
 *
 *		3.	If x < 0 then atan2(x,y) =
 *			PI*(sign(y)) + atan(y/x)
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"

/* mjr++ */
static unsigned long
	__notanumber[2] = { 0x7fffffffL, 0xffffffffL }; /* ieee NAN */
#define NAN  (*((double *)&__notanumber[0]))


double atan2 (x, y)
double x;
double y;
{
    double result;
    extern double sign();
    extern double atan();

    ENTER ("atan2");
    DEBUG4 ("atan2in", "x = %le y = %le", x, y);
/* mjr++ */
    if(x == NAN) return NAN;

    if (x == 0.0) {
	result = sign (HALFPI, y);
    } else if (x > 0.0) {
	result = atan (y/x);
    } else {
	result = atan (y/x) + sign (PI, y);
    }
    DEBUG3 ("atan2out", "result %le", result);
    LEAVE ();
    return (result);
}
