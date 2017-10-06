/* tab 8 */

# ifndef GEMMA_GEMMA_H
# define GEMMA_GEMMA_H

# include <mint/slb.h>

# ifdef GEMMA_MULTIPROC
extern SLB gemma[];
# else
extern SLB gemma;
# endif

/* AES constant values
 */

#define NIL		0
#define DESKTOP_HANDLE	0
#define DESK		DESKTOP_HANDLE

/* appl_getinfo modes */
#define AES_LARGEFONT	0
#define AES_SMALLFONT	1
#define AES_SYSTEM	2
#define AES_LANGUAGE	3
#define AES_PROCESS	4
#define AES_PCGEM	5
#define AES_INQUIRE	6
#define AES_MOUSE	8
#define AES_MENU	9
#define AES_SHELL	10
#define AES_WINDOW	11

/* appl_getinfo return values */
#define SYSTEM_FONT	0
#define OUTLINE_FONT	1

#define AESLANG_ENGLISH	0
#define AESLANG_GERMAN	1
#define AESLANG_FRENCH	2
#define AESLANG_SPANISH	4
#define AESLANG_ITALIAN	5
#define AESLANG_SWEDISH	6

/* appl_read modes */
#define APR_NOWAIT	-1

/* appl_search modes */
#define APP_FIRST 	0
#define APP_NEXT	1

		/* appl_search return values*/
#define APP_SYSTEM	0x01
#define APP_APPLICATION	0x02
#define APP_ACCESSORY	0x04
#define APP_SHELL 	0x08

		/* appl_trecord types */
#define APPEVNT_TIMER		0
#define APPEVNT_BUTTON		1
#define APPEVNT_MOUSE		2
#define APPEVNT_KEYBOARD	3

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
#define IBM 			3
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
#define OF_NONE	0x0000
#define OF_SELECTABLE 0x0001
#define OF_DEFAULT	 0x0002
#define OF_EXIT		 0x0004
#define OF_EDITABLE	 0x0008
#define OF_RBUTTON	 0x0010
#define OF_LASTOB 	 0x0020
#define OF_TOUCHEXIT  0x0040
#define OF_HIDETREE	 0x0080
#define OF_INDIRECT	 0x0100
#define OF_FL3DIND	 0x0200	/* bit 9 */
#define OF_FL3DBAK	 0x0400	/* bit 10 */
#define OF_FL3DACT	 0x0600
#define OF_SUBMENU	 0x0800	/* bit 11 */
#define OF_FLAG11		 SUBMENU
#define OF_FLAG12		 0x1000
#define FLAG13		 0x2000
#define FLAG14		 0x4000
#define FLAG15		 0x5000

/* Object states */
#define OS_NORMAL 	0x0000
#define OS_SELECTED	0x0001
#define OS_CROSSED	0x0002
#define OS_CHECKED	0x0004
#define OS_DISABLED	0x0008
#define OS_OUTLINED	0x0010
#define OS_SHADOWED	0x0020
#define OS_WHITEBAK	0x0040
#define OS_DRAW3D	0x0080
#define OS_STATE08	0x0100
#define OS_STATE09	0x0200
#define OS_STATE10	0x0400
#define OS_STATE11	0x0800
#define OS_STATE12	0x1000
#define OS_STATE13	0x2000
#define OS_STATE14	0x4000
#define OS_STATE15	0x8000

/* Object colors - default pall. */
#define WHITE		0
#define BLACK		1
#define RED 	  2
#define GREEN		3
#define BLUE	  4
#define CYAN	  5
#define YELLOW	 6
#define MAGENTA  7
#define LWHITE	 8
#define LBLACK	 9
#define LRED	  10
#define LGREEN	 11
#define LBLUE		12
#define LCYAN		13
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
	short 	g_x;
	short 	g_y;
	short 	g_w;
	short 	g_h;
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
	CICON	 *mainlist;
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
	long			index;
	union obspecptr		*indirect;
	BFOBSPEC		obspec;
	TEDINFO			*tedinfo;
	BITBLK			*bitblk;
	ICONBLK			*iconblk;
	CICONBLK		*ciconblk;
	struct user_block	*userblk;
	char			*free_string;
} OBSPEC;

typedef struct object
{
	short		ob_next;	/* -> object's next sibling */
	short		ob_head; 	/* -> head of object's children	  */
	short		ob_tail; 	/* -> tail of object's children	  */
	unsigned short	ob_type; 	/* type of object */
	unsigned short	ob_flags;	/* flags */
	unsigned short	ob_state;	/* state */
	OBSPEC		ob_spec; 	/* object-specific data */
	short		ob_x; 		/* upper left corner of object */
	short		ob_y; 		/* upper left corner of object */
	short		ob_width;	/* width of obj	*/
	short		ob_height;	/* height of obj */
} OBJECT;

typedef struct parm_block
{
	OBJECT *pb_tree;
	short	pb_obj;
	short	pb_prevstate;
	short	pb_currstate;
	short	pb_x, pb_y, pb_w, pb_h;
	short	pb_xc, pb_yc, pb_wc, pb_hc;
	long	 pb_parm;
} PARMBLK;

typedef struct user_block
{
	short (*ub_code)(PARMBLK *parmblock);
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
	short	mn_menu;
	short	mn_item;
	short	mn_scroll;
	short	mn_keystate;
} MENU;

typedef struct
{
	short 	m_out;
	short 	m_x;
	short 	m_y;
	short 	m_w;
	short	m_h;
} MOBLK;

typedef struct mouse_event_type
{
	short	*x;
	short	*y;
	short	*b;
	short	*k;
} MOUSE;

/* SLB specific structures */

# define GEMMA_VERSION	0x0108L

# define GEM_CTRL	0x00
# define CALL_AES	0x01
# define WD_FIELD	0x02
# define WD_CREATE	0x03
# define WD_OPEN	0x04
# define WD_FORMDO	0x05
# define WD_CLOSE	0x06
# define WD_DELETE	0x07
# define WD_CENTER	0x08
# define RC_INTERSECT	0x09
# define RSRC_XLOAD	0x0a
# define RSRC_XALLOC	0x0b
# define RSRC_XFREE	0x0c
# define TFORK		0x0d
# define WD_ALERT	0x0e
# define OB_XCHANGE	0x0f
# define RSRC_XGADDR	0x10
# define AP_OPEN	0x11
# define WD_ERROR	0x12
# define WD_DUP		0x13
# define WD_LINK	0x14
# define ENV_GET	0x15
# define ENV_EVAL	0x16
# define ENV_GETARGC	0x17
# define ENV_GETARGV	0x18
# define AP_TOP		0x19
# define WD_HANDLER	0x1a
# define WD_UNLINK	0x1b
# define WD_RETURN	0x1c
# define FT_FIX		0x1d
# define AV_DIR_UPD	0x1e
# define AV_XVIEW	0x1f
# define AV_HELP	0x20
# define VA_SEND	0x21
# define OB_XDRAW	0x23
# define TOVL		0x24
# define MN_XPOP	0x25
# define FSELINPUT	0x26
# define AP_CLOSE	0x27
# define NET_URL	0x28
# define PROC_EXEC	0x29

typedef struct {
	long 	aesparams[6];
	short	control[16];
	short	global[16];
	short	int_in[16];
	short	int_out[16];
	long	addr_in[16];
	long	addr_out[16];
	long	vdiparams[5];
	short	contrl[12];
	short	intin[128];
	short	ptsin[128];
	short	intout[128];
	short	ptsout[128];
	short	vwk_handle;
	long	vwk_colors;
} GEM_ARRAY;

typedef struct windial WINDIAL;

struct windial {
	OBJECT 	*wb_treeptr;
	char	*wb_title;
	OBJECT	*wb_icontree;

	short	wb_box;
	short	wb_icon;
	short	wb_handle;
	short	wb_gadgets;
	short	wb_ontop;

	short	wb_desk_x;
	short	wb_desk_y;
	short	wb_desk_w;
	short	wb_desk_h;
	short	wb_work_x;
	short	wb_work_y;
	short	wb_work_w;
	short	wb_work_h;
	short	wb_border_x;
	short	wb_border_y;
	short	wb_border_w;
	short	wb_border_h;
	short	wb_center_x;
	short	wb_center_y;
	short	wb_rclist_x;
	short	wb_rclist_y;
	short	wb_rclist_w;
	short	wb_rclist_h;
	short	wb_rcdraw_x;
	short	wb_rcdraw_y;
	short	wb_rcdraw_w;
	short	wb_rcdraw_h;

	short	wb_start_x;
	short	wb_start_y;
	short	wb_mouse_x;
	short	wb_mouse_y;
	short	wb_object;
	short	wb_key;
	short	wb_startob;
	short	wb_edindex;
	short	wb_fieldinit;
	short	wb_aesmessage[8];

# define WD_MSGVEC	0
# define WD_KEYVEC	1
# define WD_BUTVEC	2
# define WD_RC1VEC	3
# define WD_RC2VEC	4
# define WD_TIMVEC	5

	long	wb_exthandler;
	long	wb_extstack;
	long	wb_keyhandler;
	long	wb_keystack;
	long	wb_buthandler;
	long	wb_butstack;
	long	wb_rc1handler;
	long	wb_rc1stack;
	long	wb_rc2handler;
	long	wb_rc2stack;
	long	wb_timhandler;
	long	wb_timstack;

	short	wb_eventmask;
	short	wb_bclicks;
	short	wb_bmask;
	short	wb_bstate;
	short	wb_m1flag;
	short	wb_m1x;
	short	wb_m1y;
	short	wb_m1w;
	short	wb_m1h;
	short	wb_m2flag;
	short	wb_m2x;
	short	wb_m2y;
	short	wb_m2w;
	short	wb_m2h;
	long	wb_timer;

	long	wb_magic;
	WINDIAL	*wb_prev;
	WINDIAL	*wb_next;
	short	wb_autofree;
	short	wb_iconified;

	long	scratch0[16];
	long	scratch1[16];
	long	scratch2[16];
	long	scratch3[16];
	long	scratch4[16];
	long	scratch5[16];
};

/* SLB macros */

# ifndef GEMMA_MULTIPROC

# define appl_top() (gemma.exec)(gemma.handle, (long)AP_TOP, (short)0)
# define rsrc_xload(file) (gemma.exec)(gemma.handle, (long)RSRC_XLOAD, (short)1, (char *)file)
# define rsrc_xalloc() (gemma.exec)(gemma.handle, (long)RSRC_XALLOC, (short)0)
# define rsrc_xfree() (gemma.exec)(gemma.handle, (long)RSRC_XFREE, (short)0)
# define rsrc_xgaddr(type, obj) (gemma.exec)(gemma.handle, (long)RSRC_XGADDR, (short)2, (short)type, (short)obj)
# define env_get(var) (char *)(gemma.exec)(gemma.handle, (long)ENV_GET, (short)1, (const char *)var)
# define env_eval(var) (char *)(gemma.exec)(gemma.handle, (long)ENV_EVAL, (short)1, (const char *)var)
# define env_getargc() (gemma.exec)(gemma.handle, (long)ENV_GETARGC, (short)0)
# define env_getargv(argc) (char *)(gemma.exec)(gemma.handle, (long)ENV_GETARGV, (short)1, (long)argc)
# define windial_size() (gemma.exec)(gemma.handle, (long)WD_FIELD, (short)0)
# define windial_create(wd, box, icon, ftext, title) (gemma.exec)(gemma.handle, (long)WD_CREATE, (short)5, (WINDIAL *)wd, (short)box, (short)icon, (short)ftext, (char *)title)
# define windial_xcreate(wd, box, icon, ftext, title, gadgets) (gemma.exec)(gemma.handle, (long)WD_CREATE, (short)6, (WINDIAL *)wd, (short)box, (short)icon, (short)ftext, (char *)title, (short)gadgets)
# define windial_open(wd) (gemma.exec)(gemma.handle, (long)WD_OPEN, (short)1, (WINDIAL *)wd)
# define windial_formdo(wd) (gemma.exec)(gemma.handle, (long)WD_FORMDO, (short)1, (WINDIAL *)wd)
# define windial_close(wd) (gemma.exec)(gemma.handle, (long)WD_CLOSE, (short)1, (WINDIAL *)wd)
# define windial_delete(wd) (gemma.exec)(gemma.handle, (long)WD_DELETE, (short)1, (WINDIAL *)wd)
# define windial_center(wd) (gemma.exec)(gemma.handle, (long)WD_CENTER, (short)1, (WINDIAL *)wd)
# define windial_dup(old, new) (gemma.exec)(gemma.handle, (long)WD_DUP, (short)2, (WINDIAL *)old, (WINDIAL *)new)
# define windial_link(from, to) (gemma.exec)(gemma.handle, (long)WD_LINK, (short)2, (WINDIAL *)from, (WINDIAL *)to)
# define windial_longjmp(wd, vec) (gemma.exec)(gemma.handle, (long)WD_RETURN, (short)2, (WINDIAL *)wd, (short)vec);
# define windial_unlink(wd) (gemma.exec)(gemma.handle, (long)WD_UNLINK, (short)1, (WINDIAL *)wd)
# define windial_setjmp(wd, vec, adr) (gemma.exec)(gemma.handle, (long)WD_HANDLER, (short)4, (WINDIAL *)wd, (short)vec, (void *)adr)
# define windial_alert(button, str) (gemma.exec)(gemma.handle, (long)WD_ALERT, (short)2, (short)button, (char *)str)
# define windial_error(error, msg) (gemma.exec)(gemma.handle, (long)WD_ERROR, (short)2, (long)error, (char *)msg)
# define thread_fork(addr, ptitle, stack, mode) (gemma.exec)(gemma.handle, (long)TFORK, (short)5, _startup, (void *)addr, (char *)ptitle, (long)stack, (long)mode)
# define thread_overlay(addr, ptitle, stack, mode) (gemma.exec)(gemma.handle, (long)TOVL, (short)5, _startup, (void *)addr, (char *)ptitle, (long)stack, (long)mode)
# define av_dir_update(drive) (gemma.exec)(gemma.handle, (long)AV_DIR_UPD, (short)1, (short)drive)
# define av_view(pathname) (gemma.exec)(gemma.handle, (long)AV_XVIEW, (short)1, (char *)pathname)
# define av_help(fname) (gemma.exec)(gemma.handle, (long)AV_HELP, (short)1, (char *)fname)
# define open_url(url) (gemma.exec)(gemma.handle, (long)NET_URL, (short)1, (char *)url)
# define rc_intersect(src,dest) (gemma.exec)(gemma.handle, (long)RC_INTERSECT, (short)2, (RECT *)src, (RECT *)dest)
# define objc_xchange(wd, obj, newst, redraw) (gemma.exec)(gemma.handle, (long)OB_XCHANGE, (short)4, (WINDIAL *)wd, (short)obj, (short)newst, (short)redraw)
# define ftext_init(tree, obj) (gemma.exec)(gemma.handle, (long)FT_FIX, (short)2, (short)tree, (short)obj)
# define file_select(title, mask, flag) (char *)(gemma.exec)(gemma.handle, (long)FSELINPUT, (short)3, (char *)title, (char *)mask, (short)flag)
# define menu_xpop(wd, obj, menu) (gemma.exec)(gemma.handle, (long)MN_XPOP, (short)3, (WINDIAL *)wd, (short)obj, (MENU *)menu)
# define proc_exec(mode, flag, cmd, tail, env) (gemma.exec)(gemma.handle, (long)PROC_EXEC, (short)5, (short)mode, (long)flag, (char *)cmd, (char *)tail, (char *)env)
# define objc_xdraw(wd, obj) (gemma.exec)(gemma.handle, (long)OB_XDRAW, (short)2, (WINDIAL *)wd, (short)obj);

# else /* MULTIPROC */

# error "MULTIPROC flag not yet available"

# endif /* MULTIPROC */

/* SLB bindings for libgemma.a */

extern long _startup(void);
extern short call_aes(GEM_ARRAY *gem, short fn);
extern GEM_ARRAY *gem_control(void);
extern long appl_open(char *file, short thread, char *pname);
extern long appl_close(void);

/* AES bindings for libgemma.a */

extern long appl_control(short ap_cid, short ap_cwhat, void *ap_cout);
extern long appl_exit(void);
extern long appl_find(char *name);
extern long appl_getinfo(short cwhat, short *out1, short *out2, short *out3, short *out4);
extern long appl_init(void);
extern long appl_read(short ApId, short Length, void *ApPbuff);
extern long appl_search(short mode, char *fname, short *type, short *ap_id);
extern long appl_tplay(void *Mem, short Num, short Scale);
extern long appl_trecord(void *Mem, short Count);
extern long appl_write(short ApId, short Length, void *ApPbuff);
extern long appl_yield(void);

extern long evnt_button(short Clicks, short WhichButton, short WhichState, short *Mx, short *My, short *ButtonState, short *KeyState); 
extern long evnt_dclick(short ToSet, short SetGet);
extern long evnt_keybd(void);
extern long evnt_mesag(short MesagBuf[]);
extern long evnt_mouse(short EnterExit, short InX, short InY, short InW, short InH, short *OutX, short *OutY, short *ButtonState, short *KeyState); 
extern long evnt_multi(short Type, short Clicks, short WhichButton, short WhichState, 
			short EnterExit1, short In1X, short In1Y, short In1W, short In1H, 
			short EnterExit2, short In2X, short In2Y, short In2W, short In2H,
			short MesagBuf[], unsigned long Interval, short *OutX, short *OutY,
			short *ButtonState, short *KeyState, short *Key, short *ReturnCount);
extern long evnt_timer(unsigned long msec);

extern long form_alert(short DefButton, char *Str);
extern long form_button(void *Btree, short Bobject, short Bclicks, short *Bnxtobj);
extern long form_center(void *Tree, short *Cx, short *Cy, short *Cw, short *Ch);
extern long form_dial(short Flag, short Sx, short Sy, short Sw, short Sh, short Bx, short By, short Bw, short Bh);
extern long form_do(void *Tree, short StartObj);
extern long form_error(short ErrorCode);
extern long form_keybd(void *Ktree, short Kobject, short Kobnext, short Kchar, short *Knxtobject, short *Knxtchar);
extern long form_popup(OBJECT *tree, short x, short y);

extern long fsel_exinput(char *Path, char *File, short *ExitButton, char *title);
extern long fsel_input(char *Path, char *File, short *ExitButton);

extern long graf_dragbox(short Sw, short Sh, short Sx, short Sy, short Bx, short By, short Bw, short Bh, short *Fw, short *Fh); 
extern long graf_growbox(short Sx, short Sy, short Sw, short Sh, short Fx, short Fy, short Fw, short Fh); 
extern long graf_handle(short *Wchar, short *Hchar, short *Wbox, short *Hbox);
extern long graf_movebox(short Sw, short Sh, short Sx, short Sy, short Dx, short Dy);
extern long graf_mkstate(short *Mx, short *My, short *ButtonState, short *KeyState); 
extern long graf_mouse(short Form, void *FormAddress);
extern long graf_multirubber(short x, short y, short minw, short minh, GRECT *rec, short *outw, short *outh);
extern long graf_rubberbox(short Ix, short Iy, short Iw, short Ih, short *Fw, short *Fh);
extern long graf_shrinkbox(short Fx, short Fy, short Fw, short Fh, short Sx, short Sy, short Sw, short Sh); 
extern long graf_slidebox(void *Tree, short Parent, short Object, short Direction); 
extern long graf_watchbox(void *Tree, short Object, short InState, short OutState);

extern long menu_attach(short me_flag, OBJECT *me_tree, short me_item, MENU *me_mdata);
extern long menu_bar(void *Tree, short ShowFlag);
extern long menu_icheck(void *Tree, short Item, short CheckFlag);
extern long menu_ienable(void *Tree, short Item, short EnableFlag);
extern long menu_istart(short me_flag, OBJECT *me_tree, short me_imenu, short me_item);
extern long menu_popup(MENU *me_menu, short me_xpos, short me_ypos, MENU *me_mdata);
extern long menu_register(short ApId, char *MenuText);
extern long menu_settings(short me_flag, MN_SET *me_values);
extern long menu_text(void *Tree, short Item, char *Text);
extern long menu_tnormal(void *Tree, short Item, short NormalFlag);

extern long objc_add(void *Tree, short Parent, short Child);
extern long objc_change(void *Tree, short Object, short Res, short Cx, short Cy, short Cw, short Ch, short NewState,short Redraw);
extern long objc_delete(void *Tree, short Object);
extern long objc_draw(void *tree, short obj, short depth, short wx, short wy, short ww, short wh);
extern long objc_edit(void *tree, short obj, short ch, short idx, short mode);
extern long objc_find(void *Tree, short Start, short Depth, short Mx, short My);
extern long objc_offset(void *tree, short obj, short *x, short *y);
extern long objc_order(void *Tree, short Object, short NewPos);
extern long objc_sysvar(short mode, short which, short in1, short in2, short *out1, short *out2);
extern long objc_xfind(OBJECT *tree, short start, short depth, short x, short y);

extern long rsrc_free(void);
extern long rsrc_gaddr(short Type, short Index, void *Address);
extern long rsrc_load(char *Name);
extern long rsrc_obfix(void *Tree, short Index);
extern long rsrc_rcfix(void *rc_header);
extern long rsrc_saddr(short Type, short Index, void *Address);

extern long scrp_read(char *Scrappath);
extern long scrp_write(char *Scrappath);

extern long shel_envrn(char **result, char *param);
extern long shel_find(char *buf);
extern long shel_get(char *Buf, short Len);
extern long shel_help(short sh_hmode, char *sh_hfile, char *sh_hkey);
extern long shel_put(char *Buf, short Len);
extern long shel_rdef(char *lpcmd, char *lpdir);
extern long shel_read(char *Command, char *Tail);
extern long shel_wdef(char *lpcmd, char *lpdir);
extern long shel_write(short Exit, short Graphic, short Aes, void *Command, char *Tail);

extern long wind_calc(short Type, short Parts, short InX, short InY, short InW, short InH, short *OutX, short *OutY, short *OutW, short *OutH);	
extern long wind_close(short WindowHandle);
extern long wind_create(short Parts, short Wx, short Wy, short Ww, short Wh); 
extern long wind_delete(short WindowHandle);
extern long wind_draw(short handle, short startobj);
extern long wind_find(short X, short Y);
extern long wind_get(short WindowHandle, short What, short *W1, short *W2, short *W3, short *W4); 
extern void wind_new(void);
extern long wind_open(short WindowHandle, short Wx, short Wy, short Ww, short Wh);
extern long wind_set(short WindowHandle, short What, short W1, short W2, short W3, short W4);
extern long wind_sget(short handle, short field, char *buf);
extern long wind_update(short Code);

# endif

/* EOF */
