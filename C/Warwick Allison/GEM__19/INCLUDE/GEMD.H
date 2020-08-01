/////////////////////////////////////////////////////////////////////////////
//
//  GEMdesktop
//
//  A GEMdesktop is a replacement for the standard desktop.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMd_h
#define GEMd_h

#include <gemfb.h>
#include <gemfw.h>
#include <bool.h>


class GEMdesktop : public GEMformwindow
{
public:
	GEMdesktop(GEMactivity& in, const GEMrsc& rsc, int RSCindex);
	~GEMdesktop();

	virtual bool IsOpen() const;
};

#endif
