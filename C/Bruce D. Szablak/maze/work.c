/*
 * work.c - Create display working set as a list of segements
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#include <assert.h>
#include "space.h"


#define Mapclear()	{ register i; for (i=MAZEROWS; i; mazemap[--i]=0); }
#define Mapmark(x,y)	{ mazemap[y] |= 1L << (x); }
#define Mapcheck(x,y)	((mazemap[y] & (1L << (x))) == 0)

#define FIFOSIZ		40

struct	fifo {
	short	x, y, dir,
		steps,
		choices;
};

#define	Queue(nx, ny, ndir, s, c)	\
{	add->x = (nx); add->y = (ny); add->dir = (ndir); \
	add->steps = (s); \
	add->choices = (c); \
	add = add == fifo ? add - 1 : add + FIFOSIZ - 1; \
}

#define	Dequeue(nx, ny, ndir, s, c)	\
{ 	nx = take->x; ny = take->y; ndir = take->dir; \
	s = take->steps; \
	c = take->choices; \
	take = take == fifo ? take - 1 : take + FIFOSIZ - 1; \
}

#define FifoInit() { add = take = fifo + FIFOSIZ - 1; }

/*				   0^ increasing y
 *				    |
 *  coordinate system:       3      |       1
 *            decreasing x <--------+--------> increasing x
 *
 *  Eye actual position is translated (.5,.5) from the integer
 *  values passed to work_set().
 */

wadd(type, x, y, wdir, eye)
	register loc_t *eye;
{
	register warray_t *wnxt = wend++;
	register Fixpt x1, y1, x2, y2, d1, d2;

	/* first translate to eye origin */

	/* Order coords so that when the eye views the wall the left edge
	   corresponds to 1's coords and the right edge is 2's coords.
	   Thus, if the wall is behind the eye the rotation caused by
	   turning is taken into account. */

	if (type == DOOR)
	{
		d1 = ONE8TH; d2 = TWO8TH;
	}
	else
	{
		d1 = PT5; d2 = ONE;
	}
	switch (wdir)
	{
	case	0:
		x2 = (x1 = IntToFix(x - eye->x) - d1) + d2;
		y2 = y1 = IntToFix(y - eye->y) + PT5;
		break;
	case	1:
		y1 = (y2 = IntToFix(y - eye->y) - d1) + d2;
		x1 = x2 = IntToFix(x - eye->x) + PT5;
		break;
	case	2:
		x1 = (x2 = IntToFix(x - eye->x) - d1) + d2;
		y2 = y1 = IntToFix(y - eye->y) - PT5;
		break;
	case	3:
		y2 = (y1 = IntToFix(y - eye->y) - d1) + d2;
		x1 = x2 = IntToFix(x - eye->x) - PT5;
		break;
	}

	/* Then rotate to eye relative coords */

	switch (eye->dir)
	{
	case	0:
		wnxt->x1e = x1; wnxt->x2e = x2;
		wnxt->z1e = y1; wnxt->z2e = y2;
		break;
	case	1:
		wnxt->x1e = -y1; wnxt->x2e = -y2;
		wnxt->z1e = x1; wnxt->z2e = x2;
		break;
	case	2:
		wnxt->x1e = -x1; wnxt->x2e = -x2;
		wnxt->z1e = -y1; wnxt->z2e = -y2;
		break;
	case	3:
		wnxt->x1e = y1; wnxt->x2e = y2;
		wnxt->z1e = -x1; wnxt->z2e = -x2;
		break;
	}

	wnxt->type = type;
}

#define LEFT	1
#define RIGHT	2
#define L_OR_R	3
#define FIRST	4
#define DODOOR	8

void
work_set(eye, turn)
	attr_t *eye;
{
	register nx, ny, ndir;
	register struct fifo *add, *take;
	int x, y, dir, steps, choices, type, cansee;
	struct fifo fifo[FIFOSIZ];

	cansee = eye->flags & SEEINVIS;
	WInit();
	FifoInit();
	Queue(eye->p.x, eye->p.y, eye->p.dir, istep,
		(turn ? FIRST : DODOOR)|LEFT|RIGHT);

	Mapclear();
	Mapmark(eye->p.x, eye->p.y);

	do
	{
		Dequeue(x, y, dir, steps, choices);
		--steps;
		/* always step forward */
		if (type = look(maze, x, y, ndir = dir))
		{
			if ((type & DOOR) &&
				(cansee || (type & SEEINVIS) == 0))
			{
				wadd(DOOR, x, y, ndir, &eye->p);
			}
			wadd(WALL, x, y, ndir, &eye->p);
			if ((choices & DODOOR) && (type & DOOR)) goto do_door;
		}
		else
		{
		do_door:
			nx = x + dx[ndir];
			ny = y + dy[ndir];

			if (Mapcheck(nx, ny) && steps)
			{
				Queue(nx, ny, ndir, steps, choices & L_OR_R);
				Mapmark(nx, ny);
			}
		}
		if (choices & LEFT)
		{
			if (type = look(maze, x, y, ndir = TURN_LEFT(dir)))
			{
				if ((type & DOOR) &&
					(cansee || (type & SEEINVIS) == 0))
				{
					wadd(DOOR, x, y, ndir, &eye->p);
				}
				wadd(WALL, x, y, ndir, &eye->p);
			}
			else
			{
				nx = x + dx[ndir];
				ny = y + dy[ndir];

				if (Mapcheck(nx, ny) && steps)
				{
					Queue(nx, ny, ndir, steps, choices&FIRST
						? L_OR_R : RIGHT);
					Mapmark(nx, ny);
				}
			}
		}
		if (choices & RIGHT)
		{
			if (type = look(maze, x, y, ndir = TURN_RIGHT(dir)))
			{
				if ((type & DOOR) &&
					(cansee || (type & SEEINVIS) == 0))
				{
					wadd(DOOR, x, y, ndir, &eye->p);
				}
				wadd(WALL, x, y, ndir, &eye->p);
			}
			else
			{
				nx = x + dx[ndir];
				ny = y + dy[ndir];

				if (Mapcheck(nx, ny) && steps)
				{
					Queue(nx, ny, ndir, steps, choices&FIRST
						? L_OR_R : LEFT);
					Mapmark(nx, ny);
				}
			}
		}
	}
	while (add != take);
}
