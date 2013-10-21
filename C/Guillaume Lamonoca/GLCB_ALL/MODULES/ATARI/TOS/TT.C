/*
tt.c (module de base pour TT) (mode 256 couleurs)
Description des instructions de ce module dans doc.txt
Guillaume LAMONOCA
Supelec (94)
Regis ROY
Supelec (95)

Ce module permet d'exploiter l'extension 256 couleurs que
prevoit GLCB (cf falcon.c, pcvga.c et x11.c) sur un Atari TT.
La resolution "logique" sera de 320x200, mais c'est bel et bien
la resolution physique 320x480 (TTLow) qui sera utilis‚e.
On va donc simuler un mode "double ligne" en doublant les affichages.
(Quel gachis! Mais c'est le prix de la compatibilite!)

Anecdote: Ce module marchera aussi sur Falcon (avec le meme gachis)
Ceci est du au fait que je n'ai pas de TT et qu'il faut quand meme
que je puisse tester le module, meme sans TT... (Mais evidement
si vous destinez votre programme au falcon egalement, utilisez
absolument falcon.c, puisqu'il sera deux fois plus rapide!!!)
(De plus, Attention : la compatibilite Blow Up est assuree, mais
 pas la compatibilite Screen Blaster : Utilisez Falcon.c!!!)

Utiliser Pure C
Pour de gros executables: Options->Compiler "Use absolute calls"
(par prudence choisissez toujours cette option)
N'hesitez pas non plus a mettre 0 pour warning level.

(Compatibilite screenblaster et joystick rajoutee par Regis ROY)

Vous pouvez lancer un programme a partir de n'importe quelle
resolution. Lors du retour au bureau, la resolution sera retablie.

Les mouvements du joystick 1 emulent les touches flechees.
Le bouton de tir du joystick 1 emule le bouton droit de la souris.

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
  
Le module travaille en mode 256 couleurs pour autoriser l'utilisation
de la palette etendue (definir EXTENSION dans header.h).

L'eclatement du fichier provoque l'apparition publique de nombreux
symboles qui etait "static" au paravant: si dans vos programmes
vous utilisez les memes noms de variables globales ca coincera...
Si cela vous arrive renommez les variables.

Faites un fichier .PRJ pour compiler et linker
pcstart.o, exemple.c, tt.c et tt2.s ensemble
afin d'obtenir l'executable exemple.prg.

tt2.s peut etre assemble avec l'assembleur devpac 2
(produire alors un code objet DRI et remplacer IF par IFD).

contenu d'un tel fichier exemple.prj:

exemple.prg
=
pcstart.o
tt2.s (ou tt2.o si produit par devpac)
tt.c
exemple.c

PCFLTLIB.LIB
PCSTDLIB.LIB
PCTOSLIB.LIB
*/

/* si KEYMAP est defini on detourne l'it clavier (pour keymap[]) */
#define KEYMAP
/* ne pas definir ce mot si vous voulez utiliser un debuggeur */
/* KEYMAP est aussi defini dans tt2.s */

/* definir DMASOUND, YAMAHASOUND ou rien (auto-detection) */

#include "header.h"
#include <tos.h>
#include <stdlib.h>


extern void mse_it(void);
extern void kbd_it(void);
extern void cls(void);
extern void swaps2(void);
extern long refreshscreen(void);
extern void bmovea(void);
extern void bmoveb(void);
extern void copyba(void);
extern void copybb(void);
extern void copybc(void);
extern void putpba(void);
extern void putpbb(void);
extern void putpbc(void);
extern void getmaska(void);
extern void getbloca(void);
extern void affchara(void);
extern void affcharb(void);
extern void playsa(void);
extern void unbuf(void);

/********************************************************************/
/* variables globales */

static long snd_cookie;

long roffset=0L;
static int video_proc;

static unsigned long bakpal[256];
static unsigned int oldbigpal[3*256];

static unsigned int egapal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};

static int nbcol;
static unsigned int oldpal[16];
static long tmppal[256];
static unsigned int tmppal2[256];

int tmasque[16]=
{
	0x0000,0x8000,0xc000,0xe000,0xf000,0xf800,0xfc00,0xfe00,
	0xff00,0xff80,0xffc0,0xffe0,0xfff0,0xfff8,0xfffc,0xfffe
};

int mousefond[256];

static char defaultmouse[160+16*8]=
{
	0x3f,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x1f,0xff,0x40,0x00,0x40,0x00,0x40,0x00,0x40,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x0f,0xff,0x60,0x00,0x60,0x00,0x60,0x00,0x60,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x07,0xff,0x70,0x00,0x70,0x00,0x70,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x03,0xff,0x78,0x00,0x78,0x00,0x78,0x00,0x78,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x01,0xff,0x7c,0x00,0x7c,0x00,0x7c,0x00,0x7c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0xff,0x7e,0x00,0x7e,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x7f,0x7f,0x00,0x7f,0x00,0x7f,0x00,0x7f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x3f,0x7f,0x80,0x7f,0x80,0x7f,0x80,0x7f,0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x1f,0x7c,0x00,0x7c,0x00,0x7c,0x00,0x7c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x01,0xff,0x6c,0x00,0x6c,0x00,0x6c,0x00,0x6c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x10,0xff,0x46,0x00,0x46,0x00,0x46,0x00,0x46,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x30,0xff,0x06,0x00,0x06,0x00,0x06,0x00,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x78,0x7f,0x03,0x00,0x03,0x00,0x03,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0xf8,0x7f,0x03,0x00,0x03,0x00,0x03,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0xfc,0x7f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};



static int nbscreen=2;

static int oldres;
static long oldxbios2,oldxbios3;
long pt_ecr_actif,pt_ecr_travail;
static long bigbloc;
char swapflag=0;
char vblflag=0;
static long tempo_pt_ecr;

long masque;
long masque2;
long matrice;
long matrice2;
long ecran;
int haut;
int larg;
char *recal;
char *recal2;
int fmask;
int dec;
int tmask;
int cnt;
int ntmask;

static int ftab[200];

static int color=15;
int pma= -1;
int pmb= -1;
int pmc= -1;
int pmd= -1;
int pme= -1;
int pmf= -1;
int pmg= -1;
int pmh= -1;
static long ma= -1L;
static long mb= -1L;
static long mc= -1L;
static long md= -1L;
static long tm[4]={0L,0xffff0000L,0xffffL,-1L};

static unsigned long ltime;
unsigned long lastvbl;

int g_oldx,g_oldy,xmax,ymax,fmousex,fmousey;
long mousebob,lastbob;
int tmsk,ntmsk,count;
char broken=0;
char startflag,mousemode,endflag;
char bufferflag=1;
char kbufferflag=1;
char statek,lstatek;
static int mouselevel=-1;

static long voffset=16L;
static long oldvbl[8];
static long oldtrap[8];
static long oldkbdit;
int kbdcnt=0;
int kbdptr=0;
char kbdbuf[16];

int xcur=0;
int ycur=0;

long adrunbuf;
int fbufnbr=0;
int fbufin=0;
int fbufout=0;
char fbuffer[256];

int msebuffer[128];
int nbrbuffer=0;
int lstbufptr=0;
int msebufptr=0;

int keybbufptr=0;
int lstkbufptr=0;
int nbrkbuffer=0;
char keybbuffer[256];

static unsigned char dta[44];

long suiveuse=0L;
char inuse=0;
long old_118,old_134,old_400;
char old_fa07,old_fa19,old_fa1f;
long splstart,splend,splcour;
int splvol,splfreq,splrep;

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

unsigned char codekey[256]=
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








/*******************************************************/

typedef struct
{	
	long 	ident;
	long	valeur;
}	t_cookie;

long gc(long target)
{
	long old_stack;
	t_cookie **ptr_tab_cookie=(t_cookie **)0x5a0;	
							/* pointeur vers le tableau des cookie	*/
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
		if (tab_cookie	->ident	==target)	/* si le cookie est le cookie recherche	*/
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









/******************************************************************/
/* initialisation du systeme */


static long getborder(void)
{
	unsigned long couleur1;
	unsigned long couleur2;
	unsigned long r,v,b;

	if ((((unsigned int)Vsetmode(-1))&7)==4)
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


static int initscreen(void)
{
	unsigned int i;
	

	bigbloc=(long)memalloc(2L*153600L+255L);
	if (bigbloc)
	{


	video_proc=(int)(gc('_VDO')>>16);
	
	if (video_proc == -1) video_proc = 0;

	oldxbios2=xbios(2);
	oldxbios3=xbios(3);
	
	
	if (video_proc==2)
	{	
			xbios(85,0,256,bakpal);
			oldres = (int)xbios(81);
			xbios(5,-1L,-1L,7); /* TTLow, enfin j'espere! */
			roffset=12800L;
	}
	else
		return 0;
			

		nbscreen=2;

		pt_ecr_travail=bigbloc;	
		pt_ecr_travail=((pt_ecr_travail+255L)&0x00FFFF00L);
		pt_ecr_actif=pt_ecr_travail+153600L;
		
		for(i=0;i<38400U;i++)
		*((long*)(pt_ecr_actif)+i)=*((long*)(pt_ecr_travail)+i)=0L;

		pt_ecr_travail+=roffset;
		pt_ecr_actif+=roffset;
		
		return 1;
	}
	return 0;
}




#define	LIN25	0
#define LIN50	VERTFLAG

static	long	NewAdr2;
static	long	NewAdr3;
static	long	OldAdr2;
static 	long	OldAdr3;

static	int		MinRez;
static	int		NewRez;
static	int		OldRez;

/* initscreen2 et killscreen2 ajoutes pour compatibilite Blow Up! */
/* teste avec succes avec la carte Blow Up II */
	
static int initscreen2(void)
{
	unsigned int i;

	video_proc=(int)(gc('_VDO')>>16);
	
	if (video_proc<3)
		return initscreen();
					
	NewRez=BPS8|COL40|LIN50;

	MinRez=BPS1|COL80|LIN25;

	OldRez=Vsetmode(-1);    
	if ((((unsigned int)OldRez)&7)>=3)
		nbcol=256;
	else
		nbcol=16;
    Supexec(getborder);
	xbios(94,0,nbcol,bakpal);
	
	if (gc('BLOW')!= -1L)
	{
		OldRez&=0x1ff;
		NewRez|=0x8000;
		MinRez|=0x8000;
	}
	
	OldAdr2=(long)Physbase();
	OldAdr3=(long)Logbase();


	NewRez|=Vsetmode(-1)&0x20;
	MinRez|=Vsetmode(-1)&0x20;
	if (((int)xbios(89))==2)
	{
		NewRez|=VGA_FALCON;
		NewRez^=VERTFLAG;
		MinRez|=VGA_FALCON;
		MinRez^=VERTFLAG;
		roffset=12800L;
	}


	nbscreen=2;
	NewAdr2=(long)memalloc(VgetSize(NewRez)+255L);
	NewAdr3=(long)memalloc(VgetSize(NewRez)+255L);

	pt_ecr_actif=((NewAdr2+255L)&0x00FFFF00L);
	pt_ecr_travail=((NewAdr3+255L)&0x00FFFF00L);
	
	for(i=0;i<38400U;i++)
		*((long*)(pt_ecr_actif)+i)=*((long*)(pt_ecr_travail)+i)=0L;

	pt_ecr_travail+=roffset;
	pt_ecr_actif+=roffset;
		

	Vsetmode(MinRez);
	xbios(5,pt_ecr_travail,pt_ecr_actif,-1);
	Vsetmode(NewRez);

	return 1;
}






static void killscreen(void)
{
	xbios(80,oldres);
	xbios(84,0,256,bakpal);
	
	xbios(5,oldxbios3,oldxbios2,-1);
			
	memfree((void **)&bigbloc);
}



static void killscreen2(void)
{
	if (video_proc<3)
		killscreen();
	else
	{
		Vsetmode(MinRez);
		xbios(5,OldAdr3,OldAdr2,-1);
		Vsetmode(OldRez);	

		xbios(93,0,nbcol,bakpal);
				
		memfree((void **)&NewAdr2);
		memfree((void **)&NewAdr3);
	}
}





static long sys_off(void)
{
	long adr;
	int i;

	adr=0x484L;
	*(char*)adr|=2;

	for(i=0,adr=0x4ceL;i<8;i++,adr+=4L)
	*(long*)adr=oldvbl[i];

	for(i=0,adr=8L;i<8;i++,adr+=4L)
	*(long*)adr=oldtrap[i];

	*(long*)(xbios(34)+voffset)=oldkbdit;

	killscreen2();

	return 0;
}


void killsystem(void)
{
	stopsample();
	empty();
	cls();
	swap();
	cls();
	Supexec(sys_off);
}




int rts=0x4e75;

static long sys_on(void)
{
	long adr;
	int i;

	adr=0x484L;
	*(char*)adr&=0xfc;

	for(i=0,adr=0x4ceL;i<8;i++,adr+=4L)
	oldvbl[i]=*(long*)adr;

	for(i=0,adr=8L;i<8;i++,adr+=4L)
	{
		oldtrap[i]=*(long*)adr;
	}

	adr=0x4ceL;
	*(long*)adr=(long)mse_it;
	adrunbuf=(long)&rts;
	adr+=4L;
	for(i=0;i<7;i++,adr+=4L)
	*(long*)adr=0L;

	/* permet de detourner it clavier pour detecter relachement
	des touches: gestion necessaire au fonctionement de keymap[].
	Cette ligne doit etre enlevee pour pouvoir utiliser un debuggeur
	mais cela empechera la gestion de la souris dans le module. */

#ifdef KEYMAP
	voffset=32L;
	adrunbuf=(long)unbuf;
#endif

	oldkbdit=*(long*)(xbios(34)+voffset);
	*(long*)(xbios(34)+voffset)=(long)kbd_it;

	return 0;
}


            
void initsnd(void)
{
	snd_cookie=gc('_SND');
	if (snd_cookie== -1L)
		snd_cookie=1L;

	#ifdef YAMAHASOUND
		snd_cookie=1L;
	#endif              

	#ifdef DMASOUND
		snd_cookie=2L;
	#endif		
}

void initkbd(void)
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

int initsystem(void)
{
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
		Supexec(sys_on);
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
/* gestion de la palette etendue  */


void setbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;
	unsigned int r,b,v;
	
	for(i=0;i<3*nb;i++) oldbigpal[3*no+i]=ptr[i];

	if (video_proc==2)
	{
		for(i=0;i<nb;i++)
		{
			r=(ptr[i*3]>>12)&15;
			v=(ptr[i*3+1]>>12)&15;
			b=(ptr[i*3+2]>>12)&15;
			tmppal2[i+no]=r*256+v*16+b;
		}
		xbios(84,no,nb,tmppal2+no);
	}
	else
	{	
		for(i=0;i<nb;i++)
		{
			r=(ptr[i*3]>>8)&255;
			v=(ptr[i*3+1]>>8)&255;
			b=(ptr[i*3+2]>>8)&255;
			tmppal[i+no]=r*65536L+v*256L+(long)b;
		}
		xbios(93,no,nb,tmppal+no);
	}

	refresh();
}

void getbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;
	
	for(i=0;i<3*nb;i++) ptr[i]=oldbigpal[3*no+i];
}


void setbigcolor(int n,unsigned int r,unsigned int v,unsigned int b)
{
	unsigned int t[3];

	t[0]=r;
	t[1]=v;
	t[2]=b;
	setbigpalette(n,1,t);
}

void getbigcolor(int n,unsigned int *r,unsigned int *v,unsigned int *b)
{
	unsigned int t[3];

	getbigpalette(n,1,t);
	*r=t[0];
	*v=t[1];
	*b=t[2];
}







/*****************************************************************/
/* gestion des 16 couleurs  */


void setcolor(int c)
{
	color=c&255;
	ma=tm[color&3];
	mb=tm[(color>>2)&3];
	mc=tm[(color>>4)&3];
	md=tm[(color>>6)&3];
}


void setpalette(unsigned int *pal)
{
	int i,r,v,b;

	for(i=0;i<16;i++) oldpal[i]=pal[i];

	if (video_proc==2)
	{
		for(i=0;i<16;i++)
			tmppal2[i]=pal[i]&0x0fff;
		xbios(84,0,16,tmppal2);
	}
	else
	{
		for(i=0;i<16;i++)
		{
			r=((pal[i]>>8)&15)*17;
			v=((pal[i]>>4)&15)*17;
			b=(pal[i]&15)*17;
			tmppal[i]=r*65536L+v*256L+(long)b;
		}
		xbios(93,0,16,tmppal);
	}

	refresh();
}


void getpalette(unsigned int *pal)
{
	int i;
	for(i=0;i<16;i++) pal[i]=oldpal[i];
}








/*****************************************************************/
/* instructions de gestion des ecrans graphiques */

void simplescreen(void)
{
	if (nbscreen==2)
	{
		tempo_pt_ecr=pt_ecr_travail;
		pt_ecr_travail=pt_ecr_actif;
		nbscreen=1;
	}
}


void doublescreen(void)
{
	if (nbscreen==1)
	{
		pt_ecr_travail=tempo_pt_ecr;
		nbscreen=2;
	}
}



static long swapscreen(void)
{
	while(*(unsigned long*)0x4baL==lastvbl);
	while(*(unsigned long*)0x4baL==lastvbl+1L);

	swaps2();
	return 0;
}


void swap(void)
{
	if (nbscreen==2)
	{
		Supexec(swapscreen);
		do {} while(swapflag);
	}
}


void refresh(void)
{
	Supexec(refreshscreen);
	do {} while(vblflag);
}

void copyscreen(void)
{
	hide();
	bmove((void *)pt_ecr_actif,(void *)pt_ecr_travail,128000L);
	show();
}









/******************************************************************/
/* instructions graphiques de base */

#define sgn(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define abs(x) ((x<0)?(-(x)):(x))


void pellipse(int x,int y,int lx,int ly,int c)
{
	register int i,r,a,s;
	register int ry=(ly+1)>>1;
	register int rx=lx>>1;

	if (c>=0) setcolor(c);
	for(i=0,a=64;i<ry;i++)
	{
		s=(int)(((long)(ry-i)<<14L)/ry);
		while(sn[a]>s) a++;
		r=rx+(int)((cs[a]*(long)rx)>>14L);
		hline(x+r,y+i,x+lx-1-r,-1);
		hline(x+r,y+ly-i-1,x+lx-1-r,-1);
	}
}


void pbox(int x,int y,int lx,int ly,int c)
{
	register int i;

	if (c>=0) setcolor(c);
	for(i=y;i<y+ly;i++) hline(x,i,x+lx-1,-1);
}




void rline(int x1,int y1,int x2,int y2,int c)
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
				a=((long)dy<<16L)/abs(dx);
				for(i=x1,y=32768L+((long)y1<<16L);i!=x2;i+=d,y+=a)
					plot(i,(int)(y>>16),-1);
			}
			else
			{
				d=sgn(dy);
				a=((long)dx<<16L)/abs(dy);
				for(i=y1,x=32768L+((long)x1<<16L);i!=y2;i+=d,x+=a) 
					plot((int)(x>>16),i,-1);
			}

			plot(x2,y2,-1);
		}

}



void dline(int x1,int y1,int x2,int y2,int c)
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
				a=((long)dy<<16L)/abs(dx);
				for(i=x1,y=32768L+((long)y1<<16L);i!=x2;i+=d,y+=a)
					plot(i,(int)(y>>16),-1);
			}
			else
			{
				d=sgn(dy);
				a=((long)dx<<16L)/abs(dy);
				for(i=y1,x=32768L+((long)x1<<16L);i!=y2;i+=d,x+=a) 
					plot((int)(x>>16),i,-1);
			}

			plot(x2,y2,-1);
		}

}


void dbox(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);
	hline(x,y,x+lx-1,-1);
	hline(x,y+ly-1,x+lx-1,-1);
	vline(x,y,y+ly-1,-1);
	vline(x+lx-1,y,y+ly-1,-1);
}





void plot(int x,int y,int c)
{
	register long *ptr;
	register unsigned long m,nm;

	if (c>=0) setcolor(c);
	ptr=(long *)(pt_ecr_travail+y*640L+(x&0xfff0L));
	nm=0x80008000L;
	nm>>=x&15;
	m=~nm;
	*(ptr++)=(*ptr&m)|(nm&ma);
	*(ptr++)=(*ptr&m)|(nm&mb);
	*(ptr++)=(*ptr&m)|(nm&mc);
	*(ptr++)=(*ptr&m)|(nm&md);
	ptr+=76;
	*(ptr++)=(*ptr&m)|(nm&ma);
	*(ptr++)=(*ptr&m)|(nm&mb);
	*(ptr++)=(*ptr&m)|(nm&mc);
	*(ptr++)=(*ptr&m)|(nm&md);
}


void vline(int x,int y,int y1,int c)
{
	register long *ptr;
	register unsigned long m,nm;
	register int dy=sgn(y1-y);
	register int i;

	if (c>=0) setcolor(c);
	if (!dy) dy++;
	ptr=(long *)(pt_ecr_travail+y*640L+(x&0xfff0L));
	nm=0x80008000L;
	nm>>=x&15;
	m=~nm;
	for(i=y;i!=y1+dy;i+=dy,ptr+=dy*160-84)
	{
		*(ptr++)=(*ptr&m)|(nm&ma);
		*(ptr++)=(*ptr&m)|(nm&mb);
		*(ptr++)=(*ptr&m)|(nm&mc);
		*(ptr++)=(*ptr&m)|(nm&md);
		ptr+=76;
		*(ptr++)=(*ptr&m)|(nm&ma);
		*(ptr++)=(*ptr&m)|(nm&mb);
		*(ptr++)=(*ptr&m)|(nm&mc);
		*(ptr++)=(*ptr&m)|(nm&md);
	}
}





void hline(int x,int y,int x1,int c)
{
	register long *ptr,*tmp;
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
	ptr=(long *)(pt_ecr_travail+y*640L+cx*16L);

	if (cx==cx1)
	{
		im=-1;
		im>>=(15-bx1+bx);
		im<<=(15-bx1);
		nm=im+((long)im<<16L);
		m=~nm;
		*(ptr++)=((*ptr)&m)|(nm&ma);
		*(ptr++)=((*ptr)&m)|(nm&mb);
		*(ptr++)=((*ptr)&m)|(nm&mc);
		*(ptr++)=((*ptr)&m)|(nm&md);
		ptr+=76;
		*(ptr++)=((*ptr)&m)|(nm&ma);
		*(ptr++)=((*ptr)&m)|(nm&mb);
		*(ptr++)=((*ptr)&m)|(nm&mc);
		*(ptr++)=((*ptr)&m)|(nm&md);
	}
	else
	{
		im=-1;
		im>>=bx;
		nm=im+((long)im<<16L);
		m=~nm;
		*(ptr++)=((*ptr)&m)|(nm&ma);
		*(ptr++)=((*ptr)&m)|(nm&mb);
		*(ptr++)=((*ptr)&m)|(nm&mc);
		*(ptr++)=((*ptr)&m)|(nm&md);
		ptr+=76;
		*(ptr++)=((*ptr)&m)|(nm&ma);
		*(ptr++)=((*ptr)&m)|(nm&mb);
		*(ptr++)=((*ptr)&m)|(nm&mc);
		*(ptr++)=((*ptr)&m)|(nm&md);
		ptr-=80;
		cx++;
		if (cx!=cx1)
		{
			tmp=ptr;
			for(i=cx;i<cx1;i++)
			{
				*(ptr++)=ma;
				*(ptr++)=mb;
				*(ptr++)=mc;
				*(ptr++)=md;
			}
			ptr=tmp+80;
			for(i=cx;i<cx1;i++)
			{
				*(ptr++)=ma;
				*(ptr++)=mb;
				*(ptr++)=mc;
				*(ptr++)=md;
			}
			ptr-=80;
		}
		im=-1;
		im<<=15-bx1;
		nm=im+((long)im<<16L);
		m=~nm;
		*(ptr++)=((*ptr)&m)|(nm&ma);
		*(ptr++)=((*ptr)&m)|(nm&mb);
		*(ptr++)=((*ptr)&m)|(nm&mc);
		*(ptr++)=((*ptr)&m)|(nm&md);
		ptr+=76;
		*(ptr++)=((*ptr)&m)|(nm&ma);
		*(ptr++)=((*ptr)&m)|(nm&mb);
		*(ptr++)=((*ptr)&m)|(nm&mc);
		*(ptr++)=((*ptr)&m)|(nm&md);
	}
}



void polyline(int n,int *tp,int c)
{
	register int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n-1;i++) rline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3],-1);
}


static void fplot(int x,int y)
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


static void fline(int x1,int y1,int x2,int y2)
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
			a=((long)dy<<16L)/abs(dx);
			for(i=x1,y=32768L+((long)y1<<16L);i!=x2;i+=d,y+=a)
				fplot(i,(int)(y>>16));
		}
		else
		{
			d=sgn(dy);
			a=((long)dx<<16L)/abs(dy);
			for(i=y1,x=32768L+((long)x1<<16L);i!=y2;i+=d,x+=a) 
				fplot((int)(x>>16),i);
		}

	fplot(x2,y2);

}





void polyfill(int n,int *tp,int c)
{
	register int i;

	if (c>=0) setcolor(c);
	
	for(i=0;i<200;i++) ftab[i]= -1;
	for(i=0;i<n-1;i++) fline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3]);
}















/******************************************************************/
/* instructions d'allocation memoire */



long ramfree(void)
{
	long r;
	r=(long)gemdos(0x48,-1L);
	return(r);
}


void memfree(void **adr)
{
	if (*adr)
	{
		free((void *)*adr);
		*adr=0L;
	}
}


void *memalloc(long size)
{
	return((void *)malloc((size_t) size));
}










/*****************************************************************/
/* instructions de transfert de blocs */

void *bmsce;
void *bmdst;
long bmlen;

void bmove(void *sce,void *dst,long len)
{
	bmsce=sce;
	bmdst=dst;
	bmlen=len;
	
	if (sce>dst) bmovea(); else bmoveb();
	
}












/******************************************************************/
/* instructions de gestion de l'horloge */

static long picktime(void)
{
	ltime=*(unsigned long *)0x4baL;
	ltime+=(ltime<<2L);
	return 0;
}

unsigned long systime(void)
{
	Supexec(picktime);
	return(ltime);
}

void waitdelay(unsigned int n)
{
	unsigned long start;

	start=systime();
	do {} while((systime()-start)<(unsigned long)n);
}












/******************************************************************/
/* fonctions aleatoires */

int randint(void)
{
	return((int)xbios(17)&0x7fff);
}

int randval(int n)
{
	return(randint()%n);
}















/*****************************************************************/
/* gestion de fichiers */

static void verifnom(char *s,char *s2)
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



int bexist(char *nom)
{
	int r;
	char nom2[200];

	verifnom(nom,nom2);
	gemdos(0x1a,dta);
	r=(int)gemdos(0x4e,nom2,0);
	if (!r) r=1; else r=0;
	return(r);
}

long bsize(char *nom)
{
	long s=0L;

	if (bexist(nom))
	s=dta[26]*256L*65536L+dta[27]*65536L+dta[28]*256L+(long)dta[29];
	return(s);
}

int bload(char *nom,void *adr,long offset,long len)
{
	int fd;
	char nom2[200];

	verifnom(nom,nom2);
	fd=(int)gemdos(0x3d,nom2,0);
	if (fd>0)
	{
		gemdos(0x42,offset,fd,1);
		gemdos(0x3f,fd,len,adr);
		gemdos(0x3e,fd);
		fd=0;
	}
	return(fd);
}

int bsave(char *nom,void *adr,long offset,long len)
{
	int fd;
	int r=0;
	char nom2[200];

	verifnom(nom,nom2);
	fd=(int)gemdos(0x3d,nom2,2);
	if (fd>0)
	{
		gemdos(0x42,offset,fd,1);
		r=(int)gemdos(0x40,fd,len,adr);
		if (r==-1) r=-13;
		gemdos(0x3e,fd);
		fd=0;
	}
	if (r<0) fd=r;
	return(fd);
}



int bmake(char *nom,void *adr,long len)
{
	int fd;
	int r=0;
	char nom2[200];

	verifnom(nom,nom2);
	gemdos(0x1a,dta);
	r=(int)gemdos(0x4e,nom2,0);
	if (r==-33) r=0;
	if (!r)
	{
		fd=(int)gemdos(0x3c,nom2,0);
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





int bopen(char *nom)
{
	int fd;
	char nom2[200];

	verifnom(nom,nom2);
	fd=(int)gemdos(0x3d,nom2,0);
	if (fd<=0) fd=-1;
	return(fd);
}


int bcreate(char *nom)
{
	int fd;
	char nom2[200];

	verifnom(nom,nom2);
	fd=(int)gemdos(0x3c,nom2,0);
	if (fd<=0) fd=-1;
	return(fd);
}



int bread(int fd,void *adr,long len)
{
	int r=0;

	r=(int)gemdos(0x3f,fd,len,adr);
	return(r);
}


int bwrite(int fd,void *adr,long len)
{
	int r=0;

	r=(int)gemdos(0x40,fd,len,adr);
	return(r);
}



int bclose(int fd)
{
	int r=0;

	r=(int)gemdos(0x3e,fd);
	return(r);
}


















/*************************************************************/
/* gestion de la souris et du clavier */


int kbhit(void)
{
#ifdef KEYMAP
	return(nbrkbuffer);
#else
	return((int)bios(1,2));
#endif
}

int buthit(void)
{
	return(nbrbuffer);
}

int keyhit(void)
{
	return(buthit()|kbhit());
}

char getch(void)
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


void empty(void)
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

void confirm(void)
{
	empty();
	do {} while (!buthit());
}

int getmouse(void)
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



void hide(void)
{
	if (mouselevel==0)
	{
		endflag=1;
		do {} while(mousemode);
	}
	mouselevel-=1;
}

void show(void)
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


void initbloc(void **blocptr)
{
	pixbloc *bloc;
	*blocptr=memalloc((long)sizeof(pixbloc));
	bloc=(pixbloc *)*blocptr;
	if (*blocptr) bloc->id=0;
}


void freebloc(void **blocptr)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id) memfree((void **)&bloc->bloc);
		if (bloc->id==2) memfree((void **)&bloc->mask);
		bloc->id=0;
		memfree(blocptr);
	}
}



void getbloc(void **blocptr,int x,int y,int lx,int ly)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if ((!bloc->id)||(bloc->lx!=lx)||(bloc->ly!=ly))
		{
			if (bloc->id) memfree((void **)&bloc->bloc);
			if (bloc->id==2) memfree((void **)&bloc->mask);
			bloc->id=0;
			bloc->bloc=(long)memalloc((8L*ly)*(lx/8L));
			if (bloc->bloc)
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}


		if (bloc->id)
		{
			matrice=bloc->bloc;
			ecran=pt_ecr_travail+((long)x)+y*640L;
			haut=ly-1;
			larg=(lx/16)-1;
			recal=(char*)(320+8*(40-(lx/8)));
			
			getbloca();
		}
	}
}



void copybloc(void **blocptrs,int xs,int ys,int lxs,int lys,
					void **blocptrd,int xd,int yd)
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
			matrice=blocs->bloc+((long)xs)+ys*(long)(blocs->lx);
			matrice2=blocd->bloc+((long)xd)+yd*(long)(blocd->lx);
			haut=lys-1;
			larg=(lxs/16)-1;
			recal=(char*)(blocs->lx-lxs);
			recal2=(char*)(blocd->lx-lxs);

			copyba();


			if ((blocs->id==2)&&(blocd->id==2))
			{
				masque=blocs->mask+xs/8L+ys*(blocs->lx/8L);
				masque2=blocd->mask+xd/8L+yd*(blocd->lx/8L);
				haut=lys-1;
				larg=(lxs/16)-1;
				recal=(char*)((blocs->lx-lxs)/8);
				recal2=(char*)((blocd->lx-lxs)/8);

				copybb();

			}

		}
	}
}




void putpbloc(void **blocptr,int x,int y,int xs,int ys,
					int lxs,int lys)
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
			matrice=bloc->bloc+((long)xs)+ys*(long)(bloc->lx);
			ecran=pt_ecr_travail+(long)(x&0xfff0)+y*640L;
			recal2=(char*)(bloc->lx-lxs);

			if (dec)
			{
				haut=lys;
				larg=lxs/16;
				recal=(char*)(320+8*(38-(lxs/8)));

				putpba();
				
			}
			else
			{
				haut=lys-1;
				larg=(lxs/16)-1;
				recal=(char*)(320+8*(40-(lxs/8)));

				if (fmask) putpbb(); else putpbc();
				

			}
		}


	}
}



void putbloc(void **blocptr,int x,int y)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		putpbloc(blocptr,x,y,0,0,bloc->lx,bloc->ly);
	}
}


void getmask(void **blocptr,int x,int y)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id)
		{
			if (bloc->id==2)
			{
				memfree((void **)&bloc->mask);
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
				ecran=pt_ecr_travail+((long)x)+y*640L;
				haut=bloc->ly-1;
				larg=(bloc->lx/16)-1;
				recal=(char*)(320+8*(40-(bloc->lx/8)));

				getmaska();
			

			}


		}
	}
}













/*****************************************************************/
/* instructions de gestion de fonte */


void affchar(int x,int y,char c)
{
	unsigned int n;

	if ((c>31)&&(c<=126))
	{
		if (c>95) c-=32;
		n=c-32;

		dec=x&15;
		tmask=tmasque[dec];
		haut=8;
		ntmask=~tmask;
		matrice=(long)&sysfonte[n*16];
		ecran=pt_ecr_travail+(x&0xfff0)+y*640L;

		pma=(int)(ma>>16);
		pmb=(int)(ma&0xffff);
		pmc=(int)(mb>>16);
		pmd=(int)(mb&0xffff);
		pme=(int)(mc>>16);
		pmf=(int)(mc&0xffff);
		pmg=(int)(md>>16);
		pmh=(int)(md&0xffff);

		if (dec)
		{
			recal=(char*)(320+8*36);
			affchara();
		}
		else
		{
			recal=(char*)(320+8*38);
			affcharb();
		}
	}
}



void afftext(int x,int y,char *s)
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



void printchar(char c)
{
	int t;

	while(ycur>192)
	{
		ycur-=8;
		bmove((void *)(pt_ecr_travail+2*8*320L),(void *)pt_ecr_travail,2*192*320L);
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


void print(char *s)
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

long spl_tab[384]=
{
	0x8000900L,0xA000801L,0x9000A00L,0x8010901L,0xA000802L,0x9010A00L,
	0x8010901L,0xA010802L,0x9020A01L,0x8020902L,0xA020803L,0x9020A02L,
	0x8030903L,0xA020803L,0x9030A03L,0x8040903L,0xA030804L,0x9040A02L,
	0x8040904L,0xA030804L,0x9040A04L,0x8050905L,0xA020805L,0x9040A04L,
	0x8050905L,0xA040806L,0x9050A02L,0x8050905L,0xA050806L,0x9050A04L,
	0x8060906L,0xA020806L,0x9050A05L,0x8060906L,0xA040806L,0x9060A05L,
	0x8070905L,0xA050807L,0x9060A04L,0x8060906L,0xA060808L,0x9050A04L,
	0x8070907L,0xA040807L,0x9060A06L,0x8080906L,0xA040808L,0x9060A05L,
	0x8070907L,0xA060808L,0x9070A04L,0x8080906L,0xA060807L,0x9070A07L,
	0x8080908L,0xA020808L,0x9070A06L,0x8080908L,0xA040808L,0x9070A07L,
	0x8090906L,0xA060808L,0x9080A06L,0x8090908L,0xA020809L,0x9070A06L,
	0x8080908L,0xA070809L,0x9070A07L,0x8090909L,0xA000809L,0x9080A06L,
	0x8090909L,0xA020808L,0x9080A08L,0x8090908L,0xA070809L,0x9090A05L,
	0x80A0908L,0xA010809L,0x9090A06L,0x80A0908L,0xA040809L,0x9080A08L,
	0x8090909L,0xA07080AL,0x9090A00L,0x80A0908L,0xA06080AL,0x9090A03L,
	0x8090909L,0xA08080AL,0x9090A05L,0x80B0907L,0xA04080AL,0x9090A06L,
	0x80B0908L,0xA01080AL,0x9080A08L,0x8090909L,0xA09080AL,0x90A0A00L,
	0x80A090AL,0xA01080AL,0x90A0A02L,0x80A0909L,0xA08080AL,0x90A0A05L,
	0x80B0908L,0xA07080AL,0x90A0A06L,0x80C0901L,0xA01080AL,0x9090A09L,
	0x80A090AL,0xA07080BL,0x9080A08L,0x80B0909L,0xA07080BL,0x90A0A00L,
	0x80A090AL,0xA08080BL,0x90A0A03L,0x80B0909L,0xA08080BL,0x90A0A05L,
	0x80C0907L,0xA03080AL,0x90A0A09L,0x80C0906L,0xA06080BL,0x9090A09L,
	0x80C0907L,0xA06080CL,0x9080A04L,0x80C0907L,0xA07080BL,0x90A0A08L,
	0x80B090BL,0xA02080AL,0x90A0A0AL,0x80B090BL,0xA05080BL,0x90A0A09L,
	0x80B090BL,0xA06080CL,0x9090A06L,0x80B090BL,0xA07080CL,0x9090A07L,
	0x80C090AL,0xA00080CL,0x90A0A00L,0x80B090BL,0xA08080CL,0x9090A08L,
	0x80B090AL,0xA0A080CL,0x90A0A05L,0x80B090BL,0xA09080DL,0x9040A03L,
	0x80C0909L,0xA09080DL,0x9050A04L,0x80D0905L,0xA05080DL,0x9060A04L,
	0x80C090AL,0xA08080CL,0x90B0A00L,0x80C090BL,0xA02080BL,0x90B0A0AL,
	0x80C090AL,0xA09080CL,0x90B0A06L,0x80D0907L,0xA07080CL,0x90B0A07L,
	0x80D0908L,0xA06080DL,0x9090A02L,0x80C090BL,0xA08080DL,0x9090A05L,
	0x80B090BL,0xA0B080DL,0x9080A08L,0x80C090BL,0xA09080CL,0x90B0A09L,
	0x80D0909L,0xA08080DL,0x9090A08L,0x80D090AL,0xA02080DL,0x90A0A04L,
	0x80D090AL,0xA05080CL,0x90B0A0AL,0x80C090CL,0xA01080CL,0x90C0A03L,
	0x80C090CL,0xA05080CL,0x90C0A06L,0x80C090CL,0xA07080DL,0x90B0A00L,
	0x80D090BL,0xA00080CL,0x90C0A08L,0x80C090BL,0xA0B080DL,0x90B0A06L,
	0x80C090CL,0xA09080CL,0x90C0A09L,0x80C090CL,0xA09080DL,0x90A0A0AL,
	0x80D090AL,0xA0A080DL,0x90A0A0AL,0x80D090BL,0xA09080DL,0x90B0A09L,
	0x80C090CL,0xA0A080CL,0x90C0A0AL,0x80C090CL,0xA0A080DL,0x90B0A0AL,
	0x80D090BL,0xA0A080DL,0x90B0A0AL,0x80D090BL,0xA0A080CL,0x90C0A0BL,
	0x80C090CL,0xA0B080DL,0x90C0A02L,0x80D090CL,0xA05080DL,0x90C0A06L,
	0x80E0900L,0xA00080DL,0x90B0A0BL,0x80D090CL,0xA08080EL,0x9040A04L,
	0x80E0905L,0xA05080DL,0x90C0A09L,0x80E0906L,0xA06080EL,0x9070A05L,
	0x80E0908L,0xA00080EL,0x9070A07L,0x80E0908L,0xA06080DL,0x90C0A0AL,
	0x80C090CL,0xA0C080EL,0x9090A01L,0x80E0908L,0xA08080EL,0x9090A07L,
	0x80E0909L,0xA08080EL,0x9090A08L,0x80D090CL,0xA0B080EL,0x9090A09L,
	0x80E0909L,0xA09080EL,0x90A0A04L,0x80D090DL,0xA00080DL,0x90D0A04L,
	0x80D090DL,0xA07080DL,0x90D0A08L,0x80E090AL,0xA09080DL,0x90D0A09L,
	0x80D090DL,0xA09080EL,0x90B0A00L,0x80E090BL,0xA00080EL,0x90B0A07L,
	0x80D090DL,0xA0A080DL,0x90C0A0CL,0x80E090BL,0xA09080EL,0x90B0A09L,
	0x80E090BL,0xA09080DL,0x90D0A0BL,0x80D090DL,0xA0B080DL,0x90D0A0BL,
	0x80E090BL,0xA0A080EL,0x90B0A0AL,0x80E090BL,0xA0A080EL,0x90B0A0BL,
	0x80E090BL,0xA0B080EL,0x90B0A0BL,0x80E090BL,0xA0B080EL,0x90C0A00L,
	0x80E090CL,0xA00080EL,0x90C0A05L,0x80E090CL,0xA09080EL,0x90C0A09L,
	0x80D090DL,0xA0C080DL,0x90D0A0CL,0x80E090CL,0xA0A080EL,0x90C0A0AL,
	0x80E090CL,0xA0A080EL,0x90C0A0AL,0x80E090CL,0xA0B080EL,0x90C0A0BL,
	0x80E090CL,0xA0B080EL,0x90C0A0BL,0x80E090CL,0xA0B080EL,0x90C0A0BL,
	0x80E090CL,0xA0B080EL,0x90C0A0BL,0x80D090DL,0xA0D080DL,0x90D0A0DL,
	0x80D090DL,0xA0D080DL,0x90D0A0DL,0x80D090DL,0xA0D080DL,0x90D0A0DL,
	0x80E090DL,0xA00080EL,0x90C0A0CL,0x80E090DL,0xA0A080EL,0x90D0A0AL,
	0x80E090DL,0xA0A080EL,0x90D0A0AL,0x80E090DL,0xA0B080EL,0x90D0A0BL,
	0x80E090DL,0xA0B080EL,0x90D0A0BL,0x80E090DL,0xA0B080EL,0x90D0A0BL,
	0x80E090DL,0xA0B080FL,0x9030A00L,0x80F0903L,0xA00080FL,0x9030A00L,
	0x80F0903L,0xA00080FL,0x9030A00L,0x80F0903L,0xA00080EL,0x90D0A0CL
};












/*******************************************************************/
/* gestion des samples */

void *psadr;
long pslen;
int psn;
int psv;
int psf;

void playsample(void *adr,long len,long freq)
{
	if (snd_cookie&2L)
	{
		Supexec(stop_dma);
		dmalen=len;
		pcm=(long)adr;
		dmafreq=1;                  /* 12.5 khz */
		if (freq>18000L) dmafreq=2; /* 25 khz */
		if (freq>37000L) dmafreq=3; /* 50 khz */
		Supexec(start_dma);
	}
	else
	if (snd_cookie&1L)
	{
		psadr=adr;
		pslen=len;

		psn=1;
		psv=15;
		psf=(int)freq;

		psv=(15-psv)>>1;

		playsa();
	}
}



void stopsample(void)
{
	if (snd_cookie&2L)
		Supexec(stop_dma);
	else
		if (snd_cookie&1L)
			playsample(0L,0L,0L);
}


void fixsample(void *adr,long len)
{
	long i;
	char *ptr;

	ptr=(char *)adr;	
	for(i=0L;i<len;i++) *(ptr++)-=128;
}
 
 
