/* vdiwork.h
 * workstation parameters for VDI calls
 * Copyright 1989, Atari Corp.
 *
 * 890808 kbad
 */


/* WS_INIT structure, a.k.a. work_in
 */
typedef struct _ws_init {
		short	device_id;
		short	linetype;
		short	linecolor;
		short	markertype;
		short	markercolor;
		short	textface;
		short	textcolor;
		short	fillinterior;
		short	fillstyle;
		short	fillcolor;
		short	ndc_rc;
} WS_INIT;

/* WORKSTATION structure, a.k.a work_out
 */
typedef struct _workstation {
		short	xres;			/* x resolution */
		short	yres;			/* y resolution */
		short	noscale;		/* scaling not possible (e.g. film) */
		short	wpixel;			/* pixel width in microns */
		short	hpixel;			/* pixel height in microns */
		short	cheights;		/* # of char heights (0 = continuous) */
		short	linetypes;		/* # of line types */
		short	linewidths;		/* # of line widths  (0 = continuous) */
		short	markertypes;	/* # of marker types */
		short	markersizes;	/* # of marker sizes (0 = continuous) */
		short	faces;			/* # of text faces */
		short	patterns;		/* # of fill patterns */
		short	hatches;		/* # of hatch styles */
		short	colors;			/* # of colors available (mono = 2) */
		short	ngdps;			/* # of Generalized Drawing Primitives */
		short	gdps[10];		/* list of 1st 10 supported GDPs:
								 * 1: bar		4: circle	7: ellpie
								 * 2: arc		5: ellipse	8: round rect
								 * 3: pieslice	6: ellarc	9: filled rrect
								 *		10: justified graphics text
								 */
		short	gdpattr[10];	/* attributes associated with each GDP:
								 * 0: polyline		2: text		4: none
								 * 1: polymarker	3: fill
								 */
								/* Capability flags: */
		short	color;			/* color */
		short	textrot;		/* text rotation */
		short	fillarea;		/* area fill */
		short	cellarray;		/* cell array operation */
		short	palette;		/* # of colors in palette
								 * 0: >32767, 2: mono, >2: # of colors
								 */
		short	locators;		/* # of locator devices available:
								 * 1: keyboard, 2: keyboard + other
								 */
		short	valuators;		/* # of valuator devices available:
								 * 1: keyboard, 2: other
								 */
		short	choicedevs;		/* # of choice devices available:
								 * 1: fn keys 2: other
								 */
		short	stringdevs;		/* # of string devices available:
								 * 1: keyboard
								 */
		short	wstype;			/* workstation type:
								 * 0: output only	3: reserved
								 * 1: input only	4: metafile
								 * 2: input/output
								 */
} WORKSTATION;

/* WS_EXTENTS structure, returned by open v/workstation calls in ptsout
 */
typedef struct _ws_extents {
		short	min_wchar;		/* Character extents in current coordinates */
		short	min_hchar;		/* Heights are baseline to top line, not	*/
		short	max_wchar;		/* character box size.
		short	max_hchar;
		short	min_wline;		/* minimum line width */
		short	zero5;
		short	max_wline;		/* maximum line width */
		short	zero7;
		short	min_wmarker;	/* marker extents */
		short	min_hmarker;
		short	max_wmarker;
		short	max_hmarker;
		short	reserved[3];
} WS_EXTENTS;

/* XINQUIRE structure, returned by vq_extnd()
 */
typedef struct _xinquire {
0		short	screentype;		/* Type of screen:
								 * 0: not a screen
								 * 1: seperate alpha/graphics and screens
								 * 2: seperate alpha/graphics, same screen
								 * 3: common alpha/graphics, separate RAM
								 * 4: common alpha/graphics, common RAM
								 */
1		short	bgcolors;		/* # of background colors */
2		short	text_effects;	/* bitmap of text effects supported */
3		short	scaling;		/* raster scaling possible */
4		short	planes;			/* video planes */
5		short	lut;			/* lookup table supported */
6		short	rops;			/* 16x16 pixel raster ops per second */
7		short	contourfill;	/* contour fill capability */
8		short	text_rot;		/* text rotation ability:
								 * 0: no, 1: 90 degree, 2: arbitrary
								 */
9		short	write_modes;	/* # of writing modes available */
10		short	input_modes;	/* input modes available
								 * 0: none, 1: request, 2: sample
								 */
11		short	text_align;		/* text alignment capability */
12		short	inking;			/* inking capability flag */
13		short	rubberbanding;	/* rubberbanding capability
								 * 0: none, 1: lines, 2: lines/rects
								 */
14		short	max_vertices;	/* for polyline, polymarker, filled area */
15		short	max_intin;
16		short	mouse_buttons;	/* # of mouse buttons */
17		short	wide_styles;	/* styles available for wide lines */
18		short	wide_modes;		/* # of writing modes for wide lines */
19..44		short	reserved[26];
} XINQUIRE;
		
