
/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools stereo/quad -> mono mixdown effect file.
 *
 * Does not mix up to more channels.
 *
 * What's in a center channel?
 */

#include "st.h"

/* Private data for SKEL file */
typedef struct avgstuff {
	int	mix;			/* How are we mixing it? */
} *avg_t;

#define MIX_CENTER	0
#define MIX_LEFT	1
#define MIX_RIGHT	2

/*
 * Process options
 */
avg_getopts(effp, n, argv) 
eff_t effp;
int n;
char **argv;
{
	avg_t avg = (avg_t) effp->priv;

	avg->mix = MIX_CENTER;
	if (n)
		if(!strcmp(argv[0], "-l"))
			avg->mix = MIX_LEFT;
		else if (!strcmp(argv[0], "-r"))
			avg->mix = MIX_RIGHT;
		else
			fail("Averaging effect takes options '-l' or '-r'.");
}

/*
 * Start processing
 */
void
avg_start(effp)
eff_t effp;
{
	switch (effp->outinfo.channels) {
		case 1: switch (effp->ininfo.channels) {
			case 2: 
			case 4:
				return;
		}
		case 2: switch (effp->ininfo.channels) {
			case 4:
				return;
		}
	}
	fail("Can't average %d channels into %d channels",
		effp->ininfo.channels, effp->outinfo.channels);
}

/*
 * Process either isamp or osamp samples, whichever is smaller.
 */

avg_flow(effp, ibuf, obuf, isamp, osamp)
eff_t effp;
long *ibuf, *obuf;
int *isamp, *osamp;
{
	avg_t avg = (avg_t) effp->priv;
	int len, done;
	
	switch (effp->outinfo.channels) {
		case 1: switch (effp->ininfo.channels) {
			case 2:
				len = ((*isamp/2 > *osamp) ? *osamp : *isamp/2);
				for(done = 0; done < len; done++) {
					switch(avg->mix) {
					    case MIX_CENTER:
						*obuf++ = ibuf[0]/2 + ibuf[1]/2;
						break;
					    case MIX_LEFT:
						*obuf++ = ibuf[0];
						break;
					    case MIX_RIGHT:
						*obuf++ = ibuf[1];
						break;
					}
					ibuf += 2;
				}
				*isamp = len * 2;
				*osamp = len;
				break;
			case 4:
				len = ((*isamp/4 > *osamp) ? *osamp : *isamp/4);
				for(done = 0; done < len; done++) {
					*obuf++ = ibuf[0]/4 + ibuf[1]/4 +
						ibuf[2]/4 + ibuf[3]/4;
					ibuf += 4;
				}
				*isamp = len * 4;
				*osamp = len;
				break;
				
		}
		break;
		case 2: switch (effp->ininfo.channels) {
			/*
			 * After careful inspection of CSOUND source code,
			 * I'm mildly sure the order is:
			 * 	front-left, front-right, rear-left, rear-right
			 */
			case 4:
				len = ((*isamp/2 > *osamp) ? *osamp : *isamp/2);
				len &= ~1;
				for(done = 0; done < len; done++) {
					obuf[0] = ibuf[0]/2 + ibuf[2]/2;
					obuf[1] = ibuf[1]/2 + ibuf[3]/2;
					ibuf += 4;
					obuf += 2;
				}
				*isamp = len * 2;
				*osamp = len;
				break;
		}
	}
}

/*
 * Do anything required when you stop reading samples.  
 * Don't close input file! 
 *
 * Should have statistics on right, left, and output amplitudes.
 */
avg_stop(effp)
eff_t effp;
{
	/* nothing to do */
}

