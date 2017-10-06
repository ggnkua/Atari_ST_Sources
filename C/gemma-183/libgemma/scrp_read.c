# include "extdef.h"

long
scrp_read(char *scrap)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)scrap;

	return call_aes(gem, 80);
}

/* EOF */
