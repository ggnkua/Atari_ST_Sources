/* Devpac DSP example code MATMULT1.C */
/* for Lattice C                      */
/* (c) Copyright HiSoft 1993          */
/* All rights reserved                */

/* Note that this uses different data to the BASIC examples as
   the random number algorithms used by the languages are different
*/
#include <stdio.h>
#include <stdlib.h>

#define N 4
typedef float MATRIX[N][N];
 
void showmat(MATRIX c)
{
int i,j;
	for	(j=0;j<N;j++)
	{
		for	(i=0;i<N;i++)
			printf("%f\t",c[i][j]);
		printf("\n");
	}
	printf("\n");
}


void mult(MATRIX a,MATRIX b,MATRIX c)
{
int i,j,k;
	for	(i=0;i<N;i++)
		for	(j=0;j<N;j++)
				{
					c[i][j]=0;
					for (k=0;k<N;k++)
						c[i][j]+=a[k][j]*b[i][k];
				}
}

int main(void)
{
MATRIX a, b, c;
int i,j;


	for	(i=0;i<N;i++)
		for	(j=0;j<N;j++)
			{
				a[i][j]=(float)(rand())/(RAND_MAX+1);
				b[i][j]=(float)(rand())/(RAND_MAX+1);
			}

	showmat(a);
	showmat(b);

	mult(a,b,c);

	showmat(c);
	return 0;
}
