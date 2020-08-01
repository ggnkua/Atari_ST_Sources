/////////////////////////////////////////////////////////////////////////////
//
//  GEMtextobject - derivative of a GEMobject which coerces to char*.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMto_h
#define GEMto_h

#include <gemo.h>


class GEMtextobject : public GEMobject
{
public:
	GEMtextobject(class GEMform& f, int RSCindex);

	operator char*() const;
	GEMtextobject& operator = (char*);
	char& operator[] (int);
};


#endif
