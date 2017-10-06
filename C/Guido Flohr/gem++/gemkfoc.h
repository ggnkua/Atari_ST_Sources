/////////////////////////////////////////////////////////////////////////////
//
//  GEMkeyfocus
//
//  Share key focus among windows.
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMkfoc_h
#define GEMkfoc_h

#include <gemks.h>

class GEMkeyfocus : GEMkeysink {
public:
	GEMkeyfocus(GEMactivity& act);
	~GEMkeyfocus();

	virtual GEMfeedback Consume(const GEMevent&);
};

#endif
