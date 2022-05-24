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

#include <dos.h>
#include <math.h>
#include "video.h"
#include "proto.h"
#include "dither.h"

/* Range values for lum, cr, cb. */

int LUM_RANGE;
int CR_RANGE;
int CB_RANGE;

/* Arrays holding quantized value ranged for lum, cr, and cb. */

int *lum_values;
int *cr_values;
int *cb_values;

/* Declaration of global variable containing dither type. */

extern int ditherType;

/*
 *--------------------------------------------------------------
 *
 * InitColor --
 *
 *      Initialized lum, cr, and cb quantized range value arrays.
 *
 * Results: 
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void
InitColor()
{
  int i;

  for (i=0; i<LUM_RANGE; i++) {
    lum_values[i] = ((i * 256) / (LUM_RANGE)) + (256/(LUM_RANGE*2));
  }

  for (i=0; i<CR_RANGE; i++) {
    cr_values[i] = ((i * 256) / (CR_RANGE)) + (256/(CR_RANGE*2));
  }

  for (i=0; i<CB_RANGE; i++) {
    cb_values[i] = ((i * 256) / (CB_RANGE)) + (256/(CB_RANGE*2));
  }

}


/*
 *--------------------------------------------------------------
 *
 * ConvertColor --
 *
 *      Given a l, cr, cb tuple, converts it to r,g,b.
 *
 * Results:
 *      r,g,b values returned in pointers passed as parameters.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

static void
ConvertColor(l, cr, cb, r, g, b)
     unsigned char l, cr, cb;
     unsigned char *r, *g, *b;
{
  double fl, fcr, fcb, fr, fg, fb;

  fl = (double) l;
  fcr =  ((double) cr) - 128.0;
  fcb =  ((double) cb) - 128.0;


  fr = fl + (1.40200 * fcb);
  fg = fl - (0.71414 * fcb) - (0.34414 * fcr);
  fb = fl + (1.77200 * fcr);

  if (fr < 0.0) fr = 0.0;
  else if (fr > 255.0) fr = 255.0;

  if (fg < 0.0) fg = 0.0;
  else if (fg > 255.0) fg = 255.0;

  if (fb < 0.0) fb = 0.0;
  else if (fb > 255.0) fb = 255.0;

  *r = (unsigned char) fr;
  *g = (unsigned char) fg;
  *b = (unsigned char) fb;

}

void init_mode(int mode)
{       union REGS r;
	r.w.ax = mode;
	/*int386(0x10,&r,&r); */
}

/*
 *--------------------------------------------------------------
 *
 * InitDisplay --
 *
 *      Initialized display, sets up colormap, etc.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void InitDisplay(name)
char *name;
{
  int ncolors = LUM_RANGE*CB_RANGE*CR_RANGE;
  int i, lum_num, cr_num, cb_num;
  unsigned char r, g, b;
  if (ditherType == NO_DITHER) return;
   
  init_mode(0x13);

  outp(0x3c8,0);
  for (i=0; i< ncolors ; i++) {
    lum_num = (i / (CR_RANGE*CB_RANGE))%LUM_RANGE;
    cr_num = (i / CB_RANGE)%CR_RANGE;
    cb_num = i % CB_RANGE;
    ConvertColor(lum_values[lum_num], cr_values[cr_num], cb_values[cb_num], &r, &g, &b);
    outp(0x3c9,(unsigned char) (r >> 2));
    outp(0x3c9,(unsigned char) (b >> 2));
    outp(0x3c9,(unsigned char) (g >> 2));

  }

  while (i < 255)    
  { outp(0x3c9,(unsigned char) (r >> 2));
    outp(0x3c9,(unsigned char) (b >> 2));
    outp(0x3c9,(unsigned char) (g >> 2));
    i++;
  }
}


/*
 *--------------------------------------------------------------
 *
 * InitGrayDisplay --
 *
 *      Initialized display for gray scale dither.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void InitGrayDisplay(name)
char *name;
{
  int i;
  init_mode(0x13);
  outp(0x3c8,0);
  for (i=0; i < 255; i++) {
    outp(0x3c9,(unsigned char) (i >> 2) );
    outp(0x3c9,(unsigned char) (i >> 2) );
    outp(0x3c9,(unsigned char) (i >> 2) );

  }
}


/*
 *--------------------------------------------------------------
 *
 * InitMonoDisplay --
 *
 *      Initialized display for monochrome dither.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void InitMonoDisplay(name)
char *name;
{

}


/*
 *--------------------------------------------------------------
 *
 * InitColorDisplay --
 *
 *      Initialized display for full color output.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void InitColorDisplay(name)
char *name;
{

}


/*
 *--------------------------------------------------------------
 *
 * ExecuteDisplay --
 *
 *      Actually displays display plane in previously created window.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void
ExecuteDisplay(vid_stream)
     VidStream *vid_stream;
{
  char dummy;
  int depth,x,y;
  int width = (vid_stream->h_size) >> 2;
  int height = (vid_stream->v_size);
  int add_width = (320 >> 2) - width;
  int *screen_ptr; 
  int *source_ptr; 
  source_ptr = (int *) vid_stream->current->display;
  screen_ptr = (int *) (0xa0000); 
  screen_ptr += (80 * ( (200 - height) >> 1) ); 
  screen_ptr += add_width >> 1;

  totNumFrames++;

  if (!quietFlag) {
    fprintf (stderr, "%d\r", totNumFrames);
  }

  if (ditherType == NO_DITHER) return;

    if (ditherType == Twox2_DITHER) {
       /* 8 */
    } else if (ditherType == FULL_COLOR_DITHER) {
    } else if (ditherType == MONO_DITHER || ditherType == MONO_THRESHOLD) {
      /* 1 */
    } else {
	/*8 */
    }
      
      if (!noDisplayFlag) 
      {         for ( y = 0 ; y < height ; y++)
		{       for ( x = 0 ; x < width ; x ++)
			{       *screen_ptr++ = *source_ptr++; 
			}
		screen_ptr += add_width;
		}

      }
}
