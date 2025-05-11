
/* sin, expansion due to good ol Hastings */

#include "math.h"

#define N_COEFF 5

double _sin_coeff[] = 
	{
	1.57079631847,
	-.64596371106,
	.07968967928,
	-.00467376557,
	.00015148419
	};

double sin(x)
double x;
{
  double x2;		/* will be x^2 */
  double xn;		/* will be x^(2n+1) */
  double accum;
  int n;
  long ix;

  x = x / (pi * 2);		/* scale it */
/* need to fold x back to between -1 and 1 */

  ix = (long )x;		/* truncate to int */
  x = x - (double )ix;		/* subtract the int part */
				/* now it's between -1 and 1 */

  x = (x * 4.0);

  while (x > 1.0)
	x = 2.0 - x;
  while (x < -1.0)
	x = -2.0 - x;

  x2 = x * x;		/* x^2 */

  for (n = 0, xn = x, accum = 0 ; n < N_COEFF ; n++)
	{
	accum += xn * _sin_coeff[n];
	xn = xn * x2;
	}
  return(accum);
}

double cos(x)
{
  return(sin(x + (pi / 2.0)));
}
