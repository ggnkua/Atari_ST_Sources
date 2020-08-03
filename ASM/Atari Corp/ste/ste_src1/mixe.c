/************************************************************************/
/*                                                                      */
/*            CREATE BY ATARI FRANCE  									*/
/*				PROGRAMMED BY THIERRY SAUVAGEOT                         */
/*                 FOR DEVELOPERS                                       */
/*                 THIS IS A SAMPLE DEMONSTRATION IN MONO MODE          */
/*                                                                      */
/*                 THIS PROGRAMMING IN TURBO C                          */
/*                 ATTENTION AT THE STRUCTURE ASSIGNMENT                */

/************************************************************************/

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <linea.h>

/* D‚finition des macros d'accŠs au registres sonores
*/
#define SNDCONTROL *(char *)(0xFFFF8901)
#define SNDHIGBASE *(char *)(0xFFFF8903)
#define SNDMEDBASE *(char *)(0xFFFF8905)
#define SNDLOWBASE *(char *)(0xFFFF8907)
#define SNDHIGCNT  *(char *)(0xFFFF8909)
#define SNDMEDCNT  *(char *)(0xFFFF890B)
#define SNDLOWCNT  *(char *)(0xFFFF890D)
#define SNDHIGEND  *(char *)(0xFFFF890F)
#define SNDMEDEND  *(char *)(0xFFFF8911)
#define SNDLOWEND  *(char *)(0xFFFF8913)
#define SNDMODE    *(char *)(0xFFFF8921)
#define MWDATA	   *(int *)(0xFFFF8922)
#define MWMASK     *(int *)(0xFFFF8924)

/* D‚finition des commandes de control du Volume/Tone Controler
*/
#define VTCMASK 0x07FF

#define MASTER80 0xC0
#define MASTER40 0xD4
#define MASTER00 0xE8

#define LEFT40 0x140
#define LEFT20 0x14A
#define LEFT00 0x154

#define RIGHT40 0x100
#define RIGHT20 0x10A
#define RIGHT00 0x114

#define TREBBLEM12 0x80
#define TREBBLE00  0x86
#define TREBBLEP12 0x8C

#define BASSM12 0x40
#define BASS00  0x46
#define BASSP12 0x4C

#define MIXM12  0x00
#define MIXGI   0x01
#define NOMIXGI 0x02

/* D‚finition d'un type qui va nous faciliter la vie
*/
/*typedef union {
	char c[4];
	long l;
	void *p;
} longchar;
*/

/* Macros de position souris en relatif … la 
   base line A. Il faut avoir initialiser LineAbase
*/
#define XMOUSE ((unsigned short *)Linea)[-301]
#define YMOUSE ((unsigned short *)Linea)[-300]

/* Video Address Pointer (READ AND WRITE)
*/
#define HIGPTR *(char *)(0xFFFF8201)
#define MEDPTR *(char *)(0xFFFF8203)
#define LOWPTR *(char *)(0xFFFF820D)

/* Video address counter (READ AND WRITE)
*/
#define HIGCNT *(char *)(0xFFFF8205)
#define MEDCNT *(char *)(0xFFFF8207)
#define LOWCNT *(char *)(0xFFFF8209)

/* Offset to next line 
*/
#define LINESTRIDE *(char *)(0xFFFF820F)

/* Color Palette
*/
#define COLOR(a) *(unsigned int *)(0xFFFF8240+2*(a))

/* Horizontal bit-wise scroll
*/
#define HSHIFT *(char *)(0xFFFF8265)

typedef union {
	unsigned long l;		
	unsigned char c[4];
	void *p;
} longchar;


/* On d‚finit quelques type pour l'‚cran
*/

/* double ligne couleur */
typedef struct {
	unsigned int word[160];
} LINE2;

/* simple ligne couleur */
typedef struct {
	unsigned int word[80];
} LINE1;

/* simple ‚cran couleur */
typedef struct { 
	LINE1 line[200];
} SCREEN1;

/* double ‚cran couleur */
typedef struct {
	LINE2 line[200];
} SCREEN2;

/* -------------------------------------------------------- */

/* Ecriture de l'adresse de d‚but du son
*/
void SetSndBase(void *p)
{	long OldSSP=Super(NULL);
	longchar t;
	t.p=p;
	SNDHIGBASE=t.c[1];
	SNDMEDBASE=t.c[2];
	SNDLOWBASE=t.c[3];
	Super((void *)OldSSP);
}

/* Lecture de l'adresse de d‚but du son
*/
void *GetSndBase(void)
{	long OldSSP=Super(NULL);
	longchar t;
	t.l=0;
	t.c[1]=SNDHIGBASE;
	t.c[2]=SNDMEDBASE;
	t.c[3]=SNDLOWBASE;
	Super((void *)OldSSP);
	return t.p;
}

/* Lecture du compteur de trames. Ce registre est READ ONLY
   indique … quelle trame se trouve la g‚n‚ration de son
*/
void *GetSndCnt(void)
{	long OldSSP=Super(NULL);
	longchar t;
	t.l=0;
	t.c[1]=SNDHIGCNT;
	t.c[2]=SNDMEDCNT;
	t.c[3]=SNDLOWCNT;
	Super((void *)OldSSP);
	return t.p;
}

/* Ecriture de l'adresse de fin du son
*/
void SetSndEnd(void *p)
{	long OldSSP=Super(NULL);
	longchar t;
	t.p=p;
	SNDHIGEND=t.c[1];
	SNDMEDEND=t.c[2];
	SNDLOWEND=t.c[3];
	Super((void *)OldSSP);
}

/* Lecture de l'adresse de fin du son
*/
void *GetSndEnd(void)
{	long OldSSP=Super(NULL);
	longchar t;
	t.l=0;
	t.c[1]=SNDHIGEND;
	t.c[2]=SNDMEDEND;
	t.c[3]=SNDLOWEND;
	Super((void *)OldSSP);
	return t.p;
}

/* Ecriture du mode DMA
	00 : DMA non activ‚. C'est le mode standard
	01 : DMA actif. Le son n'est jou‚ qu'une fois
	10 : r‚serv‚ (‡a veut dire non document‚)
	11 : DMA actif. Le son est jou‚ en mode repeat
*/
void SetSndDMA(int mode)
{	long OldSSP=Super(NULL);
	SNDCONTROL=mode;
	Super((void *)OldSSP);
}

/* Lecture du mode DMA
	voir SetSndDMA()
*/
int GetSndDMA(void)
{	long OldSSP=Super(NULL);
	int mode=SNDCONTROL;
	Super((void *)OldSSP);
	return mode;
}

/* Ecriture du mode de fonctionnement
	mode = m00000rr
	m    : 	0 -> st‚r‚ophonique
	   	1 -> monophonique
	rr   : 00 ->  6258 Hz
	       01 -> 12517 Hz 
	       10 -> 25033 Hz
	       11 -> 50066 Hz
*/
void SetSndMode(int mode)
{	long OldSSP=Super(NULL);
	SNDMODE=mode;
	Super((void *)OldSSP);
}

/* Lecture du mode de fonctionnement
	voir SetndMode();
*/
int GetSndMode(void)
{	long OldSSP=Super(NULL);
	int mode=SNDMODE;
	Super((void *)OldSSP);
	return mode;
}

/* Ecriture de commandes Volume/Tone controler
   les 11 bits de poid faible sont utilis‚s
*/  
void SetVTC(int data)
{	MWMASK=0x07FF;
	while (MWMASK!=0x07FF);
	MWDATA=data;
}

void Init(void)
{	long OldSSP=Super(NULL);
	SetVTC(MASTER40);	/* MASTER VOLUME … -40dB */
	SetVTC(BASSM12);	/* BASS +12 dB		 */
	SetVTC(TREBBLE00);	/* TEBBLE +12 dB	 */
	SetVTC(MIXGI);		/* Mix avec le GI du ST  */
	Super((void *)OldSSP);
}

/* IMAGE */

/* Initialisation de l'adresse vid‚o
*/
void SetScreenPtr(void *ad)
{	longchar t;
	long OldSSP=Super(NULL);

	t.p=ad;
	HIGPTR=t.c[1];
	MEDPTR=t.c[2];
	LOWPTR=t.c[3];
	Super((void *)OldSSP);
}

/* Lecture de l'adresse vid‚o
*/
void *GetScreenPtr(void)
{	longchar t;
	long OldSSP=Super(NULL);

	t.l=0;
	t.c[1]=HIGPTR;
	t.c[2]=MEDPTR;
	t.c[3]=LOWPTR;
	
	Super((void *)OldSSP);
	return t.p;
} 

/* Initialisation du registre de d‚calage horizontal
*/
void SetScroll(unsigned int n)
{	long OldSSP=Super(NULL);
	HSHIFT=n&15;
	Super((void *)OldSSP);
} 

/* Lecture du registre de scrolling 
*/
unsigned int GetScroll(void)
{	long OldSSP=Super(NULL);
	int v=HSHIFT&15;
	Super((void *)OldSSP);
	return v;
} 

/* Ecriture de la largeur de ligne
*/
void SetLineStride(unsigned int n)
{	long OldSSP=Super(NULL);
	LINESTRIDE = n;
	Super((void *)OldSSP);
} 

/* Lecture de la largeur de ligne
*/
unsigned int GetLineStride(void)
{	long OldSSP=Super(NULL);
	int n=LINESTRIDE;
	Super((void *)OldSSP);
	return n;
} 


int X,Y;
SCREEN2 picbuf[2];
SCREEN1 imabuf;
int NewPalette[16],OldPalette[16];
int OldRes;

/* Installation de la palette et sauvegarde de l'ancienne
*/
void InsPalette(void)
{	int *New=NewPalette,*Old=OldPalette,*Hard=(int *)(0xFFFF8240);
	int n=16;
	long OldSSP=Super(NULL);
	
	while (n--) 
	{	*Old++=*Hard;
		*Hard++=*New++;
	}
	
	OldRes=*(char *)(0xFFFF8260);
	*(char *)(0xFFFF8260)=0;
	Super((void *)OldSSP);
}

/* Restitution de l'ancienne palette
*/
void RestPalette(void)
{	int *Old=OldPalette,*Hard=(int *)(0xFFFF8240);
	int n=16;
	long OldSSP=Super(NULL);
	
	while (n--) *Hard++=*Old++;
	*(char *)(0xFFFF8260)=OldRes;
	
	Super((void *)OldSSP);
}

void **SavVbl=NULL;

/* Installation d'une routine en VBL
*/
int InsVBL(void (*f)())
{	long OldSSP=Super(NULL);
	int nbvbl=*(int *)(0x454);
	void **list=*(void **)(0x456);
	
	while (nbvbl--) 
	{	if (*list++==NULL) 
		{	*--list=f;
			SavVbl=list;
			break;
		}
	}
	Super((void *)OldSSP);
	return (nbvbl==0?-1:0);
}

/* Suppression de la routine pr‚c‚demment install‚e
*/
void RmvVBL(void)
{	long OldSSP=Super(NULL);
	*SavVbl=NULL;
	Super((void *)OldSSP);
}

/* Routine de scrolling sous VBL
 	Prend la position de la souris et la transforme
 	en une adresse dans les images
 */
void Scrolling(void)
{	long X=XMOUSE,
	     Y=YMOUSE;
	longchar t;
	
	HSHIFT=X&15;
	LINESTRIDE=(X&15?76:80); 
	t.p=&picbuf[0].line[Y].word[((X>>1)&0xFFF8)>>1];
	HIGCNT=t.c[1];
	MEDCNT=t.c[2];
	LOWCNT=t.c[3];
}

void pause(void)
{
	long i;
	for(i=0;i<500000;i++);
}

/* effect mirroir */
void miroir(void)
{
long i,j;
		for(i=0,j=199;i<200;i++,j--)
		{
			LINE1 *p0=(LINE1 *)&picbuf[1].line[i];

			p0[0]=imabuf.line[j];
		}
}

/* effect mirroir tasse demi */

void demita(void)
{
long i,j;
	for(i=0,j=1;i<100;i++,j+=2)
		{
			LINE1 *p0=(LINE1 *)&picbuf[1].line[i];
			LINE1 *p1=(LINE1 *)&picbuf[0].line[199-i];

			p0[1]=imabuf.line[j];
			p1[1]=imabuf.line[j-1];
		}
}

/* effect restore */
void restore(void)
{
long i;
	for(i=0;i<200;i++)
		{
			LINE1 *p0=(LINE1 *)&picbuf[0].line[i];
			p0[0]=imabuf.line[i];
		}
}

/* effect normale */
void normal(void)
{
long i;
	for(i=0;i<200;i++)
		{
		LINE1 *p0=(LINE1 *)&picbuf[1].line[i];

			p0[0]=p0[1]=imabuf.line[i];
		}
}

/* effect tasser */
void tasser(void)
{
long i,j;
	for(i=0,j=1;i<100;i++,j+=2)
		{
		LINE1 *p0=(LINE1 *)&picbuf[1].line[i];
		LINE1 *p1=(LINE1 *)&picbuf[1].line[i+100];
			p0[0]=p0[1]=imabuf.line[j];
			p1[0]=p1[1]=imabuf.line[j-1];
		}
}

/* effect 1 2 3 4 */
void effect(void)
{
long i,j;
	for(i=0;i<200;i++) /* miroir sur meme page */
		{
		LINE1 *p0=(LINE1 *)&picbuf[0].line[i];
		LINE1 *p2=(LINE1 *)&picbuf[0].line[199-i];

		p2[1]=p0[0]; /* affectation de structure 80 char */
		}
		for(i=0,j=1;i<100;i++,j+=2) /* tasser meme page */
		{
			LINE1 *p3=(LINE1 *)&picbuf[0].line[j-1];
			LINE1 *p0=(LINE1 *)&picbuf[1].line[i];
			LINE1 *p1=(LINE1 *)&picbuf[0].line[j];
			LINE1 *p2=(LINE1 *)&picbuf[1].line[i+100];
			p0[1]=p1[0];
			p2[1]=p3[0];
		}
}

/* effect mirroir tasse demi bizzard */
void bizzard(void)
{
long i,j;
	for(i=0,j=1;i<100;i++,j+=2)
		{
		
			picbuf[0].line[i]=picbuf[0].line[j];
			picbuf[0].line[199-i]=picbuf[0].line[j-1];
		}
}

/* effect une sur 2 */
void sansune(void)
{
long j;
LINE2 l;
	for(j=0;j<160;j++) l.word[j]=0;	
	for(j=0;j<200;j+=2)
		{
			picbuf[1].line[j]=l;
			
		}
}

typedef struct 
{
	void (*f)();
} FONC;

FONC tab[8] = {normal,bizzard,tasser,restore,effect,demita,miroir,sansune};

void p(void (*f)(void))
{
	(*f)();
}


char Buffer[500000];	/* Buffer de r‚ception du sample  */
char *PB;
long l;			/* Longueur du sample en octets	  */

void main(void)
{	int hdl;
	long OldSSP;


	void *OldScreen;
	int dummy,t;
	long i,j;

	hdl=Fopen("THEME.SPL",0);
	l=Fread(hdl,500000,Buffer);
	Fclose(hdl);
	for(PB=Buffer;PB<(Buffer+l);PB++)
	{
		(*PB)-=127;
	}
	Init();


/* d‚termine la base line A pour la position souris
*/
	linea_init();

		SetSndMode(129);
		SetSndBase(Buffer);
		SetSndEnd(Buffer+l);
		SetSndDMA(3);
	
/* Sauve l'adresse de l'‚cran courant
*/	
	OldScreen=GetScreenPtr();

/* Installe la routine de scrolling en VBL
*/
	InsVBL(Scrolling);

/* charge l'image et la duplique en largeur
*/		
	hdl=Fopen("MORETA.NEO",0); 
	if (hdl<0) { appl_exit(); Pterm0(); }
	Fseek(4L,hdl,0);
	Fread(hdl,32L,NewPalette);

/* Installe la pallette et sauve l'ancienne
*/
	InsPalette(); 

	Fseek(128L,hdl,0);
	for (i=0;i<200;i++) 
	{	LINE1 *p=(LINE1 *)&picbuf[0].line[i];
		Fread(hdl,sizeof(LINE1),p);
		imabuf.line[i]=p[0];
		p[1]=p[0]; /* affectation de structure */
	}
	Fclose(hdl);

/* Duplique l'image en hauteur 
*/	
	picbuf[1]=picbuf[0]; /* affectation de structure */
/*****/		
	srand(7);
/* Boucle en attendant un Ctrl-C
*/
	while (1) 
	{
	pause();
	p(tab[XMOUSE&7].f);
	pause();
	p(tab[(rand()&7)].f);


		if (Bconstat(2)<0 && (char)Bconin(2)==3) break;
	}

/* Remet tout en ordre et sort de l…
*/	
	RmvVBL();
	SetScreenPtr(OldScreen);
	SetScroll(0);
	SetLineStride(0);
	RestPalette();
	SetSndDMA(0);
}
