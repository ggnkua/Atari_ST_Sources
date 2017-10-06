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

#ifndef _GRect_h
#define _GRect_h

#include <iostream.h>
#include <aesbind.h>

#ifndef _LIBGEMPP
#include <aesext.h>
#include <yd.h>
#else
#include "aesext.h"
#include "yd.h"
#endif

class GRect : public GRECT
{
public:
  // Constructors.
  GRect() {}
  GRect (int x, int y, int w, int h);
  GRect (int xy[4]);
  
  // Destructive methods.
  virtual GRect& MoveAbs (int x, int y);
  virtual GRect& MoveRel (int xOffset, int yOffset);
  virtual GRect& MoveLeft (int xOffset = 1) { g_x -= xOffset; return *this; }
  virtual GRect& MoveRight (int xOffset = 1) { g_x += xOffset; return *this; }
  virtual GRect& MoveUp (int yOffset = 1) { g_y -= yOffset; return *this; }
  virtual GRect& MoveDown (int yOffset = 1) { g_y += yOffset; return *this; }
  virtual GRect& PressLeft (int xOffset = 1);
  virtual GRect& PressRight (int xOffset = 1);
  virtual GRect& PressTop (int xOffset = 1);
  virtual GRect& PressBottom (int xOffset = 1);
  
  GRect& Resize (int w, int h);
  GRect& SetRect (int x, int y, int w, int h);
  GRect& SetRect (int xywh[4]);
  
  // Inquiry.
  void GetOrigin (int& x, int& y) const;
  void GetSize (int& w, int& h) const;
  void GetRect (int& x, int& y, int& w, int& h) const;
  void GetRect (int xywh[4]) const;
  int Contains (int x, int y) const;
  int Area () const { return ((int) *this); }
  // Ooops, this methods blows the GEM concept.  It writes the current
  // components of the object to a file (by default cerr).  It is 
  // intended to serve debugging purposes and it is very likely to
  // vanish in the future.
  void Dump (const char* name, ostream& out = cerr) const;
  
  // Destructive operations.
        GRect& Clip (const GRect& border);
        GRect& Bound (const GRect& border);
        GRect& Constrain (const GRect& border);
        GRect& Scale (int hscale, int vscale);
  virtual GRect& Center (const GRect& reference);
        GRect& Combine (const GRect& add);
        GRect& Absolute ();
        GRect& Positive ();
        GRect& Negative ();
        
        // Non-destructive versions.
        GRect  Absolute (const GRect&) const;
        GRect  Positive (const GRect&) const;
        GRect  Negative (const GRect&) const;
        GRect  Intersect (const GRect& other);  // Like Clip.
  
  // Overloaded operators.
  inline bool operator== (const GRect&) const;
  inline bool operator!= (const GRect&) const;
  
  int GRect::operator [] (int i) const; 
  
  // Addition calls the Combine method, i. e. it returns the smallest rectangle
  // that contains both argument rectangels.  Bitwise AND calls the Intersect
  // method.
  const GRect  operator+ (const GRect& other) const;
  const GRect  operator& (const GRect& other) const;
  const GRect& operator+= (const GRect& other);
  const GRect& operator&= (const GRect& other);
  
  // (Area) comparisons.
  inline bool operator> (const GRect& other) const;
  inline bool operator>= (const GRect& other) const;
  inline bool operator< (const GRect& other) const;
  inline bool operator<= (const GRect& other) const;
  inline bool operator> (const int& i) const;
  inline bool operator>= (const int& i) const;
  inline bool operator< (const int& i) const;
  inline bool operator<= (const int& i) const;
  
  // Commutations of above.
  friend inline bool operator> (const int& i, const GRect& g);
  friend inline bool operator>= (const int& i, const GRect& g);
  friend inline bool operator< (const int& i, const GRect& g);
  friend inline bool operator<= (const int& i, const GRect& g);
  
  // Typecasts.
  operator bool () const { return ((g_w != 0) || (g_h != 0)); }
  operator int () const;
  operator int* () const;
  
private:
  mutable int xy[4];
};

// Inline implementations.
inline void GRect::GetOrigin (int& x, int& y) const
{
  x = g_x;
  y = g_y;
}

inline void GRect::GetSize (int& w, int& h) const
{
  w = g_w;
  h = g_h;
}

inline int GRect::Contains (int x, int y) const
{
  GRect ref = Absolute (*this);
  return (x >= ref.g_x && y >= ref.g_y 
      && x - ref.g_x < ref.g_w && y - ref.g_y < ref.g_h);
}

inline bool GRect::operator== (const GRect& other) const
{
  return (!(*this != other));
}

inline bool GRect::operator!= (const GRect& o) const
{
  return (g_x != o.g_x || g_y != o.g_y || g_w != o.g_w || g_h != o.g_h);
}

inline bool GRect::operator>  (const GRect& other) const
{
  return ((int) *this > (int) other);
}

inline bool GRect::operator>= (const GRect& other) const
{
  return ((int) *this >= (int) other);
}

inline bool GRect::operator<  (const GRect& other) const
{
  return ((int) *this < (int) other);
}

inline bool GRect::operator<= (const GRect& other) const
{
  return ((int) *this <= (int) other);
}

inline bool GRect::operator> (const int& i) const
{
  return ((int) (*this) > i);
}

inline bool GRect::operator>= (const int& i) const
{
  return ((int) (*this) >= i);
}

inline bool GRect::operator< (const int& i) const
{
  return ((int) (*this) < i);
}

inline bool GRect::operator<= (const int& i) const
{
  return ((int) (*this) <= i);
}

inline bool operator> (const int& i, const GRect& g)
{
  return (i > (int) g);
}

inline bool operator>= (const int& i, const GRect& g)
{
  return (i >= (int) g);
}

inline bool operator< (const int& i, const GRect& g)
{
  return (i < (int) g);
}

inline bool operator<= (const int& i, const GRect& g)
{
  return (i <= (int) g);
}
#endif
