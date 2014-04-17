/* shel_gle.c - AES shel_glen() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_glen(): return the size of the AES shell internal buffer.
 *-----------------------------------------------------------------------
 * On AES < 3.0, returns 1024.
 * On AES 3.0-4.0, returns 4192.
 * On AES 4.0 and up, calls shel_get(NULL,-1),
 * which returns 0 on error or the size of the buffer.
 */
int
shel_glen(void)
{
    int ret = 1024;
    if (isAES4())
    {
	int_in[0] = -1;
	addr_in[0] = NULL;
	ret = aes(SHEL_GET);
    }
    else if (GL_VERS >= 0x0300)
	ret = 4192;

    return ret;
}

