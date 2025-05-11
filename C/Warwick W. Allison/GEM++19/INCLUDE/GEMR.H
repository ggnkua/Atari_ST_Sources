/////////////////////////////////////////////////////////////////////////////
//
//  GEMresource
//
//  A GEMresource is an object from which forms, alerts, etc. are created.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMr_h
#define GEMr_h

#include <gemfast.h>
#include <bool.h>

class GEMrawobject;

class GEMrsc
{
public:
	// Create any number via this method.
	// rscw and rsch are the width and height of char when RSC files
	// was created (eg. 8 and 16 for STHigh, TTMedium, TTLow, TTHigh)
	GEMrsc(const char *filename, int rscw, int rsch);

	// Only every create one via this method.
	// Uses standard (dumb) GEM RSC loader.
	GEMrsc(const char *filename);

	~GEMrsc();

	int operator!() { return !ok; }

	GEMrawobject* Tree(int RSCindex) const;
	char* String(int RSCindex) const;

private:
	RSHDR* header;
	char* data;
	bool ok;
};

#endif
