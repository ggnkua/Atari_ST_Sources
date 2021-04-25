/* ASIN, ACOS, ATAN, and ATAN2 functions for Sozobon C.			*/
/* Copyright = David Brooks, 1989 All Rights Reserved			*/

#include <fplib.h>
#include <errno.h>

/* ARCTAN:								*/
/*									*/
/* The method is from Hart et al: "Computer Approximations".  It uses a	*/
/* divide-and-conquer algorithm.  The argument range is divided into	*/
/* five using the partition points tan({1,3,5,7}*pi/16), a polynomial	*/
/* valid over +/- pi/16 is calculated, and other magic is used to	*/
/* reposition the result.  Precision is >8 places.			*/

float atan(a) fstruct a;
{	fstruct		absval;
	register float	tx0, tsq, temp;
	register int	part;
	register char	sign;

	static float	adj[] = {0.0, 0.414213562, 1.0, 2.414213562};
	static float	atof[] = {0.0, 0.39269908, 0.78539816,
					1.178097245, 1.57079633};

	sign = a.sc[3] & 0x80;
	a.sc[3] &= 0x7f;			/* get fabs(a) */
	tx0 = a.f;

/* Figure out the partition */

	part = tx0<0.66817864?(tx0<0.19891237?0:1):(tx0<1.49660576?2:
			tx0<5.0273395?3:4);
	if (part == 4)
		tx0 = -1.0 / tx0;
	else if (part != 0)
	{	temp = adj[part];
		tx0 = (tx0 - temp) / (tx0 * temp + 1.0);
	}

/* Here's the calculation */

	tsq = tx0 * tx0 + 1.67784279;
	a.f = (0.93833093 / tsq + 0.44075154) * tx0 + atof[part];

	if (a.sc[3] != 0)			/* Negate if negative */
		a.sc[3] ^= sign;
	return a.f;
}

/* ARCSIN and ARCCOS use the standard identities.  There's some less	*/
/* optimal code here becausethe released Sozobon C can't properly	*/
/* compare two negative floating numbers.				*/

float asin(a) float a;
{
	if (a > 1.0 || (a+1.0) < 0.0)
	{	errno = EDOM;
		return 0.0;
	}

	return atan(a / sqrt(1.0 - a*a));
}

float acos(a) float a;
{	float	temp;

	if (a > 1.0 || (a+1.0) < 0.0)
	{	errno = EDOM;
		return 0.0;
	}

	temp = atan(sqrt(1.0 - a*a) / a);
	if (a >= 0.0)
		return temp;
	else
		return M_PI + temp;
}

/* ATAN2:								*/
/*									*/
/* Computes atan(quotient), and returns that for positive cos, else 	*/
/* extends the range depending on the sin.				*/

float atan2(s, c) fstruct s, c;
{	register float	r;

	if (c.sc[3] == 0)			/* Infinite argument */
		return (s.sc[3]<0)?-M_PI_2:M_PI_2;

	r = atan(s.f / c.f);

	if (c.sc[3] >= 0)
		return r;			/* Range -pi/2..pi/2 */
	if (s.sc[3] >= 0)
		return M_PI + r;
	return -M_PI + r;
}
