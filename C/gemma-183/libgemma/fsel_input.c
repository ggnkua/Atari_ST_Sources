# include "extdef.h"

long
fsel_input(char *inpath, char *insel, short *exbutton)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)inpath;
	gem->addr_in[1] = (long)insel;

	r = call_aes(gem, 90);

	if (exbutton)
		*exbutton = gem->int_out[1];

	return r;
}

/* EOF */
