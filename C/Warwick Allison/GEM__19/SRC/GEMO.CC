/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemo.h"
#include "gemf.h"
#include <aesbind.h>
#include <string.h>
#include <limits.h>


GEMobject::GEMobject(GEMform& F, int RSCindex) :
	form(F),
	myindex(RSCindex)
{
	if (me().Indirect()) {
		// It's already attached to a GEMobject
		original_ob_spec=me().Cook()->original_ob_spec;
	} else {
		original_ob_spec=me().ObjectSpecific();
		me().ObjectSpecific((unsigned long)this);
		me().Indirect(TRUE);
	}
}

GEMobject::~GEMobject()
{
	if (me().Cook() == this) {
		// Must have been a newly attached GEMobject
		me().Indirect(FALSE);
		me().ObjectSpecific(original_ob_spec);
	}
}

void GEMobject::Resize(short w, short h)
{
	SetWidth(w);
	SetHeight(h);
}

void GEMobject::SetWidth(short w)
{
	me().Resize(w,Height());
}

void GEMobject::SetHeight(short h)
{
	me().Resize(Width(),h);
}

void GEMobject::Redraw()
{
	int border=BorderWidth();
	if (border>0)
		form.RedrawObject(myindex,-border,-border,Width()+2*border,Height()+2*border);
	else
		form.RedrawObject(myindex);
}

void GEMobject::RedrawParent()
{
	form.RedrawObject(form.Parent(myindex));
}

GEMfeedback GEMobject::Touch(int x, int y, const GEMevent&)
{
	return IgnoredClick;
}

bool GEMobject::ContainsPoint(int x, int y) const
{
	int X,Y;

	objc_offset(&form[0],myindex,&X,&Y);
	return (x>=X && y>=Y && x<X+me().Width() && y<Y+me().Height());
}

void GEMobject::Detach()
{
	objc_delete(&form[0],myindex);
}

void GEMobject::Attach(GEMobject& o)
{
	objc_add(&form[0],myindex,o.myindex);
}

void GEMobject::Attach(int RSCindex)
{
	objc_add(&form[0],myindex,RSCindex);
}

void GEMobject::GetAbsoluteXY(int& x, int& y) const
{
	objc_offset(&form[0],myindex,&x,&y);
}

// RSCindex-based
int GEMobject::NumberOfChildren() const
{
	int c=FirstChild();
	for (int n=0; c>=0; n++) c=NextChild(c);
	return n;
}

int GEMobject::FirstChild() const
{
	return (me().Head() == myindex) ? -1 : me().Head();
}

int GEMobject::NextChild(int after) const
{
	int c=form[after].Next();
	return (c == myindex) ? -1 : c;
}

// GEMobject-based
int GEMobject::NumberOfComponents() const
{
	int c=FirstChild();
	for (int n=0; c>=0; c=NextChild(c)) if (form[c].Cook()) n++;
	return n;
}

GEMobject* GEMobject::FirstComponent() const
{
	GEMobject* o=0;
	for (int c=FirstChild(); c>=0 && !(o=form[c].Cook()); c=NextChild(c))
		;
	return o;
}

GEMobject* GEMobject::NextComponent(const GEMobject* oo) const
{
	GEMobject* o=0;
	for (int c=FirstChild(); c>=0 && !(o=form[c].Cook()) && o!=oo; c=NextChild(c))
		;
	if (c>=0) c=NextChild(c);
	for (; c>=0 && !(o=form[c].Cook()); c=NextChild(c))
		;
	return o;
}


GEMrawobject* GEMobject::Child(int c) const
{
	return &form[c];
}

int GEMobject::Type() const
{
	return me().Type();
}

void GEMobject::Type(int t)
{
	me().Type(t);
}

int GEMobject::ObjectSpecific() const
{
	return original_ob_spec;
}

void GEMobject::ObjectSpecific(int s)
{
	original_ob_spec=s;
}

#define CLASS GEMobject
#include "gemo_m.cc"
#undef CLASS
