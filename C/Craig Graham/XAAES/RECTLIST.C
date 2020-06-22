/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

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

#if JOHAN_RECTANGLES
#include "j_rect.c"
#else

#define max(x,y)	(((x)>(y))?(x):(y))
#define min(x,y)	(((x)<(y))?(x):(y))
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
	short x1,y1,x2,y2 ;

	x1 = max( s->g_x, d->g_x ) ;
	y1 = max( s->g_y, d->g_y ) ;
	x2 = min( s->g_x+s->g_w, d->g_x+d->g_w ) ;
	y2 = min( s->g_y+s->g_h, d->g_y+d->g_h ) ;
	d->g_x = x1 ;
	d->g_y = y1 ;
	d->g_w = x2 - x1 ;
	d->g_h = y2 - y1 ;
	return (x2 > x1) && (y2 > y1) ;
}

/*
	Rectangle List Generator 
	- generates a list of clipping rectangles for a given window.
	(Not a routine I'm proud of I'm afraid, but it seems to work ok)
*/

XA_RECT_LIST *generate_rect_list(XA_WINDOW *w)
{
	XA_WINDOW *wl;
	XA_RECT_LIST *rl,*rlist,*nrl,*cnrl;
	GRECT r_ours,r_win;
	
	rlist=(XA_RECT_LIST*)malloc(sizeof(XA_RECT_LIST));
	rlist->x=w->x;
	rlist->y=w->y;
	rlist->w=w->w;
	rlist->h=w->h;
	rlist->next=NULL;
	
	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	wl=w->prev;
	while(wl)
	{
		if (wl->is_open)
		{
			nrl=NULL;
			for(rl=rlist; rl; rl=rl->next)
			{
				r_win.g_x=wl->x;
				r_win.g_y=wl->y;
				r_win.g_w=wl->w;
				r_win.g_h=wl->h;
	
				r_ours.g_x=rl->x;
				r_ours.g_y=rl->y;
				r_ours.g_w=rl->w;
				r_ours.g_h=rl->h;
				if(rc_intersect(&r_ours, &r_win))
				{
					if((r_ours.g_w!=r_win.g_w)||(r_ours.g_h!=r_win.g_h))
					{
						if(r_win.g_x!=r_ours.g_x)
						{
							cnrl=(XA_RECT_LIST*)malloc(sizeof(XA_RECT_LIST));
							cnrl->x=r_ours.g_x;
							cnrl->y=r_ours.g_y;
							cnrl->w=r_win.g_x-r_ours.g_x;
							cnrl->h=r_ours.g_h;
							cnrl->next=nrl;
							nrl=cnrl;
						}
						if(r_win.g_x+r_win.g_w!=r_ours.g_x+r_ours.g_w)
						{
							cnrl=(XA_RECT_LIST*)malloc(sizeof(XA_RECT_LIST));
							cnrl->x=r_win.g_x+r_win.g_w;
							cnrl->y=r_ours.g_y;
							cnrl->w=r_ours.g_x+r_ours.g_w-r_win.g_x-r_win.g_w;
							cnrl->h=r_ours.g_h;
							cnrl->next=nrl;
							nrl=cnrl;
						}
						if(r_win.g_y!=r_ours.g_y)
						{
							cnrl=(XA_RECT_LIST*)malloc(sizeof(XA_RECT_LIST));
							cnrl->x=r_win.g_x;
							cnrl->y=r_ours.g_y;
							cnrl->w=r_win.g_w;
							cnrl->h=r_win.g_y-r_ours.g_y;
							cnrl->next=nrl;
							nrl=cnrl;
						}
						if(r_win.g_y+r_win.g_h!=r_ours.g_y+r_ours.g_h)
						{
							cnrl=(XA_RECT_LIST*)malloc(sizeof(XA_RECT_LIST));
							cnrl->x=r_win.g_x;
							cnrl->y=r_win.g_y+r_win.g_h;
							cnrl->w=r_win.g_w;
							cnrl->h=r_ours.g_y+r_ours.g_h-r_win.g_y-r_win.g_h;
							cnrl->next=nrl;
							nrl=cnrl;
						}
					}
				}else{	/* Keep the current rectangle, it hasn't been changed */
					cnrl=(XA_RECT_LIST*)malloc(sizeof(XA_RECT_LIST));
					cnrl->x=rl->x;
					cnrl->y=rl->y;
					cnrl->w=rl->w;
					cnrl->h=rl->h;
					cnrl->next=nrl;
					nrl=cnrl;
				}
			}
			for(cnrl=rlist; cnrl;)
			{
				cnrl=cnrl->next;
				free(cnrl);
			}
			rlist=nrl;
		}
		wl=wl->prev;
	}
	
	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
	
	return rlist;
}
#endif
