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

#include <string.h>
#include <ctype.h>
#include <aesbind.h>

#include "gema.h"

#include "gemprot.h"  // Implemented here.

GEMprotocol::GEMprotocol (GEMactivity& in, int priority_request) :
  act (in)
{
  act.AddProtocol (this, priority_request);
  // The activity will initialize our other private members.
}

GEMprotocol::~GEMprotocol ()
{
  act.RemoveProtocol (this);
}
  
int GEMprotocol::MaximumPriority ()
{
  GEMprotocol* that = this;
  while (that->Prev ()) {
    that = that->Prev ();
    if (that->Locked ())
      return (that->Priority () - 1);
  }
  return (that->Priority ());
}

int GEMprotocol::Priority (int priority_request)
{
  return (Promote (this, priority_request));
  // Note that the GEMactivity will set our new priority level.
}

int GEMprotocol::Promote (GEMprotocol* buddy, int priority_request)
{
  return (act.PromoteProtocol (this, buddy, priority_request));
}

void GEMprotocol::str2int (int i[], const char c[], size_t length)
{
  if (length == 0)
    length = strlen (c);
  for (size_t pos = 0; pos < length; pos++)
    i[pos] = c[pos];
}

void GEMprotocol::int2str (char c[], const int i[], size_t length)
{
  if (length == 0) {
    const int* cursor = i;
    while (*cursor != 0) {
      length++;
      cursor++;
    }
  }
  for (size_t pos = 0; pos < length; pos++)
    c[pos] = i[pos];
}

void GEMprotocol::ConvertAESName (char* name) const
{
  size_t l = strlen (name);
  size_t i;
  for (i = 0; i < l && i < 8; i++)
    name[i] = toupper (name[i]);
  for (; i < 8; i++)
    name[i] = ' ';
  name[8] = '\0';  // Do we need that?
}

int GEMprotocol::FindApplication (const char* name) const
{
  char HerName[9];
  strncpy (HerName, name, 8);
  ConvertAESName (HerName);
  return (appl_find (HerName));
}

bool GEMprotocol::Send (const char* partner, int* msg, 
                        int length, int sender_id) const
{
  int partner_id = FindApplication (partner);
  if (partner_id < 0)
    return false;
  else 
    return (Send (partner_id, msg, length, sender_id));
}

bool GEMprotocol::Send (int partner_id, int* msg, 
                        int length, const int sender_id) const
{
  if (sender_id < 0)  // Find out ourselves sender's ap_id.
    msg[1] = _AESapid;
  int status = appl_write (partner_id, length, msg);
  if (status != 0)
    return true;
  else
    return false;
}

#include <iostream.h>
GEMfeedback AESprotocol::Dispatch (const GEMevent& event)
{
  GEMfeedback retval = IgnoredClick;
  switch (event.Message (0)) {
    case AP_TERM:
      return (ApTerm (event));
    case AP_RESCHG:
      return (ApReschg (event));
    case AP_TFAIL:
      return (ApTfail (event));
    case AP_AESTERM:
      return (ApAesterm (event));
    case CH_EXIT:
      return (ChExit (event));
    case CT_KEY:
      return (CtKey (event));
    case RESCH_COMPLETED:
      return (ReschgCompleted (event));
    case SC_CHANGED:
      return (ScChanged (event));
    case SH_WDRAW:
      return (ShWdraw (event));
    case SHUT_COMPLETED:
      return (ShutCompleted (event));
    case SM_M_SPECIAL:
      return (SmMSpecial (event));
    case WM_ALLICONIFY:
      return (WmAlliconify (event));
    default:
      break;
  }
  return retval;
}

void AESprotocol::DefaultFeedback (const GEMfeedback fb)
{
  SetApTermDefault (fb);
  SetApReschgDefault (fb);
  SetApTfailDefault (fb);
  SetApAestermDefault (fb);
  SetChExitDefault (fb);
  SetCtKeyDefault (fb);
  SetReschgCompletedDefault (fb);
  SetScChangedDefault (fb);
  SetShWdrawDefault (fb);
  SetShutCompletedDefault (fb);
  SetSmMSpecialDefault (fb);
  SetWmAlliconifyDefault (fb);
}

