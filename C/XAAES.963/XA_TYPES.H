/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _XA_TYPES_H_
#define _XA_TYPES_H_

#if ! XA_SCL
#include RSCHNAME
#endif

#ifdef MEMORY_HNAME
#include MEMORY_HNAME
#else
#include <ahcm.h>
#endif

#include "xa_aes.h"
#include "xa_defs.h"
#include "display.h"

#ifndef PATH_MAX
#define PATH_MAX 128
#define NAME_MAX 128
#endif

typedef char Path[PATH_MAX];			/* HR */

typedef enum
{
	PULL,
	PUSH,
	LEAVE
} MENU_BEHAVE;

#define MONO (screen.colours < 16)		/* HR */

/*-----------------------------------------------------------------
 * Lock control
 *-----------------------------------------------------------------*/

typedef enum locks
{
	NOLOCKS   = 0,
	appl      = 1,
	newclient = 2,
	trap      = 4,
	winlist   = 8,
	desk      = 0x10,
	clients   = 0x20,
	fsel      = 0x40,
	update    = 0x80,
	mouse     = 0x100,
	envstr    = 0x200,
	pending   = 0x400,
	NOLOCKING = -1
} LOCK;


#include "messages.h"

/*-----------------------------------------------------------------
 * Display descriptions
 *-----------------------------------------------------------------*/

typedef enum {D_LOCAL = 0, D_TCP = 1} XA_DISPLAY;

typedef struct {
	int   bg_col,			/* Colour used for backgrounds */
	      fg_col,			/* Colour used for foregrounds */
	      shadow_col,		/* Colour used for shadowed 3d edge */
	      lit_col,			/* Colour used for lit 3d edge */
	      border_col,		/* Colour used for edging */
	      highlight_col;	/* Colour used for highlighting */
} XA_COLOUR_SCHEME;

typedef struct {
	RECT r;						/* Screen dimensions */
	XA_DISPLAY display_type;	/* The type of display we are using */
	XA_COLOUR_SCHEME dial_colours;	/* Colour scheme used for dialogs */
	int   colours,				/* Number of colours available */
	      planes,				/* Number of planes in screen */
	      standard_font_height,	/* Needed for appl_getinfo */
	      standard_font_id,
	      standard_font_point,
	      small_font_id,
	      small_font_point,
	      small_font_height;	/* Needed for appl_getinfo */
	 G_i  c_max_w, c_max_h,		/* Maximum character dimensions in pixels */
	      c_min_w, c_min_h;		/* Minimum (small font) character dimensions in pixels */
} XA_SCREEN;

/*-----------------------------------------------------------------
 * Configuration and options structures
 *-----------------------------------------------------------------*/

typedef struct config
{
	Path launch_path,			/* Initial path for launcher */
         scrap_path,			/* Path to the scrap directory */
         acc_path;				/* Path to desk accessory directory */
/* HR: display modes of window title */
	int   topname,
          backname;
	bool direct_call,
	     no_xa_fsel,
	     superprogdef,			/* Run progdefs in supervisor mode */
	     auto_program,
	     point_to_type,
	     fsel_cookie,
	     usehome,				/* HR 051002: Use $HOME in shell_find */
	     menu_locking,			/* HR: menus run in a window.
	                                   See lines.app run underneath the pulldown menu. :-) */
	     opentaskman;			/* HR 250102: open taskmanager at boot. */
#if ! XA_SCL
	char cancel_buttons[NUM_CB][CB_L];
#if FILESELECTOR && defined(FSEL_MENU)
	char Filters[23][16];
#endif
#endif
	MENU_BEHAVE menu_behave;	/* HR: pull, push or leave */
	int   widg_w,widg_h,widg_dw,widg_dh,		/* HR 251201: flexible widget object types. */
	      ted_filler,
	      font_id,				/* Font id to use */
	      have_wheel_vector,	/* HR 111002: If vex_whlv changed its save_ptr, we have a VDI that supports mouse wheels. */
          wheel_amount,			/*             amount of lines for a wheel click. */
          standard_font_point,	/* Size for normal text */
          medium_font_point,	/* The same, but for low resolution screens */
          small_font_point,		/* Size for small text */
          popscroll;			/* number of lines of a popup above which it will be made scrollable. */
} CFG;

typedef struct options
{
	int  windowner;			/* HR 030401: display window owner in title. */
	bool    nohide,
	     xa_nohide,
	     xa_nomove,
	     xa_none,				/* HR 250602: No xa_windows at all; classic dialogue handling. */
	     noleft,				/* HR 240901: Dont move window out left side of screen. */
	     thinwork,				/*            workarea frame a single line. */
	     live,					/* HR 211101: Live moving and sizing of windows. */
	     wheel_reverse,			/* HR 111002: Do you want move the slider in the wheel direction, or rather the window content? */
	     naes,					/* N.Aes 3d compatability */
	     naes12;
	int  thinframe,				/* HR 270901: -1: keep colour frame thin. +1: make a thicker frame for wasier border grabbing and sizing. */
	     wheel_page;			/* HR 111002: how many wheel clicks for a page */
	long half_screen;
	IFDIAG(debug_item point[D_max];)	/* HR 211201 */
} OPT;

typedef struct opt_list
{
	struct opt_list *next;
	Path name;
	OPT options;
} OPT_LIST;

typedef struct app_list
{
	struct app_list *next;
	Path name;
} APP_LIST;

typedef struct moose_data
{
	unsigned
	G_i l,		/* HR: record length */
	    ty;		/* HR: button & movement */
	G_i x,
	    y,
	    state,
	    clicks,
	    dbg1,
	    dbg2;
} MOOSE_DATA;				/* HR */

/*-----------------------------------------------------------------
 * Client application data structures
 *-----------------------------------------------------------------*/

/* List of Pending AES messages */
typedef struct xa_aesmsg_list
{
	struct xa_aesmsg_list *next;
	MSG_BUF message;
} XA_AESMSG_LIST;

typedef union
{
	long bcon;					/* returned by Bconin */
	struct
	{
		unsigned char
			state,				/* Ensure conterm bit 3 is set, so we get the keyboard status in here. */
			scan,				/* scancode */
			dum,
			code;				/* ascii (if applicable */
	}conin;
} CONKEY;

typedef struct rawkey		/* HR */
{
	CONKEY raw;
	G_u aes,				/* AES keycode */
		norm;			    /* mormalized keycode */
} KEY;

/*
 * Codes for what types of event an app is currently waiting for
 * - I've used the same bit allocation and nomenclature as evnt_multi() here,
 *   but there is
 *   the extra XAWAIT_MULTI bit to indicate we are waiting from evnt_multi()
 *   as opposed to one of the individual routines (as return values are different).
 */
typedef enum
{
	XAWAIT_MULTI	= 0x200,	/* Waiting for an evnt_multi() */
	XAWAIT_WDLG		= 0x400,	/* Waiting for a wdlg_xxx event to occur */
	XAWAIT_CHILD	= 0x800,	/* Waiting for a non-parallel shel_write() child process to exit */
/* HR: menu rectangle event */
	XAWAIT_MENU		= 0x1000,	/* AES private */
} WAITING_FOR;


typedef void TASK(struct task_administration_block *tab);

typedef struct
{
	G_i flags;
	RECT m1,m2;
	TASK *t1,*t2;	/* used by tasking */
} XA_MOUSE_RECT;

#define ATTACH_MAX 64			/* This is per menu_bar!!!! */

typedef struct menu_attachments	/* HR */
{
	OBJECT *tree;		/* attached menu tree */
	int item;
	OBJECT *to_tree;	/* attached to */
	int to_item;
} XA_MENU_ATTACHMENT;

/*-----------------------------------------------------------------
 * Object Handler Structures
 *-----------------------------------------------------------------*/

/*
 * Object display callback parameter
 * - This only exists because Lattice 5.52 has a bug that crashes the compiler
 *   if you have:
 *		typedef void (*ObjectDisplay)(OBJECT *ob, int parent_x, int parent_y);
 * HR: (*)()    I removed the (*...) out of ALL typedef'd prototypes. :-)
 */
/* HR: Well, it appeared to be handy as well. */
/* HR: 070101  completely combined with XA_TREE. */


/* HR (*)() */
/* A function of the type used for widget behaviours is a 
   'WidgetBehaviour'. */
typedef bool WidgetBehaviour(LOCK lock, struct xa_window *wind,
                                        struct xa_widget *widg);
typedef int WindowKeypress (LOCK lock, struct xa_window *wind,
                                       struct widget_tree *wt, G_u keycode, G_u nkcode, KEY key);
typedef void ClassicClick(LOCK lock, struct xa_client *client, MOOSE_DATA *md);
/* Object display function type */
typedef void ObjectDisplay(LOCK lock, struct widget_tree *wt);	/* HR (*)() */
/* Object handler function type */
typedef void ObjectHandler(LOCK lock, struct widget_tree *wt); 	/* HR */
/* Exit form condition handlers */
typedef void ExitForm(LOCK lock, struct xa_window *wind,
                                 struct xa_widget *widg,
                                 struct widget_tree *wt,
                                 int f, int os, int dbl, int which, KEY *key);	/* HR 250602 */


/* Object Tree based widget descriptor */

typedef struct
{
	void *handle;				/* For use as 'wdialog structure' */
	struct xa_window *wind;		/* cross reference to parent window. */
	int   code,					/* Data for wdlg_xxx extension. */
	      flag;
	void *user_data,
	     *data;
	EVNT *evnt;
	HNDL_OBJ *exit;
} WDLG_INFO;

typedef struct widget_tree
{
	OBJECT *tree;				/* The object tree */
	int current;					/* current item within above tree. */
	RECT r;						/* HR: Why not do the addition (parent_x+ob_x) once in the caller? */
								/* HR: And set a usefull RECT as soon as possible, ready for use in
								       all kind of functions. */
	struct xa_client *owner;	/* The tree widget would be owned by a different app to
								   the actual window (like the menu bar on the root window),
								   or the desktop toolbar widget. HR 270801: was: int pid; */
	struct xa_widget *widg;		/* HR 070702: Cross pointer to widget. */
	G_u *state_mask;
	G_i parent_x,				/* Keep both in: dont need to change everything in a single effort */
	    parent_y;
	int edit_obj,				/* Index of the current editable text field (if any) */
	    edit_pos,				/* Cursor position within the text field (if any) */
	    lastob,					/* Can be used to validate item number */
	    which;					/* kind of event for use by WDIAL exit handler. */
	bool is_menu,				/* HR: true when the tree is a menu or part of it. */
	     menu_line,				/* HR: draw a menu line. */
	     zen;					/* HR: true when the tree is embedded in a window.
	                                  Do not shadow and border. */
	G_i dx,dy;					/* displacement of root from upper left corner of window
								   for operation by sliders. */
#if WDIAL
	WDLG_INFO wdlg;
#endif
	ExitForm *exit_form;		/* Called if exit condition occurs while handling a form_do or a toolbar or anything the like ;-) */
	ObjectHandler *exit_handler; /* Handler vec for direct handling of exit condition. The 'aaplication' aspect of the exit_form */
	void *extra;				/* Extra info if needed (texts for alert) */
} XA_TREE;

/* used for linking resources's per client */
typedef struct xa_rscs
{
	struct xa_rscs *next, *prior;
	int     id, handle;
	GLOBAL *globl;   /* Need a global per resource, otherwise rsrc_gaddr would be ambiguous. */
	void *rsc;
} XA_RSCS;

typedef struct			/* Kernal command packet structure */
{
	G_i pid;			/* Client pid */
	G_u cmd;			/* Command code */
	AESPB *pb;			/* Pointer to AES parameter block */
} K_CMD_PACKET;

typedef struct
{
	char pipe[32];
	G_i ctrl[5];	
	K_CMD_PACKET packet;
	AESPB pb;
} APP_CONTRL;

typedef struct
{
	struct xa_window *wind;	/* Pointer to a window that could be about to become a dialog */
	short state,			/* fmd.r contains a valid rectangle of a form_dial, which is postponed. */
	      lock;				/* Client has locked the screen. */
	XA_WIND_ATTR kind;		/* Window attributes to be used. */
	WindowKeypress *keypress;
	ClassicClick *mousepress;
	RECT r;					/* The rectangle for the postponed dialogue window */
} FMD;

/* Main client application descriptor */
typedef struct xa_client
{
	struct xa_client *next, *prior;
	int pid;				/* HR: clients process identifier number */

	int  client_end,		/* File handle's of the clients internal reply pipe */
	     kernel_end;
	bool init,				/* HR: true between appl_init & appl_exit */
	     killed,			/* HR: true if the clients memory is destroyed. */
	     secured,			/* HR: true if secure remove_refs applied. */
	     apterm,			/* HR: true if application understands AP_TERM. */
	     wa_wheel;			/* HR 111002: The client wants WA_HEEL messages. */
	XA_AESMSG_LIST *msg;	/* Pending AES messages */
	WAITING_FOR waiting_for;		/* What types of event(s) the client is waiting for */
	AESPB *waiting_pb;		/* Parameter block for whatever the client is waiting for */
	int   mouse,			/* The cursor to use when this is top application */
	      save_mouse;		/* HR 100302 */
	MFORM *mouse_form,
	      *save_mouse_form;	/* HR 100302 */
	GLOBAL *globl_ptr;		/* Pointer to the client's globl array (so we can fill in the resource
							   address field later). */
	RSHDR  *rsrc,			/* Pointer to the client's standard GEM-style single resource file */
	       *rsrc_1;			/* For multiple resources. */
	OBJECT **trees,
	       **trees_1;
	int rsct;				/* HR: count up/down the loaded resources. Used by XA_alloc, XA_free */
/* HR: */
	XA_MENU_ATTACHMENT *attach;		/* submenus */
	XA_TREE std_menu,		/* The client's standard GEM-style menu-bar widget */
	        desktop,		/* The clients desktop as a standard toolbar widget */
	        wt;				/* Widget tree for everything except form_do(). */
	Path home_path,			/* The directory that the client was started in */
	     cmd_name;			/* The full filename used when launching the process (if launched by shell_write) */
	char *cmd_tail;			/* The command tail of the process (if launched by shell_write) */
	bool tail_is_heap;		/* If true, cmd_tail is a malloc */
	char name[NICE_NAME+2];	/* The clients 'pretty' name (possibly set by menu_register) */
	char proc_name[10];		/* The clients 'official' (ie. used by appl_find) name. */
	int  parent;			/* Process id of the client's "parent" process. (need not be a AES client!!!!) */
	FMD fmd;				/* Data needed by the XaAES windowing of dialogues. */
	void *temp;				/* Temporary storage */
	int  type;				/* What type of client is this? */
	char *half_screen_buffer;	/* HR: for wind_get WF_SCREEN (people tend to use what is offered, whether the idee is good or not) */
	long half_screen_size;
	XA_MOUSE_RECT em;		/* HR: Needed. whether threads or not */
	long timer_val;			/* HR 051201: Pass it here, instead of awkward in the return value; */ 
	XA_memory base;			/* Base of the memory allocated for the client. */
	XA_RSCS *resources;		/* HR: link loaded resoures' allocated memory, so it can be freeed.
	                               this also solves the problem that memory allocated for colour icon data
	                               was left orphaned. */

	APP_CONTRL	app;		/* HR 210501; Control structure for XA_new_client & XA_client_exit. */
	unsigned long tinybuf;	/* For writing return values to the client. */
	struct xa_client *srchn;	/* HR 190701: first/next for appl_search */
#if GENERATE_DIAGS
	char zen_name[NICE_NAME + 2 + 16];
#endif
	int  xdrive;
	Path xpath;
	OPT options;			/* HR 240901: Individual AES options. */
} XA_CLIENT;

/* HR:  removing the (*) from (*..)(..) makes it more usable */
typedef
unsigned long AES_function(LOCK lock, XA_CLIENT *client, AESPB *pb);		/* HR: pass the client structure. */

typedef enum
{
	LOCKSCREEN = 1,			/* HR 210202: lock/unlock screen around AES function. */
	NO_SEMA    = 2			/* HR 110802: Call direct for small AES functions that do not need the call_direct semaphores. */
} AES_funcflags;

typedef struct xa_function_table
{
	AES_function *f;		/* function pointer */
	bool d;					/* true id call direct */
	AES_funcflags p;		/* HR 210202: flags */
} XA_FTAB;

typedef struct button_data
{
	XA_CLIENT *client;
	G_i x, y;
	int b, clicks, ks;
	bool got,have,skip;
} BUTTON;

/*-----------------------------------------------------------------
 * Windows & Widgets
 *----------------------------------------------------------------- */


/* Relative coordinate types */
typedef enum
{
	RT,			/* Top right */
	RB,			/* Bottom right */
	LT,			/* Top left */
	LB,			/* Bottom left */
	CT,			/* Top centred */
	CR,			/* right centered */
	CB,			/* Bottom centred */
	CL			/* Left centered */
} XA_RELATIVE;

/* Widget Index's */

typedef enum
{
	XAW_TITLE,
	XAW_CLOSE,
	XAW_FULL,
	XAW_MOVER,			/* Not actually used like the others */
	XAW_INFO,
	XAW_RESIZE,
	XAW_UPLN,								/* 6 */
	XAW_DNLN,								/* 7 */
	XAW_VSLIDE,
	XAW_UPPAGE,		/* HR 050601 */
	XAW_DNPAGE,		/* HR 050601 */
	XAW_LFLN,								/* 11 */
	XAW_RTLN,								/* 12 */
	XAW_HSLIDE,
	XAW_LFPAGE,		/* HR 050601 */
	XAW_RTPAGE,		/* HR 050601 */
	XAW_ICONIFY,
	XAW_HIDE,		/* HR 210801 */
	XAW_TOOLBAR,		/* Extended XaAES widget */
	XAW_BORDER,			/* Extended XaAES widget HR 280102: used for border sizing. */
	XAW_MENU,			/* Extended XaAES widget HR 270801: must be drawn last. */
/* Number of available XA_WIDGET slots in a the window for default/standard widgets */
	XA_MAX_WIDGETS
} XA_WIDGETS;

/* Widget positions are defined as relative locations */
typedef struct
{
	XA_RELATIVE relative_type;	/* Where is the position relative to? */
	RECT r;						/* Position */
	XA_WIDGETS n;				/*     index */
	XA_WIND_ATTR mask;			/* HR: disconnect NAME|SMALLER etc from emumerated type XA_WIDGETS */
	int rsc_index;			/* HR: If a bitmap widget, index in rsc file */
	bool top;					/* HR: does the widget add to the number widgets at the top of the window. */
} XA_WIDGET_LOCATION;

/* Window Widget */
typedef struct xa_widget
{
	struct xa_widget *next;		/* For future use. */
	XA_WIDGET_LOCATION loc;		/* Location of widget relative to window extents */
	WidgetBehaviour				/* Function pointers to the behaviours of the widget */
		*display, *click, *dclick, *drag, *release;
	OB_STATE  state;			/* Current status (selected, etc) */
	XA_WIDGETS type;			/* HR: For convenience, makes it possible to dusconnect type from index */
	G_i   x, y,					/* If we are activated because we've been clicked on, this is the */
								/* relative location of the click (click_object_widget)*/
	      mx, my;				/* absolute mouse location. */
	int   s,					/* HR: 280801: we must be able to use the original button and state. */
	      k,
	      clicks,				/* HR: Pass the number of clicks, might be usefull */
		  arrowx,				/* HR: WM_ARROWED msg type */
		  xarrow,				/* HR 181201: reverse action when right clicked. */
		  limit,				/* HR: on which limit to stop */
		  xlimit,				/* HR 181201: for reverse action */
		  slider_type;			/* HR: which slider should move for scroll widget */
	void *stuff;				/* Pointer to widget dependant context data, if any */
	int  start;				/* HR: If stuff is a OBJECT tree, we want start drawing here */
} XA_WIDGET;

/* Pending action from a widget */
typedef struct xa_pending_widget
{
	XA_WIDGET *widg;				/* Pointer to widget for which this action is pending */
	struct xa_window *wind;			/* Window to which the widget is connected */
	WidgetBehaviour *action;		/* Function to call */
	G_i   x, y;
	int   offs;						/* slider information */
	RECT d;							/* distance information */
	int  xy;						/* compass when border sizing */
	bool cont;
} XA_PENDING_WIDGET;

/* Extra details for a slider widget */

typedef struct
{
	int position,		/* Actual position of the slider (0-1000(SL_RANGE)) */
	    length;			/* Length (0-1000(SL_RANGE)) */
	RECT r;				/* physical */
} XA_SLIDER_WIDGET;

#define ZT_A	1
#define ZT_B	2
#define ZT_C	3
#define ZT_D	4

/* Rectangle List entry */
typedef struct xa_rect_list
{
	struct xa_rect_list *next;
	RECT r;			/* Dimensions of segment */
} XA_RECT_LIST;

typedef enum window_type
{
	created_for_CLIENT    = 0,
/* All of the following flags indicate at least that a windows workarea is compleyely
   occupied by (part of) the dialoge root object. */
	created_for_FMD_START = 1,
	created_for_FORM_DO   = 2,
	created_for_POPUP     = 4,
	created_for_WDIAL     = 8,		/* HR 251101 */
	created_for_TOOLBAR   = 16,		/* HR 190202 */
	created_for_AES       = 0x100
} WINDOW_TYPE;

/* Callback for a window's auto-redraw function */
/* HR: (*)() */
typedef int WindowDisplay (LOCK lock, struct xa_window *wind);

/* Window status codes */
typedef enum
{
	XAWS_CLOSED,
	XAWS_OPEN,
	XAWS_ICONIFIED
} XAWS;

/* Window Descriptor */
typedef struct xa_window
{
	struct xa_window *next,	/* Window list stuff	- next is the window below */
	                 *prev;	/*						- prev is the window above (both NULL terminated) */
	XA_WIND_ATTR
	     active_widgets,	/* Summary of the current standard widgets for the window */
	     save_widgets;		/* Remember active_widgets if iconified */
	bool nolist,			/* If true, dont put in the window_list. For embedded listboxes mainly. */
	     thinwork,			/* if true and colour then work := single line box */
	     wa_wheel,			/* HR 111002: Client wants to receive WA_WHEEL */
	     outline_adjust,	/* For outlined root object put ny XaAES in a window:
	                           let the window draw the 3 pixel space that emanates from construction. */
	     dial_followed;		/* HR: false immediate after opening a dial window.
	                               true after first objc_draw. */
	RECT max,				/* Creator dimension's, maximum for sizing */
	     r,					/* Current dimensions */
	     ro,				/* HR: Original dimemsions when iconified */
		 wa,				/* user work area */
		 bd,				/* border displacement */
		 ba,				/* border area for use by border sizing facility. */
		 pr;				/* previous dimensions */
		 
	RECT *remember;			/* Where to store the current position for remembering. */
	XA_CLIENT *owner;
	int   handle,			/* Window handle */
	      is_open,			/* Flag - is the window actually open? */
	      window_status,	/* Window status */
	      frame;			/* HR: Size of the frame (0 for windowed listboxes) */
	XA_RECT_LIST *rect_list,	/* The rectangle list for redraws in this window */
	             *rect_user,	/* User (wind_get) rect list current pointer */
	             *rect_start,	/* Start of the rectangle list memory block */
	             *rect_prev,	/* Remember the first rectangle */
	             prev_rect;
	void *background;		/* Pointer to a buffer containing the saved background */
	WINDOW_TYPE dial;		/* Flag - 1 = this window was created by form_dial, */
							/* so don't destroy it until the form_dial(FMD_FINISH) */
							/*      - 2 = created by form_do() */
							/*      - 4 = otherwise created on behalf of the AES */
							/*      - 8 = or created on behalf of wdlg_xxx extension. */
	WindowDisplay  *redraw;	/* Pointer to the window's auto-redraw function (if any) */
	WindowKeypress *keypress;	/* Pointer to the window's keyboard handler function (if any) */
	WindowDisplay  *destructor;	/* Pointer to the window's destructor function (auto-called on window deletion if a fully auto window) */
	SendMessage *send_message;	/* Pointer to the internal message handler for this window (to be handled by the creator) */
	OBJECT *winob;			/* HR: Tree and index of a sub window (The parent object of the window) */
	int winitem;			/*      currently used by list boxes */
#if USER_WIDGETS
	XA_WIDGET_LIST *user_widgets;		/* Pointer to a list of user added widgets */
#endif
	XA_WIDGET *tool;		/* If dialogue or popup: which widget is used. */
	XA_WIDGET widgets[XA_MAX_WIDGETS];	/* The windows standard widget set (array for speed) */
	XA_TREE widg_info,		/* Holds the object tree information for def_widgets. */
	        menu_bar,		/*   "         "              "      for a menu bar. */
	        toolbar;		/*   "         "              "      for a tool bar. */
	Path name,info;			/* HR 271101: wind_set makes copies. */
} XA_WINDOW;

typedef struct win_base			/* HR: open and closed windows in separate lists. */
{
	XA_WINDOW *first,*last;
} WIN_BASE;

XA_WINDOW *get_top(void);
extern XA_WINDOW *root_window;
#define window_list S.open_windows.first

/* HR (*)()    prefer '*' outside typedef */
typedef void fsel_handler(LOCK lock, char *path, char *file);		/* HR */
typedef int scrl_click(LOCK lock, OBJECT *form, int objc);		/* HR */
typedef void scrl_vis(struct scroll_info *list, struct scroll_entry *s);

/* HR:  The FS_LIST box is the place holder and the
        entrypoint via its TOUCHEXIT flag.
        The list box itself is turned into a full fledged window.
*/

/* Directory entry flags */
typedef enum scroll_entry_type
{
	FLAG_DIR        = 1,
	FLAG_EXECUTABLE = 2,
	FLAG_LINK       = 4,
	FLAG_PENDING    = 8,		/* For system alerts if the update lock is set. */
	FLAG_MAL        = 0x100,	/* text part is malloc'd and must be freed. */
	FLAG_ENV        = 0x200
} SCROLL_ENTRY_TYPE;

typedef struct scroll_entry
{
	char *text;					/* Text to display */
	OBJECT *icon;				/* Icon/object to display to the left of text (if any) */
	struct scroll_entry *next;	/* Next element */
	struct scroll_entry *prev;	/* Previous element */
/* This simple number makes everything so easy */
	G_i n;					/* HR: element number in the list */
	SCROLL_ENTRY_TYPE
	    flag;					/* HR */
	char the_text[0];			/* if text included in malloc it is here.
									Let entry->text point to here.
									FLAG_MAL is off */
} SCROLL_ENTRY;

/* HR: please NO local prefixes! */

typedef void scrl_widget(struct scroll_info *list);

typedef struct scroll_info
{
	LOCK lock;
	XA_WINDOW *wi,				/* HR: make the scroll box a real window */
	          *pw;				/* HR: If the listbox is part of a windowed dialogue, we must know that,
	                                   otherwise we couldnt move that window (rp_2_ap). */
	XA_TREE *wt;				/* HR 290702 */
	OBJECT *tree;				/* HR: originating object */
	G_i item;
	SCROLL_ENTRY
		*start,					/* Pointer to first element */
		*cur,					/*            current selected element */
		*top,					/*            top-most displayed element */
		*bot,					/*            bottom_most displayed element */
		*last;					/*            last element */
	char *title;				/* Title of the list */
	/* The following simple numbers make everything so easy */
	G_i   n,					/* Number of elements in the list */
		  s,					/* HR: Number of elements that fits in the box */
	      v,					/* HR: number of characters that fit the width of the box */
	      left,					/* HR: Portion of the line that is left of the visible part */
	      max,					/* HR: Maximum length of line allowed */
	      state;				/* Extended status info for scroll list */
	scrl_click *dclick,			/* HR Callback function for double click behaviour */
	           *click;			/* HR Callback function for single click behaviour */
	scrl_widget *slider,		/* HR slider calc function */
	            *closer,		/* HR closer function */
	            *fuller;		/* HR fuller function */
	scrl_vis *vis;				/* HR check visibility */
} SCROLL_INFO;

/* SCROLL_INFO .status bits */
#define SCRLSTAT_UP		1		/* Scroll up is clicked on */
#define SCRLSTAT_DOWN	2		/* Scroll down is clicked on */
#define SCRLSTAT_SCROLL	4		/* Scroller drag is clicked on */
#define SCRLSTAT_RDB	8		/* Redraw buttons only */

typedef enum
{
	NO_MENU,
	IN_TITLE,
	IN_MENU,
	IN_DESK
} TASK_STAGE;

typedef enum
{
	NO_TASK,
	ROOT_MENU,
	MENU_BAR,
	POP_UP
} TASK_TY;

typedef struct menu_task
{
	TASK_STAGE stage;
	XA_WINDOW *popw;
	int   ty,
	      titles,
		  menus,
		  about,
		  border,
	      clicked_title,
		  pop_item,
		  point_at_menu,
		  clients,
		  exit_mb,
		  omx,
		  omy;
	G_i	  x,
		  y;
	RECT  bar,drop;
	XA_MOUSE_RECT
	       em;
	void   *Mpreserve;
	TASK   *entry;
	OBJECT *root;
	G_i   rdx, rdy;		/* root displacements */
} MENU_TASK;

typedef struct drag_task
{
	RECT in,out,dr;
	G_i  x,y;
} DRAG_TASK;

typedef struct task_administration_block
{
	struct task_administration_block *nx,*pr,	/* different concurrent tasks */
	                                 *nest;		/* stages of a recursive task (like sub menu's) */ 
	int reply,locker;
	TASK_TY ty;
	int timeout;	/* Normally 0, otherwise the frequency that we call active_function with */
	LOCK lock;
	XA_CLIENT *client;
	XA_WINDOW *wind;
	XA_WIDGET *widg;
	TASK *task;		/* general task pointer */
	AESPB *pb;
	bool scroll;
	int dbg,dbg2,dbg3;
	union
	{
		MENU_TASK menu;
		DRAG_TASK drag;
	} task_data;
} Tab;

typedef struct shared
{
	WIN_BASE   open_windows,
	         closed_windows,	/* HR: open and closed windows in separate lists. */
	           side_windows;	/*     list of other special windows like menus popups etc. */
	int   update_lock,			/* wind_update() locks */
	      mouse_lock,
	      update_cnt,
	      mouse_cnt;
	XA_CLIENT *client_list,	 			/* The clients database */
	          *Clients[MAX_PID];		/* for Pid2Client */
	OPT_LIST *app_options;			/* HR 240901: individual option settings. */
} SHARED;

typedef struct common
{
	int vh,					/* Virtual workstation handles used by the AES */
	      AESpid,					/* The AES's MiNT process ID */
		  DSKpid;				/* HR The desktop programs pid, if any */
	      home_drv;
	G_i   P_handle,				/* Physical workstation handles used by the AES */
	      global_clip[4];
	Path home,					/* XaAES's home location */
	     cmd_name;				/* Name of the Aes command pipe */
	XA_CLIENT
	     *Aes,					/* HR static pid array;  */
	     						/* HR 230501: a client didnt call appl_exit, so signal handler
	                               wants to remove the client from the AES. */
	     *pending_exit[MAX_CLIENT];

	bool shutdown,
		 mvalidate;
	long AES_in_pipe,			/* The AES instruction input pipe handle */
	     MOUSE_dev,				/* The /dev/mouse handle */
	     KBD_dev,				/* The MiNT keyboard device's file handle */
	     Salert_pipe;			/* The MiNT Salert() pipe's file handle */
/* HR: exteneded & generalized (was GeneralCallback & stuff) */
	Tab active_menu[CASCADE],
	    active_timeout,
	    *menu_base;
	int  menu_nest;				/* current depth of submenus */
	RECT iconify;				/* Positioning information for iconifying windows */
	void *Aes_rsc;				/* Pointer to the XaAES resources */
	char *env,					/* HR: new environment */
	     *strings[STRINGS];		/* HR: pointers to environment variables from mint & config file */
	XA_WINDOW *focus;			/* Only 1 of 2: the top window(window_list) or root_window. */
	Path desk;					/* Remember the desk path for Launch desk. */
	int  mouse;				/* Remember mouse shape */
	MFORM *mouse_form;			/* Remember mouse form */
} COMMON;

/* HR 210501: definitions for form_alert.
   :-)  The object tree was cloned, but NOT the texts.
*/
#define MAX_X 100
#define MAX_B 20
#define ALERT_LINES 6
#define ALERT_BUTTONS 3

typedef struct alertxt
{
	char text  [ALERT_LINES  ][MAX_X+1],	/* Texts to display in the alert */
		 button[ALERT_BUTTONS][MAX_X+1];	/* Text for buttons (note: use MAX_X to get coercible row type) */
} ALERTXT;

#endif
