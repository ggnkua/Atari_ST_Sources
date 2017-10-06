/////////////////////////////////////////////////////////////////////////////
//
//  GEMformiconwindow
//
//  A GEMformiconwindow is a GEMformwindow which iconifies.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMfiw_h
#define GEMfiw_h

#include <gemfw.h>

class GEMformiconwindow : public GEMformwindow
{
public:
	GEMformiconwindow(GEMactivity& in, const GEMrsc& in, int RSCform, int RSCicon);
	GEMformiconwindow(GEMactivity& in, const GEMrsc& in, int RSCform, int RSCicon, int Parts);
	GEMformiconwindow(const GEMformiconwindow&);
	virtual ~GEMformiconwindow();

	virtual void UserIconified(const GRect& area);
	virtual void Open();

	virtual bool IsIconified(int& w, int& h) const;

	GEMform& IconForm();

	// Default is EN
	enum Corner { EN, ES, WN, WS, NE, SE, NW, SW };
	static void Placement(GRect area, Corner);
	static void Placement(Corner); // Full screen

	// Not usually needed by user.
	static void FindPlacementArea(int& x, int& y, int w, int h);

protected:
	virtual void IconOpened();

private:
	friend class GEMiconformwindow;
	class GEMiconformwindow* icon;
	static Corner placement;
	static GRect placement_area;
};

#endif
