/************************************************************************/
/*                                                                      */
/*            CREATE BY ATARI FRANCE                                    */
/*                 FOR DEVELOPERS                                       */
/*                 THIS IS A SAMPLE DEMONSTRATION IN MONO MODE          */
/*                                                                      */
/*                 THIS PROGRAMMING IN TURBO C                          */
/*                 ATTENTION AT THE STRUCTURE ASSIGNMENT                */

/************************************************************************/

#include <tos.h>
#include <stdio.h>

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
#define SNDMODE    *(unsigned char *)(0xFFFF8921)
#define MWDATA        *(int *)(0xFFFF8922)
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
typedef union {
    char c[4];
    long l;
    void *p;
} longchar;

    unsigned char i;

/* Ecriture de l'adresse de d‚but du son
*/
void SetSndBase(void *p)
{   long OldSSP=Super(NULL);
    longchar t;


    t.p=p;
    SNDHIGBASE=t.c[1];
    SNDMEDBASE=t.c[2];
    SNDLOWBASE=t.c[3];
    SNDMODE=SNDMODE|128;
    i=SNDMODE;
    Super((void *)OldSSP);
}

/* Lecture de l'adresse de d‚but du son
*/
void *GetSndBase(void)
{   long OldSSP=Super(NULL);
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
{   long OldSSP=Super(NULL);
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
{   long OldSSP=Super(NULL);
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
{   long OldSSP=Super(NULL);
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
{   long OldSSP=Super(NULL);
    SNDCONTROL=mode;
    Super((void *)OldSSP);
}

/* Lecture du mode DMA
    voir SetSndDMA()
*/
int GetSndDMA(void)
{   long OldSSP=Super(NULL);
    int mode=SNDCONTROL;
    Super((void *)OldSSP);
    return mode;
}

/* Ecriture du mode de fonctionnement
    mode = m00000rr
    m    :    0 -> st‚r‚ophonique
         1 -> monophonique
    rr   : 00 ->  6258 Hz
           01 -> 12517 Hz 
           10 -> 25033 Hz
           11 -> 50066 Hz
*/
void SetSndMode(int mode)
{   long OldSSP=Super(NULL);
    SNDMODE=mode;
    Super((void *)OldSSP);
}

/* Lecture du mode de fonctionnement
    voir SetndMode();
*/
int GetSndMode(void)
{   long OldSSP=Super(NULL);
    int mode=SNDMODE;
    Super((void *)OldSSP);
    return mode;
}

/* Ecriture de commandes Volume/Tone controler
   les 11 bits de poid faible sont utilis‚s
*/  
void SetVTC(int data)
{   MWMASK=0x07FF;
    while (MWMASK!=0x07FF);
    MWDATA=data;
}

void Init(void)
{   long OldSSP=Super(NULL);
    SetVTC(MASTER40);   /* MASTER VOLUME … -40dB */
    SetVTC(BASSM12);    /* BASS +12 dB       */
    SetVTC(TREBBLE00);  /* TEBBLE +12 dB     */
    SetVTC(MIXGI);      /* Mix avec le GI du ST  */
    Super((void *)OldSSP);
}

char Buffer[50000];     /* Buffer de r‚ception du sample pour jouer */
char Buf[50000];     /* Buffer de r‚ception du sample pour lecture */
char *Buff;
char *Bu;
char *PB;
long l;            /* Longueur du sample en octets      */

void main(void)
{   int hdl,i=1,j;
    long OldSSP;
    DTA *adfi;

    adfi=Fgetdta();
    if(Fsfirst("*.SPL",0)!=0)
         { printf("horreur et des SS poir");
              exit(1);
         }
    printf("%s \n",adfi->d_fname);
    hdl=Fopen(adfi->d_fname,0);
    l=Fread(hdl,50000,Buffer);
    Fclose(hdl);

	for(PB=Buffer;PB<(Buffer+l);PB++)
	{

		(*PB)-=127;

	}

	Buff=Buffer;
    Bu=Buf;
	j=1;
	Init();
    SetSndMode(129); /* pour monophonique mode 128 et 1 pour 12517 hz */

    while(i!=0)
    {

         SetSndBase(Buff); /* fixe adresse de depart */
         SetSndEnd(Buff+l); /* fixe adresse d'arriver */
         SetSndDMA(3);        /* met le son en repetitive mode */
         if(Fsnext()!=0)
              { 
              SetSndDMA(0);  /* stop le son */
              exit(1);
              }
	
         printf("%s \n",adfi->d_fname);
         hdl=Fopen(adfi->d_fname,0);
         l=Fread(hdl,50000,Bu);
         Fclose(hdl);

		for(PB=Bu;PB<(Bu+l);PB++)
		{

			(*PB)-=127;

		}
		 	/*	switch buffer */
	 	 if(j==0) 
			{
				j=1;
				Buff=Buffer;
				Bu=Buf;
			}
		 else
			{
				j=0;
				Buff=Buf;
				Bu=Buffer;
			}		 
    }
    Cconin();
}
