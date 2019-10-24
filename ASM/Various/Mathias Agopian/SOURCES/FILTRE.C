/************************************************/
/*												*/
/* Filtrage par FFT								*/
/*												*/
/************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <math.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>

#include "FFT_DSP.H"
#include "FALC_SPL.H"


char *sample_name="EXEMPLE.AVR";
int ability;
int ap_id;


int init_dsp(void);
void play(int *ptr_spl,FALCON_SPL *datas);
void filtre(int *ptr_spl,FALCON_SPL *datas,long fc);


int main(void)
{
	int  SOURCE;
	FALCON_SPL datas;
	int *ptr_spl;

	ap_id=appl_init();

	Dsp_Unlock();

	ability = init_dsp();
	if (ability)
	{
		SOURCE = open_sample(sample_name,&datas,0);
		if (SOURCE)
		{
			if ((datas.numVoices == 2) && (datas.numBits == 16 ))
			{
				ptr_spl=Malloc(datas.Length);
				if (ptr_spl>0)
				{
					
					datas.Length = Fread(SOURCE,datas.Length,ptr_spl);
					printf("\nLecture... (Appuyez sur une touche)");	play(ptr_spl,&datas);
					printf("\nFiltrage … Fc = Fe/4 ...");				filtre(ptr_spl,&datas,(datas.Frequence)/4);
					printf("\nLecture... (Appuyez sur une touche)");	play(ptr_spl,&datas);

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
			printf("\nFichier introuvable.");
		}
		Dsp_Reserve(0,0);
		Dsp_Unlock();
	}
	
	printf("\nAppuyez sur une touche");
	Bconin(2);
	
	appl_exit();
	
	return 0;
}


void play(int *ptr_spl,FALCON_SPL *datas)
{
	int prescale;
	prescale=(int)round((25175000.0/(256.0 * datas->Frequence))-1.0);
	buffoper(0);
	setmode(1);
	devconnect(0,8,0,prescale,1);
	soundcmd(4,2);
	setbuffer(0,ptr_spl,(char *)ptr_spl+datas->Length);
	buffoper(3);
	while(!kbhit());
	getch();
	buffoper(0);
}



/*
 * Calcul d'un filtre Passe Bas par
 * Transform‚e de fourrier
 */
 
void filtre(int *ptr_spl,FALCON_SPL *datas,long fc)
{
	static int Lsignal[1024];
	static int Rsignal[1024];
	static int Lspectre[1024*2];
	static int Rspectre[1024*2];
	long *lLspectre,*lRspectre;
	int *ptr_fin_signal,*ptr_signal;
	int i;
	int Ncut;
	long avance_ptr;
	
	lLspectre = (long *)Lspectre;
	lRspectre = (long *)Rspectre;
	Ncut = (fc * 1024) / (datas->Frequence);
	
	avance_ptr = 512 * 2;
	ptr_fin_signal = (int *) ((char *)ptr_spl + datas->Length);
	ptr_signal = ptr_spl;
	

	/* Recuperation de la voie droite et de la voie gauche */
	/* Les 1er 512 points (demi signal) ne sont pas pond‚r‚s */

	for (i=0;i<512;i++)
	{
		Lsignal[i] = ptr_signal[i<<1];
		Rsignal[i] = ptr_signal[(i<<1)+1];
		ptr_signal[i<<1] = 0;
		ptr_signal[(i<<1)+1] = 0;
	}

	/* les 512 suivants, sont pond‚r‚s par une fenetre */
	/* triangulaire	*/

	for (i=512;i<1024;i++)
	{
		Lsignal[i] = (int)(( (long)(ptr_signal[i<<1])		* (512-abs(i-512))  )/512) ;
		Rsignal[i] = (int)(( (long)(ptr_signal[(i<<1)+1])	* (512-abs(i-512))  )/512) ;
	}

	while (ptr_signal < (ptr_fin_signal - avance_ptr))
	{
		
		/* FFT voies droite et gauche */

		fft(Lsignal,Lspectre,ability);
		fft(Rsignal,Rspectre,ability);

		/*
		 * Calcul du Filtre dans le domaine fr‚quentiel
		 * C'est ici qu'a lieu tout le traitement:
		 * On peut definir quasiment n'importe quel
		 * gabarit pour le filtre.
		 * (passe bas, passe haut, passe bande, coupe bande, equaliseur, etc...)
		 */

		for (i=Ncut;i<=1024-Ncut;i++)			/* <= n'est pas une erreur */
		{
			lLspectre[i]=0L;
			lRspectre[i]=0L;
		}

		/* FFT inverse, pour reconstruire le signal */

		ffti(Lspectre,Lsignal,ability);
		ffti(Rspectre,Rsignal,ability);

		/* Le demi signal est ajout‚ au demi signal precedant */

		for (i=0;i<512;i++)
		{
			ptr_signal[i<<1] 		+= Lsignal[i];
			ptr_signal[(i<<1)+1]	+= Rsignal[i];
		}

		/* On passe aux 512 points suivants */

		ptr_signal += avance_ptr;

		/* Fenetrage des 512 points suivants */

		for (i=0;i<512;i++)
		{
			Lsignal[i] = (int)( ((long)(ptr_signal[i<<1])		* i ) / 512 );
			Rsignal[i] = (int)( ((long)(ptr_signal[(i<<1)+1])	* i ) / 512 );
		}

		/* Recopie les 512 points que l'on vient de calculer */

		for (i=0;i<512;i++)
		{
			ptr_signal[i<<1] 		= Lsignal[512+i];
			ptr_signal[(i<<1)+1]	= Rsignal[512+i];
		}

		/* Fenetrage des points 512 … 1024 */

		for (i=512;i<1024;i++)
		{
			Lsignal[i] = (int)( ((long)(ptr_signal[i<<1])		* (1024-i) ) / 512 );
			Rsignal[i] = (int)( ((long)(ptr_signal[(i<<1)+1])	* (1024-i) ) / 512 );
		}

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
