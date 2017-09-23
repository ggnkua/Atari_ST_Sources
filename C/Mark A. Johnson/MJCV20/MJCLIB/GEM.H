/* gem/vdi definitions and structures */

struct object {
	int	next;		/* index of next object in the tree	*/
	int	start;		/* index of first subordinate		*/
	int	last;		/* index of last subordinate		*/
	int 	type;		/* type of the object			*/
	int	flags;		/* selectability of the objects		*/
	int	status;		/* state of the object			*/
	int	*spec;		/* pointer to object data structure	*/
	int	x;		/* x coord relative to parent		*/
	int	y;		/* y coord relative to parent		*/
	int	w;		/* width of the object			*/
	int	h;		/* height of the object			*/
};

/* object types */

#define BOX	20
#define TEXT	21
#define BOXTEXT	22
#define IMAGE	23
#define PROGDEF	24
#define IBOX	25
#define BUTTON	26
#define BOXCHAR	27
#define STRING	28
#define FTEXT	29
#define FBOXT	30
#define ICON	31
#define TITLE	32

/* object flags */

#define NONE	0x00
#define SELECT	0x01
#define DEFAULT	0x02
#define EXIT	0x04
#define EDIT	0x08
#define RBUTTON	0x10
#define LASTOBJ	0x20
#define TOUCHX	0x40
#define HIDE	0x80
#define INDIR	0x100

/* object status */

#define CROSSED	0x02
#define CHECKED	0x04
#define DISABLE	0x08
#define OUTLINE	0x10
#define SHADOW	0x20

struct tedinfo {
	char	*text;		/* string to be output			*/
	char	*tmplt;		/* template for the string		*/
	char	*valid;		/* permission string for input		*/
	int	font;		/* character set (normal 3, small 5)	*/
	int	res1;		/* reserved				*/
	int 	just;		/* justify (left 0, right 1, center 2)	*/
	int	color;		/* text color				*/
	int	res2;		/* reserved				*/
	int	thick;		/* border thickness -127 to 128		*/
	int 	txtlen;		/* length of the string			*/
	int	tmplen;		/* length of the template		*/
};

/*
 * vdi structure definitions and defines
 */

/* color indices */
#define	WHITE		0
#define	BLACK		1
#define	RED		2
#define	GREEN		3
#define	BLUE		4
#define	CYAN		5
#define	YELLOW		6
#define	MAGENTA		7
#define	LOW_WHITE	8
#define	GREY		9
#define	LIGHT_RED	10
#define LIGHT_GREEN	11
#define	LIGHT_BLUE	12
#define	LIGHT_CYAN	13
#define	LIGHT_YELLOW	14
#define	LIGHT_MAGENTA	15

/* writing modes */
#define	WR_REPLACE	1
#define	WR_TRANSPARENT	2
#define	WR_XOR		3
#define	WR_REVTRANS	4

/* marker types */
#define	DOT_MTYPE	1
#define PLUS_MTYPE	2
#define ASTERISK_MTYPE	3
#define	SQUARE_MTYPE	4
#define	X_MTYPE		5
#define	DIAMOND_MTYPE	6

/* end styles */
#define SQUARE_ESTYLE	0	/* default */
#define ARROW_ESTYLE	1
#define ROUND_ESTYLE	2

/* line types */
#define SOLID_LTYPE	1
#define LONG_DASH_LTYPE	2
#define DOT_LTYPE	3
#define DASHDOT_LTYPE	4
#define DASH_LTYPE	5
#define	DASHDOTDOT_LTYPE 6
#define USERDEF_LTYPE	7

/* text alignment */
#define LEFTJUST_HOR	0	/* default */
#define CENTERJUST_HOR	1
#define RIGHTJUST_HOR	2
#define BASELINE_VER	0	/* default */
#define HALFLINE_VER	1
#define ASCENTLINE_VER	2
#define BOTTOM_VER	3
#define DESCENT_VER	4
#define TOP_VER		5

/* text effects */
#define THICK_EFCT	1
#define LIGHT_EFCT	2
#define SKEW_EFCT	4
#define UNDERLINE_EFCT	8
#define OUTLINE_EFCT	16
#define SHADOW_EFCT	32

/* fill interior styles */
#define HOLLOW_IS	0
#define SOLID_IS	1
#define PATTERN_IS	2
#define HATCH_IS	3
#define USERDEF_IS	4

/* raster copy modes */
#define	ALL_ZEROS	0
#define S_AND_D		1
#define	S_AND_NOTD	2
#define S_ONLY		3
#define NOTS_AND_D	4
#define NOCHANGE	5
#define	S_XOR_D		6
#define	S_OR_D		7
#define NOTS_AND_NOTD	8
#define NOTS_XOR_NOTD	9
#define NOT_D		10
#define S_OR_NOTD	11
#define NOT_S		12
#define NOTS_OR_D	13
#define NOTS_OR_NOTD	14
#define ALL_ONES	15

struct vdi_openin { 	/* used in v_opnvwk */
	short	linetype,	/* 0 to 6 */
		linecolor,	/* 0=white 1=black */
		marktype,	/* 0 to 6 */
		markcolor,
		textfont,
		textcolor,
		fillstyle,
		fillcolor,
		promptflag;
};

struct	vdi_openout {	/* used in v_opnvwk */
	short	maxx, maxy, flag, pelwidth, pelheight, numcharhght, numlinetyp,
		numlinewid, nummarktyp,	nummarksiz, numgfonts, numpatterns,
		numhatch, numcolors, numgdp, gdplist[10], gdpattr[10],
		doescolor, rotstext, canfill, pixelops,	locateflg, valuatflg,
		choiceflg, stringflg, stationtyp, devicetyp, numwrite,
		inputlevel, alignstext,	inkingflg, rubberband, maxndcx,
		maxndcy, version[5];
};

struct	vdi_mattr {	/* used in vqm_attributes */
	short	marktyp, markcolor, markmode, markwid, markhgt;
};

struct	vdi_lattr {	/* used in vql_attributes */
	short	linetyp, linecolor, linemode, beginstyle, endstyle, linewid;
};

struct	vdi_fattr {	/* used in vqf_attributes */
	short	insidestyle, color, style, wrmode, perimeter;
};

struct	vdi_tattr { 	/* used in vqt_attributes */
	short	textface, color, angle, halign, valign, wrmode,
		charwid, charhgt, charcellw, charcellh;
};

struct	vdi_form {	/* used in vsc_form */
	short	xhotspot, yhotspot, maskcolor, pntrcolor,
		maskshape[16], pntrshape[16];
};

/*
 * Memory Form Definition Block
 *
 */

struct mfdb {
	char	*fd_addr;    /* Address of upper left corner of first */
                             /* raster plane. If NULL then screen     */
	short	fd_w;	     /* Form width in pels                    */
	short	fd_h;        /* Form height in pels                   */
	short	fd_wdwidth;  /* Form width in words                   */
	short	fd_stand;    /* Form format 0= device spec 1=standard */
	short	fd_nplanes;  /* Number of memory planes               */
	short	dummy[3];
};
