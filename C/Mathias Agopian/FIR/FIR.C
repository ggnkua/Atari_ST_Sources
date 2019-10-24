/*
 * (c) Mathias Agopian
 */
 
#include <stdio.h>
#include <math.h>
#include <tos.h>

#define NTAPS 63

int init_dsp(void);
void CalcFirCoefs(long fe,long fc,int ntaps,int ability);

long DspParBlk[NTAPS];
int FIRability;
char *FIRname = "FIR.LOD";
char scratch[4096];

int main(void)
{
	long fe,fc;
	int ntaps;

	ntaps = NTAPS;
	fe = 49170L;

	FIRability = init_dsp();
	if (FIRability)
	{
		dsptristate(1,1);
		devconnect(3,2,0,1,1);
		devconnect(1,8,0,1,1);
		soundcmd(4,2);
		soundcmd(5,0);

		printf("\nFiltre FIR du 63eme ordre");
		printf("\n-------------------------\n\n");

		do
		{
			printf("Fr‚quence de coupure (Hz) - 0 pour sortir - : ");
			scanf("%lu",&fc);
			if (fc)
			{
				CalcFirCoefs(fe,fc,ntaps,FIRability);
			}
		}while(fc);

		Dsp_Reserve(0,0);
		Dsp_Unlock();
	}
	else
	{
		printf("\nAppuyez sur une touche");
		Bconin(2);
	}
	
	return 0;
}

void CalcFirCoefs(long fe,long fc,int ntaps,int ability)
{
	int k,i;
	int error;
	double f0;
	double c;
	double alpha;

	error = 0;
	if (Dsp_GetProgAbility() != ability)
	{
		error = Dsp_LoadProg(FIRname,ability,scratch);
	}

	if (!error)
	{	
		f0 = (double)fc/(double)fe;
				
		for (i=0,k=-(ntaps-1)/2 ; k<=(ntaps-1)/2 ; k++)
		{
			if (k)
			{
				alpha = 2.0 * M_PI * k * f0;		
				c = 2.0 * f0 * sin(alpha)/alpha;
			}
			else
			{
				c = 2.0 * f0;
			}
	
			DspParBlk[i++] = trunc(c * 0x7FFFFFL);
		}
			
		Dsp_BlkUnpacked(DspParBlk,2,0L,0L);
		Dsp_BlkUnpacked(DspParBlk+2,NTAPS-2,0L,0L);
	}
	else
	{
		printf("\nFichier %s instrouvable",FIRname);
	}
}

int init_dsp(void)
{
	int ability;
	long xmem,ymem;

	/*
	 * Demander le DSP et r‚server sa m‚moire
	 */
	 
	if (!Dsp_Lock())
	{
		ability = Dsp_RequestUniqueAbility();
		Dsp_Available(&xmem,&ymem);
		Dsp_Reserve(xmem,ymem);
	}
	else
	{
		ability = 0;
		printf("\nLe DSP est d‚ja en service");
	}
	return ability;
}
