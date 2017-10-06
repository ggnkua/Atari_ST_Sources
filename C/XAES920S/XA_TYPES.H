/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_TYPES_H_
#define _XA_TYPES_H_
#include "xa_aes.h"
#include RSCHNAME
#include MEMORY_HNAME
#include "xa_defs.h"
#include "display.h"

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
	NOLOCKS   =   0,
	appl      =   1,
	newclient =   2,
	trap      =   4,
	winlist   = 010,
	desk      = 011,
	clients   = 012,
	fsel      = 014,
	update    = 020,
	mouse     = 021,
	envstr    = 022,
	pending   = 024,
	NOLOCKING = -1
} LOCK;


#include "messages.h"

/*-----------------------------------------------------------------
 * Display descriptions
 *-----------------------------------------------------------------*/

typedef enum {D_LOCAL = 0, D_TCP = 1} XA_DISPLAY;

typedef struct {
	short bg_col,			/* Colour used for backgrounds */
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
	short colours,				/* Number of colours available */
	      planes,				/* Number of planes in screen */
	      c_max_w, c_max_h,		/* Maximum character dimensions in pixels */
	      c_min_w, c_min_h,		/* Minimum (small font) character dimensions in pixels */
	      standard_font_height,	/* Needed for appl_getinfo */
	      standard_font_id,
	      standard_font_point,
	      small_font_id,
	      small_font_point,
	      small_font_height;	/* Needed for appl_getinfo */
} XA_SCREEN;

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
	long bcon;
	struct
	{
		unsigned char
			state,				/* Ensure conterm bit 3 is set, so we get the keyboard status in here. */
			scan,				/* Put the normalized keycode in here. */
			dum,
			code;
	}conin;
} CONKEY;

typedef struct rawkey		/* HR */
{
	CONKEY raw;
	unsigned short
		aes,				/* AES keycode */
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
	XAWAIT_DIALOG	= 0x400,	/* Waiting for a form_do() dialog to exit */
	XAWAIT_CHILD	= 0x800,	/* Waiting for a non-parallel shel_write() child process to exit */
/* HR: menu rectangle event */
	XAWAIT_MENU		= 0x1000,	/* AES private */
} WAITING_FOR;


/* Client Types HR: change to names from compendium (some time :-) */
#define XA_CT_APP	0x01	/* Client is a standard app */
#define XA_CT_ACC	0x02	/* Client is an accessory */

typedef enum		/* HR: compendium */
{
	APP_FIRST,
	APP_NEXT,
	APP_DESK,
	APP_SYSTEM      = 0x01,
	APP_APPLICATION = 0x02,
	APP_ACCESSORY   = 0x04,
	APP_SHELL       = 0x08
} CLIENT_TYPE;

typedef void TASK(struct task_administration_block *tab);

typedef struct
{
	short flags;
	RECT m1,m2;
	TASK *t1,*t2;	/* used by tasking */
} XA_MOUSE_RECT;

#define ATTACH_MAX 64			/* This is per menu_bar!!!! */

typedef struct menu_attachments	/* HR */
{
	char *text;		/* outplaced menu entry text, to which a left arrow is appended */
	OBJECT *tree;		/* attached menu tree */
	short item;
} XA_MENU_ATTACHMENT;

/*-----------------------------------------------------------------
 * Object Handler Structures
 *-----------------------------------------------------------------*/

/*
 * Object display callback parameter
 * - This only exists because Lattice 5.52 has a bug that crashes the compiler
 *   if you have:
 *		typedef void (*ObjectDisplay)(OBJECT *ob, short parent_x, short parent_y);
 * HR: (*)()    I removed the (*...) out of ALL typedef'd prototypes. :-)
 */
/* HR: Well, it appeared to be handy as well. */
/* HR: 070101  completely combined with XA_TREE. */


/* Object display function type */
typedef void ObjectDisplay(LOCK lock, struct widget_tree *wt);	/* HR (*)() */
/* Object handler function type */
typedef void ObjectHandler(LOCK lock, struct widget_tree *wt); 	/* HR */

/* Object Tree based widget descriptor */

typedef struct widget_tree
{
	OBJECT *tree;				/* The object tree */
	short item;					/* Only used by menu widgets. */
	RECT r;						/* HR: Why not do the addition (parent_x+ob_x) once in the caller? */
								/* HR: And set a usefull RECT as soon as possible, ready for use in
								       all kind of functions. */
	short *state_mask;
	short parent_x,				/* Keep both in: dont need to change everything in a single effort */
	      parent_y,
	      edit_obj,				/* Index of the current editable text field (if any) */
	      edit_pos,				/* Cursor position within the text field (if any) */
	      pid,					/* The tree widget would be owned by a different app to
								   the actual window (like the menu bar on the root window) */
	      lastob;				/* Can be used to validate item number */
	bool is_menu,				/* HR: true when the tree is a menu or part of it. */
	     zen;					/* HR: true when the tree is embedded in a window.
	                                  Do not shadow and border. */
	ObjectHandler *handler;		/* Handler vec for direct handling */
	void *extra;				/* Extra info if needed (texts for alert) */
} XA_TREE;

/* used for linking resources's per client */
typedef struct xa_rscs
{
	struct xa_rscs *next, *prior;
	short id, ct;
	void *rsc;
} XA_RSCS;

typedef struct			/* Kernal command packet structure */
{
	short pid;			/* Client pid */
	unsigned short cmd;	/* Command code */
	AESPB *pb;			/* Pointer to AES parameter block */
} K_CMD_PACKET;

typedef struct
{
	char pipe[32];
	short ctrl[5];	
	K_CMD_PACKET packet;
	AESPB pb;
} APP_CONTRL;

/* Main client application descriptor */
typedef struct xa_client
{
	struct xa_client *next, *prior;
	short pid;				/* HR: clients process identifier number */
	int client_end,			/* File handle's of the clients internal reply pipe */
	    kernel_end;
	bool init,				/* HR: true between appl_init & appl_exit */
	     killed,			/* HR: true if the clients memory is destroyed. */
	     secured;			/* HR: true if secure remove_refs applied. */
	XA_AESMSG_LIST *msg;	/* Pending AES messages */
	WAITING_FOR waiting_for;		/* What types of event(s) the client is waiting for */
	AESPB *waiting_pb;		/* Parameter block for whatever the client is waiting for */
	short client_mouse;		/* The cursor to use when this is top application */
	MFORM *client_mouse_form;
	GLOBAL *globl_ptr;		/* Pointer to the client's globl array (so we can fill in the resource
							   address field later). */
	RSHDR *std_resource;		/* Pointer to the client's standard GEM-style single resource file */
	short rsct;				/* HR: count up/down the loaded resources. Used by XA_alloc, XA_free */
/* HR: */
	XA_MENU_ATTACHMENT *attach;		/* extended ob_spec's for submenus */
	XA_TREE std_menu,		/* The client's standard GEM-style menu-bar widget */
	        wt;				/* Widget tree for everything except form_do(). */
	Path home_path;			/* The directory that the client was started in */
	char *cmd_tail;			/* The command tail of the process (if launched by shell_write) */
	bool heap_tail;			/* If true, cmd_tail is a malloc */
	char *cmd_name;			/* The full filename used when launching the process (if launched by shell_write) */
	bool heap_name;			/* If true, cmd_name is a malloc */
	char name[NICE_NAME+2];	/* The clients 'pretty' name (possibly set by menu_register) */
	char proc_name[10];		/* The clients 'official' (ie. used by appl_find) name. */
	short parent;			/* Process id of the client's "parent" process (if launched with shell_write) */
	struct xa_window *zen;	/* Pointer to a window that could be about to become a dialog */
	void *temp;				/* Temporary storage */
	OBJECT *desktop;		/* Pointer to the client's custom desktop object tree (if any) */
	short type;				/* What type of client is this? */
	bool half_screen;		/* HR: true if the client has issued wind_get(WF_SCREEN, ...) */
	XA_MOUSE_RECT em;		/* HR: Needed. whether threads or not */

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
} XA_CLIENT;

/* HR:  removing the (*) makes it more usable */
typedef
unsigned long AES_function(LOCK lock, XA_CLIENT *client, AESPB *pb);		/* HR: pass the client structure. */

typedef struct xa_function_table
{
	AES_function *f;		/* function pointer */
	bool d;					/* true id call direct */
	short dum;		/* make it 8 bytes, benefits scaling in 020 */
} XA_FTAB;

typedef struct button_data
{
	XA_CLIENT *client;
	short x, y, b, clicks, ks;
	bool got,have;
} BUTTON;

/*-----------------------------------------------------------------
 * Windows & Widgets
 *----------------------------------------------------------------- */

/* HR (*)() */
/* A function of the type used for widget behaviours is a 
   'WidgetBehaviour'. */
typedef bool WidgetBehaviour(LOCK lock, struct xa_window *wind, struct xa_widget *widg);

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

/* Widget positions are defined as relative locations */
typedef struct
{
	XA_RELATIVE relative_type;	/* Where is the position relative to? */
	RECT r;						/* Position */
} XA_WIDGET_LOCATION;

/* Widget Callback/Behaviour Identifiers */
typedef enum
{
	XACB_DISPLAY,
	XACB_CLICK,
	XACB_DCLICK,
	XACB_DRAG,
	XACB_RELEASE,		/* HR 050601 */
	COUNT_XACB
} XACB;

/* Widget Index's */

typedef enum
{
	XAW_TITLE,
	XAW_CLOSE,
	XAW_FULL,
	XAW_MOVER,			/* Not actually used like the others */
	XAW_INFO,
	XAW_RESIZE,
	XAW_UPLN,
	XAW_DNLN,
	XAW_VSLIDE,
	XAW_UPPAGE,		/* HR 050601 */
	XAW_DNPAGE,		/* HR 050601 */
	XAW_LFLN,
	XAW_RTLN,
	XAW_HSLIDE,
	XAW_LFPAGE,		/* HR 050601 */
	XAW_RTPAGE,		/* HR 050601 */
	XAW_ICONIFY,
	XAW_MENU,			/* Extended XaAES widget */
	XAW_TOOLBAR,		/* Extended XaAES widget */
/* Number of available XA_WIDGET slots in a the window for default/standard widgets */
	XA_MAX_WIDGETS
} XA_WIDGETS;

/* Window Widget */
typedef struct xa_widget
{
	XA_WIDGET_LOCATION loc;			/* Location of widget relative to window extents */
	WidgetBehaviour *behaviour[COUNT_XACB];	/* Callback function pointers to the behaviours of the widget */
	OB_STATES state;					/* Current status (selected, etc) */
	XA_WIDGETS type;				/* HR: For convenience, makes it possible to dusconnect type from index */
	short mask;						/* HR: disconnect NAME|SMALLER etc from emumerated type XA_WIDGETS */
	short click_x, click_y;			/* If we are displaying because we've been clicked on, this is the location  */
									/* of the click (this is only used by the slider widget really) */
	short rsc_index,			/* HR: If a bitmap widget, index in rsc file */
		  arrowx,				/* HR: WM_ARROWED msg type */
		  limit,				/* HR: on which limit to stop */ 
		  slider_type;			/* HR: which slider should move for scroll widget */
	void *stuff;				/* Pointer to widget dependant context data, if any */
	short start;				/* HR: If stuff is a OBJECT tree, we want start drawing here */
} XA_WIDGET;

typedef struct xa_widget_list
{
	XA_WIDGET this;				/* ugly!! :-) */
	struct xa_widget_list *next;
} XA_WIDGET_LIST;

/* Pending action from a widget */
typedef struct xa_pending_widget
{
	XA_WIDGET *widg;				/* Pointer to widget for which this action is pending */
	struct xa_window *wind;			/* Window to which the widget is connected */
	WidgetBehaviour *action;		/* Function to call */
	short x, y,
	      offs;						/* slider information */
	bool wait;
} XA_PENDING_WIDGET;

/* Extra details for a slider widget */

typedef struct
{
	short position;		/* Actual position of the slider (0-1000) */
	short length;		/* Length (0-1000) */
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
	created_by_FMD_START = 1,
	created_by_FORM_DO   = 2
} WINDOW_TYPE;

/* Callback for a window's auto-redraw function */
/* HR: (*)() */
typedef short WindowDisplay (LOCK lock, struct xa_window *wind);
typedef short WindowKeypress (LOCK lock, struct xa_window *wind, unsigned short keycode, unsigned short nkcode, CONKEY raw);

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
	bool nolist;			/* If true, dont put in the window_list. For embedded listboxes mainly. */
	RECT max,				/* Creator dimension's, maximum for sizing */
	     r,					/* Current dimensions */
	     ro,				/* HR: Original dimemsions when iconified */
		 wa,				/* user work area */
		 bd,				/* border displacement */
		 pr;				/* previous dimensions */
		 
	RECT *remember;			/* Where to store the current position for remembering. */
	XA_CLIENT *owner;
	short handle,			/* Window handle */
	      pid,				/* Client pid of the window's owner */
	      behalf,			/* HR: pid on behalf of which a window is created: dialogues, alerts, and fileselector. */
	      is_open,			/* Flag - is the window actually open? */
	      window_status,	/* Window status */
	      frame,			/* HR: Size of the frame (0 for windowed listboxes) */
	      widgets_on_top;	/* Number of widgets on the top bar, not including the title */
	XA_RECT_LIST *rect_list,	/* The rectangle list for redraws in this window */
	             *rect_user,	/* User (wind_get) rect list current pointer */
	             *rect_start;	/* Start of the rectangle list memory block */
	void *background;		/* Pointer to a buffer containing the saved background */
	short bgx, bgy;			/* Location the saved background came from */
	WINDOW_TYPE dial;		/* Flag - 1 = this window was created by form_dial, */
							/* so don't destroy it until the form_dial(FMD_FINISH) */
							/*      - 2 = created by form_do() */
	WindowDisplay  *redraw;	/* Pointer to the window's auto-redraw function (if any) */
	WindowKeypress *keypress;	/* Pointer to the window's keyboard handler function (if any) */
	WindowDisplay  *destructor;	/* Pointer to the window's destructor function (auto-called on window deletion if a fully auto window) */
	SendMessage *send_message;	/* Pointer to the internal message handler for this window (to be handled by the creator) */
	OBJECT *winob;			/* HR: Tree and index of a sub window (The parent object of the window) */
	short item;				/*      currently used by list boxes */
#if USER_WIDGETS
	XA_WIDGET_LIST *user_widgets;		/* Pointer to a list of user added widgets */
#endif
	XA_WIDGET widgets[XA_MAX_WIDGETS];	/* The windows standard widget set (array for speed) */
	XA_TREE tree_info;		/* Holds the object information for def_widgets. */
} XA_WINDOW;


typedef struct win_base			/* HR: open and closed windows in separate lists. */
{
	XA_WINDOW *first,*last;
} WIN_BASE;

#define root_window S.open_windows.last
#define window_list S.open_windows.first

/* HR (*)()    prefer '*' outside typedef */
typedef void fsel_handler(LOCK lock, char *path, char *file);		/* HR */
typedef short scrl_click(LOCK lock, OBJECT *form, short objc);		/* HR */
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
	short n;					/* HR: element number in the list */
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
	OBJECT *tree;				/* HR: originating object */
	short item;
	SCROLL_ENTRY
		*start,					/* Pointer to first element */
		*cur,					/*            current selected element */
		*top,					/*            top-most displayed element */
		*bot,					/*            bottom_most displayed element */
		*last;					/*            last element */
	char *title;				/* Title of the list */
	/* The following simple numbers make everything so easy */
	short n,					/* Number of elements in the list */
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
	short ty,
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
		  omy,
		  x,
		  y;
	RECT  bar,drop;
	XA_MOUSE_RECT
	       em;
	void   *Mpreserve;
	TASK   *entry;
	OBJECT *root;
	short rdx, rdy;		/* root displacements */
} MENU_TASK;

typedef struct drag_task
{
	RECT in,out,dr;
	short x,y;
} DRAG_TASK;

typedef struct task_administration_block
{
	struct task_administration_block *nx,*pr,	/* different concurrent tasks */
	                                 *nest;		/* stages of a recursive task (like sub menu's) */ 
	short pid,reply,locker;
	TASK_TY ty;
	short timeout;	/* Normally 0, otherwise the frequency that we call active_function with */
	LOCK lock;
	XA_CLIENT *client;
	XA_WINDOW *wind;
	XA_WIDGET *widg;
	TASK *task;		/* general task pointer */
	AESPB *pb;
	short dbg,dbg2,dbg3;
	union
	{
		MENU_TASK menu;
		DRAG_TASK drag;
	} task_data;
} Tab;

typedef struct config
{
	char *half_screen_buffer;	/* HR: for wind_get WF_SCREEN (people like to use what is offered, whether the idee is good or not) */
	long half_screen_size,
	     half_screen_max;
	Path launch_path,			/* Initial path for launcher */
         scrap_path,			/* Path to the scrap directory */
         acc_path;				/* Path to desk accessory directory */
	short font_id,				/* Font id to use */
          standard_font_point,	/* Size for normal text */
          medium_font_point,	/* The same, but for low resolution screens */
          small_font_point,		/* Size for small text */
/* HR: display modes of window title */
	      topname,
          backname,
          ted_filler
          ;
	bool no_xa_fsel,
	     naes,					/* N.Aes 3d compatability */
	     mintmouse,				/* Use MiNTs dev/mouse */
	     superprogdef,			/* Run progdefs in supervisor mode */
	     auto_program,
	     point_to_type,
	     fsel_cookie;
	short windowner;			/* HR 030401: display window owner in title. */
	bool menu_windowed;			/* HR: menus run in a window. See lines.app run underneath the pulldown menu. :-) */
	char *mouse_name,
	     cancel_buttons[NUM_CB][CB_L];
#if FILESELECTOR && defined(FSEL_MENU)
	char Filters[23][16];
#endif
	MENU_BEHAVE menu_behave;	/* HR: pull, push or leave */
} CFG;

typedef struct shared
{
	WIN_BASE   open_windows,
	         closed_windows;	/* HR: open and closed windows in separate lists. */
	short update_lock,			/* wind_update() locks */
	      mouse_lock,
	      update_cnt,
	      mouse_cnt;
	XA_CLIENT *client_list,	 			/* The clients database */
	          *Clients[MAX_PID];		/* for Pid2Client */
} SHARED;

typedef struct common
{
	short vh,					/* Virtual workstation handles used by the AES */
	      P_handle,				/* Physical workstation handles used by the AES */
	      AESpid,					/* The AES's MiNT process ID */
		  DSKpid;				/* HR The desktop programs pid, if any */
	      home_drv,
	      global_clip[4];
	Path home;					/* XaAES's home location */
	char *cmd_name;				/* Name of the Aes command pipe */
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
	short menu_nest;			/* current depth of submenus */
	RECT iconify;				/* Positioning information for iconifying windows */
	void *Aes_rsc;				/* Pointer to the XaAES resources */
	char *env,					/* HR: new environment */
	     *strings[STRINGS];		/* HR: pointers to environment variables from mint & config file */
	XA_WINDOW *focus;			/* Only 1 of 2: the top window(window_list) or root_window. */
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
