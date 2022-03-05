/* CEIL, FLOOR, MODF, and FMOD functions for Sozobon C.			*/
/* Copyright = David Brooks, 1989 All Rights Reserved			*/

#include <fplib.h>

/* This macro returns true if the number is so large that is has no	*/
/* representable fraction.						*/

#define ISLGINT(a)	(((a).sc[3] & EXP_MASK) > (BIAS + MANT_BITS))

/* CEIL: smallest integral value not less than a.			*/

float ceil(a) 
fstruct a;
{	register float	aint;

	if (ISLGINT(a))
		return a.f;

	if ((aint = (float)((long)a.f)) != a.f && a.sc[3] >= 0)
		++aint;

	return aint;
}

/* FLOOR: largest integral value not greater than a.			*/

float floor(a)
fstruct a;
{	register float	aint;

	if (ISLGINT(a))
		return a.f;

	if ((aint = (float)((long)a.f)) != a.f && a.sc[3] < 0)
		--aint;

	return aint;
}

/* Just for once, we luck out: negative numbers behave as needed... */

float modf(a, ip)
fstruct a;
float *ip;
{	long ipart;

	*ip = (ISLGINT(a))?a.f:(float)(long)a.f;

	return a.f - *ip;
}

float fmod(n, d)
float n, d;
{	fstruct quot;
	long iquot;

	quot.f = n / d;
	if (ISLGINT(quot))
		return 0.0;

	iquot = (long)quot.f;
	return n - (float)iquot * d;
}
