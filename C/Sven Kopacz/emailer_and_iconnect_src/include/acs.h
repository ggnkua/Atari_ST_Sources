/*
 *		ACS.H		(c) 1991, 1992 Stefan Bachert	
 *
 *		Revision:	4 APR 1992
 *
 */

#ifndef __ACS__
#define __ACS__

/* uses types out of the following includes */

#include	<aes.h>
#include	<vdi.h>

#ifdef	__TURBOC__				/* cdecl is TC, Pure C only */
#else
# ifdef	LATTICE
#  define	cdecl	__stdargs
#  define	int		short
# else
#  define	cdecl
# endif
#endif


#ifndef NULL
#define NULL ((void *) 0L)
#endif

#ifndef FALSE
#define FALSE	(0)				/* Function FALSE value			*/
#endif

#ifndef TRUE
#define TRUE	(1)				/* Function TRUE value			*/
#endif

#ifndef FAIL
#define FAIL	(-1)			/* Function failure return val	*/
#endif

#ifndef OK
#define OK		(0)				/* Function success return val	*/
#endif

/*
 *	Global Types
 */

#define	swd	struct wd			/* local #undef */
swd;							/* recursive use: Awindow */
								/* Parameter Window, Object, Mumber */

typedef void (*Aaction) (void);
typedef swd *(*Acreate) (void *x);


typedef struct {				/* Extented Object */
	Aaction click;				/* action on exit, touchexit or dclick */
	Aaction drag;				/* action on drag */
	int ob_flags;				/* ob_flags, must be same as in OBJECT */
								/* since it will be checked */
	int key;					/* key for selecting */
	void *userp1;				/* user pointer */
	void *userp2;
	int mo_index;				/* mouse index upon this field */
								/* contains title number for menues */
	int type;					/* Object type (not AES type) */
	} AOBJECT;


typedef struct {				/* Mouse parameters */
	int	number;					/* Mousenumber 255=Userdef */
	MFORM *form;				/* Mouseform or NULL */
	} Amouse;


typedef struct {				/* Rectangle */
	int x,y,w,h;
	} Axywh;

	
typedef  struct	wd	{			/* Windowobject */
		/* Users part */
	void *user;					/* Users object pointer */
	int (*service) (swd *a,/* Service call */
		 int task, void *in_out);
	swd * (*create) (void *a);	/* create window passing window specific parameters*/
	int (* open) (swd* a);		/* open window return success */
	int (* init) (swd* a);		/* init window return success */
	OBJECT *work;				/* Object within window */
	void *reserved;				/* reserved pointer */
	int ob_edit, ob_col;		/* object nr and act column */
		/* GEM attributes */
	int	wi_id;					/* gem window id or -1 */
	int wi_kind;				/* window attributes */
    Axywh wi_act;				/* actual outer coordinates */
    Axywh wi_normal;			/* normal outer coordinates */
	Axywh wi_work;				/* inner size without menu */
	Axywh wi_slider;			/* last set slider (init -1) */
	int	wi_nx, wi_ny;			/* normal offset zero or negative */
	int snap_mask;				/* snap mask due to patter offset */
	char *name;					/* points to name */
	char *info;					/* points to info */
		/* ACS attributes */
	int type;					/* type of this window */
	int kind;					/* own attributes */
	int state;					/* state of window */
	int icon;					/* objectnr in root window, -1 if not */
	ICONBLK *iconblk;			/* defines the Iconimage, NULL means default Icon */
		/* Menue */
	OBJECT *menu;				/* menuetree OBJECT */
		/* Keyboard */
	void (* keys) (swd *x,		/* unknown key actions */
		int kstate, int key);
		/* mouse select */
	void (* obchange) (swd* a,	/* change state of this object */
		int obnr, int new_state);
		/* window attribute reactions */
	void (* redraw) (swd* a, Axywh *b);	/* Redraw */
	void (* topped) (swd* a);			/* Topped */
	void (* closed) (swd* a);			/* closed */
	void (* fulled) (swd* a);			/* fulled */
	void (* arrowed)(swd* a, int which);/* arrowed */
	void (* hslid)	(swd* a, int pos);	/* hslide */
	void (* vslid)	(swd* a, int pos);	/* vslide */
	void (* sized)  (swd* a, Axywh *b);	/* size */
	void (* moved)  (swd* a, Axywh *b);	/* move */
	} Awindow;


typedef	struct {				/* Description start */
	char magic [8];				/* Magic "ACS 102" */
	int version;				/* Version * 102 */
	int	dx,dy;					/* virtuell desktop increments */
	int flags;					/* commom flags */
	char acc_reg [32];			/* Accessory register message */
	Awindow *root;				/* Root window */
	Awindow *acc;				/* Accessory first window */
	Amouse mouse [32];			/* 32 Mouseforms */
	} Adescr;


typedef struct {				/* list of selected Objects */
	Awindow *window;			/* the objects belong to this window */
	int maxlen;					/* max entries in list */
	int actlen;					/* actual count */
	int next;					/* next entry return by Adr_next */
	int dragback;				/* drag still selected object back to origin */
	int x, y;					/* position during pick up */
	int rx, ry;					/* relativ dragged distance */
	int *array;					/* points to array of obnr's */
	} Asel;


/*
 *	Global Defines
 */

	/* description. flags */
#define AB_CLICKMENU	(0x0001)	/* menu drop down on click instead of touch */
#define AB_MOVIES		(0x0002)	/* draws moving, growing, shrink rectangle */
#define AB_HIDEPOINTER	(0x0008)	/* hide pointer on key input */
#define	AB_CENTERDIALOG (0x0010)	/* center dialog */

	/* Awindow. service */	/* generic */
#define AS_ACCLOSED		(1)			/* accessory closed, initialize correctly */
#define AS_TERM			(2)			/* terminate */
#define AS_ICONIZED		(3)			/* the window was iconized (in order to receive a free window id) */
#define AS_MOUSE		(4)			/* Mouse is upon the window */
#define AS_SELECTADD	(5)			/* added object in select list */
#define AS_SELECTDEL	(6)			/* deleted object in select list */
#define AS_UNTOPPED		(7)			/* ACS does not handle UNTOPPED, maybe the window want it */

#define AS_OPEN			(10)		/* Open the selected list of objects */
#define AS_DELETE		(11)		/* delete selected list */
#define AS_INFO			(15)		/* Info about Window */
#define AS_DRAGGED		(16)		/* Something dragged on windows ICON */

							/* desktop */
#define AS_PLACEICON	(100)		/* place icon, in_out = the window */
#define AS_REMICON		(101)		/* remove icon */
#define AS_GHOSTICON	(102)		/* change to ghost icon */
#define AS_NORMICON		(103)		/* chance from ghost icon to normal icon */
#define AS_NEWCALL		(104)		/* set new call */

	/* Awindow. kind */
#define	AW_ICON			(0x0001)	/* Iconizing Window instead of Terminating */
#define AW_GHOSTICON	(0x0002)	/* Ghost Icon from beginning */
#define AW_STAY			(0x0004)	/* do not change state of the window iconize/open */
#define AW_OBLIST		(0x0008)	/* inner object is a objects list */
#define AW_ICONACCEPT	(0x0010)	/* accept dragging on windows icon */
#define AW_UHSLIDER		(0x0020)	/* user administrated horizontal slider */
#define AW_UVSLIDER		(0x0040)	/* user administrated vertical slider */
#define AW_NOSCROLL		(0x0080)	/* no optimized scrolling */

	/* Awindow. state */
#define AWS_FULL		(0x0001)	/* State full */
#define AWS_DIALOG		(0x0002)	/* dialog is activ */
#define AWS_MODIFIED	(0x0004)	/* dependend information was changed call init before open */
#define AWS_MODAL		(0x0008)	/* a modal dialog is open for this window */
#define AWS_FORCEREDRAW	(0x0010)	/* forces a redraw */
#define AWS_LATEUPDATE	(0x0020)	/* send AS_UPATE after returning to main loop */
#define AWS_TERM		(0x0100)	/* Terminatesequence active, skip iconizing */

	/* OBJECT. ob_flags */
#define AEO				(0x8000)	/* Extended Object */
#define AO_DEFABLE		(0x4000)	/* defaultable Object */
#define AO_DRAGABLE		(0x2000)	/* dragable Object */
#define AO_ACCEPT		(0x1000)	/* accept dragable Object */
#define AO_SILENT		(0x0800)	/* object will NOT visual react (AO_ACCEPT) */

	/* OBJECT. ob_state */
#define AOS_FIXED		(0x8000)	/* Object tree is already fixed */
#define AOS_DCLICK		(0x4000)	/* last selection was a double click */
#define AOS_CONST		(0x2000)	/* Do not copy substructure, do not release (free) substructure */

	/* AOBJECT. type */
#define	AT_ICONWINDOW	(1)			/* iconized window */
#define	AT_NEW			(2)			/* new object */
#define	AT_TRASH		(3)			/* trash bin */


	/*	AOBJECT. key */
#define AO_SCANCODE		(0x8000)	/* contain scancode instead of vdi-code */

/* desktop icons size */
#define AREA_WIDTH		(80)		/* area for icons */
#define AREA_HEIGHT		(48)
#define FRAME			(8)			/* frame around Icon */

#undef swd							/* no one knows it any more */


/*
 *	Global Defines
 */

#define	PS	(127 + 1)			/* Pathsize */

/*
 *	Global Vars	(no Values)
 */
	/* Before ACSinit0() initialized !! */
	/* AES */
extern int gl_apid;			/* AES application ID */
extern int phys_handle;		/* workstation for aes */
extern int gl_wattr;		/* attribut width */
extern int gl_hattr;		/* attribut height */

extern Axywh desk;			/* desktop limits XYWH */
	/* VDI */
extern int vdi_handle;		/* virtual VDI workstation for ACS */
extern int gl_wbox;			/* cell width of standard char */
extern int gl_hbox;			/* cell height of standard char */
extern int gl_wchar;		/* max width of standard char*/
extern int gl_hchar;		/* max height of standard char */
extern int ncolors;			/* number of colors (2=mono) */
extern int nplanes;			/* number of colors expressed in planes */
	/* Pathes */
extern char appname [PS];	/* application complete name */
extern char apppath [PS];	/* application path */
extern char apppara [PS];	/* application parameter */
extern char appfrom [PS];	/* application called from */
extern char basename[20];	/* basename appname without extention */
	/* others */
extern long ev_mtcount;		/* Timerintervall in milli sec (initial 500 ms) */
extern int application;		/* runs as an application */
extern int multitask;		/* more than 1 applications possible */
extern int appexit;			/* application is in system termination mode */
extern Adescr *description;	/* surface description, pointer for late assignment */
extern Adescr ACSdescr;		/* Linked description */
extern Asel Aselect;		/* list of selected objects */
	/* context during callback pointer values */
extern Awindow *ev_window;	/* actual window */
extern OBJECT *ev_object;	/* actual object tree */
extern int ev_obnr;			/* actaul objectnumber, index */
extern int ev_mmox, ev_mmoy;/* Mouse position */
extern int ev_mmokstate;	/* Keyboard state */
extern int dia_abort;		/* Abort dialog */
extern MFDB screenMFDB;		/* exactly this */

/*
 *	Entries, substitute this handlers
 */

int ACSinit0 (void);	/* init entry before ACS initializing */
int ACSinit (void);		/* init entry after ACS initializing */
void ACSterm (void);	/* terminate entry before terminate ACS */
void ACSaboutme (void);	/* call used for 'about me' */
void ACSmessage (int *ev_mmgpbuf);	/* handle unprocessed messages */
void ACStimer (void);	/* called at end of event loop */

/* just to call orignal call */

void _ACSaboutme (void);
void _ACSmessage (int *ev_mmgpbuf);
void _ACSclose (void);

/*
 *	Windowhandling common Routines
 */

Awindow *Awi_wid (const int wid);		/* get window for gem window id */
Awindow *Awi_root (void);				/* return root window */
Awindow *Awi_list (void);				/* next window from total set */
void Awi_sendall						/* sends message to all windows */
	(int task, void *in_out);
void Awi_down (void);					/* cycle down windows */
void Awi_up (void);						/* cycle up windows */
void Awi_show (Awindow *window);		/* show window */
int Awi_init (Awindow *window);			/* Dummy init routine */
Awindow *Awi_create (const Awindow *x);	/* create a copy of window x */
int	Awi_open (Awindow *x);				/* open window */
void Awi_closed (Awindow *x);			/* close window */
void Awi_delete (Awindow *x);			/* free window */
void Awi_topped (Awindow *window);		/* top this window */
void Awi_fulled (Awindow *window);		/* fullsize window */
void Awi_sized (Awindow *window,		/* move/resize window */
		Axywh *new);
void Awi_moved (Awindow *window,		/* move/resize window */
		Axywh *new);
void Awi_diaend (void);					/* finish open dialog */
void Awi_diastart (void);				/* start dialog */
void Awi_keys (Awindow *window,			/* key input for dialog */
		int kstate, int key);
void Awi_obview (Awindow *window,		/* show area in work object coordinates */
		Axywh *xywh);
int Awi_service (Awindow *window,		/* very simple service routine */
	int task, void *in_out);

/*
 * Window: inner Objects
 */

void Awi_obchange (Awindow *window,		/* change the state of this object in work tree*/
		int obnr, int new_state);		/* ! changed behaviour to 1.0 */
void Awi_obredraw (Awindow *window,		/* redraws everthing in the area of obnr */
		int obnr);						/* uses window-> redraw */
void Awi_redraw (Awindow *window,		/* redraw routine */
		Axywh *limit);
void Awi_arrowed (Awindow *window,		/* arrows */
		int which);
void Awi_hslid (Awindow *window,		/* horizontal slider */
		int pos);
void Awi_vslid (Awindow *window, 		/* vertical slider */
		int pos);

/*
 * Events
 */

void ACSclose (void);					/* Quit Entry will call this */
void Aev_quit (void);					/* Next eventloop will terminate */
void Aev_mess (void);					/* Accept and handle messages eg redraw */
void Aev_unhidepointer (void);			/* unhides hidden pointer */

/*
 *	Mousehandling
 */

void Amo_new (Amouse* mouse);			/* set new mouse */
void Amo_busy (void);					/* set busy indicator */
void Amo_unbusy (void);					/* remove busy indicator */
void Amo_hide (void);					/* hide mouse */
void Amo_show (void);					/* unhide mouse */

/*
 *	Objecthandling
 */

OBJECT *Aob_create (					/* creates a copy of parent */
		const OBJECT *parent);	
void Aob_delete (OBJECT *object);		/* frees object generated by Aob_create */
void Aob_fix (OBJECT *object);			/* fixes object */
void Aob_offset (Axywh *redraw,			/* calculate redraw rectangle for object */
		OBJECT *ob, int entry);
MFDB *Aob_save (Axywh *rect);			/* save rectangle of desktop */
void Aob_restore (MFDB *save,			/* restore desktop previously save with Aob_save */
		Axywh *rect);
int Aob_watch (Awindow *window,			/* watched object, select if pointer upon obnr */
		int obnr);						/* returns TRUE if button was release upon obnr */
int Aob_findflag (OBJECT *ob,			/* find obnr for which flagmask becomes true, obnr is start object */
		int obnr, int flag);
int Aob_up (OBJECT* ob, int obnr);		/* find parent objectnr, returns -1 on top level */

void Ame_namefix (OBJECT *menu);		/* fixes tree on different length of first title (name) */

int Ame_popup (Awindow *window,			/* pop up a popup menu, x/y determs upper left edge */
	OBJECT *popup, int x, int y);		/* returns selected Obnr, If a callback is defined it will be called */

/*
 * Backplane Support
 */

MFDB *Abp_create (int w, int h);		/* Create Backplane with width w and height h */
void Abp_delete (MFDB *backplane);		/* free Backplane */
void Abp_start (MFDB *backplane);		/* start writing on backplane (all vdi and aes calls) */
void Abp_end (void);					/* stop writing on backplane, resume to screen */

/*
 * Drag support functions
 */

void Adr_box (int x, int y);			/* start drawing a box which select intersected objects */
void Adr_drag (int x, int y);			/* drag object list */
int Adr_next (void);					/* returns next obnr from list */
										/* init with Aselect. next = 0, return -1 if no more object are available */
void Adr_add (Awindow *window,			/* add object in Aselect list */
	const int obnr);					/* */
void Adr_del (Awindow *window,			/* delete object from Aselect list, did not update on screen ! */
	const int obnr);					/* */
void Adr_unselect (void);				/* unselect all object in list, update screen ! */	

/*
 *	String support
 */

char *Ast_create (const char *parent);	/* create a copy of parent string */
void Ast_delete (char *string);			/* release this copy */

/*
 * ICON, Image Support
 */

ICONBLK *Aic_create						/* create a copy of icon, but not image part ! */
	(const ICONBLK *icon);
void Aic_delete (ICONBLK *icon);		/* release this copy */

BITBLK *Aim_create						/* create a bitblk copy, but not image */
	(const BITBLK *bitblk);
void Aim_delete (BITBLK *bitblk);		/* release copy */

/*
 *	USER defined Objects
 */

USERBLK *Aus_create 					/* create a copy */
	(const USERBLK *user);
void Aus_delete (USERBLK *user);		/* release this copy */

/*
 *	TEDINFO Support
 */

TEDINFO *Ate_create						/* create a copy */
	(const TEDINFO *tedi);
void Ate_delete (TEDINFO *tedi);		/* release this copy */

/*
 *	Xtra Functions
 */

void *Ax_malloc (long size);			/* ACS Malloc can be overwritten if linked before library */
void Ax_free (void *memory);			/* Mark memory as free */
void Ax_ifree (void *memory);			/* give memory immediate free (be very carefully) */

/*
 *	Dummy Routines
 */

void A_dummy (void);					/* Zero Routine; will do nothing */
void A_nokey (Awindow *w,				/* Zero Routine */
	int kstate, int key);

/*
 *	Utilities
 */
void Aob_alias (void);					/* Alias object, number in userp1 */
int A_dialog (OBJECT *dia);				/* Draw a dialogbox near the pointer, handle draw and redraw */
										/* returns buttonnumber */
int alert_str							/* display an alert box with one string parameter */
	(const char *alert,					/* alert must have the form [X][...%s....][Y] */
	 const char *para);

/*
 *	Predefined "Userdefined Objects"
 */

int cdecl A_checkbox (PARMBLK *pb);		/* checkboxes, parm simular to ob_spec for boxes ! */
int cdecl A_radiobutton (PARMBLK *pb);	/* rounded selectable elements, parm simular to ob_spec for boxes ! */
int cdecl A_innerframe (PARMBLK *pb);	/* draws a frames half a character inside ! */
int cdecl A_pattern (PARMBLK *pb);		/* draws general patterns */
int cdecl A_arrows (PARMBLK *pb);		/* draws arrows */
int cdecl A_3Dframe (PARMBLK *pb);		/* draws 3D-frame */
int cdecl A_select (PARMBLK *pb);		/* select in a frame instead of reverse */

/*
 *	ACS Plus Windows
 */

extern Awindow DESKTOP;

#undef PS
#endif
