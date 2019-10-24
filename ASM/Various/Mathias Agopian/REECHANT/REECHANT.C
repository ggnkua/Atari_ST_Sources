/*
 * (c) Mathias Agopian
 */
 
#include <stdio.h>
#include <math.h>
#include <tos.h>
#include <ext.h>
#include <ctype.h>

#include "FALC_SPL.H"

#define NTAPS 63

int init_dsp(void);
void CalcFirCoefs(long fe,long fc,int ntaps,int ability);
void DoFir(void *in,void *out,long nspl);

long DspParBlk[NTAPS];
int FIRability;
char *FIRname = "REECHANT.LOD";
char scratch[4096];

int main(int argc,char *argv[])
{
	int  SOURCE,DEST;
	char name[256];
	FALCON_SPL datas;
	long *ptr_spl;
	long *ptr_dst;
	long i;
	long fe;
	DTA dta;
	int ntaps;
	char c;


	Dsp_Unlock();

	Fsetdta(&dta);

	if (argc<2)
	{
		printf("\nGlissez un ficher AVR sur mon icone!");
		Bconin(2);
		return 0;
	}


	ntaps = NTAPS;
	FIRability = init_dsp();
	if (FIRability)
	{	
		SOURCE = open_sample(argv[1],&datas,0);
		if (SOURCE)
		{
			if ((datas.numVoices == 2) && (datas.numBits == 16 ))
			{
				ptr_spl=Malloc(datas.Length);
				if (ptr_spl>0)
				{
					
					datas.Length = Fread(SOURCE,datas.Length,ptr_spl);
					fe = datas.Frequence;

					printf("\nFr‚quence d'‚chantillonnage : %lu Hz",fe);
					printf("\n[D]iviser par deux");
					printf("\n[M]multiplier par deux");
					printf("\n[Q]uitter");
					printf("\nVotre choix : ");
					do
					{
						while(!kbhit());
						c=getche();
						c=toupper(c);
					}while((c!='Q') && (c!='M') && (c!='D'));
					
					if (c!='Q')
					{
						if (c=='D')
						{
							ptr_dst = ptr_spl;
							/* on coupe … Fe/5 a cause des lobes secondaires */
							CalcFirCoefs(fe,fe/5,ntaps,FIRability);
							DoFir(ptr_dst,ptr_dst,datas.Length/4);

							/*
							 * Reechantillonnage:
							 * On garde un echantillon sur deux
							 */
							 
							for (i=0;i<datas.Length/8;i++)
							{
								ptr_dst[i] = ptr_spl[i*2];
							}
							
							datas.Length /= 2;
						}
						else
						{
							ptr_dst = Malloc(datas.Length*2);
							if (ptr_dst)
							{
								/*
								 * Reechantillonnage:
								 * On ajoute un zero entre chaque echantillon
								 */
				 
								for(i=0;i<datas.Length/4;i++)
								{
									ptr_dst[i*2] = ptr_spl[i];
									ptr_dst[i*2+1] = 0L;
								}

								datas.Length *= 2;
								/* on coupe … Fe/5 a cause des lobes secondaires */
								CalcFirCoefs(fe,fe/5,ntaps,FIRability);
								DoFir(ptr_dst,ptr_dst,datas.Length/4);								

								Mfree(ptr_dst);
							}
						}

						if (ptr_dst)
						{
							/* sauvegarde */

							printf("\nSauvegarde brute (SPL)");
							printf("\nNom du Fichier de sauvegarde: ");
							scanf("%s",name);
							
							DEST = (int)Fcreate(name,0);
							if (DEST)
							{
								Fwrite(DEST,datas.Length,ptr_dst);
								Fclose(DEST);
							}
						}
						else
						{
							printf("\nPas assez de m‚moire");
						}
					}
					Mfree(ptr_spl);
				}
				else
				{
					printf("\nPas assez de m‚moire");
				}
			}
			else
			{
				printf("\nSeulement 16 bits st‚r‚o");
			}
			Fclose(SOURCE);
		}
		else
		{
			printf("\nFichier %s introuvable.",argv[1]);
		}

		Dsp_Reserve(0,0);
		Dsp_Unlock();
	}

	printf("\nAppuyez sur une touche");
	Bconin(2);
	
	return 0;
}

void CalcFirCoefs(long fe,long fc,int ntaps,int ability)
{
	int k,i,n;
	int error;
	double f0;
	double c;
	double alpha;

	error = Dsp_LoadProg(FIRname,ability,scratch);
	if (!error)
	{	
		f0 = (double)fc/(double)fe;
				
		for (i=0,n=1,k=-(ntaps-1)/2 ; k<=(ntaps-1)/2 ; k++,n++)
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
	
			/* Fenetre de Blackman */

			c = c * (	  0.42
						- 0.50 * cos((2.0 * M_PI * n) / (ntaps+1))
						+ 0.08 * cos((4.0 * M_PI * n) / (ntaps+1)));

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
