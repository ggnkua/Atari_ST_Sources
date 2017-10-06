/////////////////////////////////////////////////////////////////////////////
//
//  GEMvdiobject
//
//  A GEMvdiobject is an object with a user-defined graphical representation,
//  that uses a VDI to draw that representation.
//
//  The clipping is already done for the object.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMvo_h
#define GEMvo_h

#include <gemuo.h>


class GEMvdiobject : public GEMuserobject
{
public:
	GEMvdiobject(GEMform&, int RSCindex, class VDI&);

protected:
	virtual int Draw(int x, int y)=0; // Draw self at (x,y)
	VDI& vdi;

	virtual int Draw(const PARMBLK*);
	virtual bool ClipToObject() const;
};

#endif
