/* wind_gde.c - AES wind_gdesk() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/*
 * Get address of window 0 object tree.
 * Returns pdesk == NULL on AES < 4.0.
 */
void
wind_gdesk(OBJECT **pdesk, WORD *proot)
{
    OBJECT *po = NULL;
    if (isAES4())
    {
	int_in[0] = 0;
	int_in[1] = WF_NEWDESK;
	aes(WIND_GET);
	po = *(OBJECT **)&int_out[1];
	*proot = int_out[3];
    }
    *pdesk = po;
}
