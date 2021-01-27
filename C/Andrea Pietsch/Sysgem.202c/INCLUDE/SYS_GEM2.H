/* ------------------------------------------------------------------- *
 * Module Version       : 2.03                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994/95, Andrea Pietsch, 56727 Mayen     *
 * ------------------------------------------------------------------- */

#ifndef __sysgem__
#define __sysgem__

/* ------------------------------------------------------------------- */

#ifndef __PORTAB__
#include        <portab.h>
#endif
#ifndef __STDIO
#include        <stdio.h>
#endif
#ifndef __AES__
#include        <aes.h>
#endif
#ifndef __VDI__
#include        <vdi.h>
#endif

/* -------------------------------------------------------------------
 * Farbicons
 * ------------------------------------------------------------------- */

#ifndef G_CICON

/* ------------------------------------------------------------------- */

typedef struct _cic
  {
    INT         num_planes;
    INT         *col_data;
    INT         *col_mask;
    INT         *sel_data;
    INT         *sel_mask;
    struct _cic *next_res;
  } CICON;

/* ------------------------------------------------------------------- */

typedef struct
  {
    ICONBLK     monoblk;
    CICON       *mainlist;
  } CICONBLK;

/* ------------------------------------------------------------------- */

#define G_CICON         33

/* ------------------------------------------------------------------- */

#endif

/* -------------------------------------------------------------------
 * RECT - Zur Beschreibung von Rechtecken
 * ------------------------------------------------------------------- */

typedef struct
  {
    INT         x;
    INT         y;
    INT         w;
    INT         h;
  } RECT;

/* -------------------------------------------------------------------
 * Cookie-Strukur
 * ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    LONG        value;
  } COOKIE;

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
    LONG        size;
    MFDB        mf;
  } AREA;

/* -------------------------------------------------------------------
 * Parameter-Struktur
 * ------------------------------------------------------------------- */

#define PAR_HANDLE      0
#define PAR_CHARW       1
#define PAR_CHARH       2
#define PAR_BOXW        3
#define PAR_BOXH        4
#define PAR_APPLID      5
#define PAR_XMAX        6
#define PAR_YMAX        7
#define PAR_DESKX       8
#define PAR_DESKY       9
#define PAR_DESKW       10
#define PAR_DESKH       11
#define PAR_BITPLANES   12
#define PAR_MAXCOLOR    13
#define PAR_ACTCOLOR    14
#define PAR_COLOR       15
#define PAR_ACCENTRY    16
#define PAR_MULTI       17
#define PAR_VAES        18
#define PAR_VTOS        19
#define PAR_VMAGX       20
#define PAR_RMAGX       21
#define PAR_MINT        22
#define PAR_WINX        23
#define PAR_SEARCH      24
#define PAR_AGI         25
#define PAR_ICFS        26
#define PAR_BACKCOL     27
#define PAR_ACTICOL     28
#define PAR_SYSPT       29

/* ------------------------------------------------------------------- */

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
    INT         magx_rel;
    INT         mint;
    BOOL        winx;
    BOOL        search;
    INT         agi;
    INT         icfs;
  } PARAMETER;

/* -------------------------------------------------------------------
 * Dragdrop-Nachricht
 * ------------------------------------------------------------------- */

typedef struct
  {
    BOOL        gemini;
    LONG        data_type;
    BYTE        *data;
    LONG        data_len;
    BYTE        data_id  [128];
    BYTE        filename [128];
    INT         x;
    INT         y;
    INT         state;
    INT         obj;
    LONG        id;
  } DRAG_DROP;

/* -------------------------------------------------------------------
 * DialogInfo - FÅr die Dialogboxen
 * ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    VOID        *user;
    DRAG_DROP   *dd;
    LONG        denied;
    OBJECT      *tree;
    INT         kstate;
    INT         edit_field;
    INT         box;
    RECT        clip;
    VOID        *user2;
  } DIALOG_INFO;

/* -------------------------------------------------------------------
 * Window-Info
 * ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    INT         handle;
    LONG        pos_x;
    LONG        pos_y;
    LONG        doc_x;
    LONG        doc_y;
    INT         key;
    INT         state;
    INT         mTitle;
    INT         mItem;
    INT         mx, my;
    LONG        line;
    LONG        column;
    BYTE        *line_ptr;
    VOID        *line_user;
    RECT        work_area;
    RECT        draw_area;
    RECT        clip;
    VOID        *user;
    OBJECT      *tree;
    LONG        obj_id;
    INT         item;
    INT         box;
    DRAG_DROP   *dd;
    LONG        denied;
    VOID        *user2;
  } WINDOW_INFO;

/* -------------------------------------------------------------------
 * Sliderbox
 * ------------------------------------------------------------------- */

typedef struct
  {
    INT         pos;
    INT         just;
  } TABULAR;

/* ------------------------------------------------------------------- */

typedef struct
  {
    OBJECT      *tree;
    BYTE        *buffer;
    TABULAR     *tab;
    RECT        area;
    RECT        clip;
    INT         len;
    INT         box;
    INT         line;
    INT         hpos;
    BYTE        *text;
    BOOL        selected;
    BOOL        changed;
    BOOL        drawn;
  } SLD_ENTRY;

/* -------------------------------------------------------------------
 * Identifizierungs-Struktur eines Moduls
 * ------------------------------------------------------------------- */

typedef struct
  {
    BYTE        *name;
    BYTE        *author;
  } IDENTIFY;

/* -------------------------------------------------------------------
 * Funktions-Definitionen
 * ------------------------------------------------------------------- */

typedef INT     ( *MPROC )( INT item );
typedef INT     ( *APROC )( INT msg, WINDOW_INFO *inf );
typedef INT     ( *DPROC )( INT msg, INT button, DIALOG_INFO *inf );
typedef VOID    ( *RPROC )( WINDOW_INFO *inf );
typedef VOID    ( *TPROC )( VOID );
typedef LONG    ( *PPROC )( LONG id, RECT *r );
typedef VOID    ( *IPROC )( LONG id, RECT *r );
typedef INT     ( *VPROC )( BYTE *s1, BYTE *s2 );
typedef INT     ( *XPROC )( BYTE *s1, VOID *user1, BYTE *s2, VOID *user2 );
typedef VOID    ( *SPROC )( SLD_ENTRY *entry );
typedef VOID    ( *UPROC )( INT *msg );

/* -------------------------------------------------------------------
 * Erweiterte Fenster-Struktur
 * ------------------------------------------------------------------- */

#define WIN_FORCE       (1 <<  0)
#define WIN_PAINT       (1 <<  1)

/* ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    OBJECT      *tree;
    INT         pos;
    INT         start;
    INT         depth;
    INT         edit;
  } XTREE;

/* ------------------------------------------------------------------- */

typedef struct
  {
    LONG        id;
    LONG        owner;
    INT         flags;
    UINT        cfg;
    RECT        work;
    BYTE        *name;
    BYTE        *info;
    VOID        *user;
    INT         align_x;
    INT         align_y;
    INT         scr_x;
    INT         scr_y;
    INT         font_id;
    INT         font_pt;
    INT         min_w;
    INT         min_h;
    INT         max_w;
    INT         max_h;
    INT         back;
    INT         anz_trees;
    XTREE       *trees;
    OBJECT      *menu;
    OBJECT      *md;
    LONG        doc_w;
    LONG        doc_h;
    RPROC       redraw;
    APROC       waction;
    DPROC       daction;
  } XWIN;

/* -------------------------------------------------------------------
 * Werte fÅr agi aus Parameter
 * ------------------------------------------------------------------- */

#define AGI_0           0
#define AGI_3           1
#define AGI_4           2

/* -------------------------------------------------------------------
 * Werte fÅr die Alertbox
 * ------------------------------------------------------------------- */

#define ALERT_NORM      0
#define ALERT_STOP      1

#define ButtonCenter    0
#define ButtonLeft      1
#define ButtonRight     2

/* -------------------------------------------------------------------
 * Flags fuer Baeume im Fenster
 * ------------------------------------------------------------------- */

#define LINK_TOP        1
#define LINK_LEFT       2
#define LINK_RIGHT      3
#define LINK_BOTTOM     4

/* -------------------------------------------------------------------
 * Nachrichten von SysGem an eine Auswertungs-Funktion
 * ------------------------------------------------------------------- */

#define SG_OPENICONIFIED 0
#define SG_START         1
#define SG_NOWIN         2
#define SG_END           3
#define SG_END2          4
#define SG_REND          5
#define SG_REND2         6
#define SG_QUIT          7
#define SG_TIMER         8
#define SG_FTIMER        9
#define SG_POSX         10
#define SG_POSY         11
#define SG_VISIBLE      12
#define SG_INVISIBLE    13
#define SG_TOP          14
#define SG_UNTOP        15
#define SG_SIZED        16
#define SG_FULLED       17
#define SG_MOVED        18
#define SG_LCLICK1      19
#define SG_LCLICK2      20
#define SG_BUTTON       21
#define SG_BUTTON2      22
#define SG_RBUTTON      23
#define SG_RBUTTON2     24
#define SG_KEY          25
#define SG_EDKEY        26
#define SG_EDCHANGED    27
#define SG_MENU         28
#define SG_DRAGDROP     29
#define SG_HELP         30
#define SG_UNDO         31
#define SG_EXCEPTION    32
#define SG_TERMDENIED   33
#define SG_DRAWOWN      34
#define SG_SLIDER       35
#define SG_SLIDER2      36
#define SG_RSLIDER      37
#define SG_RSLIDER2     38
#define SG_3DSTATE      39
#define SG_CLIPBOARD    40
#define SG_CHILDEXIT    41
#define SG_SELECT       42
#define SG_DESELECT     43
#define SG_RADIO        44
#define SG_NEXTSTART    45
#define SG_NEWDIAL      46
#define SG_NEWFONT      47
#define SG_EDREDRAW     48
#define SG_LCIRCLE      49
#define SG_RCIRCLE      50
#define SG_RCLICK1      51
#define SG_RCLICK2      52
#define SG_TOUCH        53
#define SG_EMPTYSLDLINE 54
#define SG_LASTEDIT     55
#define SG_EDITABLE     56
#define SG_BEGINHELP    57
#define SG_ENDHELP      58
#define SG_POSITION     59
#define SG_SLDNEWPOS1   60
#define SG_SLDNEWPOS2   61

/* -------------------------------------------------------------------
 * Spezielle Nachrichten an die Module
 * ------------------------------------------------------------------- */

#define SGM_IDENTIFY    70
#define SGM_INIT        71
#define SGM_START       72
#define SGM_QUIT        73
#define SGM_USER        74

/* -------------------------------------------------------------------
 * Nachrichten von Auswertungs-Funktion(en) an SysGem
 * ------------------------------------------------------------------- */

#define SG_CLOSE        80
#define SG_REDRAW       81
#define SG_REDRAWALL    82
#define SG_TERM         83
#define SG_CONT         84
#define SG_ABORT        85
#define SG_KEYUSED      86
#define SG_KEYCONT      87
#define SG_CALL         88
#define SG_PIPE         89
#define SG_SELECTED     90
#define SG_TAKEKEY      91
#define SG_TAKEDIAL     92
#define SG_CALLUPD      93
#define SG_ICONIFY      94

/* -------------------------------------------------------------------
 * Werte fÅr 'SetTab'-Funktionen
 * ------------------------------------------------------------------- */

#define TAB_LEFT        0
#define TAB_RIGHT       1
#define TAB_CENTER      2
#define TAB_DECIMAL     3

/* -------------------------------------------------------------------
 * Werte von TerminateSysGem
 * ------------------------------------------------------------------- */

#define TERM_OK           0
#define TERM_DENIED_ACC   1
#define TERM_DENIED_SGM   2

/* -------------------------------------------------------------------
 * Werte fÅr RedrawObj
 * ------------------------------------------------------------------- */

#define SET_STATE       (1 << 0)
#define DEL_STATE       (1 << 1)
#define UPD_STATE       (1 << 2)
#define FLIP_STATE      (1 << 3)
#define TAKE_STATE      (1 << 4)
#define USER_STATE      (1 << 5)

/* -------------------------------------------------------------------
 * Stati fÅr Scroll-Funktionen
 * ------------------------------------------------------------------- */

#define SCROLL_PG_UP    0
#define SCROLL_PG_DOWN  1
#define SCROLL_UP       2
#define SCROLL_DOWN     3
#define SCROLL_PG_LEFT  4
#define SCROLL_PG_RIGHT 5
#define SCROLL_LEFT     6
#define SCROLL_RIGHT    7

/* -------------------------------------------------------------------
 * Stati fÅr SetWindowParm
 * ------------------------------------------------------------------- */

#define SET_X           1
#define SET_Y           2
#define SET_W           3
#define SET_H           4

/* ------------------------------------------------------------------- */

#define RSC_NOCICON     -1
#define RSC_LOADERR     -2
#define RSC_NOMEMORY    -3

/* ------------------------------------------------------------------- */

#define BUT_OK          1
#define BUT_ABORT       2
#define BUT_SYSTEM      4
#define BUT_HELP        8
#define BUT_ALL         ( BUT_OK | BUT_ABORT | BUT_SYSTEM | BUT_HELP )

/* ------------------------------------------------------------------- */

#ifndef __sysgem_mod__

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
 * Erweiterte Mausfunktionen
 * ------------------------------------------------------------------- */

VOID    ShowRotor       ( VOID );
VOID    UpdateRotor     ( VOID );
VOID    EndRotor        ( VOID );

VOID    ShowClock       ( VOID );
VOID    UpdateClock     ( VOID );
VOID    EndClock        ( VOID );

VOID    ShowCoffee      ( VOID );
VOID    UpdateCoffee    ( VOID );
VOID    EndCoffee       ( VOID );

VOID    ShowDisc        ( VOID );
VOID    UpdateDisc      ( VOID );
VOID    EndDisc         ( VOID );

VOID    ShowAbacus      ( VOID );
VOID    UpdateAbacus    ( VOID );
VOID    EndAbacus       ( VOID );

VOID    ShowDice        ( VOID );
VOID    UpdateDice      ( VOID );
VOID    EndDice         ( VOID );

VOID    ShowPaper       ( VOID );
VOID    UpdatePaper     ( VOID );
VOID    EndPaper        ( VOID );

/* -------------------------------------------------------------------
 * An- und Abmelden
 * ------------------------------------------------------------------- */

INT     InitGem         ( BYTE *acc, LONG prg_id, BYTE *prg_name );
VOID    ExitGem         ( VOID );
UINT    SysGemVersion   ( VOID );
BYTE    *SysGemVerStr   ( VOID );

/* ------------------------------------------------------------------- */

VOID    GetParStruct    ( PARAMETER *par );
INT     GetParam        ( INT par );

/* ------------------------------------------------------------------- */

VOID    SetKey          ( LONG l1, LONG l2 );

/* ------------------------------------------------------------------- */

VOID    SetAccProc      ( TPROC acc_open, TPROC acc_close );

BOOL    NewDialog       ( OBJECT *tree );
BOOL    DelDialog       ( OBJECT *tree );

/* ------------------------------------------------------------------- */

VOID    ClipboardChanged( VOID );

BOOL    FileSelect      ( BYTE *name, BYTE *path, BYTE *suffix, BYTE *title, BYTE *file_name );

/* -------------------------------------------------------------------
 * Einstellungen
 * ------------------------------------------------------------------- */

VOID    SetAlertTitle   ( BYTE *name );
VOID    SetProgramName  ( BYTE *name );
VOID    SetIconifyName  ( BYTE *name );
VOID    Enable3D        ( VOID );
VOID    Disable3D       ( VOID );
VOID    TellKeyStrokes  ( BOOL tell );
VOID    DialPosXY       ( BOOL center );
VOID    SetFulledX      ( INT x );
VOID    SetFulledY      ( INT y );
VOID    SetFulledW      ( INT w );
VOID    SetFulledH      ( INT h );
VOID    WaitAfterClose  ( BOOL wait );
VOID    FrameTextColor  ( INT color );
VOID    ShortCutColor   ( INT color );
VOID    LinkImage       ( LONG win_id, BITBLK *image, BYTE *text );
VOID    LinkMainImage   ( BITBLK *image, BYTE *text );
BOOL    SysGem3D        ( VOID );
VOID    UseRoundButtons ( BOOL use );
INT     SetSelColor     ( INT color );
INT     SetSelTextColor ( INT color );
VOID    SetWinBackground( LONG win_id, INT color );
VOID    UseOwnEditFields( VOID );
VOID    SetMonoEditFrame( BOOL paint );
VOID    SetReturn       ( BOOL like_sysgem );
VOID    CheckLogFont    ( BOOL check );
VOID    SetUnknownEvent ( UPROC proc );
VOID    SetLanguage     ( BOOL english );
VOID    SetLinkIconColor( LONG win_id, INT color );
VOID    SetLinkTextColor( LONG win_id, INT color );
VOID    NoEscSequence   ( LONG win_id, BOOL esc );
VOID    AllowFontChange ( BOOL change );
VOID    SendSliderPos   ( BOOL send );

/* -------------------------------------------------------------------
 * Timer-Routinen
 * ------------------------------------------------------------------- */

VOID    EnableTimer     ( VOID );
VOID    DisableTimer    ( VOID );

VOID    SetDispatchTime ( INT ms_low, INT ms_high );
VOID    SetTimer        ( INT ms_low, INT ms_high );
VOID    SetProcTimer    ( TPROC proc );

VOID    SetWindowTimer  ( LONG win_id, INT ms_low, INT ms_high );
VOID    UseFastTimer    ( LONG win_id, BOOL enable );

VOID    SetXTimer       ( LONG id, TPROC proc, INT ms_low, INT ms_high, VOID *user1, VOID *user2 );
VOID    DelXTimer       ( LONG id );

LONG    GetXTimerId     ( VOID );
VOID    *GetXTimerUser1 ( VOID );
VOID    *GetXTimerUser2 ( VOID );

/* -------------------------------------------------------------------
 * Usernachrichten
 * ------------------------------------------------------------------- */

VOID    ShowMessage     ( BYTE *text );
VOID    EndMessage      ( VOID );
VOID    ShowStatus      ( BYTE *text1, BYTE *text2, LONG p, LONG p100 );
VOID    EndStatus       ( VOID );

/* -------------------------------------------------------------------
 * Textfenster
 * ------------------------------------------------------------------- */

VOID    BeginListUpdate ( LONG win_id );
VOID    EndListUpdate   ( LONG win_id );

BYTE    *LinkList       ( LONG win_id, BYTE *text );
BYTE    *AddToList      ( LONG win_id, BYTE *text );
BYTE    *InsInList      ( LONG win_id, UINT line, BYTE *text );
BYTE    *ChgInList      ( LONG win_id, UINT line, BYTE *text );

BYTE    *xLinkList      ( LONG win_id, BYTE *text, VOID *user );
BYTE    *xAddToList     ( LONG win_id, BYTE *text, VOID *user );
BYTE    *xInsInList     ( LONG win_id, UINT line, BYTE *text, VOID *user );
BYTE    *xChgInList     ( LONG win_id, UINT line, BYTE *text, VOID *user );

BOOL    SetListTab      ( LONG win_id, INT pos, INT just );
BOOL    UpdListTab      ( LONG win_id, INT tab, INT pos, INT just );

BOOL    DelInList       ( LONG win_id, UINT line );
BOOL    SetLineIcon     ( LONG win_id, UINT line, OBJECT *tree, INT obj );
BOOL    xSetLineIcon    ( LONG win_id, UINT line, OBJECT *tree, INT obj );

UINT    CountLines      ( LONG win_id );
INT     GetLineHeight   ( LONG win_id );
VOID    RedrawLine      ( LONG win_id, UINT line );
VOID    DelCompleteList ( LONG win_id );
INT     GetTabPosition  ( LONG win_id, INT tab_nr, BOOL pixel );

INT     SetLineEffect   ( LONG win_id, UINT line, INT effect );
INT     SetLineColor    ( LONG win_id, UINT line, INT color );
INT     SetLineFlags    ( LONG win_id, UINT line, INT flags );
INT     SetLineUser     ( LONG win_id, UINT line, INT user );

BOOL    SetWindowFont   ( LONG win_id, INT font_id, INT font_pt );
VOID    GetWindowFont   ( LONG win_id, INT *id, INT *pt );

BYTE    *GetLinePtr     ( LONG win_id, UINT line );
VOID    *GetListUserPtr ( LONG win_id, UINT line );
BOOL    SetListUserPtr  ( LONG win_id, UINT line, VOID *user );

LONG    Display         ( BYTE *fname, BYTE *wname, BYTE *winfo, INT len, LONG win_id, INT x, INT y, INT w, INT h, APROC action );

INT     cmp_strings_up  ( BYTE *str1, BYTE *str2 );
INT     cmp_strings_dn  ( BYTE *str1, BYTE *str2 );
VOID    do_qsort        ( LONG win_id, VPROC compare );
VOID    xdo_qsort       ( LONG win_id, XPROC compare );

/* -------------------------------------------------------------------
 * Sliderboxen
 * ------------------------------------------------------------------- */

BOOL    LinkSlider      ( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buf, INT len, BOOL icons );
BOOL    xLinkSlider     ( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buf, INT len, BOOL icons, SPROC redraw );
BOOL    LinkHorSlider   ( OBJECT *tree, INT box, INT left, INT right, INT show, INT hide );

BOOL    SetSliderTab    ( OBJECT *tree, INT box, INT pos, INT just );
BOOL    UpdSliderTab    ( OBJECT *tree, INT box, INT tab, INT pos, INT just );
VOID    SetSliderFont   ( OBJECT *tree, INT box, INT font_id, INT font_pt, BOOL draw );

VOID    RedrawSliderBox ( OBJECT *tree, INT box );
VOID    FastDrawSldBox  ( OBJECT *tree, INT box );
VOID    RedrawTheSlider ( OBJECT *tree, INT box, BOOL draw );

VOID    ScrollSlider    ( OBJECT *tree, INT box, INT what );
BOOL    AddSliderItem   ( OBJECT *tree, INT box, INT anz_items );
INT     SetSliderPos    ( OBJECT *tree, INT box, INT pos, BOOL draw );
INT     GetSliderItems  ( OBJECT *tree, INT box );

BOOL    SelectSldItem   ( OBJECT *tree, INT box, INT line, BOOL draw );
BOOL    DeSelSldItem    ( OBJECT *tree, INT box, BOOL draw );
INT     DrawSlider      ( OBJECT *tree, INT hide, LONG p1, LONG p2, BOOL draw );

BOOL    UnLinkSlider    ( OBJECT *tree, INT box );

/* -------------------------------------------------------------------
 * Texte in Editfeldern
 * ------------------------------------------------------------------- */

VOID    SetText         ( OBJECT *tree, INT index, BYTE *text );
VOID    xSetText        ( OBJECT *tree, INT index, BYTE *text );
BYTE    *GetText        ( OBJECT *tree, INT index, BYTE *text );
VOID    ClearEditFields ( OBJECT *tree );
BOOL    SetEditField    ( OBJECT *tree, INT field );

/* -------------------------------------------------------------------
 * Fenster
 * ------------------------------------------------------------------- */

VOID    *XWindow        ( XWIN *xwin );
VOID    InitXWindow     ( XWIN *xwin );
VOID    SetWindowName   ( INT handle, BYTE *name );
VOID    SetWindowInfo   ( INT handle, BYTE *info );
VOID    CloseAllWindows ( VOID );
BOOL    WindowVisible   ( INT handle );
INT     GetTopWindow    ( VOID );
LONG    GetTopWindowId  ( VOID );
BOOL    TopWindow       ( INT handle );
BOOL    CloseWindow     ( INT handle );
BOOL    CloseWindowById ( LONG id );
INT     GetHandle       ( LONG win_id );
LONG    GetWindowId     ( INT handle );
VOID    SetWinMinSize   ( LONG win_id, INT w, INT h );
VOID    SetWinMaxSize   ( LONG win_id, INT w, INT h );
VOID    ScrollWindow    ( INT handle, INT what );
LONG    SetWindowParm   ( INT handle, INT what, LONG value );
INT     OpenWindow      ( LONG id, BYTE *name, BYTE *info, INT flags, OBJECT *menu, INT align, BOOL part, INT scr_x, INT scr_y, LONG doc_x, LONG doc_y, INT x, INT y, INT w, INT h, VOID *user, RPROC redraw, APROC action );
INT     OpenTextWindow  ( LONG id, BYTE *name, BYTE *info, OBJECT *menu, INT x, INT y, INT w, INT h, VOID *user, APROC action );
BOOL    LinkTree        ( LONG win_id, OBJECT *tree, LONG id, INT pos );
BOOL    UnLinkTree      ( LONG win_id, OBJECT *tree );
VOID    CycleWindow     ( BOOL show_window );
VOID    SetIconRedraw   ( LONG win_id, IPROC proc );
VOID    SetWinUser      ( LONG win_id, VOID *user );
VOID    *GetWinUser     ( LONG win_id );
VOID    ReSizeWindow    ( LONG win_id, RECT *size );
INT     CountWindows    ( VOID );
VOID    CheckWindow     ( LONG win_id );
VOID    CalcWinTrees    ( LONG win_id );
VOID    SetOwner        ( LONG owner );
LONG    GetOwner        ( LONG win_id );
BOOL    ChangeTree      ( LONG win_id, LONG sub_id, OBJECT *tree, BOOL draw_flg );

/* -------------------------------------------------------------------
 * Internes Hilfe-System
 * ------------------------------------------------------------------- */

VOID    BeginHelp       ( OBJECT *tree, INT obj, BYTE *text );
VOID    EndHelp         ( VOID );
VOID    EnableHelp      ( VOID );
VOID    DisableHelp     ( VOID );
VOID    SetHelpTime     ( INT count );
VOID    SetHelpColor    ( INT color );

/* -------------------------------------------------------------------
 * Schreiben ins Fenster
 * ------------------------------------------------------------------- */

BOOL    OpenLogWindow   ( LONG win_id, BYTE *title, BYTE *info, INT columns, INT rows, INT x, INT y, APROC action );
BOOL    xOpenLogWindow  ( LONG win_id, BYTE *title, BYTE *info, INT anz_trees, XTREE *trees, INT columns, INT rows, INT x, INT y, VOID *user, APROC action );
VOID    wprintf         ( LONG win_id, BYTE *format, ... );
VOID    wcls            ( LONG win_id );
VOID    wposxy          ( LONG win_id, INT x, INT y );
VOID    wgetxy          ( LONG win_id, INT *x, INT *y );
BYTE    wgetchar        ( LONG win_id, INT x, INT y, INT *effect );
VOID    winsert         ( LONG win_id );
VOID    HideCursor      ( LONG win_id );
VOID    ShowCursor      ( LONG win_id );

/* -------------------------------------------------------------------
 * Popup's
 * ------------------------------------------------------------------- */

INT     PopUp           ( OBJECT *tree, INT x, INT y, INT start, INT first );
INT     xPopUp          ( OBJECT *tree, INT obj, OBJECT *tree2, INT start, INT *first );
INT     Cycle           ( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret );
INT     CycleBack       ( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret );
INT     Listbox         ( BYTE *strings, INT count, INT len, OBJECT *tree, INT box );
INT     xListbox        ( BYTE *strings, INT count, INT len, OBJECT *tree, INT box, SPROC redraw );

/* -------------------------------------------------------------------
 * Debug-Routinen
 * ------------------------------------------------------------------- */

VOID    DebugTheModule  ( INT x, INT y );
VOID    DebugTheConfig  ( INT x, INT y, INT w_char, INT h_char );

/* -------------------------------------------------------------------
 * Kommunikation
 * ------------------------------------------------------------------- */

INT     SearchProgram   ( BYTE *prg_name );

/* -------------------------------------------------------------------
 * Verwaltung
 * ------------------------------------------------------------------- */

VOID    HandleSysGem    ( VOID );
VOID    TakeEvent       ( INT event, INT x, INT y, INT state, INT kstate, INT key, INT clicks, INT *msg );
INT     TerminateSysGem ( VOID );
VOID    DispatchEvents  ( VOID );
VOID    SetProcEvent    ( TPROC proc );

INT     SelectPrinter   ( VOID );

/* -------------------------------------------------------------------
 * Config-Datei
 * ------------------------------------------------------------------- */

UINT    CountKeywords   ( VOID );
BOOL    SetConfig       ( BYTE *keyword, VOID *value, LONG len );
BOOL    GetConfigPtr    ( BYTE *keyword, VOID *value, LONG *len );
BOOL    GetConfig       ( BYTE *keyword, VOID *value );
BOOL    DelConfig       ( BYTE *keyword );

LONG    SaveConfig      ( BYTE *file_name );
LONG    LoadConfig      ( BYTE *file_name );

/* -------------------------------------------------------------------
 * Alerts
 * ------------------------------------------------------------------- */

INT     Alert           ( INT priority, INT def, BYTE *str );
VOID    SetButton       ( INT just );
VOID    Set3DAlertColor ( INT icn1, INT icn2, INT icn3 );
VOID    SetAlertColor   ( INT icn1, INT icn2, INT icn3 );

/* -------------------------------------------------------------------
 * Redraw
 * ------------------------------------------------------------------- */

BOOL    LinkOwnRedraw   ( OBJECT *tree, INT obj );
BOOL    RemoveOwnRedraw ( OBJECT *tree, INT obj );

VOID    RedrawArea      ( INT handle, RECT *area );
VOID    SetClipping     ( RECT *r );
VOID    RedrawWindow    ( INT handle );
VOID    RedrawObj       ( OBJECT *tree, INT obj, INT depth, INT state, INT flag );
VOID    DisableObj      ( OBJECT *tree, INT obj, BOOL draw );
VOID    EnableObj       ( OBJECT *tree, INT obj, BOOL draw );
VOID    HideObj         ( OBJECT *tree, INT obj, BOOL draw );
VOID    ShowObj         ( OBJECT *tree, INT obj, BOOL draw );
VOID    SetTextColor    ( OBJECT *tree, INT obj, INT color );

/* -------------------------------------------------------------------
 * Dialoge
 * ------------------------------------------------------------------- */

BOOL    WindowDialog    ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, BOOL shut, BOOL force, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc );
BOOL    xWindowDialog   ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, BOOL shut, BOOL force, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc );
BOOL    MultipleDialog  ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, OBJECT *top, INT active, OBJECT *tree, INT edit, VOID *user, DPROC proc );
BOOL    xMultipleDialog ( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, OBJECT *top, INT active, OBJECT *tree, INT edit, VOID *user, DPROC proc );

BOOL    BeginDialog     ( LONG win_id, OBJECT *tree, INT edit, BYTE *title );
INT     HandleDialog    ( LONG win_id );
VOID    FinishDialog    ( LONG win_id );
INT     DoDialog        ( OBJECT *tree, INT edit, BYTE *title );
VOID    ChangeButton    ( OBJECT *tree, INT obj, BYTE *text );

/* -------------------------------------------------------------------
 * Modulschnittstelle
 * ------------------------------------------------------------------- */

LONG    AskModule       ( BYTE *name, INT cmd, VOID *ptr );
BOOL    ModulAvail      ( BYTE *name );
VOID    SetModulePath   ( BYTE *path );
LONG    StartSysGemModul( BYTE *name, VOID *p );
BYTE    *GetModuleName  ( BYTE *real_name );
BOOL    LoadSysGemModul ( BYTE *name );
VOID    TermSysGemModul ( BYTE *name );
BOOL    GetModuleInfo   ( INT nr, BYTE *name, BYTE *mod_name, BYTE *mod_author );

/* -------------------------------------------------------------------
 * Nachgebaute Funktionen
 * ------------------------------------------------------------------- */

INT     appl_getinfo    ( INT ap_gtype, INT *ap_gout1, INT *ap_gout2, INT *ap_gout3, INT *ap_gout4 );

/* -------------------------------------------------------------------
 * FontSelektor
 * ------------------------------------------------------------------- */

BOOL    FontSelect      ( INT buttons, INT *id, INT *pt, BYTE *title, BYTE *example, BOOL internal, TPROC help_proc );

/* -------------------------------------------------------------------
 * Bildschirmroutinen
 * ------------------------------------------------------------------- */

BOOL    NewArea         ( AREA *p );
VOID    FreeArea        ( AREA *p );
VOID    ClearArea       ( AREA *p );
VOID    CopyArea        ( INT vdi_handle, AREA *p, INT x, INT y );
BOOL    SaveArea        ( INT vdi_handle, AREA *p, RECT *r );
VOID    RestoreArea     ( INT vdi_handle, AREA *p );
VOID    MoveScreen      ( INT vdi_handle, RECT *r, INT x, INT y );

/* -------------------------------------------------------------------
 * Resourcen
 * ------------------------------------------------------------------- */

INT     LoadResource    ( BYTE *rsc_name, BOOL long_rsc );
OBJECT  *RscAdr         ( INT tree_type, INT index );
VOID    RscFree         ( VOID );
BOOL    InitResource    ( OBJECT *rsc_tree, UINT num_obs, UINT num_trees, VOID *rgb_table, BOOL long_rsc );

/* -------------------------------------------------------------------
 * MenÅzeilen
 * ------------------------------------------------------------------- */

VOID    SetDeskTopMenu  ( OBJECT *menu, MPROC proc );
VOID    RemDeskTopMenu  ( VOID );

/* -------------------------------------------------------------------
 * Sonstiges
 * ------------------------------------------------------------------- */

VOID    CalcArea        ( OBJECT *tree, INT obj, RECT *r );
VOID    RectIntersect   ( RECT *r1, RECT *r2 );
VOID    WhiteArea       ( RECT *r, INT color );
BOOL    RectVisible     ( RECT *r );

/* -------------------------------------------------------------------
 * Online-Help
 * ------------------------------------------------------------------- */

VOID    SetOnlineHelp   ( BYTE *prg_name1, BYTE *prg_name2, BYTE *file_name );
BOOL    CallOnlineHelp  ( BYTE *help );

/* -------------------------------------------------------------------
 * CRC-Routinen
 * ------------------------------------------------------------------- */

UINT    crc_16          ( BYTE *s, ULONG len );
ULONG   crc_32          ( BYTE *s, ULONG len );

/* -------------------------------------------------------------------
 * System-Routinen
 * ------------------------------------------------------------------- */

BOOL    GetCookie       ( LONG id, VOID *value );
INT     get_cpu         ( VOID );
LONG    get_longframe   ( VOID );
INT     get_mch         ( VOID );

/* -------------------------------------------------------------------
 * Font-Routinen
 * ------------------------------------------------------------------- */

BOOL    FontExists      ( INT font_id );
INT     GetFontId       ( BYTE *font_name );
BYTE    *GetFontName    ( INT font_id );
BOOL    VectorFont      ( INT font_id );

/* ------------------------------------------------------------------- */

VOID    NormalFont      ( VOID );
VOID    SmallFont       ( VOID );
VOID    SetFont         ( INT font_id, INT pt );

/* ------------------------------------------------------------------- */

INT     StringWidth     ( BYTE *text );
INT     StringHeight    ( VOID );
INT     CenterX         ( INT x1, INT x2, BYTE *text );
INT     CenterY         ( INT y1, INT y2 );

/* ------------------------------------------------------------------- */

VOID    v_xtext         ( INT color, INT x, INT y, BYTE *text );
VOID    v_stext         ( INT color, INT x, INT y, BYTE *text );

/* ------------------------------------------------------------------- */

VOID    SetSysFont      ( INT font_id );
VOID    SendFontChanged ( INT font_id, INT font_pt );
VOID    ResetSysFont    ( VOID );

/* ------------------------------------------------------------------- */

#endif  /* __sysgem_mod__ */

/* ------------------------------------------------------------------- */

#endif  /* __sysgem__ */

/* ------------------------------------------------------------------- */
