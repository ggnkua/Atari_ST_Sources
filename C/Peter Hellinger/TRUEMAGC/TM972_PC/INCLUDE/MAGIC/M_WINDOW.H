/*
   Modul: M_WINDOW (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPWINDOW_
#define _MPWINDOW_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#define  wDefault          0UL     /* Nix weiter tun                       */
#define  wBell             lBit0   /* Kling Glîckchen klingelingeling      */
#define  wColor            lBit1   /* Hintergrundfarbe des Fensters Ñndern */
#define  wFulled           lBit2   /* Fenster auf volle Grîûe bringen      */
#define  wTopped           lBit3   /* Fenster toppen                       */
#define  wHSlide           lBit4   /* Horizontal-Slider setzen             */
#define  wVSlide           lBit5   /* Vertikal-Slider setzen               */
#define  wSized            lBit6   /* Fenstergrîûe Ñndern                  */
#define  wMoved            lBit7   /* Fensterposition Ñndern               */
#define  wSizePos          lBit8   /* Fenster auf Grîûe + Position bringen */
#define  wChangeFont       lBit9   /* Font Ñndern                          */
#define  wClose            lBit10  /* Fenster schliessen                   */
#define  wBottomed         lBit11
#define  wIconify          lBit12
#define  wAllIconify       lBit13
#define  wUnIconify        lBit14
#define  wHSUpdate         lBit15
#define  wVSUpdate         lBit16
#define  wCallback         lBit17
#define  wTempClose        lBit18
#define  wReopen           lBit19
#define  wSetAsterik       lBit20
#define  wDelAsterik       lBit21
#define  wRedraw           lBit22  /* Redraw des Fensters auslîsen */ 
#define  wRedrawWin        lBit23  /* kompl. Redraw des Fensters auslîsen */
#define  wKeyDone          lBit24  /* Muss gesetzt sein, wenn der Tastendruck
                                      aus der WinKeyboard-Message verarbeitet
                                      werden konnte */
#define  wShade            lBit25  /* Fenster "shaden" */

#define  VSlider      0
#define  HSlider      1

typedef int tExData[16];
typedef long tExLong[16];

typedef struct _WinParameter
{
   int         window,
               mx,
               my,
               message;
   GRECT       spec;
   tExData     extended;
   LONGBITSET  action;
   void        *res;
   OBJECT      *tree;      /* Ab Lib-Version $407 */
   LONGBITSET  moreaction; /* Ab Lib-Version $412 */
   tExData     shortex;    /* Ab Lib-Version $412 */
   tExLong     longex;     /* Ab Lib-Version $412 */   
} WinParameter;

#define  WinMenu         lBit0
#define  WinText         lBit1
#define  WinDial         lBit2
#define  WinDrag         lBit3
#define  WinMaxsize      lBit4
#define  WinArrows       lBit5
#define  WinAlert        lBit6  /* Fenster enthÑlt Alertbox */
#define  WinTopAllowed   lBit7
#define  WinTransparent  lBit8  /* kein Hintergrund */
#define  WinBackclick    lBit9
#define  WinNoRedraw     lBit10 /* Keine auto. Redraws fÅr das Fenster */
#define  WinIconOpen     lBit11 /* Fenster iconified îffnen */
#define  WinShading      lBit12 /* Fenster shaden */
#define  WinIconTitle    lBit13 /* Text von Icons ikonifizierter Fenster in der Titelzeile */
#define  WinNoCycle		 lBit14 /* nimmt nicht am window cycling teil */
#define  WinMultiRsc	    lBit15

typedef WinParameter* PtrWinPara;

typedef struct _WinResource
{
	OBJECT	*tree;
	int		xpos,
		    ypos,
			mode,
			res1;
	void	*res2;
} WinResource;

#define  MaxResource  16
#define  tbAll        -1 
#define  tbUp          0  /* Toolbar oben     */
#define  tbDown        1  /* Toolbar unten    */
#define  tbLeft        2  /* Toolbar links    */
#define  tbRight       3  /* Toolbar rechts   */
#define  tbMenu        4  /* FenstermenÅzeile */
#define  tbIcon        5  /* Icon fÅr Iconify */

typedef WinResource WinTreeList[MaxResource];

/* Definition eines Funktionstyps */
typedef  void  (*RewriteProc)(void);
typedef  void  (*WindowHandler)(PtrWinPara);

BOOLEAN RectList(int win,int flag,GRECT *rect);
BOOLEAN RcIntersect(GRECT *rc1,GRECT *rc2);
void RedrawObjc(int win,OBJECT *tree,int entry,int depth,GRECT *clip);
void RedrawWindow(int win,int entry,int depth,GRECT *clip);
int OpenWindow (WindowHandler handler,
                BITSET element,LONGBITSET extended,
                int backcolor,int backrast,
                int x,int y,int w,int h,int xo,int yo,int wo,int ho,
                char *name, char *info,
                void *rsc,void *exinfo);
void CloseWindow(int win);
int DisposeWindows(void);
void SetWinName(int win,char *name);
void SetWinInfo(int win,char *info);
char *WinName(int win);
char *WinInfo(int win);
void SetWinAsterik(int win);
void DelWinAsterik(int win);
void SetWinTop(int win);
void SetWinBottom(int win);
void SetWinFull(int win);
void SetWinRect(int win, GRECT *rect);
void SetWinColor(int win,int color,int back);
void SetWinPos(int win,int xx,int yy);
void SetWinSize(int win,int ww,int hh);
void GetWinRect(int win,GRECT *rect);
void GetWorkRect(int win,GRECT *rect);
void GetUseableRect(int win,GRECT *rect);
void SetWinSlider(int win,int which,int pos,int size);
void PreventTopping (BOOLEAN prevent);
OBJECT *GetObjctree(int win);
OBJECT *GetMenutree(int win);
void RewriteWindow(int win,int handle,RewriteProc prc);
void *GetWinExinfo(int win);
void GEMTop(int *win,BOOLEAN *own);
BOOLEAN WinIconified(int win);
void IconifyWindow(int win,GRECT *rect,BOOLEAN iconify);
void SetIcontext(int win,char *text);
void SetWinIcon(int win,CICONBLK *icon);
void TempCloseWin(int win);
void ReopenWin(int win);
void SendSpecMessage(int win,int winmsg,int mx,int my,GRECT *r,
                     tExData ex,tExData sx,tExLong lx);
BOOLEAN WinOpen(int win);
int WinTop(BOOLEAN nodials);
void SetWinShade(int win);

#define RedrawScreen() CallMagic(2404)
#define TopNext()      CallMagic(2413)

#endif
