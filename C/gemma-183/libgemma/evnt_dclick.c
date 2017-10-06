# include "extdef.h"

long
evnt_dclick(short dnew, short dset)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = dnew;
	gem->int_in[1] = dset;

	return call_aes(gem, 26);
}

/* EOF */
