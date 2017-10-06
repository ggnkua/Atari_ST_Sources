/*
 * gem.h - main header file for new gem-lib
 */
#ifndef _GEMLIB_H_
#define _GEMLIB_H_

#include <compiler.h>


#ifdef __GEMLIB_OLDBIND			/* Backward-compatibility */
#undef _GEMLIB_H_					/* For old bindings, these header had to be multi-included. */

#ifndef __GEMLIB_HAVE_DEFS		/* first include via aesbind/vdibind/gemfast */
#define __GEMLIB_HAVE_DEFS
#else
#undef __GEMLIB_DEFS
#endif

#else									/* New include scheme: one header defines all */
#define __GEMLIB_DEFS
#define __GEMLIB_AES
#define __GEMLIB_VDI
#endif

#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************************************
 * The version of the gem-lib
 */
#define GEMLIB_PATCHLEVEL	"38"



#ifdef __GEMLIB_DEFS

/*******************************************************************************
 * The AES specific stuff from old gemfast.h
 */

#define NIL 				0
#define DESKTOP_HANDLE	0
#define DESK			  	DESKTOP_HANDLE

		/* appl_getinfo modes */
#define AES_LARGEFONT	0
#define AES_SMALLFONT	1
#define AES_SYSTEM		2
#define AES_LANGUAGE 	3
#define AES_PROCESS		4
#define AES_PCGEM 		5
#define AES_INQUIRE		6
#define AES_MOUSE 		8
#define AES_MENU			9
#define AES_SHELL 	  10
#define AES_WINDOW	  11

		/* appl_getinfo return values */
#define SYSTEM_FONT		0
#define OUTLINE_FONT 	1

#define AESLANG_ENGLISH 0
#define AESLANG_GERMAN	1
#define AESLANG_FRENCH	2
#define AESLANG_SPANISH 4
#define AESLANG_ITALIAN 5
#define AESLANG_SWEDISH 6

		/* appl_read modes */
#define APR_NOWAIT	  -1

		/* appl_search modes */
#define APP_FIRST 		0
#define APP_NEXT			1

		/* appl_search return values*/
#define APP_SYSTEM		0x01
#define APP_APPLICATION 0x02
#define APP_ACCESSORY	0x04
#define APP_SHELL 		0x08

		/* appl_trecord types */
#define APPEVNT_TIMER	 0
#define APPEVNT_BUTTON	 1
#define APPEVNT_MOUSE	 2
#define APPEVNT_KEYBOARD 3

		/* struct used by appl_trecord and appl_tplay */
typedef struct pEvntrec {
	long ap_event;
	long ap_value;
}EVNTREC;

		/* evnt_button flags */
#define LEFT_BUTTON		0x0001
#define RIGHT_BUTTON 	0x0002
#define MIDDLE_BUTTON	0x0004

#define K_RSHIFT			0x0001
#define K_LSHIFT			0x0002
#define K_CTRL 			0x0004
#define K_ALT				0x0008

		/* evnt_dclick flags */
#define EDC_INQUIRE		0
#define EDC_SET			1

		/* event message values */
#define MN_SELECTED	 10
#define WM_REDRAW 	 20
#define WM_TOPPED 	 21
#define WM_CLOSED 	 22
#define WM_FULLED 	 23
#define WM_ARROWED	 24
#define WM_HSLID		 25
#define WM_VSLID		 26
#define WM_SIZED		 27
#define WM_MOVED		 28
#define WM_NEWTOP 	 29
#define WM_UNTOPPED	 30
#define WM_ONTOP		 31
#define WM_BOTTOMED	 33
#define WM_ICONIFY	 34
#define WM_UNICONIFY  35
#define WM_ALLICONIFY 36
#define WM_TOOLBAR	 37
#define AC_OPEN		 40
#define AC_CLOSE		 41
#define AP_TERM		 50
#define AP_TFAIL		 51
#define AP_RESCHG 	 57

		/* Xcontrol messages */
#define CT_UPDATE 	 50
#define CT_MOVE		 51
#define CT_NEWTOP 	 52
#define CT_KEY 		 53

#define SHUT_COMPLETED	 60
#define RESCHG_COMPLETED 61
#define RESCH_COMPLETED  61
#define AP_DRAGDROP		 63
#define SH_WDRAW			 72
#define CH_EXIT			 90

		/* evnt_mouse modes */
#define MO_ENTER 0
#define MO_LEAVE 1

		/* evnt_multi flags */
#define MU_KEYBD	0x0001
#define MU_BUTTON 0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020

		/* form_dial opcodes */
#define FMD_START 		0
#define FMD_GROW			1
#define FMD_SHRINK		2
#define FMD_FINISH		3

		/* form_error modes */
#define FERR_FILENOTFOUND	 2
#define FERR_PATHNOTFOUND	 3
#define FERR_NOHANDLES		 4
#define FERR_ACCESSDENIED	 5
#define FERR_LOWMEM			 8
#define FERR_BADENVIRON 	10
#define FERR_BADFORMAT		11
#define FERR_BADDRIVE		15
#define FERR_DELETEDIR		16
#define FERR_NOFILES 		18

		/* fsel_(ex)input return values*/
#define FSEL_CANCEL			 0
#define FSEL_OK				 1

		/* menu_attach modes */
#define ME_INQUIRE		0
#define ME_ATTACH 		1
#define ME_REMOVE 		2

		/* menu_attach attributes */
#define SCROLL_NO 		0
#define SCROLL_YES		1

		/* menu_bar modes */
#define MENU_REMOVE		0
#define MENU_INSTALL 	1
#define MENU_INQUIRE   -1

		/* menu_icheck modes */
#define UNCHECK			0
#define CHECK				1

		/* menu_ienable modes */
#define DISABLE			0
#define ENABLE 			1

		/* menu_istart modes */
#define MIS_GETALIGN 	0
#define MIS_SETALIGN 	1

		/* menu_popup modes */
#define SCROLL_LISTBOX -1

		/* menu_register modes */
#define REG_NEWNAME	  -1

/* menu_tnormal modes */
#define HIGHLIGHT   0
#define UNHIGHLIGHT 1

/* menu_settings uses a new structure for setting and inquiring the submenu
 * delay values and the menu scroll height.	The delay values are measured in
 * milliseconds and the height is based upon the number of menu items.
 */

typedef struct _mn_set 
{
	long  display;		/*  the submenu display delay 	 */
	long  drag;			/*  the submenu drag delay 		 */
	long  delay;		/*  the single-click scroll delay */
	long  speed;		/*  the continuous scroll delay	 */
	short height; 		/*  the menu scroll height 		 */
} MN_SET;

/* shel_get modes */
#define SHEL_BUFSIZE (-1)

		/* shel_write modes */
#define SWM_LAUNCH	  0
#define SWM_LAUNCHNOW  1
#define SWM_LAUNCHACC  3
#define SWM_SHUTDOWN   4
#define SWM_REZCHANGE  5
#define SWM_BROADCAST  7
#define SWM_ENVIRON	  8
#define SWM_NEWMSG	  9
#define SWM_AESMSG	 10

		/* shel_write flags */
#define SW_PSETLIMIT 0x0100
#define SW_PRENICE	0x0200
#define SW_DEFDIR 	0x0400
#define SW_ENVIRON	0x0800

#define SD_ABORT	  0
#define SD_PARTIAL  1
#define SD_COMPLETE 2

		/* rsrc_gaddr structure types */
#define R_TREE 		0
#define R_OBJECT		1
#define R_TEDINFO 	2
#define R_ICONBLK 	3
#define R_BITBLK		4
#define R_STRING		5
#define R_IMAGEDATA	6
#define R_OBSPEC		7
#define R_TEPTEXT 	8
#define R_TEPTMPLT	9
#define R_TEPVALID  10
#define R_IBPMASK   11
#define R_IBPDATA   12
#define R_IBPTEXT   13
#define R_BIPDATA   14
#define R_FRSTR	  15
#define R_FRIMG	  16



		/* Window Attributes */
#define NAME			0x0001
#define CLOSER 		0x0002
#define FULLER 		0x0004
#define MOVER			0x0008
#define INFO			0x0010
#define SIZER			0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE 		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE 		0x0800
#define BACKDROP		0x2000
#define SMALLER		0x4000

		/* wind_create flags */
#define WC_BORDER 	 0
#define WC_WORK		 1

		/* wind_get flags */
#define WF_KIND			  1
#define WF_NAME			  2
#define WF_INFO			  3
#define WF_WORKXYWH		  4
#define WF_CURRXYWH		  5
#define WF_PREVXYWH		  6
#define WF_FULLXYWH		  7
#define WF_HSLIDE 		  8
#define WF_VSLIDE 		  9
#define WF_TOP 			 10
#define WF_FIRSTXYWH 	 11
#define WF_NEXTXYWH		 12
#define WF_RESVD			 13
#define WF_NEWDESK		 14
#define WF_HSLSIZE		 15
#define WF_VSLSIZE		 16
#define WF_SCREEN 		 17
#define WF_COLOR			 18
#define WF_DCOLOR 		 19
#define WF_OWNER			 20
#define WF_BEVENT 		 24
#define WF_BOTTOM 		 25
#define WF_ICONIFY		 26
#define WF_UNICONIFY 	 27
#define WF_UNICONIFYXYWH 28
#define WF_TOOLBAR		 30
#define WF_FTOOLBAR		 31
#define WF_NTOOLBAR		 32
#define WF_WINX			 22360
#define WF_WINXCFG		 22361

		/* window elements	*/
#define W_BOX			0
#define W_TITLE		1
#define W_CLOSER		2
#define W_NAME 		3
#define W_FULLER		4
#define W_INFO 		5
#define W_DATA 		6
#define W_WORK 		7
#define W_SIZER		8
#define W_VBAR 		9
#define W_UPARROW   10
#define W_DNARROW   11
#define W_VSLIDE	  12
#define W_VELEV	  13
#define W_HBAR 	  14
#define W_LFARROW   15
#define W_RTARROW   16
#define W_HSLIDE	  17
#define W_HELEV	  18
#define W_SMALLER   19

		/* arrow message	*/
#define WA_UPPAGE 	0
#define WA_DNPAGE 	1
#define WA_UPLINE 	2
#define WA_DNLINE 	3
#define WA_LFPAGE 	4
#define WA_RTPAGE 	5
#define WA_LFLINE 	6
#define WA_RTLINE 	7

		/* wind_update flags */
#define END_UPDATE 0
#define BEG_UPDATE 1
#define END_MCTRL  2
#define BEG_MCTRL  3

/* graf_mouse mouse types*/
#define ARROW				 0
#define TEXT_CRSR 		 1
#define BEE 				 2
#define BUSY_BEE		  BEE 	/* alias */
#define BUSYBEE		  BEE 	/* alias */
#define HOURGLASS 		 2
#define POINT_HAND		 3
#define FLAT_HAND 		 4
#define THIN_CROSS		 5
#define THICK_CROSS		 6
#define OUTLN_CROSS		 7
#define USER_DEF		  255
#define M_OFF			  256
#define M_ON			  257
#define M_SAVE 		  258
#define M_LAST 		  259
#define M_RESTORE 	  260
#define M_FORCE	  0x8000

/* objects - general */
#define ROOT		 0 	 /* index of ROOT */
#define MAX_LEN	81 	 /* max string length */
#define MAX_DEPTH  8 	 /* max depth of search or draw */

/* inside fill patterns */
#define IP_HOLLOW 0
#define IP_1PATT	1
#define IP_2PATT	2
#define IP_3PATT	3
#define IP_4PATT	4
#define IP_5PATT	5
#define IP_6PATT	6
#define IP_SOLID	7

/* normal graphics drawing modes */
#define MD_REPLACE 1
#define MD_TRANS	 2
#define MD_XOR 	 3
#define MD_ERASE	 4

		/* bit blt rules */
#define ALL_WHITE   0
#define S_AND_D	  1
#define S_AND_NOTD  2
#define S_ONLY 	  3
#define NOTS_AND_D  4
#define D_ONLY 	  5
#define S_XOR_D	  6
#define S_OR_D 	  7
#define NOT_SORD	  8
#define NOT_SXORD   9
#define D_INVERT	 10
#define NOT_D		 10
#define S_OR_NOTD  11
#define NOT_S		 12
#define NOTS_OR_D  13
#define NOT_SANDD  14
#define ALL_BLACK  15

		/* font types */
#define GDOS_PROP   0
#define GDOS_MONO   1
#define GDOS_BITM   2
#define IBM 		  3
#define SMALL		  5

		/* object types */
#define G_BOX		 20
#define G_TEXT 	 21
#define G_BOXTEXT  22
#define G_IMAGE	 23
#define G_USERDEF  24
#define G_PROGDEF  G_USERDEF
#define G_IBOX 	 25
#define G_BUTTON	 26
#define G_BOXCHAR  27
#define G_STRING	 28
#define G_FTEXT	 29
#define G_FBOXTEXT 30
#define G_ICON 	 31
#define G_TITLE	 32
#define G_CICON	 33

/* object flags */
#define NONE		 0x0000
#define SELECTABLE 0x0001
#define DEFAULT	 0x0002
#define EXIT		 0x0004
#define EDITABLE	 0x0008
#define RBUTTON	 0x0010
#define LASTOB 	 0x0020
#define TOUCHEXIT  0x0040
#define HIDETREE	 0x0080
#define INDIRECT	 0x0100
#define FL3DIND	 0x0200	/* bit 9 */
#define FL3DBAK	 0x0400	/* bit 10 */
#define FL3DACT	 0x0600
#define SUBMENU	 0x0800	/* bit 11 */
#define FLAG11		 SUBMENU
#define FLAG12		 0x1000
#define FLAG13		 0x2000
#define FLAG14		 0x4000
#define FLAG15		 0x5000

/* Object states */
#define NORMAL 	 0x0000
#define SELECTED	 0x0001
#define CROSSED	 0x0002
#define CHECKED	 0x0004
#define DISABLED	 0x0008
#define OUTLINED	 0x0010
#define SHADOWED	 0x0020
#define WHITEBAK	 0x0040
#define DRAW3D	    0x0080
#define STATE08    0x0100
#define STATE09	 0x0200
#define STATE10    0x0400
#define STATE11    0x0800
#define STATE12	 0x1000
#define STATE13	 0x2000
#define STATE14	 0x4000
#define STATE15	 0x8000

/* Object colors - default pall. */
#define WHITE	  0
#define BLACK	  1
#define RED 	  2
#define GREEN	  3
#define BLUE	  4
#define CYAN	  5
#define YELLOW   6
#define MAGENTA  7
#define LWHITE   8
#define LBLACK   9
#define LRED	  10
#define LGREEN   11
#define LBLUE	  12
#define LCYAN	  13
#define LYELLOW  14
#define LMAGENTA 15

/* editable text field definitions */
#define EDSTART		0
#define EDINIT 		1
#define EDCHAR 		2
#define EDEND			3

#define ED_START		EDSTART
#define ED_INIT		EDINIT
#define ED_CHAR		EDCHAR
#define ED_END 		EDEND

/* editable text justification */
#define TE_LEFT		0
#define TE_RIGHT		1
#define TE_CNTR		2

/* objc_change modes */
#define NO_DRAW		0
#define REDRAW 		1

/* objc_order modes */
#define OO_LAST	  -1
#define OO_FIRST		0

/* objc_sysvar modes */
#define SV_INQUIRE	0
#define SV_SET 		1

/* objc_sysvar values */
#define LK3DIND		1
#define LK3DACT		2
#define INDBUTCOL 	3
#define ACTBUTCOL 	4
#define BACKGRCOL 	5
#define AD3DVAL		6

		/* Mouse Form Definition Block */
typedef struct mouse_form {
	short mf_xhot;
	short mf_yhot;
	short mf_nplanes;
	short mf_bg;
	short mf_fg;
	short mf_mask[16];
	short mf_data[16];
}MFORM;

typedef struct graphic_rectangle
{
	int 	g_x;
	int 	g_y;
	int 	g_w;
	int 	g_h;
} GRECT;

typedef struct objc_colorword 
{
	unsigned borderc : 4;
	unsigned textc   : 4;
	unsigned opaque  : 1;
	unsigned pattern : 3;
	unsigned fillc   : 4;
}OBJC_COLORWORD;

typedef struct text_edinfo
{
	char *te_ptext;		/* ptr to text */
	char *te_ptmplt;		/* ptr to template */
	char *te_pvalid;		/* ptr to validation chrs. */
	short te_font; 		/* font */
	short te_fontid;		/* font id */
	short te_just; 		/* justification */
	short te_color;		/* color information word */
	short te_fontsize;	/* font size */
	short te_thickness;	/* border thickness */
	short te_txtlen;		/* length of text string */
	short te_tmplen;		/* length of template string */
} TEDINFO;

typedef struct icon_block {
	short *ib_pmask;
	short *ib_pdata;
	char	*ib_ptext;
	short ib_char;
	short ib_xchar;
	short ib_ychar;
	short ib_xicon;
	short ib_yicon;
	short ib_wicon;
	short ib_hicon;
	short ib_xtext;
	short ib_ytext;
	short ib_wtext;
	short ib_htext;
}ICONBLK;

typedef struct bit_block {
	short *bi_pdata;	/* ptr to bit forms data  */
	short bi_wb;		/* width of form in bytes */
	short bi_hl;		/* height in lines */
	short bi_x; 		/* source x in bit form */
	short bi_y; 		/* source y in bit form */
	short bi_color;	/* fg color of blt */
}BITBLK;

typedef struct cicon_data {
	short 				num_planes;
	short 				*col_data;
	short 				*col_mask;
	short 				*sel_data;
	short 				*sel_mask;
	struct cicon_data *next_res;
}CICON;

typedef struct cicon_blk {
	ICONBLK monoblk;
	CICON   *mainlist;
}CICONBLK;

typedef struct {
	 unsigned int character   :  8;
	 signed	 int framesize   :  8;
	 unsigned int framecol	  :  4;
	 unsigned int textcol	  :  4;
	 unsigned int textmode	  :  1;
	 unsigned int fillpattern :  3;
	 unsigned int interiorcol :  4;
} BFOBSPEC;

struct user_block;	/* forward declaration */

typedef union obspecptr
{
	long					index;
	union obspecptr	*indirect;
	BFOBSPEC 			obspec;
	TEDINFO				*tedinfo;
	BITBLK				*bitblk;
	ICONBLK				*iconblk;
	CICONBLK 			*ciconblk;
	struct user_block *userblk;
	char					*free_string;
} OBSPEC;

typedef struct object
{
	short 			ob_next;	 	/* -> object's next sibling		  */
	short 			ob_head; 	/* -> head of object's children	  */
	short 			ob_tail; 	/* -> tail of object's children	  */
	unsigned short ob_type; 	/* type of object 		  */
	unsigned short ob_flags;	/* flags 			  */
	unsigned short ob_state;	/* state 			  */
	OBSPEC			ob_spec; 	/* object-specific data 		  */
	short 			ob_x; 		/* upper left corner of object		  */
	short 			ob_y; 		/* upper left corner of object		  */
	short 			ob_width;	/* width of obj				  */
	short 			ob_height;	/* height of obj			  */
} OBJECT;

typedef struct parm_block
{
	OBJECT *pb_tree;
	short  pb_obj;
	short  pb_prevstate;
	short  pb_currstate;
	short  pb_x, pb_y, pb_w, pb_h;
	short  pb_xc, pb_yc, pb_wc, pb_hc;
	long	 pb_parm;
} PARMBLK;

typedef struct user_block
{
	int __CDECL (*ub_code)(PARMBLK *parmblock);
	long ub_parm;
} USERBLK;


typedef struct rshdr
{
	short 	rsh_vrsn;
	unsigned short rsh_object;
	unsigned short rsh_tedinfo;
	unsigned short rsh_iconblk;	/* list of ICONBLKS		*/
	unsigned short rsh_bitblk;
	unsigned short rsh_frstr;
	unsigned short rsh_string;
	unsigned short rsh_imdata; /* image data			*/
	unsigned short rsh_frimg;
	unsigned short rsh_trindex;
	short 	rsh_nobs;	/* counts of various structs	*/
	short 	rsh_ntree;
	short 	rsh_nted;
	short 	rsh_nib;
	short 	rsh_nbb;
	short 	rsh_nstring;
	short 	rsh_nimages;
	unsigned short rsh_rssize; /* total bytes in resource */
} RSHDR;

typedef struct _menu
{
	OBJECT	*mn_tree;
	short		mn_menu;
	short		mn_item;
	short		mn_scroll;
	short		mn_keystate;
} MENU;

typedef struct
{
	int 	m_out;
	int 	m_x;
	int 	m_y;
	int 	m_w;
	int	m_h;
} MOBLK;

typedef struct mouse_event_type
{
	int	*x;
	int	*y;
	int	*b;
	int	*k;
} MOUSE;

#endif 

#ifdef __GEMLIB_AES

/*******************************************************************************
 * The AES bindings from old aesbind.h
 */
	 
extern int	appl_bvset 		(int bvdisk, int bvhard);
extern int	appl_control	(int ap_cid, int ap_cwhat, void *ap_cout);
extern int	appl_exit 		(void);
extern int	appl_find 		(char *Name);
extern int	appl_getinfo 	(int type, int *out1, int *out2, int *out3, int *out4);
extern int	appl_init 		(void);
extern int	appl_read 		(int ApId, int Length, void *ApPbuff);
extern int	appl_search 	(int mode, char *fname, int *type, int *ap_id);
extern int	appl_tplay 		(void *Mem, int Num, int Scale);
extern int	appl_trecord 	(void *Mem, int Count);
extern int	appl_write 		(int ApId, int Length, void *ApPbuff);
extern int 	appl_yield 		(void);

extern int	evnt_button 	(int Clicks, int WhichButton,	int WhichState, int *Mx, int *My, int *ButtonState, int *KeyState); 
extern int	evnt_dclick 	(int ToSet, int SetGet);
extern int	evnt_keybd 		(void);
extern int	evnt_mesag 		(int MesagBuf[]);
extern int	evnt_mouse 		(int EnterExit, int InX, int InY, int InW, int InH, int *OutX, int *OutY, int *ButtonState, int *KeyState); 
extern int 	evnt_multi 		(int Type, int Clicks, int WhichButton, int WhichState, 
											int EnterExit1, int In1X, int In1Y, int In1W, int In1H, 
											int EnterExit2, int In2X, int In2Y, int In2W, int In2H,
											int MesagBuf[], unsigned long Interval, int *OutX, int *OutY,
											int *ButtonState, int *KeyState, int *Key, int *ReturnCount);
extern int	evnt_timer 		(unsigned long Interval);

extern int 	form_alert 		(int DefButton, char *Str);
extern int 	form_button 	(void *Btree, int Bobject, int Bclicks, int *Bnxtobj);
extern int 	form_center 	(void *Tree, int *Cx, int *Cy, int *Cw, int *Ch);
extern int 	form_dial 		(int Flag, int Sx, int Sy, int Sw, int Sh, int Bx, int By, int Bw, int Bh);
extern int 	form_do 			(void *Tree, int StartObj);
extern int 	form_error 		(int ErrorCode);
extern int 	form_keybd 		(void *Ktree, int Kobject, int Kobnext, int Kchar, int *Knxtobject, int *Knxtchar);

extern int 	fsel_exinput 	(char *Path, char *File, int *ExitButton, char *title);
extern int 	fsel_input 		(char *Path, char *File, int *ExitButton);

extern int 	graf_dragbox 	(int Sw, int Sh, int Sx, int Sy, int Bx, int By, int Bw, int Bh, int *Fw, int *Fh); 
extern int 	graf_growbox 	(int Sx, int Sy, int Sw, int Sh, int Fx, int Fy, int Fw, int Fh); 
extern int 	graf_handle	 	(int *Wchar, int *Hchar, int *Wbox, int *Hbox);
extern int 	graf_mbox 		(int Sw, int Sh, int Sx, int Sy, int Dx, int Dy);
#define 		graf_movebox	(a,b,c,d,e,f)	graf_mbox(a,b,c,d,e,f)
extern int 	graf_mkstate 	(int *Mx, int *My, int *ButtonState, int *KeyState); 
extern int 	graf_mouse 		(int Form, void *FormAddress);
extern int 	graf_rubbbox	(int Ix, int Iy, int Iw, int Ih, int *Fw, int *Fh);
#define		graf_rubberbox (a,b,c,d,e,f)	graf_rubbbox(a,b,c,d,e,f)
extern int 	graf_shrinkbox (int Fx, int Fy, int Fw, int Fh, int Sx, int Sy, int Sw, int Sh); 
extern int 	graf_slidebox 	(void *Tree, int Parent, int Object, int Direction); 
extern int 	graf_watchbox 	(void *Tree, int Object, int InState, int OutState);

extern int 	menu_attach 	(int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata);
extern int 	menu_bar 		(void *Tree, int ShowFlag);
extern int	menu_click		(int click, int setit);
extern int 	menu_icheck 	(void *Tree, int Item, int CheckFlag);
extern int 	menu_ienable	(void *Tree, int Item, int EnableFlag);
extern int 	menu_istart 	(int me_flag, OBJECT *me_tree, int me_imenu, int me_item);
extern int 	menu_popup 		(MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata);
extern int 	menu_register 	(int ApId, char *MenuText);
extern int 	menu_settings 	(int me_flag, MN_SET *me_values);
extern int 	menu_text 		(void *Tree, int Item, char *Text);
extern int 	menu_tnormal 	(void *Tree, int Item, int NormalFlag);
extern int	menu_unregister(int id);

extern int	objc_add 		(void *Tree, int Parent, int Child);
extern int	objc_change 	(void *Tree, int Object, int Res, int Cx, int Cy, int Cw, int Ch, int NewState,int Redraw);
extern int	objc_delete 	(void *Tree, int Object);
extern int	objc_draw 		(void *Tree, int Start, int Depth, int Cx,int Cy, int Cw, int Ch);
extern int	objc_edit 		(void *Tree, int Object, int Char, int *Index, int Kind); 
extern int	objc_find 		(void *Tree, int Start, int Depth, int Mx, int My);
extern int	objc_offset 	(void *Tree, int Object, int *X, int *Y);
extern int	objc_order 		(void *Tree, int Object, int NewPos);
extern int	objc_sysvar 	(int mode, int which, int in1, int in2, int *out1, int *out2);

extern int	rsrc_free 		(void);
extern int	rsrc_gaddr 		(int Type, int Index, void *Address);
extern int	rsrc_load 		(char *Name);
extern int	rsrc_obfix 		(void *Tree, int Index);
extern int	rsrc_rcfix 		(void *rc_header);
extern int	rsrc_saddr 		(int Type, int Index, void *Address);

extern int	scrp_clear 		(void);
extern int	scrp_read 		(char *Scrappath);
extern int	scrp_write 		(char *Scrappath);

extern int	shel_envrn 		(char **result, char *param);
extern int	shel_find 		(char *buf);
extern int 	shel_get 		(char *Buf, int Len);
extern int	shel_help		(int sh_hmode, char *sh_hfile, char *sh_hkey);
extern int 	shel_put	 		(char *Buf, int Len);
extern int	shel_rdef		(char *lpcmd, char *lpdir);
extern int	shel_read 		(char *Command, char *Tail);
extern int	shel_wdef		(char *lpcmd, char *lpdir);
extern int	shel_write		(int Exit, int Graphic, int Aes, void *Command, char *Tail);

extern int	wind_calc 		(int Type, int Parts, int InX, int InY, int InW, int InH, int *OutX, int *OutY, int *OutW, int *OutH);	
extern int	wind_close 		(int WindowHandle);
extern int	wind_create 	(int Parts, int Wx, int Wy, int Ww, int Wh); 
extern int	wind_delete 	(int WindowHandle);
extern int	wind_find 		(int X, int Y);
extern int	wind_get 		(int WindowHandle, int What, int *W1, int *W2, int *W3, int *W4); 
extern void	wind_new 		(void);
extern int	wind_open 		(int WindowHandle, int Wx, int Wy, int Ww, int Wh);
extern int	wind_set 		(int WindowHandle, int What, int W1, int W2, int W3, int W4);
extern int	wind_update 	(int Code);


/*
 * Some usefull extensions.
 */
extern int	wind_calc_grect	(int Type, int Parts, GRECT *In, GRECT *Out);  
extern int	wind_create_grect	(int Parts, GRECT *r); 
extern void	wind_get_grect		(int WindowHandle, int What, GRECT *r);
extern int	wind_open_grect 	(int WindowHandle, GRECT *r);
extern void wind_set_grect		(int WindowHandle, int What, GRECT *r);
extern void wind_set_str		(int WindowHandle, int What, char *str);

extern int	rc_copy 				(GRECT *src, GRECT *dst);
extern int	rc_equal 			(GRECT *src, GRECT *dst);
extern int 	rc_intersect 		(GRECT *r1, GRECT *r2);
extern int 	*grect_to_array 	(GRECT *area, int *array);
extern void	array_to_grect		(int *array, GRECT *area);


/*
 * aes trap interface
*/
/* Array sizes in aes control block */
#define AES_CTRLMAX		5
#define AES_GLOBMAX		16
#define AES_INTINMAX 	16
#define AES_INTOUTMAX	16
#define AES_ADDRINMAX	16
#define AES_ADDROUTMAX	16

typedef struct
{
	short *control;
	short *global;
	short *intin;
	short *intout;
	long	*addrin;
	long	*addrout;
} AESPB;

extern short	aes_global[], aes_control[], aes_intin[], aes_intout[];
extern long 	aes_addrin[], aes_addrout[];
extern AESPB	aes_params;
extern int		gl_apid, gl_ap_version;			/* initialized in appl_init */

extern void aes(AESPB *pb);

#endif /* AES */



#ifdef __GEMLIB_DEFS

/*******************************************************************************
 * The VDI specific stuff from old gemfast.h
 */

/* v_bez modes */
#define BEZ_BEZIER	0x01
#define BEZ_POLYLINE 0x00
#define BEZ_NODRAW	0x02

/* v_bit_image modes */
#define IMAGE_LEFT	0
#define IMAGE_CENTER 1
#define IMAGE_RIGHT	2
#define IMAGE_TOP 	0
#define IMAGE_BOTTOM 2

/* v_justified modes */
#define NOJUSTIFY 0
#define JUSTIFY	1

/* vq_color modes */
#define COLOR_REQUESTED 0
#define COLOR_ACTUAL 	1

/* return values for vq_vgdos() inquiry */
#define GDOS_NONE (-2L) 		 /* no GDOS installed */
#define GDOS_FSM	0x5F46534DL /* '_FSM' */
#define GDOS_FNT	0x5F464E54L /* '_FNT' */

/* vqin_mode & vsin_mode modes */
#define LOCATOR  1
#define VALUATOR 2
#define CHOICE   3
#define STRING   4

/* vqt_cachesize modes */
#define CACHE_CHAR 0
#define CACHE_MISC 1

/* vqt_devinfo return values */
#define DEV_MISSING	 0
#define DEV_INSTALLED 1

/* vqt_name return values */
#define BITMAP_FONT 0

/* vsf_interior modes */
#define FIS_HOLLOW  0
#define FIS_SOLID   1
#define FIS_PATTERN 2
#define FIS_HATCH   3
#define FIS_USER	  4

/* vsf_perimeter modes */
#define PERIMETER_OFF 0
#define PERIMETER_ON  1

/* vsl_ends modes */
#define SQUARE  0
#define ARROWED 1
#define ROUND	 2

/* vsl_type modes */
#define SOLID		 1
#define LDASHED	 2
#define DOTTED 	 3
#define DASHDOT	 4
#define DASH		 5
#define DASHDOTDOT 6
#define USERLINE	 7

/* vsm_type modes */
#define MRKR_DOT		 1
#define MRKR_PLUS 	 2
#define MRKR_ASTERISK 3
#define MRKR_BOX		 4
#define MRKR_CROSS	 5
#define MRKR_DIAMOND  6

/* vst_alignment modes */
#define TA_LEFT         0 /* horizontal */
#define TA_CENTER       1
#define TA_RIGHT        2
#define TA_BASE         0 /* vertical */
#define TA_HALF         1
#define TA_ASCENT       2
#define TA_BOTTOM       3
#define TA_DESCENT      4
#define TA_TOP          5

/* vst_charmap modes */
#define MAP_BITSTREAM 0
#define MAP_ATARI 	 1

/* vst_effects modes */
#define TXT_NORMAL       0x0000
#define TXT_THICKENED    0x0001
#define TXT_LIGHT        0x0002
#define TXT_SKEWED       0x0004
#define TXT_UNDERLINED   0x0008
#define TXT_OUTLINED     0x0010
#define TXT_SHADOWED     0x0020

/* vst_error modes */
#define APP_ERROR 	0
#define SCREEN_ERROR 1

/* vst_error return values */
#define NO_ERROR			0
#define CHAR_NOT_FOUND	1
#define FILE_READERR 	8
#define FILE_OPENERR 	9
#define BAD_FORMAT	  10
#define CACHE_FULL	  11
#define MISC_ERROR	  (-1)

/* vst_kern modes */
#define TRACK_NONE		0
#define TRACK_NORMAL 	1
#define TRACK_TIGHT		2
#define TRACK_VERYTIGHT 3

/* vst_scratch modes */
#define SCRATCH_BOTH   0
#define SCRATCH_BITMAP 1
#define SCRATCH_NONE   2

/* v_updwk return values */
#define SLM_OK 	  0x00
#define SLM_ERROR   0x02
#define SLM_NOTONER 0x03
#define SLM_NOPAPER 0x04

		/* VDI Memory Form Definition Block */
typedef struct
{
	void		*fd_addr;
	short 	fd_w; 	 /* Form Width in Pixels					  */
	short 	fd_h; 		/* Form Height in Pixels					 */
	short 	fd_wdwidth; /* Form Width in shorts(fd_w/sizeof(int)*/
	short 	fd_stand;	/* Form format 0= device spec 1=standard*/
	short 	fd_nplanes; /* Number of memory planes 				 */
	short 	fd_r1;		/* Reserved 									 */
	short 	fd_r2;		/* Reserved 									 */
	short 	fd_r3;		/* Reserved 									 */
} MFDB;

#endif 

#ifdef __GEMLIB_VDI

/*******************************************************************************
 * The VDI bindings from old vdibind.h
 */

/*
 * attribute functions 
*/
extern void	vs_color				(int handle, int index, int rgb[]);
extern int 	vswr_mode			(int handle, int mode);

extern int 	vsf_color 			(int handle, int index);
extern int 	vsf_interior 		(int handle, int style);
extern int 	vsf_perimeter 		(int handle, int vis);
extern int 	vsf_style 			(int handle, int style);
extern void	vsf_udpat 			(int handle, int pat[], int planes);

extern int 	vsl_color 			(int handle, int index);
extern void vsl_ends 			(int handle, int begstyle, int endstyle);
extern int 	vsl_type 			(int handle, int style);
extern void vsl_udsty 			(int handle, int pat);
extern int 	vsl_width 			(int handle, int width);

extern int 	vsm_color 			(int handle, int index);
extern int 	vsm_height 			(int handle, int height);
extern int 	vsm_type 			(int handle, int symbol);

extern void vst_alignment 		(int handle, int hin, int vin, int *hout, int *vout);
extern int 	vst_color	 		(int handle, int index);
extern int 	vst_effects			(int handle, int effects);
extern void vst_error 			(int handle, int mode, short *errorvar);
extern int 	vst_font 			(int handle, int font);
extern int 	vst_height 			(int handle, int height,	int *charw, int *charh, int *cellw, int *cellh);
extern int 	vst_point 			(int handle, int point, int *charw, int *charh, int *cellw, int *cellh);
extern int 	vst_rotation 		(int handle, int ang);
extern void vst_scratch 		(int handle, int mode);

/*
 * control functions
*/
extern void	v_clrwk				(int handle);
extern void	v_clsvwk				(int handle);
extern void	v_clswk				(int handle);
extern int	v_flushcache		(int handle);
extern int	v_loadcache			(int handle, char *filename, int mode);
extern void	v_opnvwk				(int work_in[], int *handle, int work_out[]);
extern void	v_opnwk				(int work_in[], int *handle, int work_out[]);
extern int	v_savecache			(int handle, char *filename);
extern void	v_set_app_buff		(int handle, void *buf_p, int size);
extern void	v_updwk				(int handle);
extern void	vs_clip				(int handle, int clip_flag, int pxyarray[]);
extern int	vst_load_fonts		(int handle, int select);
extern void	vst_unload_fonts	(int handle, int select);

/*
 * escape functions
*/
extern void	v_bit_image			(int handle, char *filename, int aspect, int x_scale, int y_scale, int h_align, int v_align, int *pxyarray);
extern void	v_clear_disp_list	(int handle);
extern int	v_copies				(int handle, int count);
extern void	v_dspcur				(int handle, int x, int y);
extern void	v_form_adv			(int handle);
extern void	v_hardcopy			(int handle);
extern int	v_orient				(int handle, int orientation);
extern void	v_output_window	(int handle, int *pxyarray);
extern int	v_page_size			(int handle, int page_id);
extern void	v_rmcur				(int handle);
extern void	v_trays				(int handle, int input, int output, int *set_input, int *set_output);
extern int	vq_calibrate		(int handle, int *flag);
extern int	vq_page_name		(int handle, int page_id, char *page_name, long *page_width, long *page_height);
extern void	vq_scan				(int handle, int *g_slice, int *g_page, int *a_slice, int *a_page, int *div_fac);
extern int	vq_tabstatus		(int handle);
extern void	vq_tray_names		(int handle, char *input_name, char *output_name, int *input, int *output);
extern int	vs_calibrate		(int handle, int flag, int *rgb);
extern int	vs_palette			(int handle, int palette);

extern void	vq_tdimensions		(int handle, int *xdimension, int *ydimension);
extern void	vt_alignment		(int handle, int dx, int dy);
extern void	vt_axis				(int handle, int xres, int yres, int *xset, int *yset);
extern void	vt_origin			(int handle, int xorigin, int yorigin);
extern void	vt_resolution		(int handle, int xres, int yres, int *xset, int *yset);

extern void	v_meta_extents		(int handle, int min_x, int min_y, int max_x, int max_y);
extern void	v_write_meta		(int handle, int numvdi_intin, int *avdi_intin, int num_ptsin, int *a_ptsin);
extern void	vm_coords			(int handle, int llx, int lly, int urx, int ury);
extern void	vm_filename			(int handle, char *filename);
extern void	vm_pagesize			(int handle, int pgwidth, int pgheight);

extern void	vsc_expose			(int handle, int state);
extern void	vsp_film				(int handle, int index, int lightness);

extern void	v_escape2000		(int handle, int times);

extern void	v_alpha_text		(int handle, char *str);
extern void	v_curdown			(int handle);
extern void	v_curhome			(int handle);
extern void	v_curleft			(int handle);
extern void	v_curright			(int handle);
extern void	v_curtext			(int handle, char *str);
extern void	v_curup				(int handle);
extern void	v_eeol				(int handle);
extern void	v_eeos				(int handle);
extern void	v_enter_cur			(int handle);
extern void	v_exit_cur			(int handle);
extern void	v_rvoff				(int handle);
extern void	v_rvon				(int handle);
extern void	vq_chcells			(int handle, int *n_rows, int *n_cols);
extern void	vq_curaddress		(int handle, int *cur_row, int *cur_col);
extern void	vs_curaddress		(int handle, int row, int col);
	

/*
 * inquiry functions
*/
extern void	vq_cellarray		(int handle, int pxyarray[], int row_len, int nrows, int *el_used, int *rows_used, int *status, int color[]);
extern int	vq_color				(int handle, int index, int flag, int rgb[]);
extern void	vq_extnd				(int handle, int flag, int work_out[]);
extern void	vqf_attributes		(int handle, int atrib[]);
extern void	vqin_mode			(int handle, int dev, int *mode);
extern void	vql_attribute		(int handle, int atrib[]);
extern void	vqm_attributes		(int handle, int atrib[]);
extern void	vqt_attributes		(int handle, int atrib[]);
extern void	vqt_cachesize		(int handle, int which_cache, long *size);
extern void	vqt_extent			(int handle, char *str, int extent[]);
extern void	vqt_fontinfo		(int handle, int *minade, int *maxade, int distances[], int *maxwidth, int effects[]);
extern void	vqt_get_table		(int handle, short **map);
extern int	vqt_name				(int handle, int element, char *name);
extern int	vqt_width			(int handle, int chr, int *cw, int *ldelta, int *rdelta);

extern int	vq_gdos 				(void);
extern long vq_vgdos 			(void);


/*
 * input function
*/
extern void	v_hide_c				(int handle);
extern void	v_show_c				(int handle, int reset);
extern void	vex_butv				(int handle, void *pusrcode, void **psavcode);
extern void	vex_curv				(int handle, void *pusrcode, void **psavcode);
extern void	vex_motv				(int handle, void *pusrcode, void **psavcode);
extern void	vex_timv				(int handle, void *time_addr, void **otime_addr, int *time_conv);
extern void	vq_key_s				(int handle, int *state);
extern void	vq_mouse				(int handle, int *pstatus, int *x, int *y);
extern void	vrq_choice			(int handle, int cin, int *cout);
extern void	vrq_locator			(int handle, int x, int y, int *xout, int *yout, int *term);
extern void	vrq_string			(int handle, int len, int echo, int echoxy[], char *str);
extern void	vrq_valuator		(int handle, int in, int *out, int *term);
extern void	vsc_form				(int handle, int form[]);
extern int	vsin_mode			(int handle, int dev, int mode);
extern int	vsm_choice			(int handle, int *choice);
extern int	vsm_locator			(int handle, int x, int y, int *xout, int *yout, int *term);
extern int	vsm_string			(int handle, int len, int echo, int echoxy[], char *str);
extern void	vsm_valuator		(int handle, int in, int *out, int *term, int *status);


/*
 * output functions
*/
extern void	v_arc					(int handle, int x, int y, int radius, int begang, int endang);
extern void	v_bar					(int handle, int pxyarray[]);
extern void	v_cellarray			(int handle, int pxyarray[], int row_length, int elements, int nrows, int write_mode, int colarray[]);
extern void	v_circle				(int handle, int x, int y, int radius);
extern void	v_contourfill		(int handle, int x, int y, int index);
extern void	v_ellarc				(int handle, int x, int y, int xrad, int yrad, int begang, int endang);
extern void	v_ellipse			(int handle, int x, int y, int xrad, int yrad);
extern void	v_ellpie				(int handle, int x, int y, int xrad, int yrad, int begang, int endang);
extern void	v_fillarea			(int handle, int count, int pxyarray[]);
extern void	v_gtext				(int handle, int x, int y, char *str) ;
extern void	v_justified			(int handle, int x, int y, char *str, int len, int word_space, int char_space);
extern void	v_pieslice			(int handle, int x, int y, int radius, int begang, int endang);
extern void	v_pline				(int handle, int count, int pxyarray[]);
extern void	v_pmarker			(int handle, int count, int pxyarray[]);
extern void	v_rbox				(int handle, int pxyarray[]);
extern void	v_rfbox				(int handle, int pxyarray[]);
extern void	vr_recfl				(int handle, int pxyarray[]);

/*
 * raster functions
*/
extern void	v_get_pixel			(int handle, int x, int y, int *pel, int *index);
extern void	vr_trnfm				(int handle, MFDB *src, MFDB *dst);
extern void	vro_cpyfm			(int handle, int mode, int pxyarray[], MFDB *src, MFDB *dst);
extern void	vrt_cpyfm			(int handle, int mode, int pxyarray[], MFDB *src, MFDB *dst, int color[]);


/*
 * Some usefull extensions.
*/
extern void	vdi_array2str		(short *src, char *des, int len);
extern int	vdi_str2array		(char *src, short *des);


/*
 * vdi trap interface
*/

/* Array sizes in vdi control block */
#define VDI_CNTRLMAX    15
#define VDI_INTINMAX  1024
#define VDI_INTOUTMAX  256
#define VDI_PTSINMAX	  256
#define VDI_PTSOUTMAX  256

typedef struct
{
	short *control;
	short *intin;
	short *ptsin;
	short *intout;
	short *ptsout;
} VDIPB;

extern short	vdi_intin[], vdi_intout[],	vdi_ptsin[], vdi_ptsout[];
extern short	vdi_control[];
extern VDIPB	vdi_params;

extern void vdi(VDIPB *pb);

#endif /* VDI */


#ifdef __cplusplus
}
#endif

#endif
