/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemvo.h"
#include "grect.h"
#include "vdi++.h"

GEMvdiobject::GEMvdiobject(GEMform& f, int RSCindex, VDI& v) :
		GEMuserobject(f,RSCindex),
		vdi(v)
{ }

int GEMvdiobject::Draw(const PARMBLK* p)
{
	GRect drawclip(p->pb_xc,p->pb_yc,p->pb_wc,p->pb_hc);
	if (ClipToObject()) {
		GRect objclip(p->pb_x,p->pb_y,Width(),Height());
		drawclip.Clip(objclip);
	}
	vdi.clip(drawclip.g_x,drawclip.g_y,drawclip.g_x+drawclip.g_w-1,drawclip.g_y+drawclip.g_h-1);
	int result=Draw(p->pb_x,p->pb_y);
	vdi.clip_off();
	return result;
}

bool GEMvdiobject::ClipToObject() const
{
	return true;
}
