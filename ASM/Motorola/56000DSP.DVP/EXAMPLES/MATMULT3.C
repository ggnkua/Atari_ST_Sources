/* Devpac DSP example code MATMULT1.C */
/* for Lattice C                      */
/* (c) Copyright HiSoft 1993          */
/* All rights reserved                */

/* Note that this uses different data to the other C examples as
   the same input data that is used by the BASIC equivalent
   is embedded in the DSP program.
*/
#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>

#define N 4
#define DSP_CODE_FILE "MATMULT3.P56"
typedef char DSP_WORD[3];
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

int main(void)
{
DSP_WORD *dsp_prog;
FILE * fp;
long prog_size;
int abil;
MATRIX c;
long c1[N][N*2];
int i,j;

	if (Dsp_Lock())
		{
			printf("DSP already in use\n");
			return 10;
		}
	
	if (Dsp_Reserve(0x40+N*N,0x1000+N*N*3))
		{
			printf("Can't reserve enough DSP RAM\n");
			Dsp_Unlock();
			return 10;
		}

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

	abil=Dsp_RequestUniqueAbility();
	Dsp_ExecProg(dsp_prog,prog_size,abil);
	Dsp_BlkUnpacked(0,0,&(c1[0][0]),N*N*2);

	for	(i=0;i<N;i++)
		for	(j=0;j<N;j++)
			c[i][j]=c1[i][j*2]+(float)(c1[i][j*2+1])/0x800000;
	
	showmat(c);
	Dsp_Unlock();
	return	0;
}
