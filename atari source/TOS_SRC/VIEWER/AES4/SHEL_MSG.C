/* shel_sen.c - AES 4.0 shel_send() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_msg(): send the AES a message.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int
shel_msg(WORD *msg)
{
	if (!isAES4()) return AESERR;
	int_in[0] = 10;
	addr_in[0] = msg;
	return aes(SHEL_WRITE);
}
