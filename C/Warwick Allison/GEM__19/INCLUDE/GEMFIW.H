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

	virtual void UserFulled();
	virtual void Open();

	bool IsIconified() const;

protected:
	virtual void IconOpened();

private:
	friend class GEMiconformwindow;
	class GEMiconformwindow* icon;
};

#endif
