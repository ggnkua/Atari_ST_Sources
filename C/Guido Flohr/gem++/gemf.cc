// GEM++.
// Copyright (C) 1992, 1993 by Warwick W. Allison.
// Copyright (C) 1997 by Guido Flohr <gufl0000@stud.uni-sb.de>.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
//
// $Date$  
// $Revision$  
// $State$  

#include <aesbind.h>
#include <vdibind.h>
#include <limits.h>
#include "gemo.h"
#include "geme.h"
#include "gemr.h"
#include "flyform.h"
#include "grect.h"
#include "geminfo.h"

#include "gemf.h"  // Implemented here.

GEMform::GEMform(const GEMrsc& in, int RSCindex) :
  myindex(RSCindex),
  open (0),
  ZoomOn (false),
  flight (true)
{
  Obj=in.Tree(myindex);
  AlignObject(ROOT,1,1);
}

// static int CountObj (GEMrawobject* o, int i) { global_count++; return -1; }
// static int CopyObj (GEMrawobject* o, int i) { global_obj[i]=GEMrawobject(o[i]); return -1; }
int GEMform::CountObj (GEMrawobject*, int) 
{ 
  global_count++; 
  return -1; 
}

int GEMform::CopyObj (GEMrawobject* o, int i)
{
  global_obj[i] = GEMrawobject (o[i]);
  return -1;
}

GEMform::GEMform(const GEMform& copy) :
  myindex(copy.myindex),
  open(0),
  ZoomOn(copy.ZoomOn),
  flight(copy.flight),
  xoffset(copy.xoffset),
  yoffset(copy.yoffset),
  xmult(copy.xmult),
  ymult(copy.ymult)
{
  global_count=0;

  // CountObj doesn't modify copy, so safe to cast off constness
  ((GEMform&) copy).Map (CountObj, false);

  Obj=new GEMrawobject[global_count];
  global_obj=Obj;

  ((GEMform&)copy).Map(CopyObj,false);
}

GEMform::~GEMform()
{
}

static int FindEdit(GEMrawobject* o, int i)
{
  return o[i].Editable() ? i : -1;
}

int GEMform::FormDo(GEMevent& finalevent)
{
  int edit=Map(FindEdit,true);
  int exit=form_do(Obj,edit);
  GEMevent fakeev(0,0,1,1);
  finalevent=fakeev;
  return exit;
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

  int bx, by, bw, bh;
  GEMinfo Info;
  Info.Desktop().GetRect (bx, by, bw, bh);

  if (Obj[ROOT].BorderWidth() >= 0) { // Inside
    // We use form_center, because it accounts for outline and shadow width.
    form_center(Obj,&X,&Y,&w,&h);
  } else {
    // No we don't, because is ignores border width.
    X=Obj[ROOT].X()+Obj[ROOT].BorderWidth();
    Y=Obj[ROOT].Y()+Obj[ROOT].BorderWidth();
    w=Obj[ROOT].Width()-2*Obj[ROOT].BorderWidth();
    h=Obj[ROOT].Height()-2*Obj[ROOT].BorderWidth();
  }

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
  wind_update(BEG_MCTRL);

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

  GEMevent event;

  while (NowWhat!=EndInteraction) {
    // The guts of the interaction is virtual
    exitor=FormDo(event);

    // But the response handling is not... until the DoItem().
    if (exitor != -1) {
      exitor&=0x7fff; // Ignore the "TOUCHEXIT double click" bit for now.

      NowWhat=DoItem(exitor,event);

      if (NowWhat==IgnoredClick && (Obj[exitor].Exit() || Obj[exitor].TouchExit()))
        NowWhat=EndInteraction;

      if (Obj[exitor].Exit()) {
        Obj[exitor].Deselect();
        if (NowWhat!=EndInteraction) {
          RedrawObject(exitor);
        }
      }
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

  wind_update(END_MCTRL);
  wind_update(END_UPDATE);

  v_clsvwk(vdihandle);
  vdihandle=-1;

  open--;

  return exitor;
}

void GEMform::RedrawObject(int RSCindex)
{
  if (IsOpen()) {
    objc_draw(Obj, RSCindex, MAX_DEPTH, 0, 0, SHRT_MAX, SHRT_MAX);
  }
}

void GEMform::RedrawObjectFromRoot(int RSCindex)
{
  int X,Y;
  objc_offset(Obj,RSCindex,&X,&Y);
  RedrawObject(ROOT,X-Obj[ROOT].X(),Y-Obj[ROOT].Y(),Obj[RSCindex].Width(),Obj[RSCindex].Height());
}


void GEMform::RedrawObject (int RSCindex, const GRect& area)
{
  if (IsOpen ()) {
    int xywh[4];
    area.GetRect (xywh);
    RedrawObject (RSCindex, xywh[0], xywh[1], xywh[2], xywh[3]);
  }
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
  int tmp = RSCfrom;    // Initialize to impossible value

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

// Static members.
int GEMform::global_count (0);
GEMrawobject* GEMform::global_obj (0);

