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
#include "gemo.h"
#include "gema.h"
#include "gemd.h"

GEMdesktop::GEMdesktop(GEMactivity& in, const GEMrsc& rsc, int RSCindex) :
	GEMformwindow(in,rsc,RSCindex,-1)
{
	int x,y,w,h;

	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);

	Object(0).MoveTo(x,y);
	Object(0).Resize(w,h);

	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	wind_set(0,WF_NEWDESK,Obj,0);
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
}

GEMdesktop::~GEMdesktop()
{
	wind_set(0,WF_NEWDESK,0);
}

bool GEMdesktop::IsOpen() const
{
	return TRUE;
}
