/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

// Only linkable if MiNTlibs used.

// FIXME: Use new GEMinfo features... It should be usable with every AES
// version however.

#include <aesbind.h>
#include "gemap.h"

void GEMapplication::SetName(const char* name)
{
  menu_register (ID, name);
}
