/* rsrc_rcf.c - AES 4.0 rsrc_rcfix() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* rsrc_rcfix(): fix up a resource in memory.
 *-----------------------------------------------------------------------
 * Converts object coordinates to pixel coordinates.
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns 1.
 */
int rsrc_rcfix(RSHDR *rp)
{
	if (!isAES4()) return AESERR;
	addr_in[0] = rp;
	return aes(RSRC_RCFIX);
}
