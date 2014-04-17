/* shel_bro.c - AES 4.0 shel_broadcast() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_broadcast(): broadcast an 8 WORD message to all but AES & sender.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int
shel_broadcast(WORD *msg)
{
	if (!isAES4()) return AESERR;

	int_in[0] = 7;
	addr_in[0] = msg;
	return aes(SHEL_WRITE);
}
