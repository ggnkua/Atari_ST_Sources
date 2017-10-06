# include "extdef.h"

long
evnt_multi(short mflags, short mbclicks, short mbmask, short mbstate, \
	short mm1flags, short mm1x, short mm1y, short mm1w, short mm1h, \
	short mm2flags, short mm2x, short mm2y, short mm2w, short mm2h, \
	short *mmgpbuff, unsigned long count, short *mmox, short *mmoy, \
	short *mmobut, short *mmokstate, short *mkreturn, short *mbreturn)
{
	long r;
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->int_in[0] = mflags;
	gem->int_in[1] = mbclicks;
	gem->int_in[2] = mbmask;
	gem->int_in[3] = mbstate;
	gem->int_in[4] = mm1flags;
	gem->int_in[5] = mm1x;
	gem->int_in[6] = mm1y;
	gem->int_in[7] = mm1w;
	gem->int_in[8] = mm1h;
	gem->int_in[9] = mm2flags;
	gem->int_in[10] = mm2x;
	gem->int_in[11] = mm2y;
	gem->int_in[12] = mm2w;
	gem->int_in[13] = mm2h;
	gem->int_in[14] = (short)count;
	gem->int_in[15] = (short)(count>>16);

	gem->addr_in[0] = (long)mmgpbuff;

	r = call_aes(gem, 25);

	if (mmox)
		*mmox = gem->int_out[1];
	if (mmoy)
		*mmoy = gem->int_out[2];
	if (mmobut)
		*mmobut = gem->int_out[3];
	if (mmokstate)
		*mmokstate = gem->int_out[4];
	if (mkreturn)
		*mkreturn = gem->int_out[5];
	if (mbreturn)
		*mbreturn = gem->int_out[6];

	return r;
}

/* EOF */
