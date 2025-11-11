/*
	unclassifiables.
*/

#include <stdio.h>
#include <string.h>
#include "utils.h"
#include "matrix.h"

#ifdef TESTING
int 
main ()
{
  float **A;
  int i, j;

  A = matrix (1, 2, 1, 5);
  for (i = 1; i <= 2; i++)
    for (j = 1; j <= 5; j++)
      A[i][j] = (float) i *j;
  printf ("Testing PrintMatrix: \n");
  PrintMatrix (A, 2, 5, " %5.2f ");
  printf ("\nwith a different format:\n");
  PrintMatrix (A, 2, 5, " %7.0f ");

  return 0;
}

#endif /* TESTING */

void 
PrintMatrix (float **M, int rows, int cols, char *fmt)
{
  int i, j;

  printf ("PrintMatrix: %d rows and %d columns.\n", rows, cols);
  for (i = 1; i <= rows; i++)
    {
      for (j = 1; j <= cols; j++)
	printf (fmt, M[i][j]);
      printf ("\n");
    }
}

void 
d_PrintMatrix (double **M, int rows, int cols, char *fmt)
{
  int i, j;

  printf ("d_PrintMatrix: %d rows and %d columns.\n", rows, cols);
  for (i = 1; i <= rows; i++)
    {
      for (j = 1; j <= cols; j++)
	printf (fmt, M[i][j]);
      printf ("\n");
    }
}

void 
Transpose (float **A, int n)	/* Transpose A, which is n x n floats */
{
  int i, j;
  float tmp;

  for (i = 1; i <= n; i++)
    for (j = (i + 1); j <= n; j++)
      {
	tmp = A[i][j];
	A[i][j] = A[j][i];
	A[j][i] = tmp;
      }
}

void 
d_Transpose (double **A, int n)	/* Transpose A, which is n x n doubles */
{
  int i, j;
  double tmp;

  for (i = 1; i <= n; i++)
    for (j = (i + 1); j <= n; j++)
      {
	tmp = A[i][j];
	A[i][j] = A[j][i];
	A[j][i] = tmp;
      }
}

void 
  CopyMatrix (double **A, double **B, int rows, int cols)
{
  int i, j;
  for (i = 1; i <= rows; i++)
    for (j = 1; j <= cols; j++)
      B[i][j] = A[i][j];
}

void 
  CopyVector (double *x, double *y, int K)
{
  int i;
  for (i = 1; i <= K; i++)
    y[i] = x[i];
}

void 
  RandomSym (double **A, int K, int *seed)
     /* This routine generates a random square symmetric matrix
	of size K x K. */
{
  int row, col;
  for (row = 1; row <= K; row++)
    for (col = 1; col <= row; col++)
      A[row][col] = A[col][row] = 5.0 * ran1 (seed);
}

void 
  RandomMatrix (double **A, int rows, int cols, int *seed)
     /* This routine fills A (rows, cols) with random numbers. */
{
  int i, j;

  for (i = 1; i <= rows; i++)
    for (j = 1; j <= rows; j++)
      A[i][j] = 5.0 * ran1 (seed);
}

double 
  trace (double **A, int N)
{
  double sum;
  int i;

  for (sum = 0.0, i = 1; i <= N; i++)
    sum += A[i][i];
  return sum;
}
