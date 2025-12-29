/*
 *		Header file Windom librairy
 */

#ifndef __WINDOM
#define __WINDOM

#include <stddef.h>
#include <portab.h>


#ifdef __GNUC__

#define __TCC_COMPAT__
#define __TCC_GEMLIB__
#define cdecl
#include <gemfast.h>
#include <aesbind.h>
#include <vdibind.h>
#include <osbind.h>
#include <ostruct.h>
#ifndef _AESversion
	extern unsigned short _global[];
	#define	_AESversion   (_global[0])
	#define	_AESnumapps   ((signed short)_global[1])
#endif
#else
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#define DESK	0
	#ifndef _AESversion
	#define	_AESversion   (_GemParBlk.global[0])
	#define	_AESnumapps   (_GemParBlk.global[1])
	#endif
#endif

/* AES 3.4 4.xx */

#ifndef G_CICON
#define G_CICON			33
typedef struct cicon_data
{
		WORD	num_planes;
		WORD	*col_data;
		WORD	*col_mask;
		WORD	*sel_data;
		WORD	*sel_mask;
		struct cicon_data *next_res;
} CICON;

typedef struct cicon_blk
{
		ICONBLK monoblk;
		CICON	*mainlist;
} CICONBLK;
#endif

/* D‚finition G‚n‚rales */

#ifndef min
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))
#endif
#define UNUSED( a)	((void )(a))

#define is_in( xp, yp, x, y, w, h) (xp>=x && yp>=y && xp<x+w && yp<y+h)

struct w_version {
	WORD patchlevel;
	char *date;
	char *cc_name;
	WORD cc_version;
};

extern struct w_version WinDom;

/* Librairie Application */

/* flag */
#define KEYBD_ON_MOUSE	0x0001
#define BUTTON_ON_MOUSE	0x0002
#define NOPALETTE		0x0004

/* key_color */
#define LTMFLY_COLOR		0x0010

/* aes4 infos */
#define	AES4_BOTTOM			0x0001
#define AES4_ICONIFY		0x0002
#define AES4_ICONIFYXYWH	0x0004
#define AES4_SMALLER		0x0008
#define AES4_BOTTOMER		0x0010
#define AES4_APPSEARCH		0x0020

typedef int	W_COLOR[3];


typedef struct {
		int 	id;
		int		handle;
		int		aeshdl;
		int		x,y,w,h;
		int 	wicon, hicon;
		int		color;
		OBJECT  *menu;
		W_COLOR *palette;
		int		work_in[10];
		int 	work_out[57];
		int		aes4;
		int 	flag;
		int 	gdos;
		int		key_color;
		int		exit_color;
		int		string_color;
		int		button_color;
		int 	menu_effect;
		void	(*menu_proc)(void);
	} APPvar;

extern APPvar app;

int ApplInit( void);
int ApplExit( void);
int ApplName( char *name, int handle);

/* Librairie Windows */

#define WAT_ALL 	0x4FFF	/* Tous les attributs possible */
#define WAT_NOINFO	0x4FEF	/* Tous les atrributs sauf la barre d'info */
#define WAT_FORM	0x400C	/* Formulaire: nom, mover, closer, smaller */
#define WAT_MFORM	0x4009  /* Formulaire modal: nom, mover, smaller */

typedef struct _grafport
	{
		int		handle;				/*  Handle station de travail virtuelle */
		W_COLOR *palette;      /*  Palette de couleur de la station 	*/
	} W_GRAFPORT;

#ifdef __GNUC__
struct _window;
#endif


typedef struct {
		OBJECT *root;							/* Le menu */
		void (*proc)( struct _window *);		/* La fonction qui gŠre le menu */
	} W_MENU;

typedef struct {
	OBJECT *root,*real;
	void (*proc)( struct _window *);
	int  *save;
	int edit, curseur, nb_ob;
} W_FORM;
	
typedef struct {
		char *name;
		int x , y, w, h;	/* Coordonn‚es originale de la fenˆtre
							 * non-ic“nifi‚e.
							 */
		void (*draw)(struct _window *);
	} W_ICON;

/*
 *	Fenetre frame (point‚ par data)
 */

typedef struct {
	struct _window *list,
				   *front,
				   *widget;
	int border;
	int color;
	int flags;
	} FRAME;

typedef struct {
	int line, col; /* diff‚re selon le status de la fenetre */
	int x,y,w,h;
	int flags;
	int vsldpos,vsldsize;
	int hsldpos,hsldsize;
	} FRAMEINFO;


typedef struct _window
	{
		int handle;
		int attrib;
		int status;
		W_GRAFPORT 	graf;
		W_MENU		menu;
		W_FORM		tool;
		W_ICON		icon;
		BOOLEAN fullsize;
		GRECT createsize;
		FRAMEINFO	frame;		/* info sur la frame */
		char *name, *info;
		int w_max, h_max;
		int w_min, h_min;
		int xpos, ypos;
		int xpos_max, ypos_max;
		int w_u, h_u;
		struct _window *next;

		int type;
		void *data;
		
		/* evenements fenˆtres */
		void (*redraw)(struct _window *);
		void (*topped)(struct _window *);
		void (*untopped)(struct _window *);
		void (*moved)(struct _window *);
		void (*sized)(struct _window *);
		void (*closed)(struct _window *);
		void (*iconified)(struct _window *);
		void (*uniconified)(struct _window *);
		void (*alliconified)(struct _window *);
		void (*hslided)(struct _window *);
		void (*vslided)(struct _window *);
		void (*fulled)(struct _window *);
		void (*uppaged)(struct _window *);
		void (*dnpaged)(struct _window *);
		void (*uplined)(struct _window *);
		void (*dnlined)(struct _window *);
		void (*lfpaged)(struct _window *);
		void (*rtpaged)(struct _window *);
		void (*lflined)(struct _window *);
		void (*rtlined)(struct _window *);

		/* les autres evenements GEM */
		void (*clicked)(struct _window *);
		void (*keyhited)(struct _window *);
		void (*timed)(struct _window *);
		void (*m1)(struct _window *);
		void (*m2)(struct _window *);
		
		/* les evenements non-GEM */
		void (*destroy)(struct _window *);
		void (*extramsg)(struct _window *);
	} WINDOW, *WINDOWPTR;

/*  Windows attributs */
#ifndef SMALLER
#define SMALLER 0x4000
#endif

/*	Windows status */
#define WS_OPEN			0x0001
#define WS_ICONIFY		0x0002
#define WS_MENU			0x0004
#define WS_TOOLBAR		0x0008
#define WS_GROW			0x0010
#define WS_UNTOPPABLE	0x0020
#define WS_FORM			0x0040
#define WS_FORMDUP		0x0080
#define WS_MODAL		0x0100
#define	WS_FRAME_ROOT	0x0200	/* fenetre frame racine */
#define WS_FRAME		0x0400	/* fenˆtre frame */

/*  WindSet mode */
#ifndef WF_BOTTOM
#define WF_BOTTOM			25
#endif

#define B_UNTOPPABLE	0x0001
#define B_MODAL			0x1000


#ifndef WF_ICONIFY
#define WF_ICONIFY			26
#define WF_UNICONIFY		27	
#define WF_UNICONIFYXYWH 	28
#define WF_TOOLBAR			30
#define WF_FTOOLBAR			31
#define WF_NTOOLBAR			32
#endif

#define WF_MENU			1000
#define WF_DRAW			1001
#define WF_DSTRY		1002
#define	WF_ICON			1003

/* WindSlider() mode */
#define HSLIDER			0x0001
#define VSLIDER			0x0002

/* Windows type */
#define WT_UNDEFINED	0
#define WT_DIALOG		1

/* Window global variable */
typedef struct {
		WINDOW *first;
		WINDOW *front;
		WINDOW *appfront;
	} WINvar;

extern WINvar wglb;

WINDOW* WindCreate( int GemAttrib, int x, int y, int w, int h);
int WindOpen( WINDOW *win, int x, int y, int w, int h);
int WindClose( WINDOW *win);
int WindDelete( WINDOW *win);
WINDOW* WindHandle( int handle);
int WindSet( WINDOW *win, int mode, ...);
int WindGet( WINDOW *win, int mode, ...);
int WindCalc( int type, WINDOW *wind, int xin, int yin,
			  int win, int hin, int *xout, int *yout, 
			  int *wout, int *hout);
void WindSlider( WINDOW *win, int mode);

void WindClear( WINDOW *win);
void add_windowlist( int);
void remove_windowlist( int);

/* Librairie evnt */

/* Nouveaux messages (AES et WinDom)*/

#ifndef WM_ICONIFY
#define WM_ICONIFY		34
#define WM_UNICONIFY	35
#define WM_ALLICONIFY	36
#define WM_TOOLBAR		37
#define	WM_BOTTOM		33
#define WM_BOTTOMED		WM_BOTTOM
#endif

#ifndef AP_TERM
#define AP_TERM			50
#define AP_TFAIL        51
#define AP_RESCHG       57
#define SHUT_COMPLETED  60
#define RESCHG_COMPLETED  61
#define CH_EXIT         80
#endif

#define WM_DESTROY		0x4400    /* old value 1000 */
#define WM_MNSELECTED	0x4401
#define WM_FORM			0x4402	  /* Pour dialogue */

typedef struct {
	int lo_timer, hi_timer;
	int bclick, bmask, bstate;
	int m1_flag, m1_x, m1_y, m1_w, m1_h;
	int m2_flag, m2_x, m2_y, m2_w, m2_h;
	int buff[8];
	int mx, my, mbut, mkstate;
	int keybd, nb_click;
	} EVNTvar;

extern EVNTvar evnt;
extern GRECT clip;

void snd_rdw( WINDOW *win);
void snd_arrw( WINDOW *win, int type);
void snd_msg( WINDOW *win, int msg, int, int, int, int);
void give_iconifyxywh( int *x, int *y, int *w, int *h);


int EvntWindom( int);

/* Librairie Menu */

/* MenuPopUp() mode */
#define P_RDRW	0x0100
#define P_WNDW	0x0200
#define P_RGTH	0x0400
#define P_LIST	0x0800
#define P_SIZE	0x1000

int MenuBar( OBJECT *menu, int mode);
int MenuTnormal( WINDOW *win, int title, int mode);
int MenuIcheck( WINDOW *win, int title, int mode);
int MenuText( WINDOW *win, int title, char *txt);
int MenuDisable( void);
int MenuEnable( void);
int MenuPopUp( void *data, int x, int y, int max, int size, int item, int mode);

/* Librairie Object */

#ifndef ED_INIT
#define ED_START     EDSTART
#define ED_INIT      EDINIT
#define ED_CHAR      EDCHAR
#define ED_END       EDEND
#endif

/* ObjcChange mode */
#define OC_TOOLBAR	0
#define OC_FORM		1

int ObjcDraw( int mode, WINDOW *win, int index, int depth);
int ObjcChange( int mode, WINDOW *win, int index, int state, int redraw);
OBJECT *ObjcDup( OBJECT *tree);
void ObjcFree( OBJECT *tree);
char *ObjcString( OBJECT *tree, int index, char *put);
int ObjcWindDraw( WINDOW *win, OBJECT *tree, int index, int depth, int xclip, int yclip, int wclip, int hclip);
int ObjcWindChange( WINDOW *win, OBJECT *tree, int index, int xclip, int yclip, int wclip, int hclip, int state);
int ObjcEdit( int type, WINDOW *win, int car, int mode, GRECT *clp);  /* fonction encore beta */

#define FORM( win) (((W_FORM*)win->data)->root)
#define TOOL( win) (win->tool.root)

/* Librairie ressource */

#ifndef __MYDIAL__
typedef struct
{
	USERBLK	ublk;
	UWORD	old_type;
} OBBLK;
#endif

typedef struct {
		OBBLK   *obblk;
		CICON   *cicon_table;
		WORD	farbtbl[256][32];
		ULONG   farbtbl2[256];
		WORD    is_palette;
		WORD	rgb_palette[256][4];
		WORD	is_init;
		WORD 	num_cib;
	} XRSRCFIX;

int RsrcLoad( const char *name);
#define RsrcFree()	rsrc_free()
int RsrcXtype( int mode, OBJECT **rs_trindex, int num_tree);
void RsrcFixCicon ( OBJECT *object, int num_obs, int num_cib, int palette[][4], XRSRCFIX *fix);
void RsrcFreeCicon ( XRSRCFIX *fix);

/* Librairie Formulaire */

void FormBegin( OBJECT *tree, MFDB *bckgrnd);
#define FormDo(a,b) form_do(a,b)
void FormEnd( OBJECT *tree, MFDB *bckgrnd);

/* FormWindDo() mode */ 
#define FORM_EVNT	0x8000

WINDOW *FormWindBegin( OBJECT *dial, char *nom);
void FormWindEnd( void);
int FormWindDo( int evnt);

void FormAttach( WINDOW *win, OBJECT *tree, void *func);
WINDOW *FormCreate( OBJECT *tree, int attrib, void *func, char *name, GRECT *coord, int grow, int dup);
int FormSave( WINDOW *win, int mode);
int FormRestore( WINDOW *win, int mode);
int FormPopup( OBJECT *tree, int x, int y, int item, int mode);

/* Libraire souris */
void MouseObjc( OBJECT *tree, int index);
void MouseWork( void);
void MouseSprite( OBJECT *tree, int index);

/* Librairie file selector */
int file_select(char *pfname, char *pname, char *fname, const char *ext, char *title);
int FselInput( char *path, char *fname, char *ext, char *title);

/* Librairie Frame */
#define FRAME_BORDER 1
#define FRAME_COLOR  2
#define FRAME_KEYBD	 3
#define FRAME_SIZE	 4
#define FRAME_FLAGS  5
#define FRAME_NOBG	 6
#define FRAME_ACTIV  7
#define FRAME_TOPPED_ACTIV  8

#define FRAME_WSCALE	0x0001
#define FRAME_HSCALE	0x0002
#define FRAME_WFIX		0x0004
#define FRAME_HFIX		0x0008
#define FRAME_NOBORDER	0x0010
#define FRAME_SELECT	0x0020

WINDOW *FrameCreate( int attrib);
void    FrameAttach( WINDOW *win, WINDOW *src, int line, int col, int w, int h, int mode);
WINDOW *FrameRemove( WINDOW *win, WINDOW *child, int line, int col);
void    FrameSet( WINDOW *win, int mode, ...);
WINDOW *FrameFind( WINDOW *win, int x, int y);
WINDOW *FrameSearch( WINDOW *win, int line, int col);
int     FrameCalc( WINDOW *win, int mode, int *x, int *y, int *w, int *h);

/* Librarie cookie */

long *get_cookiejar( void);
int new_cookie (long cookie, long value);
int	get_cookie (long cookie, long *value);
int set_cookie(long cookie, long value);

/* BubbleGEM */

#define BUBBLEGEM_SHOW  0xBABB
#define BUBBLEGEM_ACK   0xBABC

int BubbleCall( char *help, int x, int y);
int BubbleAttach( OBJECT *tree, int index, char *help);
void BubbleFree( void);
int BubbleFind( OBJECT *tree, int index, char **help);
int BubbleEvnt( void);

/* Divers */

int rect_set( GRECT *, int, int, int, int);
int rc_interset( GRECT *, GRECT *);
int CallStGuide( char *);
void w_getpal( W_COLOR *palette);
void w_setpal( W_COLOR *palette);

#endif