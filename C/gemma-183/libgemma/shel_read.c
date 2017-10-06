# include "extdef.h"

long
shel_read(char *cmd, char *tail)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)cmd;
	gem->addr_in[1] = (long)tail;

	return call_aes(gem, 120);
}

/* EOF */
