/*
 *	mgif.h - defines and typedefs for mgif (mgif.c and readgif.c)
 */

/*
 *	errors for ReadGIF
 */
#define EGIFOK		0
#define EGIFMAGIC	1	/* bad magic */
#define EGIFSDESC	2	/* bad screen descriptor */
#define EGIFEOF		3	/* premature EOF */
#define EGIFIDBAD	4	/* bad image descriptor */
#define EGIFBIG		5	/* image too big */
#define EGIFRAST	6	/* error reading raster */
#define EGIFFILE	7	/* file error (open, etc) */

/*
 *	output mode for ReadGIF
 */
#define SILENT		0
#define INQUIRE		1
#define VERBOSE		2
#define NORMAL		4

/*
 *	array dimensions, etc
 */

#define HASHSIZ		4096		/* size of hash tables */
#define OUTSIZ		1025		/* size of output table */
#define HISTSIZ		256		/* size of histogram table */
#define MAPSIZ		256		/* size of color map table */
#define MAXPIXLINE	650		/* max num pixels in display row, */
					/* need at least 642 for array dims */
#define MAX_X		640		/* number of pixels on screen, horiz*/
#define MAX_Y		400		/* number of pixels on screen, vert*/
#define LEFT		0		/* dither directions */
#define RIGHT		1

/*
 *	built-in convolution kernels
 */
#define USER_KERN	0
#define LP1_KERN	1
#define LP2_KERN	2
#define LP3_KERN	3
#define HP1_KERN	4
#define HP2_KERN	5
#define HP3_KERN	6
#define SE1_KERN	7
#define SE2_KERN	8
#define SE3_KERN	9
#define LE1_KERN	10
#define LE2_KERN	11
#define LE3_KERN	12
#define LE4_KERN	13
#define GE1_KERN	14
#define GE2_KERN	15
#define GE3_KERN	16
#define GE4_KERN	17
#define GE5_KERN	18
#define GE6_KERN	19
#define GE7_KERN	20
#define GE8_KERN	21


/*
 *	raw (long) key values from Bconin
 */		/* NEW, incorrect shift codes fixed */
#define RARROW		0x004d0000L	/* > */
/* #define S_RARRAW	0x004d0036L	* shift-> */
#define UARROW		0x00480000L	/* ^ */
/* #define S_UARRAW	0x00480038L	* shift-^ */
#define DARROW		0x00500000L	/* v */
/* #define S_DARRAW	0x00500032L	* shift-v */
#define LARROW		0x004b0000L	/* < */
/* #define S_LARRAW	0x004b0034L	* shift-< */

#define INSERT		0x00520000L	/* insert */
/* #define S_INSERT	0x00520030L	* shift-Insert */
#define CLRHOME		0x00470000L	/* ClrHome */
/* #define S_CLRHOME	0x00470037L	* shift-ClrHome */
#define HELP		0x00620000L	/* help */
#define UNDO		0x00610000L	/* undo */

#define H_COORD		0
#define V_COORD		1
#define VH_COORD	2

/*
 *  NEW, extra defines
 */
#define linea0		_linea0
#define linea3		_linea3

/*
 *	types and structures
 */
typedef unsigned char uchar_t;
typedef unsigned int  uint_t;
typedef unsigned long ulong_t;

typedef struct			/* screen descriptor */
{
	int	s_dx,		/* image size */
		s_dy;
	int	s_colors, 	/* # colors */
		s_bits,		/* bits/pixel */
		s_cr;		/* color resolution */
	char	s_gcm,		/* global color map flag */
		s_bgnd;		/* background color */

}		screen_t;

typedef struct			/* image descriptor */
{
	int	i_x,		/* position rel to upper left */
		i_y,
		i_dx,		/* size */
		i_dy,
		i_colors,	/* num colors in image */
		i_bits;		/* bits/pixel */
	char	i_gcm,		/* use global color map */
		i_intlace;	/* 0=sequential or !0=interlaced */

}		image_t;



/*---------------------------- end of mgif.h ------------------------------*/

