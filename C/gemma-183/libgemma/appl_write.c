# include "extdef.h"

long
appl_write(short id, short len, void *buf)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = id;
	gem->int_in[1] = len;
	gem->addr_in[0] = (long)buf;

	return call_aes(gem, 12);
}

/* EOF */
