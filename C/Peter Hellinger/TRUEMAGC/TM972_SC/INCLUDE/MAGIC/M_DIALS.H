/*
   Modul: M_DIALS (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPDIALS_
#define _MPDIALS_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#define MoveBox       17
#define SpecButton    18
#define SpecText      19
#define FrameBox      20
#define Helpbutton    21
#define CircleButton  22
#define TripleButton  23

#define TitleText    127 /* Titetext eines Dialogs */
#define Invisible    126 /* "unsichtbares" Objekt */
#define SliderBox    125 /* Grundobjekt eines Sliders */
#define DropCircle   124
#define DropBox      123 /* Dropbox-Objekt */
#define ListBox      122 /* Listbox-Objekt */
#define SpecBox      121 /* GBox, mit Spezialeffekten */
#define SpecBoxchar  120 /* GBoxchar, Zeichen als Shortkey */
#define TimerObjc    119 /* G_STRING, enhÑlt das Timerintervall */


/*------------------------------------------------------------------------*
 * Verwaltung der zusÑtzlich benîtigten Informationen                     *
 
*------------------------------------------------------------------------*/
#define aDefault      0UL    /* Wir tun nix                           */
#define aSelect       lBit0  /* SELECTED-Flag setzen                  */
#define aDeselect     lBit1  /* SELECTED-Flag lîschen                 */
#define aCheck        lBit2  /* CHECK-Flag setzen                     */
#define aUncheck      lBit3  /* CHECK-Flag lîschen                    */
#define aDisable      lBit4  /* Disable-Flag setzen                   */
#define aEnable       lBit5  /* Disable-Flag lîschen                  */
#define aTriple1      lBit6  /* Triple-Status 1 setzen                */
#define aTriple2      lBit7  /* Triple-Status 2 setzen                */
#define aTriple3      lBit8  /* Triple-Status 3 setzen                */
#define aSlider       lBit9  /* Slider-Positon setzen                 */
#define aBell         lBit10 /* Glocke ertînen lassen                 */
#define aAsterik      lBit11 /* Sternchen in Fenstertitel zeichnen    */
#define aNoAsterik    lBit12 /* Sternchen aus Fenstertitel lîschen    */
#define aDraw         lBit13 /* gemeldetes Objekt neuzeichnen         */
#define aDrawSlider   lBit14 /* Slider neu zeichnen                   */
#define aDrawChilds   lBit15 /* Objekt + Childs des Objekts zeichnen  */
#define aDrawParent   lBit16 /* Parent + Childs des Objekts zeichnen  */
#define aDrawDial     lBit17 /* Dialog vollstÑndig neu zeichnen       */
#define aDrawList     lBit18 /* Objektliste neuzeichnen               */
#define aClose        lBit19 /* Dialog beenden                        */
#define aUpdateSlider lBit20
#define aTopDialog    lBit21
#define aCallback     lBit22
#define aDelEdit      lBit23
#define aChangeEdit   lBit24
#define aDrawLbox     lBit25 /* Zeichnet die Listbox neu, deren Basisobjektnummer in 
                                extend.x des Dialparameterblocks zu finden ist      */
#define aSetCursor		lBit26 /* Setzt Cursor im Editfeld, relative Position. Das 
                                Editfeld wird in start, und die Position in pos 
                                des Dialparameterblocks erwartet. Positive Werte 
                                setzen den Cursor nach rechts, negative nach links. */
#define aKeyUsed		lBit27
#define aSelRegister	lBit28
                                    
typedef  int   tCtrlArray;

typedef enum
{
   dNormal,
   dSpecial,
   dFlydial,
   dModal,
   dNonmodal
} Dialmode;

typedef struct
{
   int         	message; /* Was ist passiert?    */
   OBJECT      	*tree;   /* Objektbaum           */
   int         	objc;    /* Welches Objekt?      */
   int         	mx, my;  /* Mausposition         */
   tKey        	key;     /* Tastencode           */
   char        	asc;     /* Ascii-Code           */
   BITSET      	mstate;
   BITSET       kstate; 
   GRECT       	spec;    /* Special-Parameter    */
   int         	start;   /* Edit-Element         */
   int         	pos;     /* Edit-Position        */
   LONGBITSET  	action;  /* Was ist noch zu tun? */
   tCtrlArray  	*list;   /* Zeiger auf Integer-Array */
   void        	*res;
     
   /* Folgende Werte werden ab Magic 4 Revision 5 eingetragen */
   int          window;  /* Fensterkennung des Dialogs */
   int          open;    /* > 0 Dialog ist geoeffnet */
   Dialmode     mode;    /* Modus, in dem er geoffnet wurde */
   
   /* Folgende Werte werden ab Magic 4 Revison 19 eingetragen */
   GRECT        extend;     /* erweiterte Paramter */
   LONGBITSET   moreaction; /* ZusÑtzliche éggdschn-Bits */
} DialParameter;

typedef DialParameter* PtrDialpara;

typedef void (*DialHandler)(PtrDialpara);

#define dDefault      0UL     /* Nix besonderes                  */
#define dPos          lBit0   /* Dialog positionieren            */
#define dAllkeys      lBit1   /* Alle Tasten im Editfeld melden  */
#define dMouse        lBit2   /* Mausbewegung melden             */
#define dLeaveOut     lBit3   /* abbrechen, wenn ausserhalb      */
#define dButton       lBit4   /* Ok/Abbruch Mechanik             */
#define dUpArrow      lBit5   /* Pfeil-Oben in Fenster aufnehmen */
#define dDownArrow    lBit6   /* Pfeil-Unten aufnehmen           */
#define dVSlider      lBit7   /* Vertikalen Slider aufnehmen     */
#define dLeftArrow    lBit8   /* Pfeil-Links aufnehmen           */
#define dRightArrow   lBit9   /* Pfeil-Rechts aufnehmen          */
#define dHSlider      lBit10  /* Horizontalen Slider aufnehmen   */
#define dFuller       lBit11  /* Fenster-Fuller aufnehmen        */
#define dInfo         lBit12  /* Infozeile aufnehmen             */
#define dSizer        lBit13  /* Fenster-Sizer aufnehmen         */
#define dIconifier    lBit14
#define dCenter       lBit15  /* Dialog zwangsweise zentrieren   */
#define dWintop       lBit16
#define dForceWindow  lBit17  /* Dialog muss ins Fenster         */
#define dWinKeys      lBit18
#define dBackclick    lBit19
#define dShadow       lBit20  /* Fuller 'shadowed' das Fenster   */
#define dBackColor    lBit21  /* öbernimmt die Hintergrundfarbe des
                               * Dialogs in den Hintergrund eines 
                               * iconfied Fensters.
                               */ 
#define	dIconTitle		lBit22
#define	dIconOpen		lBit23

#define CSCREEN       0
#define CMOUSE        1
#define CPOS          2

typedef enum
{
   TriState1,  /* leere Box    */
   TriState2,  /* angekreuzt   */
   TriState3,  /* grau gefÅllt */
   TriError    /* Fehler!      */
} TripleState;

typedef enum
{
   Select,
   Check,
   SelectMulti,
   CheckMulti,   
   Disable, 
   Enable,
   Nonsel,
   Reverse
} ListboxMode;

typedef enum
{
   Exact,
   Wild,
   Similar,
   AutoLoc
} FindLbMode;

int OpenDial(OBJECT *tree,Dialmode mode,LONGBITSET flags,int edit,int edpos,int ok,
              int cancel,int xpos,int ypos,char *name);
void CloseDial(OBJECT *tree);
void DialInfo(OBJECT *tree,Dialmode *mode,int *win,BOOLEAN *open);
BOOLEAN NewDial(OBJECT *tree,DialHandler handler);
void DisposeDial(OBJECT *tree);
void ObjcExtype(OBJECT *tree,int entry,int extyp);
void GetObjcExtype(OBJECT *tree,int entry,int *extyp,int *typ);
void SetUserkey(OBJECT *tree,int objc,tKey key,BOOLEAN action,BOOLEAN doset);
void ResetUserkeys(OBJECT *tree);
void UserValids(OBJECT *tree,char *str);
void DialCenter(OBJECT *tree,int flag,int xx,int yy,GRECT *rect);
void DialDraw(OBJECT *tree,int entry,int depth,GRECT *clip);
void DialChange(OBJECT *tree,int entry,int state,GRECT *clip,BOOLEAN doset,BOOLEAN draw);
void DisableDialog(OBJECT *tree);
void EnableDialog(OBJECT *tree);
TripleState GetTriple(OBJECT *tree,int entry);
void SetTriple(OBJECT *tree,int entry,TripleState state);
void GetSlider(OBJECT *tree,int entry,int *spos,int *ssize);
void SetSlider(OBJECT *tree,int entry,int spos,int ssize);
tKey DrawString(GRECT *r,int mode,int col,int bcol,int brast,int ftyp,int fid,int fsize,
                char *s,BITSET flags,BOOLEAN center,BOOLEAN middle,BOOLEAN del);
void Rect(GRECT *r,int color,int fill);
void Frame(GRECT *r,int color,int thick);
void Shadow(GRECT *r,int thick);
void Line(int x,int y,int w,int h,int color);
void FreeListbox(OBJECT *tree,int item);
BOOLEAN AddEntry(OBJECT *tree,int item,BITSET state,void *data,char *entry);
BOOLEAN DelEntry(OBJECT *tree,int item,int num);
int FindEntry(OBJECT *tree,int item,int start,char *entry);
void GetEntry(OBJECT *tree,int item,int num,void **data,char *entry);
int ActEntry(OBJECT *tree,int item);
int MaxEntry(OBJECT *tree,int item);
void RedrawListbox(OBJECT *tree,int item,int start);
void SetListboxMode(OBJECT *tree,int item,ListboxMode mode);
int FindSelected(OBJECT *tree,int item,int start);
int FindChecked (OBJECT *tree,int item,int start);
void SelectMatching (OBJECT *tree,int item,int start,char *entry,int state,
                     BOOLEAN sel,BOOLEAN first);
void SelectAll(OBJECT *tree,int item,int start,int state,BOOLEAN sel);
void SetDropboxElement(OBJECT *tree,int item,int entry,BOOLEAN draw);
void SelectEntry(OBJECT *tree,int item,int entry,int state,BOOLEAN sel);
void DropNext(OBJECT *tree,int item);
BOOLEAN InsertEntry(OBJECT *tree,int item,int pos,BITSET state,void *data,char *entry);
BOOLEAN ChangeEntry(OBJECT *tree,int item,int pos,BITSET state,void *data,char *entry);
void EnableDropbox(OBJECT *tree,int item,BOOLEAN draw);
void DisableDropbox(OBJECT *tree,int item,BOOLEAN draw);
void Frame2(GRECT *r, int color1, int color2, int thick);

#define  DisposeDials() CallMagic(1101)

void DropEntry(OBJECT *tree,int item,int dir);
void SelectMatchPtr(OBJECT *tree,int item,int start,void *data,int state,BOOLEAN sel,BOOLEAN first);
int FindExact(OBJECT *tree,int item,int start,char *entry);
int GetEntryState(OBJECT *tree,int item,int num);
BOOLEAN AddData(OBJECT *tree,int item,BITSET state,void *data,int size,char *entry);
BOOLEAN InsertData(OBJECT *tree,int item,int pos,BITSET state,void *data,int size,char *entry);
BOOLEAN ChangeData(OBJECT *tree,int item,int pos,BITSET state,void *data,int size,char *entry);
int FindListbox(OBJECT *tree,int item,int start,int percent,FindLbMode mode,char *entry);
long CountState(void *tree, int item, BITSET state);
void SetEdit(void *tree, int item, int size, char valid);
void SetEditpos(void *tree, int pos, BOOLEAN *redraw);
int GetEditpos(void *tree);
void SetEntryState(void *tree, int item, int entry, BITSET b);
int FindEntryPtr(void *tree, int item, int start, void *data);
void SelectRegister(OBJECT *tree,int item);

#endif