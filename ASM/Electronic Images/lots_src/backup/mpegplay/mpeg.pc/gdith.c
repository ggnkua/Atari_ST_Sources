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
#include <tos.h>
#include "video.h"
#include "proto.h"

#ifndef VERTFLAG

/*
 * Video
 */

/* Video mode codes */

#define	VERTFLAG	0x100	/* double-line on VGA, interlace on ST/TV */
#define	STMODES		0x080	/* ST compatible */
#define	OVERSCAN	0x040	/* Multiply X&Y rez by 1.2, ignored on VGA */
#define	PAL		0x020	/* PAL if set, else NTSC */
#define	VGA		0x010	/* VGA if set, else TV mode */
#define	COL80		0x008	/* 80 column if set, else 40 column */
#define	NUMCOLS		7	/* Mask for number of bits per pixel */
#define	BPS16		4
#define	BPS8		3
#define	BPS4		2
#define	BPS2		1
#define	BPS1		0

/* Montype return values */
enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};

/* VsetSync flags - 0=internal, 1=external */

#define	VID_CLOCK	1
#define	VID_VSYNC	2
#define	VID_HSYNC	4

#endif

/* Declaration of global variable containing dither type. */

int ScreenWidth;
int ScreenHeight;
int vid_mode;
int old_vid_mode;
static void *old_phy_base;
static void *old_log_base;
static void *Phy_base;
#define SCREENSIZE ( (256 + ( (long) 320*240*2)))
char *SCREEN;
extern void SETVGA(void *);

/*
 *--------------------------------------------------------------
 *
 * InitColorDisplay --
 *
 *	Initialized display for full color output.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      None.
 *
 *--------------------------------------------------------------
 */

void InitColorDisplay(void)
{	old_phy_base = ( void *) Physbase();
	old_log_base = ( void *) Logbase();
	old_vid_mode = Vsetmode(-1) & 0x1ff;
	SCREEN = calloc(1,SCREENSIZE);
	Phy_base = (void *) ( (long) (SCREEN+256)  & 0xffffff00);
	switch (Montype())
	{	case STmono:
			exit (2);
		case VGAcolor:
		{	ScreenWidth  = 320;
			ScreenHeight = 240;
			SETVGA(Phy_base);
			break;
		}
		case TVcolor:
		case STcolor:
		{	ScreenWidth  = 320;
			ScreenHeight = 200;
			Vsync();
#ifdef __GCC__
			Setscreen(Phy_base,Phy_base,-1,0);
#else
			Setscreen(Phy_base,Phy_base,-1);
#endif
			Vsetmode(PAL|BPS16);
		}
	}

}

void CloseColorDisplay(void)
{	Vsync();
	
#ifdef __GCC__
	Setscreen(old_log_base,old_phy_base,-1,0);
#else
	Setscreen(old_log_base,old_phy_base,-1);
#endif
	Vsetmode(old_vid_mode);
}

/*
 *--------------------------------------------------------------
 *
 * ExecuteDisplay --
 *
 *	Actually displays display plane in previously created window.
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
ExecuteDisplay(VidStream *vid_stream)
{ 	int height = vid_stream->v_size;
 	int width  = vid_stream->h_size;
	long screen;
	long curr;
	int add_width = ScreenWidth - width;

	curr = (long) vid_stream->current->display;
	screen	 = (long) ((int *) Phy_base + (add_width >> 1) 
	          	       		+ (((ScreenHeight - height) >> 1) * 320));

	while ( ((* (unsigned char *) 0xffff8a3cl) & 0x80) !=0);
	*((int *)0xffff8a20l) = (int) 2;		/* source inc X */
	*((int *)0xffff8a22l) = (int) 2;		/* source inc y */
	*((long   *)0xffff8a24l) = curr;				/* source address */
	*((int *)0xffff8a2el) = (int) 2;		/* dest inc X */
	*((int *)0xffff8a30l) = (int) (add_width+1)*2;	/* dest inc y */
	*((long   *)0xffff8a32l) = screen;			/* dest address */
	*((int *)0xffff8a36l) = (int) width;	/* X count */
	*((int *)0xffff8a38l) = (int) height;	/* Y count */
	*((int *)0xffff8a3al) = (int) 0x0203;	/* HOP/OP  */
	*((char  *)0xffff8a3dl) = (unsigned char) 0;	/* skew */
	*((char  *)0xffff8a3cl) = (unsigned char) 0x80;	/* line_num */

}



