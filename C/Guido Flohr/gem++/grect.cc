// GEM++.
// Copyright (C) 1992, 1993 by Andre Pareis <pareis@cs.tu-berlin.de>
//                               <subiaagb@w271zrz.zrz.tu-berlin.de>
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

#include "aesext.h"
#include "grect.h"
#include "yd.h"

///////////////////
// Constructors
///////////////////

GRect::GRect (int x, int y, int w, int h)
{
  g_x = x;
  g_y = y;
  g_w = w;
  g_h = h;
}

GRect::GRect (int xy[4])
{
  g_x = xy[0];
  g_y = xy[1];
  g_w = xy[2] - xy[0] + 1;
  g_h = xy[3] - xy[1] + 1;
}

////////////////////////////////////////////////////////////////////////
// Public methods
////////////////////////////////////////////////////////////////////////

GRect& GRect::SetRect (int x, int y, int w, int h)
{
  g_x = x;
  g_y = y;
  g_w = w;
  g_h = h;
  
  return *this;
}

GRect& GRect::SetRect (int xywh[4])
{
  g_x = xywh[0];
  g_y = xywh[1];
  g_w = xywh[2] - xywh[0] + 1;
  g_h = xywh[3] - xywh[1] + 1;
  
  return *this;
}

GRect& GRect::MoveAbs (int x, int y)
{
  g_x = x;
  g_y = y;
  
  return *this;
}

GRect& GRect::MoveRel (int xOffset, int yOffset)
{
  g_x += xOffset;
  g_y += yOffset;
  
  return *this;
}

GRect& GRect::PressLeft (int xOffset)
{
  g_x += xOffset;
  g_w -= xOffset;
  
  return *this;
}

GRect& GRect::PressRight (int xOffset)
{
  g_w -= xOffset;
  
  return *this;
}

GRect& GRect::PressTop (int yOffset)
{
  g_y += yOffset;
  g_h -= yOffset;
  
  return *this;
}

GRect& GRect::PressBottom (int yOffset)
{
  g_h -= yOffset;
  
  return *this;
}

GRect& GRect::Resize (int w, int h)
{
  g_w = w;
  g_h = h;
  
  return *this;
}

void GRect::GetRect (int& x, int& y, int& w, int& h) const
{
  x = g_x;
  y = g_y;
  w = g_w;
  h = g_h;
}

void GRect::GetRect (int xywh[4]) const
{
  xywh[0] = g_x;
  xywh[1] = g_y;
  xywh[2] = g_w;
  xywh[3] = g_h;
}

GRect& GRect::Clip (const GRect& b)
{
  Absolute ();
  GRect border = Absolute (b);
  
  int g_x2 = g_x + g_w;
  int g_y2 = g_y + g_h;
  if (g_x < border.g_x)
    g_x = border.g_x;
  if (g_y < border.g_y)
    g_y = border.g_y;
  int bg_x2 = border.g_x + border.g_w;
  int bg_y2 = border.g_y + border.g_h;
  if (g_x2 > bg_x2)
    g_x2 = bg_x2;
  if (g_y2 > bg_y2)
    g_y2 = bg_y2;
  g_w = g_x2 - g_x;
  g_h = g_y2 - g_y;
  
  if (g_w < 0)
    g_w = 0;
  if (g_h < 0)
    g_h = 0;
    
  return *this;
}

GRect GRect::Intersect (const GRect& o)
{
  GRect retval = *this;
  retval.Clip (o);  
  return retval;
}

GRect& GRect::Constrain (const GRect& border)
{
  g_x = border.g_x;
  g_y = border.g_y;

  if (g_w > border.g_w)
    g_x = border.g_x + (border.g_w - g_w) / 2;
  
  if (g_h > border.g_h)
    g_y = border.g_y + (border.g_h - g_h) / 2;

  return *this;
}

GRect& GRect::Center (const GRect& reference)
{
  g_x = reference.g_x + (reference.g_w - g_w) / 2;
  g_y = reference.g_y + (reference.g_h - g_h) / 2;
  return *this;
}

GRect& GRect::Combine (const GRect& i)
{
  Absolute ();
  GRect inner = Absolute (i);
  
  g_x = g_x < inner.g_x ? g_x : inner.g_x;
  g_y = g_y < inner.g_y ? g_y : inner.g_y;
  
  int g_x2 = g_x + g_w;
  int g_y2 = g_y + g_h;
  int ig_x2 = inner.g_x + inner.g_w;
  int ig_y2 = inner.g_y + inner.g_h;

  g_x2 = ig_x2 > g_x2 ? ig_x2 : g_x2;
  g_y2 = ig_y2 > g_y2 ? ig_y2 : g_y2;
  
  g_w = g_x2 - g_x;
  g_h = g_y2 - g_y;

  return *this;
}

GRect& GRect::Absolute ()
{
  if (g_w < 0) {
    g_w = -g_w;
    g_x -= g_w;
  }
  if (g_h < 0) {
    g_h = -g_h;
    g_y -= g_h;
  }
  return *this;
}

GRect GRect::Absolute (const GRect& o) const
{
  GRect ret = o;
  ret.Absolute ();
  return ret;
}

GRect& GRect::Positive ()
{
  if (g_w < 0)
    g_w = 0;
  if (g_h < 0)
    g_h = 0;
  return *this;
}

GRect GRect::Positive (const GRect& o) const
{
  GRect ret = o;
  ret.Positive ();
  return ret;
}

GRect& GRect::Negative ()
{
  if (g_w > 0)
    g_h = 0;
  if (g_w > 0)
    g_h = 0;
  return *this;
}

GRect GRect::Negative (const GRect& o) const
{
  GRect ret = o;
  ret.Negative ();
  return ret;
}

GRect&  GRect::Scale(int hscale, int vscale)
{
  g_x*=hscale;
  g_w*=hscale;
  g_y*=vscale;
  g_h*=vscale;

  return *this;
}

GRect::operator int () const
{
  int retval = g_w * g_h;
  return (retval > 0 ? retval : -retval);
}

GRect::operator int* () const 
{
  xy[0] = g_x;
  xy[1] = g_y;
  xy[2] = g_x + g_w - 1;
  xy[3] = g_y + g_h - 1;
  return xy;
}

int GRect::operator [] (int i) const 
{
  switch (i) {
    case 0:
      return g_x;
    case 1:
      return g_y;
    case 2:
      return (g_x + g_w - 1);
    case 3:
      return (g_y + g_h - 1);
    default:
      return 0;  // Any better idea?
  }
}

const GRect GRect::operator+ (const GRect& add) const
{
  GRect ret = *this;
  ret.Combine (add);
  return ret;
}

const GRect GRect::operator& (const GRect& other) const
{
  GRect ret = *this;
  ret.Clip (other);
  return ret;
}

const GRect& GRect::operator+= (const GRect& add)
{
  Combine (add);
  return *this;
}

const GRect& GRect::operator&= (const GRect& other)
{
  Clip (other);
  return *this;
}

void GRect::Dump (const char* name, ostream& out) const
{
#ifdef DEBUG	// kde je vlastne definovan ostream operator<< ?
  out << name << ".g_x = " << g_x << '\n'
      << name << ".g_y = " << g_y << '\n'
      << name << ".g_w = " << g_w << '\n'
      << name << ".g_h = " << g_h << endl;
#endif
}
