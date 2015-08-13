/************************************************************************/
/*	OBDEFS.H Common OBJECT definitions and structures.		*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

#define ROOT 0
						/* max string length	*/
#define MAX_LEN 81
					/* max depth of search or draw	*/
#define MAX_DEPTH 8
						/* inside patterns	*/
#define IP_HOLLOW 0
#define IP_1PATT 1
#define IP_2PATT 2
#define IP_3PATT 3
#define IP_4PATT 4
#define IP_5PATT 5
#define IP_6PATT 6
#define IP_SOLID 7
						/* gsx modes		*/
#define MD_REPLACE 1
#define MD_TRANS   2
#define MD_XOR     3
#define MD_ERASE   4
						/* bit blt rules	*/
#define ALL_WHITE  0
#define S_AND_D    1
#define	S_AND_NOTD 2
#define S_ONLY     3
#define NOTS_AND_D 4
#define	D_ONLY     5
#define S_XOR_D    6
#define S_OR_D     7
#define	NOT_SORD   8
#define	NOT_SXORD  9
#define D_INVERT  10
#define	NOT_D     11
#define	S_OR_NOTD 12
#define NOTS_OR_D 13
#define	NOT_SANDD 14
#define ALL_BLACK 15
						/* font types		*/
#define IBM 3
#define SMALL 5
						/* Graphic types of obs	*/
#define G_BOX     20
#define G_TEXT    21
#define G_BOXTEXT 22
#define G_IMAGE   23
#define G_USERDEF 24
#define G_IBOX    25
#define G_BUTTON  26
#define G_BOXCHAR 27
#define G_STRING  28
#define G_FTEXT   29
#define G_FBOXTEXT 30
#define G_ICON    31
#define G_TITLE   32
						/* Object flags		 */
#define NONE       0x0
#define SELECTABLE 0x1
#define DEFAULT    0x2
#define EXIT       0x4
#define EDITABLE   0x8
#define RBUTTON   0x10
#define LASTOB    0x20
#define TOUCHEXIT 0x40
#define HIDETREE  0x80
#define INDIRECT 0x100
						/* Object states	*/
#define NORMAL    0x0
#define SELECTED  0x1
#define CROSSED   0x2
#define CHECKED   0x4
#define DISABLED  0x8
#define OUTLINED 0x10
#define SHADOWED 0x20
						/* Object colors	*/
#define WHITE    0
#define BLACK    1
#define RED      2
#define GREEN    3
#define BLUE     4
#define CYAN     5
#define YELLOW   6
#define MAGENTA  7
#define LWHITE   8
#define LBLACK   9
#define LRED     10
#define LGREEN   11
#define LBLUE    12
#define LCYAN    13
#define LYELLOW  14
#define LMAGENTA 15
					/* editable text field definitions */
#define EDSTART 0
#define EDINIT  1
#define EDCHAR  2
#define EDEND   3
					/* editable text justification	  */
#define TE_LEFT  0
#define TE_RIGHT 1
#define TE_CNTR  2

/*	Structure Definitions */

typedef struct object
{
	int		ob_next;	/* -> object's next sibling	*/
	int		ob_head;	/* -> head of object's children */
	int		ob_tail;	/* -> tail of object's children */
	unsigned int	ob_type;	/* type of object- BOX, CHAR,...*/
	unsigned int	ob_flags;	/* flags			*/
	unsigned int	ob_state;	/* state- SELECTED, OPEN, ...	*/
	long		ob_spec;	/* "out"- -> anything else	*/
	int		ob_x;		/* upper left corner of object	*/
	int		ob_y;		/* upper left corner of object	*/
	int		ob_width;	/* width of obj			*/
	int		ob_height;	/* height of obj		*/
} OBJECT;


typedef struct orect
{
struct orect	*o_link;
	int	o_x;
	int	o_y;
	int	o_w;
	int	o_h;
} ORECT;


typedef struct grect
{
	int	g_x;
	int	g_y;
	int	g_w;
	int	g_h;
} GRECT;


typedef struct text_edinfo
{
	long		te_ptext;	/* ptr to text (must be 1st)	*/
	long		te_ptmplt;	/* ptr to template		*/
	long		te_pvalid;	/* ptr to validation chrs.	*/
	int		te_font;	/* font				*/
	int		te_junk1;	/* junk word			*/
	int		te_just;	/* justification- left, right...*/
	int		te_color;	/* color information word	*/
	int		te_junk2;	/* junk word			*/
	int		te_thickness;	/* border thickness		*/
	int		te_txtlen;	/* length of text string	*/
	int		te_tmplen;	/* length of template string	*/
} TEDINFO;


typedef struct icon_block
{
	long	ib_pmask;
	long	ib_pdata;
	long	ib_ptext;
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
	long	bi_pdata;		/* ptr to bit forms data	*/
	int	bi_wb;			/* width of form in bytes	*/
	int	bi_hl;			/* height in lines		*/
	int	bi_x;			/* source x in bit form		*/
	int	bi_y;			/* source y in bit form		*/
	int	bi_color;		/* fg color of blt 		*/
} BITBLK;

typedef struct user_blk
{
	long	ub_code;
	long	ub_parm;
} USERBLK;

typedef struct parm_blk
{
	long	pb_tree;
	int	pb_obj;
	int	pb_prevstate;
	int	pb_currstate;
	int	pb_x, pb_y, pb_w, pb_h;
	int	pb_xc, pb_yc, pb_wc, pb_hc;
	long	pb_parm;
} PARMBLK;

