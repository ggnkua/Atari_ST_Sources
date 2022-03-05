/* POW function for Sozobon C.						*/
/* Copyright = David Brooks, 1989 All Rights Reserved			*/
/*									*/
/* This uses exp and log in the obvious way.  A domain error occurs if	*/
/* a=0 and p<=0, or a<0 and p is not integral.				*/

#include <fplib.h>
#include <errno.h>

float pow(a, p)
fstruct a, p;
{	fstruct		r;
	register long	pint;
	register int	sign = 0;

	if (a.sc[3] == 0 && p.sc[3] <= 0)
	{	errno = EDOM;
		return 0.0;
	}

	if (a.sc[3] < 0)		/* ...if a.f < 0 */
	{	pint = (long)p.f;
		if ((float)pint != p.f)	/* ... if nonintegral */
			errno = EDOM;
		sign = pint & 1;	/* ... carry on regardless */
		a.sc[3] &= EXP_MASK;
	}

	r.f = exp(log(a.f) * p.f);
	if (sign && (r.sc[3] != 0))
		r.sc[3] |= 0x80;
	return r.f;
}
