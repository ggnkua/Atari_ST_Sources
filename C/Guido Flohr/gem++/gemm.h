/////////////////////////////////////////////////////////////////////////////
//
//  GEMmenu
//
//  A GEMmenu in its base class is a standard GEM menu, for which every
//  button is like a "quit" button.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMm_h
#define GEMm_h

#include <gemfb.h>
#include <gemf.h>

class GEMactivity;
class GEMevent;

class GEMmenu : public GEMform
{
public:
	GEMmenu(GEMactivity& in, const GEMrsc& rsc, int RSCindex);
	~GEMmenu();

	GEMfeedback Select(const GEMevent&);
	void Show(bool on=true);
	void Hide() { Show(false); }

private:
	GEMactivity& act;
};

#endif
