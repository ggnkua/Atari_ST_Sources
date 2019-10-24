#include <string.h>
#include <math.h>

#include <tos.h>
#include <ext.h>
#include <sndbind.h>
#include "DEF_VOX.H"
#include "DEFINES.H"
#include "HARD.H"

extern volatile int dsp_ready;
extern char app_path[256];

long DspParBlk[6];

/* Reglage des triggers de debut et de fin */
void set_trigger(int trigger,int quiet)
{
	DspParBlk[0]=1;
	DspParBlk[1]=(((long)trigger)<<8);
	DspParBlk[2]=(((long)quiet)<<8);
	Dsp_BlkUnpacked(DspParBlk,3,0,0);
}

/* nombre de points */
void set_nbp(int nbp)
{
	DspParBlk[0]=3;
	DspParBlk[1]=(nbp*3);
	Dsp_BlkUnpacked(DspParBlk,2,0,0);
	DspParBlk[0]=2;
	DspParBlk[1]=nbspl/(long)nbp;
	Dsp_BlkUnpacked(DspParBlk,2,0,0);
}
 
/* on entre dans la boucle principale dans le DSP */
void vox(void)
{
	dsp_ready=FALSE;
	Dsp_SetVectors(It_Ready,0);
	DspParBlk[0]=0;
	Dsp_BlkUnpacked(DspParBlk,1,0,0);
}

/* Annuler la commande vox(), retour au menu dans le DSP */
void stop_dsp(void)
{
	DspParBlk[0]=100;
	Dsp_BlkUnpacked(DspParBlk,1,0,0);
	Dsp_RemoveInterrupts(3);
	dsp_ready=FALSE;
}

/* Renvoie la derniere valeur digitalis‚e */
int get_seuil(void)
{
	long seuil;
	DspParBlk[0]=10;
	Dsp_BlkUnpacked(DspParBlk,1,&seuil,1);
	return (int)(seuil>>8);
}

/* recupere les 3 enveloppes calcul‚es par le DSP */
void get_samples(int nbp,int *ptr)
{
	Dsp_BlkWords(0,0,ptr,nbp*3);
	dsp_ready=FALSE;
}
 
/* Routine d'interruption, lorsque le DSP a fini son calcul */
void It_Ready(void)
{
	Dsp_RemoveInterrupts(3);
	dsp_ready=TRUE;
}


/********************************************
 * Initialise le systeme sonore (matrice) 	*
 ********************************************/
 
int init_snd(void)
{
	buffoper(0);
	dsptristate(1,1);
	devconnect(ADC,DSPRECV|DAC,M25_CLK,PRESCALE,1);
	soundcmd(ADDERIN,2);
	soundcmd(ADCINPUT,0);
	delay(500);
	locksnd();
	return 0;
}

/********************************************
 * Initialise le DSP					 	*
 ********************************************/

int init_dsp(void)
{
	static char *file="VOX.LOD";
	static char dspname[128];
	char *adr;
	int status;
	unsigned int ability;
	adr=Malloc(6000);
	if (!Dsp_Lock())
	{
		ability=Dsp_RequestUniqueAbility();
		strcpy(dspname,app_path);
		strcat(dspname,file);	
		status=Dsp_LoadProg(dspname,ability,adr);
		if (status)
			ability=0;
	}
	else
		ability=1;
		
	Mfree(adr);
	return ability;
}


/********************************************
 *	Algorithme de Bravais et Pearson        *
 *  (calcul‚ par le DSP)					*
 ********************************************/
 
double pearson(int *x,int *y,int n)
{
	double a;
	int e;
	dsptristate(0,0);
	DspParBlk[0]=4;
	DspParBlk[1]=0x800000L/(long)n;
	DspParBlk[2]=n;
	Dsp_BlkUnpacked(DspParBlk,3,0,0);
	Dsp_BlkWords(x,n,0,0);
	Dsp_BlkWords(y,n,0,0);
	Dsp_BlkUnpacked(0,0,DspParBlk,4);
	e=(int)(DspParBlk[2]-DspParBlk[3]);
	a=((float)DspParBlk[0]/DspParBlk[1])*pow(2,e);
	dsptristate(1,1);
	return a;
}

 /*******************************************
 * D‚sentrelacement des donn‚es             *
 *******************************************/
 
void copy_tab(int *s,int *d,int pas, int nb)
{
	register int i;
	for(i=0;i<nb;i++)
	{
		*d++=*s;
		s+=pas;
	}
}


 /*******************************************
 * Optimisation de l'amplitude              *
 *******************************************/

void optimise(int *ptr,int n)
{
	int *p;
	register int i;
	int max=0;
	double fact;
	
	for(p=ptr,i=0;i<n;i++,p++)
	{
		if ((*p)>max)
			max=*p;
	}
			
	if (max)
	{
		fact=32767.0/max;
		for(p=ptr,i=0;i<n;i++,p++)
			*p=(int)(((double)(*p))*fact);
	}	
}
