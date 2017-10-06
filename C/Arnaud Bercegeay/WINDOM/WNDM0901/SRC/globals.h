/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997
 *
 *	module: globals.h
 *	description: contient les d‚finitions des structures
 */

#ifndef __WINDOM_GLOBAL__
#define __WINDOW_GLOBAL__

#include <stddef.h>

#include "wportab.h"
#include "options.h"

/* Libraries TOS */

/* Pure C possŠde des librairies non standard */
#ifdef __PUREC__
# include <tos.h>
#else
# ifdef __SOZOBONX__
#  include <atari.h>  /* for DTA definition */
# endif
# include <osbind.h>
# include <mintbind.h>
# include <fcntl.h>
#endif

/* Libraries AES / VDI */

#ifdef __PUREC__
# include "..\include\windom.h"
#else
# include "../include/windom.h"
#endif

/* constantes d‚finies dans MGEMLIB mais manquantes … gemlib40 */

#ifndef FNT_CHANGED
#define FNT_CHANGED 83
#endif

#ifndef SM_M_SPECIAL
#define SM_M_SPECIAL    101
#define SMC_TIDY_UP		0
#define SMC_TERMINATE	1
#define SMC_SWITCH		2
#define SMC_FREEZE		3
#define SMC_UNFREEZE	4
#define SMC_RES5		5
#define SMC_UNHIDEALL	6
#define SMC_HIDEOTHERS	7
#define SMC_HIDEACT		8
#endif

/* Et qqs constantes et structures priv‚es … WinDom */

/* Magic */
#define SCREENMGR		1

#define CONF(ap)	((CONFIG *)ap.conf)
#define HI16(a) ((INT16)((long)(a) >> 16) & 0xFFFFL )
#define LO16(a) ((INT16)(long)(a) & 0xFFFFL )

/* defs pour form/toolbar */
#define ROOTS 			0
#define DRAW3D			0x0080
#define OUTLINED_WIDTH	3

typedef struct attrib {
		int font;
		int size;
		int color;
	} ATTRIB;

typedef struct ev_msg {
		int msg;
		void (*proc)(WINDOW *);
		struct ev_msg *next;
		int flags;
	} EV_MSG;

/* Evnt Mesag Flags */
#define EVM_ISWIN		0x1
#define EVM_DISABLE		0x2
#define EVM_IN_USE 		0x4
#define EVM_DELETED 	0x8

/* ApplGet/Set values */
/* note: ‚quivalent … WFORM dans windom.h */
#define FCENTER		6

#define SYSFONT		0

/*
 *	This stucture is private (because, it can
 *	change. It doesn't appear in the header file.
 *	Each member can be set with the function ApplSet()
 * 	(or with the WinDom config file)
 */

typedef struct _config {
		/* Divers drapeaux */
		unsigned int flag;
		/* Fenˆtres */
		int	wicon, hicon;
		int	bgcolor;
		int	bgpatt;
		int	bgstyle;
		/* Types ‚tendus */
		int		key_color;
		ATTRIB	string;
		ATTRIB	button;
		ATTRIB	exit;
		ATTRIB	title;
		ATTRIB	xedit_text;
		ATTRIB	xedit_label;
		ATTRIB	xlongedit;
		int		xlgedt_smlfnt;
		ATTRIB  xtedinfo;
		int		xtdinf_smlfnt;
		int		actmono;
		int		actcol;
		int		menu_effect;
		/* BubbleGEM */
		ATTRIB	bubble;
		/* Popup */
		int		popcolor;
		int		popborder;
		int		popfcolor;
		int		poppatt;
		int		popwind;		/* -1 (defaut), 0 (bloquant) ou 1 (pr‚emptif) */
		/* Autres */
		int		wcenter;		/* CENTER, MOUSE, UP_RIGHT, UP_LEFT, DN_RIGHT, DU_LEFT */
		int		weffect;		/* -1 (defaut), 0 (off), 1 (on)	*/
		int		mwidget;		/* attribut GEM des formulaires modaux */
} CONFIG;

typedef struct _bind {
		int *var;
		void *fnc;
		unsigned int bit;
	} BIND;

/*
 *	Stucture pass‚ … ub_parm
 *	pour les objets userdefs
 */

typedef struct {
		long  wp_spec;
		int   wp_type;
	} W_PARM;

/*
 *	Stucture pass‚e … ub_parm
 *	pour les objets XEDIT
 */

typedef struct {
	TEDINFO *tedinfo;	/* structure Tedinfo originale */
	char *line;			/* le buffer */
	int pos, 			/* premier caractere visible */
		curs, 			/* position curseur */
		blcbeg, blcend;	/* position bloc */
	short flags;		/* drapeaux */
	int size;			/* taille m‚moire de la ligne */
	int wp_type;		/* type de l'objet */
} W_XEDIT;

/* Drapeaux de W_XEDIT.flags */
#define XEDIT_CURS_ON 0x1
#define XEDIT_BLOC_ON 0x2

/*
 *  ajout de fonctions (arnaud 08/2001)
 */
int   scrap_txt_write( char *str);
char *scrap_txt_read ( void);

extern int 		(*__calc)( struct _window *, int, INT16 *, INT16 *, INT16 *, INT16 *);
extern void 	(*__swgt)( struct _window *, GRECT *, int);
extern int		(*__rfrm)( struct _window *, struct _window *);

extern void snd_msg ( WINDOW *win, int msg, int, int, int, int);
extern void RsrcUserFree ( OBJECT *);
extern int  is_modal ( void);
extern int  obj_fd_flag	( OBJECT *, int, int);
extern int  obj_fd_xtype( OBJECT *dial, int racine, int flag);
extern int 	obj_nb		( OBJECT *);
extern void	GrectCenter		( int w, int h, INT16 *x, INT16 *y);
extern void	DataClear		( WINDOW *win);
extern void	AddWindow	( WINDOW *win);
extern void	RemoveWindow( WINDOW *win);
extern void	add_slash	( char *path);
extern void	init_scroll_menu( void);
extern void	menu_bind( WINDOW *win, int item, int title);

extern int	VstLoadFonts( int vh, int res);
extern void	VstUnloadFonts( int vh, int res);
extern int	VstFont( int vh, int id) ;
extern int	VqtName( int vh, int elem, char *name) ;
extern int	VqtXname( int vh, int id, int index, char *name, int *fl);

WORD __CDECL ub_xboxchar( PARMBLK *pblk);
WORD __CDECL ub_boxchar3d( PARMBLK *pblk);
void init_type( OBJECT *tree, int index, void *func, int extype);
void free_type( OBJECT *tree, int index);

/* routines standards de stdcode.c 
 */

void std_cls	( WINDOW *);
void std_tpd	( WINDOW *);
void std_mvd	( WINDOW *);
void std_szd	( WINDOW *);
void std_fld	( WINDOW *);
void std_icn	( WINDOW *);
void std_unicn	( WINDOW *);
void std_allicn	( WINDOW *);
void std_arw	( WINDOW *);
void std_dnlnd	( WINDOW *);
void std_uplnd	( WINDOW *);
void std_lflnd	( WINDOW *);
void std_rtlnd	( WINDOW *);
void std_dnpgd	( WINDOW *);
void std_uppgd	( WINDOW *);
void std_rtpgd	( WINDOW *);
void std_lfpgd	( WINDOW *);
void std_vsld	( WINDOW *);
void std_hsld	( WINDOW *);
void std_dstry	( WINDOW *);
void std_btm	( WINDOW *);

void std_fntchg( WINDOW *win);

#ifndef __MINIWINDOM__
int  	menu_exec_cmd	( WINDOW *win);						/* menu.c */
void 	menu_draw		(WINDOW *win, int, int, int, int);	/* menu.c */
int 	frm_menu		( WINDOW *win);						/* menu.c */
int 	frm_keybd_ev	( OBJECT *tree);					/* dialog.c */
int 	is_menu			( WINDOW *win);						/* menu.c */
/* Directive pour mon ‚tude de la taille des ex‚cutables */
#if GFORM
int 	frm_buttn_ev	( WINDOW *win, int mode);	 			/* dialog.c */
#endif
#endif

extern int _res;
extern short *_AESglobal;
extern int __bubble_quit;
extern WORD __windowlist[];
extern WORD __iconlist[];

#ifdef WINDOMDEBUG
	#define	LOGFILE	"C:\\gemsys\\log\\windom.log"
#endif

#endif /* __WINDOM_GLOBAL__ */
