/* wind_gco.c - AES wind_gcolor() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Get colors.
 * Returns -1 on AES < 4.0, 1 on AES >= 4.0
 */
int
wind_gcolor(int handle, int which, int element, WORD *top, WORD *untop)
{
    int ret = AESERR;
    if (isAES4())
    {
	int_in[0] = handle;
	int_in[1] = which;
	int_in[2] = element;
	ret = aes(WIND_GET);
	*top = int_out[1];
	*untop = int_out[2];
    }
    return ret;
}


