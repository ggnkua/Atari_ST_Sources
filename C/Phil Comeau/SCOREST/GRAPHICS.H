/* Graphics:	Definitions used by clients of the Graphics library.
 * phil comeau 06-nov-88
 * last edited 16-sep-89 0016
 *
 * Copyright 1990 Antic Publishing Inc.
 *
 */

#ifndef GRAPHICS_H
#define GRAPHICS_H

/* Constants. */

#define FILLWHITE 0			/* fill poly with white */
#define FILLSOLID 8			/* fill poly with solid foreground
					 * color.
					 */
#define MAXFILL FILLSOLID		/* largest fill pattern code. Codes
					 * between FILLWHITE and FILLSOLID
					 * are increasing scales of gray.
					 */
#define MAXPOLY 128			/* max # lines in a polygon */

#define TEXTTHICKBIT 0			/* text effect bits */
#define TEXTLIGHTBIT 1
#define TEXTITALICBIT 2
#define TEXTULBIT 3
#define TEXTOUTLINEBIT 4
#define TEXTSHADOWBIT 5
#define TEXTTHICKMASK MASK(TEXTTHICKBIT) /* text effect bitmasks */
#define TEXTLIGHTMASK MASK(TEXTLIGHTBIT)
#define TEXTITALICMASK MASK(TEXTITALICBIT)
#define TEXTULMASK MASK(TEXTULBIT)
#define TEXTOUTLINEMASK MASK(TEXTOUTLINEBIT)
#define TEXTSHADOWMASK MASK(TEXTSHADOWBIT)

/* Line type patterns */
#define DOTTEDLNPAT 0xaaaa
#define SOLIDLNPAT 0xffff
#define DASHEDLNPAT 0xe0e0
#define UDLNTYP 7			/* user-defined line type. */

/* Graphic text special effects. */
#define THICKTEXT 0x1			/* thickened (bold) */
#define LIGHTTEXT 0x2			/* light intensity */
#define ITALICTEXT 0x4			/* skewed */
#define UNDRLNTEXT 0x8			/* underlined */
#define OUTLNTEXT 0x10			/* outlined */
#define SHADOWTEXT 0x20			/* shadowed */
#define SETTXTFX 0x8000			/* mask used to set effects */

/* Mouse button bits and masks. */
#define LEFTBUTTONBIT 0
#define MIDBUTTONBIT 1
#define RIGHTBUTTONBIT MIDBUTTONBIT	/* ST has only 2 buttons */
#define LEFTBUTTON (1 << LEFTBUTTONBIT)	/* Button bit masks */
#define MIDBUTTON (1 << MIDBUTTONBIT)
#define RIGHTBUTTON (1 << RIGHTBUTTONBIT)
#define BUTTONUP 0x0
#define BUTTONDOWN 0x1

/* Keyboard modifier bits and masks. */
#define RIGHTSHIFTBIT 0
#define LEFTSHIFTBIT 1
#define CTRLKEYBIT 2
#define ALTKEYBIT 3
#define RIGHTSHIFT (1 << RIGHTSHIFTBIT)
#define LEFTSHIFT (1 << LEFTSHIFTBIT)
#define CTRLKEY (1 << CTRLKEYBIT)
#define ALTKEY (1 << ALTKEYBIT)

/* Miscellaneous definitions. */
#define RADPERDEG 0.0174532925		/* radians per degree */
#define DEGPERRAD 57.2957795131		/* degrees per radian */

/* Types. */

/* COORD:	Coordinates. */
typedef int COORDD;			/* Device coordinates. */
typedef double COORDW;			/* World coordinates */

/* EXTENT:	Extents, or distances */
typedef int EXTENTD;			/* Device extents */
typedef double EXTENTW;			/* World extents */

/* POINT:	2D Points. */
typedef struct {			/* Device coordinates */
	COORDD x, y;
} POINT2D;

typedef struct {			/* World coordinates */
	COORDW x, y;
} POINT2W;

/* LINE:	2D Lines. */
typedef struct {			/* Device coordinates */
	COORDD x1, y1;
	COORDD x2, y2;
} LINE2D;

typedef struct {			/* World coordinates */
	COORDW x1, y1;
	COORDW x2, y2;
} LINE2W;

/* RECT:	2D Rectangles. */
typedef struct {			/* Device coordinates */
	COORDD x, y;
	EXTENTD w, h;
} RECT2D;

typedef struct {			/* World coordinates */
	COORDW x, y;
	EXTENTW w, h;
} RECT2W;

/* CIRCLE:	2D Circles. */
typedef struct {			/* Device coordinates */
	COORDD x, y;			/* center */
	EXTENTD r;			/* radius */
} CIRCLE2D;

typedef struct {			/* World coordinates */
	COORDW x, y;			/* center */
	EXTENTW r;			/* radius */
} CIRCLE2W;

/* ELLIPSE:	2D Ellipses. */
typedef struct {			/* Device coordinates */
	COORDD x, y;			/* center */
	EXTENTD hAxis, vAxis		/* horizontal & vertical axes */
} ELLIPSE2D;

typedef struct {			/* World coordinates */
	COORDW x, y;			/* center */
	EXTENTW hAxis, vAxis		/* horizontal & vertical axes */
} ELLIPSE2W;

/* ARC:	2D Circular arcs. */
typedef struct {			/* Device coordinates */
	COORDD x, y;			/* center */
	EXTENTD r;			/* radius */
	int startAngle, endAngle;	/* clockwise angles from x axis */
} ARC2D;

typedef struct {			/* World coordinates */
	COORDW x, y;			/* center */
	EXTENTD r;			/* radius */
	int startAngle, endAngle;	/* clockwise angles from x axis */
} ARC2W;

/* ELLARC:	2D Elliptical Arcs. */
typedef struct {
	COORDD x, y;			/* center */
	EXTENTD hAxis, vAxis;		/* axis lengths */
	int startAngle, endAngle;	/* clockwise angles from x axis */
} ELLARC2D;

typedef struct {
	COORDW x, y;			/* center */
	EXTENTW hAxis, vAxis;		/* axis lengths */
	int startAngle, endAngle;	/* clockwise angles from x axis */
} ELLARC2W;

/* BUTTONMASK:	Bitmask used to identify mouse buttons or their states. */
typedef BITMASK16 BUTTONMASK;

/* KBMASK:	Bitmask used to identify keyboard modifier keys. */
typedef BITMASK16 KBMASK;

/* DRAWMODE:	Drawing modes. */
typedef enum {
	ReplaceMode, TransparentMode, XORMode
} DRAWMODE;

/* COLOR:	Colors from the default color palette. */
typedef enum {
	White, Black, Red, Green, Blue, Cyan, Yellow, Magenta,
	LWhite, LBlack, LRed, LGreen, LBlue, LCyan, LYellow, LMagenta
} COLOR;

/* POINTTYPE:	Types of points that can be drawn. */
typedef enum {
	Dot = 1, Plus = 2, Star = 3, Square = 4, Cross = 5, Diamond = 6
} POINTTYPE;

/* LINEEND:	Line end styles. */
typedef enum {
	Square, Arrow, Round
} LINEEND;

/* LINEPAT:	Line patterns. */
typedef enum {
	Solid, LongDashed, Dotted, DashDotted, Dashed
} LINEPAT;

/* GC:	Defines an individual Graphics Context. */
typedef struct {
	int vdiId;			/* vdi handle */
	POINT2D org;			/* GC's origin */
	RECT2D clipRect;		/* clipping rectangle */
	int mode;			/* drawing mode (vdi) */
	int width;			/* line width */
	COLOR color;			/* drawing color */
	int txtSz;			/* text size in points */
	BITMASK16 txtFx;		/* text effects mask */
} GC;

/* Macros. */

/* SETPOINT:	Set the coordinates in a point of any type. */
#define SETPOINT(pt, xx, yy) (pt)->x = (xx); (pt)->y = (yy)

/* SETLINE:	Set the coordinates in a line of any type. */
#define SETLINE(line, xx1, yy1, xx2, yy2) (line)->x1 = (xx1); \
    (line)->y1 = (yy1); (line)->x2 = (xx2); (line)->y2 = (yy2)

/* SETRECT:	Set the coordinates in a rectangle of any type. */
#define SETRECT(r, xx, yy, ww, hh) (r)->x = (xx); (r)->y = (yy); \
    (r)->w = (ww); (r)->h = (hh)

/* SETMFDB:	Set up a Memory Form Definition Block. */
#define SETMFDB(mfdb, p, rect, nPlanes) (mfdb)->fd_addr = (long)(p); \
    (mfdb)->fd_w = (rect)->w; (mfdb)->fd_h = (rect)->h; \
    (mfdb)->fd_wdwidth = (rect)->w / 16; (mfdb)->fd_stand = 0; \
    (mfdb)->fd_nplanes = (nPlanes)

/* POINTTOPXY2D:	Convert a POINT2D structure to a pxy array. */
#define POINTTOPXY2D(point, pxy) { \
	register int *p = (pxy); \
	*p++ = (point)->x; \
	*p++ = (point)->y; \
}

/* POINTTOPXYOFF2D:	Convert a POINT2D structure to a pxy array, with
 *			offset.
 */
#define POINTTOPXYOFF2D(point, xOff, yOff, pxy) { \
	register int *p = (pxy); \
	*p++ = (point)->x + (xOff); \
	*p++ = (point)->y + (yOff); \
}

/* LINETOPXY2D:	Convert a LINE2D structure to a pxy array. */
#define LINETOPXY2D(line, pxy) { \
	register int *p = (pxy); \
	*p++ = (line)->x1; \
	*p++ = (line)->y1; \
	*p++ = (line)->x2; \
	*p = (line)->y2; \
}

/* LINETOPXYOFF2D:	Convert a LINE2D structure to a pxy array,
 *			with offset.
 */
#define LINETOPXYOFF2D(line, xOff, yOff, pxy) { \
	register int *p = (pxy); \
	*p++ = (line)->x1 + (xOff); \
	*p++ = (line)->y1 + (yOff); \
	*p++ = (line)->x2 + (xOff); \
	*p = (line)->y2 + (yOff); \
}

/* RECTTOPXY2D:	Convert a RECT2D structure to a pxy array. */
#define RECTTOPXY2D(rect, pxy) { \
	register int *p = (pxy); \
	*p++ = (rect)->x; \
	*p++ = (rect)->y; \
	*p++ = (rect)->x + (rect)->w - 1; \
	*p = (rect)->y + (rect)->h - 1; \
}

/* RECTTOPXYOFF2D:	Convert a RECT2D structure to a pxy array, with
 *			offset.
 */
#define RECTTOPXYOFF2D(rect, xOff, yOff, pxy) { \
	register int *p = (pxy); \
	*p++ = (rect)->x + (xOff); \
	*p++ = (rect)->y + (yOff); \
	*p++ = (rect)->x + (xOff) + (rect)->w - 1; \
	*p = (rect)->y + (yOff) + (rect)->h - 1; \
}

/* MOVEPOINT:	Adjust a point position by an offset (any system). */
#define MOVEPOINT(pt, xOff, yOff) (pt)->x += (xOff); (pt)->y += (yOff)

/* MOVELINE:	Adjust a line position by an offset (any system). */
#define MOVELINE(line, xOff, yOff) (line)->x1 += (xOff); \
    (line)->y1 += (yOff); (line)->x2 += (xOff); (line)->y2 += (yOff)

/* MOVERECT:	Adjust a rectangle position by an offset (any system). */
#define MOVERECT(rect, xOff, yOff) (rect)->x += (xOff); (rect)->y += (yOff)

/* COPYPOINT:	Copy a point position (any system) */
#define COPYPOINT(pSrc, pDst) (pDst)->x = (pSrc)->x; (pDst)->y = (pSrc)->y

/* COPYLINE:	Copy a line (any system) */
#define COPYLINE(pSrc, pDst) (pDst)->x1 = (pSrc)->x1; \
    (pDst)->y1 = (pSrc)->y1; (pDst)->x2 = (pSrc)->x2; \
    (pDst)->y2 = (pSrc)->y2

/* COPYRECT:	Copy a rectangle (any system) */
#define COPYRECT(pSrc, pDst) (pDst)->x = (pSrc)->x; (pDst)->y = (pSrc)->y; \
    (pDst)->w = (pSrc)->w; (pDst)->h = (pSrc)->h

/* RECTEMPTY:	Return TRUE if a rectangle is empty (any system) */
#define RECTEMPTY(rect) ((rect)->w <= 0 || (rect)->h <= 0)

/* POINTEQUAL:	Return TRUE if 2 points are equal (any system) */
#define POINTEQUAL(p1, p2) ((p1)->x == (p2)->x && (p1)->y == (p2)->y)

/* LINEEQUAL:	Return TRUE if 2 lines are equal (any system) */
#define LINEEQUAL(l1, l2) ((l1)->x1 == (l2)->x1 && (l1)->y1 == (l2)->y1 && \
    (l1)->x2 == (l2)->x2 && (l1)->y2 == (l2)->y2)

/* RECTEQUAL:	Return TRUE if 2 rectangles are equal (any system) */
#define RECTEQUAL(r1, r2) ((r1)->x == (r2)->x && (r1)->y == (r2)->y && \
    (r1)->w == (r2)->w && (r1)->h == (r2)->h)

/* POINTINRECT:	Return TRUE if a point lies within a rectangle (any system)
 */
#define POINTINRECT(pt, rect) ((pt)->x >= (rect)->x && \
    (pt)->x < (rect)->x + (rect)->w && (pt)->y >= (rect)->y && \
    (pt)->y < (rect)->y + (rect)->h)

/* POINT2NTO2D:	Convert a 2D point in NDC to DC. */
#define POINT2NTO2D(pt2n, pt2d) { \
    extern RECT2D ScreenRect; \
    (pt2d)->x = (COORDD)((pt2n)->x * (ScreenRect.w - 1)); \
    (pt2d)->y = (COORDD)((pt2n)->y * (ScreenRect.h - 1)); \
}

/* POINT2DTO2N:	Convert a 2D point in DC to NDC. */
#define POINT2DTO2N(pt2d, pt2n) { \
    extern RECT2D ScreenRect; \
    (pt2n)->x = (COORDN)(pt2d)->x / (ScreenRect.w - 1)); \
    (pt2n)->y = (COORDN)(pt2d)->y / (ScreenRect.h - 1)); \
}

/* HIDEMOUSE, SHOWMOUSE:	Make the mouse cursor invisible or visible,
 *				respectively.
 */
#define HIDEMOUSE() graf_mouse(256, NULL)
#define SHOWMOUSE() graf_mouse(257, NULL)

/* GraphGetClip:	Return a pointer to the clipping rectangle in force
 *			for a GC.
 */
#define GraphGetClip(pGC) (&(pGC)->clipRect)

/* GraphGetColor:	Return a GC's current drawing color. */
#define GraphGetColor(pGC) ((pGC)->color)

/* GraphGetWidth:	Return a GC's current line width. */
#define GraphGetWidth(pGC) ((pGC)->width)

/* GraphGetOrg:	Return a pointer to a GC's origin point. */
#define GraphGetOrg(pGC) (&(pGC)->org)

/* GraphGetMode:	Return a GC's current drawing mode. */
#define GraphGetMode(pGC) ((pGC)->mode)

/* External variable definitions. Note that GraphInit or GraphCreate must
 * be called before these are used.
 */
extern EXTENTD SysFontCellWd, SysFontCellHt, SysFontBoxWd, SysFontBoxHt;
extern RECT2D ScreenRect;
extern int NPlanes;
extern EXTENTD HPixPerInch, VPixPerInch;

/* Function Definitions. */
extern void CloseVWk(), GraphClearRect(), GraphCopyRaster(), GraphDestroy(), GraphicsDrawCircle(),
    GraphDrawEllipse(), GraphDrawFilledCircle(), GraphDrawFilledEllipse(),
    GraphDrawFilledPoly(), GraphDrawFilledRect(), GraphDrawLine(),
    GraphDrawPoint(), GraphDrawPoly(), GraphDrawRaster(), GraphDrawRect(),
    GraphDrawSpline(), GraphDrawTextString(), GraphInit(),
    GraphInvertRaster(), GraphSetClip(), GraphSetColor(), GraphSetMode(),
    GraphSetOrg(), GraphSetTextFx(), GraphSetWidth(), GraphTerm();
extern int OpenVWk();
extern BOOLEAN GraphCreate();
extern EXTENTD GraphGetDist();

#endif GRAPHICS_H
