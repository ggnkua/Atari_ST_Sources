/*
 * tos.c - GEM/TOS graphics routines
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#include "space.h"

#ifdef MEGAMAX
#include <gem.h>
#define IS_PATTERN PATTERN_IS
#define IS_HOLLOW  HOLLOW_IS
#define	MD_REPLACE WR_REPLACE

extern errno;

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];

int work_in[11];
int work_out[57];
int pxyarray[10];	/* input point array */
perror(s) char *s; { printf("%s: %d\n", s, errno); }
abort() { exit(1); }

#else
#include <gemfast.h>
#endif

#include <osbind.h>

#define COLORI	13
#define	move(y, x)	{ Cconws("\033Y"); Cconout(32+(y)); Cconout(32+(x)); }

long altscrn; /* for page flipping */
long orgscrn; /* for cleanup */

getkey()
{
	return Crawcin();
}

#ifdef FILLMODE

#define MAXCOLOR 4
#define BOTPATTERN 5
#define UPPATTERN 1

setcolor(val)
{
	vsf_color(handle, val);
}

setpattern(val)
{
	vsf_style(handle, val);
}

int (*style)();
int wall0, wall1, door, styleused;
int num_colors, colors[MAXCOLOR-2][3];

int bcolors[MAXCOLOR-2][3] = {
	600, 600, 600,
	400, 400, 400,
}; 

#endif

initscrn()
{
	int work_in[11], work_out[57];
	int i, n;
	long j;

	for (i = 0; i < 10; i++) work_in[i] = 1;
	work_in[10] = 2;
	v_opnvwk(work_in, &handle, work_out);
	vporg_x = (work_out[0]+1)/2; /* maze viewport origin */
	vporg_y = (work_out[1]+1)/4; /* in absolute coordinates */
	maxx = work_out[0]/3; /* viewport size is 2*maxx */
	maxy = work_out[1]/4; /* by 2*maxy */
	move(0,0);
	v_exit_cur(handle);
	v_clrwk(handle);
	for (i = work_out[COLORI] >> 1, n = 0; i; i >>= 1) ++n;
	j = (long)(work_out[0]+1 >> 4)*(work_out[1]+1)*n*sizeof(short)+255;
	altscrn = ((long)Malloc(j)+255) & ~0xFFL;
	orgscrn = Physbase();
	Setscreen(altscrn,-1L,-1L);
	v_clrwk(handle);
	Setscreen(orgscrn,-1L,-1L);
#ifdef FILLMODE
	num_colors = work_out[COLORI] < MAXCOLOR ? work_out[COLORI]
						 : MAXCOLOR;
	if (num_colors > 3) /* use shades of gray instead of patterns */
	{
		/* save old color values */
		for (i = 2; i < num_colors; i++)
			vq_color(handle, i, 1, colors[i-2]);
		/* set new values */
		for (i = 2; i < MAXCOLOR; i++)
		{
			vs_color(handle, i, bcolors[i-2]);
		}
		style	  = setcolor;
		door	  = BLACK;
		wall0	  = 2;
		wall1	  = 3;
		styleused = IS_SOLID;
	}
	else
	{
		style	  = setpattern;
		wall0	  = IP_3PTRN;
		wall1	  = IP_4PTRN;
		door	  = IP_1PTRN;
		styleused = IS_PATTERN;
	}
#endif
}

showmap()
{
	int r, c;
	v_clrwk(handle);
	v_enter_cur(handle);
	move(0, 0);
	for (r = 0; r < (2*MAZEROWS); r++)
	{
		for (c = 0; c < 2*MAZECOLS; ++c ) Cconout(maze[2*MAZECOLS*r+c]);
		Cconws("\r\n");
	}
	move(1 + (m.p.y << 1), (MAZECOLS-m.p.x << 1)-2);
	Cconout("v<^>"[m.p.dir]);
	Cconout('\010'); /* backspace */
	getkey();
	move(0, 0);
	v_exit_cur(handle);
	v_clrwk(handle);
}

quit(exitcode)
{
#ifdef FILLMODE
	int i;
	if (num_colors > 2)
		for (i = 2; i < num_colors; i++)
			vs_color(handle, i, colors[i-2]);
#endif
	Setscreen(orgscrn, orgscrn, -1);
	v_enter_cur(handle);
	v_clsvwk(handle);
	exit(exitcode);
}

/* image is painted in alternate screen then displayed */

show(nxt)
	register warray_t *nxt;
{
	int xy[10];
	long nxtscrn;

	nxtscrn = altscrn;
	Setscreen(altscrn,-1L,-1L);
	vswr_mode(handle, MD_REPLACE);
	/* frame viewport - erase old contents */
#ifdef FILLMODE
	/* blacken the viewport which is overlayed by walls */
	/* - this and the painting of doors */
	/* are the only places where the painter's algorithm is used */
	vsf_interior(handle, IS_PATTERN);
	vsf_perimeter(handle, 0);
	vsf_color(handle, BLACK);
	xy[0] = vporg_x - maxx; xy[1] = vporg_y-maxy;
	xy[2] = vporg_x + maxx; xy[3] = vporg_y;
	vsf_style(handle, UPPATTERN);
	v_bar(handle, xy);
	xy[0] = vporg_x - maxx; xy[1] = vporg_y;
	xy[2] = vporg_x + maxx; xy[3] = vporg_y+maxy;
	vsf_style(handle, BOTPATTERN);
	v_bar(handle, xy);
	vsf_interior(handle, styleused);
#else
	/* clear the viewport */
	vsf_interior(handle, IS_HOLLOW);
	xy[0] = vporg_x - maxx; xy[1] = vporg_y-maxy;
	xy[2] = vporg_x + maxx; xy[3] = vporg_y+maxy;
	v_bar(handle, xy);
#endif

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
#ifdef FILLMODE
			(*style)(door);
#endif
		}
		else
		{
			xy[3] = vporg_y - nxt->yr;
			xy[9] = xy[1] = vporg_y - nxt->yl;
#ifdef FILLMODE
			(*style)(nxt->yr == nxt->yl ? wall0 : wall1);
#endif
		}
#ifdef FILLMODE
		v_fillarea(handle, 5, xy);
#endif
		v_pline(handle, 5, xy);
		nxt = nxt->prv;
	}
	altscrn = Physbase();
	Setscreen(-1L, nxtscrn, -1L);
}
