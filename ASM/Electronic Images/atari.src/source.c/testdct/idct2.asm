#define FIX_1_082392200  (277)		/* FIX(1.082392200) */
#define FIX_1_414213562  (362)		/* FIX(1.414213562) */
#define FIX_1_847759065  (473)		/* FIX(1.847759065) */
#define FIX_2_613125930  (669)		/* FIX(2.613125930) */
#define DCTSIZE (8)

#define MULTIPLY(x,y) ((x)+(y))

static int workspace[8][8];

void idct2 (short *block)
{
  int tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  int tmp10, tmp11, tmp12, tmp13;
  int z5, z10, z11, z12, z13;
  int * wsptr;
  int ctr;
  short *inptr=block,*outptr=block;

  /* Pass 1: process columns from input, store into work array. */

  wsptr = workspace;
  for (ctr = DCTSIZE; ctr > 0; ctr--) {
    /*if ((inptr[DCTSIZE*1] | inptr[DCTSIZE*2] | inptr[DCTSIZE*3] |
	 inptr[DCTSIZE*4] | inptr[DCTSIZE*5] | inptr[DCTSIZE*6] |
	 inptr[DCTSIZE*7]) == 0) {
      int dcval = (int) inptr[DCTSIZE*0];
      wsptr[DCTSIZE*0] = dcval;
      wsptr[DCTSIZE*1] = dcval;
      wsptr[DCTSIZE*2] = dcval;
      wsptr[DCTSIZE*3] = dcval;
      wsptr[DCTSIZE*4] = dcval;
      wsptr[DCTSIZE*5] = dcval;
      wsptr[DCTSIZE*6] = dcval;
      wsptr[DCTSIZE*7] = dcval;
      inptr++;
      wsptr++;
      continue;
    }
    */

    /* Even part */

    tmp0 = inptr[DCTSIZE*0];
    tmp1 = inptr[DCTSIZE*2];
    tmp2 = inptr[DCTSIZE*4];
    tmp3 = inptr[DCTSIZE*6];
    tmp10 = tmp0 + tmp2;	/* phase 3 */
    tmp11 = tmp0 - tmp2;
    tmp13 = tmp1 + tmp3;	/* phases 5-3 */
    tmp12 = MULTIPLY(tmp1 - tmp3, FIX_1_414213562) - tmp13; /* 2*c4 */
    tmp0 = tmp10 + tmp13;	/* phase 2 */
    tmp3 = tmp10 - tmp13;
    tmp1 = tmp11 + tmp12;
    tmp2 = tmp11 - tmp12;
    tmp4 = inptr[DCTSIZE*1];
    tmp5 = inptr[DCTSIZE*3];
    tmp6 = inptr[DCTSIZE*5];
    tmp7 = inptr[DCTSIZE*7];
    z13 = tmp6 + tmp5;		/* phase 6 */
    z10 = tmp6 - tmp5;
    z11 = tmp4 + tmp7;
    z12 = tmp4 - tmp7;
    tmp7 = z11 + z13;		/* phase 5 */
    tmp11 = MULTIPLY(z11 - z13, FIX_1_414213562); /* 2*c4 */
    z5 = MULTIPLY(z10 + z12, FIX_1_847759065); /* 2*c2 */
    tmp10 = MULTIPLY(z12, FIX_1_082392200) - z5; /* 2*(c2-c6) */
    tmp12 = MULTIPLY(z10, - FIX_2_613125930) + z5; /* -2*(c2+c6) */
    tmp6 = tmp12 - tmp7;	/* phase 2 */
    tmp5 = tmp11 - tmp6;
    tmp4 = tmp10 + tmp5;
    wsptr[DCTSIZE*0] = (tmp0 + tmp7);
    wsptr[DCTSIZE*7] = (tmp0 - tmp7);
    wsptr[DCTSIZE*1] = (tmp1 + tmp6);
    wsptr[DCTSIZE*6] = (tmp1 - tmp6);
    wsptr[DCTSIZE*2] = (tmp2 + tmp5);
    wsptr[DCTSIZE*5] = (tmp2 - tmp5);
    wsptr[DCTSIZE*4] = (tmp3 + tmp4);
    wsptr[DCTSIZE*3] = (tmp3 - tmp4);

    inptr++;			/* advance pointers to next column */
    wsptr++;
  }
  
  /* Pass 2: process rows from work array, store into output array. */
  /* Note that we must descale the results by a factor of 8 == 2**3, */
  /* and also undo the PASS1_BITS scaling. */

  wsptr = workspace;
  for (ctr = 0; ctr < DCTSIZE; ctr++) {
    tmp10 = ((int) wsptr[0] + (int) wsptr[4]);
    tmp11 = ((int) wsptr[0] - (int) wsptr[4]);
    tmp13 = ((int) wsptr[2] + (int) wsptr[6]);
    tmp12 = MULTIPLY((int) wsptr[2] - (int) wsptr[6], FIX_1_414213562)
	  	- tmp13;
    tmp0 = tmp10 + tmp13;
    tmp3 = tmp10 - tmp13;
    tmp1 = tmp11 + tmp12;
    tmp2 = tmp11 - tmp12;
    z13 = (int) wsptr[5] + (int) wsptr[3];
    z10 = (int) wsptr[5] - (int) wsptr[3];
    z11 = (int) wsptr[1] + (int) wsptr[7];
    z12 = (int) wsptr[1] - (int) wsptr[7];
    tmp7 = z11 + z13;		/* phase 5 */
    tmp11 = MULTIPLY(z11 - z13, FIX_1_414213562); /* 2*c4 */
    z5 = MULTIPLY(z10 + z12, FIX_1_847759065); /* 2*c2 */
    tmp10 = MULTIPLY(z12, FIX_1_082392200) - z5; /* 2*(c2-c6) */
    tmp12 = MULTIPLY(z10, - FIX_2_613125930) + z5; /* -2*(c2+c6) */
    tmp6 = tmp12 - tmp7;	/* phase 2 */
    tmp5 = tmp11 - tmp6;
    tmp4 = tmp10 + tmp5;

    outptr[0] = (tmp0 + tmp7) >> 3;
    outptr[7] = (tmp0 - tmp7) >> 3;
    outptr[1] = (tmp1 + tmp6) >> 3;
    outptr[6] = (tmp1 - tmp6) >> 3;
    outptr[2] = (tmp2 + tmp5) >> 3;
    outptr[5] = (tmp2 - tmp5) >> 3;
    outptr[4] = (tmp3 + tmp4) >> 3;
    outptr[3] = (tmp3 - tmp4) >> 3;

    wsptr += DCTSIZE;		/* advance pointer to next row */
    outptr += DCTSIZE;
  }
}

