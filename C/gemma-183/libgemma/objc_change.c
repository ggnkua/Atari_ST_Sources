# include "extdef.h"

long
objc_change(void *tree, short obj, short res, \
		short wx, short wy, short ww, short wh, \
			short newst, short redraw)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = obj;
	gem->int_in[1] = res;
	gem->int_in[2] = wx;
	gem->int_in[3] = wy;
	gem->int_in[4] = ww;
	gem->int_in[5] = wh;
	gem->int_in[6] = newst;
	gem->int_in[7] = redraw;
	gem->addr_in[0] = (long)tree;

	return call_aes(gem, 47);
}

/* EOF */
