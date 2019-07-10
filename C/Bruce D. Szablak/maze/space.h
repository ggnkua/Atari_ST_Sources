/*
 * space.h - maze definitions
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#ifndef _SPACE_H
#define _SPACE_H

#ifdef MEGAMAX
#define short int
#define void
#endif

#ifndef _FIXPT_H
#include "fixpt.h"
#endif

#define MAZECOLS 21
#define MAZEROWS 11

#define ARRAYSIZ	(2*(MAZECOLS+MAZEROWS))

#define	Dostep(x, y, dir) { x += dx[dir]; y += dy[dir]; }
#define	Unstep(x, y, dir) { x -= dx[dir]; y -= dy[dir]; }

#define TURN_LEFT(dir) ((dir + 3) & 3)
#define TURN_RIGHT(dir) ((dir + 1) & 3)
#define TURN_AROUND(dir) ((dir + 2) & 3)

typedef struct {
	short	x, y, z, dir;
} loc_t;

typedef struct {
	loc_t	p;
	int	flags;
#	define	SEEINVIS 0x0001
#	define	WALL	 0x4000
#	define	DOOR	 0x8000

} attr_t;

#define WInit() { wend = warray; }

#define ASSERT(x)

#ifdef SMPCONST
#define ONE8TH 128
#define TWO8TH 256
#define PT5 512
#define ONE 1024
#else
#define ONE8TH FFDiv(IntToFix(1),IntToFix(8))
#define TWO8TH FFDiv(IntToFix(2),IntToFix(8))
#define PT5 FFDiv(IntToFix(1),IntToFix(2))
#define ONE IntToFix(1)
#endif

typedef struct  warray {
	struct warray *nxt, *prv;
	Fixpt	x1e, z1e, x2e, z2e; /* eye coordinate system */
	int	xl, yl, xr, yr;
	int	type;		/* wall type from look() */
} warray_t;

extern attr_t m;
extern warray_t warray[], wstart, *wend, *wxtra, *hide();
extern char maze[];
extern handle, debug, dx[], dy[], anim, vporg_x, vporg_y, maxx, maxy;
extern long	mazemap[];
extern istep;

/* machine dependent routines: */
extern getkey(), initscrn(), quit(), showmap(), show();

#endif
