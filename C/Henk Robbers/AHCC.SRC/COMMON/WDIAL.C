/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*	WDIAL.C
 *  =======
 *
 *	routines for handling forms in windows.
 *  Basic replacement of the following rather illdesigned
 *  system calls:
 *
 *		form_button
 *		form_keybd
 *		objc_edit
 *
 *  The routines are designed for use with the facilities
 *  in the file 'WINDOWS.C'
 */

#include <string.h>
#include <limits.h>

#include "mallocs.h"
#include "aaaa_lib.h"
#include "hierarch.h"

#define __WDIAL
#include "aaaa.h"
#include "text/cursor.h"
#include "cursor.h"
#include "wdial.h"
#include "ahcm.h"

global
short edcur = 0;	/* current selected edit field in dialogue */

#define DKIND   (NAME|INFO|MOVER|CLOSER|FULLER|SIZER|VSLIDE|UPARROW|DNARROW|HSLIDE|LFARROW|RTARROW)
#define SUBSTITUTE 1

static
bool wdial_blok(IT *w, short block)
{
	short dx=0,dy=0;
	VRECT offb,ma;
	OBJECT *obb = &w->dial.ob[block];

	objc_offset(w->dial.ob,block,&offb.x,&offb.y);
	offb.jx = offb.x+obb->w-1;
	offb.jy = offb.y+obb->h-1;

	ma.x=w->ma.x;
	ma.y=w->ma.y;
	ma.jx=w->ma.x+w->ma.w-1;
	ma.jy=w->ma.y+w->ma.h-1;

	if (offb.jx > ma.jx)			/* lower right outside w ? */
		dx += offb.jx - ma.jx;
	if (offb.jy > ma.jy)
		dy += offb.jy - ma.jy;

	if (offb.x < ma.x)				/* upper left outside w ? */
		dx += offb.x - ma.x;
	if (offb.y < ma.y)
		dy += offb.y - ma.y;
	/* If window too small its up to the user to size it */
	w->norm.pos.x += dx/w->unit.w;
	w->norm.pos.y += dy/w->unit.h;

	via (w->dial.place)(w);
	return !(dx or dy);
}

/* The following 'wdial' functions repace the form_do().
	Because window dialogues are controlled by the central and ONLY
	evnt_multi() in main(), handling of them is
	turned inside out and triggered by the vectors in IT *w		<	*/

global
bool wdial_vis(IT *w)
{
	short x, y;

	if (!w->op)
		return false;
	if (is_sheet(w))
		return true;
	x  = (w->dial.edx   - w->dial.ob->x)/wchar;
	x +=  w->dial.tmplt - w->dial.ted->tmplt;
	y  = (w->dial.edy   - w->dial.ob->y)/hchar+1;

	if (	y >  w->norm.pos.y
		and y <= w->norm.pos.y + w->norm.sz.h
		and x >  w->norm.pos.x
		and x <= w->norm.pos.x + w->norm.sz.w
	   )
		return true;
	return false;
}

static
void wdial_write_cur(IT *w)
{
	short c[4];
	c[0] = w->dial.edx + (w->dial.tmplt - w->dial.ted->tmplt)*wchar;
	c[1] = w->dial.edy + 1;
	c[2] = c[0] + wchar - 2;
	c[3] = c[1] + hchar - 2;
	write_curect(w->hl, c);
}

global
CURSOR wdial_cur		/* IT *w, CURST to	*/
{
	if (w->dial.edob eq 0)		/* No edit fields at all */
		return;
	if (w->dial.edon eq 0)
		return;				/* cursor not active */
	if (to eq ON)
	{
		if (w->dial.edup eq ON) return;
		if (wdial_vis(w))
		{
			wdial_write_cur(w);
			w->dial.edup=ON;
		}
	othw
		if (w->dial.edup eq OFF) return;
		w->dial.edup=OFF;
		if (wdial_vis(w))
			wdial_write_cur(w);
	}
}

static
TIMER wdial_timer		/* IT *w */	/* for cursor */
{
	if (w->dial.edup eq ON)
		wdial_off(w);
	else
		wdial_on(w);
}

global
void wdial_edob(IT *w, short i)
{
	struct wdial *d = &w->dial;
	if (i)
	{
		objc_offset(d->ob,i,&d->edx,&d->edy);
		d->edob = i;
		d->ed = d->ob+i;
		d->ted = d->ed->spec.tedinfo;
	}
}

static
OB_PLACE wdial_place
{
	struct wdial *d = &w->dial;
	d->ob->y = w->ma.y - w->norm.pos.y*w->unit.h - d->ddy;		/* top  to pixel */
	d->ob->x = w->ma.x - w->norm.pos.x*w->unit.w - d->ddx;		/* left to pixel */
	wdial_edob(w, d->edob);
}

static
DRAW post_wdial			/* w, arrow = 0 */	/* for redraw */
{
	short topw;
	wind_get(0,WF_TOP,&topw);
	if (w->wh eq topw and w->dial.edob)
		wdial_on(w);
}

global
void wdial_setcur(IT *w, short edob)
{
	wdial_off(w);
	w->dial.idx = 0;
	wdial_edob(w, edob);
	wdial_itotmpl(w);
	wdial_on(w);
}

/* Called before evnt_multi if dialogue is on top */
global
ANTEVNT wdial_evm		/* IT *w; bool w_on; short evmask	*/
{	return evmask|MU_KEYBD|MU_BUTTON|MU_TIMER;	}

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   Never hesitate to call this function.
	many cursor routines rely on the correct and consistent
	contents of w->txt, w->val, w->tmplt & w->idx
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
global
void wdial_itotmpl(IT *w)
{
	struct wdial *d = &w->dial;
	short i = 0;
	char *t = d->ted->tmplt;
	char *s = d->ted->text;
	if  (t and s)
	{
		while (*t)
		{
			if (*t eq '_')
				if (i >= d->idx or i >= d->ted->txtlen-2 or *s eq 0)
					break;
				else
					i++, s++;
			t++;
		}
		d->tmplt = t;
		d->txt  = s;
		d->val = d->ted->valid + (s - d->ted->text);
		d->idx = i;
	}
}

global
void wdial_xytoi(IT *w, short mx, short my)	/* raw idx (needs itotmpl for tailoring) */
{
	struct wdial *d = &w->dial;
	short i = 0,
		j = 0;
	char *t = d->ted->tmplt;

	mx = (mx - d->edx)/wchar;
	if  (t and mx >= 0)
	{
		while (*t)
		{
			if (*t eq '_')
				if (j >= mx)
					break;
				else
					i++;
			t++, j++;
		}
		d->idx = i;
	}
}

static
bool w_bounce(IT *w)				/* bounce dialogue in window */
{
	STMNR top  = bounce(w, w->norm.pos.y),
	      left = w->norm.pos.x;
	bool changed = w->norm.pos.y ne top;

	if (w->view.sz.w <= w->norm.sz.w)
		left=0;
	else
		if (left + w->norm.sz.w > w->view.sz.w)
			left = w->view.sz.w - w->norm.sz.w;
	if (left < 0)
		left = 0;

	changed |= w->norm.pos.x ne left;

	w->norm.pos.x = left;
	w->norm.pos.y = top;

	via (w->dial.place)(w);
	return changed;
}

static
bool wdial_makevis(IT *w)
{
	struct wdial *d = &w->dial;
	short x, y;
	bool draw = false;

	if (!is_sheet(w))
	{
		x  = (d->edx   - d->ob->x)/wchar;
		x +=  d->tmplt - d->ted->tmplt;
		y  = (d->edy   - d->ob->y)/hchar+1;

	/*	if (	y >  w->norm.pos.y
			and y <= w->norm.pos.y + w->norm.sz.h
			and x >  w->norm.pos.x
			and x <= w->norm.pos.x + w->norm.sz.w
		   )
	*/
		if (x <= w->norm.pos.x or x-w->norm.pos.x >= w->norm.sz.w)
		{
			draw |= true;
			w->norm.pos.x = x - (w->norm.sz.w/2);
		}

		if (y < w->norm.pos.y or y >= w->norm.pos.y + w->norm.sz.h)
		{
			draw |= true;
			w->norm.pos.y = y - (w->norm.sz.h/2);
		}

		if (draw)
		{
			w_bounce(w);
			via (w->slider)(w);
			do_redraw(w,w->wa);
		}
	}
	return draw;
}

static
bool wdial_watch(IT *w, OBJECT *ob, short nob, short is, short os)
{
	OBJECT *this = ob + nob;
	short x, y, mx, my, omx, omy, mb, ms, pobf = -1, obf = nob;

	mouse(omx, omy, ms, mb);		/* 05'17 OL mouse uses AES (hence physical handle) */
	objc_offset(ob, nob, &x, &y);

	x--, y--;

	if (!mb)		/* If mouse button is already released, assume that was just a click, so select */
	{
		this->state = is;
		draw_ob(ob, nob, w->wa,10);
	othw
		showm;
		while (mb)
		{
			mouse(mx, my, ms, mb);		/* 05'17 OL mouse uses AES (hence physical handle) */

			if (mx ne omx or my ne omy)
			{
				omx = mx;
				omy = my;

				obf = objc_find(ob, nob, 10, mx, my);

				if (obf eq nob)
					this->state = is;
				else
					this->state = os;

				if (pobf ne obf)
				{
					pobf = obf;
					hidem;
					draw_ob(ob, nob, w->wa,11);
					showm;
				}
			}
		}

		hidem;
	}

	return obf eq nob;
}

static
void Radio_b(IT *w, OBJECT *pb, short nob, bool draw)
{
	short xob, p;

	p = get_parent(pb,nob);

	if (p > 0)
	{
		xob = pb[p].head;
		do
		{
			if (	 xob                   ne nob
				and (pb[xob].flags & RBUTTON)  ne 0
				and (pb[xob].state & SELECTED) ne 0
				)
			{
				pb[xob].state &= ~SELECTED;
				if (draw)
					wdial_draw(w, xob);
			}
			if (xob eq pb[p].tail)
				break;
			xob = pb[xob].next;
		}od

		pb[nob].state |= SELECTED;
		if (draw)
			wdial_draw(w, nob);
	}
}

global
BUTTON wdial_button		/* w,button,kstate,bclicks,mx,my */
{
	struct wdial *d = &w->dial;
	bool exit = false,
		 write = false;
	short nob = objc_find(d->ob,0,MAX_DEPTH,mx,my);
	OBJECT *ob;
	/* right-button same as double click */
	if (button & 2)
		bclicks = 2;

	/*	'ping' is now exit condition.
		N.B. if button is outside form but in another window, a MESAG
		is generated, NOT a BUTTON event.
		HR 01'09: except if it is a right click.	*/


	if (nob < 0)					/* outside form ? */
	{
		ping;
		if ((button & 2) eq 0)
			exit = true;
	othw
		ob = d->ob + nob;

		/* dont use form_button, it's too silly and doesnt clip
		   It is in fact so simple, you can easily do it yourself
		   AND do it right. */

		if ( (ob->state & HIDETREE) eq 0 and (ob->state & DISABLED) eq 0)
		{
			short os = ob->state,
			      is = os ^ SELECTED;

			wdial_off(w);

		    if (ob->flags & TOUCHEXIT)
		    {
		    	if (ob->flags & RBUTTON)
		    		Radio_b(w, d->ob, nob, true);
		    	elif (ob->flags & SELECTABLE)
		    	{
		    		ob->state = is;
		    		draw_ob(d->ob, nob, w->wa,12);
		    	}

		    	exit = true;
		    }
			elif (ob->flags & SELECTABLE)
			{
				ob->state = is;
				draw_ob(d->ob,nob,w->wa,13);

				if (wdial_watch(w, d->ob, nob, is, os))
			    {
				    if (ob->flags&RBUTTON)		/* the others off */
				    	Radio_b(w, d->ob, nob, true);

					if (    (ob->flags & EXIT)
					    and (is        & SELECTED)
					   )
						exit = true;
				}
			}

	    	if (ob->flags&EDITABLE)
	    	{
	    		wdial_edob(w, nob);
	    		wdial_xytoi(w, mx, my);
	    		wdial_itotmpl(w);
	    	}

	    	if (write)
	    		draw_ob(d->ob, nob, w->wa,14);		/* we know window is on top! */

			wdial_on(w);
		}
	}

	if (exit)
	{
		if (nob > 0)
		{
			short ox, oy;

			objc_offset(d->ob, nob, &ox, &oy);
			d->cx = (mx - ox)/w->unit.w;
			d->cy = (my - oy)/w->unit.h;			/* position within object in chars */

			if (bclicks eq 2)
				nob|=0x8000;
		}
		via (d->exit)(w,nob);
	}
}

static
bool wdial_cursor(IT *w,short kcode)		/* kcode is < 0 !! */
{
	struct wdial *d = &w->dial;
	short k = kcode&0xff, exit;

	if (kcode&NKF_SHIFT)
		switch (k)
		{
			case NK_UP:
			case NK_LEFT:
				d->idx = 0;
				wdial_itotmpl(w);
				wdial_makevis(w);
			return true;
			case NK_DOWN:
			case NK_RIGHT:
			case NK_TAB:
				d->idx = d->ted->txtlen-2;
				wdial_itotmpl(w);
				wdial_makevis(w);
			return true;
			case NK_CLRHOME:
			{
				wdial_edob(w,last_edob(d->ob));
				d->idx = d->ted->txtlen-2;
				wdial_itotmpl(w);
				wdial_makevis(w);
			}
			return true;
		}
	else
	switch (k)
	{
	case NK_LEFT:
		d->idx--;
		wdial_itotmpl(w);
		wdial_makevis(w);
		return true;
	case NK_RIGHT:
		d->idx++;
		wdial_itotmpl(w);
		wdial_makevis(w);
		return true;
	case NK_UP:
		wdial_edob(w, prev_edob(d->ob, d->edob));
		wdial_itotmpl(w);
		wdial_makevis(w);
		return true;
	case NK_TAB:
	case NK_DOWN:
		wdial_edob(w, next_edob(d->ob, d->edob));
		wdial_itotmpl(w);
		wdial_makevis(w);
		return true;
	case NK_CLRHOME:
		wdial_edob(w, first_edob(d->ob));
		d->idx = 0;
		wdial_itotmpl(w);
		wdial_makevis(w);
		return true;
	case NK_RET:
	case NK_ENTER:
		exit = find_def(d->ob);
		if (exit)
		{
			short mx,my;
			objc_offset(d->ob,exit,&mx,&my);
			wdial_button(w,1,kcode,1,mx+2,my+2);
			return true;
		othw				/* if no default exit button, exit if exit|touchexit editable */
			if (d->ed->flags & (EXIT|TOUCHEXIT))
			{
				via (d->exit)(w, d->edob);
				return true;
			}
		}
	}
	return false;
}

static
bool wdial_valid(short v, short k)
{
	return true;
}

static
EDIT wdial_edkey			/* 	IT *w,short kcode) */
{
	struct wdial *d = &w->dial;
	short k = kcode&0xff;

	/*	wdial_curvis(w); */
	if (kcode < 0 and k eq NK_BS)
		if (d->idx > 0)
			wdial_cursor(w,NK_LEFT|NKF_FUNC);
		else
			return true;

	if (kcode < 0)
	{
		if (k eq NK_ESC)
		{
			d->idx = 0;
			*d->ted->text = 0;
			wdial_itotmpl(w);
			hidem;
			draw_ob(d->ob,d->edob,w->wa,15);
			showm;
		}
		elif (    (k eq NK_DEL or k eq NK_BS)
			  and *d->txt ne 0 )			/* dont delete NL */
		{
			char *to = d->txt,
				 *c = to+1;
			while ( (*to++ = *c++) ne 0);	/* incl NL */
			hidem;
			draw_ob(d->ob,d->edob,w->wa,16);
			showm;
		}
	othw
		if (wdial_valid(*d->val,k))
		{
			short j   = d->ted->txtlen - d->idx-2;
			char *c = d->ted->text   + d->ted->txtlen-3,
				 *to = c+1;
			while(j > 0)
				*to--=*c--, j--;
			*d->txt = k;
			hidem;
			draw_ob(d->ob,d->edob,w->wa,17);
			showm;
			wdial_cursor(w,NK_RIGHT|NKF_FUNC);
		}
	}
	return true;
}

global
KEYBD wdial_keybd 			/*	w,kcode		*/
{
	wdial_off(w);
	if (kcode > 0 or !wdial_cursor(w,kcode))	/* cursor handling */
		if (is_sheet(w))
			wdial_edkey(w,kcode);	/* other keys */
		else
			w->edit(w,kcode);	/* other keys */
	wdial_on(w);
}

global
void wdial_draw(IT *w, short start) /* for draw other redraw events */
{
	if (w->op)
	{
		GRECT t1;
		short hl = w->hl;
		wind_get(w->wh,WF_FIRSTXYWH,&t1.x,&t1.y,&t1.w,&t1.h);
		while (t1.w and t1.h)
		{
			if (rc_intersect(&w->wa,&t1))	/* only changes t1 */
			{
				gsclip(hl,1,t1);
				wdial_off(w);
				draw_ob(w->dial.ob,start,t1,18);
				wdial_on(w);
			}
			wind_get(w->wh,WF_NEXTXYWH,&t1.x,&t1.y,&t1.w,&t1.h);
		}
		gsclip(hl,1,scr_grect);
	}
}

global
void wdial_change(IT *w, bool draw, short start, short item, short fm, short fv, short sm, short sv)
{
	OBJECT *db = &w->dial.ob[item];

	db->flags&=fm;
	db->flags|=fv;
	db->state&=sm;
	db->state|=sv;

    if (    (db->flags&RBUTTON ) ne 0		/* new state */
        and (db->state&SELECTED) ne 0
       )
		Radio_b(w, w->dial.ob, item, draw);	/* the others off */
	if (draw)
		wdial_draw(w,start);
}

static
void ck_act_on(IT *w, IT *wt)
{
	if (    wt
	    and !is_drop(wt)
#if DIGGER
		and !is_jrnl(wt)
#endif
	   )
	{
		strcpy(w->info + 4, wt->title.t);
		w->dial.act_on = wt;
	othw
		strcpy(w->info + 4, "Defaults");
		w->dial.act_on = nil;
	}

	if (w->wh > 0 and (w->wkind&INFO))
		wind_set(w->wh, WF_INFO, w->info);
}

global
void set_dialinfs(IT *wt)
{
	IT *w;
	STMDEF *b = &winbase;
	STMC  *ws = stmfifirst(b);
	while (ws)
	{
		w = ws->wit;
		if (    is_dial(w)
			and (   wt eq nil
			     or w->dial.act_on ne wt )
#if DIGGER
			and !(    wt ne nil
			      and is_jrnl(wt) )
#endif
		   )
		{
			ck_act_on(w, wt);
			via (w->dial.action)(w->dial.act_on);
		}
		ws = stmfinext(b);
	}
}

static
CLOSED wdial_close
{
	close_w(w);
}

static
FCLOSE wdial_delete
{
	close_w(w);
	stmdelcur(&winbase);
	return true;
}

global
void close_dials(void)
{
	STMC *ws=stmfifirst(&winbase);
	while (ws)
	{
		IT *w=ws->wit;
		if (is_dial(w))
			close_w(w);
		ws=stmfinext(&winbase);
	}
}

global
IT *wind_dial(INFO_T t,short blok)
{
	IT *w=get_it(-1,t);
	IT *wt=get_top_it();

	if (!w)
		return nil;		/* no window dialogues */

	if (w->wh < 0)
	{
		short wh=wind_create(DKIND,win.x,win.y,win.w,win.h);
		if (wh < 0)
			return nil;	/* no more windows available; cant do */
		w->wh=wh;
		w->op=false;
	}

	if (!is_dial(wt))
		ck_act_on(w,wt);

	wi_title(w);

	if (!w->op)
		w->op=wind_open(w->wh,w->rem.x,w->rem.y,w->rem.w,w->rem.h) ne 0;

	if (w->op)
	{
		wind_set(w->wh,WF_TOP);
		get_work(w);
		if (blok)
		{
			wdial_blok(w, blok);
			do_redraw(w, w->wa);
		}
		via (w->slider)(w);
		return w;
	othw
		return nil;
	}
}

/* frem = fulled position (snapped desk wa) or size of complete dialogue
		whichever is smaller */

static
SIZED wdial_size	/* IT *w, RECT *to	*/
{
	RECT mto,tto;
	bool changed = false;

	if ((w->wkind&SIZER) eq 0)			/* security */
	{
		tto.w=w->rem.w;
		tto.h=w->rem.h;
	}
	snapwindow(w,to);
	tto = *to;
	mto.w = w->view.sz.w * w->unit.w + w->v.w;
	if (tto.w > mto.w)
		tto.w = mto.w;
	/*	changed |= true; 	*/		/* no redraw event */
	mto.h = w->view.sz.h * w->unit.h + w->v.h;
	if (tto.h > mto.h)
		tto.h = mto.h;
/*		changed |= true;	*/
	w->rem=tto;
	w->nfrem=w->rem;
	w->full=false;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	changed = w_bounce(w);			/* dialogue bounced */
	via (w->slider)(w);
	if (changed)
		do_redraw(w,w->wa);
	via (w->winfo)(w);
#ifdef PRINFO
	print_it(w,"wdial_size");
#endif
}

static
FULLED wdial_full
{
	bool changed;
	if ( w->full)		/* all these values are allready snapped */
	{
		w->rem=w->nfrem;
		w->full=false;
	othw
		w->rem=w->frem;
		w->full=true;
	}
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	changed = w_bounce(w);
	via (w->slider)(w);
	if (changed)
		do_redraw(w,w->wa);
	via (w->winfo)(w);
#ifdef PRINFO
	print_it(w,"wdial_full");
#endif
}

static
SLIDE wdial_slide
{
	if ( w->vslp ne vslp )
	{
		STMNR old = w->norm.pos.y;

		w->vslp = vslp;
		wind_set(w->wh, WF_VSLIDE, vslp);

		w->norm.pos.y = ((w->view.sz.h-w->norm.sz.h)*vslp)/1000;
		w_bounce(w);
		if (w->norm.pos.y ne old)
		{
			via (w->slider)(w);
#if !FASTRACK
				do_redraw(w, w->wa);
#else
				if (!topw or is_beyond_scr(w))
					do_redraw(w, w->wa);
				elif (old > w->norm.pos.y)
					rack_up(w, old);
				else
					rack_dn(w, old);
#endif
		}
	}

	if ( w->hslp ne hslp)
	{
		short old = w->norm.pos.x;

		w->hslp = hslp;
		wind_set(w->wh, WF_HSLIDE, hslp);

		w->norm.pos.x = (((long)w->view.sz.w-w->norm.sz.w)*hslp)/1000;
		w_bounce(w);
		if (w->norm.pos.x ne old)
		{
			via (w->slider)(w);
			do_redraw(w, w->wa);
		}
	}
	via (w->winfo)(w);
#ifdef PRINFO
	print_it(w, "wdial_slide");
#endif
}

static
ARROWD wdial_arrowed		/* IT *w, short arrow, bool topw */
{
	RECT clip = w->wa;
	short ht = 4,
		  vt = 1,
	      h  = w->norm.sz.w-1,
		  v  = w->norm.sz.h-2;
	STMNR oldtop = w->norm.pos.y;

	if (arrow <= WA_DNLINE)
	{
		switch (arrow)
		{
		case WA_UPPAGE:
			vt = v;
		case WA_UPLINE:
			w->norm.pos.y -= vt;
			w_bounce(w);
			if (w->norm.pos.y ne oldtop)
			{
				via (w->slider)(w);
#if !FASTRACK
				do_redraw(w,clip);
#else
				if (!topw or is_beyond_scr(w))
					do_redraw(w,clip);	/* over rectangle list debug: ins_msg */
				else
					rack_up(w, oldtop);
#endif
			}
		break;
		case WA_DNPAGE:
			vt = v;
		case WA_DNLINE:
			w->norm.pos.y += vt;
			w_bounce(w);
			if (w->norm.pos.y ne oldtop)
			{
				via (w->slider)(w);
#if !FASTRACK
				do_redraw(w,clip);
#else
				if (!topw or is_beyond_scr(w))
					do_redraw(w,clip);
				else
					rack_dn(w, oldtop);
#endif
			}
		break;
		}
	othw
		short old=w->norm.pos.x;

		switch (arrow)
		{
		case WA_LFPAGE:				/* blad naar links */
			w->norm.pos.x-=h;
		break;
		case WA_RTPAGE:				/* blad naar rechts */
			w->norm.pos.x+=h;
		break;
		case WA_LFLINE:				/* kolom naar links */
			w->norm.pos.x-=ht;
		break;
		case WA_RTLINE:				/* kolom naar rechts */
			w->norm.pos.x+=ht;
		break;
		}
		w_bounce(w);
		if (w->norm.pos.x ne old)
		{
			via (w->slider)(w);
			do_redraw(w,clip);
		}
	}
}

global
IT * create_dialw(char *name, short tree, OBJECT *o, short item, WINIT winit, VpW fresh, DEXIT d_do)
{
	IT *w =
	create_IT	(	false,		/* do NOT create window itself */
					name,
					-1,
					" on ",
					nil,
					DKIND,
					tree,		/* tree index as window type */
					nil,
					nil,
					o,			/* OBJECT tree */
					wdial_place,	/* calc x & y when moved */
					item,		/* start item for draw */
					winit,
					d_do,		/* handling after 'exit' object */
					nil,			/* antedraw; prepare dialogue tree for find, resp replace */
					nil,			/* draw: standard done by objc_draw (for clipping) */
					post_wdial,			/* postdraw */
					wdial_evm,			/* antevnt */
					nil,nil,nil,nil,
				#if (DKIND&CLOSER)
					wdial_close,
				#else
					nil,
				#endif
					wdial_delete,
					nil,	/* top_dialalogue, standard */
				#if (DKIND&FULLER)
					wdial_full,
				#else
					nil,
				#endif
				#if (DKIND&(VSLIDE|HSLIDE))
					wdial_slide,
					v_slider,
				#else
					nil,
					nil,
				#endif
				#if (DKIND&(UPARROW|LFARROW))
					wdial_arrowed,
				#else
					nil,
				#endif
				#if (DKIND&SIZER)
					wdial_size,
				#else
					nil,
				#endif
				#if (DKIND&MOVER)
					movewindow,
				#else
					nil,
				#endif
					wdial_button,
					wdial_keybd,
					wdial_edkey,
					wdial_timer,
					nil,nil,nil,nil,/* no menu in this window */
					nil,nil,nil,	/* no text selections */
					wdial_cur,
					nil, nil, 
					nil,			/* no specific mouse form */
					nil,nil,
					deskw.unit,
					points,
					nil
				);
	if (w)
	{
		w->view.sz.w = o[item].w/w->unit.w;
		w->view.sz.h = o[item].h/w->unit.h;
		w->dial.action = fresh;
		w->dial.edon = ON;
	}
	return w;
}

#if SUBSTITUTE

char pri[81];

#if HAVE_IMAGES
static
OBJECT *radio_slct, *radio_deslct;
static
short radio_bgcol;
#endif

static
short vdi_handle = -1;
extern
short phys_handle,hchar,wchar,points;			/* ex main.c */


/*----------------------------------------------------------------------------------------*/
/* USERDEF-Funktion fr Check-Button																		*/
/* Funktionsresultat:	nicht aktualisierte Objektstati												*/
/* parmblock:			Zeiger auf die Parameter-Block-Struktur									*/
/*----------------------------------------------------------------------------------------*/

#define CHECK_GLYF 1

static
void	userdef_text( short x, short y, void *string )
{
	vswr_mode( vdi_handle, MD_TRANS );
	v_gtext( vdi_handle, x, y, string );
	vswr_mode( vdi_handle, MD_REPLACE );
}

static
void c_clip(GRECT c)
{
	if (c.x or c.y or c.w or c.h)	/* PROFIBUCH page 565 */
		gsclip( vdi_handle, ON, c);
}

static
short cdecl check_button( PARMBLK *parmblock )
{
	short rect[4];
	short  xy[10];
	/* Clipping rectangle: The 1 that is given to objc_draw(). */
	c_clip(parmblock->clip);
	*(GRECT *) rect = parmblock->size;				/* Objekt-Rechteck... */
	rect[2] = rect[0] + hchar - 2;
	rect[3] = rect[1] + hchar - 2;

	xy[0] = rect[0];
	xy[1] = rect[1];
	xy[2] = rect[2];
	xy[3] = rect[1];
	xy[4] = rect[2];
	xy[5] = rect[3];
	xy[6] = rect[0];
	xy[7] = rect[3];
	xy[8] = rect[0];
	xy[9] = rect[1];
	v_pline( vdi_handle, 5, xy );					/* schwarzen Rahmen zeichnen */

	xy[0] = rect[0] + 1;
	xy[1] = rect[1] + 1;
	xy[2] = rect[2] - 1;
	xy[3] = rect[3] - 1;

	vswr_mode( vdi_handle, MD_REPLACE);
	vr_recfl( vdi_handle, xy );						/* weiže Box zeichnen */
	vswr_mode( vdi_handle, MD_TRANS);

	if ( parmblock->currstate & SELECTED )
	{
		static char check[2]={8,0};
		parmblock->currstate &= ~SELECTED;			/* Bit l”schen */
	#if CHECK_GLYF
		v_gtext( vdi_handle, rect[0]+wchar/2, rect[1]-1, check);
	#else
		xy[0] = rect[0] + 2;
		xy[1] = rect[1] + 2;
		xy[2] = rect[2] - 2;
		xy[3] = rect[3] - 2;
		v_pline( vdi_handle, 2, xy );

		xy[1] = rect[3] - 2;
		xy[3] = rect[1] + 2;
		v_pline( vdi_handle, 2, xy );
	#endif
	}

	v_gtext(vdi_handle, parmblock->size.x + hchar + wchar, parmblock->size.y, parmblock->P.text );
	return( parmblock->currstate );
}

/*------------------------------------------------------------------*/
/* USERDEF-Funktion fr Radio-Button								*/
/* Funktionsresultat:	nicht aktualisierte Objektstati				*/
/* parmblock:			Zeiger auf die Parameter-Block-Struktur		*/
/*------------------------------------------------------------------*/

static
short cdecl radio_button( PARMBLK *parmblock )
{
	short rect[4];
	short  xy[4];

	c_clip(parmblock->clip);    /* Zeichenoperationen auf gegebenen Bereich beschr„nken */

	*(GRECT *) rect = parmblock->size;				/* Objekt-Rechteck... */
	rect[2] = rect[0] + hchar - 2;
	rect[3] = rect[1] + hchar - 2;

	v_rbox( vdi_handle, rect );						/* schwarzen Round box zeichnen */

	xy[0] = rect[0] + 1;
	xy[1] = rect[1] + 1;
	xy[2] = rect[2] - 1;
	xy[3] = rect[3] - 1;

	vswr_mode( vdi_handle, MD_REPLACE);
	v_rfbox( vdi_handle, xy );						/* weiže Box zeichnen */

	if ( parmblock->currstate & SELECTED )
	{
		parmblock->currstate &= ~SELECTED;			/* Bit l”schen */

		vsf_color( vdi_handle, 1 );					/* schwarz - fr das button */
		xy[0] = rect[0] + 3;
		xy[1] = rect[1] + 3;
		xy[2] = rect[2] - 3;
		xy[3] = rect[3] - 3;
		v_rfbox( vdi_handle, xy );
		vsf_color( vdi_handle, 0 );					/* weiž  */
	}
	vswr_mode( vdi_handle, MD_TRANS);

	v_gtext(vdi_handle, parmblock->size.x + hchar + wchar, parmblock->size.y, parmblock->P.text);

	return( parmblock->currstate );
}

#if HAVE_IMAGES
static
short cdecl radio_button( PARMBLK *parmblock )
{
	BITBLK	*image;
	MFDB	src;
	MFDB	des;
	short xy[8];
	short image_colors[2];

	c_clip(parmblock->clip);

	if ( parmblock->currstate & SELECTED )			/* Selektion? */
	{
		parmblock->currstate &= ~SELECTED;			/* Bit l”schen */
		image = radio_slct->spec.bitblk;
	}
	else
		image = radio_deslct->spec.bitblk;

	src.fd_addr = image->data;
	src.fd_w = image->wb * 8;
	src.fd_h = image->hl;
	src.fd_wdwidth = image->wb / 2;
	src.fd_stand = 0;
	src.fd_nplanes = 1;
	src.fd_r1 = 0;
	src.fd_r2 = 0;
	src.fd_r3 = 0;

	des.fd_addr = nil;

	xy[0] = 0;
	xy[1] = 0;
	xy[2] = src.fd_w - 1;
	xy[3] = src.fd_h - 1;
	xy[4] = parmblock->size.x;
	xy[5] = parmblock->size.y;
	xy[6] = xy[4] + xy[2];
	xy[7] = xy[5] + xy[3];

	image_colors[0] = 1;			/* schwarz als Vordergrundfarbe */
	image_colors[1] = radio_bgcol;	/* Hintergrundfarbe */

	vrt_cpyfm( vdi_handle, MD_REPLACE, xy, &src, &des, image_colors );
	v_gtext(vdi_handle, parmblock->size.x + hchar + wchar, parmblock->size.y, parmblock->P.text );

	return( parmblock->currstate );
}
#endif

/*------------------------------------------------------------------*/
/* USERDEF-Funktion fr Gruppen-Rahmen								*/
/* Funktionsresultat:	nicht aktualisierte Objektstati				*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur	*/
/*------------------------------------------------------------------*/
static
short cdecl group( PARMBLK *parmblock )
{
	short ob[4];
	short xy[12];

	c_clip(parmblock->clip);

	*(GRECT *) ob = *(GRECT *) &parmblock->size.x;		/* Objekt-Rechteck... */
	ob[2] += ob[0] - 1;
	ob[3] += ob[1] - 1;

	xy[0] = ob[0] + wchar;
	xy[1] = ob[1] + hchar / 2;
	xy[2] = ob[0];
	xy[3] = xy[1];
	xy[4] = ob[0];
	xy[5] = ob[3];
	xy[6] = ob[2];
	xy[7] = ob[3];
	xy[8] = ob[2];
	xy[9] = xy[1];
	xy[10] = (short) ( xy[0] + strlen( parmblock->P.text ) * wchar );
	xy[11] = xy[1];

	v_pline( vdi_handle, 6, xy );

	v_gtext(vdi_handle, ob[0] + wchar, ob[1], parmblock->P.text );

	return( parmblock->currstate );
}

/*--------------------------------------------------------------*/
/* USERDEF-Funktion fr šberschrift								*/
/* Funktionsresultat:	nicht aktualisierte Objektstati			*/
/* parmblock:			Zeiger auf die Parameter-Block-Struktur	*/
/*--------------------------------------------------------------*/
static
short cdecl ob_title( PARMBLK *parmblock )
{
	short xy[4];
	c_clip(parmblock->clip);

	v_gtext(vdi_handle, parmblock->size.x, parmblock->size.y, parmblock->P.text );

	xy[0] = parmblock->size.x;
	xy[1] = parmblock->size.y + parmblock->size.h;
	xy[2] = parmblock->size.x + parmblock->size.w - 1;
	xy[3] = xy[1];
	v_pline( vdi_handle, 2, xy );

	return( parmblock->currstate );
}

extern short aes_flags,aes_font,MagX_version;
extern bool MagX;

/*------------------------------------------------------------------*/
/* MagiC-Objekte durch USERDEFs ersetzen							*/
/* Funktionsergebnis:	-											*/
/* obs:			Zeiger auf die Objekte								*/
/*	aes_flags:	Informationen ber das AES							*/
/*	rslct:		Zeiger auf Image fr selektierten Radio-Button		*/
/*	rdeslct:	Zeiger auf Image fr deselektierten Radio-Button	*/
/*------------------------------------------------------------------*/
#if HAVE_IMAGES
global
void *substitute_objects( OBJECT *obs, bool menu, OBJECT *rslct, OBJECT *rdeslct)
#else
global
void *subst_objects( OBJECT *obs, bool menu)
#endif
{
	USERBLK	*ublks = nil;
	OBJECT	*ob;
	short no_subs;

/*	if (( aes_flags & GAI_MAGIC ) && ( MagX_version >= 0x0300 ))	/* MagiC-AES? */
		return nil;
*/
	if (( aes_flags & GAI_WHITEBAK ) != 0)		/* MagiC objects are there */
		return nil;

	ob = obs;				/* Zeiger auf die Objekte */
	no_subs = 0;

	do{
		if (( ob->state & WHITEBAK ) && ( ob->state & 0x8000 ))	/* MagiC-Objekt? */
			switch ( ob->type & 0xff )
			{			/* Checkbox, Radiobutton oder Gruppenrahmen? */
			case	G_BUTTON:
#if HAVE_IMAGES
				if (   ( ob->flags & RBUTTON ) ne 0		/* Radio-Button? */
					and rslct eq nil )					/* have picture? */
					break;
#endif
				no_subs++;
			break;
			case	G_STRING:	/* šberschrift? */
				no_subs++;
			break;
			}
		if ( ob->flags & LASTOB )
			break;
		ob++;
	}od

	if ( no_subs )		/* sind MagiC-Objekte vorhanden? */
	{
#if HAVE_IMAGES
		radio_slct = rslct;
		radio_deslct = rdeslct;
#endif
		ublks = xmalloc( no_subs * sizeof( USERBLK ), AH_UBBLK);
		if ( ublks )		/* Speicher vorhanden? */
		{
			USERBLK	*tmp; short i, dum;
			short wi[12],
				  wo[57];

			if (vdi_handle < 0)
			{
				vdi_handle = phys_handle;
				for(i=0;i<=10;wi[i++]=1);
				wi[10]=2;
				v_opnvwk(wi,&vdi_handle,wo);		/* returns in ref handle virtual workstation's handle */
				if (vdi_handle eq 0)				/* 05'17 HR check */
					return nil;
				vst_font( vdi_handle, aes_font );				/* Font einstellen */
				vst_color( vdi_handle, 1 );						/* schwarz */
				vst_effects( vdi_handle, 0 );					/* keine Effekte */
				vst_alignment( vdi_handle, 0, 5, &dum, &dum );	/* an der Zeichenzellenoberkante ausrichten */
				vst_height( vdi_handle, points, &dum, &dum, &dum, &dum );
				vsl_type( vdi_handle, 1 );
				vsl_color( vdi_handle, 1 );
				vswr_mode( vdi_handle, MD_TRANS );
				vsf_color( vdi_handle, 0 );					/* weiž  */
			}

			tmp = ublks;
			ob = obs;				/* Zeiger auf die Objekte */

			do{
				short type;
				ushort state;

				type = ob->type & 0x00ff;
				state = (uint) ob->state;

				if (menu and type eq G_STRING and (aes_flags&GAI_GSHORTCUT))
					ob->type = G_SHORTCUT;
				if (( state & WHITEBAK ) && ( state & 0x8000 ))	/* MagiC-Objekt? */
				{
					state &= 0xff00;				/* nur das obere char ist interessant */

					if ( aes_flags & GAI_MAGIC )	/* altes MagiC-AES? */
					{
						if (( type == G_BUTTON ) && ( state == 0xfe00 ))
						{	/* Gruppenrahmen? */
							tmp->ub_parm = (long) ob->spec.free_string;	/* Zeiger auf den Text */
							tmp->ub_code = group;

							ob->type = G_USERDEF;
							ob->flags &= ~FL3DMASK;		/* 3D-Flags l”schen */
							ob->spec.userblk = tmp;		/* Zeiger auf den USERBLK */

							tmp++;
						}
					othw							/* TOS-AES oder sonstiges */
						switch ( type )
						{
							case	G_BUTTON:			/* Checkbox, Radiobutton oder Gruppenrahmen? */
								tmp->ub_parm = (long) ob->spec.free_string;	/* Zeiger auf den Text */

								if ( state == 0xfe00 )			/* Gruppenrahmen? */
									tmp->ub_code = group;
								elif ( ob->flags & RBUTTON )	/* Radio-Button? */
#if HAVE_IMAGES
									if (rslct)					/* had picture ? */
										tmp->ub_code = radio_button;
									else
										break;
#else
									tmp->ub_code = radio_button;
#endif
								else							/* Check-Button */
									tmp->ub_code = check_button;

								ob->type = G_USERDEF;
								ob->flags &= ~FL3DMASK;			/* 3D-Flags l”schen */
								ob->spec.userblk = tmp;			/* Zeiger auf den USERBLK */

								tmp++;
							break;
							case	G_STRING:					/* šberschrift? */
								if ( state == 0xff00 )			/* Unterstreichung auf voller L„nge? */
								{
									tmp->ub_parm = (long) ob->spec.free_string;	/* Zeiger auf den Text */
									tmp->ub_code = ob_title;
									ob->type = G_USERDEF;
									ob->flags &= ~FL3DMASK;		/* 3D-Flags l”schen */
									ob->spec.userblk = tmp;		/* Zeiger auf den USERBLK */
									tmp++;

								}
							break;
						}
					}
				}
				if (ob->flags&LASTOB)
					break;
				ob++;														/* n„chstes Objekt */
			}od
		}
	}
	return ublks;			/* per tree */
}

/*----------------------------------------------*/
/* Speicher fr Resource-Anpassung freigeben	*/
/* Funktionsresultat:	-						*/
/*----------------------------------------------*/
global
void	subst_free( USERBLK *ublks )
{
	if ( ublks )		/* Speicher vorhanden? */
		xfree( ublks );
	if (vdi_handle > 0)
		v_clsvwk(vdi_handle),
		vdi_handle = -1;

}

#else
#if HAVE_IMAGES
global
void *substitute_objects( OBJECT *obs, bool menu, OBJECT *rslct, OBJECT *rdeslct)
#else
global
void *subst_objects( OBJECT *obs, bool menu)
#endif
{}
void subst_free( USERBLK *ublks ) {}
#endif