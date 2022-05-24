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

/* Perform byte reordering if needed*/
static unsigned int byteord(unsigned int n)
{
unsigned int bs;
                                        /* Remap aabbccdd to ddccbbaa */
    bs=(n & 0xff000000) >> 24;          /* = 000000aa */
    bs=bs | ((n & 0x00ff0000) >> 8);    /* = 0000bbaa */
    bs=bs | ((n & 0x0000ff00) << 8);    /* = 00ccbbaa */
    bs=bs | ((n & 0x000000ff) << 24);   /* = ddccbbaa */
    return(bs);
}

/*
 *--------------------------------------------------------------
 *
 * get_more_data --
 *
 *	Called by correct_underflow in bit parsing utilities to
 *      read in more data.
 *
 * Results:
 *	Input buffer updated, buffer length updated.
 *      Returns 1 if data read, 0 if EOF, -1 if error.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

int get_more_data(unsigned int *buf_start, int max_length, int *length_ptr, unsigned int **buf_ptr)
{
  
  int length, num_read, i, request;
  unsigned char *buffer, *mark;
  unsigned int *lmark;

  if (EOF_flag) return 0;

  length = *length_ptr;
  buffer = (unsigned char *) *buf_ptr;

  if (length > 0) {
    memcpy((unsigned char *) buf_start, buffer, (length*4));
    mark = ((unsigned char *) (buf_start + length));
  }
  else {
    mark = (unsigned char *) buf_start;
    length = 0;
  }

  request = (max_length-length)*4;
  
  num_read = fread( mark, 1, request, BitStream);

  /* Paulo Villegas - 26/1/1993: Correction for 4-byte alignment */
  {
    int num_read_rounded;
    unsigned char *index;
 
    num_read_rounded = 4*(num_read/4);

    /* this can happen only if num_read<request; i.e. end of file reached */
    if( num_read_rounded < num_read )
      { 
        num_read_rounded = 4*( num_read/4+1 );
        /* fill in with zeros */
        for( index=mark+num_read; index<mark+num_read_rounded; *(index++)=0 );
        /* advance to the next 4-byte boundary */
        num_read = num_read_rounded;
      }
  }

  if (num_read < 0) {
    return -1;
  }
  else if (num_read == 0) {
    *buf_ptr = buf_start;
    
    /* Make 32 bits after end equal to 0 and 32
       bits after that equal to seq end code
       in order to prevent messy data from infinite
       recursion.
    */

    *(buf_start + length) = 0x0;
    *(buf_start + length+1) = ISO_11172_END_CODE;

    EOF_flag = 1;
    return 0;
  }

  lmark = (unsigned int *) mark;

  num_read = num_read/4;

#ifdef INTEL_BYTE_ORDER
  for (i=0; i<num_read; i++) {
    *lmark = byteord(*lmark);
    lmark++;
  }
#endif

  *buf_ptr = buf_start;
  *length_ptr = length + num_read;
 
  return 1;
}
