/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<types2b.h>
#include	<mt_aes.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include "rect.h"

/*----------------------------------------------------------------------------------------*/
/* gets the object coordinates (absolute)																	*/
/* return:		-																									*/
/*----------------------------------------------------------------------------------------*/
void	objc_rect( OBJECT *tree, int16 obj, GRECT *rect )
{
  objc_offset( tree, obj, &rect->g_x, &rect->g_y );
  rect->g_w = tree[obj].ob_width;
  rect->g_h = tree[obj].ob_height;
} /* objc_rect */


/*----------------------------------------------------------------------------------------*/
/* Testet, ob 2 Rechtecke identisch sind																	*/
/* Funktionsresultat:	1 falls ja, 0 sonst																*/
/*----------------------------------------------------------------------------------------*/
int16 rc_equal( GRECT *p1, GRECT *p2 )
{
	return ((p1->g_x == p2->g_x) &&
		(p1->g_y == p2->g_y) &&
		(p1->g_w == p2->g_w) &&
		(p1->g_h == p2->g_h));
}


/*----------------------------------------------------------------------------------------*/
/* Testet, ob ein Punkt in einem Rechteck ist															*/
/* Funktionsresultat:	1 falls ja, 0 sonst																*/
/*----------------------------------------------------------------------------------------*/
int16 rc_inside( GRECT *r, int16 x, int16 y )
{
	if( (x >= r->g_x) && (x <= r->g_x+r->g_w) && (y >= r->g_y) && (y <= r->g_y+r->g_h) )
		return TRUE;
	else
		return FALSE;
}


/*----------------------------------------------------------------------------------------*/
/* Beschr„nkt ein Rechteck (r2) auf ein anderes (r1)													*/
/* Funktionsresultat:	0																						*/
/*----------------------------------------------------------------------------------------*/
int16	rc_intersect( GRECT *r1, GRECT *r2 )
{
	int16	tx, ty, tw, th, ret;
	
	tx = max (r2->g_x, r1->g_x);
	tw = min (r2->g_x + r2->g_w, r1->g_x + r1->g_w) - tx;
	ret = (0 < tw);
	if (ret) 
	{
		ty = max (r2->g_y, r1->g_y);
		th = min (r2->g_y + r2->g_h, r1->g_y + r1->g_h) - ty;
		ret = (0 < th);
		if (ret) 
		{
			r2->g_x = tx;
			r2->g_y = ty;
			r2->g_w = tw;
			r2->g_h = th;
		}
	}
	return (ret);
}


/*----------------------------------------------------------------------------------------*/
/* Wandelt eine GRECT Struktur in ein Array																*/
/* Funktionsresultat:	Zeiger auf Array																	*/
/*----------------------------------------------------------------------------------------*/
int16 *grect_to_array( GRECT *area, int16 *array )
{
	int16 *ip = array;

	*ip = area->g_x;
	ip[2] = *ip;
	ip++;
	*ip = area->g_y;
	ip[2] = *ip;
	ip++;
	*ip++ += area->g_w - 1;
	*ip   += area->g_h - 1;
	return (array);
}


/*----------------------------------------------------------------------------------------*/
/* Wandelt ein Array in eine GRECT Struktur																*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/
void array_to_grect( int16 *array, GRECT *area )
{
	area->g_x = array[0];
	area->g_y = array[1];
	area->g_w = array[2] - array[0] + 1;
	area->g_h = array[3] - array[1] + 1;
}
