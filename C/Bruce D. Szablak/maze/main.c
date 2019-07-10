/*
 * main.c - Test 3d maze display using a "maze-walker"
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#include <stdio.h>
#include "space.h"

getmaze()
{
	FILE *fp = fopen("maze", "r");
	char *s = maze;
	int c;
	if (fp == NULL)
	{
		perror("Cannot open maze:");
		exit(1);
	}
	while ((c = getc(fp))!=EOF) if (c != '\n') *s++ = c;
}

look(maze, x, y, dir)
	char *maze;
{
	int r = (y << 1) + 1 + dy[dir];
	int c = ((MAZECOLS-1)-x << 1) - dx[dir];
	char e =  maze[r * (2*MAZECOLS) + c];
	switch (e)
	{
	case	'-': case '|': return WALL;
	case	's': case '~': return DOOR & SEEINVIS;
	case	'#': case '=': return DOOR;
	case	' ': return 0;
	}
	printf("%d %d %d (%d,%d,%d,%d)\n", x, y, dir, r, c, e,r*(2*MAZECOLS)+c);
	abort();
}

canstep(lookat, flags)
{
	if (lookat & WALL) return 0;
	if (lookat & DOOR) return (lookat & SEEINVIS) ? (flags & SEEINVIS) : 1;
	return 1;
}

#ifdef SMPCONST
Fixpt Sin[] = {	724, 512, 392, 316 };
Fixpt Cos[] = {	724, 887, 946, 974 };
#else
Fixpt Sin[] = {	FIDiv(IntToFix(707), 1000),
		FIDiv(IntToFix(500), 1000),
		FIDiv(IntToFix(383), 1000),
		FIDiv(IntToFix(309), 1000), };

Fixpt Cos[] = {	FIDiv(IntToFix(707), 1000),
		FIDiv(IntToFix(866), 1000),
		FIDiv(IntToFix(924), 1000),
		FIDiv(IntToFix(951), 1000), };
#endif

main(argc, argv)
	char *argv[];
{
	int i;
	register warray_t *w;
	register Fixpt s, c, t, u;

	if (argc < 3)
	{
		fprintf(stderr, "usage: %s x y [dir [anim]]\n", argv[0]);
		exit(1);
	}
	getmaze();
	initscrn();
	m.p.x = atoi(argv[1]);
	m.p.y = atoi(argv[2]);
	m.p.z = 0;
	m.p.dir = argc > 3 ? atoi(argv[3]) : 0;
	anim = argc > 4 ? atoi(argv[4]) : 0;
	m.flags |= SEEINVIS;
	for(;;)
	{
		work_set(&m, 0);
		show(hide());
		switch (getkey())
		{
		case	'w':
			if (canstep(look(maze, m.p.x, m.p.y, m.p.dir), m.flags))
			{
				m.p.x += dx[m.p.dir];
				m.p.y += dy[m.p.dir];
				t = ONE >> anim;
				for (i = 1 << anim; --i;)
				{
					for (w = wend; --w >= warray; )
					{
						w->z1e -= t;
						w->z2e -= t;
					}
					show(hide());
				}
			}
			break;

		case	'a':
			work_set(&m, 1);
			s = Sin[anim-1]; c = Cos[anim-1];
			for (i = anim; i--;)
			{
				for (w = wend; --w >= warray; )
				{
					t = w->x1e; u = w->z1e;
					w->x1e = FFMlt(t,c) + FFMlt(u,s);
					w->z1e = FFMlt(u,c) - FFMlt(t,s);
					t = w->x2e; u = w->z2e;
					w->x2e = FFMlt(t,c) + FFMlt(u,s);
					w->z2e = FFMlt(u,c) - FFMlt(t,s);
				}
				show(hide());
			}
			m.p.dir = TURN_LEFT(m.p.dir);
			break;

		case	'd':
			work_set(&m, 1);
			s = Sin[anim-1]; c = Cos[anim-1];
			for (i = anim; i--;)
			{
				for (w = wend; --w >= warray; )
				{
					t = w->x1e; u = w->z1e;
					w->x1e = FFMlt(t,c) - FFMlt(u,s);
					w->z1e = FFMlt(u,c) + FFMlt(t,s);
					t = w->x2e; u = w->z2e;
					w->x2e = FFMlt(t,c) - FFMlt(u,s);
					w->z2e = FFMlt(u,c) + FFMlt(t,s);
				}
				show(hide());
			}
			m.p.dir = TURN_RIGHT(m.p.dir);
			break;

		case	'x':
			m.p.dir = TURN_AROUND(m.p.dir);
			break;

		case	'm':
			showmap();
			break;

		case	'q':
			quit(0);
		}
	}
}
