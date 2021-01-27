/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1995, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#ifndef __kernel__
#define __kernel__

/* ------------------------------------------------------------------- */

#ifdef PASCAL

/* ------------------------------------------------------------------- */

#define InitGem         sgInitGem
#define FileSelect      sgFileSelect
#define SetAlertTitle   sgSetAlertTitle
#define SetProgramName  sgSetProgramName
#define SetIconifyName  sgSetIconifyName
#define LinkImage       sgLinkImage
#define LinkMainImage   sgLinkMainImage
#define ShowMessage     sgShowMessage
#define ShowStatus      sgShowStatus
#define LinkList        sgLinkList
#define AddToList       sgAddToList
#define InsInList       sgInsInList
#define ChgInList       sgChgInList
#define xLinkList       sgxLinkList
#define xAddToList      sgxAddToList
#define xInsInList      sgxInsInList
#define xChgInList      sgxChgInList
#define BeginHelp       sgBeginHelp
#define Display         sgDisplay
#define SetText         sgSetText
#define GetText         sgGetText
#define SetWindowName   sgSetWindowName
#define SetWindowInfo   sgSetWindowInfo
#define OpenWindow      sgOpenWindow
#define OpenLogWindow   sgOpenLogWindow
#define xOpenLogWindow  sgxOpenLogWindow
#define SearchProgram   sgSearchProgram
#define SetConfig       sgSetConfig
#define GetConfigPtr    sgGetConfigPtr
#define GetConfig       sgGetConfig
#define DelConfig       sgDelConfig
#define SaveConfig      sgSaveConfig
#define LoadConfig      sgLoadConfig
#define Alert           sgAlert
#define WindowDialog    sgWindowDialog
#define xWindowDialog   sgxWindowDialog
#define MultipleDialog  sgMultipleDialog
#define BeginDialog     sgBeginDialog
#define DoDialog        sgDoDialog
#define ChangeButton    sgChangeButton
#define AskModule       sgAskModule
#define ModulAvail      sgModulAvail
#define SetModulePath   sgSetModulePath
#define StartSysGemModul sgStartSysGemModul
#define LoadSysGemModul sgLoadSysGemModul
#define TermSysGemModul sgTermSysGemModul
#define GetModuleInfo   sgGetModuleInfo
#define FontSelect      sgFontSelect
#define LoadResource    sgLoadResource
#define SetOnlineHelp   sgSetOnlineHelp
#define CallOnlineHelp  sgCallOnlineHelp
#define GetFontId       sgGetFontId
#define StringWidth     sgStringWidth
#define CenterX         sgCenterX
#define v_xtext         sgv_xtext
#define v_stext         sgv_stext

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */

#include        "portab.h"
#include        "sys_gem2.h"

/* ------------------------------------------------------------------- */

#define         OBJ_BUTTON      0
#define         OBJ_TOUCH       1
#define         OBJ_RADIO       2
#define         OBJ_SELECT      3
#define         OBJ_BOX         4
#define         OBJ_CHAR        5
#define         OBJ_TEXT        6
#define         OBJ_STRING      7
#define         OBJ_FRAME       8
#define         OBJ_MENTRY      9
#define         OBJ_MTITLE      10
#define         OBJ_MBOX        11
#define         OBJ_EDIT        12
#define         OBJ_HELP        13
#define         OBJ_REITER      14
#define         OBJ_LISTBOX     15
#define         OBJ_CIRCLE      16
#define         OBJ_BALKEN1     17
#define         OBJ_BALKEN2     18
#define         OBJ_BALKEN3     19

/* ------------------------------------------------------------------- */

#define         AV_PROTOKOLL    0x4700
#define					AV_SENDCLICK		0x4709							/* [GS]	*/
#define					AV_SENDKEY			0x4710							/* [GS]	*/
#define 				AV_ASKCONFONT 	0x4714							/* [GS] */
#define					AV_STARTPROG 		0x4722							/* [GS] */
#define         AV_WINDOPEN     0x4724
#define         AV_WINDCLOSE    0x4726
#define 				AV_PATH_UPDATE 	0x4730							/* [GS] */
#define         AV_EXIT         0x4736
#define 				AV_STARTED 			0x4738							/* [GS] */

/* ------------------------------------------------------------------- */

#define         VA_PROTOKOLL    0x4701
#define         VA_START        0x4711
#define 				VA_CONFONT			0x4715							/* [GS] */
#define         VA_DRAGACCWIND     0x4725
#define 				VA_FONTCHANGED	0x4739							/* [GS] */

/* ------------------------------------------------------------------- */

#define         WM_BOTTOM       25
#define         WF_ICONIFY      26
#define         WF_UNICONIFY    27
#define         WM_BOTTOMED     33
#define         WM_ICONIFY      34
#define         WM_UNICONIFY    35
#define         WM_ALLICONIFY   36
#define         WM_TOOLBAR      37
#define         WM_SHADE        22360
#define         WM_UNSHADE      22361
#define         WM_BACKDROP     100
#define         AP_DRAGDROP     63
#define         SC_CHANGED      80

/* ------------------------------------------------------------------- */

#define         LINK_MENU       0
#define         LINK_DIALOG     5
#define         LINK_REITER     6

/* ------------------------------------------------------------------- */

#define         WIN_DRAWN       (1 << 10)
#define         WIN_VISIBLE     (1 << 11)
#define         WIN_FAST        (1 << 12)
#define         WIN_FULLED      (1 << 13)
#define         WIN_DIALOG      (1 << 14)

/* ------------------------------------------------------------------- */

#define         ICON_HIDE       1
#define         ICON_ICON       2
#define         ICON_MAIN       3

/* ------------------------------------------------------------------- */

#define         ICFS_GETPOS     0x0001
#define         ICFS_FREEPOS    0x0002
#define         ICFS_SNAP       0x0003

/* ------------------------------------------------------------------- */

#define         ICONIFY_AES     1
#define         ICONIFY_ICFS    2


/* ------------------------------------------------------------------- */

#define EOS			'\0'

/* ------------------------------------------------------------------- */

typedef VOID    (*OPROC)( struct _win *win, VOID *p );

/* ------------------------------------------------------------------- */

typedef struct
  {
    INT         event;
    INT         xclicks;
    INT         xmask;
    INT         xstate;
    INT         watch1;
    RECT        watch1r;
    INT         watch2;
    RECT        watch2r;
    INT         tim_lo;
    INT         tim_hi;
    INT         mwich;
    INT         x;
    INT         y;
    INT         state;
    INT         kstate;
    INT         key;
    INT         clicks;
    INT         msg [8];
  } XEVENT;

/* ------------------------------------------------------------------- */

typedef union
  {
    LONG        p;
    bfobspec    b;
  } COLOR_INF;

/* ------------------------------------------------------------------- */

typedef struct _ubk
  {
    struct _ubk *next;                  /* Zeiger auf n„chsten Block   */
    INT CDECL  (*code)( PARMBLK *p );   /* Zeiger auf Zeigerfunktion   */
    struct _ubk *ubb;                   /* Zeiger auf sich selbst      */
    BYTE        *text;                  /* Zeiger auf den Text         */
    LONG        parm;                   /* Geretteter ob_spec.index    */
    INT         obj;                    /* Objektnummer                */
    INT         ob_typ;                 /* Zeichentyp                  */
    INT         typ;                    /* Objecttyp                   */
    INT         ext;                    /* Erweiterter Typ Nr. x       */
    INT         ch;                     /* Shortcut-Zeichen            */
    INT         pos;                    /* Shortcut-Position           */
  } USERB;

/* ------------------------------------------------------------------- */

typedef struct _fnt
  {
    struct _fnt *next;                  /* Zeiger auf n„chsten Font    */
    BYTE        name              [40]; /* Name des Fonts              */
    BOOL        vektor;                 /* Vektorfont?                 */
    INT         id;                     /* Id des Fonts                */
  } FONT;

/* ------------------------------------------------------------------- */

typedef struct _xrd
  {
    struct _xrd *next;                  /* Zeiger auf n„chstes Objekt  */
    INT         obj;                    /* Objektnummer                */
  } XREDRAW;

/* ------------------------------------------------------------------- */

#define MAX_TAB         100             /* TABULAR def. in sys_gem2.h  */

/* ------------------------------------------------------------------- */

typedef struct _sld
  {
    struct _sld *next;                  /* Zeiger auf n„chsten Slider  */
    OBJECT      *tree;                  /* Zeiger auf den Objektbaum   */
    INT         box;                    /* Die Sliderbox               */

    INT         sel;                    /* Tempor„rvariablen           */
    INT         desel;                  /* Tempor„rvariablen           */

    INT         font_id;                /* Id des Sliderfonts          */
    INT         font_pt;                /* Gr”že des Sliderfonts       */

    INT         chw;                    /* Breite des Zeichens 'W'     */
    INT         chh;                    /* H”he eines Zeichens         */

    INT         left;                   /* Objektnummer fr links      */
    INT         right;                  /* Objektnummer fr rechts     */
    INT         hor_show;               /* Sliderelement               */
    INT         hor_hide;               /* Sliderelement               */
    INT         hpos;                   /* Position horizontal         */
    INT         max_hor;                /* Breite des breitesten Text  */

    INT         up;                     /* Button fr 'hoch'           */
    INT         dn;                     /* Button fr 'down'           */
    INT         show;                   /* Button fr 'show'           */
    INT         hide;                   /* Button fr 'hide'           */
    INT         pos;                    /* Aktuelle oberste Zeile      */
    INT         max_ver;                /* Maximale Anzahl Zeilen      */

    BOOL        icons;
    INT         len;                    /* L„nge eines Textes          */
    BYTE        *buf;                   /* Zeiger auf den Text         */
    TABULAR     tab      [MAX_TAB + 1]; /* Tabulatoren                 */
    SPROC       paint_entry;            /* Zeichenfunktion             */
  } SLIDER;

/* ------------------------------------------------------------------- */

typedef struct _dia
  {
    struct _dia *next;                  /* Zeiger auf n„chsten Dialog  */
    OBJECT      *tree;                  /* Zeiger auf Objektbaum       */
    USERB       *user;                  /* Zeiger auf Userbl”cke       */
    XREDRAW     *redraw;                /* Eigene Redraw-Funktion      */
    SLIDER      *slider;                /* Zeiger auf die Slider       */
    INT         edit;                   /* Aktuelles Editfeld          */
    INT         edch;                   /* Cursorposition im Editfeld  */
    BOOL        cursor;                 /* Cursor sichtbar?            */
  } DIALOG_SYS;  /* [GS] */

/* ------------------------------------------------------------------- */

typedef struct
  {
    BYTE        *txt;                   /* Zeiger auf den Text         */
    BYTE        *pt;                    /* Aktuelle Position Text      */
    INT         x, y;                   /* Position des Cursors        */
    INT         col, row;               /* Ausmaže des Fensters        */
    INT         w, h;                   /* Breite, H”he eines Zeichens */
    INT         line_len;               /* L„nge einer Zeile           */
    BOOL        cursor;                 /* Cursor sichtbar?            */
    BOOL        no_esc;                 /* Keine Auswertung?           */
  } LOG;

/* ------------------------------------------------------------------- */

typedef struct _wtx
  {
    struct _wtx *next;
    BYTE        *text;                  /* Zeiger auf den Text         */
    VOID        *user;                  /* Userzeiger fr die Zeile    */
    OBJECT      *icon;                  /* Zeiger auf ein Icon         */
    BOOL        only;                   /* Nur das icon zeichnen?      */
    INT         start;                  /* Startobjekt                 */
    INT         effect;                 /* Texteffekte                 */
    INT         color;                  /* Textfarbe                   */
    INT         flags;                  /* Textflags                   */
    INT         user_flag;              /* Userflags                   */
    INT         pixel;                  /* Breite des Textes in Pixel  */
    INT         height;                 /* H”he der Zeile              */
    INT         len;                    /* L„nge des Strings           */
  } WTEXT;

/* ------------------------------------------------------------------- */

typedef struct _wtr
  {
    struct _wtr *next;                  /* Zeiger auf n„chsten Baum    */
    LONG        id;                     /* Id des Teilbaumes           */
    DIALOG_SYS  *dial;     /* [GS] */	  /* Zeiger auf Grunddialog      */
    INT         start;                  /* Startobjekt                 */
    INT         depth;                  /* Zeichentiefe                */
    INT         w;                      /* Breite des Baumes           */
    INT         h;                      /* H”he des Baumes             */
    INT         pos;                    /* Position des Baumes         */
  } WTREE;

/* ------------------------------------------------------------------- */

typedef struct _win
  {
    struct _win *next;                  /* Zeiger auf n„chstes Fenster */
    VOID        *user;                  /* Userzeiger                  */
    VOID        *user2;                 /* Userzeiger fr LogWindow    */
    LONG        id;                     /* Id des Fensters             */
    LONG        owner;                  /* Eigentmer des Fensters     */
    LONG        pos_x;                  /* Position im Dokumentber.    */
    LONG        pos_y;                  /* Position im Dokumentber.    */
    LONG        doc_x;                  /* Dokumentbereich             */
    LONG        doc_y;                  /* Dokumentbereich             */
    LONG        timer_anz;              /* Anzahl der Schritte         */
    LONG        timer;                  /* N„chster Timer              */
    RECT        work;                   /* Realer Arbeitsbereich       */
    RECT        full;                   /* Zwischenspeicher FULLED     */
    INT         icon_icolor;            /* Farbe der Bitmap            */
    INT         icon_tcolor;            /* Farbe des Textes            */
    INT         icon;                   /* Iconifiziert?               */
    INT         icon_pos;               /* Handle des Icons            */
    BITBLK      *icfs_icon;             /* Zeiger auf Icon             */
    BYTE        icfs_name         [10]; /* Name fr ICFS               */
    INT         handle;                 /* AES-Handle des Fensters     */
    INT         kind;                   /* AES-Flags des Fensters      */
    INT         flags;                  /* Eigene Flags fr's Fenster  */
    INT         back;                   /* Farbe des Hinterdrundes     */
    INT         align_x;                /* Ausrichtung Snap-Bereich    */
    INT         align_y;                /* Ausrichtung Snap-Bereich    */
    INT         min_w;                  /* Minimale Gr”že des Fensters */
    INT         min_h;                  /* Minimale Gr”že des Fensters */
    INT         max_w;                  /* Maximale Gr”že des Fensters */
    INT         max_h;                  /* Maximale Gr”že des Fensters */
    INT         scr_x;                  /* Scrollweiten                */
    INT         scr_y;                  /* Scrollweiten                */
    INT         font_id;                /* Font des Fensters           */
    INT         font_pt;                /* Font des Fensters           */
    DIALOG_SYS  *dial;                  /* Bei Dialog belegt    [GS]   */
    WTREE       *tree;                  /* Zeiger auf die B„ume        */
    APROC       waction;                /* Action-Funktion             */
    DPROC       daction;                /* Action-Funktion             */
    RPROC       redraw;                 /* Redraw-Funktion             */
    IPROC       iconredraw;             /* Redraw-Funktion             */
    LOG         log;                    /* Parameter fr LogWindow     */
    TABULAR     tab      [MAX_TAB + 1]; /* Tabulatoren                 */
    WTEXT       *first;                 /* Zeiger auf erste Textzeile  */
    WTEXT       *last;                  /* Zeiger auf letzte Textzeile */
    UINT        lines;                  /* Anzahl der Zeilen           */
    BOOL        list_upd;               /* Liste wird aufgebaut...     */
    BYTE        name             [ 80]; /* Name des Fensters           */
    BYTE        show             [ 80]; /* Name des Fensters           */
    BYTE        info             [200]; /* Infozeile des Fensters      */
  } WINDOW;

/* ------------------------------------------------------------------- */

typedef struct _xtm
  {
    struct _xtm *next;                  /* Zeiger auf n„chsten Timer   */
    TPROC       proc;                   /* Behandlungsroutine          */
    LONG        id;                     /* Id des Timers               */
    VOID        *user1;                 /* Userpointer                 */
    VOID        *user2;                 /* Userpointer                 */
    LONG        timer;                  /* Zeit                        */
    LONG        timer_anz;              /* Zeit                        */
  } XTIMER;

/* ------------------------------------------------------------------- */

typedef struct
  {
    LONG        magic;                  /* 'SGEM'                      */
    LONG        version;                /* '2.02'                      */
    LONG        anz;                    /* Anzahl der Datens„tze       */
    ULONG       crc;                    /* excl. crc 32                */
  } INI_CF0;

/* ------------------------------------------------------------------- */

typedef struct
  {
    ULONG       crc_all;                /* excl. crc 32                */
    ULONG       crc_key;                /* crc 32 ber keyword excl 0b */
    ULONG       crc_val;                /* crc 32 ber value           */
    LONG        len_key;                /* L„nge keyword in byte       */
    LONG        len_val;                /* L„nge value in byte         */
  } INI_CF1;

/* ------------------------------------------------------------------- */

typedef struct _cfg
  {
    struct _cfg *next;
    LONG        len;                    /* L„nge der Struktur          */
    BYTE        *keyword;               /* Zeiger auf Keyword          */
    VOID        *value;                 /* Zeiger auf den Wert         */
  } INI_CFG;

/* ------------------------------------------------------------------- */

typedef LONG  ( *SGM_PROC )( INT msg, INT user, VOID *p );
/*typedef INT   ( *USR_PROC )( INT );  nicht mehr ben”tigt, da in sys_gem2.h  /* [GS] */ */

/* ------------------------------------------------------------------- */

typedef struct _mod
  {
    struct _mod *next;                  /* Zeiger auf n„chstes Modul   */
    BYTE        name    [20];           /* Name des Moduls             */
    SGM_PROC    start;                  /* Einsprungadresse            */
    LONG        buf_len;                /* L„nge des Bereiches         */
    BYTE        *buffer;                /* Buffer fr das Modul        */
    BYTE        *mod_name;              /* Zeiger auf Modulnamen       */
    BYTE        *mod_autor;             /* Zeiger auf Copyright        */
  } MODULE;

/* ------------------------------------------------------------------- */

#define SGM_ENTER       0
#define SGM_LEAVE       1

typedef VOID    (*YPROC)( INT status, MODULE *mod, INT cmd, INT user, VOID *p, LONG result );
typedef VOID    (*ZPROC)( VOID );

/* ------------------------------------------------------------------- */

typedef struct
  {
    /* ---------------------------------------------------------------
     * System
     * --------------------------------------------------------------- */

    INT         appl_id;
    INT         acc;
    INT         app;
    INT         aes_version;
    INT         vdi_handle;
    INT         vdi_user;

    INT         gemini;

    /* ---------------------------------------------------------------
     * Systemwerte
     * --------------------------------------------------------------- */

    INT         xmax;
    INT         ymax;
    INT         charw;
    INT         charh;
    INT         boxw;
    INT         boxh;
    RECT        desk;

    INT         magicpc_version;				/* [GS] */
    INT         magx_version;
    INT         magx_revision;
    INT         nvdi_version;
    INT         winx_version;
    INT         mint_version;
    INT         tos_version;
    INT         multitasking;
		INT					wdialog;								/* [GS] TRUE, wenn WDialog vorh*/

    INT         iconify;
    BYTE        icn_name          [40];
    INT CDECL   (*icfs_server)( INT fkt, ... );
    INT         icfs_version;
    BYTE        iconified_name    [10]; /* Name des ganzen Programms   */
    BITBLK      *iconified_icon;        /* Zeiger auf Programm-Icon    */

    DRAG_DROP   drag;

    PARAMETER   param;

    /* ---------------------------------------------------------------
     * Fonts
     * --------------------------------------------------------------- */

    INT         system_fonts;
    INT         loaded_fonts;

    INT         sysfont_hid;
    INT         sysfont_hpt;

    INT         confont_hid;
    INT         confont_hpt;
    BOOL        allow_change;

    INT         font_hid;
    INT         font_hpt;
    INT         font_sid;
    INT         font_spt;

    INT         act_font_id;
    INT         act_font_pt;
    INT         act_font_vk;
    INT         act_font_cw;
    INT         act_font_ch;

    /* ---------------------------------------------------------------
     * Farben
     * --------------------------------------------------------------- */

    INT         act_color;
    INT         max_color;
    INT         bitplanes;

    INT         lwhite;
    INT         lblack;

    INT         shortcut_color;
    INT         frametext_color;

    INT         mono_ausr;
    INT         mono_frag;
    INT         mono_stop;

    INT         icon_ausr;
    INT         icon_frag;
    INT         icon_stop;

    INT         selb_color;             /* Selektierbalken Sliderbox   */
    INT         selt_color;             /* SelektierText   Sliderbox   */

    /* ---------------------------------------------------------------
     * Programmdaten
     * --------------------------------------------------------------- */

    LONG        prg_id;
    BYTE        acc_name        [40];
    BYTE        prg_name        [40];
    BYTE        win_name        [40];

    BYTE        clipboard       [130];
    BYTE        clipboard_path  [130];
    BYTE        module_path     [130];

    BYTE        *global_mem;
    
    GS_INFO	*gs_info;
    BYTE	*gs_buffer;
    GS_PROC	gs_proc;
    
    LONG        key1;

    /* ---------------------------------------------------------------
     * Zeiger
     * --------------------------------------------------------------- */

    OBJECT      *listbox;
    OBJECT      *cycle_win;
    OBJECT      *fontsel;

    INT        (*form)( const INT button, char *text );   /* [GS] */

    FONT        *font;
    INI_CFG     *pini;
    DIALOG_SYS  *dialog;  /* [GS] */
    WINDOW      *window;
    MODULE      *module;

    VOID        (*draw_slider)( OBJECT *tree, INT box, RECT *clip );
    INT         (*test_slider)( WINDOW *win, OBJECT *tree, INT obj, INT y, INT clicks, INT *ret );
    VOID        (*term_module)( BYTE *name );

    /* ---------------------------------------------------------------
     * Einstellungen
     * --------------------------------------------------------------- */

    BOOL        like_mac;
    BOOL        edit_mono;
    BOOL        bergner;
    BOOL        center;
    BOOL        self_edit;
    BOOL        locked;
    BOOL        wait;
    BOOL        tell;
    BOOL        timer;
    BOOL        sg_return;
    BOOL        cursor_off;
    BOOL        send_slider;

    INT         button_just;
    INT         help_count;
    INT         help_color;

    BOOL        alert;
    BOOL        new_dial;
    BOOL        english;
    BOOL        new_event;
    BOOL        resizing;

    BOOL        check_logfont;

    BOOL        use_arbpt;
    BOOL        no_blub;
    BOOL        msg_shown;
    BOOL				fslx;											/* [GS] Flag fr Dateiauswahl  */
    BOOL				pdlg;											/* [GS] Flag fr Druckerdialog */

    INT		divider;												/* Trennlinien zeichnen (==0)  */

    BOOL        mod_init;
    YPROC       spy_module;
    ZPROC       spy_ini;

    /* ---------------------------------------------------------------
     * Menzeile
     * --------------------------------------------------------------- */

    OBJECT      *menu_tree;
    MPROC       menu_proc;

    /* ---------------------------------------------------------------
     * Timer
     * --------------------------------------------------------------- */

    XTIMER      *xtimer;                /* Zeiger auf die Timer        */
    LONG        timer_anz;              /* Anzahl der Schritte         */
    LONG        timert;                 /* Verstrichene Zeit           */
    TPROC       timer_proc;             /* Aufgerufene Funktion        */

    /* ---------------------------------------------------------------
     * Hilfe
     * --------------------------------------------------------------- */

    BYTE        help_prg_name    [128];
    BYTE        help_prg_path    [128];
    BYTE        help_prg_file    [128];

    /* ---------------------------------------------------------------
     * Acc
     * --------------------------------------------------------------- */

    TPROC       acc_open;
    TPROC       acc_close;
    LONG        key2;

  } SYSGEM;

/* -------------------------------------------------------------------
 * system32.c
 * ------------------------------------------------------------------- */

VOID    *Allocate       ( LONG size );
VOID    Dispose         ( VOID *p );
VOID    InsertPtr       ( VOID *src, VOID *mem );
VOID    DeletePtr       ( VOID *src, VOID *mem );

/* ------------------------------------------------------------------- */

VOID    ReplaceMode     ( VOID );
VOID    TransMode       ( VOID );
VOID    TextEffect      ( INT eff );
VOID    TextColor       ( INT color );
VOID    inv_area        ( INT color, INT x, INT y, INT w, INT h );
VOID    move_screen     ( RECT *r, INT x, INT y );
VOID    CopyToScreen    ( BOOL draw_3d, VOID *img_h, VOID *img_l, INT x, INT y );
VOID    Line            ( INT x0, INT y0, INT x1, INT y1, INT color );
VOID    Rect            ( INT x0, INT y0, INT x1, INT y1, INT color );
VOID    Frame           ( INT x0, INT y0, INT x1, INT y1, INT thick, INT color );
VOID    FilledRect      ( INT x0, INT y0, INT x1, INT y1, INT color );
VOID    DrawPattern     ( INT x0, INT y0, INT x1, INT y1, INT pattern, INT interiorcol );
VOID    PaintPattern    ( INT x0, INT y0, INT x1, INT y1, bfobspec *sp );

USERB   *find_user 			( OBJECT *tree, INT obj );
LONG    GetObjType      ( OBJECT *tree, INT i, INT *typ, INT *ext );
DIALOG_SYS  *find_dialog    ( OBJECT *tree );  /* [GS] */
BOOL    MouseClicked    ( INT *x, INT *y );
VOID    DoRedraw        ( WINDOW *win, RECT *dirty );

INT     ObjTyp          ( OBJECT *tree, INT i );
BOOL    is_editfield    ( OBJECT *tree, INT i );
INT     first_edit      ( OBJECT *tree );
INT     last_edit       ( OBJECT *tree );
INT     next_edit       ( DIALOG_SYS *dial );  						/* [GS] */
INT     prev_edit       ( DIALOG_SYS *dial );  						/* [GS] */
VOID    clear_edit      ( DIALOG_SYS *dial, INT edit );  	/* [GS] */
INT     prev_edit       ( DIALOG_SYS *dial );  						/* [GS] */
INT     next_edit       ( DIALOG_SYS *dial );  						/* [GS] */
INT     last_edit       ( OBJECT *tree );
INT     first_edit      ( OBJECT *tree );
BOOL    is_editfield    ( OBJECT *tree, INT i );
VOID    edit_char       ( DIALOG_SYS *dial, INT ch );  		/* [GS] */
VOID    show_cursor     ( DIALOG_SYS *dial );  						/* [GS] */
VOID    hide_cursor     ( DIALOG_SYS *dial );  						/* [GS] */
USERB   *NewUserblock   ( DIALOG_SYS *dial, OBJECT *tree, INT obj, BYTE *text, INT typ );  /* [GS] */
VOID    InitWindowMenu  ( OBJECT *menu_line );

VOID    Cursor          ( VOID );
VOID    SendRedraw      ( INT handle, RECT *r );

VOID 		KeyFound        ( WINDOW *win, WTREE *wt, INT x, INT y, INT obj, BOOL exit ); /* [GS] */
VOID    HandleButton    ( INT x, INT y, INT clicks, INT state );
VOID    HandleKey       ( UINT gem_key, INT kstate );
VOID    HandleTimer     ( VOID );

INT     GetHighRes      ( VOID );
INT     SendMessage     ( INT msg, WINDOW *win, WTREE *wt, VOID *p0, INT p1, INT p2, INT p3, INT p4 );

VOID    DisableGemini   ( VOID );
INT     SearchProgram   ( BYTE *prg_name );
VOID    ClipboardChanged ( VOID );
VOID    SendToGemini    ( INT what, INT handle );
/* VOID    SendStart       ( VOID ); [GS] */

WTEXT   *find_line      ( WINDOW *win, UINT line );
VOID    output_sld      ( INT color, BYTE *q, INT x, INT y, INT w, TABULAR *tab, VOID (*xx_text)( INT, INT, INT, BYTE* ));
BOOL    CalcSlider      ( WINDOW *win, RECT *z );
VOID    SendExit        ( INT id, INT res );
VOID    SendStart       ( VOID );
VOID    SendChanged     ( VOID );
UINT    make_nkc        ( INT key, INT state );
UBYTE   alt_shortcut    ( UINT key );
INT     simulate_out    ( INT px, BYTE *q, INT x, INT w, TABULAR *tab );
VOID    GetsyColors     ( VOID );
VOID    CheckBlub       ( VOID );
VOID    VqtDevice       ( INT dev_no, INT *open, BYTE *name );

/* ------------------------------------------------------------------- */

#define CTL_MOUSE       (1 << 0)
#define CTL_UPDATE      (1 << 1)
#define CTL_MHIDE       (1 << 2)

/* ------------------------------------------------------------------- */

VOID    BeginControl    ( INT ctrl );
VOID    EndControl      ( INT ctrl );

/* -------------------------------------------------------------------
 * system16.c
 * ------------------------------------------------------------------- */

INT CDECL DrawUserDef   ( PARMBLK *p );
INT CDECL draw_mline    ( PARMBLK *p );
VOID    HandleEvents    ( VOID );
VOID    MakeStartup     ( VOID );
VOID    DelButton       ( VOID );

/* -------------------------------------------------------------------
 * window.c
 * ------------------------------------------------------------------- */

WINDOW  *find_window    ( INT handle, LONG id );
WINDOW  *topped         ( VOID );
WINDOW  *forced         ( VOID );
VOID 		MenuLock 				( VOID );										/* [GS] */
VOID 		MenuUnlock 			( VOID );										/* [GS] */
WINDOW  *DialogInWindow ( OBJECT *tree );
VOID    FixWinTree      ( WINDOW *win );
BYTE    *BuildWinName   ( BYTE *text );
VOID    FixEntry        ( WTREE *wt, INT pos, RECT *w );
VOID    WinCalcBorder   ( WINDOW *win, RECT *w );
VOID    do_arrow        ( INT handle, INT scroll );
VOID    MoveWindow      ( WINDOW *win, RECT *w, INT msg );
VOID    FullWindow      ( WINDOW *win );
WTREE   *find_wt_type   ( WINDOW *win, INT pos );
VOID    SetTheSlider    ( INT handle, INT slid, INT newp );

VOID    FreeWindow      ( WINDOW *win );
BOOL    Iconify         ( INT handle, RECT *r );
BOOL    IconifyAllInOne ( INT handle, RECT *r );
BOOL    IconifyAll      ( VOID );
VOID    UnIconify       ( INT handle );
WINDOW  *iconified      ( VOID );
VOID    DestroyWindow   ( WINDOW *win, BOOL close );
VOID    MoveWinArea     ( WINDOW *win, RECT *area, INT scroll, INT w, INT h, BOOL do_white, OPROC callback, VOID *user );

/* -------------------------------------------------------------------
 * slider.c
 * ------------------------------------------------------------------- */

VOID    PaintSliderbox  ( OBJECT *tree, INT box, RECT *clip );

/* -------------------------------------------------------------------
 * log.c
 * ------------------------------------------------------------------- */

VOID    do_blink        ( VOID );

/* -------------------------------------------------------------------
 * text.c
 * ------------------------------------------------------------------- */

VOID    ListUpdate      ( WINDOW *win );

/* -------------------------------------------------------------------
 * blub.c
 * ------------------------------------------------------------------- */

VOID    CheckBlub       ( VOID );
VOID    DelBlub         ( VOID );
VOID    InitBlub        ( VOID );

/* -------------------------------------------------------------------
 * gemscrip.c
 * ------------------------------------------------------------------- */

VOID	sgHandleGemScript ( INT *msg );

/* -------------------------------------------------------------------
 * fsel.c				alles [GS]
 * ------------------------------------------------------------------- */


VOID		HandleFslx			( EVENT *evt );

/* -------------------------------------------------------------------
 * cl_cpu.c				alles [GS]
 * ------------------------------------------------------------------- */

VOID ClearCache 				( VOID );

/* ------------------------------------------------------------------- */

#endif

/* ------------------------------------------------------------------- */
