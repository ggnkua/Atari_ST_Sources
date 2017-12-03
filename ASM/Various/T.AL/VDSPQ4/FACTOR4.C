/*
	factor.c
	
	precalc fir coeff
*/
#include <portab.h>
#include <stdio.h>
#include <math.h>

#include "vector.h"

#define DSP_FRAC ((double)(1L<<22))

/* Deriche factors */
float alpha;
double sa[4], sb[3], sk;	/* filter */
double da,    db[3], dk;	/* gradient */

void factor(float alpha)
{
	long dsp_sa[4], dsp_sb[3];	/* filter */
	long dsp_da,    dsp_db[3];	/* gradient */

	/* filter */
	sk= pow(1.0 - exp(-alpha), 2.0) 
	  / (1.0 + 2.0 * alpha * exp(-alpha) - exp(-2.0 * alpha));
	
	sa[0]= sk;
	sa[1]= sk * (alpha - 1.0) * exp(-alpha);
	sa[2]= sk * (alpha + 1.0) * exp(-alpha);
	sa[3]= -sk * exp(-2.0 * alpha);
	
	sb[1]= -2.0 * exp(-alpha);
	sb[2]= exp(-2.0 * alpha);

	dsp_sa[0]= sa[0] * DSP_FRAC;
	dsp_sa[1]= sa[1] * DSP_FRAC;
	dsp_sa[2]= sa[2] * DSP_FRAC;
	dsp_sa[3]= sa[3] * DSP_FRAC;
	dsp_sb[1]= sb[1] * DSP_FRAC;
	dsp_sb[2]= sb[2] * DSP_FRAC;

	/* select transfert mode */
	init_send_factor();

	/* send factors to dsp */
	send_factor(dsp_sa, 4);
	send_factor(&dsp_sb[1], 2);
		
	printf("\nfilter:\na0= %6.3f\na1= %6.3f\na2= %6.3f\na3= %6.3f\nb1= %6.3f\nb2= %6.3f\n",
	       (float)sa[0], (float)sa[1], (float)sa[2], (float)sa[3],
	       (float)sb[1], (float)sb[2]);
    
	/* gradient */
	dk= pow(1.0 - exp(-alpha), 2.0) / exp(-alpha);
	da= dk * exp(-alpha);
	db[1]= -2.0 * exp(-alpha);
	db[2]= exp(-2.0 * alpha);

	dsp_da= da * DSP_FRAC;
	dsp_db[1]= db[1] * DSP_FRAC;
	dsp_db[2]= db[2] * DSP_FRAC;
	
	/* send  factors to dsp */
	send_factor(&dsp_da, 1);
	send_factor(&dsp_db[1], 2);
	
	printf("\ngradient:\na = %6.3f\nb1= %6.3f\nb2= %6.3f\n",
	       (float)da, (float)db[1], (float)db[2]);
}
