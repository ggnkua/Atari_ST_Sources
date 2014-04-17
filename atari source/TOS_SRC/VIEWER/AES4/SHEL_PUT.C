/* shel_put.c - AES shel_put() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_put(): write data into the AES shell internal buffer.
 *-----------------------------------------------------------------------
 * On AES < 4.0, this call validates the size being written.
 */
int
shel_put(const char *buf, int len)
{
	if (!isAES4() && len > shel_glen()) return AESERR;

	int_in[0] = len;
	addr_in[0] = (void *)buf;
	return aes(SHEL_PUT);
}
