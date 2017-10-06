# include "extdef.h"

long
objc_order(void *tree, short obj, short newpos)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = obj;
	gem->int_in[1] = newpos;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 45);
}

/* EOF */
