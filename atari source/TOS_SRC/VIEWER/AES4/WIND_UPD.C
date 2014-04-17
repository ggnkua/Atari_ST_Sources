/* wind_upd.c - AES wind_update() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * This wind_update masks out all but the low 2 bits on AES < 4.0
 */
int
wind_update(int which)
{
	if (!isAES4()) which &= 3;
	int_in[0] = which;
	return aes(WIND_UPDATE);
}
