/*
 */

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include "video.h"
#include "decoders.h"
#include "proto.h"

/* External declarations. */

extern int zigzag_direct[];

/*
 *--------------------------------------------------------------
 *
 * ParseReconBlock --
 *
 *	Parse values for block structure from bitstream.
 *      n is an indication of the position of the block within
 *      the macroblock (i.e. 0-5) and indicates the type of 
 *      block (i.e. luminance or chrominance). Reconstructs
 *      coefficients from values parsed and puts in 
 *      block.dct_recon array in vid stream structure.
 *      sparseFlag is set when the block contains only one
 *      coeffictient and is used by the IDCT.
 *
 * Results:
 *	
 *
 * Side effects:
 *      Bit stream irreversibly parsed.
 *
 *--------------------------------------------------------------
 */

#define DCT_recon blockPtr->dct_recon
#define DCT_dc_y_past blockPtr->dct_dc_y_past
#define DCT_dc_cr_past blockPtr->dct_dc_cr_past
#define DCT_dc_cb_past blockPtr->dct_dc_cb_past

#define DECODE_DCT_COEFF_FIRST DecodeDCTCoeffFirst
#define DECODE_DCT_COEFF_NEXT DecodeDCTCoeffNext

void
ParseReconBlock(n)
     int n;
{

  Block *blockPtr = &curVidStream->block;
  
  if (bufLength < 100)
    correct_underflow();

  {
    int diff;
    int size, level, i, run, pos, coeff;
    int *reconptr;
    unsigned char *iqmatrixptr, *niqmatrixptr;
    int qscale;

    reconptr = DCT_recon[0];
    {
      INT32 *p= (INT32 *) reconptr;
      p[0]  = p[1]  = p[2]  = p[3]  = p[4]  = p[5]  = p[6]  = p[7]  = p[8]  = p[9] = 
      p[10] = p[11] = p[12] = p[13] = p[14] = p[15] = p[16] = p[17] = p[18] = p[19] =
      p[20] = p[21] = p[22] = p[23] = p[24] = p[25] = p[26] = p[27] = p[28] = p[29] = 
      p[30] = p[31] = 0;
     }

    if (curVidStream->mblock.mb_intra) {

      if (n < 4) {

	unsigned int next16bits, index, flushed;

	show_bits16(next16bits);
	index = next16bits >> (16-7);
	size = dct_dc_size_luminance[index].value;
	flushed = dct_dc_size_luminance[index].num_bits;
	next16bits &= bitMask[16+flushed];

	if (size != 0) {
	  flushed += size;
	  diff = next16bits >> (16-flushed);
          if (!(diff & bitTest[32-size])) {
	    diff = rBitMask[size] | (diff + 1);
	  }
	} else {
	  diff = 0;
	}
	flush_bits(flushed);

	if (n == 0) {
	  coeff = diff << 3;
	  if (curVidStream->mblock.mb_address -
	      curVidStream->mblock.past_intra_addr > 1) 
	    coeff += 1024;
	  else coeff += DCT_dc_y_past;
	  DCT_dc_y_past = coeff;
	} else {
	  coeff = DCT_dc_y_past + (diff << 3);
	  DCT_dc_y_past = coeff;
	}
      } else {
	
	/*
	 * Get the chrominance bits.  This code has been hand optimized to
	 * as described above
	 */
	unsigned int next16bits, index, flushed;

	show_bits16(next16bits);
	index = next16bits >> (16-8);
	size = dct_dc_size_chrominance[index].value;
	flushed = dct_dc_size_chrominance[index].num_bits;
	next16bits &= bitMask[16+flushed];
	
	if (size != 0) {
	  flushed += size;
	  diff = next16bits >> (16-flushed);
          if (!(diff & bitTest[32-size])) {
	    diff = rBitMask[size] | (diff + 1);
	  }
	} else {
	  diff = 0;
	}
	flush_bits(flushed);
	
	if (n == 4) {
	  coeff = diff << 3;
	  if (curVidStream->mblock.mb_address -
	      curVidStream->mblock.past_intra_addr > 1) 
	    coeff += 1024;
	  else coeff += DCT_dc_cr_past;
	  DCT_dc_cr_past = coeff;

	} else {
	  coeff = diff << 3;
	  if (curVidStream->mblock.mb_address -
	      curVidStream->mblock.past_intra_addr > 1) 
	    coeff += 1024;
	  else coeff += DCT_dc_cb_past;
	  DCT_dc_cb_past = coeff;
	}
      }
      
      *reconptr = coeff;
      i = 0; pos = 0;
    
      if (curVidStream->picture.code_type != 4) {
	
	qscale = curVidStream->slice.quant_scale;
	iqmatrixptr = curVidStream->intra_quant_matrix[0];
	
	while(1) {
	  
	  DECODE_DCT_COEFF_NEXT(run, level);

	  if (run == END_OF_BLOCK) break;

	  i = i + run + 1;
	  pos = zigzag_direct[i];
	  coeff = (level * qscale * ((int) iqmatrixptr[pos])) >> 3;
	  if (level < 0) {
	      coeff += (coeff & 1);
	  } else {
	      coeff -= (coeff & 1);
	  }

	  reconptr[pos] = coeff;

	}

	flush_bits(2);

	goto end;
      }
    }
    
    else {
      
      niqmatrixptr = curVidStream->non_intra_quant_matrix[0];
      qscale = curVidStream->slice.quant_scale;
      
      DECODE_DCT_COEFF_FIRST(run, level);
      i = run;

      pos = zigzag_direct[i];
      if (level < 0) {
	  coeff = (((level<<1) - 1) * qscale * 
		   ((int) (niqmatrixptr[pos]))) >> 4; 
	  coeff += (coeff & 1);
      } else {
	  coeff = (((level<<1) + 1) * qscale * 
		   ((int) (*(niqmatrixptr+pos)))) >> 4; 
	  coeff -= (coeff & 1);
      }
      reconptr[pos] = coeff;

      if (curVidStream->picture.code_type != 4) {
	
	while(1) {
	  
	  DECODE_DCT_COEFF_NEXT(run, level);

	  if (run == END_OF_BLOCK) break;

	  i = i+run+1;
	  pos = zigzag_direct[i];
	  if (level < 0) {
	      coeff = (((level<<1) - 1) * qscale * 
		       ((int) (niqmatrixptr[pos]))) >> 4; 
	      coeff += (coeff & 1);
	  } else {
	      coeff = (((level<<1) + 1) * qscale * 
		       ((int) (*(niqmatrixptr+pos)))) >> 4; 
	      coeff -= (coeff & 1);
	  }
	  reconptr[pos] = coeff;
	}

	flush_bits(2);

	goto end;
      }
    }
    
  end:

    ASMIDCT(reconptr);

  }
}
	
