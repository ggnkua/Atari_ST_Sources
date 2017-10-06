/*
mac.c (module de base pour macintosh)
Description des instructions de ce module dans doc.txt.
Guillaume LAMONOCA
Supelec (94)

Utiliser Think C 5.0

Creer un projet exemple.'PI' (Opt-P pour obtenir PI) (Opt: touche "^\=" )
Placer dans la liste: (ADD dans le menu SOURCE)
	ANSI			(C libraries)
	Mactraps		(Mac Libraries)
	mac.c			(GLCbase)
	exemple.c		(GLCbase)

Separer les 4 elements en les faisant glisser hors du groupe initial
(vous devez obtenir des lignes pointillees entre chaque element)
(un groupe ne peut pas contenir plus de 32Ko)
(un code objet est donc limite a 32Ko: evitez les variables globales
volumineuses et privilegiez plutot les allocations de memoire
dynamiques avec memalloc() et memfree())
Dans OPTIONS choisissez FACTORY SETTINGS et desactivez CONFIRM PROJECT UPDATES.

Faire RUN pour lancer la compilation, l'edition de lien et le programme.
(Parfois des bugs inexplicables surviennent avec RUN: en fait c'est un
 debordement de pile, mais on est pas prevenu... 
 Solution: Dans SET PROJECT TYPE augmenter la PARTITION.
    par exemple passer de 384 a 512 Ko)
La PARTITION est en fait la zone memoire reservee pour votre application.
Si vous faites beaucoup d'allocation dynamique ou si vous utilisez de
gros blocs graphiques n'hesitez pas a l'augmenter: par exemple 1024 Ko.

Faire BUILD APPLICATION pour obtenir un executable sur disk.

Ce module de base n'utilise que du graphisme monochrome. Pour avoir la
vitesse maximum d'affichage, je vous conseille de choisir N&B dans
l'accessoire Moniteurs.

Remarque: Pour l'exectution des sons digitalises, la fonction playsample()
utilise une fonction tres ancienne mais tres simple a utiliser.
L'inconvenient est que la frequence de l'echantillon doit etre traduite
en unite de compteur: suivant les Mac des coefficients differents peuvent
etre necessaires. Regardez la fonction playsample() a la fin de MAC.C.
*/


#include "Sound.h"
#include "header.h"


/********************************************************************/
/* variables globales */

static int RATIO=3;
static int emulmono=0;

static unsigned int egapal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};

static unsigned int oldpal[16];


static char graypat[9][8]={
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x80,0x00,0x08,0x00,0x80,0x00,0x08,0x00,
	0x88,0x00,0x22,0x00,0x88,0x00,0x22,0x00,
	0x88,0x22,0x88,0x22,0x88,0x22,0x88,0x22,
	0xaa,0x55,0xaa,0x55,0xaa,0x55,0xaa,0x55,
	0xbb,0xee,0xbb,0xee,0xbb,0xee,0xbb,0xee,
	0xff,0xbb,0xff,0xee,0xff,0xbb,0xff,0xee,
	0xff,0xbf,0xff,0xfb,0xff,0xbf,0xff,0xfb,
	0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
};


static int ecran_travail=0;
static int ecran_actif=1;
static int pw=0;
static WindowPtr window;
static Rect wbounds;
static int windowW,windowH,screenW,screenH;
static WindowRecord wrecord;
static Rect dragRect;
static Rect rectecr;
static int nbscreen=2;
static BitMap ecran[2];
static GrafPort grafport[2];


static Pattern pat;
static int color=15;

static int xcur=0;
static int ycur=0;


int mousex,mousey,mousek,vblclock;
int msex,msey,msek,mclk;

static int nbrbuffer=0;
static int lstbufptr=0;
static int msebufptr=0;
static int msebuffer[128];

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


static int keybuffer[256];
static int keybufptr=0;
static int keybufend=0;
static int keybufnbr=0;



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














/*******************************************************************************/
/* initialisation du systeme */


int initsystem(void)
{
	int i;
	int r=1;
	int rx,ry;
	unsigned char *p;

	MaxApplZone();
	InitGraf(&thePort);
	FlushEvents(everyEvent,0);
	InitWindows();
	InitCursor();

	wbounds=thePort->portBits.bounds;
	screenH=wbounds.bottom-wbounds.top;
	screenW=wbounds.right-wbounds.left;

	rx=screenW/320;
	ry=screenH/200;
	if (ry<rx) rx=ry;
	if (rx<RATIO) RATIO=rx;

	windowW=320*RATIO;
	windowH=200*RATIO;
	if (!RATIO) return(0);

	SetRect(&rectecr,0,0,windowW,windowH);
	OpenPort(&grafport[0]);
	OpenPort(&grafport[1]);
	ecran[0].bounds=ecran[1].bounds=rectecr;
	ecran[0].rowBytes=ecran[1].rowBytes=windowW/8;
	ecran[0].baseAddr=memalloc(((long)windowH)*windowW/8);
	ecran[1].baseAddr=memalloc(((long)windowH)*windowW/8);
	grafport[0].portBits=ecran[0];
	grafport[1].portBits=ecran[1];

	wbounds.left=(screenW-windowW)/2;
	wbounds.top=(screenH-windowH)/2;
	wbounds.right=wbounds.left+windowW;
	wbounds.bottom=wbounds.top+windowH;

	dragRect = screenBits.bounds;

	window=NewWindow(&wrecord, &wbounds, "\p", true,
	noGrowDocProc, (WindowPtr) -1L, true, 0);

	pw=1; 
	SetPort(window);
	setpalette(egapal);
	cls();
	pw=0; 
	SetPort(&grafport[ecran_actif]);
	cls();
	pw=0; 
	SetPort(&grafport[ecran_travail]);
	cls();
	setcolor(15);


	SetEventMask(everyEvent);


	return(r);
}






void killsystem(void)
{
	pw=1; 
	SetPort(window);
	CloseWindow(window);
	ClosePort(&grafport[0]);
	ClosePort(&grafport[1]);
	memfree((void **)&ecran[0].baseAddr);
	memfree((void **)&ecran[1].baseAddr);
	exit(0);
}





























/***************************************************************/
/* gestion des couleurs */


void setcolor(int c)
{
	int i,n;
	
	if (c==FOND) n=0;
	else
	if (c==MASK) n=8;
	else
	n=oldpal[c]>>12;
	for(i=0;i<8;i++) pat[i]=~graypat[n][i];
	PenPat(pat);
	color=c;
}


void getpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) pal[i]=oldpal[i];
}




void setpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) oldpal[i]=pal[i];
}


















/************************************************************/
/* instructions de gestion des ecrans graphiques */



void simplescreen(void)
{
	if (nbscreen==2)
	{
		ecran_travail=ecran_actif;
		nbscreen=1;
		pw=0; 
		SetPort(&grafport[ecran_travail]);
	}
}


void doublescreen(void)
{
	if (nbscreen==1)
	{
		ecran_travail=1-ecran_actif;
		nbscreen=2;
		pw=0; 
		SetPort(&grafport[ecran_travail]);
	}
}


void cls(void)
{
	int t;
	xcur=ycur=0;
	t=color;
	pbox(0,0,320,200,0);
	setcolor(t);
}


void copyscreen(void)
{
	CopyBits(&ecran[ecran_actif],&ecran[ecran_travail],
		&rectecr,&rectecr,srcCopy,0L);
}


void refresh(void)
{
	vblclock++;
	if (pw)
		CopyBits(&ecran[ecran_actif],&window->portBits,&rectecr,
			&rectecr,srcCopy,0L);
	else
	{
		pw=1; 
		SetPort(window);
		CopyBits(&ecran[ecran_actif],&window->portBits,&rectecr,
			&rectecr,srcCopy,0L);
		pw=0; 
		SetPort(&grafport[ecran_travail]);
	}		
}



void swap(void)
{
	vblclock++;
	if (nbscreen==2)
	{
		ecran_travail=1-ecran_travail;
		ecran_actif=1-ecran_actif;
	}
	if (pw)
		CopyBits(&ecran[ecran_actif],&window->portBits,
			&rectecr,&rectecr,srcCopy,0L);
	else
	{
		pw=1; 
		SetPort(window);
		CopyBits(&ecran[ecran_actif],&window->portBits,
			&rectecr,&rectecr,srcCopy,0L);
		pw=0; 
		SetPort(&grafport[ecran_travail]);
	}
}




























/******************************************************************/
/* instructions graphiques de base */

#define sgn(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define abs(x) ((x<0)?(-(x)):(x))


void pellipse(int x,int y,int lx,int ly,int c)
{
	Rect r;
	if (c>=0) setcolor(c);
	SetRect(&r,x*RATIO,y*RATIO,(x+lx)*RATIO,(y+ly)*RATIO);
	FillOval(&r,pat);
}


void pbox(int x,int y,int lx,int ly,int c)
{
	Rect r;
	if (c>=0) setcolor(c);
	SetRect(&r,x*RATIO,y*RATIO,(x+lx)*RATIO,(y+ly)*RATIO);
	FillRect(&r,pat);
}


void plot(int x,int y,int c)
{
	Rect r;
	if (c>=0) setcolor(c);
	SetRect(&r,x*RATIO,y*RATIO,(x+1)*RATIO,(y+1)*RATIO);
	FillRect(&r,pat);
}


void vline(int x,int y,int y2,int c)
{
	if (y2>y) pbox(x,y,1,y2-y+1,c); else pbox(x,y2,1,y-y2+1,c);
}


void hline(int x,int y,int x2,int c)
{
	if (x2>x) pbox(x,y,x2-x+1,1,c); else pbox(x2,y,x-x2+1,1,c);
}


void rline(int x,int y,int x2,int y2,int c)
{
	if (c>=0) setcolor(c);

	MoveTo(x*RATIO,y*RATIO);
	LineTo(x2*RATIO,y2*RATIO);
}



void dline(int x1,int y1,int x2,int y2,int c)
{
	int dx=x2-x1;
	int dy=y2-y1;
	int d;
	int i;
	double a,x,y;

	if (c>=0) setcolor(c);

	if (!dx) vline(x1,y1,y2,-1);
	else
		if (!dy) hline(x1,y1,x2,-1);
		else
		{

			if (abs(dx)>abs(dy))
			{
				d=sgn(dx);
				a=(double)dy/abs(dx);
				for(i=x1,y=0.5+(double)y1;i!=x2;i+=d,y+=a)
					plot(i,(int)y,-1);
			}
			else
			{
				d=sgn(dy);
				a=(double)dx/abs(dy);
				for(i=y1,x=0.5+(double)x1;i!=y2;i+=d,x+=a)
					plot((int)x,i,-1);
			}

			plot(x2,y2,-1);
		}

}




void dbox(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);
	pbox(x,y,lx,1,-1);
	pbox(x,y+ly-1,lx,1,-1);
	pbox(x,y,1,ly,-1);
	pbox(x+lx-1,y,1,ly,-1);
}


void polyline(int n,int *tp,int c)
{
	int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n-1;i++) rline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3],-1);
}



void polyfill(int n,int *tp,int c)
{
	PolyHandle p;
	int i;

	if (c>=0) setcolor(c);

	p=OpenPoly();
	polyline(n,tp,-1);
	ClosePoly();
	FillPoly(p,pat);
	KillPoly(p);
}










/*****************************************************************/
/* instructions d'allocation memoire                             */

long ramfree(void)
{
	return(FreeMem());
}


void *memalloc(long size)
{
	long r;
	r=(long)NewPtr(size);
	if (r<0L) r=0L;
	return((void *)r);
}


void memfree(void **ptr)
{
	if (*ptr) DisposePtr(*ptr);
	*ptr=(void *)0L;
}















/**************************************************************/
/* transferts de blocs memoire */

void bmove(void *src,void *dst,long len)
{
	memmove(dst,src,len);
}












/*****************************************************************/
/* instructions de gestion d'horloge                             */


unsigned long systime(void)
{
	unsigned long r;
	r=(TickCount()*50L)/3L;
	return(r);
}


void waitdelay(unsigned int n)
{
	unsigned long start;
	start=systime();
	do {} while((unsigned long)(systime()-start)<((unsigned long)n));
}


















/******************************************************************/
/* fonctions aleatoires                                           */


int randint(void)
{
	return((unsigned int)(Random())&0x7fff);
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

static int nextfile(void)
{
	int r=0;
	int i;

	for(i=0;i<MAXFILE;i++) if (!fused[i]) r=i+1;
	return(r);
}


static void verifnom(char *s,char *s2)
{

	*s2=':';
	s2++;

	while(*s)
	{
		*s2= *s;
		if (*s=='/') *s2=':';
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
	char *d;
	char *s;
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
					s=(char *)adr;
					d=(char *)(buffer)+offset;
					for(i=0L;i<len;i++) *(d++)= *(s++);
					r=bmake(nom,buffer,filesize);
				}
				memfree((void **)&buffer);
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

	fp = fopen(nom2,"r");
	if (fp)
	{
		fseek(fp, offset, 0);
		r=fread((char *)adr,len,1,fp);
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
		r=fwrite((char *)adr,len,1,fp);
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
		fp = fopen(nom2,"r");
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; }
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
			r=fwrite((char *)adr,len,1,fp);
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
			r=fread((char *)adr,len,1,fp);
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
}

void show(void)
{
}

static void handlemousedown(EventRecord *theEvent)
{
	WindowPtr theWindow;
	int windowCode=FindWindow(theEvent->where,&theWindow);

	switch (windowCode)
	{
	case inSysWindow: 
		SystemClick(theEvent,theWindow);
		break;


	case inDrag:
		if (theWindow == window)
			DragWindow(window,theEvent->where,&dragRect);
		break;

	case inContent:
		if (theWindow == window)
		{
			if (theWindow!=FrontWindow())
				SelectWindow(window);
		}
		break;

	case inGoAway:
		if ((theWindow==window)&&TrackGoAway(window,theEvent->where))
			HideWindow(window);

		killsystem();

		break;
	}
}



static void addchar(int c)
{
	if (keybufnbr<256)
	{
		keybuffer[keybufptr++]=c;
		keybufnbr++;
		keybufptr&=255;
	}
}



static void addbut(int k,int x,int y,int c)
{
	int ptr;

	if (nbrbuffer<32)
	{
		ptr=(msebufptr>>1);
		msebuffer[ptr]=k;
		msebuffer[ptr+1]=x;
		msebuffer[ptr+2]=y;
		msebuffer[ptr+3]=c;
		msebufptr+=8;
		msebufptr&=255;
		nbrbuffer++;
	}
}



static void lookevent(EventRecord theEvent)
{
	Point w;
	int x,y;
	unsigned int k;

	SystemTask();

	switch (theEvent.what)
	{
	case mouseDown:
		w=theEvent.where;
		GlobalToLocal(&w);
		x=w.h/RATIO;
		y=w.v/RATIO;

		if ((x<320)&&(y<200)&&(x>=0)&&(y>=0))
		{
			mousek=1+2*keymap[9];
			addbut(1,x,y,(int)((theEvent.when*10L/6L)&65535L));
		}
		handlemousedown(&theEvent);
		break;

	case mouseUp:

		w=theEvent.where;
		GlobalToLocal(&w);
		x=w.h/RATIO;
		y=w.v/RATIO;

		if ((x<320)&&(y<200)&&(x>=0)&&(y>=0))
		{
			mousek=2*keymap[9];
			addbut(5,x,y,(int)((theEvent.when*10L/6L)&65535L));
		}
		break;

	case keyDown:
		k=(unsigned int)(theEvent.message&charCodeMask);
		addchar(k); 
		keymap[k]=1;
		if (k==9) addbut(2,mousex,mousey,(int)((theEvent.when*10L/6L)&65535L));
		break;


	case keyUp:
		k=(unsigned int)(theEvent.message&127L);
		keymap[k]=0;
		if (k==9) addbut(6,mousex,mousey,(int)((theEvent.when*10L/6L)&65535L));
		break;

	case updateEvt:
		BeginUpdate(window);
		refresh();
		EndUpdate(window);
		break;

	case activateEvt:
		InvalRect(&window->portRect);
		break;

	}
}





int getmouse(void)
{
	int ptr;

	buthit();

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

		/* msek: bit 0:bouton bit 1:touche "tab" bit 2:0:presse 1:relache */

		return(msek);
	}

	return(0);
}





static int msemoved(void)
{
	int r=0;
	int k,x,y;
	Point vh;

	GetMouse(&vh);

	mousex=vh.h/RATIO;
	mousey=vh.v/RATIO;
	if (mousex>319) mousex=319;
	if (mousey>199) mousey=199;
	if (mousex<0) mousex=0;
	if (mousey<0) mousey=0;
	mousek=keymap[9]*2;
	if (Button()) mousek|=1;

	return(mousek);
}









int buthit(void)
{
	int r;
	int n,k,x,y;
	EventRecord ev;
	Point w;

	pw=1; 
	SetPort(window);
	do
	    {
		r=GetNextEvent(everyEvent,&ev);

		if (r) lookevent(ev);
	}
	while(r);

	msemoved();

	pw=0; 
	SetPort(&grafport[ecran_travail]);
	return(nbrbuffer);
}






void empty(void)
{
	kbhit();
	buthit();

	keybufnbr=keybufptr=keybufend=0;
	nbrbuffer=lstbufptr=msebufptr=0;
}


char getch(void)
{
	char c=0;
	do {} while(!kbhit());
	if (keybufnbr)
	{
		c=keybuffer[keybufend++];
		keybufend&=255;
		keybufnbr--;
	}

	return(c);
}


int kbhit(void)
{
	int r;
	unsigned int k;
	EventRecord ev;

	pw=1; 
	SetPort(window);
	do
	    {
		r=GetNextEvent(everyEvent,&ev);

		if (r) lookevent(ev);
	}
	while(r);


	pw=0; 
	SetPort(&grafport[ecran_travail]);
	return(keybufnbr);
}


int keyhit(void)
{
	int r;

	r=buthit();
	if (!r) r=kbhit();
	return(r);
}



void confirm(void)
{
	empty();
	while(!buthit());
}

















/***************************************************************/
/* gestion de blocs graphiques */


typedef struct
{
	int lx;
	int ly;
	int id;
	BitMap bloc;
	BitMap mask;
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
		if (bloc->id) memfree((void **)&bloc->bloc.baseAddr);
		if (bloc->id==2) memfree((void **)&bloc->mask.baseAddr);
		bloc->id=0;
		memfree((void **)blocptr);
	}
}



void getbloc(void **blocptr,int x,int y,int lx,int ly)
{
	Rect r;
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if ((!bloc->id)||(bloc->lx!=lx)||(bloc->ly!=ly))
		{
			if (bloc->id) memfree((void **)&bloc->bloc.baseAddr);
			if (bloc->id==2) memfree((void **)&bloc->mask.baseAddr);
			bloc->id=0;
			if (bloc->bloc.baseAddr=memalloc(((long)lx)*RATIO*ly*RATIO))
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
				bloc->bloc.rowBytes=(lx*RATIO+7)/8;
				SetRect(&bloc->bloc.bounds,0,0,lx*RATIO,ly*RATIO);
			}
		}

		SetRect(&r,x*RATIO,y*RATIO,(x+lx)*RATIO,(y+ly)*RATIO);
		if (bloc->id)
		CopyBits(&ecran[ecran_travail],&bloc->bloc,&r,&bloc->bloc.bounds,
			srcCopy,0L);

	}
}




void copybloc(void **blocptrs,int xs,int ys,int lxs,int lys,void **blocptrd,int xd,int yd)
{
	Rect rs,rd;
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
		SetRect(&rs,xs*RATIO,ys*RATIO,(xs+lxs)*RATIO,(ys+lys)*RATIO);
		SetRect(&rd,xd*RATIO,yd*RATIO,(xd+lxs)*RATIO,(yd+lys)*RATIO);
		CopyBits(&blocs->bloc,&blocd->bloc,&rs,&rd,srcCopy,0L);

		if ((blocs->id==2)&&(blocd->id==2))
		{
		SetRect(&rs,xs*RATIO,ys*RATIO,(xs+lxs)*RATIO,(ys+lys)*RATIO);
		SetRect(&rd,xd*RATIO,yd*RATIO,(xd+lxs)*RATIO,(yd+lys)*RATIO);
		CopyBits(&blocs->mask,&blocd->mask,&rs,&rd,srcCopy,0L);
		}
		}
	}
}



void putpbloc(void **blocptr,int x,int y,int xs,int ys,int lxs,int lys)
{
	Rect r,rs;
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
		if (bloc->id==1)
		{
		SetRect(&rs,xs*RATIO,ys*RATIO,(xs+lxs)*RATIO,(ys+lys)*RATIO);
		SetRect(&r,x*RATIO,y*RATIO,(x+lxs)*RATIO,(y+lys)*RATIO);
		CopyBits(&bloc->bloc,&ecran[ecran_travail],&rs,&r,srcCopy,0L);
		}
		else
		if (bloc->id==2)
		{
		SetRect(&rs,xs*RATIO,ys*RATIO,(xs+lxs)*RATIO,(ys+lys)*RATIO);
		SetRect(&r,x*RATIO,y*RATIO,(x+lxs)*RATIO,(y+lys)*RATIO);
		CopyMask(&bloc->bloc,&bloc->mask,&ecran[ecran_travail],
			&rs,&rs,&r);
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
	Rect r;
	pixbloc *bloc;

	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;
		if (bloc->id)
		{
			if (bloc->id==2)
			{
				memfree((void **)&bloc->mask.baseAddr);
				bloc->id=1;
			}
			if (bloc->id==1)
			{
			bloc->mask.baseAddr=
				memalloc(((long)bloc->lx)*RATIO*bloc->ly*RATIO);
			if (bloc->mask.baseAddr)
				{
				bloc->id=2;
				bloc->mask.rowBytes=(bloc->lx*RATIO+7)/8;
				SetRect(&bloc->mask.bounds,0,0,bloc->lx*RATIO,
					bloc->ly*RATIO);
				}
			}
		SetRect(&r,x*RATIO,y*RATIO,(x+bloc->lx)*RATIO,(y+bloc->ly)*RATIO);
		if (bloc->id==2)
		CopyBits(&ecran[ecran_travail],&bloc->mask,&r,&bloc->mask.bounds,
			notSrcCopy,0L);
		}
	}
}
















/*****************************************************************/
/* instructions de gestion de fonte */



void affchar(int x,int y,char c)
{
	BitMap cbloc;
	BitMap cmask;
	unsigned int n,i,j,k,m,f,t;
	Rect r;


	if ((c>31)&&(c<128))
	{
		if (c>95) c-=32;

		n=c-32;

		if (((oldpal[color]>>12)==8)&&(RATIO!=1))
		{
			SetRect(&r,x*RATIO,y*RATIO,(x+8)*RATIO,(y+8)*RATIO);
			cmask.baseAddr=(void *)&sysfonte[n*16];
			cmask.rowBytes=1;
			SetRect(&cmask.bounds,0,0,8,8);
			CopyBits(&cmask,&ecran[ecran_travail],&cmask.bounds,
				&r,notSrcOr,0L);

			cmask.baseAddr=(void *)&sysfonte[n*16+8];
			cmask.rowBytes=1;
			SetRect(&cmask.bounds,0,0,8,8);
			cbloc.baseAddr=(void *)pat;
			cbloc.rowBytes=1;
			SetRect(&cbloc.bounds,0,0,8,8);
			CopyMask(&cbloc,&cmask,&ecran[ecran_travail],
				&cbloc.bounds,&cmask.bounds,&r);
		}
		else
		{
			t=color;
			for(i=0;i<8;i++)
		for(m=sysfonte[n*16+i],f=sysfonte[n*16+i+8],k=0;k<8;k++,f<<=1,m<<=1)
		if (!(m&128)) if (f&128) plot(x+k,y+i,t); else plot(x+k,y+i,0);
			setcolor(t);
		}

	}

}




void afftext(int x,int y,char *s)
{

	while(*s)
	{
		affchar(x,y,*s++);
		x+=8;
		if (x>312) { x=0; y+=8; if (y>192) y=0; }
	}

}



void printchar(char c)
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
	if (c==13) { ycur+=8; xcur= -8; }
	else
	affchar(xcur,ycur,c);

	xcur+=8;
	if (xcur>312) { xcur=0; ycur+=8; } 


}



void print(char *s)
{
	while(*s) printchar(*s++);

	xcur=0; 
	ycur+=8; 
	
}




































/*******************************************************************/
/* gestion des samples */

void playsample(void *adr,long len,long freq)
{
	struct FFSynthRec *myFFPtr;
	Fixed sf;

	if (adr)
	{
		sf=3*(Fixed)freq;
/* coefficient egal a 3 sur les Mac LCIII */
/* Si vous vous apercevez que la frequence est trop grande ou trop petite, changez ce coefficient. */

		myFFPtr=(struct FFSynthRec *)adr;
		myFFPtr->mode=ffMode;
		myFFPtr->count=sf;

/* on remplace les 6 premiers octets par mode et frequence */
		StopSound();
		StartSound((void *)adr,len-6,(SndCompletionProcPtr)(0));

	}
}

void stopsample()
{
	StopSound();
}

void fixsample(void *adr,long len)
{
}

 

