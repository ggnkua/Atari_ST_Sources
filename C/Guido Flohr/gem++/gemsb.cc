/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////
#include "gemsb.h"
#include <aesbind.h>

GEMstreambuf::GEMstreambuf(int ApplID) : ID(ApplID)
{ }

size_t GEMstreambuf::sputn(const char* s, size_t n)
{
	return appl_write(ID,n,(char*)s); // SAFE - appl_write doesn't hack s
}

size_t GEMstreambuf::sgetn(char* s, size_t n)
{
	return appl_read(ID,n,s);
}

