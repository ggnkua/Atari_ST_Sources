/* gem_wing.c : module GLCB pour portage WinG->GEM (mode chunky)
Description des instructions de ce module dans doc*.txt
Guillaume LAMONOCA
E-mail : GL@gen4.pressimage.fr

Module GEM 256c pour les modes chunky/packed bits (ex: true color).
Module interessant pour les Atari equipes de cartes Matrix ou
Spektrum, ainsi que le Medusa (ce module doit etre super sur T60).
Attention en mode 256 couleurs 8 plans ce module ne marchera pas.
Il est destine aux mode 256 couleurs chunky (1 octet=1 pixel).
Module compatible GLCB complet. La definition de EXTENSION est
acceptee (256c). keymap[] ne detecte qu'une seule touche
et il faut la presser deux fois pour simuler son relachement
(le GEM n'envoie pas de message lorsqu'on relache une touche).
Il faut privilegier le controle a la souris plutot qu'au clavier.
Seul moyen de faire du double buffering en SVGA 256 couleurs
sur Atari avec carte graphique speciale sans se prendre la
tete. Gere a fond les AES multitaches (iconify), permet la
creation d'accessoire (permet reellement de faire du multitache
cooperatif entre plusieurs accessoires SANS Multitos!), gere
correctement l'attribution d'une palette de couleur a la
fenetre GEM correspondante (si palette il y a).

Si l'extension .PRG du programme est chang‚e en .ACC,       
  le programme deviendra alors un simple accessoire.
  (Attention, un accessoire a toujours une pile ridicule !)
  (enfin, ... il parait)
Attention : pour cela, vous devrez neanmoins ajoutez
un #include "gem_acc.h" DERRIERE le #include "header.h"
de votre module contenant l'appel a initsystem(). Ceci
permet de simuler un redemarrage de l'accessoire aux bons
moments... (Si vous oubliez, l'ACC vous previendra !)

Par rapport aux modules Atari (TOS) deja diffuses au paravant
ce module GEM sera surement plus lent, mais permet d'attaquer
directement les pseudo ram video qui correspondent a l'ecran
visible (variable globale ptr_view_screen) et a l'ecran cache
de travail (variable globale ptr_work_screen). Ces deux
variables globales vous donneront l'adresse de l'octet qui
correspond au pixel en haut a gauche. Le format de ces pseudo
ram video est bien adapte pour les algorithme de projection
de bitmap en 3D par exemple (1 octet=1 pixel).
On peut realiser alors un rafraichissement du contenu de la
fenetre GEM a partir de ces pseudo ram video (avec la fonction
swap() ou la fonction refresh()) en perdant le moins de temps
possible (necessite d'un mode chunky, car les modes codes par
plans de bits demanderait trop de temps de calcul pour la 
conversion...). Pas de constante RATIO disponible, car un zoom
meme x2 ralentirait beaucoup trop le rafraichissement, de plus
c'est inutile, vu que le bureau GEM autorise d'abaisser la
resolution jusqu'aux resolutions 320x200 ou 320x280.
(Windows ne le permet pas, d'ou l'interet du zoom x2 de WinG!)

L'interet est de fournir la meme format que le module GLCB wing.c
qui exploite le revolutionnaire WinG (Extension gratuite pour
Windows sur PC qui devrait attirer de nombreux developpeurs de
jeux 3D. ID Software a deja realise WinDoom en utilisant WinG!!!).
Ainsi, tout jeu programme avec le module wing.c sera immediatement
recompilable avec le module gem_wing.c et les developpeurs n'auront
plus d'excuses pour ne pas proposer une version Atari de leur jeu.
Le module fonctionne par comodite sur Falcon (true color), mais
ne sera interessant que sur Falcon accelere, TT dote de carte
graphique speciale, ou sur Medusa.

Pour le son, rien n'est implemente. Il faudra plutot faire
des requetes au serveur sonore SMSV (Sound & Music Server)
que je prepare actuellement et qui centralisera la gestion
des bruitages et des musiques, meme sous Multitos (arbitre).
(Ce serveur sera egalement implemente sous Windows).


Utiliser Pure C
Pour de gros executables: Options->Compiler "Use absolute calls"
(par prudence choisissez toujours cette option)
N'hesitez pas non plus a mettre 0 pour warning level.

  
Faites un fichier .PRJ pour compiler et linker
pcstart.o, exemple.c, et gem.c ensemble
afin d'obtenir l'executable exemple.prg.

contenu d'un tel fichier exemple.prj:

exemple.prg (ou exemple.acc)
=
pcstart.o
gem_wing.c
gem_asm.s
exemple.c

PCSTDLIB.LIB       ; standard library
PCFLTLIB.LIB       ; floating point library
PCEXTLIB.LIB       ; extended library
PCTOSLIB.LIB       ; TOS library
PCGEMLIB.LIB       ; AES and VDI library

*/

/*#define KILLED_WHEN_CLOSED*/
/* pour provoquer l'arret du programme a chaque fermeture de la fenetre
   et un redemarrage du programme a chaque rappel de l'accessoire
   (si on donne au fichier executable l'extension ACC)
   (sinon ce redemarrage n'intervient que dans certains cas :
    a chaque appel de programme et changement de resolution du bureau)
*/

/*#define USER_FREE_FUNCTION*/
/* pour qu'une fonction utilisateur 'free_all()' soit appelee avant
   l'arret imprevu du programme. Dans le cas ou VOUS appelez killsystem()
   il est normal que vous liberiez au prealable les zones memoire que
   vous avez alloue ou toutes autres ressources. Mais il existe des cas
   ou killsystem() sera appele sans qu'on vous demande votre avis...
   Dans ces cas la (CTRL+Q, changement de resolution, lancement d'un autre
   programme lorsqu'il s'agit d'un accessoire ou qu'on est sous Multitos),
   killsystem() sera appele, mais grace a cette constante, free_all()
   sera appele juste avant. A vous d'‚crire la fonction free_all() qui
   va bien. Prototype : void free_all(void)
*/

/*#define CTRL_Q_CONFIRM*/
/* CTRL+Q entraine normalement l'arret brusque du programme. Cependant
   en definissant cette constante, une fenˆtre de confirmation sera
   activ‚e, et l'arret ne sera valide que si l'utilisateur repond 'Yes' */


#define SYSTEM_CURSOR_COLOR 15
/* no de la couleur pour le curseur GEM */
/* Le GEM ignore cette information (en true color, ce sera toujours N&B) */

/*#define KEEP_SYSTEM_PALETTE*/
/* Dans le cas d'un fonctionnement en 256 couleurs, cette constante 
   empeche le module de toucher aux couleurs 0 a 15, reduisant ainsi
   les couleurs disponibles (240 couleurs entre 16 et 255).
   Conseil : mettez du blanc pour la couleur 255 et du noir pour la
   couleur 0 si vous songez a faire un portage vers Windows (de plus,
   pour epargner la palette systeme sous Windows, il faut eviter les
   couleurs 0 a 9 et 246 a 255).
   La couleur 255 est la couleur transparente pour les sprites.
*/

/*#define NOSYSCURSOR*/
/* Si vous definissez la constante NOSYSCURSOR, le pointeur
   d'origine de la souris sera remplace par un pointeur special :
   Le pointeur GEM est toujours fluide, mais clignotera a
   chaque rafraichissement du contenu de la fenetre. Par contre
   le pointeur special ne clignotera jamais, mais sa fluidite
   dependra de la frequence de rafraichissement.
   Ce pointeur special n'entre en action que si la fenetre est
   active, non iconifiee, et si le pointeur de la souris entre
   dans la zone de la fenetre. Si cette constante est definie
   getch() et confirm(), qui en temps normal ne provoquent pas
   de rafraichissement pendant l'attente d'un click ou d'une
   touche, rafraichiront l'ecran avec refresh() pour permettre
   au curseur de bouger.
*/


/* -------------------------------------------------------------------- */
/*       Inclusion des fichiers de d‚clarations.                        */
/* -------------------------------------------------------------------- */


#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

#include <portab.h>
#include <tos.h>

#include <setjmp.h>

#include "header.h"

/* -------------------------------------------------------------------- */
/*       D‚clarations des variables globales externes.                  */
/* -------------------------------------------------------------------- */
                                    /* Cette variable globale permet    */
extern int _app;                    /*   au programme de d‚terminer     */
                                    /*   s'il a ‚t‚ lanc‚ comme         */
                                    /*   programme ou comme accessoire  */


#define WIDTH 320
#define HEIGHT 200

#define NOM_ACC		"  Nom accessoire"
#define NOM_FENETRE	"Nom fenˆtre"
#define NOM_ICONE	"Nom ic“ne"


/* -------------------------------------------------------------------- */
/*       Constantes pour l'AES 4.1                                      */
/* -------------------------------------------------------------------- */                                   

/* Ce module gere bien l'AES>=4.0 (iconification,Select+shift,Select+ctrl, etc...)

   Mais :

   Notez le defaut de l'AES 4.0 et 4.1 : 
   -----------------------------------
   
   Lorsqu'on s‚lectionne un programme ou le bureau dans le menu des accessoires,
   cela selectionne la fenetre correspondante, mais le systeme n'envoie pas de
   message WM_UNTOPPED a la fenetre precedement active... Tragique!
   Car a ce moment la, je n'ai plus aucun moyen (pas de message envoye)
   pour savoir que la fenetre n'est plus active, et donc restaurer la palette
   de couleur... Donc theoriquement il ne faudrait pas utiliser le menu des
   accessoires pour selectionner un programme ou le bureau (il faudrait cliquer
   plutot dans les fenetres). Bref une horreur...
   
   Rassurez-vous, j'ai trouve une solution elegante a ce probleme. Puisque la 
   selection d'un programme ou du bureau par le menu des accessoires, desactive
   les fenetres actives sans leur envoyer le message WM_UNTOPPED (ce qui est
   la moindre des choses; esperons que ce petit bug soit repare dans les versions
   futures de l'AES, en attendant je vous invite a prendre ma solution), on va
   s'arranger pour que toute tentative de selection dans ce menu soit precedee par
   une desactivation 'virtuelle' de la fenetre (provoquee par le programme, donc il
   sera au courant cette fois et pourra restaurer la palette).
   De plus, en meme temps que de contourner ce petit bug des AES 4.0 et 4.1, cela
   resoudra un petit probleme d'ergonomie : souvent la palette (par exemple la
   palette EGA par defaut du module) rend illisible les menus (couleurs 0 et 1 trop
   proches). Or desactiver 'virtuellement' la fenetre avant de toucher au menu
   provoquera une restauration de la palette systeme et donc rendra lisible les
   menus. On va donc desactiver notre fenetre des que l'utilisateur a l'intention
   de toucher a la barre de menu du systeme. Pour cela on detectera l'entree
   de la souris dans le rectangle correspondant a la barre de menu.


   Bug in AES 4.0 and 4.1 :
   ----------------------
   
   If you select a program or desktop in accessory menu, WM_UNTOPPED message is
   NOT sent to top window, but the window is no longer topped...
   So palette restoration is impossible.

   Solution : detect mouse pointer entering menu bar, and 'virtualy' untop the window.
   So, user will be able to read menus (system palette restored), and won't cause
   any problem if he selects program or desktop via accessory menu, since the
   window has already aknowledged a 'virtual' untop event (don't need WM_UNTOPPED).
   
*/   

#ifndef SMALLER
#define SMALLER 0x4000
#endif

#ifndef WM_ICONIFY
#define WM_ICONIFY 34
#endif

#ifndef WM_UNICONIFY
#define WM_UNICONIFY 35
#endif

#ifndef WM_ALLICONIFY
#define WM_ALLICONIFY 36
#endif

#ifndef WM_BOTTOMED
#define WM_BOTTOMED 33
#endif

#ifndef WF_ICONIFY
#define WF_ICONIFY 26
#endif

#ifndef WF_UNICONIFY
#define WF_UNICONIFY 27
#endif

/* New constant for new message (i need it in order to handle properly color palettes) */
/* 700 est une valeur arbitraire non deja prise par un evenements AES */

#ifndef WM_RESTOREPAL
#define WM_RESTOREPAL 700 
#endif

static WORD restorepalmsg[8]={WM_RESTOREPAL};

long      Orientation = -1;     /* assume up-bottom DIBs*/

void cls(void);
void affchara(void);
void drawba(void);
void copyba(void);
void putpba(void);

void look_event(int);

/* -------------------------------------------------------------------- */
/*       Macros.                                                        */
/* -------------------------------------------------------------------- */

#define min(a, b)           ((a) < (b) ? (a) : (b))
#define max(a, b)           ((a) > (b) ? (a) : (b))
#define sgn(x) 				((x==0)?(0):((x<0)?(-1):(1)))
#define abs(x) 				((x<0)?(-(x)):(x))
 
/* -------------------------------------------------------------------- */
/*       Variables globales.                                            */
/* -------------------------------------------------------------------- */

static	int    whandle=0;                   /* Identificateur de la fenˆtre     */
static	char   title[] = NOM_FENETRE;       /* Titre de la fenˆtre              */
static	int    gl_wchar,                    /* Largeur et hauteur d'un          */
		       gl_hchar,                    /*   caractŠre                      */
		       gl_wbox,                     /* Largeur et hauteur de la         */
		       gl_hbox;                     /*   zone d'affichage               */

static	int    phys_handle=0,               /* Identificateur pour GEM et VDI   */
		       handle=0;
static	int    max_x,                       /* Largeur maximale de l'‚cran      */
		       max_y;                       /* Hauteur maximale de l'‚cran      */
static	int    appl_id,                     /* Identificateur du programme      */
		       menu_id;                     /* Identificateur dans le menu GEM  */


static unsigned char *bitmap_screen[2];
static unsigned char *bitmap[2];

unsigned char *ptr_work_screen;
unsigned char *ptr_view_screen;
unsigned long screen_size;
unsigned char *physbase;

jmp_buf	glcb_jmpb;

static 	int		sleep=0;
static	int 	topped=0;
static  int		acc_error=0;
static	int		iconified=0;

typedef struct
{	
	long 	ident;
	long	valeur;
}	t_cookie;



void event_loop( void );

int again=0;
int acc_ok=0;



#ifdef MESSAGE
static int idprog=0;

void message(char *s,int p)
{
	printf("%d %lu\t%d\t%s\n",idprog,Malloc(-1),p,s);
}
#endif

static int desk=0;   
static int clut=0;
static int chunky=0;
static unsigned int deskpalsize;
static unsigned int deskpal[256][3];

static unsigned int egapal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};

static unsigned int oldpal[16]=
{
	0x0000,0x1008,0x3080,0x5088,
	0x2800,0x3808,0x4880,0x5ccc,
	0x3888,0x400f,0x50f0,0x60ff,
	0x4f00,0x5f0f,0x7ff0,0x8fff
};

unsigned int clut256[256];   /* table 8 bits -> 16 bits true color */

#ifdef EXTENSION
static unsigned int oldpal256[256*3];
#endif


static int ecran_travail=0;
static int ecran_actif=1;
static int nbscreen=2;
static int nocolor= -2;

unsigned char cur_color;
#ifdef EXTENSION
unsigned char cur_fg_color=0;
#else
unsigned char cur_fg_color=16;
#endif

int xcur=0;
int ycur=0;

static int mouselevel=1;

static int oldmousek=0;

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

long masque;
long masque2;
long matrice;
long matrice2;
long ecran;
int haut;
int larg;
char *recal;
char *recal2;

static unsigned char dta[44];

static int ftab[HEIGHT];

static unsigned long ltime;

#ifdef NOSYSCURSOR	     

static void *cursorbob=NULL;
static void *cursorbak=NULL;

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

/* souris du bureau : ne pas modifier */
MFORM souris1={
			0,0,
			1,
			0,
			1,			
			0xc000,0xe000,0xf000,0xf800,0xfc00,0xfe00,0xff00,0xff80,
			0xffc0,0xffe0,0xfe00,0xef00,0xcf00,0x8780,0x0780,0x0380,
			0x0000,0x4000,0x6000,0x7000,0x7800,0x7c00,0x7e00,0x7f00,
			0x7f80,0x7c00,0x6c00,0x4600,0x0600,0x0300,0x0300,0x0000
			};

#ifndef NOSYSCURSOR
/* souris du programme (mode monochrome) */
MFORM souris2={
			0,0,
			1,
			1,
			0,	
			0xc000,0xe000,0xf000,0xf800,0xfc00,0xfe00,0xff00,0xff80,
			0xffc0,0xffe0,0xfe00,0xef00,0xcf00,0x8780,0x0780,0x0380,
			0x0000,0x4000,0x6000,0x7000,0x7800,0x7c00,0x7e00,0x7f00,
			0x7f80,0x7c00,0x6c00,0x4600,0x0600,0x0300,0x0300,0x0000
			};

/* souris du programme (si palette systeme modifiee) */
MFORM souris4={
			0,0,
			1,
			0,
			SYSTEM_CURSOR_COLOR,
			0xc000,0xe000,0xf000,0xf800,0xfc00,0xfe00,0xff00,0xff80,
			0xffc0,0xffe0,0xfe00,0xef00,0xcf00,0x8780,0x0780,0x0380,
			0x0000,0x4000,0x6000,0x7000,0x7800,0x7c00,0x7e00,0x7f00,
			0x7f80,0x7c00,0x6c00,0x4600,0x0600,0x0300,0x0300,0x0000
			};
#else
MFORM souris2={
			0,0,
			1,
			0,
			1,			
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			};
MFORM souris4={
			0,0,
			1,
			0,
			1,			
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			};
#endif



/* souris invisible */
MFORM souris3={
			0,0,
			1,
			0,
			1,			
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			};


#ifdef PRINT_EVENTS
int idprog=0;
#endif

#define MOUSE_OUTSIDE	0
#define MOUSE_INSIDE	1

int mouse_pos=MOUSE_OUTSIDE;

#ifdef USER_FREE_FUNCTION
	void free_all(void);
#endif

static	int window_x,window_y,window_w,window_h;
static	int menubar_x,menubar_y,menubar_w,menubar_h;
static  int window_y_min;

static int sommeil=0;

static int lastkey=0;

static char formstring[80];


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

void savedeskpalette(void);
void restoredeskpalette(void);
void restorepalette(void);


long gc(long target)
{
	long old_stack;
	t_cookie** ptr_tab_cookie=(t_cookie **)0x5a0;	/* pointeur vers le tableau	*/																				/* des cookie	*/
	t_cookie *tab_cookie;

	/* pour lire l'adresse du tableau des cookies, il faut etre en mode	
		superviseur		*/
	if (Super((void *)1L)==0L)	/* si on est en mode utilisateur	*/
	{		
		old_stack=Super(0L);	/* on passe en mode superviseur	*/
	}
	else
	{	
		old_stack=0;
	}
	tab_cookie=*ptr_tab_cookie;	/* on lit cette adresse			*/
	
	
	if (old_stack)				/* si on etait en utilisateur au debut	*/
	{
		Super((void *)old_stack);	/*  on y retourne */
	}				
		
	if (tab_cookie==0L)		/* si le tos <1.6, on n'a pas de cookie jar	*/
		return(-2);				
		
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


static void open_window( void )
{	
	int kind;
	int x,y,w,h;
	int x2,y2,w2,h2;

	w=WIDTH;
	h=HEIGHT;
	x=(max_x-w)/2;
	y=(max_y-h)/2;

	if ( whandle <= 0 )
	{			
		kind=NAME|CLOSER|MOVER|SMALLER;
		wind_calc(WC_BORDER,kind,x,y,w,h,&x2,&y2,&w2,&h2);
		whandle = wind_create( kind, 0, 0, max_x + 1, max_y + 1 );	
		if ( whandle <= 0 )	
			return;

		topped=1;
		sommeil=0;
		
		wind_set( whandle, WF_NAME, title );
		if (y2<window_y_min)
			y2=window_y_min;
		wind_open( whandle, x2, y2, w2, h2 );
	}
	else	
	{
		topped=1;
		sommeil=0;
		wind_set( whandle, WF_TOP );
	}

	mouse_pos=MOUSE_OUTSIDE;

	wind_get(whandle,WF_WORKXYWH,&window_x,&window_y,&window_w,&window_h);
	appl_write(appl_id,16,restorepalmsg);
}


static int rc_intersect( GRECT *r1, GRECT *r2 )
{	
	int x, y, w, h;
	
	x = max( r2->g_x, r1->g_x );
	y = max( r2->g_y, r1->g_y );
	w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );
	
	r2->g_x = x;
	r2->g_y = y;
	r2->g_w = w - x;
	r2->g_h = h - y;
	
	return ( ((w > x) && (h > y) ) );
}






static void redraw_window( void )
{            
#ifdef NOSYSCURSOR
	int x,y;
	int ecran;
	int drawmouse=0;
#endif
		
	int		t;
	GRECT	work,box;
	int		clip[4];
	
	if( whandle <= 0 )                 /* Il n'y a aucune fenˆtre       */
		return;                          

     
#ifdef NOSYSCURSOR
	if ((mouselevel>0)&&(mouse_pos==MOUSE_INSIDE)&&(topped==2)&&(!iconified))
	{         
		drawmouse=1;
		ecran=ecran_travail;
		ecran_travail=ecran_actif;
		ptr_work_screen=bitmap_screen[ecran_travail];
		x=mousex;
        y=mousey;
		getbloc(&cursorbak,((x<WIDTH-16)?(x):(WIDTH-16)),((y<HEIGHT-16)?(y):(HEIGHT-16)),16,16);
		putbloc(&cursorbob,x,y);
		ecran_travail=ecran;
		ptr_work_screen=bitmap_screen[ecran_travail];
	}                   
#endif




	wind_update( BEG_UPDATE );

	graf_mouse( M_OFF, (void *)0 );
	
	wind_get( whandle, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
	work.g_w = min( work.g_w, max_x - work.g_x + 1 );
	work.g_h = min( work.g_h, max_y - work.g_y + 1 );

	wind_get( whandle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h );
	while ( box.g_w > 0 && box.g_h > 0 )
	{	
		if( rc_intersect( &work, &box ) )
		{		
		
			if (!iconified)
			{	
				if (chunky==1)  /* 256 colors chunky mode (medusa,matrix,spektrum) */
				{
					matrice=(long)(ptr_view_screen+((long)(box.g_x-work.g_x))+(box.g_y-work.g_y)*((long)WIDTH));
					matrice2=(long)physbase+((long)box.g_x)+box.g_y*((long)max_x+1);
					haut=box.g_h-1;
					larg=box.g_w-1;
					recal=(char*)(WIDTH-box.g_w);
					recal2=(char *)(max_x+1-box.g_w);
					
					copyba();
				}
				else	/* True color 65536 colors mode (falcon) */
				{
					matrice=(long)(ptr_view_screen+((long)(box.g_x-work.g_x))+(box.g_y-work.g_y)*((long)WIDTH));
					matrice2=(long)physbase+2L*((long)box.g_x)+box.g_y*2L*((long)max_x+1);
					haut=box.g_h-1;
					larg=box.g_w-1;
					recal=(char*)(WIDTH-box.g_w);
					recal2=(char *)(2L*(max_x+1-box.g_w));
					
					drawba();
				}
			}
			else
			{
				clip[0] = box.g_x;
				clip[1] = box.g_y;
				clip[2] = box.g_x+box.g_w-1;
				clip[3] = box.g_y+box.g_h-1;
			
				vs_clip( handle, 1, clip );		
			
				t=nocolor;
				vsf_color( handle, 0 );                       /* set white fill   */
				vswr_mode( handle, 1 );                       /* set replace mode */
				v_bar( handle, clip);
				vsf_color( handle, 1 );
				v_gtext( handle, work.g_x+(work.g_w-gl_wchar*(int)strlen(NOM_ICONE))/2, work.g_y+work.g_h/2, NOM_ICONE);
				setcolor(t);
			}
		}
		wind_get( whandle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h );
	}
	
	graf_mouse( M_ON, (void *)0 );

	wind_update( END_UPDATE );



#ifdef NOSYSCURSOR
	if (drawmouse) 
	{
		ecran=ecran_travail;
		ecran_travail=ecran_actif;
		ptr_work_screen=bitmap_screen[ecran_travail];
		putbloc(&cursorbak,((x<WIDTH-16)?(x):(WIDTH-16)),((y<HEIGHT-16)?(y):(HEIGHT-16)));
		ecran_travail=ecran;
		ptr_work_screen=bitmap_screen[ecran_travail];
	}    
#endif			
}


/*       Traitement des ‚v‚nements re‡us dans le tampon … message.      */
/*       ->                      Pointeur sur le tampon … message.      */
/*       <-                      Si la fenˆtre est referm‚e et si le    */
/*                                 programme n'est pas un accessoire,   */
/*                                 alors la fonction retourne 1 pour    */
/*                                 signaler l'arrˆt du programme, sinon */
/*                                 la fonction retourne toujours 0.     */

static void handle_message( int pipe[8] )
{
#ifdef MESSAGE
message("message",pipe[0]);
#endif

	if ((acc_error)&&(pipe[0]!=AC_OPEN))
		return;
	
	switch ( pipe[0] )
	{	
		case WM_RESTOREPAL:	
			if (topped==1)
			{
				topped=2;
				sommeil=0;
				if (handle)
				{
					savedeskpalette();
					restorepalette();
				}
			}
			break;
	
		case WM_REDRAW:	
			redraw_window( );		
			break;
		
		case WM_ONTOP:
		case WM_TOPPED:		
			if (pipe[3]==whandle)
			{
				topped=1;
				sommeil=0;
				wind_set( whandle, WF_TOP );
				appl_write(appl_id,16,restorepalmsg);
			}
			break;			


		case WM_UNTOPPED:
			restoredeskpalette();
			topped=0;
			sommeil=0;
			break;
		
		
		case AP_TERM:
		case AP_RESCHG:
		case WM_CLOSED:
			if ( pipe[3] == whandle )
			{	
				restoredeskpalette();
				topped=0;
				sommeil=0;
				wind_close( whandle );
				wind_delete( whandle );
				whandle = 0;
				iconified=0;
			}
			
			if ( _app )	
			{
#ifdef USER_FREE_FUNCTION
				free_all();
#endif
				killsystem();
			}
#ifdef KILLED_WHEN_CLOSED
			if (!sleep)
			{
#ifdef USER_FREE_FUNCTION
				free_all();
#endif
				killsystem();
			}
#endif
			break;
		
		case WM_MOVED:
		case WM_SIZED:		
			if ( pipe[3] == whandle )
			{
				wind_set( whandle, WF_CURRXYWH,  pipe[4], pipe[5], pipe[6], pipe[7] );
				wind_get(whandle,WF_WORKXYWH,&window_x,&window_y,&window_w,&window_h);
				redraw_window( );			
			}
			break;
			
		case WM_BOTTOMED:
			if ( pipe[3] == whandle )		
			{	
				wind_set( whandle, WF_BOTTOM);
				restoredeskpalette();
				topped=0;
				sommeil=0;
			}
			break;
			
		case WM_ICONIFY:
		case WM_ALLICONIFY:
			if ( pipe[3] == whandle )		
			{	
				wind_set( whandle, WF_ICONIFY,  pipe[4], pipe[5], pipe[6], pipe[7] );
				iconified=1;
				restorepalette();
			}
			break;
			
		case WM_UNICONIFY:
			if ( pipe[3] == whandle )		
			{	
				wind_set( whandle, WF_UNICONIFY,  pipe[4], pipe[5], pipe[6], pipe[7] );
				wind_get(whandle,WF_WORKXYWH,&window_x,&window_y,&window_w,&window_h);
				savedeskpalette();
				iconified=0;
				restorepalette();
			}
			break;
			
		
		case AC_OPEN:
			if ( pipe[4] == menu_id )	
			{
				if (sleep)
				{
					sleep=0;
					longjmp(glcb_jmpb,0);
				}
				
				if (!acc_error)
					open_window( );
				else
				{
					switch(acc_error)
					{
						case 2:
							form_alert(1,"[3][ |Can't create view |or work screen! |(Out of memory ?) | ][Sorry]");
							break;
						case 4:
							form_alert(1,"[3][ |Sorry, but 'GEM_ACC.H' |must be included in order |to make a correct accessory! | ][Sorry]");
							break;
						case 5:
							sprintf(formstring,"[3][Sorry, but screen is |not large enough! | |Select a better resolution |(at least %dx%d) ][OK]",WIDTH,HEIGHT);
							form_alert(1,formstring);
							break;
						case 6:
							form_alert(1,"[3][ |Can't work with a |bit-planes mode! |Select any chunky mode. | ][Sorry]");
							break;
					}
				}
			}
			break;
		
		case AC_CLOSE:	
			if ( pipe[3] == menu_id )	
			{
				if (!sleep)
				{
#ifdef USER_FREE_FUNCTION
					free_all();
#endif
					killsystem();
				}
					
#ifdef MESSAGE
message("AC_CLOSE (no kill)",-1);
#endif
			}
			break;
	}
}





int initacc(void)
{
#ifdef MESSAGE
	if (!idprog)
		idprog=randint();
#endif

	acc_ok=1; /* setjmp a ete execute dans main() : ouf! */
	return initsystem();
}





int initsystem( void )
{	
#ifdef NOSYSCURSOR
	int j;
#endif
	int i;
	int work_in[11];
	int work_out[57];
	int pts[8];

#ifdef MESSAGE
message("initsystem, apres setjmp",0);
#endif


	phys_handle=0;
	handle=0;
 	topped=0;
	iconified=0;
	
	ecran_travail=0;
	ecran_actif=1;
	nbscreen=2;

	nocolor= -2;
	
	xcur=0;
	ycur=0;
	
	mouselevel=1;
	
	oldmousek=0;
	
	nbrbuffer=0;
	lstbufptr=0;
	msebufptr=0;
	
	keybufptr=0;
	keybufend=0;
	keybufnbr=0;


	if (!again)
	{
		appl_id = appl_init( );
		if ( appl_id == -1 )
			return 0;
	}

	
	for ( i = 0; i < 10; i++ )	
		work_in[i]  = 1;
	work_in[0] = Getrez()+2;
	work_in[10] = 2;
	phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
	handle = phys_handle;
	v_opnvwk( work_in, &handle, work_out );
	if ( handle == 0 )	
	{	
		form_alert(1,"[3][ | |Can't open workstation ! | | ][Sorry]");
		appl_exit( );
		return 0;
	}

	deskpalsize=work_out[13];
	max_x = work_out[0]; 
	max_y = work_out[1];

	vqt_extent(phys_handle,"Query menubar height!",pts);
	menubar_x=0;
	menubar_y=0;
	menubar_w=max_x+1;
	menubar_h=(abs(pts[1]-pts[7])+4)*2; /* 100% de marge */
	window_y_min=abs(pts[1]-pts[7])+4;
		
	vq_extnd(handle,1,work_out);

	if ( ( (1L<<((unsigned long)work_out[4]))!=(unsigned long)deskpalsize )
		&& (work_out[4]==16) )
	{
		chunky=2; /* true color mode */
		clut=0;
	}
	else
		if (work_out[4]==8)
		{
			chunky=1; /* 256 color mode (no bitplanes!, otherwise module will bug) */
			clut=1;   /* must be medusa card, matrix card or spektrum card... but  */
					  /* auto detection is too hard without enough information...  */
		}

	if (!chunky)
	{
		if (_app)
		{
			form_alert(1,"[3][ |Can't work with a |bit-planes mode! |Select any chunky mode. | ][Sorry]");
			appl_exit( );
			return 0;
		}
		else
		{
			v_clsvwk( handle );
			handle=0;
			acc_error=6;
			menu_id = menu_register( appl_id, NOM_ACC );
			event_loop();
		}
	}


	if ((WIDTH>max_x+1)||(HEIGHT>max_y+1))
		if (!_app)
		{
			acc_error=5; /* provoquer erreur, car l'ecran est trop petit !*/
			v_clsvwk( handle );
			handle=0;
			menu_id = menu_register( appl_id, NOM_ACC );
			event_loop();
		}
		else
		{
			sprintf(formstring,"[3][Sorry, but screen is |not large enough! | |Select a better resolution |(at least %dx%d) ][OK|Continue]",WIDTH,HEIGHT);
			if (form_alert(1,formstring)==1)
			{
				appl_exit( );
				return 0;
			}
		}
	
	if ((acc_ok==0)&&(!_app))
	{
		acc_error=4; /* provoquer erreur, car gem_acc.h n'a pas ete utilise !*/
		v_clsvwk( handle );
		handle=0;
		menu_id = menu_register( appl_id, NOM_ACC );
		event_loop();
	}

	physbase=Physbase();
	screen_size=((long)WIDTH)*HEIGHT;
	bitmap[0]=(unsigned char *)memalloc(screen_size);
	bitmap[1]=(unsigned char *)memalloc(screen_size);
	ptr_work_screen=bitmap_screen[0]=(unsigned char *)(((long)bitmap[0]+3L)&0xfffffffcL);
	ptr_view_screen=bitmap_screen[1]=(unsigned char *)(((long)bitmap[1]+3L)&0xfffffffcL);

	if ((!bitmap[0])||(!bitmap[1]))
	{
		if (_app)
			form_alert(1,"[3][ |Can't create view |or work screen! |(Out of memory ?) | ][Sorry]");
		else
			acc_error=2;

		memfree((void **)&bitmap[0]);
		memfree((void **)&bitmap[1]);

		v_clsvwk( handle );
		handle=0;

		if (_app)
		{
			appl_exit( );
			return 0;
		}
	}

	if ((acc_error)&&(!_app))
	{
		menu_id = menu_register( appl_id, NOM_ACC );
		event_loop();
	}
				              /* Si le programme a ‚t‚ lanc‚ en     */	
		                      /*   tant qu'accessoire _app vaut 0,  */
				              /*   sinon _app vaut 1                */	
	if ( !_app )
	{
		if (!again)
			menu_id = menu_register( appl_id, NOM_ACC );
		else
			if (!acc_error)
				open_window();
	}
	else
	{	
		graf_mouse( 0, (void*)0 );
		open_window( );
	}


	again=1;

	setpalette(egapal);
	setcolor(15);


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
#endif



	cls();

	return 1;
}



void killsystem(void)
{
#ifdef NOSYSCURSOR
	freebloc(&cursorbak);
	freebloc(&cursorbob);
#endif

	memfree((void **)&bitmap[0]);
	memfree((void **)&bitmap[1]);

	if (whandle>0)
	{
		restoredeskpalette();
		topped=0;
		sommeil=0;
		wind_close( whandle );
		wind_delete( whandle );
		iconified=0;
	}
	whandle = 0;
		
	if (handle)
	{
		v_clsvwk( handle );
		handle=0;
	}

#ifdef MESSAGE	
message("killsystem",-2);
#endif


	if (_app)
	{	
		appl_exit( );
		exit(0);
	}
	else
	{
		if (!acc_error)
			sleep=1;
		event_loop();
	}
}











/***************************************************************/
/* gestion des 16 couleurs */


void setcolor(int c)
{
	if (nocolor!=c)
	{
		nocolor=c;	
		
		if (c==MASK)
			c=0;
		else
			if (c==FOND)
				c=255;
#ifndef EXTENSION
			else
				c+=16;
#endif
		
		cur_color=c;
	}
}


void getpalette(unsigned int *pal)
{
	int i;

	for(i=0;i<16;i++) pal[i]=oldpal[i];
}


static void savedeskpalette(void)
{
	int i;
	
	if (clut)
	{
		for(i=0;i<deskpalsize;i++)
			vq_color(handle,i,1,(WORD *)deskpal[i]);
		desk=1;
	}
}


static void restoredeskpalette(void)
{
	int i;
		
	if ((clut)&&(desk)&&(topped==2)&&(!iconified))
	{
		for(i=0;i<deskpalsize;i++)
			vs_color(handle,i,(WORD *)deskpal[i]);
	}
	
	if (phys_handle)
		vsc_form(phys_handle,(int *)&souris1);
}


static void restorepalette(void)
{
	int i;
	unsigned int c[3];
	int offset=0;

	if (iconified)
	{
		if ((clut)&&(whandle>0)&&(topped==2))
			for(i=0;i<deskpalsize;i++)
				vs_color(handle,i,(WORD *)deskpal[i]);
	}
	else
	{
		if ((clut)&&(whandle>0)&&(topped==2))
		{
#ifndef EXTENSION		
			if (deskpalsize>=32)
				offset=16;
			for(i=0;i<16;i++)
			{
				c[0]=((oldpal[i]>>8)&15)*66+10;
				c[1]=((oldpal[i]>>4)&15)*66+10;
				c[2]=(oldpal[i]&15)*66+10;
				vs_color(handle,i+offset,(WORD *)c);
			}
#else
#ifndef KEEP_SYSTEM_PALETTE
			for(i=0;i<256;i++)
#else
			for(i=16;i<256;i++)
#endif
			{
				c[0]=oldpal256[3*i]/66+8;
				c[1]=oldpal256[3*i+1]/66+8;
				c[2]=oldpal256[3*i+2]/66+8;
				vs_color(handle,i+offset,(WORD *)c);
			}
#endif
		}
	}

	if ((mouse_pos==MOUSE_INSIDE)&&(!iconified)&&(topped==2)&&(phys_handle))
		if (mouselevel>0)
		{
#ifndef EXTENSION
			if ((!clut)||(deskpalsize>=32))
#else
			if (!clut)
#endif
				vsc_form(phys_handle,(int *)&souris2);
			else
				vsc_form(phys_handle,(int *)&souris4);
		}
		else
			vsc_form(phys_handle,(int *)&souris3);

}

void setpalette(unsigned int *pal)
{
	int i;

#ifdef EXTENSION
#define OFFSET 0
#else
#define OFFSET 16
#endif

	for(i=0;i<16;i++)
		oldpal[i]=pal[i];

	if (chunky==2)
		for(i=0;i<16;i++)
			clut256[i+OFFSET]=(((oldpal[i]>>8)&15)<<12)+
							(((oldpal[i]>>4)&15)<<7)+
							((oldpal[i]&15)<<1);
#ifdef EXTENSION
	for(i=0;i<16;i++)
	{
		oldpal256[3*i]=((oldpal[i]>>8)&15)*4369;
		oldpal256[3*i+1]=((oldpal[i]>>4)&15)*4369;
		oldpal256[3*i+2]=(oldpal[i]&15)*4369;
	}
#endif
	restorepalette();	
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

	if (chunky==2)
		for(i=0;i<nb;i++)
			clut256[no+i]=(((ptr[i*3+0]>>11)&31)<<11)+
							(((ptr[i*3+1]>>10)&63)<<5)+
							(((ptr[i*3+2]>>11)&31));

	restorepalette();
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
	}

	ptr_work_screen=bitmap_screen[ecran_travail];
	ptr_view_screen=bitmap_screen[ecran_actif];
}


void doublescreen(void)
{
	if (nbscreen==1)
	{
		ecran_travail=1-ecran_actif;
		nbscreen=2;
	}
	ptr_work_screen=bitmap_screen[ecran_travail];
	ptr_view_screen=bitmap_screen[ecran_actif];
}


void copyscreen(void)
{
	if (nbscreen==2)
		bmove(ptr_view_screen,ptr_work_screen,screen_size);
}

void refresh(void)
{
	vblclock++;

	redraw_window();
	look_event(0); 
	
}



void swap(void)
{                                    
	vblclock++;

	if (nbscreen==2)
	{
		ecran_travail=1-ecran_travail;
		ecran_actif=1-ecran_actif;
	}
	
	ptr_work_screen=bitmap_screen[ecran_travail];
	ptr_view_screen=bitmap_screen[ecran_actif];
			      
	redraw_window();
	look_event(0);                   
	
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
	if (c>=0) setcolor(c);
	*(ptr_work_screen+y*((long)WIDTH)+((long)x))=cur_color;
}


void vline(int x,int y,int y1,int c)
{
	register unsigned char *ptr;
	register int dy=sgn(y1-y);
	register int i;
	register unsigned char cur_c;

	if (c>=0) setcolor(c);
	cur_c=cur_color;
	if (!dy) dy++;
	ptr=ptr_work_screen+y*((long)WIDTH)+((long)x);
	for(i=y;i!=y1+dy;i+=dy,ptr+=dy*WIDTH) *ptr=cur_c;
}


void hline(int x,int y,int x1,int c)
{
	register unsigned char *ptr;
	register int n=x1-x;
	register int i;
	register unsigned char cur_c;

	if (c>=0) setcolor(c);
	ptr=ptr_work_screen+y*((long)WIDTH)+((long)x);
	cur_c=cur_color;
	if (n>=0)
		for(i=0;i<=n;i++) *(ptr++)=cur_c;
	else
	{
		n= -n-1;
		*ptr=cur_c;
		for(i=0;i<=n;i++) *(--ptr)=cur_c;
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

void bmove(void *sce,void *dst,long len)
{
	memmove(dst,sce,len);
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
	do
	{
#ifndef NOSYSCURSOR
	look_event(0);
#else
	refresh();
#endif
	}
	while((systime()-start)<(unsigned long)n);
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



static void addchar(int c)
{
	keymap[lastkey]=0;
	if (c!=lastkey)
	{
		lastkey=c;
		keymap[c]=1;
	}
	else
		lastkey=0;
	
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
	mousek=k;
}


void look_event(int mode)
{	
	int x, y,		
		kstate,
		key,
		clicks,
		event,
		state;
	int pipe[8];
#ifdef CTRL_Q_CONFIRM
	int r;	
#endif 

	if ((whandle<=0)||(topped!=2)||(iconified))
	{	
		if (!sommeil)	
		{
			if ((mode==1)||(mode==2)||(iconified))
				event = evnt_multi( MU_MESAG | MU_KEYBD,
				                  0,0,0,
				                  0,0,0,0,0,
				                  0,0,0,0,0,
				                  pipe,
				                  0, 0,
				                  &x, &y, &state, &kstate, &key, &clicks );
			else
				event = evnt_multi( MU_MESAG | MU_TIMER | MU_KEYBD,
				                  0,0,0,
				                  0,0,0,0,0,
				                  0,0,0,0,0,
				                  pipe,
				                  1, 0,
				                  &x, &y, &state, &kstate, &key, &clicks );
		}
		else
		{
			if ((mode==1)||(mode==2))
				event = evnt_multi( MU_MESAG | MU_BUTTON | MU_KEYBD,
				                  1,1,(mousek^1)&1,
				                  0,0,0,0,0,
				                  0,0,0,0,0,
				                  pipe,
				                  0, 0,
				                  &x, &y, &state, &kstate, &key, &clicks );
			else
				event = evnt_multi( MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD,
				                  1,1,(mousek^1)&1,
				                  0,0,0,0,0,
				                  0,0,0,0,0,
				                  pipe,
				                  1, 0,
				                  &x, &y, &state, &kstate, &key, &clicks );
				
			                  
			if (event&MU_BUTTON)
			{
				mousek=state;
				
				if (!(mousek&1))
				{
					sommeil=0;
					topped=2;
					restorepalette();
				}
			}
		}		
				
		if (event&MU_MESAG )			
			handle_message( pipe );
	
		return;
	}
	
#ifdef PRINT_EVENTS
	if (!idprog) idprog=randint();
#endif

	switch(mode)
	{
		case 1:	
			event = evnt_multi( MU_KEYBD | MU_M1 | MU_M2 | MU_MESAG,
			                  0, 0, 0,
			                  mouse_pos, window_x, window_y, window_w, window_h,
		    	              0, menubar_x, menubar_y, menubar_w, menubar_h,
		        	          pipe,
		            	      0, 0,
		                	  &x, &y, &state, &kstate, &key, &clicks );
			break;
		case 2:	
			event = evnt_multi( MU_KEYBD | MU_BUTTON | MU_M1 | MU_M2 | MU_MESAG,
			                  1, 1, (mousek^1)&1,
			                  mouse_pos, window_x, window_y, window_w, window_h,
		    	              0, menubar_x, menubar_y, menubar_w, menubar_h,
		        	          pipe,
		            	      0, 0,
		                	  &x, &y, &state, &kstate, &key, &clicks );
			break;
		case 0:
		default:
			if (mouse_pos==MOUSE_INSIDE)
				event = evnt_multi( MU_KEYBD | MU_M1 | MU_M2 | MU_MESAG,
				                  0, 0, 0,
				                  0, window_x, window_y, window_w, window_h,
		    		              1, window_x, window_y, window_w, window_h,
		        		          pipe,
		            		      0, 0,
		                		  &x, &y, &state, &kstate, &key, &clicks );
			else
				event = evnt_multi( MU_KEYBD | MU_M1 | MU_M2 | MU_MESAG | MU_TIMER,
				                  0, 0, 0,
				                  0, window_x, window_y, window_w, window_h,
			    	              0, menubar_x, menubar_y, menubar_w, menubar_h,
		        		          pipe,
		            		      1, 0,
		                		  &x, &y, &state, &kstate, &key, &clicks );
	}


	if ((y<menubar_h)&&(clut))
	{
		restoredeskpalette();
		topped=0;
		sommeil=1;
	}


	if (event&(MU_M1|MU_BUTTON))
		msemoved((x-window_x),(y-window_y),state);
	else
		msemoved((x-window_x),(y-window_y),mousek);

	if (topped)
	if (event&MU_KEYBD)
	{
		if ((key==0x1e11)&&(kstate&4))
		{
#ifdef CTRL_Q_CONFIRM
			restoredeskpalette();
			r=form_alert(2,"[0][ | |Do you want to quit ? | | ][Yes|No]");
			restorepalette();
			if (r==1)
#endif		
			{
#ifdef USER_FREE_FUNCTION
			free_all();
#endif
			killsystem();
			}
		}
		else
		{		
			if ((key&255)==0)
			{
				switch((key>>8)&255)
				{
					case 0x48:
						addchar('^');
						break;
					case 0x50:
						addchar('v');
						break;
					case 0x4b:
						addchar('<');
						break;
					case 0x4d:
						addchar('>');
						break;
				}
			}
			else
				if (key&255)
					addchar(key&255);
		}
#ifdef PRINT_EVENTS
		printf("%cH -%5d- key:[%c] %d 0x%x  kstate:0x%x  <%5d>\n",27,idprog,key,key,key,kstate,vblclock++);
#endif
	}
	
	
	if (event&MU_BUTTON)	
	{
#ifdef PRINT_EVENTS
		printf("%cH -%5d- (%3d,%3d) (%3d)    [%3d,%3d,%3d]  <%5d>\n",27,idprog,x,y,state,kstate,key,clicks,vblclock);
#endif
	}

	if (topped)
	if (event&MU_M2)
	{
#ifdef PRINT_EVENTS	
		printf("%cH -%5d- sortie :(%d,%d)  [%d]  kstate:0x%x  <%5d>\n",27,idprog,x,y,state,kstate,vblclock++);
#endif

		if ((mode==1)||(mode==2)||(mouse_pos==MOUSE_OUTSIDE))
		{
			if (clut)
			{
				restoredeskpalette();
				topped=0;
				sommeil=1;
			}
		}
		else
		{
			if (mouse_pos==MOUSE_INSIDE)
			{
				mouse_pos=MOUSE_OUTSIDE;
				if (phys_handle)
					vsc_form(phys_handle,(int *)&souris1);
			}
		}
	}

	if (topped)
	if (event&MU_M1)
	{
#ifdef PRINT_EVENTS
		printf("%cH -%5d- entree :(%d,%d)  [%d]  kstate:0x%x  <%5d>\n",27,idprog,x,y,state,kstate,vblclock++);
#endif

		if (mouse_pos==MOUSE_OUTSIDE)
		{			
			mouse_pos=MOUSE_INSIDE;
			if (phys_handle)
			{
				if (mouselevel>0)
				{
#ifndef EXTENSION
					if ((!clut)||(deskpalsize>=32))
#else
					if (!clut)
#endif
						vsc_form(phys_handle,(int *)&souris2);
					else
						vsc_form(phys_handle,(int *)&souris4);
				}
				else
					vsc_form(phys_handle,(int *)&souris3);
				
			}
		}
		else
			if ((mode==1)||(mode==2))
				if (mouse_pos==MOUSE_INSIDE)
				{
					mouse_pos=MOUSE_OUTSIDE;
					if (phys_handle)
						vsc_form(phys_handle,(int *)&souris1);
				}

	}
	
	if (topped)
	if (mouse_pos==MOUSE_INSIDE)
	{
#ifdef PRINT_EVENTS		
		printf("%cH %5d,%5d %5d",27,mousex,mousey,mousek);
#endif
		if ((oldmousek&2)!=(mousek&2))
		{
			if (oldmousek&2)
				addbut(6,mousex,mousey,vblclock);
			else
				addbut(2,mousex,mousey,vblclock);
		}
		
		if ((oldmousek&1)!=(mousek&1))
		{
			if (oldmousek&1)
				addbut(5,mousex,mousey,vblclock);
			else
				addbut(1,mousex,mousey,vblclock);
		}			
		
		oldmousek=mousek;
	}
	


	if (event&MU_MESAG )			
		handle_message( pipe );

}

void event_loop( void )
{	
	while (1) look_event(0);
}

int kbhit(void)
{
	if (!keybufnbr)
		look_event(0);
	return(keybufnbr);
}

int buthit(void)
{
	if (!nbrbuffer)
		look_event(0);
	return(nbrbuffer);
}

int keyhit(void)
{
	if (!(keybufnbr|nbrbuffer))
		look_event(0);
	return(keybufnbr|nbrbuffer);
}

char getch(void)
{
	char r;


#ifndef NOSYSCURSOR	
	if (keybufnbr)
	{
		r=keybuffer[keybufend++];
		keybufend&=255;
		keybufnbr--;
		return r;
	}

	do look_event(1); while(!keybufnbr);
#else
	do
	{
		if ((mouse_pos==MOUSE_INSIDE)&&(topped==2)&&(!iconified))
		{
			redraw_window();
			look_event(0);
		}
		else
			look_event(1);
	}
	while(!keybufnbr);
#endif

	r=keybuffer[keybufend++];
	keybufend&=255;
	keybufnbr--;
	
	return r;
}


void empty(void)
{
	keybufnbr=keybufptr=keybufend=0;
	nbrbuffer=lstbufptr=msebufptr=0;
}


void confirm(void)
{
	empty();
#ifndef NOSYSCURSOR
	do look_event(2); while (!nbrbuffer);
#else
	do
	{
		if ((mouse_pos==MOUSE_INSIDE)&&(topped==2)&&(!iconified))
		{
			redraw_window();
			look_event(0);
		}
		else
			look_event(2);
	}
	while(!nbrbuffer);
#endif
}

int getmouse(void)
{
	int ptr;

	if (buthit())
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

		return msek;
	}

	return 0;
}


void hide(void)
{
	mouselevel-=1;

	if ((mouselevel==0)&&(mouse_pos==MOUSE_INSIDE)&&(!iconified)&&(topped==2))
		if (phys_handle)
			vsc_form(phys_handle,(int *)&souris3);
}

void show(void)
{
	mouselevel+=1;
	
	if ((mouselevel==1)&&(mouse_pos==MOUSE_INSIDE)&&(!iconified)&&(topped==2))
		if (phys_handle)
		{
#ifndef EXTENSION
			if ((!clut)||(deskpalsize>=32))
#else
			if (clut)
#endif
				vsc_form(phys_handle,(int *)&souris2);
			else
				vsc_form(phys_handle,(int *)&souris4);
		}
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
			bloc->id=0;
			bloc->bloc=(long)memalloc(((long)ly)*lx);
			if (bloc->bloc)
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}


		if (bloc->id)
		{

			matrice=(long)(ptr_work_screen+((long)x)+y*((long)WIDTH));
			matrice2=bloc->bloc;
			haut=ly-1;
			larg=lx-1;
			recal=(char*)(WIDTH-lx);
			recal2=0;
			
			copyba();
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
			matrice=blocs->bloc+((long)xs)+ys*((long)blocs->lx);
			matrice2=blocd->bloc+((long)xd)+yd*((long)blocd->lx);
			haut=lys-1;
			larg=lxs-1;
			recal=(char*)((long)(blocs->lx-lxs));
			recal2=(char*)((long)(blocd->lx-lxs));

			copyba();

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
		if (bloc->id)
		{
			matrice=bloc->bloc+((long)xs)+ys*((long)bloc->lx);
			matrice2=(long)(ptr_work_screen+((long)x)+y*((long)WIDTH));
			recal=(char*)((long)(bloc->lx-lxs));
			recal2=(char*)(WIDTH-lxs);
			haut=lys-1;
			larg=lxs-1;

			if (bloc->id==1) copyba(); else putpba();
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
			bloc->id=2;
	}
	
	x+=0;
	y+=0;
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

		matrice=(long)&sysfonte[n*16];
		ecran=(long)(ptr_work_screen+((long)x)+y*((long)WIDTH));

		recal=(char*)(WIDTH-8);
		affchara();
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
	int t;

	while(ycur>HEIGHT-8) 
	{
	
		ycur-=8;
		bmove((void *)(ptr_work_screen+8L*WIDTH),(void *)ptr_view_screen,(HEIGHT-8)*((long)WIDTH));
		t=nocolor;
		pbox(0,HEIGHT-8,WIDTH,8,cur_fg_color);
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
	/* utiliser le serveur musical (Sound & Music Server : SMSV) qui arrive bientot... */
	adr=adr;
	len=len;
	freq=freq;
}


void stopsample()
{
}


void fixsample(void *adr,long len)
{
	adr=adr;
	len=len;
}


 



