# include "extdef.h"

/* as of AES 1.40 */

long
fsel_exinput(char *inpath, char *insel, short *exbutton, char *title)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)inpath;
	gem->addr_in[1] = (long)insel;
	gem->addr_in[2] = (long)title;

	r = call_aes(gem, 91);

	if (exbutton)
		*exbutton = gem->int_out[1];

	return r;
}

/* EOF */
