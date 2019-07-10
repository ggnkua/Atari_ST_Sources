/*
 * space.c - global variables
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#include "space.h"

char maze[947];

attr_t m;

long	mazemap[MAZEROWS]; /* MAZECOLS < 32 */

int istep = 11;	/* how many steps used to find candidate walls to display */
		/* can be used to implement lighting effects */

int handle, debug, anim, vporg_x, vporg_y, maxx, maxy;

int dx[4] = { 0, 1, 0, -1 }, dy[4] = { 1, 0, -1, 0 };

warray_t warray[ARRAYSIZ], wstart, *wend, *wxtra;
