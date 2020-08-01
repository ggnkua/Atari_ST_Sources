/////////////////////////////////////////////////////////////////////////////
//
//  GEMcanvas
//
//  A GEMcanvas is a GEMscrollableobject scrolling over a virtual area.
//
//  This file is Copyright 1993 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#ifndef GEMc_h
#define GEMc_h

#include <gemscro.h>

class GEMcanvas : public GEMscrollableobject {
public:
	GEMcanvas(GEMform&, int RSCindex, int width, int height);
	GEMcanvas(GEMform&, int RSCindex); // Unlimited (int) size.

	virtual void Scroll(int pixels_right, int pixels_down);

	void ScrollTo(int x, int y);

	int CanvasWidth() { return w; }
	int CanvasHeight() { return h; }

	int CanvasX() { return x; }
	int CanvasY() { return y; }

protected:
	virtual void DrawAt(int x, int y, const GRect& area)=0;

private:
	virtual void RedrawClipped(int x, int y, const GRect& area);
	int x,y;
	int w,h;
};


#endif
