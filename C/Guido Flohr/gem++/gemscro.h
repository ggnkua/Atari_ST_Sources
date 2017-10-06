/////////////////////////////////////////////////////////////////////////////
//
//  GEMscrollableobject
//
//  A GEMscrollableobject is a VDI and a GEMuserobject, with scrolling.
//
//  This file is Copyright 1993 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#ifndef GEMscro_h
#define GEMscro_h

#include <gemvo.h>
#include <vdi++.h>

class GEMscrollableobject : public VDI, public GEMuserobject {
public:
	GEMscrollableobject(GEMform&, int RSCindex);

	virtual void Scroll(int pixels_right, int pixels_down);

	void VScroll(int pixels_down);
	void HScroll(int pixels_right);

protected:
	// AES calls not permitted in this routine.
	virtual int RedrawClipped(int x, int y, const GRect&)=0;

	virtual int Draw(const PARMBLK*);
};


#endif
