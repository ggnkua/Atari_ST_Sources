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

static int abs(int i)
{
	return i<0 ? -i : i;
}

static const int UNLIMITED=-1;

GEMscrollableobject::GEMscrollableobject(GEMform& form, int RSCindex) :
	VDI(),
	GEMuserobject(form,RSCindex)
{
}

void GEMscrollableobject::Scroll(int pixels_right, int pixels_down)
{
	if (pixels_down || pixels_right) {
		int X,Y;
		GetAbsoluteXY(X,Y);

		for (GRect* clip=form.FirstClip(myindex); clip; clip=form.NextClip(clip)) {
			int pxy[8];

			// Anything to scroll?
			if (abs(pixels_right)<clip->g_w
			 && abs(pixels_down)<clip->g_h) {
				if (pixels_right>0) {
					pxy[0]=clip->g_x+pixels_right;
					pxy[2]=clip->g_x+clip->g_w-1;
					pxy[4]=clip->g_x;
					pxy[6]=clip->g_x+clip->g_w-pixels_right-1;
				} else {
					pxy[0]=clip->g_x;
					pxy[2]=clip->g_x+clip->g_w+pixels_right-1;
					pxy[4]=clip->g_x-pixels_right;
					pxy[6]=clip->g_x+clip->g_w-1;
				}

				if (pixels_down>0) {
					pxy[1]=clip->g_y+pixels_down;
					pxy[3]=clip->g_y+clip->g_h-1;
					pxy[5]=clip->g_y;
					pxy[7]=clip->g_y+clip->g_h-pixels_down-1;
				} else {
					pxy[1]=clip->g_y;
					pxy[3]=clip->g_y+clip->g_h+pixels_down-1;
					pxy[5]=clip->g_y-pixels_down;
					pxy[7]=clip->g_y+clip->g_h-1;
				}

				ro_cpyfm(VDI::SRC,pxy);

				if (pixels_right>0) {
					GRect redraw_side(clip->g_x+clip->g_w-pixels_right,clip->g_y,
						pixels_right,clip->g_h);
					RedrawClipped(X,Y,redraw_side);
				} else if (pixels_right) {
					GRect redraw_side(clip->g_x,clip->g_y,-pixels_right,clip->g_h);
					RedrawClipped(X,Y,redraw_side);
				}

				if (pixels_down>0) {
					if (pixels_right>0) {
						GRect redraw_side(clip->g_x,clip->g_y+clip->g_h-pixels_down,
							clip->g_w-pixels_right,pixels_down);
						RedrawClipped(X,Y,redraw_side);
					} else {
						GRect redraw_side(clip->g_x-pixels_right,clip->g_y+clip->g_h-pixels_down,
							clip->g_w+pixels_right,pixels_down);
						RedrawClipped(X,Y,redraw_side);
					}
				} else if (pixels_down) {
					if (pixels_right>0) {
						GRect redraw_side(clip->g_x,clip->g_y,clip->g_w-pixels_right,-pixels_down);
						RedrawClipped(X,Y,redraw_side);
					} else {
						GRect redraw_side(clip->g_x-pixels_right,clip->g_y,clip->g_w+pixels_right,-pixels_down);
						RedrawClipped(X,Y,redraw_side);
					}
				}
			} else {
				RedrawClipped(X,Y,*clip);
			}
		}
	}
}

void GEMscrollableobject::VScroll(int pixels_down)
{
	// Could be marginally optimized by specificizing Scroll().
	Scroll(0,pixels_down);
}

void GEMscrollableobject::HScroll(int pixels_right)
{
	// Could be marginally optimized by specificizing Scroll().
	Scroll(pixels_right,0);
}

void GEMscrollableobject::Draw(const PARMBLK* p)
{
	GRect drawclip(p->pb_xc,p->pb_yc,p->pb_wc,p->pb_hc);
	GRect objclip(p->pb_x,p->pb_y,GEMuserobject::Width(),GEMuserobject::Height());
	drawclip.Clip(objclip);

	RedrawClipped(p->pb_x,p->pb_y,drawclip);
}
