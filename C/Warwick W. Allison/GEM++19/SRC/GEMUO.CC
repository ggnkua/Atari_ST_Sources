/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemuo.h"
#include <osbind.h>

GEMuserobject::GEMuserobject(GEMform& f, int RSCindex) :
	GEMobject(f,RSCindex)
{
	ub.ub_code=Handler;
	ub.ub_parm=(long)this;
	originalspec=GEMobject::ObjectSpecific();
	originaltype=GEMobject::Type();
	GEMobject::ObjectSpecific((int)&ub);
	GEMobject::Type(G_USERDEF);
}

GEMuserobject::~GEMuserobject()
{
	GEMobject::ObjectSpecific(originalspec);
	GEMobject::Type(originaltype);
}

int GEMuserobject::Handler(void* p)
{
	PARMBLK* pb=(PARMBLK*)p;

	if (pb->pb_currstate==pb->pb_prevstate) {
		((GEMuserobject*)pb->pb_parm)->Draw(pb);
		return 0;
	} else {
		return ((GEMuserobject*)pb->pb_parm)->Change(pb);
	}
}

int GEMuserobject::Change(const PARMBLK* p)
{
	Draw(p);
	return 0;
}

int GEMuserobject::Type() const
{
	return originaltype;
}

void GEMuserobject::Type(int t)
{
	originaltype=t;
}

int GEMuserobject::ObjectSpecific() const
{
	return originalspec;
}

void GEMuserobject::ObjectSpecific(int s)
{
	originalspec=s;
}

