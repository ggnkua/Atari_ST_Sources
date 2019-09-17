#define ROOT   0

#define MAX_LEN   81                 /* maximum string length */

#define MAX_DEPTH   8                /* maximium depth of search or draw */

#define IP_HOLLOW  0                 /* inside patterns */
#define IP_1PATT   1
#define IP_2PATT   2
#define IP_3PATT   3 
#define IP_4PATT   4
#define IP_5PATT   5 
#define IP_6PATT   6
#define IP_SOLID   7
 
#define MD_REPLACE   1                /* gsx modes */
#define MD_TRANS     2 
#define MD_XOR       3
#define MD_ERASE     4
 
#define ALL_WHITE    0                /* bit blit rules */
#define S_AND_D      1
#define S_AND_NOTD   2
#define S_ONLY       3
#define NOTS_AND_D   4
#define D_ONLY       5
#define S_XOR_D      6 
#define S_OR_D       7
#define NOT_SORD     8
#define NOT_SXORD    9 
#define D_INVERT    10
#define NOT_D       11
#define S_OR_NOTD   12 
#define NOTS_OR_D   13
#define NOT_SANDD   14 
#define ALL_BLACK   15

 
#define IBM 3                       /* font types */
#define SMALL 5


#define G_BOX       20                /* Graphic types of objects */
#define G_TEXT      21
#define G_BOXTEXT	22
#define G_IMAGE		23
#define G_PROGDEF	24
#define	G_USERDEF	G_PROGDEF
#define G_IBOX		25
#define G_BUTTON	26
#define G_BOXCHAR	27
#define G_STRING	28
#define G_FTEXT		29
#define G_FBOXTEXT	30
#define G_ICON		31
#define G_TITLE		32

#define NONE		0x0000	/* Object flags	*/
#define SELECTABLE	0x0001
#define DEFAULT		0x0002
#define EXIT		0x0004
#define EDITABLE	0x0008
#define RBUTTON		0x0010
#define LASTOB		0x0020
#define TOUCHEXIT	0x0040
#define HIDETREE	0x0080
#define INDIRECT	0x0100

#define NORMAL		0x0000	/* Object states */
#define SELECTED	0x0001
#define CROSSED		0x0002
#define CHECKED		0x0004
#define DISABLED	0x0008
#define OUTLINED	0x0010
#define SHADOWED	0x0020
#define SPECIAL		0x0040	/* user defined object state */

#define WHITE		0	/* Object colors */
#define BLACK		1
#define RED			2
#define GREEN		3
#define BLUE		4
#define CYAN		5
#define YELLOW		6
#define MAGENTA		7
#define LWHITE		8
#define LBLACK		9
#define LRED		10
#define LGREEN		11
#define LBLUE		12
#define LCYAN		13
#define LYELLOW		14
#define LMAGENTA	15


#define ED_START	0	/* editable text field definitions */
#define EDSTART	ED_START
#define ED_INIT	1
#define EDINIT	ED_INIT
#define ED_CHAR	2
#define EDCHAR	ED_CHAR
#define ED_END	3
#define EDEND	ED_END


#define TE_LEFT		0	/* editable text justification */
#define TE_RIGHT	1
#define TE_CNTR		2


/* Structure Definitions */


typedef struct object
{
	short ob_next;
	short ob_head;
	short ob_tail;
	unsigned short ob_type;
	unsigned short ob_flags;
	unsigned short ob_state;
	void *ob_spec;
	short ob_x;
	short ob_y;
	short ob_width;
	short ob_height;
} OBJECT;


typedef struct orect
{
        struct orect *o_link;
        int     o_x;
        int     o_y;
        int     o_w;
        int     o_h;
} ORECT;


typedef struct grect
{
	short g_x;
	short g_y;
	short g_w;
	short g_h;
} GRECT;


typedef struct text_edinfo
{
	char *te_ptext;
	char *te_ptmplt;
	char *te_pvalid;
	short te_font;
	short te_junk1;
	short te_just;
	short te_color;
	short te_junk2;
	short te_thickness;
	short te_txtlen;
	short te_tmplen;
} TEDINFO;

typedef struct icon_block
{
	short *ib_pmask;
	short *ib_pdata;
	char *ib_ptext;
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
} ICONBLK;

typedef struct bit_block
{
	short *bi_pdata;
	short bi_wb;
	short bi_hl;
	short bi_x;
	short bi_y;
	short bi_color;
} BITBLK;


typedef struct appl_blk
{
	int (*ub_code)();
	long ub_parm;
} APPLBLK;


typedef struct parm_blk
{
	OBJECT *pb_tree;
	int     pb_obj;
	int     pb_prevstate;
	int     pb_currstate;
	int     pb_x;
	int     pb_y;
	int     pb_w;
	int     pb_h;
	int     pb_xc;
	int     pb_yc;
	int     pb_wc;
	int     pb_hc;
	long pb_parm;
} PARMBLK;
