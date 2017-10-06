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

#include "geminfo.h"

#include "gemscreen.h"  // implemented here.

GEMscreen::GEMscreen (VDI& vdi, int mode) : 
  GRect (),
  Vdi (vdi),
  copymode (mode)
{
  GEMinfo Info;
  const GRect& Desktop = Info.Desktop ();
  g_x = Desktop.g_x;
  g_y = Desktop.g_y,
  g_w = Desktop.g_w;
  g_h = Desktop.g_h;
}

GEMscreen::GEMscreen (VDI& vdi, int x, int y, int w, int h, int mode) :
  Vdi (vdi),
  GRect (x, y, w, h),
  copymode (mode)
{}

GEMscreen::GEMscreen (VDI& vdi, int xy[4], int mode) : 
  Vdi (vdi),
  GRect (xy),
  copymode (mode)
{
}
 
// The central method that will be called by all other moving methods.
GEMscreen& GEMscreen::MoveAbs (int x, int y)
{
  GEMinfo Info;
  const GRect& Desktop = Info.Desktop ();
  GRect Source = Absolute (*this) & Desktop;
  GRect Dest = Source;
  Dest.MoveAbs (x, y);
  Dest &= Desktop;
  int pxyarray[8];
  memcpy (pxyarray, (int*) Source, 4 * sizeof (int));
  memcpy (pxyarray + 4, (int*) Dest, 4 * sizeof (int));
  Copy (copymode, pxyarray);
  GRect::MoveAbs (x, y);
  return (*this);
}

GEMscreen& GEMscreen::MoveRel (int xOffset, int yOffset)
{
  return (MoveAbs (g_x + xOffset, g_y + yOffset));
}

GEMscreen& GEMscreen::MoveLeft (int xOffset)
{
  return (MoveAbs (g_x - xOffset, g_y));
}

GEMscreen& GEMscreen::MoveRight (int xOffset)
{
  return (MoveAbs (g_x + xOffset, g_y));
}

GEMscreen& GEMscreen::MoveUp (int yOffset)
{
  return (MoveAbs (g_x, g_y - yOffset));
}

GEMscreen& GEMscreen::MoveDown (int yOffset)
{
  return (MoveAbs (g_x, g_y + yOffset));
}

GEMscreen& GEMscreen::Center (const GEMscreen& reference)
{
  GRect Dest = *this;
  Dest.Center (reference);
  return (MoveAbs (Dest.g_x, Dest.g_y));
}

void GEMscreen::Copy (int mode, int pxyarray[])
{
  Vdi.ro_cpyfm (mode, pxyarray);
}
