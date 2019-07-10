/*
 * dos.c - EGA compatible (CGA mode) graphics routines
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#include <stdio.h>
#include <graph.h>
#include <conio.h>
#include "space.h"

short old_mode;
short page = 0;

getkey()
{
	return getch();
}

initscrn()
{
	struct videoconfig config;

	old_mode = _setvideomode(_HRESBW); /* CGA 640x200 */
	_getvideoconfig(&config);
	_displaycursor(_GCURSOROFF);
	_setvisualpage(0);
	_setactivepage(0);
	_clearscreen(_GCLEARSCREEN);
	_setactivepage(1);
	_clearscreen(_GCLEARSCREEN);
	maxx = config.numxpixels/3; /* viewport size is 2*maxx */
	maxy = config.numypixels/4; /* by 2*maxy */
	vporg_x = config.numxpixels/2; /* maze viewport origin */
	vporg_y = config.numypixels/4; /* in absolute coordinates */
}

showmap()
{
	int r, c;
	_clearscreen(_GCLEARSCREEN);
	_displaycursor(_GCURSORON);
	_settextposition(0, 0);
	for (r = 0; r < (2*MAZEROWS); r++)
	{
		for (c = 0; c < 2*MAZECOLS; ++c ) putchar(maze[2*MAZECOLS*r+c]);
		_outtext("\r\n");
	}
	_settextposition(1 + (m.p.y << 1), (MAZECOLS-m.p.x << 1)-2);
	putchar("v<^>"[m.p.dir]);
	putchar('\010'); /* backspace */
	getkey();
	_settextposition(0, 0);
	_displaycursor(_GCURSOROFF);
	_clearscreen(_GCLEARSCREEN);
}

quit(exitcode)
{
	_displaycursor(_GCURSORON);
	_setvideomode(old_mode);
	exit(exitcode);
}

/* image is painted in alternate screen then displayed */

show(nxt)
	register warray_t *nxt;
{
	int xy[10], i;

	/* clear the viewport */
	_setactivepage(++page & 1);
	_clearscreen(_GVIEWPORT);
	_rectangle(_GBORDER,vporg_x-maxx,vporg_y-maxy,vporg_x+maxx,vporg_y+maxy);
	while (nxt != &wstart)
	{
		xy[8] = xy[6] = xy[0] = nxt->xl;
		xy[4] = xy[2] = nxt->xr;
		xy[5] = vporg_y + nxt->yr;
		xy[7] = vporg_y + nxt->yl;
		if (nxt->type == DOOR)
		{
			xy[3] = vporg_y - (nxt->yr >> 1);
			xy[9] = xy[1] = vporg_y - (nxt->yl >> 1);
		}
		else
		{
			xy[3] = vporg_y - nxt->yr;
			xy[9] = xy[1] = vporg_y - nxt->yl;
		}
		_moveto(xy[0], xy[1]);
		for (i = 2; i < 10; i += 2) _lineto(xy[i],xy[i+1]);
		nxt = nxt->prv;
	}
	_setvisualpage(page & 1);
}
