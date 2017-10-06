#ifndef __GFWINDOWS__
# define __GFWINDOWS__

# include <aes.h>

/************************* defines ***********************************/

# define NO_HANDLE (-1)      	             /* Wert fÅr ungÅltiges Handle */

# define ALL  (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)

# define MAX_LENGTH  128						 /* max. LÑnge einer Textzeile */

# define CL_TEXT     0x0001					 /* Klasse Textfenster */

# define WI_NONE     0x0000                /* Keine Flags */
# define WI_FULLED   0x0001                /* Flag fÅr "Fenster auf voller Grîûe" */
# define WI_LOCKED   0x0002                /* Flag fÅr "Fenster gelockt" */
# define WI_FIRSTDRW 0x0004                /* Flag fÅr "Fenster erstesmal gezeichnet" */
# define WI_ONTOP    0x0010                /* Flag fÅr "Fenster ist oben" */
# define WI_NOTOP    0x0020                /* Flag fÅr "Fenster darf nicht nach oben */
# define WI_RESIDENT 0x0040                /* Flag fÅr "Fenster resident" */
# define WI_NOSCROLL 0x0100                /* Flag fÅr "Update statt Scrolling */

# define DO_CLOSE    6                     /* Code fÅr "Fenster schlieûen" */
# define DO_DELETE   7                     /* Code fÅr "Fenster lîschen" */

# define SRCH_CLOSED 0x01                  /* Search-Code fÅr geschlossene Fenster */
# define SRCH_OPENED 0x02                  /* Search-Code fÅr geîffnete Fenster */
# define SRCH_ANY    (SRCH_CLOSED | SRCH_OPENED) /* Search-Code fÅr jedes Fenster */

# define MOVED       0x01                  /* FÅr Verschieben und Vergrîûern */
# define SIZED       0x02

# define HORIZONTAL  0x01                  /* FÅr Scrolling... */
# define VERTICAL    0x02                  /* ...und Schieber setzen */
# define SLPOS       0x01                  /* FÅr Schieber setzen */
# define SLSIZE      0x02

/************************* types ***********************************/

typedef struct window *WINDOWP;				/* Zeiger fÅr Parameter */

typedef struct window
{
	int handle;										/* Handle fÅr Fenster */
	BOOLEAN opened;								/* Fenster geîffnet */
	unsigned int flags;							/* Flags des Fensters */
	unsigned int kind;							/* Art des Fensters */
	int class;										/* Klasse des Fensters */
	LRECT doc;										/* Grîûe des Dokuments, Position */
	int xfac;										/* X-Factor des Dokumentes */
	int yfac;										/* Y-Factor des Dokumentes */
	int xunits;										/* X-Scroll-Einheiten */
	int yunits;										/* Y-Scroll-Einheiten */
	RECT scroll;									/* Scrollbereich */
	RECT work;										/* Arbeitsbereich */
	long special;									/* FÅr speziellen Gebrauch */
	char name[128];								/* Name des Fensters */
	char info[128];								/* Infozeile des Fensters */
	OBJECT *object;								/* Objektbaum fÅr Fenster */
	BOOLEAN (*test) (WINDOWP, int );			/* Test vor einer Aktion */
	void (*open) (WINDOWP);						/* Aktion vor dem ôffnen */
	void (*close) (WINDOWP);					/* Aktion nach dem Schlieûen */
	void (*delete) (WINDOWP);					/* Aktion nach dem Lîschen */
	void (*draw) (WINDOWP);						/* Zeichnen-Aktion */
	void (*arrow) (WINDOWP,int,long,long );/* Pfeil-Aktion */
	void (*snap) (WINDOWP, RECT *, int );	/* Schnapp-Aktion */
	void (*top) (WINDOWP);						/* Aktion nach Top */
	void (*untop) (WINDOWP);					/* Aktion vor Untop */
} WINDOW;

/************************* globals ***********************************/

/************************* functions *********************************/

GLOBAL BOOLEAN init_windows ( char *, int );
GLOBAL void exit_windows ( void );
GLOBAL BOOLEAN handle_window_events ( int * );
GLOBAL WINDOWP create_textwindow ( char *, int, int, int, RECT * );

GLOBAL WINDOWP search_window ( int, int  );
GLOBAL WINDOWP find_window ( int );
GLOBAL WINDOWP find_xy_window ( const int, const int );
GLOBAL WINDOWP find_top ( void );
GLOBAL BOOLEAN is_top ( WINDOWP );
GLOBAL BOOLEAN any_open ( BOOLEAN );
GLOBAL int num_windows ( int, int, WINDOWP [] );
GLOBAL int num_locked ( void );
GLOBAL void lock_all ( WINDOWP );
GLOBAL void unlock_all ( void );

GLOBAL WINDOWP create_window ( unsigned int, int );
GLOBAL void delete_window ( WINDOWP );
GLOBAL BOOLEAN open_window ( WINDOWP );
GLOBAL void close_window ( WINDOWP );
GLOBAL void close_top ( void );
GLOBAL void close_all ( BOOLEAN );
GLOBAL void draw_window ( WINDOWP );
GLOBAL void redraw_window ( WINDOWP, const RECT * );
GLOBAL void top_window ( WINDOWP );
GLOBAL void untop_window ( WINDOWP );
GLOBAL void scroll_window ( WINDOWP, int, long );
GLOBAL void arrow_window ( WINDOWP, int, int );
GLOBAL void v_slider ( WINDOWP, int );
GLOBAL void h_slider ( WINDOWP, int );
GLOBAL void set_sliders ( WINDOWP, int, int );
GLOBAL void snap_window ( WINDOWP, RECT *, int );
GLOBAL void full_window ( WINDOWP );
GLOBAL void size_window ( WINDOWP, const RECT * );
GLOBAL void move_window ( WINDOWP, const RECT * );

GLOBAL void get_work ( WINDOWP, BOOLEAN );
GLOBAL void get_border ( WINDOWP, int, RECT * );
GLOBAL void draw_object ( WINDOWP, int );

GLOBAL void scroll_area ( const RECT *, int, int );
GLOBAL void clr_area ( const RECT * );
GLOBAL void clr_work ( WINDOWP );
GLOBAL void clr_scroll ( WINDOWP );
GLOBAL void clr_left ( WINDOWP );
GLOBAL void clr_right ( WINDOWP );
GLOBAL void clr_top ( WINDOWP );
GLOBAL void clr_bottom ( WINDOWP );
GLOBAL void set_redraw ( WINDOWP, const RECT * );

#endif  /* __GFWINDOWS__ */
