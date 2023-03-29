/*****************************************************************************
 *
 * Module : WINDOWS.H
 * Author : Dieter Geiû
 *
 * Creation date    : 05.03.90
 * Last modification:
 *
 *
 * Description: This module defines windows definitions.
 *
 * History:
 * 01.10.04: WI_ICONIFY added
 * 27.01.04: Funktion message bei struct window mit zusÑtzliche Parameter,
 *					 damit man feststellen kann welche Sondertaste beim eintreffen
 *					 einer Nachricht gedrÅckt war.
 * 26.01.04: message_window and message_all new parameter mk added
 * 25.02.97: WI_SHADED added
 * 13.02.97: Functions message_window and message_all added
 * 02.12.95: Functions DragLine, SizeBox, and DrawHandles added
 * 29.07.95: Function window_button returns BOOLEAN
 * 05.03.94: Members yscroll and yscroll in WINDOW added
 * 29.10.93: Listbox functionality removed
 * 14.09.93: Function draw_growbox added
 * 10.09.93: Function scroll_area moved to GLOBAL.H
 * 04.09.93: Function window_button added
 * 03.09.93: Function draw_win_obj added
 * 05.03.90: Creation of body
 *****************************************************************************/

#ifndef __WINDOWS__
#define __WINDOWS__

/****** DEFINES **************************************************************/

#define MAX_GEMWIND 64                    /* Maximale Anzahl Fenster in GEM */

#define WI_NONE     0x0000                /* Keine Flags */
#define WI_FULLED   0x0001                /* Flag fÅr "Fenster auf voller Grîûe" */
#define WI_LOCKED   0x0002                /* Flag fÅr "Fenster gelockt" */
#define WI_FIRSTDRW 0x0004                /* Flag fÅr "Fenster erstesmal gezeichnet" */
#define WI_DLCLOSE  0x0008                /* Flag fÅr "Dialog-Fenster schlieûen" */
#define WI_ONTOP    0x0010                /* Flag fÅr "Fenster ist oben" */
#define WI_NOTOP    0x0020                /* Flag fÅr "Fenster darf nicht nach oben */
#define WI_RESIDENT 0x0040                /* Flag fÅr "Fenster resident" */
#define WI_MOUSE    0x0080                /* Flag fÅr "Eigene Mausform" */
#define WI_NOSCROLL 0x0100                /* Flag fÅr "Update statt Scrolling */
#define WI_MODAL    0x0200                /* Flag fÅr "Modales Dialog-Fenster" */
#define WI_MODELESS 0x0400                /* Flag fÅr "Nicht-Modales Dialog-Fenster" */
#define WI_CURSKEYS 0x0800                /* Flag fÅr "Cursor Tasten fÅr Scrolling" */
#define WI_MNSCROLL 0x1000                /* Flag fÅr "Scrollbare MenÅzeile */
#define WI_TOPMENU  0x2000                /* Flag fÅr "MenÅzeile soll nur oben funktionieren */
#define WI_SHADED   0x4000                /* Flag fÅr "Fenster eingeklappt" */
/* [GS] 5.1e Start */
#define WI_ICONIFY  0x8000                /* Flag fÅr "Fenster Iconify" */
/* Ende */

#define DRAG_OK     ( 0)                  /* Drag-Code fÅr "Funktion OK" */
#define DRAG_SWIND  (-1)                  /* Drag-Code fÅr "Gleiches Fenster" */
#define DRAG_SCLASS (-2)                  /* Drag-Code fÅr "Gleiche Art" */
#define DRAG_NOWIND (-3)                  /* Drag-Code fÅr "UngÅltiges Fenster" */
#define DRAG_NORCVR (-4)                  /* Drag-Code fÅr "Kein EmpfÑnger" */
#define DRAG_NOACTN (-5)                  /* Drag-Code fÅr "Keine EmpfÑnger-Aktion */

#define DO_UNDO     0                     /* Code fÅr "Undo" */
#define DO_CUT      1                     /* Code fÅr "Cut" */
#define DO_COPY     2                     /* Code fÅr "Copy" */
#define DO_PASTE    3                     /* Code fÅr "Paste" */
#define DO_CLEAR    4                     /* Code fÅr "Clear" */
#define DO_SELALL   5                     /* Code fÅr "Select all" */
#define DO_CLOSE    6                     /* Code fÅr "Fenster schlieûen" */
#define DO_DELETE   7                     /* Code fÅr "Fenster lîschen" */
#define DO_EXTERNAL 0x0100                /* Externe Operationen */

#define OBJ_OPEN    0                     /* Code fÅr "Objekt îffnen" */
#define OBJ_INFO    1                     /* Code fÅr "Info von Objekt" */
#define OBJ_HELP    2                     /* Code fÅr "Hilfe von Objekt" */

#define SRCH_CLOSED 0x01                  /* Search-Code fÅr geschlossene Fenster */
#define SRCH_OPENED 0x02                  /* Search-Code fÅr geîffnete Fenster */
#define SRCH_ANY    (SRCH_CLOSED | SRCH_OPENED) /* Search-Code fÅr jedes Fenster */
#define SRCH_SUB    0x04                  /* Search-Code fÅr Unterklasse */

#define MOVED       0x01                  /* FÅr Verschieben und Vergrîûern */
#define SIZED       0x02

#define SLPOS       0x01                  /* FÅr Schieber setzen */
#define SLSIZE      0x02

#define HANDLE_SIZE	7		/* size of handles in pixels */

enum HANDLE_POSITIONS
{
  HANDLE_TL,				/* top left */
  HANDLE_TM,				/* top middle */
  HANDLE_TR,				/* top right */
  HANDLE_ML,				/* middle left */
  HANDLE_MR,				/* middle right */
  HANDLE_BL,				/* bottom left */
  HANDLE_BM,				/* bottom middle */
  HANDLE_BR				/* bottom right */
}; /* HANDLE_POSITIONS */

enum DRAG_MESSAGES
{
  DM_START,				/* start of drag operation */
  DM_CHANGE,				/* value has changed */
  DM_FINISH,				/* drag operation finished */
}; /* DRAG_MESSAGES */

enum SIZE_MESSAGES
{
  SM_START,				/* start of size operation */
  SM_CHANGE,				/* value has changed */
  SM_FINISH,				/* size operation finished */
}; /* SIZE_MESSAGES */

/****** TYPES ****************************************************************/

typedef struct window *WINDOWP;           /* Zeiger fÅr Parameter */

typedef struct window
{
  WORD    handle;                         /* Handle fÅr Fenster */
  WORD    opened;                         /* Wie oft wurde Fenster geîffnet ? */
  UWORD   flags;                          /* Flags des Fensters */
  UWORD   kind;                           /* Art des Fensters */
  WORD    class;                          /* Klasse des Fensters */
  WORD    subclass;                       /* Unterklasse des Fensters */
  WORD    icon;                           /* Objektnummer des Icons des Fensters */
  LRECT   doc;                            /* Position und Breite der Schieber/Dokumentes */
  WORD    xfac;                           /* X-Factor des Dokumentes */
  WORD    yfac;                           /* Y-Factor des Dokumentes */
  WORD    xunits;                         /* X-Scroll-Einheiten */
  WORD    yunits;                         /* Y-Scroll-Einheiten */
  WORD    xscroll;                        /* Linker fester Rand beim horizontalen Scrolling */
  WORD    yscroll;                        /* Oberer fester Rand beim vertikalen Scrolling */
  RECT    scroll;                         /* Scrollbereich */
  RECT    work;                           /* Arbeitsbereich */
/* [GS] 5,1f Start */
	RECT		iconify_pos;										/* Position wenn Fenster iconifiziert ist */
/* Ende */
  WORD    bg_color;                       /* Hintergrund-Farbe */
  WORD    mousenum;                       /* Nummer der Mausform */
  MFORM   *mouseform;                     /* Mausform, falls mousenum = 255 */
  LONG    milli;                          /* Anzahl der Millisekunden */
  LONG    count;                          /* ZÑhler fÅr Millisekunden */
  LONG    special;                        /* FÅr speziellen Gebrauch */
  WORD    edit_obj;                       /* Aktuelles editiertes Objekt */
  WORD    edit_inx;                       /* Aktueller Index im editierten Objekt */
  WORD    exit_obj;                       /* Objekt, mit dem Box verlassen wurde */
  LONGSTR name;                           /* Name des Fensters */
  LONGSTR info;                           /* Infozeile des Fensters */
  OBJECT  *object;                        /* Objektbaum fÅr Fenster */
  OBJECT  *menu;                          /* MenÅzeile fÅr Fenster */
  WORD    first_menu;                     /* Erstes angezeigtes MenÅ */
  VOID    (*updt_menu) _((WINDOWP window));             /* MenÅ auf neuen Stand bringen */
  VOID    (*hndl_menu) _((WINDOWP window, WORD title, WORD item)); /* MenÅ-Handler */
  BOOLEAN (*test)      _((WINDOWP window, WORD action));/* Test vor einer Aktion */
  VOID    (*open)      _((WINDOWP window));             /* Aktion vor dem ôffnen */
  VOID    (*close)     _((WINDOWP window));             /* Aktion nach dem Schlieûen */
  VOID    (*delete)    _((WINDOWP window));             /* Aktion nach dem Lîschen */
  VOID    (*draw)      _((WINDOWP window));             /* Zeichnen-Aktion */
  VOID    (*arrow)     _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos)); /* Pfeil-Aktion */
  VOID    (*snap)      _((WINDOWP window, RECT *new, WORD mode));  /* Schnapp-Aktion */
  VOID    (*objop)     _((WINDOWP window, SET objs, WORD action)); /* Objekt-Operationen im Fenster */
  WORD    (*drag)      _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj)); /* Ziehen von Objekten */
  VOID    (*click)     _((WINDOWP window, MKINFO *mk)); /* Klick-Aktion (selektieren) */
  VOID    (*unclick)   _((WINDOWP window));             /* Klick-Aktion (deselektieren) */
  BOOLEAN (*key)       _((WINDOWP window, MKINFO *mk)); /* Tastatur-Aktion */
  VOID    (*timer)     _((WINDOWP window));             /* Aktion nach Ablaufen einer Zeitspanne */
/* [GS] 5.1d Start: */
  BOOLEAN (*message)   _((WINDOWP window, WORD *msg, MKINFO *mk ));  /* Nachricht an Fenster */
/* Ende; alt:
  BOOLEAN (*message)   _((WINDOWP window, WORD *msg));  /* Nachricht an Fenster */
*/
  VOID    (*top)       _((WINDOWP window));             /* Aktion nach Top */
  VOID    (*untop)     _((WINDOWP window));             /* Aktion vor Untop */
  VOID    (*edit)      _((WINDOWP window, WORD action));/* Cut/Copy/Paste */
  BOOLEAN (*showinfo)  _((WINDOWP window, WORD icon));  /* Information des Fensters eines Moduls */
  BOOLEAN (*showhelp)  _((WINDOWP window, WORD icon));  /* Hilfe des Fensters eines Moduls */
} WINDOW;

typedef VOID (CALLBACK *DRAGFUNC) (INT msg, CONST RECT *r, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p);
typedef VOID (CALLBACK *SIZEFUNC) (INT msg, CONST RECT *r, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p);

/****** VARIABLES ************************************************************/

GLOBAL WINDOWP sel_window;      /* Zeiger auf selektiertes Fenster */
GLOBAL SET     sel_objs;        /* Menge selektierter Objekte */

/****** FUNCTIONS ************************************************************/

GLOBAL WINDOWP search_window  _((WORD class, WORD mode, WORD icon));
GLOBAL WINDOWP find_window    _((WORD wh));
GLOBAL WINDOWP find_top       _((VOID));
GLOBAL BOOLEAN is_top         _((WINDOWP window));
GLOBAL BOOLEAN any_open       _((BOOLEAN incl_desk, BOOLEAN incl_closer, BOOLEAN incl_modal));
GLOBAL WORD    num_windows    _((WORD class, WORD mode, WINDOWP winds []));
GLOBAL WORD    num_locked     _((VOID));

GLOBAL WINDOWP create_window  _((UWORD kind, WORD class));
GLOBAL VOID    delete_window  _((WINDOWP window));
GLOBAL BOOLEAN open_window    _((WINDOWP window));
GLOBAL VOID    close_window   _((WINDOWP window));
GLOBAL VOID    close_top      _((VOID));
GLOBAL VOID    close_all      _((BOOLEAN delete, BOOLEAN close_desk));
GLOBAL VOID    draw_window    _((WINDOWP window));
GLOBAL VOID    redraw_window  _((WINDOWP window, CONST RECT *area));
GLOBAL VOID    top_window     _((WINDOWP window));
GLOBAL VOID    untop_window   _((WINDOWP window));
GLOBAL VOID    cycle_window   _((VOID));
GLOBAL VOID    scroll_window  _((WINDOWP window, WORD dir, LONG delta));
GLOBAL VOID    arrow_window   _((WINDOWP window, WORD arrow, WORD amount));
GLOBAL VOID    h_slider       _((WINDOWP window, WORD new_value));
GLOBAL VOID    v_slider       _((WINDOWP window, WORD new_value));
GLOBAL VOID    set_sliders    _((WINDOWP window, WORD which, WORD mode));
GLOBAL VOID    snap_window    _((WINDOWP window, RECT *new, WORD mode));
GLOBAL VOID    full_window    _((WINDOWP window));
GLOBAL VOID    size_window    _((WINDOWP window, CONST RECT *new));
GLOBAL VOID    move_window    _((WINDOWP window, CONST RECT *new));
/* [GS] 5.1e Start */
GLOBAL VOID		 iconify_window _((WINDOWP window, WORD *msg));
GLOBAL VOID 	 uniconify_window _((WINDOWP window, WORD *msg));
/* Ende */
GLOBAL WORD    drag_to_window _((WORD mox, WORD moy, WINDOWP src_window, WORD src_obj, WINDOWP *dest_window, WORD *dest_obj));
GLOBAL VOID    click_window   _((WINDOWP window, MKINFO *mk));
GLOBAL VOID    unclick_window _((WINDOWP window));
GLOBAL BOOLEAN key_window     _((WINDOWP window, MKINFO *mk));
GLOBAL BOOLEAN key_all        _((MKINFO *mk));
GLOBAL VOID    timer_window   _((WINDOWP window));
GLOBAL VOID    timer_all      _((LONG milli));
/* [GS] 5.1d; Start */
GLOBAL BOOLEAN message_window _((WINDOWP window, WORD *msg, MKINFO *mk ));
GLOBAL BOOLEAN message_all    _((WORD *msg, MKINFO *mk ));
/* Ende; alt:
GLOBAL BOOLEAN message_window _((WINDOWP window, WORD *msg));
GLOBAL BOOLEAN message_all    _((WORD *msg));
*/

GLOBAL VOID    get_border     _((WINDOWP window, WORD obj, RECT *border));
GLOBAL VOID    draw_growbox   _((WINDOWP window, BOOLEAN grow));
GLOBAL VOID    draw_object    _((WINDOWP window, WORD obj));
GLOBAL VOID    draw_win_obj   _((WINDOWP window, OBJECT *tree, WORD obj));
GLOBAL BOOLEAN window_button  _((WINDOWP window, OBJECT *tree, WORD obj, WORD clicks));
GLOBAL VOID    set_cursor     _((WINDOWP window, WORD obj, WORD inx));
GLOBAL VOID    drag_boxes     _((WORD num_objs, CONST RECT *boxes, WINDOWP inv_window, SET inv_objs, RECT *diff, CONST RECT *bound, WORD x_raster, WORD y_raster));
GLOBAL VOID    edit_noecho    _((MKINFO *mk, WORD cursor, BYTE *s, WORD maxlen));

GLOBAL VOID    clr_area       _((CONST RECT *area));
GLOBAL VOID    clr_work       _((WINDOWP window));
GLOBAL VOID    clr_scroll     _((WINDOWP window));
GLOBAL VOID    clr_left       _((WINDOWP window));
GLOBAL VOID    clr_top        _((WINDOWP window));
GLOBAL VOID    clr_right      _((WINDOWP window));
GLOBAL VOID    clr_bottom     _((WINDOWP window));
GLOBAL VOID    set_redraw     _((WINDOWP window, CONST RECT *area));

GLOBAL VOID    draw_mtitle    _((WINDOWP window, WORD title));
GLOBAL VOID    draw_mbar      _((WINDOWP window));
GLOBAL VOID    menu_normal    _((WINDOWP window, WORD title, BOOLEAN normal));
GLOBAL BOOLEAN menu_manager   _((WINDOWP window, WORD mox, WORD moy, WORD mobutton, WORD breturn));
GLOBAL BOOLEAN menu_key       _((WINDOWP window, MKINFO *mk));

GLOBAL VOID    DrawGreyLine   _((CONST RECT *rc, SHORT sBkColor));
GLOBAL VOID    DragLine       _((CONST RECT *rc, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p, DRAGFUNC dragfunc));
GLOBAL VOID    SizeBox        _((CONST RECT *rc, RECT *diff, RECT *bound, SHORT min_width, SHORT min_height, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p, SIZEFUNC sizefunc, SHORT sHandlePos));
GLOBAL VOID    DrawHandles    _((CONST RECT *rc));
GLOBAL BOOLEAN GetHandleSize  _((CONST RECT *rc, SHORT sHandlePos, RECT *pRectHandle));

GLOBAL BOOLEAN init_windows   _((WORD err_nowindow, WORD maxreswind, WORD class_help));
GLOBAL BOOLEAN term_windows   _((VOID));

#endif /* __WINDOWS__ */

