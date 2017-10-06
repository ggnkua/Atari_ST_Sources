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

#ifndef _VDILOAD_H
#define _VDILOAD_H

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <system.h>

#include <grect.h>
#include <vdi++.h>
#include <bool.h>

#include "LoadSample.DLList.h"

class VDILoadWindow
{
public:
  VDILoadWindow (VDI& vdi, LoadSampleDLList& list, int minscale);
  void GetLoad ();
  void SetWorkRect (const GRect& NewWork);
  void Redraw (const GRect& area);
  void CutList (int length);
  
  void SetBackgroundColor (int bg) { BackgroundColor = bg; }
  void SetForegroundColor (int fg) { ForegroundColor = fg; }
  void SetHighlightColor (int hl) { HighlightColor = hl; }
  
  int GetScale () const { return Scale; }
  
private:
  void Rescale ();

  VDI& Vdi;
  LoadSampleDLList& LoadList;
  int MinimumScale;
  GRect Work;
  int BackgroundColor;
  int ForegroundColor;
  int HighlightColor;
  int Scale;
  Pix PeakSample;
};
#endif
