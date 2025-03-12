#include <aes.h>
#include <tos.h>

#include "demo.h"


WORD rc_intersect(GRECT *r1, GRECT *r2)
{
	/*
	*	šberschneiden sich die zwei Rechecke?
	*/
	
	WORD x, y, w, h;
	
	x = max( r2->g_x, r1->g_x );
	y = max( r2->g_y, r1->g_y );
	w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );
	
	r2->g_x = x;
	r2->g_y = y;
	r2->g_w = w - x;
	r2->g_h = h - y;
	
	return ( ((w > x) && (h > y) ) );
}
