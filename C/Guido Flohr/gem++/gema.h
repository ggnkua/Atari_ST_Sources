/////////////////////////////////////////////////////////////////////////////
//
//  GEMactivity
//
//  A GEMactivity is an interaction with the user through the GEM interface.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMa_h
#define GEMa_h

#ifndef _LIBGEMPP
#include <gemfb.h>
#include <geme.h>
#include <gemprot.h>
#else
#include "gemfb.h"
#include "geme.h"
#include "gemprot.h"
#endif

class GEMmenu;
class GEMdeskaccessory;
class GEMwindow;
class GEMtimer;
class GEMkeysink;
class GEMrectangletracker;

class GEMactivity
{
public:
  GEMactivity();

  virtual ~GEMactivity();

  // Standard main-loop...
  void Do();

  // Components, so you may build your own...
  void BeginDo();
  GEMfeedback OneDo();
  GEMfeedback OneDo(int eventmask);
  void EndDo();

  // These are for call by GEM* classes
  void AddWindow(GEMwindow&);
  void RemoveWindow(GEMwindow&);
  void SetMenu(GEMmenu*);
  void SetTimer(GEMtimer*);
  void SetKeySink(GEMkeysink*);
  void SetDeskAccessory(GEMdeskaccessory*);
  void SetRectangleTracker(GEMrectangletracker*);
  void Topped(const GEMwindow&);
  void Bottomed(const GEMwindow&);

  // Traverse windows

  // Iterate over windows efficiently, top to bottom.
  // nb. they're not necessarily open.
  // eg. for (void* i=act.First(); i; act.Next(i)) { act[i].... }
  void* First() const                      { return winlist; }
  void Next(void*& i) const                { i=((WL*)i)->next; }
  void Prev(void*& i) const                { i=((WL*)i)->prev; }
  // Dangerous: I (gf) would expect something else from an operator[].
  // Especially dangerous that the compiler wouldn't complain about
  // something like "act[0].Close ()".
  GEMwindow& operator[](void* i) const     { return *((WL*)i)->window; }

  // Slow versions:
  GEMwindow* TopWindow() const;
  GEMwindow* WindowUnder(const GEMwindow*) const;

private:
  GEMfeedback PerformMessage(const GEMevent&);
  struct WL {
    WL(GEMwindow *wind, WL *n);
    GEMwindow *window;
    struct WL *next;
    struct WL *prev;
  } *winlist;
  GEMwindow* Window(int ID) const;
  WL* ListWindow(int ID) const;

  GEMmenu *menu;
  GEMdeskaccessory *acc;
  GEMtimer *timer;
  GEMkeysink *keysink;
  GEMrectangletracker *rectrack;
  
  GEMprotocol* firstprot;
  GEMprotocol* lastprot;
  
  GEMprotocol* FindSlot (int permission, int request);
  void InsertAfter (GEMprotocol* before, GEMprotocol* insert);
  
  friend class GEMprotocol;
  
  int AddProtocol (GEMprotocol*, int priority);
  void RemoveProtocol (GEMprotocol*);
  int PromoteProtocol (GEMprotocol* sponsor, GEMprotocol* buddy, int priority);
  
  GEMevent event;
};

#endif
