# include "extdef.h"

long
objc_draw(void *tree, short obj, short depth, short wx, short wy, short ww, short wh)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)tree;
	gem->int_in[0] = obj;
	gem->int_in[1] = depth;
	gem->int_in[2] = wx;
	gem->int_in[3] = wy;
	gem->int_in[4] = ww;
	gem->int_in[5] = wh;

	return call_aes(gem, 42);
}

/* EOF */
