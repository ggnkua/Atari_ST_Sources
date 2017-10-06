# include "extdef.h"

long
shel_find(char *buf)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)buf;

	return call_aes(gem, 124);
}

/* EOF */
