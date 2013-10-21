/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mintbind.h>
#include <string.h>
#
#include "xa_types.h"
#include "xa_globl.h"

#include "xalloc.h"
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
XA_RECT_LIST *generate_rect_list(LOCK lock, XA_WINDOW *w, short which)
{
	XA_WINDOW *wl;
	XA_RECT_LIST *rl, *rlist, *nrl, *cnrl, *rl_next;
	XA_RECT_LIST *free_list;
	RECT r_ours, r_win;
	short win_cnt, f;

	IFWL(Sema_Up(winlist);)

	
	if (w->rect_start)
	{
		w->prev_rect = *w->rect_start;		/* HR 251002: remember the first rectangle before calc */
		w->rect_prev = &w->prev_rect;		/*            This can be used to see if redraw are necessary. */
		w->prev_rect.next = nil;
		free(w->rect_start);
	}
	else
		w->rect_prev = nil;

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
				if (rc_intersect(r_ours, &r_win))		/* If window intersects this rectangle, process */
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
						DIAG((D_r,w->owner,"  Obscured - freeing\n"));
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

	if (rlist)
	{
		w->rect_list = w->rect_user = w->rect_start;
		*w->rect_start = *rlist;		/* HR: compiler code should be efficient */
	othw
		free(w->rect_start);
		w->rect_list = w->rect_user = w->rect_start = nil;
	}	

#if GENERATE_DIAGS
	if (w->handle)
	{
		DIAG((D_r,w->owner,    "[%d]rect_list dump h:%d (%d/%d,%d/%d) for %s:\n", which, w->handle, w->r, w_owner(w) ));
		if (w->rect_prev)
		{
			DIAG((D_r,w->owner,"rect_prev            (%d/%d,%d/%d)\n", w->rect_prev->r));
		}
		rlist = w->rect_start;
		while (rlist)
		{
			DIAG((D_r,w->owner,"(%d/%d,%d/%d) @%lx, next=%lx\n", rlist->r, rlist, rlist->next));
			rlist = rlist->next;
		}
	}
#endif

	IFWL(Sema_Dn(winlist);)

	return w->rect_start;
}

global
void dispose_rect_list(XA_WINDOW *w)
{
	if (w->rect_start)
	{
		DIAG((D_rect,w->owner,"free rect list\n"));
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

bool was_visible(XA_WINDOW *w)
{
	RECT o, n;
	if (w->rect_prev and w->rect_start)
	{
		o = w->rect_prev->r;
		n = w->rect_start->r;
		DIAG((D_r, w->owner, "was_visible? prev (%d/%d,%d/%d) start (%d/%d,%d/%d)\n", o, n));
		if (o.x eq n.x and o.y eq n.y and o.w eq n.w and o.h eq n.h)
			return true;
	}
	return false;
}

/*
 *	Compute intersection of two rectangles; put result rectangle
 *	into *d; return true if intersection is nonzero.
 *
 *	(Original version of this function taken from Digital Research's
 *	GEM sample application `DEMO' [aka `DOODLE'],  Version 1.1,
 *	March 22, 1985)
 */
global
bool rc_intersect(RECT s, RECT *d)
{
#define max(x,y)	(((x)>(y))?(x):(y))
#define min(x,y)	(((x)<(y))?(x):(y))
	short w1 = s.x + s.w,
	      w2 = d->x + d->w,
	      h1 = s.y + s.h,
	      h2 = d->y + d->h;
	d->x = max(s.x, d->x);
	d->y = max(s.y, d->y);
/*	if (s.x > d->x) d->x = s.x;
	if (s.y > d->y) d->y = s.y;
*/	d->w = min(w1, w2) - d->x;
	d->h = min(h1, h2) - d->y;

	return d->w > 0 and d->h > 0;
}
