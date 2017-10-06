# include "extdef.h"

/* as of AES 4.0 when appl_getinfo() indicates */

long
appl_control(short cid, short cwhat, void *out)
{
# ifdef GEMMA_MULTIPROC
	gem = gem_control();
# endif
	gem->int_in[0] = cid;
	gem->int_in[1] = cwhat;
	gem->addr_in[0] = (long)out;

	return call_aes(gem, 129);
}

/* EOF */
