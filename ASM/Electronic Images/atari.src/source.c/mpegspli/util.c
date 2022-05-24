/*
 * Copyright (c) 1992 The Regents of the University of California.
 * All rights reserved.
 * 
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * I can be contacted via 
 * Email: michael@ecel.uwa.edu.au
 * Post: P.O. Box 506, NEDLANDS WA 6009, AUSTRALIA
 */

#include "main.h"

/*
 *--------------------------------------------------------------
 *
 * correct_underflow --
 *
 *	Called when buffer does not have sufficient data to 
 *      satisfy request for bits.
 *      Calls get_more_data, an application specific routine
 *      required to fill the buffer with more data.
 *
 * Results:
 *      None really.
 *  
 * Side effects:
 *	buf_length and buffer fields in curVidStream structure
 *      may be changed.
 *
 *--------------------------------------------------------------
 */

void correct_underflow()
{

  int status;

  status = get_more_data( buf_start, max_buf_length, &bufLength, &bitBuffer);

  if (status  < 0) {
	longjmp(env,ERR_READ_BITSTREAM);

  }else if ((status == 0) && (bufLength < 1)) {
	longjmp(env,ERR_UNEXPECTED_EOF);

  }

  curBits = *bitBuffer;
}

/*
 *--------------------------------------------------------------
 *
 * next_bits --
 *
 *	Compares next num bits to low order position in mask.
 *      Buffer pointer is NOT advanced.
 *
 * Results:
 *	TRUE, FALSE, or error code.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

int next_bits(int num, unsigned int mask)
{
  unsigned int stream;
  int ret_value;

  /* If no current stream, return error. */

  if (BitStream == NULL)
    longjmp(env,ERR_NO_BIT_STREAM);

  /* Get next num bits, no buffer pointer advance. */

  show_bitsn(num, &stream);

  /* Compare bit stream and mask. Set return value toTRUE if equal, FALSE if
     differs. 
  */

  if (mask == stream) {
    ret_value = TRUE;
  } else ret_value = FALSE;

  /* Return return value. */

  return ret_value;
}

/*
 *--------------------------------------------------------------
 *
 * next_start_code --
 *
 *	Parses off bitstream until start code reached. When done
 *      next 4 bytes of bitstream will be start code. Bit offset
 *      reset to 0.
 *
 * Results:
 *	Status code.
 *
 * Side effects:
 *	Bit stream irreversibly parsed.
 *
 *--------------------------------------------------------------
 */

int next_start_code()
{
  int state;
  int byteoff;
  unsigned int data;

  /* If no current stream, return error. */

  if (BitStream == NULL)
    longjmp(env,ERR_NO_BIT_STREAM);

  /* If insufficient buffer length, correct underflow. */

  if (bufLength < 2) {
    correct_underflow();
  }

  /* If bit offset not zero, reset and advance buffer pointer. */

  byteoff = bitOffset % 8;

  if (byteoff != 0) {
    bitOffset += (8-byteoff);
    if (bitOffset > 31) {
      bitBuffer++;
      curBits = *bitBuffer;
      bufLength--;
      bitOffset = 0;
    }
  }

  /* Set state = 0. */

  state = 0;

  /* While buffer has data ... */

  while(bufLength > 0) {

    /* If insufficient data exists, correct underflow. */

    if (bufLength < 2) {
      correct_underflow();
    }

    /* If next byte is zero... */

    get_bits8(&data);

    if (data == 0) {

      /* If state < 2, advance state. */

      if (state < 2) state++;
    }

    /* If next byte is one... */

    else if (data == 1) {

      /* If state == 2, advance state (i.e. start code found). */

      if (state == 2) state++;

      /* Otherwise, reset state to zero. */

      else state = 0;
    }

    /* Otherwise byte is neither 1 or 0, reset state to 0. */

    else {
      state = 0;
    }

    /* If state == 3 (i.e. start code found)... */

    if (state == 3) {

      /* Set buffer pointer back and reset length & bit offsets so
	 next bytes will be beginning of start code. 
      */

      bitOffset = bitOffset - 24;

      if (bitOffset < 0) {
	bitOffset = 32 + bitOffset;
	bufLength++;
	bitBuffer--;
	curBits = *bitBuffer;
      }

      /* Return success. */

      return OK;
    }
  }

  /* Return underflow error. */

  return BUF_UNDERFLOW;
}
