# include "extdef.h"

long
evnt_mouse(short mof, short mox, short moy, short mow, short moh, \
		short *momx, short *momy, short *mobutton, short *mokstate)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = mof;
	gem->int_in[1] = mox;
	gem->int_in[2] = moy;
	gem->int_in[3] = mow;
	gem->int_in[4] = moh;

	r = call_aes(gem, 22);

	if (momx)
		*momx = gem->int_out[1];
	if (momy)
		*momy = gem->int_out[2];
	if (mobutton)
		*mobutton = gem->int_out[3];
	if (mokstate)
		*mokstate = gem->int_out[4];

	return r;
}

/* EOF */
