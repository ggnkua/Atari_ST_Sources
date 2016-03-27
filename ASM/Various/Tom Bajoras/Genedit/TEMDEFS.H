/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras
 
                          Copyright 1990/1991 Tom Bajoras

   defines and typedefs for TEM stuff

******************************************************************************/

#define NTEMPAGES 8					/* # of template pages */
#define NTEMSEGS (NTEMPAGES+2)	/* # of template segments */
#define NTEMCTRLS 10					/* # of control types on pallette */
#define MAXEDLENG 5000L				/* largest control that can be edited */
#define MAXNBUTROW 9					/* maximum dimensions of button arrays */
#define MAXNBUTCOL 9
#define MAXNPOINTS 32				/* maximum # points on a graph */
#define MAXNCALC (MAXNBUTROW*MAXNBUTCOL+1)
#define MAXNVALS (MAXNBUTROW*MAXNBUTCOL)
#define MAXSTRLENG 255				/* string in string pool (+ null term) */
#define MAXANGLE 3600				/* tenths of degrees per circle */
#define MAXLINK 3						/* # of controls per val upd'd in real-time */
#define KNOBANGLE (MAXANGLE/8)
#define JOYSTICKW 8			/* half of joystick indicator diagonal (mono) */
#define MAXRECTFILL 24		/* highest #'d fill pattern in rectangle control */
#define NEBDTCOLS 5			/* # editable fields in ebdt entry */
#define PTFIXED 0				/* types of pts for grph */
#define PTFOLLOW 1
#define PTFULL 2

#define CTYP_LINE 0			/* control types */
#define CTYP_RECT 1
#define CTYP_TEXT 3
#define CTYP_NUMB 4
#define CTYP_KNOB 5
#define CTYP_SLID 7
#define CTYP_IBUT 8
#define CTYP_CBUT 9
#define CTYP_GRPH 10
#define CTYP_JOY  11
#define CTYP_EBDT -1
#define CTYP_MIDI -3
#define CTYP_DUMMY 999

#define OUTPUT_BIT (1<<6)		/* bits in options byte */
#define VALIDT_BIT (1<<5)
										/* others go here !!! */

/* used in clean_pool() */
typedef struct {
	long offset;
	long new;
	int used;
} POOL_INFO;

/* 256-byte null-term'd, null-padded string */
typedef struct {
	char str[256];
} STR256;

/* EBDT entry */
typedef struct {
	long offset;   /* parameter's byte offset into edit buffer */
	char name[32]; /* parameter name (31 characters + null) */
	int length;    /* bytes in parameter: 1,2,4 */
	long low,high; /* parameter minimum and maximum values (high>=low) */
} EBDT;

/* start of control */
typedef struct {
	int type;		/* control type, #defined as CTYP_xxxx */
	int length;		/* bytes in control, including CTRLHEADER */
} CTRLHEADER;

/* follows ctrlheader in visible control */
typedef struct {
	int y1;	/* y-coord of top of control, relative to template window */
	int x1;	/* x-coord of left edge of control, relative to template window */
	int y2;	/* y-coord of bottom of control, relative to template window */
	int x2;	/* x-coord of right edge of control, relative to template window */
				/* for all controls: y2>=y1, for a non-line: x2>=x1 */
	char options;			/* bits:
									0= control selected
									6= output only
									7= "extended control type" (not used yet)
								*/
	char color;				/* all 8 bits must be used, for GenEdit Mac */
} MAC_RECT;

/* Value information part of control */
typedef struct {
   int val;			/* the control's value */
   int low;
   int high;		/* min and max for value:  For some control
							types this is user-editable; for other control types
							it is fixed.  high >= low */
   int invert;		/* 0: outputted value is val
							1: outputted value is high-val+low */
   int linkpage;	/* page # where control is linked to, -1 same as self */
   int linkctrl;	/* index to control linked to, -1 same as self */
   int linkval;	/* index to which value is controlled on the controlled
							control.  Must be < the controlled control's number of
							values.  -1 same as self */
} VAL_INFO;

/* Extended value information (used in IBUT) */
typedef struct {
	VAL_INFO val;
	long str;		/* offset into string pool, -1L for null */
} XVAL_INFO;

typedef struct {
	char xmode,xfactor,xline;
	char ymode,yfactor,yline;
	char active;
	char rfu;
} PT_INFO;

/* Super-Extended value information (used in GRPH) */
typedef struct {
	VAL_INFO xval,yval;
	PT_INFO pt_info;
} XXVAL_INFO;

/* Line control */
typedef struct {
	MAC_RECT rect;
	unsigned int style;	/* = pattern: $FFFF solid, $AAAA half-tone, etc. */
} CTRL_LINE;

/* Rectangle control */
typedef struct {
	MAC_RECT rect;
	int fill;   /* 0= hollow, 1= solid, > 1 machine-dependent fill pattern */
} CTRL_RECT;

/* Text control */
typedef struct {
   MAC_RECT rect;
   int font;		/* 0= normal, 1= miniature */
   VAL_INFO val;  /* low always 0 */
   long str[1];	/* offset into string pool for each value (-1L = null) */
} CTRL_TEXT;

/* Number control */
typedef struct {
   MAC_RECT rect;
   int font;		/* 0= normal, 1= miniature */
   VAL_INFO val;
} CTRL_NUMB;

/* Knob control */
typedef struct {
   MAC_RECT rect;
   VAL_INFO val;
} CTRL_KNOB;

/* Slider control */
typedef struct {
   MAC_RECT rect;   /* if height > width, then slider moves vertically.
                     if height <= width, then slider moves horizontally. */
   VAL_INFO val;
} CTRL_SLID;

/* Independent button set control */
typedef struct {
   MAC_RECT rect;		/* coordinates are for the array.  The array's rectangle
								is divided into button rectangles according to nrows
								and ncols. */
   int font;			/* 0= normal, 1= miniature */
   int nrows,ncols;	/* how many rows and how many columns in the array of
								buttons, each= 1-9 */
   int flag;			/* if nrows*ncols=1:
								0= toggle, 1= momentary
								if nrows*ncols>1:
								=0 or 1, minimum # buttons in the set that has to
								selected */
	XVAL_INFO xval[1]; /* Each button has 2 possible values: low
								if not selected; high if selected */
							 /* one of these for each button.  Order:
								left-to-right, top-to-bottom */
} CTRL_IBUT;

/* Combined button set control */
typedef struct {
   MAC_RECT rect;		/* coordinates are for the array.  The array's rectangle
								is divided into button rectangles according to nrows
								and ncols. */
   int font;			/* 0= normal, 1= miniature */
   int nrows,ncols;	/* how many rows and how many columns in the array of
								buttons, each = 1-9 */
   int flag;			/* if nrows*ncols=1:
								0= toggle, 1= momentary
								if nrows*ncols>1:
								=0 or 1, minimum # buttons in the set that has to
								selected */
   VAL_INFO val;		/* value is the selected button number (1-n) (0 if none
								is selected).  low always 0 or 1, high always
								nrows*ncols. */
   long str[1];		/* string inside each button.  Truncated on
								right if can't fit inside button.  Order: left-to-
								right, top-to-bottom */
} CTRL_CBUT;

/* Graph control */
typedef struct {
   MAC_RECT rect;
	char yaxis;					/* x-coordinate of y-axis, percent from left,
										0-100, -1 invisible */
	char xaxis;					/* y-coordinate of x-axis, percent from bottom,
										0-100, -1 invisible */
   int npoints;				/* how many points on the graph */
	XXVAL_INFO xxval[1];		/* one of these for each point */
} CTRL_GRPH;

/* Joystick control */
typedef struct {
   MAC_RECT rect;
   VAL_INFO val[2];            /* x-value, y-value, sum <= a constant */
} CTRL_JOY;

/* EBDT control */
typedef struct {
   int index;      /* EBDT entry number for edit buffer parameter to be changed
                      by this control, -1 for none */
   int linkpage;   /* page # where control is linked to */
   int linkctrl;   /* see VAL_INFO */
   int linkval;
	int undo;		/* used during ebdt editing */
} CTRL_EBDT ;

/* MIDI control */
typedef struct {
	int low;
	int high;
	int delta;		 /* how often to send the string as value is modified in
							 real-time, 0= non-real-time */
   int linkpage;   /* page # where control is linked to */
   int linkctrl;   /* see VAL_INFO */
   int linkval;
   long str;		 /* offset into string pool (-1L = null) */
} CTRL_MIDI ;

/* Each character in the string in a MIDI control represents a hex nibble,
	as follows:

   '0' - '9', 'A' - 'F', 'a'- 'f' = hex constants
   'n' = channel, always lower case, gotten from the cnx CHN variable
   'w' - 'z' = value nibbles ('w' highest nibble, 'z' lowest nibble),
         always lower case
	The string always contains an even number of nibbles.
*/

/* EOF */
