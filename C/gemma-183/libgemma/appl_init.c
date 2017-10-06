# include "extdef.h"

long
appl_init(void)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif

	return call_aes(gem, 10);
}

/* EOF */
