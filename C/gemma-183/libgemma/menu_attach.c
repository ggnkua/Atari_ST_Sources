# include "extdef.h"

/* as of AES 3.30 (Falcon TOS) */

long
menu_attach(short flag, OBJECT *tree, short item, MENU *data)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = flag;
	gem->int_in[1] = item;
	gem->addr_in[0] = (long)tree;
	gem->addr_in[1] = (long)data;

	return (long)call_aes(gem, 37);
}

/* EOF */
