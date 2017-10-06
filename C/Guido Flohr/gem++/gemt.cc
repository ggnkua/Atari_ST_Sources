/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemt.h"
#include "gema.h"

GEMtimer::GEMtimer (GEMactivity& in, int millisec) :
  interval (millisec), mytime (now + interval)
{
  if (!act) (act = &in)->SetTimer (this);
  InsertInto (head);
}

GEMtimer::~GEMtimer ()
{
  if (head == this && !next) {
    act->SetTimer (0);
    act = 0;
    head = 0;
  } else {
    DeleteFrom (head);
  }
}

// Below for service provider
int GEMtimer::NextInterval ()
{
  if (head)
    return (head->mytime - now);
  else
    // WAIT A SEC!  THIS SHOULDN'T HAPPEN!
    return 1000;
}

GEMfeedback GEMtimer::ExpireNext (const GEMevent& e)
// Expire() the next GEMtimer and any equal to it.
{
  GEMfeedback result = ContinueInteraction;
  now = head->mytime;
  while (head->mytime <= now && result != EndInteraction) {
    result = head->Expire (e);
    head->mytime += head->interval + 1; // So interval==0 doesn't lock or starve 
                                        // the scheduler.
    GEMtimer* toinsert = head;
    head = head->next;
    toinsert->InsertInto (head);
  }
  return result;
}


GEMactivity* GEMtimer::act = 0;
GEMtimer* GEMtimer::head = 0;
int GEMtimer::now = 0;

void GEMtimer::InsertInto (GEMtimer*& list)
// Insert self into the given list in order of increasing mytime.
{
  if (list) {
    if (list->mytime > mytime) {
      next = list;
      list = this;
    } else {
      InsertInto (list->next);
    }
  } else {
    next = list;
    list = this;
  }
}

void GEMtimer::DeleteFrom (GEMtimer*& list)
// Delete self from the given list
{
  if (list) {
    if (list==this) {
      list = next;
    } else {
      DeleteFrom (list->next);
    }
  }
}
