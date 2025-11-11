
#include <stdio.h>
#include <math.h>
#include "distribs.h"

/* The F distribution. */

#ifdef TESTING
int 
main ()
{
  double x, p, invp;
  int df1, df2;

  for (df1 = 1; df1 < 10; df1 += 4)
    for (df2 = 1; df2 < 10; df2 += 4)
      {
	printf ("\nF(%d, %d)\n", df1, df2);
	for (x = 0.5; x < 5.0; x += 2.0)
	  {
	    p = pF (x, df1, df2);
	    invp = critF (p, df1, df2);
	    printf ("x = %2.1f, Prob(>F) = %10.8f, InvF = %10.8f\n",
		    x, p, invp);
	  }
      }

  return 0;
}

#endif

/* Rest of this file essentially cleaned up version of Gary
Perlman's source on StatLib. */

#define I_PI 0.3183098861837906715377675	/* 1/pi */
#define F_EPSILON 1.0e-9	/* accuracy of critF approximation */
#define F_MAX 9999.0		/* maximum F ratio */

/*FUNCTION pF: probability of F.
  ALGORITHM Compute probability of F ratio.
	Adapted from Collected Algorithms of the CACM
	Algorithm 322
	Egon Dorrer
*/

double 
pF (double F, int df1, int df2)
{
  int i, j;
  int a, b;
  double w, y, z, d, p;

  if (F < F_EPSILON || df1 < 1 || df2 < 1)
    return (1.0);

  a = df1 % 2 ? 1 : 2;
  b = df2 % 2 ? 1 : 2;
  w = (F * df1) / df2;
  z = 1.0 / (1.0 + w);
  if (a == 1)
    if (b == 1)
      {
	p = sqrt (w);
	y = I_PI;
	d = y * z / p;
	p = 2.0 * y * atan (p);
      }
    else
      {
	p = sqrt (w * z);
	d = 0.5 * p * z / w;
      }
  else if (b == 1)
    {
      p = sqrt (z);
      d = 0.5 * z * p;
      p = 1.0 - p;
    }
  else
    {
      d = z * z;
      p = w * z;
    }
  y = 2.0 * w / z;

  for (j = b + 2; j <= df2; j += 2)
    {
      d *= (1.0 + a / (j - 2.0)) * z;
      p = (a == 1 ? p + d * y / (j - 1.0) : (p + w) * z);
    }
  y = w * z;
  z = 2.0 / z;
  b = df2 - 2;
  for (i = a + 2; i <= df1; i += 2)
    {
      j = i + b;
      d *= y * j / (i - 2.0);
      p -= z * d / j;
    }
  /* correction for approximation errors suggested in certification */
  if (p < 0.0)
    p = 0.0;
  else if (p > 1.0)
    p = 1.0;

  return (1.0 - p);
}

/* critF: compute critical F value t produce given probability.
   ALGORITHM
	Begin with upper and lower limits for F values (maxf and minf)
	set to extremes.  Choose an f value (fval) between the extremes.
	Compute the probability of the f value.  Set minf or maxf, based
	on whether the probability is less than or greater than the
	desired p.  Continue adjusting the extremes until they are
	within F_EPSILON of each other.
*/

double 
critF (double p, int df1, int df2)
{
  double fval;
  double maxf = F_MAX;		/* maximum F ratio */
  double minf = 0.0;		/* minimum F ratio */

  if (p <= 0.0 || p >= 1.0)
    return (0.0);

  fval = 1.0 / p;		/* the smaller the p, the larger the F */

  while (fabs (maxf - minf) > F_EPSILON)
    {
      if (pF (fval, df1, df2) < p)	/* F too large */
	maxf = fval;
      else			/* F too small */
	minf = fval;
      fval = (maxf + minf) * 0.5;
    }

  return (fval);
}
