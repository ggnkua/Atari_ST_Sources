# include "extdef.h"

/* as of AES 4.0 when appl_getinfo() indicates */

long
appl_search(short mode, char *fname, short *type, short *apid)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = mode;
	gem->addr_in[0] = (long)fname;

	r = call_aes(gem, 18);

	*type = gem->int_out[1];
	*apid = gem->int_out[2];

	return r;
}

/* EOF */
