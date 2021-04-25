/* SQRT function for Sozobon C.						*/
/* Copyright = David Brooks, 1989 All Rights Reserved			*/
/*									*/
/* The method is from Hart et al: "Computer Approximations".  We reduce	*/
/* the range to [0.25..1.0], then apply the polynomial:			*/
/* 0.25927688 + 1.0520212n - 0.31632214n^2, giving 2.3 digits 		*/
/* approximation.  Then we do two Newton's iterations (giving ~9 digits	*/
/* precision).								*/
/*									*/
/* A negative argument gives a return value of 0.0 and sets EDOM.	*/

#include <fplib.h>
#include <errno.h>

/* Sadly we can't use register for objects of type fstruct. */

float sqrt(n)
fstruct n;
{	register int exp;		/* Separate unbiased exponent.	*/
	fstruct s;

	if (n.sc[3] == 0)		/* Check for 0.0		*/
		return 0.0;

	if ((exp = n.sc[3]) < 0)	/* Test argument's sign.	*/
	{	errno = EDOM;
		return 0.0;
	}

	exp -= BIAS;			/* Get unbiased exponent.	*/
	if (exp & 1)
	{	n.sc[3] = BIAS-1;	/* Convert to 0.25..0.5.	*/
		++exp;
	}
	else
		n.sc[3] = BIAS;		/* Or convert to 0.5..1.	*/

	s.f = 0.25927688 + n.f * (1.0520212 + n.f * -0.31632214);

	s.f = s.f + n.f / s.f;		/* One Newton.			*/
	s.sc[3] -= 1;			/* (here's the divide by 2).	*/
	s.f = s.f + n.f / s.f;		/* The other Newton.		*/
	s.sc[3] += ((unsigned int)exp >> 1) - 1;
					/* Divide by 2 and insert
					   half the original exponent.	*/
	return s.f;
}
