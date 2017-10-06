# include "extdef.h"

long
menu_ienable(void *tree, short item, short enable)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = item;
	gem->int_in[1] = enable;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 32);
}

/* EOF */
