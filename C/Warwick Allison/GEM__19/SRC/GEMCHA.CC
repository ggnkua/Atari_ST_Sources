/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////
#include "gemcha.h"

GEMchangearea::GEMchangearea() :
	GRect(0,0,0,0)
{
}

void GEMchangearea::Clear()
{
	g_x=0;
	g_y=0;
	g_w=0;
	g_h=0;
}

bool GEMchangearea::Changed() const
{
	return !!g_w;
}

void GEMchangearea::Include(int x, int y)
{
	if (Changed()) {
		if (x<g_x) {
			g_w+=g_x-x;
			g_x=x;
		}
		if (y<g_y) {
			g_h+=g_y-y;
			g_y=y;
		}
		if (g_x+g_w-1<x) {
			g_w=x-g_x+1;
		}
		if (g_y+g_h-1<y) {
			g_h=y-g_y+1;
		}
	} else {
		g_x=x;
		g_y=y;
		g_w=1;
		g_h=1;
	}
}

void GEMchangearea::Include(const GRect& area)
{
	if (area.g_w>0 && area.g_h>0) {
		Include(area.g_x,area.g_y);
		Include(area.g_x+area.g_w-1,area.g_y+area.g_h-1);
	}
}
