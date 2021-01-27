/********************************************************
 * RCUTIL.C various utilities on rectangles             *
 ********************************************************/

#include "gemf.h"

/**************************************************************************
 * RCADJUST.C - Adjust a GRECT or VRECT rectangle to a new size.
 *************************************************************************/

static void rc_adjust(VRECT *prect,int xadjust,int yadjust,int is_grect)
{
	prect->v_x1 -= xadjust;
	prect->v_y1 -= yadjust;

	if (is_grect)
		xadjust *= 2, yadjust *= 2;

	prect->v_x2 += xadjust;
	prect->v_y2 += yadjust;

	if (prect->v_x1 < 0)
		prect->v_x1 = 0;

	if (prect->v_y1 < 0)
		prect->v_y1 = 0;

	if (prect->v_x2 <= 0)
		prect->v_x2 = 1;

	if (prect->v_y2 <= 0)
		prect->v_y2 = 1;
}

VRECT *rc_vadjust(VRECT *prect, int xadjust, int yadjust)
{
	rc_adjust(prect, xadjust, yadjust, 0);
	return prect;
}

GRECT *rc_gadjust(GRECT *prect, int xadjust, int yadjust)
{
	rc_adjust((VRECT *)prect, xadjust, yadjust, 1);
	return prect;
}

/**************************************************************************
 * RCCONFIN.C - Force destrect to be within boundrect.
 *              If destrect is bigger than boundrect, precedence is given
 *              to the upper and left edges (ie, dest will be aligned
 *              with the boundry on the topleft edge).
 *************************************************************************/

GRECT *rc_confine(GRECT *pbound, GRECT *pdest)
{
	int   diff;
	VRECT bound;
	VRECT dest;

	rc_gtov(pbound, &bound);
	rc_gtov(pdest,  &dest);

	if (0 < (diff = dest.v_x2 - bound.v_x2))
		pdest->g_x -= diff;

	if (0 < (diff = dest.v_y2 - bound.v_y2))
		pdest->g_y -= diff;

	if (dest.v_x1 < bound.v_x1)
		pdest->g_x = bound.v_x1;

	if (dest.v_y1 < bound.v_y1)
		pdest->g_y = bound.v_y1;

	return pdest;
}

/**************************************************************************
 * RCCOPY.C - Copy a rectangle .
 *************************************************************************/

void *rc_copy(void *psrce, void *pdest)
{
	*(GRECT *)pdest = *(GRECT *)psrce;
	return pdest;
}

/**************************************************************************
 * RCEQUAL.C - Return TRUE/FALSE indicating rectangles are EQUAL/NOTEQUAL.
 *************************************************************************/

int rc_equal(long *p1, long *p2)
{
	if (*p1 == *p2)
		if (*(p1+1) == *(p2+1))
			return 1;
	return 0;
}

/**************************************************************************
 * RCGTOV.C - Convert GRECT to VRECT.
 *************************************************************************/

VRECT *rc_gtov(GRECT *pgrect, VRECT *pvrect)
{
	pvrect->v_x1 = pgrect->g_x;
	pvrect->v_y1 = pgrect->g_y;
	pvrect->v_x2 = pgrect->g_x + pgrect->g_w - 1;
	pvrect->v_y2 = pgrect->g_y + pgrect->g_h - 1;
	return pvrect;
}

/**************************************************************************
 * RCINTERS.C - Calc intersection of two GRECT rectangles.
 *              Returns TRUE if rectanlges have common area, FALSE if not.
 *************************************************************************/

int rc_intersect(GRECT *prect1, GRECT *prect2)
{
	int w1, w2;
	int lx, rx;
	int ty, by;

	/* calc right-side x as the lesser x of the two rectangles */

	w1 = prect1->g_x + prect2->g_w;
	w2 = prect2->g_x + prect2->g_w;
	rx  = (w1 < w2) ? w1 : w2;

	/*  calc bottom y as the lesser y of the two rectanlges */

	w1 = prect1->g_y + prect1->g_h;
	w2 = prect2->g_y + prect2->g_h;
	by  = (w1 < w2) ? w1 : w2;

	/* calc left-side x as the greater x of the two rectangles */

	w1 = prect1->g_x;
	w2 = prect2->g_x;
	lx = (w1 > w2) ? w1 : w2;

	/* calc top y as the greater y of the two rectangles */

	w1 = prect1->g_y;
	w2 = prect2->g_y;
	ty = (w1 > w2) ? w1 : w2;

	/* store the calculated rectangle (converting back to GRECT-type w/h) */

	prect2->g_x = lx;
	prect2->g_y = ty;
	prect2->g_w = rx - lx;
	prect2->g_h = by - ty;

/*
 * if the calculated width or height is zero or less, it indicates
 * that there is no overlap in at least one dimension, and thus no
 * overlap in the rectangles, so return FALSE.  if both values are
 * positive, there is a common intersecting area, so return TRUE.
 */

	if ( prect2->g_w <= 0 || prect2->g_h <= 0)
		return 0;
	else
		return 1;
}

/**************************************************************************
 * RCPTINRE.C - Return TRUE/FALSE indicating point is in/out of rectangle.
 *************************************************************************/

int rc_ptinrect(GRECT *prect, int x, int y)
{
	VRECT   r;

	rc_gtov(prect, &r);

	if (x < r.v_x1 || x > r.v_x2 || y < r.v_y1 || y > r.v_y2)
		return 0;
	else
		return 1;
}

/**************************************************************************
 * RCSCALE.C -  Scale sourcerect into destrect using specified percentage.
 *              The destination rectangle is g'teed to have width and
 *              height values of at least 1, since GEM and other lib
 *              library routines puke on no-area rectangles.
 *************************************************************************/

GRECT *rc_scale(GRECT *psource, GRECT *pdest, int percentage)
{
	int wdest;
	int hdest;
	int wsource;
	int hsource;

	if (percentage < 0)
		percentage = 100;

	wsource = psource->g_w;
	hsource = psource->g_h;

	wdest = (wsource * (long)percentage) / 100;
	hdest = (hsource * (long)percentage) / 100;

	pdest->g_x = psource->g_x + ((wsource - wdest) / 2);
	pdest->g_y = psource->g_y + ((hsource - hdest) / 2);
	pdest->g_w = wdest ? wdest : 1;
	pdest->g_h = hdest ? hdest : 1;

	return pdest;
}

/**************************************************************************
 * RCUNION.C - Compute union of 2 GRECT rectangles.
 *             Does not return anything, since by definition the two
 *             rectangles will have common area.
 *************************************************************************/

GRECT *rc_union(GRECT *prect1, GRECT *prect2)
{
	int w1, w2;
	int lx, rx;
	int ty, by;

	/* calc right-side x as the greater x of the two rectangles */

	w1 = prect1->g_x + prect2->g_w;
	w2 = prect2->g_x + prect2->g_w;
	rx  = (w1 > w2) ? w1 : w2;

	/*  calc bottom y as the greater y of the two rectanlges */

	w1 = prect1->g_y + prect1->g_h;
	w2 = prect2->g_y + prect2->g_h;
	by  = (w1 > w2) ? w1 : w2;

	/* calc left-side x as the lesser x of the two rectangles */

	w1 = prect1->g_x;
	w2 = prect2->g_x;
	lx = (w1 < w2) ? w1 : w2;

	/* calc top y as the lesser y of the two rectangles */

	w1 = prect1->g_y;
	w2 = prect2->g_y;
	ty = (w1 < w2) ? w1 : w2;

	/* store the calculated rectangle (converting back to GRECT-type w/h) */

	prect2->g_x = lx;
	prect2->g_y = ty;
	prect2->g_w = rx - lx;
	prect2->g_h = by - ty;

	return prect2;
}

/**************************************************************************
 * RCVTOG.C - Convert VRECT to GRECT.
 *************************************************************************/

GRECT *rc_vtog(VRECT *pvrect, GRECT *pgrect)
{
	pgrect->g_x = pvrect->v_x1;
	pgrect->g_y = pvrect->v_y1;
	pgrect->g_w = pvrect->v_x2 - pvrect->v_x1 + 1;
	pgrect->g_h = pvrect->v_y2 - pvrect->v_y1 + 1;
	return pgrect;
}
