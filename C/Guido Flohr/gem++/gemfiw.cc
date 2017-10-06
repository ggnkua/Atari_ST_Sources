/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemfiw.h"
#include "geme.h"
#include <aesbind.h>
#include "aesext.h"
#include "geminfo.h"

class GEMiconformwindow : public GEMformwindow {
public:
	GEMiconformwindow(GEMactivity& act, const GEMrsc& in, int RSCindex, GEMformiconwindow* of) :
		GEMformwindow(act,in,RSCindex,0),
		parent(of)
	{
		GEMformwindow::Move(-1,0); // Not placed
	}

	GEMiconformwindow(const GEMiconformwindow& copy, GEMformiconwindow* of) :
		GEMformwindow(copy),
		parent(of)
	{
		GEMformwindow::Move(-1,0); // Not placed
	}

	virtual void Top(const GEMevent& e)
	{
		Click(e);
	}

	virtual GEMfeedback Click(const GEMevent&)
	{
		GEMevent ev;
		ev.Rectangle(ev.X()-1,ev.Y()-1,3,3,true); // Wait for mouse move >1 ...
		ev.Button(1,0); // ... or for button up.
		ev.Get(MU_M1|MU_BUTTON);
		if (ev.Rectangle()) {
			int bx,by,bw,bh;
			GEMinfo Info;
			Info.Desktop().GetRect (bx, by, bw, bh);
			int nx,ny;
			GRect w=BorderRect();
			graf_dragbox(w.g_w,w.g_h,w.g_x,w.g_y,bx,by,bw,bh,&nx,&ny);
			GEMformwindow::Move(nx,ny);
		} else {
			Close();
			if (parent->Zooms(true)) {
				GRect s=BorderRect();
				GRect f=parent->BorderRect();
				graf_growbox(s.g_x,s.g_y,s.g_w,s.g_y,f.g_x,f.g_y,f.g_w,f.g_h);
			} else {
				parent->Zooms(false);
			}
			parent->IconOpened();
		}
		return ContinueInteraction;
	}

	void MoveToPlacementArea (const GRect& where)
	{
	  if (&where != 0) {
	    GEMformwindow::Move (where.g_x, where.g_y);
	  } else {
	  	GEMinfo Info;
  		const GRect& rootwin = Info.Desktop ();

		GRect area=BorderRect();

  		if (area.g_y<=rootwin.g_y && area.g_x<rootwin.g_x) {
	  		// Hasn't been placed
		  	GEMformiconwindow::FindPlacementArea(area.g_x,area.g_y,area.g_w,area.g_h);
			  GEMformwindow::Move(area.g_x,area.g_y);
			}
		}
	}

private:
	GEMformiconwindow* parent;
};

GEMformiconwindow::GEMformiconwindow(GEMactivity& act, const GEMrsc& in, int RSCform, int RSCicon) :
	GEMformwindow(act,in,RSCform,CLOSER|MOVER|NAME|SMALLER),
	icon(new GEMiconformwindow(act,in,RSCicon,this))
{
	Zooms(true);
}

GEMformiconwindow::GEMformiconwindow(GEMactivity& act, const GEMrsc& in, int RSCform, int RSCicon, int Parts) :
	GEMformwindow(act,in,RSCform,Parts),
	icon(new GEMiconformwindow(act,in,RSCicon,this))
{
	Zooms(true);
}

GEMformiconwindow::GEMformiconwindow(const GEMformiconwindow& copy) :
	GEMformwindow(copy),
	icon(new GEMiconformwindow(*copy.icon,this))
{
}

GEMformiconwindow::~GEMformiconwindow()
{
	delete icon;
}

void GEMformiconwindow::UserIconified(const GRect& rect)
{
	Close();

	icon->MoveToPlacementArea(rect);

	if (Zooms(true)) {
		GRect s=BorderRect();
		GRect f=icon->BorderRect();
		graf_shrinkbox(f.g_x,f.g_y,f.g_w,f.g_y,s.g_x,s.g_y,s.g_w,s.g_h);
	} else {
		Zooms(false);
	}

	icon->Open();
}

void GEMformiconwindow::Open()
{
	if (GEMformwindow::IsIconified()) icon->Close();
	GEMformwindow::Open();
}

void GEMformiconwindow::IconOpened()
{
	Open();
}

bool GEMformiconwindow::IsIconified(int& w, int& h) const
{
	if (icon->IsOpen()) {
		GRect ir=icon->BorderRect();
		w=ir.g_w;
		h=ir.g_h;
		return true;
	} else {
		return false;
	}
}

GEMform& GEMformiconwindow::IconForm()
{
	return *icon;
}

void GEMformiconwindow::Placement(GRect area, Corner c)
{
	placement=c;
	placement_area=area;
}

void GEMformiconwindow::Placement(Corner c)
{
	GRect rootwin;
	wind_get(0, WF_WORKXYWH, &rootwin.g_x, &rootwin.g_y, &rootwin.g_w, &rootwin.g_h);
	Placement(rootwin,c);
}

GEMformiconwindow::Corner GEMformiconwindow::placement=GEMformiconwindow::EN;
GRect GEMformiconwindow::placement_area(0,0,0,0);

void GEMformiconwindow::FindPlacementArea(int& x, int& y, int w, int h)
{
	if (placement_area.g_w==0) {
		// Initialize
		Placement(placement);
	}

	switch (placement) {
	 case EN: case NE:
		x=placement_area.g_x+placement_area.g_w-w;
		y=placement_area.g_y;
	break; case ES: case SE:
		x=placement_area.g_x+placement_area.g_w-w;
		y=placement_area.g_y+placement_area.g_h-h;
	break; case WN: case NW:
		x=placement_area.g_x;
		y=placement_area.g_y;
	break; case WS: case SW:
		x=placement_area.g_x;
		y=placement_area.g_y+placement_area.g_h-h;
	}

	const int border=3;

	while (1) {
		if (!wind_find(x,y)
		 && !wind_find(x+w-1,y+h-1)
		 && !wind_find(x,y+h-1)
		 && !wind_find(x+w-1,y)) {
			// Found space
			return;
		}

		switch (placement) {
		 case EN: case ES: case WN: case WS:
			if (placement==EN || placement==WN) y+=h+border;
			else y-=h+border;
			if (y+h>=placement_area.g_y+placement_area.g_h) {
				y=placement_area.g_y;
				if (placement==EN || placement==ES) {
					x-=w+border;
					if (x<placement_area.g_x) {
						x=y=0; return; // Give up.
					}
				} else {
					x+=w+border;
					if (x+w>=placement_area.g_x+placement_area.g_w) {
						x=y=0; return; // Give up.
					}
				}
			}
		break; case NE: case SE: case NW: case SW:
			if (placement==NE || placement==NW) x+=w+border;
			else x-=w+border;
			if (x+w>=placement_area.g_x+placement_area.g_w) {
				x=placement_area.g_x;
				if (placement==NE || placement==SE) {
					y-=h+border;
					if (y<placement_area.g_y) {
						x=y=0; return; // Give up.
					}
				} else {
					y+=h+border;
					if (y+h>=placement_area.g_y+placement_area.g_h) {
						x=y=0; return; // Give up.
					}
				}
			}
		}
	}
}

