/////////////////////////////////////////////////////////////////////////////
//
//  GEMchangearea
//
//  A GEMchangearea is a GRect for representing a rectangular changed area.
//
//  This file is Copyright 1993 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////
#ifndef GEMcha_h
#define GEMcha_h

#include <grect.h>
#include <bool.h>

class GEMchangearea : public GRect {
public:
	GEMchangearea(); // Initially empty

	GEMchangearea(int x, int y, int w, int h);

	void Clear();
	bool Changed() const;
	void Include(int x, int y);
	void Include(const GRect& area);
};

#endif
