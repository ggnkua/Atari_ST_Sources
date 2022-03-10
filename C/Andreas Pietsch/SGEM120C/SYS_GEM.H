/* ------------------------------------------------------------------- *
 * Module Version       : 1.20                                         *
 * Module Date          : 21-05-94                                     *
 * Last Change          : 21-05-94                                     *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#ifndef __sysgem__
#define __sysgem__

/* ------------------------------------------------------------------- */

#define SYSGEM_VERSION  0x0120  /* Version 1.20                        */

/* ------------------------------------------------------------------- */

#define USE_RECT        1       /* RECT-Struktur von SysGem nutzen?    */
#define USE_COOKIE      1       /* Cookie-Struktur einbinden?          */
#define OLD_SYSGEM      0

/* ------------------------------------------------------------------- */

#ifndef __PORTAB__
#include <portab.h>
#endif
#ifndef __AES__
#include <aes.h>
#endif
#ifndef __VDI__
#include <vdi.h>
#endif
#ifndef __STDARG
#include <stdarg.h>
#endif

/* ------------------------------------------------------------------- */

#define SPECIAL_MOVER   17
#define SPECIAL_BUTTON  18
#define SPECIAL_TEXT    19
#define SPECIAL_FRAME   20
#define SPECIAL_SCUT    21

/* ------------------------------------------------------------------- */

#ifndef WHITEBAK
#define WHITEBAK        64
#endif
#ifndef DRAW3D
#define DRAW3D          128
#endif
#ifndef SMALLER
#define SMALLER         0x4000
#endif

/* -------------------------------------------------------------------
 * RECT-Struktur
 * ------------------------------------------------------------------- */

#if USE_RECT
typedef struct
  {
    INT         x;
    INT         y;
    INT         w;
    INT         h;
  } RECT;
#else
#define RECT    GRECT
#endif

/* -------------------------------------------------------------------
 * Cookie-Struktur
 * ------------------------------------------------------------------- */

#if USE_COOKIE
typedef struct
  {
    LONG        id;
    LONG        value;
  } COOKIE;
#endif

/* -------------------------------------------------------------------
 * Parameter - RÅckgabe von Init_GEM
 * ------------------------------------------------------------------- */

typedef struct
  {
    INT         vdi_handle;
    INT         charw;
    INT         charh;
    INT         boxw;
    INT         boxh;
    INT         appl_id;
    INT         xmax;
    INT         ymax;
    RECT        desktop;
    INT         bitplanes;
    INT         max_colors;
    INT         act_colors;
    BOOL        color_avail;
    INT         acc_entry;
    BOOL        multitask;
    INT         aes_version;
    UINT        tos_version;
    INT         magx;
    INT         magx_rel;               /* fÅr Thorsten ;-)            */
    INT         mint;
    BOOL        winx;
    BOOL        search;
    INT         agi;
    BOOL        draw_3d;
  } PARAMETER;

/* -------------------------------------------------------------------
 * Area - Fuer Bildschirmbereiche
 * ------------------------------------------------------------------- */

typedef struct
  {
    BOOL        init;
    INT         x;
    INT         y;
    INT         w;
    INT         h;
    ULONG       size;
    MFDB        mf;
  } AREA;

/* -------------------------------------------------------------------
 * Dragdrop-Nachricht
 * ------------------------------------------------------------------- */

typedef struct
  {
    BOOL        gemini;         /* D&D von Gemini?                     */
    LONG        data_type;      /* Typ-Id von Mint                     */
    BYTE        *data;          /* Adresse der Daten fÅr D&D bei Gemini*/
    LONG        data_len;       /* LÑnge von *data in Byte             */
    BYTE        data_id  [128]; /* Klassifizierung                     */
    BYTE        filename [128]; /* So wenn MiNT will...                */
    INT         x;              /* X-Position der Maus                 */
    INT         y;              /* Y-Position der Maus                 */
    INT         state;          /* Status der Sondertasten             */
    INT         obj;            /* Object innerhalb des Baumes         */
    LONG        id;             /* Baum innerhalb des Fensters         */
  } DRAG_DROP;

/* -------------------------------------------------------------------
 * DialogInfo - FÅr die Dialogboxen
 * ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    VOID        *user;
    UINT        special;
    DRAG_DROP   *dd;
  } DIALOG_INFO;

/* -------------------------------------------------------------------
 * WindowInfo - FÅr die Fensterroutinen
 * ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    LONG        pos_x;
    LONG        pos_y;
    LONG        doc_x;
    LONG        doc_y;
    INT         scroll;
    INT         handle;
    INT         key;
    INT         state;
    INT         mTitle;
    INT         mItem;
    INT         mx, my;
    LONG        line;
    LONG        column;
    BYTE        *line_ptr;
    RECT        work_area;
    RECT        draw_area;
    RECT        clip;
    VOID        *user;
    LONG        obj_id;
    INT         item;
    DRAG_DROP   *dd;
  } WINDOW_INFO;

/* -------------------------------------------------------------------
 * Funktionen fÅr Dialoge, Redraw und Auswertung
 * ------------------------------------------------------------------- */

typedef INT     (*DPROC)(INT msg, INT button, DIALOG_INFO *inf );
typedef INT     (*APROC)(INT msg, WINDOW_INFO *inf );
typedef VOID    (*RPROC)(WINDOW_INFO *inf );
typedef VOID    (*TPROC)(VOID);
typedef LONG    (*MPROC)(BYTE msg, BYTE sub, LONG l1, LONG l2);
typedef INT     (*FPROC)(OBJECT *tree, INT ed, LONG id );
typedef INT     (*CPROC)(BYTE *str1, BYTE *str2 );

/* -------------------------------------------------------------------
 * Nachrichten von SysGem an eine Auswertungs-Funktion
 * ------------------------------------------------------------------- */

#define SG_START        0
#define SG_END          1
#define SG_QUIT         2
#define SG_DRAW         3
#define SG_POSX         4
#define SG_POSY         5
#define SG_VISIBLE      6
#define SG_INVISIBLE    7
#define SG_TOP          8
#define SG_UNTOP        9
#define SG_SIZED        10
#define SG_LCLICK1      11
#define SG_LCLICK2      12
#define SG_RCLICK1      13
#define SG_RCLICK2      14
#define SG_BUTTON       15
#define SG_KEY          16
#define SG_MENU         17
#define SG_NOWIN        18
#define SG_DRAGDROP     19
#define SG_MOVED        20
#define SG_SLID_UP      21
#define SG_SLID_DN      22
#define SG_SLID_MV      23
#define SG_SLID_PGUP    24
#define SG_SLID_PGDN    25

/* -------------------------------------------------------------------
 * Nachrichten von Auswertungs-Funktion an SysGem
 * ------------------------------------------------------------------- */

#define SG_CLOSE        0
#define SG_REDRAW       1
#define SG_TERM         2
#define SG_CONT         3
#define SG_ABORT        4
#define SG_KEYUSED      5
#define SG_KEYCONT      6

/* -------------------------------------------------------------------
 * Spezial-Flags fÅr die Auswertungsfunktion
 * ------------------------------------------------------------------- */

#define SG_RIGHTCLICK   (1U << 0)
#define SG_DOUBLECLICK  (1U << 1)

/* -------------------------------------------------------------------
 * Werte fÅr agi aus Parameter
 * ------------------------------------------------------------------- */

#define AGI_0           0
#define AGI_3           1
#define AGI_4           2

/* -------------------------------------------------------------------
 * PrioritÑten fÅr die Alert-Box
 * ------------------------------------------------------------------- */

#define ALERT_NORM      1
#define ALERT_STOP      3

/* -------------------------------------------------------------------
 * Flags fuer Baeume im Fenster
 * ------------------------------------------------------------------- */

#define LINK_LEFT       0
#define LINK_RIGHT      1
#define LINK_TOP        2
#define LINK_BOTTOM     3

/* -------------------------------------------------------------------
 * Button-Anordnung fÅr Alert
 * ------------------------------------------------------------------- */

#define ButtonCenter    0
#define ButtonLeft      1
#define ButtonRight     2

/* -------------------------------------------------------------------
 * Stati fÅr RedrawObj
 * ------------------------------------------------------------------- */

#define FLIP_STATE      0
#define DEL_STATE       1
#define SET_STATE       2
#define UPD_STATE       3

/* -------------------------------------------------------------------
 * Stati fÅr Scroll-Funktionen
 * ------------------------------------------------------------------- */

#define SCROLL_UP       1
#define SCROLL_DOWN     2
#define SCROLL_RIGHT    3
#define SCROLL_LEFT     4
#define SCROLL_PG_LEFT  5
#define SCROLL_PG_RIGHT 6
#define SCROLL_PG_UP    7
#define SCROLL_PG_DOWN  8

/* -------------------------------------------------------------------
 * Stati fÅr SetWindowParm
 * ------------------------------------------------------------------- */

#define SET_X           1
#define SET_Y           2
#define SET_W           3
#define SET_H           4

/* -------------------------------------------------------------------
 * Nachrichten
 * ------------------------------------------------------------------- */

#define MSG_TERM        1
#define MSG_OPEN        2
#define MSG_CLOSE       3
#define MSG_USER        4
#define MSG_SYSTEM      5
#define MSG_NEW         6
#define MSG_QUIT        7

/* -------------------------------------------------------------------
 * Maus-Funktionen
 * ------------------------------------------------------------------- */

#define ShowArrow()        graf_mouse ( ARROW,       NULL )
#define ShowBee()          graf_mouse ( BUSYBEE,     NULL )
#define ShowHour()         graf_mouse ( HOURGLASS,   NULL )
#define ShowFinger()       graf_mouse ( POINT_HAND,  NULL )
#define ShowHand()         graf_mouse ( FLAT_HAND,   NULL )
#define ShowThinCross()    graf_mouse ( THIN_CROSS,  NULL )
#define ShowThickCross()   graf_mouse ( THICK_CROSS, NULL )
#define ShowOutlineCross() graf_mouse ( OUTLN_CROSS, NULL )
#define ShowMouse()        graf_mouse ( M_ON,        NULL )
#define HideMouse()        graf_mouse ( M_OFF,       NULL )

/* -------------------------------------------------------------------
 * Objekt-Manipulation
 * ------------------------------------------------------------------- */

#define SetState(x,y,z)       x [y].ob_state |= z
#define DelState(x,y,z)       x [y].ob_state &= ~z
#define GetState(x,y,z)       (( x [y].ob_state & z ) != 0 )
#define SetFlags(x,y,z)       x [y].ob_flags |= z
#define DelFlags(x,y,z)       x [y].ob_flags &= ~z
#define GetFlags(x,y,z)       (( x [y].ob_flags & z ) != 0 )
#define SetGlobalState(x,y,z) x [y].ob_state  = z
#define SetGlobalFlags(x,y,z) x [y].ob_flags  = z

/* -------------------------------------------------------------------
 * An- und Abmelden
 * ------------------------------------------------------------------- */

INT     Init_GEM        ( PARAMETER *par, BYTE *acc, LONG prg_id, BYTE *prg_name, LONG usr_id, BYTE *usr_name, LONG key );
VOID    Exit_GEM        ( VOID );
VOID    SetAccProc      ( TPROC a_open, TPROC a_close );

/* -------------------------------------------------------------------
 * Abfrageroutinen
 * ------------------------------------------------------------------- */

INT     appl_geti       ( INT ap_gtype, INT *ap_gout1, INT *ap_gout2, INT *ap_gout3, INT *ap_gout4 );
INT     objc_sysv       ( INT ob_smode, INT ob_swhich, INT ob_sival1, INT ob_sival2, INT *ob_soval1, INT *ob_soval2 );

#define appl_getinfo    appl_geti
#define objc_sysvar     objc_sysv

ULONG   magx_avail      ( VOID );
UINT    mint_avail      ( VOID );
BOOL    winx_avail      ( VOID );
BOOL    has_search      ( VOID );

VOID    CalcArea        ( OBJECT *tree, INT obj, RECT *r );
INT     objc_frame      ( OBJECT *tree, INT entry );

/* -------------------------------------------------------------------
 * Resourcen
 * ------------------------------------------------------------------- */

UINT    LoadResource    ( BYTE *rsc_name );
OBJECT  *RscAdr         ( INT tree_type, INT index );
VOID    RscFree         ( VOID );

/* -------------------------------------------------------------------
 * Menuezeile
 * ------------------------------------------------------------------- */

BOOL    SetDeskTopMenu  ( OBJECT *menu, APROC action );
VOID    RemDeskTopMenu  ( VOID );
VOID    SelectMenu      ( INT item, BOOL invert );
BOOL    SetDeskTop      ( OBJECT *tree, INT first, APROC action );
VOID    RemoveDeskTop   ( VOID );

/* -------------------------------------------------------------------
 * Einstellungen
 * ------------------------------------------------------------------- */

VOID    UseRightButton  ( BOOL use );
VOID    TellKeyStrokes  ( BOOL tell );
VOID    SetReturn       ( BOOL like_sysgem );
VOID    UseHighButtons  ( BOOL use_high );
VOID    SetButton       ( INT just );
VOID    FrameTextColor  ( INT color );
VOID    DialPosXY       ( BOOL center );
INT     SetIconColor    ( INT color );
VOID    LinkImage       ( LONG win_id, BITBLK *image, BYTE *text );
VOID    SetFieldProc    ( FPROC proc );
VOID    ShortCutColor   ( INT color );
VOID    SetAlertTitle   ( BYTE *string );

/* -------------------------------------------------------------------
 * Cookies
 * ------------------------------------------------------------------- */

BOOL    RemoveCookie    ( LONG id );
BOOL    SetCookie       ( LONG id, LONG value );
BOOL    GetCookie       ( LONG id, LONG *value );

/* -------------------------------------------------------------------
 * Texte im Fenster
 * ------------------------------------------------------------------- */

BYTE    *LinkList       ( LONG win_id, BYTE *text );
BYTE    *AddToList      ( LONG win_id, BYTE *text );
BYTE    *ChgInList      ( LONG win_id, UINT line, BYTE *text );
BOOL    DelInList       ( LONG win_id, UINT line );
UINT    CountLines      ( LONG win_id );
UINT    Display         ( BYTE *fname, BYTE *wname, BYTE *winfo, INT len, LONG win_id, INT x, INT y, INT w, INT h, APROC action );
INT     cmp_strings_up  ( BYTE *str1, BYTE *str2 );
INT     cmp_strings_dn  ( BYTE *str1, BYTE *str2 );
VOID    do_qsort        ( LONG win_id, CPROC compare );

/* -------------------------------------------------------------------
 * Popup's
 * ------------------------------------------------------------------- */

INT     PopUp           ( OBJECT *tree, INT x, INT y, INT start, INT first );
INT     xPopUp          ( OBJECT *tree, INT obj, OBJECT *tree2, INT start, INT *first );
INT     Cycle           ( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret );
INT     Listbox         ( BYTE *strings, INT count, INT len, OBJECT *tree, INT box );

/* -------------------------------------------------------------------
 * Sliderboxen
 * ------------------------------------------------------------------- */

BOOL    LinkSlider      ( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buffer, INT len, INT format );
VOID    RedrawSliderBox ( OBJECT *tree, INT box );
VOID    ScrollSlider    ( OBJECT *tree, INT box, INT what );
BOOL    AddSliderItem   ( OBJECT *tree, INT box, INT anz_items );
INT     SetSliderPos    ( OBJECT *tree, INT box, INT pos, BOOL draw );
BOOL    UnLinkSlider    ( OBJECT *tree, INT box );

/* -------------------------------------------------------------------
 * Funktionen zum schreiben ins Fenster
 * ------------------------------------------------------------------- */

BOOL    OpenLogWindow   ( LONG win_id, BYTE *title, BYTE *info, INT columns, INT rows, INT x, INT y, APROC action );
VOID    wprintf         ( LONG win_id, BYTE *format, ... );
VOID    wcls            ( LONG win_id );
VOID    wposxy          ( LONG win_id, INT x, INT y );
VOID    wgetxy          ( LONG win_id, INT *x, INT *y );
BYTE    wgetchar        ( LONG win_id, INT x, INT y, INT *effect );
VOID    HideCursor      ( LONG win_id );
VOID    ShowCursor      ( LONG win_id );

/* -------------------------------------------------------------------
 * Fenster- und Dialoge I
 * ------------------------------------------------------------------- */

BOOL    NewDialog       ( OBJECT *tree );
VOID    DelDialog       ( OBJECT *tree );
INT     Alert           ( INT priority, INT def, BYTE *str );
INT     DoDialog        ( OBJECT *tree, INT ed, BYTE *title );
VOID    RedrawObj       ( OBJECT *tree, INT obj, INT depth, INT state, INT flag );
VOID    ShowDialog      ( OBJECT *tree );
VOID    EndDialog       ( OBJECT *tree );
INT     HandleDialog    ( OBJECT *tree, INT ed );
VOID    ChangeButton    ( OBJECT *tree, INT obj, BYTE *text, BOOL draw );
VOID    SetEditField    ( OBJECT *tree, INT field );
VOID    GetEditFields   ( OBJECT *tree, VOID (*callback)(INT obj, BYTE *s ));
VOID    ClearEditFields ( OBJECT *tree );
INT     IsMenuKey       ( OBJECT *tree, INT scan, INT state );
VOID    SetWinMinSize   ( LONG win_id, INT w, INT h );
VOID    SetWinMaxSize   ( LONG win_id, INT w, INT h );
BOOL    IsVisible       ( INT handle );

/* -------------------------------------------------------------------
 * Fenster- und Dialoge II
 * ------------------------------------------------------------------- */

INT  WindowDialog ( LONG        id,
                    INT         xpos,
                    INT         ypos,
                    BYTE        *name,
                    BYTE        *info,
                    BOOL        shut,
                    BOOL        force,
                    OBJECT      *tree,
                    OBJECT      *menu,
                    INT         edit,
                    VOID        *user,
                    DPROC       proc );

INT OpenWindow ( LONG   id,
                 BYTE   *name,
                 BYTE   *info,
                 INT    flags,
                 OBJECT *menu,
                 INT    align,
                 BOOL   part_redraw,
                 INT    scroll_x,
                 INT    scroll_y,
                 LONG   doc_x,
                 LONG   doc_y,
                 INT    x,
                 INT    y,
                 INT    w,
                 INT    h,
                 VOID   *user,
                 RPROC  redraw,
                 APROC  action );

/* -------------------------------------------------------------------
 * Fensterroutinen
 * ------------------------------------------------------------------- */

VOID    CloseAllWindows ( VOID );
VOID    RectIntersect   ( RECT *r1, RECT *r2 );
VOID    SetWindowName   ( INT handle, BYTE *name );
VOID    SetWindowInfo   ( INT handle, BYTE *info );
LONG    GetWindowId     ( INT handle );
INT     GetTopWindow    ( VOID );
LONG    GetTopWindowId  ( VOID );
BOOL    TopWindow       ( INT handle );
INT     GetHandle       ( LONG id );
BOOL    CloseWindow     ( INT handle );
VOID    WhiteArea       ( RECT *r );
BOOL    LinkTree        ( LONG win_id, OBJECT *tree, LONG id, INT pos );
LONG    SetWindowParm   ( INT handle, INT what, LONG value );
VOID    ScrollWindow    ( INT handle, INT what );
VOID    RedrawArea      ( INT handle, RECT *r );
VOID    RedrawWindow    ( INT handle );
VOID    RedrawDialog    ( OBJECT *tree );

/* -------------------------------------------------------------------
 * Verwaltung
 * ------------------------------------------------------------------- */

INT     HandleSysGem    ( VOID );
VOID    TerminateSysGem ( VOID );
VOID    SetMessageProc  ( MPROC proc );
INT     ProgramExist    ( LONG id );
VOID    SendSgMsg       ( INT msg, INT sub, LONG dest, LONG parm );
INT     SendMsg         ( LONG dest, INT msg, INT sub, LONG parm, INT timeout, LONG *result );

/* -------------------------------------------------------------------
 * Timer-Verwaltung
 * ------------------------------------------------------------------- */

VOID    SetProcTimer    ( TPROC p );
VOID    SetTimer        ( INT ms_low, INT ms_high );

/* -------------------------------------------------------------------
 * Bildschirmroutinen
 * ------------------------------------------------------------------- */

BOOL    NewArea         ( AREA *p );
VOID    FreeArea        ( AREA *p );
VOID    ClearArea       ( AREA *p );
VOID    CopyArea        ( INT handle, AREA *p, INT x, INT y );
BOOL    SaveArea        ( INT handle, AREA *p, RECT *r );
VOID    RestoreArea     ( INT handle, AREA *p );
VOID    MoveScreen      ( INT handle, RECT *r, INT x, INT y );

/* -------------------------------------------------------------------
 * Textfunktionen
 * ------------------------------------------------------------------- */

BYTE   *GetText         ( OBJECT *tree, INT index, BYTE *text );
VOID    SetText         ( OBJECT *tree, INT index, BYTE *text );

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */
