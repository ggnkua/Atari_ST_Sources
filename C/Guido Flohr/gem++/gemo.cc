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
    me().Indirect(true);
  }
}

GEMobject::~GEMobject()
{
  if (me().Cook() == this) {
    // Must have been a newly attached GEMobject
    me().Indirect(false);
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

void GEMobject::RedrawParent () const
{
  if (form.Parent (myindex) == -1)
    Redraw ();
  else
    form.RedrawObject (form.Parent (myindex));
}

void GEMobject::RedrawParent (const GRect& clip) const
{
  if (form.Parent (myindex) == -1) {
    GRect NewClip (clip);
    NewClip.MoveRel (-X (), -Y ());
    Redraw (NewClip);
  } else {
    form.RedrawObject (form.Parent (myindex), clip);
  }
}

void GEMobject::RedrawParentAbsolute (const GRect& clip) const
{
  if (form.Parent (myindex) == -1) {
    RedrawAbsolute (clip);
  }
  GRect RelClip;
  objc_offset (&form[ROOT], form.Parent (myindex), &RelClip.g_x, &RelClip.g_y);
  GEMrawobject& Parent = form.Object (form.Parent (myindex));
  RelClip.Resize (Parent.Width (), Parent.Height ());
  int xoffset = RelClip.g_x;
  int yoffset = RelClip.g_y;
  RelClip.Clip (clip);
  RelClip.MoveRel (Parent.X () - xoffset, Parent.Y () - yoffset);
  form.RedrawObject (form.Parent (myindex), RelClip);
}

void GEMobject::Redraw () const
{
  int border = BorderWidth ();
  if (border < 0) // Outside
    form.RedrawObject (myindex, border, border, 
    Width () - 2 * border, Height () - 2 * border);
  else
    form.RedrawObject (myindex);
}

void GEMobject::Redraw (const GRect& clip) const
{
  form.RedrawObject (myindex, clip);
}

void GEMobject::RedrawAbsolute (const GRect& clip) const
{
  GRect RelClip = AbsolutePosition ();
  int xoffset = RelClip.g_x;
  int yoffset = RelClip.g_y;
  RelClip.Clip (clip);
  RelClip.MoveRel (X () - xoffset, Y () - yoffset);
  form.RedrawObject (myindex, RelClip);
}

GEMfeedback GEMobject::Touch(int x, int y, const GEMevent&)
{
  if (x == y)
    return IgnoredClick;
  else
    return IgnoredClick;
}

bool GEMobject::ContainsPoint(int x, int y) const
{
  int X,Y;

  objc_offset(&form[ROOT],myindex,&X,&Y);
  return (x>=X && y>=Y && x<X+me().Width() && y<Y+me().Height());
}

void GEMobject::Detach()
{
  objc_delete(&form[ROOT],myindex);
}

void GEMobject::Attach(GEMobject& o)
{
  objc_add(&form[ROOT],myindex,o.myindex);
}

void GEMobject::Attach(int RSCindex)
{
  objc_add(&form[ROOT],myindex,RSCindex);
}

void GEMobject::GetAbsoluteXY(int& x, int& y) const
{
  objc_offset(&form[ROOT],myindex,&x,&y);
}

// RSCindex-based
int GEMobject::NumberOfChildren() const
{
  int c=FirstChild();
  int n;
  for (n=0; c>=0; n++) c=NextChild(c);
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
  int n;
  for (n=0; c>=0; c=NextChild(c)) if (form[c].Cook()) n++;
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
  int c;
  for (c=FirstChild(); c>=0 && !(o=form[c].Cook()) && o!=oo; c=NextChild(c))
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

void GEMobject::Hot(bool yes)
{
  int ext=me().ExtType();
  if (yes) ext|=0x10;
  else ext&=~0x10;
  me().ExtType(ext);
}

bool GEMobject::Hot()
{
  return !!(me().ExtType()&0x10);
}

void GEMobject::InFocus (bool)
{
  // Ignore.
  return;
}

const GRect GEMobject::Position () const
{
  GRect ret (X (), Y (), Width (), Height ());
  return ret;
}

const GRect GEMobject::AbsolutePosition () const
{
  GRect ret;
  ret.Resize (Width (), Height ());
  GetAbsoluteXY (ret.g_x, ret.g_y);
  return ret;
}

#define CLASS GEMobject
#include "gemo_m.cc"
#undef CLASS
