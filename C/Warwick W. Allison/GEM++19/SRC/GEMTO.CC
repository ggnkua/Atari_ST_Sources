/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemto.h"


GEMtextobject::GEMtextobject(class GEMform& f, int RSCindex) :
	GEMobject(f,RSCindex)
{
}

GEMtextobject::operator char*() const
{
	return Text();
}

GEMtextobject& GEMtextobject::operator = (char* t)
{
	SetText(t);
	return *this;
}

char& GEMtextobject::operator[] (int i)
{
	return Text()[i];
}
