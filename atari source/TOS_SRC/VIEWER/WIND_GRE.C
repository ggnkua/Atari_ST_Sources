/* wind_gre.c - AES wind_grect() function
 *=======================================================================
 * 920630 kbad
 */
#include "aes4.h"
#include "_aes.h"

/*
 * Get various window rects:
 * WF_WORK, WF_CURR, WF_PREV, WF_FULL, WF_FIRST, WF_NEXT
 */
void
wind_grect(int handle, int which, GRECT *prect)
{
	int_in[0] = handle;
	int_in[1] = which;
	aes(WIND_GET);
	*prect = *(GRECT *)&int_out[1];
}
