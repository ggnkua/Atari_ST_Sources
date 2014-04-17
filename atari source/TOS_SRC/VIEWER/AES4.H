/* aes4.h - aes 4.0 library functions
 *=======================================================================
 * 920630 kbad finished 1st test version of lib
 * 920628 kbad from various test sources
 */
#ifndef _AES4_H
#define _AES4_H _AES4_H

#ifndef _PORTAB_H
#include <portab.h>
#endif
#ifndef _AES_H
#include <aes.h>
#endif

#ifdef LATTICE
/* define traditional array names */
#define apb	_AESpb
#define control	_AEScontrol
#define global	_AESglobal
#define int_in	_AESintin
#define int_out	_AESintout
#define addr_in	_AESaddrin
#define addr_out _AESaddrout

#undef wind_update /* can't be inline for these bindings */
#endif

/* Many AES functions can be tested against this value for failure */
#define AESFAIL 0

/* Many of the AES 4.0 specific functions return this value on AES < 4.0 */
#define AESERR -1

/* Application library
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Symbolic names for global array values
 */
#define GL_VERS	(global[0])		/* AES version # */
#define GL_NAPP	(global[1])		/* # of concurrent apps supported */
#define GL_APID	(global[2])		/* application ID */
#define GL_PRI1	(global[3])		/* application storage */
#define GL_PRI2	(global[4])
#define GL_PPRI	((void *)&global[3])	/* pointer to application storage */
#define GL_RSHDR (*(RSHDR **)&global[5]) /* pointer to loaded resource */
/* global[7-12] reserved */
#define GL_REZ	(global[13])		/* screen device # (Getrez()+2) */
#define GL_COLORS (global[14])		/* # of colors supported by AES */

/* Useful macros for checking global array values */
#define isAES()		(GL_VERS != 0)
#define isAES33()	(GL_VERS >= 0x0330)
#define isAES4()	(GL_VERS >= 0x0400)
#define isMultiTOS()	(GL_NAPP == -1)


/* appl_getid(): get application ID or translate AES apid <-> MiNT id
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns GL_APID for AP_AESID mode, and AESERR (-1) for
 * AP_MINT2AES and AP_AES2MINT modes.
 * On AES >= 4.0, returns AESERR (-1) if the application was not found,
 * otherwise returns the appropriate id.
 */
int appl_getid(int mode, int id);

/* appl_getid() modes */
#define AP_AESID    0	/* returns AES id of current process */
#define AP_MINT2AES -1	/* given MiNT id, returns AES id */
#define AP_AES2MINT -2	/* given AES id, returns MiNT id */


/* appl_name(): set application appl_find() name.
 *-----------------------------------------------------------------------
 * This function works on all AES versions.
 */
void appl_name(const char *name);


/* appl_register(): set application name in the desk menu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns menu item index, or AESERR if no room on the menu.
 * NOTE: like menu_register(), the string passed to this function
 *	must not be a stack-allocated variable, as the AES doesn't copy
 *	the string, it only keeps the pointer.
 */
int appl_register(const char *name);


/* appl_search(): search AES process IDs
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1 if the return values are valid,
 * or AESFAIL (0) when no more applications can be found.
 */
int appl_search(int mode, char *name, WORD *type, WORD *id);

/* appl_search() modes */
#define AP_SFIRST   0	/* get first AES id */
#define AP_SNEXT    1	/* get next AES id */
#define AP_SSHELL   2	/* get AES id of system shell */

/* appl_search() type returns */
#define AP_ISSYS    1
#define AP_ISAPP    2
#define AP_ISACC    4


/* Event library
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * AES 4.0 message IDs
 */

#define WM_UNTOPPED	30	/* msg[3]: handle of window no longer on top */
#define WM_ONTOP	31	/* msg[3]: handle of window which became top */

#define AP_TERM		50	/* Request to terminate. msg[5]: reason	    */
#define AP_RESCH	57	/* AP_TERM msg[5] value for shutdown due to */
				/* to resolution change.		    */
#define AP_TFAIL	51	/* Failure response to AP_TERM, sent to AES */
				/* Put error code in msg[1].		    */
#define SHUTDOWN_DONE	60	/* Reply to initiator of a shutdown.	    */
				/* If !msg[3], shutdown failed, and msg[4]  */
				/*   is failer's apid, msg[5] is error code */
				/* Otherwise shutdown succeeded.	    */
#define RESCH_DONE	61	/* Reply to initiator of res change.	    */
				/* If !msg[3], res change failed.	    */
				/* Otherwise, intiator should terminate to  */
				/* allow AES to complete the res change.    */

#define AP_DD		63	/* Drag & drop message.  msg[3]: wind,	    */
				/* msg[4]: mouse x, msg[5]: mouse y,	    */
				/* msg[6-7]: file type.  See DD_MSG struct. */

#define AP_ACK		64	/* IPC acknowledgement message		    */
				/* msg[3]: ack code (>0: OK, <=0: error)    */
				/* msg[4]: id of message being ack'd	    */
				/* msg[5-7] depend on message		    */
				/* See ACK_MSG struct.			    */
#define AP_ACK_OK	1	/* Generic "ok" ack code for AP_ACK	    */
#define AP_ACK_NAK	0	/* Generic "fail" ack code for AP_ACK	    */
#define AP_ACK_ERR	-1	/* Generic "error" ack code for AP_ACK	    */

#define CH_EXIT		80	/* msg[3]: child apid, msg[4]: exit code    */


/*-----------------------------------------------------------------------
 * Message structures
 */

/*
 * Drag & drop message structure.
 */
typedef struct {
	WORD id;		/*[0] AP_DD (63) */
	WORD sender;		/*[1] apid of sender */
	WORD extra;		/*[2] 0 (or more if >1 file type supported) */
	WORD wind;		/*[3] window handle of d&d target, or 0 */
	WORD mx, my;		/*[4-5] mouse x, y of button release, or 0 */
	char ext[4];		/*[6-7] null-terminated preferred file type */
} DD_MSG;

/* DDX_MSG for more than 1 file type */
typedef struct {
	char ext1[4];
	char ext2[4];
	char ext3[4];
	char ext4[4];
} DDX_MSG;


/*
 * Acknowledgement message structure.
 * Can be followed in the pipe by error text.
 */
typedef struct {
	WORD id;		/*[0] AP_ACK (64) */
	WORD sender;		/*[1] apid of sender */
	WORD extra;		/*[2] 0, or 64 if error text included */
	WORD ack;		/*[3] ack code: > 0 means OK, <= 0 means error */
	WORD ack_id;		/*[4] id of message being ack'd */
	WORD code;		/*[5] message-specific response code */
	union {			/*[6-7] extended message-specific info */
	    BYTE b[4];
	    WORD w[2];
	    LONG l;
	}   x;
} ACK_MSG;

typedef char *ACK_TEXT[64];	/* error text for ACK_MSG */


/* evnt_emu() structure */
typedef struct emu {
/* Inputs */
	UWORD	flags;
	UWORD	bclicks, bmask, bstate;
	UWORD	m1out;
	GRECT	m1;
	UWORD	m2out;
	GRECT	m2;
	ULONG	time;
/* Outputs */
	UWORD	events;
	WORD	mx, my;
	UWORD	mb, ks, kr, br;
	WORD	msg[8];
/* Extended message buffer.  This is the max recommended appl_write() size. */
	BYTE	xmsg[64];
} EMU;

/* evnt_emu() - evnt_multi() using an EMU structure.
 *-----------------------------------------------------------------------
 * The caller only need fill in those fields which apply to the events
 * awaited.  Caller needn't swap the words of the e_time field:
 * the binding swaps it on the way in and unswaps it on the way out.
 */
UWORD evnt_emu(EMU *ep);


/* evnt_read() - read a message if available.
 *-----------------------------------------------------------------------
 * This function can be used by applications which need to wait for both
 * AES messages and non-AES stuff (MiNT stuff, pipe reads, serial port, etc).
 * On AES < 4.0, it calls evnt_multi(MU_MESAG|MU_TIMER,...),
 * with a timer value of 0.
 * On AES >= 4.0, it calls the more efficient appl_read(-1,16,msg).
 * Returns AESFAIL (0) if no message was waiting, else returns > 0.
 */
int evnt_read(WORD *msg);


/* Menu library
 *=======================================================================
 */

/* MN_SELECTED message buffer */
typedef struct {
	WORD	id;	/* msg[0] (10) MN_SELECTED */
	WORD	sender;	/* msg[1] apid of sender */
	WORD	extra;	/* msg[2] (0) extra bytes in message pipe */
	WORD	title;	/* msg[3] menu title selected */
	WORD	item;	/* msg[4] menu item selected */
	OBJECT	*menu;	/* msg[5-6] object tree of item */
	WORD	parent;	/* msg[7] parent object of menu item */
} MN_MSG;


/* menu_owner(): return the AES id of the current menu owner, or -1 if none.
 *-----------------------------------------------------------------------
 * It's a good idea to call wind_update(1) before menu_owner() so that
 * nobody can change the menu while you're checking the owner.
 * On AES < 4.0, returns GL_APID if your menu is showing, else AESERR (-1).
 * On AES >= 4.0, returns the result of menu_bar(-1,NULL):
 * the apid of the current menu owner, or AESERR (-1).
 */
int menu_owner(void);


/* Submenu structure for menu_popup() and menu_attach() */
typedef struct {
	OBJECT	*mn_tree;	/* menu object tree */
	WORD	mn_menu;	/* parent object of the submenu */
	WORD	mn_item;	/* starting menu item */
	WORD	mn_scroll;	/* != 0 : menu can scroll (G_STRINGs only) */
	WORD	mn_keystate;	/* shift key states at click time */
} MENU;

/* menu_popup(): handle a popup menu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns AESFAIL (0) if the user didn't click on an
 * enabled item, or 1 if the information in mdata is valid.
 */
int menu_popup(const MENU *menu, int left_x, int top_y, MENU *mdata);


/* menu_attach(): attach, change, remove or inquire a submenu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1 for success, AESFAIL (0) for any error.
 */
int menu_attach(int set, OBJECT *tree, int item, MENU *mdata);

/* attach or change a submenu */
#define menu_submenu(tree,item,mdata)	menu_attach(1,(tree),(item),(mdata))

/* inquire a submenu */
#define menu_inquire(tree,item,mdata)	menu_attach(0,(tree),(item),(mdata))

/* remove a submenu */
#define menu_remove(tree,item)		menu_attach(2,(tree),(item),(MENU*)0L)


/* menu_istart(): set or inquire the starting menu item of a submenu.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns the submenu start item if successful,
 * or AESFAIL (0) on any error.
 */
int menu_istart(int set, OBJECT *tree, int imenu, int istart);


/* Input structure for menu_settings() */
typedef struct {		/* (defaults) */
	long	display;	/* (200ms) delay before submenu appears */
	long	drag;		/* (10000ms) delay before submenu disappears */
	long	delay;		/* (250ms) single-click scroll delay */
	long	speed;		/* (0ms) continuous scroll delay */
	WORD	height;		/* (16) menu scroll height */
} MN_SET;

/* menu_settings(): set or inquire submenu delays and scroll height.
 *-----------------------------------------------------------------------
 * If set == 0, returns current values in *values.
 * if set == 1, sets all values in *values which aren't set to -1.
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1.
 */
int menu_settings(int set, MN_SET *values);


/* Object library
 *=======================================================================
 */

/* objc_gclip(): get the full extent of an object for clipping
 *-----------------------------------------------------------------------
 * This function also returns the physical x,y of the object.
 * Any of the output pointers may be NULL.
 */
void objc_gclip(const OBJECT *tree, int obj, WORD *px, WORD *py, GRECT *clip);


/* objc_sysvar(): set/inquire object-related system variables
 *-----------------------------------------------------------------------
 * Either of the output pointers may be NULL if you don't 
 */
int objc_sysvar(int set, int which, int ani_col, int chcolor,
		WORD *oani_col, WORD *ochcolor);
#define LK3DIND	  1
#define LK3DACT   2
#define INDBUTCOL 3
#define ACTBUTCOL 4
#define ALERTBG   5


/* Resource library
 *=======================================================================
 */

/* rsrc_rcfix(): fix up a resource in memory.
 *-----------------------------------------------------------------------
 * Converts object coordinates to pixel coordinates.
 * The resource must have be a GEM RCS format resource, read in from disk,
 * or a compiled GEM RCS RSH file linked in with your program.
 * NOTE: if you've done a rsrc_load(), you must do a rsrc_free() before
 *	calling this function.
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1.
 */
int rsrc_rcfix(RSHDR *rp);


/* Shell library
 *=======================================================================
 */


/* shel_glen(): return the size of the AES shell internal buffer.
 *-----------------------------------------------------------------------
 * On AES < 3.0, returns 1024.
 * On AES 3.0-4.0, returns 4192.
 * On AES 4.0 and up, calls shel_get(NULL,-1),
 * which returns 0 on error or the size of the buffer.
 */
int shel_glen(void);


/* shel_put(): write data into the AES shell internal buffer.
 *-----------------------------------------------------------------------
 * On AES < 4.0, this call validates the size being written,
 * and returns AESERR (-1) if it's too large.
 */
int shel_put(const char *buf, int len);

/************************************************************************
NOTE:	many of the following functions invoke various shel_write modes.
	On AES versions < 4.0, they will simply return AESERR (-1).
*************************************************************************/

/* shel_run() input structure */
typedef struct {
	char	*cmd;
	long	limit;
	long	nice;
	char	*setpath;
	char	*env;
} SH_RUN;

/* shel_run(): run a program concurrently
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1)
 * On AES >= 4.0, returns child process' AES id, or AESFAIL (0).
 */
int shel_run(int mode, int isgem, int useargv, SH_RUN *p, const char *args);

/* shel_run() modes */
#define SH_RUNANY	0	/* run app or DA with path & ext search */
#define SH_RUNAPP	1	/* run GEM (isgem==1) or TOS app */
#define SH_RUNACC	3	/* run DA */
/* extended mode bit masks */
#define SH_LIMIT	0x0100
#define SH_NICE		0x0200
#define SH_SETPATH	0x0400
#define SH_SETENV	0x0800

/* shel_shutdown(): get the system into or out of shutdown mode.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int shel_shutdown(int mode);

/* shel_shutdown() modes */
#define SH_SHUTDOWN	2
#define SH_PARTIAL	1
#define SH_RESTART	0

/* shel_changeres(): change resolution.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int shel_changeres(int res);

/* shel_changeres() res numbers */
#define ST_LOW	2
#define ST_MED	3
#define ST_HIGH	4
#define TT_MED	6
#define TT_HIGH	8
#define TT_LOW	9

/* shel_broadcast(): broadcast an 8 WORD message to all but AES & sender.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int shel_broadcast(WORD *msg);

/* shel_sizeenv(): get AES environment size.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns size in bytes of the AES environment.
 */
int shel_sizeenv(void);

/* shel_setenv(): set ("VAR=VAL") or clear ("VAR=") an AES env variable.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int shel_setenv(const char *s);

/* shel_copyenv(): copy len bytes of AES environment string into buf.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns the number of bytes not copied.
 */
int shel_copyenv(char *buf, short len);

/* shel_grok(): tell the AES what messages you understand.
 *-----------------------------------------------------------------------
 * BInding doesn't call the AES on versions < 4.0.
 */
void shel_grok(WORD bits);

/* shel_grok() bits */
#define G_AP_TERM	0x0001

/* shel_msg(): send the AES an 8 WORD message.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int shel_msg(WORD *msg);


/* Window library
 *=======================================================================
 * NOTE: Contrary to other documentation, wind_get() and wind_set()
 *	both have void returns.
 */

/* wind_get/set() selectors */
#ifndef WF_COLOR
#define WF_COLOR	18	/* see wind_gcolor(), wind_scolor() */
#endif
#ifndef WF_DCOLOR
#define WF_DCOLOR	19	/* see wind_gcolor(), wind_scolor() */
#endif
#define WF_OWNER	20	/* e.g: wind_get(handle, WF_OWNER, &owner,
				 *		&isopen, &h_above, &h_below);
				 */
#define WF_BEVENT	24	/* see wind_bevent() */
#define WF_BOTTOM	25	/* get or set */


/* wind_bevent(): set/get a window's button event status.
 *-----------------------------------------------------------------------
 * If set == -1, returns 1 if the window gets button events when it's
 * untopped, or 0 if the window gets topped events when it's untopped.
 * If set != -1 on AES < 4.0, returns -1.
 * If set >= 0 on AES >= 4.0, sets the window to get button events (set==1)
 * or topped events (set==0) when it is untopped, and returns 1.
 */
int wind_bevent(int handle, int set);


/* Various wind_get/set() routines.
 *-----------------------------------------------------------------------
 * NOTE: on AES 4.0, wind_get(0,WF_TOP,&w1,&w2,&w3,&w4)
 *	 returns the top window handle in w1, its owner's AES id in w2,
 *	 and the handle of the window below it in w3.
 */

/*
 * Get menu/alert buffer
 */
void wind_gbuf(void **pbufp, long *plen);

/*
 * Get colors.
 * Returns -1 on AES < 4.0, 1 on AES >= 4.0
 */
int wind_gcolor(int handle, int which, int element, WORD *top, WORD *untop);

/*
 * Get address of window 0 object tree.
 * Returns pdesk == NULL on AES < 4.0.
 */
void wind_gesk(OBJECT **pdesk, WORD *proot);

/*
 * Get string values: WF_INFO, WF_NAME
 * Returns -1 on AES < 4.0, 1 on AES >= 4.0
 */
int wind_gstr(int handle, int which, char *buf);

/*
 * Get various window rects:
 * WF_WORK, WF_CURR, WF_PREV, WF_FULL, WF_FIRST, WF_NEXT
 */
void wind_grect(int handle, int which, GRECT *prect);

/*
 * Get word values:
 * WF_KIND, WF_HSLIDE, WF_VSLIDE, WF_HSLSIZE, WF_VSLSIZE, WF_BOTTOM,
 * and WF_TOP if you don't care about the new values returned in AES 4.0.
 */
WORD wind_gword(int handle, int which);


/*
 * Set new desktop
 */
void wind_sdesk(OBJECT *tree, int obj);

/*
 * Set string values: WF_INFO, WF_NAME
 */
void wind_sstr(int handle, int which, char *p);


/*
 * wind_update() check-and-set masks.
 * Under AES >= 4.0, these cause wind_update() to return 0 immediately
 * if the screen (TRY_UPDATE) or mouse (TRY_MCTRL) are already owned
 * by another process.  wind_update() bindings should mask out all but
 * the low 2 bits on AES < 4.0.
 */
#define TRY_UPDATE	0x101
#define TRY_MCTRL	0x103

#endif /* !defined(_AES4_H) */
