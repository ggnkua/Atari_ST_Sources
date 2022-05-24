
#include "config.h"

#define FIX_1_082392200  (277)		/* FIX(1.082392200) */
#define FIX_1_414213562  (362)		/* FIX(1.414213562) */
#define FIX_1_847759065  (473)		/* FIX(1.847759065) */
#define FIX_2_613125930  (669)		/* FIX(2.613125930) */
#define DCTSIZE (8)

	movsx	eax,(DCTSIZE*1)[ESI]
	movsx	ebx,(DCTSIZE*7)[ESI]
	add	eax,ebx			; z11 = inptr[DCTSIZE*1] + inptr[DCTSIZE*7];
	movsx	ebx,(DCTSIZE*5)[ESI]
	movsx	edx,(DCTSIZE*3)[ESI]
	add	ebx,edx	 		; z13 = inptr[DCTSIZE*5] + inptr[DCTSIZE*3];		/* phase 6 */
	movsx	ecx,(DCTSIZE*2)[ESI]
	movsx	edx,(DCTSIZE*6)[ESI]
	add	ecx,edx	 		; tmp13 = inptr[DCTSIZE*2] + inptr[DCTSIZE*6];	/* phases 5-3 */
	movsx	edx,(DCTSIZE*0)[ESI]
	movsx	ebp,(DCTSIZE*4)[ESI]
	add	edx,ebp	 	 	; tmp10 = inptr[DCTSIZE*0] + inptr[DCTSIZE*4];	/* phase 3 */

	add	edx,ecx		 	; tmp0 = tmp10 + tmp13;	/* phase 2 */
	add	eax,ebx			; tmp7 = z11 + z13;		/* phase 5 */
	mov	ebp,edx
	add	edx,eax			; tmp0 + tmp7
	mov	(DCTSIZE*0)[EDI],edx 	; inptr[DCTSIZE*0] = (tmp0 + tmp7);
	sub	ebp,eax
	mov	(DCTSIZE*7)[EDI],ebp 	; inptr[DCTSIZE*7] = (tmp0 - tmp7);
	movsx 	edx,(DCTSIZE*2)[ESI]
	movsx	ebp,(DCTSIZE*6)[ESI]
	sub	edx,ebp 		
	mul	edx,FIX_1_414213562
	sar	edx,8
	sub 	edx,ecx 		; tmp12 = MULTIPLY(inptr[DCTSIZE*2] - inptr[DCTSIZE*6], FIX_1_414213562) - tmp13; /* 2*c4 */
	mov	ebp,edx
	sub	ebp,eax	 		; tmp6 = tmp12 - tmp7;	/* phase 2 */
	sub	eax,ebx			; z11+z13 - z13
	sub	eax,ebx			; z11-z13
	mul	eax,FIX_1_414213562
	sar	eax,8			; tmp11 = MULTIPLY(z11 - z13, FIX_1_414213562); /* 2*c4 */
	add	eax,edx 		; tmp1 = tmp11 + tmp12;
	add	eax,ebp 
	mov	(DCTSIZE*1)[EDI],eax 	; inptr[DCTSIZE*1] = (tmp1 + tmp6);
	sub	eax,ebp
	sub	eax,ebp
	mov	(DCTSIZE*6)[EDI],eax 	; inptr[DCTSIZE*6] = (tmp1 - tmp6);
	sub	eax,edx			; tmp11
	mov	ebx,eax
	sub	eax,edx 		; tmp2 = tmp11 - tmp12;
	sub	ebx,ebp			; tmp5 = tmp11 - tmp6;
	add	eax,ebx
	mov	(DCTSIZE*2)[EDI],eax 	; inptr[DCTSIZE*2] = (tmp2 + tmp5);
	sub	eax,ebx
	sub	eax,ebx
	mov	(DCTSIZE*5)[EDI],eax 	; inptr[DCTSIZE*5] = (tmp2 - tmp5);

    z10 = inptr[DCTSIZE*5] - inptr[DCTSIZE*3];
    z12 = inptr[DCTSIZE*1] - inptr[DCTSIZE*7];
    z5 = MULTIPLY(z10 + z12, FIX_1_847759065); /* 2*c2 */
    tmp12 = MULTIPLY(z10, - FIX_2_613125930) + z5; /* -2*(c2+c6) */
    tmp10 = MULTIPLY(z12, FIX_1_082392200) - z5; /* 2*(c2-c6) */
    tmp4 = tmp10 + tmp5;
    tmp3 = tmp10 - tmp13;
    
	mov	(DCTSIZE*4)[EDI],eax 	; inptr[DCTSIZE*4] = (tmp3 + tmp4);
    	mov	(DCTSIZE*3)[EDI],eax 	; inptr[DCTSIZE*3] = (tmp3 - tmp4);
	inc	edi 			; inptr++;


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

void init_idct()
{
}

