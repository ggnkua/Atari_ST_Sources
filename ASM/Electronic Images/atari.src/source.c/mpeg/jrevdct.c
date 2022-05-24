/*
 * jrevdct.c
 *
 */

#include <string.h>
#include "video.h"
#include "proto.h"

#define GLOBAL                  /* a function referenced thru EXTERNs */

#define FIX_1_082392200  (277)		/* FIX(1.082392200) */
#define FIX_1_414213562  (362)		/* FIX(1.414213562) */
#define FIX_1_847759065  (473)		/* FIX(1.847759065) */
#define FIX_2_613125930  (669)		/* FIX(2.613125930) */

#define MULTIPLY(x,y) (((x)*(y))>> 8)


void j_rev_dct (short *block)
{
  int tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  int tmp10, tmp11, tmp12, tmp13;
  int z5, z10, z11, z12, z13;
  int ctr;
  short *inptr=block;

  /* Pass 1: process columns from input, store into work array. */

  for (ctr = DCTSIZE; ctr > 0; ctr--) {
    if ((inptr[DCTSIZE*1] | inptr[DCTSIZE*2] | inptr[DCTSIZE*3] |
	 inptr[DCTSIZE*4] | inptr[DCTSIZE*5] | inptr[DCTSIZE*6] |
	 inptr[DCTSIZE*7]) == 0) {
      int dcval = (int) inptr[DCTSIZE*0];
      inptr[DCTSIZE*0] = dcval;
      inptr[DCTSIZE*1] = dcval;
      inptr[DCTSIZE*2] = dcval;
      inptr[DCTSIZE*3] = dcval;
      inptr[DCTSIZE*4] = dcval;
      inptr[DCTSIZE*5] = dcval;
      inptr[DCTSIZE*6] = dcval;
      inptr[DCTSIZE*7] = dcval;
      inptr++;
      continue;
    } 

    /* Even part */

    tmp10 = inptr[DCTSIZE*0] + inptr[DCTSIZE*4];	/* phase 3 */
    tmp11 = inptr[DCTSIZE*0] - inptr[DCTSIZE*4];
    tmp13 = inptr[DCTSIZE*2] + inptr[DCTSIZE*6];	/* phases 5-3 */
    tmp12 = MULTIPLY(inptr[DCTSIZE*2] - inptr[DCTSIZE*6], FIX_1_414213562) - tmp13; /* 2*c4 */
    tmp0 = tmp10 + tmp13;	/* phase 2 */
    tmp3 = tmp10 - tmp13;
    tmp1 = tmp11 + tmp12;
    tmp2 = tmp11 - tmp12;
    z13 = inptr[DCTSIZE*5] + inptr[DCTSIZE*3];		/* phase 6 */
    z11 = inptr[DCTSIZE*1] + inptr[DCTSIZE*7];
    tmp7 = z11 + z13;		/* phase 5 */
    tmp11 = MULTIPLY(z11 - z13, FIX_1_414213562); /* 2*c4 */
    z10 = inptr[DCTSIZE*5] - inptr[DCTSIZE*3];
    z12 = inptr[DCTSIZE*1] - inptr[DCTSIZE*7];
    inptr[DCTSIZE*0] = (tmp0 + tmp7);
    inptr[DCTSIZE*7] = (tmp0 - tmp7);
    z5 = MULTIPLY(z10 + z12, FIX_1_847759065); /* 2*c2 */
    tmp10 = MULTIPLY(z12, FIX_1_082392200) - z5; /* 2*(c2-c6) */
    tmp12 = MULTIPLY(z10, - FIX_2_613125930) + z5; /* -2*(c2+c6) */
    tmp6 = tmp12 - tmp7;	/* phase 2 */
    inptr[DCTSIZE*1] = (tmp1 + tmp6);
    inptr[DCTSIZE*6] = (tmp1 - tmp6);
    tmp5 = tmp11 - tmp6;
    inptr[DCTSIZE*2] = (tmp2 + tmp5);
    inptr[DCTSIZE*5] = (tmp2 - tmp5);
    tmp4 = tmp10 + tmp5;
    inptr[DCTSIZE*4] = (tmp3 + tmp4);
    inptr[DCTSIZE*3] = (tmp3 - tmp4);

    inptr++;			/* advance pointers to next column */
  }
  inptr = block; 
  /* Pass 2: process rows from work array, store into output array. */
  /* Note that we must descale the results by a factor of 8 == 2**3, */
  /* and also undo the PASS1_BITS scaling. */

  for (ctr = 0; ctr < DCTSIZE; ctr++) {
    tmp10 = ((int) inptr[0] + (int) inptr[4]);
    tmp11 = ((int) inptr[0] - (int) inptr[4]);
    tmp13 = ((int) inptr[2] + (int) inptr[6]);
    tmp12 = MULTIPLY((int) inptr[2] - (int) inptr[6], FIX_1_414213562)
	  	- tmp13;
    tmp0 = tmp10 + tmp13;
    tmp3 = tmp10 - tmp13;
    tmp1 = tmp11 + tmp12;
    tmp2 = tmp11 - tmp12;
    z13 = (int) inptr[5] + (int) inptr[3];
    z10 = (int) inptr[5] - (int) inptr[3];
    z11 = (int) inptr[1] + (int) inptr[7];
    z12 = (int) inptr[1] - (int) inptr[7];
    tmp7 = z11 + z13;		/* phase 5 */
    tmp11 = MULTIPLY(z11 - z13, FIX_1_414213562); /* 2*c4 */
    z5 = MULTIPLY(z10 + z12, FIX_1_847759065); /* 2*c2 */
    tmp10 = MULTIPLY(z12, FIX_1_082392200) - z5; /* 2*(c2-c6) */
    tmp12 = MULTIPLY(z10, - FIX_2_613125930) + z5; /* -2*(c2+c6) */
    tmp6 = tmp12 - tmp7;	/* phase 2 */
    tmp5 = tmp11 - tmp6;
    tmp4 = tmp10 + tmp5;
#define SR (3)
    inptr[0] = ((tmp0 + tmp7) >> SR);
    inptr[7] = ((tmp0 - tmp7) >> SR);
    inptr[1] = ((tmp1 + tmp6) >> SR);
    inptr[6] = ((tmp1 - tmp6) >> SR);
    inptr[2] = ((tmp2 + tmp5) >> SR);
    inptr[5] = ((tmp2 - tmp5) >> SR);
    inptr[4] = ((tmp3 + tmp4) >> SR);
    inptr[3] = ((tmp3 - tmp4) >> SR);

    inptr += DCTSIZE;		/* advance pointer to next row */
  }
}

