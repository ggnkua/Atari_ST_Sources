/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include <limits.h>
#include <aesbind.h>

#include "aesext.h"
#include "gemfb.h"
#include "geme.h"
#include "gempa.h"
#include "gemw.h"
#include "gemm.h"
#include "gemt.h"
#include "gemda.h"
#include "gemks.h"
#include "gemrt.h"
#include "grect.h"
#include "contract.h"
#include "scancode.h"
#include "bool.h"
#include "gema.h"
#include "gemprot.h"

GEMactivity::WL::WL(GEMwindow *wind, GEMactivity::WL *n) :
  window(wind),
  next(n),
  prev(n ? n->prev : 0)
{
  if (n) n->prev=this;
}

GEMactivity::GEMactivity() :
  winlist(0), menu(0), acc(0), timer(0), keysink(0), rectrack(0),
  firstprot (0), lastprot (0)
{ }

GEMactivity::~GEMactivity()
{ }

// XXX This is a bit of a problem.
// XXX Maybe the desktop shouldn't be a window.
//
static bool IsDesktop(GEMwindow* w)
{
  return w->IsOpen() && w->Handle()==0;
}

void GEMactivity::AddWindow(GEMwindow& w)
{
  winlist=new struct WL(&w,winlist);
}

void GEMactivity::RemoveWindow(GEMwindow& w)
{
  WL* c;
  
  for (c=winlist; c && c->window!=&w;  c=c->next)
    ;

  if (c) {
    // Cut it out
    if (c->prev) c->prev->next=c->next;
    if (c->next) c->next->prev=c->prev;
    if (c==winlist) winlist=c->next;

    delete c;
  }
}

int GEMactivity::AddProtocol (GEMprotocol* that, int priority_request)
{
  // Paranoid?
  if (!that)
    return -1;
  
  GEMprotocol* preceder = FindSlot (INT_MAX, priority_request);
  InsertAfter (preceder, that);
  return that->priority;  
}

void GEMactivity::RemoveProtocol (GEMprotocol* that)
{
  if (!that)
    return;
  if (that == firstprot)
    firstprot = that->next;
  if (that == lastprot)
    lastprot = that->prev;
    
  GEMprotocol* cursor = that->next;
  while (cursor) {
    cursor->priority--;
    cursor = cursor->next;
  }
  if (that->next)
    that->next->prev = that->prev;
  if (that->prev)
    that->prev->next = that->next;
  that->next = that->prev = NULL;
  that->priority = INT_MAX;
}

int GEMactivity::PromoteProtocol (GEMprotocol* sponsor, GEMprotocol* buddy, 
                                  int priority_request)
{
  if (!sponsor || !buddy)
    return -1;
  int permission = sponsor->priority < buddy->priority ? 
      sponsor->priority : buddy->priority;
  
  GEMprotocol* preceder = FindSlot (permission, priority_request);
  RemoveProtocol (buddy);
  InsertAfter (preceder, buddy);
  return buddy->priority;
}

void GEMactivity::InsertAfter (GEMprotocol* preceder, GEMprotocol* insert)
{
  if (!preceder) {
    // The inserted element will be the new head of the list.
    insert->prev = NULL;
    if (firstprot) {
      // There are other elements in the list.
      insert->next = firstprot->next;
      firstprot->prev = insert;
    } else {
      // Gee, this is the first AND the last element.
      insert->next = NULL;
      lastprot = insert;
    }
    insert->priority = 0;
    firstprot = insert;
    return;
  }
  if (preceder->next) {
    // If we've made it until here that means that we really insert the
    // new element.
    preceder->next->prev = insert;
  } else {
    // The inserted element will be the new tail of the list.
    lastprot = insert;
  }
  insert->next = preceder->next;
  preceder->next = insert;
  insert->prev = preceder;
  insert->priority = preceder->priority + 1;
}

GEMprotocol* GEMactivity::FindSlot (int permission, int request) {
  GEMprotocol* cursor = lastprot;
  while (cursor) {
    if (((cursor->lock) && (cursor->priority <= permission))
          || (cursor->priority > request))
        return cursor;
    cursor->priority++;
    cursor = cursor->next;
  }
  return cursor;
}

void GEMactivity::SetMenu(GEMmenu* m)
{
  menu=m;
}

void GEMactivity::SetTimer(GEMtimer* t)
{
  timer=t;
}

void GEMactivity::SetKeySink(GEMkeysink* k)
{
  keysink=k;
}

void GEMactivity::SetDeskAccessory(GEMdeskaccessory* a)
{
  acc=a;
}

void GEMactivity::SetRectangleTracker(GEMrectangletracker* rt)
{
  rectrack=rt;
}

void GEMactivity::Do()
{
  GEMfeedback res=ContinueInteraction;

  BeginDo();

  while (res != EndInteraction) {
    res=OneDo();
  }

  EndDo();
}

void GEMactivity::BeginDo()
{
  if (menu) menu->Show();

  graf_mouse(ARROW,0);
}

GEMfeedback GEMactivity::OneDo()
{
  return OneDo(0xffff); // Allow any events
}

GEMfeedback GEMactivity::OneDo(int eventmask)
{
  GEMfeedback res = ContinueInteraction;

  int get = MU_BUTTON|MU_MESAG;

  if (timer && timer->NextInterval () >= 0) {
    get |= MU_TIMER;
    event.Interval (timer->NextInterval ());
  }

  if (keysink) get |= MU_KEYBD;

  if (rectrack) {
    get |= MU_M1; // XXX Only one?  Should ask rectrack?
    rectrack->CalculateRectangles (event);
  }

  event.Get (get & eventmask);

  if (rectrack) {
    rectrack->MousePosition (event);
  }

  if (event.Keyboard ()) {
    res = keysink->Consume (event);
  }

  if (event.Timer()) {
    res = timer->ExpireNext (event);
  }

  if (event.Button()) {
    GEMwindow *win=0;
    WL* c;
    
    for (c=winlist; c && !win; c=c->next) {
      int X,Y,W,H;
      if (c->window->IsOpen()) {
        wind_get(c->window->Handle(),WF_WORKXYWH,&X,&Y,&W,&H);
        if (event.X()>=X && event.X()<X+W && event.Y()>=Y && event.Y()<Y+H)
          win=c->window;
      }
    }
    if (win) res=win->Click(event);
  }

  if (event.Message()) {
    res = PerformMessage(event);
  }

  return res;
}

void GEMactivity::EndDo()
{
  if (menu) menu->Hide();
}

GEMwindow* GEMactivity::Window(int ID) const
{
  WL* c;
  
  for (c=winlist; c && c->window->Handle()!=ID;  c=c->next)
    ;
  return c ? c->window : 0;
}

GEMactivity::WL* GEMactivity::ListWindow(int ID) const
{
  WL* c;
  
  for (c=winlist; c && c->window->Handle()!=ID;  c=c->next)
    ;
  return c;
}

void GEMactivity::Bottomed(const GEMwindow& w)
{
  // Find the window.
  WL* c;
  for (c=winlist; c && c->window!=&w;  c=c->next)
    ;

  if (c) {
    // Find the end of open windows (&& not below desktop root window)
    WL* end=c;
    while (end->next
        && !IsDesktop(end->next->window)
        && end->next->window->IsOpen())
    {
      end=end->next;
    }

    // If found and not already last.
    if (c!=end) {
      // Cut c out
      if (c->prev) c->prev->next=c->next;
      if (c->next) c->next->prev=c->prev;
      if (c==winlist) winlist=c->next;

      // Put c at end
      c->next=end->next;
      if (c->next) c->next->prev=c;
      end->next=c;
      c->prev=end;
    }
  }
}

void GEMactivity::Topped(const GEMwindow& w)
{
  // Find the window.
  WL* c;
  for (c=winlist; c && c->window!=&w;  c=c->next)
    ;

  // If found and not already first.
  if (c && c!=winlist) {
    // Cut it out.
    if (c->prev) c->prev->next=c->next;
    if (c->next) c->next->prev=c->prev;

    // Put at head.
    c->next=winlist;
    c->prev=0;
    winlist->prev=c;
    winlist=c;
  }
}






GEMfeedback GEMactivity::PerformMessage(const GEMevent& event)
{
  GEMfeedback r = ContinueInteraction;

  if (event.Message(0)==MN_SELECTED && menu) {
    return menu->Select(event);
  } else if (event.Message(0)==AC_OPEN) {
    if (acc) acc->Open(event);
    return ContinueInteraction;
  } else if (event.Message(0)==AC_CLOSE) {
    if (acc) acc->Close(event);
    return ContinueInteraction;
  }

  bool processed = false;
  
  GEMwindow* To=Window(event.Message(3));

  if (To) {
    GRect rect(event.Message(4),event.Message(5),event.Message(6),event.Message(7));
    switch (event.Message(0)) {
      case WM_REDRAW:
        To->RedrawOverlaps(rect);
        processed = true;
        break; 
      case WM_TOOLBAR:
        r = To->ToolbarClick (event.Message (4), event.Message (5), 
            event.Message (6));
        processed = true;
        break;
      case WM_CLOSED:  
        r=To->UserClosed();
        processed = true;
        break; 
      case WM_MOVED: 
        To->UserMoved(rect.g_x,rect.g_y);
        processed = true;
        break; 
      case WM_TOPPED:  
        To->Top(event);
        processed = true;
        break; 
      case WM_M_BDROPPED:
      case WM_BOTTOMED:  
        To->Bottom(event);
        processed = true;
        break; 
      case WM_FULLED:  
        To->UserFulled();
        processed = true;
        break; 
      case WM_ICONIFY: 
        To->UserIconified(rect);  // FIXME:
        // Should test if coordinates are really returned...
        processed = true;
        break; 
      case WM_UNICONIFY: 
        To->UserUniconified(rect);
        processed = true;
        break; 
      case WM_SIZED: 
        To->UserResized(rect.g_w,rect.g_h);
        processed = true;
        break; 
      case WM_VSLID: 
        To->VSlidered(event.Message(4));
        processed = true;
        break; 
      case WM_HSLID: 
        To->HSlidered(event.Message(4));
        processed = true;
        break; 
      case WM_ARROWED:
        switch (event.Message(4)) {
          case WA_UPLINE:
            To->LineUp();
            break; 
          case WA_DNLINE:
            To->LineDown();
            break; 
          case WA_UPPAGE:
            To->PageUp();
            break; 
          case WA_DNPAGE:
            To->PageDown();
            break; 
          case WA_LFLINE:
            To->ColumnLeft();
            break; 
          case WA_RTLINE:
            To->ColumnRight();
            break; 
          case WA_LFPAGE:
            To->PageLeft();
            break; 
          case WA_RTPAGE:
            To->PageRight();
        }
        processed = true;
    }
  }
  
  if (processed) {
    if (r == RedrawMe) {
      To->RedrawOverlaps(To->WorkRect());
      r = ContinueInteraction;
    }
  } else {
    GEMprotocol* prot = firstprot;
    while (prot) {
      GEMfeedback state = prot->Dispatch (event);
      if (state == EndInteraction)
        return state;
      else if (state == ContinueInteraction)
        break;
      prot = prot->next;
    }
  }
  
  return r;
}

GEMwindow* GEMactivity::TopWindow() const
{
  WL* c;
  
  for (c=winlist; c; c=c->next) {
    if (c->window->IsOpen()) return c->window;
  }

  return 0;
}

GEMwindow* GEMactivity::WindowUnder(const GEMwindow* find) const
{
  WL* c;
  for (c=winlist; c && c->window!=find; c=c->next) {
    // I'm searching.  I'm searching.
  }

  if (!c) return 0; // Found none.

  // Found, go to next
  c=c->next;

  for (/*keep looking*/; c; c=c->next) {
    if (c->window->IsOpen()) return c->window;
  }

  return 0;
}
