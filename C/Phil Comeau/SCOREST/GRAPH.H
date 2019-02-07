/* graph.h: Definitions relating to graphics
 * phil comeau 04-jan-88
 * last edited 13-oct-89 0005
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

/* Constants. */

#define MAXX 640			/* number of x pixels on monochrome
					 * screen.
					 */
#define MAXY 400			/* number of y pixels on monochrome
					 * screen.
					 */
#define MAXSLIDE 1000			/* maximum window slider value */
#define BITSPERWORD 16			/* number of bits in a word. */
#define SQUAREEND 0			/* line endstyles */
#define ARROWEND 1
#define ROUNDEND 2

/* Types. */

/* LINESTYLE: Structure defining characteristics of a line. */
typedef struct {
	int lnW;			/* line width */
	int lnEnd;			/* line endstyle */
	unsigned int lnPat;		/* line pattern bitmask */
} LINESTYLE;

/* TXTSTYLE: Structure defining text characteristics. */
typedef struct {
	int txtFont;			/* font id */
	int txtSz;			/* text size in points */
	int txtAttr;			/* text attributes bitmask */
} TXTSTYLE;

/* MSFORM: Structure defining a mouse form. */
typedef struct {
	int msTyp;			/* type of mouse form */
	struct {			/* mouse form definition, if form
					 * type is USER_DEF
					 */
		int x;			/* mouse hotspot offset from
					 * upper left corner
					 */
		int y;
		int rsvd;		/* reserved; set to 1 */
		int bgColor;		/* background color index */
		int fgColor;		/* foreground color index */
		int bgImg[16];		/* array of bits defining mouse
					 * background
					 */
		int fgImg[16];		/* array of bits defining mouse
					 * foreground
					 */
	} msFormDef;
} MSFORM;

/* Macros. */

/* WCSPTTOSCS:	Convert a point in WCS to SCS */
#define WCSPTTOSCS(wcsPt, scsPt) { \
	extern RECT2D WinWcsRct, WinScsRct; \
	(scsPt)->x = ((wcsPt)->x - WinWcsRct.x) + WinScsRct.x; \
	(scsPt)->y = ((wcsPt)->y - WinWcsRct.y) + WinScsRct.y; \
}

/* SCSPTTOWCS: 	Convert a point in SCS to WCS */
#define SCSPTTOWCS(scsPt, wcsPt) { \
	extern RECT2D WinWcsRct, WinScsRct; \
	(wcsPt)->x = ((scsPt)->x - WinScsRct.x) + WinWcsRct.x; \
	(wcsPt)->y = ((scsPt)->y - WinScsRct.y) + WinWcsRct.y; \
}

/* WCSLNTOSCS:	Convert a line in WCS to SCS. */
#define WCSLNTOSCS(wcsLn, scsLn) \
    WCSPTTOSCS((POINT2D *)&(wcsLn)->x1, (POINT2D *)&(scsLn)->x1); \
    WCSPTTOSCS((POINT2D *)&(wcsLn)->x2, (POINT2D *)&(scsLn)->x2)

/* SCSLNTOWCS:	Convert a line in SCS to WCS. */
#define SCSLNTOWCS(scsLn, wcsLn) \
    SCSPTTOWCS((POINT2D *)&(scsLn)->x1, (POINT2D *)&(wcsLn)->x1); \
    SCSPTTOWCS((POINT2D *)&(scsLn)->x2, (POINT2D *)&(wcsLn)->x2)

/* WCSRCTTOSCS:	Convert a rectangle in WCS to SCS. */
#define WCSRCTTOSCS(wcsRct, scsRct) COPYRECT(wcsRct, scsRct); \
    WCSPTTOSCS((POINT2D *)(wcsRct), (POINT2D *)(scsRct))

/* SCSRCTTOWCS:	Convert a rectangle in SCS to WCS. */
#define SCSRCTTOWCS(scsRct, wcsRct) COPYRECT(scsRct, wcsRct); \
    SCSPTTOWCS((POINT2D *)(scsRct), (POINT2D *)(wcsRct))
