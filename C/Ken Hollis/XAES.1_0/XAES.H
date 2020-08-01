/********************************************************************
 *																1.10*
 *	XAES: The Extended Application Environment Systems				*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 ********************************************************************/

#include <aes.h>
#include <vdi.h>
#include <stdio.h>

/*	Hmmm...  XAES really isn't that compatible is it? */
#ifdef	__GNUC__
#error	"XAES is not compatible with Gnu C or Gnu C++"
#elif	__ALCYON__
#error	"XAES is not compatible with Alcyon C"
#elif	__PROSPERO__
#error	"XAES is not compatible with Prospero C"
#elif	__SOZOBON__
#error	"XAES is not compatible with Sozobon C"
#elif	__LASER_C__
#error	"XAES is not compatible with Laser C"
#endif

#ifdef __AES__
#ifndef DEBUG
#error	"PLEASE ENABLE DEBUGGING!"
#endif

#define	GLOBAL			/* A globally useful routine			*/
#define	LOCAL	static	/* A module-only routine				*/

#ifdef __TURBOC__
#pragma warn -pia		/* Possibly Incorrect Assignment is off	*/
#pragma warn -sus		/* Sustain strange warnings				*/
#endif

#ifndef min
#define min(a,b)	((a) < (b) ? (a) : (b))	/* Minimum value	*/
#define max(a,b)	((a) > (b) ? (a) : (b))	/* Maximum value	*/
#endif

#define	BOOL	int		/* Extended boolean values				*/
#define	TRUE	1		/* True boolean value					*/
#define	FALSE	0		/* False boolean value					*/
#define	FAIL	-1		/* Fail boolean value (supported too!)	*/
#define	NOMORE	FAIL	/* No more windows available			*/

#define	MAX_WINDOWS		100		/* Maximum number of windows	*/
#define AES_VERSION		_GemParBlk.global[0]	/* Version of AES */

#define	UNUSED(x)		((void)(x))		/* Any unused variables */

#define WC_NOTOBJECTABLE	0	/* Window can be closed w/o asking */
#define WC_OBJECTABLE		1	/* Pause before closing window	*/
#define	WC_FORCED			2	/* Force window to be closed	*/
#define	WC_NOTCLOSABLE		3	/* Window cannot be closed		*/

/* Extended window KIND creation flags */
#ifndef SMALLER
#define	SMALLER		0x2000		/* Window smaller gadget		*/
#endif
#define	CASCADE		0x1000		/* Cascade window gadget		*/
#define	MENUWORK	0x4000		/* Menu workspace				*/
#define	OPTIONS		0x8000		/* Options (not yet used)		*/

/* These signify the starting point of user defined messages */
#define	WM_USER		0x0500		/* User defined window messages */
#define	WF_USER		0x1000		/* User defined window fixes	*/
#define	WM_MAGIC	0x0500		/* Additive for our messages	*/
#define	WF_MAGIC	0x3E20		/* Additive for our window fixes */

#define	WM_XAES		(WM_USER + WM_MAGIC)	/* Remind you of	*/
#define	WF_XAES		(WF_USER + WF_MAGIC)	/* Windows??? :)	*/
#define	WM_XAESKEY	(WM_XAES + 0x0100)		/* Keyer events		*/
#define	WM_XAESPS	(WM_XAESKEY + 0x0400)	/* Program events	*/

/* Activation events */
#define	WM_DIALOG	(WM_XAES + 0)	/* Dialog					*/
#define	WM_KEYBD	(WM_XAES + 1)	/* Keyboard					*/
#define	WM_BUTTON	(WM_XAES + 2)	/* General button			*/
#define	WM_TEXT		(WM_XAES + 3)	/* Text						*/
#define	WM_HOTKEY	(WM_XAES + 4)	/* Hotkey (object activation by ALT) */
#define	WM_FKEY		(WM_XAES + 5)	/* Function key				*/
#define	WM_HELP		(WM_XAES + 6)	/* Help key					*/
#define	WM_UNDO		(WM_XAES + 7)	/* Undo key					*/
#define	WM_MENU		(WM_XAES + 8)	/* Menu						*/
#define	WM_CLIP		(WM_XAES + 9)	/* Clipboard usage			*/
#define	WM_TIMECHG	(WM_XAES + 10)	/* Change timer information */
#define	WM_GETHELP	(WM_XAES + 11)	/* Help about info			*/
#define	WM_SLIDER	(WM_XAES + 12)	/* Slider message			*/
#define	WM_ICONIFY	(WM_XAES + 13)	/* Iconified message		*/
#define	WM_UNICONIFY	(WM_XAES + 14)	/* Uniconified message	*/

/* Keyer events */
#define	WM_CREATED	(WM_XAESKEY + 0)	/* Window created		*/
#define	WM_KILL		(WM_XAESKEY + 1)	/* Window killed		*/
#define	WM_TIMER	(WM_XAESKEY + 2)	/* Timer event has elapsed */
#define	WM_PAINT	(WM_XAESKEY + 3)	/* Dispatch "redraw"	*/
#define	WM_COPIED	(WM_XAESKEY + 4)	/* Window just copied	*/

/* Program status events */
#define	WM_CLOSEALL	(WM_XAESPS + 0)	/* All windows closed message */
#define	WM_PROGEND	(WM_XAESPS + 1)	/* Program termination message */

/* Window states */
#define	W_NULLIFIED			0x0000	/* Window has no state		*/
#define W_OPEN				0x0001	/* Window is currently opened */
#define W_MINIMIZED 		0x0002	/* Window is minimized		*/
#define W_UNUNTOPPABLE		0x0004	/* Window cannot be un-untopped */
#define W_BEVENT			0x0008	/* Window accepts bkgnd clicks */
#define	W_FLYING			0x0010	/* Window is a flying dialog */
#define	W_TEXT				0x0020	/* Window is a text window	*/
#define	W_TIMER				0x0040	/* Window is a timer		*/
#define	W_DIALOG			0x0080	/* Window is a dialog		*/
#define	W_DESKTOP			0x0100	/* Window is the desktop	*/
#define	W_UNSIZABLE			0x0200	/* Window cannot be sized	*/
#define	W_ICONIFIED			0x0400	/* Window is iconified		*/

/* Window styles */
#define	W_CUSTOMWINDOW		0x0001	/* Window has custom elements */

/* Window get and set messages */
#define WF_MINIMIZE 	(WF_XAES + 0)	/* Minimizable window	*/
#define WF_UNUNTOPPABLE	(WF_XAES + 1)	/* Cannot untop window	*/
#define	WF_FLYING		(WF_XAES + 2)	/* Flying Dialog window */
#define	WF_TEXT			(WF_XAES + 3)	/* Text window			*/
#define	WF_TIMER		(WF_XAES + 4)	/* Timer window			*/
#define	WF_DIALOG		(WF_XAES + 5)	/* Dialog window		*/
#define	WF_UNSIZABLE	(WF_XAES + 6)	/* Cannot size window	*/
#define	WF_CUSTOMWIN	(WF_XAES + 7)	/* Customized window	*/
#define	WF_SLIDEPOS		(WF_XAES + 8)	/* Slider position		*/
#define	WF_ICONIFIED	(WF_XAES + 9)	/* Iconified window		*/
#define	WF_UNICONIFIED	(WF_XAES + 10)	/* Uniconified window	*/

/* Window callback methods */
#define	CBK_NONE		0x0000	/* No callbacks are provided */
#define	CBK_OBJECTS		0x0001	/* Callbacks only on object selection */
#define	CBK_WINDOW		0x0002	/* Callbacks on any window actions */
#define	CBK_ACTION		0x0004	/* Callbacks on an action-by-action basis */
#define	CBK_CREATION	0x0008	/* Callbacks only on window creation */
#define	CBK_DELETION	0x0010	/* Callbacks only on window deletion */

/* Size-box mode indices; these are self-explanatory. */
#define	S_UPPERLEFT		1
#define	S_TOP			2
#define	S_UPPERRIGHT	3
#define	S_RIGHT			4
#define	S_LOWERRIGHT	5
#define	S_BOTTOM		6
#define	S_LOWERLEFT		7
#define	S_LEFT			8

/* Object Creation types */
#define	WC_WINDOW		1		/* Create a window				*/
#define WC_SWINDOW		2		/* Create a small window		*/
#define	WC_FLYING		3		/* Create a flying dialog		*/
#define	WC_SLIDER		4		/* Create an object slider		*/
#define	WC_POPUP		5		/* Create an object popup		*/
#define	WC_TEXTGADGET	6		/* Create an object text gadget */
#define	WC_GRAPHGADGET	7		/* Create an object graphic gadget */
#define	WC_LISTBOX		8		/* Create a popup list box		*/
#define	WC_TOOLBAR		9		/* Create a toolbar				*/
#define	WC_ICONIFIED	10		/* Create an iconified window	*/

/* Editing modes */
#define	EDIT_INSERT		1		/* Edit insert mode				*/
#define	EDIT_REPLACE	2		/* Edit replace mode			*/

/* Mouse forms.  These are the custom mouse forms that are called with
   WGrafMouse.  These are currently used for the custom windows (will
   be used) and for loading and initializing stuff.. */
#define	INIT_MOUSE		50		/* Computer-type mouse			*/
#define	LOAD_MOUSE		51		/* Resource mouse				*/
#define	LRSLIDE_MOUSE	52		/* Left/right slider			*/
#define	UDSLIDE_MOUSE	53		/* Up/down slider				*/
#define	URMOVE_MOUSE	54		/* Upper-right sizer			*/
#define	ULMOVE_MOUSE	55		/* Upper-left sizer				*/
#define	LLMOVE_MOUSE	56		/* Lower-left sizer				*/
#define	LRMOVE_MOUSE	57		/* Lower-right sizer			*/
#define	CLIP_MOUSE		58		/* Clipboard mouse				*/
#define	DIALOG_MOUSE	59		/* Dialog box mouse				*/
#define	HELP_MOUSE		60		/* Help mouse					*/
#define	IBARHELP_MOUSE	61		/* I-BAR Help mouse				*/
#define	TSIZER_MOUSE	62		/* Top sizer mouse				*/
#define	LSIZER_MOUSE	63		/* Left sizer mouse				*/
#define	RSIZER_MOUSE	64		/* Right sizer mouse			*/
#define	BSIZER_MOUSE	65		/* Bottom sizer mouse			*/
#define	MOVER_MOUSE		66		/* Mover mouse					*/
#define	NOMODAL_MOUSE	67		/* Outside of modal mouse		*/
#define	NOWINDOW_MOUSE	68		/* Outside of window mouse		*/
#define	ANIMATED_MOUSE	300		/* Animated mouse				*/
#define	COLOR_MOUSE		301		/* Colour mouse (if ever)		*/

/* Mouse form tools.  This is for mouse animation, and for other
   tools if the programmer wants to store mouse shapes from loading
   in from memory, or if they create a mouse tool.  Very handy. */
#define	GET_MOUSE		400		/* Get current mouse form index */
#define	SAVE_MOUSE		401		/* Save current mouse form index */
#define	PREV_MOUSE		402		/* Get previous mouse form index */
#define	NEXT_MOUSE		403		/* Get next mouse form index	*/
#define	FIRST_MOUSE		404 	/* Get first mouse form index	*/
#define	LAST_MOUSE		405		/* Get last mouse form index	*/
#define	CLEAR_MOUSE		406		/* Clear all mice indices		*/
#define	FIND_MOUSE		407		/* Find mouse form index		*/
#define	NEWPOS_MOUSE	408		/* Reposition counter			*/

/* Timer status modes.  The PAUSED and RESUMED modes are not yet
   functioning, because we don't have multiple timer access yet.
   These are passed in msg_buf[4]. */
#define	T_NOTEXIST	-1			/* Timer is non-existent		*/
#define T_STOPPED	0			/* Timer stopped				*/
#define T_RUNNING	1			/* Timer running				*/
#define	T_PAUSED	T_STOPPED	/* Timer "paused"				*/
#define	T_RESUMED	T_RUNNING	/* Timer resumed (running)		*/
#define	T_ALLSTOP	2			/* All timers stopped			*/
#define	T_ALLRUN	3			/* All timers running			*/
#define	T_ALLPAUSE	T_ALLSTOP	/* All timers "paused"			*/
#define	T_ALLRESUME	T_ALLRUN	/* All timers resumed (running) */

/* Checks for the all window kill */
#define	K_NO_STOP	0			/* Kill all windows, no stopping */
#define	K_ASK		1			/* Ask before killing windows	*/
#define	K_ACC		2			/* Close windows in an accessory */

/* Extended Object Types */
#define SCALE			16		/* Automatic scaling of image	*/
#define	FLYING			17		/* Flying dialog mover			*/
#define CUSTOM			18		/* Custom arrow buttons			*/
#define UNDERLINE		19		/* Underlined text				*/
#define	BOXFRAME		20		/* Box frame for selections		*/
#define	HELPBTN			21		/* Activation button under [HELP] */
#define	CYCLEBTN		22		/* Cycle button for popup menus */
#define	TEXTEFFECTS		23		/* Object text effects			*/
#define	CUSTBTN			24		/* Custom Selection and Radio boxes */
#define	DROPDOWN		25		/* Dropdown button for dropdown selections */
#define	MENUTEAR		30		/* Detatchable menu bar			*/
#define	UNDOBTN			31		/* Activation button under [UNDO] */
#define	MENULINE		40		/* Thick line for separator		*/
#define	SLIDERLEFT		100		/* Move slider left				*/
#define	SLIDERRIGHT		101		/* Move slider right			*/
#define	SLIDERUP		102		/* Move slider up				*/
#define	SLIDERDOWN		103		/* Move slider down				*/
#define	SLIDERTRACK		104		/* Slider track					*/
#define	SLIDERSLIDE		105		/* Slider mover					*/

/* Standard Extended Object Flags */
#ifdef OBFLAGS11					/* (New AES bindings available?) */
#define HANDSLIDE		OBFLAGS12	/* Hand shown for slider	*/
#define MENUSIDE		OBFLAGS13	/* Menu with side items		*/
#define	BOXFRAMETITLE	OBFLAGS15	/* Box frame title with box around it */
#else
#define	HANDSLIDE		0x0800	/* See above */
#define	MENUSIDE		0x2000
#define	BOXFRAMETITLE	0x8000
#endif

/* Extended Object States */
#ifdef OBSTATE15				/* New AES bindings available?	*/
#define	MENUTYPE	OBSTATE13	/* Object is a menu title		*/
#define	ALREADYMOD	OBSTATE14	/* Already modified for sizing (temporary state) */
#define	FAKED3D		OBSTATE15	/* Faked 3D setting for Falcon	*/
#else
#define	MENUTYPE	0x2000		/* See above */
#define	ALREADYMOD	0x4000
#define	FAKED3D		0x8000
#endif

/* WDie types */
#define	FORCE_EXIT		-1		/* Force exit with query		*/
#define	FORCE_EXIT_ABS	-2		/* Absolute force exit (no query) */

/* WFindOwner returns */
#define	W_NOTOWNER		-1		/* Not owner of this window		*/

/* Scaling settings */
#define NO_SCALING		0x0000	/* No scaling is done			*/
#define SCALING			0x0001	/* All/complete scaling is performed */
#define TEST_SCALING	0x0002	/* Icon mask scaling is done	*/
#define DARK_SCALING	0x0004	/* Icon data scaling is done	*/

/* XAES STANDARD Configuration bits */
#define	X_LEFTBORDER	0x0001	/* Allow left border moving		*/
#define	X_WINXCOMPAT	0x0002	/* Allow WinX compatibility		*/
#define	X_MOUSEGADGETS	0x0004	/* Change mouse under element	*/
#define	X_MOUSESLIDERS	0x0008	/* Change mouse to slider shape */
#define	X_ROUNDOBJECTS	0x0010	/* Rounded objects allowed		*/
#define	X_ROUNDSHADOW	0x0020	/* Rounded shadowing allowed	*/
#define	X_NICELINE		0x0040	/* Niceline dashing allowed		*/
#define	X_GENEVACOMPAT	0x0080	/* Geneva compatibility			*/
#define	X_DRAW3DCOMPAT	0x0100	/* Draw-3D two-color compatibility */
#define	X_AUTOCHANGE	0x0200	/* Auto change mouse allowed	*/
#define	X_ELEMENTSEL	0x0400	/* Select elements on click		*/
#define	X_MEDEMUL		0x0800	/* Medium resolution 3D Colors	*/

/* XAES EXTENDED Configuration bits */
#define	X_INTERFACE		0x0001	/* InterFace-like object drawing */
#define	X_ACTIVEDRAG	0x0002	/* Active redrawing windows		*/
#define	X_BACKGROUND	0x0004	/* Background clickable windows */

/* XAES Window centering flags */
#define	XW_MOUSECENTER	1		/* Center window to mouse		*/
#define	XW_SCREENCENTER	2		/* Center window to screen		*/
#define	XW_PHYSICCENTER	3		/* Center window to logical screen */

/* XAES 3D drawing styles */
#define	DRAW_STANDARD	1		/* Standard (and crappy) TOS look */
#define	DRAW_MULTITOS	2		/* Standard MultiTOS look		*/
#define	DRAW_GENEVA		3		/* Geneva look					*/
#define	DRAW_ZOOM		4		/* Zoom look (offset of MOTIF)	*/
#define	DRAW_MOTIF		5		/* Motif look (X11R6 type)		*/
#define	DRAW_LTMF		6		/* Let 'em Fly 1.30 look		*/
#define	DRAW_XAES		7		/* Our own drawing style		*/

/* Slider types */
#define	SLIDER_HOR		1		/* Horizontal slider type		*/
#define	SLIDER_VER		2		/* Vertical slider type			*/
#define	SLIDER_2D		3		/* Free-moving slider type		*/

/* Object routine creation types */
#define	MOUSE_DOWN		1		/* Mouse press event			*/
#define	MOUSE_UP		2		/* Mouse release event			*/
#define	MOUSE_MOVE		3		/* Mouse slider move event		*/
#define	MOUSE_CLICK		4		/* Mouse click event			*/

/* Attribute flags for WChangeAttribute */
#define	TEXT_ATTRIB		1		/* Change text string			*/
#define	TEMPLATE_ATTRIB	2		/* Change template string		*/
#define	VALID_ATTRIB	3		/* Change validation string		*/
#define	FONT_ATTRIB		4		/* Change font size				*/
#define	JUSTIFY_ATTRIB	5		/* Change justification of text */
#define	BORDCOL_ATTRIB	6		/* Change border color			*/
#define	TEXTCOL_ATTRIB	7		/* Change text color			*/
#define	TRANS_ATTRIB	8		/* Change transparency mode		*/
#define	FILLPTN_ATTRIB	9		/* Change fill pattern			*/
#define	INCOL_ATTRIB	10		/* Change fill (interior) color */
#define	THICK_ATTRIB	11		/* Change thickness of object	*/

#define	XC_INITIALIZE	1		/* Initialization callback def	*/
#define	XC_DEINITIALIZE	2		/* Deinitialization callback def */
#define	XC_STARTUP		3		/* Startup callback def			*/
#define	XC_EXIT			4		/* Exit callback def			*/

#define	OUTSIDE_DIALOG	-1		/* Outside of any dialog area	*/

#define	XCallInitializeCallback		DoCallback(XC_INITIALIZE)
#define	XCallDeinitializeCallback	DoCallback(XC_DEINITIALIZE)
#define	XCallStartupCallback		DoCallback(XC_STARTUP)
#define	XCallExitCallback			DoCallback(XC_EXIT)

typedef struct timer
{
	long	clock;				/* Clock ticks to wait for		*/
	long	ev_mtcount;			/* Timer counter				*/
	void	*user;				/* User parameters to give Dispatcher routine */
	int		status;				/* Status of timer				*/
	int		tick_count;			/* Number of clock ticks past	*/
} TIMER;

/* Window routine callbacks...  Quite a workout if you ask me! */
typedef struct callbacks {
	BOOL	(*MN_SELECTED_callback)(int, int, int, int);
	BOOL	(*WM_REDRAW_callback)(int, int, int, int, int);
	BOOL	(*WM_TOPPED_callback)(int);
	BOOL	(*WM_CLOSED_callback)(int);
	BOOL	(*WM_FULLED_callback)(int);
	BOOL	(*WM_ARROWED_callback)(int, int);
	BOOL	(*WM_HSLID_callback)(int, int);
	BOOL	(*WM_VSLID_callback)(int, int);
	BOOL	(*WM_SIZED_callback)(int, int, int, int, int);
	BOOL	(*WM_MOVED_callback)(int, int, int, int, int);
	BOOL	(*WM_NEWTOP_callback)(int);
	BOOL	(*WM_UNTOPPED_callback)(int);
	BOOL	(*WM_ONTOP_callback)(int);
	BOOL	(*AC_OPEN_callback)(int);
	BOOL	(*AC_CLOSE_callback)(int);
	BOOL	(*CT_UPDATE_callback)();	/* Undocumented, not used */
	BOOL	(*CT_MOVE_callback)();		/* Undocumented, not used */
	BOOL	(*CT_NEWTOP_callback)();	/* Undocumented, not used */
	BOOL	(*AP_TERM_callback)(void);
	BOOL	(*AP_TFAIL_callback)(int);
	BOOL	(*AP_RESCHG_callback)(int);
	BOOL	(*SHUT_COMPLETED_callback)(int);
	BOOL	(*RESCHG_COMPLETED_callback)(int);
	BOOL	(*AP_DRAGDROP_callback)(int, int, int, int, int, long);
	BOOL	(*CH_EXIT_callback)(int, int);
} CALLS;

typedef struct window {
	struct window *prev, *next;	/* Linked-list for windows		*/
	int		handle;				/* Window AES handle			*/
	int		state, oldstate;	/* Window state settings		*/
	int		style, oldstyle;	/* Window style settings		*/
	int		kind, oldkind;		/* Window display settings		*/
	int		editmode;			/* Editing mode					*/
	int		edobject, edpos;	/* Editing object and position	*/
	int		wind_type;			/* Large or small window		*/
	int		icon_num;			/* Object number of the actual icon */
	int		infpos, infend;		/* Info display and end display indices */
	char	title[128], info[128];	/* Window name information	*/
	char	*icon_text;			/* Text to replace in icon field */
	BOOL	has_edit;			/* Window has an editable object */
	BOOL	edit_disp;			/* Window's cursor is displayed */
	GRECT	size, minimum, maximum;	/* Current size, min & max size */
	GRECT	oldsize;			/* Size saved at iconify time	*/
	OBJECT	*tree, *wind, *iconify;	/* Tree, window, and iconified trees */
	CALLS	*callbacks;			/* Window callback routines		*/
	TIMER	timer;				/* Timer window information		*/
	void	*WndDispatcher;		/* Dispatcher linked to window	*/
	void	*user;				/* User information				*/
} WINDOW;

typedef struct {
	void	(*Initialize)(void);		/* Initialization routine */
	void	(*Deinitialize)(void);		/* Deinitialize routine */
	void	(*Startup)(void);			/* Startup routine		*/
	void	(*Exit)(void);				/* Exit routine			*/
} INITS;

typedef struct {
	OBJECT	*tree;				/* Flying dialog tree			*/
	void	*flybuffer;			/* Flying dialog saved screen buffer */
} FLYDIAL;

typedef struct
{
	long cookie_id;				/* Cookie ID number				*/
	long cookie_value;			/* Points to your cookie data	*/
} COOKIE;

typedef struct {
	int		textattributes[10];	/* Text saved attributes		*/
	int		fillattributes[5];	/* Fill saved attributes		*/
	int		lineattributes[6];	/* Line saved attributes		*/
} XVDIVARS;
typedef struct {	long	magic;				/* Magic number to check if buffer installed */	int		vdihandle;			/* VDI Handle of buffer (= VDIhandle) */	int		pxy[8];				/* Point XY array for memory buffer */	MFDB	mfdb,scr;			/* Memory Form Definition Blocks of graphics */	char	data[];				/* Any extra data				*/} Buffer;

typedef struct slider
{
	int		slide_pos;			/* Slider position				*/
	int		slide_max;			/* Slider maximum position		*/
	long	slide_acc;			/* Slider accumulator			*/
	long	slide_step;			/* Slider step setting for accumulator */
	int		slide_tstep;		/* Slider step rate for positioning */
	int		slide_type;			/* Slider type (Horizontal or Vertical) */
	int		slide_increase;		/* Slider increase object		*/
	int		slide_decrease;		/* Slider decrease object		*/
	int		slide_slider;		/* Slider slide object			*/
	int		slide_track;		/* Slider track object			*/
} SLIDER;

typedef struct
{
	int		curr_sel;			/* Currently selected object	*/
	char	*sel_text;			/* Selection text				*/
} POPUP;

typedef struct
{
	void	(*mouse_down)(int, int, int, int, int);
	void	(*mouse_up)(int, int, int, int, int);
	void	(*mouse_move)(int, int, int, int, int);
	void	(*mouse_click)(int, int, int, int);
} ROUTS;

typedef struct extinfo
{
    char    *te_ptext;         /* Pointer to text string           */
    char    *te_ptmplt;        /* Pointer to text template         */
    char    *te_pvalid;        /* Pointer to validation string     */
    int     te_font;           /* Font size                        */
    int     te_junk1;          /* Unused                           */
    int     te_just;           /* Text justification               */
    struct {
		unsigned int bord_color		: 4;	/* Border color		   */
		unsigned int text_color		: 4;	/* Text display color  */
		unsigned int transparency	: 1;	/* vswr_mode to use    */
		unsigned int fill_ptn		: 3;	/* Fill pattern        */
		unsigned int in_color		: 4;	/* Fill pattern color  */
    }		te_color;          /* Color                            */
    int     te_junk2;		   /* Unused                           */
    int     te_thickness;      /* Border thickness                 */
	char	te_character, nullterm;	/* Character/nullterm string   */
    int     te_txtlen;         /* Text length                      */
    int     te_tmplen;         /* Length of template               */
	int		te_hotkey;		   /* Hotkey storage				   */
	SLIDER	te_slider;         /* Slider information               */
	POPUP	te_popup;          /* Popup information                */
	POPUP	te_listbox;        /* Listbox information              */
	ROUTS	te_routines;	   /* Button-routine callbacks		   */
	void	*oldparm;		   /* Old ub_parms                     */
	int		oldtype;		   /* Old object type                  */
} EXTINFO;

typedef struct mouseforms
{
	int	forms[16];
} MICE;

typedef struct window_owner_info
{
	int	handle;
	int	owner;
} WOWNERS;

typedef struct
{
	char *wind_title;
	char *hline1, *hline2, *hline3, *hline4, *hline5, *hline6,
		 *hline7, *hline8;
} WHELP;

typedef struct image
{
	int		*hi_on, *hi_off, *lo_on, *lo_off;
} IMAGE;

typedef struct images
{
	int		count;
	IMAGE	*image;
} IMAGES;

typedef struct
{
	int		sizer_ul[2];
	int		sizer_top[2];
	int		sizer_ur[2];
	int		sizer_right[2];
	int		sizer_lr[2];
	int		sizer_bot[2];
	int		sizer_ll[2];
	int		sizer_left[2];
	int		mover[2];
	int		hor_slide_hatch[2];
	int		hor_track_hatch[2];
	int		ver_slide_hatch[2];
	int		ver_track_hatch[2];
} ELEMENT;

/* 	1 = MultiTOS
 *	2 = Geneva
 *	3 = Zoom
 *	4 = Motif
 *	5 = XAES
 */
typedef struct
{
	int		shade_lower_part[5];
	int		shade_upper_part[5];
	int		shade_fill[5];
} SHADES;

typedef struct
{
	int		topped_focus;
	int		untopped_focus;
} FCOL;

typedef struct
{
	int		config1;
	int		config2;
	int		wind_center;
	int		draw_3d;
	int		hotkey_color;
	int		active_text_color;
	int		inactive_text_color;
	ELEMENT	window_elements;
	SHADES	button_shades;
	FCOL	focus_colors;
} CONFIG;

extern	int		VDIhandle;
extern	int		Life, Return, Ap_ID;
extern	int		gr_cw, gr_ch, gr_bw, gr_bh, small_font, large_font;
extern	int		color_font, image_w, image_h, big_img, num_colors;
extern	int		num_planes, config1, config2, cur_mouse, cur_mouse_form;
extern	int		edit_old_x, edit_old_y, num_configs, GenevaInstalled;
extern 	int		colorsave1, colorsave2, colorsave3;
extern	char	*prgnameheader;
extern	void	*_MainDispatcher, *_MainKeyDispatcher, *dpbuffer;
extern	void	*bgbuffer;
extern	BOOL	helpmode;
extern	MFDB	screen;
extern	MICE	mouseform;
extern	GRECT	desk;
extern	INITS	GlobInits;
extern	CONFIG	xaes;
extern	OBJECT	*wl_menubar, *WINDTREE, *WINPOPUP, *CASCPOPUP;
extern	OBJECT	*FULLPOPUP, *WINPOPUP, *CASCPOPUP, *FULLPOPUP;
extern	OBJECT	*RTPOPUP, *HELPWINDOW, *LBOX, *P_UP, *ALERTWIN;
extern	OBJECT	*ERRORWIN;
extern	WINDOW	*WindowChain;
extern	WOWNERS	owned_winds[MAX_WINDOWS];
extern	XVDIVARS SaveHandles;

#include "xproto.h"

#else
#error	"Compilation stopped.  Where is AES.H's __AES__ define?"
#endif