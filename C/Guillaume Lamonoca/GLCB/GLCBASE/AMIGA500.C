/*
amiga500.c (module de base pour amiga 500 et 2000)
Description des instructions de ce module dans doc.txt.
Guillaume LAMONOCA
Supelec (94)

D'avance je m'excuse pour ce module... En effet je n'ai qu'un petit
amiga 500 sous amigados 1.2 et pratiquement pas de doc. C'est un
vrai miracle que ce module marche! Il est tres mal programme a
cause du manque de doc. Mais meme avec une doc complete, je ne
peut pas faire de module correct pour amiga car commodore a decider
de construire son avenir sur amigados 2.0. Je ne peut pas me 
permettre d'acheter tous les ordinateurs du marche!!!
Donc je vous appelle a l'aide, vous qui etes programmeur de talent
je vous demande d'ecrire un module de base "amiga20.c" qui se servira
de amigados 2.0 pour utiliser correctement les librairies jusqu'a 
la version V39 et meme au dela... L'ideal est de faire un module
similaire a PCVGA: 100% compatible avec les autres modules (320x200
en 16 couleurs), mais dans le cas ou vous detectez la possibilite
d'avoir 8 plans, un module qui permet de monter le no de couleur
jusqu'a 255 et qui permet l'acces aux fontions setbigpalette(),
getbigpalette(),setbigcolor() et getbigcolor().


Utiliser Aztec C 3.6a (K&R 1ere edition)
Ce C n'est pas genial mais il est correct quand on n'a pas de disque dur.

compilation et edition de lien:

cc +c +d amiga.c
cc +c +d exemple.c
ln +q exemple.o amiga.o -lml -lcl

Si une erreur "no more expression space" intervient,
alors diminuez le nombre de vos MACROS en
rajoutant des fonctions ou des variables intermediaires,
ou bien coupez en 2 le source pour former 2 modules.
De meme pour les chaines de caracteres, si elles sont
trop nombreuses au sein d'un tableau, il faudra morceler
ce tableau. C'est la galere... je sais...

Attention!
Si vous utilisez des fonctions mathematiques
vous devez vous assurer que "mathtrans.lib"
est bien present sur le disk!!!

*/

#include "header.h"

void *OpenLibrary();
void *AllocMem();
long AvailMem();
long lseek();

struct Node
{
	struct Node *ln_Succ;
	struct Node *ln_Pred;
	unsigned char ln_Type;
	char ln_Pri;
	char *ln_Name;
};

typedef unsigned char *STRPTR;
typedef STRPTR *APTR;

struct Interrupt
{
	struct Node is_Node;
	APTR is_Data;
	int (*is_Code)();
};


/********************************************************************/
/* variables globales */


struct Interrupt keybinter={{0L,0L,2L,100,"k"},0L,0L};
struct Interrupt mouseinter={{0L,0L,2L,0,"m"},0L,0L};
struct Interrupt copperinter={{0L,0L,2L,0,"c"},0L,0L};


static unsigned int egapal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};


static unsigned int oldpal[16];

struct sprlist
{
	char pos[4];
	int spr[32];
	int fin[2];
};


static struct sprlist spritelist=
{
	{
		0xa05a,0xb000
	},
	{
		0xc000,0x0000,
		0xe000,0x4000,
		0xf000,0x6000,
		0xf800,0x7000,
		0xfc00,0x7800,
		0xfe00,0x7c00,
		0xff00,0x7e00,
		0xff80,0x7f00,
		0xffc0,0x7f80,
		0xffe0,0x7c00,
		0xfe00,0x6c00,
		0xef00,0x4600,
		0xcf00,0x0600,
		0x8780,0x0300,
		0x0780,0x0300,
		0x0380,0x0000
	},
	{
		0x0000,0x0000
	}
};



struct coplist
{
	int cmap[32];
	int ispr[32];
	int head[2];
	int init[18];
	int bitp[16];
	int wait[6];
};

static struct coplist copperlist=
{
	{
		0x0180, 0x000,
		0x0182, 0x000,
		0x0184, 0x000,
		0x0186, 0x000,
		0x0188, 0x000,
		0x018A, 0x000,
		0x018C, 0x000,
		0x018E, 0x000,
		0x0190, 0x000,
		0x0192, 0x000,
		0x0194, 0x000,
		0x0196, 0x000,
		0x0198, 0x000,
		0x019A, 0x000,
		0x019C, 0x000,
		0x019E, 0x000
	},

	{
		0x0120, 0x0000,
		0x0122, 0x0000,
		0x0124, 0x0000,
		0x0126, 0x0000,
		0x0128, 0x0000,
		0x012A, 0x0000,
		0x012C, 0x0000,
		0x012E, 0x0000,
		0x0130, 0x0000,
		0x0132, 0x0000,
		0x0134, 0x0000,
		0x0136, 0x0000,
		0x0138, 0x0000,
		0x013A, 0x0000,
		0x013C, 0x0000,
		0x013E, 0x0000
	},

	{	
		0x3501,	0xFFFE
	},

	{
		0x008E, 0x4481,	/* DIWSTRT */
		0x0090, 0x0cc1,	/* DIWSTOP */
		0x0092, 0x0038,	/* DDFSTRT */
		0x0094, 0x00d0,	/* DDFSTOP */
		0x0100, 0x4200,	/* BPLCON0 */
		0x0102, 0x0000,	/* BPLCON1 */
		0x0104, 0x0024,	/* BPLCON2 */
		0x0108, 0x0000,	/* BPL1MOD */
		0x010A, 0x0000 	/* BPL2MOD */
	},

	{
		0x00E0, 0x0000,
		0x00E2, 0x0000,
		0x00E4, 0x0000,
		0x00E6, 0x0000,
		0x00E8, 0x0000,
		0x00EA, 0x0000,
		0x00EC, 0x0000,
		0x00EE, 0x0000
	},

	{
		0x1801, 0xFFFE,
		0x009C, 0x8010,
		0xFFFF, 0xFFFE          
	}
};

static char *ab="`1234567890 _|?0azertyuiop^$?123qsdfghjklm%#?456<wxcvbn,;:=??789";

static long clock=0L;

static unsigned long seed=0xffffffffL;

static struct sprlist *sprite;
static struct coplist *copper;
static long chipspr,chipcop,pt_ecran_actif,pt_ecran_travail,bigbloc;
static char swapflag=0;
static char vblflag=0;
static long oldcoplist,gfxbase,silence;
static int nbscreen=2;
static long old_travail;

static int ftab[200];

static unsigned int tmasque [16]=
{
	0x0000,0x8000,0xc000,0xe000,0xf000,0xf800,0xfc00,0xfe00,
	0xff00,0xff80,0xffc0,0xffe0,0xfff0,0xfff8,0xfffc,0xfffe
};

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
static int pma=-1;
static int pmb=-1;
static int pmc=-1;
static int pmd=-1;

static int msebufptr=0;
static int lstbufptr=0;
static int nbrbuffer=0;
static int msebuffer[128];
static int keybbufptr=0;
static int lstkbufptr=0;
static int nbrkbuffer=0;
static char keybbuffer[256];
static int xmax,ymax,fmousex,fmousey;
static char bufferflag=1;
static char kbufferflag=1;
static int mouselevel= -1;
static int olddat;
static char olddatx,olddaty;
static int pasx=1;
static int pasy=1;

static int xcur=0;
static int ycur=0;

int msex,msey,msek,mclk;
int mousex,mousey,mousek,vblclock;

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












/******************************************************************/
/* initialisation du systeme */



static void killscreen()
{
	refresh();

	*(int *)0xdff096L=0x0080;
	*(long *)0xdff080L=oldcoplist;
	*(int *)0xdff088L=0;
	*(int *)0xdff096L=0x8080;

	memfree(&chipcop);
	memfree(&chipspr);
	memfree(&bigbloc);

	CloseLibrary(gfxbase);
}


static void initscreen()
{
	int i;

	gfxbase=(long)OpenLibrary("graphics.library",0L);
	oldcoplist=*(long *)(gfxbase+38L);

	bigbloc=pt_ecran_actif=(long)memalloc(64000L);
	pt_ecran_travail=bigbloc+32000L;

	for(i=0;i<4;i++)
	{	
		copperlist.bitp[1+i*4]=(pt_ecran_actif+i*8000L)>>16;
		copperlist.bitp[3+i*4]=(pt_ecran_actif+i*8000L)&0xffff;
	}	
	for(i=0;i<8;i++)
	{
		copperlist.ispr[1+i*4]=silence>>16;
		copperlist.ispr[3+i*4]=silence&0xffff;
	}


	chipspr=(long)memalloc((long)sizeof(struct sprlist));
	sprite=(struct sprlist *)chipspr;
	copperlist.ispr[1]=chipspr>>16;
	copperlist.ispr[3]=chipspr&0xffff;
	bmove(&spritelist,chipspr,(long)sizeof(struct sprlist));

	chipcop=(long)memalloc((long)sizeof(struct coplist));
	copper=(struct coplist *)chipcop;
	bmove(&copperlist,chipcop,(long)sizeof(struct coplist));

	*(int *)0xdff096L=0x0080;
	*(long *)0xdff080L=chipcop;
	*(int *)0xdff088L=0;
	*(int *)0xdff096L=0x8080;

	*(int *)0xdff1a2L=0x000;
	*(int *)0xdff1a4L=0x000;
	*(int *)0xdff1a6L=0xfff;
	*(int *)0xdff096L=0x8220;
}

static char codescan(c)
unsigned char c;
{
	char r=c&127;

	if (r<64) r=ab[(int)r];
	else
	switch(r)
	{
		case 0x40: r=32;  break;
		case 0x41: r=8;   break;
		case 0x43: r=13;  break;
		case 0x44: r=13;  break;
		case 0x45: r=27;  break;
		case 0x46: r='{'; break;
		case 0x4a: r='-'; break;
		case 0x4c: r='^'; break;
		case 0x4d: r='v'; break;
		case 0x4e: r='>'; break;
		case 0x4f: r='<'; break;
		case 0x5f: r='}'; break;
		case 0x5a: r='('; break;
		case 0x5b: r=')'; break;
		case 0x5c: r='/'; break;
		case 0x5d: r='*'; break;
		case 0x5e: r='+'; break;
		default: r=0; break;
	}

	return(r);
}


static int keybserver()
{
	unsigned int c;
	unsigned char a;

	c=~*(char *)0xbfec01;
	c=((c>>1)&127)+((c<<7)&128);

	a=codescan(c&127);

	if (c<128) keymap[(int)a]=1; else keymap[(int)a]=0;
	
	if ((c<128)&&(nbrkbuffer!=256)&&(kbufferflag))
	{
		keybbuffer[keybbufptr]=a;
		keybbufptr++;
		keybbufptr&=255;
		nbrkbuffer++;
	}

	return(0);
}




static int mouseserver()
{
	int i,dat,k,v,ptr,vstart,vstop,hstart;
	char dx,dy,datx,daty;

	if ((swapflag)&&(nbscreen==2))
	{
		old_travail=pt_ecran_travail;
		pt_ecran_travail=pt_ecran_actif;
		pt_ecran_actif=old_travail;
		for(i=0;i<4;i++)
		{
			copper->bitp[1+i*4]=(pt_ecran_actif+i*8000L)>>16;
			copper->bitp[3+i*4]=(pt_ecran_actif+i*8000L)&0xffff;
		}
		swapflag=0;
	}

	clock+=20L; /* +20L pour 50Hz(20ms)  et +17L pour 60Hz(16.6ms) */
	vblclock++;

	dat=*(int *)0xdff00aL;

	if (olddat!=dat)
	{

		datx=dat&0xFF;
		daty=dat>>8;

		dx=datx-olddatx;
		dy=daty-olddaty;

		fmousex+=(int)dx/pasx;
		fmousey+=(int)dy/pasy;

		olddatx=datx;
		olddaty=daty;
		olddat=dat;

		if (fmousex<0) fmousex=0;
		if (fmousex>xmax) fmousex=xmax;
		if (fmousey<0) fmousey=0;
		if (fmousey>ymax) fmousey=ymax;


	}

	if ((*(char *)0xbfe001L)&64) k=0; else k=1;
	if (!((*(int *)0xdff016L)&1024)) k|=2;

	v=mousek^k;
	mousek=k;
	mousex=fmousex;
	mousey=fmousey;

	if (mouselevel>=0)
	{
		vstart=0x44+mousey;
		hstart=0x80+mousex;
	}
	else
	{
		vstart=0x44+ymax+1;
		hstart=0x80+xmax+1;
	}
	vstop=vstart+16;
	
	sprite->pos[0]=vstart&0xff;
	sprite->pos[1]=(hstart>>1);
	sprite->pos[2]=vstop&0xff;
	sprite->pos[3]=((vstart&256)>>6)+((vstop&256)>>7)+(hstart&1);


	if (v&1) 
	{
		if (k&1) k=1; else k=5; 
	}
	else
	if (v&2)
	{
		if (k&2) k=2; else k=6;
	}

	if ((v)&&(nbrbuffer!=32)&&(bufferflag))
	{
		ptr=msebufptr>>1;
		msebuffer[ptr]=k;
		msebuffer[ptr+1]=fmousex;
		msebuffer[ptr+2]=fmousey;
		msebuffer[ptr+3]=vblclock;
		msebufptr+=8;
		msebufptr&=255;
		nbrbuffer++;
	}

	vblflag=0;


	return(0);
}


static int copperserver()
{
	return(0);
}







void killsystem()
{
	stopsample();
	empty();
	killscreen();

	RemIntServer(4L,&copperinter);
	RemIntServer(3L,&keybinter);
	RemIntServer(5L,&mouseinter);
	memfree(&silence);
}




int initsystem()
{
	int r=1;

	silence=(long)memalloc(32L);

	vblclock=0;
	fmousex=152;
	fmousey=92;
	xmax=319;
	ymax=199;
	swapflag=vblflag=0;
	mouselevel=-1;
	olddatx=olddaty=0;

	*(int *)0xdff09aL=0x03a0;
	*(int *)0xdff036L=0;
	mouseinter.is_Code=mouseserver;
	AddIntServer(5L,&mouseinter);
	*(int *)0xdff09aL=0x8020;

	keybinter.is_Code=keybserver;
	AddIntServer(3L,&keybinter);

	copperinter.is_Code=copperserver;
	AddIntServer(4L,&copperinter);
	*(int *)0xdff09aL=0x8010;


	initscreen();
	cls();
	swap();
	cls();
	swap();
	setpalette(egapal);

	show();

	return(r);
}










/******************************************************************/
/* gestion des 16 couleurs */


void setcolor(c)
int c;
{
	if (c&1) pma=-1; else pma=0;
	if (c&2) pmb=-1; else pmb=0;
	if (c&4) pmc=-1; else pmc=0;
	if (c&8) pmd=-1; else pmd=0;
	color=c&15;
}


void setpalette(pal)
unsigned int *pal;
{
	int i;

	for(i=0;i<16;i++) oldpal[i]=pal[i];
	for(i=0;i<16;i++) copper->cmap[1+i*2]=(pal[i]&0xfff);
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
		nbscreen=1;
		old_travail=pt_ecran_travail;
		pt_ecran_travail=pt_ecran_actif;
	}
}


void doublescreen()
{
	if (nbscreen==1)
	{
		nbscreen=2;
		pt_ecran_travail=old_travail;
	}
}


void cls()
{
	xcur=ycur=0;
	
	{
		#asm
			move.l _pt_ecran_travail,A0
			move.w #7999,D0
		w0:
			clr.l (A0)+
			dbf.w D0,w0
		#endasm
	}

}




void swap()
{
	if (nbscreen==2)
	{
		swapflag=1;
		do {} while(swapflag);
	}
	else
	refresh();
}


void refresh()
{
	vblflag=1;
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
	register int *ptr;
	register unsigned int m,nm;

	if (c>=0) setcolor(c);

	ptr=(int *)pt_ecran_travail;
	ptr+=y*20+x/16;
	nm=0x8000;
	nm>>=x&15;
	m=~nm;
	*(ptr)=(*ptr&m)|(nm&pma);
	ptr+=4000;
	*(ptr)=(*ptr&m)|(nm&pmb);
	ptr+=4000;
	*(ptr)=(*ptr&m)|(nm&pmc);
	ptr+=4000;
	*(ptr)=(*ptr&m)|(nm&pmd);
}



void vline(x,y,y1,c)
int x,y,y1,c;
{
	register int *ptr;
	register unsigned int m,nm;
	register int dy=sgn(y1-y);
	register int i;

	if (c>=0) setcolor(c);
	if (!dy) dy++;
	ptr=(int *)pt_ecran_travail;
	ptr+=y*20+x/16;
	nm=0x8000;
	nm>>=x&15;
	m=~nm;
	for(i=y;i!=y1+dy;i+=dy,ptr+=dy*20)
	{
		*ptr=(*ptr&m)|(nm&pma);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmb);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmc);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmd);
		ptr-=12000;
	}
}




void hline(x,y,x1,c)
int x,y,x1,c;
{
	register int *ptr;
	register unsigned int m,nm;
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
	ptr=(int *)pt_ecran_travail;
	ptr+=y*20+cx;

	if (cx==cx1)
	{
		nm=-1;
		nm>>=(15-bx1+bx);
		nm<<=(15-bx1);
		m=~nm;
		*ptr=(*ptr&m)|(nm&pma);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmb);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmc);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmd);
	}
	else
	{
		nm=-1;
		nm>>=bx;
		m=~nm;
		*ptr=(*ptr&m)|(nm&pma);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmb);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmc);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmd);
		ptr-=11999;
		cx++;
		if (cx!=cx1)
			for(i=cx;i<cx1;i++) 
			{
				*ptr=pma;
				ptr+=4000;
				*ptr=pmb;
				ptr+=4000;
				*ptr=pmc;
				ptr+=4000;
				*ptr=pmd;
				ptr-=11999;
			}
		nm=-1;
		nm<<=15-bx1;
		m=~nm;
		*ptr=(*ptr&m)|(nm&pma);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmb);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmc);
		ptr+=4000;
		*ptr=(*ptr&m)|(nm&pmd);
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
		hline(x,y,l,-1);
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
	return(AvailMem(2L));
}


void memfree(adr)
void **adr;
{
	long size;

	if (*adr)
	{
		*adr=(void *)((long)*adr-4L);
		size=*(long *)*adr;
		FreeMem(*adr,size+4L);
		*adr=0L;
	}
}


void *memalloc(size)
long size;
{
	void *r;

	r=AllocMem(size+4L,0x10002L);

	if (r)
	{
		*(long *)r=size;
		r=(void *)(4L+(long)r);
	}

	return(r);
}



 
















/*****************************************************************/
/* instructions de transfert de blocs */



void bmove(sce,dst,len)
void *sce,*dst;
long len;
{

if (sce>dst)
{
#asm
	movem.l A0-A1/D0,-(A7)
	move.l 8(A5),A0
	move.l 12(A5),A1
	move.l 16(A5),D0
lp:
	move.b (A0)+,(A1)+
	subq.l #1,D0
	bne lp
	movem.l (A7)+,A0-A1/D0
#endasm
}
else
{
#asm
	movem.l A0-A1/D0,-(A7)
	move.l 8(A5),A0
	move.l 12(A5),A1
	move.l 16(A5),D0
	adda.l D0,A0
	adda.l D0,A1
lpi:
	move.b -(A0),-(A1)
	subq.l #1,D0
	bne lpi
	movem.l (A7)+,A0-A1/D0
#endasm
}

}














/******************************************************************/
/* instructions de gestion de l'horloge */


unsigned long systime()
{
	return(clock);
}


void waitdelay(n)
int n;
{
	unsigned long start;

	start=systime();
	do {} while((unsigned long)(systime()-start)<(unsigned long)n);
}








/********************************************************/
/* fonctions aleatoires */


int randint()
{
	if (seed)
	{
		if (seed>0x80000000L) seed=((seed<<1)^0x1d872b41L); else seed<<=1;
	}
	else
	seed=clock;

	return((int)seed&0x7fff);
}


int randval(n)
int n;
{
	return(randint()%n);
}





























/*****************************************************************/
/* gestion de fichiers */

#define MAXF 32768

static void lread(fd,adr,len)
int fd;
void *adr;
long len;
{
	unsigned int l;

	while(len)
	{
		if (len>MAXF) l=MAXF; else l=(unsigned int)len;
		len-=(long)l;
		read(fd,adr,l);
		adr=(void *)((long)adr+(long)l);
	}
}

static void lwrite(fd,adr,len)
int fd;
void *adr;
long len;
{
	unsigned int l;

	while(len)
	{
		if (len>MAXF) l=MAXF; else l=(unsigned int)len;
		len-=(long)l;
		write(fd,adr,l);
		adr=(void *)((long)adr+(long)l);
	}
}





int bexist(nom)
char *nom;
{
	int r;

	r=open(nom,0);
	if (r>0) { close(r); r=1; }
	else
	if (!r) r=1;
	else 
	r=0; 

	return(r);
}


long bsize(nom)
char *nom;
{
	long size=0L;
	int fd;

	fd=open(nom,0);
	if (fd>0) { size=(long)lseek(fd,0L,2); close(fd); }

	return(size);
}


int bload(nom,adr,offset,len)
char *nom;
void *adr;
long offset,len;
{
	int fd;

	fd=open(nom,0);
	if (fd>0)
	{
		lseek(fd,offset,0);
		lread(fd,adr,len);
		close(fd);
		fd=0;
	}

	return(fd);
}

int bsave(nom,adr,offset,len)
char *nom;
void *adr;
long offset,len;
{
	int fd;

	fd=open(nom,1);
	if (fd>0)
	{
		lseek(fd,offset,0);
		lwrite(fd,adr,len);
		close(fd);
		fd=0;
	}

	return(fd);
}

int bmake(nom,adr,len)
char *nom;
void *adr;
long len;
{
	int fd;

	fd=open(nom,257);
	if (fd>0)
	{
		lwrite(fd,adr,len);
		close(fd);
		fd=0;
	}

	return(fd);
}






int bopen(nom)
char *nom;
{
	int fd;

	fd=open(nom,0);
	if (fd>0) lseek(fd,0L,0); else fd=-1;

	return(fd);
}


int bcreate(nom)
char *nom;
{
	int fd;

	fd=open(nom,257);
	if (fd>0) lseek(fd,0L,0); else fd=-1;

	return(fd);
}



int bread(fd,adr,len)
int fd;
void *adr;
long len;
{
	lread(fd,adr,len);
	
	return(0);
}


int bwrite(fd,adr,len)
int fd;
void* adr;
long len;
{
	lwrite(fd,adr,len);

	return(0);
}



int bclose(fd)
int fd;
{
	close(fd);

	return(0);
}

















/*************************************************************/
/* gestion de la souris et du clavier */

int buthit()
{
	return(nbrbuffer);
}

int kbhit()
{
	return(nbrkbuffer);
}

int keyhit()
{
	return(nbrkbuffer|nbrbuffer);
}






char getch()
{
	char r;

	do {} while(!nbrkbuffer);

	r=keybbuffer[lstkbufptr];
	lstkbufptr++;
	lstkbufptr&=255;
	nbrkbuffer--;
	
	return(r);
}


void empty()
{
	bufferflag=0;
	nbrbuffer=msebufptr=lstbufptr=0;
	bufferflag=1;
	kbufferflag=0;
	nbrkbuffer=keybbufptr=lstkbufptr=0;
	kbufferflag=1;
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
		nbrbuffer--;

/* msek: bit 0:bouton gauche bit 1:bouton droit bit 2:0:presse 1:relache */

		return(msek);
	}
	else
	return(0);
}



void hide()
{
	mouselevel--;
}

void show()
{
	mouselevel++;
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
			ecran=pt_ecran_travail+x/8+y*40;
			haut=ly-1;
			larg=(lx/16)-1;
			recal=(char*)(40-(lx/8));
		{
		#asm

		move.l	_ecran,A1
		move.l 	_matrice,A0
		move.w	_haut,D0
l3b:
		move	_larg,D1
l4b:
		move.w	(A1),(A0)+
		move.w 	8000(A1),(A0)+
		move.w 	16000(A1),(A0)+
		move.w 	24000(A1),(A0)+
		addq.l	#2,A1
		dbf		D1,l4b
		adda.l	_recal,A1
		dbf	 	D0,l3b

		#endasm
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
		#asm

		move.l 	_matrice,A0
		move.l	_matrice2,A1
		move.w	_haut,D0
l3z:
		move	_larg,D1
l4z:
		move.l	(A0)+,(A1)+
		move.l	(A0)+,(A1)+
		dbf		D1,l4z
		adda.l	_recal,A0
		adda.l	_recal2,A1
		dbf	 	D0,l3z

		#endasm
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
		#asm

		move.l 	_masque,A0
		move.l	_masque2,A1
		move.w	_haut,D0
l3y:
		move	_larg,D1
l4y:
		move.w	(A0)+,(A1)+
		dbf		D1,l4y
		adda.l	_recal,A0
		adda.l	_recal2,A1
		dbf	 	D0,l3y

		#endasm
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
			ecran=pt_ecran_travail+(x&0xfff0)/8+y*40;
			recal2=(char*)((bloc->lx-lxs)/2);

			if (dec)
			{
				haut=lys;
				larg=lxs/16;
				recal=(char*)(38-(lxs/8));

				{
				#asm

		move.l _masque,A2
	    move.l _ecran,A1
    	move.l _matrice,A0
		move.w _dec,D7
		move.w D7,D0
		subi.w #16,D0
		neg.w D0

cont_20:  

		move.w _tmask,D1
		clr.w D2
		clr.w D3
		clr.w D4
		clr.w D5

		move.w _larg,_cnt 

cont_21:      
		tst.w	_fmask
		bne.s	sb1

		and.w D1,(A1)
		and.w D1,8000(A1)
		and.w D1,16000(A1)
		and.w D1,24000(A1)
		clr.w D1
		bra.s	sb2
sb1:
		move.w (A2),D6
		lsr.w D7,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,8000(A1)
		and.w D6,16000(A1)
		and.w D6,24000(A1)
		move.w (A2)+,D6
		lsl.w D0,D6
		move.w D6,D1
sb2:	
		move.w (A0),D6
		lsr.w D7,D6
		or.w D2,D6
		or.w D6,(A1)
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D2

		move.w (A0),D6
		lsr.w D7,D6
		or.w D3,D6
		or.w D6,8000(A1)
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D3

		move.w (A0),D6
		lsr.w D7,D6
		or.w D4,D6
		or.w D6,16000(A1)
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D4

		move.w (A0),D6
		lsr.w D7,D6
		or.w D5,D6
		or.w D6,24000(A1)
		move.w (A0)+,D6
		lsl.w D0,D6
		move.w D6,D5

		addq.l #2,A1

		subq.w #1,_cnt
		bne.s cont_21


		move.w _ntmask,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,8000(A1)
		and.w D6,16000(A1)
		and.w D6,24000(A1)

		or.w D2,(A1)
		or.w D3,8000(A1)
		or.w D4,16000(A1)
		or.w D5,24000(A1)

		addq.l #2,A1
		adda.l _recal,A1
		adda.l _recal2,A0
		subq.w #1,_haut
		bne.s  cont_20

				#endasm
				}
			}
			else
			{
				haut=lys-1;
				larg=(lxs/16)-1;
				recal=(char*)(40-(lxs/8));

				if (fmask)
				{
				#asm

		move.l _masque,A2
		move.l _ecran,A1
		move.l _matrice,A0		
		move.w _haut,D0
cont_12:
		move.w _larg,D1 
cont_13:      
		move.w (A2)+,D2
		and.w D2,(A1)
		and.w D2,8000(A1)
		and.w D2,16000(A1)
		and.w D2,24000(A1)
		move.w (A0)+,D3
		or.w D3,(A1)
		move.w (A0)+,D3
		or.w D3,8000(A1)
		move.w (A0)+,D3
		or.w D3,16000(A1)
		move.w (A0)+,D3
		or.w D3,24000(A1)
		addq.l #2,A1

		dbf.w  D1,cont_13
		adda.l _recal,A1
		adda.l _recal2,A0
		dbf.w  D0,cont_12

				#endasm
				}
				else
				{
				#asm

		move.l _masque,A2
		move.l _ecran,A1
		move.l _matrice,A0		
		move.w _haut,D0
cont_18:
		move.w _larg,D1 
cont_19:      
		move.w (A0)+,(A1)
		move.w (A0)+,8000(A1)
		move.w (A0)+,16000(A1)
		move.w (A0)+,24000(A1)
		addq.l #2,A1
		dbf.w  D1,cont_19
		adda.l _recal,A1
		adda.l _recal2,A0
		dbf.w  D0,cont_18

				#endasm
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
				ecran=pt_ecran_travail+x/8+y*40;
				haut=bloc->ly-1;
				larg=(bloc->lx/16)-1;
				recal=(char*)(40-(bloc->lx/8));

			{
			#asm

		move.l	_ecran,A1
		move.l 	_matrice,A0
		move.w	_haut,D0
l3c:
		move	_larg,D1
l4c:
		move.w	(A1),D4
		not.w	D4
		move.w	D4,(A0)+
		addq.l	#2,A1
		dbf		D1,l4c
		adda.l	_recal,A1
		dbf	 	D0,l3c

			#endasm	
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
	ecran=pt_ecran_travail+(x&0xfff0)/8+y*40;

	if (dec)
	{
		recal=(char*)(36);

		{
		#asm

		move.l _ecran,A1
		move.l _matrice,A0
		move.l	A0,A2
		adda.l	#8,A2
		move.w _dec,D7
		move.w D7,D0
		subi.w #16,D0
		neg.w D0
cont_c23:  
		move.w _tmask,D1
		move.b (A0)+,D6
		lsl.w #8,D6
		ori.w #$ff,D6
		move.w D6,D3
		lsr.w D7,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,8000(A1)
		and.w D6,16000(A1)
		and.w D6,24000(A1)
		lsl.w D0,D3
		move.w D3,D1

		move.b (A2)+,D6
		lsl.w #8,D6
		move.w D6,D3
		lsr.w D7,D6
		move.w	D6,D4
		and.w	_pma,D4
		or.w D4,(A1)
		move.w	D6,D4
		and.w	_pmb,D4
		or.w D4,8000(A1)
		move.w	D6,D4
		and.w	_pmc,D4
		or.w D4,16000(A1)
		move.w	D6,D4
		and.w	_pmd,D4
		or.w D4,24000(A1)
		addq.l #2,A1
		lsl.w D0,D3
		move.w D3,D2

		move.w _ntmask,D6
		or.w D1,D6
		and.w D6,(A1)
		and.w D6,8000(A1)
		and.w D6,16000(A1)
		and.w D6,24000(A1)

		move.w	D2,D4
		and.w	_pma,D4
		or.w D4,(A1)
		move.w	D2,D4
		and.w	_pmb,D4
		or.w D4,8000(A1)
		move.w	D2,D4
		and.w	_pmc,D4
		or.w D4,16000(A1)
		move.w	D2,D4
		and.w	_pmd,D4
		or.w D4,24000(A1)
		addq.l #2,A1

		adda.l _recal,A1
		subq.w #1,_haut
		bne.s  cont_c23
		#endasm    	
		}

	}
	else
	{
		recal=(char*)(38);

		{
		#asm

		move.l _ecran,A1
		move.l _matrice,A0
		move.l	A0,A2
		adda.l	#8,A2
		move.w #7,D0
cont_c133:      
		move.b (A0)+,D2
		lsl.w #8,D2
		ori.w #$ff,D2
		and.w D2,(A1)
		and.w D2,8000(A1)
		and.w D2,16000(A1)
		and.w D2,24000(A1)
		move.b (A2)+,D3
		lsl.w #8,D3
		move.w	D3,D4
		and.w	_pma,D4
		or.w D4,(A1)
		move.w	D3,D4
		and.w	_pmb,D4
		or.w D4,8000(A1)
		move.w	D3,D4
		and.w	_pmc,D4
		or.w D4,16000(A1)
		move.w	D3,D4
		and.w	_pmd,D4
		or.w D4,24000(A1)
		addq.l #2,A1

		adda.l _recal,A1
		dbf.w D0,cont_c133

		#endasm
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
	void *ecr;
	int t;

	while(ycur>192) 
	{
		ycur-=8;
		initbloc(&ecr);
		getbloc(&ecr,0,8,320,192);
		putbloc(&ecr,0,0);
		freebloc(&ecr);
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
/* gestion des samples */


void stopsample()
{
	*(int *)0xdff096L=0x000f;
}


void playsample(adr,len,freq)
void *adr;
long len,freq;
{
	int i;

	if (adr)
	{
		if (len>131071L) len=131071L;

		*(int *)0xdff096L=0x0001;
		*(long *)0xdff0a0L=(long)adr;
		*(int *)0xdff0a4L=(int)(len>>1L);
		*(int *)0xdff0a8L=64;
		*(int *)0xdff0a6L=(int)(3579545L/freq);
		*(int *)0xdff09eL=0x00ff;
		*(int *)0xdff096L=0x8001;

		for(i=0;i<10;i++);

		*(int *)0xdff0a4L=10;
		*(long *)0xdff0a0L=silence;
	}
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
 

