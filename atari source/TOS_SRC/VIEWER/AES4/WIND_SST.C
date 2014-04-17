/* wind_sst.c - AES wind_sstr() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Set string values: WF_INFO, WF_NAME
 */
void
wind_sstr(int handle, int which, char *p)
{
	int_in[0] = handle;
	int_in[1] = which;
	*(char **)&int_in[2] = p;
	aes(WIND_SET);
}
