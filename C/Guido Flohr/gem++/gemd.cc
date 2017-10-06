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
#include "geminfo.h"

GEMdesktop::GEMdesktop(GEMactivity& in, const GEMrsc& rsc, int RSCindex) :
	GEMformwindow(in,rsc,RSCindex,-1)
{
        GEMinfo Info;
	const GRect& Desktop = Info.Desktop ();
	
	Object(0).MoveTo (Desktop.g_x, Desktop.g_y);
	Object(0).Resize (Desktop.g_w, Desktop.g_h);

	form_dial(FMD_START, 0, 0, 0, 0, 
	    Desktop.g_x, Desktop.g_y, Desktop.g_w, Desktop.g_h);
	wind_set(0, WF_NEWDESK, long(Obj), 0, 0, 0);
	form_dial(FMD_START, 0, 0, 0, 0, 
	    Desktop.g_x, Desktop.g_y, Desktop.g_w, Desktop.g_h);
}

GEMdesktop::~GEMdesktop()
{
	wind_set(0,WF_NEWDESK,0,0,0,0);
}

bool GEMdesktop::IsOpen() const
{
	return true;
}
