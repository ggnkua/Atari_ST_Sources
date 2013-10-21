/*
atari.c (module de base pour atari:st,ste,tt,falcon) (basse resolution)
Description des instructions de ce module dans doc.txt
Guillaume LAMONOCA
Supelec (94)

Utiliser Laser C 1.0
  
Compatible ScreenBlaster, BLowUp, etc...  
      
Pour le son, vous pouvez choisir 3 implementations:
- Son gere par interruption (frequence quelconque)
  (definir YAMAHASOUND pour l'obtenir de maniere inconditionnelle)
- Son DMA (meilleur, mais frequence egale a 12.5, 25 ou 50 khz)
  (pour avoir le son DMA inconditionnellement definissez DMASOUND)
- Son DMA si le bit 1 du cookie '_SND' est actif (DMA prioritaire),
  sinon son gere par interruption si le bit 0 du cookie '_SND'
  est actif (circuit Yamaha present).
  (implementation par defaut : ni YAMAHASOUND, ni DMASOUND defini)
  
  Si le circuit desire n'est pas present, il n'y aura pas de son...
  (Si cookie '_SND' absent, ca doit etre un ST -Yamaha present-)
  
Compiler exemple.c et atari.c avec COMPILE dans menu EXECUTE.
Clicker LINK dans ce meme menu. Rajouter atari.o et exemple.o
dans la liste ou figure deja init.o. Donner le nom exemple.prg a
l'executable. Clicker sur DO IT. Vous pouvez le lancer avec RUN.

Laser C n'accepte pas les prototypes (K&R 1ere edition).
Mais il est rapide, peu volumineux et accepte l'assembleur.

Le shell du laser C 1.0 marche mal avec les derniers atari.
(l'execution des programmes sous shell entrainent de nombreuses
 catastrophes: le cache se plante en modifiant les FAT!!!)

Solution: utiliser genst2 (devpac2) comme shell et utiliser
	un makefile (le tout dans un bon RAM-disque si possible!).

makefile:
exemple.prg : exemple.o atari.o
	\m\ld.ttp \m\init.o atari.o exemple.o \m\libc.a -o exemple.prg
exemple.o : exemple.c
	\m\ccom.ttp exemple.c
atari.o : atari.c
	\m\ccom.ttp atari.c
^________________________tabulation!

Les *.ttp (sauf make.ttp) et la librairie classique libc.a
	ont ete places dans le repertoire \m.
Il suffit de lancer make.ttp pour lancer la compilation
	et l'edition de lien. Si les erreurs defilent trop vite,
	lancez make.ttp avec la ligne de commande ">fichier".
Les erreur seront ecrites dans ce fichier.

Quelques astuces supplementaires:

-Grace a la fonction gemdos(0x4b,0,"prog.ttp","ligne de commande","");
	vous pouvez programmer le shell de vos reves! (fonction EXEC)

-Le makefile se sert des dates de creations des fichiers.
	Si vous n'avez pas envie de toucher sans arret a la date,
	voici un petit programme qui incremente la date a chaque boot.
	(le placer dans un dossier AUTO)

------------------------------------------------------------------
incdate.c : incremente la date (a linker avec init.o et atari.o)

extern long xbios();

typedef union
{
	struct
	{
		unsigned day	 : 5;
		unsigned month	 : 4;
		unsigned year	 : 7;
		unsigned seconds : 5;
		unsigned minutes : 6;
		unsigned hours	 : 5;
	} part;
	long realtime;
} datetime;

int main()
{
	datetime date;

	date.realtime=0x1a310000L;

	if (bexist("incdate.dat")) bload("incdate.dat",&date.realtime,0L,4L);

	if (date.part.day++>28)
	{
		date.part.day=1;
		if (date.part.month++>12)
		{
			date.part.day=1;
			if (date.part.year++>119)
				date.part.day=0;
		}
	}

	xbios(22,date.realtime);
	bmake("incdate.dat",&date.realtime,4L);

}
------------------------------------------------------------------
shell.c : minishell permettant de lancer make.ttp et d'attendre la
	pression d'une touche avant de revenir au GEM ou dans genst2.
	Si aucune erreur ne survient, on lance l'execution de '*.PRG'.
	(a linker avec init.o)

int main()
{
	int r;
	
	gemdos(2,27);
	gemdos(2,'H');       'E' pour effacer l'ecran
	gemdos(9,"Shell");
	gemdos(2,13);
	gemdos(2,10);
	gemdos(2,10);
	r=gemdos(0x4b,0,"make.ttp","","");
	if (r)
		gemdos(7);
	else
		gemdos(0x4b,0,"*.prg","","");
}
------------------------------------------------------------------
*/

/* atari.c */

/* si NOBOMB est defini on detourne les exceptions */ 
#define NOBOMB
/* si KEYMAP est defini on detourne l'it clavier (pour keymap[]) */
#define KEYMAP
/* ne pas definir ces 2 mots si vous voulez utiliser un debuggeur */

/* definir DMASOUND, YAMAHASOUND ou rien (auto-detection) */


#include "header.h"

extern long bios();
extern long xbios();
extern long gemdos();
extern void *lmalloc();


/********************************************************************/
/* variables globales */

static long	snd_cookie;

static int emulmono=0;

static unsigned int egapal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};

static int nbcol;
static unsigned int oldpal[16];
static unsigned int tmppal[16];
static unsigned int bkpal[16];

static unsigned long bakpal[256];

static int tmasque[16]=
{
	0x0000,0x8000,0xc000,0xe000,0xf000,0xf800,0xfc00,0xfe00,
	0xff00,0xff80,0xffc0,0xffe0,0xfff0,0xfff8,0xfffc,0xfffe
};

static int mousefond[128];

static char defaultmouse[160]=
{
	0x3f,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x1f,0xff,0x40,0x00,0x40,0x00,0x40,0x00,0x40,0x00,
	0x0f,0xff,0x60,0x00,0x60,0x00,0x60,0x00,0x60,0x00,
	0x07,0xff,0x70,0x00,0x70,0x00,0x70,0x00,0x70,0x00,
	0x03,0xff,0x78,0x00,0x78,0x00,0x78,0x00,0x78,0x00,
	0x01,0xff,0x7c,0x00,0x7c,0x00,0x7c,0x00,0x7c,0x00,
	0x00,0xff,0x7e,0x00,0x7e,0x00,0x7e,0x00,0x7e,0x00,
	0x00,0x7f,0x7f,0x00,0x7f,0x00,0x7f,0x00,0x7f,0x00,
	0x00,0x3f,0x7f,0x80,0x7f,0x80,0x7f,0x80,0x7f,0x80,
	0x00,0x1f,0x7c,0x00,0x7c,0x00,0x7c,0x00,0x7c,0x00,
	0x01,0xff,0x6c,0x00,0x6c,0x00,0x6c,0x00,0x6c,0x00,
	0x10,0xff,0x46,0x00,0x46,0x00,0x46,0x00,0x46,0x00,
	0x30,0xff,0x06,0x00,0x06,0x00,0x06,0x00,0x06,0x00,
	0x78,0x7f,0x03,0x00,0x03,0x00,0x03,0x00,0x03,0x00,
	0xf8,0x7f,0x03,0x00,0x03,0x00,0x03,0x00,0x03,0x00,
	0xfc,0x7f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};

                                   
static long bloc32k;
static int nbscreen=2;

static int oldres;
static long oldxbios2,oldxbios3;
static long pt_ecran_actif,pt_ecran_travail,bigbloc;
static char swapflag=0;
static char vblflag=0;
static long tempo_pt_ecran;

static long masque;
static long masque2;
static long matrice;
static long matrice2;
static long ecran;
static int haut;
static int larg;
static char *recal;
static char *recal2;
static int fmask;
static int dec;
static int tmask;
static int cnt;
static int ntmask;

static int color=15;
static int pma= -1;
static int pmb= -1;
static int pmc= -1;
static int pmd= -1;
static long ma= -1L;
static long mb= -1L;
static int ftab[200];
static long tm[4]={0L,0xffff0000L,0xffffL,-1L};

static unsigned long ltime;
static unsigned long lastvbl;

static int oldx,oldy,xmax,ymax,fmousex,fmousey;
static long mousebob,lastbob;
static int tmsk,ntmsk,count;
static char broken,startflag,mousemode,endflag;
static char bufferflag=1;
static char kbufferflag=1;
static char statek,lstatek;
static int mouselevel=-1;

static int lasterr=0;
static long voffset=16L;
static long oldvbl[8];
static long oldtrap[8];
static long oldkbdit;
static int kbdcnt=0;
static int kbdptr=0;
static char kbdbuf[16];

static int xcur=0;
static int ycur=0;

static long adrunbuf;
int fbufnbr=0;
int fbufin=0;
int fbufout=0;
char fbuffer[256];

static int msebuffer[128];
static int nbrbuffer=0;
static int lstbufptr=0;
static int msebufptr=0;

static int keybbufptr=0;
static int lstkbufptr=0;
static int nbrkbuffer=0;
static char keybbuffer[256];

static unsigned char dta[44];

static long suiveuse=0L;
static char inuse=0;
static long old_118,old_134,old_400;
static char old_fa07,old_fa19,old_fa1f;
static long splstart,splend,splcour;
static int splvol,splfreq,splrep;


static long fbase;	/* adresse de la fonction systeme screen blaster */
static unsigned int lineskip;
static unsigned char bitoffs;

static int video_proc;
static long vscreen;

char keymap[256]={
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

static unsigned char codekey[256]=
{	
	0,27,'1','2','3','4','5','6','7','8','9','0',0,'_',8,0,
	'a','z','e','r','t','y','u','i','o','p','[',']',13,0,'q','s',
	'd','f','g','h','j','k','l','m','\\',0,0,'#','w','x','c','v',
	'b','n',',',';','/','=',0,0,0,' ',0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,'^',0,'-','<',0,'>','+',0,
	'v',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3',
	'0','.',13,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

int mousex,mousey,mousek,vblclock;
int msex,msey,msek,mclk;


/********************************************************************/
/* fontes */

static unsigned char sysfonte[64*16]={
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0xc3,0xc3,0xc3,0xc3,0xc7,0xe7,0xc7,0xe7,0x1c,0x1c,0x1c,0x18,0x18,0x00,0x18,0x00,
0x81,0x81,0x81,0xdb,0xff,0xff,0xff,0xff,0x36,0x36,0x24,0x00,0x00,0x00,0x00,0x00,
0xc8,0x88,0x00,0x81,0x80,0x00,0x81,0xdb,0x13,0x33,0x7e,0x36,0x37,0x7e,0x24,0x00,
0x83,0x01,0x01,0x81,0xc0,0x00,0x80,0xc1,0x3c,0x6e,0x68,0x3e,0x0b,0x6b,0x3e,0x00,
0x9f,0x09,0x81,0xc3,0xc1,0x80,0xd8,0xfd,0x20,0x52,0x24,0x08,0x12,0x25,0x02,0x00,
0xc7,0x83,0x83,0x83,0x00,0x00,0x80,0xc6,0x18,0x24,0x34,0x38,0x4d,0x46,0x39,0x00,
0x8f,0x8f,0xcf,0x8f,0xdf,0xff,0xff,0xff,0x30,0x30,0x10,0x20,0x00,0x00,0x00,0x00,
0xf3,0xe3,0xc7,0xc7,0xc7,0xe7,0xf3,0xfb,0x04,0x08,0x18,0x10,0x18,0x08,0x04,0x00,
0xcf,0xe7,0xe3,0xf3,0xe3,0xe3,0xc7,0xef,0x10,0x08,0x0c,0x04,0x0c,0x08,0x10,0x00,
0xff,0xc9,0xe1,0x80,0xc0,0xc1,0xed,0xff,0x00,0x12,0x0c,0x3f,0x0c,0x12,0x00,0x00,
0xff,0xe3,0xe3,0x80,0xc0,0xe3,0xf3,0xff,0x00,0x0c,0x0c,0x3f,0x0c,0x0c,0x00,0x00,
0xff,0xff,0xff,0xff,0xc7,0xc7,0x87,0xcf,0x00,0x00,0x00,0x00,0x18,0x18,0x30,0x00,
0xff,0xff,0xff,0x81,0xc1,0xff,0xff,0xff,0x00,0x00,0x00,0x3e,0x00,0x00,0x00,0x00,
0xff,0xff,0xff,0xff,0xff,0x8f,0x8f,0xcf,0x00,0x00,0x00,0x00,0x00,0x30,0x30,0x00,
0xff,0xf9,0xf1,0xe3,0xc7,0x8f,0xdf,0xff,0x00,0x02,0x04,0x08,0x10,0x20,0x00,0x00,
0xc3,0x81,0x00,0x00,0x00,0x80,0xc1,0xe3,0x1c,0x26,0x63,0x63,0x63,0x32,0x1c,0x00,
0xe3,0xc3,0xe3,0xe3,0xe3,0xe3,0x80,0xc0,0x0c,0x1c,0x0c,0x0c,0x0c,0x0c,0x3f,0x00,
0x81,0x00,0x80,0xc0,0x81,0x03,0x00,0x80,0x3e,0x63,0x07,0x1e,0x3c,0x70,0x7f,0x00,
0x00,0x80,0xe1,0xc1,0xe0,0x00,0x80,0xc1,0x7f,0x06,0x0c,0x1e,0x03,0x63,0x3e,0x00,
0xe1,0xc1,0x81,0x01,0x00,0x80,0xf1,0xf9,0x0e,0x1e,0x36,0x66,0x7f,0x06,0x06,0x00,
0x01,0x01,0x01,0x80,0xf8,0x18,0x80,0xc1,0x7e,0x60,0x7e,0x03,0x03,0x63,0x3e,0x00,
0xc1,0x81,0x0f,0x01,0x00,0x00,0x80,0xc1,0x1e,0x30,0x60,0x7e,0x63,0x63,0x3e,0x00,
0x00,0x80,0xf0,0xe1,0xc3,0xc7,0xc7,0xe7,0x7f,0x03,0x06,0x0c,0x18,0x18,0x18,0x00,
0x83,0x01,0x01,0x81,0x00,0x00,0x80,0xc1,0x3c,0x62,0x72,0x3c,0x4f,0x43,0x3e,0x00,
0x81,0x00,0x00,0x80,0xc0,0xf0,0x81,0xc3,0x3e,0x63,0x63,0x3f,0x03,0x06,0x3c,0x00,
0xff,0xc7,0xc7,0xe7,0xc7,0xc7,0xe7,0xff,0x00,0x18,0x18,0x00,0x18,0x18,0x00,0x00,
0xff,0xc7,0xc7,0xe7,0xc7,0xc7,0x87,0xcf,0x00,0x18,0x18,0x00,0x18,0x18,0x30,0x00,
0xf1,0xe1,0xc3,0x87,0xc7,0xe3,0xf1,0xf9,0x06,0x0c,0x18,0x30,0x18,0x0c,0x06,0x00,
0xff,0xff,0x81,0xc1,0x81,0xc1,0xff,0xff,0x00,0x00,0x3e,0x00,0x3e,0x00,0x00,0x00,
0x8f,0xc7,0xe3,0xf1,0xe1,0xc3,0x87,0xcf,0x30,0x18,0x0c,0x06,0x0c,0x18,0x30,0x00,
0x81,0x00,0x00,0x80,0xe1,0xf3,0xe3,0xf3,0x3e,0x7f,0x63,0x06,0x0c,0x00,0x0c,0x00,
0x83,0x01,0x00,0x00,0x00,0x00,0x00,0x81,0x3c,0x42,0x99,0xa1,0xa1,0x99,0x42,0x3c,
0xc3,0x81,0x00,0x00,0x00,0x00,0x18,0x9c,0x1c,0x36,0x63,0x63,0x7f,0x63,0x63,0x00,
0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x81,0x7e,0x63,0x63,0x7e,0x63,0x63,0x7e,0x00,
0xc1,0x80,0x0c,0x1f,0x1f,0x88,0xc0,0xe1,0x1e,0x33,0x60,0x60,0x60,0x33,0x1e,0x00,
0x03,0x01,0x00,0x00,0x00,0x00,0x01,0x83,0x7c,0x66,0x63,0x63,0x63,0x66,0x7c,0x00,
0x00,0x00,0x1f,0x01,0x01,0x1f,0x00,0x80,0x7f,0x60,0x60,0x7e,0x60,0x60,0x7f,0x00,
0x00,0x00,0x1f,0x01,0x01,0x1f,0x1f,0x9f,0x7f,0x60,0x60,0x7e,0x60,0x60,0x60,0x00,
0xc0,0x80,0x0f,0x00,0x00,0x80,0xc0,0xe0,0x1f,0x30,0x60,0x6f,0x63,0x33,0x1f,0x00,
0x18,0x18,0x18,0x00,0x00,0x18,0x18,0x9c,0x63,0x63,0x63,0x7f,0x63,0x63,0x63,0x00,
0x80,0xc0,0xe3,0xe3,0xe3,0xe3,0x80,0xc0,0x3f,0x0c,0x0c,0x0c,0x0c,0x0c,0x3f,0x00,
0xf8,0xf8,0xf8,0xf8,0xf8,0x18,0x80,0xc1,0x03,0x03,0x03,0x03,0x03,0x63,0x3e,0x00,
0x18,0x10,0x01,0x03,0x03,0x01,0x10,0x98,0x63,0x66,0x6c,0x78,0x7c,0x6e,0x67,0x00,
0x8f,0x8f,0x8f,0x8f,0x8f,0x8f,0x80,0xc0,0x30,0x30,0x30,0x30,0x30,0x30,0x3f,0x00,
0x18,0x00,0x00,0x00,0x10,0x18,0x18,0x9c,0x63,0x77,0x7f,0x6b,0x63,0x63,0x63,0x00,
0x18,0x08,0x00,0x00,0x00,0x10,0x18,0x9c,0x63,0x73,0x7b,0x7f,0x6f,0x67,0x63,0x00,
0x81,0x00,0x00,0x00,0x00,0x00,0x80,0xc1,0x3e,0x63,0x63,0x63,0x63,0x63,0x3e,0x00,
0x01,0x00,0x00,0x00,0x00,0x01,0x1f,0x9f,0x7e,0x63,0x63,0x63,0x7e,0x60,0x60,0x00,
0x81,0x00,0x00,0x00,0x00,0x00,0x80,0xc2,0x3e,0x63,0x63,0x63,0x6f,0x66,0x3d,0x00,
0x01,0x00,0x00,0x00,0x00,0x01,0x10,0x98,0x7e,0x63,0x63,0x67,0x7c,0x6e,0x67,0x00,
0x83,0x01,0x01,0x81,0xc0,0x00,0x80,0xc1,0x3c,0x66,0x60,0x3e,0x03,0x63,0x3e,0x00,
0x80,0xc0,0xe3,0xe3,0xe3,0xe3,0xe3,0xf3,0x3f,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x00,
0x18,0x18,0x18,0x18,0x18,0x18,0x80,0xc1,0x63,0x63,0x63,0x63,0x63,0x63,0x3e,0x00,
0x18,0x18,0x18,0x00,0x80,0xc1,0xe3,0xf7,0x63,0x63,0x63,0x77,0x3e,0x1c,0x08,0x00,
0x18,0x18,0x18,0x00,0x00,0x00,0x08,0x9c,0x63,0x63,0x63,0x6b,0x7f,0x77,0x63,0x00,
0x18,0x00,0x80,0xc1,0x81,0x00,0x08,0x9c,0x63,0x77,0x3e,0x1c,0x3e,0x77,0x63,0x00,
0x11,0x11,0x11,0x81,0xc3,0xc7,0xc7,0xe7,0x66,0x66,0x66,0x3c,0x18,0x18,0x18,0x00,
0x00,0x80,0xe0,0xc1,0x83,0x07,0x00,0x80,0x7f,0x07,0x0e,0x1c,0x38,0x70,0x7f,0x00,
0xc3,0xc3,0xc7,0xc7,0xc7,0xc7,0xc3,0xe3,0x1c,0x18,0x18,0x18,0x18,0x18,0x1c,0x00,
0xff,0x9f,0xcf,0xe7,0xf3,0xf9,0xfd,0xff,0x00,0x20,0x10,0x08,0x04,0x02,0x00,0x00,
0xc3,0xe3,0xe3,0xe3,0xe3,0xe3,0xc3,0xe3,0x1c,0x0c,0x0c,0x0c,0x0c,0x0c,0x1c,0x00,
0xe7,0xc3,0x81,0x08,0x9c,0xff,0xff,0xff,0x08,0x1c,0x36,0x63,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x00
};


/**********************************************************************/
/* tables trigonometriques 14 bits */

static int tsn[320]={
	0,402,804,1205,1606,2006,2404,2801,
	3196,3590,3981,4370,4756,5139,5520,5897,
	6270,6639,7005,7366,7723,8076,8423,8765,
	9102,9434,9760,10080,10394,10702,11003,11297,
	11585,11866,12140,12406,12665,12916,13160,13395,
	13623,13842,14053,14256,14449,14635,14811,14978,
	15137,15286,15426,15557,15679,15791,15893,15986,
	16069,16143,16207,16261,16305,16340,16364,16379,
	16384,16379,16364,16340,16305,16261,16207,16143,
	16069,15986,15893,15791,15679,15557,15426,15286,
	15137,14978,14811,14635,14449,14256,14053,13842,
	13623,13395,13160,12916,12665,12406,12140,11866,
	11585,11297,11003,10702,10394,10080,9760,9434,
	9102,8765,8423,8076,7723,7366,7005,6639,
	6270,5897,5520,5139,4756,4370,3981,3590,
	3196,2801,2404,2006,1606,1205,804,402,
	0,-402,-804,-1205,-1606,-2006,-2404,-2801,
	-3196,-3590,-3981,-4370,-4756,-5139,-5520,-5897,
	-6270,-6639,-7005,-7366,-7723,-8076,-8423,-8765,
	-9102,-9434,-9760,-10080,-10394,-10702,-11003,-11297,
	-11585,-11866,-12140,-12406,-12665,-12916,-13160,-13395,
	-13623,-13842,-14053,-14256,-14449,-14635,-14811,-14978,
	-15137,-15286,-15426,-15557,-15679,-15791,-15893,-15986,
	-16069,-16143,-16207,-16261,-16305,-16340,-16364,-16379,
	-16384,-16379,-16364,-16340,-16305,-16261,-16207,-16143,
	-16069,-15986,-15893,-15791,-15679,-15557,-15426,-15286,
	-15137,-14978,-14811,-14635,-14449,-14256,-14053,-13842,
	-13623,-13395,-13160,-12916,-12665,-12406,-12140,-11866,
	-11585,-11297,-11003,-10702,-10394,-10080,-9760,-9434,
	-9102,-8765,-8423,-8076,-7723,-7366,-7005,-6639,
	-6270,-5897,-5520,-5139,-4756,-4370,-3981,-3590,
	-3196,-2801,-2404,-2006,-1606,-1205,-804,-402,
	0,402,804,1205,1606,2006,2404,2801,
	3196,3590,3981,4370,4756,5139,5520,5897,
	6270,6639,7005,7366,7723,8076,8423,8765,
	9102,9434,9760,10080,10394,10702,11003,11297,
	11585,11866,12140,12406,12665,12916,13160,13395,
	13623,13842,14053,14256,14449,14635,14811,14978,
	15137,15286,15426,15557,15679,15791,15893,15986,
	16069,16143,16207,16261,16305,16340,16364,16379
};
static int ttg[65]={
	-16384,-15599,-14850,-14133,-13446,-12786,-12151,-11539,
	-10947,-10375,-9820,-9281,-8757,-8247,-7749,-7263,
	-6786,-6320,-5862,-5413,-4970,-4534,-4104,-3679,
	-3259,-2843,-2430,-2021,-1614,-1209,-805,-402,
	0,402,805,1209,1614,2021,2430,2843,
	3259,3679,4104,4534,4970,5413,5862,6320,
	6786,7263,7749,8247,8757,9281,9820,10375,
	10947,11539,12151,12786,13446,14133,14850,15599,
	16384
};
int *sn=tsn;
int *cs=tsn+64;
int *tg=ttg+32;




/***********************************************************/
/*  D‚finitions pour screen blaster */

/**** D‚finition du header du fichier INF ****/

typedef struct
{	
	long 	ident;
	long	valeur;
}	t_cookie;


typedef struct info_header
{
	char ident[24];
	int inc1[7];
	int curs[5];
	int inc2[10];
	long scrtyp[4];
	char scrname[4][32];
} INFO_HEADER;


/**** D‚finition de la structure d'un bloc de r‚solution ****/
typedef struct info_bloc
{
	struct info_bloc *next_bloc;
	int inc3;
	char *descr;
	int vxmax,vymax,pxmax,pymax;
	int xratio,yratio;
	int nbplane;
	long nbcolor;
	int octpline;
	int inc5;
	int vfreq,hfreq;
	int inc6,inc7;
	long scrmask;
	int sblastfreq;
	int rsvd[13];
	struct change *chglist;
	long rsvd1;
} INFO_BLOC;

struct chval
{
	int *pos;
	int val;
};
	
typedef struct change
{
	int nbchange;
	struct chval chg[25];
}CHANGE;

CHANGE chg_vgalow=
{
	21,
	{
		{0xffff82a2L,1049},
		{0xffff82acL,1045},
		{0xffff82a4L,943},
		{0xffff82a6L,143},
		{0xffff82a8L,143},
		{0xffff82aaL,943},
		{0xffff8282L,23},
		{0xffff828cL,17},
		{0xffff8284L,18},
		{0xffff8286L,1},
		{0xffff8288L,526},
		{0xffff828aL,13},
		{0xffff828eL,0},
		{0xffff8290L,0},
		{0xffff8210L,80},
		{0xffff820eL,0},
		{0xffff82c0L,0x186},
		{0xffff8266L,0},
		{0xffff8260L,0},
		{0xffff82c2L,5},
		{0xffff820aL,512}
	}
},
chg_rgblow=
{
	21,
	{
		{0xffff82a2L,625},
		{0xffff82acL,619},
		{0xffff82a4L,613},
		{0xffff82a6L,47},
		{0xffff82a8L,111},
		{0xffff82aaL,511},
		{0xffff8282L,62},
		{0xffff828cL,52},
		{0xffff8284L,50},
		{0xffff8286L,9},
		{0xffff8288L,575},
		{0xffff828aL,28},
		{0xffff828eL,0},
		{0xffff8290L,0},
		{0xffff8210L,80},
		{0xffff820eL,0},
		{0xffff82c0L,0x81},
		{0xffff8266L,0},
		{0xffff8260L,0},
		{0xffff82c2L,0},
		{0xffff820aL,512}
	}
};


INFO_BLOC myresbloc={
	0L,
	0,
	"320*200",
	319,199,319,199,
	278,278,
	4,
	16,
	160,
	0,
	600,310,
	0,0,
	0xffffffffL,
	0,
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	&chg_vgalow,
	0L
};


INFO_BLOC *sblres;

/*******************************************************/
/* D‚finition des fonctions sblater */


long get_cookie(target)
long target;
{
	long old_stack;
	t_cookie **ptr_tab_cookie=(t_cookie **)0x5a0;	/* pointeur vers le tableau	*/																				/* des cookie	*/
	t_cookie *tab_cookie;

	/* pour lire l'adresse du tableau des cookies, il faut etre en mode	
		superviseur		*/
	if (gemdos(0x20,1L)==0L)	/* si on est en mode utilisateur	*/
	{		
		old_stack=gemdos(0x20,0L);	/* on passe en mode superviseur	*/
	}
	else
	{	
		old_stack=0;
	}
	tab_cookie=*ptr_tab_cookie;	/* on lit cette adresse			*/
	
	
	if (old_stack)				/* si on etait en utilisateur au debut	*/
	{
		gemdos(0x20,old_stack);	/*  on y retourne */
	}				
		
	if (tab_cookie==0L)		/* si le tos <1.6, on n'a pas de cookie jar	*/
		return(-1);				
		
	do		/* on boucle jusqu'a avoir trouve le cookie ou avoir atteint			*/
			/* le dernier element de la cookie jar									*/
	{
		if (tab_cookie	->ident	==target)	/* si le cookie est le cookie recherch‚	*/
		{
			return(tab_cookie	->valeur);	/* on renvoie sa valeur					*/
		}
		else
		{
			/* sinon, on passe au cookie suivant	*/
			tab_cookie++;
		}	
	}	
	while (tab_cookie->ident!=0);	/* la table des cookie est toujours	*/
								/* terminee par un cookie dont l'ident vaut	0	*/

	/* si on n'a pas trouve le cookie	, on renvoie -1 */
	return(-1);
}


long initsblfunc()  		/* R‚cupŠre l'adresse des fonctions Screen blaster et la renvoie (sinon -1)*/
{
	fbase = get_cookie('OSBL');
	
}

char *getinfpath()			/* Renvoie lechemin … partir duquel a ‚t‚ charg‚ le fichier INF */
{
	asm{
	move.w	#0,D0
	move.l	fbase,A0
	jsr	(A0)
	move.l	A0,D0
	}
}

void getsblrez(blact,firstbloc)
INFO_BLOC **blact;				/* Renvoie l'adresse du premier bloc de r‚solution */
INFO_BLOC **firstbloc;			/* et l'adresse du bloc de r‚solution actuel */
{
	asm{
	move.w	#1,D0
	move.l	fbase,A0
	jsr	(A0)
	move.l	blact(A6),A2
	move.l	A0,(A2)
	move.l	firstbloc(A6),A2
	move.l	A1,(A2)
	}
}

void setsblrez(newbloc)
INFO_BLOC *newbloc; /* Se place dans la r‚solution d‚finie par newbloc */ 
{
	long oldst=0L;
	
	
	if(gemdos(0x20,1L)==0L)
		oldst=gemdos(0x20,0L);
	asm{
	move.l	newbloc(A6),A0
	move.w	#2,D0
	move.l	fbase,A1
	jsr	(A1)
	}
	if(oldst) gemdos(0x20,oldst);
}

int sblon()		/* Renvoie 1 si la carte est en fonction sinon 0 */
{
	asm{
		move	#3,D0
		move.l	fbase,A0
		jsr	(A0)
		}
}	







/******************************************************************/
/* initialisation du systeme */



static long mse_it()
{
	long adr;

	asm{
			lea adrts(PC),A0
			move.l A0,adrunbuf
			lea start2(PC),A0
			move.l A0,adr(A6)
			bra.s end2
start2:
			movem.l D0-D7/A0-A6,-(A7)
			move.l	0x4baL,lastvbl
			addq #1,vblclock
			clr.b vblflag
			move fmousex,mousex
			move fmousey,mousey
			move.b statek,lstatek
			
			tst.b swapflag
			beq.s noswp
			
			move.l pt_ecran_actif,A0
			move.l pt_ecran_travail,pt_ecran_actif
			move.l A0,pt_ecran_travail

noswp:
			tst.b mousemode
			beq.s stop

			tst.b startflag
			beq.s suite

			tst.b swapflag
			bne.s swp
			
			tst.b endflag
			bne.s hid
			
			btst.b #5,lstatek
			beq.s suite
hid:
			move.l pt_ecran_actif,A1
			bra.s call
swp:
			move.l pt_ecran_travail,A1
call:
			bsr bloc

suite:
			tst.b endflag
			beq.s svte

			clr.b endflag
			clr.b mousemode
			bra.s stop
svte:		
			tst.b swapflag
			bne.s sivte
			tst.b startflag
			beq.s sivte

			btst.b #5,lstatek
			beq.s stop
sivte:
			st startflag
			bsr getback
			bsr bob
			move mousex,oldx
			move mousey,oldy	
			bclr.b #5,lstatek
stop:		
			clr.b swapflag

			move.b lstatek,statek

#ifdef KEYMAP
			move.l	adrunbuf,A2
			
fag:		
			tst.w	fbufnbr
			beq.s	ffend

			jsr (A2)
			bra.s	fag

ffend:		
			
#endif
			movem.l (A7)+,D0-D7/A0-A6
			rts


bob:
			move mousex,D0
			move.l pt_ecran_actif,A1
			move.l A1,lastbob
			move D0,D1
			andi #0xfff0,D1
			asr #1,D1
			ext.l D1
			adda.l D1,A1
			move mousey,D1
			mulu #160,D1
			adda.l D1,A1
			move.l mousebob,A0
			move D0,D7
			andi #15,D7
			beq.s pair

			lea tmasque,A2
			move D7,D4
			asl #1,D4
			move 0(A2,D4.w),D5
			move D5,tmsk
			eori #0xffff,D5
			move D5,ntmsk
    
			move #16,count
			move mousey,D2
			cmp #184,D2
			blt.s good
			subi #200,D2
			neg D2
			move D2,count
good:
			clr.b broken
			move mousex,D2
			cmp #304,D2
			blt.s ok
			st broken

ok:
			move.w D7,D0
			subi.w #16,D0
			neg.w D0
			cont_2:
			move.w tmsk,D1

			move.w (A0),D6
			lsr.w D7,D6
			or.w D1,D6
			and.w D6,(A1)
			and.w D6,2(A1)
			and.w D6,4(A1)
			and.w D6,6(A1)
			move.w (A0)+,D6
			lsl.w D0,D6
			move.w D6,D1

			move.w (A0),D6
			lsr.w D7,D6
			or.w D6,(A1)+
			move.w (A0)+,D6
			lsl.w D0,D6
			move.w D6,D2

			move.w (A0),D6
			lsr.w D7,D6
			or.w D6,(A1)+
			move.w (A0)+,D6
			lsl.w D0,D6
			move.w D6,D3

			move.w (A0),D6
			lsr.w D7,D6
			or.w D6,(A1)+
			move.w (A0)+,D6
			lsl.w D0,D6
			move.w D6,D4

			move.w (A0),D6
			lsr.w D7,D6
			or.w D6,(A1)+
			move.w (A0)+,D6
			lsl.w D0,D6
			move.w D6,D5

			tst.b broken
			beq.s cont_1

			adda.l #8,A1
			bra.s cut

cont_1:

			move.w ntmsk,D6
			or.w D1,D6
			and.w D6,(A1)
			and.w D6,2(A1)
			and.w D6,4(A1)
			and.w D6,6(A1)

			or.w D2,(A1)+
			or.w D3,(A1)+
			or.w D4,(A1)+
			or.w D5,(A1)+

cut:
			adda.l #144,A1
			subq.w #1,count
			bne.s  cont_2
			rts

pair:
			move.w #15,D0
			move mousey,D2
			cmp #184,D2
			blt.s cont_3
			subi #200,D2
			neg D2
			subq #1,D2
			move D2,D0

cont_3:      
			move.w (A0),D2
			swap D2
			move.w (A0)+,D2
			and.l D2,(A1)
			move.l (A0)+,D3
			or.l D3,(A1)+
			and.l D2,(A1)
			move.l (A0)+,D3
			or.l D3,(A1)+
			adda.l #152,A1

			dbf.w  D0,cont_3
			rts

bloc:
			move.l lastbob,A1
			move oldx,D0
			move D0,D1
			andi #0xfff0,D1
			asr #1,D1
			ext.l D1
			adda.l D1,A1
			move oldy,D1
			mulu #160,D1
			adda.l D1,A1
			lea mousefond,A0

			move.w #15,D0
			move oldy,D2
			cmp #184,D2
			blt.s aok
			subi #200,D2
			neg D2
			subq #1,D2
			move D2,D0
aok:
			move.l #144,D4
			move #1,D2
			move oldx,D3
			cmp #304,D3
			blt.s cont_a
			clr D2
			move.l #152,D4

cont_a:
			move.w D2,D1
cont_b:
			move.l (A0)+,(A1)+
			move.l (A0)+,(A1)+
			dbf  D1,cont_b
			adda.l D4,A1
			dbf  D0,cont_a
			rts

getback:
			move mousex,D0
			move.l pt_ecran_actif,A1
			move D0,D1
			andi #0xfff0,D1
			asr #1,D1
			ext.l D1
			adda.l D1,A1
			move mousey,D1
			mulu #160,D1
			adda.l D1,A1
			lea mousefond,A0

			move.w #15,D0
			move mousey,D2
			cmp #184,D2
			blt.s cok
			subi #200,D2
			neg D2
			subq #1,D2
			move D2,D0
cok:
			move.l #144,D4
			move #1,D2
			move mousex,D3
			cmp #304,D3
			blt.s cont_c
			clr D2
			move.l #152,D4
		
cont_c:
			move.w D2,D1
cont_d:
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			dbf  D1,cont_d
			adda.l D4,A1
			dbf  D0,cont_c
adrts:		rts
end2:
	}
	return(adr);
}








static long kbd_it()
{
	long adr;

	asm{
#ifdef KEYMAP
			lea unbuf(PC),A0
			move.l A0,adrunbuf
#endif
			lea start(PC),A0
			move.l A0,adr(A6)
			bra.s end
start:
#ifdef KEYMAP


			MOVEM.L	D0-D1/A0,-(A7)

			lea		0xfffffc00,A0
			move.b	(A0),D0
			btst.b	#7,D0
			beq.s	fit_end
			btst.b	#0,D0
			beq.s	fit_end

			move.b	2(A0),D0

			lea		fbuffer,A0
			move.w 	fbufin,D1
			move.b	D0,0(A0,D1.w)
			addq.w	#1,D1
			andi.w	#0xff,D1
			move.w	D1,fbufin
			addq.w	#1,fbufnbr
			
fit_end:
			MOVEM.L	(A7)+,D0-D1/A0
			RTS
						
unbuf:		
			MOVEM.L	D0-D3/A0-A1,-(A7)
			lea		kbdbuf,A0

			lea		fbuffer,A1
			move.w	fbufout,D1
			clr.w	D0
			move.b	0(A1,D1.w),D0
			addq.w	#1,D1
			andi.w	#0xff,D1
			move.w	D1,fbufout
			subq.w	#1,fbufnbr

			tst.w	kbdcnt
			bne.s	kbody
			CMPI.w	#0xF6,D0
			BLT.s	kkey
khead:
			clr.w	kbdptr
			move.w	#3,kbdcnt
kbody:
			move.w	kbdptr,D1
			move.b	D0,0(A0,D1.w)
			addq.w	#1,kbdptr
			subq.w	#1,kbdcnt
			beq.s	msepack
			bra.s	it_end

kkey:
			clr.w	D1
			move.b	D0,D1
			andi.w	#127,D1
			lea		codekey,A0
			move.b	0(A0,D1.w),D1
			lea		keymap,A0

			btst	#7,D0
			beq.s	kdown
kup:
			clr.b	0(A0,D1.w)
			bra.s	it_end
			
kdown:
			move.b	#1,0(A0,D1.w)

			tst.b	kbufferflag
			beq.s	it_end
			move	nbrkbuffer,D3
			cmp.w	#256,D3
			beq.s	it_end
			move	keybbufptr,D2
			lea		keybbuffer,A0
			move.b	D1,0(A0,D2.w)
			addq	#1,D2
			andi	#255,D2
			addq	#1,D3
			move	D3,nbrkbuffer
			move	D2,keybbufptr

			bra.s	it_end
#endif
			MOVEM.L	D0-D3/A0-A1,-(A7)
msepack:
			MOVE.B	(A0),D3
			MOVE.B	D3,D1
			ANDI.B	#0xF8,D1
			CMPI.B	#0xF8,D1
			BNE.s	it_end
			MOVE.B	1(A0),D0
			OR.B	2(A0),D0
			BNE.S	it_2
			BCLR.B	#5,statek
			BRA.S	it_1
it_2:
			BSET.B	#5,statek
			MOVE.W	fmousex,D0
			MOVE.B	1(A0),D1
			EXT.W	D1
			ADD.W	D1,D0
			MOVE.W	fmousey,D1
			MOVE.B	2(A0),D2
			EXT.W	D2
			ADD.W	D2,D1
			BSR.S	it_4
			MOVE.W	D0,fmousex
			MOVE.W	D1,fmousey
it_1:
			ANDI.W	#3,D3
			LSR.B	#1,D3
			BCC.S	it_0
			BSET	#1,D3
it_0:
			MOVE.B	statek,D1
			ANDI.W	#3,D1
			CMP.B	D1,D3
			BEQ.S	it_end
			MOVE.W	D3,mousek
			EOR.B	D3,D1
			ROR.B	#2,D1
			OR.B	D1,D3
			MOVE.B	D3,statek
			clr 	D0
			move.b	D3,D0
			andi	#0xc0,D3
			beq.s	it_end
			tst.b	bufferflag
			beq.s	it_end
			move	nbrbuffer,D3
			cmp		#32,D3
			beq.s	it_end
			move	msebufptr,D2
			lea		msebuffer,A0
			move	D0,0(A0,D2.w)
			move	fmousex,2(A0,D2.w)
			move	fmousey,4(A0,D2.w)
			move	vblclock,6(A0,D2.w)
			addq	#8,D2
			andi	#255,D2
			addq	#1,D3
			move	D3,nbrbuffer
			move	D2,msebufptr
it_end:
			MOVEM.L	(A7)+,D0-D3/A0-A1
			RTS
it_4:
			TST.W	D0
			BGE.S	it_5
			CLR.W	D0
			BRA.S	it_6
it_5:
			CMP.W	xmax,D0
			BLE.S	it_6
			MOVE.W	xmax,D0
it_6:
			TST.W	D1
			BGE.S	it_7
			CLR.W	D1
			RTS
it_7:
			CMP.W	ymax,D1
			BLE.S	it_8
			MOVE.W	ymax,D1
it_8:
			RTS
end:
	}
	return(adr);
}



static long getborder()
{
	unsigned long couleur1;
	unsigned long couleur2;
	unsigned long r,v,b;

	if ((((unsigned int)xbios(88,-1))&7)==4)
	{
		/* En mode True Color, sur TV, la couleur de bordure est
		   la couleur systeme no 240 (et la couleur hardware no 0),
		   mais n'est pas mise a jour dans les variables systemes
		   lors de l'initialisation du mode True color : il faut le
		   faire soi-meme au moins une fois, pour esperer la preserver */
	
		couleur1=*((unsigned long *)0xffff9800L); /* recupere couleur hard no 0 */
		r=((couleur1>>24L)&0x000000fcL)+((couleur1>>30L)&0x00000003L);
		v=((couleur1>>16L)&0x000000fcL)+((couleur1>>22L)&0x00000003L);
		b=((couleur1)&0x000000fcL)+((couleur1>>6L)&0x00000003L);
		couleur2=r*65536L+v*256L+b;
		xbios(93,240,1,&couleur2); /* met a jour la couleur systeme no 240 */
	}
	
	return 0;
}

         
static int initscreen()
{
	int i;
	char *ptr;
	int mon_type;
	INFO_BLOC *blocs;
	long oldst=0L;

	sblres=0L;

	video_proc=(int)(get_cookie('_VDO')>>16);
	vscreen=get_cookie('VSCR');
	
	if(video_proc == -1)video_proc = 0;

	oldxbios2=xbios(2);
	oldxbios3=xbios(3);
	
	if(vscreen!=-1L)
	{
		/**** RecupŠre les paramŠtres de hardscroll ****/
		/****  (Si jamais il y a un ‚cran virtuel)  ****/

		if(gemdos(0x20,1L)==0L) oldst = gemdos(0x20,0L);
		if(video_proc >= 3)
			lineskip = *(unsigned int*)0xffff820eL;
		else
			lineskip = (unsigned int)(*(unsigned char*)0xffff820fL);
		bitoffs = *(unsigned char *)0xffff8265L;
		*(unsigned char *)0xffff8265L = 0;
		if(oldst) gemdos(0x20,oldst);
		oldst = 0L;
	}
	
	switch(video_proc)
	{
		case 3:       
			if ((((unsigned int)xbios(88,-1))&7)==3)
				nbcol=256;
			else
				nbcol=16;
			xbios(38,getborder);
			xbios(94,0,nbcol,bakpal);		/* Sauvegarde palette */
			bloc32k = gemdos(0x15,32000L);
			if(initsblfunc()!=-1)		/* Screen blaster est l… ? */
			if(sblon())					/* Est-il en fonction ?*/
			{
				getsblrez(&sblres,&blocs); /* on recupŠre l'adresse de la res act */
				mon_type=xbios(89);
				if(mon_type!=0)
				{
					if(mon_type==2)	/* Moniteur VGA */
						myresbloc.chglist=&chg_vgalow;
					else			/* t‚l‚ ou ‚cran */
						myresbloc.chglist=&chg_rgblow;
						
					setsblrez(&myresbloc);
				}
			}
			if(sblres == 0L)
			{
				oldres=xbios(88,-1);
				xbios(5,bloc32k,bloc32k,-1);
			}
			break;
		case 2:
			xbios(85,0,256,bakpal);
			oldres = xbios(81);
			xbios(5,-1L,-1L,0);
			bloc32k = xbios(2);
			break;
			
		default:
			oldres=xbios(4);
			if(gemdos(0x20,1L)==0L) oldst = gemdos(0x20,0L);
			for(i=0;i<16;i++)
			{
				((int*)(bakpal))[i]=((int*)(0xffff8240L))[i];
			}
			if(oldst) gemdos(0x20,oldst);
			oldst = 0L;
	}	
			
		
	bigbloc=pt_ecran_travail=(long)memalloc(66560L+255L);
	if (pt_ecran_travail)
	{
		pt_ecran_travail=((pt_ecran_travail+255L)&0x00FFFF00);
		for(i=0,ptr=(char*)(pt_ecran_travail);i<1280;i++,ptr++) *ptr=0; 
		pt_ecran_travail+=1280L;
		pt_ecran_actif=pt_ecran_travail+32000L;
		for(i=0,ptr=(char*)(pt_ecran_actif);i<1280;i++,ptr++) *ptr=0; 
		pt_ecran_actif+=1280L;
		xbios(5,pt_ecran_travail,pt_ecran_actif,0);
	}
	else
		return 0;
	tempo_pt_ecran=pt_ecran_travail;
}



static int killscreen()
{
	long oldst=0L,newtop;


	switch(video_proc)
	{
		case 3:
		if(sblres)
		{
			newtop=gemdos(0x15,((long)(sblres->vxmax+1)*(sblres->vymax+1)*(sblres->nbplane))/8L);
			xbios(5,newtop,newtop,-1);
			setsblrez(sblres);
		}
		else
			xbios(5,0L,0L,3,oldres);
		xbios(93,0,nbcol,bakpal);
		break;
		
		case 2:
		xbios(80,oldres);
		xbios(84,0,256,bakpal);
		break;
		
		default:
		xbios(5,-1L,-1L,oldres);
		xbios(6,bakpal);
	}
	
	if(vscreen==-1L)
		xbios(5,oldxbios3,oldxbios2,-1);
	else
	{
		xbios(5,oldxbios3,oldxbios3,-1);
		if(gemdos(0x20,1L)==0L) oldst = gemdos(0x20,0L);
		xbios(37);
		*(char*)0xffff8201L=(oldxbios2&0xff0000)>>16;
		*(char*)0xffff8203L=(oldxbios2&0xff00)>>8;
		*(char*)0xffff820dL=(oldxbios2&0xfe);
		
		if(video_proc == 3)
			*(unsigned int*)0xffff820eL=lineskip;
		else
			*(unsigned char*)0xffff820fL=(unsigned char)lineskip;
		*(unsigned char *)0xffff8265L=bitoffs;
		if(oldst) gemdos(0x20,oldst);
	}
			
	memfree(&bigbloc);
}


#define VERTFLAG          0x0100
#define STMODES           0x0080
#define OVERSCAN          0x0040
#define PAL               0x0020
#define VGA_FALCON        0x0010
#define TV                0x0000

#define COL80             0x08
#define COL40             0x00

#define BPS16             4
#define BPS8              3
#define BPS4              2
#define BPS2              1
#define BPS1              0



#define	LIN25	0
#define LIN50	VERTFLAG

long	NewAdr2;
long	NewAdr3;
long	OldAdr2;
long	OldAdr3;

int		MinRez;
int		NewRez;
int		OldRez;

/* initscreen2 et killscreen2 ajoutes pour compatibilite Blow Up! */
/* teste avec succes avec la carte Blow Up II */
	
static int initscreen2()
{
	char *ptr;
	int i;

	video_proc=(int)(get_cookie('_VDO')>>16);
	
	if ((video_proc<3)||(get_cookie('OSBL')!= -1L))
		return initscreen();
							
	NewRez=BPS4|COL40|LIN25|STMODES;
	
	MinRez=BPS1|COL80|LIN25;

	OldRez=xbios(88,-1);
	if ((((unsigned int)OldRez)&7)==3)
		nbcol=256;
	else
		nbcol=16;
	xbios(38,getborder);
	xbios(94,0,nbcol,bakpal);
	
	if (get_cookie('BLOW')!= -1L)
	{
		OldRez&=0x1ff;
		NewRez|=0x8000;
		MinRez|=0x8000;
	}
		
	OldAdr2=(long)xbios(2);
	OldAdr3=(long)xbios(3);


	NewRez|=xbios(88,-1)&0x20;
	MinRez|=xbios(88,-1)&0x20;
	if (((int)xbios(89))==2)
	{
		NewRez|=VGA_FALCON;
		NewRez^=VERTFLAG;
		MinRez|=VGA_FALCON;
		MinRez^=VERTFLAG;
	}


	nbscreen=2;
	NewAdr2=(long)memalloc((long)xbios(91,NewRez)+255L+2560L);
	NewAdr3=(long)memalloc((long)xbios(91,NewRez)+255L+2560L);

	pt_ecran_actif=((NewAdr2+255L)&0x00FFFF00L);
	pt_ecran_travail=((NewAdr3+255L)&0x00FFFF00L);	
	for(i=0,ptr=(char*)(pt_ecran_travail);i<1280;i++,ptr++) *ptr=0; 
	pt_ecran_travail+=1280L;
	for(i=0,ptr=(char*)(pt_ecran_actif);i<1280;i++,ptr++) *ptr=0; 
	pt_ecran_actif+=1280L;
	bigbloc=tempo_pt_ecran=pt_ecran_travail;

	xbios(88,MinRez);
	xbios(5,pt_ecran_travail,pt_ecran_actif,-1);
	xbios(88,NewRez);

	return 1;
}


                    
static int killscreen2()
{
	if ((video_proc<3)||(get_cookie('OSBL')!= -1L))
		killscreen();
	else
	{
		xbios(88,MinRez);
		xbios(5,OldAdr3,OldAdr2,-1);
		xbios(88,OldRez);	

		xbios(93,0,nbcol,bakpal);
				
		memfree((void **)&NewAdr2);
		memfree((void **)&NewAdr3);
	}
}



static void sys_off()
{
	long adr;
	int i;
	char s[30];

	adr=0x484L;
	*(char*)adr|=2;

	xbios(6,bkpal);
	refresh();

	for(i=0,adr=0x4ceL;i<8;i++,adr+=4L)
	*(long*)adr=oldvbl[i];

	for(i=0,adr=8L;i<8;i++,adr+=4L)
	*(long*)adr=oldtrap[i];

	*(long*)(xbios(34)+voffset)=oldkbdit;

	killscreen2();

	if (lasterr)
	{
		switch(lasterr)
		{
			case 2: sprintf(s,"peek-poke illegal"); break;
			case 3: sprintf(s,"adresse impaire"); break;
			case 4: sprintf(s,"instruction illegale"); break;
			case 5: sprintf(s,"division par zero"); break;
			default: sprintf(s,"%d bombes!",lasterr); break;
		}
		gemdos(9,s);
		gemdos(2,10);
		gemdos(2,13);
		gemdos(9,"Pressez une touche");
		gemdos(7);
	}
}


void killsystem()
{
	stopsample();
	empty();
	xbios(38,sys_off);
}




static long onerr()
{
	long adr;

asm{
	lea err(PC),A0
	move.l A0,adr(A6)
	bra.s endl

err:
	move.w #2,lasterr
	bra.s bye
	move.w #3,lasterr
	bra.s bye
	move.w #4,lasterr
	bra.s bye
	move.w #5,lasterr
	bra.s bye
	move.w #6,lasterr
	bra.s bye
	move.w #7,lasterr
	bra.s bye
	move.w #8,lasterr
	bra.s bye
	move.w #9,lasterr
	bye:
	movem.l D0-D7/A0-A6,-(A7)
	}

	sys_off();

asm{
	movem.l (A7)+,D0-D7/A0-A6
	}
	
	exit(1);
	
asm{
endl:
	}

return(adr);
}




static void sys_on()
{
	long adr,adr2;
	int i;

	adr=0x484L;
	*(char*)adr&=0xfc;

	bmove(0xffff8240L,bkpal,32L);

	for(i=0,adr=0x4ceL;i<8;i++,adr+=4L)
	oldvbl[i]=*(long*)adr;

	for(i=0,adr=8L,adr2=onerr();i<8;i++,adr2+=10L,adr+=4L)
	{
		oldtrap[i]=*(long*)adr;

	/* cette ligne permet de detourner les erreurs (parfois utile) */
	/* et de revenir facilement au shell lors d'une exception. */
#ifdef NOBOMB
		*(long*)adr=adr2;
#endif
	}

	adr=0x4ceL;
	*(long*)adr=mse_it();
	adr+=4L;
	for(i=0;i<7;i++,adr+=4L)
	*(long*)adr=0L;

	/* permet de detourner it clavier pour detecter relachement
	des touches: gestion necessaire au fonctionement de keymap[].
	Cette ligne doit etre enlevee pour pouvoir utiliser un debuggeur
	mais cela empechera la gestion de la souris dans le module. */

#ifdef KEYMAP
	voffset=32L;
#endif

	oldkbdit=*(long*)(xbios(34)+voffset);
	*(long*)(xbios(34)+voffset)=kbd_it();
}


void initsnd()
{
		snd_cookie=get_cookie('_SND');
		if (snd_cookie== -1L)
			snd_cookie=1L;

		#ifdef YAMAHASOUND
			snd_cookie=1L;
		#endif              

		#ifdef DMASOUND
			snd_cookie=2L;
		#endif		
}

void initkbd()
{
	int i;
	
	char *table;
	char **r;
	
	r=(char **)xbios(16,-1L,-1L,-1L);
	
	table=*r;
	
	for(i=0;i<128;i++)
		if (table[i])
			codekey[i]=table[i];
}


int initsystem()
{
	int i=0;

	if (initscreen2())
	{
		initkbd();
		initsnd();
		mousebob=(long)defaultmouse;
		fmousex=152;
		fmousey=92;
		xmax=319;
		ymax=199;
		swapflag=startflag=mousemode=endflag=0;
		mouselevel= -1;
		xbios(38,sys_on);
		cls();
		swap();
		cls();
		swap();
		setpalette(egapal);
		show();
		return(1);
	}
	else
	return(0);
}








/*****************************************************************/
/* gestion des 16 couleurs  */


void setcolor(c)
int c;
{
	color=c&15;
	ma=tm[color&3];
	mb=tm[(color>>2)&3];
}


void setpalette(pal)
unsigned int *pal;
{
	int i;

	for(i=0;i<16;i++) oldpal[i]=pal[i];
	for(i=0;i<16;i++) tmppal[i]=((pal[i]>>1)&0x777)+((pal[i]&0x111)<<3);
	xbios(6,tmppal);
	refresh();
}


void getpalette(pal)
unsigned int *pal;
{
	int i;
	for(i=0;i<16;i++) pal[i]=oldpal[i];
}












/*****************************************************************/
/* instructions de gestion des ecrans graphiques */

void simplescreen()
{
	if (nbscreen==2)
	{
		tempo_pt_ecran=pt_ecran_travail;
		pt_ecran_travail=pt_ecran_actif;
		nbscreen=1;
	}
}


void doublescreen()
{
	if (nbscreen==1)
	{
		pt_ecran_travail=tempo_pt_ecran;
		nbscreen=2;
	}
}




void cls()
{
	xcur=ycur=0;

asm {
	move.l pt_ecran_travail,A0
	move.w #7999,D0
w0:
	clr.l (A0)+
	dbf.w D0,w0
	}
}



static void swapscreen()
{
	while(*(unsigned long*)0x4baL==lastvbl);
	while(*(unsigned long*)0x4baL==lastvbl+1L);

asm{
	move.l pt_ecran_travail,D0
	lsr #8,D0
	move.l D0,0xFF8200
	st swapflag
	}
}


void swap()
{
	if (nbscreen==2)
	{
		xbios(38,swapscreen);
		do {} while(swapflag);
	}
}


static void refreshscreen()
{
asm{
	move.l pt_ecran_actif,D0
	lsr #8,D0
	move.l D0,0xFF8200
	st vblflag
	}
}

void refresh()
{
	xbios(38,refreshscreen);
	do {} while(vblflag);
}

void copyscreen()
{
	hide();
	bmove(pt_ecran_actif,pt_ecran_travail,32000L);
	show();
}









/******************************************************************/
/* instructions graphiques de base */

#define sgn(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define abs(x) ((x<0)?(-(x)):(x))


void pellipse(x,y,lx,ly,c)
int x,y,lx,ly,c;
{
	register int i,r,a,s;
	register int ry=(ly+1)>>1;
	register int rx=lx>>1;

	if (c>=0) setcolor(c);
	for(i=0,a=64;i<ry;i++)
	{
		s=(int)(((ry-i)<<14L)/ry);
		while(sn[a]>s) a++;
		r=rx+(int)((cs[a]*(long)rx)>>14L);
		hline(x+r,y+i,x+lx-1-r,-1);
		hline(x+r,y+ly-i-1,x+lx-1-r,-1);
	}
}


void pbox(x,y,lx,ly,c)
int x,y,lx,ly,c;
{
	register int i;

	if (c>=0) setcolor(c);
	for(i=y;i<y+ly;i++) hline(x,i,x+lx-1,-1);
}




void rline(x1,y1,x2,y2,c)
int x1,y1,x2,y2,c;
{
	register long a,x,y;
	register int i;
	register int d;
	register int dx=x2-x1;
	register int dy=y2-y1;

	if (c>=0) setcolor(c);

	if (!dx) vline(x1,y1,y2,-1);
	else
		if (!dy) hline(x1,y1,x2,-1);
		else
		{

			if (abs(dx)>abs(dy))
			{
				d=sgn(dx);
				a=(dy<<16L)/abs(dx);
				for(i=x1,y=32768L+(y1<<16L);i!=x2;i+=d,y+=a)
					plot(i,(int)(y>>16),-1);
			}
			else
			{
				d=sgn(dy);
				a=(dx<<16L)/abs(dy);
				for(i=y1,x=32768L+(x1<<16L);i!=y2;i+=d,x+=a) 
					plot((int)(x>>16),i,-1);
			}

			plot(x2,y2,-1);
		}

}



void dline(x1,y1,x2,y2,c)
int x1,y1,x2,y2,c;
{
	register long a,x,y;
	register int i;
	register int d;
	register int dx=x2-x1;
	register int dy=y2-y1;

	if (c>=0) setcolor(c);

	if (!dx) vline(x1,y1,y2,-1);
	else
		if (!dy) hline(x1,y1,x2,-1);
		else
		{

			if (abs(dx)>abs(dy))
			{
				d=sgn(dx);
				a=(dy<<16L)/abs(dx);
				for(i=x1,y=32768L+(y1<<16L);i!=x2;i+=d,y+=a)
					plot(i,(int)(y>>16),-1);
			}
			else
			{
				d=sgn(dy);
				a=(dx<<16L)/abs(dy);
				for(i=y1,x=32768L+(x1<<16L);i!=y2;i+=d,x+=a) 
					plot((int)(x>>16),i,-1);
			}

			plot(x2,y2,-1);
		}

}


void dbox(x,y,lx,ly,c)
int x,y,lx,ly,c;
{
	if (c>=0) setcolor(c);
	hline(x,y,x+lx-1,-1);
	hline(x,y+ly-1,x+lx-1,-1);
	vline(x,y,y+ly-1,-1);
	vline(x+lx-1,y,y+ly-1,-1);
}





void plot(x,y,c)
int x,y,c;
{
	register long *ptr;
	register unsigned long m,nm;

	if (c>=0) setcolor(c);
	ptr=(long *)(pt_ecran_travail+y*160L+((x&0xfff0L)>>1L));
	nm=0x80008000L;
	nm>>=x&15;
	m=~nm;
	*(ptr++)=(*ptr&m)|(nm&ma);
	*(ptr++)=(*ptr&m)|(nm&mb);
}


void vline(x,y,y1,c)
int x,y,y1,c;
{
	register long *ptr;
	register unsigned long m,nm;
	register int dy=sgn(y1-y);
	register int i;

	if (c>=0) setcolor(c);
	if (!dy) dy++;
	ptr=(long *)(pt_ecran_travail+y*160L+((x&0xfff0L)>>1L));
	nm=0x80008000L;
	nm>>=x&15;
	m=~nm;
	for(i=y;i!=y1+dy;i+=dy,ptr+=dy*40)
	{
		*(ptr++)=(*ptr&m)|(nm&ma);
		*(ptr--)=(*ptr&m)|(nm&mb);
	}
}





void hline(x,y,x1,c)
int x,y,x1,c;
{
	register long *ptr;
	register unsigned long m,nm;
	register unsigned int im;
	register int i,cx,cx1,bx,bx1;

	if (x<x1)
	{
		cx=x>>4;
		cx1=x1>>4;
		bx=x&15;
		bx1=x1&15;
	}
	else
	{
		cx1=x>>4;
		cx=x1>>4;
		bx1=x&15;
		bx=x1&15;
	}

	if (c>=0) setcolor(c);
	ptr=(long *)(pt_ecran_travail+y*160L+cx*8L);

	if (cx==cx1)
	{
		im=-1;
		im>>=(15-bx1+bx);
		im<<=(15-bx1);
		nm=im+(im<<16L);
		m=~nm;
		*(ptr++)=(*ptr&m)|(nm&ma);
		*ptr=(*ptr&m)|(nm&mb);
	}
	else
	{
		im=-1;
		im>>=bx;
		nm=im+(im<<16L);
		m=~nm;
		*(ptr++)=(*ptr&m)|(nm&ma);
		*(ptr++)=(*ptr&m)|(nm&mb);
		cx++;
		if (cx!=cx1)
			for(i=cx;i<cx1;i++) { *(ptr++)=ma; *(ptr++)=mb; }
		im=-1;
		im<<=15-bx1;
		nm=im+(im<<16L);
		m=~nm;
		*(ptr++)=(*ptr&m)|(nm&ma);
		*ptr=(*ptr&m)|(nm&mb);
	}
}



void polyline(n,tp,c)
int n,c;
int *tp;
{
	register int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n-1;i++) rline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3],-1);
}


static void fplot(x,y)
int x,y;
{
	register int l=ftab[y];
	register int d;

	if (l>=0)
	{
		d=l-x;
		if ((!d)||(d==1)||(d== -1))
		{
			plot(x,y,-1);
			ftab[y]=x;
		}
		else
		{
			hline(x,y,l,-1);
			ftab[y]= -1;
		}
	}
	else
	{
		plot(x,y,-1);
		ftab[y]=x;
	}

}


static void fline(x1,y1,x2,y2)
int x1,y1,x2,y2;
{
	register long a,x,y;
	register int i;
	register int d;
	register int dx=x2-x1;
	register int dy=y2-y1;


	if (dx|dy)
		if (abs(dx)>abs(dy))
		{
			d=sgn(dx);
			a=(dy<<16L)/abs(dx);
			for(i=x1,y=32768L+(y1<<16L);i!=x2;i+=d,y+=a)
				fplot(i,(int)(y>>16));
		}
		else
		{
			d=sgn(dy);
			a=(dx<<16L)/abs(dy);
			for(i=y1,x=32768L+(x1<<16L);i!=y2;i+=d,x+=a) 
				fplot((int)(x>>16),i);
		}

	fplot(x2,y2);

}





void polyfill(n,tp,c)
int n,c;
int *tp;
{
	register int i;

	if (c>=0) setcolor(c);
	
	for(i=0;i<200;i++) ftab[i]= -1;
	for(i=0;i<n-1;i++) fline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3]);
}















/******************************************************************/
/* instructions d'allocation memoire */



long ramfree()
{
	long r;
	r=(long)gemdos(0x48,-1L);
	return(r);
}

void memfree(adr)
void **adr;
{
	if (*adr)
	{
		free(*adr);
		*adr=0L;
	}
}


void *memalloc(size)
long size;
{
	return(lmalloc(size));
}













/*****************************************************************/
/* instructions de transfert de blocs */

void bmove(sce,dst,len)
void *sce,*dst;
long len;
{
	if (sce>dst)
	{
		asm{
		movem.l A0-A1/D0,-(A7)
		move.l sce(A6),A0
		move.l dst(A6),A1
		move.l len(A6),D0
lp:		move.b (A0)+,(A1)+
		subq.l #1,D0
		bne lp
		movem.l (A7)+,A0-A1/D0
		}
	}
	else
	{
		asm{
		movem.l A0-A1/D0,-(A7)
		move.l sce(A6),A0
		move.l dst(A6),A1
		move.l len(A6),D0
		adda.l D0,A0
		adda.l D0,A1
lpi:	move.b -(A0),-(A1)
		subq.l #1,D0
		bne lpi
		movem.l (A7)+,A0-A1/D0
		}
	}
}












/******************************************************************/
/* instructions de gestion de l'horloge */

static void picktime()
{
	ltime=*(unsigned long *)0x4baL;
	ltime+=(ltime<<2L);
}

unsigned long systime()
{
	xbios(38,picktime);
	return(ltime);
}

void waitdelay(n)
int n;
{
	unsigned long start;

	start=systime();
	do {} while((systime()-start)<(unsigned long)n);
}












/******************************************************************/
/* fonctions aleatoires */

int randint()
{
	return((int)xbios(17)&0x7fff);
}

int randval(n)
int n;
{
	return(randint()%n);
}















/*****************************************************************/
/* gestion de fichiers */

static void verifnom(s,s2)
char *s,*s2;
{
	while(*s)
	{
		*s2= *s;
		if (*s=='/') *s2='\\';
		s++;
		s2++;
	}
	*s2=0;
}



int bexist(nom)
char *nom;
{
	int r;
	char nom2[200];

	verifnom(nom,nom2);
	gemdos(0x1a,dta);
	r=gemdos(0x4e,nom2,0);
	if (!r) r=1; else r=0;
	return(r);
}

long bsize(nom)
char *nom;
{
	long s=0L;

	if (bexist(nom))
	s=dta[26]*256L*65536L+dta[27]*65536L+dta[28]*256L+(long)dta[29];
	return(s);
}

int bload(nom,adr,offset,len)
char *nom;
long adr,offset,len;
{
	int fd;
	char nom2[200];

	verifnom(nom,nom2);
	fd=gemdos(0x3d,nom2,0);
	if (fd>0)
	{
		gemdos(0x42,offset,fd,1);
		gemdos(0x3f,fd,len,adr);
		gemdos(0x3e,fd);
		fd=0;
	}
	return(fd);
}

int bsave(nom,adr,offset,len)
char *nom;
long adr,offset,len;
{
	int fd;
	int r=0;
	char nom2[200];

	verifnom(nom,nom2);
	fd=gemdos(0x3d,nom2,2);
	if (fd>0)
	{
		gemdos(0x42,offset,fd,1);
		r=gemdos(0x40,fd,len,adr);
		if (r==-1) r=-13;
		gemdos(0x3e,fd);
		fd=0;
	}
	if (r<0) fd=r;
	return(fd);
}



int bmake(nom,adr,len)
char *nom;
long adr,len;
{
	int fd;
	int r=0;
	char nom2[200];

	verifnom(nom,nom2);
	gemdos(0x1a,dta);
	r=gemdos(0x4e,nom2,0);
	if (r==-33) r=0;
	if (!r)
	{
		fd=gemdos(0x3c,nom2,0);
		if (fd>0)
		{
			gemdos(0x40,fd,len,adr);
			gemdos(0x3e,fd);
			fd=0;
		}
		else
		if (fd==-1) fd=-13;
	}
	else fd=r;
	return(fd);
}





int bopen(nom)
char *nom;
{
	int fd;
	char nom2[200];

	verifnom(nom,nom2);
	fd=gemdos(0x3d,nom2,0);
	if (fd<=0) fd=-1;
	return(fd);
}


int bcreate(nom)
char *nom;
{
	int fd;
	char nom2[200];

	verifnom(nom,nom2);
	fd=gemdos(0x3c,nom2,0);
	if (fd<=0) fd=-1;
	return(fd);
}



int bread(fd,adr,len)
int fd;
long adr,len;
{
	int r=0;

	r=gemdos(0x3f,fd,len,adr);
	return(r);
}


int bwrite(fd,adr,len)
int fd;
long adr,len;
{
	int r=0;

	r=gemdos(0x40,fd,len,adr);
	return(r);
}



int bclose(fd)
int fd;
{
	int r=0;

	r=gemdos(0x3e,fd);
	return(r);
}


















/*************************************************************/
/* gestion de la souris et du clavier */


int kbhit()
{
#ifdef KEYMAP
	return(nbrkbuffer);
#else
	return(bios(1,2));
#endif
}

int buthit()
{
	return(nbrbuffer);
}

int keyhit()
{
	return(buthit()|kbhit());
}

char getch()
{
#ifdef KEYMAP
	char r;

	do {} while(!nbrkbuffer);

	r=keybbuffer[lstkbufptr];
	lstkbufptr++;
	lstkbufptr&=255;
	nbrkbuffer--;
	
	return(r);
#else
	return((char)bios(2,2));
#endif
}


void empty()
{
	bufferflag=0;
	nbrbuffer=msebufptr=lstbufptr=0;
	bufferflag=1;
#ifdef KEYMAP
	kbufferflag=0;
	nbrkbuffer=keybbufptr=lstkbufptr=0;
	kbufferflag=1;
#else
	if (bios(1,2)) do bios(2,2); while (bios(1,2));
#endif
}

void confirm()
{
	empty();
	do {} while (!buthit());
}

int getmouse()
{
	int ptr;

	if (nbrbuffer)
	{
		ptr=(lstbufptr>>1);
		msek=msebuffer[ptr];
		msex=msebuffer[ptr+1];
		msey=msebuffer[ptr+2];
		mclk=msebuffer[ptr+3];
		lstbufptr+=8;
		lstbufptr&=255;
		nbrbuffer-=1;

/* msek: bit 0:bouton gauche bit 1:bouton droit bit 2:0:presse 1:relache */

		if (msek&64)
		if (msek&1) msek=1; else msek=5;
		else
		if (msek&128)
		if (msek&2) msek=2; else msek=6;
		else
		msek=0;

		return(msek);
	}
	else
	return(0);
}



void hide()
{
	if (mouselevel==0)
	{
		endflag=1;
		do {} while(mousemode);
	}
	mouselevel-=1;
}

void show()
{
	if (mouselevel==-1)
	{
		startflag=0;
		mousemode=1;
		do {} while(startflag);
	}
	mouselevel+=1;
}













/***************************************************************/
/* gestion de blocs graphiques */



typedef struct
{
	int lx;
	int ly;
	int id;
	long bloc;
	long mask;
} 
pixbloc;


void initbloc(blocptr)
void **blocptr;
{
	pixbloc *bloc;
	*blocptr=memalloc((long)sizeof(pixbloc));
	bloc=(pixbloc *)*blocptr;
	if (*blocptr) bloc->id=0;
}


void freebloc(blocptr)
void **blocptr;
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id) memfree(&bloc->bloc);
		if (bloc->id==2) memfree(&bloc->mask);
		bloc->id=0;
		memfree(blocptr);
	}
}



void getbloc(blocptr,x,y,lx,ly)
void **blocptr;
int x,y,lx,ly;
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if ((!bloc->id)||(bloc->lx!=lx)||(bloc->ly!=ly))
		{
			if (bloc->id) memfree(&bloc->bloc);
			if (bloc->id==2) memfree(&bloc->mask);
			bloc->id=0;
			if (bloc->bloc=(long)memalloc((4L*ly)*(lx/8L)))
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}


		if (bloc->id)
		{

			matrice=bloc->bloc;
			ecran=pt_ecran_travail+x/2L+y*160L;
			haut=ly-1;
			larg=(lx/16)-1;
			recal=(char*)(4*(40-(lx/8)));
		{
		asm{

		move.l	ecran,A1
		move.l 	matrice,A0
		move.w	haut,D0
l3b:
		move	larg,D1
l4b:
		move.l	(A1)+,(A0)+
		move.l 	(A1)+,(A0)+
		dbf		D1,l4b
		adda.l	recal,A1
		dbf	 	D0,l3b

		}
		}

		}
	}
}



void copybloc(blocptrs,xs,ys,lxs,lys,blocptrd,xd,yd)
void **blocptrs;
int xs,ys,lxs,lys;
void **blocptrd;
int xd,yd;
{
	pixbloc *blocs;
	pixbloc *blocd;
	if ((*blocptrs)&&(*blocptrd))
	{
		blocs=(pixbloc *)*blocptrs;
		blocd=(pixbloc *)*blocptrd;
		if ((blocs->id)&&(blocd->id))
		if ((xd>=0)&&(yd>=0)&&(xs>=0)&&(ys>=0))
		if ((xs+lxs<=blocs->lx)&&(ys+lys<=blocs->ly))
		if ((xd+lxs<=blocd->lx)&&(yd+lys<=blocd->ly))
		{
			matrice=blocs->bloc+xs/2L+ys*(blocs->lx/2L);
			matrice2=blocd->bloc+xd/2L+yd*(blocd->lx/2L);
			haut=lys-1;
			larg=(lxs/16)-1;
			recal=(char*)((blocs->lx-lxs)/2);
			recal2=(char*)((blocd->lx-lxs)/2);
		{
		asm{

		move.l 	matrice,A0
		move.l	matrice2,A1
		move.w	haut,D0
l3z:
		move	larg,D1
l4z:
		move.l	(A0)+,(A1)+
		move.l	(A0)+,(A1)+
		dbf		D1,l4z
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,l3z

		}
		}

		if ((blocs->id==2)&&(blocd->id==2))
		{
			masque=blocs->mask+xs/8L+ys*(blocs->lx/8L);
			masque2=blocd->mask+xd/8L+yd*(blocd->lx/8L);
			haut=lys-1;
			larg=(lxs/16)-1;
			recal=(char*)((blocs->lx-lxs)/8);
			recal2=(char*)((blocd->lx-lxs)/8);

		{
		asm{

		move.l 	masque,A0
		move.l	masque2,A1
		move.w	haut,D0
l3y:
		move	larg,D1
l4y:
		move.w	(A0)+,(A1)+
		dbf		D1,l4y
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,l3y

		}
		}



		}

		}
	}
}




void putpbloc(blocptr,x,y,xs,ys,lxs,lys)
void **blocptr;
int x,y,xs,ys,lxs,lys;
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;

		if ((y>=0)||(y+lys<=200))
		{
			if (y<0)
			{
				ys+=(-y);
				lys-=(-y);
				y=0;
			}
			else
			if (y+lys>200)
			{
				lys=200-y;
			}
		}
		if (lys>0)
		if ((x>=0)&&(y>=0)&&(xs>=0)&&(ys>=0))
		if ((x<320)&&(y<200))
		if ((x+lxs<=320)&&(y+lys<=200))
		if (bloc->id)
		{
			dec=x&15;
			tmask=tmasque[dec];
			ntmask=~tmask;
			fmask=bloc->id-1;
			masque=bloc->mask+xs/8L+ys*(bloc->lx/8L);
			matrice=bloc->bloc+xs/2L+ys*(bloc->lx/2L);
			ecran=pt_ecran_travail+(x&0xfff0)/2L+y*160L;
			recal2=(char*)((bloc->lx-lxs)/2);

			if (dec)
			{
				haut=lys;
				larg=lxs/16;
				recal=(char*)(4*(38-(lxs/8)));

				{
				asm{

		move.l masque,A2
	    move.l ecran,A1
    	move.l matrice,A0
		move.w dec,D7
		move.w D7,D0
		subi.w #16,D0
		neg.w D0

cont_20:  

		move.w tmask,D1
		clr.w D2
		clr.w D3
		clr.w D4
		clr.w D5

		move.w larg,cnt 

cont_21:      
		tst.w	fmask
		bne.s	sb1

		and.w D1,(A1)
		and.w D1,2(A1)
		and.w D1,4(A1)
		and.w D1,6(A1)
		clr.w D1
		bra.s	sb2
sb1:
		move.w (A2),D6
		lsr.w D7,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,2(A1)
		and.w D6,4(A1)
		and.w D6,6(A1)
		move.w (A2)+,D6
		lsl.w D0,D6
		move.w D6,D1
sb2:	
		move.w (A0),D6
		lsr.w D7,D6
		or.w D2,D6
		or.w D6,(A1)+
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D2

		move.w (A0),D6
		lsr.w D7,D6
		or.w D3,D6
		or.w D6,(A1)+
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D3

		move.w (A0),D6
		lsr.w D7,D6
		or.w D4,D6
		or.w D6,(A1)+
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D4

		move.w (A0),D6
		lsr.w D7,D6
		or.w D5,D6
		or.w D6,(A1)+
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D5


		subq.w #1,cnt
		bne.s cont_21


		move.w ntmask,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,2(A1)
		and.w D6,4(A1)
		and.w D6,6(A1)

		or.w D2,(A1)+
		or.w D3,(A1)+
		or.w D4,(A1)+
		or.w D5,(A1)+

		adda.l recal,A1
		adda.l recal2,A0
		subq.w #1,haut
		bne.s  cont_20

				}
				}
			}
			else
			{
				haut=lys-1;
				larg=(lxs/16)-1;
				recal=(char*)(4*(40-(lxs/8)));

				if (fmask)
				{
				asm{

		move.l masque,A2
		move.l ecran,A1
		move.l matrice,A0		
		move.w haut,D0
cont_12:
		move.w larg,D1 
cont_13:      
		move.w (A2)+,D2
		and.w D2,(A1)
		and.w D2,2(A1)
		and.w D2,4(A1)
		and.w D2,6(A1)
		move.w (A0)+,D3
		or.w D3,(A1)+
		move.w (A0)+,D3
		or.w D3,(A1)+
		move.w (A0)+,D3
		or.w D3,(A1)+
		move.w (A0)+,D3
		or.w D3,(A1)+

		dbf.w  D1,cont_13
		adda.l recal,A1
		adda.l recal2,A0
		dbf.w  D0,cont_12

				}
				}
				else
				{
				asm{

		move.l masque,A2
		move.l ecran,A1
		move.l matrice,A0		
		move.w haut,D0
cont_18:
		move.w larg,D1 
cont_19:      
		move.l (A0)+,(A1)+
		move.l (A0)+,(A1)+
		dbf.w  D1,cont_19
		adda.l recal,A1
		adda.l recal2,A0
		dbf.w  D0,cont_18

				}
				}

			}
		}


	}
}



void putbloc(blocptr,x,y)
void **blocptr;
int x,y;
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		putpbloc(blocptr,x,y,0,0,bloc->lx,bloc->ly);
	}
}


void getmask(blocptr,x,y)
void **blocptr;
int x,y;
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id)
		{
			if (bloc->id==2)
			{
				memfree(&bloc->mask);
				bloc->id=1;
			}
			if (bloc->id==1)
			{
				bloc->mask=(long)memalloc(bloc->ly*(bloc->lx/8L));
				if (bloc->mask) bloc->id=2;
			}
		
			if (bloc->id==2)
			{
				matrice=bloc->mask;
				ecran=pt_ecran_travail+x/2L+y*160L;
				haut=bloc->ly-1;
				larg=(bloc->lx/16)-1;
				recal=(char*)(4*(40-(bloc->lx/8)));

			{
			asm{

		move.l	ecran,A1
		move.l 	matrice,A0
		move.w	haut,D0
l3c:
		move	larg,D1
l4c:
		move.w	(A1),D4
		not.w	D4
		move.w	D4,(A0)+
		addq.l	#8,A1
		dbf		D1,l4c
		adda.l	recal,A1
		dbf	 	D0,l3c

			}	
			}

			}


		}
	}
}













/*****************************************************************/
/* instructions de gestion de fonte */


void affchar(x,y,c)
int x,y;
char c;
{
unsigned int n;

if ((c>31)&&(c<128))
{
	if (c>95) c-=32;
	n=c-32;

	dec=x&15;
	tmask=tmasque[dec];
	haut=8;
	ntmask=~tmask;
	matrice=(long)&sysfonte[n*16];
	ecran=pt_ecran_travail+(x&0xfff0)/2L+y*160L;

	pma=ma>>16;
	pmb=ma&0xffff;
	pmc=mb>>16;
	pmd=mb&0xffff;

	if (dec)
	{
		recal=(char*)(4*36);

		{
		asm{

		move.l ecran,A1
		move.l matrice,A0
		move.l	A0,A2
		adda.l	#8,A2
		move.w dec,D7
		move.w D7,D0
		subi.w #16,D0
		neg.w D0
cont_c23:  
		move.w tmask,D1
		move.b (A0)+,D6
		lsl.w #8,D6
		ori.w #0xff,D6
		move.w D6,D3
		lsr.w D7,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,2(A1)
		and.w D6,4(A1)
		and.w D6,6(A1)
		lsl.w D0,D3
		move.w D3,D1

		move.b (A2)+,D6
		lsl.w #8,D6
		move.w D6,D3
		lsr.w D7,D6
		move.w	D6,D4
		and.w	pma,D4
		or.w D4,(A1)+
		move.w	D6,D4
		and.w	pmb,D4
		or.w D4,(A1)+
		move.w	D6,D4
		and.w	pmc,D4
		or.w D4,(A1)+
		move.w	D6,D4
		and.w	pmd,D4
		or.w D4,(A1)+
		lsl.w D0,D3
		move.w D3,D2

		move.w ntmask,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,2(A1)
		and.w D6,4(A1)
		and.w D6,6(A1)

		move.w	D2,D4
		and.w	pma,D4
		or.w D4,(A1)+
		move.w	D2,D4
		and.w	pmb,D4
		or.w D4,(A1)+
		move.w	D2,D4
		and.w	pmc,D4
		or.w D4,(A1)+
		move.w	D2,D4
		and.w	pmd,D4
		or.w D4,(A1)+

		adda.l recal,A1
		subq.w #1,haut
		bne.s  cont_c23
		}    	
		}

	}
	else
	{
		recal=(char*)(4*38);

		{
		asm{

		move.l ecran,A1
		move.l matrice,A0
		move.l	A0,A2
		adda.l	#8,A2
		move.w #7,D0
cont_c133:      
		move.b (A0)+,D2
		lsl.w #8,D2
		ori.w #0xff,D2
		and.w D2,(A1)
		and.w D2,2(A1)
		and.w D2,4(A1)
		and.w D2,6(A1)
		move.b (A2)+,D3
		lsl.w #8,D3
		move.w	D3,D4
		and.w	pma,D4
		or.w D4,(A1)+
		move.w	D3,D4
		and.w	pmb,D4
		or.w D4,(A1)+
		move.w	D3,D4
		and.w	pmc,D4
		or.w D4,(A1)+
		move.w	D3,D4
		and.w	pmd,D4
		or.w D4,(A1)+

		adda.l recal,A1
		dbf.w D0,cont_c133

		}
		}
	}
}

}



void afftext(x,y,s)
int x,y;
char *s;
{

	while(*s)
	{
		affchar(x,y,*s++);
		x+=8;
		if (x>312)
		{ 
			x=0; 
			y+=8; 
			if (y>192) y=0; 
		}
	}

}



void printchar(c)
char c;
{
	int t;

	while(ycur>192)
	{
		ycur-=8;
		bmove(pt_ecran_travail+8*160L,pt_ecran_travail,192*160L);
		t=color;
		pbox(0,192,320,8,0);
		setcolor(t);
	}

	if (c==10) xcur= -8;
	else
		if (c==13)
		{ 
			ycur+=8; 
			xcur= -8; 
		}
		else
			affchar(xcur,ycur,c);

	xcur+=8;
	if (xcur>312)
	{ 
		xcur=0; 
		ycur+=8; 
	}


}


void print(s)
char *s;
{
	while(*s) printchar(*s++);

	xcur=0; 
	ycur+=8; 
	
}









       

/*******************************************************************/
/* gestion du son DMA */

static long dmalen;
static int dmafreq;
static long pcm;

unsigned int *DMA=(unsigned int *)0xFF8900L;

static long start_dma()
{
	DMA[1]=(unsigned int)((unsigned long)pcm>>16);
	DMA[2]=(unsigned int)((unsigned long)pcm>>8);
	DMA[3]=(unsigned int)pcm;
	
	DMA[7]=(unsigned int)((unsigned long)(pcm+dmalen)>>16);
	DMA[8]=(unsigned int)((unsigned long)(pcm+dmalen)>>8);
	DMA[9]=(unsigned int)(pcm+dmalen);

	DMA[16]=0x80+dmafreq;
	DMA[0]=1;
	
	return 0;
}

static long stop_dma()
{
	DMA[0]=0;
	
	return 0;
}








/*******************************************************************/
/* tableau necessaire a la simulation du DAC sonore */

static long spl_tab[384]=
{
	0x8000900,0xA000801,0x9000A00,0x8010901,0xA000802,0x9010A00,
	0x8010901,0xA010802,0x9020A01,0x8020902,0xA020803,0x9020A02,
	0x8030903,0xA020803,0x9030A03,0x8040903,0xA030804,0x9040A02,
	0x8040904,0xA030804,0x9040A04,0x8050905,0xA020805,0x9040A04,
	0x8050905,0xA040806,0x9050A02,0x8050905,0xA050806,0x9050A04,
	0x8060906,0xA020806,0x9050A05,0x8060906,0xA040806,0x9060A05,
	0x8070905,0xA050807,0x9060A04,0x8060906,0xA060808,0x9050A04,
	0x8070907,0xA040807,0x9060A06,0x8080906,0xA040808,0x9060A05,
	0x8070907,0xA060808,0x9070A04,0x8080906,0xA060807,0x9070A07,
	0x8080908,0xA020808,0x9070A06,0x8080908,0xA040808,0x9070A07,
	0x8090906,0xA060808,0x9080A06,0x8090908,0xA020809,0x9070A06,
	0x8080908,0xA070809,0x9070A07,0x8090909,0xA000809,0x9080A06,
	0x8090909,0xA020808,0x9080A08,0x8090908,0xA070809,0x9090A05,
	0x80A0908,0xA010809,0x9090A06,0x80A0908,0xA040809,0x9080A08,
	0x8090909,0xA07080A,0x9090A00,0x80A0908,0xA06080A,0x9090A03,
	0x8090909,0xA08080A,0x9090A05,0x80B0907,0xA04080A,0x9090A06,
	0x80B0908,0xA01080A,0x9080A08,0x8090909,0xA09080A,0x90A0A00,
	0x80A090A,0xA01080A,0x90A0A02,0x80A0909,0xA08080A,0x90A0A05,
	0x80B0908,0xA07080A,0x90A0A06,0x80C0901,0xA01080A,0x9090A09,
	0x80A090A,0xA07080B,0x9080A08,0x80B0909,0xA07080B,0x90A0A00,
	0x80A090A,0xA08080B,0x90A0A03,0x80B0909,0xA08080B,0x90A0A05,
	0x80C0907,0xA03080A,0x90A0A09,0x80C0906,0xA06080B,0x9090A09,
	0x80C0907,0xA06080C,0x9080A04,0x80C0907,0xA07080B,0x90A0A08,
	0x80B090B,0xA02080A,0x90A0A0A,0x80B090B,0xA05080B,0x90A0A09,
	0x80B090B,0xA06080C,0x9090A06,0x80B090B,0xA07080C,0x9090A07,
	0x80C090A,0xA00080C,0x90A0A00,0x80B090B,0xA08080C,0x9090A08,
	0x80B090A,0xA0A080C,0x90A0A05,0x80B090B,0xA09080D,0x9040A03,
	0x80C0909,0xA09080D,0x9050A04,0x80D0905,0xA05080D,0x9060A04,
	0x80C090A,0xA08080C,0x90B0A00,0x80C090B,0xA02080B,0x90B0A0A,
	0x80C090A,0xA09080C,0x90B0A06,0x80D0907,0xA07080C,0x90B0A07,
	0x80D0908,0xA06080D,0x9090A02,0x80C090B,0xA08080D,0x9090A05,
	0x80B090B,0xA0B080D,0x9080A08,0x80C090B,0xA09080C,0x90B0A09,
	0x80D0909,0xA08080D,0x9090A08,0x80D090A,0xA02080D,0x90A0A04,
	0x80D090A,0xA05080C,0x90B0A0A,0x80C090C,0xA01080C,0x90C0A03,
	0x80C090C,0xA05080C,0x90C0A06,0x80C090C,0xA07080D,0x90B0A00,
	0x80D090B,0xA00080C,0x90C0A08,0x80C090B,0xA0B080D,0x90B0A06,
	0x80C090C,0xA09080C,0x90C0A09,0x80C090C,0xA09080D,0x90A0A0A,
	0x80D090A,0xA0A080D,0x90A0A0A,0x80D090B,0xA09080D,0x90B0A09,
	0x80C090C,0xA0A080C,0x90C0A0A,0x80C090C,0xA0A080D,0x90B0A0A,
	0x80D090B,0xA0A080D,0x90B0A0A,0x80D090B,0xA0A080C,0x90C0A0B,
	0x80C090C,0xA0B080D,0x90C0A02,0x80D090C,0xA05080D,0x90C0A06,
	0x80E0900,0xA00080D,0x90B0A0B,0x80D090C,0xA08080E,0x9040A04,
	0x80E0905,0xA05080D,0x90C0A09,0x80E0906,0xA06080E,0x9070A05,
	0x80E0908,0xA00080E,0x9070A07,0x80E0908,0xA06080D,0x90C0A0A,
	0x80C090C,0xA0C080E,0x9090A01,0x80E0908,0xA08080E,0x9090A07,
	0x80E0909,0xA08080E,0x9090A08,0x80D090C,0xA0B080E,0x9090A09,
	0x80E0909,0xA09080E,0x90A0A04,0x80D090D,0xA00080D,0x90D0A04,
	0x80D090D,0xA07080D,0x90D0A08,0x80E090A,0xA09080D,0x90D0A09,
	0x80D090D,0xA09080E,0x90B0A00,0x80E090B,0xA00080E,0x90B0A07,
	0x80D090D,0xA0A080D,0x90C0A0C,0x80E090B,0xA09080E,0x90B0A09,
	0x80E090B,0xA09080D,0x90D0A0B,0x80D090D,0xA0B080D,0x90D0A0B,
	0x80E090B,0xA0A080E,0x90B0A0A,0x80E090B,0xA0A080E,0x90B0A0B,
	0x80E090B,0xA0B080E,0x90B0A0B,0x80E090B,0xA0B080E,0x90C0A00,
	0x80E090C,0xA00080E,0x90C0A05,0x80E090C,0xA09080E,0x90C0A09,
	0x80D090D,0xA0C080D,0x90D0A0C,0x80E090C,0xA0A080E,0x90C0A0A,
	0x80E090C,0xA0A080E,0x90C0A0A,0x80E090C,0xA0B080E,0x90C0A0B,
	0x80E090C,0xA0B080E,0x90C0A0B,0x80E090C,0xA0B080E,0x90C0A0B,
	0x80E090C,0xA0B080E,0x90C0A0B,0x80D090D,0xA0D080D,0x90D0A0D,
	0x80D090D,0xA0D080D,0x90D0A0D,0x80D090D,0xA0D080D,0x90D0A0D,
	0x80E090D,0xA00080E,0x90C0A0C,0x80E090D,0xA0A080E,0x90D0A0A,
	0x80E090D,0xA0A080E,0x90D0A0A,0x80E090D,0xA0B080E,0x90D0A0B,
	0x80E090D,0xA0B080E,0x90D0A0B,0x80E090D,0xA0B080E,0x90D0A0B,
	0x80E090D,0xA0B080F,0x9030A00,0x80F0903,0xA00080F,0x9030A00,
	0x80F0903,0xA00080F,0x9030A00,0x80F0903,0xA00080E,0x90D0A0C
};











/*******************************************************************/
/* gestion des samples */


void playsample(adr,len,freq)
void *adr;
long len,freq;
{
	int n,v,f;
	
if (snd_cookie&2L)
{
	xbios(38,stop_dma);
	dmalen=len;
	pcm=(long)adr;
	dmafreq=1;                  /* 12.5 khz */
	if (freq>18000L) dmafreq=2; /* 25 khz */
	if (freq>37000L) dmafreq=3; /* 50 khz */
	xbios(38,start_dma);
}
else
if (snd_cookie&1L)
{
	n=1;
	v=15;
	f=(int)freq;

	v=(15-v)>>1;

asm{

	MOVEM.L D0-D7/A0-A6,-(A7)

	TST.L	adr(A6)
	BNE.S	playspl

stopspl:
	TST.B	inuse
	BEQ.S	plend
	PEA	stop_it(PC)
	MOVE.W	#0x26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	MOVEQ	#0,D0
	BRA.S	plend

playspl:
	TST.B	inuse
	BNE.S	plend
	MOVE.L	adr(A6),D0
	MOVE.L	D0,splstart
	MOVE.L	D0,splcour
	ADD.L	len(A6),D0
	MOVE.L	D0,splend
	MOVE.W	n(A6),splrep
	MOVE.W	v(A6),splvol
	MOVE.W	f(A6),D0
	MOVE.W	D0,splfreq

	PEA	init_itspl(PC)
	MOVE.W	#0x26,-(A7)
	TRAP	#14
	PEA	init_dosnd(PC)
	MOVE.W	#0x26,-(A7)
	TRAP	#14
	PEA	level_128(PC)
	MOVE.W	#0x26,-(A7)
	TRAP	#14
	PEA	init_sndchp(PC)
	MOVE.W	#0x26,-(A7)
	TRAP	#14
	PEA	set_freq(PC)
	MOVE.W	#0x26,-(A7)
	TRAP	#14
	LEA	0x1E(A7),A7
	MOVE.L	#1,suiveuse
	MOVE.W	splfreq,D0
	EXT.L	D0
	ST	inuse
	BRA.S plend

stop_it:
	BSR level_128
	BSR	restore_it
	CLR.L	suiveuse
	CLR.B	inuse
	RTS

level_128:
	MOVE	SR,-(A7)
	ORI.W	#0x700,SR
	BCLR	#5,0xFFFFFA07.W
	BCLR	#5,0xFFFFFA0F.W
	MOVE.B	#8,0xFFFF8800.W
	MOVE.B	#0xD,0xFFFF8802.W
	MOVE.B	#9,0xFFFF8800.W
	MOVE.B	#9,0xFFFF8802.W
	MOVE.B	#0xA,0xFFFF8800.W
	MOVE.B	#8,0xFFFF8802.W
	MOVE.W	(A7)+,SR
	RTS

restore_it:
	MOVE	SR,-(A7)
	ORI.W	#0x700,SR
	BTST	#5,old_fa07
	BEQ.S	rst1
	MOVE.B	old_fa07,0xFFFFFA07.W
	MOVE.B	old_fa19,0xFFFFFA19.W
	MOVE.B	old_fa1f,0xFFFFFA1F.W
	MOVE.L	old_134,0x134.W
rst1:
	MOVE.L	old_118,0x118.W
	MOVE.L	old_400,0x400.W
	MOVE.W	(A7)+,SR
	RTS


set_freq:
	MOVE	SR,-(A7)
	ORI.W	#0x700,SR
	MOVE.W	splfreq,D0
	BSR	calc_freq
	PEA it_spl(PC)
	MOVE.W	D4,-(A7)
	MOVE.W	D5,-(A7)
	CLR.W	-(A7)
	MOVE.W	#0x1F,-(A7)
	TRAP	#14
	LEA	0xC(A7),A7
	MOVE.W	(A7)+,SR
	RTS

calc_freq:
	CMPI.W	#0x32,D0
	BGE.S	cf1
	MOVEQ	#0x32,D0
cf1:
	CMPI.W	#0x4D58,D0
	BLE.S	cf2
	MOVE.W	#0x4D58,D0
cf2:
	MOVE.W	D0,D2
	MOVE.L	#0x00258000L,D0
	DIVU	D2,D0
	SWAP	D0
	MOVE.W	D0,D1
	ADD.W	D1,D1
	CLR.W	D0
	SWAP	D0
	CMP.W	D2,D1
	BLT.S	cf3
	ADDQ.W	#1,D0
cf3:
	LEA	tab_freq(PC),A0
	MOVE.W	#0x7FFF,D1
	MOVEQ	#7,D2
cf4:
	MOVE.L	D0,D3
	DIVU	(A0)+,D3
	CMPI.W	#0xFF,D3
	BGT.S	cf5
	SWAP	D3
	CMP.W	D1,D3
	BGE.S	cf5
	MOVE.W	D3,D1
	SWAP	D3
	MOVE.W	D3,D4
	MOVE.W	D2,D5
cf5:
	CMPI.W	#1,D2
	DBEQ	D2,cf4
	MOVE.L	#0x00258000L,D0
	MOVEQ	#7,D1
	SUB.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	D4,D2
	LEA	tab_freq(PC),A0
	MULU	0(A0,D1.W),D2
	DIVU	D2,D0
	MOVE.W	D0,splfreq
	RTS

tab_freq:
	DC.W	200,100,64,50,16,10,4

init_itspl:
	MOVE	SR,-(A7)
	ORI.W	#0x700,SR
	MOVE.B	0xFFFFFA07.W,old_fa07
	BTST	#5,old_fa07
	BEQ.S	ii3
	MOVE.L	0x134.W,old_134
	MOVE.B	0xFFFFFA19.W,old_fa19
ii1:
	MOVE.B	0xFFFFFA1F.W,D0
	CMPI.B	#1,D0
	BNE.S	ii1
ii2:
	MOVE.B	0xFFFFFA1F.W,D0
	CMPI.B	#1,D0
	BEQ.S	ii2
	MOVE.B	0xFFFFFA1F.W,old_fa1f
ii3:
	LEA		0x90,A0
	MOVE.L	0x118.W,old_118
	MOVE.L	0x118.W,(A0)
	LEA	kbd_rt(PC),A0
	MOVE.L	A0,0x118.W
	MOVE.L	0x400.W,old_400
	LEA	ii4(PC),A0
	MOVE.L	A0,0x400.W
	MOVE.W	(A7)+,SR
ii4:
	RTS


kbd_rt:
	MOVE.B	0xFFFFFA09.W,-(A7)
	BCLR	#5,0xFFFFFA09.W
	MOVE	SR,-(A7)
	MOVE.W	#0x2500,SR
	TRAP	#4
	move	(A7)+,SR
	MOVE.B	(A7)+,0xFFFFFA09.W
	RTE

init_dosnd:
	PEA	mes_dosnd(PC)
	MOVE.W	#0x20,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	RTS

mes_dosnd:
	DC.W	0xFF00

init_sndchp:
	MOVE	SR,-(A7)
	ORI.W	#0x700,SR
	MOVE.B	#7,0xFFFF8800.W
	MOVE.B	0xFFFF8800.W,D0
	ANDI.B	#0xC0,D0
	ORI.B	#0x3F,D0
	MOVE.B	D0,0xFFFF8802.W
	MOVE.W	(A7)+,SR
	RTS


it_spl:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	CLR.W	D0
	
	MOVEA.L	splcour,A0
	MOVE.B	(A0)+,D0
	MOVE.W	splvol,D1
	BEQ.S	bv
	ASR.B	D1,D0
bv:
	ADDI.B	#128,D0
	MOVE.L	A0,splcour
	CMPA.L	splend,A0
	BNE.S	its4
	SUBQ.W	#1,splrep
	BNE.S	its2
	BSR	stop_it
	BRA.S	its5
its2:
	ADDQ.L	#1,suiveuse
	MOVE.L	splstart,splcour
its4:
	ADD.W	D0,D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	LEA	0xFFFF8800.W,A0
	LEA spl_tab,A1
	MOVE.B	0(A1,D0.W),0(A0)
	MOVE.B	1(A1,D0.W),2(A0)
	MOVE.B	2(A1,D0.W),0(A0)
	MOVE.B	3(A1,D0.W),2(A0)
	MOVE.B	4(A1,D0.W),0(A0)
	MOVE.B	5(A1,D0.W),2(A0)
its5:
	MOVEM.L	(A7)+,D0-D1/A0-A1
	BCLR	#5,0xFFFFFA0F.W
	RTE

plend:
	MOVEM.L (A7)+,D0-D7/A0-A6
	}
        
}
}



void stopsample()
{       
	if (snd_cookie&2L)
		xbios(38,stop_dma);
	else
		if (snd_cookie&1L)
			playsample(0L,0L,0L);
}


void fixsample(adr,len)
void *adr;
long len;
{
	long i;
	char *ptr;

	ptr=(char *)adr;	
	for(i=0L;i<len;i++) *(ptr++)-=128;
}
 
 

