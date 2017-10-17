#ifndef _GEMFORM_H_
#define _GEMFORM_H_

/* font types		*/
#define IBM 3
#define SMALL 5

#define MAX_DEPTH 8    

/* Object Drawing Types */

/* Graphic types of obs	*/
#define G_BOX 20
#define G_TEXT 21
#define G_BOXTEXT 22
#define G_IMAGE 23
#define G_USERDEF 24
#define G_IBOX 25
#define G_BUTTON 26
#define G_BOXCHAR 27
#define G_STRING 28
#define G_FTEXT 29
#define G_FBOXTEXT 30
#define G_ICON 31
#define G_TITLE 32
#define G_CICON	33

/* Object flags		 */
#define NONE 0x0
#define SELECTABLE 0x1
#define DEFAULT 0x2
#define EXIT 0x4
#define EDITABLE 0x8
#define RBUTTON 0x10
#define LASTOB 0x20
#define TOUCHEXIT 0x40
#define HIDETREE 0x80
#define INDIRECT 0x100
#define FL3DIND 0x200
#define FL3DBAK	0x400
#define FL3DACT 0x600
#define SUBMENU	0x800

/* Object states	*/
#define NORMAL 0x0
#define SELECTED 0x1
#define CROSSED 0x2
#define CHECKED 0x4
#define DISABLED 0x8
#define OUTLINED 0x10
#define SHADOWED 0x20
#define WHITEBAK 0x40
#define DRAW3D 0x80

/* Object colors	*/
#define WHITE 0
#define BLACK 1
#define RED 2
#define GREEN 3
#define BLUE 4
#define CYAN 5
#define YELLOW 6
#define MAGENTA 7
#define LWHITE 8
#define LBLACK 9
#define LRED 10
#define LGREEN 11
#define LBLUE 12
#define LCYAN 13
#define LYELLOW 14
#define LMAGENTA 15

typedef struct
{
	char *te_ptext;	/* ptr to text (must be 1st)	*/
	char *te_ptmplt;	/* ptr to template		*/
	char *te_pvalid;	/* ptr to validation chrs.	*/
	short	te_font;	/* font				*/
	short	te_junk1;	/* junk word			*/
	short	te_just;	/* justification- left, right...*/
	short	te_color;	/* color information word	*/
	short	te_junk2;	/* junk word			*/
	short	te_thickness;	/* border thickness		*/
	short	te_txtlen;	/* length of text string	*/
	short te_tmplen;	/* length of template string	*/
} TEDINFO;

typedef struct
{
	short *ib_pmask;
	short *ib_pdata;
	short *ib_ptext;
	short	ib_char;
	short	ib_xchar;
	short	ib_ychar;
	short	ib_xicon;
	short	ib_yicon;
	short	ib_wicon;
	short	ib_hicon;
	short	ib_xtext;
	short	ib_ytext;
	short	ib_wtext;
	short	ib_htext;
} ICONBLK;

typedef struct
{
	short *bi_pdata;		/* ptr to bit forms data	*/
	short	bi_wb;			/* width of form in bytes	*/
	short	bi_hl;			/* height in lines		*/
	short	bi_x;			/* source x in bit form		*/
	short	bi_y;			/* source y in bit form		*/
	short	bi_color;		/* fg color of blt 		*/
} BITBLK;

typedef struct
{
	void *ub_code;
	long ub_parm;
} USERBLK;

typedef struct cicon_data
{
	short num_planes;
	short *col_data;
	short *mask;
	short *sel_data;
	short *sel_mask;
	struct cicon_data *next_res;
} CICON;

typedef struct cicon_blk
{
	ICONBLK monoblk;
	CICON *mainlist;	/* list of color icons for different res */
} CICONBLK;

typedef struct
{
	unsigned character   : 8;
	signed   framesize   : 8;
	unsigned framecol    : 4;
	unsigned textcol     : 4;
	unsigned textmode    : 1;
	unsigned fillpattern : 3;
	unsigned interiorcol : 4;
} bfobspec;

typedef union obspecptr
{
	long index;
	union obspecptr *indirect;
	bfobspec obspec;
	TEDINFO *tedinfo;
	ICONBLK *iconblk;
	CICONBLK *ciconblk;
	BITBLK *bitblk;
	USERBLK *userblk;
	char *free_string;
} OBSPEC;

typedef struct
{
	short	ob_next;
	short	ob_head;
	short	ob_tail;
	unsigned short ob_type;
	unsigned short ob_flags;
	unsigned short ob_state;
	OBSPEC ob_spec;
	short	ob_x;
	short	ob_y;
	short	ob_width;
	short	ob_height;
} OBJECT;

typedef struct
{
	OBJECT *pb_tree;
	short	pb_obj;
	short	pb_prevstate;
	short	pb_currstate;
	short	pb_x, pb_y, pb_w, pb_h;
	short	pb_xc, pb_yc, pb_wc, pb_hc;
	long pb_parm;
} PARMBLK;

typedef struct
{
	short	x;
	short y;
	short bstate;
	short kstate;
} EVNTDATA;

#define SCROLL_NO 0
#define SCROLL_YES 1

typedef struct _menu
{
	OBJECT *mn_tree;
	short  mn_menu;
	short  mn_item;
	short  mn_scroll;
	short  mn_keystate;
} MENU;

typedef struct
{
	short	g_x;
	short	g_y;
	short	g_w;
	short	g_h;
} GRECT;

/* form */
#define FMD_START  0
#define FMD_GROW   1
#define FMD_SHRINK 2
#define FMD_FINISH 3

/* AES wind_s/get()- Modes */
#define WF_KIND          1
#define WF_NAME          2
#define WF_INFO          3
#define WF_WORKXYWH      4
#define WF_CURRXYWH      5
#define WF_PREVXYWH      6
#define WF_FULLXYWH      7
#define WF_HSLIDE        8
#define WF_VSLIDE        9
#define WF_TOP          10
#define WF_FIRSTXYWH	11
#define WF_NEXTXYWH     12
#define WF_RESVD        13
#define WF_NEWDESK      14
#define WF_HSLSIZE      15
#define WF_VSLSIZE      16
#define WF_SCREEN       17
#define WF_COLOR        18
#define WF_DCOLOR       19
#define WF_OWNER        20
#define WF_BEVENT       24
#define WF_BOTTOM       25

#define END_UPDATE 0
#define BEG_UPDATE 1
#define END_MCTRL  2
#define BEG_MCTRL  3

/* Mouse forms */
#define	ARROW				0
#define	TEXT_CRSR		1
#define	HOURGLASS		2
#define	BUSYBEE			2
#define	POINT_HAND		3
#define	FLAT_HAND		4
#define	THIN_CROSS		5
#define	THICK_CROSS		6
#define	OUTLN_CROSS		7
#define	USER_DEF			255
#define	M_OFF				256
#define	M_ON				257
#define	M_SAVE			258
#define	M_RESTORE		259

typedef struct mfstr
{
	short mf_xhot;
	short mf_yhot;
	short mf_nplanes;
	short mf_fg;
	short mf_bg;
	short mf_mask[16];
	short mf_data[16];
} MFORM;

#define ALL_WHITE 0
#define S_AND_D 1
#define S_AND_NOTD 2
#define S_ONLY 3
#define NOTS_AND_D 4
#define D_ONLY 5
#define S_XOR_D 6
#define S_OR_D 7
#define NOT_SORD 8
#define NOT_SXORD 9
#define D_INVERT 10
#define NOT_D 10
#define S_OR_NOTD 11
#define NOT_S 12
#define NOTS_OR_D	13
#define NOT_SANDD 14
#define ALL_BLACK 15

typedef struct memory_form
{
	void *fd_addr;
	short	fd_w;
	short	fd_h;
	short	fd_wdwidth;
	short	fd_stand;
	short	fd_nplanes;
	short	fd_r1;
	short	fd_r2;
	short	fd_r3;
} MFDB;

/* Array sizes in vdi control block */
#define VDI_CNTRLMAX 15
#define VDI_INTINMAX 1024
#define VDI_PTSINMAX 256
#define VDI_PTSOUTMAX 256

typedef struct
{
	short *control;
	const short *intin;
	const short *ptsin;
	short *intout;
	short *ptsout;
} VDIPB;
  
short form_center(OBJECT *fo_ctree, short *fo_cx, short *fo_cy, short *fo_cw, short *fo_ch);
short form_dial(short fo_diflag, short fo_dilittlx, short fo_dilittly, short fo_dilittlw, short fo_dilittlh, short fo_dibigx, short fo_dibigy, short fo_dibigw, short fo_dibigh);
short form_do(OBJECT *fo_dotree, short fo_dostartob);
short objc_draw(OBJECT *ob_drtree, short ob_drstartob, short ob_drdepth, short ob_drxclip, short ob_dryclip, short ob_drwclip, short ob_drhclip);
short objc_offset(OBJECT *ob_oftree, short ob_ofobject, short *ob_ofxoff, short *ob_ofyoff);
short menu_popup(MENU *me_menu, short me_xpos, short me_ypos, MENU *me_mdata);
short wind_get(short whdl, short subfn, short *g1, short *g2, short *g3, short *g4);
short wind_update(short wi_ubegend);
short graf_handle(short *gr_hwchar, short *gr_hhchar, short *gr_hwbox, short *gr_hhbox);
short graf_mkstate(short *gr_mkmx, short *gr_mkmy, short *gr_mkmstate, short *gr_mkkstate);
short graf_mouse(short gr_monumber, MFORM *gr_mofaddr);
short graf_slidebox(OBJECT *gr_slptree, short gr_slparent, short gr_slobject, short gr_slvh);

void v_opnvwk(short work_in[], short *handle, short work_out[]);
void v_clsvwk(short handle);
void vq_extnd(short handle, short flag, short work_out[]);
void vro_cpyfm(short handle, short mode, short pxy[], MFDB *src, MFDB *dst);

#endif /* _GEMFORM_H_ */
