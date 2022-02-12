#include <lib.h>
#include <math.h>
/*
	SINCOS.C
*/

#define PI 3.141592654
#define HALF_PI 1.570796327
#define TWO_PI 6.283185308

PRIVATE _PROTOTYPE( double series, (double x));

PRIVATE double series(x)
double x;

{
  PRIVATE double coef[5] = {
	   1.0, -0.1666665, 8.333026e-3, -1.980741e-4, 2.601887e-6};
  double x2, ans;
  int i;

  x2 = x * x;
  ans = coef[4];
  for (i = 3; i >= 0; i--) ans = ans * x2 + coef[i];
  return(ans * x);
}

double sin(x)
double x;

{

  if ((x > 1.0e5) || (x < -1.0e5))	/* needed to guarantee that
					 * while loop will terminate
					 * for extremely large angles */
	x = 0;
  while (x > PI) x = x - TWO_PI;
  while (x < -PI) x = x + TWO_PI;
  if (x > HALF_PI) x = PI - x;
  if (x < -HALF_PI) x = -(PI + x);
  return(series(x));
}

double cos(x)
double x;

{
  return(sin(x + HALF_PI));
}
