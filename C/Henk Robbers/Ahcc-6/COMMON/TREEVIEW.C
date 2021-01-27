/*  Copyright (c) 2012- present by Henk Robbers Amsterdam.
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

/*	TREEVIEW.C
 *	==========
 *
 *	Routines for showing a tree view in a window.
 */

#define TRVKIND    (NAME|MOVER|CLOSER|VSLIDE|UPARROW|DNARROW)

#define __MINT__
#include <string.h>
#include <ext.h>

#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "common/mallocs.h"
#include "aaaa.h"
#include "common/kit.h"
#include "cursor.h"
#include "common/options.h"
#include "common/cursor.h"
#include "files.h"
#include "common/ahcm.h"
#include "common/treeview.h"

void send_msg (char *, ...);
short alert_msg(char *t, ... );

global
RECT norect = {0,0,0,0};

global
void trv_draw(IT *w, NSP np)
{
	hidem;
	while (np)
	{
		np->r = norect;
		if (np->ln >= w->norm.pos.y and w->trv.y+hchar <= w->wa.y+w->wa.h)
			trv_line(w, np);
		if (np->d)
			trv_draw(w, np->d);
		np = np->n;
	}
	showm;
}

static
int which_arrow(int wheel, int clicks)
{
	if (wheel eq 0)
		if (clicks < 0)
			return WA_UPLINE;
		else
			return WA_DNLINE;
	elif (wheel eq 1)
		if (clicks < 0)
			return WA_LFLINE;
		else
			return WA_RTLINE;
	else
		return 0;
}

static
ANTEVNT trv_evm		/* IT *w; bool w_on; short evmask */
{
	evmask |= MU_M1;
	if (w_on)
		evmask |= MU_BUTTON|MU_KEYBD;

	return evmask;
}

static
TOPPED trv_top			/* (struct it *nw, struct it *ow) */
{
	to_top();
	wind_set(nw->wh,WF_TOP);
}

#if TRVKIND&SIZE
SIZED trv_sizew
{
	snapwindow(w,to);
	w->rem=*to;
	wind_set(w->wh,WF_CURRXYWH,*to);
	get_work(w);
	w->norm.pos.y  = bounce(w,w->norm.pos.y);
	do_redraw(w, w->wa);
	via (w->slider)(w);
}
#endif

static
MOVED trv_movew
{
	snapwindow(w,to);
	w->rem=*to;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	get_work(w);
	do_redraw(w, w->wa);
}

global
IT * treeview_window(Cstr name,
                    void *root,
                    Cstr pname,
					WINIT *winit,
					DRAW *draw,
					SELECT *select,
					CLOSED *closer,
					KEYBD *keybd,
					WICON *write_icon,
					MENU_DO *do_menu,
					M_S *wmenu,
					INFO_T type)
{
	IT * w = create_IT(true,
				name,
				0,
				nil,
				nil,
				TRVKIND,
				type,
				root,
				pname,
				nil,
				nil,
				0,			/* item */
				winit,
				nil,		/* DEXIT */
				nil,
				draw,
				nil,
				trv_evm,
				nil,
				nil,
				nil,
				nil,
				closer,
				nil,
				nil,
				nil,
				slidewindow,		/*	general */
				v_slider,			/*	general */
				arrowwindow,		/*	general */
#if TRVKIND&SIZE
				trv_sizew,
#else
				nil,
#endif
				trv_movew,
				trv_button,
				keybd,
				nil,
				nil,
				menu_draw,
				do_menu,
				nil,
				wmenu,
				select,
				nil,
				nil,
				nil,			/* cursor */
				nil,
				nil,
				nil,			/* mouse */
				nil,
				0L,
				deskw.unit,
				0,		/* 07'20 HR v6 */
				13,
				0,
				nil
				);

#ifdef COFT
	if (w)
	{
		w->trv.wicon = write_icon;
		w->trv.dp    = root;
		w->norm.pos.y = 0;
	}
#endif
	return w;
}

global
NSP trv_new_nest(Cstr name)
{
	static short count = 0;
	NSP new;
	short l = strlen(name);

	new = calloc(1,sizeof(Nest)+l+1);
	if (new)
	{
		strcpy(new->trv_txt,name);
		new->count = ++count;
	}
	return new;
}

static
bool greater(NSP new, NSP n)
{
	if (new->f > n->f)		/* folders first */
		return true;
	if (new->f eq n->f and stricmp(new->trv_txt,n->trv_txt) > 0)
		return true;
	return false;
}

global
void trv_spacer(NSP np)
{
	NSP new = trv_new_nest("");		/* spacer */
	if (new)
	{
		new->f = EMP;
		trv_add_nest(np, new, 0);
	}
}

global
NSP trv_add_nest(NSP in, NSP new, bool sort)
{
	new->o = in;
	if (in->d eq nil)
	{
		in->d = new;
		new->dep = in->dep+1;
	othw
		NSP n = in->d,
		    np = n;
		new->dep = n->dep;

		do{

			if (!sort or (sort and greater(new,n)))
			{
				if (n->n eq nil)	/* must put at end */
				{
					n->n = new;
					break;
				}
			othw
				if (n eq in->d)
					in->d = new;
				else
					np->n = new;
				new->n = n;
				break;
			}
			np = n;
			n = n->n;
		}od

	}
	return new;
}

global
void trv_del_nest(NSP np)	/* free deeper of np (keep np itself) */
{
	NSP dp = np->d;
	if (dp)
	{
		while(dp->n)
		{
			NSP n = dp->n;
			trv_del_nest(n);
			free(dp);
			dp = n;
		}
		np->d = nil;
	}
}

global
NSP trv_find_sel(NSP np)
{
	while(np)
	{
		NSP dp;
		if (np->state&SELECTED)
			return np;
		dp = trv_find_sel(np->d);
		if (dp)
			return dp;
		np = np->n;
	}
	return np;
}

static
NSP find_xy(NSP np, short x, short y)
{
	while(np)
	{
		NSP dp;
		if (m_inside(x,y,np->r))
			return np;
		dp = find_xy(np->d,x,y);
		if (dp)
			return dp;
		np = np->n;
	}
	return np;
}
/*
static
NSP find_y(NSP np, short y)
{
	while(np)
	{
		NSP dp;
		if (np->r.y < y and y < np->r.y + np->r.h)
			return np;
		dp = find_y(np->d,y);
		if (dp)
			return dp;
		np = np->n;
	}
	return np;
}
*/
global
NSP trv_find_ln(NSP np, short ln)
{
	while(np)
	{
		NSP dp;
		if (ln <= np->ln)
			break;
		dp = trv_find_ln(np->d, ln);
		if (dp)
			return dp;
		np = np->n;
	}
	return np;
}

static void trv_select(IT *w, NSP fx, short b)
{
#ifdef TEXTFILE
	if (b > 1 and fx->trv_txt)
		open_text_file(fx->trv_txt);
	else
#endif
	{
		w->trv.sel = fx;
		via (w->select)(w);
	}
}

static
BUTTON trv_button
{
	NSP fx = find_xy(w->trv.root,mx,my);
	if (fx)
		trv_select(w, fx, button);
/*	else
	{
		fx = find_y(w->trv.root,my);
		if (fx)
		{
			int x = fx->r.x;
			if (mx < x)
			{

				while(x-VLINE_W > mx and fx->o)
					fx = fx->o, x-=VLINE_W;
				trv_select(w, fx->o, button);
			}
		}
	}
*/
}

static
void v_lin(short hl, short x, short y)
{
	line(hl,x+wchar,y,x+wchar,y+hchar-1);
}

static
void e_lin(short hl,short x, short y)
{
	short x1 = x+wchar, y1 = y+hchar/2;

	line(hl,x1,y,x1,y1);
	line(hl,x1,y1,x+VLINE_W-1,y1);
}

static
void h_lin(short hl,short x, short y)
{
	short y1 = y+hchar/2;
	v_lin(hl,x,y);
	line(hl,x+wchar,y1,x+VLINE_W-1,y1);

}

static
short vlines(short hl,NSP np, short x, short y)
{
	if (np and np->dep)
	{
		x = vlines(hl,np->o,x,y);
		if (np->n)
			if (np->n->f ne EMP)
				v_lin(hl,x,y);
		x += VLINE_W;
	}
	return x;
}

static
void hlines(short hl,NSP np, short x, short y)
{
	if (np and np->dep)
	{
		x = vlines (hl,np->o,x,y);
		if (np->f ne EMP)
		{
			if (!np->n or (np->n and np->n->f eq EMP) )
				e_lin(hl,x,y);
			else
				h_lin(hl,x,y);
		}
	}
}

static
WICON trv_icon /* (short hl, RECT r, bool op, bool sel, bool kleur) */
{
	RECT ri;
	short hh = half_h(),
	      ww = wchar,
	      h1, w1;

	if (hh < hchar)
		ww *= 2;

	ri.x = r.x+1;
	ri.y = r.y+1;
	ri.w = ww  ;
	ri.h = ww-1;
	h1 = ri.h/2;
	w1 = ri.w/2;
	gsbox(hl, ri);

	/* minus */
	line(hl,ri.x+2, ri.y+h1  , ri.x+ri.w-3, ri.y + h1  );
	if (hh < hchar)
		line(hl,ri.x+2, ri.y+h1-1, ri.x+ri.w-3, ri.y + h1-1);
	if (!op)
	{	/* make it a plus */
		if (hh < hchar)
			line(hl, ri.x+w1-1, ri.y+2, ri.x+w1-1, ri.y+ri.h-3);
		line(hl, ri.x+w1  , ri.y+2, ri.x+w1  , ri.y+ri.h-3);
	}

	if (sel)
	{
		ri.x += 1, ri.y += 1, ri.w -= 2, ri.h -= 2;
		vswr_mode(hl, 3);
		vsf_color(hl, 1);
		gspbox   (hl, ri);
		vswr_mode(hl, 0);
		vsf_color(hl, 0);
	}
}

static
char vspa[] = "   ";

global
void trv_linenrs(IT *w, NSP np)
{
	while (np)
	{
		short t = np->dep*strlen(vspa)+strlen(np->trv_txt)+2;
		if (np->f eq NEST /* and np->d eq nil*/)
			t+=2;  /* ->-> */

		np->ln = ++w->view.sz.h;
		if (t > w->norm.sz.w)
			w->norm.sz.w = t;
		trv_linenrs(w, np->d);
		np = np->n;
	}
}

global
void trv_deselect(IT *w, NSP np)
{
	while (np)
	{
		np->state&=~SELECTED;
		trv_deselect(w, np->d);
		np = np->n;
	}
}

static
void trv_line(IT *w, NSP np)
{
	short rl, i;
	RECT r;
	char ln[2*MAXL+1], *p = ln, *q = ln;

	short y  = w->trv.y,
	      hl = w->vhl;
	w->line = ln;

	*p = 0;	 /* for xcat */
	i = np->dep;
	while (i--) p = xcat(p,vspa);					/* fill up */

	r.x = (p-(w->line+w->norm.pos.x))*wchar+w->wa.x;		/* RECT r for clicking */
	r.y = y;
	r.w = 0;
	r.h = 0;

	if (np->f ne EMP)		/* else only vline's */
	{
		p = xcat(p, " ");
		if (np->f eq NEST)
			p = xcat(p, "  ");		/* placeholder for icon */

		p = xcpy(p,np->trv_txt);

		if (*np->trv_x)
			p = xcat(p, np->trv_x);
	}

	r.w = (p-(w->line+w->norm.pos.x))*wchar+w->wa.x - r.x;
	r.h = hchar;

	np->r = r;
	rl = p - q; /* strlen(w->line); */

	if (rl > w->norm.pos.x)
		v_gtext(hl,w->wa.x,y,w->line+w->norm.pos.x);

	if (np->f eq NEST)
	{
		via(w->trv.wicon)(hl,r,np->d ne nil, (np->state&SELECTED) ne 0, scr.kleuren > 2);
		else
			trv_icon(hl,r,np->d ne nil, (np->state&SELECTED) ne 0, scr.kleuren > 2);	/* standard (+,-) icon */
	}

	hlines(hl,np,w->wa.x-w->norm.pos.x*wchar,y);

	if (np->state&SELECTED and np->f eq TERM)
	{
		vswr_mode(hl,3);
		vsf_color(hl,1);
		gpbox(hl,r.x+wchar,r.y,r.w-wchar,r.h);
		vswr_mode(hl,0);
		vsf_color(hl,0);
	}

	if ( r.x + r.w < w->wa.x + w->wa.w )			/* erase rest of line */
	{
		short ew = r.x+r.w;
		r.x += r.w;
		r.w = (w->wa.x+w->wa.w) - ew;
		if (r.w > 0)
			gspbox(hl,r);
	}

	w->trv.y = y + hchar;
}

global
void trv_adjust(IT *w, NSP np)
{
	RECT wa = w->wa;
	short to;
	w->norm.sz.h = (win.h-w->v.h)/hchar;
	if (w->view.sz.h < w->norm.sz.h)
	{
		w->norm.sz.h = w->view.sz.h;
		w->norm.pos.y = 0;
	}
	elif (np->subs+1 > w->norm.sz.h)
	{
		w->norm.sz.h = np->subs+1;
		w->norm.pos.y = np->ln - 1;
	}
	else
	{
		to = np->ln - w->norm.pos.y + np->subs;
		if (to > w->norm.sz.h)
			w->norm.pos.y += to - w->norm.sz.h;
	}

	if (w->norm.sz.w > (win.w/wchar)+w->v.w)
		w->norm.sz.w = win.w/wchar;
	if (w->norm.sz.h > (win.h/hchar)+w->v.h)
		w->norm.sz.h = win.h/hchar;
	wa.w = (w->norm.sz.w/*+1*/)*wchar + w->v.w;
	wa.h =  w->norm.sz.h   *hchar + w->v.h;
	wa.x += w->v.x;
	wa.y += w->v.y;
	snapwindow(w, &wa);
	wa = fit_inside(wa, wwa);

	wind_set(w->wh, WF_CURRXYWH, wa);
	w->norm.pos.y  = bounce(w,w->norm.pos.y);
	w->view.sz.w = w->norm.sz.w;
	get_work(w);
	do_redraw(w, w->wa);
	via(w->slider)(w);
}
