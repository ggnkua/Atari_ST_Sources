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

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#ifdef STDC_HEADERS
# include <string.h>
#endif

#include <aesbind.h>
#include "gemap.h"

GEMapplication::GEMapplication() :
  ID (appl_init()),
  isnew (true),
  Name (0)
{
  ap = this;
}

GEMapplication::GEMapplication (const char *name) :
  isnew (false)
{
  char fname[9];
  int i;

  for (i = 0; name[i] && i < 8; i++)
    fname[i] = name[i];

  while (i < 8) {
    fname[i] = ' ';
    i++;
  }

  fname[i] = 0;

  ID = appl_find (fname);
}

GEMapplication::~GEMapplication ()
{
  if (ap == this) ap=0;
  if (isnew) appl_exit ();
  if (Name) delete Name;
}

GEMapplication* GEMapplication::ap = 0;

GEMapplication* GEMapplication::This()
{
  return ap;
}

int GEMapplication::RegisterName (const char* name)
{
  if (Name) delete Name;

  Name = new char[strlen (name)];
  strcpy (Name, name);
  return (menu_register (ID, Name));
}
