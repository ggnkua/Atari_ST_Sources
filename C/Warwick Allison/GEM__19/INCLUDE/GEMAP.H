/////////////////////////////////////////////////////////////////////////////
//
//  GEMapplication
//
//  A GEMapplication is an program environment in which GEM may be used.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMap_h
#define GEMap_h
#include <bool.h>


class GEMapplication
{
public:
	GEMapplication();			// A new application
	GEMapplication(const char *);		// An existing application

	~GEMapplication();

	int Id() const { return ID; }

private:
	int ID;
	bool isnew;
};

#endif
