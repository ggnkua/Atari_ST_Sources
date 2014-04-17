/* appl_get.c - AES 4.0 appl_getid() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* appl_getid(): get application ID or translate AES apid <-> MiNT id
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns GL_APID for AP_AESID mode, and AESERR (-1) for
 * AP_MINT2AES and AP_AES2MINT modes.
 * On AES >= 4.0, returns AESERR (-1) if the application was not found,
 * otherwise returns the appropriate id.
 */
int
appl_getid(int mode, int id)
{
	if (!isAES4())
	    return (mode != AP_AESID) ? AESERR : GL_APID;
	addr_in[0] = (void *)((long)mode << 16);
	return aes(APPL_FIND);
}
