/* FABS, LDEXP, and FREXP functions for Sozobon C.			*/
/* Copyright ½ David Brooks, 1989 All Rights Reserved			*/

/* Mustn't allow the standard declaration of fabs()... */
#define MATH_H

#include <fplib.h>
#include <errno.h>

/* FABS: directly manipulate the sign bit, punning the type.  Actually	*/
/* the argument and return are both float.				*/

unsigned long fabs(a)
unsigned long a;
{	return a & 0xFFFFFF7FL;	}

/* LDEXP: again direct manipulation.					*/

float ldexp(a, n)
fstruct a;
int n;
{
/* "long" to handle int overflow/underflow... */
	register long exp = (long)(a.sc[3] & EXP_MASK) + n;

	if (exp <= 0L)
		return 0L;			/* Underflow */

	if (exp > 0x7FL)
	{	errno = ERANGE;			/* Overflow */
		a.ul |= 0xFFFFFF7FL;		/* Preserve sign */
		return a.f;
	}

	a.sc[3] = (a.sc[3] & 0x80) | exp;
	return a.f;
}

/* FREXP: split into convenient mantissa and exponent			*/

float frexp(a, ip)
fstruct a;
int *ip;
{	if (a.sc[3] == 0)
		*ip = 0;
	else
	{	*ip = (a.sc[3] & 0x7f) - BIAS;
		a.sc[3] = (a.sc[3] & 0x80) | BIAS;	/* preserve sign,
							   force exponent */
	}

	return a.f;
}
