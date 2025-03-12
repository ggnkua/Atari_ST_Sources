
/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools Vibro effect file.
 *
 * Modeled on world-famous Fender(TM) Amp Vibro knobs.
 * 
 * Algorithm: generate a sine wave ranging from
 * 0 + depth to 1.0, where signal goes from -1.0 to 1.0.
 * Multiply signal with sine wave.  I think.
 */

#include <math.h>
#include "st.h"

/* Private data for Vibro effect */
typedef struct vibrostuff {
	float 		speed;
	float 		depth;
	short		*sinetab;		/* sine wave to apply */
	int		mult;			/* multiplier */
	unsigned	length;			/* length of table */
	int		counter;		/* current counter */
} *vibro_t;

/*
 * Process options
 */
vibro_getopts(effp, n, argv) 
eff_t effp;
int n;
char **argv;
{
	vibro_t vibro = (vibro_t) effp->priv;

	vibro->depth = 0.5;
	if ((n == 0) || !sscanf(argv[0], "%f", &vibro->speed) ||
		((n == 2) && !sscanf(argv[1], "%f", &vibro->depth)))
		fail("Usage: vibro speed [ depth ]");
	if ((vibro->speed <= 0.001) || (vibro->speed > 30.0) || 
			(vibro->depth < 0.0) || (vibro->depth > 1.0))
		fail("Vibro: speed must be < 30.0, 0.0 < depth < 1.0");
}

/*
 * Prepare processing.
 */
vibro_start(effp)
eff_t effp;
{
	vibro_t vibro = (vibro_t) effp->priv;

	vibro->length = effp->ininfo.rate / vibro->speed;
	if (! (vibro->sinetab = (short*) malloc(vibro->length * sizeof(short))))
		fail("Vibro: Cannot malloc %d bytes",
			vibro->length * sizeof(short));

	sine(vibro->sinetab, vibro->length, vibro->depth);
	vibro->counter = 0;
}

/*
 * Processed signed long samples from ibuf to obuf.
 * Return number of samples processed.
 */

vibro_flow(effp, ibuf, obuf, isamp, osamp)
eff_t effp;
long *ibuf, *obuf;
int *isamp, *osamp;
{
	vibro_t vibro = (vibro_t) effp->priv;
	register counter, tablen;
	int len, done;
	register short *sinetab;
	long l;

	len = ((*isamp > *osamp) ? *osamp : *isamp);

	sinetab = vibro->sinetab;
	counter = vibro->counter;
	tablen = vibro->length;
	for(done = 0; done < len; done++) {
		l = *ibuf++;
		/* 24x8 gives 32-bit result */
		*obuf++ = ((l / 256) * sinetab[counter++ % tablen]);
	}
	vibro->counter = counter;
	/* processed all samples */
}

/*
 * Do anything required when you stop reading samples.  
 * Don't close input file! 
 */
vibro_stop(effp)
eff_t effp;
{
	/* nothing to do */
}

/* This was very painful.  We need a sine library. */

sine(buf, len, depth)
short *buf;
int len;
float depth;
{
	int i;
	int scale = depth * 128;
	int base = (1.0 - depth) * 128;
	double val;

	for (i = 0; i < len; i++) {
		val = sin((float)i/(float)len * 2.0 * M_PI);
		buf[i] = (val + 1.0) * scale + base * 2;
	}
/*
	for (i = 0; i < len; i++)
		fprintf(stderr, "%d\n", buf[i]);
*/
}




