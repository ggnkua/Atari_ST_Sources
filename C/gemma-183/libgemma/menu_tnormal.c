# include "extdef.h"

long
menu_tnormal(void *tree, short title, short normal)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = title;
	gem->int_in[1] = normal;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 33);
}

/* EOF */
