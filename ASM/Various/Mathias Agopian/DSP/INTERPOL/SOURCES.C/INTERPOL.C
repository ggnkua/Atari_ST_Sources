/* 
 * Programme d'exemple d'utilisation
 * de l'interpolation lin‚aire au DSP
 *
 * Exemple sur sin,cos,sqr.
 *
 * (c) 1994 AGOPIAN Mathias
 * pour STMAG
 *
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
char *file="INTERPOL.LOD";		/* nom du programme DSP */
char *adr;
int i;
long DspParBlk[3];

#define SIN 0;
#define COS 1;
#define SQR 2;

float dsp_sin(float x);
float dsp_cos(float x);
float dsp_sqr(float x);
extern long Ext24(long a);

int main(void)
{
	float a,b,c,x;
	adr=Malloc(4096);
	ability=Dsp_RequestUniqueAbility();
	status=Dsp_LoadProg(file,ability,adr);
	if (!status)
	{
		printf("\n\nComparaison SIN/DSP_SIN\n\n");
		for(i=0;i<360;i+=36)
		{
			x=i;
			a=sin((double)(x*2.0*M_PI)/360.0);
			b=dsp_sin(x);
			c=0;
			if (fabs(a)>0.00001)
				c=fabs(100.0*(a-b)/a);	/* calcul de l'erreur */
			printf("SIN(%f)=%f   DSP_SIN(%f)=%f   Erreur=%f %%\n",x,a,x,b,c);
		}
	
		printf("\n\nComparaison COS/DSP_COS\n\n");
		for(i=0;i<360;i+=36)
		{
			x=i;
			a=cos((double)(x*2.0*M_PI)/360.0);
			b=dsp_cos(x);
			c=0;
			if (fabs(a)>0.00001)
				c=fabs(100.0*(a-b)/a);	/* calcul de l'erreur */
			printf("COS(%f)=%f   DSP_COS(%f)=%f   Erreur=%f %%\n",x,a,x,b,c);
		}

		printf("\n\nComparaison SQRT/DSP_SQR\n\n");
		for(i=0;i<10;i++)
		{
			x=i/10.0;
			a=sqrt(x);
			b=dsp_sqr(x);
			c=0;
			if (fabs(a)>0.00001)
				c=fabs(100.0*(a-b)/a);	/* calcul de l'erreur */
			printf("SQRT(%f)=%f   DSP_SQR(%f)=%f   Erreur=%f %%\n",x,a,x,b,c);
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
 * float dsp_sin(float x)
 * x est exprim‚ en degr‚s (pas forc‚ment entiers)
 * ATTENTION: Ici les angles devraient etre POSITIFS,
 * En effet, lors de l'interpolation il faut prendre le
 * point connu PRECEDENT et non suivant, dans le cas de nombres
 * negatifs... R‚fl‚chissez y! 
 * La fonction retourne le sinus de x
 *
 */ 
float dsp_sin(float deg)
{
	long ret;
	long *ptr;
	float d;
	
	/*
	 * Conversion des degres en offset dans la table de sinus
	 * du DSP, contenue dans les ROM de celui-ci.
	 * Cette table contient un sinus complet sur 256 points.
	 */
	
	d=(deg*(256.0/360.0));
	
	/*
	 * Donn‚es pour le DSP
	 */
	 
	ptr=DspParBlk;
	*ptr++=SIN;								/* On veut un sinus          */
	*ptr++=trunc(d);						/* partie entiŠre de l'angle */
	*ptr++=(d-trunc(d))*0x1000000L;			/* partie decimale           */
	Dsp_BlkUnpacked(DspParBlk,3,&ret,1);	/* on envoie 3 donn‚es et on recois 1 resultat */
	ret=Ext24(ret);							/* le resultat est sur 24 bits, il faut l'‚tandre … 32 */
	return ((float)ret/0x800000L);			/* division par 2^23 pour obtenir la valeur cod‚e */
}											/* (codage en virgule fixe)	*/



/*
 * float dsp_cos(float x)
 * La procedure est identique … dsp_sinus(x)
 * Retourne le cosinus de x
 */
float dsp_cos(float deg)
{
	long ret;
	long *ptr;
	float d;
	d=(deg*(256.0/360.0));
	ptr=DspParBlk;
	*ptr++=COS;
	*ptr++=trunc(d);
	*ptr++=(d-trunc(d))*0x1000000L;
	Dsp_BlkUnpacked(DspParBlk,3,&ret,1);
	ret=Ext24(ret);
	return ((float)ret/0x800000L);
}

/*
 * float dsp_sqr(float x)
 * x est compris entre 0 et 1
 * La fonction retourne la racine carr‚e de x
 *
 */

float dsp_sqr(float x)
{
	long ret;
	long *ptr;
	float d;
	d=x*256.0;
	ptr=DspParBlk;
	*ptr++=SQR;
	*ptr++=trunc(d);
	*ptr++=(d-trunc(d))*0x1000000L;
	Dsp_BlkUnpacked(DspParBlk,3,&ret,1);
	ret=Ext24(ret);
	return ((float)ret/0x800000L);
}

