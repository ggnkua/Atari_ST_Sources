/* evnt_rea.c - AES 4.0 evnt_read() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* evnt_read() - read a message if available.
 *-----------------------------------------------------------------------
 * This function can be used by applications which need to wait for
 * both MiNT and AES messages.
 * On AES < 4.0, it calls evnt_multi(MU_MESAG|MU_TIMER,...),
 * with a timer value of 0.
 * On AES >= 4.0, it calls the more efficient appl_read(-1,16,msg).
 * Returns AESFAIL (0) if no message was waiting, else returns > 0.
 */
int
evnt_read(WORD *msg)
{
    int ret;
    addr_in[0] = msg;
    if (isAES4())
    {
	int_in[0] = -1;
	int_in[1] = 16;
	ret = aes(APPL_READ);
    }
    else
    {
	int_in[0] = MU_MESAG|MU_TIMER;
	*(long *)&int_in[14] = 0L;
	ret = aes(EVNT_MULTI) & MU_MESAG;
    }
    return ret;
}

