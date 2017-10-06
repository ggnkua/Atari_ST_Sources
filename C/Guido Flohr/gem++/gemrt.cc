#include "aesbind.h"
#include "bool.h"
#include "gemfb.h"
#include "gema.h"
#include "gempa.h"
#include "geme.h"
#include "grect.h"
#include "gemw.h"
#include "gemrt.h"
#include "geminfo.h"

#ifdef SHOW_RECT // Debugging tool
#include "vdi++.h"
#include "vdidef.h"
#endif

GEMrectangletracker::GEMrectangletracker(GEMactivity& in) :
  act(in),
  prev_x(-1)
{
  act.SetRectangleTracker(this);
}

GEMrectangletracker::~GEMrectangletracker()
{
  act.SetRectangleTracker(0); // XXX There can be only one.
}

#ifdef SHOW_RECT
static int pxy[10];
#endif

void GEMrectangletracker::CalculateRectangles(GEMevent& ev)
{
  // Start with full root window, clip down from there.

  GEMinfo Info;
  GRect rect = Info.Desktop ();

  for (void* i=act.First(); i; act.Next(i)) {
    if (act[i].IsOpen()
     && act[i].ClipTrackingRectangle(ev.X(),ev.Y(),rect))
    {
      break; // No need to look under it.
    }
  }

  if (!rect.g_w || !rect.g_h) {
    // Minimal rectangle
    rect.g_w=1;
    rect.g_h=1;
  }

  // Wait to leave it.
  ev.Rectangle(rect.g_x,rect.g_y,rect.g_w,rect.g_h,true);

#ifdef SHOW_RECT
  VDI& vdi=DefaultVDI();
  int p[10]={
    rect.g_x,rect.g_y,
    rect.g_x+rect.g_w-1,rect.g_y,
    rect.g_x+rect.g_w-1,rect.g_y+rect.g_h-1,
    rect.g_x,rect.g_y+rect.g_h-1,
    rect.g_x,rect.g_y
  };
  pxy=p;
  vdi.swr_mode(MD_XOR);
  graf_mouse(M_OFF,0);
  vdi.pline(5,pxy);
  graf_mouse(M_ON,0);
#endif
}

GEMfeedback GEMrectangletracker::MousePosition(const GEMevent& ev)
{
  if (ev.X()!=prev_x || ev.Y()!=prev_y) { // Ignore if not moved
    prev_x=ev.X();
    prev_y=ev.Y();

    int wid=wind_find(ev.X(),ev.Y());

    for (void* i=act.First(); i && act[i].IsOpen(); act.Next(i)) {
      if (act[i].Handle()==wid) {
        act[i].MousePosition(ev);
      } else {
        act[i].MousePositionOff();
      }
    }
  }

#ifdef SHOW_RECT
  VDI& vdi=DefaultVDI();
  graf_mouse(M_OFF,0);
  vdi.pline(5,pxy);
  graf_mouse(M_ON,0);
#endif
  return ContinueInteraction;
}

