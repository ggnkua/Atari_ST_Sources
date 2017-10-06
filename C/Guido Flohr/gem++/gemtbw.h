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

#ifndef GEMtbw_h
#define GEMtbw_h

#ifndef _LIBGEMPP
#include <gemw.h>
#include <gemr.h>
#include <gema.h>
#include <gemo.h>
#include <gemro.h>
#include <grect.h>
#include <bool.h>
#include <gemfast.h>
#include <aesext.h>
#else
#include "gemw.h"
#include "gemr.h"
#include "gema.h"
#include "gemo.h"
#include "gemro.h"
#include "grect.h"
#include "bool.h"
#include "gemfast.h"
#include "aesext.h"
#endif

class GEMtoolbarwindow : public GEMwindow
{
public:
  GEMtoolbarwindow (GEMactivity& in, int Parts, const GEMrsc& r, int RSCindex);
  GEMtoolbarwindow (GEMactivity& in, int Parts, const GEMrsc& r, int RSCindex, 
       const GRect& actWorkArea);
  GEMtoolbarwindow (GEMactivity& in, int Parts, const GEMrsc& r, int RSCindex, 
       const GRect& actWorkArea, const GRect& maxWorkArea);

  virtual bool Create();
  
  bool Fake () { return ToolBarFake; }
  void Fake (bool yesno);
  
protected:
  virtual void Redraw (GRect& area);
  
  virtual GRect Work2Win (const GRect& work) const;
  virtual GRect Win2Work (const GRect& outer) const;
  
private:
  const GEMrsc& rsc;
  GEMactivity& act;
  GEMform form;
  GEMobject object;
  GEMrawobject* rawobject;
  bool ToolBarFake;
};

#endif
