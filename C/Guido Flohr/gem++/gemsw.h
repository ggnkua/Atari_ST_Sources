/////////////////////////////////////////////////////////////////////////////
//
//  GEMscrollingwindow
//
//  A GEMscrollingwindow is a GEMwindow which blits to scroll.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMsw_h
#define GEMsw_h

#include <gemw.h>


class GEMscrollingwindow : public GEMwindow
{
public:
	GEMscrollingwindow(GEMactivity& in, const GEMrsc& in, int RSCindex);
	GEMscrollingwindow(GEMactivity& in, const GEMrsc& in, int RSCindex, int Parts);
	GEMscrollingwindow(const GEMscrollingwindow&);

};

#endif
