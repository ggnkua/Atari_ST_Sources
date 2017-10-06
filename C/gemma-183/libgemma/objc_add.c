# include "extdef.h"

long
objc_add(void *tree, short parent, short child)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = parent;
	gem->int_in[1] = child;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 40);
}

/* EOF */
