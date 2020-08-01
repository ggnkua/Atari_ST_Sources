/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include <aesbind.h>
#include <osbind.h>
#include "gemfw.h"
#include "gemo.h"
#include "geme.h"
#include "scancode.h"

// The global int "StartObject" links the call to RedrawOverlaps
// with RedrawOverlaps' calls to Redraw.  An alternative solution
// would be to have RedrawOverlaps accept a parameter which it
// just blindly passed to Redraw, however this would involve a
// void* pointer, and would delocalize the issue.  When setting
// the StartObject, be sure to reset it to ROOT, since redraw
// events, etc. will also call RedrawOverlaps.
static int StartObject=ROOT;

GEMformwindow::GEMformwindow(GEMactivity& act, const GEMrsc& in, int RSCindex) :
	GEMwindow(act,CLOSER|MOVER|NAME), GEMform(in, RSCindex),
	rubberwidth(FALSE),
	rubberheight(FALSE)
{
	GRect workArea(Obj[ROOT].X(), Obj[ROOT].Y(),
		Obj[ROOT].Width(), Obj[ROOT].Height());
	Max = Pos = workArea;
	initialized = TRUE;
	Align(0,0,2,2); // For simple shade patterns (complex ones require 4x4)

	ButtonEventFlags(1);
}

GEMformwindow::GEMformwindow(GEMactivity& act, const GEMrsc& in, int RSCindex, int Parts) :
	GEMwindow(act,Parts), GEMform(in, RSCindex),
	rubberwidth(bool(Parts&SIZER && !(Parts&HSLIDE))),
	rubberheight(bool(Parts&SIZER && !(Parts&VSLIDE)))
{
	GRect workArea(Obj[ROOT].X(), Obj[ROOT].Y(),
		Obj[ROOT].Width(), Obj[ROOT].Height());
	Max = Pos = workArea;
	initialized = TRUE;
	Align(0,0,2,2); // For simple shade patterns (complex ones require 4x4)

	// Assumes ColumnWidth() and LineHeight() are 1.
	SetTotalColumns(Obj[ROOT].Width());
	SetTotalLines(Obj[ROOT].Height());
	SetVisibleColumns(Obj[ROOT].Width());
	SetVisibleLines(Obj[ROOT].Height());

	ButtonEventFlags(1);
}

GEMformwindow::GEMformwindow(const GEMformwindow& copy) :
	GEMwindow(copy), GEMform(copy),
	rubberwidth(copy.rubberwidth),
	rubberheight(copy.rubberheight)
{
	// GEMwindow is exactly the same, except position changes slightly.
	Obj[ROOT].MoveTo(Pos.g_x,Pos.g_y);
}

static
bool GetKey(int& Key)
// Modal.  Menu bar is not active while getting keys.
// Returns FALSE if non-key event arrives.
{
	int Pipe[32];
	int mx,my,button,meta,count;

	wind_update(BEG_MCTRL);

	int got=evnt_multi(MU_KEYBD|MU_BUTTON,
				1,1,1,0,0,0,0,0,0,0,0,0,0,
				Pipe,0,&mx,&my,&button,&meta,&Key,&count
			);

	wind_update(END_MCTRL);

	if (got&MU_KEYBD) {
		return TRUE;
	}

	return FALSE;
}

void GEMformwindow::Redraw(const GRect& area)
{
	if (IsOpen()) {
		objc_draw(Obj, StartObject, MAX_DEPTH, area.g_x, area.g_y, area.g_w, area.g_h);
	}
}

bool GEMformwindow::ScrollByBlitting() const
{
	// Actually, without WINX, patterns may look poor with blit scrolling.
	return TRUE;
}

void GEMformwindow::SetWorkRect(const GRect& r)
// Do the normal SetWorkRect, then adjust object tree position.
{
	GEMwindow::SetWorkRect(r);
	GEMrawobject* root=&Obj[ROOT];
	GEMobject* croot=root->Cook();

	if (croot) {
		croot->MoveTo(Pos.g_x-LeftColumn()*ColumnWidth(),
			Pos.g_y-TopLine()*LineHeight());
		bool changed=FALSE;
		if (rubberwidth && Pos.g_w!=croot->Width()) {
			croot->SetWidth(Pos.g_w);
			changed=TRUE;
		}
		if (rubberheight && Pos.g_h!=croot->Height()) {
			croot->SetHeight(Pos.g_h);
			changed=TRUE;
		}
		if (changed) {
			RedrawObject(0);
		}
	} else {
		root->MoveTo(Pos.g_x-LeftColumn()*ColumnWidth(),
			Pos.g_y-TopLine()*LineHeight());
	}
}

void GEMformwindow::HFlushSlider()
// Adjust object tree position.
{
	GEMwindow::HFlushSlider();
	Obj[ROOT].MoveTo(Pos.g_x-LeftColumn()*ColumnWidth(),
		Pos.g_y-TopLine()*LineHeight());
}

void GEMformwindow::VFlushSlider()
// Adjust object tree position.
{
	GEMwindow::VFlushSlider();
	Obj[ROOT].MoveTo(Pos.g_x-LeftColumn()*ColumnWidth(),
		Pos.g_y-TopLine()*LineHeight());
}

static
void WaitForNoButton()
{
	int X,Y,Buttons,Metas;

	do graf_mkstate(&X,&Y,&Buttons,&Metas); while (Buttons);
}


// Any point in making this a method of GEMobjects?
static
void WatchBox(GEMobject *O)
{
	int X,Y,Buttons,Metas;
	bool OldOn=O->Selected();
	bool On=FALSE;

	do {
		graf_mkstate(&X,&Y,&Buttons,&Metas);
		On=O->ContainsPoint(X,Y);
		if (On!=OldOn) {
			OldOn=On;
			O->Selected(On);
			O->Redraw();
		}
	} while (Buttons);
}

static
int FindEditable(GEMrawobject *Obj, int Object, int way)
{
	int c=Object+way;

	while (1) {
		if (c<0) while (!(Obj[++c].LastObject()));
		else if (Obj[c].Editable() || c==Object) return c;
		else if (Obj[c].LastObject() && way>0) c=0;
		else c+=way;
	}
}

void GEMformwindow::Edit(int Object, int Index)
{
	// The Atari Compendium says "Reserved for future use.  Do not call."
	//objc_edit(Obj,Object,0,Index,EDSTART,&Index);

	objc_edit(Obj,Object,0,Index,EDINIT,&Index);

	WaitForNoButton();

	while (1) {
		int Key;

		if (!GetKey(Key)) {
			objc_edit(Obj,Object,0,Index,EDEND,&Index);
			return;
		}

		switch (Key>>8) {
			case KEY_RETURN:
				objc_edit(Obj,Object,0,Index,EDEND,&Index);
				return;
		break;	case KEY_UP:
				objc_edit(Obj,Object,0,Index,EDEND,&Index);
				Object=FindEditable(Obj,Object,-1);
				objc_edit(Obj,Object,0,Index,EDINIT,&Index);
		break;	case KEY_DOWN:
				objc_edit(Obj,Object,0,Index,EDEND,&Index);
				Object=FindEditable(Obj,Object,+1);
				objc_edit(Obj,Object,0,Index,EDINIT,&Index);
		break;	default:
				objc_edit(Obj,Object,Key,Index,EDCHAR,&Index);
		}

	}
}

static
bool inside(int x, int y, const GRECT& pt)
{
	return ( x>=pt.g_x && y>=pt.g_y && x<pt.g_x+pt.g_w && y<pt.g_y+pt.g_h );
}

void GEMformwindow::Top(const GEMevent& e)
{
	if (!inside(e.X(),e.Y(),WorkRect()) || Click(e)==IgnoredClick) GEMwindow::Top(e);
}

GEMfeedback GEMformwindow::Click(const GEMevent& e)
{
	GEMfeedback result=IgnoredClick;

	int o=objc_find(Obj,ROOT,MAX_DEPTH,e.X(),e.Y());

	if (o>=0) {
		while (o>=0 && !Obj[o].Disabled() && !Obj[o].RadioButton()
		  && !Obj[o].TouchExit() && !Obj[o].Editable()
		  && !Obj[o].Exit() && !Obj[o].Selectable()) {
			o=Parent(o);
		}
		if (o<0) o=0;

		GEMobject *O=operator[](o).Cook();

		int dummy=O==0;

		if (dummy) O=new GEMobject(*this,o);

		if (!O->Disabled()) {
			int X,Y;
			objc_offset(Obj,o,&X,&Y);

			if (O->TouchExit())
				result=DoItem(o,e);

			if (O->RadioButton()) {
				if (!O->Selected()) {
					int p=Parent(o);
					int c=Obj[p].Head();
					while (c!=p) {
						GEMobject P(*this,c);
						if (P.Selected() && P.RadioButton()) {
							P.Deselect();
							P.Redraw();
						}
						c=Obj[c].Next();
					}
					O->Select();
					O->Redraw();

					result=DoItem(o,e);

					if (result==IgnoredClick) result=ContinueInteraction;
				} else 
					result=ContinueInteraction;
			} else {
				if (O->Selectable() && !O->Exit()) {
					if (O->Selected()) O->Deselect();
					else O->Select();
					O->Redraw();

					result=DoItem(o,e);
					if (result==IgnoredClick) result=ContinueInteraction;
					WaitForNoButton();
				}
			}

			if (O->Editable()) {
				Edit(o,1/* Column */);
				result=DoItem(o,e);
				if (result==IgnoredClick) result=ContinueInteraction;
			}

			if (O->Exit()) {
				result=ContinueInteraction;
				if (O->Selectable()) {
					WatchBox(O);
					if (O->Selected()) {
						result=DoItem(o,e);
						if (result==IgnoredClick) result=ContinueInteraction;
						O->Deselect();
						O->Redraw();
					}
				} else {
					WaitForNoButton();
				}
			}
		}
		if (dummy) delete O;
	}

	if (result==IgnoredClick && (ButtonEventFlags(-1)&1)) {
		GEMwindow::Top(e);
		result=ContinueInteraction;
	}

	return result;
}


void GEMformwindow::RedrawObject(int RSCindex)
{
	if (IsOpen()) {
		int x,y;
		objc_offset(Obj,RSCindex,&x,&y);
		GRect R(x,y,Obj[RSCindex].Width(),Obj[RSCindex].Height());
		StartObject=RSCindex;
		RedrawOverlaps(R);
		StartObject=ROOT;
	}
}

void GEMformwindow::RedrawObject(int RSCindex,int Cx,int Cy,int Cw,int Ch) // Clipped
{
	if (IsOpen()) {
		int x,y;
		objc_offset(Obj,RSCindex,&x,&y);
		GRect R(x+Cx,y+Cy,Cw,Ch);
		StartObject=RSCindex;
		RedrawOverlaps(R);
		StartObject=ROOT;
	}
}

void GEMformwindow::AlignObject(int RSCindex, int xmlt=8, int ymlt=1)
{
	GEMform::AlignObject(RSCindex,xmlt,ymlt);

	int j;
	int x,y;
	wind_calc(1,parts,xoffset,yoffset,50,50,&x,&y,&j,&j);

	Align(x,y,xmult,ymult);
}

bool GEMformwindow::IsOpen() const
{
	return GEMwindow::IsOpen();
}

bool GEMformwindow::RubberWidth()
{
	return rubberwidth;
}

bool GEMformwindow::RubberHeight()
{
	return rubberheight;
}

void GEMformwindow::RubberWidth(bool yes)
{
	rubberwidth=yes;
}

void GEMformwindow::RubberHeight(bool yes)
{
	rubberheight=yes;
}

void GEMformwindow::Rubber(bool yes)
{
	RubberWidth(yes);
	RubberHeight(yes);
}

class GEMfwRect : public GRect {
public:
	GRect box;
	GRect obox;
};

GRect* GEMformwindow::FirstClip(int RSCobject)
{
	if (IsOpen()) {
		GEMfwRect* result=new GEMfwRect;

		objc_offset(Obj,RSCobject,&result->obox.g_x,&result->obox.g_y);
		result->obox.g_w=Obj[RSCobject].Width();
		result->obox.g_h=Obj[RSCobject].Height();

		wind_get(Handle(), WF_FIRSTXYWH,
			&result->box.g_x, &result->box.g_y, &result->box.g_w, &result->box.g_h);

		return NextClip(result);
	} else {
		return 0;
	}
}

GRect* GEMformwindow::NextClip(GRect* prev)
{
	GEMfwRect* rect=(GEMfwRect*)prev;

	while (rect->box.g_w && rect->box.g_h) {
		if (rc_intersect(&rect->obox, &rect->box)) {
			rect->g_x=rect->box.g_x;
			rect->g_y=rect->box.g_y;
			rect->g_w=rect->box.g_w;
			rect->g_h=rect->box.g_h;
			// Get ready for the next call to this.
			wind_get(Handle(), WF_NEXTXYWH,
				&rect->box.g_x, &rect->box.g_y, &rect->box.g_w, &rect->box.g_h);

			return rect;
		}
		wind_get(Handle(), WF_NEXTXYWH,
			&rect->box.g_x, &rect->box.g_y, &rect->box.g_w, &rect->box.g_h);
	}

	delete rect;

	return 0;
}

// To slow scrolling in pixels, and this improves pattern scrolling.

int GEMformwindow::VLineAmount()
{
	return 4;
}

int GEMformwindow::HColumnAmount()
{
	return 4;
}

