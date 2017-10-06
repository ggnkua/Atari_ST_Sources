# include "extdef.h"

/* as of AES 4.0 (MultiTOS 1.04) */

long
appl_getinfo(short cwhat, \
		short *out1, short *out2, short *out3, short *out4)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;
# endif
	long r;

# ifdef GEMMA_MULTIPROC
	gem = gem_control();
# endif
	gem->int_in[0] = cwhat;

	r = call_aes(gem, 130);

	*out1 = gem->int_out[1];
	*out2 = gem->int_out[2];
	*out3 = gem->int_out[3];
	*out4 = gem->int_out[4];

	return r;
}

/* EOF */
