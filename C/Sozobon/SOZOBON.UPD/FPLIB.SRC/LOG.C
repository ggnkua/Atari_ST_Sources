/* LOG functions for Sozobon C.						*/
/* Copyright ½ David Brooks, 1989 All Rights Reserved			*/

#include <fplib.h>
#include <errno.h>

/* LOG:									*/
/*									*/
/* This yanks out the exponent, performs a polynomial valid over +/-	*/
/* sqrt(2), and adds the scaled exponent back in.  Domain error on	*/
/* arguments <= 0.							*/

float log(a) fstruct a;
{	register float	t1, t2, t3;
	static fstruct nhuge = {0xFFFFFFFFL};	/* Largest negative	*/

	if (a.f <= 0.0)
	{	errno = EDOM;			/* Impossible really	*/
		return nhuge.f;
	}

	if (a.f < M_SQRT2 && a.f > M_SQRT1_2)
	{	t3 = 0.0;	/* arg between sqrt(2) and sqrt(2)/2	*/
		t2 = (t1 = a.f - 1.0) + 2.0;
	}
	else
	{	t3 = (float)(((int)a.sc[3] << 1) - 0x81) * 0.34657359;
			/* ...(log2(a) * 2 + 1) * ln(2)/2 */
		a.sc[3] = BIAS;			/* Scale back to range */
		t2 = a.f + M_SQRT1_2;
		t1 = a.f - M_SQRT1_2;
	}

	t1 /= t2;
	t2 = t1 * t1;

	return t3 + t1 * (2.0000008 + t2 * (0.66644078 + t2 * 0.41517739));
}

/* LOG10 is easy. */

float log10(a) float a;
{
	return M_LOG10E * log(a);
}
