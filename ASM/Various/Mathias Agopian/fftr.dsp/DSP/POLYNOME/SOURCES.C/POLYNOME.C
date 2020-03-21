/* 
 * Programme d'exemple de calcul de f(x)
 * par approximation au DSP
 *
 * Exemple pour exp(x) et sin(x)
 *
 * (c) 1994 AGOPIAN Mathias
 * pour STMAG
 *
 */
 
/*
 * Remarquez la tres bonne pr‚cision de ce type
 * de calcul...
 */

/*
 * Remarque: Le programme peut etre tres
 * largement optimise (surtout lors de l'appel
 * des fonctions DSP), mais ce n'‚tait pas le but
 * ici.
 * En faisant des appels direct au DSP, on peut
 * aller bien plus vite que le 68882!
 *
 */

/*
 * Ce programme NE contient PAS toute la s‚quence
 * de chargement d'un programme dans le DSP.
 * Voyez les articles du mois dernier
 * ou bien le listing m24x24.c
 *
 */ 
 
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include <math.h>

unsigned int ability;
unsigned int handle;
unsigned int status;
long size;
char *file="POLYNOME.LOD";		/* nom du programme DSP */
char *adr;
int i;
long DspParBlk[3];
long res[3];

#define EXP 0;
#define SIN 1;

float dsp_exp(float x);
float dsp_sin(float x);

int main(void)
{
	float a,b,c,x;
	adr=Malloc(4096);
	ability=Dsp_RequestUniqueAbility();
	status=Dsp_LoadProg(file,ability,adr);
	if (!status)
	{
		printf("\n\nComparaison exp/DSP_EXP\n\n");
		for(i=-25;i<25;i++)
		{
			x=i/25.0;
			a=exp(x);
			b=dsp_exp(x);
			c=fabs(100.0*(a-b)/a);	/* calcul de l'erreur */
			printf("exp(%f)=%f   DSP_EXP(%f)=%f   Erreur=%f %%\n",x,a,x,b,c);
		}

		printf("\n\nComparaison sin/DSP_SIN\n\n");
		for(i=0;i<57;i++)
		{
			x=(i*2*M_PI)/360.0;
			a=sin(x);
			b=dsp_sin(x);
			c=fabs(100.0*(a-b)/a);	/* calcul de l'erreur */
			printf("sin(%f)=%f   DSP_SIN(%f)=%f   Erreur=%f %%\n",x,a,x,b,c);
		}
	}
	else
		printf("Fichier %s introuvable.\n",file);
		
	printf("Appuyez sur une touche\n");
	Bconin(2);
	Mfree(adr);
	return 0;
}


/*
 * float dsp_exp(float x)
 * x est compris entre -1 et 1
 * La fonction retourne l'exponentielle de x
 */

float dsp_exp(float x)
{
	/* Adresse de parametres */
	long *ptr=DspParBlk;
	
	/* Fonctions exp */
	*ptr++=EXP;
	
	/* Convertir x en virgule fixe */
	*ptr++=x*0x800000L;
	
	/* envoie au DSP */
	Dsp_BlkUnpacked(DspParBlk,2,res,2);
	
	/* Conversion du resultat en flotant
	 * Le resultat est de la forme:
	 *
	 * eeeeeeee.eddddddd
	 *  res[0] = eeeeeeee
	 *  res[1] = eddddddd
	 *
	 * avec eee... : Partie entiere
	 *      ddd... : Partie decimale
	 */
	return (float)((res[0]<<1)+(((float)res[1])/0x800000L));
}


/*
 * Dsp_sin(x)
 * Calcul de sinus x par approximation par polynome
 * ici il faut -1<x<1 ( ie: -54<x<54 degres )
 * x est exprim‚ en radians.
 */
 
float dsp_sin(float x)
{
	long *ptr=DspParBlk;
	*ptr++=SIN;
	*ptr++=x*0x800000L;
	Dsp_BlkUnpacked(DspParBlk,2,res,1);
	return ((float)res[0])/0x800000L;
}
