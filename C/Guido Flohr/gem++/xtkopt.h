// Modular AES Desktop Environment - MADe.
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


// MADload.
 
#ifndef _XTKOPT_H
#define _XTKOPT_H

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <system.h>

#include <bool.h>

class ToolkitOptions {
public:
  ToolkitOptions (int argc, char* const* argv);
  ~ToolkitOptions () { if (label) delete label; }
  
  inline int BackgroundColor () const { return bg; }
  inline int ForegroundColor () const { return fg; }
  inline int HighlightColor () const { return hl; }
  inline int Update () const { return update; }
  inline int Scale () const { return scale; }
  inline int Jumpscroll () const { return jumpscroll; }
  inline char* Title () const { return title; }
  inline char* Label () const { return label; }
  inline bool Info () const { return info; }
  inline bool Iconic () const { return iconic; }
  inline bool Reverse () const { return reverse; }
  inline int Width () const { return width; }
  inline int Height () const { return height; }
  inline bool LeftRef () const { return left_ref; }
  inline bool RightRef () const { return right_ref; }
  inline bool TopRef () const { return top_ref; }
  inline bool BottomRef () const { return bottom_ref; }
  inline int XOffset () const { return xoffset; }
  inline int YOffset () const { return yoffset; }
  inline bool Fixed () const { return fixed; }
  inline int Precision () const { return precision; } 
  
private:
  int Color2VDI (const char* color) const;
  void GetGeometry (char* geometry);
  void ClearGeometry ();
  bool nolabel;
  bool iconic;
  bool reverse;
  int update;
  int scale;
  int bg;
  int fg;
  int hl;
  int jumpscroll;
  char* title;
  char* label;
  int info;
  int width;
  int height;
  int xoffset;
  int yoffset;
  bool right_ref;
  bool left_ref;
  bool top_ref;
  bool bottom_ref;
  static char* default_title;
  bool fixed;
  int precision;
};
#endif

