# include "extdef.h"

long
menu_text(void *tree, short item, char *text)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = item;
	gem->addr_in[0] = (long)tree;
	gem->addr_in[1] = (long)text;

	return call_aes(gem, 34);
}

/* EOF */
