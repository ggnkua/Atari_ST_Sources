/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include <aesbind.h>
#include "gemap.h"


GEMapplication::GEMapplication() :
	ID(appl_init()),
	isnew(TRUE)
{ }

GEMapplication::GEMapplication(const char *name) :
	isnew(FALSE)
{
	char fname[9];

	for (int i=0; name[i] && i<8; i++)
		fname[i]=name[i];

	while (i<8) {
		fname[i]=' ';
		i++;
	}

	fname[i]=0;

	ID=appl_find(fname);
}

GEMapplication::~GEMapplication()
{
	if (isnew) appl_exit();
}
