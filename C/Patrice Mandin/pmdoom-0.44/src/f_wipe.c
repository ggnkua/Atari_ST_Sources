// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// $Log:$
//
// DESCRIPTION:
//	Mission begin melt/wipe screen special effect.
//
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <string.h>

#include "z_zone.h"
#include "i_video.h"
#include "v_video.h"
#include "m_random.h"

#include "doomdef.h"

#include "f_wipe.h"

//
//                       SCREEN WIPE PACKAGE
//

// when zero, stop the wipe
static boolean	go = 0;

static byte*	wipe_scr_start=NULL;
static byte*	wipe_scr_end=NULL;
static byte*	wipe_scr;

static byte wipe_dblbuffer;
static int*	y;

int
wipe_initMelt
( int	width,
  int	height,
  int	ticks )
{
    int i, r;
    
    // copy start screen to main screen
	{
		unsigned char *src, *dst;
		int y;

		src = wipe_scr_start;
		dst = wipe_scr;
		for (y=0;y<height;y++) {
			memcpy(dst,src,width);
			dst += sysvideo.pitch;
			src += sysvideo.width;
		}
	}
    
	// setup initial column positions
	// (y<0 => not ready to scroll yet)
	y = (int *) Z_Malloc(width*sizeof(int), PU_STATIC, 0);
	y[0] = -(M_Random()%16);
	for (i=1;i<width;i++) {
		r = (M_Random()%3) - 1;
		y[i] = y[i-1] + r;
		if (y[i] > 0)
			y[i] = 0;
		else if (y[i] == -16)
			y[i] = -15;
	}

	return 0;
}

int
wipe_doMelt
( int	width,
  int	height,
  int	ticks )
{
    int		i;
    int		j;
    int		dy;
    int		sidx, didx;
    
    short*	s;
    short*	d;
    boolean	done = true;

	if (wipe_dblbuffer) {
	    V_DrawBlock(0, 0, 0, width, height, wipe_scr_end);
		wipe_scr = screens[0];
	}

    width>>=1;

	while (ticks--) {
		for (i=0;i<width;i++) {
			if (y[i]<0) {
				y[i]++;
				done = false;
			} else if (y[i] < height) {
				dy = (y[i] < 16) ? y[i]+1 : 8;
				if (y[i]+dy >= height)
					dy = height - y[i];
				if (!wipe_dblbuffer) {
					s = &((short *)wipe_scr_end)[i+y[i]*width];
					d = &((short *)wipe_scr)[i+y[i]*(sysvideo.pitch>>1)];
					sidx = didx = 0;
					for (j=dy;j;j--) {
						d[didx] = s[sidx];
						sidx += width;
						didx += sysvideo.pitch>>1;
					}
				}
				y[i] += dy;
				s = &((short *)wipe_scr_start)[i];
				d = &((short *)wipe_scr)[i+y[i]*(sysvideo.pitch>>1)];
				sidx = didx = 0;
				for (j=height-y[i];j;j--) {
					d[didx] = s[sidx];
					sidx += width;
					didx += sysvideo.pitch>>1;
				}
				done = false;
			}
		}
	}
	return done;
}

int
wipe_exitMelt
( int	width,
  int	height,
  int	ticks )
{
    Z_Free(y);
	if (wipe_scr_start) {
		Z_Free(wipe_scr_start);
		wipe_scr_start=NULL;
	}
	if (wipe_scr_end) {
		Z_Free(wipe_scr_end);
		wipe_scr_end=NULL;
	}
    return 0;
}

int
wipe_StartScreen
( int	x,
  int	y,
  int	width,
  int	height )
{
	if (!wipe_scr_start)
		wipe_scr_start = Z_Malloc(sysvideo.width*sysvideo.height, PU_STATIC, NULL);
    I_ReadScreen(wipe_scr_start);
    return 0;
}

int
wipe_EndScreen
( int	x,
  int	y,
  int	width,
  int	height )
{
	if (!wipe_scr_end)
		wipe_scr_end = Z_Malloc(sysvideo.width*sysvideo.height, PU_STATIC, NULL);
    I_ReadScreen(wipe_scr_end);
    V_DrawBlock(x, y, 0, width, height, wipe_scr_start); // restore start scr.
    return 0;
}

void V_MarkRect(int, int, int, int);

int
wipe_ScreenWipe
( int	wipeno,
  int	x,
  int	y,
  int	width,
  int	height,
  int	ticks )
{
	int rc;

	// initial stuff
	if (!go) {
		go = 1;
		wipe_scr = screens[0];
		wipe_initMelt(width, height, ticks);
		wipe_dblbuffer = false;
	} else {
		if (wipe_scr != screens[0])
			wipe_dblbuffer = true;
	}

	// do a piece of wipe-in
	V_MarkRect(0, 0, width, height);
	rc = wipe_doMelt(width, height, ticks);

	// final stuff
	if (rc) {
		go = 0;
		wipe_exitMelt(width, height, ticks);
	}

	return !go;
}
