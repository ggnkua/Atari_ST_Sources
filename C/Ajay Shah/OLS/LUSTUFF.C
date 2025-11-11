/*
	The LU approach to numerical linear algebra.
	Mostly off Numerical Recipes.
*/

#include <stdio.h>
#include <math.h>
#include "utils.h"
#include "matrix.h"

void lubksb (float **a, int n, int *indx, float b[]);
void d_lubksb (double **a, int n, int *indx, double b[]);
int ludcmp (float **a, int n, int *indx, float *d);
int d_ludcmp (double **a, int n, int *indx, double *d);
int dnear (double x, double y);
int fnear (float x, float y);

int d_LinSys (double **A, double *b, double *x, int K);

#ifdef TESTING
int TestInversion ();
int TestLinSys ();

int 
main ()
{
  int returncode;

  returncode = 0;
  if (1 == TestInversion ())
    {
      returncode = 1;
      printf ("INVERSION TEST FAILED.\n");
    }
  if (1 == TestLinSys ())
    {
      returncode = 1;
      printf ("LINEAR SYSTEMS TEST FAILED.\n");
    }
  return returncode;
}

int 
TestInversion ()
{
  double biggesterror, error, **A, **Acopy, **B, **product;
  int trial, i, j, K, returncode, seed;

  seed = 0;
  K = 20;			/* going to be playing with K x K matrices.  */
  A = dmatrix (1, K, 1, K);
  Acopy = dmatrix (1, K, 1, K);
  B = dmatrix (1, K, 1, K);
  product = dmatrix (1, K, 1, K);
  printf ("TESTING MATRIX INVERSION.\n");
  printf ("Today, we're going to play with %d x %d matrices.\n\n", K, K);

  for (trial = 1; trial <= 5; trial++)
    {
      printf ("Trial #%d:\n	generating matrix,\n", trial);
      RandomSym (A, K, &seed);
      CopyMatrix (A, Acopy, K, K);	/* because inversion clobbers A */
      printf ("	inverting it,\n");
      returncode = d_Inverse (A, B, K);
      if (returncode != 0)
	{
	  printf ("d_Inverse returned %d.\n", returncode);
	  return 1;
	}
      printf ("	post-multiplying,\n");
      d_MMult (Acopy, B, product, K, K, K);
      printf ("	finding biggest error = ");
      biggesterror = -1.0e10;
      for (i = 1; i <= K; i++)
	for (j = 1; j <= K; j++)
	  {
	    if (i == j)
	      error = fabs (product[i][i] - 1.0);
	    else
	      error = fabs (product[i][j]);
	    if (error > biggesterror)
	      biggesterror = error;
	  }
      printf ("%e.\n\n", biggesterror);
    }
  free_dmatrix (A, 1, K, 1, K);
  free_dmatrix (B, 1, K, 1, K);
  free_dmatrix (Acopy, 1, K, 1, K);
  free_dmatrix (product, 1, K, 1, K);
  return 0;
}

int 
TestLinSys ()
{
  double sum, biggesterror, error, **A, **Acopy;
  double *x, *b, *test;
  int row, trial, i, K, returncode, seed;

  seed = 0;
  K = 20;			/* going to be playing with K x K matrices.  */
  A = dmatrix (1, K, 1, K);
  Acopy = dmatrix (1, K, 1, K);
  x = dvector (1, K);
  b = dvector (1, K);
  test = dvector (1, K);
  printf ("TESTING SOLUTION OF LINEAR SYSTEMS.\n");
  printf ("Today, we're going to play with %d x %d systems.\n\n", K, K);

  for (trial = 1; trial <= 5; trial++)
    {
      printf ("Trial #%d:\n	generating system,\n", trial);
      RandomSym (A, K, &seed);
      CopyMatrix (A, Acopy, K, K);	/* because LinSys clobbers A. */
      for (i = 1; i <= K; i++)
	b[i] = ran1 (&seed);
      printf ("	solving system,\n");
      returncode = d_LinSys (A, b, x, K);
      if (returncode != 0)
	{
	  printf ("d_LinSys returned %d.\n", returncode);
	  return 1;
	}
      printf ("	post-multiplying,\n");
      for (row = 1; row <= K; row++)
	{
	  sum = 0.0;
	  for (i = 1; i <= K; i++)
	    {
	      sum += Acopy[row][i] * x[i];
	      test[row] = sum;
	    }
	}
      printf ("	finding biggest error = ");
      biggesterror = -1.0e10;
      for (i = 1; i <= K; i++)
	{
	  error = fabs (test[i] - b[i]);
	  if (error > biggesterror)
	    biggesterror = error;
	}
      printf ("%e.\n\n", biggesterror);
    }
  free_dmatrix (Acopy, 1, K, 1, K);
  free_dmatrix (A, 1, K, 1, K);
  free_dvector (x, 1, K);
  free_dvector (b, 1, K);
  free_dvector (test, 1, K);
  return 0;
}

#endif

/* all routines are in matrix.h except low-level lu routines. */

#define TINY 1.0e-10;
#define DTINY 1.0e-20;

int 
fnear (float x, float y)
{
  return (fabs (x - y) < 1.0e-10) ? 1 : 0;
}

int 
dnear (double x, double y)
{
  return (fabs (x - y) < 1.0e-20) ? 1 : 0;
}

void 
lubksb (float **a, int n, int *indx, float b[])
{
  int i, ii = 0, ip, j;
  float sum;

  for (i = 1; i <= n; i++)
    {
      ip = indx[i];
      sum = b[ip];
      b[ip] = b[i];
      if (ii)
	for (j = ii; j <= i - 1; j++)
	  sum -= a[i][j] * b[j];
      else if (sum)
	ii = i;
      b[i] = sum;
    }
  for (i = n; i >= 1; i--)
    {
      sum = b[i];
      for (j = i + 1; j <= n; j++)
	sum -= a[i][j] * b[j];
      b[i] = sum / a[i][i];
    }
}

void 
d_lubksb (double **a, int n, int *indx, double b[])
{
  int i, ii = 0, ip, j;
  double sum;

  for (i = 1; i <= n; i++)
    {
      ip = indx[i];
      sum = b[ip];
      b[ip] = b[i];
      if (ii)
	for (j = ii; j <= i - 1; j++)
	  sum -= a[i][j] * b[j];
      else if (sum)
	ii = i;
      b[i] = sum;
    }
  for (i = n; i >= 1; i--)
    {
      sum = b[i];
      for (j = i + 1; j <= n; j++)
	sum -= a[i][j] * b[j];
      b[i] = sum / a[i][i];
    }
}

int 
ludcmp (float **a, int n, int *indx, float *d)
{
  int i, imax, j, k;
  float big, dum, sum, temp;
  float *vv;

  vv = vector (1, n);
  *d = 1.0;
  for (i = 1; i <= n; i++)
    {
      big = 0.0;
      for (j = 1; j <= n; j++)
	if ((temp = fabs (a[i][j])) > big)
	  big = temp;
      if (fnear (big, 0.0))
	return 1;
      vv[i] = 1.0 / big;
    }
  for (j = 1; j <= n; j++)
    {
      for (i = 1; i < j; i++)
	{
	  sum = a[i][j];
	  for (k = 1; k < i; k++)
	    sum -= a[i][k] * a[k][j];
	  a[i][j] = sum;
	}
      big = 0.0;
      for (i = j; i <= n; i++)
	{
	  sum = a[i][j];
	  for (k = 1; k < j; k++)
	    sum -= a[i][k] * a[k][j];
	  a[i][j] = sum;
	  if ((dum = vv[i] * fabs (sum)) >= big)
	    {
	      big = dum;
	      imax = i;
	    }
	}
      if (j != imax)
	{
	  for (k = 1; k <= n; k++)
	    {
	      dum = a[imax][k];
	      a[imax][k] = a[j][k];
	      a[j][k] = dum;
	    }
	  *d = -(*d);
	  vv[imax] = vv[j];
	}
      indx[j] = imax;
      if (a[j][j] == 0.0)
	a[j][j] = TINY;
      if (j != n)
	{
	  dum = 1.0 / (a[j][j]);
	  for (i = j + 1; i <= n; i++)
	    a[i][j] *= dum;
	}
    }
  free_vector (vv, 1, n);
  return 0;
}

int 
d_ludcmp (double **a, int n, int *indx, double *d)
{
  int i, imax, j, k;
  double big, dum, sum, temp;
  double *vv;

  vv = dvector (1, n);
  *d = 1.0;
  for (i = 1; i <= n; i++)
    {
      big = 0.0;
      for (j = 1; j <= n; j++)
	if ((temp = fabs (a[i][j])) > big)
	  big = temp;
      if (dnear (big, 0.0))
	return 1;
      vv[i] = 1.0 / big;
    }
  for (j = 1; j <= n; j++)
    {
      for (i = 1; i < j; i++)
	{
	  sum = a[i][j];
	  for (k = 1; k < i; k++)
	    sum -= a[i][k] * a[k][j];
	  a[i][j] = sum;
	}
      big = 0.0;
      for (i = j; i <= n; i++)
	{
	  sum = a[i][j];
	  for (k = 1; k < j; k++)
	    sum -= a[i][k] * a[k][j];
	  a[i][j] = sum;
	  if ((dum = vv[i] * fabs (sum)) >= big)
	    {
	      big = dum;
	      imax = i;
	    }
	}
      if (j != imax)
	{
	  for (k = 1; k <= n; k++)
	    {
	      dum = a[imax][k];
	      a[imax][k] = a[j][k];
	      a[j][k] = dum;
	    }
	  *d = -(*d);
	  vv[imax] = vv[j];
	}
      indx[j] = imax;
      if (a[j][j] == 0.0)
	a[j][j] = DTINY;
      if (j != n)
	{
	  dum = 1.0 / (a[j][j]);
	  for (i = j + 1; i <= n; i++)
	    a[i][j] *= dum;
	}
    }
  free_dvector (vv, 1, n);
  return 0;
}

int 
Inverse (float **A, float **Y, int n)
{
  int *indexes;
  int i, j;
  float d;
  float *onecolumn;

  indexes = ivector (1, n);
  if (ludcmp (A, n, indexes, &d) == 1)
    return 1;
  onecolumn = vector (1, n);

  for (i = 1; i <= n; i++)
    {
      for (j = 1; j <= n; j++)
	onecolumn[j] = 0.0;
      onecolumn[i] = 1.0;
      lubksb (A, n, indexes, onecolumn);
      for (j = 1; j <= n; j++)
	Y[j][i] = onecolumn[j];
    }
  free_ivector (indexes, 1, n);
  free_vector (onecolumn, 1, n);
  return 0;
}

int 
d_Inverse (double **A, double **Y, int n)
{
  int *indexes;
  int i, j;
  double d;
  double *onecolumn;

  indexes = ivector (1, n);
  if (d_ludcmp (A, n, indexes, &d) == 1)
    {
      free_ivector (indexes, 1, n);
      return 1;
    }
  onecolumn = dvector (1, n);

  for (i = 1; i <= n; i++)
    {
      for (j = 1; j <= n; j++)
	onecolumn[j] = 0.0;
      onecolumn[i] = 1.0;
      d_lubksb (A, n, indexes, onecolumn);
      for (j = 1; j <= n; j++)
	Y[j][i] = onecolumn[j];
    }
  free_ivector (indexes, 1, n);
  free_dvector (onecolumn, 1, n);
  return 0;
}

int 
d_LinSys (double **A, double *b, double *x, int K)
{
  int *indexes;
  double d;

  indexes = ivector (1, K);
  if (1 == d_ludcmp (A, K, indexes, &d))
    {
      free_ivector (indexes, 1, K);
      return 1;
    }
  CopyVector (b, x, K);		/* copy b into x */
  d_lubksb (A, K, indexes, x);
  free_ivector (indexes, 1, K);
  return 0;
}

#undef TINY
#undef DTINY
