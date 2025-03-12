
/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools Low-Pass effect file.
 *
 * Algorithm:  1nd order filter.
 * From Fugue source code:
 *
 * 	output[N] = input[N] * A + input[N-1] * B
 *
 * 	A = 2.0 * pi * center
 * 	B = exp(-A / frequency)
 */

#include <math.h>
#include "st.h"

/* Private data for Lowpass effect */
typedef struct lowpstuff {
	float	center;
	double	A, B;
	double	in1;
} *lowp_t;

/*
 * Process options
 */
lowp_getopts(effp, n, argv) 
eff_t effp;
int n;
char **argv;
{
	lowp_t lowp = (lowp_t) effp->priv;

	if ((n < 1) || !sscanf(argv[0], "%f", &lowp->center))
		fail("Usage: lowp center");
}

/*
 * Prepare processing.
 */
lowp_start(effp)
eff_t effp;
{
	lowp_t lowp = (lowp_t) effp->priv;
	if (lowp->center > effp->ininfo.rate*2)
		fail("Lowpass: center must be < minimum data rate*2\n");

	lowp->A = (M_PI * 2.0 * lowp->center) / effp->ininfo.rate;
	lowp->B = exp(-lowp->A / effp->ininfo.rate);
	lowp->in1 = 0.0;
}

/*
 * Processed signed long samples from ibuf to obuf.
 * Return number of samples processed.
 */

lowp_flow(effp, ibuf, obuf, isamp, osamp)
eff_t effp;
long *ibuf, *obuf;
int *isamp, *osamp;
{
	lowp_t lowp = (lowp_t) effp->priv;
	int len, done;
	double d;
	long l;

	len = ((*isamp > *osamp) ? *osamp : *isamp);

	/* yeah yeah yeah registers & integer arithmetic yeah yeah yeah */
	for(done = 0; done < len; done++) {
		l = *ibuf++;
		d = lowp->A * (l / 65536) + lowp->B * (lowp->in1 / 65536);
		d *= 0.8;
		if (d > 32767)
			d = 32767;
		if (d < - 32767)
			d = - 32767;
		lowp->in1 = l;
		*obuf++ = d * 65536;
	}
}

/*
 * Do anything required when you stop reading samples.  
 * Don't close input file! 
 */
lowp_stop(effp)
eff_t effp;
{
	/* nothing to do */
}

