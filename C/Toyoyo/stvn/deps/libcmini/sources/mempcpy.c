/*  mempcpy.c -- MiNTLib.
    Copyright (C) 1999 Guido Flohr <guido@freemint.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/

/* Copy memory to memory until the specified number of bytes
   has been copied, return pointer to following byte.
   Overlap is handled correctly but don't rely on it!

   This file should be replaced by a better implementation within
   bzero.cpp.  */

#include <string.h>

void*
mempcpy(void* dstpp, const void* srcpp, size_t len)
{
  return (void*) ((char*) memcpy (dstpp, srcpp, len) + len);
}
