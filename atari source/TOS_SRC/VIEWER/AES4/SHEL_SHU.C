/* shel_shu.c - AES 4.0 shel_shutdown() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_shutdown(): get the system into or out of shutdown mode.
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1).
 * On AES >= 4.0, returns (?)
 */
int shel_shutdown(int mode)
{
	if (!isAES4()) return AESERR;
	int_in[0] = 4;
	int_in[1] = mode;
	return aes(SHEL_WRITE);
}
