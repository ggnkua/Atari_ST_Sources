/* Devpac DSP example code MATMULT5.C */
/* for Lattice C                      */
/* (c) Copyright HiSoft 1993          */
/* All rights reserved                */

/* Note that this uses different data to the BASIC examples as
   the random number algorithms used by the languages are different
*/

#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>

#define N 4
#define DSP_CODE_FILE "MATMULT5.B56"
typedef char DSP_WORD[3];
typedef float MATRIX[N][N];

static int MulAbility; 
static int MultHandle;
 
int InitMult(void)
{
DSP_WORD *dsp_prog;
FILE * fp;
long prog_size;
MultHandle=Dsp_InqSubrAbility(MulAbility);
if (MultHandle==0)
	{
		/* Now open the DSP file */
		fp=fopen(DSP_CODE_FILE,"rb");
		if (fp==NULL)
			{
				printf("Can't open file " DSP_CODE_FILE "\n");
				Dsp_Unlock();
				return 10;
			}
	
		/* Now read the DSP file into dsp_prog with the size in dsp words in prog_size */	
		fseek(fp,0,SEEK_END);
		prog_size=ftell(fp)/sizeof(DSP_WORD);
		fseek(fp,0,SEEK_SET);
		dsp_prog=malloc(prog_size*sizeof(DSP_WORD));
		fread(dsp_prog,sizeof(DSP_WORD),prog_size,fp);
		fclose(fp);

		MultHandle=Dsp_LoadSubroutine(dsp_prog,prog_size,MulAbility);
		if (MultHandle==0)
		{
			printf("Can't load subroutine\n");
			return 10;
		}
	}
return 0;
}
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

/* multiply a by b giving c - returns non-zero if error */
int mult(MATRIX a,MATRIX b,MATRIX c)
{
long a1[N][N],b1[N][N],c1[N][N*2];
int i,j;

if (InitMult()) return 10;
/* First we need to convert the values to fixed point */
for	(i=0;i<N;i++)
		for	(j=0;j<N;j++)
			{
				a1[i][j]= 0x800000*a[i][j];
				b1[i][j]= 0x800000*b[i][j];
			}

	if(Dsp_RunSubroutine(MultHandle))
		{
			printf("Can't run subroutine\n");
			return 10; 
		}
/* send the data */
	Dsp_BlkUnpacked(&a1[0][0],N*N,0,0);
	Dsp_BlkUnpacked(&b1[0][0],N*N,0,0);

/* get the results back one at a time */
	for	(i=0;i<N;i++)
		for	(j=0;j<N;j++)
			{
			Dsp_BlkUnpacked(0,0,&c1[i][j*2],2);
			c[i][j]=c1[i][j*2]*2 +(float)(c1[i][j*2+1])/0x800000;
			}
	
	return 0;
}
int main(void)
{
MATRIX a,b,c;
int i,j;

MulAbility=Dsp_RequestUniqueAbility();

for	(i=0;i<N;i++)
		for	(j=0;j<N;j++)
			{
				a[i][j]=  (float)(rand())/(RAND_MAX+1);
				b[i][j]=  (float)(rand())/(RAND_MAX+1);
			}

	showmat(a);
	showmat(b);

	if(mult(a,b,c)) 
		{
			printf("multiply failed\n");
			return 10;
		}
	
	showmat(c);
	return 0;	
}
