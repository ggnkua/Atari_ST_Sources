# include "extdef.h"

long
evnt_timer(unsigned long timer)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = (short)timer;
	gem->int_in[1] = timer>>16;

	return call_aes(gem, 24);
}

/* EOF */
