/* windows.c	generic window handlers
 *=======================================================================
 * 920607 kbad
 * 05/04/93	C.Gee	Open text windows to a size that is within the
 *			screen boundaries.
 */

#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>

#include "gemutil.h"
#include "windows.h"

MLOCAL	WIND	w0;
GLOBAL	GRECT	w_rmax;
GLOBAL	WORD	w_wchar, w_hchar, w_wbox, w_hbox;

WORD scroll_chunk = 7; /* granular scrolling */

/* Functions
 *=======================================================================
 */

/* Generic window functions */
GLOBAL	WORD	w_new __PROTO((int kind, const GRECT *rfull,
							   int wsid, int wchar, int hchar, int vw, int vh,
							   WORD (*sizecalc)(WIND w, const GRECT *rnew),
							   long alloc));
GLOBAL	void	w_free __PROTO((WIND w));
GLOBAL	WORD	w_open __PROTO((WIND w, const GRECT *ropen));
GLOBAL	WIND	w_lookup __PROTO((int id));
GLOBAL	WIND	*w_plink __PROTO((WIND w));

/* Generic window utility functions */
GLOBAL	void	w_nameinfo __PROTO((WIND w, char *name, char *info));
GLOBAL	void	w_scroll __PROTO((WIND w, int dx, int dy, GRECT *rdraw));
GLOBAL	WORD	w_sliders __PROTO((WIND w, int dovert, int dohorz));
GLOBAL	WORD	wsl_size __PROTO((int visrange, int range));
GLOBAL  WORD	wsl_position __PROTO((WORD *pval, int visrange, int range));

/* Default window handlers */
GLOBAL	void	w_erase __PROTO((WIND w, GRECT *rclip));
GLOBAL	WORD	w_sizecalc __PROTO((WIND w, const GRECT *rnew));

/* Default window message handlers */
GLOBAL	WORD	w_redraw __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_topped __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_closed __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_fulled __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_arrowed __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_slid __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_sized __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_ontop __PROTO((WIND w, WORD *msg));

WINDFP w_handlers[N_WINDFP] = {
	w_redraw,	w_topped,	w_closed,	w_fulled,	w_arrowed,
	w_slid,		w_slid,		w_sized,	w_sized,	w_ontop,
	w_ignore,	w_ontop,	w_ignore,	w_ignore,	w_ignore,
	w_ignore,	w_ignore,	w_ignore,	w_ignore,	w_ignore
};


/* Generic window functions
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Initialize window variables.
 */
void
w_init()
{
	graf_handle(&w_wchar, &w_hchar, &w_wbox, &w_hbox);
	wind_grect(0, WF_WORKXYWH, &w_rmax);
}

/*-----------------------------------------------------------------------
 * Allocate & create a window.
 * Return the AES window id of the window, or < 0 on error.
 */
GLOBAL WORD
w_new(kind, rfull, wsid, wchar, hchar, vw, vh, sizecalc, alloc)
const GRECT	*rfull;
	WORD	(*sizecalc) __PROTO((WIND w, const GRECT *rnew));
	long	alloc;
{
	WIND	w;
	WORD	i, ret;
	GRECT	*rwp;

	if (!w_rmax.g_w)
		w_init();

	w = calloc(1, alloc);
	if (!w) ret = -33;
	else
	{
		w->wsid = wsid;
		w->kind = kind;
		w->wchar = wchar;
		w->hchar = hchar;
		w->vw = vw;
		w->vh = vh;
		rwp = &w->rwind;
		if (rfull) *rwp = *rfull;
		else
		{
			*rwp = w_rmax;
			rwp->g_w -= ( w_wbox / 2 );	/* cjg 05/04/93 */
			rwp->g_h -= w_hbox;		/* cjg 05/04/93 */
#if 0
	/*Removed CJG 05-04-93 */			
			rwp->g_w += w_wbox / 2 + 3;
			rwp->g_h += w_hbox / 2 + 3;
#endif
		}
		w->sizecalc = (sizecalc) ? sizecalc : w_sizecalc;
		w->sizecalc(w, rwp);
		w_isopen(w) = 0; /* sizecalc sets work rect, and it isn't yet open */
		ret = w->id = wind_create(w->kind, rwp->g_x, rwp->g_y,
					  rwp->g_w, rwp->g_h);
		if (ret < 0)
			free(w);
		else
		{
			w->free = w_free;
			w->draw = w_erase;
			*w_plink(NULL) = w;
			for (i = 0; i < N_WINDFP; i++)
				w->do_message[i] = w_handlers[i];
		}
	}
	return ret;
}

/*-----------------------------------------------------------------------
 * Close (if open), delete and free a window.
 * Be sure to deallocate any auxiliary structures before calling this.
 */
GLOBAL void
w_free(w)
	WIND w;
{
	WIND *pw;

	if (!w) return;

	if (w_isopen(w))
		wind_close(w->id);
	wind_delete(w->id);
	pw = w_plink(w);
	if (pw && *pw == w)
		*pw = w->next;
	free(w);
}

/*-----------------------------------------------------------------------
 * Open or reopen a window.
 * If ropen == NULL, use the window's rwind rectangle.
 */
GLOBAL WORD
w_open(w, ropen)
	WIND	w;
const GRECT	*ropen;
{
	WORD	msg[8];

	if (ropen)
		w->rwind = *ropen;
	w->sizecalc(w, &w->rwind);
	w_sliders(w, TRUE, TRUE);
	w_ontop(w, msg);
	return wind_open(w->id, w->rwind.g_x, w->rwind.g_y,
							w->rwind.g_w, w->rwind.g_h);
}

/*-----------------------------------------------------------------------
 * Return the WIND pointer for a given AES window id, or NULL.
 */
GLOBAL WIND
w_lookup(id)
{
	WIND w = w0;
	if (id != W_HEAD)
		while (w && w->id != id)
			w = w->next;
	return w;
}

/*-----------------------------------------------------------------------
 * Return the address of the link pointer that points to window w.
 * Return NULL if w is not on the window list.
 */
GLOBAL WIND *
w_plink(w)
	WIND w;
{
	WIND *wp = &w0;

	while (*wp && *wp != w)
		wp = &(*wp)->next;

	return (*wp == w) ? wp : NULL;
}


/* Generic window utility functions
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Set window name and/or info lines.
 */
GLOBAL void
w_nameinfo(w, name, info)
	WIND	w;
	char	*name, *info;
{
	if (name && w->kind & NAME)
		wind_sstr(w->id, WF_NAME, strcpy(w->name, name));
	if (info && w->kind & INFO)
		wind_sstr(w->id, WF_INFO, strcpy(w->info, info));
}

/*-----------------------------------------------------------------------
 * Scroll a window by dx, dy.  To just redraw, call with dx and dy = 0.
 */
GLOBAL void
w_scroll(w, dx, dy, rdraw)
	WIND	w;
	GRECT	*rdraw;
{
	GRECT	r, rdirt;

	wind_update(1);
	graf_mouse(M_OFF, NULL);
	wind_grect(w->id, WF_FIRSTXYWH, &r);
	while(r.g_w && r.g_h)
	{
		if (rc_intersect(rdraw, &r)
		&&	rc_intersect(&w_rmax, &r)) /* window rect may be off screen! */
		{
			if (w->wsid > 0 && (dx || dy))
			{
				vs_clip(w->wsid, 0, &r.g_x);
				bb_scroll(w->wsid, &r, dx, dy, &rdirt, NULL);
			}
			else
				rdirt = r;
			w->draw(w, &rdirt);
		}
		wind_grect(w->id, WF_NEXTXYWH, &r);
	}
	graf_mouse(M_ON, NULL);
	wind_update(0);
}

/*-----------------------------------------------------------------------
 * Set window slider sizes & positions.
 * Return TRUE if w->vx or w->vy was changed.
 */
GLOBAL WORD
w_sliders(w, dovert, dohorz)
	WIND	w;
{
	GRECT	chrect, *rdp = &w->rdraw;
	WORD	x = w->vx;
	WORD	y = w->vy;

	rc_chrect(rdp, rdp->g_x, rdp->g_y, w->wchar, w->hchar, &chrect);
	if (dovert && (w->kind & VSLIDE))
	{
		wind_set(w->id, WF_VSLSIZE, wsl_size(chrect.g_h, w->vh));
		wind_set(w->id, WF_VSLIDE, wsl_position(&w->vy, chrect.g_h, w->vh));
	}
	if (dohorz && (w->kind & HSLIDE))
	{
		wind_set(w->id, WF_HSLSIZE, wsl_size(chrect.g_w, w->vw));
		wind_set(w->id, WF_HSLIDE, wsl_position(&w->vx, chrect.g_w, w->vw));
	}

	return (x != w->vx || y != w->vy);
}

GLOBAL WORD
wsl_size(visrange, range)
{
	return (range && range > visrange) ?
			umul_div(1000, visrange, range) : 1000;
}

GLOBAL WORD
wsl_position(pval, visrange, range)
WORD *pval;
{
	WORD maxval = (WORD)(range - visrange);
	if (maxval <= 0)
	{
		*pval = 0;
		return 0;
	}
	if (*pval >= maxval)
	{
		*pval = maxval;
		return 1000;
	}
	return umul_div(1000, *pval, maxval);
}


/* Default window handlers
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Default window draw function:
 * Set clipping to the draw rectangle and erase it.
 */
void
w_erase(w, rclip)
	WIND	w;
	GRECT	*rclip;
{
	WORD	xy[4];
	if (w->wsid < 0) return;
	rc_getpts(rclip, xy);
	vs_clip(w->wsid, 1, xy);
	vswr_mode(w->wsid, MD_REPLACE);
	vsf_interior(w->wsid, FIS_HOLLOW);
	vsf_perimeter(w->wsid, 0);
	v_bar(w->wsid, xy);
}

/*-----------------------------------------------------------------------
 * Compute new window, work & draw rects for a change in window size or
 * position.  Return TRUE if the window rect changed.
 */
GLOBAL WORD
w_sizecalc(w, rnew)
	WIND	w;
const GRECT	*rnew;
{
	GRECT	rcurr = w->rwind;

	w->rwind = *rnew;
#if 0
/* I don't know what drugs I was on when I wrote this code */
{
	WORD off = (w->rwind.g_x + w->rwind.g_w) - (w_rmax.g_x + w_rmax.g_w);
	if (off > 0) w->rwind.g_w -= off;
	off = (w->rwind.g_y + w->rwind.g_h) - (w_rmax.g_y + w_rmax.g_h);
	if (off > 0) w->rwind.g_h -= off;
}
#endif

	wind_calc(WC_WORK, w->kind, rnew->g_x, rnew->g_y, rnew->g_w, rnew->g_h,
			  &w->rwork.g_x, &w->rwork.g_y, &w->rwork.g_w, &w->rwork.g_h);
	w->rdraw = w->rwork;
	return !rc_equal(&w->rdraw, &rcurr);
}


/* Generic window message handlers
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Handle WM_REDRAW:
 * scroll the redraw area with dx, dy = 0.
 */
GLOBAL WORD
w_redraw(w, msg)
	WIND	w;
	WORD	*msg;
{
	w_scroll(w, 0, 0, (GRECT *)&msg[4]);
	return 1;
}

/*-----------------------------------------------------------------------
 * Handle WM_TOPPED:
 * put the window at the head of the window list, then top it.
 */
GLOBAL WORD
w_topped(w, msg)
	WIND	w;
	WORD	*msg;
{
	w_ontop(w, msg);
	return wind_set(w->id, WF_TOP);
}

/*-----------------------------------------------------------------------
 * Handle WM_CLOSED:
 * Close the window, set its work rect to empty,
 * and put it at the end of the window list.
 */
GLOBAL WORD
w_closed(w, msg)
	WIND	w;
	WORD	*msg;
{
	WIND	*wp = w_plink(w);
	if (wp)
		*wp = w->next;
	*w_plink(NULL) = w;
	w->next = NULL;
	w_isopen(w) = 0;
	return wind_close(w->id);
}

/*-----------------------------------------------------------------------
 * Handle WM_FULLED:
 * If the window is full (rsave.g_w != 0),
 * set the window rectangle to the save rectangle.
 * Otherwise, set the window rectangle to the full rectangle, minimizing
 * changes in the window x & y position.
 */
GLOBAL WORD
w_fulled(w, msg)
	WIND	w;
	WORD	*msg;
{
	WORD	off, isfull;
	GRECT	*rwp = &w->rwind, *rp = (GRECT *)&msg[4];

	if (w_isfull(w))
	{
		*rp = w->rsave;
		isfull = 0;
	}
	else
	{
		w->rsave = *rwp;
		isfull = w_isfull(w);
		wind_grect(w->id, WF_FULLXYWH, rp);
		rp->g_x = rwp->g_x;
		rp->g_y = rwp->g_y;
		off = (rp->g_x + rp->g_w) - (w_rmax.g_x + w_rmax.g_w);
		if (off > 0)
			rp->g_x = max(w_rmax.g_x, rp->g_x - off);
		off = (rp->g_y + rp->g_h) - (w_rmax.g_y + w_rmax.g_h);
		if (off > 0)
			rp->g_y = max(w_rmax.g_y, rp->g_y - off);
	}
	w_msg(w, WM_SIZED, msg);
/* The w_sized function sets w_isfull() to 0, so restore it */
	w_isfull(w) = isfull;
	return 1;
}

/*-----------------------------------------------------------------------
 * Handle WM_ARROWED:
 * While the mouse is down, scroll or page the window until it hits an edge.
 */
GLOBAL WORD
w_arrowed(w, msg)
	WIND	w;
	WORD	*msg;
{
	GRECT	chrect;
	WORD	vx, vy, xmax, ymax, dx, dy;
	WORD	mx, my, mb, ks;

	rc_chrect(&w->rdraw, w->rdraw.g_x, w->rdraw.g_y,
			  w->wchar, w->hchar, &chrect);
	vx = w->vx;
	vy = w->vy;
	xmax = w->vw - chrect.g_w;
	ymax = w->vh - chrect.g_h;

	do {
		dx = dy = 0;
		switch (msg[4])
		{
			case WA_UPPAGE:
				dy = min(chrect.g_h, w->vy);
				w->vy -= dy;
				dy *= w->hchar;
			break;
			case WA_DNPAGE:
				dy = min(chrect.g_h, ymax - w->vy);
				w->vy += dy;
				dy *= -w->hchar;
			break;
			case WA_UPLINE:
				if (w->vy)
					w->vy--, dy = w->hchar;
			break;
			case WA_DNLINE:
				if (w->vy < ymax)
					w->vy++, dy = -w->hchar;
			break;
			case WA_LFPAGE:
				dx = min(chrect.g_w, w->vx);
				w->vx -= dx;
				dx *= w->wchar;
			break;
			case WA_RTPAGE:
				dx = min(chrect.g_w, xmax - w->vx);
				w->vx += dx;
				dx *= -w->wchar;
			break;
			case WA_LFLINE:
				if (w->vx)
					w->vx--, dx = w->wchar;
			break;
			case WA_RTLINE:
				if (w->vx < xmax)
					w->vx++, dx = -w->wchar;
			break;
		}

		if (dx || dy)
		{
			if ( dx && (abs(vx - w->vx) > scroll_chunk
						|| w->vx == xmax || w->vx == 0) )
			{
				wind_set(w->id, WF_HSLIDE,
						 wsl_position(&w->vx, chrect.g_w, w->vw));
				vx = w->vx;
			}
			if ( dy && (abs(vy - w->vy) > scroll_chunk
						|| w->vy == ymax || w->vy == 0) )
			{
				wind_set(w->id, WF_VSLIDE,
						 wsl_position(&w->vy, chrect.g_h, w->vh));
				vy = w->vy;
			}

			w_scroll(w, dx, dy, &w->rdraw);
		}
		graf_mkstate(&mx, &my, &mb, &ks);
	} while (mb);

	if (vx != w->vx)
		wind_set(w->id, WF_HSLIDE, wsl_position(&w->vx, chrect.g_w, w->vw));
	if (vy != w->vy)
		wind_set(w->id, WF_VSLIDE, wsl_position(&w->vy, chrect.g_h, w->vh));

	return 1;
}

/*-----------------------------------------------------------------------
 * Handle a WM_VSLID or WM_HSLID message.
 */
GLOBAL WORD
w_slid(w, msg)
	WIND	w;
	WORD	*msg;
{
	GRECT	chrect, *prd = &w->rdraw;
	WORD	set, newval, oldval, maxval, dx, dy;

	rc_chrect(prd, prd->g_x, prd->g_y, w->wchar, w->hchar, &chrect);
	dx = dy = 0;
	if (msg[0] == WM_HSLID)
	{
		set = WF_HSLIDE;
		oldval = w->vx;
		maxval = w->vw - chrect.g_w;
		newval = w->vx = (maxval <= 0) ? 0 : umul_div(msg[4], maxval, 1000);
		dx = oldval - newval;
		if (abs(dx) < chrect.g_w)
			dx *= w->wchar;
		else
			dx = 0;
	}
	else
	{
		set = WF_VSLIDE;
		oldval = w->vy;
		maxval = w->vh - chrect.g_h;
		newval = w->vy = (maxval <= 0) ? 0 : umul_div(msg[4], maxval, 1000);
		dy = oldval - newval;
		if (abs(dy) < chrect.g_h)
			dy *= w->hchar;
		else
			dy = 0;
	}

	if (newval != oldval)
	{
		wind_set(w->id, set, msg[4]);
		w_scroll(w, dx, dy, prd);
	}
	return 1;
}

/*-----------------------------------------------------------------------
 * Handle a WM_SIZED or WM_MOVED message.
 */
GLOBAL WORD
w_sized(w, msg)
	WIND	w;
	WORD	*msg;
{
	WORD	old_w, old_h;

/* Allow borders to go off-screen */
#if 0 /* this isn't working in AES 4.0 */
	if (w->rwind.g_x == -1 && msg[4] == 0)
		msg[4] = -1;
#endif
	if (msg[0] == WM_SIZED)
	{
		if (msg[4] + msg[6] == w_rmax.g_x + w_rmax.g_w)
			msg[6] += w_wbox / 2 + 3;
		if (msg[5] + msg[7] == w_rmax.g_y + w_rmax.g_h)
			msg[7] += w_hbox / 2 + 3;
	}

	old_w = w->rwind.g_w;
	old_h = w->rwind.g_h;
	if (w->sizecalc(w, (GRECT *)&msg[4]))
	{
		wind_set(w->id, WF_CURRXYWH, w->rwind.g_x, w->rwind.g_y,
									 w->rwind.g_w, w->rwind.g_h);
		if (w_sliders(w, (w->rwind.g_h != old_h), (w->rwind.g_w != old_w)))
			/* redraw? */;
	}
	w_isfull(w) = 0;
	return 1;
}

/*-----------------------------------------------------------------------
 * Put w at the head of the window list.
 */
GLOBAL WORD
w_ontop(w, msg)
	WIND	w;
	WORD	*msg;
{
	WIND	*wp = w_plink(w);
	if (wp)
		*wp = w->next;
	w->next = w0;
	w0 = w;
	return 1;
}
