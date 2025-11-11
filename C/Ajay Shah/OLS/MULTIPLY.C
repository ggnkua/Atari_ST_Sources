/*
Various kinds of matrix multiplies.
*/

#include <stdio.h>
#include <math.h>
#include "utils.h"
#include "matrix.h"

void 
MMult (float **A, float **B, float **C, int M, int N, int K)
     /* A is MxN, B is NxK.  C is AxB.  Nothing is allocated.  */
{
  int row, col, j;
  float sum;

  for (row = 1; row <= M; row++)
    for (col = 1; col <= K; col++)
      {
	sum = 0.0;
	for (j = 1; j <= N; j++)
	  sum += A[row][j] * B[j][col];
	C[row][col] = sum;
      }
}

void 
d_MMult (double **A, double **B, double **C, int M, int N, int K)
     /* A is MxN, B is NxK.  C is AxB.  Nothing is allocated.  */
{
  int row, col, j;
  double sum;

  for (row = 1; row <= M; row++)
    for (col = 1; col <= K; col++)
      {
	sum = 0.0;
	for (j = 1; j <= N; j++)
	  sum += A[row][j] * B[j][col];
	C[row][col] = sum;
      }
}

float 
dot (float *x, float *y, int N)
{
  int i;
  float sum;

  for (sum = 0.0, i = 0; i < N; i++)
    sum += x[i] * y[i];
  return sum;
}

double 
d_dot (double *x, double *y, int N)
{
  int i;
  double sum;

  for (sum = 0.0, i = 0; i < N; i++)
    sum += x[i] * y[i];
  return sum;
}

double 
df_dot (double *x, float *y, int N)
{
  int i;
  double sum;

  for (sum = 0.0, i = 0; i < N; i++)
    sum += x[i] * ((double) y[i]);
  return sum;
}
