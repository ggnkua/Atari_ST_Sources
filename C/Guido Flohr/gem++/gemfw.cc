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
  GEMwindow(act,CLOSER|MOVER|NAME|SMALLER), GEMform(in, RSCindex),
  rubberwidth(false),
  rubberheight(false),
  touched_object(-1),
  edit_object(-1)
{
  GRect workArea=WorkRect();
  form_center (Obj, &workArea.g_x, &workArea.g_y, &workArea.g_w, &workArea.g_h);

  SetWorkRect(workArea);

#ifdef ALIGN_FORMWINDOWS
  // Not necessary with WINX
  Align(0,0,2,2); // For simple shade patterns (complex ones require 4x4)
#endif

  ButtonEventFlags(1);
}

GEMformwindow::GEMformwindow(GEMactivity& act, const GEMrsc& in, int RSCindex, int Parts) :
  GEMwindow(act,Parts), GEMform(in, RSCindex),
  rubberwidth(bool(Parts&SIZER && !(Parts&HSLIDE))),
  rubberheight(bool(Parts&SIZER && !(Parts&VSLIDE))),
  touched_object(-1),
  edit_object(-1)
{
  GRect workArea=WorkRect();

  form_center (Obj, &workArea.g_x, &workArea.g_y, &workArea.g_w, &workArea.g_h);

  // Assumes ColumnWidth() and LineHeight() are 1.
  SetTotalColumns(Obj[ROOT].Width());
  SetTotalLines(Obj[ROOT].Height());

  SetWorkRect(workArea);

#ifdef ALIGN_FORMWINDOWS
  // Not necessary with WINX
  Align(0,0,2,2); // For simple shade patterns (complex ones require 4x4)
#endif

  SetVisibleColumns((WorkRect ()).g_w);
  SetVisibleLines((WorkRect ()).g_h);

  ButtonEventFlags(1);
}

GEMformwindow::GEMformwindow(const GEMformwindow& copy) :
  GEMwindow(copy), GEMform(copy),
  rubberwidth(copy.rubberwidth),
  rubberheight(copy.rubberheight),
  touched_object(-1),
  edit_object(-1)
{
  // GEMwindow is exactly the same, except position changes slightly.
  const GRect& pos = WorkRect();
  Obj[ROOT].MoveTo(pos.g_x,pos.g_y);
}

static
bool GetKey(GEMevent& event)
// Modal.  Menu bar is not active while getting keys.
// Returns false if non-key event arrives.
{
  wind_update(BEG_MCTRL);

  event.Get(MU_KEYBD|MU_BUTTON);

  wind_update(END_MCTRL);

  return event.Keyboard();
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
  return true;
}

void GEMformwindow::SetWorkRect(const GRect& r)
// Do the normal SetWorkRect, then adjust object tree position.
{
  GEMwindow::SetWorkRect(r);
  GEMrawobject* root=&Obj[ROOT];
  GEMobject* croot=root->Cook();

  const GRect& pos=WorkRect();

  if (croot) {
    croot->MoveTo(pos.g_x-LeftColumn()*ColumnWidth(),
      pos.g_y-TopLine()*LineHeight());
    bool changed=false;
    if (rubberwidth && pos.g_w!=croot->Width()) {
      croot->SetWidth(pos.g_w);
      changed=true;
    }
    if (rubberheight && pos.g_h!=croot->Height()) {
      croot->SetHeight(pos.g_h);
      changed=true;
    }
    if (changed) {
      RedrawObject(0);
    }
  } else {
    root->MoveTo(pos.g_x-LeftColumn()*ColumnWidth(),
      pos.g_y-TopLine()*LineHeight());
  }
}

void GEMformwindow::HFlushSlider()
// Adjust object tree position.
{
  GEMwindow::HFlushSlider();
  const GRect& pos=WorkRect();
  Obj[ROOT].MoveTo(pos.g_x-LeftColumn()*ColumnWidth(),
    pos.g_y-TopLine()*LineHeight());
}

void GEMformwindow::VFlushSlider()
// Adjust object tree position.
{
  GEMwindow::VFlushSlider();
  const GRect& pos=WorkRect();
  Obj[ROOT].MoveTo(pos.g_x-LeftColumn()*ColumnWidth(),
    pos.g_y-TopLine()*LineHeight());
}

static
void WaitForNoButton()
{
  int X,Y,Buttons,Metas;

  wind_update(BEG_MCTRL);
  do graf_mkstate(&X,&Y,&Buttons,&Metas); while (Buttons);
  wind_update(END_MCTRL);
}


// Any point in making this a method of GEMobjects?
static
void WatchBox(GEMform& form, int O)
{
  int X,Y,Buttons,Metas;
  int x,y,w=form[O].Width(),h=form[O].Height();
  objc_offset(&form[0],O,&x,&y);
  bool OldOn=form[O].Selected();
  bool On=false;

  wind_update(BEG_MCTRL);

  do {
    graf_mkstate(&X,&Y,&Buttons,&Metas);
    On = X>=x && X<x+w && Y>=y && Y<y+h;
    if (On!=OldOn) {
      OldOn=On;
      form[O].Selected(On);
      form.RedrawObject(O);
    }
  } while (Buttons);

  wind_update(END_MCTRL);
}

static
int FindEditable(GEMrawobject *Obj, int Object, int way)
{
  int c=Object+way;

  while (1) {
    if (c<0) while (!(Obj[++c].LastObject()));
    else if (Obj[c].Editable()) return c;
    else if (c==Object) return -2; // None ANYWHERE
    else if (Obj[c].LastObject() && way>0) c=0;
    else c+=way;
  }
}


void GEMformwindow::Edit(int obj, int index)
{
  GEMobject* edo=Obj[obj].Cook();

  if (!edo) {
    // Dumb object - must be edited modally

    if (edit_object>=0) Obj[edit_object].InFocus(false);

    // objc_edit(Obj,obj,0,index,EDINIT,&index);
    objc_edit(Obj,obj,0,&index,EDINIT);

    WaitForNoButton();

    while (!edo) {
      GEMevent event;

      if (!GetKey(event)) {
        // objc_edit(Obj,obj,0,index,EDEND,&index);
        objc_edit(Obj,obj,0,&index,EDEND);
        edit_object=-1;
        return; // No more editing.
      }

      switch (event.Key()>>8) {
       case KEY_RETURN:
        // objc_edit(Obj,obj,0,index,EDEND,&index);
        objc_edit(Obj,obj,0,&index,EDEND);
        return;
      break;  case KEY_UP:
        // objc_edit(Obj,obj,0,index,EDEND,&index);
        objc_edit(Obj,obj,0,&index,EDEND);
        obj=FindEditable(Obj,obj,-1);
        edo=Obj[obj].Cook();
        // if (!edo) objc_edit(Obj,obj,0,index,EDINIT,&index);
        if (!edo) objc_edit(Obj,obj,0,&index,EDINIT);
      break;  case KEY_DOWN: case KEY_TAB:
        // objc_edit(Obj,obj,0,index,EDEND,&index);
        objc_edit(Obj,obj,0,&index,EDEND);
        obj=FindEditable(Obj,obj,+1);
        edo=Obj[obj].Cook();
        // if (!edo) objc_edit(Obj,obj,0,index,EDINIT,&index);
        if (!edo) objc_edit(Obj,obj,0,&index,EDINIT);
      break;  default:
        // objc_edit(Obj,obj,event.Key(),index,EDCHAR,&index);
        objc_edit(Obj,obj,event.Key(),&index,EDCHAR);
        DoItem(obj,event); // XXX SHOULD BE IN GEMobject
      }
    }

    edo->InFocus(true);
    edit_object=obj;
  } else {
    if (edit_object!=obj) {
      if (edit_object>=0) Obj[edit_object].InFocus(false);
      edo->InFocus(true);
      edit_object=obj;
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

    GEMrawobject &O=Object(o);

    if (!O.Disabled()) {
      if (O.TouchExit())
        result=DoItem(o,e);

      if (O.RadioButton()) {
        if (!O.Selected()) {
          int p=Parent(o);
          int c=Obj[p].Head();
          while (c!=p) {
            GEMrawobject& P=Object(c);
            if (P.Selected() && P.RadioButton()) {
              P.Deselect();
              RedrawObject(c);
            }
            c=Obj[c].Next();
          }
          O.Select();
          RedrawObject(o);

          result=DoItem(o,e);

          if (result==IgnoredClick) result=ContinueInteraction;
        } else 
          result=ContinueInteraction;
      } else {
        if (O.Selectable() && !O.Exit()) {
          if (O.Selected()) O.Deselect();
          else O.Select();
          RedrawObject(o);

          result=DoItem(o,e);
          if (result==IgnoredClick) result=ContinueInteraction;
          WaitForNoButton();
        }
      }

      if (O.Editable()) {
        Edit(o,1/* Column */);
        result=ContinueInteraction;
      }

      if (O.Exit()) {
        result=ContinueInteraction;
        if (O.Selectable()) {
          bool was_selected=O.Selected();
          WatchBox(*this,o);
          if (O.Selected() != was_selected) {
            O.Deselect();
            result=DoItem(o,e);
            if (result==IgnoredClick) result=ContinueInteraction;
            RedrawObject(o);
          }
        } else {
          WaitForNoButton();
        }
      }
    }
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
  wind_calc(1,Parts(),xoffset,yoffset,50,50,&x,&y,&j,&j);

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

int GEMformwindow::ClipTrackingRectangle(int x, int y, GRect& rect)
{
  if (GEMwindow::ClipTrackingRectangle(x,y,rect)) {
    // It's in the work area... but which object?
    int cursor=objc_find(Obj,ROOT,MAX_DEPTH,x,y);
    while (cursor>=0) {
      GRect work;
      objc_offset(Obj,cursor,&work.g_x,&work.g_y);
      work.g_w=Obj[cursor].Width();
      work.g_h=Obj[cursor].Height();
      if (GEMwindow::ClipTrackingRectangle(work,x,y,rect)) {
        // Go down to children
        cursor=Obj[cursor].Head();
      } else {
        // Go across to other children
        int newcursor=Obj[cursor].Next();
        if (Obj[newcursor].Tail()==cursor) newcursor=-1; // End of children
        cursor=newcursor;
      }
    }
    return 1;
  } else {
    return 0;
  }
}

void GEMformwindow::MousePosition(const GEMevent& ev)
{
  if (edit_object==-1) {
    // May set to -2 -> No edit now, no edit ever.
    // If this is no good, need someway to flag that something
    // has become editable - checking here too often is expensive.
    edit_object=FindEditable(Obj,0,1);
  }
  GEMwindow::MousePosition(ev);
  int hot=objc_find(Obj,ROOT,MAX_DEPTH,ev.X(),ev.Y());
  ObjectTouched(hot);
}

void GEMformwindow::MousePositionOff()
{
  GEMwindow::MousePositionOff();
  ObjectTouched(-1);
}

void GEMformwindow::ObjectTouched(int obj)
{
  // Maybe ignore if obj==touched_object?
  // If so, have to set touched_object to -1 on close, etc.

  GEMobject* o=Obj[touched_object].Cook();

  // Out of this object...
  if (o && o->Hot()) {
    GEMevent ev;
    ev.Rectangle(0,0,0,0,true);
    ev.Which(MU_M1);
    o->Touch(0,0,ev);
  }

  touched_object=obj;
  o=Obj[touched_object].Cook();

  // Into this object...
  if (o && o->Hot()) {
    GEMevent ev;
    ev.Rectangle(0,0,0,0,false);
    ev.Which(MU_M1);
    o->Touch(0,0,ev);
  }
}

GEMfeedback GEMformwindow::Key(const GEMevent& ev)
{
  if (edit_object) {
    GEMobject* edo=Obj[edit_object].Cook();
    if (edo) {
      if (edo->Editable()) return edo->Touch(0,0,ev);
    } else {
      // YIKES!  It slipped away!
      Edit(edit_object,1);
      return ContinueInteraction;
    }
  }
  return IgnoredClick;
}

void GEMformwindow::InFocus(bool yes)
{
  if (edit_object) {
    GEMobject* edo=Obj[edit_object].Cook();
    if (edo) {
      edo->InFocus(yes);
    } else {
      // YIKES!  It slipped away!
      edit_object=-1;
    }
  }
}
