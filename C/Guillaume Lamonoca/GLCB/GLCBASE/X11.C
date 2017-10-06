/*
X11.c (module de base pour environnement X11:vms,unix,etc...)
Description des instructions de ce module dans doc.txt.
Guillaume LAMONOCA
Christophe JOUIN
Supelec (94)

Definir 'EXTENSION' dans header.h afin de pouvoir utiliser la palette
 etendue de 256 couleurs avec composantes sur 3*16 bits
 Vous pouvez regler NBCOLORS avec le nombre de couleurs desire
 (pour epargner les couleurs utilisees par le session manager par ex.)


compilation et edition de lien manuelle d'un programme utilisant x11.c:

sur vms:
	cc x11.c
	cc exemple.c
	link exemple.obj,x11.obj,$users:[public.x11]xlib.opt/opt

(sur alpha compilez avec l'option /standard=vaxc le cas echeant...)
(xlib.opt est un fichier texte contenant la ligne suivante:
sys$share:decw$xlibshr/share   (ne pas oublier Return a la fin))

(Si FTIME n'est pas definie faites
$define lnk$library sys$library:vaxctrl)


sur unix:
	cc -c x11.c
	cc -c exemple.c
	cc exemple.o x11.o -lX11 -lm -o exemple
(ou)cc exemple.o x11.o -lX11 -lbsd -lm -o exemple (si ftime est non defini)


utilisation d'un makefile (ou exemple.mak) (vms):
exemple.exe : exemple.obj x11.obj
(tab)link exemple.obj,x11.obj,[public.x11]xlib.opt/opt
exemple.obj : exemple.c
(tab)cc exemple.c
x11.obj : x11.c
(tab)cc x11.c

utilisation d'un makefile (ou exemple.mak) (unix):
exemple : exemple.o x11.o
(tab)cc exemple.o x11.o -lX11 -lm -o exemple
exemple.o : exemple.c
(tab)cc -c exemple.c
x11.o : x11.c
(tab)cc -c x11.c

lancement de la compilation des modules et de l'edition de lien par:
make (ou make -f exemple.mak)

Si vous avez des problemes de reactions de la souris (test suivi de souris)
modifiez la fonction waitdelay: utilisez l'attente active.
*/

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#ifndef VMS
#include <sys/time.h>
#include <sys/timeb.h>
#endif

#include "header.h"

#ifdef VMS
extern void lib$wait(float *);
#endif


/********************************************************************/
/* variables globales */

#define DUREEMAX 1000*60*60  /* duree max d'inactivite permise: 1h    */
#define MINDELAY 50          /* evite saturation du serveur graphique */

#define RATIO 2
#define WIDTH 320
#define HEIGHT 200
#define NBCOLORS 16	     /* extensible, mais n'en abusez pas */
			     /* restez compatible avec 16 couleurs */
static int emulmono=0;

static int autokill=1;       /* 1: suicide si inactivite trop longue  */

#ifdef EXTENSION
#undef NBCOLORS
#define NBCOLORS 256         /* a reduire si vous voulez epargnez les */
#endif                       /* couleurs des autres fenetres ouvertes */




static unsigned int egapal[NBCOLORS]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};



static unsigned int oldpal[NBCOLORS];
static unsigned int oldbigpal[3*256];


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
static Display *display;
static Window window;
static int rdepth;
static int sdepth=1;
static GC gc;
static Screen *screen;
static unsigned long white,black;
static Colormap colormap,xcolormap;
static GC gctab[(NBCOLORS+2)];
static unsigned long pixels[(NBCOLORS+2)];
static XColor colors[NBCOLORS];
static Visual *visual;
static int allocpal=0;
static Pixmap ecran[2];
static Pixmap graypixmap[9];

static int color=15;

static int xcur=0;
static int ycur=0;

static unsigned long timestart;

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

static unsigned long last;

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




























/************************************************************/
/* initialisation du systeme */


int initsystem(void)  /* retourne 1 si initialisation reussie */
{
	int i;
	int windowW;
	int windowH;
	XSetWindowAttributes xswa;
	XGCValues xgcv;
	XSizeHints xsh;

	windowW=WIDTH*RATIO;
	windowH=HEIGHT*RATIO;
	display=XOpenDisplay(0);

	if (!display) return(0);
	else
	{
		mousek=0;
		XAutoRepeatOff(display);
		timestart=last=systime();
		screen=XDefaultScreenOfDisplay(display);
		rdepth=sdepth=XDefaultDepthOfScreen(screen);
		if (emulmono) sdepth=1;
		XSynchronize(display,0);

		black=XBlackPixelOfScreen(screen);
		white=XWhitePixelOfScreen(screen);
		colormap=XDefaultColormapOfScreen(screen);
		visual=XDefaultVisualOfScreen(screen);

		xswa.event_mask=VisibilityChangeMask;
		xswa.background_pixel=black;
		xswa.border_pixel=white;
		xswa.override_redirect=0;
		xswa.backing_store=Always;
		xswa.bit_gravity=StaticGravity;
		xswa.win_gravity=CenterGravity;
		window=XCreateWindow(display,XRootWindowOfScreen(screen),
			randval(50),randval(100),windowW,windowH,0,
			XDefaultDepthOfScreen(screen),InputOutput,
			XDefaultVisualOfScreen(screen),
			CWWinGravity|CWBitGravity|CWBackingStore|CWEventMask|
			CWBackPixel|CWOverrideRedirect|CWBorderPixel,&xswa);

		if (sdepth!=1)
			xcolormap=XCreateColormap(display,window,
				visual,AllocAll);

		xgcv.foreground = white;
		xgcv.background = black;
		gc=XCreateGC(display,window,GCForeground | GCBackground,&xgcv);

		XSetGraphicsExposures(display,gc,False);
		/* CAPITAL!!! : evite d'accumuler sans cesse des expose events */

		xsh.x=0;
		xsh.y=0;
		xsh.width=windowW;
		xsh.height=windowH;
		xsh.min_width=windowW;
		xsh.max_width=windowW;
		xsh.min_height=windowH;
		xsh.max_height=windowH;
		xsh.flags=PPosition|PSize|PMinSize|PMaxSize;

		XSetNormalHints(display, window, &xsh);
		XStoreName(display,window,"");
		XMapWindow(display, window);
		XSelectInput(display,window,PointerMotionMask|ButtonPressMask|
			ButtonReleaseMask|KeyPressMask|KeyReleaseMask);
		XFlush(display);
		XSync(display,0);

		for (i=0;i<(NBCOLORS+2);i++)
		{
			if (i&1) pixels[i]=white; else pixels[i]=black;
			if (i==NBCOLORS) pixels[i]=0;
			if (i==(NBCOLORS+1)) pixels[i]=(1<<rdepth)-1;
			xgcv.foreground=pixels[i];
			xgcv.background=black;
			gctab[i]=XCreateGC(display,window,
				GCForeground|GCBackground,&xgcv);
			XSetFunction(display,gctab[i],GXcopy);
			XSetFillStyle(display,gctab[i],FillSolid);
		}

		ecran[0]=XCreatePixmap(display,window,windowW,windowH,rdepth);
		ecran[1]=XCreatePixmap(display,window,windowW,windowH,rdepth);

		for(i=0;i<9;i++)
			graypixmap[i]=XCreatePixmapFromBitmapData(display,window,
				&graypat[i][0],8,8,white,black,rdepth);

		setpalette(egapal);

		cls();
		swap();
		cls();

		empty();
		waitdelay(500);

		return(1);
	}
}





void killsystem(void)
{
	int i;

	if ((allocpal)&&(sdepth!=1))
		XFreeColors(display,colormap,pixels,NBCOLORS,0);

	XUnmapWindow(display,window);
	XDestroyWindow(display,window);
	XFreeGC(display,gc);
	if (sdepth!=1) XFreeColormap(display,xcolormap);
	for(i=0;i<(NBCOLORS+2);i++) XFreeGC(display,gctab[i]);
	for(i=0;i<9;i++) XFreePixmap(display,graypixmap[i]);
	XFreePixmap(display,ecran[0]);
	XFreePixmap(display,ecran[1]);
	XAutoRepeatOn(display);
	XCloseDisplay(display);
	exit(0);
}












/***************************************************************/
/* gestion des couleurs */


void setcolor(int c)
{
	if (c==FOND) c=NBCOLORS;
	if (c==MASK) c=(NBCOLORS+1);
	color=c;
}


void getpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<NBCOLORS;i++) pal[i]=oldpal[i];
}



void setpalette(unsigned int *pal)
{
	int i,norme;
	int block=0;
	int ok=1;

	XGCValues xgcv;

	for(i=0;i<NBCOLORS;i++) oldpal[i]=pal[i];

	if (sdepth==1)
	{
		for (i=0;i<NBCOLORS;i++)
		{
			xgcv.foreground=pixels[i]=white;
			xgcv.background=black;
			XChangeGC(display,gctab[i],
				GCForeground|GCBackground,&xgcv);
			XSetTile(display,gctab[i],graypixmap[pal[i]>>12]);
			XSetFillStyle(display,gctab[i],FillTiled);
		}
	}
	else
	{
		XSetWindowColormap(display,window,colormap);
		if ((allocpal)&&(sdepth!=1))
			XFreeColors(display,colormap,pixels,NBCOLORS,0);
		if (XAllocColorCells(display,colormap,0,0,0,pixels,NBCOLORS)) 
			block=1;

		for(i=0;i<NBCOLORS;i++)
		{
			colors[i].red=((pal[i]>>8)&15)*4369;
			colors[i].green=((pal[i]>>4)&15)*4369;
			colors[i].blue=(pal[i]&15)*4369;
			colors[i].flags=DoRed|DoBlue|DoGreen;
			colors[i].pixel=pixels[i];

			if (!block)
			{
				XAllocColor(display,colormap,&colors[i]);
				pixels[i]=colors[i].pixel;
			}
			xgcv.foreground=pixels[i];
			xgcv.background=black;
			XChangeGC(display,gctab[i],
				GCForeground|GCBackground,&xgcv);
			XSetFillStyle(display,gctab[i],FillSolid);
		}
		if (block) XStoreColors(display,colormap,colors,NBCOLORS); else ok=0;
		XSetWindowColormap(display,window,colormap);
	}

	if (ok) allocpal=1; 
	else
	{


		for (i=0;i<NBCOLORS;i++)
		{
			colors[i].red=((pal[i]>>8)&15)*4369;
			colors[i].green=((pal[i]>>4)&15)*4369;
			colors[i].blue=(pal[i]&15)*4369;
			colors[i].flags=DoRed|DoBlue|DoGreen;
			colors[i].pixel=i;
			pixels[i]=i;
			xgcv.foreground=pixels[i];
			xgcv.background=black;
			XChangeGC(display,gctab[i],
				GCForeground|GCBackground,&xgcv);
			XSetFillStyle(display,gctab[i],FillSolid);
		}

		XStoreColors(display,xcolormap,colors,NBCOLORS);
		XSetWindowColormap(display,window,xcolormap);

	}

}




/***************************************************************/
/* gestion de la palette etendue */




void setallpalette(void)
{
	int i,norme;
	int block=0;
	int ok=1;

	XGCValues xgcv;

	if (sdepth==1)
	{
		for (i=0;i<NBCOLORS;i++)
		{
			norme=oldbigpal[i*3]*3+oldbigpal[i*3+1]*6+oldbigpal[i*3+2];
			norme/=72817;
			xgcv.foreground=pixels[i]=white;
			xgcv.background=black;
			XChangeGC(display,gctab[i],
				GCForeground|GCBackground,&xgcv);
			XSetTile(display,gctab[i],graypixmap[norme]);
			XSetFillStyle(display,gctab[i],FillTiled);
		}
	}
	else
	{
		XSetWindowColormap(display,window,colormap);
		if ((allocpal)&&(sdepth!=1))
			XFreeColors(display,colormap,pixels,NBCOLORS,0);
		if (XAllocColorCells(display,colormap,0,0,0,pixels,NBCOLORS)) 
			block=1;

		for(i=0;i<NBCOLORS;i++)
		{
			colors[i].red=oldbigpal[i*3];
			colors[i].green=oldbigpal[i*3+1];
			colors[i].blue=oldbigpal[i*3+2];
			colors[i].flags=DoRed|DoBlue|DoGreen;
			colors[i].pixel=pixels[i];

			if (!block)
			{
				XAllocColor(display,colormap,&colors[i]);
				pixels[i]=colors[i].pixel;
			}
			xgcv.foreground=pixels[i];
			xgcv.background=black;
			XChangeGC(display,gctab[i],
				GCForeground|GCBackground,&xgcv);
			XSetFillStyle(display,gctab[i],FillSolid);
		}
		if (block) XStoreColors(display,colormap,colors,NBCOLORS); else ok=0;
		XSetWindowColormap(display,window,colormap);
	}

	if (ok) allocpal=1; 
	else
	{
		for (i=0;i<NBCOLORS;i++)
		{
			colors[i].red=oldbigpal[i*3];
			colors[i].green=oldbigpal[i*3+1];
			colors[i].blue=oldbigpal[i*3+2];
			colors[i].flags=DoRed|DoBlue|DoGreen;
			colors[i].pixel=i;
			pixels[i]=i;
			xgcv.foreground=pixels[i];
			xgcv.background=black;
			XChangeGC(display,gctab[i],
				GCForeground|GCBackground,&xgcv);
			XSetFillStyle(display,gctab[i],FillSolid);
		}

		XStoreColors(display,xcolormap,colors,NBCOLORS);
		XSetWindowColormap(display,window,xcolormap);

	}

}



void setbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;

	for(i=0;i<3*nb;i++) oldbigpal[3*no+i]=ptr[i];
	setallpalette();
}


void getbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;

	for(i=0;i<3*nb;i++) ptr[i]=oldbigpal[3*no+i];
}

void setbigcolor(int n,unsigned int r,unsigned int v,unsigned int b)
{
	oldbigpal[n*3]=r;
	oldbigpal[n*3+1]=v;
	oldbigpal[n*3+2]=b;
	setallpalette();
}

void getbigcolor(int n,unsigned int *r,unsigned int *v,unsigned int *b)
{
	*r=oldbigpal[n*3];
	*v=oldbigpal[n*3+1];
	*b=oldbigpal[n*3+2];
}






/************************************************************/
/* instructions de gestion des ecrans graphiques */

void simplescreen(void)
{
	ecran_travail=ecran_actif;
}


void doublescreen(void)
{
	ecran_travail=1-ecran_actif;
}


void cls(void)
{
	xcur=ycur=0;
	XFillRectangle(display,ecran[ecran_travail],gctab[0],
		0,0,WIDTH*RATIO,HEIGHT*RATIO);
}


void copyscreen(void)
{
	XFlush(display);
	XSync(display,0);
	XSetFunction(display,gc,GXcopy);
	XCopyArea(display,ecran[ecran_actif],ecran[ecran_travail],gc,
		0,0,WIDTH*RATIO,HEIGHT*RATIO,0,0);
}


void refresh(void)
{
	unsigned long dif;

	dif=systime()-last;
	if (dif<MINDELAY) waitdelay(MINDELAY-dif);

	vblclock++;

	XSetFunction(display,gc,GXcopy);
	XCopyArea(display,ecran[ecran_actif],window,gc,
		0,0,WIDTH*RATIO,HEIGHT*RATIO,0,0);
	XFlush(display);
	XSync(display,0);

	
	last=systime();
}


void swap(void)
{
	unsigned long dif;

	dif=systime()-last;
	if (dif<MINDELAY) waitdelay(MINDELAY-dif);

	vblclock++;

	ecran_travail=1L-ecran_travail;
	ecran_actif=1L-ecran_actif;

	XSetFunction(display,gc,GXcopy);

	XCopyArea(display,ecran[ecran_actif],window,gc,
		0,0,WIDTH*RATIO,HEIGHT*RATIO,0,0);

	XFlush(display);
	XSync(display,0);


	last=systime();

}








/******************************************************************/
/* instructions graphiques de base */

#undef sgn
#undef abs
#define sgn(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define abs(x) ((x<0)?(-(x)):(x))


void pellipse(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);
	XFillArc(display,ecran[ecran_travail],gctab[color],
	RATIO*x,RATIO*y,RATIO*lx,RATIO*ly,0,360*64);
}


void pbox(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);
	XFillRectangle(display,ecran[ecran_travail],
	gctab[color],x*RATIO,y*RATIO,lx*RATIO,ly*RATIO);
}


void plot(int x,int y,int c)
{
	if (c>=0) setcolor(c);
	XFillRectangle(display,ecran[ecran_travail],
	gctab[color],x*RATIO,y*RATIO,RATIO,RATIO);
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

	XDrawLine(display,ecran[ecran_travail],gctab[color],x*RATIO,y*RATIO,
		x2*RATIO,y2*RATIO);
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
	XPoint points[256];
	int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n;i++)
	{
		points[i].x=RATIO*tp[i*2];
		points[i].y=RATIO*tp[i*2+1];
	}
	XFillPolygon(display,ecran[ecran_travail],gctab[color],
	points,n,Complex,CoordModeOrigin);
}





















/*****************************************************************/
/* instructions d'allocation memoire                             */

long ramfree(void)
{
	return(10000000L); /* on ne sait pas faire:supposons memoire infinie */
}

void *memalloc(long size)
{
	return((void *)malloc(size));
}

void memfree(void **ptr)
{
	if (*ptr) free(*ptr);
	*ptr=(void *)0L;
}












/**************************************************************/
/* transferts de blocs memoire */

void bmove(void *src,void *dst,long len)
{
	char *s;
	char *d;
	long i;

	s=(char *)src;
	d=(char *)dst;
	if (s>d)
		for(i=0;i<len;i++) *(d++)= *(s++);
	else
		for(d+=len,s+=len,i=0;i<len;i++) *(--d)= *(--s);
}

















/*****************************************************************/
/* instructions de gestion d'horloge                             */


unsigned long systime(void)
{
	struct timeb t;

	ftime(&t);
	return(t.time*1000L+t.millitm);
}


void waitdelay(unsigned int n)
{
/* attente active: */
/*
	unsigned long start;
	start=systime();
	do {} while((unsigned long)(systime()-start)<((unsigned long)n));
*/

/* attente inactive: on rend la main au serveur. */

#ifdef VMS
	float f;

	f=(float)(n/1000.0);
	lib$wait(&f);
#else
	unsigned long usec;
	struct timeval timeout;

	usec=(unsigned long)n*1000L;
	timeout.tv_usec=usec%(unsigned long)1000000;
	timeout.tv_sec=usec/(unsigned long)1000000;
	(void)select(0,(void *)0,(void *)0,(void *)0,&timeout);
#endif
}















/*****************************************************************/
/* fonctions aleatoires                                          */

int randint(void)
{
	return((int)((rand()>>2)+128*rand())&0x7fff);
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
#ifdef VMS
	int n= -1;
	int i=0;
	char *p;

	p=s;


	while(*p)
	{
		if (*p=='/') n=i;
		i++;
		p++;
	}

	if (n>-1)
	{
		*(s2++)='[';
		*(s2++)='.';
		for(i=0;i<n;i++)
		{
			*s2= *s;
			if (*s=='/') *s2='.';
			s2++;
			s++;
		}
		s++;
		*(s2++)=']';
	}

	while(*s)
	{
		*s2= *s;
		s++;
		s2++;
	}
	*s2=0;

#else

	while(*s)
	{
		*s2= *s;
		s++;
		s2++;
	}
	*s2=0;

#endif

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

#ifdef VMS
/* pour ne pas creer de version supplementaire sous VMS   */
/* dans le cas ou l'on ne change pas la taille du fichier */
	if (bsize(nom)==len)
	{
		fp = fopen(nom2,"ab+");
		if (fp)
		{
			fseek(fp, 0, 0);
			r=fwrite((char *)adr,len,1,fp);
			if (r==1) r=0; 
			else r= -1;
			fclose(fp);
		}
	}
	else
#endif
	{
		fp = fopen(nom2,"wb");
		if (fp)
		{
			r=fwrite((char *)adr,len,1,fp);
			if (r==1) r=0; 
			else r= -1;
			fclose(fp);
		}
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

void hide()
{
}

void show()
{
}

static void addbut(int k,int x,int y,int c)
{
	int ptr;

	if (k==1) mousek|=1;
	if (k==2) mousek|=2;
	if (k==5) mousek&=~1;
	if (k==6) mousek&=~2;

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

/* msek: bit 0:bouton gauche bit 1:bouton du milieu bit 2:0:presse 1:relache */

		return(msek);
	}

	return(0);
}






static void msemoved(void)
{
	int r;
	int k,x,y;
	XEvent ev;

	do
	    {
		r=XCheckWindowEvent(display,window,PointerMotionMask,&ev);

		if (autokill)
		{
			if (r) timestart=systime();
			else
			if ((unsigned long)(systime()-timestart)>DUREEMAX)
				killsystem();
		}
		else
		timestart=systime();

		if (r)
		{
			mousex=ev.xmotion.x/RATIO;
			mousey=ev.xmotion.y/RATIO;
		}

	}
	while(r);

}









int buthit(void)
{
	int r;
	int n,k,x,y;
	XEvent ev;

	do
	    {
		r=XCheckWindowEvent(display,window,
			ButtonPressMask|ButtonReleaseMask,&ev);

		if (autokill)
		{
			if (r) timestart=systime();
			else
			if ((unsigned long)(systime()-timestart)>DUREEMAX)
				killsystem();
		}
		else
		timestart=systime();

		if (r)
		{
			x=ev.xbutton.x/RATIO;
			y=ev.xbutton.y/RATIO;
			n=(ev.xbutton.state>>8)&3;

			k=ev.xbutton.button;
			if (k==1) { if (n&1) k=5; }
			else
			if (k==2) { if (n&2) k=6; }
			else
			k=0;

			if (k) addbut(k,x,y,vblclock++);
		}

	}
	while(r);

	msemoved();

	return(nbrbuffer);
}



static void addchar(char c)
{
	if (keybufnbr<256)
	{
		keybuffer[keybufptr++]=c;
		keybufnbr++;
		keybufptr&=255;
	}
}

void empty(void)
{
	kbhit();
	buthit();

	keybufnbr=keybufptr=keybufend=0;
	nbrbuffer=lstbufptr=msebufptr=0;
}

static int conversion(XEvent *event)
{
  XKeyEvent *ev;
  int k;

	ev=(XKeyEvent *)event;

	k=XLookupKeysym(ev,0);

	if (k==XK_grave)
		return 27;
	if (k>=XK_KP_0 && k<=XK_KP_9)
		return k-XK_KP_0+'0';
	if (k<128)
		return k;
	else
	{
		switch(k)
		{
		case XK_Control_L : /* CTRL */
		case XK_Shift_L :
		case XK_Multi_key : /* caractere compose */
		case XK_Alt_L :
		case XK_Alt_R :
		case XK_Shift_R :
			return 32;
		case XK_Delete :
			return 8;
		case XK_Return :
		case XK_KP_Enter :
			return 13;
		case XK_KP_F3 :
			return '/';
		case XK_KP_F4 :
			return '*';
		case XK_KP_Subtract :
			return '-';
		case XK_KP_Add :
			return '+';
		case XK_KP_Separator :
			return ',';
		case XK_KP_Decimal :
			return '.';
		case XK_Left :
			return '<';
		case XK_Right :
			return '>';
		case XK_Up :
			return '^';
		case XK_Down :
			return 'v';
		case XK_Escape :
			return 27;
		
		}
		
	}
	return 0;
}



char getch(void)
{
	XEvent ev;
	char c=0;
	int k;
	
	if (!kbhit())
	{
		XWindowEvent(display,window,KeyPressMask,&ev);

		timestart=systime();
		
		k=conversion(&ev);
		addchar(k); 
		keymap[k]=1; 
	}
	
	c=keybuffer[keybufend++];
	keybufend&=255;
	keybufnbr--;

	return(c);
}


int kbhit(void)
{
	int r,k;
	XEvent ev;

	do
	    {
		r=XCheckWindowEvent(display,window,
			KeyPressMask|KeyReleaseMask,&ev);

		if (autokill)
		{
			if (r) timestart=systime();
			else
			if ((unsigned long)(systime()-timestart)>DUREEMAX)
				killsystem();
		}
		else
		timestart=systime();

		if (r)
		{

			k=conversion(&ev);
			if (ev.xkey.type==KeyPress) { 
				addchar(k); 
				keymap[k]=1; 
			} 
			else keymap[k]=0;
		}

	}
	while(r);

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
	XEvent ev;
	int x,y,k,n;

	empty();
	XWindowEvent(display,window,ButtonPressMask,&ev);

	timestart=systime();
	x=ev.xbutton.x/RATIO;
	y=ev.xbutton.y/RATIO;
	n=(ev.xbutton.state>>8)&3;

	k=ev.xbutton.button;
	if (k==1) { 
		if (n&1) k=5; 
	}
	else
		if (k==2) { 
			if (n&2) k=6; 
		}
		else
			k=0;

	if (k) addbut(k,x,y,vblclock++);
}


















/***************************************************************/
/* gestion de blocs graphiques */


typedef struct
{
	int lx;
	int ly;
	int id;
	Pixmap bloc;
	Pixmap mask;
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
		if (bloc->id) XFreePixmap(display,bloc->bloc);
		if (bloc->id==2) XFreePixmap(display,bloc->mask);
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
			if (bloc->id) XFreePixmap(display,bloc->bloc);
			if (bloc->id==2) XFreePixmap(display,bloc->mask);
			bloc->id=0;
			bloc->bloc=XCreatePixmap(display,window,
				lx*RATIO,ly*RATIO,rdepth);
			if (bloc->bloc)
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}

		XSetFunction(display,gc,GXcopy);
		if (bloc->id)
		XCopyArea(display,ecran[ecran_travail],bloc->bloc,gc,
			x*RATIO,y*RATIO,lx*RATIO,ly*RATIO,0,0);

	}
}


void copybloc(void **blocptrs,int xs,int ys,int lxs,int lys,void **blocptrd,int xd,int yd)
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
			XSetFunction(display,gc,GXcopy);
			XCopyArea(display,blocs->bloc,blocd->bloc,
				gc,xs*RATIO,ys*RATIO,lxs*RATIO,lys*RATIO,
				xd*RATIO,yd*RATIO);

		if ((blocs->id==2)&&(blocd->id==2))
		{
			XSetFunction(display,gc,GXcopy);
			XCopyArea(display,blocs->mask,blocd->mask,
				gc,xs*RATIO,ys*RATIO,lxs*RATIO,lys*RATIO,
				xd*RATIO,yd*RATIO);
		}
		}
	}
}



void putpbloc(void **blocptr,int x,int y,int xs,int ys,int lxs,int lys)
{
	pixbloc *bloc;
	if (*blocptr)
	{
		bloc=(pixbloc *)*blocptr;

		if ((y>=0)||(y+lys<=HEIGHT))
		{
			if (y<0)
			{
				ys+=(-y);
				lys-=(-y);
				y=0;
			}
			else
			if (y+lys>HEIGHT)
			{
				lys=HEIGHT-y;
			}
		}
		if (lys>0)
		if ((x>=0)&&(y>=0)&&(xs>=0)&&(ys>=0))
		if ((x<WIDTH)&&(y<HEIGHT))
		if ((x+lxs<=WIDTH)&&(y+lys<=HEIGHT))
		if (bloc->id==1)
		{
			XSetFunction(display,gc,GXcopy);
			XCopyArea(display,bloc->bloc,ecran[ecran_travail],
				gc,xs*RATIO,ys*RATIO,lxs*RATIO,lys*RATIO,
				x*RATIO,y*RATIO);
		}
		else
		if (bloc->id==2)
		{
			XSetFunction(display,gc,GXand);
			XCopyArea(display,bloc->mask,ecran[ecran_travail],
				gc,xs*RATIO,ys*RATIO,lxs*RATIO,lys*RATIO,
				x*RATIO,y*RATIO);
			XSetFunction(display,gc,GXor);
			XCopyArea(display,bloc->bloc,ecran[ecran_travail],
				gc,xs*RATIO,ys*RATIO,lxs*RATIO,lys*RATIO,
				x*RATIO,y*RATIO);
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
				XFreePixmap(display,bloc->mask);
				bloc->id=1;
			}
			if (bloc->id==1)
			{
				bloc->mask=XCreatePixmap(display,window,
					bloc->lx*RATIO,bloc->ly*RATIO,rdepth);
				if (bloc->mask) bloc->id=2;
			}
		
		XSetFunction(display,gc,GXcopyInverted);
		if (bloc->id==2)
		XCopyArea(display,ecran[ecran_travail],bloc->mask,gc,
			x*RATIO,y*RATIO,bloc->lx*RATIO,bloc->ly*RATIO,0,0);
		}
	}
}



















/*****************************************************************/
/* instructions de gestion de fonte */


void affchar(int x,int y,char c)
{
	unsigned int n,i,j,k,m,f,t;

	t=color;
	if ((c>31)&&(c<=127))
	{
		if (c>95) c-=32;

		n=c-32;

		for(i=0;i<8;i++)
		for(m=sysfonte[n*16+i],f=sysfonte[n*16+i+8],k=0;k<8;k++,f<<=1,m<<=1)
			if (!(m&128))
			if (f&128) plot(x+k,y+i,t); else plot(x+k,y+i,0);

		setcolor(t);
	}

}



void afftext(int x,int y,char *s)
{

	while(*s)
	{
		affchar(x,y,*s++);
		x+=8;
		if (x>WIDTH-8)
		{ 
			x=0; 
			y+=8; 
			if (y>HEIGHT-8) y=0; 
		}
	}

}



void printchar(char c)
{
	void *ecr;
	int t;

	while(ycur>HEIGHT-8) 
	{
		ycur-=8;
		initbloc(&ecr);
		getbloc(&ecr,0,8,WIDTH,HEIGHT-8);
		putbloc(&ecr,0,0);
		freebloc(&ecr);
		t=color;
		pbox(0,HEIGHT-8,WIDTH,8,0);
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
	if (xcur>WIDTH-8)
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


void playsample(void *adr,long len,long freq)
{
	/* pas de son pour l'instant avec X11... */
}


void stopsample()
{
}


void fixsample(void *adr,long len)
{
}


 

