/* EXP and hyperbolic trig functions for Sozobon C.			*/
/* Copyright ½ David Brooks, 1989 All Rights Reserved			*/

#include <fplib.h>
#include <errno.h>

/* EXP:									*/
/*									*/
/* Uses the synthesis (2**n) * (2**[m/8]) * b**g			*/
/* where b = 2**(1/8) and 8*n+m+g = arg/ln(b).  b**g has a cubic 	*/
/* approximation: source and accuracy unknown.				*/
/*									*/
/* Beware a bug in the standard release: can't compare two negative	*/
/* floating numbers.							*/

float exp(a) register float a;
{	fstruct		res;
	register int	aint;

	static fstruct huge = {HUGE_AS_INT};
	static float powtab[] = {1.0, 1.09050773, 1.1892071, 1.2968396,
			1.41421356, 1.5422108, 1.68179283, 1.8340081};

	if (a > 43.5)
	{	errno = ERANGE;
		return huge.f;
	}

	if ((a + 43.5) < 0.0)
		return 0.0;				/* Underflow */

	if ((aint = (int)(a *= 11.5415603)) < 0)	/* 8/ln(2) */
		--aint;				/* Correct mathematically */
	a = (float)aint - a;			/* -(frac part)		*/

	res.f = 1.0 + a * (-0.0866439378 + a * (0.003750577 + 
				a * -0.11321783e-3));
	res.sc[3] += aint >> 3;			/* Mult by 2**n		*/
	return res.f * powtab[aint&7];		/* Mult by 2**[m/8]	*/
}

/* HYPERBOLIC FUNCTIONS: virtually free					*/

float sinh(a) float a;
{	register float	ea = exp(a);

	return 0.5 * (ea - (1.0 / ea));
}

float cosh(a) float a;
{	register float	ea = exp(a);

	return 0.5 * (ea + (1.0 / ea));
}

float tanh(a) float a;
{	register float	e2a;

	e2a = exp(a);
	e2a = e2a * e2a;			/* exp-squared-a */
	return (e2a - 1.0) / (e2a + 1.0);
}

