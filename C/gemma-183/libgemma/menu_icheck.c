# include "extdef.h"

long
menu_icheck(void *tree, short item, short check)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = item;
	gem->int_in[1] = check;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 31);
}

/* EOF */
