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

// A GEMscreen is a (visible area) of the display that can be manipulated
// just like a GRect.  But whereas a GRect is an abstract construct a
// GEMscreen is a visible object and whenever it makes sense you can
// see the results of your manipulations on the screen.  Well, it actually
// only makes sense if you move the GEMscreen around on the screen.
//
// Internally the underlying GRect is transformed into an int array and
// the ro_cpyfm method of the included VDI object is called.
//
// Maybe VDIraster would have been a better name for this class and if
// you agree then the class should have been derived both from GRect and
// from an MFDB.  However, this class covers only a very restricted, yet
// very commonly used part of the VDI's raster functionality.  A GEMscreen
// is ALWAYS part of the visible screen, rasters are always copied opaque,
// you can't copy a raster to an area outside of the screen and so on.
// 

#ifndef _GEMscreen_h
#define _GEMscreen_h

#ifndef _LIBGEMPP
#include <grect.h>
#include <vdi++.h>
#else
#include "aesext.h"
#include "vdi++.h"
#endif

class GEMscreen : public GRect
{
public:
  // Constructors.
  GEMscreen(VDI& vdi, int mode = S_ONLY);
  GEMscreen (VDI& vdi, int x, int y, int w, int h, int mode = S_ONLY);
  GEMscreen (VDI& vdi, int xy[4], int mode = S_ONLY);

  // Destructive methods.
  virtual GEMscreen& MoveAbs (int x, int y);
  virtual GEMscreen& MoveRel (int xOffset, int yOffset);
  virtual GEMscreen& MoveLeft (int xOffset = 1);
  virtual GEMscreen& MoveRight (int xOffset = 1);
  virtual GEMscreen& MoveUp (int yOffset = 1);
  virtual GEMscreen& MoveDown (int yOffset = 1);
  
  // Destructive operations.
  virtual GEMscreen& Center (const GEMscreen& reference);

protected:
  // Derived classes may wish to overload this method.
  virtual void Copy (int mode, int pxyarray[8]);
  virtual VDI& GetVDI () { return Vdi; }
  
private:
  VDI& Vdi;
  int copymode;
};
#endif
