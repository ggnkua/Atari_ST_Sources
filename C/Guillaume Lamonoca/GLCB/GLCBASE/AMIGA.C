/*
amiga.c (module de base pour amiga, tous modeles)
Description des instructions de ce module dans doc.txt.
Christophe JOUIN
Gilles ROY
Supelec (94)

  compiler avec LATTICE V5.10
  
  pour creer la librairie glc.lib a la racine de la disquette
  
  lc -b0 -r0 -O -w -v -cfis -mt -R:glc.lib amiga.c
  
   -b0 : large data model
   -r0 : large code model
   -O : global optimization
   -w : short integer
   -v : no stack checking (pour myhandler)
   -cfis : need prototypes, don't multi-include,
      single string for several egal string
   -mt : optimize time (-ms for space)
   -R:glc.lib : creer la librairie :glc.lib
      
exemple de 'makefile' 
si vous voulez compiler en simple precision pour les float (
 float/double de type ffp (les plus rapides),l'executable aura
 besoin de mathtrans.library dans votre directorie LIBS: )

OPT = -b0 -r0 -O -cis -ff -w -v -mt
OBJ = essai.o
LIB = LIB /glc.lib LIB:amiga.lib \
   LIB:lcmffp.lib LIB:lcsnb.lib \
   define __main=__tinymain

essai : $(OBJ)
   Blink FROM LIB:c.o $(OBJ) to essai $(LIB)

.c.o:
   lc $(OPT) $*

essai.o : essai.c

si vous voulez compiler en double precision pour les float (
float/double de type lattice FP,n' a pas 
besoin de   mathtrans.library   dans votre directorie LIBS: )

OPT = -b0 -r0 -O -cis -fl -w -v -mt
OBJ = essai.o
LIB = LIB /glc.lib LIB:lcms.lib \
    LIB:lcsnb.lib LIB:amiga.lib\
   define __main=__tinymain

essai : $(OBJ)
   Blink FROM LIB:c.o $(OBJ) to essai $(LIB)

.c.o:
   lc $(OPT) $*

essai.o : essai.c

si vous voulez compiler alors qu'il n'y a ni double ni float 
avec 2 progs :

OPT = -b0 -r0 -O -cis -w -v -mt
OBJ = essai.o essai2.o
LIB = LIB /glc.lib \
    LIB:lcsnb.lib LIB:amiga.lib\
   define __main=__tinymain

essai : $(OBJ)
   Blink FROM LIB:c.o $(OBJ) to essai $(LIB)

.c.o:
   lc $(OPT) $*

essai.o : essai.c
essai2.o : essai2.c


NB : 
   - define __main=__tinymain est pour rendre l'executable plus court
   mais les 'printf' et 'scanf' ne peuvent plus etre utilises
   
   - l'option -O est a enlever si l'on ne veut pas passer trop de
   temps a compiler, ou si on n'a pas assez de memoire centrale
   
   - remarquer la position de LIB:amiga.lib pour les ffp
   lcmffp.lib redefinit sprintf mais alors dans ce cas
   sprintf ne supporte plus %07ld ..., c'est pourquoi je
   met amiga.lib d'abord pour avoir un bon sprintf
   (mais il ne supporte plus %g ou %lf ...)      
  


  - si vous le compiler avec un autre compilateur :
   
   - vous aurez besoin de amiga_asm.a
   
   - compiler en Large Data Model et Large Data Code
     avec Short Integer ( int doivent faire 16 bits)
     No Stack Checking (pas de verification de pile pour 'myhandler' )
     avec eventuellement une optimisation du temps d'execution
     
     il faudra peut-etre changer UWORD_CHIP (pour dice il faut changer
     de place le chip  ?)
     
     
  - vous pouver choisir la police de caracteres utilisee :
    #define FAST_FONT  : choisi topaz.font (plus rapide mais pas 
      entierement compatible avec les modules des autres machines
    #undef FAST_FONT : choisi les caracteres qu'utilisent tous les
      modules mais plus lents ...
        
  - NO_SAMPLE est un flag qui permet de dire de
     ne pas gerer de code pour restituer le son
     si NO_SAMPLE est '#undef' alors tous les memalloc se feront en
     CHIP RAM pour etre sur que les samples seront en chip
     ( le module glcbase ne prevoit pas de type pour la memoire )

  - ATTENTION est un flag pour dire au module de verifier les ordres
    graphiques (ex: plot en dehors de la fenetre )
    il affiche dans le cli (shell) des warnings eventuels
    (si la mise au point est finie -> #undef ATTENTION
    
  - pour polyfill, un nombre de points maximum est impose par le module
    amiga, pour certain programme, il faudra augmenter ce nombre
      (cf AREA_SIZE )
      
*/
#include "header.h"

#include <exec/types.h>
#include <exec/interrupts.h>
#include <exec/memory.h>

#include <graphics/view.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/sprite.h>
#include <graphics/text.h>

#include <devices/timer.h>
#include <devices/input.h>
#include <devices/inputevent.h>
#include <devices/audio.h>

#ifdef LATTICE
                     /* pour le Lattice C, on utilise les prototypes */
#include <proto/exec.h>
#include <proto/dos.h>
   /* ce define est pour empecher le C d'avoir un guru sur BltBitMap !?
    dans lc2 (SAS C trop vieux ou mauvais pragma ?) */
#define NO_PRAGMAS
#include <proto/graphics.h>

#else

/*    protos d' Aztec C ?
#include <functions.h>
*/

#endif

      /* pas de test sur les ordres graphiques ( => plus rapide ) */
#undef ATTENTION
     /* autorise les samples,mais memalloc uniquement en chip .. */
#undef NO_SAMPLE
   /* utilise la font standard de glcbase */
#undef FAST_FONT


extern void HandlerInterface(void); /* uniquement si pas LATTICE C */

/*  option inverse de celles choisies
#undef FAST_FONT
#define ATTENTION
#undef NO_SAMPLE
*/


/* define a changer si autre compilateur ? */
#define UWORD_CHIP UWORD chip


/* constantes pour configuration */

#define WIDTH 320
#define HEIGHT 200
#define DEPTH 4
#define NB_COL 16

#define BLOC_DEPTH 4
#define MASK_DEPTH 1

#define ALLOC_MEM(t) memalloc(sizeof(t))

#ifndef FAST_FONT
static UWORD_CHIP sysfontes[64*8]={
0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
0x3C1C,0x3C1C,0x3C1C,0x3C18,0x3818,0x1800,0x3818,0x1800,
0x7E36,0x7E36,0x7E24,0x2400,0x0,0x0,0x0,0x0,
0x3713,0x7733,0xFF7E,0x7E36,0x7F37,0xFF7E,0x7E24,0x2400,
0x7C3C,0xFE6E,0xFE68,0x7E3E,0x3F0B,0xFF6B,0x7F3E,0x3E00,
0x6020,0xF652,0x7E24,0x3C08,0x3E12,0x7F25,0x2702,0x200,
0x3818,0x7C24,0x7C34,0x7C38,0xFF4D,0xFF46,0x7F39,0x3900,
0x7030,0x7030,0x3010,0x7020,0x2000,0x0,0x0,0x0,
0xC04,0x1C08,0x3818,0x3810,0x3818,0x1808,0xC04,0x400,
0x3010,0x1808,0x1C0C,0xC04,0x1C0C,0x1C08,0x3810,0x1000,
0x0,0x3612,0x1E0C,0x7F3F,0x3F0C,0x3E12,0x1200,0x0,
0x0,0x1C0C,0x1C0C,0x7F3F,0x3F0C,0x1C0C,0xC00,0x0,
0x0,0x0,0x0,0x0,0x3818,0x3818,0x7830,0x3000,
0x0,0x0,0x0,0x7E3E,0x3E00,0x0,0x0,0x0,
0x0,0x0,0x0,0x0,0x0,0x7030,0x7030,0x3000,
0x0,0x602,0xE04,0x1C08,0x3810,0x7020,0x2000,0x0,
0x3C1C,0x7E26,0xFF63,0xFF63,0xFF63,0x7F32,0x3E1C,0x1C00,
0x1C0C,0x3C1C,0x1C0C,0x1C0C,0x1C0C,0x1C0C,0x7F3F,0x3F00,
0x7E3E,0xFF63,0x7F07,0x3F1E,0x7E3C,0xFC70,0xFF7F,0x7F00,
0xFF7F,0x7F06,0x1E0C,0x3E1E,0x1F03,0xFF63,0x7F3E,0x3E00,
0x1E0E,0x3E1E,0x7E36,0xFE66,0xFF7F,0x7F06,0xE06,0x600,
0xFE7E,0xFE60,0xFE7E,0x7F03,0x703,0xE763,0x7F3E,0x3E00,
0x3E1E,0x7E30,0xF060,0xFE7E,0xFF63,0xFF63,0x7F3E,0x3E00,
0xFF7F,0x7F03,0xF06,0x1E0C,0x3C18,0x3818,0x3818,0x1800,
0x7C3C,0xFE62,0xFE72,0x7E3C,0xFF4F,0xFF43,0x7F3E,0x3E00,
0x7E3E,0xFF63,0xFF63,0x7F3F,0x3F03,0xF06,0x7E3C,0x3C00,
0x0,0x3818,0x3818,0x1800,0x3818,0x3818,0x1800,0x0,
0x0,0x3818,0x3818,0x1800,0x3818,0x3818,0x7830,0x3000,
0xE06,0x1E0C,0x3C18,0x7830,0x3818,0x1C0C,0xE06,0x600,
0x0,0x0,0x7E3E,0x3E00,0x7E3E,0x3E00,0x0,0x0,
0x7030,0x3818,0x1C0C,0xE06,0x1E0C,0x3C18,0x7830,0x3000,
0x7E3E,0xFF7F,0xFF63,0x7F06,0x1E0C,0xC00,0x1C0C,0xC00,
0x7C3C,0xFE42,0xFF99,0xFFA1,0xFFA1,0xFF99,0xFF42,0x7E3C,
0x3C1C,0x7E36,0xFF63,0xFF63,0xFF7F,0xFF63,0xE763,0x6300,
0xFE7E,0xFF63,0xFF63,0xFF7E,0xFF63,0xFF63,0xFF7E,0x7E00,
0x3E1E,0x7F33,0xF360,0xE060,0xE060,0x7733,0x3F1E,0x1E00,
0xFC7C,0xFE66,0xFF63,0xFF63,0xFF63,0xFF66,0xFE7C,0x7C00,
0xFF7F,0xFF60,0xE060,0xFE7E,0xFE60,0xE060,0xFF7F,0x7F00,
0xFF7F,0xFF60,0xE060,0xFE7E,0xFE60,0xE060,0xE060,0x6000,
0x3F1F,0x7F30,0xF060,0xFF6F,0xFF63,0x7F33,0x3F1F,0x1F00,
0xE763,0xE763,0xE763,0xFF7F,0xFF63,0xE763,0xE763,0x6300,
0x7F3F,0x3F0C,0x1C0C,0x1C0C,0x1C0C,0x1C0C,0x7F3F,0x3F00,
0x703,0x703,0x703,0x703,0x703,0xE763,0x7F3E,0x3E00,
0xE763,0xEF66,0xFE6C,0xFC78,0xFC7C,0xFE6E,0xEF67,0x6700,
0x7030,0x7030,0x7030,0x7030,0x7030,0x7030,0x7F3F,0x3F00,
0xE763,0xFF77,0xFF7F,0xFF6B,0xEF63,0xE763,0xE763,0x6300,
0xE763,0xF773,0xFF7B,0xFF7F,0xFF6F,0xEF67,0xE763,0x6300,
0x7E3E,0xFF63,0xFF63,0xFF63,0xFF63,0xFF63,0x7F3E,0x3E00,
0xFE7E,0xFF63,0xFF63,0xFF63,0xFF7E,0xFE60,0xE060,0x6000,
0x7E3E,0xFF63,0xFF63,0xFF63,0xFF6F,0xFF66,0x7F3D,0x3D00,
0xFE7E,0xFF63,0xFF63,0xFF67,0xFF7C,0xFE6E,0xEF67,0x6700,
0x7C3C,0xFE66,0xFE60,0x7E3E,0x3F03,0xFF63,0x7F3E,0x3E00,
0x7F3F,0x3F0C,0x1C0C,0x1C0C,0x1C0C,0x1C0C,0x1C0C,0xC00,
0xE763,0xE763,0xE763,0xE763,0xE763,0xE763,0x7F3E,0x3E00,
0xE763,0xE763,0xE763,0xFF77,0x7F3E,0x3E1C,0x1C08,0x800,
0xE763,0xE763,0xE763,0xFF6B,0xFF7F,0xFF77,0xF763,0x6300,
0xE763,0xFF77,0x7F3E,0x3E1C,0x7E3E,0xFF77,0xF763,0x6300,
0xEE66,0xEE66,0xEE66,0x7E3C,0x3C18,0x3818,0x3818,0x1800,
0xFF7F,0x7F07,0x1F0E,0x3E1C,0x7C38,0xF870,0xFF7F,0x7F00,
0x3C1C,0x3C18,0x3818,0x3818,0x3818,0x3818,0x3C1C,0x1C00,
0x0,0x6020,0x3010,0x1808,0xC04,0x602,0x200,0x0,
0x3C1C,0x1C0C,0x1C0C,0x1C0C,0x1C0C,0x1C0C,0x3C1C,0x1C00,
0x1808,0x3C1C,0x7E36,0xF763,0x6300,0x0,0x0,0x0,
0xFF7F,0xFF7F,0xFF7F,0xFF7F,0xFF7F,0xFF7F,0xFF7F,0x7F00};
#endif

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
16069,16143,16207,16261,16305,16340,16364,16379};

static int ttg[65]={
-16384,-15599,-14850,-14133,-13446,-12786,-12151,-11539,
-10947,-10375,-9820,-9281,-8757,-8247,-7749,-7263,
-6786,-6320,-5862,-5413,-4970,-4534,-4104,-3679,
-3259,-2843,-2430,-2021,-1614,-1209,-805,-402,
0,402,805,1209,1614,2021,2430,2843,
3259,3679,4104,4534,4970,5413,5862,6320,
6786,7263,7749,8247,8757,9281,9820,10375,
10947,11539,12151,12786,13446,14133,14850,15599,16384};

static WORD palette[32] =
{
   0x0000,0x1008,0x3080,0x5088,
   0x2800,0x3808,0x4880,0x5ccc,
   0x3888,0x400f,0x50f0,0x60ff,
   0x4f00,0x5f0f,0x7ff0,0x8fff
};
      /* tableau de sin,cos et tan */
int *sn=tsn;  
int *cs=tsn+64;
int *tg=ttg+32;

int msex=160,msey=100,msek=0,mclk=0;
int mousex=160,mousey=100,mousek=0,vblclock = 0;

char keymap[256]={0};

/* declaration de types */

typedef struct BitMap *Bitmap;

struct Display_
{
   struct View view;
   struct ViewPort viewport;
   struct RasInfo rasinfo;
   Bitmap bitmap;
};
typedef struct Display_ *Display;

   /* AREA_SIZE * 2 / 5  donne le nb max de points pour un polyfill */
#define AREA_SIZE 50
                     /* 20 points */
#define ELLIPSE_SIZE 8
                     /* 3 points */
struct GC_
{
   struct RastPort rastport;
   PLANEPTR plane;
   struct AreaInfo areainfo,ellipseinfo;
   struct TmpRas tmpras;
   WORD areabuffer[AREA_SIZE];
   WORD ellipsebuffer[ELLIPSE_SIZE];
};
typedef struct GC_ *GC;

/* variables globales */
static struct RastPort *rastport=0l;

#ifdef FAST_FONT
static struct TextFont *textFont=0,*oldTextFont=0;
#else
static Bitmap char_forme=0L;
#endif

static struct View* oldview=0L;

static int color;    /* couleur courante */
static int xcur = 0, ycur = 0; /* position du curseur charactere */

static Display disp1=0L;
static Display disp2=0L;
static GC gc=0L;
struct GfxBase *GfxBase=0L;
static int nbscreen=2;
static int working=1;
static int system=0;

/* fonctions internes */

#define WIDTH_OF(u) ((u)->BytesPerRow<<3)
#define HEIGHT_OF(u) ((u)->Rows)
#define DEPTH_OF(u) ((u)->Depth)

static Bitmap YFreeBitmap(Bitmap bit)
{
   int p;
   if (bit)
   {
      for(p=0;p<DEPTH_OF(bit);p++)
         FreeRaster(bit->Planes[p],WIDTH_OF(bit),HEIGHT_OF(bit));
      memfree((void **)&bit);
   }
   return 0L;
}

static Bitmap YCreateBitmap(int lx,int ly,int depth)
{
   Bitmap bit;
   int p;
   if (!(bit=ALLOC_MEM(struct BitMap)))
      return 0L;
      
   InitBitMap(bit,depth,lx,ly);
   for(p=0;p<depth;p++)
      if (!(bit->Planes[p]=AllocRaster(lx,ly)))
      {
         DEPTH_OF(bit)=p;
         return YFreeBitmap(bit);
      }
   return bit;
}   

/* creation d'un ecran */

static void YFreeDisplay(Display disp)
{
   if (disp)
   {
      if (disp->bitmap)
         YFreeBitmap(disp->bitmap);     
      if ( disp->viewport.ColorMap)
         FreeColorMap(disp->viewport.ColorMap);

      FreeVPortCopLists(&disp->viewport);
      
      if (disp->view.LOFCprList)
         FreeCprList(disp->view.LOFCprList);
      if (disp->view.SHFCprList)
         FreeCprList(disp->view.SHFCprList);
    
      memfree((void **)&disp);
   }
}

static Display YCreateDisplay(UWORD width,UWORD height,UWORD depth,WORD *palette)
{
  Display disp;

   if ( !(disp = ALLOC_MEM(struct Display_)) )
      return 0L;
   if ( !(disp->bitmap=YCreateBitmap(width,height,depth)))
   {
      memfree((void **)&disp);
      return 0L;
   }   
   InitView(&disp->view);
   InitVPort(&disp->viewport);
   disp->view.ViewPort = &disp->viewport;
   disp->view.DyOffset+=28;
   
   disp->rasinfo.BitMap = disp->bitmap;
   disp->rasinfo.RxOffset = 0;
   disp->rasinfo.RyOffset = 0;
   disp->rasinfo.Next = NULL;
   
   disp->viewport.RasInfo = &disp->rasinfo;
   disp->viewport.DWidth = width;
   disp->viewport.DHeight = height;
   disp->viewport.Modes = SPRITES;

   disp->viewport.ColorMap = GetColorMap(32L);
   if (!(disp->viewport.ColorMap))
   {
      YFreeDisplay(disp);
      return 0L;
   }
   LoadRGB4(&disp->viewport,palette,32L);
   MakeVPort(&disp->view,&disp->viewport);
   
   MrgCop(&disp->view);

   return disp;
}

/* GESTION DU GC */

static GC YCreateGC(Bitmap bit)
{
   GC gc;
   int i,lx,ly;
 
   if (bit)
   {
      if ( !(gc = ALLOC_MEM(struct GC_)) )
         return 0L;

      lx=WIDTH_OF(bit);
      ly=HEIGHT_OF(bit);   
         
      InitRastPort(&gc->rastport);
      gc->rastport.BitMap= bit;
      BNDRYOFF(&gc->rastport); /* no outline */

      if (!(gc->plane = AllocRaster(lx,ly)))
      {
         memfree((void **)&gc);
         return 0L;
      }
   
      for(i=0;i<AREA_SIZE;i++)
         gc->areabuffer[i]=0;
      for(i=0;i<ELLIPSE_SIZE;i++)
         gc->ellipsebuffer[i]=0;
      
      InitArea(&gc->areainfo,gc->areabuffer,(AREA_SIZE*2)/5);   
      InitArea(&gc->ellipseinfo,gc->ellipsebuffer,(ELLIPSE_SIZE*2)/5);   
      InitTmpRas(&gc->tmpras,gc->plane,RASSIZE(lx,ly));
      gc->rastport.TmpRas = &gc->tmpras;  

      return gc;
   }
return 0L;
}

static void YFreeGC(GC gc)
{
   if (gc)
   {
      if (gc->plane)
             FreeRaster(gc->plane,
                        WIDTH_OF(gc->rastport.BitMap),
                        HEIGHT_OF(gc->rastport.BitMap));
      
      memfree((void **)&gc);
   }
}

/********************************/
/* gestion des blocs graphiques */

typedef struct
{
   int lx,ly,id;
   Bitmap bloc,mask;
} pixbloc;

void initbloc(void **blocptr)
{
	pixbloc *bloc;
	*blocptr=ALLOC_MEM(pixbloc);
	if (bloc=(pixbloc *)*blocptr) bloc->id=0;
}

void freebloc(void **blocptr)
{
	pixbloc *bloc;
	if (bloc=(pixbloc *)*blocptr)
	{
		if (bloc->id) YFreeBitmap(bloc->bloc);
		if (bloc->id==2) YFreeBitmap(bloc->mask);
		memfree(blocptr);
	}
}
      
void getbloc(void **blocptr,int x,int y,int lx,int ly)
{
	pixbloc *bloc;
	if (bloc=(pixbloc *)*blocptr)
	{
		if ((!bloc->id) || (bloc->lx!=lx) || (bloc->ly!=ly) )
		{
			if (bloc->id) YFreeBitmap(bloc->bloc);
			if (bloc->id==2) YFreeBitmap(bloc->mask);
			bloc->id=0;
			bloc->bloc=YCreateBitmap(lx,ly,BLOC_DEPTH);
			if (bloc->bloc)
			{
				bloc->id=1;
				bloc->lx=lx;
				bloc->ly=ly;
			}
		}

		if (bloc->id)
         BltBitMap(rastport->BitMap,x,y,bloc->bloc,
            0,0,lx,ly,0xC0L,0xffL,0L);
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
         BltBitMap(blocs->bloc,xs,ys,
            blocd->bloc,xd,yd,lxs,lys,0xC0L,0xffL,0L);         
   		if ((blocs->id==2)&&(blocd->id==2))
   		{
            BltBitMap(blocs->mask,xs,ys,
               blocd->mask,xd,yd,lxs,lys,0xC0L,0xffL,0L);         
   		}
		}
	}
}

void putpbloc(void **blocptr,int x,int y,int xs,int ys,int lxs,int lys)
{
	pixbloc *bloc;
	if ((bloc=(pixbloc *)*blocptr) && (x>=0) && (x<WIDTH))
   {
		if (y<0)
		{
			ys-=y;
			lys+=y;
			y=0;
	   }
		else
		if (y+lys>HEIGHT)
		{
			lys=HEIGHT-y;
		}
		if ((lys>0)&&(y>=0)&&(xs>=0)&&(ys>=0))
		if ((x+lxs<=WIDTH)&&(y+lys<=HEIGHT))
		if (bloc->id==1)
         BltBitMapRastPort(bloc->bloc,xs,ys,
            rastport,x,y,lxs,lys,0xC0L);
		else
		if (bloc->id==2)
         BltMaskBitMapRastPort(bloc->bloc,xs,ys,rastport,
            x,y,lxs,lys,0xE0L,(APTR)bloc->mask->Planes[0]);
	}
}

void putbloc(void **blocptr,int x,int y)
{
	pixbloc *bloc;
   if (bloc=(pixbloc *)*blocptr)
		putpbloc(blocptr,x,y,0,0,bloc->lx,bloc->ly);
}

void getmask(void **blocptr,int x,int y)
{
	pixbloc *bloc;
	if ((bloc=(pixbloc *)*blocptr) && (bloc->id))
   {
		if (bloc->id==2)
		{
		   YFreeBitmap(bloc->mask);
			bloc->id=1;
		}
		if (bloc->id==1)
		{
			bloc->mask=YCreateBitmap(bloc->lx,bloc->ly,MASK_DEPTH);
			if (bloc->mask) bloc->id=2;
		}
		if (bloc->id==2)
      BltBitMap(rastport->BitMap,x,y,bloc->mask,0,0,bloc->lx,bloc->ly,
         0xC0L,0xffL,0L);
	}
}

/* devices */

#define pointer_height 16
static UWORD_CHIP sprite_wait[]=
   {
    0,0, /* reserved, must be NULL */
    0x0400, 0x07C0,
    0x0000, 0x07C0,
    0x0100, 0x0380,
    0x0000, 0x07E0,
    0x07C0, 0x1FF8,
    0x1FF0, 0x3FEC,
    0x3FF8, 0x7FDE,
    0x3FF8, 0x7FBE,
    0x7FFC, 0xFF7F,
    0x7EFC, 0xFFFF,
    0x7FFC, 0xFFFF,
    0x3FF8, 0x7FFE,
    0x3FF8, 0x7FFE,
    0x1FF0, 0x3FFC,
    0x07C0, 0x1FF8,
    0x0000, 0x07E0,
    0,0, /* reserved, must be NULL */
};

static UWORD_CHIP sprite_data[]=
{
   0,0,   /* reserve */
  	0xc000,0x0000,  /* dessin */
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
	0x0380,0x0000,
	0x0000,0x0000      /* reserve */
};

static struct SimpleSprite pointer_sprite;
static int sprite_nb= -1;
static int sprite_color;
static int mouselevel=0;

static void Wait_IO(void)
{
   if (system)
   {
      pointer_sprite.x = mousex;
      pointer_sprite.y = mousey;
      pointer_sprite.height = pointer_height;
      ChangeSprite(NULL,&pointer_sprite,sprite_wait);
   }
}

static void End_IO(void)
{
 if (system)
 {  
   if (mouselevel>=0)
   {
      pointer_sprite.x = mousex;
      pointer_sprite.y = mousey;
   }
   else
   {
      pointer_sprite.x = WIDTH+2;
      pointer_sprite.y = HEIGHT+2;
   }
   pointer_sprite.height = pointer_height;
   ChangeSprite(NULL,&pointer_sprite,sprite_data);
 }
}

static int YCreatePointer(void)
{
   sprite_nb =  GetSprite(&pointer_sprite, -1);
   if (sprite_nb == -1) return 0;
   
   sprite_color = 16+((sprite_nb & 0x06) << 1);

   palette[sprite_color+1]=0x000;
   palette[sprite_color+2]=0x888;
   palette[sprite_color+3]=0xFFF;

   pointer_sprite.x = mousex;
   pointer_sprite.y = mousey;
   pointer_sprite.height = pointer_height;
   ChangeSprite(NULL,&pointer_sprite,sprite_data);
  
   return 1;
}

static void YFreePointer(void)
{
   if (sprite_nb != -1)
      FreeSprite(sprite_nb);
}

void hide(void)
{
   mouselevel--;
   if (mouselevel<0)
    MoveSprite(NULL,&pointer_sprite,WIDTH+2,HEIGHT+2);
}

void show(void)
{
   mouselevel++;
   if (mouselevel>=0)
      MoveSprite(NULL,&pointer_sprite,mousex,mousey);
}


/*     AUDIO    */   
 
static struct MsgPort   *AudioMP  = NULL;
static struct IOAudio   *AudioIO  = NULL;
static int audio_error=1;
static int playing=0;
static ULONG horloge;
static UBYTE cannaux[] = { 3 , 5 , 10 , 12 };


/*********************************************************/
static int init_audio(void)
/**********************************************************
** Initialise le port de message et la struture d'E/S    **
** pour les sorties audio.                               **
**********************************************************/
{
#ifndef NO_SAMPLE   
   if (GfxBase->DisplayFlags & PAL)
      horloge = 3546895L;
   else
      horloge = 3579545L;
       
   if( ( AudioMP = CreatePort(0,0) ) == NULL) return(0);
   
   AudioIO = (struct IOAudio*)CreateExtIO( AudioMP,
                                        sizeof( struct IOAudio ));

   if( AudioIO )
   {
      AudioIO->ioa_Request.io_Command = ADCMD_ALLOCATE;
      AudioIO->ioa_Request.io_Flags = ADIOF_NOWAIT;
      AudioIO->ioa_AllocKey = 0;
      AudioIO->ioa_Data = cannaux;
      AudioIO->ioa_Length = sizeof(cannaux);

      if( audio_error = OpenDevice( AUDIONAME , 0L, 
                        (struct IORequest*)AudioIO ,0L))
      {
         DeleteExtIO( (struct IORequest*)AudioIO );
         DeletePort( AudioMP );
         return 0;
      }
   }
   else
   {
      DeletePort( AudioMP );
      return 0;
   }
#endif
         
   return(1);

} 

/*********************************************************/
static void fin_audio(void)
/**********************************************************
** Ferme tout ce qui à été ouvert pour l'audio           **
**********************************************************/
{
#ifndef NO_SAMPLE   
    stopsample();
    if (!audio_error) CloseDevice( (struct IORequest*)AudioIO );
    if (AudioIO) DeleteExtIO( (struct IORequest*)AudioIO );
    if ( AudioMP ) DeletePort( AudioMP );
#endif
} 
  
void fixsample(void *adr,long len)
{ 
#ifndef NO_SAMPLE   
   LONG l;
   BYTE *data;
         data=(BYTE *)adr;
               
         for(l=0L;l<len;l++)
            *(data++) -= 128;
#endif            
}

void playsample(void *adr,long len,long freq)
{
#ifndef NO_SAMPLE
   stopsample();

   AudioIO->ioa_Data    = adr;
   AudioIO->ioa_Length  = len;
   AudioIO->ioa_Period  = horloge / freq;
   AudioIO->ioa_Cycles = 1;
   AudioIO->ioa_Volume = 64;
   
   AudioIO->ioa_Request.io_Command = CMD_WRITE;
   AudioIO->ioa_Request.io_Flags = ADIOF_PERVOL | ADIOF_NOWAIT ;

   BeginIO( (struct IORequest*)AudioIO );
   playing=1;
#endif
} 

void stopsample(void)
{
#ifndef NO_SAMPLE
 if (playing)
 {   
   AbortIO( (struct IORequest*)AudioIO );
   WaitPort(AudioMP);
 }
 playing=0;
#endif
}


/*  DEVICES */

   
struct Device_
{
   struct IOStdReq *request;
   struct MsgPort *port;
   int error;
};
typedef struct Device_ *Device;
struct DeviceTimer_
{
   struct timerequest *request;
   struct MsgPort *port;
   int error;
};
typedef struct DeviceTimer_ *DeviceTimer;
   
Device YCloseDevice(Device dev)
{
   if (dev)
   {
      if (!dev->error)
         CloseDevice(dev->request);
      if (dev->request)
         DeleteExtIO(dev->request);
      if (dev->port)
         DeletePort(dev->port);
      memfree((void **)&dev);
   }            
   return 0L;
}   

Device YOpenDevice(char name[],long unit,long size)
{
   Device dev;
   if (!(dev = ALLOC_MEM(struct Device_)))
      return 0L;
   dev->error=1;
   if (!(dev->port=CreatePort(0L,0L)))
      return YCloseDevice(dev);
   if (!(dev->request=CreateExtIO(dev->port,size)))
      return YCloseDevice(dev);
   if (dev->error=OpenDevice(name,unit,dev->request,NULL))
      return YCloseDevice(dev);
   return dev;
}    
#define OPEN_DEVICE(c,u,t) YOpenDevice(c,u,sizeof(t))

static DeviceTimer timer=0L;
static struct timerequest *timer_request;
static Device handler=0L;
static struct Interrupt  *message=0L;

static void repeatkey(ULONG sec,ULONG micro)
{
   DeviceTimer repeat;
   repeat=(DeviceTimer)OPEN_DEVICE("input.device",0,struct timerequest);
   if (repeat)
   {
      repeat->request->tr_node.io_Command=IND_SETTHRESH;
      repeat->request->tr_time.tv_secs=sec;
      repeat->request->tr_time.tv_micro=micro;
      DoIO ((struct IORequest *)repeat->request);
      YCloseDevice((Device)repeat);
   }
}

void waitdelay(unsigned int millisec)
{
      if (millisec != 0)
      {
         timer_request->tr_time.tv_secs = millisec / 1000;
         timer_request->tr_time.tv_micro = 1000 * (millisec % 1000);
         timer_request->tr_node.io_Command = TR_ADDREQUEST;
         DoIO ((struct IORequest *)timer_request);
      }
}      

unsigned long systime(void)
{
   timer_request->tr_node.io_Command = TR_GETSYSTIME;
   DoIO( (struct IORequest *)timer_request);
   return (timer_request->tr_time.tv_secs*1000L+
            timer_request->tr_time.tv_micro/1000L);
}

/*  aleatoires */
ULONG RangeRand(ULONG);

int randint(void)
{
   return ((int)RangeRand(32768L));
}
int randval(int n)
{
   return ((int)RangeRand(n));
}

/* evenements */

#define MAX_MOUSE_X  319
#define MAX_MOUSE_Y  199


#define MAX_MOUSE_EVENT 32

typedef struct {
   int button;
   int x,y;
   int clock;
} mouse_event;

static mouse_event mouse_tableau[MAX_MOUSE_EVENT];
static int mouse_entree=0;
static int mouse_sortie=0;
static int mouse_nb=0;
static volatile int flag_mouse = 1;
static int keybbufptr=0;
static int lstkbufptr=0;
static int nbrkbuffer=0;
static volatile int kbufferflag = 1;
static char keybbuffer[256]={0};

#define MAX_KEY 256

int buthit(void)
{
   return mouse_nb;
}

int kbhit(void)
{
	return(nbrkbuffer);
}

int keyhit(void)
{
	return(nbrkbuffer|mouse_nb);
}

char getch(void)
{
	char r;

	do {} while(!nbrkbuffer);

   kbufferflag=0;
	r=keybbuffer[lstkbufptr];
	lstkbufptr++;
	lstkbufptr&=255;
	nbrkbuffer--;
	kbufferflag=1;
	return(r);
}


void empty(void)
{
   flag_mouse = 0;
   mouse_entree = mouse_sortie = mouse_nb = 0;
   flag_mouse = 1;

	kbufferflag=0;
	nbrkbuffer=keybbufptr=lstkbufptr=0;
	kbufferflag=1;
}

void confirm(void)
{ int g;
   empty();
   do { g=getmouse(); } while(g!=1 && g!=2);
}

int getmouse(void)
{
   if (mouse_nb)
   {
      flag_mouse=0;
      msex = mouse_tableau[mouse_sortie].x ;
      msey = mouse_tableau[mouse_sortie].y ;
      msek = mouse_tableau[mouse_sortie].button ;
      mclk = mouse_tableau[mouse_sortie].clock ;
      mouse_sortie++;
      mouse_sortie &= (MAX_MOUSE_EVENT-1);
      mouse_nb--;
      flag_mouse=1;
      return (msek);
   }
   return 0;
}

static int codescan(int c)
{
   static char *ab="`1234567890 _|?0azertyuiop^$?123qsdfghjklm%#?456<wxcvbn,;:=?.789 \010\0\015\015\033{";
	
   if (c<71) return ((int)ab[c]);
	switch(c)
	{
		case 0x4a: return '-';
		case 0x4c: return '^';
		case 0x4d: return 'v';
		case 0x4e: return '>';
		case 0x4f: return '<';
		case 0x5a: return '(';
		case 0x5b: return ')';
		case 0x5c: return '/';
		case 0x5d: return '*';
		case 0x5e: return '+';
      case 0x5f: return '}';
	}
	return (0);
}

#ifdef LATTICE
struct InputEvent * __asm myhandler(register __a0 struct InputEvent *event,
register __a1 APTR mydata)
#else
struct InputEvent *myhandler(struct InputEvent *event,APTR mydata)
#endif
{
register struct InputEvent *ev;
register int new_event;
int  a,b;
   ev = event;
   b=0;
   do
   {
      vblclock++;  
      new_event = 0;
      switch ( ev->ie_Class )
      {
          case  IECLASS_RAWMOUSE:
            mousex += ev->ie_X;
            if (mousex < 0) mousex = 0;
            else
               if (mousex > MAX_MOUSE_X) mousex = MAX_MOUSE_X;
            mousey += ev->ie_Y;
            if (mousey < 0) mousey = 0;
            else
               if (mousey > MAX_MOUSE_Y) mousey = MAX_MOUSE_Y;
            
            b=1;
            
            if ((mouse_nb < MAX_MOUSE_EVENT) && flag_mouse)
            {
               switch ( ev -> ie_Code )
               {
                   case IECODE_UP_PREFIX+IECODE_LBUTTON:
                     new_event = 5;
                     mousek &= ~1;
                     break;
                   case IECODE_UP_PREFIX+IECODE_RBUTTON:
                     new_event = 6;
                     mousek &= ~2;
                     break;
                   case IECODE_LBUTTON:
                     new_event  = 1;
                     mousek |= 1;
                     break;
                   case IECODE_RBUTTON:
                     new_event = 2;
                     mousek |= 2;
                     break;
               }         
               if (new_event)
               {
                     mouse_tableau[mouse_entree].x = mousex;
                     mouse_tableau[mouse_entree].y = mousey;
                     mouse_tableau[mouse_entree].button = new_event;
                     mouse_tableau[mouse_entree].clock = vblclock;
                     mouse_entree++;
                     mouse_entree &= (MAX_MOUSE_EVENT-1);
                     mouse_nb++;
               }
            }
            break;
            
        case IECLASS_RAWKEY:
            new_event = ev -> ie_Code;
            a=codescan(new_event & 127);
            if (new_event<128)
            {
               keymap[a]=1;
               if ((nbrkbuffer < MAX_KEY) && (kbufferflag))
               {
                     keybbuffer[keybbufptr]=a;
                     keybbufptr++;
                     keybbufptr &= ( MAX_KEY-1);
                     nbrkbuffer++;
               }
            }
            else
               keymap[a]=0;
                 
            break;
         case IECLASS_DISKINSERTED :
         case IECLASS_DISKREMOVED :
            ev->ie_NextEvent=0L;
            return ev;
                                   
      }         
      ev = ev->ie_NextEvent;
   } while(ev);
   
   if (b && (mouselevel>=0)) MoveSprite(NULL,&pointer_sprite,mousex,mousey);
   
   return (NULL);
}

int init_device(void)
{
   struct InputEvent event;
   if (!YCreatePointer())
      return 0;
   
   if (!(timer=(DeviceTimer)OPEN_DEVICE(TIMERNAME,UNIT_MICROHZ,struct timerequest)))
      return 0;
   timer_request=timer->request; 
   
   if (!(handler=OPEN_DEVICE("input.device",0,struct IOStdReq)))
      return 0;
   /* cache la souris */
   event.ie_NextEvent=NULL;
   event.ie_Class = IECLASS_POINTERPOS;
   event.ie_Code = IECODE_NOBUTTON;
   event.ie_Qualifier=IEQUALIFIER_RELATIVEMOUSE;
   event.ie_X=641;
   event.ie_Y=481;
   handler->request->io_Data = (APTR)(&event);
   handler->request->io_Command = IND_WRITEEVENT;
   handler->request->io_Flags = 0;
   handler->request->io_Length = sizeof(struct InputEvent);
   DoIO(handler->request);
   
   waitdelay(300);
          
   if (!(message=ALLOC_MEM(struct Interrupt)))
      return 0;
#ifdef LATTICE      
   message->is_Code = (void (*)(void))myhandler;
#else
   message->is_Code = HandlerInterface;
#endif
   
   message->is_Data = 0L;

   message->is_Node.ln_Pri=100;
   message->is_Node.ln_Name="handler";
               
   handler->request->io_Data=(APTR)message;
   handler->request->io_Command=IND_ADDHANDLER;
   DoIO(handler->request);
       
   
   repeatkey(3600L,0L);
   return 1;
}

void fin_device(void)
{
   repeatkey(0L,500000L);
   YFreePointer();
   if (message)
   {
      handler->request->io_Data=(APTR)message;
      handler->request->io_Command=IND_REMHANDLER;
      DoIO(handler->request);
      memfree((void **)&message);
   }
   YCloseDevice(handler);
   YCloseDevice((Device)timer);
}


/************************************/
/* instructions graphiques de bases */

void getpalette(unsigned int *pal)
{
	int i;
	for(i=0;i<NB_COL;i++) pal[i]=palette[i];
}

void setpalette(unsigned int *pal)   
{
 int i;
	for(i=0;i<NB_COL;i++) palette[i]=pal[i];
   LoadRGB4(&disp1->viewport,palette,32);
   LoadRGB4(&disp2->viewport,palette,32);
}  

#define CHG_COLOR(c) if (c>=0) setcolor(c) 

void cls(void)
{
   SetRast(rastport,0L);
   xcur=ycur=0;
}

void setcolor(int c)
{
   color=c;
   SetAPen(rastport,c & 15);
}
#ifdef ATTENTION
void warning(char *texte)
{
   printf("warning : %s \n",texte);
}
#endif

void plot(int x,int y,int c)
{
   CHG_COLOR(c);
#ifdef ATTENTION
   if (x< 0 || y<0 || x>=WIDTH || y>=HEIGHT)
      warning("plot");
   else
#endif      
      WritePixel(rastport,x,y);
}      

void dline(int x1,int y1,int x2,int y2,int c)
{
   CHG_COLOR(c);
#ifdef ATTENTION
   if (x1<0 || y1<0 || x1>=WIDTH || y1>=HEIGHT)
      warning("dline : 1");
   if (x2<0 || y2<0 || x2>=WIDTH || y2>=HEIGHT)
      warning("dline : 2");
#endif      
   Move(rastport,x1,y1);
   Draw(rastport,x2,y2);
}

void rline(int x1,int y1,int x2,int y2,int c)
{
   CHG_COLOR(c);
#ifdef ATTENTION   
   if (x1<0 || y1<0 || x1>=WIDTH || y1>=HEIGHT)
      warning("rline : 1");
   if (x2<0 || y2<0 || x2>=WIDTH || y2>=HEIGHT)
      warning("rline : 2");
#endif   
   Move(rastport,x1,y1);
   Draw(rastport,x2,y2);
}

void vline(int x,int y,int y2,int c)
{
#ifdef ATTENTION   
   if (x<0 || y<0 || x>=WIDTH || y>=HEIGHT)
      warning("vline : 1");
   if (y2<0 || y2>=HEIGHT)
      warning("vline : 2");
#endif   
   CHG_COLOR(c);
   Move(rastport,x,y);
   Draw(rastport,x,y2);
}

void hline(int x,int y,int x2,int c)
{
#ifdef ATTENTION   
   if (x<0 || y<0 || x>=WIDTH || y>=HEIGHT)
      warning("hline : 1");
   if (x2<0 || x2>=WIDTH)
      warning("hline : 2");
#endif   
   CHG_COLOR(c);
   Move(rastport,x,y);
   Draw(rastport,x2,y);
}

void dbox(int x,int y,int lx,int ly,int c)
{
   int x2,y2;

   CHG_COLOR(c);

   x2=x+lx-1;
   y2=y+ly-1;
#ifdef ATTENTION   
   if (x<0 || y<0 || x>=WIDTH || y>=HEIGHT)
      warning("dbox : 1");
   if (x2<0 || y2<0 || x2>=WIDTH || y2>=HEIGHT)
      warning("dbox : 2");
#endif   
   Move(rastport,x,y);
   Draw(rastport,x2,y);
   Draw(rastport,x2,y2);
   Draw(rastport,x,y2);
   Draw(rastport,x,y);
}   
   
void pbox(int x,int y,int lx,int ly,int c)
{
#ifdef ATTENTION   
   int x2=x+lx-1,y2=y+ly-1;
#endif   
   
   CHG_COLOR(c);   

#ifdef ATTENTION
      
   if (x<0 || y<0 || x>=WIDTH || y>=HEIGHT)
      warning("rbox : 1");
   if (x2<0 || y2<0 || x2>=WIDTH || y2>=HEIGHT)
      warning("rbox : 2");
   if ((lx<=0) || (ly<=0))
      warning("rbox : 3");
   else
#endif      
      RectFill(rastport,x,y,x+lx-1,y+ly-1);
}

void pellipse(int x,int y,int lx,int ly,int c)
{
   int a = (lx>>1);
   int b = (ly>>1);
#ifdef ATTENTION   
   int x2=x+lx-1,y2=y+ly-1;
#endif   

   CHG_COLOR(c);

#ifdef ATTENTION
   if (x<0 || y<0 || x>=WIDTH || y>=HEIGHT)
      warning("pellipse : 1");
   if (x2<0 || y2<0 || x2>=WIDTH || y2>=HEIGHT)
      warning("pellipse : 2");
   if ((a<=0) || (b<=0))
      warning("pellipse : 3");
   else
#endif
   {
      rastport->AreaInfo= &gc->ellipseinfo;
      AreaEllipse(rastport,x+a,y+b,a,b);
      AreaEnd(rastport);
   }
}

void polyline(int n,int *tp,int c)
{
   if (n>1)
   {  CHG_COLOR(c);
      Move(rastport,tp[0],tp[1]);
      n--;tp+=2;    
      PolyDraw(rastport,n,tp);
   }
}

void polyfill(int n,int *tp,int c)
{
   int i;
   if (n>2)
   {
      CHG_COLOR(c);
      rastport->AreaInfo= &gc->areainfo;
      AreaMove(rastport,tp[0],tp[1]);
      n--; /* pas besoin du rebouclage des points */
      for (i=1;i<n;i++)
         AreaDraw(rastport,tp[i+i],tp[i+i+1]);
      AreaEnd(rastport);
   
   }
}

/*******************/
/* gestion memoire */

#define DEPL sizeof(long)

long ramfree(void)
{
	return((long)AvailMem(0L));
}

void memfree(void **adr)
{
	long size;

	if (*adr)
	{
		*adr=(void *)((long)*adr-DEPL);
		size=*(long *)*adr;
		FreeMem(*adr,size+DEPL);
		*adr=0L;
	}
}

void *memalloc(long size)
{
	void *r;

#ifdef NO_SAMPLE
	r=AllocMem(size+DEPL,MEMF_CLEAR);
#else
  r=AllocMem(size+DEPL,MEMF_CLEAR|MEMF_CHIP);
#endif
  
   if (r)
	{
		*(long *)r=size;
		r=(void *)(DEPL+(long)r);
	}
	return(r);
}

void bmove(void *src0,void *dst0,long len)
{
   long i;
   BYTE  *src,*dst;
   src = (BYTE *)src0;
   dst = (BYTE *)dst0;
   
   if (src>dst)
   {
      if (src-dst>len)
         CopyMem(src,dst,len);
      else
         for (i=0;i<len;i++) *dst++ = *src++;
   }
   else
   {
      if (dst-src>len)
         CopyMem(src,dst,len);
      else
      {
         dst+=len;
         src+=len;
      
         for(i=0;i<len;i++)      
            *(--dst) = *(--src);
     }
   }
}

/**********************/
/* gestion des fontes */

void affchar(int x,int y,char c)
{
#ifdef FAST_FONT
   char t[1];
   
   t[0]=c;
   Move(rastport,x,y+rastport->TxBaseline);
   Text(rastport,t,1);
#else
   
   char *pt;
   Bitmap old;

	if ((c>31)&&(c<128))
	{
		if (c>95) c-=64;
      else c-=32;
      
      pt=(char *)(sysfontes+(c<<3));
      old=rastport->BitMap;
      rastport->BitMap=char_forme;
      BltTemplate(pt,8,2,rastport,0,0,8,8);
      rastport->BitMap=old;
      BltMaskBitMapRastPort(char_forme,0,0,rastport,
            x,y,8,8,0xE0,(APTR)pt);
	}
#endif
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

void print(char *s)
{
	while(*s) printchar(*s++);
   xcur=0;ycur+=8; 	
}

/****************************/
/* systemes */

static void YLoadDisplay(Display disp)
{
   WaitBlit();
   LoadView(&disp->view);
   WaitTOF();
}

#define WorkingScreen(disp,nb) gc->rastport.BitMap=disp->bitmap;working=nb


static struct Process *process=0;
static APTR old_ptr;

int initsystem(void)
{  
#ifdef FAST_FONT
   struct TextAttr textAttr;
#endif      
   
   /* supprime les system requesters 'disk is full' 'disk is write protected '... */
   process=(struct Process *)FindTask(0L);
   if (process)
   {
      old_ptr=process->pr_WindowPtr;
      process->pr_WindowPtr=(APTR)-1L;
   }
   
      
   if (!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",33L)))
      return 0;
   if (!init_device())
   {
      killsystem();
      return 0;
   }
   if (!init_audio())
   {
      killsystem();
      return 0;
   }
#ifndef FAST_FONT   
   if (!(char_forme=YCreateBitmap(8,8,BLOC_DEPTH)))
   {
      killsystem();
      return 0;
   }
#endif      
   oldview = GfxBase->ActiView;
   
   disp1 =  YCreateDisplay(WIDTH,HEIGHT,DEPTH,palette);
   if (!disp1)
   {
      killsystem();
      return 0;
   }
   disp2 =  YCreateDisplay(WIDTH,HEIGHT,DEPTH,palette);
   if (!disp2)
   {
      killsystem();
      return 0L;
   }

   nbscreen=2;
   working=1;
         
   gc = YCreateGC(disp1->bitmap);
   if (!gc)
   {
      killsystem();
      return 0L;
   }
   rastport= &gc->rastport;
   
#ifdef FAST_FONT   
   
   oldTextFont=rastport->Font;
   
   SetDrMd(rastport,JAM1);
   
   textAttr.ta_Name="topaz.font";
   textAttr.ta_YSize=8;
   textAttr.ta_Style=FS_NORMAL;
   textAttr.ta_Flags=FPF_DESIGNED|FPF_ROMFONT;
   
   textFont=OpenFont(&textAttr);
   if (!textFont)
   {
      killsystem();
      return 0;
   }
   SetFont(rastport,textFont);
#endif   
   
   setcolor(15);
   
   cls();
   WorkingScreen(disp2,2);
   cls();

   YLoadDisplay(disp1);

   MoveSprite(NULL,&pointer_sprite,mousex,mousey);
   
   system=1;
   
   return 1;
}

void killsystem(void)
{
   system=0;
   
   if (oldview)
   {
      LoadView(oldview);
      WaitTOF();
   }
   WaitBlit();

#ifdef FAST_FONT
   if (textFont)
   {
      SetFont(rastport,oldTextFont);
      CloseFont(textFont);
   }
#endif   

   YFreeGC(gc);
   YFreeDisplay(disp2);
   YFreeDisplay(disp1);
#ifndef FAST_FONT   
   YFreeBitmap(char_forme);
#endif   
   fin_device(); 
   fin_audio();  
   if (GfxBase)
      CloseLibrary((struct Library *)GfxBase);
        
   if (process) process->pr_WindowPtr=old_ptr;    
} 

void simplescreen(void)
{
   if (nbscreen==2)
   {
      nbscreen=1;
      if (working == 1)
      {
            WorkingScreen(disp2,2);
      }
      else
      {
         WorkingScreen(disp1,1);
      }
   }
}

void doublescreen(void)
{
   if (nbscreen==1)
   {
      nbscreen=2;
      if (working == 1)
      {
         WorkingScreen(disp2,2);
      }
      else
      {
         WorkingScreen(disp1,1);
      }
   }
}

void swap(void)
{
   if (nbscreen==2)
   {
      if (working == 1)
      {
         WorkingScreen(disp2,2);
         YLoadDisplay(disp1);
      }
      else
      {
         WorkingScreen(disp1,1);
         YLoadDisplay(disp2);
      }         
   }
   else
      refresh();
}

void refresh(void)
{
   WaitBlit();
}

void copyscreen(void)
{
   if (nbscreen==2)
      if (working == 1)
         BltBitMap(disp2->bitmap,0,0,disp1->bitmap,
            0,0,WIDTH,HEIGHT,0xC0,0xff,NULL);
      else
         BltBitMap(disp1->bitmap,0,0,disp2->bitmap,
            0,0,WIDTH,HEIGHT,0xC0,0xff,NULL);
}

/* gestion des fichiers */

#define MAXFILE 16
static BPTR liste_file[MAXFILE]={0L};
static char used_file[MAXFILE]={0};
   
static int newfile(void)
{
   int i;
   for(i=0;i<MAXFILE;i++)
      if (!used_file[i]) return (i+1);
   return 0;
}

#define freefile(r) used_file[r]=liste_file[r]=0
   
int bexist(char *nom)
{
   BPTR fd;
   fd=Open(nom,MODE_OLDFILE);
   if (fd)
   {
      Close(fd);
      return 1;
   }
   return 0;
}

long bsize(char *nom)
{
   long size=0L;
   BPTR fd;
   Wait_IO();
   fd=Open(nom,MODE_OLDFILE);
   if (fd)
   {
      Seek(fd,0,OFFSET_END); /* se place a la fin du fichier */
      size=Seek(fd,0,OFFSET_CURRENT); /* recupere la position courante */
      Close(fd);
   }
   End_IO();
   return size;
}

int bmake(char *nom,void *adr,long len)
{
   BPTR fd;
   int error=1;
   Wait_IO();
   fd=Open(nom,MODE_NEWFILE);
   if (fd)
   {
      if (Write(fd,adr,len)==len) error=0;
      Close(fd);
   }
   End_IO();
   return error;
}

static int RWopen(char *nom,long mode)
{
   int r;
   BPTR fd;
   r=newfile();
   if (r)
   {
      fd=Open(nom,mode);
      if (fd)
      {
         liste_file[r-1]=fd;
         used_file[r-1]=1;
      }
      else
      {
         freefile(r-1);
         r = -1;
      }
    }
    return r;
}   

int bopen(char *nom)
{
   return RWopen(nom,MODE_OLDFILE);
}

int bclose(int r)
{
   r-=1;
   if ((r>=0) && (r<MAXFILE) && liste_file[r])
   {
      Close(liste_file[r]);
      freefile(r);
      return 0;
   }
   return (-1);
}

int bread(int r,void *adr,long len)
{
   r-=1;
   if ((r>=0) && (r<MAXFILE) && liste_file[r])
   {
      Wait_IO();
      r=Read(liste_file[r],adr,len);
      End_IO();
      if (r==len)
         return 0;
   }
   return (-1);
}

int bwrite(int r,void *adr,long len)
{
   r-=1;
   if ((r>=0) && (r<MAXFILE) && liste_file[r])
   {
      Wait_IO();
      r=Write(liste_file[r],adr,len);
      End_IO();
      if (r==len)
         return 0;
   }
   return (-1);
}

int bcreate(char *nom)
{
   return RWopen(nom,MODE_NEWFILE);
}

int bload(char *nom,void *adr,long offset,long len)
{
   BPTR fd;
   int error=1;
   Wait_IO();
   fd=Open(nom,MODE_OLDFILE);
   if (fd)
   {
      Seek(fd,offset,OFFSET_BEGINNING);
      if (Read(fd,adr,len)==len)
         error=0;
      Close(fd);
   }
   End_IO();
   return error;
}

int bsave(char *nom,void *adr,long offset,long len)
{
   BPTR fd;
   int error=1;
   Wait_IO();
   fd=Open(nom,MODE_OLDFILE);
   if (fd)
   {
      Seek(fd,offset,OFFSET_BEGINNING);
      if (Write(fd,adr,len)==len)
         error=0;
      Close(fd);
   }
   End_IO();
   return error;
}
