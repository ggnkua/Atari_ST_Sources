/* wind_gst.c - AES 4.0 wind_gstr() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Get string values: WF_INFO, WF_NAME
 * Returns -1 on AES < 4.0, 1 on AES >= 4.0
 */
int
wind_gstr(int handle, int which, char *buf)
{
    int ret = AESERR;
    if (isAES4())
    {
	int_in[0] = handle;
	int_in[1] = which;
	*(char **)&int_in[2] = buf;
	ret = aes(WIND_GET);
    }
    return ret;
}
