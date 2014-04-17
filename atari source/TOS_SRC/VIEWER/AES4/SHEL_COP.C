/* shel_cop.c - AES 4.0 shel_copyenv() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_copyenv(): copy len bytes of AES environment string into buf.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns the number of bytes not copied.
 */
int
shel_copyenv(char *buf, short len)
{
	if (!isAES4()) return AESERR;
	int_in[0] = 8;
	int_in[1] = 1;
	int_in[2] = len;
	addr_in[0] = buf;
	return aes(SHEL_WRITE);
}
