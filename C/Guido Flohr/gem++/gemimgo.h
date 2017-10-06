/////////////////////////////////////////////////////////////////////////////
//
//  GEMimageobject - derivative of GEMobject, allowing all the
//                     operations on IMGs to work on GEMobjects.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMimgo_h
#define GEMimgo_h

#include <gemo.h>

class IMG;

// Image bitmap and icon bitmap foreground or mask.
class GEMimageobject : public GEMobject
{
public:
	GEMimageobject(class GEMform& f, int RSCindex, IMG& data);
	GEMimageobject(class GEMform& f, int RSCindex, IMG& data, IMG& mask);
};

#endif
