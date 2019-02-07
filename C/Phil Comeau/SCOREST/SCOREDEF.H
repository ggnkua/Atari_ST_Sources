/* scoredef.h: Definitions used by ScoreST music layout program
 * phil comeau 19-jan-88
 * last edited 12-jul-89 0003
 *
 * Copyright 1990 Antic Publishing Inc.
 */

/* Screen coordinate definitions */
#define SCSMAXX 640
#define SCSMAXY 400

/* World Coordinate System definitions */
#define WCSPGWD 8			/* page width in inches */
#define WCSPGHT 11			/* page height in inches */
#define WCSHPPI 80			/* horizontal points per inch
					 * (epson printer)
					 */
#define WCSVPPI 72			/* vertical points per inch */
#define WCSMAXX ((WCSPGWD * WCSHPPI) + (WCSHPPI / 2))
					/* largest x coordinate */
#define WCSMAXY (WCSPGHT * WCSVPPI)	/* largest y coordinate */

/* Mouse definitions */
#define MSEXIT 1			/* generate mouse event when mouse
					 * leaves rectangle
					 */
#define MSENTER 0			/* generate mouse event when mouse
					 * enters rectangle
					 */

/* Musical definitions */
#define LINESINSTAFF 5			/* Number of lines making up a
					 * staff.
					 */

/* Graphical definitions */

#define STAFFSPHT 6			/* Distance (in pixels) between
					 * individual lines in a staff.
					 */
#define BEAMWD 3			/* Width of a beam line. */
#define LDGRLNWD 13			/* Width of a ledgerline. */
#define CRVSZ 25			/* # lines in curve template */
#define CRVWD 361			/* width of curve template */
#define CRVHT 46			/* height of curve template */
#define MINCRVWD 20			/* smallest allowed curve */
#define MAXCRVANGLE 0.785398163		/* largest curve inclination (45
					 * degrees in radians)
					 */
#define CRVYSCALE 2			/* rate curve height increases
					 * relative to width
					 */
#define NTRILLLINES 4			/* # lines in trill form */
#define BRACESZ 13			/* # lines in brace template */
#define BRACEWD 9			/* width of brace template */
#define BRACEHT 25			/* height of brace template */
#define BRACEXSCALE 0.5			/* rate brace witdth increases
					 * relative to height.
					 */

/* Directions. */
#define UP 0
#define DOWN 1

/* Page definitions */
#define GRIDLNPAT 0x8888		/* line pattern used for grid lines
					 */

/* Printer quality flags. */
#define DRAFT 0
#define FINAL 1

#define CANCEL 0			/* continuation flags. */
#define DONE 1
#define RETRY 2

/* Key scan codes. */
#define DELKEY 0x537f			/* delete key */
#define BSKEY 0x0e08			/* backspace key */
#define LARROWKEY 0x4b00		/* left arrow */
#define RARROWKEY 0x4d00		/* right arrow */
#define UARROWKEY 0x4800		/* up arrow */
#define DARROWKEY 0x5000		/* down arrow */
#define S_LARROWKEY 0x4b34		/* shift left arrow */
#define S_RARROWKEY 0x4d36		/* shift right arrow */
#define S_UARROWKEY 0x4838		/* shift up arrow */
#define S_DARROWKEY 0x5032		/* shift down arrow */

/* Misc. Definitions */
#define FILENAMESZ 128
#define GRIDTEXTSZ 10			/* Size (in points) of inch
					 * numbers appearing in grid.
					 */
#define RSRCFILE "scorest.rsc"		/* Score resource filename */
#define CFGFILE "scorest.cfg"		/* Score configuration filename */
#define MAXSTR 256
#define MAGIC 0xbadbabe			/* magic number identifying a score
					 * file.
					 */
#define SCALE 100			/* scaling factor */
#define INCREMENT 1
#define NOCHANGE 0
#define DECREMENT (-1)

