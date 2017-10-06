// GEM++.
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

// A GEMprotocol is an abstract for arbitrary protocols that are processed
// via the message pipelining facilities of the AES.  The class GEMprotocol 
// is a virtual base class since the Dispatch method is not defined.
// 
// The base class will register and unregister itself in the associated 
// GEMactivity inside the constructor resp. destructor call.  The GEMactivity
// will then call the virtual Dispatch method of your implementation.
// The Dispatch method should return one of the GEMfeedback enumerations
// IgnoredClick, ContinueInteraction, or EndInteraction.
//
// The default for your protocol should be IgnoredClick. This will cause
// the GEMapplication to call the other registered protocols' Dispatch
// method.
//
// If you return ContinueInteraction, the activity will also proceed but
// it won't call the Dispatch method for protocols with lower priority.
//
// Returning EndInteraction will stop the user interaction for this
// activity and will normally lead to program termination.
//
// Of course the GEMactivity has to call the dispatchers in a certain
// order.  The protocol that has been registered first will be served
// first.  This order can be changed by derived classes any time by
// calling the Priority methods.
//
// If you choose to employ the classes priority mechanism you should
// be aware of that priorities and pointers to preceding and succeeding
// protocols may arbitrarily change in unexpected situations.  You
// should employ double care for that fact in multi-threaded applications. 
//
// AES messages that shouldn't be redefined will never be passed thru
// to protocols.  The messages that I consider generic are:  MN_SELECTED,
// WM_REDRAW, WM_TOPPED, WM_CLOSED, WM_FULLED, WM_ARROWED, WM_HSLID,
// WM_VSLID, WM_SIZED, WM_MOVED, WM_NEWTOP, WM_UNTOPPED, WM_ONTOP,
// WM_BOTTOMED, WM_ICONIFY, WM_UNICONIFY, WM_SHADED, WM_UNSHADED, AC_OPEN,
// AC_CLOSE and WM_TOOLBAR.  You have access to these messages in other
// GEM++ classes.
//
// Maybe you miss some of messages in the "forbidden" list.  WM_ALLICONIFY
// might be a candidate.  But an application should decide itself 
// how to react to a WM_ALLICONIFY message.  A small tool may decide
// to terminate, some programs may have a reason to ignore this message
// and others will react the way they're supposed to.  The derived class
// GEMbaseprotocol provides defaults for all of these messages.  In the
// declaration and definition of this class you will also get an idea
// on how to implement other protocols.

#ifndef _GEMprot_h
#define _GEMprot_h

#include <limits.h>

#ifndef _LIBGEMPP
#include <geme.h>
#include <gemfb.h>
#include <bool.h>
#else
#include <geme.h>
#include "gemfb.h"
#include "bool.h"
#endif

class GEMactivity;

class GEMprotocol
{
public:
  GEMprotocol (GEMactivity& in, int priority_request = INT_MAX);
  
  // FIXME: Allow derived classes access to the RemoveProtocol method
  // of GEMapplication.
  virtual ~GEMprotocol ();
  
  // The Dispatch method is the interface to the AES message pipes.  See
  // the prologue for an interpration of possible return values.
  // Remember that EVERY non-generic AES message received by the
  // GEMactivity will be passed to EVERY registered protocol until
  // one will return either ContinueInteraction or EndInteraction.  If
  // you implement a whole bunch of protocols in your activity and
  // the messages defined by your protocol are within a certain range
  // you should consider to do a superficial check before actually
  // processing a message.  
  virtual GEMfeedback Dispatch (const GEMevent& event) = 0;
  
  // Inquire the protocol's current priority.  Note that this value may 
  // be changed behind your back whenever another protocol with a higher 
  // priority gets registered.  If you want to avoid this, you should set 
  // a lock for your protocol.  This will still fail if a protocol of higher 
  // priority places one of its buddies in front of you... (see the Promote 
  // method below).
  //
  // IMPORTANT: A priority level of 0 signifies top priority and the
  // higher the return value the lower the priority of your protocol!
  // Use the overloaded comparison operators and you'll be able to think
  // in normal ways again.
  int Priority () const { return priority; }
  
  // Inquire the maximum priority your protocol can promote itselft to.
  int MaximumPriority ();
  
  // Lock or unlock your current priority.  Locking your priority will
  // prevent other protocols to overtake you.
  void LockPriority (bool yes) { lock = yes; }
  
  // Return current lock state.
  bool Locked () { return lock; }
  
  // Set priority to PRIORITY_REQUEST.  The method returns the priority
  // actually assigned.  Decreasing your own priority should always work.
  int Priority (int priority_request);
  
  // One GEMprotocol of high priority can be a vehicle for the promotion
  // of another protocol.  The Promote method will try to promote the
  // buddy protocol to the requested priority by lending its own permissions
  // to the buddy.  Note that a protocol may even promote a buddy to
  // a higher priority than its own one.  This method will also allow you
  // to make a preceder protocol inherit the priority of its elder by
  // promoting it to the current priority and then destroying the elder
  // object. The method returns -1 if the buddy isn't registered in
  // the objects GEMactivity otherwise the priority actually assigned.
  int Promote (GEMprotocol* buddy, int priority_request);
  
  // We should make friends with the GEMactivity class to give it access
  // to our protected traversal methods.
  friend class GEMactivity;

  // Overloaded operators.  They negate the comparison between the
  // two priorities thus making the world in order again:  The GEMprotocol
  // with top priority is "bigger" than the GEMprotocol with the
  // lowest priority.
  inline bool operator>  (const GEMprotocol& other) const;
  inline bool operator>= (const GEMprotocol& other) const;
  inline bool operator<  (const GEMprotocol& other) const;
  inline bool operator<= (const GEMprotocol& other) const;
  inline bool operator== (const GEMprotocol& other) const;
  
  // Communications interface.
  bool Send (const char* partner, int* msg, int length = 16, 
             int sender_id = -1) const;
  bool Send (int partner_id, int* msg, int length = 16, 
             int sender_id = -1) const;
  int FindApplication (const char* name) const;
  
  // Utility methods.
  void ConvertAESName (char* name) const;
  void str2int (int i[], const char c[], size_t length = 0);
  void int2str (char c[], const int i[], size_t length = 0);
  
protected:
  GEMprotocol* Next () const { return next; }
  GEMprotocol* Prev () const { return prev; }
  
private:
  GEMactivity& act;
  int priority;
  bool lock;
  GEMprotocol* next;
  GEMprotocol* prev;
  
  GEMprotocol (const GEMprotocol&);      // No copying.
  void operator= (const GEMprotocol&);   // No assignement.
};

class AESprotocol : public GEMprotocol
{
public:
  AESprotocol (GEMactivity& in, int priority_request = INT_MAX) :
    GEMprotocol (in, priority_request),
    ApTermDefault (EndInteraction),
    ApReschgDefault (EndInteraction),
    ApTfailDefault (IgnoredEvent),
    ChExitDefault (IgnoredEvent),
    CtKeyDefault (IgnoredEvent),
    ReschgCompletedDefault (IgnoredEvent),
    ScChangedDefault (IgnoredEvent),
    ShWdrawDefault (IgnoredEvent),
    ShutCompletedDefault (IgnoredEvent),
    SmMSpecialDefault (IgnoredEvent),
    WmAlliconifyDefault (IgnoredEvent)
      {}

  virtual GEMfeedback Dispatch (const GEMevent& event);

  virtual void DefaultFeedback (const GEMfeedback fb);
  
  void SetApTermDefault (const GEMfeedback fb) { ApTermDefault = fb; }
  void SetApReschgDefault (const GEMfeedback fb) { ApReschgDefault = fb; }
  void SetApTfailDefault (const GEMfeedback fb) { ApTfailDefault = fb; }
  void SetApAestermDefault (const GEMfeedback fb) { ApAestermDefault = fb; }
  void SetChExitDefault (const GEMfeedback fb) { ChExitDefault = fb; }
  void SetCtKeyDefault (const GEMfeedback fb) { CtKeyDefault = fb; }
  void SetReschgCompletedDefault (const GEMfeedback fb) { ReschgCompletedDefault = fb; }
  void SetScChangedDefault (const GEMfeedback fb) { ScChangedDefault = fb; }
  void SetShWdrawDefault (const GEMfeedback fb) { ShWdrawDefault = fb; }
  void SetShutCompletedDefault (const GEMfeedback fb) { ShutCompletedDefault = fb; }
  void SetSmMSpecialDefault (const GEMfeedback fb) { SmMSpecialDefault = fb; }
  void SetWmAlliconifyDefault (const GEMfeedback fb) { WmAlliconifyDefault = fb; }
  
protected:
  virtual GEMfeedback ApTerm (const GEMevent&) { return ApTermDefault; }
  virtual GEMfeedback ApReschg (const GEMevent&) { return ApReschgDefault; }
  virtual GEMfeedback ApTfail (const GEMevent&) { return ApTfailDefault; }
  virtual GEMfeedback ApAesterm (const GEMevent&) { return ApAestermDefault; }
  virtual GEMfeedback ChExit (const GEMevent&) { return ChExitDefault; }
  virtual GEMfeedback CtKey (const GEMevent&) { return CtKeyDefault; }
  virtual GEMfeedback ReschgCompleted (const GEMevent&) { return ReschgCompletedDefault; }
  virtual GEMfeedback ScChanged (const GEMevent&) { return ScChangedDefault; }
  virtual GEMfeedback ShWdraw (const GEMevent&) { return ShWdrawDefault; }
  virtual GEMfeedback ShutCompleted (const GEMevent&) { return ShutCompletedDefault; }
  virtual GEMfeedback SmMSpecial (const GEMevent&) { return SmMSpecialDefault; }
  virtual GEMfeedback WmAlliconify (const GEMevent&) { return WmAlliconifyDefault; }

private:
  GEMfeedback ApTermDefault;
  GEMfeedback ApReschgDefault;
  GEMfeedback ApTfailDefault;
  GEMfeedback ApAestermDefault;
  GEMfeedback ChExitDefault;
  GEMfeedback CtKeyDefault;
  GEMfeedback ReschgCompletedDefault;
  GEMfeedback ScChangedDefault;
  GEMfeedback ShWdrawDefault;
  GEMfeedback ShutCompletedDefault;
  GEMfeedback SmMSpecialDefault;
  GEMfeedback WmAlliconifyDefault;
};

inline bool GEMprotocol::operator> (const GEMprotocol& other) const
{
  return (priority <= other.priority);
}

inline bool GEMprotocol::operator>= (const GEMprotocol& other) const
{
  return (priority < other.priority);
}

inline bool GEMprotocol::operator< (const GEMprotocol& other) const
{
  return (priority >= other.priority);
}

inline bool GEMprotocol::operator<= (const GEMprotocol& other) const
{
  return (priority > other.priority);
}

inline bool GEMprotocol::operator== (const GEMprotocol& other) const
{
  return (priority == other.priority);
}

#endif
