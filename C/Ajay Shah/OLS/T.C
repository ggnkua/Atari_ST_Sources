/* Algorithm AS 3 from
   Applied Statistics (1968) Vol. 17, p. 189.
   Student's t distribution probability (lower tail).

   Fortran source from statlib,
   translated by f2c,
   cleaned up A LOT by hand by Ajay Shah, Sun May  5 03:48:17 PDT 1991
*/

#include <math.h>
#include "distribs.h"

double critt (double p, int dof);

#ifdef TESTING
int 
main ()
{
  int dof;
  double p, t, probability;
  void printf ();

  printf ("\nt Probabilities:\n\n");
  printf ("dof     Pr(t<0.5)   Pr(t<1.5)   Pr(t<2.5)   Pr(t<3.5)   Pr(t<4.5)\n\n");
  for (dof = 1; dof < 35; dof += 7)
    {
      printf ("%2d     ", dof);
      for (t = 0.5; t <= 5.0; t += 1.0)
	if (0 == tprob (t, dof, &probability))
	  printf ("  %f  ", probability);
	else
	  {
	    printf ("Ouch!\n");
	    return 1;
	  }
      printf ("\n");
    }
  printf ("\nNormal:");
  for (t = 0.5; t <= 5.0; t += 1.0)
    printf ("  %f  ", pnorm1 (t));
  printf ("\n\n\n");

  printf ("Inverse probabilities:\n\n");
  printf ("       %10s%10s%10s%10s\n\n",
	  "Prob=0.2", "Prob=0.4", "Prob=0.6", "Prob=0.8");
  for (dof = 1; dof < 35; dof += 6)
    {
      printf ("%2d     ", dof);
      for (p = 0.2; p <= 0.8; p += 0.2)
	printf ("%10.6f", critt (p, dof));
      printf ("\n");
    }
  printf ("\nNormal:");
  for (p = 0.2; p <= 0.8; p += 0.2)
    printf ("%10.6f", critz (p));
  printf ("\n");

  return 0;
}

#endif

int 
tprob (double t, int dof, double *probability)

     /* Arguments:
	t : wanna evaluate integral from t to +infinity.
	dof: degrees of freedom of this t distribution.
	probability : computed value might be returned.

	function returns error code 1 if something is wrong,
	0 if all is well.
*/

#define ONEBYPI ((double) 0.3183098861837906715377675)

{
  double d_dof, s, c, f, a, b;
  int fk, ks, im2, ioe, k;

  if (dof < 1)
    return 1;
  d_dof = (double) dof;		/* d_dof is F of fortran code. */

  a = t / sqrt (d_dof);
  b = d_dof / (d_dof + (t * t));
  im2 = dof - 2;
  ioe = dof % 2;
  s = c = f = 1.0;
  fk = ks = 2 + ioe;
  if (im2 > 2)
    for (k = ks; k <= im2; k += 2)
      {
	c = c * b * (fk - 1.0) / fk;
	s += c;
	if (s == f)
	  break;
	f = s;
	fk += 2.0;
      }
  if (ioe != 1)
    {				/* Label 20 of fortran code. */
      *probability = 0.5 + (0.5 * a * sqrt (b) * s);
      return 0;
    }
  else
    {				/* Label 30 of fortran code. */
      if (dof == 1)
	s = 0.0;
      *probability = 0.5 + ((a * b * s + atan (a)) * ONEBYPI);
      return 0;
    }
}

#undef ONEBYPI

#define T_MAX 35.0
#define T_EPSILON 0.0001

/* critt: compute critical t value to produce given probability.
   ALGORITHM
	Begin with upper and lower limits for t values (maxt and mint)
	set to extremes.  Choose a t value (tval) between the extremes.
	Compute the probability of the t value.  Set mint or maxt, based
	on whether the probability is less than or greater than the
	desired p.  Continue adjusting the extremes until they are
	within T_EPSILON of each other.
*/

double 
critt (double p, int dof)
{
  double pt, tval;
  double maxt = T_MAX;		/* maximum t ratio */
  double mint = -T_MAX;		/* minimum t ratio */

  if (p <= 0.0 || p >= 1.0)
    return (0.0);

  tval = 0.0;

  while (fabs (maxt - mint) > T_EPSILON)
    {
      tprob (tval, dof, &pt);
      if (pt > p)		/* t too large */
	maxt = tval;
      else			/* t too small */
	mint = tval;
      tval = (maxt + mint) / 2.0;
    }
  return (tval);
}
