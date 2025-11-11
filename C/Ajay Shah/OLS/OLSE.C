/*
	Engine for doing OLS.
*/

#include <stdio.h>
#include <math.h>
#include <stddef.h>
#include "utils.h"		/* for allocation/deallocation stuff. */
#include "matrix.h"		/* for matrix inversion, dot products, etc. */
#include "linstats.h"		/* for error checks. */

int 
  olsengine (int noinference, float **data, int K, int ObsNum,
	     double *beta, double *S,
	     double *sigma2, double *R2, double *F,
	     float *Yhat)

     /*
   Blackbox which does OLS.  Takes data matrix, K and ObsNum.
   Produces vector of coefficients beta, vector of standard
   errors S and scalar Rsquared.

   You have to allocate everything (beta, S and Yhat) before
   calling ols.  Notice R2 and sigma2 are passed by reference.

   This function merely computes things; No I/O takes place.
*/

{
  double **XpX;			/* X'X matrix. */
  double **Xpy;			/* X'y matrix */
  double **V;			/* (X'X) inverse matrix. */
  double **tmpbeta;		/* temporary representation for beta. */
  int i;

  if ((XpX = dmatrix (1, K, 1, K)) == NULL)
    {
      printf ("No room for X'X matrix.\n");
      return 1;
    }
  if ((V = dmatrix (1, K, 1, K)) == NULL)
    {
      printf ("No room for X'X inverse matrix.\n");
      return 1;
    }
  if ((Xpy = dmatrix (1, K, 1, 1)) == NULL)
    {
      printf ("No room for X'y vector.\n");
      return 1;
    }
  if ((tmpbeta = dmatrix (1, K, 1, 1)) == NULL)
    {
      printf ("No room for beta vector.\n");
      return 1;
    }

  MakeXpX (data, XpX, K, ObsNum);
  MakeXpy (data, Xpy, K, ObsNum);
  if (1 == d_Inverse (XpX, V, K))
    return 1;
  d_MMult (V, Xpy, tmpbeta, K, K, 1);
  /* multiply V (KxK) by Xpy (Kx1) giving tmpbeta (Kx1) */

  /* Now move into vector representation of beta: */
  for (i = 0; i < K; i++)
    beta[i] = tmpbeta[i + 1][1];
  if (noinference)
    return 0;
  /* don't waste time doing inference when he says
		he doesn't want it. */

  /* Generate predictions: */
  Predict (data, beta, Yhat, K, ObsNum);	/* produces Yhat */
  ANOVA (data, Yhat, K, ObsNum, sigma2, R2, F);
  for (i = 0; i < K; i++)
    S[i] = sqrt ((*sigma2) * V[i + 1][i + 1]);

  free_dmatrix (tmpbeta, 1, K, 1, 1);
  free_dmatrix (Xpy, 1, K, 1, 1);
  free_dmatrix (XpX, 1, K, 1, K);
  free_dmatrix (V, 1, K, 1, K);

  return 0;
}

void 
Predict (float **data, double *beta, float *Yhat,
	 int K, int ObsNum)
{
  int i;

  for (i = 0; i < ObsNum; i++)
    Yhat[i] = (float) df_dot (beta, data[i], K);
}

void 
MakeXpX (float **data, double **XpX, int K, int ObsNum)
{
  int vr, vc, i;
  double sum;

  for (vr = 0; vr < K; vr++)
    {
      for (vc = 0; vc <= vr; vc++)
	{
	  sum = 0.0;
	  for (i = 0; i < ObsNum; i++)
	    sum += (double) (data[i][vc] * data[i][vr]);
	  XpX[vr + 1][vc + 1] = sum;
	  XpX[vc + 1][vr + 1] = sum;
	}
    }
}

void 
MakeXpy (float **data, double **Xpy, int K, int ObsNum)
{
  int v, i;
  double sum;

  for (v = 0; v < K; v++)
    {
      sum = 0.0;
      for (i = 0; i < ObsNum; i++)
	sum += (double) (data[i][v] * data[i][K]);
      Xpy[v + 1][1] = sum;
    }
}

void 
ANOVA (float **data, float *Yhat, int K, int ObsNum,
       double *sigma2, double *R2, double *F)
     /* Basically does a analysis of variance and reports results.*/
{
  double sumY, mean, dev;
  int i;
  double expl_var, total_var, sse;
  /* explained variation, total variation and SSE */

  for (sumY = 0.0, i = 0; i < ObsNum; i++)
    sumY += (double) data[i][K];
  mean = sumY / ObsNum;

  expl_var = 0.0;
  total_var = 0.0;
  sse = 0.0;
  for (i = 0; i < ObsNum; i++)
    {
      dev = (double) (mean - data[i][K]);
      total_var += (dev * dev);
      dev = (double) (mean - Yhat[i]);
      expl_var += (dev * dev);
    }
  sse = total_var - expl_var;

  *sigma2 = sse / (ObsNum - K);
  *R2 = expl_var / total_var;
  *F = expl_var / ((K - 1) * (*sigma2));
}
