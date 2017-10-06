/////////////////////////////////////////////////////////////////////////////
//
//  GEMkeysink
//
//  A GEMkeysink is an event handler that acts when a key is pressed.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMks_h
#define GEMks_h

#include <gemfb.h>

class GEMactivity;
class GEMevent;

class GEMkeysink
{
public:
	GEMkeysink(GEMactivity& in);
	virtual ~GEMkeysink();

	virtual GEMfeedback Consume(const GEMevent&)=0;

private:
	GEMactivity& act;
};

#endif
