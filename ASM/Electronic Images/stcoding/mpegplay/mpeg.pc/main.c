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
 */

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <string.h>
#include <tos.h>
#include <dspbind.h>
#include "video.h"
#include "util.h"
#include "proto.h"

/* Define buffer length. */
char buffer[4096];	
#define BUF_LENGTH 40000

/* External declaration of main decoding call. */

extern VidStream *mpegVidRsrc();
extern VidStream *NewVidStream();


FILE *input;			/* Global file pointer to incoming data. */

int loopFlag =1;
static int EOF_flag = 0;	/* End of File flag. */
jmp_buf env;

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

long 
get_more_data(buf_start, max_length, length_ptr, buf_ptr)
     unsigned long *buf_start;
     long max_length;
     long *length_ptr;
     unsigned long **buf_ptr;
{
  
  long length, num_read, i, request;
  unsigned char *buffer, *mark;
  unsigned long *lmark;

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
  
  num_read = fread( mark, 1, request, input);

  /* Paulo Villegas - 26/1/1993: Correction for 4-byte alignment */
  {
    long num_read_rounded;
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
  
  if   (num_read < 0) {
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
    *(buf_start + length+1) = SEQ_END_CODE;

    EOF_flag = 1;
    return 0;
  }

  num_read = num_read/4;
  *buf_ptr = buf_start;
  *length_ptr = length + num_read;
 
  return 1;
}

/*
 *--------------------------------------------------------------
 *
 * main --
 *
 *	Parses command line, starts decoding and displaying.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */


int main(long argc, char **argv)
{ 
  static VidStream *theStream;
  void *old_stack= Super(0); 

  Bconout( 2,27 );
  Bconout( 2,'E' );
  Bconout( 2,27 );
  Bconout( 2,'f' );
  puts("        PLAYMPEG v0.4\x9e      ");
  puts("        by Martin GRIFFiths 1994");
  {	long xav,yav;
  	Dsp_Lock();
  	Dsp_Available(&xav,&yav);
 	Dsp_Reserve(xav,yav);
  	if  (Dsp_LoadProg("PLAYMPEG.LOD",(int) Dsp_RequestUniqueAbility(),&buffer[0]) < 0)
  	{    	fprintf(stderr,"        Cound not open PLAYMPEG.LOD DSP Module");
		fprintf(stderr,"        Press any key.");
	  	Cnecin();
		exit(1);
	}
  }

  input = fopen(argv[1],"rb");
  if (input == NULL) 
  {    	fprintf(stderr,"        Could not open file %s\n",argv[1]);
	fprintf(stderr,"        Press any key.");
  	Cnecin();
	exit(1);
  }

  puts("        Press any key.");
  Cnecin();

  InitColorDisplay();
  init_tables();
  theStream = NewVidStream(BUF_LENGTH);
  mpegVidRsrc(0, theStream);

  if (setjmp(env) != 0) {

    DestroyVidStream(theStream);

    rewind(input);

    EOF_flag = 0;
    curBits = 0;
    bitOffset = 0;
    bufLength = 0;
    bitBuffer = NULL;

  }

  while (Cconis() == 0)
  	mpegVidRsrc(0, theStream);
  
  CloseColorDisplay();
  Dsp_Unlock();

  Super(old_stack);
}
 

/*
 *--------------------------------------------------------------
 *
 * DoDitherImage --
 *
 *	Called when image needs to be dithered. Selects correct
 *      dither routine based on info in ditherType.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */


void
DoDitherImage(l, Cr, Cb, disp, h, w) 
unsigned char *l, *Cr, *Cb, *disp;
long h,w;
{
	extern cdecl ASMDITH(unsigned char *,unsigned char *, unsigned char *, unsigned char *, long, long); 
	ASMDITH(l, Cr, Cb, disp, h, w);
}
