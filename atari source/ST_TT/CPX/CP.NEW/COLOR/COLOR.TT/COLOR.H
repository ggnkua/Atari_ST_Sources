/*
 * Color.h
 *
 * Mar 12 1990	ml.	Started this.
 */
 
/* total # of color registers */
#define	NUMREG		256


/* ST Resolutions */
#define	STMID		1				/* ST medium rez */
#define	STHI		2				/* ST high rez */
#define	TTHI		6				/* TT high rez */
#define	TTLOW		7				/* TT low rez */


/* Video modes */
#define	_VDO		0x5f56444fL		/* cookie for video modes */
#define	STVDO		0				/* ST video */
#define	STEVDO		1				/* STE video */
#define	TTVDO		2				/* TT video */


/* Flip bit - bit 0 at FLIPLOC; 1 - background is white */
#define	FLIPLOC		(int *)0xffff8240L	/* flip bit location */
#define	NOT_FLIPPED	0x0001				/* bit 0 set means not flipped */


/* Flags */
#define	HILITE		0				/* highlight an object */
#define	DEHILITE	1				/* de-highlight an object */


/* RGB gun value related */
#define VAL_PAGE	2				/* pager increment */


/* Bank related */
#define	NUM_BNK		16				/* number of banks of color */
#define	COL_PER_BNK	16				/* number of colors per bank */
#define	BNK_MIN		0				/* smallest bank # */
#define	BNK_MAX		NUM_BNK-1		/* biggest bank # */
#define	BNK_PAGE	2				/* pager increment */


/* Related to color boxes shown */
#define	MAX_COL_SHOWN	16			/* # color boxes on screen */
#define	COL_PER_ROW		4			/* # color box per line */


/* State of a color */
#define	DIRTY	0x01				/* color has been modified */
#define	CLEAN	0x00				/* color has NOT been modified */


/* Mouse-related */
#define	HIDE_MOUSE	graf_mouse(M_OFF, 0L)
#define	SHOW_MOUSE	graf_mouse(M_ON, 0L)
#define	ARROW_MOUSE	graf_mouse(ARROW, 0L)
#define	BEE_MOUSE	graf_mouse(BUSYBEE, 0L)
#define	DRAG_MOUSE	graf_mouse(FLAT_HAND, 0L)


/* Key codes */
#define	UNDO	0x6100		/* Undo key */
#define	HOME	0x4700		/* Clr Home Key */


/* Palette size */
#define	MONO	2					/* monochrome */


/* Indices into array of RGB gun values for VDI */
#define	R	0					/* red gun value */
#define	G	1					/* green gun value */
#define	B	2					/* blue gun value */


/* Structure for RGB gun values of each color */
typedef struct {
	int	rint;					/* red intensity */
	int	gint;					/* green intensity */
	int	bint;					/* blue intensity */
} RGB;


/* Structure for variables saved at data segment of CPX */
typedef struct {
	int	bnk;						/* bank number */
	int	inv;						/* invert state */
	int	gray;						/* hypermono mode */
	union {								/* colors of bank 0 */
		RGB ttlow[NUMREG];				/* for TT low rez */
		RGB	orez[COL_PER_BNK];			/* for all other rez */
	} ubnk0;
	RGB	obnk[NUM_BNK-1][COL_PER_BNK];	/* colors of banks 1-15 */
} DEFAULTS;

