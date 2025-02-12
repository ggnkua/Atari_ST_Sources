
/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools rate change effect file.
 */

#include <math.h>
#include "st.h"

/*
 * Least Common Multiple Linear Interpolation 
 *
 * Find least common multiple of the two sample rates.
 * Construct the signal at the LCM by interpolating successive
 * input samples as straight lines.  Pull output samples from
 * this line at output rate.
 *
 * Of course, actually calculate only the output samples.
 *
 * LCM must be 32 bits or less.  Two prime number sample rates
 * between 32768 and 65535 will yield a 32-bit LCM, so this is 
 * stretching it.
 */

/*
 * Algorithm:
 *  
 *  Generate a master sample clock from the LCM of the two rates.
 *  Interpolate linearly along it.  Count up input and output skips.
 *
 *  Input:   |inskip |       |       |       |       |
 *                                                                      
 *                                                                      
 *                                                                      
 *  LCM:     |   |   |   |   |   |   |   |   |   |   |
 *                                                                      
 *                                                                      
 *                                                                      
 *  Output:  |  outskip  |           |           | 
 *
 *                                                                      
 */


/* Private data for Lerp via LCM file */
typedef struct ratestuff {
	u_l	lcmrate;		/* least common multiple of rates */
	u_l	inskip, outskip;	/* LCM increments for I & O rates */
	u_l	total;
	u_l	intot, outtot;		/* total samples in terms of LCM rate */
	long	lastsamp;
} *rate_t;

/*
 * Process options
 */
rate_getopts(effp, n, argv) 
eff_t effp;
int n;
char **argv;
{
	if (n)
		fail("Rate effect takes no options.");
}

/*
 * Prepare processing.
 */
rate_start(effp)
eff_t effp;
{
	rate_t rate = (rate_t) effp->priv;
	IMPORT long lcm();
	
	rate->lcmrate = lcm((long)effp->ininfo.rate, (long)effp->outinfo.rate);
	/* Cursory check for LCM overflow.  
	 * If both rate are below 65k, there should be no problem.
	 * 16 bits x 16 bits = 32 bits, which we can handle.
	 */
	rate->inskip = rate->lcmrate / effp->ininfo.rate;
	rate->outskip = rate->lcmrate / effp->outinfo.rate; 
	rate->total = rate->intot = rate->outtot = 0;
	rate->lastsamp = 0;
}

/*
 * Processed signed long samples from ibuf to obuf.
 * Return number of samples processed.
 */

rate_flow(effp, ibuf, obuf, isamp, osamp)
eff_t effp;
long *ibuf, *obuf;
int *isamp, *osamp;
{
	rate_t rate = (rate_t) effp->priv;
	int len, done;
	long *istart = ibuf;
	long last;

	done = 0;
	if (rate->total == 0) {
		/* Emit first sample.  We know the fence posts meet. */
		*obuf = *ibuf++;
		/* Count up until have right input samples */
			rate->lastsamp = *obuf++ >> 16;
		done = 1;
		rate->total = 1;
		/* advance to second output */
		rate->outtot += rate->outskip;
		/* advance input range to span next output */
		while ((rate->intot + rate->inskip) <= rate->outtot){
			last = *ibuf++ / 65536;
			rate->intot += rate->inskip;
		}
	}
	/* number of output samples the input can feed */
	len = (*isamp * rate->inskip) / rate->outskip;
	if (len > *osamp)
		len = *osamp;
	last = rate->lastsamp;
	for(; done < len; done++) {
		*obuf = last;
		*obuf += ((float)((*ibuf / 65536)  - last)* ((float)rate->outtot - 
				rate->intot))/rate->inskip;
		*obuf *= 65536;
		obuf++;
		/* advance to next output */
		rate->outtot += rate->outskip;
		/* advance input range to span next output */
		while ((rate->intot + rate->inskip) <= rate->outtot){
			last = *ibuf++ >> 16;
			rate->intot += rate->inskip;
			if (ibuf - istart == *isamp)
				goto out;
		}
		/* long samples with high LCM's overrun counters! */
		if (rate->outtot == rate->intot)
			rate->outtot = rate->intot = 0;
	}
out:
	*isamp = ibuf - istart;
	*osamp = len;
	rate->lastsamp = last;
}

/*
 * Do anything required when you stop reading samples.  
 * Don't close input file! 
 */
rate_stop(effp)
eff_t effp;
{
	/* nothing to do */
}

