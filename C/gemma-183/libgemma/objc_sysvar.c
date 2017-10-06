# include "extdef.h"

/* as of AES 3.40 */

long
objc_sysvar(short mode, short which, short in1, short in2, short *out1, short *out2)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = mode;
	gem->int_in[1] = which;
	gem->int_in[2] = in1;
	gem->int_in[3] = in2;

	r = call_aes(gem, 48);

	if (out1)
		*out1 = gem->int_out[1];
	if (out2)
		*out2 = gem->int_out[2];

	return r;
}

/* EOF */
