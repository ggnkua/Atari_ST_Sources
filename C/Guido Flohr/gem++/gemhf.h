/////////////////////////////////////////////////////////////////////////////
//
//  GEMhotform
//
//  A GEMhotform is a GEMform that behaves more like a menu, in that
//  selectable items are selected under the mouse cursor as it moves.
//
//  This is useful for many form applications, such as pop-up menus.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMmf_h
#define GEMmf_h

#include <gemf.h>


class GEMhotform : public GEMform
{
public:
	GEMhotform(const GEMrsc& in, int RSCindex);
	GEMhotform(const GEMhotform& copy);

	const int NoObject=-1;

	virtual int DoKey(int meta, int key);
	virtual int DoOff();
	virtual int DoHot(int ob, bool inside);

protected:
	const int Ignore=-2;
	virtual int FormDo(GEMevent& finalevent);

private:
	int curedit;
	// static int to_find; - musel jsem hodit do .cc, protoze to jinak nenasel - buhvi proc
	// Has to be static because it is passed as an argument to the Map() method
	// of the GEMform class (which doesn't like an extra "this" pointer.
	static int FindToFind(GEMrawobject* o, int i);
};


#endif
