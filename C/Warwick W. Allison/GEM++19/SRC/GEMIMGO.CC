/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemimgo.h"
#include "img.h"

GEMimageobject::GEMimageobject(class GEMform& f, int RSCindex, IMG& data) :
	GEMobject(f,RSCindex)
{
	SetImageBitmap((char*)data.Location(),data.Width(),data.Height(),FALSE);
}

GEMimageobject::GEMimageobject(class GEMform& f, int RSCindex, IMG& data, IMG& mask) :
	GEMobject(f,RSCindex)
{
	SetImageBitmap((char*)data.Location(),data.Width(),data.Height(),FALSE);
	SetImageBitmap((char*)mask.Location(),mask.Width(),mask.Height(),TRUE);
}
