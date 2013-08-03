/*	OBDEFS.H	03/15/84 - 11/22/84	Gregg Morris		*/

#define ROOT 0
#define NIL -1
						/* max string length	*/
#define MAX_LEN 81
						/* max depth of search	*/
						/*   or draw for objects*/
#define MAX_DEPTH 10
						/* inside patterns	*/
#define IP_HOLLOW 0
#define IP_1PATT 1
#define IP_2PATT 2
#define IP_3PATT 3
#define IP_4PATT 4
#define IP_5PATT 5
#define IP_6PATT 6
#define IP_SOLID 7
						/* system foreground and*/
						/*   background rules	*/
#define SYS_FG 0x1100

#define WTS_FG 0x11a1				/* window title selected*/
						/*   using pattern 2 &	*/
						/*   replace mode text 	*/
#define WTN_FG 0x1100				/* window title normal	*/
						/* gsx modes		*/
#define MD_REPLACE 1
#define MD_TRANS 2
#define MD_XOR 3
#define MD_ERASE 4
						/* gsx styles		*/
#define FIS_HOLLOW 0
#define FIS_SOLID 1
#define FIS_PATTERN 2
#define FIS_HATCH 3
#define FIS_USER 4
						/* bit blt rules	*/
#define ALL_WHITE 0
#define S_AND_D 1
#define S_ONLY 3
#define NOTS_AND_D 4
#define S_XOR_D 6
#define S_OR_D 7
#define D_INVERT 10
#define NOTS_OR_D 13
#define ALL_BLACK 15
						/* font types		*/
#define IBM 3
#define SMALL 5

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
						/* Object states	*/
#define NORMAL 0x0
#define SELECTED 0x1
#define CROSSED 0x2
#define CHECKED 0x4
#define DISABLED 0x8
#define OUTLINED 0x10
#define SHADOWED 0x20
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

#define OBJECT struct object

OBJECT
{
	WORD		ob_next;	/* -> object's next sibling	*/
	WORD		ob_head;	/* -> head of object's children */
	WORD		ob_tail;	/* -> tail of object's children */
	UWORD		ob_type;	/* type of object- BOX, CHAR,...*/
	UWORD		ob_flags;	/* flags			*/
	UWORD		ob_state;	/* state- SELECTED, OPEN, ...	*/
	LONG		ob_spec;	/* "out"- -> anything else	*/
	UWORD		ob_x;		/* upper left corner of object	*/
	UWORD		ob_y;		/* upper left corner of object	*/
	UWORD		ob_width;	/* width of obj			*/
	UWORD		ob_height;	/* height of obj		*/
};

#define ORECT	struct orect

ORECT
{
	ORECT	*o_link;
	WORD	o_x;
	WORD	o_y;
	WORD	o_w;
	WORD	o_h;
} ;


#define GRECT	struct grect

GRECT
{
	WORD	g_x;
	WORD	g_y;
	WORD	g_w;
	WORD	g_h;
} ;


#define TEDINFO struct text_edinfo

TEDINFO
{
	LONG		te_ptext;	/* ptr to text			*/
	LONG		te_ptmplt;	/* ptr to template		*/
	LONG		te_pvalid;	/* ptr to validation chrs.	*/
	WORD		te_font;	/* font				*/
	WORD		te_junk1;	/* junk word			*/
	WORD		te_just;	/* justification- left, right...*/
	WORD		te_color;	/* color information word	*/
	WORD		te_junk2;	/* junk word			*/
	WORD		te_thickness;	/* border thickness		*/
	WORD		te_txtlen;	/* length of text string	*/
	WORD		te_tmplen;	/* length of template string	*/
};


#define ICONBLK struct icon_block

ICONBLK
{
	LONG	ib_pmask;
	LONG	ib_pdata;
	LONG	ib_ptext;
	WORD	ib_char;
	WORD	ib_xchar;
	WORD	ib_ychar;
	WORD	ib_xicon;
	WORD	ib_yicon;
	WORD	ib_wicon;
	WORD	ib_hicon;
	WORD	ib_xtext;
	WORD	ib_ytext;
	WORD	ib_wtext;
	WORD	ib_htext;
};

#define BITBLK struct bit_block

BITBLK
{
	LONG	bi_pdata;		/* ptr to bit forms data	*/
	WORD	bi_wb;			/* width of form in bytes	*/
	WORD	bi_hl;			/* height in lines		*/
	WORD	bi_x;			/* source x in bit form		*/
	WORD	bi_y;			/* source y in bit form		*/
	WORD	bi_rule;		/* blt rule to use		*/
};


#define USERBLK struct user_blk
USERBLK
{
	LONG	ub_code;
	LONG	ub_parm;
};

#define PARMBLK struct parm_blk
PARMBLK
{
	LONG	pb_tree;
	WORD	pb_obj;
	WORD	pb_prevstate;
	WORD	pb_currstate;
	WORD	pb_x, pb_y, pb_w, pb_h;
	WORD	pb_xc, pb_yc, pb_wc, pb_hc;
	LONG	pb_parm;
};

#define MFDB struct memform
MFDB
{
    LONG	mp;
    WORD	fwp;
    WORD	fh;
    WORD	fww;
    WORD	ff;
    WORD	np;
    WORD	r1;
    WORD	r2;
    WORD	r3;
};

#define FILLPAT struct patarray
FILLPAT
{
    WORD	patword[16];
};

#define EDSTART 0
#define EDINIT 1
#define EDCHAR 2
#define EDEND 3

#define TE_LEFT 0
#define TE_RIGHT 1
#define TE_CNTR 2

