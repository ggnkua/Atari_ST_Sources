# include "extdef.h"

long
shel_get(char *buf, short len)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = len;
	gem->addr_in[0] = (long)buf;

	return call_aes(gem, 122);
}

/* EOF */
