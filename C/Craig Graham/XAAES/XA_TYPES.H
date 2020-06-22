/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_TYPES_H_
#define _XA_TYPES_H_
#include <VDI.H>
#include "K_DEFS.H"

/*-----------------------------------------------------------------
 * Display descriptions
 *-----------------------------------------------------------------*/
 
typedef enum { D_LOCAL=0, D_TCP=1 } XA_DISPLAY;

typedef struct {
	short bg_col;			/* Colour used for backgrounds */
	short fg_col;			/* COlour used for foregrounds */
	short b_r_col;			/* Colour used for bottom right 3d edge */
	short t_l_col;			/* Colour used for top left 3d edge */
	short border_col;		/* Colour used for edging */
	short highlight_col;	/* Colour used for highlighting */
} XA_COLOUR_SCHEME;

typedef struct {
	short x,y,w,h;				/* Screen dimensions */
	short colours;				/* number of colours available */
	short planes;				/* number of planes in screen */
	XA_DISPLAY display_type;	/* The type of display we are using */
	short P_handle;				/* VDI physical workstation handle (for D_LOCAL screens) */
	short V_handle;				/* VDI virtual workstation handle (for all screens) */
	short c_max_w,c_max_h;		/* Maximum character dimensions in pixels */
	short c_min_w,c_min_h;		/* Minimum (small font) character dimensions in pixels */
	XA_COLOUR_SCHEME dial_colours;	/* Colour scheme used for dialogs */
	short standard_font_height;	/* needed for appl_getinfo */
	short standard_font_id;
	short standard_font_point;
	short small_font_id;
	short small_font_point;
	short small_font_height;	/* needed for appl_getinfo */
} XA_SCREEN;

/*-----------------------------------------------------------------
 * Client application data structures
 *-----------------------------------------------------------------*/

/* List of Pending AES messages */
typedef struct xa_aesmsg_list {
	struct xa_aesmsg_list *next;
	short message[8];
} XA_AESMSG_LIST;

/*
   Codes for what types of event an app is currently waiting for
   - I've used the same bit allocation as evnt_multi() here, but there is
     the extra XAWAIT_MULTI bit to indicate we are waiting from evnt_multi()
     as opposed to one of the individual routines (as return values are different).
*/
#define XAWAIT_KEY		0x01
#define XAWAIT_BUTTON	0x02
#define XAWAIT_MOUSE1	0x04
#define XAWAIT_MOUSE2	0x08
#define XAWAIT_MESSAGE	0x10
#define XAWAIT_TIMER	0x20
#define XAWAIT_MULTI	0x100	/* Waiting for an evnt_multi() */
#define XAWAIT_DIALOG	0x200	/* Waiting for a form_do() dialog to exit */
#define XAWAIT_CHILD	0x400	/* Waiting for a non-parallel shel_write() child process to exit */

struct xa_window;
struct xa_widget;

/* Client Types */
#define XA_CT_APP	0x01	/* Client is a standard app */
#define XA_CT_ACC	0x02	/* Client is an accessory */

/* Main client application descriptor */
typedef struct {
	int clnt_pipe_rd;		/* File handle of the clients internal reply pipe (client end) */
	int clnt_pipe_wr;		/* File handle of the clients internal reply pipe (server end) */
	int reply_pipe;			/* File handle of the clients external reply pipe */
	XA_AESMSG_LIST *msg;	/* Pending AES messages */
	struct xa_pending_widget *widget_active;	/* Pending active widget (if any) */
	short waiting_for;		/* What types of event(s) the client is waiting for */
	AESPB *waiting_pb;		/* Parameter block for whatever the client is waiting for */
	short client_mouse;		/* The cursor to use when this is top application */
	MFORM *client_mouse_form;
	short *globl_ptr;		/* Pointer to the client's globl array (so we can fill in the resource
							   address field later). */
	void *std_resource;		/* Pointer to the client's standard GEM-style single resource file */
	OBJECT *std_menu;		/* Pointer to the client's standard GEM-style menu-bar */
	char home_path[150];	/* The directory that the client was started in */
	char *cmd_tail;			/* The command tail of the process (if launched by shell_write) */
	char *cmd_name;			/* The full filename used when launching the process (if launched by shell_write) */
	char name[20];			/* The clients 'pretty' name (possibly set by menu_register) */
	char proc_name[9];		/* The clients 'official' (ie. used by appl_find) name. */
	short parent;			/* Process id of the client's "parent" process (if launched with shell_write) */
	struct xa_window *zen;	/* Pointer to a window that could be about to become a dialog */
	void *temp;				/* temporary storage */
	OBJECT *desktop;		/* Pointer to the client's custom desktop object tree (if any) */
	short client_type;		/* What type of client is this? */
} XA_CLIENT;

/*-----------------------------------------------------------------
 * Windows & Widgets
 *----------------------------------------------------------------- */

/* A pointer to a function of the type used for widget behaviours is a 
   'WidgetCallback'. */
typedef short (*WidgetCallback)(struct xa_window *wind, struct xa_widget *widg);

/* Relative coordinate types */
typedef enum {	RT=0,	/* Top right */
				RB=1,	/* Bottom right */
				LT=2,	/* Top left */
				LB=3,	/* Bottom left */
				CT=4,	/* Top centred */
				CB=5	/* Bottom centred */
			} XA_RELATIVE;

/* Widget positions are defined as relative locations */
typedef struct {
	XA_RELATIVE relative_type;	/* Where is the position relative to? */
	short x,y;					/* position */
} XA_WIDGET_LOCATION;

/* Object Tree based widget descriptor */
typedef struct {
	OBJECT *tree;				/* The object tree */
	short edit_obj;				/* Index of the current editable text field (if any) */
	short edit_pos;				/* Cursor position within the text field (if any) */
	short owner;				/* The tree widget would be owned by a different app to
								   the actual window (like the menu bar on the root window) */
} XA_WIDGET_TREE;

/* Widget Callback/Behaviour Identifiers */
#define COUNT_XACB		4
#define XACB_DISPLAY	0
#define XACB_CLICK		1
#define XACB_DCLICK		2
#define XACB_DRAG		3

/* Widget Status */
typedef enum { XAW_PLAIN=0, XAW_SELECTED=1, XAW_TOOLBARSTATE=3 } XA_WIDGET_STATUS;

/* Window Widget */
typedef struct xa_widget {
	XA_WIDGET_LOCATION loc;		/* Location of widget relative to window extents */
	WidgetCallback behaviour[COUNT_XACB];	/* Callback function pointers to the behaviours of the widget */
	XA_WIDGET_STATUS stat;		/* Current status (selected, etc) */
	short w,h;					/* dimensions */
	short click_x,click_y;		/* If we are displaying because we've been clicked on, this is the location  */
								/* of the click (this is only used by the slider widget really) */
	void *stuff;				/* Pointer to widget dependant context data, if any */
} XA_WIDGET;

typedef struct xa_widget_list {
	XA_WIDGET this;
	struct xa_widget_list *next;
} XA_WIDGET_LIST;

/* Pending action from a widget */
typedef struct xa_pending_widget {
	XA_WIDGET *widg;
	struct xa_window *wind;
	WidgetCallback action;
} XA_PENDING_WIDGET;

/* Extra details for a slider widget */
typedef struct {
	short position;		/* Actual position of the slider (0-1000) */
	short length;		/* Length (0-1000) */
} XA_SLIDER_WIDGET;

#define ZT_A	1
#define ZT_B	2
#define ZT_C	3
#define ZT_D	4

/* Rectangle List entry */
typedef struct xa_rect_list {
	struct xa_rect_list *next;
	short x,y,w,h;			/* dimensions of segment */
} XA_RECT_LIST;

/* Number of available XA_WIDGET slots in a the window for default/standard widgets */
#define XA_MAX_WIDGETS	15

/* Widget Index's */
#define XAW_TITLE		0
#define XAW_CLOSE		1
#define XAW_FULL		2
#define XAW_MOVER		3		/* Not actually used like the others */
#define XAW_INFO		4
#define XAW_RESIZE		5
#define XAW_UP			6
#define XAW_DOWN		7
#define XAW_VSLIDE		8
#define XAW_LEFT		9
#define XAW_RIGHT		10
#define XAW_HSLIDE		11
#define XAW_ICONIFY		12
#define XAW_MENU		13		/* Extended XaAES widget */
#define XAW_TOOLBAR		14		/* Extended XaAES widget */

/* Callback for a window's auto-redraw function */
typedef short (*WindowDisplayCallback)(struct xa_window *wind);
typedef short (*WindowKeypressCallback)(struct xa_window *wind, unsigned short keycode);

/* Window status codes */
#define XAWS_CLOSED		0
#define XAWS_OPEN		1
#define XAWS_ICONIFIED	2

/* Window Descriptor */
typedef struct xa_window {
	struct xa_window *next;	/* Window list stuff	- next is the window below */
	struct xa_window *prev;	/*						- prev is the window above (both NULL terminated) */
	long active_widgets;	/* Summary of the current standard widgets for the window */
	XA_WIDGET widgets[XA_MAX_WIDGETS];	/* The windows standard widget set (array for speed) */
	XA_WIDGET_LIST *user_widgets;		/* Pointer to a list of user added widgets */
	short x,y,w,h;			/* current dimensions */
	short handle;			/* Window handle */
	short owner;			/* client pid of the window's owner */
	short is_open;			/* flag - is the window actually open? */
	short window_status;	/* window status */
	short widgets_on_top;	/* Number of widgets on the top bar, not including the title */
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl_full;		/* The full rectangle list for redraws in this window */
	XA_RECT_LIST *rl_work;		/* The work area rectangle list for redraws in this window */
	XA_RECT_LIST *rl_work_cur;	/* Current pointer for the above */
#else
	XA_RECT_LIST *rect_list;	/* The rectangle list for redraws in this window */
#endif
	short wx,wy,ww,wh;		/* current user work area dimensions */
	short prev_x,prev_y,prev_w,prev_h;	/* Previous window coords */
	void *background;		/* pointer to a buffer containing the saved background */
	short bgx,bgy;			/* location the saved background came from */
	short created_by_FMD_START;	/* flag - 1=this window was created by form_dial, */
								/* so don't destroy it until the form_dial(FMD_FINISH) */
	WindowDisplayCallback redraw;	/* Pointer to the window's auto-redraw function (if any) */
	WindowKeypressCallback keypress;	/* Pointer to the window's keyboard handler function (if any) */
} XA_WINDOW;

#endif