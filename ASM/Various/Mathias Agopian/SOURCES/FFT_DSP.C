#include <tos.h>

char *fft2rcn = "MAIN.LOD";
char scratch[4096];

/************************************************/
/*												*/
/* Calcul de la FFT inverse	d'un spectre 		*/
/* complexe sur 1024 points.					*/
/*												*/
/*	int spectre[2048]	(complexe)				*/
/*	int signal[1024]	(reel)					*/
/*												*/
/************************************************/

int ffti(int *spectre,int *signal,int ability)
{
	static long sig[1024];
	int i,error;
	long temp;
	long RItemp;
	long *sp1,*sp2;
	

	error = 0;
	if (Dsp_GetProgAbility() != ability)
	{
		error = Dsp_LoadProg(fft2rcn,ability,scratch);
	}

	if (!error)
	{
		/*
		 * Comme on utilise le meme algorithme pour la FFT et la FFT inverse
		 * il faut calculer FFT { X(-n) } qui est ‚gal …  FFT inverse { x(n) }.
		 * Il convient donc d'inverser le spectre autour de X(0).
		 */
		sp1=(long *)spectre;
		sp2=sp1+1024;
		sp1++;
		while (sp1<sp2)
		{
			RItemp = *sp1;
			*sp1++ = *--sp2;
			*sp2 = RItemp;
	 	}

		temp = 0x7F0000L;
		Dsp_BlkUnpacked(&temp,1L,0L,0L);
		Dsp_BlkWords(spectre,2048L,sig,2048L);
		
		/*
		 * Conversion en reel
		 */

		for (i=0;i<1024;i++)
		{
			temp = sig[i] >> 16;		/* elimine la partie imaginaire */
			signal[i] = (int)temp;
		}
	}
	return error;
}


/************************************************/
/*												*/
/* Calcul de la FFT d'un signal reel	 		*/
/* sur 1024 points.								*/
/*												*/
/*	int spectre[2048]							*/
/*	int signal[1024]							*/
/*												*/
/************************************************/

int fft(int *signal,int *spectre,int ability)
{
	static long sig[1024];
	int error;
	long fact;
	int i;
	int temp;

	/*
	 * Si notre programme n'est pas dans le DSP
	 * Alors, on le charge
	 */
	 
	error = 0;
	if (Dsp_GetProgAbility() != ability)
	{
		error = Dsp_LoadProg(fft2rcn,ability,scratch);
	}

	if (!error)
	{
		/*
		 * La FFT est effectu‚e sur un vecteur complexe
		 * Le signal est donc converti en complexe (partie imaginaire nulle
		 */
		
		for (i=0;i<1024;i++)
		{
			temp = signal[i] >> 2;			/* Evite les OVERFLOWS dans le DSP */
			sig[i] = (long)(temp) << 16;	/* ajoute la partie imaginaire */
		}
		
		/*
		 * Envoi du signal au DSP et calcul
		 */
		 
		fact = 0x7FFFL;
		Dsp_BlkUnpacked(&fact,1L,0L,0L);
		Dsp_BlkWords(sig,2048L,spectre,2048L);
	}
	return error;
}
