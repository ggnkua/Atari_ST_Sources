/* pcvga.c : module de base pour PC a faible capacite mais vitesse elevee
	pour VGA 256 couleurs. A linker avec pcvga2.obj (tasm /mx pcvga2.asm)

	Guillaume LAMONOCA
	Supelec (94)

	Utiliser Turbo C.
	Compiler en modele LARGE ou HUGE. (huge) pour les pointeurs "balladeurs".

	Ram limitee a 640 ko.

	En maintenant E enfonce on simule la souris avec le pave numerique:
		1-9: deplacement souris
		'/': bouton gauche
		'*': bouton droit

	L'affichage du curseur de la souris est mis a jour a chaque appel
	des fonctions swap() et refresh(), getch(), hide(), show() et confirm().
	La fonction waitdelay() utilise refresh() pour que la souris soit raffraichie.

	Ce module de base est 100% compatible avec les autres.

	Mais il contient de nouvelles fonctions pour gerer les 256 couleurs:
	(dans le header definir EXTENSION). SVP ne pas utiliser ces fonctions pour
	des programmes domaine public: restez compatibles avec 16 couleurs (merci).

	Attention: Les sprites (blocs graphiques ayant un masque) ne peuvent pas
	utiliser la couleur no 255!

	Pour les samples le module utilise un petit fichier de configuration
	"SPEECH.CFG". Pour modifier le choix du speech device, il suffit
	d'effacer ce fichier (Le module en produira un nouveau).
	Si le sample depasse 64Ko, le surplus n'est pas joue.

	Vous pouvez definir DOUBLELIGNES pour avoir 400 lignes au lieu de 200
	(SVP ne pas utiliser cette option pour des softs domaine public.merci)

	Attention: a cause de la segmention les fichiers sont limites a 64ko.
	 De meme les blocs graphiques ne doivent pas etre trop grands (lx*ly<65536).
*/

#include <alloc.h>
#include <dos.h>
#include <mem.h>
#include "header.h"


extern void initkbd();
extern void killkbd();
extern void inithp();
extern void initspl();
extern void freqspl();
extern void killspl();
extern void sendinit(int);
extern void itmouse();
extern void killmse();

extern void putplane(long,long,int,int,int,int);
extern void getplane(long,long,int,int,int,int);
extern void putsplane(long,long,int,int,int,int);
extern void getsplane(long,long,int,int,int,int);











/********************************************************************/
/* variables globales */


static int vp=0;
static int nbscreen=2;
static long pt_ecran_actif,pt_ecran_travail,tempo_pt_ecran;

int mousex,mousey,mousek,vblclock;
int msex,msey,msek,mclk;

int nbrbuffer=0;
int msebufptr=0;
static int lstbufptr=0;
static int oldvp,oldx,oldy;
static int oldmselevel= -1;
static int mouselevel= -1;

int statek=0;
char bufferflag=1;
char kbufferflag=1;

static char color=15;

static xcur=0;
static ycur=0;

#ifdef DOUBLELIGNES
#define NBLIGNES 400
#define ECRTAILLE 0x8000L
#else
#define NBLIGNES 200
#define ECRTAILLE 0x4000L
#endif

static int filltab[NBLIGNES];
static unsigned int oldpal[16];
static unsigned int oldvgapal[3*256];

static unsigned int egapal[16]=
 {
	 0x0000,0x1008,0x3080,0x5088,
	 0x2800,0x3808,0x4880,0x5ccc,
	 0x3888,0x400f,0x50f0,0x60ff,
	 0x4f00,0x5f0f,0x7ff0,0x8fff
 };


int msebuffer[128];
static void *mousebloc;
static void *mousefond;
static char defaultmouse[256]=
{
0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x0f,0x0f,0x0f,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x0f,0x00,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x0f,0x00,0xff,0x00,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0x00,0xff,0xff,0x00,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0x00,0xff,0xff,0xff,0xff,0x00,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0x00,0x0f,0x0f,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff
};


char keymap[256]=
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

char keybuffer[256];
int keybufptr=0;
int keybufend=0;
int keybufnbr=0;

unsigned char codekey[256]=
{
	0,27,'1','2','3','4','5','6','7','8','9','0',')','=',8,0,
	'a','z','e','r','t','y','u','i','o','p','^','$',13,0,'q','s',
	'd','f','g','h','j','k','l','m','%',0,0,'*','w','x','c','v',
	'b','n',',',';',':','!',0,'*',0,' ',0,0,0,0,0,0,
	0,0,0,0,0,0,0,'7','8','9','-','4','5','6','+','1',
	'2','3','0','.',0,0,'<',0,0,0,0,0,0,0,0,0,
	0,0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3',
	'0','.',13,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'/',0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,'^',0,0,'<',0,'>',0,0,'v',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

static unsigned char codeat[256]=
{
	0,27,'1','2','3','4','5','6','7','8','9','0','-','=','\\',8,
	0,'a','z','e','r','t','y','u','i','o','p','^','$',0,0,'q',
	's','d','f','g','h','j','k','l','m','%',13,0,0,'<','w','x',
	'c','v','b','n',',',';',':','!',0,0,0,0,0,' ',0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,27,0,'<',0,0,'/',
	'^',0,'v',0,'*',0,'>',0,'.',0,'*','-','+',0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

static unsigned char codepcxt[256]=
{
	0,27,'1','2','3','4','5','6','7','8','9','0',')','=',8,0,
	'a','z','e','r','t','y','u','i','o','p','^','$',13,0,'q','s',
	'd','f','g','h','j','k','l','m','%',0,'*','<','w','x','c','v',
	'b','n',',',';',':','!',0,'*',0,' ',0,0,0,0,0,0,
	0,0,0,0,0,'/','*',0,'^',0,'-','<',0,'>','+',0,
	'v',0,0,'.',0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

















/********************************************************************/
/* fontes */

static unsigned int sysfonte[64*16]=
{
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















/*****************************************************************/
/* instructions de programmation du processeur VGA               */


#define MAP_MASK 2
#define MEM_MODE 4

#define READ_MAP_SELECT 4
#define GRAPHICS_MODE 5
#define MISCELL_MODE 6

#define MAX_SCAN 9
#define UNDERLINE 0x14
#define MODE_CTRL 0x17


#define wmap(n)	outport(0x3c4,MAP_MASK+(256<<(n)))
#define rmap(n) outport(0x3ce,READ_MAP_SELECT+((n)<<8))
#define wall() outport(0x3c4,MAP_MASK+256*15)
#define wbit(n) outport(0x3c4,MAP_MASK+((n)<<8))

static char oldmode;

static void copymode_on(void)
{
	outportb(0x3ce,GRAPHICS_MODE);
	oldmode=inportb(0x3cf);
	outportb(0x3cf,(inportb(0x3cf)&0xfc)|1);
	wall();
}

static void copymode_off(void)
{
	outportb(0x3cf,oldmode);
}

















/************************************************************/
/* initialisation du systeme */

int sndblast=0;
int dacport=0;
int speaker=0;



static void setvisual(int n)
{
	register int a,b;
	long ptr;

	ptr=pt_ecran_actif=0xa0000000L+n*0x00008000L;
	a=(int)(ptr>>8)&255;
	b=(int)ptr&255;
	a=(a<<8)+12;
	b=(b<<8)+13;

	outport(0x3d4,b);
	outport(0x3d4,a);
}

static void settravail(int n)
{
	pt_ecran_travail=0xa0000000L+n*0x00008000L;
}



static int initscreen(void)
{
	int r=0;
	union REGS Regs;

	Regs.x.ax=0x1a00;
	int86(0x10,&Regs,&Regs);

	if (Regs.h.al==0x1a)
	{

		_AH=0;
		_AL=0x13;
		geninterrupt(0x10);


		outportb(0x3ce,GRAPHICS_MODE);
		outportb(0x3cf,inportb(0x3cf)&0xef);
		outportb(0x3ce,MISCELL_MODE);
		outportb(0x3cf,inportb(0x3cf)&0xfd);
		outportb(0x3c4,MEM_MODE);
		outportb(0x3c5,(inportb(0x3c5)&0xf7)|4);

		memset((void *)0xa0000000L,0,0xffff);

#ifdef DOUBLELIGNES
		outportb(0x3d4,MAX_SCAN);
		outportb(0x3d5,inportb(0x3d5)&0x70);
#endif

		outportb(0x3d4,UNDERLINE);
		outportb(0x3d5,inportb(0x3d5)&0xbf);
		outportb(0x3d4,MODE_CTRL);
		outportb(0x3d5,inportb(0x3d5)|0x40);


		settravail(1-vp);
		setvisual(vp);

		setpalette(egapal);

		r=1;
	}

	return r;
}




static int testce(void)
{
	union REGS regs;

	regs.x.ax=0x1200;
	int86(0x16,&regs,&regs );
	return (regs.x.ax!=0x1200);
}


int initsystem(void)
{
	int r=0;
	int i,j;
	unsigned char m;
	int cfg[3];

	srand(*(int *)0x0040006cL);

	clrscr();

	m=*(unsigned char *)0xf000fffeL;
	if ((m==0xfe)||(m==0xfb)||(m==0xff))
		for(i=0;i<256;i++) codekey[i]=codepcxt[i];

	if ((m==0xfc)&&(!testce()))
		for(i=0;i<256;i++) codekey[i]=codeat[i];

	initkbd();

	if (bexist("speech.cfg"))
	{
		bload("speech.cfg",cfg,0L,6L);
		sndblast=cfg[0];
		dacport=cfg[1];
		speaker=cfg[2];
	}
	else
	{
		printf("VGA 256Ko card required.\n\n");
		printf("   SPEECH.CFG not found. Creating it...\n");
		printf("   Erase it if you want to modify speech device.\n\n");
		printf("   Please select your speech device:\n\n");
		printf("0: no sound\n");
		printf("1: internal speaker  (only efficient on fast computers)\n");
		printf("2: soundblaster card (22ch)\n");
		printf("3: soundmaster+ card (22fh)\n");
		printf("4: card using 'LPT1' (%xh)\n",*(int *)0x00400008L);
		printf("5: modify soundblaster base address\n");
		printf("6: other DAC port\n");

		do
		{
			r=getch();
			if ((r>47)&&(r<55)) r-=48; else r=-1;
		}
		while(r==-1);

		if (r==1) { dacport=0x42; speaker=1; }
		if (r==2) { dacport=0x22c; sndblast=1; }
		if (r==3) dacport=0x22f;
		if (r==4) dacport=*(int *)0x00400008L;
		if (r==5) sndblast=1;

		if (r>4)
		{
			if (r==5) printf("soundblaster DAC port is base address + 00c\n");
			else printf("Enter your EXACT DAC port (base address + correct offset)\n");

			do
			{
				printf("Enter your DAC port:");
				dacport=0;
				for(i=0;i<3;i++)
				{
					do
					{
						r=getch();
						if ((r>47)&&(r<58)) r-=48; else
						if ((r>96)&&(r<103)) r-=87; else
						if ((r>64)&&(r<71)) r-=55; else r=-1;
						if (r!=-1) if (r<10) printf("%c",r+48); else printf("%c",r+55);
					}
					while(r==-1);
					dacport=dacport*16+r;
				}
				printf("\nIs %xh correct? (Yes/No)\n",dacport);
				r=getch();
			}
			while((r!='y')&&(r!='Y'));
		}


		cfg[0]=sndblast;
		cfg[1]=dacport;
		cfg[2]=speaker;
		bmake("speech.cfg",cfg,6L);
	}

	if (initscreen())
	{
		initmouse();
		if (sndblast) sendinit(0xd1);
		if (speaker) inithp();
		if (dacport) initspl();
		r=1;

		for(i=0;i<16;i++)
			for(j=0;j<16;j++)
			{
				m=defaultmouse[i*16+j];
				plot(j,i,(int)m);
				if (m==255) plot(j,i+16,0);
					else plot(j,i+16,255);
			}

		initbloc(&mousefond);
		initbloc(&mousebloc);
		getbloc(&mousebloc,0,0,16,16);
		getmask(&mousebloc,0,16);

		cls();
		show();
	}
	else
	{
		killkbd();
		printf("\nVGA card not found.\n");
	}

	return r;
}



void killsystem(void)
{
	freebloc(&mousebloc);
	freebloc(&mousefond);
	if (dacport) killspl();
	if (sndblast) sendinit(0xd3);
	if (speaker) nosound();
	killmse();
	killkbd();
	textmode(3);
}

















/************************************************************/
/* gestion des couleurs */


void setcolor(int c)
{
	color=(char)(c&255);
}


void setvgacolor(int n,int r,int v,int b)
{
	_AH=0x10;
	_AL=0x10;
	_BX=n;
	_CH=v;
	_CL=b;
	_DH=r;
	geninterrupt(0x10);
}

void getvgacolor(int n,int *r,int *v,int *b)
{
	_AH=0x10;
	_AL=0x15;
	_BX=n;
	geninterrupt(0x10);
	*v=_CH;
	*b=_CL;
	*r=_DH;
}


void setvgapalette(int no,int nb,char *ptr)
{
	union REGS r;
	struct SREGS rs;

	do {} while(!(inportb(0x3da)&8));

	r.h.ah=0x10;
	r.h.al=0x12;
	r.x.bx=no;
	r.x.cx=nb;
	rs.es=FP_SEG(ptr);
	r.x.dx=FP_OFF(ptr);
	int86x(0x10,&r,&r,&rs);
}

void getvgapalette(int no,int nb,char *ptr)
{
	union REGS r;
	struct SREGS rs;

	r.h.ah=0x10;
	r.h.al=0x17;
	r.x.bx=no;
	r.x.cx=nb;
	rs.es=FP_SEG(ptr);
	r.x.dx=FP_OFF(ptr);
	int86x(0x10,&r,&r,&rs);
}


void setbigcolor(int n,unsigned int r,unsigned int v,unsigned int b)
{
	setvgacolor(n,r>>10,v>>10,b>>10);
	oldvgapal[n*3]=r;
	oldvgapal[n*3+1]=v;
	oldvgapal[n*3+2]=b;
}

void getbigcolor(int n,unsigned int *r,unsigned int *v,unsigned int *b)
{
	*r=oldvgapal[n*3];
	*v=oldvgapal[n*3+1];
	*b=oldvgapal[n*3+2];
}

void setbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;
	unsigned char vgapal[256*3];

	if (nb<=256)
	{
		for(i=no*3;i<3*(no+nb);i++) oldvgapal[i]=ptr[i];
		for(i=0;i<3*nb;i++) vgapal[i]=ptr[i]>>10;
		setvgapalette(no,nb,vgapal);
	}
}

void getbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;

	if (nb<=256)
		for(i=no*3;i<3*(no+nb);i++) ptr[i]=oldvgapal[i];
}


void getpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) pal[i]=oldpal[i];
}


void setpalette(unsigned int *pal)
{
	int i,r,v,b;
	char vgapal[48];

	for(i=0;i<16;i++)
	{
		oldpal[i]=pal[i];
		r=(pal[i]&0xf00)>>8;
		v=(pal[i]&0xf0)>>4;
		b=pal[i]&15;
		vgapal[3*i]=(r<<2)+(r>>2);
		vgapal[3*i+1]=(v<<2)+(v>>2);
		vgapal[3*i+2]=(b<<2)+(b>>2);
	}

	setvgapalette(0,16,vgapal);
}













/************************************************************/
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



void cls(void)
{
	wall();

	memset((void *)pt_ecran_travail,0,ECRTAILLE);

	xcur=ycur=0;
}




static void refreshmouse(void)
{
	int p=1;
	int x,y,k;

	if (oldmselevel>=0)
	{
		x=oldx;
		y=oldy;
		settravail(oldvp);
		putbloc(&mousefond,x&0xfffc,y);
	}

	if (mouselevel>=0)
	{
		x=mousex;
		y=mousey;
		settravail(vp);
		if (x&3)
			getbloc(&mousefond,x&0xfffc,y,20,16);
		else
			getbloc(&mousefond,x,y,16,16);
		putbloc(&mousebloc,x,y);
		oldx=x;
		oldy=y;
		oldvp=vp;
	}

	oldmselevel=mouselevel;

	vblclock++;

	if (nbscreen==2)
		settravail(1-vp);
	else
		settravail(vp);

	if (keymap['e'])
	{
		if (keymap['7']) movemouse(mousex-p,mousey-p);
		if (keymap['8']) movemouse(mousex+0,mousey-p);
		if (keymap['9']) movemouse(mousex+p,mousey-p);
		if (keymap['4']) movemouse(mousex-p,mousey+0);
		if (keymap['6']) movemouse(mousex+p,mousey+0);
		if (keymap['1']) movemouse(mousex-p,mousey+p);
		if (keymap['2']) movemouse(mousex+0,mousey+p);
		if (keymap['3']) movemouse(mousex+p,mousey+p);

		k=keymap['/']+2*keymap['*'];
		if ((k&1)&&(!(mousek&1))) addbut(65,mousex,mousey,vblclock);
		if ((!(k&1))&&(mousek&1)) addbut(64,mousex,mousey,vblclock);
		if ((k&2)&&(!(mousek&2))) addbut(130,mousex,mousey,vblclock);
		if ((!(k&2))&&(mousek&2)) addbut(128,mousex,mousey,vblclock);
		mousek=k;
	}


}


void refresh(void)
{
	setvisual(vp);
	do {} while((inportb(0x3da)&8));
	do {} while(!(inportb(0x3da)&8));
	refreshmouse();
}



void swap(void)
{
	if (nbscreen==2) vp=1-vp;
	setvisual(vp);
	do {} while((inportb(0x3da)&8));
	do {} while(!(inportb(0x3da)&8));
	refreshmouse();
}




void copyscreen(void)
{
	if (nbscreen==2)
	{
		hide();
		copymode_on();
		bmove((void *)pt_ecran_actif,(void *)pt_ecran_travail,ECRTAILLE);
		copymode_off();
		show();
	}
}



















/******************************************************************/
/* instructions graphiques de base */


#define SGN(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define ABS(x) ((x<0)?(-(x)):(x))


void pellipse(int x,int y,int lx,int ly,int c)
{
	register int i,r,a,s;
	register int ry=(ly+1)>>1;
	register int rx=lx>>1;

	if (c>=0) setcolor(c);
	for(i=0,a=64;i<ry;i++)
	{
		s=(int)(((long)(ry-i)<<14)/ry);
		while(sn[a]>s) a++;
		r=rx+(int)((cs[a]*(long)rx)>>14);
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

			if (ABS(dx)>ABS(dy))
			{
				d=SGN(dx);
				a=((long)dy<<16)/ABS(dx);
				for(i=x1,y=32768L+((long)y1<<16);i!=x2;i+=d,y+=a)
					plot(i,(int)(y>>16),-1);
			}
			else
			{
				d=SGN(dy);
				a=((long)dx<<16)/ABS(dy);
				for(i=y1,x=32768L+((long)x1<<16);i!=y2;i+=d,x+=a)
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

			if (ABS(dx)>ABS(dy))
			{
				d=SGN(dx);
				a=((long)dy<<16)/ABS(dx);
				for(i=x1,y=32768L+((long)y1<<16);i!=x2;i+=d,y+=a)
					plot(i,(int)(y>>16),-1);
			}
			else
			{
				d=SGN(dy);
				a=((long)dx<<16)/ABS(dy);
				for(i=y1,x=32768L+((long)x1<<16);i!=y2;i+=d,x+=a)
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




void plot(int x,int y,int c)
{
	register char *ptr;

	if (c>=0) setcolor(c);
	wmap(x&3);
	ptr=(char *)(pt_ecran_travail+(y<<6)+(y<<4)+(x>>2));
	*ptr=color;
}


void vline(int x,int y,int y1,int c)
{
	register char *ptr;
	register int i;
	register int t;
	register col;
	register ey;

	if (c>=0) setcolor(c);

	col=color;
	if (y>y1)
	{
		t=y;
		y=y1;
		y1=t;
	}
	ey=y1;
	ptr=(char *)(pt_ecran_travail+(y<<6)+(y<<4)+(x>>2));
	wmap(x&3);
	for(i=y;i<ey;i++,ptr+=80) *ptr=col;
}




void hline(x,y,x1,c)
int x,y,x1,c;
{
	register char *ptr;
	register unsigned int m;
	register int i,cx,cx1,bx,bx1;
	register char col;

	if (x<x1)
	{
		cx=x>>2;
		cx1=x1>>2;
		bx=x&3;
		bx1=x1&3;
	}
	else
	{
		cx1=x>>2;
		cx=x1>>2;
		bx1=x&3;
		bx=x1&3;
	}

	if (c>=0) setcolor(c);
	col=color;
	ptr=(char *)(pt_ecran_travail+(y<<6)+(y<<4)+cx);

	if (cx==cx1)
	{
		m=15;
		m>>=(3-bx1+bx);
		m<<=bx;
		wbit(m);
		*ptr=col;
	}
	else
	{
		m=15;
		m<<=bx;
		wbit(m);
		*(ptr++)=col;
		cx++;
		if (cx!=cx1)
		{
			wall();
			memset(ptr,col,cx1-cx);
			ptr+=cx1-cx;
		}
		m=15;
		m>>=3-bx1;
		wbit(m);
		*ptr=col;
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
	register int l=filltab[y];
	register int d;

	if (l>=0)
	{
		d=l-x;
		if ((!d)||(d==1)||(d== -1))
		{
			plot(x,y,-1);
			filltab[y]=x;
		}
		else
		{
			hline(x,y,l,-1);
			filltab[y]= -1;
		}
	}
	else
	{
		plot(x,y,-1);
		filltab[y]=x;
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
		if (ABS(dx)>ABS(dy))
		{
			d=SGN(dx);
			a=((long)dy<<16)/ABS(dx);
			for(i=x1,y=32768L+((long)y1<<16);i!=x2;i+=d,y+=a)
				fplot(i,(int)(y>>16));
		}
		else
		{
			d=SGN(dy);
			a=((long)dx<<16)/ABS(dy);
			for(i=y1,x=32768L+((long)x1<<16);i!=y2;i+=d,x+=a)
				fplot((int)(x>>16),i);
		}

	fplot(x2,y2);
}





void polyfill(int n,int *tp,int c)
{
	register int i;

	if (c>=0) setcolor(c);

	memset((void *)filltab,255,2*NBLIGNES);
	for(i=0;i<n-1;i++) fline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3]);
}


















/*****************************************************************/
/* instructions d'allocation memoire                             */

long ramfree(void)
{
	return(farcoreleft());
}

void *memalloc(long size)
{
	return((void *)farmalloc(size));
}

void memfree(void **ptr)
{
	if (*ptr) farfree(*ptr);
	*ptr=0L;
}















/**************************************************************/
/* transferts de blocs memoire */

void bmove(void *src,void *dst,long len)
{
	register char huge *hs;
	register char huge *hd;
	register char *s;
	register char *d;
	register long hi;
	register unsigned int i,l;

	if (len>65535L)
	{
		hs=(char huge *)src;
		hd=(char huge *)dst;
		if (hs>hd)
			for(hi=0L;hi<len;hi++) *(hd++)= *(hs++);
		else
			for(hd+=len,hs+=len,hi=0L;hi<len;hi++) *(--hd)= *(--hs);
	}
	else
	{
		l=(unsigned int)len;
		s=(char *)src;
		d=(char *)dst;
		if (s>d)
			for(i=0;i<l;i++) *(d++)= *(s++);
		else
			for(d+=l,s+=l,i=0;i<l;i++) *(--d)= *(--s);
	}
}


















/*****************************************************************/
/* instructions de gestion d'horloge                             */


unsigned long systime(void)
{
	unsigned long r;

	r=biostime(0,0L);
	return 54*r;
}


void waitdelay(unsigned int n)
{
	unsigned long start;

	start=systime();

	if (n<100)
		do {} while((unsigned long)(systime()-start)<(unsigned long)n);
	else
		do refresh(); while((unsigned long)(systime()-start)<(unsigned long)n);
}













/*****************************************************************/
/* fonctions aleatoires */


int randint(void)
{
	return(rand());
}

int randval(int n)
{
	return(randint()%n);
}













/**************************************************************/
/* gestion des fichiers */

#define MAXFILE 16
FILE *ftab[MAXFILE];
char fused[MAXFILE]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};




#define MAXF 32768

static int flread(void *adr,long len,FILE *fp)
{
	unsigned int l;
	char huge *ptr;
	int r=1;

	ptr=(char huge *)adr;
	while((len)&&(r==1))
	{
		if (len>MAXF) l=MAXF; else l=(unsigned int)len;
		len-=(long)l;
		r=fread((void *)ptr,l,1,fp);
		ptr+=l;
	}
	return r;
}

static int flwrite(void *adr,long len,FILE *fp)
{
	unsigned int l;
	char huge *ptr;
	int r=1;

	ptr=(char huge *)adr;
	while((len)&&(r==1))
	{
		if (len>MAXF) l=MAXF; else l=(unsigned int)len;
		len-=(long)l;
		r=fwrite((void *)ptr,l,1,fp);
		ptr+=l;
	}
	return r;
}



static int nextfile(void)
{
	int r=0;
	int i;

	for(i=0;i<MAXFILE;i++) if (!fused[i]) r=i+1;
	return(r);
}


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
	FILE *fp;
	char nom2[200];
	verifnom(nom,nom2);

	fp = fopen(nom2,"r");
	if (fp)
	{
		fclose(fp);
		return(1);
	}
	else
		return(0);
}


long bsize(char *nom)
{
	FILE *fp;
	char nom2[200];
	long size=0L;

	verifnom(nom,nom2);

	fp = fopen(nom2,"r");
	if (fp)
	{
		fseek(fp, 0L, 2);
		size = ftell(fp);
		fclose(fp);
	}

	return(size);
}



int bsave(char *nom,void *adr,long offset,long len)
{
	void *buffer;
	long filesize;
	FILE *fp;
	int r= -1;
	char huge *d;
	char huge *s;
	long i;

	char nom2[200];
	verifnom(nom,nom2);
	fp = fopen(nom2,"r");
	if (fp)
	{
		r=fseek(fp, 0L, 2);
		filesize = ftell(fp);
		fclose(fp);

		if (!r)
		{
			r= -1;
			if (buffer=memalloc(filesize))
			{
				if (!bload(nom,buffer,0L,filesize))
				{
					s=(char huge *)adr;
					d=(char huge *)(buffer)+offset;
					for(i=0L;i<len;i++) *(d++)= *(s++);
					r=bmake(nom,buffer,filesize);
				}
				memfree(&buffer);
			}
		}
	}

	return(r);
}




int bload(char *nom,void *adr,long offset,long len)
{
	FILE *fp;
	int r= -1;
	char nom2[200];

	verifnom(nom,nom2);

	fp = fopen(nom2,"rb");
	if (fp)
	{
		fseek(fp, offset, 0);
		r=flread(adr,len,fp);
		if (r==1) r=0;
		else r= -1;
		fclose(fp);

	}

	return(r);
}



int bmake(char *nom,void *adr,long len)
{
	FILE *fp;
	int r= -1;
	char nom2[200];

	verifnom(nom,nom2);

	fp = fopen(nom2,"wb");
	if (fp)
	{
		r=flwrite(adr,len,fp);
		if (r==1) r=0;
		else r= -1;
		fclose(fp);
	}
	return(r);
}



int bcreate(char *nom)
{
	FILE *fp;
	int r=0;
	char nom2[200];

	r=nextfile();
	if (r)
	{
		verifnom(nom,nom2);
		fp = fopen(nom2,"wb");
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; }
		else r=0;
	}
	return(r);
}


int bopen(char *nom)
{
	FILE *fp;
	int r=0;
	char nom2[200];

	r=nextfile();
	if (r)
	{
		verifnom(nom,nom2);
		fp = fopen(nom2,"rb");
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; fseek(fp, 0L, 0); }
		else r=0;
	}
	return(r);
}



int bclose(int n)
{
	FILE *fp;
	int r=0;

	if (n)
	{
		fp=ftab[n-1];
		fclose(fp);
		fused[n-1]=0;
	}
	return(r);
}




int bwrite(int n,void *adr,long len)
{
	FILE *fp;
	int r= -1;

	if (n)
	{
		fp=ftab[n-1];
		if (fp)
		{
			r=flwrite(adr,len,fp);
			if (r==1) r=0;
			else r= -1;
		}
	}
	return(r);
}




int bread(int n,void *adr,long len)
{
	FILE *fp;
	int r= -1;

	if (n)
	{
		fp=ftab[n-1];
		if (fp)
		{
			r=flread(adr,len,fp);
			if (r==1) r=0;
			else r= -1;
		}
	}
	return(r);
}

















/**************************************************************/
/* gestion de la souris et du clavier */


void hide(void)
{
	mouselevel--;
	refresh();
}

void show(void)
{
	mouselevel++;
	refresh();
}


static int addbut(int k,int x,int y,int c)
{
	int ptr;


	if (nbrbuffer<32)
	{
		bufferflag=0;
		ptr=(msebufptr>>1);
		msebuffer[ptr]=k;
		msebuffer[ptr+1]=x;
		msebuffer[ptr+2]=y;
		msebuffer[ptr+3]=c;
		msebufptr+=8;
		msebufptr&=255;
		nbrbuffer++;
		bufferflag=1;

	}
}


char getch(void)
{
	char r;

	do refresh(); while(!keybufnbr);

	r=keybuffer[keybufend];
	keybufend++;
	keybufend&=255;
	keybufnbr--;

	return(r);
}




static int movemouse(int x,int y)
{
	if (x<0) x=0;
	if (x>304) x=304;
	if (y<0) y=0;
	if (y>(NBLIGNES-1)) y=NBLIGNES-1;


	_AX=4;
	_CX=x*2;
	_DX=y;
	geninterrupt(0x33);

	mousex=x;
	mousey=y;
}


static void mousesizex(int xmin,int xmax)
{
	_AX=7;
	_CX=xmin;
	_DX=xmax;
	geninterrupt(0x33);
}

static void mousesizey(int ymin,int ymax)
{
	_AX=8;
	_CX=ymin;
	_DX=ymax;
	geninterrupt(0x33);
}

static void mousestep(int pasx,int pasy)
{
	_AX=15;
	_CX=pasx;
	_DX=pasy;
	geninterrupt(0x33);
}


static void mousefreq(int freq)
{
	_AX=0x1c;
	_BX=freq;
	geninterrupt(0x33);
}



void empty(void)
{
	bufferflag=0;
	kbufferflag=0;
	nbrbuffer=msebufptr=lstbufptr=0;
	keybufnbr=keybufptr=keybufend=0;
	bufferflag=1;
	kbufferflag=1;
}

int kbhit(void)
{
	return(keybufnbr);
}

int keyhit(void)
{
	return(nbrbuffer|keybufnbr);
}

int buthit(void)
{
	return(nbrbuffer);
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

		/* msek:
		   bit 0:bouton gauche
		   bit 1:bouton droit
		   bit 2:0:presse 1:relache
		*/

		if (msek&64)
		if (msek&1) msek=1; else msek=5;
		else
		if (msek&128)
		if (msek&2) msek=2; else msek=6;
		else
		msek=0;
		return msek;
	}

	return 0;
}


static int initmouse(void)
{

	int r;

	vblclock=0;

	_AX=0;
	geninterrupt(0x33);
	r=_AX;

	mousex=oldx=160-8;
	mousey=oldy=NBLIGNES/2-8;

	if (r)
	{
		mousefreq(1);
		mousestep(16,32);
		mousesizex(0,639-32);
		mousesizey(0,NBLIGNES-1);

		movemouse(oldx,oldy);
		itmouse();
	}

	return r;
}



void confirm(void)
{
	empty();
	do refresh(); while (!buthit());
}


















/***************************************************************/
/* gestion de blocs graphiques */


typedef struct
{
	int lx;
	int ly;
	int id;
	long bloc;
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
		if (bloc->id) memfree((void **)&bloc->bloc);
		bloc->id=0;
		memfree(blocptr);
	}
}



void getbloc(blocptr,x,y,lx,ly)
void **blocptr;
int x,y,lx,ly;
{
	int i;

	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if ((!bloc->id)||(bloc->lx!=lx)||(bloc->ly!=ly))
		{
			if (bloc->id) memfree((void **)&bloc->bloc);
			bloc->id=0;
			if (bloc->bloc=(long)memalloc(ly*(long)lx))
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}


		if (bloc->id)
		{

			for(i=0;i<4;i++)
			{
				rmap(i);
				getplane(bloc->bloc+((lx>>2)*ly)*i,
					pt_ecran_travail+(x>>2)+(y<<6)+(y<<4),
					lx>>2,ly,0,80-(lx>>2));
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
	int i;

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
			for(i=0;i<4;i++)
			{
				putplane(blocs->bloc+((blocs->lx>>2)*blocs->ly)*i
					+(xs>>2)+ys*(blocs->lx>>2),
						blocd->bloc+((blocd->lx>>2)*blocd->ly)*i
					+(xd>>2)+yd*(blocd->lx>>2),
					lxs>>2,lys,(blocs->lx-lxs)>>2,(blocd->lx-lxs)>>2);
			}
		}
	}
}



void putpbloc(blocptr,x,y,xs,ys,lxs,lys)
void **blocptr;
int x,y,xs,ys,lxs,lys;
{
	int i;

	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;

		if ((y>=0)||(y+lys<=NBLIGNES))
		{
			if (y<0)
			{
				ys+=(-y);
				lys-=(-y);
				y=0;
			}
			else
			if (y+lys>NBLIGNES)
			{
				lys=NBLIGNES-y;
			}
		}

		if ((lys>0)&&(lxs>0))
		if ((x>=0)&&(y>=0)&&(xs>=0)&&(ys>=0))
		if ((x<320)&&(y<NBLIGNES))
		if ((x+lxs<=320)&&(y+lys<=NBLIGNES))
		if (bloc->id==1)
		{

			for(i=0;i<4;i++)
			{
				wmap(x&3);
				putplane(bloc->bloc+((bloc->lx>>2)*bloc->ly)*i
					+(xs>>2)+ys*(bloc->lx>>2),
					pt_ecran_travail+(x>>2)+(y<<6)+(y<<4),
					lxs>>2,lys,(bloc->lx-lxs)>>2,80-(lxs>>2));
				x++;
			}

		}
		else
		if (bloc->id==2)
		{

			for(i=0;i<4;i++)
			{
				wmap(x&3);
				putsplane(bloc->bloc+((bloc->lx>>2)*bloc->ly)*i
					+(xs>>2)+ys*(bloc->lx>>2),
					pt_ecran_travail+(x>>2)+(y<<6)+(y<<4),
					lxs>>2,lys,(bloc->lx-lxs)>>2,80-(lxs>>2));
				x++;
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
	int i;

	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id)
		{
			bloc->id=2;

			for(i=0;i<4;i++)
			{
				rmap(i);
				getsplane(bloc->bloc+((bloc->lx>>2)*bloc->ly)*i,
					pt_ecran_travail+(x>>2)+(y<<6)+(y<<4),
					bloc->lx>>2,bloc->ly,0,80-(bloc->lx>>2));
			}

		}
	}
}















/*****************************************************************/
/* instructions de gestion de fonte */


void affchar(int x,int y,char c)
{
	register char *ptr;
	register unsigned int n,i,j,k,m,f;

	if ((c>31)&&(c<=127))
	{
		if (c>95) c-=32;

		n=c-32;
		n<<=4;


		ptr=(char *)(pt_ecran_travail+(y<<6)+(y<<4)+(x>>2));

		for(k=128;k;k>>=1)
		{
			wmap(x&3);
			for(i=0;i<8;i++)
			{
				m=sysfonte[n+i];
				f=sysfonte[n+i+8];
				if (!(m&k))
					if (f&k) *ptr=color; else *ptr=0;
				ptr+=80;
			}
			x++;
			if (!(x&3)) ptr++;
			ptr-=640;
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
			if (y>(NBLIGNES-8)) y=0;
		}
	}

}



void printchar(char c)
{
	void *ecr;
	int t,i;
	char m;

	while(ycur>(NBLIGNES-8))
	{
		ycur-=8;

		copymode_on();
		bmove((void *)(pt_ecran_travail+640L),(void *)pt_ecran_travail,ECRTAILLE-640L);
		copymode_off();

		t=color;
		pbox(0,NBLIGNES-8,320,8,0);
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
/* gestion des samples */

/* sndblast: */
/* 0:simple dac port (soundmaster+:22fh) */
/* 1:soundblaster card (on:d1h,sample:10h+data,off:d3h (port 22ch)) */

int spkperiod=110;
int addcnt=65535;
int period=65535;
int voldigit,cntper,offstart,segdigit,offdigit,lendigit,repdigit,cntdigit;


void playsample(void *adr,long len,long freq)
{
	int v=15;
	if (len>65534L) len=65534L;

	if (dacport)
	{
		segdigit=0;
		offstart=offdigit=FP_OFF(adr);
		cntdigit=lendigit=(unsigned int)len;
		repdigit=1;
		voldigit=(15-v)/2;
		period=(int)(1200000L/freq);
		if (speaker) period=spkperiod;
		freqspl();
		segdigit=FP_SEG(adr);
	}
}



void stopsample(void)
{
	segdigit=0;
	period=65535;
	freqspl();
}



void fixsample(void *adr,long len)
{
	long i;
	char huge *ptr;

	ptr=(char huge *)adr;
	for(i=0L;i<len;i++) *(ptr++)-=128;
}


