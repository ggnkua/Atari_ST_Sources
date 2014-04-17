/* shel_run.c - AES 4.0 shel_run() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* shel_run(): run a program concurrently
 *-----------------------------------------------------------------------
 * On AES < 4.0, returns AESERR (-1)
 * On AES >= 4.0, returns child process' AES id, or AESFAIL (0).
 */
int
shel_run(int mode, int isgem, int useargv, SH_RUN *p, const char *args)
{
	if (!isAES4()) return AESERR;
	int_in[0] = mode;
	int_in[1] = isgem;
	int_in[2] = useargv;
	addr_in[0] = (mode & 0xff00) ? (void *)p : (void *)p->cmd;
	addr_in[1] = (char *)args;
	return aes(SHEL_WRITE);
}
