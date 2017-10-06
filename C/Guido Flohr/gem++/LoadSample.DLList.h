// This may look like C code, but it is really -*- C++ -*-
// WARNING: This file is obsolete.  Use ../DLList.h, if you can.
/* 
Copyright (C) 1988 Free Software Foundation
    written by Doug Lea (dl@rocky.oswego.edu)

This file is part of the GNU C++ Library.  This library is free
software; you can redistribute it and/or modify it under the terms of
the GNU Library General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your
option) any later version.  This library is distributed in the hope
that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.  See the GNU Library General Public License for more details.
You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the Free Software
Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/


#ifndef _LoadSampleDLList_h
#ifdef __GNUG__
#pragma interface
#endif
#define _LoadSampleDLList_h 1

#include <Pix.h>
#include "LoadSample.defs.h"

#ifndef _LoadSampleDLListNode_h
#define _LoadSampleDLListNode_h 1

struct LoadSampleDLListNode
{
  LoadSampleDLListNode*         bk;
  LoadSampleDLListNode*         fd;
  LoadSample                    hd;
                         LoadSampleDLListNode();
                         LoadSampleDLListNode(const LoadSample& h, 
                                       LoadSampleDLListNode* p = 0,
                                       LoadSampleDLListNode* n = 0);
                         ~LoadSampleDLListNode();
};

inline LoadSampleDLListNode::LoadSampleDLListNode() {}

inline LoadSampleDLListNode::LoadSampleDLListNode(const LoadSample& h, LoadSampleDLListNode* p,
                                    LoadSampleDLListNode* n)
  :bk(p), fd(n), hd(h) {}

inline LoadSampleDLListNode::~LoadSampleDLListNode() {}

typedef LoadSampleDLListNode* LoadSampleDLListNodePtr;

#endif

class LoadSampleDLList
{
  friend class          LoadSampleDLListTrav;

  LoadSampleDLListNode*        h;

public:
                        LoadSampleDLList();
                        LoadSampleDLList(const LoadSampleDLList& a);
                        ~LoadSampleDLList();

  LoadSampleDLList&            operator = (const LoadSampleDLList& a);

  int                   empty();
  int                   length();

  void                  clear();

  Pix                   prepend(LoadSample& item);
  Pix                   append(LoadSample& item);
  void                  join(LoadSampleDLList&);

  LoadSample&                  front();
  LoadSample                   remove_front();
  void                  del_front();

  LoadSample&                  rear();
  LoadSample                   remove_rear();
  void                  del_rear();

  LoadSample&                  operator () (Pix p);
  Pix                   first();
  Pix                   last();
  void                  next(Pix& p);
  void                  prev(Pix& p);
  int                   owns(Pix p);
  Pix                   ins_after(Pix p, LoadSample& item);
  Pix                   ins_before(Pix p, LoadSample& item);
  void                  del(Pix& p, int dir = 1);
  void                  del_after(Pix& p);

  void                  error(const char* msg);
  int                   OK();
};


inline LoadSampleDLList::~LoadSampleDLList()
{
  clear();
}

inline LoadSampleDLList::LoadSampleDLList()
{
  h = 0;
}

inline int LoadSampleDLList::empty()
{
  return h == 0;
}


inline void LoadSampleDLList::next(Pix& p)
{
  p = (p == 0 || p == h->bk)? 0 : Pix(((LoadSampleDLListNode*)p)->fd);
}

inline void LoadSampleDLList::prev(Pix& p)
{
  p = (p == 0 || p == h)? 0 : Pix(((LoadSampleDLListNode*)p)->bk);
}

inline Pix LoadSampleDLList::first()
{
  return Pix(h);
}

inline Pix LoadSampleDLList::last()
{
  return (h == 0)? 0 : Pix(h->bk);
}

inline LoadSample& LoadSampleDLList::operator () (Pix p)
{
  if (p == 0) error("null Pix");
  return ((LoadSampleDLListNode*)p)->hd;
}

inline LoadSample& LoadSampleDLList::front()
{
  if (h == 0) error("front: empty list");
  return h->hd;
}

inline LoadSample& LoadSampleDLList::rear()
{
  if (h == 0) error("rear: empty list");
  return h->bk->hd;
}

#endif
