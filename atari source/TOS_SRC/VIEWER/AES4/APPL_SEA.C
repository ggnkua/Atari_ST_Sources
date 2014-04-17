/* appl_sea.c - AES 4.0 appl_search() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* appl_search(): search AES process IDs
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1 if the return values are valid,
 * or AESFAIL (0) when no more applications can be found.
 */
int
appl_search(int mode, char *name, WORD *type, WORD *id)
{
    int ret = AESERR;
    if (isAES4())
    {
	int_in[0] = mode;
	addr_in[0] = name;

	if (ret = aes(APPL_SEARCH))
	{
	    *type = int_out[1];
	    *id = int_out[2];
	}
    }
    return ret;
}
