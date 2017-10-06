/////////////////////////////////////////////////////////////////////////////
//
//  GEMrectangletracker
//
//  A GEMrectangletracker is an event handler that acts on mouse entry/exit
//  to rectangles it defines.
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMrt_h
#define GEMrt_h

#include <gemfb.h>

class GEMactivity;
class GEMevent;

class GEMrectangletracker
{
public:
	GEMrectangletracker(GEMactivity& in);
	virtual ~GEMrectangletracker();

	virtual void CalculateRectangles(GEMevent&);
	virtual GEMfeedback MousePosition(const GEMevent&);

private:
	GEMactivity& act;
	int prev_x,prev_y;
};

#endif
