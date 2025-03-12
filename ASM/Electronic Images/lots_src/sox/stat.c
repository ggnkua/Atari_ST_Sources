
/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools statistics "effect" file.
 *
 * Build various statistics on file and print them.
 * No output.
 */

#include "st.h"

/* Private data for STAT effect */
typedef struct statstuff {
	long	min, max, mean;		/* amplitudes */
	long	dmin, dmax, dmean;	/* deltas */
	long	last;			/* previous sample */
	int	first;
	int	total;
	int	volume;
        unsigned long bin[4];
} *stat_t;

#define	abs(val)	(((val) < 0) ? -(val) : (val))

/*
 * Process options
 */
stat_getopts(effp, n, argv) 
eff_t effp;
int n;
char **argv;
{
	stat_t stat = (stat_t) effp->priv;

	stat->volume = 0;
	if (n)
		if (strcmp(argv[0], "-V"))
			stat->volume = 1;
		else
			fail("Summary effect takes no options.");
}

/*
 * Prepare processing.
 */
stat_start(effp)
eff_t effp;
{
	stat_t stat = (stat_t) effp->priv;
        int i;

	stat->min = stat->dmin = 0x7fffffff;
	stat->max = stat->dmax = 0x80000000;
	stat->first = 1;

        for (i = 0; i < 4; i++)
                stat->bin[i] = 0;
}

/*
 * Processed signed long samples from ibuf to obuf.
 * Return number of samples processed.
 */

stat_flow(effp, ibuf, obuf, isamp, osamp)
eff_t effp;
long *ibuf, *obuf;
int *isamp, *osamp;
{
	stat_t stat = (stat_t) effp->priv;
	int len, done;
	long samp, delta;

	len = ((*isamp > *osamp) ? *osamp : *isamp);
	for(done = 0; done < len; done++) {
		/* work in absolute levels for both sample and delta */
		samp = *ibuf++;
	        *obuf++ = samp;

                stat->bin[RIGHT(samp,30)+2]++;

		samp = abs(samp);
		if (samp < stat->min)
			stat->min = samp;
		if (samp > stat->max)
			stat->max = samp;
		if (stat->first) {
			stat->first = 0;
			stat->mean = samp;
			stat->dmean = 0;
		} else  {
			/* overflow avoidance */
			if ((stat->mean > 0x20000000) || (samp > 0x20000000))
				stat->mean = stat->mean/2 + samp/2;
			else
				stat->mean = (stat->mean + samp)/2;

			delta = abs(samp - stat->last);
			if (delta < stat->dmin)
				stat->dmin = delta;
			if (delta > stat->dmax)
				stat->dmax = delta;
			/* overflow avoidance */
			if ((delta > 0x20000000) || (stat->dmean > 0x20000000))
				stat->dmean = stat->dmean/2 + delta/2;
			else
				stat->dmean = (stat->dmean + delta)/2;
		}
		stat->last = samp;
	}
	/* Process all samples */
}

/*
 * Do anything required when you stop reading samples.  
 * Don't close input file! 
 */
void
stat_stop(effp)
eff_t effp;
{
	stat_t stat = (stat_t) effp->priv;
	double amp, range;
        float x;

	stat->min   = RIGHT(stat->min, 16);
	stat->max   = RIGHT(stat->max, 16);
	stat->mean  = RIGHT(stat->mean, 16);
	stat->dmin  = RIGHT(stat->dmin, 16);
	stat->dmax  = RIGHT(stat->dmax, 16);
	stat->dmean = RIGHT(stat->dmean, 16);

	range = 32767.0;

	amp = - stat->min;
	if (amp < stat->max)
		amp = stat->max;
	/* Just print the volume adjustment */
	if (stat->volume) {
		fprintf(stderr, "%.3f\n", 32767.0/amp);
		return;
	}
	/* print them out */
	fprintf(stderr, "Maximum amplitude: %.3f\n", stat->max/range);
	fprintf(stderr, "Minimum amplitude: %.3f\n", stat->min/range);
	fprintf(stderr, "Mean    amplitude: %.3f\n", stat->mean/range);

	fprintf(stderr, "Maximum delta:     %.3f\n", stat->dmax/range);
	fprintf(stderr, "Minimum delta:     %.3f\n", stat->dmin/range);
	fprintf(stderr, "Mean    delta:     %.3f\n", stat->dmean/range);

	fprintf(stderr, "Volume adjustment: %.3f\n", 32767.0/amp);

        if (stat->bin[2] == 0 && stat->bin[3] == 0)
                fprintf(stderr, "\nProbably text, not sound\n");
        else {

                x = (float)(stat->bin[0] + stat->bin[3]) / (float)(stat->bin[1] + stat->bin[2]);

                if (x >= 3.0)                        /* use opposite style */
                        if (effp->ininfo.style == UNSIGNED)
                                printf ("\nTry: -t raw -b -s \n");
                        else
                                printf ("\nTry: -t raw -b -u \n");

                else if (x <= 1.0/3.0);              /* correctly decoded */

                else if (x >= 0.5 && x <= 2.0)       /* use ULAW */
                        if (effp->ininfo.style == ULAW)
                                printf ("\nTry: -t raw -b -u \n");
                        else
                                printf ("\nTry: -t raw -b -U \n");

                else    
                        fprintf (stderr, "\nCan't guess the type\n");
        }

}

