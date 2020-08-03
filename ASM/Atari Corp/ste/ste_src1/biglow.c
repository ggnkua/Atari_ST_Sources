/************************************************************************/
/*                                                                      */
/*            CREATE BY ATARI FRANCE                                    */
/*                 FOR DEVELOPERS                                       */
/*                 THIS IS A DEMONSTRATION IN LOW RESOLUTION           */
/*                                                                      */
/*                 THIS PROGRAMMING IN TURBO C                          */
/*                 ATTENTION AT THE STRUCTURE ASSIGNMENT                */

/************************************************************************/

#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <linea.h>

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

/* Initialisation de l'adresse vid‚o
*/
void SetScreenPtr(void *ad)
{   longchar t;
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
{   longchar t;
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
{   long OldSSP=Super(NULL);
    HSHIFT=n&15;
    Super((void *)OldSSP);
} 

/* Lecture du registre de scrolling 
*/
unsigned int GetScroll(void)
{   long OldSSP=Super(NULL);
    int v=HSHIFT&15;
    Super((void *)OldSSP);
    return v;
} 

/* Ecriture de la largeur de ligne
*/
void SetLineStride(unsigned int n)
{   long OldSSP=Super(NULL);
    LINESTRIDE = n;
    Super((void *)OldSSP);
} 

/* Lecture de la largeur de ligne
*/
unsigned int GetLineStride(void)
{   long OldSSP=Super(NULL);
    int n=LINESTRIDE;
    Super((void *)OldSSP);
    return n;
} 


int X,Y;
SCREEN2 picbuf[2];
int NewPalette[16],OldPalette[16];
int OldRes;

/* Installation de la palette et sauvegarde de l'ancienne
*/
void InsPalette(void)
{   int *New=NewPalette,*Old=OldPalette,*Hard=(int *)(0xFFFF8240);
    int n=16;
    long OldSSP=Super(NULL);
    
    while (n--) 
    {    *Old++=*Hard;
         *Hard++=*New++;
    }
    
    OldRes=*(char *)(0xFFFF8260);
    *(char *)(0xFFFF8260)=0;
    Super((void *)OldSSP);
}

/* Restitution de l'ancienne palette
*/
void RestPalette(void)
{   int *Old=OldPalette,*Hard=(int *)(0xFFFF8240);
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
{   long OldSSP=Super(NULL);
    int nbvbl=*(int *)(0x454);
    void **list=*(void **)(0x456);
    
    while (nbvbl--) 
    {    if (*list++==NULL) 
         {    *--list=f;
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
{   long OldSSP=Super(NULL);
    *SavVbl=NULL;
    Super((void *)OldSSP);
}

/* Routine de scrolling sous VBL
    Prend la position de la souris et la transforme
    en une adresse dans les images
 */
void Scrolling(void)
{   long X=XMOUSE,
         Y=YMOUSE;
    longchar t;
    
    HSHIFT=X&15;
    LINESTRIDE=(X&15?76:80); 
    t.p=&picbuf[0].line[Y].word[((X>>1)&0xFFF8)>>1];
    HIGCNT=t.c[1];
    MEDCNT=t.c[2];
    LOWCNT=t.c[3];
}

void main(void)
{   int Hdl;
    void *OldScreen;
    int dummy;
    long i;

/* d‚termine la base line A pour la position souris
*/
    linea_init();

/* charge l'image et la duplique en largeur
*/       
    Hdl=Fopen("MORETA.NEO",0); if (Hdl<0) { appl_exit(); Pterm0(); }
    Fseek(4L,Hdl,0);
    Fread(Hdl,32L,NewPalette);
    Fseek(128L,Hdl,0);
    for (i=0;i<200;i++) 
    {    LINE1 *p=(LINE1 *)&picbuf[0].line[i];
         Fread(Hdl,sizeof(LINE1),p);
         p[1]=p[0];
    }
    Fclose(Hdl);

/* Duplique l'image en hauteur 
*/  
    picbuf[1]=picbuf[0];
         
/* Installe la pallette et sauve l'ancienne
*/
    InsPalette(); 
    
/* Sauve l'adresse de l'‚cran courant
*/  
    OldScreen=GetScreenPtr();

/* Installe la routine de scrolling en VBL
*/
    InsVBL(Scrolling);
    
/* Boucle en attendant un Ctrl-C
*/
    while (1) if (Bconstat(2)<0 && (char)Bconin(2)==3) break;

/* Remet tout en ordre et sort de l…
*/  
    RmvVBL();
    SetScreenPtr(OldScreen);
    SetScroll(0);
    SetLineStride(0);
    RestPalette();
}


 
