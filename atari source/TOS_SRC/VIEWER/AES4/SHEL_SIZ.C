/* shel_siz.c - AES 4.0 shel_sizeenv() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_sizeenv(): get AES environment size.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns size in bytes of the AES environment.
 */
int
shel_sizeenv(void)
{
	if (!isAES4()) return AESERR;
	int_in[0] = 8;
	int_in[1] = 0;
	return aes(SHEL_WRITE);
}
