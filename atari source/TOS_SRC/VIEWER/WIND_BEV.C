/* wind_bev.c - AES 4.0 wind_bevent() function
 *=======================================================================
 * 920630 kbad
 */
#include "aes4.h"
#include "_aes.h"

/* wind_bevent(): set/get a window's button event status.
 *-----------------------------------------------------------------------
 * If set == -1, returns 1 if the window gets button events when it's
 * untopped, or 0 if the window gets topped events when it's untopped.
 * If set >= 0 on AES < 4.0, returns -1.
 * If set >= 0 on AES >= 4.0, sets the window to get button events (set==1)
 * or topped events (set==0) when it is untopped, and returns 1.
 */
int
wind_bevent(int handle, int set)
{
	int func;
	if (!isAES4()) return (set == -1) ? 0 : AESERR;
	int_in[0] = handle;
	int_in[1] = WF_BEVENT;
	int_in[2] = set;
	func = (set < 0) ? WIND_GET : WIND_SET;
	return aes(func);
}

