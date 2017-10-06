/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemc.h"
#include "grect.h"

static const int UNLIMITED=-1;

GEMcanvas::GEMcanvas(GEMform& form, int RSCindex, int width, int height) :
	GEMscrollableobject(form,RSCindex),
	x(0),y(0),
	w(width),h(height)
{
}

GEMcanvas::GEMcanvas(GEMform& form, int RSCindex) :
	GEMscrollableobject(form,RSCindex),
	x(0),y(0),
	w(UNLIMITED),h(UNLIMITED)
{
}

void GEMcanvas::Scroll(int pixels_right, int pixels_down)
{
	if (w!=UNLIMITED) {
		if (x+GEMuserobject::Width()+pixels_right > CanvasWidth()) {
			pixels_right = CanvasWidth()-x-GEMuserobject::Width();
		} else if (x+pixels_right < 0) {
			pixels_right=-x;
		}
	}

	if (h!=UNLIMITED) {
		if (y+GEMuserobject::Height()+pixels_down > CanvasHeight()) {
			pixels_down = CanvasHeight()-y-GEMuserobject::Height();
		} else if (y+pixels_down < 0) {
			pixels_down=-y;
		}
	}

	x+=pixels_right;
	y+=pixels_down;

	GEMscrollableobject::Scroll(pixels_right,pixels_down);
}

void GEMcanvas::ScrollTo(int nx, int ny)
{
	Scroll(nx-x,ny-y);
}

int GEMcanvas::RedrawClipped(int ox, int oy, const GRect& oarea)
{
	clip(oarea.g_x,oarea.g_y,oarea.g_x+oarea.g_w-1,oarea.g_y+oarea.g_h-1);
	GRect area(oarea.g_x-ox+x,oarea.g_y-oy+y,oarea.g_w,oarea.g_h);
	int result=DrawAt(ox-x,oy-y,area);
	clip_off();
	return result;
}

void GEMcanvas::ResizeCanvas(int width, int height)
{
/* Not the place for this.
	int pixels_right=0;
	int pixels_down=0;

	if (x+GEMuserobject::Width() > width) {
		pixels_right = width-x-GEMuserobject::Width();
	}
	if (y+GEMuserobject::Height() > height) {
		pixels_down = height-y-GEMuserobject::Height();
	}

	if (pixels_right||pixels_down) {
		Scroll(pixels_right, pixels_down);
	}
*/

	w=width;
	h=height;
}
