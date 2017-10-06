/////////////////////////////////////////////////////////////////////////////
//
//  GEMuserobject
//
//  A GEMuserobject is an object with a user-defined graphical representation.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMuo_h
#define GEMuo_h

#include <gemo.h>


class GEMuserobject : public GEMobject
{
public:
	GEMuserobject(GEMform&, int RSCindex);
	virtual ~GEMuserobject();

protected:
	virtual int Change(const PARMBLK*);
	virtual int Draw(const PARMBLK*)=0;
	virtual int Type() const;
	virtual int ObjectSpecific() const;
	virtual void Type(int);
	virtual void ObjectSpecific(int);

private:
	USERBLK ub;
	int originaltype;
	int originalspec;
	static int Handler(void*);
};

#endif
