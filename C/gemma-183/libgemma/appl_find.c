# include "extdef.h"

long
appl_find(char *name)
{
# ifdef GEMMA_MULTIPROC
	gem = gem_control();
# endif
	gem->addr_in[0] = (long)name;

	return call_aes(gem, 13);
}

/* EOF */
