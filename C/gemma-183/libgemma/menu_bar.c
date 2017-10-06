# include "extdef.h"

long
menu_bar(void *tree, short show)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = show;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 30);
}

/* EOF */
