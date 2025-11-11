
/* File olse.c */

/* OLS Engine.

This module is steeped in a certain notation, and assumptions
about data structures.

X is the data matrix.  It is one observation per row.  Each row
is a set of r.h.s. variables.  The last variable on each row is
the l.h.s. variable (commonly called y).

beta is the vector of OLS coefficients.  S is the vector of
standard errors about these.
*/

void MakeXpX (float **data, double **XpX, int K, int ObsNum);
/* Given matrix data ObsNum rows by K cols, computes the
	X'X matrix using the first (K-1) variables. */

void MakeXpy (float **data, double **Xpy, int K, int ObsNum);
/* Assuming y is the K'th column of data, computes X'y */

void Predict (float **data, double *beta, float *Yhat,
	      int K, int ObsNum);
/* Given a matrix data, a vector of OLS coefficients beta,
	computes a vector of predictions Yhat */

void ANOVA (float **data, float *Yhat, int K, int ObsNum,
	    double *sigma2, double *R2, double *F);
/* Given true y (K'th col of data) and predictions Yhat,
	computes sigma2, R2 and F */

int olsengine (int noinference, float **data, int K, int ObsNum,
	       double *beta, double *S,
	       double *sigma2, double *R2, double *F,
	       float *Yhat);

/* Blackbox which does OLS.  Computations only, no IO.
	Inputs:
		noinference, data, K, ObsNum
	Outputs:
		beta, S, sigma2, R2, F, Yhat.

	If noinference, then beta is computed but no inference is
	done.  sigma2 is MSE.  F is the test that all beta are
	simultaneously 0.  Yhat is vector of predictions.

	beta, S and Yhat are vectors.  Caller must allocate!

	*/
