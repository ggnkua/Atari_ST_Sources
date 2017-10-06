# include "extdef.h"

/* as of AES 3.30 (Falcon TOS) */

long
menu_istart(short flag, OBJECT *tree, short imenu, short item)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = flag;
	gem->int_in[1] = imenu;
	gem->int_in[2] = item;
	gem->addr_in[0] = (long)tree;

	return (long)call_aes(gem, 38);
}

/* EOF */
