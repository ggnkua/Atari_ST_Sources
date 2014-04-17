/* shel_cha.c - AES 4.0 shel_changeres() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

int
shel_changeres(int res)
{
	if (!isAES4()) return AESERR;
	int_in[0] = 5;
	int_in[1] = res;
	return aes(SHEL_WRITE);
}
