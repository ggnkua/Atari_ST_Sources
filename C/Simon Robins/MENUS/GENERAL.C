/*	$Id: GENERAL.C,v 1.23 1994/06/12 22:00:00 SCR Exp SCR $ */

#include <aes.h>
#include <taddr.h>

#include "general.h"

#if !defined(LATTICE) || !defined(M68000)
void rc_adjust(GRECT *xywh, int size)
{
	xywh->g_x += size;
	xywh->g_y += size;
	size *= 2;
	xywh->g_w -= size;
	xywh->g_h -= size;
}
#endif

void gtovrect(GRECT *g, short *v)
{
	v[2] = (v[0] = g->g_x) + g->g_w - 1;
	v[3] = (v[1] = g->g_y) + g->g_h - 1;
}

int objc_parent(OBJECT *tree, int this)
{
	int that = NIL;

	if(this <= NIL)
		return ROOT;
	that = OB_NEXT(this);
	if(that > NIL)
	{
		while(OB_TAIL(that) != this)
		{
			this = that;
			that = OB_NEXT(this);
		}
	}
	if(that == NIL)
		that = ROOT;
	return that;
}
