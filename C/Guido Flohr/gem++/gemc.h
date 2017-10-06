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

	int CanvasWidth() const { return w; }
	int CanvasHeight() const { return h; }

	int CanvasX() const { return x; }
	int CanvasY() const { return y; }

	void ResizeCanvas(int width, int height);

protected:
	virtual int DrawAt(int x, int y, const GRect& area)=0;
	void SetXY(int nx, int ny) { x=nx; y=ny; }

private:
	virtual int RedrawClipped(int x, int y, const GRect& area);
	int x,y;
	int w,h;
};


#endif
