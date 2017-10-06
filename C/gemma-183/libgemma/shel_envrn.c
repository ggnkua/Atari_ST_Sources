# include "extdef.h"

long
shel_envrn(char **out, char *arg)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)out;
	gem->addr_in[1] = (long)arg;

	return call_aes(gem, 125);
}

/* EOF */
