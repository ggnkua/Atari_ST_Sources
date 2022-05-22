/*
 *--------------------------------------------------------------
 *
 * ParseAwayBlock --
 *
 *	Parses off block values, throwing them away.
 *      Used with grayscale dithering.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void
ParseAwayBlock(n)
     int n;
{
  unsigned int diff;
  unsigned int size, run;
  int level;

  if (bufLength < 100)
    correct_underflow();

  if (curVidStream->mblock.mb_intra) {

    /* If the block is a luminance block... */

    if (n < 4) {

      /* Parse and decode size of first coefficient. */

      DecodeDCTDCSizeLum(size);

      /* Parse first coefficient. */

      if (size != 0) {
	get_bitsn(size, diff);
      }
    }

    /* Otherwise, block is chrominance block... */

    else {

      /* Parse and decode size of first coefficient. */

      DecodeDCTDCSizeChrom(size);

      /* Parse first coefficient. */

      if (size != 0) {
	get_bitsn(size, diff);
      }
    }
  }

  /* Otherwise, block is not intracoded... */

  else {

    /* Decode and set first coefficient. */

    DECODE_DCT_COEFF_FIRST(run, level);
  }

  /* If picture is not D type (i.e. I, P, or B)... */

  if (curVidStream->picture.code_type != 4) {

    /* While end of macroblock has not been reached... */

    while (1) {

      /* Get the dct_coeff_next */

      DECODE_DCT_COEFF_NEXT(run, level);

      if (run == END_OF_BLOCK) break;
    }

    /* End_of_block */

    flush_bits(2);
  }
}
