#include <gemfast.h>
#include "globals.h"
/*
 * megamax compatibility routines for gcc
 *  ++jrb	bammi@dsrgsun.ces.cwru.edu
 */
void rect_set( GRECT *r, int x, int y, int w, int h)
{
    r->g_x = x;
    r->g_y = y;
    r->g_w = w;
    r->g_h = h;
}

char *xtrcpy(char *dest, char *src)
{
    /* like strcpy but returns pointer to end of dest */
    if(!src)
	return dest;	/* gigo */
    
    while(*src)
	*dest++ = *src++;
    *dest = '\0';
    return dest;
}
