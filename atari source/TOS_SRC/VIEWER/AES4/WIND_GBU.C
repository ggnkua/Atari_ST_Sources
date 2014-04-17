/* wind_gbu.c - AES wind_gbuf() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Get menu/alert buffer
 */
void
wind_gbuf(void **pbufp, long *plen)
{
	int_in[0] = 0;
	int_in[1] = WF_SCREEN;
	aes(WIND_GET);
	*pbufp = *(void **)&int_out[1];
	*plen = *(long *)&int_out[3];
}

