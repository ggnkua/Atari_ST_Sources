# include "extdef.h"

/* N.AES function */

long
shel_help(short mode, char *file, char *key)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = mode;
	gem->addr_in[0] = (long)file;
	gem->addr_in[1] = (long)key;

	return call_aes(gem, 128);
}

/* EOF */
