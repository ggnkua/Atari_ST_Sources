/* graph: Graphics library for Score
 * phil comeau 06-jan-88
 * last edited 10-oct-89 0007
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
*/

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <mylib.h>
#include <graphics.h>
#include "graph.h"

/* Constants: */
#define NBITPLANES 1			/* # bit planes in a monochrome
					 * system.
					 */

/* Global variables: */

static BOOLEAN MouseHidden = FALSE;
static RECT2D CurClipRct = {0, 0, 0, 0}; /* Current clipping rectangle. */
static MSFORM CurMsForm = {-1};		/* Current mouse form */
static MSFORM SaveMsForm;		/* Place to save the mouse form. */

extern FILE *Debug;

/* setLnStyle: Set the line pattern, width and end style. */
setLnStyle(lnStyle)
register LINESTYLE *lnStyle;
{
	setLnTyp(lnStyle->lnPat);
	setLnWd(lnStyle->lnW);
	setLnEnd(lnStyle->lnEnd);
}

/* setLnTyp: Set the polyline line type to the specified pattern. */
setLnTyp(lnPat)
unsigned int lnPat;
{
	extern int GHandle;
	static unsigned int curLnPat = SOLIDLNPAT;

	if (lnPat != curLnPat) {
		vsl_udsty(GHandle, lnPat);
		vsl_type(GHandle, UDLNTYP);
		curLnPat = lnPat;
	}
}

/* setLnWd: Set the polyline line width to the specified value. */
setLnWd(lnWd)
int lnWd;
{
	extern int GHandle;
	static int curLnWd = 1;

	if (lnWd != curLnWd) {
		vsl_width(GHandle, lnWd);
		curLnWd = lnWd;
	}
}

/* setLnEnd: Set the polyline end style. */
setLnEnd(lnEnd)
int lnEnd;
{
	extern int GHandle;
	static int curLnEnd = SQUAREEND;

	if (lnEnd != curLnEnd) {
		vsl_ends(GHandle, SQUAREEND, lnEnd);
		curLnEnd = lnEnd;
	}
}

/* setTxtStyle: Set text effects and size */
setTxtStyle(txtStyle)
register TXTSTYLE *txtStyle;
{
	setTxtFx(txtStyle->txtAttr);
	setTxtSz(txtStyle->txtSz);
}

/* setTxtFx: Set graphic text special effects */
setTxtFx(fx)
register int fx;
{
	extern int GHandle;
	static int curTxtFx = 0;

	if (fx != curTxtFx) {

		/* Set the new effects. */
		vst_effects(GHandle, fx | SETTXTFX);
		curTxtFx = fx;
	}
}

/* setTxtSz: Set the text size in points. */
setTxtSz(sz)
register int sz;
{
	int junk;
	extern int GHandle;
	static int curSz = 0;

	if (sz != curSz) {

		/* Set the new text size in points. */
		vst_point(GHandle, sz, &junk, &junk, &junk, &junk);
		curSz = sz;
	}
}

/* hideMouse: hide the mouse from view. */
hideMouse()
{
	if (!MouseHidden) {
		HIDEMOUSE();
		MouseHidden = TRUE;
	}
}

/* showMouse: make the mouse visible. */
showMouse()
{
	if (MouseHidden) {
		SHOWMOUSE();
		MouseHidden = FALSE;
	}
}

/* setClipRct: Set the clipping rectangle. */
setClipRct(clipRct)
register RECT2D *clipRct;
{
	int clipXY[4];
	extern int GHandle;

	if (!RECTEQUAL(clipRct, &CurClipRct)) {

		/* Set the new clipping rectangle. */
		RECTTOPXY2D(clipRct, clipXY);
		vs_clip(GHandle, TRUE, clipXY);
		bcopy(clipRct, &CurClipRct, sizeof (RECT2D));
	}
}

/* getClipRct: Get the current clipping rectangle. */
getClipRct(clipRct)
register RECT2D *clipRct;
{
	COPYRECT(&CurClipRct, clipRct);
}

/* drwLine: Draw a line */
drwLine(line)
register LINE2D *line;
{
	int lineXY[4];
	register int *pLine;
	extern int GHandle;

	pLine = lineXY;
	*pLine++ = line->x1;
	*pLine++ = MAX(line->y1, 0);
	*pLine++ = line->x2;
	*pLine = MAX(line->y2, 0);
	v_pline(GHandle, 2, lineXY);
}

/* clrRect: Fill a rectangle with white */
clrRect(rect)
register RECT2D *rect;
{
	int barXY[4];
	extern int GHandle;

	RECTTOPXY2D(rect, barXY);
	vsf_color(GHandle, WHITE);
	v_bar(GHandle, barXY);
	vsf_color(GHandle, BLACK);
}

/* setMsForm: Change the mouse form */
setMsForm(msForm)
register MSFORM *msForm;
{
	/* The bcmp in the Laser C library returns 0 when the blocks being
	 * compared are different. I think this is a bug.
	 */
	if (bcmp(msForm, &CurMsForm, sizeof(MSFORM)) != 0) {

		/* Set the new mouse form. */
		graf_mouse(msForm->msTyp, &msForm->msFormDef);
		COPY(msForm, &CurMsForm, sizeof(MSFORM));
	}
}

/* svMsForm: Save the current mouse form for later restoration. */
svMsForm()
{
	bcopy(&CurMsForm, &SaveMsForm, sizeof(MSFORM));
}

/* rstMsForm: Restore a previously-saved mouse form. */
rstMsForm()
{
	bcopy(&SaveMsForm, &CurMsForm, sizeof(MSFORM));
	graf_mouse(CurMsForm.msTyp, &CurMsForm.msFormDef);
}

/* setWrtMode: Set the graphics writing mode. */
setWrtMode(wrtMode)
register int wrtMode;
{
	static int curWrtMode = 0;
	extern int GHandle;

	if (wrtMode != curWrtMode) {

		/* Set the new writing mode. */
		vswr_mode(GHandle, wrtMode);
		curWrtMode = wrtMode;
	}
}

/* drwRst: Draw a raster image. */
drwRst(srcPtr, destRct, wrtMode)
register char *srcPtr;
register RECT2D *destRct;
register int wrtMode;
{
	RECT2D srcRct;

	/* The raster image is assume to start at the upper left corner of
	 * the memory block.
	 */
	SETRECT(&srcRct, 0, 0, destRct->w, destRct->h);
	rstCopy(wrtMode, srcPtr, &srcRct, NULL, destRct);
}

/* rstCopy: Copy a raster image from one place to another. */
rstCopy(wrtMode, srcPtr, srcRct, destPtr, destRct)
int wrtMode;
register char *srcPtr, *destPtr;
register RECT2D *srcRct, *destRct;
{
	MFDB srcFdb, destFdb;
	int pxy[8];
	extern int GHandle;

	SETMFDB(&srcFdb, srcPtr, srcRct, NBITPLANES);
	SETMFDB(&destFdb, destPtr, destRct, NBITPLANES);
	RECTTOPXY2D(srcRct, &pxy[0]);
	RECTTOPXY2D(destRct, &pxy[4]);
	vro_cpyfm(GHandle, wrtMode, pxy, &srcFdb, &destFdb);
}

/* drwRct: Draw a rectangle. */
drwRct(rct)
register RECT2D *rct;
{
	int pxy[10];
	register int *pBox;
	extern int GHandle;

	pBox = pxy;
	*pBox++ = rct->x;
	*pBox++ = rct->y;
	*pBox++ = rct->x + rct->w - 1;
	*pBox++ = rct->y;
	*pBox++ = rct->x + rct->w - 1;
	*pBox++ = rct->y + rct->h - 1;
	*pBox++ = rct->x;
	*pBox++ = rct->y + rct->h - 1;
	*pBox++ = rct->x;
	*pBox = rct->y + 1;	/* needed so lines don't overlap in XOR */

	v_pline(GHandle, 5, pxy);
}

/* rctInRct: Return TRUE if one rectangle (rct1) is completely within
 * another (rct2).
 */
BOOLEAN rctInRct(rct1, rct2)
register RECT2D *rct1, *rct2;
{
	return ((rct1->x >= rct2->x) &&
	    (rct1->x < (rct2->x + rct2->w)) &&
	    ((rct1->x + rct1->w) <= (rct2->x + rct2->w)) &&
	    (rct1->y >= rct2->y) &&
	    (rct1->y < (rct2->y + rct2->h)) &&
	    ((rct1->y + rct1->h) <= (rct2->y + rct2->h)));
}
