/* 
 * (c) 1994 AGOPIAN Mathias
 * pour STMAG
 *
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include <sndbind.h>
#include <aes.h>
#include <vdi.h>
#include <screen.h>
#include <ext.h>


/* Quelques d‚finitions */

#define	Npoints	100
#define FALSE	0
#define TRUE	~FALSE
#define Nmots	10


/* Les prototypes */

int init_dsp(void);
int init_snd(void);
void It_Ready(void);
void set_trigger(int trigger);
void set_nbp(int nbp);
void vox(void);
void get_samples(int nbp,int *ptr);
void copy_tab(int *s,int *d,int pas, int nb);
void optimise(int *ptr,int n);
void draw_env(int *ptr,int n,int l,int c);
void demo(void);
void apprentissage(int *nb);
int	reconnaissance(int nb);
double Cxy(int *x,int *y,int t,int n);

/* Le variables globales */

long DspParBlk[2];
int samples[Npoints*3];
int env[3][Npoints];
int max[Nmots][3][Npoints];
int min[Nmots][3][Npoints];
int moy[Nmots][3][Npoints];
char mots_ptr[Nmots][16];

char *file="VOX.LOD";			/* nom du programme DSP */
int i;
int pxy[4];
int handle;
int dummy;
volatile int dsp_ready;


/* C'est la que toute l'histoire a commanc‚e... */

int main(void)
{
	unsigned int ability;
	
	/*
	 * Le DSP est il pret ?
	 */
	 
	ability=init_dsp();
	if (ability)
	{
		Clear_home();
		handle=graf_handle(&dummy,&dummy,&dummy,&dummy);		
		for(i=0;i<=(Npoints*3-1);samples[i++]=0);
		while(kbhit()) getch();

		/*
		 * Initialisation du systŠme sonore (matrice)
		 */
		 
		init_snd();

		/*
		 * Seuil … partir duquel le DSP considŠre
		 * qu'un signal coh‚rent est pr‚sent (0 … 32767)
		 */
		 
		set_trigger(5000);
		
		/*
		 * Nombre de points pour l'analyse
		 */
		 
		set_nbp(Npoints);

		/*
		 * Petite demo
		 */
		 
		demo();

		/*
		 * On quitte
		 */
		 
		Dsp_RemoveInterrupts(3);
		Dsp_Unlock();
	}
	return 0;
}


void demo(void)
{
	int Nmots_appris;
	int choix;
	apprentissage(&Nmots_appris);
	do
	{
		choix=reconnaissance(Nmots_appris);
		Clear_home();
		if(choix<Nmots_appris)
			printf("\nLe mot est '%s'",mots_ptr[choix]);
		else
			printf("\nJe ne connais pas ce mot!");
	}while(!kbhit());
	getch();
}

void apprentissage(int *nb)
{
	int i,j;
	char c;
	*nb=0;

	do
	{
		Clear_home();
		printf("\nQuel est le mot … apprendre : ");
		scanf("%s",mots_ptr[*nb]);
		printf("\nPrononcez distinctement '%s' \n",mots_ptr[*nb]);
		
		for (i=0;i<Npoints;i++)
		{
			for (j=0;j<3;j++)
			{
				max[*nb][j][i]=0;
				min[*nb][j][i]=32767;
				moy[*nb][j][i]=0;
			}
		}
		
		for(i=0;i<4;i++)
		{
			printf("\r(%d sur 4) Allez y : ",i+1);
			vox();
			while(!dsp_ready);
			get_samples(Npoints,samples);
			copy_tab(samples  ,env[0],3,Npoints);
			copy_tab(samples+1,env[1],3,Npoints);
			copy_tab(samples+2,env[2],3,Npoints);
			optimise(env[0],Npoints);
			optimise(env[1],Npoints);
			optimise(env[2],Npoints);
			for (j=0;j<Npoints;j++)
			{
				if (max[*nb][0][j]<env[0][j]) max[*nb][0][j]=env[0][j];
				if (max[*nb][1][j]<env[1][j]) max[*nb][1][j]=env[1][j];
				if (max[*nb][2][j]<env[2][j]) max[*nb][2][j]=env[2][j];
				if (min[*nb][0][j]>env[0][j]) min[*nb][0][j]=env[0][j];
				if (min[*nb][1][j]>env[1][j]) min[*nb][1][j]=env[1][j];
				if (min[*nb][2][j]>env[2][j]) min[*nb][2][j]=env[2][j];
				moy[*nb][0][j]+=env[0][j]/4;
				moy[*nb][1][j]+=env[1][j]/4;
				moy[*nb][2][j]+=env[2][j]/4;
			}
			
		}

		for(j=0;j<3;j++)
		{
			draw_env(max[*nb][j],Npoints,200+j*100,RED);
			draw_env(min[*nb][j],Npoints,200+j*100,BLUE);
		}
			
		(*nb)++;
		printf("\nUn autre mot ? (O/N)");
		c=getch();
	}while((c|0x20)=='o');
}

int	reconnaissance(int nb)
{
	int i,j,k,hit;
	double erreur,errmot=0.70;
	
	hit=nb+1;
	printf("\nDites quelque chose :");
	printf("\nPour sortir appuyez sur une touche et dites n'importe quoi!");
	vox();
	while((!dsp_ready));
	get_samples(Npoints,samples);
	copy_tab(samples  ,env[0],3,Npoints);
	copy_tab(samples+1,env[1],3,Npoints);
	copy_tab(samples+2,env[2],3,Npoints);
	optimise(env[0],Npoints);
	optimise(env[1],Npoints);
	optimise(env[2],Npoints);
	for(i=0;i<nb;i++)
	{
		erreur=0;
		for(j=0;j<3;j++)
		{
			for(k=0;k<Npoints-1;k++)
				erreur=erreur+(float)abs(env[j][k]-moy[i][j][k])/(max[i][j][k]-min[i][j][k]);
		}

		erreur=erreur/(3*Npoints);
		if (erreur<errmot)
		{
			errmot=erreur;
			hit=i;
		}
	}
	return hit;
}


/********************************************
 * D‚sentrelacement des donn‚es             *
 ********************************************/
 
void copy_tab(int *s,int *d,int pas, int nb)
{
	int i;
	for(i=0;i<nb;i++)
	{
		*d++=*s;
		s+=pas;
	}
}


/********************************************
 * Optimisation de l'amplitude              *
 ********************************************/

void optimise(int *ptr,int n)
{
	int *p;
	int i;
	int max=0;
	double fact;

	/*
	 * Recherche de la plus grande amplitude
	 */
	 
	for(p=ptr,i=0;i<n;i++)
	{
		if ((*p)>max)	max=*p;
		p++;
	}
	
	/* Si tous les samples ne sont pas nuls */
	if (max)
	{
		/* le multiplier par le coefficient 'fact'*/
		fact=32767/max;
		for(p=ptr,i=0;i<n;i++)
		{
			*p=(int)(((double)(*p))*fact);
			p++;
		}
	}	
}


/********************************************
 * Dessin des enveloppes					*
 ********************************************/
 
void draw_env(int *ptr,int n,int l,int c)
{
	int i,x,y;
	static int pxy[4];
	vsl_color(handle,c);
	pxy[2]=0;
	pxy[3]=l;
	for(x=0,i=0;i<n-1;i++)
	{
		y=*ptr++;
		pxy[0]=pxy[2]; pxy[2]=x++;
		pxy[1]=pxy[3]; pxy[3]=l-y/300;
		v_pline(handle,2,pxy);
	}
}		

/********************************************
 * Routines d'interfacage avec le DSP		*
 ********************************************/

/*
 * Parametrage du seuil d'audition
 */
 
void set_trigger(int trigger)
{
	DspParBlk[0]=1;
	DspParBlk[1]=(((long)trigger)<<8);
	Dsp_BlkUnpacked(DspParBlk,2,0,0);
}


/*
 * Du nombre de samples pour l'analyse
 */
 
void set_nbp(int nbp)
{
	DspParBlk[0]=3;
	DspParBlk[1]=(nbp*3);
	Dsp_BlkUnpacked(DspParBlk,2,0,0);
	DspParBlk[0]=2;
	DspParBlk[1]=65536L/(long)nbp;
	Dsp_BlkUnpacked(DspParBlk,2,0,0);
}


/*
 * Lance le DSP...
 */
 
void vox()
{
	dsp_ready=FALSE;
	Dsp_SetVectors(It_Ready,0);
	DspParBlk[0]=0;
	Dsp_BlkUnpacked(DspParBlk,1,0,0);
}


/*
 * Recupere le resultat
 */
 
void get_samples(int nbp,int *ptr)
{
	Dsp_BlkWords(0,0,ptr,nbp*3);
	dsp_ready=FALSE;
}


/*
 * Routine d'interruption, positionne
 * un flag quand le DSP … termin‚
 */
 
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
	devconnect(ADC,DSPRECV|DAC,M25_CLK,CLK33K,1);
	soundcmd(ADDERIN,2);
	soundcmd(ADCINPUT,0);
	delay(500);
	return 0;
}

/********************************************
 * Initialise le DSP					 	*
 ********************************************/

int init_dsp(void)
{
	char *adr;
	int status;
	unsigned int ability;

	/*
	 * On r‚serve de la m‚moire
	 * Le buffer doit etre assez grand pour contenir le
	 * programme DSP en mot DSP (24 bits).
	 */
	 
	 adr=Malloc(4096);
	 
	/*
	 * On demande une ability 
	 */
	 		
	ability=Dsp_RequestUniqueAbility();
	 
	/*
	 * Le DSP est il libre ?
	 */

	if (!Dsp_Lock())
	{
		status=Dsp_LoadProg(file,ability,adr);
		if (status)
		{
			ability=0;
			printf("Fichier %s introuvable.\n",file);
			printf("Appuyez sur une touche\n");
			Bconin(2);
		}
	}
	else
	{
		ability=0;
		printf("Le DSP est occup‚\n");
		printf("Appuyez sur une touche\n");
		Bconin(2);
	}
			
	Mfree(adr);
	
	return ability;
}
