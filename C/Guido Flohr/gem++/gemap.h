// GEM++.
// Copyright (C) 1992, 1993 by Warwick W. Allison.
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

#ifndef _GEMAP_H
#define _GEMAP_H

#include <bool.h>
#include <geminfo.h>

class GEMapplication
{
public:
  GEMapplication();     // A new application
  GEMapplication(const char *);   // An existing application

  ~GEMapplication();

  int Id() const { return ID; }

  // New!
  // int SetName (const char*)
  int RegisterName (const char*);

  static GEMapplication* This(); // Most recent GEMapplication()

private:
  int ID;
  bool isnew;
  static GEMapplication* ap;
  char* Name;
};

#endif
