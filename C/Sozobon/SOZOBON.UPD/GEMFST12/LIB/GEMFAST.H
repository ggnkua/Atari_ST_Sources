
/**************************************************************************
 *
 * GEMFAST.H - Header file for common VDI and AES symbols.	
 *
 *  This header file contains items compatible with both GEMDEFS and OBDEFS
 *  from the Alcyon system.  Note that there are no 'extern' definitions
 *  for the functions, because they all return a signed int and work
 *  fine as autodefined functions.
 *
 *  If you have a lot of source already coded for #include <gemdefs.h>,
 *  you can continue to use your original gemdefs file, or you can rename
 *  this file to gemdefs.h; if your source also includes obdefs.h, remove
 *  them when using this file.
 *
 * Credits dept:
 *	This file bears an amazing similarity to the original Alcyon GEMDEFS
 *	and OBDEFS header files, which are copyrighted by Atari.  What can I
 *	say?  Copyrighted or not, these are the names and values that every-
 *	body uses, so of course the files look *awful* similar...
 *
 *************************************************************************/

							/* evnt_multi flags */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020
							/* keyboard states */
#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL 	0x0004
#define K_ALT		0x0008
							/* event message values */
#define MN_SELECTED 10
#define WM_REDRAW	20
#define WM_TOPPED	21
#define WM_CLOSED	22
#define WM_FULLED	23
#define WM_ARROWED	24
#define WM_HSLID	25
#define WM_VSLID	26
#define WM_SIZED	27
#define WM_MOVED	28
#define WM_NEWTOP	29
#define AC_OPEN	40
#define AC_CLOSE	41
							/* form_dial opcodes */
#define FMD_START	0
#define FMD_GROW	1
#define FMD_SHRINK	2
#define FMD_FINISH	3
							/* rsrc_gaddr structure types */
#define R_TREE 	0 
#define R_OBJECT	1
#define R_TEDINFO	2
#define R_ICONBLK	3
#define R_BITBLK	4
#define R_STRING	5
#define R_IMAGEDATA 6
#define R_OBSPEC	7
#define R_TEPTEXT	8
#define R_TEPTMPLT	9
#define R_TEPVALID	10
#define R_IBPMASK	11 
#define R_IBPDATA	12	
#define R_IBPTEXT	13
#define R_BIPDATA	14
#define R_FRSTR	15
#define R_FRIMG	16 
							/* Window Attributes */
#define NAME		0x0001
#define CLOSER 	0x0002
#define FULLER 	0x0004
#define MOVER		0x0008
#define INFO		0x0010
#define SIZER		0x0020
#define UPARROW	0x0040
#define DNARROW	0x0080
#define VSLIDE 	0x0100
#define LFARROW	0x0200
#define RTARROW	0x0400
#define HSLIDE 	0x0800
							/* wind_create flags */
#define WC_BORDER	0
#define WC_WORK	1
							/* wind_get flags */
#define WF_KIND	 1
#define WF_NAME	 2
#define WF_INFO	 3
#define WF_WORKXYWH  4
#define WF_CURRXYWH  5
#define WF_PREVXYWH  6
#define WF_FULLXYWH  7
#define WF_HSLIDE	 8
#define WF_VSLIDE	 9
#define WF_TOP 	 10
#define WF_FIRSTXYWH 11
#define WF_NEXTXYWH  12
#define WF_RESVD	 13
#define WF_NEWDESK	 14
#define WF_HSLSIZE	 15
#define WF_VSLSIZE	 16
#define WF_SCREEN	 17
							/* wind_update flags */
#define END_UPDATE	0
#define BEG_UPDATE	1
#define END_MCTRL	2
#define BEG_MCTRL	3
							/* graf_mouse mouse types*/
#define ARROW		0
#define BEE		2
#define TEXT_CRSR	1
#define HOURGLASS	2
#define POINT_HAND	3
#define FLAT_HAND	4
#define THIN_CROSS	5
#define THICK_CROSS 6
#define OUTLN_CROSS 7
#define USER_DEF	255
#define M_OFF		256
#define M_ON		257
						/* max depth of search or draw  */
#define MAX_DEPTH	8
						/* inside fill patterns	*/
#define IP_HOLLOW	0
#define IP_1PATT	1
#define IP_2PATT	2
#define IP_3PATT	3
#define IP_4PATT	4
#define IP_5PATT	5
#define IP_6PATT	6
#define IP_SOLID	7
						/* normal graphics drawing modes */
#define MD_REPLACE	1
#define MD_TRANS	2
#define MD_XOR 	3
#define MD_ERASE	4
						/* bit blt rules */
#define ALL_WHITE	0
#define S_AND_D	1
#define S_AND_NOTD	2
#define S_ONLY 	3
#define NOTS_AND_D	4
#define D_ONLY 	5
#define S_XOR_D	6
#define S_OR_D 	7
#define NOT_SORD	8
#define NOT_SXORD	9
#define D_INVERT	10
#define NOT_D		10
#define S_OR_NOTD	11
#define NOT_S		12
#define NOTS_OR_D	13
#define NOT_SANDD	14
#define ALL_BLACK	15
						/* object types */
#define G_BOX		20
#define G_TEXT 	21
#define G_BOXTEXT	22
#define G_IMAGE	23
#define G_USERDEF	24
#define G_IBOX 	25
#define G_BUTTON	26
#define G_BOXCHAR	27
#define G_STRING	28
#define G_FTEXT	29
#define G_FBOXTEXT	30
#define G_ICON 	31
#define G_TITLE	32
						/* object flags */
#define NONE		0x0000
#define SELECTABLE	0x0001
#define DEFAULT	0x0002
#define EXIT		0x0004
#define EDITABLE	0x0008
#define RBUTTON	0x0010
#define LASTOB 	0x0020
#define TOUCHEXIT	0x0040
#define HIDETREE	0x0080
#define INDIRECT	0x0100
						/* Object states */
#define NORMAL 	0x0000
#define SELECTED	0x0001
#define CROSSED	0x0002
#define CHECKED	0x0004
#define DISABLED	0x0008
#define OUTLINED	0x0010
#define SHADOWED	0x0020
						/* editable text field definitions */
#define EDSTART	0
#define EDINIT 	1
#define EDCHAR 	2
#define EDEND		3
						/* editable text justification */
#define TE_LEFT	0
#define TE_RIGHT	1
#define TE_CNTR	2
					    /* VDI Memory Form Definition Block */
typedef struct form_definition
	{
	long fd_addr;
	int	fd_w;
	int	fd_h;
	int	fd_wdwidth;
	int	fd_stand;
	int	fd_nplanes;
	int	fd_r1;
	int	fd_r2;
	int	fd_r3;
	} FDB;
							/* Mouse Form Definition Block */
typedef struct mouse_form
	{
	int mf_xhot;
	int mf_yhot;
	int mf_nplanes;
	int mf_fg;
	int mf_bg;
	int mf_mask[16];
	int mf_data[16];
	} MFORM ;

typedef struct object
	{
	int	ob_next;			/* -> object's next sibling	  */
	int	ob_head;			/* -> head of object's children */
	int	ob_tail;			/* -> tail of object's children */
	unsigned int ob_type;	/* type of object			  */
	unsigned int ob_flags;	/* flags					  */
	unsigned int ob_state;	/* state					  */
	long ob_spec;			/* object-specific data		  */
	int	ob_x;			/* upper left corner of object  */
	int	ob_y;			/* upper left corner of object  */
	int	ob_width; 		/* width of obj			  */
	int	ob_height;		/* height of obj			  */
	} OBJECT;

typedef struct graphic_rectangle
	{
	int g_x;
	int g_y;
	int g_w;
	int g_h;
	} GRECT;

typedef struct vdi_rectangle
	{
	int v_x1;
	int v_y1;
	int v_x2;
	int v_y2;
	} VRECT;

typedef struct text_edinfo
	{
	char *te_ptext;		/* ptr to text 		    */
	char *te_ptmplt;		/* ptr to template		    */
	char *te_pvalid;		/* ptr to validation chrs.   */
	int	te_font;			/* font				    */
	int	te_junk1; 		/* junk word			    */
	int	te_just;			/* justification		    */
	int	te_color; 		/* color information word    */
	int	te_junk2; 		/* junk word			    */
	int	te_thickness;		/* border thickness 	    */
	int	te_txtlen;		/* length of text string     */
	int	te_tmplen;		/* length of template string */
	} TEDINFO;

typedef struct icon_block
	{
	int	*ib_pmask;
	int	*ib_pdata;
	char *ib_ptext;
	int	ib_char;
	int	ib_xchar;
	int	ib_ychar;
	int	ib_xicon;
	int	ib_yicon;
	int	ib_wicon;
	int	ib_hicon;
	int	ib_xtext;
	int	ib_ytext;
	int	ib_wtext;
	int	ib_htext;
	} ICONBLK;

typedef struct bit_block
	{
	int	*bi_pdata;			/* ptr to bit forms data  */
	int	bi_wb;				/* width of form in bytes */
	int	bi_hl;				/* height in lines		 */
	int	bi_x;				/* source x in bit form	 */
	int	bi_y;				/* source y in bit form	 */
	int	bi_color; 			/* fg color of blt		 */
	} BITBLK;

typedef struct user_block
	{
	long ub_code;
	long ub_parm;
	} USERBLK;

typedef struct parm_block
	{
	long pb_tree;
	int	pb_obj;
	int	pb_prevstate;
	int	pb_currstate;
	int	pb_x, pb_y, pb_w, pb_h;
	int	pb_xc, pb_yc, pb_wc, pb_hc;
	long pb_parm;
	} PARMBLK;

/*  end of GEMFAST.H */

