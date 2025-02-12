/******************************************************************************
*                                                                             *
*       Copyright (C) 1992,1993,1994 Tony Robinson                            *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

# include <math.h>
# include <stdio.h>
# include <stdlib.h>
# include "shorten.h"

/* watch out, these are all 0 .. order inclusive arrays */

# define E_BITS_PER_COEF (2 + LPCQUANT)

int wav2lpc(buf, nbuf, offset, qlpc, nlpc, version, psigbit, presbit) 
	long *buf; int nbuf; long offset; int *qlpc, nlpc, version;
	float *psigbit, *presbit; {
  static float *fbuf = NULL;
  static int nflpc = 0, nfbuf = 0;
  int   i, j, bestnbit, bestnlpc;
  float e = 0.0, bestesize, ci, esize;
  float acf[MAX_LPC_ORDER + 1];
  float ref[MAX_LPC_ORDER + 1];
  float lpc[MAX_LPC_ORDER + 1];
  float tmp[MAX_LPC_ORDER + 1];
  float escale = 0.5 * M_LN2 * M_LN2 / nbuf;

  /* if necessary, limit the LPC order to the number of samples available */
  if(nlpc >= nbuf) nlpc = nbuf - 1;

  /* grab some space for a 'zero mean' buffer of floats if needed */
  if(nlpc > nflpc || nbuf > nfbuf) {
    if(fbuf != NULL) free(fbuf - nflpc);
    fbuf  = ((float*) pmalloc((nlpc + nbuf) * sizeof(*fbuf))) + nlpc;
    nfbuf = nbuf;
    nflpc = nlpc;
  }

  /* zero mean signal and compute energy */
  for(j = 0; j < nbuf; j++) {
    float tmp = fbuf[j] = buf[j] - offset;
    e += tmp * tmp;
  }

  /* compute the estimated number of bits per sample */
  if(e > 0.0)
    esize = 0.5 * log(escale * e) / M_LN2;
  else
    esize = 0.0;

  /* return the expected number of bits per original signal sample */
  *psigbit  = esize;

  /* store the best values so far (the zeroth order predictor) */
  acf[0]    = e;
  bestnlpc  = 0;
  bestnbit  = nbuf * esize;
  bestesize = esize;

  /* check all linear predictors up to and including length nlpc */
  /* if version is 2 or greater, just check two more than bestnlpc */
  for(i = 1; i <= nlpc && e > 0.0 && (version < 12 || i <= bestnlpc + 2); i++){
    float sum = 0.0;

    /* compute the jth autocorrelation coefficient */
    for(j = i; j < nbuf; j++)
      sum += fbuf[j] * fbuf[j - i];
    acf[i] = sum;

    /* compute the reflection and LP coeffients for order j predictor */
    ci = 0.0;
    for(j = 1; j < i; j++) ci += lpc[j] * acf[i - j];
    ref[i] = ci = (acf[i] - ci) / e;
    lpc[i] = ci;
    for(j = 1; j < i; j++) tmp[j] = lpc[j] - ci * lpc[i - j];
    for(j = 1; j < i; j++) lpc[j] = tmp[j];

    /* compute the new energy in the prediction residual */
    e = (1 - ci * ci) * e;
    if(e > 0.0)
      esize = 0.5 * log(escale * e) / M_LN2;
    else
      esize = 0.0;

    /* store this model if it is the best so far */
    if(nbuf * esize + i * E_BITS_PER_COEF < bestnbit) {

      /* store best model order */
      bestnlpc  = i;
      bestnbit  = nbuf * esize + i * E_BITS_PER_COEF;
      bestesize = esize;

      /* store the quantised LP coefficients */
      for(j = 0; j < bestnlpc; j++)
	qlpc[j] = lpc[j + 1] * (1 << LPCQUANT);
    }
  }

  /* return the expected number of bits per residual signal sample */
  *presbit = bestesize;

  /* return the best model order */
  return(bestnlpc);
}
