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

#ifndef _GEMF_H
#define _GEMF_H

#include <gemfb.h>
#include <gemrawo.h>
#include <grect.h>
#include <bool.h>

class GEMobject;
class GEMrsc;
class GEMevent;
class GRect;

class GEMform
{
public:
  GEMform(const GEMrsc& in, int RSCindex);
  GEMform(const GEMform&);
  virtual ~GEMform();

  int Do(); // Centred
  virtual int Do(int x, int y);

  bool Zooms(bool b);
  bool Flight(bool b);
  void Fly(bool opaque=true);

  virtual void RedrawObject(int RSCindex);
  // New!
  virtual void RedrawObject (int RSCindex, const GRect& area);
  virtual void RedrawObject(int RSCindex,int Cx,int Cy,int Cw,int Ch); // Clipped
  void RedrawObjectFromRoot(int RSCindex);

  int Parent(int RSCindex) const;

  // See GEMrawobject for conversion function to GEMobject*
  GEMrawobject& Object(int RSCindex) const { return Obj[RSCindex]; }
  GEMrawobject& operator[](int RSCindex) const { return Object(RSCindex); }

  virtual void AlignObject(int RSCindex, int xmult=8, int ymult=1);

  const int SearchDown=-1;
  const int SkipSubtree=-2;

  int Map (int Do (GEMrawobject*, int), bool skiphidden=true, int RSCfrom=0, int RSCto=-1);
  
  virtual GEMfeedback DoItem(int item, const GEMevent& e);

  int Index() const { return myindex; }

  virtual bool IsOpen();

  // Should always be called to completion.
  // GRects invalid afer next call.
  virtual GRect* FirstClip(int RSCobject);
  virtual GRect* NextClip(GRect* prev);

private:
  int myindex;
  void* flybuffer;
  int vdihandle;
  int open;
  static int global_count;
  static GEMrawobject* global_obj;
  static int CountObj (GEMrawobject* o, int i);
  static int CopyObj (GEMrawobject* o, int i);
  
protected:
  bool ZoomOn;
  bool flight;
  GEMrawobject *Obj;
  virtual int FormDo(GEMevent& finalevent);
  int xoffset,yoffset,xmult,ymult;

  void FlagOpen(int dopen) { open+=dopen; }
};
inline  bool GEMform::Zooms(bool b) { bool t=b; ZoomOn=b; return t; }
#endif
