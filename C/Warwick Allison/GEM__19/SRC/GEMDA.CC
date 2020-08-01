/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemda.h"
#include "gemap.h"
#include "gema.h"
#include "geme.h"
#include <aesbind.h>

GEMdeskaccessory::GEMdeskaccessory(const GEMapplication& appl, GEMactivity& in, const char* MenuItemName) :
	act(in)
{
	menuid=menu_register(appl.Id(),(char*)MenuItemName);
	act.SetDeskAccessory(this);
}

GEMdeskaccessory::~GEMdeskaccessory()
{
	act.SetDeskAccessory(0);
}

void GEMdeskaccessory::Open(const GEMevent& e)
{
	if (e.Message(4)==menuid) Open();
}

void GEMdeskaccessory::Close(const GEMevent& e)
{
	if (e.Message(3)==menuid) Close();
}

