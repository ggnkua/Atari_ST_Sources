# include "extdef.h"

long
shel_write(short mode, short wisgr, short wiscr, void *cmd, char *tail)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = mode;
	gem->int_in[1] = wisgr;
	gem->int_in[2] = wiscr;
	gem->addr_in[0] = (long)cmd;
	gem->addr_in[1] = (long)tail;

	return call_aes(gem, 121);
}

/* EOF */
