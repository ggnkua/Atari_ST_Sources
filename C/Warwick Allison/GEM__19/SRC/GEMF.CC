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
#include <vdibind.h>
#include <values.h>
#include "gemf.h"
#include "gemo.h"
#include "geme.h"
#include "gemr.h"
#include "flyform.h"
#include "grect.h"


GEMform::GEMform(const GEMrsc& in, int RSCindex) :
	myindex(RSCindex),
	ZoomOn(FALSE),
	flight(TRUE),
	open(0)
{
	Obj=in.Tree(myindex);
	AlignObject(ROOT,1,1);
}

static int global_count;
static GEMrawobject* global_obj;
static int CountObj(GEMrawobject* o, int i) { global_count++; return -1; }

// Why is "foo=bar" different from "foo=GEMrawobject(bar)"?
static int CopyObj(GEMrawobject* o, int i) { global_obj[i]=GEMrawobject(o[i]); return -1; }
//static int CopyObj(GEMrawobject* o, int i) { global_obj[i]=o[i]; return -1; }

GEMform::GEMform(const GEMform& copy) :
	myindex(copy.myindex),
	ZoomOn(copy.ZoomOn),
	flight(copy.flight),
	xoffset(copy.xoffset),
	yoffset(copy.yoffset),
	xmult(copy.xmult),
	ymult(copy.ymult),
	open(0)
{
	global_count=0;

	// CountObj doesn't modify copy, so safe to cast off constness
	((GEMform&)copy).Map(CountObj,FALSE);

	Obj=new GEMrawobject[global_count];
	global_obj=Obj;

	((GEMform&)copy).Map(CopyObj,FALSE);
}

GEMform::~GEMform()
{
}

static int FindEdit(GEMrawobject* o, int i)
{
	return o[i].Editable() ? i : -1;
}

int GEMform::FormDo()
{
	int edit=Map(FindEdit,TRUE);
	return form_do(Obj,edit);
}

int GEMform::Do()
{
	int x,y,w,h;
	form_center(Obj,&x,&y,&w,&h);
	return Do(x,y);
}

int GEMform::Do(int x, int y)
{
	open++; // Not actually re-entrant yet.

	// I have not used the GEM++ VDI class here, because that
	// would drag all that functionality in.  When gemlib gets a
	// bit more stable, I will use the GEM++ VDI.
	int j;
	int WorkOut[64];
	int WorkIn[]={1,1,1,1,1,1,1,1,1,1,2};
	vdihandle=graf_handle(&j,&j,&j,&j);
	v_opnvwk(WorkIn,&vdihandle,WorkOut);

	int X,Y,w,h;

	int bx,by,bw,bh;
	wind_get(0,WF_WORKXYWH,&bx,&by,&bw,&bh);

	// We use form_center, because it accounts for outline width.
	form_center(Obj,&X,&Y,&w,&h);

	if (w < bw) { // Can't do anything if it fills the width
		// We cancel the "centering" effect - just need w.
		Obj[ROOT].MoveBy(x-X,0);

		// Then, align the object tree, AND adjust the save-area/clip accordingly.
		int dx=(Obj[ROOT].X()+xoffset+xmult/2)/xmult*xmult-xoffset-Obj[ROOT].X();
		x+=dx;
		Obj[ROOT].MoveBy(dx,0);

		// But... make sure it is within the root window (if possible without resizing)
		if (x+w > bx+bw) {
			// Off right side - flushright.
			dx=(bx+bw)-(x+w);
		} else if (x<bx) {
			// Off left side - flushleft.
			dx=bx-x;
		} else {
			dx=0;
		}

		x+=dx;
		Obj[ROOT].MoveBy(dx,0);
	}

	if (h < bh) { // Can't do anything if it fills the height
		// Then we cancel the "centering" effect - just need (w,h).
		Obj[ROOT].MoveBy(0,y-Y);

		// Then, align the object tree, AND adjust the save-area/clip accordingly.
		int dy=(Obj[ROOT].Y()+yoffset+ymult/2)/ymult*ymult-yoffset-Obj[ROOT].Y();
		Obj[ROOT].MoveBy(0,dy);
		y+=dy;

		// But... make sure it is within the root window (if possible without resizing)
		if (y+h > by+bh) {
			dy=(by+bh)-(y+h);
		} else if (y<by) {
			dy=by-y;
		} else {
			dy=0;
		}

		y+=dy;
		Obj[ROOT].MoveBy(0,dy);
	}

	wind_update(BEG_UPDATE);

	if (ZoomOn) form_dial(FMD_GROW,0,0,0,0,x,y,w,h);

	if (flight) {
		flybuffer = flysave(vdihandle,x,y,w,h);
	} else {
		flybuffer = 0;
	}

	if (!flybuffer) form_dial(FMD_START,0,0,0,0,x,y,w,h);

	objc_draw(Obj, ROOT, MAX_DEPTH, x, y, w, h);

	GEMfeedback NowWhat=ContinueInteraction;
	int exitor=0;

	while (NowWhat!=EndInteraction) {
		// The guts of the interaction is virtual
		exitor=FormDo();

		// But the response handling is not... until the DoItem().
		if (exitor != -1) {
			exitor&=0x7fff; // Ignore the "TOUCHEXIT double click" bit for now.

			if (Obj[exitor].Exit()) Obj[exitor].Deselect();

			GEMevent e; // Current mouse state.
			NowWhat=DoItem(exitor,e);

			if (NowWhat==IgnoredClick && Obj[exitor].Exit())
				NowWhat=EndInteraction;
		} else {
			NowWhat=EndInteraction;
		}
	}

	if (flybuffer) {
		flyrestore(flybuffer);
		flybuffer=0;
	} else {
		form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	}

	if (ZoomOn)
		form_dial(FMD_SHRINK,0,0,0,0,
			Obj[ROOT].X(),Obj[ROOT].Y(),Obj[ROOT].Width(),Obj[ROOT].Height()
		);

	wind_update(END_UPDATE);

	v_clsvwk(vdihandle);
	vdihandle=-1;

	open--;

	return exitor;
}

void GEMform::RedrawObject(int RSCindex)
{
	if (IsOpen()) {
		objc_draw(Obj,RSCindex,MAX_DEPTH,0,0,MAXSHORT,MAXSHORT);
	}
}

void GEMform::RedrawObjectFromRoot(int RSCindex)
{
	int X,Y;
	objc_offset(Obj,RSCindex,&X,&Y);
	RedrawObject(ROOT,X-Obj[ROOT].X(),Y-Obj[ROOT].Y(),Obj[RSCindex].Width(),Obj[RSCindex].Height());
}

void GEMform::RedrawObject(int RSCindex,int Cx,int Cy,int Cw,int Ch) // Clipped
{
	if (IsOpen()) {
		int X,Y;
		objc_offset(Obj,RSCindex,&X,&Y);
		objc_draw(Obj,RSCindex,MAX_DEPTH,Cx+X,Cy+Y,Cw,Ch);
	}
}

int GEMform::Parent(int o) const
{
	int n=o;

	do {
		o=n;
		n=Obj[n].Next();
	} while (n>=0 && Obj[n].Tail()!=o);

	return n;
}

void GEMform::AlignObject(int RSCindex, int xmlt=8, int ymlt=1)
{
	int x,y;
	objc_offset(Obj,RSCindex,&x,&y);

	int rx,ry;
	objc_offset(Obj,ROOT,&rx,&ry);

	xoffset=x-rx;
	yoffset=y-ry;
	xmult=xmlt;
	ymult=ymlt;
}

/* Non-recursive traverse of an object tree. */
int GEMform::Map(int Do(GEMrawobject*, int), bool skiphidden, int RSCfrom, int RSCto)
{
	int tmp = RSCfrom;		// Initialize to impossible value

	// Look until final node, or off
	// the end of tree
	while (RSCfrom != RSCto && RSCfrom >= 0) {
		// Did we 'pop' into RSCfrom node for the second time?
		// Is this subtree hidden?
		if (Obj[RSCfrom].Tail() == tmp
		 || (skiphidden && Obj[RSCfrom].HideTree())) {
			// Yes - move right.
			tmp = RSCfrom;
			RSCfrom = Obj[tmp].Next();
		} else {
			// No, this is a new node
			tmp = RSCfrom;
			RSCfrom = -1;

			// Apply operation
			int reply=Do(Obj, tmp);

			// Found object to return?
			if (reply>=0) return reply;

			// Traverse subtree?
			if (reply==-1) RSCfrom = Obj[tmp].Head();

			// Traverse right if nowhere to go
			if (RSCfrom < 0)
				RSCfrom = Obj[tmp].Next();
		}
	}

	return -1;
}

GEMfeedback GEMform::DoItem(int obj, const GEMevent& e)
{
	GEMfeedback result=IgnoredClick;

	// CallBacks
	GEMobject* O=operator[](obj).Cook();

	if (O) {
		int ox,oy;
		objc_offset(Obj,obj,&ox,&oy);
		result=O->Touch(e.X()-ox,e.Y()-oy,e);

		switch (result) {
		 case RedrawMe:
			RedrawObject(obj);
		break; case RedrawMyParent:
			RedrawObject(Parent(obj));
		break; default: ;
		}
	}

	return result;
}

bool GEMform::Flight(bool on)
{
	bool result=flight;
	flight=on;
	return result;
}

void GEMform::Fly(bool opaque)
{
	if (flight && flybuffer && vdihandle>=0) {
		int dx,dy;
		flyfly(vdihandle,&flybuffer,&dx,&dy,opaque);
		Obj[ROOT].MoveBy(dx,dy);
		if (!opaque) {
			// Must redraw in this case
			RedrawObject(0);
		}
	}
}

bool GEMform::IsOpen()
{
	return open>0;
}

GRect* GEMform::FirstClip(int RSCobject)
{
	if (IsOpen()) {
		GRect* result=new GRect;
		objc_offset(Obj,RSCobject,&result->g_x,&result->g_y);
		result->g_w=Obj[RSCobject].Width();
		result->g_h=Obj[RSCobject].Height();
		// XXX Should we also clip to screen border?
		return result;
	} else {
		return 0;
	}
}

GRect* GEMform::NextClip(GRect* prev)
{
	delete prev;
	return 0;
}
