/******************************************************************************
*                                                                             *
*       Copyright (C) 1992,1993,1994 Tony Robinson                            *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

# include <math.h>
# include <stdio.h>
# include "shorten.h"

# define ALPHA0 (3.0 / 2.0)
# define ALPHA1 M_LN2

int wav2poly(buf, nbuf, offset, version, psigbit, presbit) long *buf; int nbuf;
	long offset; int version; float *psigbit, *presbit; {
  long  sum0 = 0, sum1 = 0, sum2 = 0, sum3 = 0, sum;
  long  last0 = buf[-1] - offset;
  long  last1 = buf[-1] - buf[-2];
  long  last2 = last1 - (buf[-2] - buf[-3]);
  float alpha = (version == 0) ? ALPHA0 : ALPHA1;
  int   i, fnd;

  for(i = 0; i < nbuf; i++) {
    long diff0, diff1, diff2;

    sum0 += labs(diff0 = buf[i] - offset);
    sum1 += labs(diff1 = diff0 - last0);
    sum2 += labs(diff2 = diff1 - last1);
    sum3 += labs(        diff2 - last2);

    last0 = diff0;
    last1 = diff1;
    last2 = diff2;
  }

  if(sum0 < MIN(MIN(sum1, sum2), sum3)) {
    sum = sum0;
    fnd = FN_DIFF0;
  }
  else if(sum1 < MIN(sum2, sum3)) {
    sum = sum1;
    fnd = FN_DIFF1;
  }
  else if(sum2 < sum3) {
    sum = sum2;
    fnd = FN_DIFF2;
  }
  else {
    sum = sum3;
    fnd = FN_DIFF3;
  }

  /* return the expected number of bits per original signal sample */
  *psigbit = (sum0 > 0) ? log(alpha * sum0 / (double) nbuf) / M_LN2 : 0.0;

  /* return the expected number of bits per residual signal sample */
  *presbit = (sum  > 0) ? log(alpha * sum  / (double) nbuf) / M_LN2 : 0.0;

  return(fnd);
}

