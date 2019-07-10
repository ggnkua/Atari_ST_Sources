/*
 * hide.c - Translate display set into hidden-surface, perspective list
 *
 * Copyright 1990 by Bruce D. Szablak
 *
 * This software is distributed "as is" with no warrantee of fitness
 * for any use. Unrestricted use of this software is hereby granted.
 */

#include <stdio.h>
#include <assert.h>
#include "space.h"

#define NULL 0

#define D_OVER_S PT5

/* HGHT is so the closest possible wall will be seen to be half screen high. */
#ifdef SMPCONST
#define HGHT 205
#else
#define HGHT FFMlt(FIDiv(IntToFix(4),10),PT5)
#endif

/*
 * simplifying assumptions:
 *	assume (x1,z1) are the coords of the left edge of the wall, and
 *	(x2,z2) are the coords of the right edge of the wall as viewed from
 *	the viewpoint.
 */

#define LEFT 1
#define RIGHT 2

#define BITS(x,z)  (((x) < -(z) ?  LEFT : 0) | ((x) > (z) ?  RIGHT : 0))

project(winfo)
	warray_t *winfo;
{
	register Fixpt	x1e = winfo->x1e,
			x2e = winfo->x2e,
			z1e = winfo->z1e,
			z2e = winfo->z2e;
	register int	c1, c2;

	/* ignore walls behind eye */
	if (z1e <= 0 && z2e <= 0) return 0;

	x1e = FFMlt(x1e, D_OVER_S); /* scale so that viewing triangle is */
	x2e = FFMlt(x2e, D_OVER_S); /* defined by z=-x and z=x */

	/* clip wall to viewing triangle */

	c1 = BITS(x1e, z1e);  c2 = BITS(x2e, z2e);

	while (c1 || c2)
	{
		if (c1 & c2) return 0; /* both endpoints clipped by same edge */
	
		if (c1 & LEFT)
		{
			/* crosses z = -x */
			z1e = -(x1e = FFDiv(FFMlt(z1e,x2e)-FFMlt(z2e,x1e),
					(x1e - x2e) + (z1e - z2e)));
			c1 = BITS(x1e, z1e);
		}
		else if (c2 & RIGHT)
		{
			/* crosses z = x */
			z2e = x2e = FFDiv(FFMlt(z2e,x1e)-FFMlt(z1e,x2e),
					(x1e - x2e) - (z1e - z2e));
			c2 = BITS(x2e, z2e);
		}
		else if (c1 & RIGHT)
		{
			/* crosses z = x */
			z1e = x1e = FFDiv(FFMlt(z2e,x1e)-FFMlt(z1e,x2e),
					(x1e - x2e) - (z1e - z2e));
			c1 = BITS(x1e, z1e);
		}
		else if (c2 & LEFT)
		{
			/* crosses z = -x */
			z2e = -(x2e = FFDiv(FFMlt(z1e,x2e)-FFMlt(z2e,x1e),
					(x1e - x2e) + (z1e - z2e)));
			c2 = BITS(x2e, z2e);
		}
	}
	
	winfo->xl = vporg_x + FixToInt(maxx*FFDiv(x1e,z1e));
	winfo->xr = vporg_x + FixToInt(maxx*FFDiv(x2e,z2e));
	if (winfo->xl == winfo->xr) return 0; /* ignore totally clipped walls */
	ASSERT(winfo->xl <= winfo->xr);
	ASSERT(winfo->xl >= 0);
	ASSERT(winfo->xr <= 2*(vporg_x+1));

	winfo->yl = FixToInt(maxy*FFDiv(HGHT,z1e));
	winfo->yr = FixToInt(maxy*FFDiv(HGHT,z2e));
	if (winfo->yl > maxy) winfo->yr = winfo->yl = maxy;
	ASSERT(winfo->yr <= maxy);

	return 1;
}

warray_t * /* pointer to the new wall segment */
splitwall(splte, spltr)
	warray_t *splte, /* wall to be split */
		 *spltr; /* wall that causes split */
{
	warray_t *newwall = wxtra++;

	/* Original wall's left edge is hidden.
	   New wall is the same as the old except the right edge is hidden. */

	newwall->type = splte->type;
	newwall->xl = splte->xl; /* inherit left edge values */
	newwall->yl = splte->yl;
	newwall->xr = spltr->xl; /* right edge values depend on the splitter */
	newwall->yr = splte->yl + FFMlt(FFDiv(splte->yr - splte->yl,
			splte->xr - splte->xl), newwall->xr - splte->xl);

	splte->xl = spltr->xr;
	splte->yl = splte->yl + FFMlt(FFDiv(splte->yr - splte->yl,
			splte->xr - splte->xl), splte->xr - splte->xl);
	return newwall;
}

addwall(w)
	warray_t *w;
{
	warray_t *n, *s;

	if (w->xl == w->xr) return;

	/* Create a list of wall descriptors sorted in order of
	   increasing x value in screen coordinates. If two walls
	   overlap, calculate what is hidden: left edge, right edge,
	   center portion (splits wall), or the entire wall. The code
	   assumes that walls already added are closer to the eye than
	   the new wall (asserts are not used because split walls are
	   not completely initialized. */

	for (n = wstart.nxt; n != &wstart; n = n->nxt)
	{
		if (n->type == DOOR) continue;
		if (w->xl >= n->xr) /* edge to the right of n's right edge? */
		{
			continue; /* no overlap - look at next wall */
		}
		if (w->xr <= n->xl) /* edge to the left of n's left edge? */
		{
			w->nxt = n; /* no overlap - just insert into list */
			w->prv = n->prv; n->prv = w; w->prv->nxt = w;
			return; 
		}
		if (w->xl < n->xl) /* overlap n's left edge? - hide something */
		{
			if (w->xr > n->xr) /* cover n's right edge? */
			{
				/* ASSERT(w->z2e >= n->z2e);  n nearer eye? */
				s = splitwall(w, n); /* n splits w */
				s->nxt = n;
				s->prv = n->prv; n->prv = s; s->prv->nxt = s;
				continue; /* w may overlap another wall */
			}
			w->xr = n->xl; /* only w's right edge is hidden */
			w->yr = w->yl + FFMlt(FFDiv(w->yr - w->yl,
					w->xr - w->xl), w->xr - w->xl);
			w->nxt = n;
			w->prv = n->prv; n->prv = w; w->prv->nxt = w;
			return; 
		}
		if (w->xr <= n->xr) /* no edge overlap? */
		{
			/* ASSERT(w->z2e >= n->z2e); n nearer eye? */
			/* else w splits n:
			 *	splitwall(n, w)->follow(n);
			 *	w->follow(n);
			 */
			return; /* w is hidden by n */
		}
		w->xl = n->xr; /* only w's left edge is hidden */
		w->yl = w->yl + FFMlt(FFDiv(w->yr - w->yl,
				w->xr - w->xl), w->xr - w->xl);
		/* w might overlap next n so do again */
	}
	/* insert at end of list - begining of list if first wall to be added */
	w->prv = wstart.prv;
	w->nxt = &wstart;
	if (wstart.nxt == &wstart) wstart.prv = wstart.nxt = w;
	else wstart.prv = wstart.prv->nxt = w;
}

warray_t *
hide()
{
	warray_t *nxt;

	wstart.nxt = wstart.prv = &wstart;
	wxtra = wend;
	for (nxt = warray; nxt < wend; nxt++)
		if (project(nxt))
		{
			addwall(nxt);
		}
	return wstart.prv;
}
