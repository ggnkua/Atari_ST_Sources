# include "extdef.h"

long
menu_register(short apid, char *text)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = apid;
	gem->addr_in[0] = (long)text;

	return call_aes(gem, 35);
}

/* EOF */
