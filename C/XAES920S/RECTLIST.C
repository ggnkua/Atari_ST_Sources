/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <mintbind.h>
#include <string.h>
#
#include "xa_types.h"
#include "xa_globl.h"

#include "c_window.h"
#include "rectlist.h"

/*
 *	Rectangle List Generator 
 *	- Generates a list of clipping rectangles for a given window.
 *	(Not a routine I'm proud of I'm afraid, but it seems to work ok)
 *	++cg[29/9/96]: as I've not managed to debug Johan's rect list stuff,
 *	here's a mod to my original algorithm that only does a single malloc...
 */

global
XA_RECT_LIST *generate_rect_list(LOCK lock, XA_WINDOW *w)
{
	XA_WINDOW *wl;
	XA_RECT_LIST *rl, *rlist, *nrl, *cnrl, *rl_next;
	XA_RECT_LIST *free_list;
	RECT r_ours, r_win;
	short win_cnt, f;

	if unlocked(winlist)			/* HR: 131200 Moved up. */
		Sema_Up(WIN_LIST_SEMA);

	if (w->rect_start)
		free(w->rect_start);

	win_cnt = 0;
	for (wl = w->prev; wl; wl = wl->prev)
		win_cnt++;		

/* Block allocate the required space (approximately) */	
	w->rect_start = rlist = xmalloc(sizeof(XA_RECT_LIST) * (win_cnt * 6 + 2),4);
	rlist++;
	rlist->r = w->r;
	rlist->next = nil;

	if (win_cnt)
	{
		rl = free_list = rlist + 1;
		for (f = 0; f < win_cnt * 6; f++)
			free_list[f].next = &free_list[f + 1];
		
		free_list[win_cnt * 6 - 1].next = nil;
		
		wl = w->prev;
		while(wl)
		{
			nrl = nil;
			for (rl = rlist; rl; rl = rl_next)
			{
				r_win = wl->r;		
				r_ours = rl->r;				
				if (rc_intersect(&r_ours, &r_win))		/* If window intersects this rectangle, process */
				{
	/* If window doesn't completely mask this rectangle, create new results */				
					if((r_ours.w != r_win.w) or (r_ours.h != r_win.h))
					{
						if(r_win.x != r_ours.x)
						{
							cnrl = free_list;
							free_list = free_list->next;
							cnrl->r.x = r_ours.x;
							cnrl->r.y = r_ours.y;
							cnrl->r.w = r_win.x - r_ours.x;
							cnrl->r.h = r_ours.h;
							cnrl->next = nrl;
							nrl = cnrl;
						}
						if(r_win.x + r_win.w != r_ours.x + r_ours.w)
						{
							cnrl = free_list;
							free_list = free_list->next;
							cnrl->r.x = r_win.x + r_win.w;
							cnrl->r.y = r_ours.y;
							cnrl->r.w = (r_ours.x + r_ours.w) - (r_win.x + r_win.w);
							cnrl->r.h = r_ours.h;
							cnrl->next = nrl;
							nrl = cnrl;
						}
						if(r_win.y != r_ours.y)
						{
							cnrl = free_list;
							free_list = free_list->next;
							cnrl->r.x = r_win.x;
							cnrl->r.y = r_ours.y;
							cnrl->r.w = r_win.w;
							cnrl->r.h = r_win.y - r_ours.y;
							cnrl->next = nrl;
							nrl = cnrl;
						}
						if(r_win.y + r_win.h != r_ours.y + r_ours.h)
						{
							cnrl = free_list;
							free_list = free_list->next;
							cnrl->r.x = r_win.x;
							cnrl->r.y = r_win.y + r_win.h;
							cnrl->r.w = r_win.w;
							cnrl->r.h = (r_ours.y + r_ours.h) - (r_win.y + r_win.h);
							cnrl->next = nrl;
							nrl = cnrl;
						}
					} else
					{
						DIAG((D.r,-1,"  Obscured - freeing\n"));
					}
					rl_next = rl->next;			/* Release the original rectangle */
					rl->next = free_list;			/* Add original rectangle to the free list */
					free_list = rl;
				} else		/* Keep the current rectangle, it hasn't been changed */
				{
					rl_next = rl->next;
					rl->next = nrl;
					nrl = rl;
				}
			}
			rlist = nrl;
			wl = wl->prev;
		}
	}
	
	w->rect_list = w->rect_user = w->rect_start;
	
	if (rlist)
		*w->rect_start = *rlist;		/* HR: PC code is efficient */
	else
	{
		free(w->rect_start);
		w->rect_list = w->rect_user = w->rect_start = nil;
	}	

#if GENERATE_DIAGS		
	DIAG((D.r,w->pid,"rect_list dump h:%d(%d/%d,%d/%d) for %s(%d):\n",
			w->handle, w->r.x, w->r.y, w->r.w, w->r.h,
			w->owner->name, w->owner->pid));
	for (rlist = w->rect_start; rlist; rlist = rlist->next)
		DIAG((D.r,w->pid,"{[%d/%d,%d/%d] @%lx, next=%lx}\n", rlist->r, rlist, rlist->next));

#endif

	if unlocked(winlist)			/* HR: 131200 Moved down. */
		Sema_Dn(WIN_LIST_SEMA);

	return w->rect_start;
}

global
void dispose_rect_list(XA_WINDOW *w)
{
	if (w->rect_start)
	{
		DIAG((D.rect,-1,"free rect list\n"));
		free(w->rect_start);
	}
	w->rect_start = w->rect_user = w->rect_list = nil;
}

global
XA_RECT_LIST *rect_get_user_first(XA_WINDOW *w)
{
	w->rect_user = w->rect_start;
	return w->rect_user;
}

global
XA_RECT_LIST *rect_get_system_first(XA_WINDOW *w)
{
	w->rect_list = w->rect_start;
	return w->rect_list;
}

global
XA_RECT_LIST *rect_get_user_next(XA_WINDOW *w)
{
	if (w->rect_user)
		w->rect_user = w->rect_user->next;
	return w->rect_user;
}

global
XA_RECT_LIST *rect_get_system_next(XA_WINDOW *w)
{
	if (w->rect_list)
		w->rect_list = w->rect_list->next;
	return w->rect_list;
}

/*
 *	Compute intersection of two rectangles; put result rectangle
 *	into *d; return TRUE if intersection is nonzero.
 *
 *	(Original version of this function taken from Digital Research's
 *	GEM sample application `DEMO' [aka `DOODLE'],  Version 1.1,
 *	March 22, 1985)
 */
global
bool rc_intersect(const RECT *s, RECT *d)
{
#define max(x,y)	(((x)>(y))?(x):(y))
#define min(x,y)	(((x)<(y))?(x):(y))
	short w1 = s->x + s->w,
	      w2 = d->x + d->w,
	      h1 = s->y + s->h,
	      h2 = d->y + d->h;
	d->x = max(s->x, d->x);
	d->y = max(s->y, d->y);
/*	if (s->x > d->x) d->x = s->x;
	if (s->y > d->y) d->y = s->y;
*/	d->w = min(w1, w2) - d->x;
	d->h = min(h1, h2) - d->y;

	return d->w > 0 and d->h > 0;
}
