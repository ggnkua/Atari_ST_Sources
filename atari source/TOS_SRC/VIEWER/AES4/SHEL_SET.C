/* shel_set.c - AES 4.0 shel_setenv() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_setenv(): set ("VAR=VAL") or clear ("VAR=") an AES env variable.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int
shel_setenv(const char *s)
{
	if (!isAES4()) return AESERR;
	int_in[0] = 8;
	int_in[1] = 1;
	addr_in[0] = (void *)s;
	return aes(SHEL_WRITE);
}
