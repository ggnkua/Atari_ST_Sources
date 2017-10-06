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

// A GEMtoolbarwindow is a window with a toolbar attached to it.

#include "geminfo.h"

#include "gemtbw.h"  // Implemented here.

GEMtoolbarwindow::GEMtoolbarwindow (GEMactivity& in, int Parts, 
                                    const GEMrsc& r, int RSCindex) :
  GEMwindow (in, Parts),
  rsc (r),
  act (in),
  form (rsc, RSCindex),
  object (form, RSCindex)
{
  // After the constructor for GEMwindow has returned the window might
  // actually be above the top of the screen since it didn't take
  // the toolbar height into account.
  GEMinfo Info;
  SetMaxWorkRect (Win2Work (Info.Desktop ()));
  SetWorkRect (Win2Work (Info.Desktop ()));
  
  // Find out if we have to emulate the toolbar.
  if (Info.HasToolBar ()) {
    ToolBarFake = false;
  } else
    ToolBarFake = true;
  
  rawobject = rsc.Tree (RSCindex);
}

GEMtoolbarwindow::GEMtoolbarwindow (GEMactivity& in, int Parts, 
                                    const GEMrsc& r, int RSCindex,
                                    const GRect& actWorkArea) :
  GEMwindow (in, Parts, actWorkArea),
  rsc (r),
  act (in),
  form (rsc, RSCindex),
  object (form, RSCindex)
{
  GEMinfo Info;
  
  // Find out if we have to emulate the toolbar.
  if (Info.HasToolBar ())
    ToolBarFake = false;
  else
    ToolBarFake = true;
  
  rawobject = rsc.Tree (RSCindex);
}

GEMtoolbarwindow::GEMtoolbarwindow (GEMactivity& in, int Parts, 
                                    const GEMrsc& r, int RSCindex,
                                    const GRect& actWorkArea, 
                                    const GRect& maxWorkArea) :
  GEMwindow (in, Parts, actWorkArea, maxWorkArea),
  rsc (r),
  act (in),
  form (rsc, RSCindex),
  object (form, RSCindex)
{
  // Find out if we have to emulate the toolbar.
  GEMinfo Info;
  if (Info.HasToolBar ())
    ToolBarFake = false;
  else
    ToolBarFake = true;
 
  rawobject = rsc.Tree (RSCindex);  
}

bool GEMtoolbarwindow::Create ()
{
  if (!GEMwindow::Create ())
    return false;
    
  if (!ToolBarFake) {
    union {
      short int hilo[2];
      GEMrawobject* RawObj;
    } ToolBarAddr;
    ToolBarAddr.RawObj = rawobject;
    
    if (wind_set (Handle (), WF_TOOLBAR, ToolBarAddr.hilo[0], ToolBarAddr.hilo[1], 0, 0)
        == 0) {
      Close ();
      Delete ();
      return false;
    }    
  }
  return true;
}

void GEMtoolbarwindow::Redraw (GRect& area)
{
  if (ToolBarFake) {
    object.SetWidth ((GEMwindow::WorkRect ()).g_w);
    form.RedrawObject (area);
  }
}

GRect GEMtoolbarwindow::Work2Win (const GRect& work) const
{
  GRect retval = GEMwindow::Work2Win (work);
//  retval.g_y -= object.Height ();
//  retval.g_h += object.Height ();
  return retval;
}

GRect GEMtoolbarwindow::Win2Work (const GRect& outer) const
{
  GRect retval = GEMwindow::Win2Work (outer);
//  retval.g_y += object.Height ();
//  retval.g_h -= object.Height ();
  return retval;
}

void GEMtoolbarwindow::Fake (bool yes)
{
  GEMinfo Info;
  
  if (yes) {
    ToolBarFake = true;
    if (IsCreated ()) {
      if (Info.HasToolBar ()) {
        wind_set (Handle (), WF_TOOLBAR, 0, 0, 0, 0);
      }
    }
  } else {
    ToolBarFake = false;
    if (IsCreated ()) {
      if (Info.HasToolBar ()) {
        union {
          short int hilo[2];
          GEMrawobject* RawObj;
        } ToolBarAddr;
        ToolBarAddr.RawObj = rawobject;
    
        if (wind_set (Handle (), WF_TOOLBAR, 
            ToolBarAddr.hilo[0], ToolBarAddr.hilo[1], 0, 0) == 0) 
          Fake (false);
      }
    }
  }
}
