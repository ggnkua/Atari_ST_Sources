# include "extdef.h"

long
evnt_button(short bclicks, short bmask, short bstate, \
		short *mx, short *my, short *bbutton, short *kstate)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = bclicks;
	gem->int_in[1] = bmask;
	gem->int_in[2] = bstate;

	r = call_aes(gem, 24);

	if (mx)
		*mx = gem->int_out[1];
	if (my)
		*my = gem->int_out[2];
	if (bbutton)
		*bbutton = gem->int_out[3];
	if (kstate)
		*kstate = gem->int_out[4];

	return r;
}

/* EOF */
