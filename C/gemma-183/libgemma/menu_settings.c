# include "extdef.h"

/* as of AES 3.30 (Falcon TOS) */

long
menu_settings(short flag, MN_SET *values)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = flag;
	gem->addr_in[0] = (long)values;

	return (long)call_aes(gem, 39);
}

/* EOF */
