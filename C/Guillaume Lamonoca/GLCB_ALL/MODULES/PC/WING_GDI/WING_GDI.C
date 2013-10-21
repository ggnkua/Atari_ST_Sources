/* wing_gdi.c : module de base pour PC (Windows+WinG+MultiMedia lib)
Description des instructions de ce module dans doc*.txt.
Guillaume LAMONOCA
Supelec (94)

Dreaming of making yourself WinDoom ? This module is for you !
(Read doc.txt and use the ptr_work_screen or ptr_view_screen
 virtual "video ram" pointers,setbigpalette(),refresh(),swap())
Doc.txt may be found in the first release of GLCB : glcb.zip

Module fonctionnant avec WinG (extension gratuite de Windows)
 - en 16 couleurs non modifiables en mode 16 couleurs physiques
 - en 16 couleurs (GLCB normal) en mode 256 couleurs physiques
 - en 256 couleurs (GLCB+EXTENSION) en mode 256 couleurs physiques

Ce module utilise les fonctions GDI pour le graphisme.
Avantages : - la taille de la fenetre peut etre quelconque
	    - le GDI vous fait croire que vous avez 256
		couleur alors que vous n'en avez que
		254 ou 236 (par de subtiles substitutions).
	    - les fonctions GDI sont rapides (ex: polyfill)
		pour les graphismes classiques
Inconvenient :
	    - la substition de couleur du GDI perturbe
		bien sur le rendu des couleurs lorsque la
		palette change entre le moment ou une
		bitmap est capturee et le moment ou elle
		est affichee (il est possible aussi que
		les bitmaps memorisent la palette au
	        moment de leurs creations...)
	    - les blocs graphiques avec silhouette (sprites)
		consomme deux fois trop de memoire
                (masque stoque en plus du bloc graphique)

En d'autres termes, si votre programme a pour vocation de
manipuler beaucoup de bitmaps, ou si vous jouez beaucoup avec
la palette de couleurs, mieux vaut utiliser wing.c (module
GLCB pour Windows+WinG+Multimedia lib, mais qui n'utilise pas
du tout le GDI et ne consomme que la memoire vraiment
necessaires pour les blocs graphiques avec silhouette).

WinG est disponible partout et gratuitement. Cette extension
ajoute a Windows des fonctions permettant d'afficher des
bitmaps a tres tres grande vitesse. (WinDoom utilise WinG).
De plus WinG permet de travailler directement dans la bitmap
comme s'il s'agissait d'une memoire video et dans un format
plus que sympatique.

Utiliser Turbo C++ ou Borland C++ et compiler en modele LARGE
(Ou mieux, en modele HUGE si la perte de vitesse importe peu)

Si vous obtenez de nombreux Warnings, plutot que de
corriger vos sources, n'hesitez pas a desactiver ces
warnings! (Dans Options -> Compiler -> Messages)

Attention dans Compiler -> Optimizations, vous pouvez
choisir "Fastest" mais je vous conseille alors de
desactiver "Copy propagation","Invariant code motion"
et "Induction variables"!!!
(En optimisant trop on perd le sens de certaines
 lignes de programme!)

Dans Compiler -> Code generation, selectionnez
"Duplicate strings merged" pour gagner de la place sur
les chaines de characteres.

Marche a suivre pour produire exemple.exe
-----------------------------------------

Mettez les fichiers suivants dans un projet exemple.prj :

wing_gdi.c                                \__ module GLCB
nocursor.rc  (indispensable a wing_gdi.c) /   pour WinG !
wing.lib     (indispensable pour wing_gdi.c, livre avec WinG)
exemple.c    (ou vos sources)


Remarques
---------

Il faut absolument eviter de sortir brusquement de
votre programme car sous windows les zones memoires allouees
dynamiquement doivent etre liberees a la fin de votre
programme! Une interruption brusque laissera ces zones
memoires inutilisables pour le systeme! Donc prevoyez
toujours un moyen de sortir de maniere normale de votre
programme (liberation des objets, des zones memoires et
appel a la fonction killsystem()).
(Ou alors ajouter un appel vers votre fonction free_all()
 a la fin de la fonction WinMain dans ce module en
 definissant la constante USER_FREE_FUNCTION)

Pour les samples, vous devez avoir installe un driver
correct avec le panneau de configuration de windows.
De plus il ne faut pas jouer un sample a une frequence
trop haute ou trop basse (ideal:11025 Hz).

Attention! Sur PC, un pointeur ne peut se "deplacer"
sur une zone plus vaste que 64Ko, a moins qu'il ne
soit declare comme suit (toujours le cas en modele HUGE):

char huge *p;

Pour garantir la portabilite sur les autres machines
il suffit alors d'ecrire:

#define huge <commentaire> dans header.h par exemple.
(exemple ci-dessous)

Les fonctions graphiques utilisent GDI. Toutefois grace
aux variables globales ptr_view_screen et ptr_work_screen
vous pouvez travailler directement dans les bitmaps offscreen
(ca simule des rams video en quelque sorte...)
Format des "ram video": 1 octet= 1 pixel, attention 0 donnera
toujours du noir et 255 toujours du blanc (seul le GDI vous
donnera l'illusion d'avoir vraiment 256 couleurs).
En mode 16 couleurs physiques, mefiez vous (0 a 15 seulement)!
Ce mode 16 couleurs physiques est autorise par commodite,
mais doit bien sur etre interdit si vous voulez controler
les couleurs...
Attention l'orientation haut-bas des rams videos depend
du materiel. Vous pouvez cependant forcer une orientation
(-1:normale, 1:inversee) en definissant la macro FORCE_ORIENTATION.
(forcer l'orientation peut abaisser la vitesse de rafraichissement)
La variable globale Orientation vous donne la plus rapide orientation.

Si vous definissez la constante NOSYSCURSOR, le pointeur
d'origine de la souris sera remplace par un pointeur special :
Le pointeur Windows est toujours fluide, mais clignotera a
chaque rafraichissement du contenu de la memoire. Par contre
le pointeur special ne clignotera jamais, mais sa fluidite
dependra de la frequence de rafraichissement.

La constante WARNINGS provoque l'apparition d'un message
qui conseille l'utilisateur de passer en 256 couleurs si
ce n'est pas le mode actuel bien sur.

Amusez vous bien... Gardez en tete que WinDoom utilise la
meme technique que ce module : controle des couleurs (fonction
setbigpalette), ordre de rafraichissement (refresh ou swap, qui
declenchent l'appel a la fonction supersonique WinGBitBlt),
et acces direct aux bitmaps offscreens (ptr_work_screen ou
ptr_view_screen) par le biais de petites routines assembleurs
hyper optimisees... Ajoutez le fait que grace a Windows vous
avez facilement acces a la memoire etendue (et meme virtuelle)
et a l'execution de sons digitalises et de musiques MIDI, et
vous obtenez une methode accessible aux debutants en C, qui
permet neanmoins de realiser des logiciels qui n'ont rien
a envier aux super-productions (avec la gestion specifiques
des cartes hardware en moins! Quel luxe!).

La constante RATIO_256_COLORS peut vous permettre de faire
un zoom d'un facteur 2 si vous vous contentez d'un faible
resolution (320x200) comme c'est le cas par defaut.
La perte de temps de ce zoom peut etre negligeable par rapport
au temps de calcul d'une image grace a la puissance de la
fonction WinGStretchBlt (Vive WinG!!!).

Guillaume LAMONOCA
7 allee lucien mazan
13500 MARTIGUES

E-mail : gl@gen4.pressimage.fr

PS:Si vous faites beaucoup de profit avec ce module, SVP, pensez
   a moi! Les temps sont durs et un pourcentage meme symbolique
   serait fort apprecie... (ceci dit, tous les modules GLCB
   sont freeware a la diffusion comme a l'utilisation : vous
   n'etes pas tenu de reverser la moindre royalty... la seule
   chose que je vous demande, c'est de profiter de l'existence
   des autres modules GLCB pour realiser des versions pour
   les autres machines afin de les aider a survivre)
   'gem_wing.c' est un module pour GEM destine specialement
   pour des conversions rapides de programmes WinG vers GEM.

   Symbolic royalty or donation expected. But GLCB is freeware,
   you have no royalties to pay back. I just want you to compile
   your program for other platforms (in order to help them to
   survive). Since other GLCB modules exist, use them (the module
   'gem_wing.c' is my favorite)!!!
*/

#define prout /**/

#include <windows.h>
#include <mmsystem.h>
#include <process.h>
#include <alloc.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <wing.h>
#include "header.h"



#ifdef WIN32
#undef huge
#define huge /**/
#endif



/********************************************************************/
/* variables globales */

/* facteur de grossissement (selon mode graphique physique)*/
	     
#define RATIO_16_COLORS 1
#define RATIO_256_COLORS 2

static int RATIO;

#define WARNINGS /* pour conseiller le basculement en 256c*/

#define PIXSIZE 1

#define WIDTH 320
#define HEIGHT 200


#define NOM_FENETRE "Nom fenêtre"
#define NOM_CLASSE "OutputWClass"

/*#define USER_FREE_FUNCTION*/
/* pour provoquer l'appel a votre fonction de liberation
   memoire void free_all(void) lors d'un arret brutal    */

/*#define NOSYSCURSOR*/
/* pour avoir un pointeur souris sans clignotement */

#define SYSTEM_CURSOR_COLOR 15
/* no de la couleur pour le pointeur souris special */


/*#define ONLY_ONCE*/
		   /* un seul exemplaire du programme   */
		   /* en cours d'execution              */

/*#define NOCLOSEBOX*/
/* pour avoir une fenetre sans icone de fermeture */
/* mais ALT-F4 TOUJOURS possible !                */
 
char *ptr_view_screen=NULL;  /* adresse "ram video" ecran actif */
char *ptr_work_screen=NULL;/* adresse "ram video" ecran travail */

/* pour avoir ram video orientee de haut en bas (+lent)*/
/*#define FORCE_ORIENTATION*/ 
long      Orientation = -1;     /* assume up-bottom DIBs*/

static 	jmp_buf   jmpb;

static	int	   palette256=0;

#ifdef EXTENSION
static	int	   fIncludeStatic = 0; /* Use the static color entries*/
#else     
static	int	   fIncludeStatic = 1;
#endif

static  HPALETTE   hpalApp;
static  BOOL       fAppActive;


static unsigned int oldpal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};

#ifdef EXTENSION
static unsigned int oldpal256[256*3];
#endif

#ifdef NOSYSCURSOR
static int defaultmouse[256]=
{
0x0001,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0xffff,0xffff,0xffff,0x0001,0x0001,0x0001,0x0001,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0xffff,0x0001,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0xffff,0x0001,0x0000,0x0001,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0x0001,0x0000,0x0000,0x0001,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0001,0x0000,0x0000,0x0000,0x0000,0x0001,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0001,0xffff,0xffff,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0001,0x0001,0x0001,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
};
#endif
			   
static void far *pSurfaceBits[2];     
static struct INFO
       {
		BITMAPINFOHEADER InfoHeader;
		RGBQUAD ColorTable[256];
       } Info;

static void *cursorbob=NULL;
static void *cursorbak=NULL;
static HCURSOR visible_cursor;
static HCURSOR invisible_cursor;

static int silence=0;
static int ecran_travail=0;
static int ecran_actif=1;
static UINT nosound=1;
static HWAVEOUT hwo;
static PCMWAVEFORMAT pcmwf;
static WAVEHDR whdr;
static HANDLE hInst;
static HWND window;
static HDC hdcm,hdcm2,hdcm3,hdc;
static HBITMAP holdbitmap,holdbitmap2,holdbitmap3,hcharbm,hdummy;
static HBITMAP hecran[2];
static HPEN hpen,holdpen;
static HBRUSH hbrush,holdbrush;
static PAINTSTRUCT ps;
static int nbscreen=2;
static COLORREF color=RGB(255,255,255);
static nocolor=15;

static int xcur=0;
static int ycur=0;

static int realmsex=WIDTH/2-8;
static int realmsey=HEIGHT/2-8;
static int realmsemode=1;
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




//*** Setting up SYSPAL_NOSTATIC

#define NumSysColors (sizeof(SysPalIndex)/sizeof(SysPalIndex[1]))
#define rgbBlack RGB(0,0,0)
#define rgbWhite RGB(255,255,255)

//*** These are the GetSysColor display element identifiers
static int SysPalIndex[] = {
  COLOR_ACTIVEBORDER,
  COLOR_ACTIVECAPTION,
  COLOR_APPWORKSPACE,
  COLOR_BACKGROUND,
  COLOR_BTNFACE,
  COLOR_BTNSHADOW,
  COLOR_BTNTEXT,
  COLOR_CAPTIONTEXT,
  COLOR_GRAYTEXT,
  COLOR_HIGHLIGHT,
  COLOR_HIGHLIGHTTEXT,
  COLOR_INACTIVEBORDER,

  COLOR_INACTIVECAPTION,
  COLOR_MENU,
  COLOR_MENUTEXT,
  COLOR_SCROLLBAR,
  COLOR_WINDOW,
  COLOR_WINDOWFRAME,
  COLOR_WINDOWTEXT
};

//*** This array translates the display elements to black and white
static COLORREF MonoColors[] = {
  rgbBlack,
  rgbWhite,
  rgbWhite,
  rgbWhite,
  rgbWhite,
  rgbBlack,
  rgbBlack,
  rgbBlack,
  rgbBlack,
  rgbBlack,
  rgbWhite,
  rgbWhite,
  rgbWhite,
  rgbWhite,
  rgbBlack,
  rgbWhite,
  rgbWhite,
  rgbBlack,

  rgbBlack
};

//*** This array holds the old color mapping so we can restore them
static COLORREF OldColors[NumSysColors];

static PALETTEENTRY aPalette[256];

/********************************************************************/
/* fontes */

static unsigned int sysfonte[64*16]={
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

			      
static void matchpalette16(void)
{
	int i;
	PALETTEENTRY aPalette[16];
	RGBQUAD aPaletteRGB[16];

	if (hdcm)
	{
		/*** BEFORE BLTTING, match the DIB color table to the*/
		/*** current palette to match the animated palette*/

		hdc=GetDC(window);
		GetSystemPaletteEntries(hdc, 0, 16, aPalette);
		ReleaseDC(window,hdc);
		/*** Alas, palette entries are r-g-b, rgbquads are b-g-r*/
		for (i=0; i<16; ++i)
		{
			aPaletteRGB[i].rgbRed = aPalette[i].peRed;
			aPaletteRGB[i].rgbGreen = aPalette[i].peGreen;
			aPaletteRGB[i].rgbBlue = aPalette[i].peBlue;
			aPaletteRGB[i].rgbReserved = 0;
		}       	

		SelectObject(hdcm,hecran[0]);
		WinGSetDIBColorTable(hdcm,0,16,aPaletteRGB);
		SelectObject(hdcm,hecran[1]);
		WinGSetDIBColorTable(hdcm,0,16,aPaletteRGB);
		SelectObject(hdcm,hecran[ecran_travail]);
	}
}



static void initwindow(void)
{
#ifdef FORCE_ORIENTATION
	Info.InfoHeader.biHeight=Orientation;
#else                 
	Orientation=Info.InfoHeader.biHeight;
#endif

	Info.InfoHeader.biHeight = HEIGHT*PIXSIZE*Orientation;
	Info.InfoHeader.biWidth = WIDTH*PIXSIZE;

	hdc=GetDC(window);
	hdcm=WinGCreateDC();
	hdcm2=WinGCreateDC();
	hdcm3=CreateCompatibleDC(hdc);
	hcharbm=CreateBitmap(8,8,1,1,&sysfonte[0]);
	hdummy=CreateCompatibleBitmap(hdcm,WIDTH*PIXSIZE,HEIGHT*PIXSIZE);
	hecran[0]=WinGCreateBitmap(hdcm,(BITMAPINFO far *)&Info,&pSurfaceBits[0]);
	hecran[1]=WinGCreateBitmap(hdcm,(BITMAPINFO far *)&Info,&pSurfaceBits[1]);
	ReleaseDC(window,hdc);


	ptr_view_screen=pSurfaceBits[ecran_actif];
	ptr_work_screen=pSurfaceBits[ecran_travail];


	holdbitmap=SelectObject(hdcm,hecran[ecran_actif]);
	holdbitmap2=SelectObject(hdcm2,hdummy);
	holdbitmap3=SelectObject(hdcm3,hcharbm);

	hpen=CreatePen(PS_NULL,1,NULL);
	hbrush=CreateSolidBrush(RGB(0,0,0));
	holdbrush=SelectObject(hdcm,hbrush);
	holdpen=SelectObject(hdcm,hpen);
	Rectangle(hdcm,0,0,WIDTH*PIXSIZE+1,HEIGHT*PIXSIZE+1);
	SelectObject(hdcm,hecran[ecran_travail]);
	Rectangle(hdcm,0,0,WIDTH*PIXSIZE+1,HEIGHT*PIXSIZE+1);
	SelectObject(hdcm,holdbrush);
	SelectObject(hdcm,holdbrush);
	SelectObject(hdcm,holdpen);
	DeleteObject(hbrush);
	DeleteObject(hpen);

	hpen=CreatePen(PS_NULL,1,NULL);
	holdpen=SelectObject(hdcm,hpen);
	hbrush=CreateSolidBrush(color);
	holdbrush=SelectObject(hdcm,hbrush);

	SetTextColor(hdcm,RGB(0,0,0));



	pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
	pcmwf.wf.nChannels=1;
	pcmwf.wf.nSamplesPerSec=11025L;
	pcmwf.wf.nAvgBytesPerSec=11025L;
	pcmwf.wf.nBlockAlign=1;
	pcmwf.wBitsPerSample=8;    
	nosound=waveOutOpen(&hwo,WAVE_MAPPER,(WAVEFORMAT *)&pcmwf,NULL,NULL,NULL);
	if (!nosound)
	{
		waveOutGetID(hwo,&nosound);
		waveOutSetVolume(nosound,0xffff);
		waveOutReset(hwo);
		waveOutClose(hwo);
    		nosound=1;
	}


}


int initsystem(void)
{
#ifdef NOSYSCURSOR
	int i,j;
#endif


	if (!palette256)
	        matchpalette16();

	setpalette(oldpal);
	cls();
	swap();
	cls();

#ifdef NOSYSCURSOR
	SetCursor(invisible_cursor);
#else
	SetCursor(visible_cursor);
#endif

#ifdef NOSYSCURSOR
	pbox(0,0,16,16,FOND);
	pbox(16,0,16,16,FOND);
	for(i=0;i<16;i++)
		for(j=0;j<16;j++)
			switch(defaultmouse[i*16+j])
			{
				case 0x0001:
					plot(j,i,0);
                                        plot(j+16,i,MASK);
					break;
				case 0xffff:
					plot(j,i,SYSTEM_CURSOR_COLOR);
					plot(j+16,i,MASK);
                                        break;
                        }

	initbloc(&cursorbob);
	getbloc(&cursorbob,0,0,16,16);
	getmask(&cursorbob,16,0);          
	initbloc(&cursorbak);
	getbloc(&cursorbak,0,0,16,16);

        cls();
#endif

	setcolor(15);

	return 1;
}


void killcursor(void)
{
	SetCursor(visible_cursor);
}


/*** AppActivate sets the system palette use and*/
/*** remaps the system colors accordingly.*/
static void AppActivate(BOOL fActive)
{
	HDC hdc;
	int i;

	if (!palette256)
        	return;

	/*** Just use the screen DC*/
	hdc = GetDC(NULL);

	/*** If the app is activating, save he current color mapping*/
	/*** and switch to SYSPAL_NOSTATIC*/
	if (fActive && GetSystemPaletteUse(hdc) == SYSPAL_STATIC)
	{
		/*** Store the current mapping*/
		for (i=0; i<NumSysColors; i++)
			OldColors[i] = GetSysColor(SysPalIndex[i]);

		/*** Switch to SYSPAL_NOSTATIC and remap the colors*/
		SetSystemPaletteUse(hdc, SYSPAL_NOSTATIC);
		SetSysColors(NumSysColors, SysPalIndex, MonoColors);
	}
	else
		if (!fActive)
		{
			/*** Always switch back to SYSPAL_STATIC and the old mapping*/
			SetSystemPaletteUse(hdc, SYSPAL_STATIC);

			SetSysColors(NumSysColors, SysPalIndex, OldColors);
		}

	/*** Be sure to release the DC!*/
	ReleaseDC(NULL,hdc);
}

void killsystem(void)
{
	MSG msg;

	DestroyWindow(window);

	while(GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
}


static void killsystem2(void)
{
	MSG msg;

	stopsample();

	pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
	pcmwf.wf.nChannels=1;
	pcmwf.wf.nSamplesPerSec=11025L;
	pcmwf.wf.nAvgBytesPerSec=11025L;
	pcmwf.wf.nBlockAlign=1;
	pcmwf.wBitsPerSample=8;
	nosound=waveOutOpen(&hwo,WAVE_MAPPER,(WAVEFORMAT *)&pcmwf,NULL,NULL,NULL);
	if (!nosound)
	{
		waveOutGetID(hwo,&nosound);
		waveOutSetVolume(nosound,0);
		waveOutReset(hwo);
		waveOutClose(hwo);
	    	nosound=1;
	}

	playsample(&silence,1L,11025L);
	stopsample();

	SelectObject(hdcm,holdbrush);
	SelectObject(hdcm,holdpen);
	DeleteObject(hbrush);
	DeleteObject(hpen);

	SelectObject(hdcm,holdbitmap);
	SelectObject(hdcm2,holdbitmap2);
	SelectObject(hdcm3,holdbitmap3);
	DeleteObject(hcharbm);
	DeleteObject(hdummy);
	DeleteObject(hecran[0]);
	DeleteObject(hecran[1]);
	DeleteDC(hdcm);
	DeleteDC(hdcm2);
	DeleteDC(hdcm3);

        if (palette256)
		if (hpalApp)
			DeleteObject(hpalApp);

	PostQuitMessage(0);

	killcursor();

	while(GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	freebloc(&cursorbak);
	freebloc(&cursorbob);

/*	exit(0);*/
	longjmp(jmpb,1);
}
		      
static void matchpalette(void)
{
	int i;
	PALETTEENTRY aPalette[256];
	RGBQUAD aPaletteRGB[256];

	if (hdcm)
	{
		/*** BEFORE BLTTING, match the DIB color table to the*/
		/*** current palette to match the animated palette*/
		GetPaletteEntries(hpalApp, 0, 256, aPalette);
		/*** Alas, palette entries are r-g-b, rgbquads are b-g-r*/
		for (i=0; i<256; ++i)
		{
			aPaletteRGB[i].rgbRed = aPalette[i].peRed;
			aPaletteRGB[i].rgbGreen = aPalette[i].peGreen;
			aPaletteRGB[i].rgbBlue = aPalette[i].peBlue;
			aPaletteRGB[i].rgbReserved = 0;
		}       	


		SelectObject(hdcm,hecran[0]);
		WinGSetDIBColorTable(hdcm,0,256,aPaletteRGB);
		SelectObject(hdcm,hecran[1]);
		WinGSetDIBColorTable(hdcm,0,256,aPaletteRGB);
		SelectObject(hdcm,hecran[ecran_travail]);
	}
}


long FAR PASCAL WndProc (HWND hWnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	BOOL f;            



	window=hWnd;

	switch (Message)
	{
		case WM_DESTROY:
			killsystem2();
			break;

					  
		case WM_PALETTECHANGED:   
			if (!palette256)			
				return (DefWindowProc(hWnd, Message, wParam, lParam));

			if ((HWND)wParam == hWnd)
				break;

		      /* fall through to WM_QUERYNEWPALETTE */

		case WM_QUERYNEWPALETTE:  
			if (!palette256)			
				return (DefWindowProc(hWnd, Message, wParam, lParam));

			hdc = GetDC(hWnd);

			if (hpalApp)
				SelectPalette(hdc, hpalApp, FALSE);

			f = RealizePalette(hdc);
			ReleaseDC(hWnd,hdc);

			if (f)
				InvalidateRect(hWnd,NULL,TRUE);

			return f;

		case WM_PAINT:
			hdc=BeginPaint(hWnd,&ps);

			if (palette256)	
			{
				if (hpalApp)
				{
					SelectPalette(hdc, hpalApp, FALSE);
					RealizePalette(hdc);				
                                }
			}

			SelectObject(hdcm,hecran[ecran_actif]);
			if (RATIO==1)
				WinGBitBlt(hdc,0,0,WIDTH*PIXSIZE,HEIGHT*PIXSIZE,hdcm,0,0);
                        else
				WinGStretchBlt(hdc,0,0,WIDTH*PIXSIZE*RATIO,HEIGHT*PIXSIZE*RATIO,hdcm,0,0,WIDTH*PIXSIZE,HEIGHT*PIXSIZE);
			SelectObject(hdcm,hecran[ecran_travail]);
			EndPaint(hWnd,&ps);

                        break;


		case WM_ACTIVATEAPP:
			if (!palette256)			
				return (DefWindowProc(hWnd, Message, wParam, lParam));

			fAppActive = (BOOL)wParam;

        /*** Remap the system colors and deal with the palette */
        		if (fIncludeStatic == 0)
			{
				AppActivate(fAppActive);

				if (hpalApp)
				{
					hdc = GetDC(hWnd);

					UnrealizeObject(hpalApp);
					SelectPalette(hdc, hpalApp, FALSE);
					RealizePalette(hdc);

					ReleaseDC(hWnd, hdc);
				}
			}
			break;


#ifndef NOSYSCURSOR
		case WM_SETCURSOR:
			if (realmsemode>0)
				SetCursor(visible_cursor);
			else 
				SetCursor(invisible_cursor);
                	break;
#endif
		case WM_CREATE:
			break;


		default:
			return (DefWindowProc(hWnd, Message, wParam, lParam));
	}
	return (NULL);
}

static void initcursor(HANDLE hInstance)
{
	invisible_cursor=LoadCursor(hInstance,MAKEINTRESOURCE(100));
	visible_cursor=LoadCursor(NULL, IDC_ARROW);
}


static int InitApplication(HANDLE hInstance)
{
	WNDCLASS  wc;


	wc.style = CS_BYTEALIGNCLIENT;
	wc.lpfnWndProc = WndProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
#ifdef NOSYSCURSOR
	wc.hCursor= invisible_cursor;
#else                          
	wc.hCursor= NULL;
#endif
	wc.hbrBackground = GetStockObject(BLACK_BRUSH);
	wc.lpszMenuName = NULL;
	wc.lpszClassName = NOM_CLASSE;

	return (RegisterClass(&wc));
}

				 
/*
 *  Clear the System Palette so that we can ensure an identity palette 
 *  mapping for fast performance.
 */

static void ClearSystemPalette(void)
{                      
	/*** A dummy palette setup*/
	struct
	{
		WORD Version;
		WORD NumberOfEntries;
		PALETTEENTRY aEntries[256];
	} Palette =
		{
			0x300,
			256
		};

	HPALETTE ScreenPalette;
	HDC ScreenDC;
	int Counter;

	if (!palette256)
		return;

	/*** Reset everything in the system palette to black*/
	for(Counter = 0; Counter < 256; Counter++)
	{
		Palette.aEntries[Counter].peRed = 0;
		Palette.aEntries[Counter].peGreen = 0;
		Palette.aEntries[Counter].peBlue = 0;
		Palette.aEntries[Counter].peFlags = PC_NOCOLLAPSE;
	}

	/*** Create, select, realize, deselect, and delete the palette*/
	ScreenDC = GetDC(NULL);
	ScreenPalette = CreatePalette((LOGPALETTE *)&Palette);

	if (ScreenPalette)
	{
		ScreenPalette = SelectPalette(ScreenDC,ScreenPalette,FALSE);
		RealizePalette(ScreenDC);
		ScreenPalette = SelectPalette(ScreenDC,ScreenPalette,FALSE);
		DeleteObject(ScreenPalette);
	}

	ReleaseDC(NULL, ScreenDC);

	return;
}
					 



//*** Creating an identity palette code here


HPALETTE CreateIdentityPalette(RGBQUAD aRGB[], int nColors)
{
	int i;
	struct
	{
		WORD Version;
		WORD NumberOfEntries;
		PALETTEENTRY aEntries[256];
	} Palette =
		{
			0x300,
			256
		};
	HDC hdc;

	if (!palette256)
		return NULL;

	hdc = GetDC(NULL);

	/*** For SYSPAL_NOSTATIC, just copy the color table into*/
	/*** a PALETTEENTRY array and replace the first and last entries*/
	/*** with black and white*/
	if (GetSystemPaletteUse(hdc) == SYSPAL_NOSTATIC)
	{
		/*** Fill in the palette with the given values, marking each*/
		/*** as PC_RESERVED*/
		for(i = 0; i < nColors; i++)
		{
			Palette.aEntries[i].peRed = aRGB[i].rgbRed;
			Palette.aEntries[i].peGreen = aRGB[i].rgbGreen;
			Palette.aEntries[i].peBlue = aRGB[i].rgbBlue;
			Palette.aEntries[i].peFlags = PC_RESERVED;
		}

		/*** Mark any remaining entries PC_RESERVED*/
		for (; i < 256; ++i)
		{
			Palette.aEntries[i].peFlags = PC_RESERVED;
		}

		/*** Make sure the last entry is white*/
		/*** This may replace an entry in the array!*/
		Palette.aEntries[255].peRed = 255;
		Palette.aEntries[255].peGreen = 255;
		Palette.aEntries[255].peBlue = 255;
		Palette.aEntries[255].peFlags = 0;

		/*** And the first is black*/
		/*** This may replace an entry in the array!*/
		Palette.aEntries[0].peRed = 0;
		Palette.aEntries[0].peGreen = 0;
		Palette.aEntries[0].peBlue = 0;
		Palette.aEntries[0].peFlags = 0;
	}
	else
        {
		/*** For SYSPAL_STATIC, get the twenty static colors into*/
		/*** the array, then fill in the empty spaces with the*/
		/*** given color table*/

		int nStaticColors;
		int nUsableColors;

		/*** Get the static colors*/
		nStaticColors = GetDeviceCaps(hdc, NUMCOLORS);
		GetSystemPaletteEntries(hdc, 0, 256, Palette.aEntries);

		/*** Set the peFlags of the lower static colors to zero*/
		nStaticColors = nStaticColors / 2;
		for (i=0; i<nStaticColors; i++)
			Palette.aEntries[i].peFlags = 0;

		/*** Fill in the entries from the given color table*/
		nUsableColors = nColors - nStaticColors;
		for (; i<nUsableColors; i++)
		{
			Palette.aEntries[i].peRed = aRGB[i].rgbRed;
			Palette.aEntries[i].peGreen = aRGB[i].rgbGreen;
			Palette.aEntries[i].peBlue = aRGB[i].rgbBlue;
			Palette.aEntries[i].peFlags = PC_RESERVED;
		}

		/*** Mark any empty entries as PC_RESERVED*/
		for (; i<256 - nStaticColors; i++)
			Palette.aEntries[i].peFlags = PC_RESERVED;

		/*** Set the peFlags of the upper static colors to zero*/
		for (i = 256 - nStaticColors; i<256; i++)
			Palette.aEntries[i].peFlags = 0;
	}

	ReleaseDC(NULL, hdc);

	/*** Create the palette*/
	return CreatePalette((LOGPALETTE *)&Palette);
}
	     
/***************************************************************************
  Palette Creation
  Create three palettes of solid color washes, with or without statics
*/
void CreateWashPalette(void)
{
	RGBQUAD aWash[256];
	int i;

	if (!palette256)
        	return;

	/*** Fill in the palette with a 256-color ramp*/
	for (i=0; i<256; ++i)
	{
		aWash[i].rgbRed = aWash[i].rgbBlue = aWash[i].rgbGreen = 0;

		aWash[i].rgbRed = (BYTE)i;
		aWash[i].rgbReserved = 0;
	}

	/*** Turn the wash into a palette*/
	if (hpalApp)
		DeleteObject(hpalApp);
	hpalApp = CreateIdentityPalette(aWash, 256);
}


static int InitInstance(HANDLE hInstance, int nCmdShow)
{
	HWND	hWnd;
 	int	screenH,screenW,windowW,windowH;

	HDC	Screen;
	int	PaletteDevice;
	int	nBitsPixel;         
	int    	nPlanes;         
	int	nColorDepth;



	/* Detect non-palettized device */
	Screen = GetDC(0);

	if (Screen)
	{
		PaletteDevice = GetDeviceCaps(Screen, RASTERCAPS) & RC_PALETTE;
		nBitsPixel = GetDeviceCaps(Screen, BITSPIXEL);         
		nPlanes = GetDeviceCaps(Screen, PLANES);         
		nColorDepth = nBitsPixel * nPlanes;
		ReleaseDC(0, Screen);

		if ((8 != nColorDepth)&&(4 != nColorDepth))
		{
		        MessageBox(0,
				 "Change to 16 or 256 colors.",
			         "Incorrect Display Mode",
				 MB_OK);
                        return 0;
		}

		if ((8 != nColorDepth)||(0 == PaletteDevice))
		{
#ifdef WARNINGS			
		        MessageBox(0,
				 "In order to increase speed, change to 256 colors.",
			         "Non-palettized Display",
				 MB_OK);
#endif
			palette256=0;
                        RATIO=RATIO_16_COLORS;
		}
		else
                {
			palette256=1;
			RATIO=RATIO_256_COLORS;
                }
	}

	/* Set up an optimal bitmap*/
	if (WinGRecommendDIBFormat((BITMAPINFO far *)&Info) == FALSE)
		return 0;



	screenH=GetSystemMetrics(SM_CYSCREEN);
	screenW=GetSystemMetrics(SM_CXSCREEN);

 	if ((screenW<WIDTH)||(screenH<HEIGHT))
        	return 0;


	ClearSystemPalette();

	windowW=WIDTH*RATIO*PIXSIZE+2*GetSystemMetrics(SM_CXBORDER);
	windowH=HEIGHT*RATIO*PIXSIZE+GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYBORDER);

	hInst = hInstance;

#ifdef NOCLOSEBOX
	hWnd = CreateWindow(
		NOM_CLASSE,
		NOM_FENETRE,
		0,
		(screenW-windowW)/2,
		(screenH-windowH)/2,
		windowW,
		windowH,
		NULL,
		NULL,
		hInstance,
		NULL
		);
#else
	hWnd = CreateWindow(
		NOM_CLASSE,
		NOM_FENETRE,
		WS_SYSMENU,
		(screenW-windowW)/2,
		(screenH-windowH)/2,
		windowW,
		windowH,
		NULL,
		NULL,
		hInstance,
		NULL
		);
#endif

	if (!hWnd)
		return (FALSE);

	window=hWnd;

	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);




	ClearSystemPalette();
	CreateWashPalette();

	return (TRUE);

}


static int get_args(char* argv[],char *commandline)
{
	int n=1;
	char *p=commandline;

	argv[0]="";

	while (*p)
	{
		argv[n]=p;
                n++;
		while ((*p)&&(*p!=' '))
			p++;
		if (*p==' ')
		{
			*p=0;
                        p++;
			while ((*p)&&(*p==' '))
				p++;
		}
	}

	return n;
}



#ifdef USER_FREE_FUNCTION
void free_all(void);
#endif


int main(int argc, char *argv[]);

		  
static char commandline[256];

#pragma argsused
int PASCAL WinMain(HANDLE hInstance, HANDLE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	int	result;
	int     argc;
        char*	argv[20];

        if (!setjmp(jmpb))
	{             
#ifdef ONLY_ONCE
		if (hPrevInstance)
		{
			BringWindowToTop(FindWindow(NOM_CLASSE,NOM_FENETRE));
			return 0;
		}
#endif
		initcursor(hInstance);

		if (!hPrevInstance)
			if (!InitApplication(hInstance))
			{
	                	killcursor();
				return (FALSE);
	                }


		if (!InitInstance(hInstance, nCmdShow))
		{
        		killcursor();
			return (FALSE);
        	}

		initwindow();

		strcpy(commandline,lpCmdLine);
		argc=get_args(argv,commandline);
		result=main(argc,argv);

	}

	/* meme en cas d'arret brutal on passera par ici */

#ifdef USER_FREE_FUNCTION
	free_all();
#endif
	/* pour liberer les zones allouees par VOTRE programme */

        return result;
}




























/***************************************************************/
/* gestion des 16 couleurs */


static COLORREF couleur(int n)
{

	unsigned int r,v,b;

	if (n==FOND) return RGB(0,0,0);
	if (n==MASK) return RGB(255,255,255);

#ifndef EXTENSION
	r=16*((oldpal[n]>>8)&15);
	v=16*((oldpal[n]>>4)&15);
	b=16*(oldpal[n]&15);
#else
	getbigcolor(n,&r,&v,&b);    
	r=(r>>8)&255;
	v=(v>>8)&255;
	b=(b>>8)&255;
#endif      

	if (r>=240) r=255;
	if (v>=240) v=255;
	if (b>=240) b=255;

	return RGB(r,v,b);
}

void setcolor(int c)
{
	if (nocolor!=c)
	{
		color=couleur(c);
		nocolor=c;

		SelectObject(hdcm,holdbrush);
		DeleteObject(hbrush);
		hbrush=CreateSolidBrush(color);
		SelectObject(hdcm,hbrush);
	}
}

void settruecolor(int r, int v, int b)
{
	color=RGB(r,v,b);
	nocolor= -1;

	SelectObject(hdcm,holdbrush);
	DeleteObject(hbrush);
	hbrush=CreateSolidBrush(color);
	SelectObject(hdcm,hbrush);
}


void getpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) pal[i]=oldpal[i];
}



void setpalette(unsigned int *pal)
{
	unsigned int i,r,v,b;
			     
	for(i=0;i<16;i++) oldpal[i]=pal[i];

#ifdef EXTENSION
	if (palette256)
        {
		for(i=0;i<16;i++)
		{
			r=(pal[i]>>8)&15;
			v=(pal[i]>>4)&15;
			b=pal[i]&15;
			oldpal256[i*3+0]=r*4096;
			oldpal256[i*3+1]=v*4096;
			oldpal256[i*3+2]=b*4096;
		}
		setbigpalette(0,16,&oldpal256[0]);
	}
	else          
        {
		for(i=0;i<16;i++)
		{
			r=(pal[i]>>8)&15;
			v=(pal[i]>>4)&15;
			b=pal[i]&15;
			oldpal256[i*3+0]=r*4096;
			oldpal256[i*3+1]=v*4096;
			oldpal256[i*3+2]=b*4096;
		}
	}
#else                        
	if (palette256)
	{
		for(i=0;i<16;i++)
		{            
			r=(pal[i]>>8)&15;
			v=(pal[i]>>4)&15;
			b=pal[i]&15;
			aPalette[16+i].peRed=(BYTE)(r*16);
			aPalette[16+i].peGreen=(BYTE)(v*16);
			aPalette[16+i].peBlue=(BYTE)(b*16);
			aPalette[16+i].peFlags=PC_RESERVED;                	
                }

		hdc = GetDC(window);
		SelectPalette(hdc, hpalApp, FALSE);
		AnimatePalette(hpalApp, 16, 16, &aPalette[16]);
		ReleaseDC(window, hdc);

		matchpalette();

		InvalidateRect(window, NULL, FALSE);
		UpdateWindow(window);
	}
#endif
}







/***************************************************************/
/* gestion des 256 couleurs */

#ifdef EXTENSION		
void setbigcolor(int n,unsigned int r,unsigned int v,unsigned int b)
{
	unsigned int tmp[3];

	tmp[0]=r;
	tmp[1]=v;
	tmp[2]=b;

	setbigpalette(n,1,tmp);
}

void getbigcolor(int n,unsigned int *r,unsigned int *v,unsigned int *b)
{
	*r=oldpal256[n*3+0];
	*v=oldpal256[n*3+1];
	*b=oldpal256[n*3+2];
}

void setbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;

	for(i=0;i<nb;i++)
	{
		oldpal256[(no+i)*3+0]=ptr[i*3+0];
		oldpal256[(no+i)*3+1]=ptr[i*3+1];
		oldpal256[(no+i)*3+2]=ptr[i*3+2];
	}

	if (no==0)
	{
		no++;
                nb--;
	}

	if (no+nb==256)
	{
		nb--;
        }

	if ((palette256)&&(nb>0))
	{
		hdc = GetDC(window);
		for(i=0;i<nb;i++)
		{
			aPalette[no+i].peRed=(BYTE)(oldpal256[(no+i)*3+0]>>8);
			aPalette[no+i].peGreen=(BYTE)(oldpal256[(no+i)*3+1]>>8);
			aPalette[no+i].peBlue=(BYTE)(oldpal256[(no+i)*3+2]>>8);
			aPalette[no+i].peFlags=PC_RESERVED;
                }

		SelectPalette(hdc, hpalApp, FALSE);
		AnimatePalette(hpalApp, no, nb, &aPalette[no]);
		ReleaseDC(window, hdc);

		matchpalette();

		InvalidateRect(window, NULL, FALSE);
		UpdateWindow(window);
	}

}

void getbigpalette(int no,int nb,unsigned int *ptr)
{
	int i;

	for(i=0;i<nb;i++)
	{
		ptr[i*3+0]=oldpal256[(no+i)*3+0];
		ptr[i*3+1]=oldpal256[(no+i)*3+1];
		ptr[i*3+2]=oldpal256[(no+i)*3+2];
	}
}
#endif











/************************************************************/
/* instructions de gestion des ecrans graphiques */



void simplescreen(void)
{
	if (nbscreen==2)
	{
		ecran_travail=ecran_actif;
		nbscreen=1;
		SelectObject(hdcm,hecran[ecran_travail]);
	}                           
	ptr_view_screen=pSurfaceBits[ecran_actif];
	ptr_work_screen=pSurfaceBits[ecran_travail];
}


void doublescreen(void)
{
	if (nbscreen==1)
	{
		ecran_travail=1-ecran_actif;
		nbscreen=2;
		SelectObject(hdcm,hecran[ecran_travail]);
	}
	ptr_view_screen=pSurfaceBits[ecran_actif];
	ptr_work_screen=pSurfaceBits[ecran_travail];
}


void cls(void)
{
	int t;

	xcur=ycur=0;
	t=nocolor;
	pbox(0,0,WIDTH,HEIGHT,0);
	setcolor(t);
}


void copyscreen(void)
{
	if (nbscreen==2)
	{
		SelectObject(hdcm2,hecran[ecran_actif]);
		BitBlt(hdcm,0,0,WIDTH*PIXSIZE,HEIGHT*PIXSIZE,hdcm2,0,0,SRCCOPY);
		SelectObject(hdcm2,holdbitmap2);
	}
}

void refresh(void)
{
#ifdef NOSYSCURSOR
	int x,y;
#endif

	vblclock++;

#ifdef NOSYSCURSOR
	if (realmsemode>0)
	{             
		SelectObject(hdcm,hecran[ecran_actif]);
		x=realmsex;
                y=realmsey;
	        getbloc(&cursorbak,x,y,16,16);
		putbloc(&cursorbob,x,y);
	}
#endif
	RedrawWindow(window,NULL,NULL,RDW_INVALIDATE);
	buthit(); 
#ifdef NOSYSCURSOR
	if (realmsemode>0)   
        {
		SelectObject(hdcm,hecran[ecran_actif]);
		putbloc(&cursorbak,x,y); 
		SelectObject(hdcm,hecran[ecran_travail]);
	}
#endif

	ptr_view_screen=pSurfaceBits[ecran_actif];
	ptr_work_screen=pSurfaceBits[ecran_travail];
}

void swap(void)
{
#ifdef NOSYSCURSOR
	int x,y;
#endif

	vblclock++;

	if (nbscreen==2)
	{
		ecran_travail=1-ecran_travail;
		ecran_actif=1-ecran_actif;
	}
			      
#ifdef NOSYSCURSOR
	if (realmsemode>0)
	{            
		SelectObject(hdcm,hecran[ecran_actif]);
		x=realmsex;
                y=realmsey;
	        getbloc(&cursorbak,x,y,16,16);
		putbloc(&cursorbob,x,y);
	}                   
#endif
	RedrawWindow(window,NULL,NULL,RDW_INVALIDATE);
	buthit();                   
#ifdef NOSYSCURSOR
	if (realmsemode>0) 
	{
		SelectObject(hdcm,hecran[ecran_actif]);
		putbloc(&cursorbak,x,y);
		SelectObject(hdcm,hecran[ecran_travail]);
	}    
#endif			
	ptr_view_screen=pSurfaceBits[ecran_actif];
	ptr_work_screen=pSurfaceBits[ecran_travail];
}











/******************************************************************/
/* instructions graphiques de base */

#define SGN(x) ((x==0)?(0):((x<0)?(-1):(1)))
#define ABS(x) ((x<0)?(-(x)):(x))

void pellipse(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);

	Ellipse(hdcm,x*PIXSIZE,y*PIXSIZE,(x+lx)*PIXSIZE+1,(y+ly)*PIXSIZE+1);
}


void pbox(int x,int y,int lx,int ly,int c)
{
	if (c>=0) setcolor(c);

	Rectangle(hdcm,x*PIXSIZE,y*PIXSIZE,(x+lx)*PIXSIZE+1,(y+ly)*PIXSIZE+1);
}


void plot(int x,int y,int c)
{
	if (c>=0) setcolor(c);

	Rectangle(hdcm,x*PIXSIZE,y*PIXSIZE,(x+1)*PIXSIZE+1,(y+1)*PIXSIZE+1);
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
	HPEN hp;
	if (c>=0) setcolor(c);

#ifdef WIN32        
	LineTo(hdcm,x*PIXSIZE,y*PIXSIZE);
#endif

	hp=CreatePen(PS_SOLID,1,color);
	SelectObject(hdcm,hp);
#ifndef WIN32
	MoveTo(hdcm,x*PIXSIZE,y*PIXSIZE);
#endif
	LineTo(hdcm,x2*PIXSIZE,y2*PIXSIZE);
	SelectObject(hdcm,hpen);
	DeleteObject(hp);
}



void dline(int x1,int y1,int x2,int y2,int c)
{
	int dx=x2-x1;
	int dy=y2-y1;
	int d;
	int i;
	double a,x,y;

	if (c>=0) setcolor(c);

	if (!dx)
		vline(x1,y1,y2,-1);
	else
		if (!dy) hline(x1,y1,x2,-1);
		else
		{

			if (ABS(dx)>ABS(dy))
			{
				d=SGN(dx);
				a=(double)dy/ABS(dx);
				for(i=x1,y=0.5+(double)y1;i!=x2;i+=d,y+=a)
					plot(i,(int)y,-1);
			}
			else
			{
				d=SGN(dy);
				a=(double)dx/ABS(dy);
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
	for(i=0;i<n-1;i++)
		rline(tp[i*2],tp[i*2+1],tp[i*2+2],tp[i*2+3],-1);

}



void polyfill(int n,int *tp,int c)
{
	POINT points[256];
	int i;

	if (c>=0) setcolor(c);
	for(i=0;i<n;i++)
	{
		points[i].x=PIXSIZE*tp[i*2];
		points[i].y=PIXSIZE*tp[i*2+1];
	}
	Polygon(hdcm,points,n);
}










/*****************************************************************/
/* instructions d'allocation memoire                             */

long ramfree(void)
{
	return GetFreeSpace(NULL);
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
	char huge *hs;
	char huge *hd;
	char *s;
	char *d;
	long hi;
	unsigned int i,l;

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
	return GetTickCount();
}


void waitdelay(unsigned int n)
{
	unsigned long start;
	start=systime();
	do
	{
#ifdef NOSYSCURSOR
		refresh();
#else
		buthit();
#endif
	}
	while((unsigned long)(systime()-start)<((unsigned long)n));
}


















/******************************************************************/
/* fonctions aleatoires                                           */


int randint(void)
{
	return(rand()&0x7fff);
}

int randval(int n)
{
	return(randint()%n);
}















/**************************************************************/
/* gestion des fichiers */

#define MAXFILE 16
HMMIO ftab[MAXFILE];
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
	HMMIO fp;
	char nom2[200];
	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		mmioClose(fp,NULL);
		return(1);
	}
	else
		return(0);
}


long bsize(char *nom)
{
	HMMIO fp;
	char nom2[200];
	long size=0L;

	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		size=mmioSeek(fp, 0L, SEEK_END);
		mmioClose(fp,NULL);
	}

	return(size);
}



int bsave(char *nom,void *adr,long offset,long len)
{
	void *buffer;
	long filesize;
	HMMIO fp;
	int r= -1;

	char nom2[200];
	verifnom(nom,nom2);
	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		r=0;
		filesize = mmioSeek(fp, 0L, SEEK_END);
		mmioClose(fp,NULL);

		if (!r)
		{
			r= -1;
			buffer=memalloc(filesize);
			if (buffer)
			{
				if (!bload(nom,buffer,0L,filesize))
				{
                                	bmove(adr,(char *)buffer+offset,len);
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
	HMMIO fp;
	int r= -1;
	char nom2[200];

	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_READ);
	if (fp)
	{
		mmioSeek(fp, offset, SEEK_SET);
		if (len==mmioRead(fp,adr,len))
			r=0;
		else
			r= -1;
		mmioClose(fp,NULL);
	}

	return(r);
}




int bmake(char *nom,void *adr,long len)
{
	HMMIO fp;
	int r= -1;
	char nom2[200];

	verifnom(nom,nom2);

	fp = mmioOpen(nom2,NULL,MMIO_WRITE|MMIO_CREATE);
	if (fp)
	{
		if (len==mmioWrite(fp,adr,len))
			r=0;
		else
			r= -1;
		mmioClose(fp,NULL);
	}
	return(r);
}



int bcreate(char *nom)
{
	HMMIO fp;
	int r;
	char nom2[200];

	r=nextfile();
	if (r)
	{
		verifnom(nom,nom2);
		fp = mmioOpen(nom2,NULL,MMIO_WRITE|MMIO_CREATE);
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; }
		else r=0;
	}
	return(r);
}



int bopen(char *nom)
{
	HMMIO fp;
	int r;
	char nom2[200];

	r=nextfile();
	if (r)
	{
		verifnom(nom,nom2);
		fp = mmioOpen(nom2,NULL,MMIO_READ);
		if (fp) { ftab[r-1]=fp; fused[r-1]=1; }
		else r=0;
	}
	return(r);
}



int bclose(int n)
{
	HMMIO fp;
	int r=0;

	if (n)
	{
		fp=ftab[n-1];
		mmioClose(fp,NULL);
		fused[n-1]=0;
	}
	return(r);
}




int bwrite(int n,void *adr,long len)
{
	HMMIO fp;
	int r= -1;

	if (n)
	{
		fp=ftab[n-1];
		if (fp)
		{
			if (len==mmioWrite(fp,adr,len))
				r=0;
			else
				r= -1;
		}
	}
	return(r);
}




int bread(int n,void *adr,long len)
{
	HMMIO fp;
	int r= -1;

	if (n)
	{
		fp=ftab[n-1];
		if (fp)
		{
			if (len==mmioRead(fp,adr,len))
				r=0;
			else
				r= -1;
		}
	}
	return(r);
}


















/**************************************************************/
/* gestion de la souris et du clavier */

void hide(void)
{
	realmsemode--;
#ifndef NOSYSCURSOR
	if (realmsemode==0)
		SetCursor(invisible_cursor);
#endif
}

void show(void)
{
	realmsemode++;
#ifndef NOSYSCURSOR
	if (realmsemode==1)
		SetCursor(visible_cursor);
#endif
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


static void msemoved(int x,int y,unsigned int k)
{
	mousex=x;
	mousey=y;
	if (mousex<0) mousex=0;
	if (mousey<0) mousey=0;
	if (mousex>(WIDTH-1)) mousex=(WIDTH-1);
	if (mousey>(HEIGHT-1)) mousey=(HEIGHT-1);
	mousek=0;
	if (k&MK_LBUTTON) mousek|=1;
	if (k&MK_RBUTTON) mousek|=2;
}


static unsigned int scancode(unsigned int k)
{
	switch(k)
	{
		case 0xDB: k=')'; break;
		case 0xBB: k='='; break;
		case 0xDD: k='^'; break;
		case 0xBA: k='$'; break;
		case 0xC0: k='%'; break;
		case 0xDC: k='*'; break;
		case 0xBC: k=','; break;
		case 0xBE: k=';'; break;
		case 0xBF: k=':'; break;
		case 0xDF: k='!'; break;
		case 111: k='/'; break;
		case 106: k='*'; break;
		case 109: k='-'; break;
		case 107: k='+'; break;
		case 110: k='.'; break;
		case 96: k='0'; break;
		case 97: k='1'; break;
		case 98: k='2'; break;
		case 99: k='3'; break;
		case 100: k='4'; break;
		case 101: k='5'; break;
		case 102: k='6'; break;
		case 103: k='7'; break;
		case 104: k='8'; break;
		case 105: k='9'; break;
		case 0x26: k='^'; break;
		case 0x28: k='v'; break;
		case 0x25: k='<'; break;
		case 0x27: k='>'; break;
		case 226: k='<'; break;
	}

	if ((k>='A')&&(k<='Z')) k+=32;

	if (k>127) k=0;
	if ((k<32)&&(k!=27)&&(k!=13)&&(k!=8)) k=0;

	return k;
}


static int lookevent(MSG *msg)
{
	int x,y,k,r;

	k=(unsigned int)msg->wParam;
	x=((int)LOWORD(msg->lParam))/(PIXSIZE*RATIO);
	y=((int)HIWORD(msg->lParam))/(PIXSIZE*RATIO);
	r=1;

	switch (msg->message)
	{
		case WM_MOUSEMOVE:
			realmsex=x;
                        realmsey=y;
			msemoved(x,y,k);
			break;

		case WM_LBUTTONDOWN:
			msemoved(x,y,k);

			if ((x<WIDTH)&&(y<HEIGHT)&&(x>=0)&&(y>=0))
				addbut(1,x,y,(int)(msg->time&65535L));

			break;

		case WM_LBUTTONUP:
			msemoved(x,y,k);

			if ((x<WIDTH)&&(y<HEIGHT)&&(x>=0)&&(y>=0))
				addbut(5,x,y,(int)(msg->time&65535L));

			break;

		case WM_RBUTTONDOWN:
			msemoved(x,y,k);

			if ((x<WIDTH)&&(y<HEIGHT)&&(x>=0)&&(y>=0))
				addbut(2,x,y,(int)(msg->time&65535L));

			break;

		case WM_RBUTTONUP:
			msemoved(x,y,k);

			if ((x<WIDTH)&&(y<HEIGHT)&&(x>=0)&&(y>=0))
				addbut(6,x,y,(int)(msg->time&65535L));

			break;


		case WM_KEYUP:
			k&=255;
		        k=scancode(k);
			if (k) keymap[k]=0;
			break;

		case WM_KEYDOWN:
			k&=255;
			k=scancode(k);
			if ((k)&&(!(msg->lParam>>30)))
			{
				addchar(k);
				keymap[k]=1;
			}
			break;

		default:
			r=0;
        		break;
	}

	return r;
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

		/* msek: bit 0:bouton gauche  bit 1:bouton droit  bit 2:0:presse 1:relache */

		return msek;
	}

	return 0;
}







int buthit(void)
{
	MSG msg;

	while(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		if (!lookevent(&msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

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
#ifndef NOSYSCURSOR
	MSG msg;
#endif

	while(!kbhit())
	{
#ifndef NOSYSCURSOR
		if (GetMessage(&msg, NULL, 0, 0))
			if (!lookevent(&msg))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
#else
		refresh();
#endif
	}

	if (keybufnbr)
	{
		c=(char)keybuffer[keybufend++];
		keybufend&=255;
		keybufnbr--;
	}

	return(c);
}


int kbhit(void)
{
	MSG msg;

	while(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		if (!lookevent(&msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

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
#ifndef NOSYSCURSOR
	MSG msg;
#endif

	empty();
	while(!buthit())
	{
#ifndef NOSYSCURSOR
		if (GetMessage(&msg, NULL, 0, 0))
			if (!lookevent(&msg))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}		
#else
		refresh();
#endif
	}
}













/***************************************************************/
/* gestion de blocs graphiques */


typedef struct
{
	int lx;
	int ly;
	int id;
	HBITMAP bloc;
	HBITMAP mask;
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
		if (bloc->id) DeleteObject(bloc->bloc);
		if (bloc->id==2) DeleteObject(bloc->mask);
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
			if (bloc->id) DeleteObject(bloc->bloc);
			if (bloc->id==2) DeleteObject(bloc->mask);
			bloc->id=0;
			bloc->bloc=CreateCompatibleBitmap(hdcm,lx*PIXSIZE,ly*PIXSIZE);

			if (bloc->bloc)
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}

		if (bloc->id)
		{
			SelectObject(hdcm2,bloc->bloc);
			BitBlt(hdcm2,0,0,lx*PIXSIZE,ly*PIXSIZE,hdcm,x*PIXSIZE,y*PIXSIZE,SRCCOPY);
			SelectObject(hdcm2,holdbitmap2);
		}

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
		if (blocd!=blocs)
		{

			SelectObject(hdcm,blocs->bloc);
			SelectObject(hdcm2,blocd->bloc);
			BitBlt(hdcm2,xd*PIXSIZE,yd*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm,xs*PIXSIZE,ys*PIXSIZE,SRCCOPY);

			if ((blocs->id==2)&&(blocd->id==2))
			{
				SelectObject(hdcm,blocs->mask);
				SelectObject(hdcm2,blocd->mask);
				BitBlt(hdcm2,xd*PIXSIZE,yd*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm,xs*PIXSIZE,ys*PIXSIZE,SRCCOPY);
			}

			SelectObject(hdcm,hecran[ecran_travail]);
			SelectObject(hdcm2,holdbitmap2);

		}
		else
		{

			SelectObject(hdcm2,blocd->bloc);
			BitBlt(hdcm2,xd*PIXSIZE,yd*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm2,xs*PIXSIZE,ys*PIXSIZE,SRCCOPY);

			if (blocd->id==2)
			{
				SelectObject(hdcm2,blocd->mask);
				BitBlt(hdcm2,xd*PIXSIZE,yd*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm2,xs*PIXSIZE,ys*PIXSIZE,SRCCOPY);
			}

			SelectObject(hdcm2,holdbitmap2);
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
			SelectObject(hdcm2,bloc->bloc);
			BitBlt(hdcm,x*PIXSIZE,y*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm2,xs*PIXSIZE,ys*PIXSIZE,SRCCOPY);
			SelectObject(hdcm2,holdbitmap2);
		}
		else
			if (bloc->id==2)
			{
				SelectObject(hdcm2,bloc->mask);
				BitBlt(hdcm,x*PIXSIZE,y*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm2,xs*PIXSIZE,ys*PIXSIZE,SRCPAINT);
				SelectObject(hdcm2,bloc->bloc);
				BitBlt(hdcm,x*PIXSIZE,y*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm2,xs*PIXSIZE,ys*PIXSIZE,SRCINVERT);
				SelectObject(hdcm2,bloc->mask);
				BitBlt(hdcm,x*PIXSIZE,y*PIXSIZE,lxs*PIXSIZE,lys*PIXSIZE,hdcm2,xs*PIXSIZE,ys*PIXSIZE,SRCINVERT);
				SelectObject(hdcm2,holdbitmap2);
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
				DeleteObject(bloc->mask);
				bloc->id=1;
			}
			if (bloc->id==1)
			{
				bloc->mask=CreateCompatibleBitmap(hdcm,bloc->lx*PIXSIZE,bloc->ly*PIXSIZE);
				if (bloc->mask) bloc->id=2;
			}

			if (bloc->id==2)
			{
				SelectObject(hdcm2,bloc->mask);
				BitBlt(hdcm2,0,0,bloc->lx*PIXSIZE,bloc->ly*PIXSIZE,hdcm,x*PIXSIZE,y*PIXSIZE,SRCCOPY);
				SelectObject(hdcm2,holdbitmap2);
			}
		}
	}
}












/*****************************************************************/
/* instructions de gestion de fonte */


#ifndef WIN32
void affchar(int x,int y,char c)
{
	unsigned int n;

	if ((c>31)&&(c<127))
	{
		if (c>95) c-=(char)32;

		n=c-32;

		SelectObject(hdcm3,hcharbm);

		SetBkColor(hdcm,couleur(MASK));
		SetBitmapBits(hcharbm,16,&sysfonte[n*16]);
#if (PIXSIZE==1)
		BitBlt(hdcm,x*PIXSIZE,y*PIXSIZE,8*PIXSIZE,8*PIXSIZE,hdcm3,0,0,SRCAND);
#else                
		StretchBlt(hdcm,x*PIXSIZE,y*PIXSIZE,8*PIXSIZE,8*PIXSIZE,hdcm3,0,0,8,8,SRCAND);
#endif

		SetBkColor(hdcm,color);
		SetBitmapBits(hcharbm,16,&sysfonte[n*16+8]);
#if (PIXSIZE==1)
		BitBlt(hdcm,x*PIXSIZE,y*PIXSIZE,8*PIXSIZE,8*PIXSIZE,hdcm3,0,0,SRCPAINT);
#else
		StretchBlt(hdcm,x*PIXSIZE,y*PIXSIZE,8*PIXSIZE,8*PIXSIZE,hdcm3,0,0,8,8,SRCPAINT);
#endif
		SelectObject(hdcm3,holdbitmap3);
	}

}
#else
/* WIN32 : strangely... BitBlt jumps odd lines when bitblting... */
/* so, draw by ploting points...                                 */
void affchar(int x,int y,char c)
{
	unsigned int n,i,k,m,f,t;

	t=nocolor;
	if ((c>31)&&((unsigned char)c<=127))
	{
		if (c>95) c-=(char)32;
	
		n=c-32;
	
		for(i=0;i<8;i++)
		for(m=sysfonte[n*16+i],f=sysfonte[n*16+i+8],k=0;k<8;k++,f<<=1,m<<=1)
		if (!(m&128))
		if (f&128) plot(x+k,y+i,t); else plot(x+k,y+i,0);
	
		setcolor(t);
	}
}
#endif



void afftext(int x,int y,char *s)
{
	while(*s)
	{
		affchar(x,y,*s++);
		x+=8;
		if (x>WIDTH-8) { x=0; y+=8; if (y>(HEIGHT-8)) y=0; }
	}
}


void printchar(char c)
{
	void *ecr;
	int t;

	while(ycur>(HEIGHT-8))
	{
		ycur-=8;
		initbloc(&ecr);
		getbloc(&ecr,0,8,WIDTH,(HEIGHT-8));
		putbloc(&ecr,0,0);
		freebloc(&ecr);
		t=nocolor;
		pbox(0,(HEIGHT-8),WIDTH,8,0);
		setcolor(t);
	}


	if (c==10) xcur= -8;
	else
	if (c==13) { ycur+=8; xcur= -8; }
	else
	affchar(xcur,ycur,c);

	xcur+=8;
	if (xcur>(WIDTH-8)) { xcur=0; ycur+=8; }


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
	stopsample();

	pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
	pcmwf.wf.nChannels=1;
	pcmwf.wf.nSamplesPerSec=freq;
	pcmwf.wf.nAvgBytesPerSec=freq;
	pcmwf.wf.nBlockAlign=1;
	pcmwf.wBitsPerSample=8;

	whdr.lpData=adr;
	whdr.dwBufferLength=len;
	whdr.dwBytesRecorded=NULL;
	whdr.dwUser=NULL;
	whdr.dwFlags=WHDR_PREPARED;
	whdr.dwLoops=1;
	whdr.lpNext=NULL;
	whdr.reserved=NULL;

	nosound=waveOutOpen(&hwo,WAVE_MAPPER,(WAVEFORMAT *)&pcmwf,NULL,NULL,NULL);

	if (!nosound)
		waveOutWrite(hwo,&whdr,sizeof(WAVEHDR));
}



void stopsample()
{
	if (!nosound)
	{
		waveOutReset(hwo);
		waveOutClose(hwo);
		nosound=1;
	}
}


void fixsample(void *adr,long len)
{
	long i;
	char huge *ptr;
	WAVEHDR wh;

	ptr=(char huge *)adr;
	for(i=0L;i<len;i++) *(ptr++)-=(char)128;

	wh.lpData=adr;
	wh.dwBufferLength=len;
	wh.dwBytesRecorded=NULL;
	wh.dwUser=NULL;
	wh.dwFlags=NULL;
	wh.dwLoops=1;
	wh.lpNext=NULL;
	wh.reserved=NULL;

	if (nosound)
	{
		pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM;
		pcmwf.wf.nChannels=1;
		pcmwf.wf.nSamplesPerSec=11025L;
		pcmwf.wf.nAvgBytesPerSec=11025L;
		pcmwf.wf.nBlockAlign=1;
		pcmwf.wBitsPerSample=8;
		nosound=waveOutOpen(&hwo,WAVE_MAPPER,(WAVEFORMAT *)&pcmwf,NULL,NULL,NULL);
		if (!nosound)
			waveOutPrepareHeader(hwo,&wh,sizeof(WAVEHDR));
		waveOutReset(hwo);
		waveOutClose(hwo);
		nosound=1;
	}
	else
		waveOutPrepareHeader(hwo,&wh,sizeof(WAVEHDR));
}







