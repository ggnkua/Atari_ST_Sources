/* SIN, COS, and TAN functions for Sozobon C.				*/
/* Copyright = David Brooks, 1989 All Rights Reserved			*/

#include <fplib.h>
#include <errno.h>

/* SIN:
/*									*/
/* The method is from Hart et al: "Computer Approximations". It reduces	*/
/* the range to 0..pi/2, scaled to 0..1, and applies:			*/
/* 1.57079629t - 0.64596336t^3 + 0.0796884805t^5 - 0.0046722279t^7	*/
/*		+ 0.00015082056t^9 (precision of 8.5 digits) and	*/
/* finally fixes the sign.						*/
/*									*/
/* MODIFICATIONS:							*/
/* DWB	03/15/89	Don't try to negate x if it's zero.		*/
/* DWB	04/30/89	Fix cos(0.0)					*/

float sin(a) fstruct a;
{	register float		t, ipart, tsq;
	fstruct			x;
	register unsigned long	tint;
	register char		sign;

	sign = a.sc[3] & 0x80;
	a.sc[3] ^= sign;		/* sin(negative x) = -sin(-x) */

/* If the argument is huge, the result is rather arbitrary -- and,	*/
/* besides, the following code will break.				*/

	if (a.sc[3] >= (BIAS + MANT_BITS))
	{	errno = ERANGE;
		return 0.0;
	}

	t = a.f * M_2_PI;		/* Express in quarter-turns */

/* Get integer part and fraction.  Optimise the common case, in the
   first quadrant */

	if (t <= 1.0)
		tint = 0L;
	else
	{	tint = t;			/* tint = whole quarterturns */
		ipart = (float)tint;
		t = (tint & 1)?ipart - t + 1.0:t - ipart;   /* Get fraction */
	}
	tsq = t * t;
	x.f = t * (1.57079629 + tsq * (-0.64596336 + tsq * (0.0796884805
		+ tsq * (-0.46722279e-2 + tsq * 0.15082056e-3))));

	if (x.sc[3] != 0)			/* Don't negate zero!	*/
	{	if ((int)tint & 2)		/* Quadrants 3 and 4	*/
			x.sc[3] |= 0x80;	/* Set negative		*/
		if (sign != 0)
			x.sc[3] ^= 0x80;	/* Negate		*/
	}

	return x.f;
}

/* COS:									*/
/*									*/
/* Although approximations are available, this will do fine.  I'm not	*/
/* proud of the hack to fix the only rational argument with a rational	*/
/* result, but then pride is the first deadly sin...			*/

float cos(a) float a;
{
	return a==0.0?1.0:sin(M_PI_2 - a);
}

/* TAN:									*/
/* (v-e-r-y s-l-o-w-l-y)						*/

float tan(a) float a;
{
	return sin(a) / sin(M_PI_2 - a);
}
