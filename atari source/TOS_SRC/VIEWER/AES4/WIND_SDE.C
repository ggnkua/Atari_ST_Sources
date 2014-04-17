/* wind_sde.c - AES wind_sdesk() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Set new desktop
 */
void
wind_sdesk(OBJECT *tree, int obj)
{
	int_in[0] = 0;
	int_in[1] = WF_NEWDESK;
	*(OBJECT **)&int_in[2] = tree;
	int_in[4] = obj;
	aes(WIND_SET);
}
