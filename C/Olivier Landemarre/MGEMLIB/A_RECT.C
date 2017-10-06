/*
 *	Aes rectangle utils
 *		rc_copy		copy grects
 * 		rc_equal	compare two grects
 *              rc_intersect    check if two grects intersect, ret intersec
 *              rc_union        union of two grects
 *		grect_to_aray	convert GRECT to a vdi pxy style coordinate
 *				array
 *
 *	    ++jrb	bammi@cadence.com
 *	    modified: mj -- ntomczak@vm.ucs.ualberta.ca
 */
/*#include <macros.h>*/ 
#include "mgem.h"

#ifndef min
#define min(a, b)             ((a) < (b) ? (a) : (b))
#endif
#ifndef max
#define max(a, b)             ((a) > (b) ? (a) : (b))
#endif

int rc_copy(GRECT *src, GRECT *dst)
{
    *dst = *src;
    return 1;
}

int rc_equal(GRECT *p1, GRECT *p2) 
{
    return ((p1->g_x == p2->g_x) &&
	    (p1->g_y == p2->g_y) &&
	    (p1->g_w == p2->g_w) &&
	    (p1->g_h == p2->g_h));
}


int rc_intersect(GRECT *r1, GRECT *r2)
{
      int     tx, ty, tw, th, ret;
	
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


INT16 *grect_to_array(GRECT *area, INT16 *array)
{
    INT16 *ip = array;

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


void array_to_grect(INT16 *array, GRECT *area)
{
	area->g_x = array[0];
	area->g_y = array[1];
	area->g_w = array[2] - array[0] + 1;
	area->g_h = array[3] - array[1] + 1;
}
