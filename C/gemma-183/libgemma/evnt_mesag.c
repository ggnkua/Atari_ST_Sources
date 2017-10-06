# include "extdef.h"

long
evnt_mesag(short *msgbuf)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)msgbuf;

	return call_aes(gem, 23);
}

/* EOF */
