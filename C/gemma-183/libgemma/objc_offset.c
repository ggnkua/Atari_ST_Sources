# include "extdef.h"

long
objc_offset(void *tree, short obj, short *xo, short *yo)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = obj;
	gem->addr_in[0] = (long)tree;

	r = call_aes(gem, 44);

	if (xo)
		*xo = gem->int_out[1];
	if (yo)
		*yo = gem->int_out[2];

	return r;
}

/* EOF */
