# include "extdef.h"

/* Mag!X 4.0 function, emulated by the library */

long
form_popup(OBJECT *pop, short xp, short yp)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = xp;
	gem->int_in[1] = yp;
	gem->addr_in[0] = (long)pop;

	return (long)call_aes(gem, 135);
}

/* EOF */
