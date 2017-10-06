/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

HR: This is a old version that is used anymore

#include <VDI.H>
#include <MINTBIND.H>
#include <memory.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "C_WINDOW.H"
#include "EVENTS.H"
#include "rectlist.h"

#define max(x,y)	(((x)>(y))?(x):(y))
#define min(x,y)	(((x)<(y))?(x):(y))


#define BLKALLOC	10		/* Elements to allocate at a time */
static XA_RECT_LIST *unused = NULL;	/* List of free elements */
#define ALLOC(elem)	{					\
				if (!unused)			\
					new_elements();		\
				elem = unused;			\
				unused = unused->next;	\
			}
#define FREE(elem)	{					\
  				elem->next = unused;	\
				unused = elem;			\
			}

/*
 *	Compute intersection of two rectangles; put result rectangle
 *	into *d; return TRUE if intersection is nonzero.
 *
 *	(Original version of this function taken from Digital Research's
 *	GEM sample application `DEMO' [aka `DOODLE'],  Version 1.1,
 *	March 22, 1985)
 */

short rc_intersect(const GRECT *s, GRECT *d)
{
	short x1, y1, x2, y2;

	x1 = max(s->g_x, d->g_x);
	x2 = min(s->g_x + s->g_w, d->g_x + d->g_w);
	if (x2 <= x1)
		return 0;

	y1 = max(s->g_y, d->g_y);
	y2 = min(s->g_y + s->g_h, d->g_y + d->g_h);
	if (y2 <= y1)
		return 0;

	d->g_x = x1;
	d->g_y = y1;
	d->g_w = x2 - x1;
	d->g_h = y2 - y1;
	return 1;
}

static int intersect(const XA_RECT_LIST *s, const XA_WINDOW *d, XA_RECT_LIST *r)
{
	short x1, y1, x2, y2;

	x1 = max(s->x, d->x);
	x2 = min(s->x + s->w, d->x + d->w);
	if (x2 <= x1)
		return 0;

	y1 = max(s->y, d->y);
	y2 = min(s->y + s->h, d->y + d->h);
	if (y2 <= y1)
		return 0;
	
	r->x = x1;
	r->y = y1;
	r->w = x2 - x1;
	r->h = y2 - y1;

	return 1;
}

static int w_intersect(const XA_RECT_LIST *s, const XA_WINDOW *d, XA_RECT_LIST *r)
{
	short x1, y1, x2, y2;

	x1 = max(s->x, d->wx);
	x2 = min(s->x + s->w, d->wx + d->ww);
	if (x2 <= x1)
		return 0;

	y1 = max(s->y, d->wy);
	y2 = min(s->y + s->h, d->wy + d->wh);
	if (y2 <= y1)
		return 0;
	
	r->x = x1;
	r->y = y1;
	r->w = x2 - x1;
	r->h = y2 - y1;

	return 1;
}

static void new_elements(void)
{
	int i;
	
	unused = (XA_RECT_LIST *)malloc(BLKALLOC * sizeof(XA_RECT_LIST));
	for(i = 0; i < BLKALLOC - 1; i++)
		unused[i].next = &unused[i + 1];
	unused[BLKALLOC - 1].next = NULL;
#ifdef RL_DIAGS
	DIAGS(("New rectangles (%ld)\n", (long)unused));
#endif
}


XA_RECT_LIST *create_work_list(XA_WINDOW *w)
{
	XA_RECT_LIST *rl, *work, *cnrl, isect;
	
	rl = w->rl_full;
	work = NULL;

#ifdef RL_DIAGS
	DIAGS(("Creating new worklist\n"));
#endif

	while(rl)
	{
		if (w_intersect(rl, w, &isect))
		{
			ALLOC(cnrl);
			cnrl->x = isect.x;
			cnrl->y = isect.y;
			cnrl->w = isect.w;		/* Was + 1 */
			cnrl->h = isect.h;		/* Was + 1 */
			cnrl->next = work;
			work = cnrl;
		}
		rl = rl->next;
	}
	
	return work;
}

static void free_rl_list(XA_RECT_LIST *list)
{
	XA_RECT_LIST *cur;

	if (!list)
		return;

	cur = list;
	while(cur->next)
		cur = cur->next;
	cur->next = unused;
	unused = list;

}

/*
	Rectangle List Generator 
	- generates a list of clipping rectangles for a given window.
*/

XA_RECT_LIST *generate_rect_list(XA_WINDOW *w)
{
	XA_WINDOW *wl;
	XA_RECT_LIST *rl, *rlist, *nrl, *cnrl;
	GRECT r_ours, r_win;
	XA_RECT_LIST *rlnext, isect;

#ifdef RL_DIAGS
	DIAGS(("Generating new rectlist\n"));
#endif

	ALLOC(rlist);	
	rlist->x = w->x;
	rlist->y = w->y;
	rlist->w = w->w;
	rlist->h = w->h;
	rlist->next = NULL;

	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	wl = w->prev;
	while(wl)
	{
		if (wl->is_open)
		{

			nrl = NULL;
			for(rl = rlist; rl; rl = rlnext)
			{
				rlnext = rl->next;

				if (!intersect(rl, wl, &isect))	/* Any overlap? */
				{
					rl->next = nrl;					/* Keep the current rectangle, */
					nrl = rl;						/* it hasn't changed */
				} else
				{
					if ((rl->w != isect.w) || (rl->h != isect.h))	/* Not complete covering? */
					{
						if (rl->x != isect.x)	/* Not at left border? */
						{
							ALLOC(cnrl);
							cnrl->x = rl->x;
							cnrl->y = isect.y;
							cnrl->w = isect.x - rl->x;
							cnrl->h = isect.h;
							cnrl->next = nrl;
							nrl = cnrl;
						}
						
						if (isect.x + isect.w != rl->x + rl->w)	/* Not at right border? */
						{
							ALLOC(cnrl);
							cnrl->x = isect.x + isect.w;
							cnrl->y = isect.y;
							cnrl->w = rl->x + rl->w - (isect.x + isect.w);
							cnrl->h = isect.h;
							cnrl->next = nrl;
							nrl = cnrl;
						}
						
						if (isect.y != rl->y)	/* Not at top border? */
						{
							ALLOC(cnrl);
							cnrl->x = rl->x;
							cnrl->y = rl->y;
							cnrl->w = rl->w;
							cnrl->h = isect.y - rl->y;
							cnrl->next = nrl;
							nrl = cnrl;
						}
						
						if (isect.y + isect.h != rl->y + rl->h)	/* Not at bottom border? */
						{
							ALLOC(cnrl);
							cnrl->x = rl->x;
							cnrl->y = isect.y + isect.h;
							cnrl->w = rl->w;
							cnrl->h = rl->y + rl->h - (isect.y + isect.h);
							cnrl->next = nrl;
							nrl = cnrl;
						}
						
						FREE(rl);		/* Now split, so throw away original! */

					} else
					{
						FREE(rl);		/* Invisible - throw away! */

					}
				}
			}
			rlist = nrl;
		}
		wl = wl->prev;
	}
	
	Psemaphore(3, WIN_LIST_SEMAPHORE, 0L);
	
	return rlist;
}


void invalidate_rect_lists(XA_WINDOW *wind)
{
#ifdef RL_DIAGS
	DIAGS(("Invalidating lists\n"));
#endif
	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

	while(wind)
	{
		free_rl_list(wind->rl_full);
		wind->rl_full = NULL;
		free_rl_list(wind->rl_work);
		wind->rl_work = NULL;
		generate_rect_list(wind);		/* ++cg[29/8/96]: regenerate the rectangle lists here to avoid redraw problems */
		wind = wind->next;
	}

	Psemaphore(3, WIN_LIST_SEMAPHORE, 0L);

}
