/* wind_gwo.c - AES wind_gword() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Get word values:
 * WF_KIND, WF_HSLIDE, WF_VSLIDE, WF_HSLSIZE, WF_VSLSIZE, WF_BOTTOM,
 * and WF_TOP if you don't care about the new values returned in AES 4.0.
 */
WORD
wind_gword(int handle, int which)
{
	int_in[0] = handle;
	int_in[1] = which;
	aes(WIND_GET);
	return int_out[1];
}

