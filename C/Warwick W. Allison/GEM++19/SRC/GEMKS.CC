/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemks.h"
#include "gema.h"

GEMkeysink::GEMkeysink(GEMactivity& in) :
	act(in)
{
	act.SetKeySink(this);
}

GEMkeysink::~GEMkeysink()
{
	act.SetKeySink(0);
}
