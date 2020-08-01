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

class GEMiconformwindow : public GEMformwindow {
public:
	GEMiconformwindow(GEMactivity& act, const GEMrsc& in, int RSCindex, GEMformiconwindow* of) :
		GEMformwindow(act,in,RSCindex,0),
		parent(of)
	{
	}

	GEMiconformwindow(const GEMiconformwindow& copy, GEMformiconwindow* of) :
		GEMformwindow(copy),
		parent(of)
	{
	}

	virtual void Top(const GEMevent& e)
	{
		Click(e);
	}

	virtual GEMfeedback Click(const GEMevent&)
	{
		GEMevent ev;
		ev.Rectangle(ev.X()-1,ev.Y()-1,3,3,TRUE); // Wait for mouse move >1 ...
		ev.Button(1,0); // ... or for button up.
		ev.Get(MU_M1|MU_BUTTON);
		if (ev.Rectangle()) {
			int bx,by,bw,bh;
			int nx,ny;
			wind_get(0,WF_WORKXYWH,&bx,&by,&bw,&bh);
			GRect w=BorderRect();
			graf_dragbox(w.g_w,w.g_h,w.g_x,w.g_y,bx,by,bw,bh,&nx,&ny);
			GEMformwindow::Move(nx,ny);
		} else {
			Close();
			if (parent->Zooms(TRUE)) {
				GRect s=BorderRect();
				GRect f=parent->BorderRect();
				graf_growbox(s.g_x,s.g_y,s.g_w,s.g_y,f.g_x,f.g_y,f.g_w,f.g_h);
			} else {
				parent->Zooms(FALSE);
			}
			parent->IconOpened();
		}
		return ContinueInteraction;
	}

private:
	GEMformiconwindow* parent;
};

GEMformiconwindow::GEMformiconwindow(GEMactivity& act, const GEMrsc& in, int RSCform, int RSCicon) :
	GEMformwindow(act,in,RSCform,CLOSER|MOVER|NAME|FULLER),
	icon(new GEMiconformwindow(act,in,RSCicon,this))
{
	Zooms(TRUE);
}

GEMformiconwindow::GEMformiconwindow(GEMactivity& act, const GEMrsc& in, int RSCform, int RSCicon, int Parts) :
	GEMformwindow(act,in,RSCform,Parts),
	icon(new GEMiconformwindow(act,in,RSCicon,this))
{
	Zooms(TRUE);
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

void GEMformiconwindow::UserFulled()
{
	Close();
	if (Zooms(TRUE)) {
		GRect s=BorderRect();
		GRect f=icon->BorderRect();
		graf_shrinkbox(f.g_x,f.g_y,f.g_w,f.g_y,s.g_x,s.g_y,s.g_w,s.g_h);
	} else {
		Zooms(FALSE);
	}
	icon->Open();
}

void GEMformiconwindow::Open()
{
	if (IsIconified()) icon->Close();
	GEMformwindow::Open();
}

void GEMformiconwindow::IconOpened()
{
	Open();
}

bool GEMformiconwindow::IsIconified() const
{
	return icon->IsOpen();
}
