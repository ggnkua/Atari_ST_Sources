# include "extdef.h"

/* N.AES function */

long
objc_xfind(OBJECT *tree, short start, short depth, short mx, short my)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = start;
	gem->int_in[1] = depth;
	gem->int_in[2] = mx;
	gem->int_in[3] = my;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 49);
}

/* EOF */
